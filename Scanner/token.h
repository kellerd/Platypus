/* Filename: token.h
 * Token declarations necessary for the scanner implementation 
 * CST8152, Assignment #2, Summer 2004.
 * The file is complete
 * Version 2.5
 * Provided by: Svillen Ranev
 */
#ifndef TOKEN_H_
#define TOKEN_H_

/* Constants */

#define VID_LEN 16   /* variable identifier length */
#define ERR_LEN 21   /* error message length */
#define IL_LEN  5   /* maximum number of digits for IL */

/* Token codes */

#define ERR_T     0  /* Error token */
#define SEOF_T    1  /* Source end-of-file token */
#define AVID_T    2  /* Arithmetic Variable identifier token */
#define SVID_T    3  /* String Variable identifier token */
#define FPL_T     4  /* Floating point literal token */
#define IL_T      5  /* Integer literal token */
#define STR_T     6  /* String literal token */
#define SCC_OP_T  7  /* String concatenation operator token */
#define ASS_OP_T  8  /* Assignment operator token */
#define ART_OP_T  9  /* Arithmetic operator token */
#define REL_OP_T 10  /* Relational operator token */ 
#define LOG_OP_T 11  /* Logical operator token */
#define LPR_T    12  /* Left parenthesis token */
#define RPR_T    13  /* Right parenthesis token */
#define LBR_T    14  /* Left brace token */
#define RBR_T    15  /* Right brace token */
#define KW_T     16  /* Keyword token */
#define COM_T    17  /* Comma token */
#define EOS_T    18 /* End of statement *(semi - colon) */


/* Operators token attributes */

typedef enum ArithmeticOperators  {PLUS, MINUS, MULT, DIV} Arr_Op;
typedef enum RelationalOperators  {EQ, NE, GT, LT} Rel_Op;
typedef enum LogicalOperators     {AND,OR} Log_Op;


/* Structure declaring the token and its attributes */

typedef union TokenAttribute{
	int get_int;      /* integer attributes accessor */
	Arr_Op arr_op;    /* arithmetic operator attribute code */
	Rel_Op rel_op;    /* relational operator attribute code */
	Log_Op log_op;    /* logical operator attribute code */
	int i_value;      /* integer literal attribute (value) */
	int kwt_idx;      /* keyword index in the keyword table */	  
	int str_offset;   /* sring literal offset from the beginning of */
	                     /* the string literal buffer (str_buf->bf_head) */
	float f_value;    /* floating-point literal attribute (value) */
        char vid_lex[VID_LEN+1]; /* variable identifier token attribute */
        char err_lex[ERR_LEN]; /* error token attribite */
  } TokenAttribute;

typedef struct Token
{
	int t_code;                 /* token code */
	TokenAttribute attribute; /* token attribute */
} Token;

#endif