PLATYPUS {

sum = 0.0;
first = -1.0;
second = -(1.2 + 3.0);
third = 7; fourth = 0h4;  
sum = first + second  - (third +fourth); 

mult = sum + 8 * 7;

light$ = "sun ";
day$ = light$ << "shines " << "all" << "day"; \> day$ will contain "sun shines"
day$ = (light$ << "shines") << always; \> Bad

}