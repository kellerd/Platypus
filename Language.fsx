type SEOF = SEOF
type OneOrMany<'a> = | One of 'a | Many of 'a * 'a list
 with static member toList oneOrMany = 
                    match oneOrMany with
                    | One a -> [a]
                    | Many (head,tail) -> head::tail
      static member ofList head tail =
        match tail with 
        | [] -> One(head)
        | xs -> Many(head,tail)
type ArithmeticVariableIdentifier = ArithmeticVariableIdentifier of string
type StringVariableIdentifier = StringVariableIdentifier of string
type ArithmeticOp = Plus | Minus | Mul | Div
type AssignOp = AssignOp
type NumberLiteral = Single of float32 | Short of int16
type RelationalOp = Eq | Ne | Gt | Lt
type StringLiteral = StringLiteral of string
type StringConcatOp = StringConcatOp  
type LogicalOp = And | Or
type ParsedArithmeticExpression = 
    | Unary of UnaryArithmeticExpression
    | Add of AdditiveArithmeticExpression
and UnaryArithmeticExpression = 
    ArithmeticOp * PrimaryArithmeticExpression
and AdditiveArithmeticExpression = 
    | AddOpExpr of AdditiveArithmeticExpression * ArithmeticOp * MultiplicativeArithmeticExpression
    | Multiplicative of MultiplicativeArithmeticExpression
and MultiplicativeArithmeticExpression =
    | MulOpExpr of MultiplicativeArithmeticExpression * ArithmeticOp * PrimaryArithmeticExpression
    | Primary of PrimaryArithmeticExpression
and PrimaryArithmeticExpression = 
    | Var of ArithmeticVariableIdentifier
    | Expr of ParsedArithmeticExpression
    | Literal of NumberLiteral

type ArithmeticExpression = 
    | Arithmetic of ArithmeticExpression * ArithmeticOp * ArithmeticExpression
    | ArithmeticVariable of ArithmeticVariableIdentifier
    | ArithmeticLiteral of NumberLiteral

type StringExpression = 
    | SVar of StringVariableIdentifier 
    | SLiteral of StringLiteral

type LogicalExpression = RelationalExpression * (LogicalOp * RelationalExpression) list 
and ConditionalExpression = LogicalOrExpression
and LogicalOrExpression = 
    | LogicalOr of LogicalOrExpression * LogicalAndExpression
    | JustAnd of LogicalAndExpression
and LogicalAndExpression = 
    | LogicalAnd of LogicalAndExpression * RelationalExpression
    | JustRelational of RelationalExpression
and RelationalExpression = 
    | Str of PrimaryStringRelationalExpression * RelationalOp * PrimaryStringRelationalExpression
    | Arith of PrimaryArithRelationalExpression * RelationalOp * PrimaryArithRelationalExpression
    | LExpr of LogicalOrExpression
and PrimaryStringRelationalExpression = 
    | PrimaryRelSVid of StringVariableIdentifier 
    | PrimaryRelSLit of  StringLiteral
and PrimaryArithRelationalExpression = 
    | PrimaryRelALit of NumberLiteral 
    | PrimeRelAVid of ArithmeticVariableIdentifier

type AssignmentStatement = AssignmentExpression
and AssignmentExpression = 
    | ArithmeticAssign of ArithmeticVariableIdentifier * ArithmeticExpression
    | StringAssign of StringVariableIdentifier * StringExpression OneOrMany

type InputStatement = Read of Variable OneOrMany
and Variable = AVID of ArithmeticVariableIdentifier | SVID of StringVariableIdentifier
type OutputStatement = Write of OutputLine 
and OutputLine = Vars of Variable OneOrMany | StringOutputLine of StringLiteral | Empty

type IterationStatement = AssignmentExpression option * ConditionalExpression * AssignmentExpression option * Statement list
and SelectionStatement = ConditionalExpression * Statement OneOrMany * Else option
and Else = Statement OneOrMany
and Statement = 
    | Assign of AssignmentStatement
    | Select of SelectionStatement
    | Iter of IterationStatement
    | Input of InputStatement
    | Output of OutputStatement
type Program = 
    Platypus of Statement list * SEOF

