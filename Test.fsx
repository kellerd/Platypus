#load "Interpret.fsx"
open System
open Platypus
open Parser
open Interpret

let getFiles = (IO.Path.Combine (__SOURCE_DIRECTORY__, "Sample Code\\Bonus3\\"),"*.pls") |> IO.Directory.EnumerateFiles
let parseProgs = getFiles |> Seq.map (fun f -> f,(f |> buffer |> runParser program))


parseProgs  |> Seq.filter(function _,Failure(err) -> true | _,Success _ -> false)


let progs = [
     "PLATYPUS  
    \> Comment
    \> Comment
    \> Comment
 {IF(\"1\"==\"1\"OR\"3\"==\"4\"AND\"5\"==\"5\")THEN{WRITE(\"a\");};}";
"PLATYPUS{FOR(,\"1\"==\"2\"OR\"3\"==\"4\"AND\"5\"==\"6\",)DO{WRITE(\"a\");};}";
"PLATYPUS{FOR(i=1,i<5,i=i+1)DO{WRITE(\"a\");};}";]
let parse = progs |> List.map (runParser program)
let interpret = progs |> List.iter (doProgram)

one "Sample Code\\Bonus3\\" "loops.pls" |> doProgram