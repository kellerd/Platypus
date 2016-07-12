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
        | :? int16 as v  -> ShortVar (unbox<int16> v)
        | x -> failwith <| sprintf "Can't be other type %s" (x.GetType().FullName)
    let (|AVariable|_|) = function
        | AVID (AVariableId(v)) -> Some v
        | _ -> None
    let (|SVariable|_|) = function
        | SVID (StringVariableIdentifier(vid)) -> (globalVars.TryGetValue(vid)  |> function (true,v) -> Some(unbox<string> v) | _ -> None)
        | _ -> None
    let printVar = function
            | AVariable(SingleVar(v)) -> sprintf "Float 32 Value: %f" v 
            | AVariable(ShortVar(v)) -> sprintf "Int 16 Value: %d" v 
            | SVariable(v) -> sprintf "%s" <| unbox<string> v 
            | _ -> sprintf "null"
    let removeIfFound key = 
        if globalVars.ContainsKey key then
            globalVars.Remove(key) |> ignore
        globalVars
    let setVar var value = //Default should be int, upcast to float, stays float
        match var,value with
        | AVID ((ArithmeticVariableIdentifier(vid))),SingleVar(v) -> 
            (removeIfFound vid).Add(vid,box v)
        | AVID ((ArithmeticVariableIdentifier(vid))),ShortVar(v) -> 
            (removeIfFound vid).Add(vid,box v)
        | SVID (StringVariableIdentifier(vid)),v-> 
            (removeIfFound vid).Add(vid,box v)
//    let evalAExpression expression = 
    let stringExpressionToString = function 
        | SVar(v) -> match SVID(v) with
                        | SVariable(s) -> s 
                        | _ -> ""
        | SLiteral(StringLiteral(s)) -> s     
    let evalSExpression expression = 
        expression |> OneOrMany<_>.toList |> List.map stringExpressionToString |> String.concat ""

    

    let evalAExpression expr = 
        let rec (|IsFloat|_|) expr = 
            let rec mapFloatExpr = function
                | Arithmetic (ar1,op,ar2) -> (mapFloatExpr ar1,op,mapFloatExpr ar2) |> Arithmetic
                | ArithmeticVariable(AVariableId(ShortVar(v))) -> ArithmeticLiteral(Single(v|>float32))
                | ArithmeticLiteral(Short(v)) ->  ArithmeticLiteral(Single(v|>float32))
                | v -> v
            match expr with
            | Arithmetic (IsFloat(ar1),op,_) -> Some expr
            | Arithmetic (_,op,IsFloat(ar2)) -> Some expr
            | Arithmetic(_) -> None
            | ArithmeticVariable(AVariableId(ShortVar(_))) -> None
            | ArithmeticVariable(AVariableId(SingleVar(_))) -> Some expr
            | ArithmeticVariable(_) -> None
            | ArithmeticLiteral(Single(_)) -> Some expr
            | ArithmeticLiteral(Short(_)) -> None
            |> Option.map mapFloatExpr 
        let rec evalArithmetic expr  : NumberLiteral =
            let doOp = function
                | (Short(lit),Plus,Short(lit2)) -> Short(lit + lit2)
                | (Short(lit),Minus,Short(lit2)) -> Short(lit - lit2)
                | (Short(lit),Mul,Short(lit2)) -> Short(lit * lit2)
                | (Short(lit),Div,Short(lit2)) -> Short(lit / lit2)
                | (Single(lit),Plus,Single(lit2)) -> Single(lit + lit2)
                | (Single(lit),Minus,Single(lit2)) -> Single(lit - lit2)
                | (Single(lit),Mul,Single(lit2)) -> Single(lit * lit2)
                | (Single(lit),Div,Single(lit2)) -> Single(lit / lit2)
                | _ -> failwith "Can't do casts this way, expr should be pre-cast"
            match expr with
                | IsFloat(Arithmetic(ar1,op,ar2)) -> (evalArithmetic ar1,op,evalArithmetic ar2) |> doOp
                | Arithmetic(ar1,op,ar2) -> (evalArithmetic ar1,op,evalArithmetic ar2) |> doOp
                | ArithmeticLiteral(v) -> v
                | ArithmeticVariable(AVariableId(ShortVar(v))) -> Short(v)
                | ArithmeticVariable(AVariableId(SingleVar(v))) -> Single(v)
                | ArithmeticVariable(_) -> Short(Unchecked.defaultof<int16>)
                | ArithmeticLiteral(v) ->  v
//            match expr with 
//            | IsFloat(expr) -> evalArithmetic' validateNumeric<float32> addzero expr  |> box
//            | _ -> evalArithmetic' validateNumeric<int16> addzero expr  |> box
        
        evalArithmetic expr 
    let evalStatements = function
        | Output(Write(Empty)) ->  printfn ""
        | Output(Write(StringOutputLine(StringLiteral(s)))) -> s |> System.Text.RegularExpressions.Regex.Unescape |> printfn "%s"
        | Output (Write(Vars(vars))) -> OneOrMany<_>.toList vars |> List.map printVar |> String.concat ""  |> System.Text.RegularExpressions.Regex.Unescape |> printfn "%s" 
        | Assign(ArithmeticAssign(var,expression)) -> evalAExpression expression |> (function | Short(v) -> v |> setVar (AVID var)
                                                                                              | Single(v) -> v |> setVar (AVID var))
        | Assign(StringAssign(var,expression)) -> evalSExpression expression |> setVar (SVID var)
        // | Select(_) -> failwith "Not implemented yet"
        // | Iter(_) -> failwith "Not implemented yet"
        // | Input(_) -> failwith "Not implemented yet"
//        | Assign
//        | Select
//        | Iter 
//        | Input 
    match program with 
    | Platypus (statements,_) -> List.iter evalStatements statements 

let doProgram program = 
    let blank = (new Dictionary<string,obj>())
    //use blank = dict [("a$",box "a");("b",box 7);]
    let context = evalProgram blank
    match run pProgram program with
    | Success (p,_) -> context p
    | Failure (err) -> printfn "%s" err
    blank.Clear()

let pls = """PLATYPUS{c = 5/10.0 ;WRITE(c);}     """ 
doProgram pls
one "Sample Code\\Bonus3" "string.pls" |> doProgram


