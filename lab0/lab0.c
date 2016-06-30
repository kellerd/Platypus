/* Danny Keller
** 040 429 834
** Lab 0
*/
#include <stdio.h>
#include <math.h>
int main (void) {
   double maxint, maxuint;
   int ic;
   printf("The size of type signed char is: %d\n", sizeof(signed char));
   printf("The size of type char is: %d\n", sizeof(char));
   printf("The size of type unsigned char is: %d\n", sizeof(unsigned char));
   printf("The size of type signed short is: %d\n", sizeof(signed short));
   printf("The size of type short is: %d\n", sizeof(short));
   printf("The size of type unsigned short is: %d\n", sizeof(unsigned short));
   printf("The size of type signed int is: %d\n", sizeof(signed int));
   printf("The size of type int is: %d\n", sizeof(int));
   printf("The size of type unsigned int is: %d\n", sizeof(unsigned int));
   printf("The size of type signed long is: %d\n", sizeof(signed long));
   printf("The size of type long is: %d\n", sizeof(long));
   printf("The size of type unsigned long is: %d\n", sizeof(unsigned long));
   printf("The size of type float is: %d\n", sizeof(float));
   printf("The size of type double is: %d\n", sizeof(long double));
   printf("The size of type long double is: %d\n", sizeof(long double));
   printf("The size of type size_t is: %d\n", sizeof(size_t));
   printf("The size of type wchar_t is: %d\n", sizeof(wchar_t));
   maxint = pow(2, 8 * sizeof(int) - 1) - 1;
   maxuint = pow(2, 8 * sizeof(unsigned int)) - 1;
   printf("The last positive integer value is %.0f\n", maxint);
   printf("The last positive unsigned integer value is %.0f\n", maxuint);
   for (ic = 0; ic >= -1; ic += 10000);
   printf("%d\n", ic - 10000);
   return(0);
}
