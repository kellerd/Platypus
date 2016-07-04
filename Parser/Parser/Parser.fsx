#load "Expr.fsx"
open Expr
open System
type Result<'a>  = 
    | Success of 'a
    | Failure of string
type Parser<'T> = Parser of (string -> Result<'T * string>)
let retn x = (fun s -> Success(x, s))
             |> Parser
let failParse err = (fun _ -> Failure(err))
                    |> Parser
let Zero = retn ()

let run (Parser parser) input = 
    parser input
let orElse (Parser p1) (Parser p2) = 
    fun str ->
        match p1 str with
        | Success (value,left) ->  Success(value,left)
        | Failure (err) -> 
            match p2 str with
            | Success (value, left) -> Success(value,left)
            | Failure _ -> Failure(err)
    |> Parser       
let andAlso (Parser p1) (Parser p2) = 
    fun str ->
        match p1 str with
        | Success (value,_) ->  
            match p2 str with
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
    |>> (List.Cons >> List.truncate 16 >> charListToStr >> ArithmeticVariableIdentifier >> AVID)
let pStringIdentifier = 
    pBaseIdent 
    |>> (List.Cons >> List.truncate 15) .>>. pchar '$' 
    |>> (fun (list,nd) ->  
        list @ [nd] |> charListToStr |>  StringVariableIdentifier |> SVID)
let pVariableIdentifier = pArithmeticIdentifier <|> pStringIdentifier
let pPLATYPUS = pstring "PLATYPUS"
let pIF = pstring "IF"
let pTHEN = pstring "THEN"
let pELSE = pstring "ELSE"
let pFOR = pstring "FOR"
let pDO = pstring "DO"
let pREAD = pstring "READ"
let pWRITE = pstring "WRITE"
let keyword = pPLATYPUS <|> pIF <|> pTHEN <|> pELSE <|> pFOR <|> pDO <|> pREAD <|> pWRITE
let integerLiteral = parseAny |>> int16
let strToHex hexStr = Convert.ToInt16(hexStr,16)
let pHexDigit = anyOf (['0' ..'9'] @ ['A' .. 'F'])
let pNonZeroDigit = anyOf ['1' .. '9']
let pDecimalInteger = 
    pstring "0" <|> (pNonZeroDigit .>>. many pDigit |>> (List.Cons >> charListToStr)) 
let pHexIntegerLiteral = 
    pstring "0h" >>. many1 pHexDigit 
    |>> (OneOrMany<_>.toList >> charListToStr)
let pIntegerLiteral = pDecimalInteger <|> pHexIntegerLiteral
let pPrefixFloat = pDecimalInteger .>>. pstring "." .>>. many pDigit
let pPostfixFloat = retn "0" .>>. pstring "." .>>. (many1 pDigit |>> OneOrMany<_>.toList)
let pFloatingPointLiteral = pPrefixFloat <|> pPostfixFloat |>> fun ((pre,dec),post) -> pre + dec + (charListToStr post)
let pStringLiteral = 
    let quot = pchar '"'
    let pStringCharacter = notp quot &&. pInputCharacter
    between quot (many pStringCharacter) quot
    |>> charListToStr
let pSeparator = anyOf ['(';')';'{';'}';',';';';'"';'.';]
let pStatementSeparator = pchar ';'
let pAssignmentOp = pstring "="
let pLogicalOp = pstring "AND" <|> pstring "OR"
let pRelationalOp = pstring ">" <|> pstring "<" <|> pstring "==" <|> pstring "!=" 
let pStringConcatOp = pstring "<<"
let pArithmeticOp = pstring "+" <|> pstring "-" <|> pstring "*" <|> pstring "/" 

//Semantic
let pSAssignExpression vid = parse { 
    let! expr = pStringExpression 
    return StringAssign(vid,expr)
}
let pAAssignExpression vid = parse { 
    let! expr = pArithExpression 
    return ArithmeticAssign(vid,expr)
}            
let pAssignmentStatement = parse {
    let! variable = pVariableIdentifier .>> pAssignmentOp 
    let! expression = parse {
        match variable with 
        | SVID(vid) -> StringAssign(vid, parse {return! pSAssignExpression}) 
        | AVID (vid) -> ArithmeticAssign (vid, parse { return pArithExpression})
    }
    let! statement = expression .>> pStatementSeparator
    return Assign statement                  
}
let pSelectionStatement = 
    pIF >>. pConditionalExpression .>> pTHEN .>>. many1 pStatement .>>. opt (pELSE >>. many1 pStatement)
    |>> fun ((c,ifs),optElse) ->
        match (ifs,optElse) with

        Select(c,)
and pStatement = pAssignmentStatement <|> 
                 pSelectionStatement <|>
                 pIterStatement <|>
                 pInputStatement <|> 
                 pOutputStatement

let pProgram = pPLATYPUS >>. many pStatement .>>. parseEOF |>> Platypus
