#load "Platypus.fsx"
open System.Linq
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
            | AVariable(SingleVar(v)) -> sprintf "%f" v 
            | AVariable(ShortVar(v)) -> sprintf "%d" v 
            | SVariable(v) -> sprintf "%s" <| unbox<string> v 
            | _ -> sprintf ""
    let removeIfFound key = 
        if globalVars.ContainsKey key then
            globalVars.Remove(key) |> ignore
        globalVars
    let setVar var value = //Default should be int, upcast to float, stays float
        match var,value with
        | AVariable(SingleVar(_)) & AVID (ArithmeticVariableIdentifier(vid)),ShortVar(v) -> 
            (removeIfFound vid).Add(vid,box (v |> float32))
        | AVariable(ShortVar(_)) & AVID (ArithmeticVariableIdentifier(vid)),ShortVar(v) 
        | AVID (ArithmeticVariableIdentifier(vid)),ShortVar(v) -> 
            (removeIfFound vid).Add(vid,box v)
        | AVariable(ShortVar(_)) & AVID (ArithmeticVariableIdentifier(vid)),SingleVar(v) -> 
            (removeIfFound vid).Add(vid,box (v |> int16))
        | AVariable(SingleVar(_)) & AVID (ArithmeticVariableIdentifier(vid)),SingleVar(v) 
        | AVID ((ArithmeticVariableIdentifier(vid))),SingleVar(v) -> 
            (removeIfFound vid).Add(vid,box v)
        | SVID (StringVariableIdentifier(vid)),v-> 
            (removeIfFound vid).Add(vid,box v)
    let stringExpressionToString = function 
        | SVar(v) -> match SVID(v) with SVariable(s) -> s | _ -> ""
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
        evalArithmetic expr 
    let (|TryShort|_|) input = match Int16.TryParse(input) with
                               | true,i -> Some i
                               | false,_ -> None
    let (|TrySingle|_|) input = match System.Single.TryParse(input) with
                                | true,f -> Some f
                                | false,_ -> None
    let evalReadVar setVar = function
        | SVID(_) as var -> Console.ReadLine() |> box |> setVar var
        | AVID(_) as var -> match Console.ReadLine() with
                            | TryShort i -> setVar var <| box i
                            | TrySingle f -> setVar var <| box f
                            | _ -> failwith "Expected short integer or single float"

    let evalConditional = 
        let comp = function
            | (a,Eq,b) -> a = b
            | (a,Ne,b) -> a <> b
            | (a,Gt,b) -> a > b
            | (a,Lt,b) -> a < b
        let rec compA = function
            | Short(a),op,Single(b) -> (Single(a|>float32),op,Single(b)) |> compA
            | Single(a),op,Short(b) -> (Single(a),op,Single(b|>float32)) |> compA
            | (a,Eq,b) -> a = b
            | (a,Ne,b) -> a <> b
            | (a,Gt,b) -> a > b
            | (a,Lt,b) -> a < b
        let evalPrimaryNum = function
            | PrimaryRelALit (f) -> f
            | PrimeRelAVid (AVariableId(ShortVar(v))) -> Short(v)
            | PrimeRelAVid (AVariableId(SingleVar(v))) -> Single(v)
            | _ -> Short(0s)
        let evalPrimaryString = function
            | PrimaryRelSVid (v) -> match SVID(v) with SVariable(s) -> s | _ -> ""
            | PrimaryRelSLit  (StringLiteral(s)) -> s

        let rec evalLogicalOr = function
            | LogicalOr(logicalOr,logicalAnd) -> evalLogicalOr logicalOr || evalLogicalAnd logicalAnd
            | JustAnd (logicalAnd) -> evalLogicalAnd logicalAnd
        and evalLogicalAnd = function
            | LogicalAnd (logicalAnd , relational) -> evalLogicalAnd logicalAnd && evalRelational relational
            | JustRelational (relational) -> evalRelational relational
        and evalRelational = function
            | Str (primaryString , op , primaryString2) -> 
                 (evalPrimaryString primaryString,op,evalPrimaryString primaryString2) |> comp // (writePre >> comp >> writePost)
            | Arith (primaryNum , op , primaryNum2) ->
               (evalPrimaryNum primaryNum,op,evalPrimaryNum primaryNum2) |> compA //(writePre >> compA >> writePost)
            | LExpr (logicalOr) -> evalLogicalOr logicalOr
        evalLogicalOr
    let rec evalStatement = function
        | Output(Write(Empty)) ->  printfn ""
        | Output(Write(StringOutputLine(StringLiteral(s)))) -> s |> System.Text.RegularExpressions.Regex.Unescape |> printfn "%s"
        | Output (Write(Vars(vars))) -> OneOrMany<_>.toList vars |> List.map printVar |> String.concat ""  |> System.Text.RegularExpressions.Regex.Unescape |> printfn "%s" 
        | Assign(ArithmeticAssign(var,expression)) -> evalAExpression expression |> (function | Short(v) -> v |> setVar (AVID var)
                                                                                              | Single(v) -> v |> setVar (AVID var))
        | Assign(StringAssign(var,expression)) -> evalSExpression expression |> setVar (SVID var)
        | Input(Read(vars)) -> OneOrMany<_>.toList vars |> List.iter (evalReadVar setVar)
        | Select(cond,statements,maybeElseStatements) -> 
            if (evalConditional cond) then
                OneOrMany<_>.toList statements |> List.iter evalStatement
            else
                maybeElseStatements |> Option.map (OneOrMany<Statement>.toList) |> Option.iter (List.iter evalStatement)
        | Iter(maybeExpr,cond,maybeIncrement,statements) -> 
            maybeExpr |> Option.iter (Assign >> evalStatement)
            while (evalConditional cond) do
                statements |> List.iter evalStatement
                maybeIncrement |> Option.iter (Assign >> evalStatement)
    match program with 
    | Platypus (statements,_) -> List.iter evalStatement statements 

let doProgram program = 
    let blank = (new Dictionary<string,obj>())
    //use blank = dict [("a$",box "a");("b",box 7);]
    let context = evalProgram blank
    match run pProgram program with
    | Success (p,_) -> context p
    | Failure (err) -> printfn "%s" err
    printfn "%A" (blank)
    blank.Clear()

// let pls = """PLATYPUS{FOR(i=0,i<5,i=i+1){WRITE(i);}}     """ 
// doProgram pls


