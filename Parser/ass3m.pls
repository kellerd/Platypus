\> This program calculates the sum and the average
\> of 5 numbers
PLATYPUS {
day1 = 1.;
day2 = 2.;
day3 = 3.;
day4 = 4.;
day5 = 5.;
sum = day1 + day2 + day3 + day4 + day5; 
avg = 0.0;
temp = sum;
WRITE("Calculating...
 sum and avg");
res$ = "Result\n";
i = 0; n=00;
FOR (,temp > 5.0 OR temp == 5.0,)DO {
  temp = temp - 5.0;
  avg = avg + 1.0;
  i = i + 01;
};
WRITE(res$);
WRITE(sum);
WRITE(i,avg);
}

