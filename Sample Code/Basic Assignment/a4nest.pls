PLATYPUS {
     a = 1;
     b = 2;
     IF (b > a) THEN {
         IF (b == 2) THEN {
              FOR (i = 0, i < 10, i = i + 1) DO {
                   c = b + 5;
                   FOR (j = a - 1, j < c, j = j + a) DO {
                        IF ( b > 5 ) THEN {
                           b = b + 1;
			} ELSE {
			   b = b + 2;
                        };
			WRITE(a,b,c,j);
                   };
              }
         } ELSE {
            WRITE("666");
         }
     };             
}