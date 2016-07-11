#load "Platypus.fsx"
open System
open Platypus
open Parser
open Language
open System.Collections.Generic
let evalProgram (globalVars: IDictionary<string,obj>) (program:Program) =
    
    let (|AVariableId|_|) = function
        | (ArithmeticVariableIdentifier(vid)) -> (globalVars.TryGetValue(vid) |> function (true,v) -> Some v | _ -> None)
    let (|SingleVar|ShortVar|) (o:obj) = 
        match o with 
        | :? float32 as v -> SingleVar (unbox<float32> v)
        | :? int16 as v -> ShortVar (unbox<int16> v)
        | _ -> failwith "Can't be other type"
    let (|AVariable|_|) = function
        | AVID (AVariableId(v)) -> Some v
        | _ -> None
    let (|SVariable|_|) = function
        | SVID (StringVariableIdentifier(vid)) -> (globalVars.TryGetValue(vid)  |> function (true,v) -> Some(unbox<string> v) | _ -> None)
        | _ -> None
    let printVar = function
            | AVariable(v) -> printfn "%A" v 
            | SVariable(v) -> printfn "%s" <| unbox<string> v 
            | _ -> printfn "null"
    let removeIfFound key = 
        if globalVars.ContainsKey key then
            globalVars.Remove(key) |> ignore
        globalVars
    let setVar var value = 
        match var with
        | AVID ((ArithmeticVariableIdentifier(vid))) -> 
            (removeIfFound vid).Add(vid,box value)
        | SVID (StringVariableIdentifier(vid)) -> 
            (removeIfFound vid).Add(vid,box value)
//    let evalAExpression expression = 
    let stringExpressionToString = function 
        | SVar(v) -> match SVID(v) with
                        | SVariable(s) -> s 
                        | _ -> ""
        | SLiteral(StringLiteral(s)) -> s     
    let evalSExpression expression = 
        expression |> OneOrMany<_>.toList |> List.map stringExpressionToString |> String.concat ""

    

    let evalAExpression expr = 
        let rec (|IsFloat|IsInt|) = function
            | Unary(exp) -> checkUnaryArithmeticExpression exp
            | Add(add) -> checkAdditiveArithmeticExpression add
        and  checkUnaryArithmeticExpression = function
            | _,primaryExpr -> checkPrimaryArithmeticExpression primaryExpr 
        and checkAdditiveArithmeticExpression = function
            | AddOpExpr(expr,_,multiplicative) -> 
                match checkAdditiveArithmeticExpression expr, checkMultiplicativeArithmeticExpression multiplicative with
                | Choice1Of2(_) as mapping,_ -> mapping
                | _, ( Choice1Of2(_) as mapping) -> mapping
                | mapping,_ -> mapping
            | Multiplicative(expr) -> checkMultiplicativeArithmeticExpression expr 
        and checkMultiplicativeArithmeticExpression = function
            | MulOpExpr (expr, _ ,primary) -> 
                match checkMultiplicativeArithmeticExpression expr, checkPrimaryArithmeticExpression primary with
                |  Choice1Of2(_) as mapping,_ -> mapping
                | _, ( Choice1Of2(_) as mapping) -> mapping
                | mapping,_ -> mapping
            | Primary (primary) -> checkPrimaryArithmeticExpression primary
        and checkPrimaryArithmeticExpression = function
            | Var(AVariableId(SingleVar(_))) -> Choice1Of2(expr)
            | Var(AVariableId(ShortVar(_))) -> Choice2Of2(expr)
            | Var(_) -> Choice2Of2(expr)
            | Expr(IsFloat(_)) ->  Choice1Of2(expr)
            | Expr(_) -> Choice2Of2(expr)
            | Literal(Single(_)) ->  Choice1Of2(expr)
            | Literal(Short(_)) -> Choice2Of2(expr)
 
        let evalArithmetic expr  = 
            let addzero = (+) LanguagePrimitives.GenericZero

            let rec evalArithmetic' continuation  expr = 
                match expr with
                | Unary(exp) -> evalUnaryArithmeticExpression continuation exp 
                | Add(add) -> evalAdditiveArithmeticExpression continuation add 
            and  evalUnaryArithmeticExpression continuation expr1 = 
                match expr1 with
                | (Plus,primaryExpr) -> evalPrimaryArithmeticExpression ((*) LanguagePrimitives.GenericOne >> continuation) primaryExpr
                | (Minus,primaryExpr) -> evalPrimaryArithmeticExpression ((*) (LanguagePrimitives.GenericZero - LanguagePrimitives.GenericOne >> continuation)) primaryExpr 
            and evalAdditiveArithmeticExpression  continuation  expr1 = 
                match expr1 with
                | AddOpExpr(expr,Plus,multiplicative) -> evalMultiplicativeArithmeticExpression  ((+) <| evalAdditiveArithmeticExpression  addzero expr >> continuation) multiplicative 
                | AddOpExpr(expr,Minus,multiplicative) -> evalMultiplicativeArithmeticExpression  ((-) <|  evalAdditiveArithmeticExpression  addzero expr >> continuation) multiplicative
                | Multiplicative(expr) -> evalMultiplicativeArithmeticExpression  addzero expr 
            and evalMultiplicativeArithmeticExpression continuation  expr1 = 
                match expr1 with
                | MulOpExpr (expr, Mul ,primary) -> evalPrimaryArithmeticExpression  (((*) <| evalMultiplicativeArithmeticExpression  addzero expr) >> continuation)  primary 
                | MulOpExpr (expr, Div ,primary) -> evalPrimaryArithmeticExpression  (((/) <| evalMultiplicativeArithmeticExpression  addzero expr) >> continuation)  primary 
                | Primary (primary) -> evalPrimaryArithmeticExpression  addzero primary
            and evalPrimaryArithmeticExpression continuation  expr1 = 
                match expr,expr1 with
                | IsFloat(_),Var(AVariableId(SingleVar(v))) ->  v |> float32 |> continuation |> Choice1Of2
                | IsFloat(_),Var(AVariableId(ShortVar(v))) ->  v |> float32 |> continuation |> Choice1Of2
                | IsFloat(_),Var(_) -> LanguagePrimitives.GenericZero |> float32 |> Choice1Of2
                | IsFloat(_),Expr(e) -> evalArithmetic'  continuation e
                | IsFloat(_),Literal(Single(v)) ->  v  |> float32 |> continuation |> Choice1Of2
                | IsFloat(_),Literal(Short(v)) ->  v |> float32 |> continuation |> Choice1Of2
                | IsInt(_),Var(AVariableId(SingleVar(v))) ->  v |> int16 |> continuation |> Choice2Of2
                | IsInt(_),Var(AVariableId(ShortVar(v))) ->  v |> int16 |> continuation |> Choice2Of2
                | IsInt(_),Var(_) -> LanguagePrimitives.GenericZero |> int16 |> Choice2Of2
                | IsInt(_),Expr(e) -> evalArithmetic'  continuation e
                | IsInt(_),Literal(Single(v)) ->  v  |> int16 |> continuation |> Choice2Of2
                | IsInt(_),Literal(Short(v)) ->  v |> int16 |> continuation |> Choice2Of2
            evalArithmetic' addzero expr
//            match expr with 
//            | IsFloat(expr) -> evalArithmetic' validateNumeric<float32> addzero expr  |> box
//            | _ -> evalArithmetic' validateNumeric<int16> addzero expr  |> box
        
        evalArithmetic expr 
    let evalStatements = function
        | Output (Write(Vars(vars))) -> OneOrMany<_>.toList vars |> List.iter printVar 
        | Assign(ArithmeticAssign(var,expression)) -> evalAExpression expression |> setVar (AVID var)
        | Assign(StringAssign(var,expression)) -> evalSExpression expression |> setVar (SVID var)
        | Select(_) -> failwith "Not implemented yet"
        | Iter(_) -> failwith "Not implemented yet"
        | Input(_) -> failwith "Not implemented yet"
//        | Assign
//        | Select
//        | Iter 
//        | Input 
    match program with 
    | Platypus (statements,_) -> List.iter evalStatements statements 

let pls = "PLATYPUS{WRITE(a$);WRITE(b);}" 

let doProgram program = 
    let blank = (new Dictionary<string,obj>())
    //use blank = dict [("a$",box "a");("b",box 7);]
    let context = evalProgram blank
    match run pProgram pls with
    | Success (p,eof) -> context p
    | Failure (err) -> printfn "%s" err
    printfn "%A" context
    blank.Clear()

doProgram pls