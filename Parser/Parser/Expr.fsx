type SEOF = SEOF
type OneOrMany<'a> = | One of 'a | Many of 'a * 'a list
 with static member toList oneOrMany = 
                    match oneOrMany with
                    | One a -> [a]
                    | Many (head,tail) -> head::tail
type ArithmeticVariableIdentifier = ArithmeticVariableIdentifier of string
type StringVariableIdentifier = StringVariableIdentifier of string
type AdditiveOp = Plus | Minus
type AssignOp = AssignOp
type MultiplicativeOp = Mul | Div
type NumberLiteral = Single of float32 | Short of int16
type RelationalOp = Eq | Ne | Gt | Lt
type StringLiteral = StringLiteral of string
type StringConcatOp = StringConcatOp  
type ArithmeticExpression = 
    | Unary of UnaryArithmeticExpression
    | Add of AdditiveArithmeticExpression
and UnaryArithmeticExpression = 
    AdditiveOp * PrimaryArithmeticExpression
and AdditiveArithmeticExpression = 
    | AddOpExpr of AdditiveArithmeticExpression * AdditiveOp * MultiplicativeArithmeticExpression
    | Multiplicative of MultiplicativeArithmeticExpression
and MultiplicativeArithmeticExpression =
    | MulOpExpr of MultiplicativeArithmeticExpression * MultiplicativeOp * PrimaryArithmeticExpression
    | Primary of PrimaryArithmeticExpression
and PrimaryArithmeticExpression = 
    | Var of ArithmeticVariableIdentifier
    | Expr of ArithmeticExpression
    | Literal of NumberLiteral

type StringExpression = 
    | SPrimary of PrimaryStringExpression 
    | ConcatExpr of StringExpression *  PrimaryStringExpression
and PrimaryStringExpression =
    | SVar of StringVariableIdentifier 
    | SLiteral of StringLiteral

type ConditionalExpression = LogicalOrExpression
and LogicalOrExpression = 
    | LogicalOrExpression of LogicalAndExpression * LogicalOrExpressionPrime
and LogicalAndExpression =
    |  LogicalAndExpression of  RelationalExpression * LogicalAndExpressionPrime
and LogicalOrExpressionPrime =
    | LogicOr of (LogicalAndExpression * LogicalOrExpressionPrime) option
and LogicalAndExpressionPrime =
    | LogicAnd of (RelationalExpression * LogicalAndExpressionPrime) option
and  RelationalExpression = 
    | Str of PrimaryStringRelationalExpression * RelationalOp * PrimaryStringRelationalExpression
    | Arith of PrimaryArithRelationalExpression * RelationalOp * PrimaryArithRelationalExpression
and PrimaryStringRelationalExpression = 
    | PrimaryRelSVid of StringVariableIdentifier 
    | PrimaryRelSLit of  StringLiteral
and PrimaryArithRelationalExpression = 
    | PrimaryRelALit of NumberLiteral 
    | PrimeRelAVid of ArithmeticVariableIdentifier

type AssignmentStatement = AssignmentExpression
and AssignmentExpression = 
    | ArithmeticAssign of ArithmeticVariableIdentifier * ArithmeticExpression
    | StringAssign of StringVariableIdentifier * StringExpression

type InputStatement = Read of Variable list
and Variable = AVID of ArithmeticVariableIdentifier | SVID of StringVariableIdentifier
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

