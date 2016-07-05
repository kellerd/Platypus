PLATYPUS {

\> iThink is by default  integer
iThink = 3.5;        \> changed floating point
                  
\> variable of type string
\>iDream$ = 7;		\> illegal					

iFloat = 7.7;    \> the default type is changed to foating-point
iFloat = 7;      \> still floating-point - 7.0 will be assigned to iFloat
iFloat = i;      \> still floating-point (i is an integer variable initialized to zero)
\>iFloat =  "abc ";  \> illegal

\> Default float
Float = 1 + 1 - 4;	\> Still float, not a constant
Float = 7 * 4 - 7.0;    \> Still float

Float = 1;
WRITE(iThink, iFloat, Float);
}
