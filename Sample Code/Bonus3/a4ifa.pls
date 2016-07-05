PLATYPUS {
	\> Expected a, 8, a, hello, c, abcd
	a = 5;
	IF (a == 5) THEN {
                WRITE("a");WRITE();
		IF (8.0 == 6) THEN {
                        WRITE("Bah");WRITE();
		} ELSE {
                        WRITE("8");WRITE();
		}
	} ELSE {
		WRITE("5");
		IF ("hello" == "hello") THEN {
                        WRITE("hello");WRITE();
		} ELSE {
                        WRITE("Bah");WRITE();
		};
	}
	IF (a < 5.1)THEN {
                WRITE("a");WRITE();
		IF ("hello" == "hello") THEN {
                        WRITE("hello");WRITE();
		} ELSE {
                        WRITE("Bah");WRITE();
		}
	};
	IF (B != 0.0) THEN{
                WRITE("B");WRITE();
	}
	str$ = "abcd";
	c = 5.01;
	IF (c > a) THEN{
                WRITE("c");WRITE();
		IF (str$ < "bcde") THEN {
                        WRITE(str$);WRITE();
		}
	} ELSE {
                WRITE("a");WRITE();
	}
	
}
