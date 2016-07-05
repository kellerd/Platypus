
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

let opt p = (p |>> Some) <|> (retn None)    
let between p1 p2 p3 = p1 >>. p2 .>> p3

let choice listOfParsers = 
        List.reduce ( <|> ) listOfParsers 


let rec sequence parsers = 
    let cons head tail = head::tail
    let consLifted = lift2 cons
    match parsers with
    | [] ->
        retn []
    | head::tail -> consLifted head (sequence tail)

let notp parser  = 
    fun str ->
        match run parser str with
        | Success _ -> Failure "Matched, failing notp"
        | Failure _ -> Success((),str)
    |> Parser
