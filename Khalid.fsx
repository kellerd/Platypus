open Microsoft.FSharp.Core
open System
#load "Parser.fsx"

type SEOF = SEOF
type OneOrMany<'a> = | One of 'a | Many of 'a * 'a list
 with static member ToList oneOrMany = 
                    match oneOrMany with
                    | One a -> [a]
                    | Many (head,tail) -> head::tail
      static member OfList head tail =
        match tail with 
        | [] -> One(head)
        | xs -> Many(head,xs)

open Parser

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
let letter = anyOf (['a' .. 'z'] @ ['A' .. 'Z'])
let digit = anyOf ['0' .. '9']
let letterOrDigit = letter <|> digit

type ObjectType =
    | Table
    | Column
    | Index
    | View
    | MaterializedView
    | Synonym
    | Function
    | StoredProc
type SQLStatements =
    | Create of string * ObjectType
    | Comment of string * string
let manyToString = OneOrMany<_>.ToList >> charListToStr

let oracleIdentifier = 
    let singleId = anyOf (['a' .. 'z'] @ ['A' .. 'Z'] @ ['_'] @ ['0' .. '9']) |> many1 |> map manyToString
    many whiteSpace
    >>. singleId 
    .>>. opt (parseChar '.' >>. singleId) 
    .>>. opt (parseChar '.' >>. singleId)
    .>> many whiteSpace
    |>> fun ((schema, table), column) -> 
        match table, column with
        | Some table, Some col -> schema + "." + table + "." + col 
        | None, Some col -> schema + "." + col
        | Some table, None -> schema + "." + table  
        | None, None -> schema

let size = 
    parseChar '('  .>> many whiteSpace >>. many1 digit .>> many whiteSpace .>> parseChar ')'
    |>> manyToString |>> Convert.ToInt16
let datatype = 
    many1 letterOrDigit |>> manyToString
    .>> many whiteSpace
    .>>. opt size
let manyOracleIdentifier =
    oracleIdentifier 
    |> many1
    |>> fun x -> OneOrMany<_>.ToList x |> String.concat ""

let constraints = 
    manyOracleIdentifier
    <|> ( betweenC '('  manyOracleIdentifier  ')' ) 

let columnDef = 
  oracleIdentifier
  .>>. datatype
  .>> many whiteSpace
  .>>. many constraints

let columnList = 
    let cols = sepBy oracleIdentifier (parseChar ',') 
    betweenC '(' cols ')'
    
let orderByList = 
    let cols = sepBy manyOracleIdentifier (parseChar ',') 
    betweenC '(' cols ')'

let tableDef =
  let cols = sepBy columnDef (parseChar ',') 
  betweenC '(' cols ')'

let CREATE objectType name = 
    parseString "CREATE" 
    <|> (parseString "CREATE"
        .>> many whiteSpace
        .>> parseString "OR"
        .>> many whiteSpace
        .>> parseString "REPLACE")
    .>> many whiteSpace
    >>. objectType
    .>> many whiteSpace
    .>>. name
    |> map (fun (objectType, str) -> Create(str, objectType))

let statementTerminator = 
    many whiteSpace .>> parseChar ';'  .>> many whiteSpace
        
let TABLE =  parseString "TABLE" |>> fun _ -> Table
let COLUMN =  parseString "COLUMN" |>> fun _ -> Column
let INDEX =  (parseString "INDEX" <|> parseString "UNIQUE INDEX") |>> fun _ -> Index
let VIEW =  parseString "VIEW" |>> fun _ -> View
let MATERIALIZEDVIEW =  parseString "MATERIALIZED VIEW" |>> fun _ -> MaterializedView
let SYNONYM =  parseString "SYNONYM" |>> fun _ -> Synonym
let PUBLICSYNONYM =  parseString "PUBLIC SYNONYM" |>> fun _ -> Synonym
let FUNCTION =  parseString "FUNCTION" |>> fun _ -> Function
let PROCEDURE =  parseString "PROCEDURE" |>> fun _ -> StoredProc 

let objectType = choice [
    TABLE
    COLUMN
    INDEX 
    VIEW
    MATERIALIZEDVIEW
    SYNONYM
    PUBLICSYNONYM
    FUNCTION
    PROCEDURE
]

let COMMENT = parseString "COMMENT"

let CreateTable = 
    CREATE TABLE oracleIdentifier 
    .>> many whiteSpace
    .>> tableDef
    .>> many whiteSpace
    
let stringLiteral = 
    let quot = parseChar '\''
    let stringCharacter = notp quot &&. inputCharacter
    between quot (many stringCharacter) quot
    |>> charListToStr

let Comment = 
    COMMENT 
    .>> many whiteSpace
    .>> parseString "ON"
    .>> many whiteSpace
    .>> objectType
     >>. oracleIdentifier
    .>> parseString "IS"
    .>> many whiteSpace
    .>>. stringLiteral
    |>> Comment

let Index =
    CREATE INDEX oracleIdentifier
    .>> many whiteSpace
    .>> parseString "ON"
    .>> oracleIdentifier
    .>> orderByList
    
runParser Index "CREATE UNIQUE INDEX AH096_PK ON AH096_HRSR_USER_SEARCH
( X.SEAR, CH )"

let statement = 
    choice [
        CreateTable
        Comment
        Index 
    ] 

let SQLFile = 
    let singleStatement =
        many whiteSpace >>. statement .>> statementTerminator
    many singleStatement

let files = System.IO.Directory.EnumerateFiles (IO.Path.Combine(__SOURCE_DIRECTORY__, "Files"))

let result = 
    files
    |> Seq.filter (fun x -> x.EndsWith("00_START_HRSR_2_0.SQL") |> not)
    //|> Seq.take 5
    |> Seq.map (System.IO.File.ReadAllText >> runParser SQLFile)

let err = Seq.find(function  Success(x, "") -> false | _ -> true) result 

let thingsIWant =
    result 
    |> Seq.collect (function 
        | Success(results, _) -> 
            results 
            |> List.choose(function 
                | Create(name, _) -> Some name
                | _ -> None 
            )
        | _ -> [] 
    )
    |> Seq.toList
