/* File Name: scanner.c
 * Author: Danny Keller - 040 439 834 - leek0001@algonquincollege.com
 * Course: CST8152 - Lab: 11
 * Assignment: 3 - Symbol Table
 * Date: July 13, 2004
 * Version: 3.1
 * Professor: Sv. Ranev
 * PURPOSE:
 *    SCANNER.C: Functions that implement a Lexical Analyzer (Scanner)
 *    as required for CST 8152, Assignment #2, Summer 2004.
 *    scanner_ini() must be called before using the scanner.
 *    The file is incomplete;
 *    Provided by: Svillen Ranev, Version 2.5
 * Function List:
 * 	char_class()
 *		get_next_state()
 *		iskeyword()
 *		atohl()
 *		scanner_init()
 *		get_next_token()
 *		aa_func02()
 *		aa_func08()
 *		aa_func07()
 *		aa_func14()
 *		aa_func09()
 */

/* The symbol table */

#include <stdio.h>   /* standard input / output */
#include <ctype.h>   /* conversion functions */
#include <stdlib.h>  /* standard library functions */
#include <string.h>  /* string functions */
#include <limits.h>  /* integer type constants */
#include <float.h>   /* floating-point type constants */
#include <math.h>		/* for pow, atof function */

/*#define NDEBUG        to suppress assert() call */
#include <assert.h>  /* assert() prototype */

/* project header files */
#include "buffer.h"
#include "token.h"

#ifndef  TABLE_H_
#include "table.h"
#endif

#include "errno.h"

#include "stable.h"
extern STD sym_table;

#define DEBUG  /* for conditional processing */
#undef  DEBUG

#define RUN_TIME_ERROR 1	/* This goes into scerrnum if runtime error occurs */

#define HEX_MIN_DIGITS 3	/* Minimum number of digits for a hex number (0hF)*/
#define HEX_MAX_DIGITS 6	/* Maximum number of digits for a hex number 2 byte (0hFFFF)*/
#define HEX_BASE 16			/* The base of a hex digit */

#define S_FAIL1 -1			/* Scanner integer failure constant */

#ifndef TRUE
#define TRUE 1					/* Boolean true */
#endif

#ifndef FALSE
#define FALSE 0				/* Boolean false */
#endif

/* Global objects - variables */
/* defined in platy_st.c - this is your String Literal Table */
/* this buffer is used as a repository for string literals*/
extern Buffer * str_table;

int line;                /* source code line numbers */
extern int scerrnum;     /* run-time error number - defined in platy_st.c */
/* No other global variable declarations/definitiond are allowed */

/* Function prototypes */
static int char_class(char c); /* character class function */
static int get_next_state(int, char, int *); /* state machine function */
int iskeyword(char * kw_lexeme);
long atohl(char * lexeme); /* converts hex string to decimal value */

/* Function Name: scanner_init
 * Purpose: Takes a buffer to initialize for the main scanner
 * Author: Svillen Ranev
 * Version: ?
 * Called Functions: cb_putc, b_reset
 * Parameters:
 		buf - type: Buffer pointer
               purpose: the main buffer for the main file to scan
 * Return Value: None
 * Algorithm:
 *		ADD file ternimator to buffer
 *		RESET string table
 *		SET line number to 1
 */
void scanner_init(Buffer *buf)
{
        cb_putc(buf, '\0'); /* in case EOF is not in the buffer */
        b_reset(str_table); /* reset the string literal table */
        line = 1;
}

/* Function Name: get_next_token
 * Purpose: Takes a buffer to search for the next token in the file
 * Author: Danny Keller
 *		Minor Implimentation and Psuedo-Code: Svillen Ranev
 * Version: 2.12
 * Called Functions: cb_getsize, b_create, b_destroy, cb_putc, cb_setmark
 *							cb_getmark, isspace, isalnum, get_next_state, aa_table[]
 *							strncmp, printf, sprintf, strcat
 * Parameters:
 		sc_buf - type: Buffer pointer
               purpose: the main buffer for the main file to scan
 * Return Value: None
 * Algorithm:
 *		STATE <- 0
 *		GET next character
 *  	IF size of buffer is overrun OR End of file is found in buffer
 *			TOKEN <- END OF FILE TOKEN
 *		ELSE IF white space is found
 *			SKIP it
 *		ELSE IF a comment is found
 *			SKIP it to end of line or end of file
 *			LinesInFile <- LinesInFile + 1
 *		ELSE IF logical operator OR arithmetic operator or assignment operator found
 *			TOKEN <- that operator
 *		ELSE IF legal string is found
 *			COPY string into string table
 *			TOKEN <- string index in buffer
 *		ELSE IF illegal string
 *			IF string > 20 characters
 *				TOKEN <- Error token (17 characters of string + three periods)
 *		ELSE
 *			TOKEN <- Error token (With string)
 *		ENDIF
 *		IF a character OR digit OR dot(.) is found
 *			FSM0. Begin with state = 0 and the input character c
 *			FSM1. Get the next state from the transition table calling
 *					state = get_next_state(state, c, &accept);
 *			FSM2. Get the next character
 *			FSM3. If the state is not accepting (accept == NOAS), go to step FSM1
 *			If the step is accepting, token is found, leave the machine and
 *		  		call the accepting function as described below.
 *
 *			CREATE  A TEMPORRARY LEXEME BUFFER HERE;
 *			GET THE BEGINNING OF THE LEXEME
 *			. SET forward  IF THE FINAL STATE IS A RETRACTING FINAL STATE
 *			. COPY THE LEXEME INTO lex_buf
 *			. WRITE YOUR CODE HERE
 *			. WHEN VID (KEYWORDS INCLUDED), FPL OR IL IS RECOGNIZED
 *		  	. CALL THE ACCEPTING (aa_table) with lex_buf as arguement
 *		RETURN The token
 */
Token get_next_token(Buffer * sc_buf)
{
	Token t;					/* the token */
	unsigned char c; 		/* input symbol */
	Buffer *lex_buf; 		/* temporary buffer for holding lexemes */
	int accept = NOAS; 	/* Not Accepting State */
	int state = 0;     	/* Start state in the Transition Table */

   /* lexstart is the offset from the beginning of the char buffer of the
	input buffer (sc_buf) to the first character of the current lexeme,
	which is being processed by the scanner. */
	int lexstart;      /* current lexeme start offset - get/setmark*/

	/*forward is the offset from the beginning of the char buffer of the
	input buffer (sc_buf) to the current character, which is to be processed
	by the scanner. forward is static, it will keep the current value */
	static int forward = 0;  /* current input char offset, ititialized only once */

   int buf_size; /* Size of token buffer */

   /* Check if sc_buf is NULL */
	if (sc_buf == NULL) {
   	t = aa_table[ES]("RUN TIME ERROR: ");
		scerrnum = RUN_TIME_ERROR;
      return t;
   }

	buf_size = cb_getsize(sc_buf);
   if (buf_size == R_FAIL1) {
   	t = aa_table[ES]("RUN TIME ERROR: ");
		scerrnum = RUN_TIME_ERROR;
      return t;
   }
	while (TRUE){ /* endless loop broken by token returns */

      /* IF next symbol to process is invalid (off the end of the buffer) */
      if (buf_size <= forward) {
      	t.t_code = SEOF_T;
         return t;
      }
		/* GET NEXT SYMBOL FROM THE INPUT BUFFER */
		c = sc_buf->ca_head[forward++];

		/* special cases or exceptions processing */

		/* Only process special ones if State is 0 */
     	if (isspace(c)) {		/* Skip spaces */
			if (c == '\n' || c == '\r')
        		line++;			/* If newline, increment counter */
      	continue;
  	   }
      switch(c) {
  	      case '\0':
         case UEOF:
         	/* If end of file */
  	   		t.t_code = SEOF_T;
     		   return t;
  	      /* Arethmetic operators */
			case '+':
     			t.t_code = ART_OP_T;
     		   t.attribute.arr_op = PLUS;
  		      return t;
	      case '-':
  	   		t.t_code = ART_OP_T;
   	      t.attribute.arr_op = MINUS;
  	      	return t;
      	case '*':
      		t.t_code = ART_OP_T;
     	   	t.attribute.arr_op = MULT;
  	   	   return t;
   	   case '/':
     			t.t_code = ART_OP_T;
     		   t.attribute.arr_op = DIV;
  		      return t;
      	/* Braces and parenthasis */
        	case '{':
      		t.t_code = LBR_T;
     			return t;
			case '}':
	      	t.t_code = RBR_T;
        		return t;
     		case '(':
   	   	t.t_code = LPR_T;
  	      	return t;
   	   case ')':
      		t.t_code = RPR_T;
     	   	return t;
			/* Statement seperators */
	      case ',':
     			t.t_code = COM_T;
     		   return t;
  		   case ';':
  	   		t.t_code = EOS_T;
      	   return t;
  	   }
  		if (c == '<') {
        	char d;		/* The second character */
         /* If room in buffer for two chars, then check the second one */
         if (forward < buf_size) {
           	#ifdef DEBUG
	            printf("Room for two: %c", c);
            #endif
           	d = sc_buf->ca_head[forward];
            /* String concatination operator */
            if (d == '<') {
            	/* If second is found, increment forward */
		         forward++;
              	t.t_code = SCC_OP_T;
					return t;
     	     	}
         }
  	      /* Less than operator */
         t.t_code = REL_OP_T;
         t.attribute.rel_op = LT;
        	return t;
     	}
  	   if (c == '>') {
         /* Greater than operator */
         t.t_code = REL_OP_T;
        	t.attribute.rel_op = GT;
    	   return t;
  	   }
      if (c == '=') {
      	char d;     /* The second character */
         /* If room for more */
         if (forward < buf_size) {
         	#ifdef DEBUG
	            printf("Room for two: %c", c);
            #endif
           	d = sc_buf->ca_head[forward];
            if (d == '=') {
		         forward++;
              	t.t_code = REL_OP_T;
               t.attribute.rel_op = EQ;
					return t;
     	    	}
         }
         /* Equals operator */
       	t.t_code = ASS_OP_T;
         return t;
  	   }
		if (c == '!') {
      	char d;		/* The second character */
         if (forward < buf_size) {
         	#ifdef DEBUG
	            printf("Room for two: %c", c);
            #endif
            d = sc_buf->ca_head[forward];
            /* != is not equals operator */
				if (d == '=') {
            	forward++;
            	t.t_code = REL_OP_T;
            	t.attribute.rel_op = NE;
					return t;
				} else {
         		/* ![any] is an error */
					t.t_code = ERR_T;
					sprintf(t.attribute.err_lex, "%c", c);
               return t;
            }
         }
         /* ![nothing] */
			t.t_code = ERR_T;
         sprintf(t.attribute.err_lex, "%c", c);
   		return t;
		}
		if (c == '\\') {
      	char findNextLine;	/* char to examine until EOL */
         char d = EOF;			/* Char after \ */
         char Retract = FALSE;	/* If found EOF by default (overrunning end of buffer
         									then don't retract */
         if (forward < buf_size)
         	d = sc_buf->ca_head[forward++];

         /* Comment then skip to new line or eof*/
         if (d != EOF && d != '\0' && d != '\n' && d != '\r') {
	         while (TRUE) {
           		findNextLine = sc_buf->ca_head[forward++];
         	  	if (findNextLine == EOF || findNextLine == '\0'
      	        		|| findNextLine == '\n'  || findNextLine == '\r') {
               	Retract = TRUE;
   	        		break;
               }
               /* Over-running end of buffer */
               if (forward >= buf_size)
               	break;
	         }
         }
         if (d != '>') {/* Errornous letter following - store error */
		      t.t_code = ERR_T;
            /* New lines if error */
				if (findNextLine == '\n' || findNextLine == '\r' || d == '\n' || d == '\r')
               	line++;
            if (d == EOF || d == '\0') {
            	if (Retract == TRUE) /* If EOF then retract */
	           		forward--;
               /* Don't copy EOF */
               sprintf(t.attribute.err_lex, "%c", c);
            } else {
            	sprintf(t.attribute.err_lex, "%c%c", c, d);
            }
            return t;
         }
         /* End of comment, retract to let rest of scanner take care of last character */
         if (Retract == TRUE)
	         forward--;
         if (findNextLine == EOF || findNextLine == '\0' || forward >= buf_size) {
          	 t.t_code = ERR_T;
             sprintf(t.attribute.err_lex, "%c", EOF);
             return t;
         }
         continue;
		}
      /* Check for string literals */
		if (c == '\"')
      {
      	t.t_code = STR_T;
         t.attribute.str_offset = str_table->put_offset;
	      for (lexstart = forward;
           		sc_buf->ca_head[forward] != EOF &&
               sc_buf->ca_head[forward] != '\0' &&
               sc_buf->ca_head[forward] != '\"' &&
               buf_size > forward;
               forward++) {
         	if (sc_buf->ca_head[forward] == '\n' || sc_buf->ca_head[forward] == '\r')
            	line++;
         }

         /* If I got a good string */
         if (forward < buf_size && sc_buf->ca_head[forward] == '\"') {
   	     	/* Store it in the string table */
            for(; lexstart < forward; lexstart++) {
         	  	if (cb_putc(str_table,sc_buf->ca_head[lexstart]) == NULL) {
      				t = aa_table[ES]("RUN TIME ERROR: ");
						scerrnum = RUN_TIME_ERROR;
                  return t;
	            }
   	      }
            /* Put a null byte on the end */
            if (cb_putc(str_table,'\0') == NULL) {
      			t = aa_table[ES]("RUN TIME ERROR: ");
					scerrnum = RUN_TIME_ERROR;
               return t;
            }
            /* Get the char after the " */
            forward++;
            return t;
         } else {
           	/* if error in getting string then it was from EOF */
				t.t_code = ERR_T;
            /* If enough room to store all of error string, do so */
            /* Plus one for bad character */
				if (forward - lexstart + 1 < ERR_LEN) {
              	int i;	/* Simple counter */
 					for (i = 0, lexstart--; lexstart < forward; i++, lexstart++)
                 	t.attribute.err_lex[i] = sc_buf->ca_head[lexstart];
               t.attribute.err_lex[i] = '\0';
            } else {
              	/* Copy only the first ERR_LEN - 4 chars, then quit */
               int i;	/* Simple counter */
 					for (i = 0, lexstart--; i < ERR_LEN - 4; i++, lexstart++)
                 	t.attribute.err_lex[i] = sc_buf->ca_head[lexstart];
               /* And add three dots at the end */
               t.attribute.err_lex[i] = '\0';
               strcat(t.attribute.err_lex, "...");
				}
            /* forward gets left alone because it points to EOF */
            return t;
         }
      }

	  	/* Process state transition table */
	  	/* IF (c is a digit OR c is a letter OR c is a dot (.)){ */
  		if (isalnum(c) || c == '.') {
        	/* SET THE MARK AT THE BEGINING OF THE LEXEME - forward is next char*/
 			if (cb_setmark(sc_buf,forward - 1) == R_FAIL1) {
     			t = aa_table[ES]("RUN TIME ERROR: ");
				scerrnum = RUN_TIME_ERROR;
            return t;
         }
         state = get_next_state(state,c, &accept);
         /* While the state is not accepting (accept == NOAS) go back
         	to step 1 */
         while (accept == NOAS) {
            if (forward >= buf_size) { /* Running off the end by accident (no-sentinal)*/
              	t = aa_table[ES]("RUN TIME ERROR: ");
					scerrnum = RUN_TIME_ERROR;
	            return t;
				} else /* Get the next character */
            	c = sc_buf->ca_head[forward];
            forward++;
            /* Get the next state from the transition table */
            state = get_next_state(state,c, &accept);
			}
         /* If the step is accepting, token is found, leave the machine and
        		call the accepting function */
         if (accept != NOAS) {
          	/* get start of the lexeme */
				if ((lexstart = cb_getmark(sc_buf)) == R_FAIL1) {
      			t = aa_table[ES]("RUN TIME ERROR: ");
					scerrnum = RUN_TIME_ERROR;
               return t;
            }
            /* Create the temp lexeme buffer (+1 is needed for NULL byte) */
            if ((lex_buf = b_create(forward - lexstart + 1, 0, 0.0f)) == NULL) {
      			t = aa_table[ES]("RUN TIME ERROR: ");
					scerrnum = RUN_TIME_ERROR;
               return t;
            }
            /* SET forward  IF THE FINAL STATE IS A RETRACTING FINAL STATE */
            if (accept == ASWR) {
              	forward--;
            }
            /* COPY THE LEXEME INTO lex_buf USING cb_putc(...),
              	lexstart AND forward */
            for (;lexstart < forward; lexstart++) {
               if (! isspace(sc_buf->ca_head[lexstart]))
              		cb_putc(lex_buf,sc_buf->ca_head[lexstart]);
               else
               	if (sc_buf->ca_head[lexstart] == '\n' || sc_buf->ca_head[lexstart] == '\r')
                  	line++;
            }
            /* Now copy the null byte at the end */
            if (cb_putc(lex_buf,'\0') == NULL) {
      			t = aa_table[ES]("RUN TIME ERROR: ");
					scerrnum = RUN_TIME_ERROR;
               return t;
            }
            if (aa_table[state] != NULL) {
              	t = aa_table[state](lex_buf->ca_head);
               return t;
            }
            b_destroy(lex_buf);
            lex_buf = NULL;
         }
      }
		/* If the function ends up here, then a character cannot be
        	recognized (not in the platypus alphabet) */
      t.t_code = ERR_T;
      sprintf(t.attribute.err_lex, "%c", c);

		return t;
   }/*end while(TRUE)*/
}

/* Function Name: get_next_state
 * Purpose: Takes the current state and the next character and gets the state
 *				that follows
 * Author: Svillen Ranev
 * Version: ?
 * Called Functions: assert, printf, exit, char_class
 * Parameters:
 		state - type: integer
               purpose: the current state of the scanner
 		c - type: character
      	 purpose: the next character to check
      accept - type: integer pointer
      	 purpose: the next state's accepting state type
 * Return Value: type: int - purpose: The next state
 */
int get_next_state(int state, char c, int *accept)
{
	int col;
	int next;
	col = char_class(c);
	next = st_table[state][col];
#ifdef DEBUG
printf("Input symbol: %c Row: %d Column: %d Next: %d \n",c,state,col,next);
#endif

/* Assertion failed: test, file filename, line linenum */

       assert(next != IS);

#ifdef DEBUG
	if(next == IS){
	  printf("Scanner Error: Illegal state:\n");
	  printf("Input symbol: %c Row: %d Column: %d\n",c,state,col);
	  exit(1);
	}
#endif
	*accept = as_table[next];
	return next;
}

/* Function Name: char_class
 * Purpose: Takes a character and returns what collumn in the table row it
 				belongs to
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions: None
 * Parameters:
 		c - type: character
          purpose: the character to check what class it is in
 * Return Value: The character collumn in the table
 * Algorithm:
 *		CHECK the current letter, return what collumn it is in the table
 */
int char_class (char c)
{
	int val;		/* The collumn identifier in the TT */
	if ((c >= 'a' && c <= 'g') || (c >= 'i' && c <= 'z') || (c >= 'G' && c <= 'Z'))
   	val = 0;
   else if (c >= 'A' && c <= 'F')
   	val = 1;
   else if (c == 'h')
   	val = 2;
	else if (c == '0')
   	val = 3;
   else if (c >= '1' && c <= '9')
   	val = 4;
   else if (c == '.')
   	val = 5;
   else if (c == '$')
   	val = 6;
   else if (c == EOF || c == '\0')
   	val = 8;
   else	/* Other */
   	val = 7;
	return val;
}

/* Function Name: aa_func02
 * Purpose: Takes a lexeme and stores it as a variable identifier
 * Author: Danny Keller
 * Version: 2.0
 *	History: Version 2.0 uses they symbol table
 * Called Functions: strncpy, iskeyword, strcmp, strlen
 * Parameters:
 		lexeme - type: array of characters
          purpose: the lexeme of the keyword/variable identifier/reserved word
 * Return Value: Token
 * Algorithm:
 *		IF keyword OR reserved word
 *			SET appropriate attribute
 *       SET the type
 *			RETURN token
 *		ELSE
 *			IF last char is $
 *				SET as string variable
 *			ELSE
 *				SET as arithmetic variable
 *			RETURN token
 */
Token aa_func02(char lexeme[]){
	int index;	/* Index of an array or of symbol table */
   Token t;	/* The token */
   /* If not keyword or reserved word, then call accepting func */
   if ((index = iskeyword(lexeme)) >= 0) {
    	t.t_code = KW_T;
      t.attribute.kwt_idx = index;
   	return t;
   } else if (strcmp(lexeme, "OR") == 0) {
   	t.t_code = LOG_OP_T;
		t.attribute.log_op = OR;
		return t;
	}  else if (strcmp(lexeme, "AND") == 0) {
   	t.t_code = LOG_OP_T;
      t.attribute.log_op = AND;
      return t;
   }
   /* If not a reserved word or keyword, check variables */
   /* Truncate to 16 length */
	if (strlen(lexeme) > 16) {
		if (lexeme[strlen(lexeme) - 1] == '$')
			lexeme[VID_LEN - 1] = '$';
   	lexeme[VID_LEN] = '\0';
   }


   /* If end is $ then it is a string VID */
   if (lexeme[strlen(lexeme) - 1] == '$') {
   	t.t_code = SVID_T;
   } else {
     	t.t_code = AVID_T;
   }

 	/* Copy the lexeme into the symbol table */
   index = st_vrinsert(sym_table, lexeme, line);
   if (index == ERR) {
      printf("\nError: Symbol Table full\n");
      st_store(sym_table);
      exit(1);
   }
   t.attribute.vid_stoffset = index;
   return t;
}

/* Function Name: aa_func08
 * Purpose: Takes a lexeme and stores it as a floating point number
 * Author: Danny Keller
 * Version: 1.95
 * Called Functions: atof, aa_table[ES]
 * Parameters:
 		lexeme - type: array of characters
          purpose: the lexeme of the functions
 * Return Value: Token
 * Algorithm:
 *		TRY to convert string
 *		IF error happens
 *			SET error token
 *		ELSE
 *			SET float token
 *		RETURN token
 */
Token aa_func08(char lexeme[]){
	Token t;	/* The token */
	double TheFloat;	/* The double value of the lexeme */
   TheFloat = atof(lexeme);
   if (TheFloat > FLT_MAX || TheFloat < -FLT_MAX  		/* Range */
   	|| (TheFloat > 0 && TheFloat < FLT_MIN) || (TheFloat < 0 && TheFloat > FLT_MIN)
   	|| TheFloat == HUGE_VAL || TheFloat == -HUGE_VAL || errno != EZERO) /* Errors */ {
		t = aa_table[ES](lexeme);
   } else {
      t.t_code = FPL_T;
      t.attribute.f_value = (float)TheFloat;
   }
	return t;
}

/* Function Name: aa_func07
 * Purpose: Takes a lexeme and stores it as a integer number
 * Author: Danny Keller
 * Version: 1.15
 * Called Functions: atoi, strlen, aa_table[ES]
 * Parameters:
 		lexeme - type: array of characters
          purpose: the lexeme of the functions
 * Return Value: Token
 * Algorithm:
 *		TRY to convert string
 *		IF error happens
 *			SET error token
 *		ELSE
 *			SET integer token
 *		RETURN token
 */

Token aa_func07(char lexeme[]){
   Token t;		/* The token */
	int TheDecimal; /* the int value of the lexeme */
   int length = strlen(lexeme);
   if (length > IL_LEN || length == 0) {
		t = aa_table[ES](lexeme);
   } else {
	   TheDecimal = (int)atoi(lexeme);
      if (TheDecimal >= 0) {
      	t.t_code = IL_T;
      	t.attribute.i_value = TheDecimal;
      } else
      	t = aa_table[ES](lexeme);	/* Check range */
   }
	return t;
}

/* Function Name: aa_func14
 * Purpose: Takes a lexeme and stores it as a integer number
 * Author: Danny Keller
 * Version: 1.1
 * Called Functions: atohl, aa_table[ES], strlen
 * Parameters:
 		lexeme - type: array of characters
          purpose: the lexeme of the functions
 * Return Value: Token
 * Algorithm:
 *		TRY to convert string
 *		IF error happens
 *			SET error token
 *		ELSE
 *			SET integer token
 *		RETURN token
 */

Token aa_func14(char lexeme[]){
   Token t;	/* The token */
   int TheDecimal; /* the int value of the lexeme */
   int length = strlen(lexeme); /* THe length of the lexeme */
   if (length > HEX_MAX_DIGITS || length < HEX_MIN_DIGITS) {
   	t = aa_table[ES](lexeme);
   } else {
	   TheDecimal = (int)atohl(lexeme);
      if (TheDecimal >= 0) {
      	/* 0h00... */
      	if (TheDecimal == 0 && length > 3) {
         	t = aa_table[ES](lexeme);
         } else {
      		t.t_code = IL_T;
      		t.attribute.i_value = TheDecimal;
         }
      } else
      	t = aa_table[ES](lexeme);	/* Check range */
   }
	return t;
}

/* Function Name: aa_func09
 * Purpose: Takes a lexeme and puts it into an error
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions: strncpy
 * Parameters:
 		lexeme - type: array of characters
          purpose: the lexeme of the functions
 * Return Value: Token
 * Algorithm:
 *		SET the error token
 *		RETURN the token
 */

Token aa_func09(char lexeme[]){
   Token t;	/* The token */
   strncpy(t.attribute.err_lex, lexeme, ERR_LEN - 1);
	t.attribute.err_lex[ERR_LEN - 1] = '\0';
   t.t_code = ERR_T;
	return t;
}

/* Function Name: atohl
 * Purpose: Takes a hex lexeme and converts it to a long integer
 * Author: Danny Keller
 * Version: 1.10
 * Called Functions: strlen, pow, isdigit
 * Parameters:
 		lexeme - type: char pointer
               purpose: the storage of the hexedecimal string
               form: 0h[0-9A-F]+
 * Return Value: Long value of the hex string
				 if an error happens output is -1
 * Algorithm:
 *		CHOP off first two letters for 0h
 *		Multiplier <- string length of lexeme - 3 (two for 0h, one for the power)
 *		NewNumber <- 0
 *		FOR every character
 *			NewNumber <- NewNumber + 16 ^ Multiplier
 *			Multiplier = Multiplier - 1
 *		ENDFOR
 *		RETURN NewNumber
 */

long atohl(char * lexeme){
   int length = strlen(lexeme) - strlen("0h");	/* Length of actual hex number (length - 0h) */
   int Multiplier = length - 1; /* 16 to the power of Multiplier */
   long NewNumber = 0L; /* Long value of the hex number */

   /* Check arguments */
	if (lexeme == NULL || length == 0)
      return -1L;

	/* Skip the 0h */
	for (lexeme += strlen("0h"); *lexeme != '\0'; lexeme++, Multiplier--) {
   	int charValue;	/* Integer value of one char (1 - 15)
      /* Get the digit value of the char */
      if (isdigit(*lexeme))
      	charValue = *lexeme - '0';
      else if (*lexeme >= 'A' || *lexeme <= 'F')
      	charValue = 10 + (int)(*lexeme - 'A'); /* 10 + (1 TO 5) */
      else
      	return -1L;
   	NewNumber += charValue * (long)pow(HEX_BASE, Multiplier);
   }
   return NewNumber;
}

/* Function Name: iskeyword
 * Purpose: Takes a keyword lexeme checks against a list of PLATYPUS keywords
 * Author: Danny Keller
 * Version: 1.01
 * Called Functions: strcmp
 * Parameters:
 		kw_lexeme - type: char pointer
               	purpose: the storage of the possible keyword string
               	keyword index on found
 * Return Value: 0 on found
				 		S_FAIL1 on not found
 * Algorithm:
 *		FOR every word in the keyword table
 *			IF the next word equals the given lexeme
 *				RETURN 0
 *		RETURN S_FAIL1
 */

int iskeyword(char * kw_lexeme)
{
	int i;		/* Simple counter */
   if (kw_lexeme == NULL)
   	return S_FAIL1;
	for (i = 0; i < KWT_SIZE; i++)
   	if (strcmp(kw_table[i], kw_lexeme) == 0)
      	return i;
   return S_FAIL1;
}