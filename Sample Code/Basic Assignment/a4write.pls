PLATYPUS {
	WRITE(Var1, var2$, var3);\> Correct
	WRITE(var1, var2, );
	WRITE();	\> Correct
	WRITE(var1, "asdf", var2, var3); \> STR literal inside var list
	WRITE(var1, "asdf"var2, var3, "pie");
	WRITE(,whoops);
	WRITE(a a = b + b);
	WRITE(

}
\> Whooops found EOF