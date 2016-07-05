PLATYPUS {
	\> Expected 5, yeah, a, hello, B, c, abcd
	a = 5;
	blah$ = "asdf";
	blah2$ = "bsdf";
	IF (blah$ > blah2$ OR 8 == 6 AND a == 5.1) THEN {
                WRITE("a");WRITE();
		IF (8.0 == 6) THEN {
                        WRITE("Bah");WRITE();
		} ELSE {
                        WRITE("8");WRITE();
		}
	} ELSE {
                WRITE("5");WRITE();
		a = 5.1; \> Will be truncated to 5
		IF (7.0 == 7 OR "hello" == "hello" AND blah2$ > "cccc" OR 8 == 9.0) THEN {
                        WRITE("yeah");WRITE();
		} ELSE {
                        WRITE("Bah");WRITE();
		};
	}
	IF (a < 5.1)THEN {
                WRITE("a");WRITE();
		IF ("hello" == "hello" AND a == 5 OR whoops < 1) THEN {
                        WRITE("hello");WRITE();
		} ELSE {
                        WRITE("Bah");WRITE();
		}
	};
	B = -1;
	IF (B < 0.0) THEN{
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
