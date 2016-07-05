#load "Expr.fsx"
open Expr
open System
type Result<'a>  = 
    | Success of 'a
    | Failure of string
type Parser<'T> = Parser of (string -> Result<'T * string>)

let untuple ((x,y),z) = x,y,z
let retn x = (fun s -> Success(x, s))
             |> Parser
let failParse err = (fun _ -> Failure(err))
                    |> Parser
let Zero = retn ()

let run (Parser parser) input = 
    parser input
let orElse p1 p2 = 
    fun str ->
        match run p1 str with
        | Success (value,left) ->  Success(value,left)
        | Failure (err) -> 
            match run p2 str with
            | Success (value, left) -> Success(value,left)
            | Failure _ -> Failure(err)
    |> Parser       
let andAlso p1 p2 = 
    fun str ->
        match run p1 str with
        | Success (value,_) ->  
            match run p2 str with
            | Success (value2, left) -> Success((value,value2),left)
            | Failure err -> Failure(err)
        | Failure (err) -> Failure(err)
    |> Parser 

let bind f x =
    (fun input -> 
        match run x input with
        | Success(value,left) -> run (f value) left
        | Failure err -> Failure err)
    |> Parser 
type ParserBuilder() = 
    member ___.Bind(m,f) = bind f m
    member ___.Return(x) = retn x
    member ___.ReturnFrom(p) = p
    member ___.Zero() = Zero
    
let parse = new ParserBuilder()

let map f = bind (f >> retn)

let andThen p1 p2 = parse {
    let! p1' = p1
    let! p2' = p2
    return p1',p2'
}     
   
let apply fParser xValue = parse {
    let! f = fParser
    let! x = xValue 
    return f x
}

let (>>=) p f = bind f p
let (<!>) = map 
let (<*>) = apply 
let (|>>) p f = map f p
let (|>>!) p f = map (fun _ -> f) p
let (<|>) = orElse
let (.&&.) = andAlso
let (.&&) p1 p2 = p1 .&&. p2 |>> fst
let (&&.) p1 p2 = p1 .&&. p2 |>> snd
let (.>>.) = andThen
let (.>>) p1 p2 = p1 .>>. p2 |>> fst
let (>>.) p1 p2 = p1 .>>. p2 |>> snd

let lift2 f xP yP =
    retn f <*> xP <*> yP
let rec parseZeroOrMore parser input =
    match run parser input  with
    | Failure _ -> ([],input)  
    | Success (firstValue,inputAfterFirstParse) -> 
        let (subsequentValues,remainingInput) = 
            parseZeroOrMore parser inputAfterFirstParse
        (firstValue::subsequentValues,remainingInput)  

let many p = parseZeroOrMore p >> Success |> Parser
let many1 p = parse {
    let! head = p
    let! tail = many p
    return 
        match tail with 
        | [] -> One(head)
        | xs -> Many(head,tail)
} 
let opt p = (p |>> Some) <|> (retn None)    
let between p1 p2 p3 = p1 >>. p2 .>> p3

let sepBy1 p seperator = parse {
    let split = parse {
        let! _ = seperator
        let! cap = p
        return cap
    }
    let! first = p
    let! rest = many split
    return first::rest
}

let sepBy p seperator =
    sepBy1 p seperator <|> retn []

let choice listOfParsers = 
        List.reduce ( <|> ) listOfParsers 

let parseAny = 
    fun str -> 
        match String.length str with
        | 0 -> Failure "No more input"
        | 1 -> Success (str.[0], String.Empty)
        | _ -> Success (str.[0], str.[1..])
    |> Parser

let parseEOF = 
    fun str -> 
        match String.length str with
        | 0 -> Success ((), str)
        | _ -> Failure "More input"
    |> Parser
    |>> fun _ -> SEOF
let pchar charToMatch = parse {
    let! c = parseAny
    if c = charToMatch then 
        return c 
    else 
        return! failParse "Not same char"
}
let betweenC cbefore p cend = between (pchar cbefore) p (pchar cend)

let rec sequence parsers = 
    let cons head tail = head::tail
    let consLifted = lift2 cons
    match parsers with
    | [] ->
        retn []
    | head::tail -> consLifted head (sequence tail)

let charListToStr charList = 
     String(List.toArray charList)
let pstring (stringToMatch:string) = 
    stringToMatch.ToCharArray() 
    |> Array.map pchar 
    |> Array.toList 
    |> sequence 
    |>> charListToStr
let notp p  = 
    fun str ->
        match run p str with
        | Success _ -> Failure "Matched, failing notp"
        | Failure _ -> Success((),str)
    |> Parser
let anyOf listOfChars = 
        listOfChars
        |> List.map pchar
        |> choice

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
let pFloatingPointLiteral = pPrefixFloat <|> pPostfixFloat |>> fun ((pre,dec),post) -> (Convert.ToSingle(pre + dec + (charListToStr post))  |> NumberLiteral.Single)
let pStringLiteral = 
    let quot = pchar '"'
    let pStringCharacter = notp quot &&. pInputCharacter
    between quot (many pStringCharacter) quot
    |>> (charListToStr >> StringLiteral)
let pComma = pchar ','
let pStatementSeparator = pchar ';'
let pAssignmentOp = pstring "=" |>>! AssignOp
let pAnd = pstring "AND"
let pOr = pstring "OR"
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

// let rec logicalAndExprPrime prime = 
//     opt (pAnd >>. pRelationalExpression .>>. (logicalAndExprPrime prime))
//     |>> prime
// let pLogicalAndExpression = 
//     pRelationalExpression .>>. (logicalAndExprPrime LogicAnd)
//     |>> LogicalAndExpression
// let rec pLogicalOrExprPrime prime= 
//     opt (pOr >>. pLogicalAndExpression .>>. (pLogicalOrExprPrime prime))
//     |>> prime
// let pLogicalOrExpression = 
//     pLogicalAndExpression .>>. (pLogicalOrExprPrime LogicOr)
//     |>> LogicalOrExpression


// let pConditionalExpression = pLogicalOrExpression

let pVariableList = many pVariableIdentifier
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
    pREAD >>. (pBetweenParens pOutputLine) .>> pStatementSeparator
    |>> (Write >> Output)
let rec pStatement () = 
    choice [pAssignmentStatement;
    //pSelectionStatement;
    //pIterStatement;
    pInputStatement;pOutputStatement]
and oneOrMoreStatements = many1 (pStatement())
and optStatements = many (pStatement())
// and pSelectionStatement = 
//     pIF >>. pBetweenParens pConditionalExpression .>> pTHEN .>>. 
//     (pBetweenBrace oneOrMoreStatements) .>>. 
//     opt (
//         pELSE >>. 
//         (pBetweenBrace oneOrMoreStatements)
//     ) .>> optStatementSep
//     |>> fun ((c,ifStatements),optElse) ->
//         Select(c,ifStatements,optElse)
// and pIterStatement = 
//     pFOR >>. pBetweenParens (optAssign.>> pComma .>>. pConditionalExpression .>> pComma .>>. optAssign) .>>
//     pDO .>>. (pBetweenBrace optStatements) .>> optStatementSep 
//     |>> fun (((assOp,cond),assOp2),statements) ->
//         Iter(assOp,cond,assOp2,statements)

let pProgram = pPLATYPUS >>. pBetweenBrace optStatements .>>. parseEOF |>> Platypus 

let buffer file = System.IO.File.ReadAllText file
let getFile f = IO.Path.Combine (__SOURCE_DIRECTORY__, "..\\", f)

"a4unary.pls" |> getFile |> buffer |> run pProgram

run pProgram "PLATYPUS{}"