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
        return c 
    else 
        return! failParse (sprintf "Not same char : %c" charToMatch) 
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
let pIgnore = many ((many1 pWhiteSpace |>> fun _ -> ()) <|> (pComment |>> fun _ -> ()))
let (.>->.) a b = a .>> pIgnore .>>. b
let (.>->) a b = a .>> pIgnore .>> b
let (>->.) a b = a >>. pIgnore >>. b
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
        
let pStringConcatOp =  pIgnore >>. pstring "<<" .>> pIgnore
let pAdditiveOp = choice [pstring "+" |>>! Plus;
                          pstring "-" |>>! Minus]
let pMultiplicativeOp = choice [pstring "*" |>>! Mul;
                                pstring "/" |>>! Div]

let pBetweenParens p = betweenC '(' (pIgnore >>. p .>> pIgnore) ')'
                      |> between pIgnore <| pIgnore
let pBetweenBrace p = betweenC '{' (pIgnore >>. p .>> pIgnore) '}'
                      |> between pIgnore <| pIgnore
//Semantic
let pPrimaryStringExpression = pIgnore >>. (pStringIdentifier |>> SVar) <|> (pStringLiteral |>> SLiteral) .>> pIgnore
let pStringExpression = pIgnore >>. sepBy1 pPrimaryStringExpression pStringConcatOp .>> pIgnore

let rec pArithExpression a = 
    (notp parseEOF) >>= (fun _ -> 
        pIgnore >>. choice [
            pAdditiveArithmeticExpression a |>> Add
            pUnaryArithmeticExpression a;]    .>> pIgnore)
and pUnaryArithmeticExpression a=  
    pIgnore >>. pAdditiveOp .>->. (pPrimaryArithmeticExpression a)     .>-> pIgnore |>> Unary
and pAdditiveArithmeticExpression a = 
    pIgnore >>. (pMultiplicativeArithmeticExpression a) .>->. many (pAdditiveArithmeticExpression' a    .>> pIgnore)     .>> pIgnore
    |>> fun (primary,additive) ->
        let rec MakeAdditive = function
            | (mul,[]) -> Multiplicative primary
            | (mul,(op,mul2)::tail) -> (MakeAdditive(mul,tail),op,mul2) |> AddOpExpr
        MakeAdditive (primary,additive)
and pAdditiveArithmeticExpression' a = 
    pIgnore >>. pAdditiveOp .>->. (pMultiplicativeArithmeticExpression a)     .>> pIgnore
and pMultiplicativeArithmeticExpression a = 
    pIgnore >>. (pPrimaryArithmeticExpression a) .>->. many (pMultiplicativeArithmeticExpression' a    .>> pIgnore)     .>> pIgnore
    |>> fun (primary,multiplicative) ->
        let rec MakeMultiplicative = function
            | (primary,[]) -> Primary primary
            | (primary,(op,primary2)::tail) -> (MakeMultiplicative(primary,tail),op,primary2) |> MulOpExpr
        MakeMultiplicative (primary,multiplicative)
and pMultiplicativeArithmeticExpression' a = 
    pIgnore >>. pMultiplicativeOp .>->. (pPrimaryArithmeticExpression a)     .>> pIgnore
and pPrimaryArithmeticExpression a = 
            pIgnore >>. choice [pArithmeticIdentifier |>> Var;
                pFloatingPointLiteral |>> Literal;
                pHexIntegerLiteral |>> (strToHex >> Short >> Literal);
                pIntegerLiteral |>> Literal;
                pBetweenParens (pArithExpression a) |>> Expr]    .>> pIgnore


let pAssignmentExpression = parse {
    let! variable = (pStringIdentifier .>-> pAssignmentOp |>> SVID) <|> (pArithmeticIdentifier .>-> pAssignmentOp |>> AVID)
    return!  
         match variable with 
                | SVID(vid) -> parse {
                    let! expr = pIgnore >>. pStringExpression .>> pIgnore
                    return StringAssign(vid,expr)
                    }
                | AVID (vid) ->  parse {
                    let! expr = pIgnore >>. pArithExpression() .>> pIgnore
                    return ArithmeticAssign(vid,expr)
                }
}
let pAssignmentStatement =  
    (notp parseEOF) >>= (fun _ ->
    pIgnore >>. pAssignmentExpression .>-> pStatementSeparator .>> pIgnore
    |>> fun statement -> Assign statement     
    )
    
let optStatementSep = opt pStatementSeparator
let optAssign = opt pAssignmentExpression  
let pPrimaryArithmeticRelationalExpression = 
    pIgnore >>. choice [
        pArithmeticIdentifier |>> PrimeRelAVid;
        pIntegerLiteral |>> PrimaryRelALit;
        pFloatingPointLiteral |>> PrimaryRelALit
    ]  .>> pIgnore
let pPrimaryStringRelationalExpression = 
    pIgnore >>. choice [
        pStringIdentifier |>> PrimaryRelSVid
        pStringLiteral |>> PrimaryRelSLit
    ] .>> pIgnore
let pArith = pPrimaryArithmeticRelationalExpression .>->. pRelationalOp .>->. pPrimaryArithmeticRelationalExpression
let pString = pPrimaryStringRelationalExpression .>->. pRelationalOp .>->. pPrimaryStringRelationalExpression 
let pRelationalExpression = 
    pIgnore >>.
    choice [
        pArith |>> (untuple >> Arith);
        pString |>> (untuple >> Str)] .>> pIgnore |>> JustRelational

let pLogicalOp = pAnd <|> pOr
let pConditionalExpression = 
    pRelationalExpression .>->. many (pLogicalOp .>->. pRelationalExpression .>-> pIgnore)
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
let pVariableList = sepBy1 ((pStringIdentifier |>> SVID) <|> (pArithmeticIdentifier |>> AVID)) (pIgnore >>. pComma .>> pIgnore)
let pInputStatement = 
    pREAD >->. (pBetweenParens pVariableList) .>-> pStatementSeparator
    |>> (Read >> Input)
let pOutputLine = 
    fun str -> 
        match run pVariableList str, run pStringLiteral str with
        | Success (vars,remaining), _ -> Success(Vars vars,remaining)
        | _, Success (strLiterals,remaining) -> Success(StringOutputLine strLiterals,remaining)
        | _,_ -> Success(Empty,str)
    |> Parser

let pOutputStatement = 
    pWRITE >->. (pBetweenParens pOutputLine) .>-> pStatementSeparator
    |>> (Write >> Output)

let pStatement =
    let rec pStatement a = 
        (notp parseEOF) >>= (fun _ ->
        pIgnore >->. choice [pAssignmentStatement;
        pSelectionStatement a;
        pIterStatement a;
        pInputStatement;pOutputStatement]
        .>-> pIgnore)
    and pSelectionStatement a = 
        pIF >->. pBetweenParens pConditionalExpression .>-> pTHEN .>->. 
        (pStatement a |> many1 |> pBetweenBrace ) .>->. 
        opt (
            pELSE >->. 
            (pStatement a |> many1 |> pBetweenBrace )
        ) .>-> optStatementSep
        |>> fun ((c,ifStatements),optElse) ->
            Select(c,ifStatements,optElse)
    and pIterStatement a = 
        pFOR >->. pBetweenParens (optAssign.>-> pComma .>->. pConditionalExpression .>-> pComma .>->. optAssign) .>->
        pDO .>->. (pStatement a |> many |>  pBetweenBrace) .>-> optStatementSep 
        |>> fun (((assOp,cond),assOp2),statements) ->
            Iter(assOp,cond,assOp2,statements)
    pStatement()
let pProgram = pPLATYPUS >->. (pStatement |> many |>  pBetweenBrace) .>->. parseEOF |>> Platypus 

// let buffer file = System.IO.File.ReadAllText file
// let getFile f = IO.Path.Combine (__SOURCE_DIRECTORY__, "Sample Code\\", f)

run pProgram "PLATYPUS  
    \> Comment
    \> Comment
    \> Comment
 {IF(\"1\"==\"2\"OR\"3\"==\"4\"AND\"5\"==\"6\")THEN{WRITE(\"a\");};}"
run pProgram "PLATYPUS{FOR(,\"1\"==\"2\"OR\"3\"==\"4\"AND\"5\"==\"6\",)DO{WRITE(\"a\");};}"
run pProgram "PLATYPUS{WRITE(a,b,c);}"