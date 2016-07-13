#Platypus Parser
The main goal was to re-implement a compilers assignment from 12 years ago, into F# to explore Parser Combinators. Which are a quick to write/easy success way to make a quick parser for given Domain Specific Language or other.

Typical use cases would be for users to enter in a specific format, and easily transform to a Expression Tree.

#Features
## C
- Recursive Top Down Parser
- Creates a stack of operations
    - [Platypus]
    - [Write]
    - [AVID]
    - a
    - [AVID]
    - b
    - [AVID]
    - c
- Interpreter reads the stack of tokens, may modify the stack, then execute
- Fed by state machine of characters and Scanner of Tokens
- Lookahead heavily used
## FSharp
- Recursive Top Down Parser Combinator
- Creates abstract syntax tree from combining tiny parsers into larger ones
- Custom operators for combining parsers in certain ways
- Parsers almost read the way the code would be written
---     
        let selectionStatement = 
          IF >->. betweenParens conditionalExpression .>-> THEN .>->. 
          (many1 (statement a) |> betweenBrace ) .>->. 
          opt (
              ELSE >->. 
              (many1 (statement a) |> betweenBrace )
          ) .>-> optStatementSep
---
        let stringAssignment = stringIdentifier .>-> assignmentOp .>->. stringExpression |>> StringAssignment
        let arithmeticAssignment = arithmeticIdentifier .>-> assignmentOp .>->. arithmeticExpression |>> ArithmeticAssignment
        let assignmentExpression = (stringAssignment <|> arithmeticAssignment) |>ignoreSpace
---
- Language spec is both defined in strongly typed system and is mirrored in parser implementation

      type ArithmeticExpression = 
      | Arithmetic of ArithmeticExpression * ArithmeticOp * ArithmeticExpression
      | ArithmeticVariable of ArithmeticVariableIdentifier
      | ArithmeticLiteral of NumberLiteral

- Monadic pass through - fast fail/shortcut
- Pattern matching negates heavy nested ifs

        Platypus
        ([Output
            (Write
               (Vars
                  (Many
                     (AVID (ArithmeticVariableIdentifier "a"),
                      [AVID (ArithmeticVariableIdentifier "b");
                       AVID (ArithmeticVariableIdentifier "c")]))))],SEOF), "")]

- Optimizations are used to translate & combine the tree into other forms when conditions exist
- Succinct
- Most illegal states can't even be written by programmer
    - F# will strongly type inputs into a function
- Immutable variables by default, state can be shared between functions/threads without threat of it being clobbered or re-referenced
- Changes or corrections to language specification will show up everywhere that it's affected in code as errors
- When the combinators get a little crazy functional programming, you can tone it down and use imperative style with Computation Expression `parse { }`
- Patterm matching can find all of the combinations and give a F# compiler warning if not all options are included. Take out one, it will highlight the statement

      | (Short(lit),Plus,Short(lit2)) -> Short(lit + lit2)
      | (Short(lit),Minus,Short(lit2)) -> Short(lit - lit2)
      | (Short(lit),Mul,Short(lit2)) -> Short(lit * lit2)
      | (Short(lit),Div,Short(lit2)) -> Short(lit / lit2)
      | (Single(lit),Plus,Single(lit2)) -> Single(lit + lit2)
      | (Single(lit),Minus,Single(lit2)) -> Single(lit - lit2)
      | (Single(lit),Mul,Single(lit2)) -> Single(lit * lit2)
      | (Single(lit),Div,Single(lit2)) -> Single(lit / lit2)

- Type inference, less typing, how you write the code will let it determine the types
    - let a = 5.3
        - a is of type float
    - let b = a * a
        - b is of type float
# Disadvantages
## C
 - Own implementation of a file io buffer, scanner, tokenizer, state machine
 - Blows up on large loops due to recursion, PI max 20 or so iterations
## FSharp
- Speed
- Scrictness of the F# language makes writing a parser for a loose language harder.
  - Have to create a few work arounds, but doing so will create less runtime errors
- Operators can get a little out of hand if not used to common conventions
  - Custom operators even more out of hand sometimes
- Max loops for PI (infinite)

# Lines of code
## C

- Infrastructure (Total:496)
  - Buffer 258
  - List 238
- Main (Total:2733)
  - Language spec - 195
  - Symbol table 308
  - Interpreter 756
  - Scanner 604
  - Parser 870
## FSharp
- Infrastructure - (Total: 107)
  - Combinator functions - 107
- Main  - (Total: 548)
  - Language spec - 84
  - Parser - 300
  - Interpreter - 164
  
# Future cleanups or perf
- Ignore and continue for ignoring weird parts of the parse and just continuing on. Like
  - a = 1 + "a" + 5 + "b"
    - Error at pos (1,9)
    - Error at pos (1,19)
    - ....
  - Instead of just one error
- Make language spec more closer to language, rather than how it should be parsed 
- Detect inf loops or like FOR(a=0,a<999999.0,a=a+1), as a will always be < 999999.0 as it will roll over to negative
- Pre-compute literals "hello"<<"world" could be "helloworld"
- change "function" to "match input with" for readability, they are the same
- find more ways to make illegal states irrepresentable  

# Conclusions
- There were no dragons. Maybe they only exist in C
- I could do this without having to restudy compilers
  - Can't really say that about calculus.
- Based on FParsec, https://fsharpforfunandprofit.com/posts/understanding-parser-combinators/