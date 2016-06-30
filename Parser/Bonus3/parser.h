/* File Name: parser.h
 * Author: Danny Keller - 040 439 834 - leek0001@algonquincollege.com
 * Course: CST8152 - Lab: 11
 * Assignment: 4 - Parser
 * Date: Aug 2, 2004
 * Version: 1.0
 * Professor: Sv. Ranev
 * PURPOSE:
 *    PARSER.C: Functions that implement a RDPP
 *    as required for CST 8152, Assignment #4, Summer 2004.
 *	Function List:
 *
 */
#ifndef  PARSER_H_
#define  PARSER_H_

/* project header files */
#include "buffer.h"
#include "token.h"
extern char * kw_table [];
#include "stable.h"
#include "List.h"
#include "Stack.h"

#ifndef DEBUG
#define DEBUG
#endif
#undef DEBUG

static Token lookahead;		/* Contains the next lookahead in the scanner */
static Buffer * sc_buf;		/* Buffer containing source input */
int synerrno;					/* Error number */
extern STD sym_table;		/* The symbol table */
extern Buffer * str_table; /* String literal table */
extern int scerrnum;			/* Scanner run time error */
extern int line;				/* Line number counter */

extern List sem_analisys;			/* Semantic analysis stack a = 6; */
extern List re_arrange;				/* Converting Infix to Postfix */

extern int Evaluate;

ListNode * evaluate(ListNode * Start);
extern void post_fix(List * psStack);
extern void conditional_fix(List * plList);

int numLoops;				/* For checking if the current portion of the stack
									should be deleted */

/* Constant definitions for parser */
#define NO_ATTR -666

#ifndef FALSE
#define FALSE 0		/* BOOLean FALSE return value */
#endif

#ifndef TRUE
#define TRUE 1		/* BOOLean TRUE return value */
#endif


#define DO 0
#define ELSE 1
#define FOR 2
#define IF 3
#define PLATYPUS 4
#define READ 5
#define THEN 6
#define WRITE 7

/* Extern function prototypes */
extern Token get_next_token(Buffer * sc_buf);

/* Function prototypes */
void parser(Buffer * in_buf);
void match(int token_code,int attribute_code, List * plList);
void syn_eh(int sync_token_code);
void syn_printe(void);
void gen_imcode(char * string);

/* Grammar functions */
void program(void);
void opt_statements(void);
void statements(void);
void statements_p(void);
void statement(void);
void assignment_statement(void);
void assignment_expression(void);
void input_statement(void);
void variable_list(void);
void variable_list_p(void);
void output_statement(void);
void output_line(void);
void selection_statement(void);
ListNode * if_statement (void);
void opt_else (void);
void opt_statement_terminator(void);
int opt_assignment_expression (void);
void iteration_statement(void);
void string_expression(void);
void string_expression_p(void);
void primary_string_expression(void);
void conditional_expression(void);
void logical_OR_expression(void);
void logical_OR_expression_p(void);
void logical_AND_expression(void);
void logical_AND_expression_p(void);
void arithmetic_expression (void);
void unary_arithmetic_expression(void);
void additive_arithmetic_expression(void);
void additive_arithmetic_expression_p(void);
void multiplicative_arithmetic_expression(void);
void multiplicative_arithmetic_expression_p(void);
void primary_arithmetic_expression(void);
void relational_expression(void);
void relational_operator(void);
void primary_s_relational_expression(void);
void primary_a_relational_expression(void);
#endif
