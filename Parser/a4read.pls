PLATYPUS {
	READ(Var1, var2$, var3);\> Correct
	READ(var1, var2, ); 
	READ();	\> Empty list
	READ(var1, "asdf", var2, var3);		\> String literal
	READ(var1, "asdf"var2, var3, "pie"); \> String literal
	READ(,whoops);
	READ(correct);
	READ(

}
\> Whooops found EOF
