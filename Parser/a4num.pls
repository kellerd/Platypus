PLATYPUS {

\> Legal decimal constants
 a = 0 + 109 + 17100;
\> Some illegal decimal constants, legals are for error handler
 b = 007 + 0095;
\> Some legal hexidecimal
 c = 0h0 - 0h7F * 0h007F / 0h00FA + (0h750 - 0h0750) -0h7FFF;
\> Some illegal decimal constants
 d = 0H07 - 0hfab * 0xWRONG / 0h * 73;
\>Legal fpl
 e = 0.0 - 0.00 + (0.010 + ( 0. - 1.) * 880. - .0) / .002 -  .7 + 7.7;
\>Illegal fpl
 f = 01.0 + 002.0 - 00.0 * . ;
}