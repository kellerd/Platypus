\>This is a syntactically correct PLATYPUS program
\>Weiler's law:
\>"Nothing is impossible for the man who doesn't have to do it himself."
\>"Parsing is passing." S^R & Compilers' law

PLATYPUS{
 a=-0h1;
 b=+.0;
 READ(c);
 READ(d,e,f);
 c=((d+e)/a)*f-(((d-e)*a)/f);
 FOR(,a!=b OR c==d AND e<f OR a>0,c = e)DO{
   IF(a==1 AND b==0.0)THEN{
    c=-(5.9);
   }ELSE {c=-c;}  
 };   
 WRITE();
 WRITE("Results: ");
 WRITE(d,e,f,a);
}