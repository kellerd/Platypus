/* Filename: table.h
/* File Name: buffer.c
 * Author: Danny Keller - 040 439 834 - leek0001@algonquincollege.com
 * Course: CST8152 - Lab: 11
 * Assignment: 2 - Scanner
 * Date: June 14, 2004
 * Version: 2.7
 * Professor: Sv. Ranev
 * Purpose:  Transition Table and function declarations necessary for the scanner
 * as required for CST 8152, Assignment #2, Summer 2004.
 * The file is incomplete.
 * Provided by: Svillen Ranev, Version 2.5
 */

#ifndef  TABLE_H_
#define  TABLE_H_

#ifndef BUFFER_H_
#include "buffer.h"
#endif

#ifndef NULL
#include <_null.h> /* NULL pointer constant is defined there */
#endif

#define UEOF 0xFF /* Unsigned EOF */

#define ES  9 /* Error state */
#define ESR 11 /* Error state with retract */
#define IS -1   /* Inavalid state */

/* State transition table definition */

#define TABLE_COLUMNS 9

int st_table[][TABLE_COLUMNS] = {
/* State 0 */  {1, 1, 1, 4, 3, 5, ES,ES,IS},
/* State 1 */  {1, 1, 1, 1, 1, 2,10,2, 2 },
/* State 2 */  {IS,IS,IS,IS,IS,IS,IS,IS,IS},
/* State 3 */  {ES,ES,ES, 3, 3, 6, 7, 7, 7},
/* State 4 */  {ES,ES,12,ES,ES, 6, 7, 7, 7},
/* State 5 */  {ES,ES,ES, 6, 6,ES,ES,ES,ESR},
/* State 6 */  {8,8,8, 6, 6,ES, 8, 8, 8},
/* State 7 */  {IS,IS,IS,IS,IS,IS,IS,IS,IS},
/* State 8 */  {IS,IS,IS,IS,IS,IS,IS,IS,IS},
/* State 9 */  {IS,IS,IS,IS,IS,IS,IS,IS,IS},
/* State 10 */ {ES,ES,ES,ES,ES,ES,ES, 2, 2},
/* State 11 */ {IS,IS,IS,IS,IS,IS,IS,IS,IS},
/* State 12 */ {ES,13,ES,13,13,ES,ES,14,ESR},
/* State 13 */ {14,13,14,13,13,ES,ES,14,14},
/* State 14 */ {IS,IS,IS,IS,IS,IS,IS,IS,IS},
};

/* Accepting state table definition */
#define ASWR     -1  /* accepting state with retract */
#define ASNR     1  /* accepting state with no retract */
#define NOAS     0  /* not accepting state */

int as_table[] = {
NOAS, /* State 0 */
NOAS, /* State 1 */
ASWR, /* State 2 */
NOAS, /* State 3 */
NOAS, /* State 4 */
NOAS, /* State 5 */
NOAS, /* State 6 */
ASWR, /* State 7 */
ASWR, /* State 8 */
ASNR, /* State 9 */
NOAS, /* State 10 */
ASWR, /* State 11 */
NOAS, /* State 12 */
NOAS, /* State 13 */
ASWR /* State 14 */
};

/* Accepting action function declarations */

/*FOR EACH OF YOUR ACCEPTING STATES YOU MUST PROVIDE
ONE FUNCTION PROTOTYPE. THEY ALL RETURN Token AND TAKE
ONE ARGUMENT: string REPRESENTING A TOKEN LEXEME.*/

Token aa_func02(char *lexeme); /* Vid */
Token aa_func07(char *lexeme); /* DIL */
Token aa_func08(char *lexeme); /* FPL */
Token aa_func09(char *lexeme); /* ES - No Retract */
Token aa_func11(char *lexeme); /* ES - With Retract */
Token aa_func14(char *lexeme); /* HIL */

/* defining a new type: pointer to function (of one char * argument)
   returning Token
*/

typedef Token (*PTR_AAF)(char *lexeme);


/* Accepting function (action) callback table (array) definition */
/* If you do not want to use the typedef, the equvalent declaration is:
 * Token (*aa_table[])(char lexeme[]) = {
 * HERE YOU MUST PROVIDE AN INITIALIZATION FOR AN ARRAY OF POINTERS
 * TO ACCEPTING FUNCTIONS. THE ARRAY HAS THE SAME SIZE AS as_table[ ].
 * YOU MUST INITIALIZE THE ARRAY ELEMENTS WITH THE CORRESPONDING
 * ACCEPTING FUNCTIONS (FOR THE STATES MARKED AS ACCEPTING IN as_table[]).
 * THE REST OF THE ELEMENTS MUST BE SET TO NULL.
 */

PTR_AAF aa_table[ ] ={
	NULL, NULL, aa_func02, NULL, NULL, NULL, NULL, aa_func07, aa_func08, aa_func09,
	NULL, aa_func09, NULL, NULL, aa_func14
};

/* Keyword lookup table (AND and OR are processes separately) */

#define KWT_SIZE  8

char * kw_table []= {
                     "DO",
                     "ELSE",
                     "FOR",
                     "IF",
                     "PLATYPUS",
                     "READ",
                     "THEN",
                     "WRITE"
                     };

#endif

