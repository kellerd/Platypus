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

let pchar charToMatch =
    fun str ->
        match run parseAny str with
        | Success (c,rest) when c = charToMatch -> Success(c,rest)
        | Success(c,rest) -> Failure (sprintf "Not same char. Wanted: %c, Got: %c: rest is: %s" charToMatch c rest)
        | Failure(err) -> Failure(err)
    |> Parser

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
let pIgnore = many ((many1 pWhiteSpace |>> ignore) <|> (pComment |>> ignore))
let maybeSpace p = pIgnore >>. p .>> pIgnore

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
   (pNonZeroDigit .>>. many pDigit |>> (List.Cons >> charListToStr)) <|> pstring "0" 
let pHexIntegerLiteral = 
    pstring "0h" >>. many1 pHexDigit 
    |>> (OneOrMany<_>.toList >> charListToStr)
let pIntegerLiteral = (pHexIntegerLiteral |>> strToHex)  <|> (pDecimalInteger |>> Convert.ToInt16)  |>> NumberLiteral.Short
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
        
let pStringConcatOp =  pstring "<<" |> maybeSpace
let pAdditiveOp = choice [pstring "+" |>>! Plus;
                          pstring "-" |>>! Minus]
let pMultiplicativeOp = choice [pstring "*" |>>! Mul;
                                pstring "/" |>>! Div]

let pBetweenParens p = betweenC '(' (maybeSpace p) ')'
                      |> between pIgnore <| pIgnore
let pBetweenBrace p = betweenC '{' (maybeSpace p) '}'
                      |> between pIgnore <| pIgnore
//Semantic
let pPrimaryStringExpression =  ((pStringIdentifier |>> SVar) <|> (pStringLiteral |>> SLiteral)) |> maybeSpace
let pStringExpression = sepBy1 pPrimaryStringExpression pStringConcatOp |> maybeSpace

let rec mapArithmeticExpression (expr:ParsedArithmeticExpression) : ArithmeticExpression = 
    match expr with 
    | Unary(Minus,primary) ->
        (ArithmeticLiteral(Short(-1s)), Mul, mapPrimary primary) |> Arithmetic
    | Unary(Plus,primary) ->
        (ArithmeticLiteral(Short(0s)), Mul, mapPrimary primary) |> Arithmetic
    | Add(expr) -> mapAdditive expr
    | Unary(_) -> failwith "Not implemented yet"
and mapAdditive = function
    | AddOpExpr(expr,op,mul) -> (mapAdditive expr,op,mapMultiplicative mul) |> Arithmetic
    | Multiplicative(expr) -> mapMultiplicative expr 
and mapMultiplicative = function
    | MulOpExpr (expr, op ,primary) -> (mapMultiplicative expr,op,mapPrimary primary) |> Arithmetic
    | Primary (primary) -> mapPrimary primary
and mapPrimary = function
    | Var(var) -> ArithmeticVariable var 
    | Expr(expr) -> mapArithmeticExpression expr
    | Literal(lit) ->  ArithmeticLiteral lit




let pArithmeticExpression = 
    let rec pParsedArithExpression a = 
        (notp parseEOF) >>= (fun _ -> 
            choice [
                pAdditiveArithmeticExpression a |>> Add
                pUnaryArithmeticExpression a;] |> maybeSpace)
    and pUnaryArithmeticExpression a=  
        pAdditiveOp .>->. (pPrimaryArithmeticExpression a) |> maybeSpace |>> Unary
    and pAdditiveArithmeticExpression a = 
        (pMultiplicativeArithmeticExpression a) .>->. many (pAdditiveArithmeticExpression' a    .>> pIgnore) |> maybeSpace
        |>> fun (primary,additive) ->
            let rec makeAdditive = function
                | (mul,[]) -> Multiplicative mul
                | (mul,(op,mul2)::tail) -> (makeAdditive(mul,tail),op,mul2) |> AddOpExpr
            makeAdditive (primary,additive)
    and pAdditiveArithmeticExpression' a = 
        pAdditiveOp .>->. (pMultiplicativeArithmeticExpression a)   |> maybeSpace
    and pMultiplicativeArithmeticExpression a = 
        (pPrimaryArithmeticExpression a) .>->. many (pMultiplicativeArithmeticExpression' a    .>> pIgnore)  |> maybeSpace
        |>> fun (primary,multiplicative) ->
            let rec makeMultiplicative = function
                | (primary,[]) -> Primary primary
                | (primary,(op,primary2)::tail) -> (makeMultiplicative(primary,tail),op,primary2) |> MulOpExpr
            makeMultiplicative (primary,multiplicative)
    and pMultiplicativeArithmeticExpression' a = 
        pMultiplicativeOp .>->. (pPrimaryArithmeticExpression a)  |> maybeSpace
    and pPrimaryArithmeticExpression a = 
                choice [pArithmeticIdentifier |>> Var;
                    pFloatingPointLiteral |>> Literal;
                    pIntegerLiteral |>> Literal;
                    pBetweenParens (pParsedArithExpression a) |>> Expr]    |> maybeSpace
    pParsedArithExpression () |>> mapArithmeticExpression

let pStringAssign = pStringIdentifier .>-> pAssignmentOp .>->. pStringExpression |>> StringAssign
let pArithmeticAssign = pArithmeticIdentifier .>-> pAssignmentOp .>->. pArithmeticExpression |>> ArithmeticAssign
let pAssignmentExpression = (pStringAssign <|> pArithmeticAssign) |>maybeSpace
    
let pAssignmentStatement =  
    (notp parseEOF) >>= (fun _ ->
    pAssignmentExpression .>-> pStatementSeparator |> maybeSpace
    |>> Assign     
    )
let optStatementSep = opt pStatementSeparator
let optAssign = opt pAssignmentExpression  
let pPrimaryArithmeticRelationalExpression = 
    choice [
        pArithmeticIdentifier |>> PrimeRelAVid;
        pFloatingPointLiteral |>> PrimaryRelALit
        pIntegerLiteral |>> PrimaryRelALit;
    ]  |> maybeSpace
let pPrimaryStringRelationalExpression = 
    choice [
        pStringIdentifier |>> PrimaryRelSVid
        pStringLiteral |>> PrimaryRelSLit
    ] |> maybeSpace
let pArith = pPrimaryArithmeticRelationalExpression .>->. pRelationalOp .>->. pPrimaryArithmeticRelationalExpression
let pString = pPrimaryStringRelationalExpression .>->. pRelationalOp .>->. pPrimaryStringRelationalExpression 
let pRelationalExpression = 
    choice [
        pArith |>> (untuple >> Arith);
        pString |>> (untuple >> Str)] |> maybeSpace |>> JustRelational

let pLogicalOp = pAnd <|> pOr
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

let pConditionalExpression = 
    pRelationalExpression .>->. many (pLogicalOp .>->. pRelationalExpression .>-> pIgnore)
    |>> mapConditional
let pVariableList = sepBy1 ((pStringIdentifier |>> SVID) <|> (pArithmeticIdentifier |>> AVID)) (maybeSpace pComma)
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
        choice [pAssignmentStatement;
        pSelectionStatement a;
        pIterStatement a;
        pInputStatement;pOutputStatement] |> maybeSpace)
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


let pProgram = pPLATYPUS >->. (pStatement |> many |>  pBetweenBrace) |> maybeSpace .>>. parseEOF |>> Platypus 

let buffer file = System.IO.File.ReadAllText file
let one dir f = 
    IO.Path.Combine (__SOURCE_DIRECTORY__, dir, f) 
    |> buffer 