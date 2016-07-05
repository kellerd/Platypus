#load "Language.fsx"
#load "Parser.fsx"
open Language
open Parser
open System

//More basic parsers

let many1 p = parse {
    let! head = p
    let! tail = many p
    return 
        match tail with 
        | [] -> One(head)
        | xs -> Many(head,tail)
} 
let parseAny = 
    fun str -> 
        match String.length str with
        | 0 -> Failure "No more input"
        | 1 -> Success (str.[0], String.Empty)
        | _ -> Success (str.[0], str.[1..])
    |> Parser

let pchar charToMatch = parse {
    let! c = parseAny
    if c = charToMatch then 
        return c 
    else 
        return! failParse "Not same char"
}

let parseEOF = 
    fun str -> 
        match String.length str with
        | 0 -> Success ((), str)
        | _ -> Failure "More input"
    |> Parser
    |>> fun _ -> SEOF

let anyOf listOfChars = 
        listOfChars
        |> List.map pchar
        |> choice

let charListToStr charList = 
     String(List.toArray charList)

let pstring (stringToMatch:string) = 
    stringToMatch.ToCharArray() 
    |> Array.map pchar 
    |> Array.toList 
    |> sequence 
    |>> charListToStr

let betweenC cbefore p cend = between (pchar cbefore) p (pchar cend)

//Lexical definition

let pInputCharacter = [0..255] |> List.map (Convert.ToChar) |> anyOf
let pLineTerminator = pchar '\r' >>. pchar '\n' <|> anyOf ['\n';'\r']
let pWhiteSpace =  anyOf ['\t';'\f';'\v';' '] <|> pLineTerminator
let pCommentCharacter = notp pLineTerminator &&. parseAny
let pComment = 
    let commentStart = pstring "\\>"
    let middle = many pCommentCharacter
    between commentStart middle pLineTerminator
let pLetter = anyOf (['a' .. 'z'] @ ['A' .. 'Z'])
let pDigit = anyOf ['0' .. '9']
let pLetterOrDigit = pLetter <|> pDigit
let pBaseIdent = 
    pLetter .>>. many pLetterOrDigit 
let pArithmeticIdentifier = 
    pBaseIdent
    |>> (List.Cons >> List.truncate 16 >> charListToStr >> ArithmeticVariableIdentifier)
let pStringIdentifier = 
    pBaseIdent 
    |>> (List.Cons >> List.truncate 15) .>>. pchar '$' 
    |>> (fun (list,nd) ->  
        list @ [nd] |> charListToStr |>  StringVariableIdentifier)
let pVariableIdentifier = (pArithmeticIdentifier |>> AVID) <|> (pStringIdentifier |>> SVID)
let pPLATYPUS = pstring "PLATYPUS"
let pIF = pstring "IF"
let pTHEN = pstring "THEN"
let pELSE = pstring "ELSE"
let pFOR = pstring "FOR"
let pDO = pstring "DO"
let pREAD = pstring "READ"
let pWRITE = pstring "WRITE"
let keyword = choice [pPLATYPUS;pIF;pTHEN;pELSE;pFOR;pDO;pREAD;pWRITE]
let integerLiteral = parseAny |>> int16
let strToHex hexStr = Convert.ToInt16(hexStr,16)
let pHexDigit = anyOf (['0' ..'9'] @ ['A' .. 'F'])
let pNonZeroDigit = anyOf ['1' .. '9']
let pDecimalInteger = 
    pstring "0" <|> (pNonZeroDigit .>>. many pDigit |>> (List.Cons >> charListToStr)) 
let pHexIntegerLiteral = 
    pstring "0h" >>. many1 pHexDigit 
    |>> (OneOrMany<_>.toList >> charListToStr)
let pIntegerLiteral = (pDecimalInteger |>> Convert.ToInt16) <|> (pHexIntegerLiteral |>> strToHex) |>> NumberLiteral.Short
let pPrefixFloat = pDecimalInteger .>>. pstring "." .>>. many pDigit
let pPostfixFloat = retn "0" .>>. pstring "." .>>. (many1 pDigit |>> OneOrMany<_>.toList)
let pFloatingPointLiteral = 
    pPrefixFloat <|> pPostfixFloat 
    |>> fun ((pre,dec),post) -> (Convert.ToSingle(pre + dec + (charListToStr post))  |> NumberLiteral.Single)

let pStringLiteral = 
    let quot = pchar '"'
    let pStringCharacter = notp quot &&. pInputCharacter
    between quot (many pStringCharacter) quot
    |>> (charListToStr >> StringLiteral)
let pComma = pchar ','
let pStatementSeparator = pchar ';'
let pAssignmentOp = pstring "=" |>>! AssignOp
let pAnd = pstring "AND" |>>! And
let pOr = pstring "OR" |>>! Or
let pRelationalOp = 
    choice [
        pstring ">" |>>! Gt;
        pstring "<" |>>! Lt;
        pstring "==" |>>! Eq;
        pstring "!="  |>>! Ne]
        
let pStringConcatOp = pstring "<<"
let pAdditiveOp = choice [pstring "+" |>>! Plus;
                          pstring "-" |>>! Minus]
let pMultiplicativeOp = choice [pstring "*" |>>! Mul;
                                pstring "/" |>>! Div]

let pBetweenParens p = betweenC '(' p ')'
let pBetweenBrace p = betweenC '{' p '}'

//Semantic
let pPrimaryStringExpression = (pStringIdentifier |>> SVar) <|> (pStringLiteral |>> SLiteral)
let rec pStringExpression () = (pPrimaryStringExpression |>> SPrimary) <|> pConcatExpression
and pConcatExpression = pStringExpression() .>> pStringConcatOp .>>. pPrimaryStringExpression |>> ConcatExpr


let rec pPrimaryArithmeticExpression() = 
    choice [pArithmeticIdentifier |>> Var;
            pIntegerLiteral |>> Literal;
            pFloatingPointLiteral |>> Literal
            pBetweenParens (pArithExpression()) |>> Expr] 
and pUnaryArithmeticExpression () =  pAdditiveOp .>>. pPrimaryArithmeticExpression()  |>> Unary
and pArithExpression () = 
    choice [pUnaryArithmeticExpression();
            pAdditiveArithmeticExpression() |>> Add]
and pMultiplactiveArithmeticExpression () =
    choice [
        pMultiplactiveArithmeticExpression () .>>. pMultiplicativeOp .>>. pPrimaryArithmeticExpression () |>> (untuple >> MulOpExpr)
        pPrimaryArithmeticExpression() |>> Primary
    ]
and pAdditiveArithmeticExpression() = 
    choice [pAdditiveArithmeticExpression () .>>. pAdditiveOp .>>. pMultiplactiveArithmeticExpression()  |>> (untuple >> AddOpExpr) ;
            pMultiplactiveArithmeticExpression () |>> Multiplicative]        

let pAssignmentExpression = parse {
    let! variable = pVariableIdentifier .>> pAssignmentOp 
    return!  
         match variable with 
                | SVID(vid) -> parse {
                    let! expr = pStringExpression() 
                    return StringAssign(vid,expr)
                    }
                | AVID (vid) ->  parse {
                    let! expr = pArithExpression() 
                    return ArithmeticAssign(vid,expr)
                }
}
let pAssignmentStatement = 
    pAssignmentExpression .>> pStatementSeparator
    |>> fun statement -> Assign statement     


let optStatementSep = opt pStatementSeparator
let optAssign = opt pAssignmentExpression  
let pPrimaryArithmeticRelationalExpression = 
    choice [
        pArithmeticIdentifier |>> PrimeRelAVid;
        pIntegerLiteral |>> PrimaryRelALit;
        pFloatingPointLiteral |>> PrimaryRelALit
    ] 
let pPrimaryStringRelationalExpression = 
    choice [
        pStringIdentifier |>> PrimaryRelSVid
        pStringLiteral |>> PrimaryRelSLit
    ]
let pArith = pPrimaryArithmeticRelationalExpression .>>. pRelationalOp .>>. pPrimaryArithmeticRelationalExpression
let pString = pPrimaryStringRelationalExpression .>>. pRelationalOp .>>. pPrimaryStringRelationalExpression 
let pRelationalExpression = 
    choice [
        pArith |>> (untuple >> Arith);
        pString |>> (untuple >> Str)]
        
let pLogicalOp = pAnd <|> pOr
let pConditionalExpression = pRelationalExpression .>>. many (pLogicalOp .>>. pRelationalExpression)

let pVariableList = sepBy1 pVariableIdentifier pComma
let pInputStatement = 
    pREAD >>. (pBetweenParens pVariableList) .>> pStatementSeparator
    |>> (Read >> Input)
let pOutputLine = 
    fun str -> 
        match run pVariableList str, run pStringLiteral str with
        | Success (vars,remaining), _ -> Success(Vars vars,remaining)
        | _, Success (strLiterals,remaining) -> Success(StringOutputLine strLiterals,remaining)
        | _,_ -> Success(Empty,str)
    |> Parser

let pOutputStatement = 
    pWRITE >>. (pBetweenParens pOutputLine) .>> pStatementSeparator
    |>> (Write >> Output)

let rec pStatement a = 
    (notp parseEOF) >>= (fun _ ->
    choice [pAssignmentStatement;
    pSelectionStatement a;
    pIterStatement a;
    pInputStatement;pOutputStatement])
and pSelectionStatement a = 
    pIF >>. pBetweenParens pConditionalExpression .>> pTHEN .>>. 
    (pStatement a |> many1 |> pBetweenBrace ) .>>. 
    opt (
        pELSE >>. 
        (pStatement a |> many1 |> pBetweenBrace )
    ) .>> optStatementSep
    |>> fun ((c,ifStatements),optElse) ->
        Select(c,ifStatements,optElse)
and pIterStatement a = 
    pFOR >>. pBetweenParens (optAssign.>> pComma .>>. pConditionalExpression .>> pComma .>>. optAssign) .>>
    pDO .>>. (pStatement a |> many |>  pBetweenBrace) .>> optStatementSep 
    |>> fun (((assOp,cond),assOp2),statements) ->
        Iter(assOp,cond,assOp2,statements)

let pProgram = pPLATYPUS >>. (pStatement () |> many |>  pBetweenBrace) .>>. parseEOF |>> Platypus 

// let buffer file = System.IO.File.ReadAllText file
// let getFile f = IO.Path.Combine (__SOURCE_DIRECTORY__, "Sample Code\\", f)

run pProgram "PLATYPUS{FOR(,\"abcd\"==\"abcd\"OR\"abcd\"==\"abcd\"AND\"abcd\"==\"abcd\",)DO{};}"
run pProgram "PLATYPUS{WRITE(\"a\");}"