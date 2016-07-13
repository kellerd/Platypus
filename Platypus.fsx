#load "Language.fsx"
#load "Parser.fsx"
open Language
open Parser
open System

//More basic parsers

let many1 p = parse {
    let! head = p
    let! tail = many p
    return OneOrMany<_>.OfList head tail
} 

let sepBy1 p seperator = parse {
    let split = parse {
        let! _ = seperator
        let! cap = p
        return cap
    }
    let! head = p
    let! tail = many split
    return OneOrMany<_>.OfList head tail
}

let sepBy p seperator =
    (sepBy1 p seperator |>> OneOrMany<_>.ToList) <|> ( retn [])

let parseAny = 
    fun str -> 
        match String.length str with
        | 0 -> Failure "No more input"
        | 1 -> Success (str.[0], String.Empty)
        | _ -> Success (str.[0], str.[1..])
    |> Parser

let parseChar charToMatch =
    fun str ->
        match runParser parseAny str with
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
        |> List.map parseChar
        |> choice

let charListToStr charList = 
     String(List.toArray charList)

let parseString (stringToMatch:string) = 
    stringToMatch.ToCharArray() 
    |> Array.map parseChar 
    |> Array.toList 
    |> sequence 
    |>> charListToStr

let betweenC cbefore p cend = between (parseChar cbefore) p (parseChar cend)

//Lexical definition

let inputCharacter = [0..255] |> List.map (Convert.ToChar) |> anyOf
let lineTerminator = parseChar '\r' >>. parseChar '\n' <|> anyOf ['\n';'\r']
let whiteSpace =  anyOf ['\t';'\f';'\v';' '] <|> lineTerminator
let commentCharacter = notp lineTerminator &&. parseAny
let comment = 
    let commentStart = parseString "\\>"
    let middle = many commentCharacter
    between commentStart middle lineTerminator
let anyWhitespace = many ((many1 whiteSpace |>> ignore) <|> (comment |>> ignore))
let ignoreSpace p = anyWhitespace >>. p .>> anyWhitespace

let (.>->.) a b = a .>> anyWhitespace .>>. b
let (.>->) a b = a .>> anyWhitespace .>> b
let (>->.) a b = a >>. anyWhitespace >>. b
let letter = anyOf (['a' .. 'z'] @ ['A' .. 'Z'])
let digit = anyOf ['0' .. '9']
let letterOrDigit = letter <|> digit
let baseIdent = 
    letter .>>. many letterOrDigit 
let arithmeticIdentifier = 
    baseIdent
    |>> (List.Cons >> List.truncate 16 >> charListToStr >> ArithmeticVariableIdentifier)
let stringIdentifier = 
    baseIdent 
    |>> (List.Cons >> List.truncate 15) .>>. parseChar '$' 
    |>> (fun (list,nd) ->  
        list @ [nd] |> charListToStr |>  StringVariableIdentifier)
let PLATYPUS = parseString "PLATYPUS"
let IF = parseString "IF"
let THEN = parseString "THEN"
let ELSE = parseString "ELSE"
let FOR = parseString "FOR"
let DO = parseString "DO"
let READ = parseString "READ"
let WRITE = parseString "WRITE"
let strToHex hexStr = Convert.ToInt16(hexStr,16)
let hexDigit = anyOf (['0' ..'9'] @ ['A' .. 'F'])
let nonZeroDigit = anyOf ['1' .. '9']
let decimalInteger = 
   (nonZeroDigit .>>. many digit |>> (List.Cons >> charListToStr)) <|> parseString "0" 
let hexIntegerLiteral = 
    parseString "0h" >>. many1 hexDigit 
    |>> (OneOrMany<_>.ToList >> charListToStr)
let integerLiteral = (hexIntegerLiteral |>> strToHex)  <|> (decimalInteger |>> Convert.ToInt16)  |>> NumberLiteral.Short
let prefixFloat = decimalInteger .>>. parseString "." .>>. many digit
let postfixFloat = retn "0" .>>. parseString "." .>>. (many1 digit |>> OneOrMany<_>.ToList)
let floatingPointLiteral = 
    prefixFloat <|> postfixFloat 
    |>> fun ((pre,dec),post) -> (Convert.ToSingle(pre + dec + (charListToStr post))  |> NumberLiteral.Single)

let stringLiteral = 
    let quot = parseChar '"'
    let stringCharacter = notp quot &&. inputCharacter
    between quot (many stringCharacter) quot
    |>> (charListToStr >> StringLiteral)
let comma = parseChar ','
let statementSeparator = parseChar ';'
let assignmentOp = parseString "=" |>>! AssignOp
let AND = parseString "AND" |>>! And
let OR = parseString "OR" |>>! Or
let relationalOp = 
    choice [
        parseString ">" |>>! Gt;
        parseString "<" |>>! Lt;
        parseString "==" |>>! Eq;
        parseString "!="  |>>! Ne]
        
let stringConcatOp =  parseString "<<" |> ignoreSpace
let additiveOp = choice [parseString "+" |>>! Plus;
                          parseString "-" |>>! Minus]
let multiplicativeOp = choice [parseString "*" |>>! Mul;
                                parseString "/" |>>! Div]

let betweenParens p = 
    betweenC '(' (ignoreSpace p) ')'
    |> between anyWhitespace <| anyWhitespace
let betweenBrace p = 
    betweenC '{' (ignoreSpace p) '}'
    |> between anyWhitespace <| anyWhitespace
//Semantic
let primaryStringExpression =  ((stringIdentifier |>> SVar) <|> (stringLiteral |>> SLiteral)) |> ignoreSpace
let stringExpression = sepBy1 primaryStringExpression stringConcatOp |> ignoreSpace

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

let arithmeticExpression = 
    let rec parsedArithExpression a = 
        (notp parseEOF) >>= (fun _ -> 
            choice [
                additiveArithmeticExpression a |>> Add
                unaryArithmeticExpression a;] |> ignoreSpace)
    and unaryArithmeticExpression a=  
        additiveOp .>->. (primaryArithmeticExpression a) |> ignoreSpace |>> Unary
    and additiveArithmeticExpression a = 
        (multiplicativeArithmeticExpression a) .>->. many (additiveArithmeticExpression' a    .>> anyWhitespace) |> ignoreSpace
        |>> fun (primary,additive) ->
            let rec makeAdditive = function
                | (mul,[]) -> Multiplicative mul
                | (mul,(op,mul2)::tail) -> (makeAdditive(mul,tail),op,mul2) |> AddOpExpr
            makeAdditive (primary,additive)
    and additiveArithmeticExpression' a = 
        additiveOp .>->. (multiplicativeArithmeticExpression a)   |> ignoreSpace
    and multiplicativeArithmeticExpression a = 
        (primaryArithmeticExpression a) .>->. many (multiplicativeArithmeticExpression' a    .>> anyWhitespace)  |> ignoreSpace
        |>> fun (primary,multiplicative) ->
            let rec makeMultiplicative = function
                | (primary,[]) -> Primary primary
                | (primary,(op,primary2)::tail) -> (makeMultiplicative(primary,tail),op,primary2) |> MulOpExpr
            makeMultiplicative (primary,multiplicative)
    and multiplicativeArithmeticExpression' a = 
        multiplicativeOp .>->. (primaryArithmeticExpression a)  |> ignoreSpace
    and primaryArithmeticExpression a = 
                choice [arithmeticIdentifier |>> Var;
                    floatingPointLiteral |>> Literal;
                    integerLiteral |>> Literal;
                    betweenParens (parsedArithExpression a) |>> Expr]    |> ignoreSpace
    parsedArithExpression () |>> mapArithmeticExpression

let stringAssignment = stringIdentifier .>-> assignmentOp .>->. stringExpression |>> StringAssignment
let arithmeticAssignment = arithmeticIdentifier .>-> assignmentOp .>->. arithmeticExpression |>> ArithmeticAssignment
let assignmentExpression = (stringAssignment <|> arithmeticAssignment) |>ignoreSpace
    
let assignmentStatement =  
    (notp parseEOF) >>= (fun _ ->
    assignmentExpression .>-> statementSeparator |> ignoreSpace
    |>> Assign     
    )
let optStatementSep = opt statementSeparator
let optAssign = opt assignmentExpression  
let primaryArithmeticRelationalExpression = 
    choice [
        arithmeticIdentifier |>> PrimeRelAVid;
        floatingPointLiteral |>> PrimaryRelALit
        integerLiteral |>> PrimaryRelALit;
    ]  |> ignoreSpace
let primaryStringRelationalExpression = 
    choice [
        stringIdentifier |>> PrimaryRelSVid
        stringLiteral |>> PrimaryRelSLit
    ] |> ignoreSpace
let arithmeticRelationalExpression = primaryArithmeticRelationalExpression .>->. relationalOp .>->. primaryArithmeticRelationalExpression
let stringRelationalExpression = primaryStringRelationalExpression .>->. relationalOp .>->. primaryStringRelationalExpression 
let relationalExpression = 
    choice [
        arithmeticRelationalExpression |>> (untuple >> Arith);
        stringRelationalExpression |>> (untuple >> Str)] |> ignoreSpace |>> JustRelational

let logicalOp = AND <|> OR
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

let conditionalExpression = 
    relationalExpression .>->. many (logicalOp .>->. relationalExpression .>-> anyWhitespace)
    |>> mapConditional
let variableList = sepBy1 ((stringIdentifier |>> SVID) <|> (arithmeticIdentifier |>> AVID)) (ignoreSpace comma)
let inputStatement = 
    READ >->. (betweenParens variableList) .>-> statementSeparator
    |>> (Read >> Input)
let outputLine = 
    fun str -> 
        match runParser variableList str, runParser stringLiteral str with
        | Success (vars,remaining), _ -> Success(Vars vars,remaining)
        | _, Success (strLiterals,remaining) -> Success(StringOutputLine strLiterals,remaining)
        | _,_ -> Success(Empty,str)
    |> Parser

let outputStatement = 
    WRITE >->. (betweenParens outputLine) .>-> statementSeparator
    |>> (Write >> Output)

let statement =
    let rec statement a = 
        (notp parseEOF) >>= (fun _ ->
        choice [assignmentStatement;
        selectionStatement a;
        iterStatement a;
        inputStatement;
        outputStatement] |> ignoreSpace)
    and selectionStatement a = 
        IF >->. betweenParens conditionalExpression .>-> THEN .>->. 
        (many1 (statement a) |> betweenBrace ) .>->. 
        opt (
            ELSE >->. 
            (many1 (statement a) |> betweenBrace )
        ) .>-> optStatementSep
        |>> fun ((c,ifStatements),optElse) ->
            Select(c,ifStatements,optElse)
    and iterStatement a = 
        FOR >->. betweenParens (optAssign.>-> comma .>->. conditionalExpression .>-> comma .>->. optAssign) .>->
        DO .>->. ( many (statement a) |> betweenBrace) .>-> optStatementSep 
        |>> fun (((assOp,cond),assOp2),statements) ->
            Iter(assOp,cond,assOp2,statements)
    statement()


let program = PLATYPUS >->. (statement |> many |>  betweenBrace) |> ignoreSpace .>>. parseEOF |>> Platypus 

let buffer file = System.IO.File.ReadAllText file
let one dir f = 
    IO.Path.Combine (__SOURCE_DIRECTORY__, dir, f) 
    |> buffer 