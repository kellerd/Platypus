\>This is a syntactically correct PLATYPUS program
\>Weiler's law:
\>"Nothing is impossible for the man who doesn't have to do it himself."
\>"Parsing is passing." Compilers' law

PLATYPUS{
a$ = "hello ";
b$ = "Joker is wild!";
WRITE(b$);WRITE();
a$ = a$ << "World "<< "!\n"<<b$<<"I got four of them\n"<<a$; 

WRITE(a$);WRITE();
c$=a$<<b$;

WRITE(c$);WRITE(); 

}
