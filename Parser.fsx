#load "Expr.fsx"
open Expr
open System
type Result<'a>  = 
    | Success of 'a
    | Failure of string
type Parser<'T> = Parser of (string -> Result<'T * string>)
let retn x = (fun s -> Success(x, s))
             |> Parser
let failParse err = (fun str -> Failure(err))
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
    member this.Bind(m,f) = bind f m
    member this.Return(x) = retn x
    member this.ReturnFrom(p) = p
    member this.Zero() = Zero
    
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
let (<*>) p f = apply f p
let (|>>) p f = map f p
let (<|>) = orElse
let (.&&.) = andAlso
let (.&&) p1 p2 = p1 .&&. p2 |>> fst
let (&&.) p1 p2 = p1 .&&. p2 |>> snd
let (.>>.) = andThen
let (.>>) p1 p2 = p1 .>>. p2 |>> fst
let (>>.) p1 p2 = p1 .>>. p2 |>> snd

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
    return head::tail
} 
let opt p = (p |>> Some) <|> (retn None)    
let between p1 p2 p3 = p1 >>. p2 .>> p3
let sepBy1 p seperator = parse {
    let split = parse {
        let! s = seperator
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

let anyOf listOfChars = 
        listOfChars
        |> List.map pchar // convert into parsers
        |> choice

let pInputCharacter = [0..255] |> List.map (Convert.ToChar) |> anyOf
let pLineTerminator = pchar '\r' >>. pchar '\n' <|> anyOf ['\n';'\r']
let pWhiteSpace =  anyOf ['\t';'\f';'\v';' '] <|> pLineTerminator


run (pWhiteSpace) "\r\nBC"     
    //     let innerFn str = 
    //         if String.IsNullOrEmpty(str) then
    //             Failure "No more input"
    //         else
    //             let first = str.[0] 
    //             if first = charToMatch then
    //                 let remaining = str.[1..]
    //                 Success (charToMatch,remaining)
    //             else
    //                 let msg = sprintf "Expecting '%c'. Got '%c'" charToMatch first
    //                 Failure msg
    //     Parser innerFn
    // let pany  str = parse {


    // } 
    // let thenParse parser1 parser2 = 
    //     let innerFn input =
    //         run parser input |> function
    //             | Success (value,left) -> 
    //                 run parser2 left