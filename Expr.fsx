type SEOF = SEOF
type OneOrMany<'a> = | Single of 'a | Many of OneOrMany<'a>
type ArithmeticVariableIdentifier = ArithmeticVariableIdentifier of string
type StringVariableIdentifier = StringVariableIdentifier of string
type AdditiveOp = Plus | Minus
type MultiplicativeOp = Mul | Div
type NumberLiteral = Float of float | Int of int
type RelationalOp = Eq | Ne | Gt | Lt
type StringLiteral = StringLiteral of string
type StringConcatOp = StringConcatOp  
type ArithmeticExpression = 
    | UnaryArithmeticExpression 
    | AdditiveArithmeticExpression
and UnaryArithmeticExpression = 
    AdditiveOp * PrimaryArithmeticExpression
and AdditiveArithmeticExpression = 
    | Additive of AdditiveArithmeticExpression * AdditiveOp * MultiplicativeArithmeticExpression
    | Multiplicative of MultiplicativeArithmeticExpression
and MultiplicativeArithmeticExpression =
    | Multiplicative of MultiplicativeArithmeticExpression * MultiplicativeOp * PrimaryArithmeticExpression
    | Primary of PrimaryArithmeticExpression
and PrimaryArithmeticExpression = 
    | Var of ArithmeticVariableIdentifier
    | Expr of ArithmeticExpression

type StringExpression = 
    | Primary of PrimaryStringExpression 
    | Concat of StringExpression *  PrimaryStringExpression
and PrimaryStringExpression =
    | SVar of StringVariableIdentifier 
    | Literal of StringLiteral

type ConditionalExpression = LogicalOrExpression
and LogicalOrExpression = | Or of LogicalOrExpression option * LogicalAndExpression
and LogicalAndExpression = | And of LogicalAndExpression option * RelationalExpression
and  RelationalExpression = 
    | Str of PrimaryStringRelationalExpression * RelationalOp * PrimaryStringRelationalExpression
    | Arith of PrimaryArithRelationalExpression * RelationalOp * PrimaryArithRelationalExpression
and PrimaryStringRelationalExpression = StringVariableIdentifier | StringLiteral
and PrimaryArithRelationalExpression = NumberLiteral | ArithmeticVariableIdentifier

type AssignmentStatement = AssignmentExpression
and AssignmentExpression = 
    | ArithmeticExpression of ArithmeticVariableIdentifier * ArithmeticExpression
    | StringExpression of StringVariableIdentifier * StringExpression

type InputStatement = Read of Variable list
and Variable = A of ArithmeticVariableIdentifier | S of StringVariableIdentifier
type OutputStatement = Write of OutputLine 
and OutputLine = Vars of Variable list | StringOutputLine of StringLiteral | Empty

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

