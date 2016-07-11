#load "Platypus.fsx"
open System
open Platypus
open Parser


let getFiles = (IO.Path.Combine (__SOURCE_DIRECTORY__, "Sample Code\\Bonus3\\"),"*.pls") |> IO.Directory.EnumerateFiles
let runProgs = getFiles |> Seq.map (fun f -> f,(f |> buffer |> run pProgram))
let one dir f = 
    IO.Path.Combine (__SOURCE_DIRECTORY__, dir, f) 
    |> buffer 
    |> run pProgram

runProgs  |> Seq.filter(function _,Failure(err) -> true | _,Success _ -> false)


one "Sample Code\\Bonus3\\" "ass2r.pls"

run pProgram "PLATYPUS  
    \> Comment
    \> Comment
    \> Comment
 {IF(\"1\"==\"2\"OR\"3\"==\"4\"AND\"5\"==\"6\")THEN{WRITE(\"a\");};}"
run pProgram "PLATYPUS{FOR(,\"1\"==\"2\"OR\"3\"==\"4\"AND\"5\"==\"6\",)DO{WRITE(\"a\");};}"
run pProgram "PLATYPUS{WRITE(a,b,c);}"