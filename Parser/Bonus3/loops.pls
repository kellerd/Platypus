\> This program calculates the sum and the average
\> of 5 numbers
PLATYPUS {
	j=0;i=0;k=0;
	FOR(,i<5,)DO{
		i=i+1;
		WRITE("Outer Loop: ");WRITE(i);WRITE();
	
		j=0;
		FOR(,j<2,)DO{
	   	j=j+1;
	   	WRITE("   Inner Loop: ");WRITE(j);WRITE();
           		k=0;
	   		FOR(,k<2,)DO{
	   			k=k+1;
	   			WRITE("     Inner Inner Loop: ");WRITE(k);WRITE();
	
	   		};	
		};
		
	
	};

	k=0;
	FOR(,k<10,)DO{
	   	k=k+1;
	   	WRITE("New Loop: ");WRITE(k);WRITE();
	};
	WRITE("DONE!!!");WRITE();

}