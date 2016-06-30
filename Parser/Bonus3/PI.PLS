\>Filename:  			pi.pls
\>Author:			Ehren Katzur
\>Modified 			Victor Chang
\>Purpose:			Calculates Pi to X digits
\>                              see EquationforPi.gif
\>Date:				April 25th, 2003

PLATYPUS{
  WRITE("Welcome to the PI calculator! No more mystery!");
  WRITE();
  WRITE("Enter the number of iterations to calculate Pi: ");
  READ(n);
  Pi = 0.0;
  nTemp = 1.0;
  nTemp2 = 1.0;
  
  m = 0;
  FOR(,m < n,)DO{
        m = m;
	nTemp =  (4.0/(8.0*m+1.0)) - (2.0/(8.0*m+4.0)) - (1.0/(8.0*m+5.0)) - (1.0/(8.0*m+6.0));
	nTemp2 = 0.0625;
	nConst = 0.0625;
	j=2;
	FOR(,j < m OR j == m,)DO{
	  j = j;
	  nTemp2 = nTemp2 * nConst;
	  j = j + 1;
	};


	IF (m > 0 )	THEN {
	  nTemp = nTemp * nTemp2;
	};



	Pi = Pi + nTemp;

        m=m+1;
        \>WRITE("m: ");WRITE(m);WRITE();WRITE();

	WRITE(Pi);
	WRITE();
	
  };
}
