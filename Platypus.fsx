#load "Language.fsx"
#load "Parser.fsx"
open Language
open Parser
open System

//More basic parsers

let many1 p = parse {
    let! head = p
    let! tail = many p
    return OneOrMany<_>.ofList head tail
} 

let sepBy1 p seperator = parse {
    let split = parse {
        let! _ = seperator
        let! cap = p
        return cap
    }
    let! head = p
    let! tail = many split
    return OneOrMany<_>.ofList head tail
}

let sepBy p seperator =
    (sepBy1 p seperator |>> OneOrMany<_>.toList) <|> ( retn [])

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
        printfn "Matched %c" c
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
let pStringExpression = sepBy1 pPrimaryStringExpression pStringConcatOp

let rec pArithExpression a = 
    (notp parseEOF) >>= (fun _ -> 
        choice [
            pAdditiveArithmeticExpression a |>> Add
            pUnaryArithmeticExpression a;])
and pUnaryArithmeticExpression a=  
    pAdditiveOp .>>. (pPrimaryArithmeticExpression a)  |>> Unary
and pAdditiveArithmeticExpression a = 
    (pMultiplicativeArithmeticExpression a) .>>. many (pAdditiveArithmeticExpression' a)
    |>> fun (primary,additive) ->
        let rec MakeAdditive = function
            | (mul,[]) -> Multiplicative primary
            | (mul,(op,mul2)::tail) -> (MakeAdditive(mul,tail),op,mul2) |> AddOpExpr
        MakeAdditive (primary,additive)
and pAdditiveArithmeticExpression' a = 
    pAdditiveOp .>>. (pMultiplicativeArithmeticExpression a) 
and pMultiplicativeArithmeticExpression a = 
    (pPrimaryArithmeticExpression a) .>>. many (pMultiplicativeArithmeticExpression' a) 
    |>> fun (primary,multiplicative) ->
        let rec MakeMultiplicative = function
            | (primary,[]) -> Primary primary
            | (primary,(op,primary2)::tail) -> (MakeMultiplicative(primary,tail),op,primary2) |> MulOpExpr
        MakeMultiplicative (primary,multiplicative)
and pMultiplicativeArithmeticExpression' a = 
    pMultiplicativeOp .>>. (pPrimaryArithmeticExpression a) 
and pPrimaryArithmeticExpression a = 
            choice [pArithmeticIdentifier |>> Var;
                pFloatingPointLiteral |>> Literal;
                pHexIntegerLiteral |>> (strToHex >> Short >> Literal);
                pIntegerLiteral |>> Literal;
                pBetweenParens (pArithExpression a) |>> Expr]
run (pArithExpression () ) "-a"
run (pArithExpression () ) "+5.0"
run (pArithExpression () ) "0hF"
run (pArithExpression () ) "-(a-5.0)"
run (pArithExpression () ) "1/3+7+(3*10)"
// and pArithExpression a = 
//     choice [pUnaryArithmeticExpression a;
//             pAdditiveArithmeticExpression a |>> Add]

     


let pAssignmentExpression = parse {
    let! variable = (pStringIdentifier .>> pAssignmentOp |>> SVID) <|> (pArithmeticIdentifier .>> pAssignmentOp |>> AVID)
    return!  
         match variable with 
                | SVID(vid) -> parse {
                    let! expr = pStringExpression
                    return StringAssign(vid,expr)
                    }
                | AVID (vid) ->  parse {
                    let! expr = pArithExpression() 
                    return ArithmeticAssign(vid,expr)
                }
}
let pAssignmentStatement =  
    (notp parseEOF) >>= (fun _ ->
    pAssignmentExpression .>> pStatementSeparator
    |>> fun statement -> Assign statement     
    )
run (pAssignmentExpression) "a$=b$<<c$<<\"abc\""

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
        pString |>> (untuple >> Str)] |>> JustRelational

let pLogicalOp = pAnd <|> pOr
let pConditionalExpression = 
    pRelationalExpression .>>. many (pLogicalOp .>>. pRelationalExpression)
    |>> fun input ->
            //After matching higher order, recurse
            let rec mapConditional = function 
                | rl, [] -> rl |> JustAnd 
                | baseRl, (Or,rl1)::(And,JustRelational(rl2))::tail -> 
                    (baseRl,(Or,LogicalAnd(rl1,rl2))::tail) |> mapConditional
                | baseRl, (Or,rl1)::(And,a)::tail -> 
                    (baseRl,(Or,LogicalAnd(rl1,LExpr(JustAnd(a))))::tail) |> mapConditional 
                | baseRl, (Or,rl1)::tail -> 
                    (JustRelational(LExpr(LogicalOr(JustAnd(baseRl),rl1))),tail) |> mapConditional
                | baseRl, (And,JustRelational(rl2))::tail -> 
                    (LogicalAnd(baseRl,rl2),tail) |> mapConditional
                | baseRl, (And,a)::tail -> 
                    (LogicalAnd(baseRl,LExpr(JustAnd(a))),tail) |> mapConditional
            mapConditional input
let pVariableList = sepBy1 ((pStringIdentifier |>> SVID) <|> (pArithmeticIdentifier |>> AVID)) pComma
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

let pStatement =
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
    pStatement()
let pProgram = pPLATYPUS >>. (pStatement |> many |>  pBetweenBrace) .>>. parseEOF |>> Platypus 

// let buffer file = System.IO.File.ReadAllText file
// let getFile f = IO.Path.Combine (__SOURCE_DIRECTORY__, "Sample Code\\", f)

run pProgram "PLATYPUS{IF(\"1\"==\"2\"OR\"3\"==\"4\"AND\"5\"==\"6\")THEN{WRITE(\"a\");};}"
run pProgram "PLATYPUS{FOR(,\"1\"==\"2\"OR\"3\"==\"4\"AND\"5\"==\"6\",)DO{WRITE(\"a\");};}"
run pProgram "PLATYPUS{WRITE(a,b,c);}"