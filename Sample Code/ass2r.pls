\> This program calculates the sum of 32767 even numbers.
\> The program is "lexically" and "syntactically" correct
\> and should not produce any error
PLATYPUS {
 
 a=+0.0;
 
 sum008 = 0. ;
 READ(a,sum008); 
 i= 0h0;
 FOR(,i < 32767 OR i == 0h7FFF, )DO{
   i = i + (0hB - 0hA);
   a=
   a*2./.5
   ;
   sum008 = sum008 + a - 1 ;
 };
 IF(text$ == "")THEN{
   text$ = "prog" << "ram";
 } ELSE {
   text$ = text$ << "ram";
 }
 WRITE("\* This is a platypus -:)-<-<-- \*");
 WRITE(text$);
 
 IF(text$ == "program" OR sum008!=.0 AND i>0h0010)THEN{
  WRITE(sum008);
  i=0;
  WRITE();
 };
}
