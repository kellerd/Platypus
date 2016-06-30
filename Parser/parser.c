/* File Name: parser.c
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
 *	parser
	match
	syn_eh
	syn_printe
	gen_imcode
	program
	opt_statements
	statements
	statements_p
	statement
	assignment_statement
	assignment_expression
	input_statement
	variable_list
	variable_list_p
	output_statement
	output_line
	selection_statement
	if_statement 
	opt_else 
	opt_statement_terminator
	opt_assignment_expression 
	iteration_statement
	string_expression
	string_expression_p
	primary_string_expression
	conditional_expression
	logical_OR_expression
	logical_OR_expression_p
	logical_AND_expression
	logical_AND_expression_p
	arithmetic_expression 
	unary_arithmetic_expression
	additive_arithmetic_expression
	additive_arithmetic_expression_p
	multiplicative_arithmetic_expression
	multiplicative_arithmetic_expression_p
	primary_arithmetic_expression
	relational_expression
	relational_operator
	primary_s_relational_expression
	primary_a_relational_expression
 */

/* project header files */
#include "parser.h"

/* Function Name: parser
 * Purpose: Starts the parser
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: in_buf
 *				type: Buffer pointer
 *				purpose: Source Code location
 * Return Value: None
 * Algorithm:
 * Init buffer
 * get first token
 * match a program
 * match end of file
 * generate IM code
 */

void parser(Buffer * in_buf){
	if (in_buf == NULL)
		return;
  sc_buf = in_buf;
  lookahead = get_next_token(sc_buf);
  program();match(SEOF_T,NO_ATTR);
  gen_imcode("PLATY: Source file parsed");
}

/* Function Name: match
 * Purpose: Matches the token found in lookahead to the items
 				found in the parameters
 * Author: Danny Keller
 * Version: 1.50
 * Called Functions:
 * Parameters: token_code
 *				type: int
 *				purpose: The token code to match
 *			attribute_code
 *				type: int
 *				purpose: The attribute of the token code to match
 * Return Value: None
 * Algorithm:
 * 	Check the token code
 *		IF code has an attribute
 *			CHECK the attribute
 *		ENDIF
 *		IF code is matched
 *			IF code is EOF
 *				RETURN
 *			ELSE
 *				increment token code
 *			ENDIF
 *		ENDIF
 */
void match(int token_code,int attribute_code)
{
   if (lookahead.t_code == token_code)
   {
   	switch(token_code) {
   		/* If the token is a certain set, match the attribute also */
   		case KW_T:
      	case LOG_OP_T:
      	case ART_OP_T:
      	case REL_OP_T:
         	/* These four you have to check attribute */
         	if (lookahead.attribute.get_int != attribute_code) {
            	syn_eh(token_code);
               return;
            }
      }
   	if (lookahead.t_code == SEOF_T) /* If eof will return */
      	return;
      lookahead = get_next_token(sc_buf);
      if (lookahead.t_code == ERR_T) {
      	syn_printe();
         if (scerrnum) /* If it was a runtime error */
         	exit(scerrnum);
      	lookahead = get_next_token(sc_buf);
         synerrno++;
         return;
      }
   } else /* No match */
   	syn_eh(token_code);
}

/* Function Name: syn_eh
 * Purpose: Error handler, match until one correct found, unless EOF
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: sync_token_code
 *				type: int
 *				purpose: The token code to match
 * Return Value: None
 * Algorithm:
 * 	PRINT the error
 *		WHILE (Item not found)
 *			IF (EOF is found while searching
 *				EXIT
 *		IF next token is not EOF
 *			Advance input one more token
 */
void syn_eh(int sync_token_code)
{
	syn_printe();
   synerrno++;
   while (lookahead.t_code != sync_token_code) {
   	lookahead = get_next_token(sc_buf);
   	if (lookahead.t_code == SEOF_T && sync_token_code != SEOF_T)
      	exit(synerrno);
      if (scerrnum) /* Runtime error */
      	exit(scerrnum);
   }
   /* Happens on match EOF with Items after PLATYPUS { } */
   if (lookahead.t_code != SEOF_T) {
   	lookahead = get_next_token(sc_buf);
	   if (scerrnum) /* Runtime error */
   		exit(scerrnum);
   }
}

/* Function Name: syn_printe
 * Purpose: Error printer
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * Algorithm:
 * 	PRINT the error with line, attribute and token code
 */
void syn_printe(void)
{
	printf("PLATY: Syntax error:  Line: %2d\n", line);
   printf("*****  Token code: %2d Attribute: ", lookahead.t_code);
   switch(lookahead.t_code) {
  		/* If the token is a certain set, print the attribute */
  		case KW_T:
      	printf("%s\n", kw_table[lookahead.attribute.kwt_idx]);
         break;
     	case LOG_OP_T:
      	printf("%d\n", lookahead.attribute.log_op);
         break;
     	case ART_OP_T:
      	printf("%d\n", lookahead.attribute.arr_op);
         break;
      case REL_OP_T:
      	printf("%d\n", lookahead.attribute.rel_op);
         break;
      case STR_T:
      	printf("%s\n", &str_table->ca_head[lookahead.attribute.str_offset]);
         break;
      case IL_T:
      	printf("%d\n", lookahead.attribute.i_value);
         break;
      case FPL_T:
      	printf("%5.1f\n", lookahead.attribute.f_value);
         break;
      case ERR_T:
      	printf("%s\n", lookahead.attribute.err_lex);
         break;
      case AVID_T:
      case SVID_T:
      	printf("%s\n", sym_table.pstvrs[lookahead.attribute.vid_stoffset].plex);
         break;
      default:
      	printf("NA\n");
         break;
   }
}

/* Function Name: gen_imcode
 * Purpose: "This has been Parsed" printer
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions: printf
 * Parameters: string
 *				 type: char *
 *				 purpose: storage place of string to output
 * Return Value: None
 * Algorithm:
 * 	PRINT the "this has been parsed" string to the screen
 */
void gen_imcode(char * string)
{
	if (string != NULL)
   	printf("%s\n", string);
}

/* Function Name: program
 * Purpose: Matches the main program
 * Author: Danny Keller
 * FIRST(program) =
 * 	{ PLATYPUS }
 *
 */
void program(void) {
	match(KW_T,PLATYPUS);match(LBR_T,NO_ATTR);opt_statements();
	match(RBR_T,NO_ATTR);
	gen_imcode("PLATY: Program parsed");
}

/* Function Name: opt_statements
 * Purpose: Matches 0 or more statements
 * Author: Danny Keller
 * FIRST(opt statements)
 *	{ FIRST(statements), Î }
 *	{ AVID, SVID, IF, FOR, READ, WRITE, Î }
 */
void opt_statements(void){
	/* FIRST set: {AVID, SVID, IF, FOR, READ, WRITE, e} */
	switch(lookahead.t_code){
   	case AVID_T:
   	case SVID_T:
   	case KW_T:
		/*PLATYPUS, ELSE, THEN, DO can be checked here and/or in
   	statements_p()  */
			statements();
			break;
   	default: /*empty string*/
     		gen_imcode("PLATY: Opt_statements parsed");
         break;
	}
}

/* Function Name: statements
 * Purpose: Matches one or more statements
 * Author: Danny Keller
 * FIRST(statements) = 
 * { FIRST(statement) } =
 * { AVID, SVID, IF, FOR, READ, WRITE }
 */
void statements(void) {
	statement();
   statements_p();
   /*gen_imcode("PLATY: Statements parsed");*/
}

/* Function Name: statements_p
 * Purpose: Matches one or more statements
 * Author: Danny Keller
 * FIRST(statements_prime) =
 * { FIRST(statement), Î } =
 * { AVID, SVID, IF, FOR, READ, WRITE, Î }
 */
void statements_p(void) {
	/* { AVID, SVID, IF, FOR, READ, WRITE, e } */
	switch(lookahead.t_code) {
      case KW_T: /* Check cases for KW's */
      	if(lookahead.attribute.get_int != IF &&
         lookahead.attribute.get_int != FOR &&
         lookahead.attribute.get_int != READ &&
         lookahead.attribute.get_int != WRITE)
	            break;
   	case AVID_T:
      case SVID_T:

         statement();
         statements_p();
         break;
      default:	/* Empty */
      	break;
   }
/*   gen_imcode("PLATY: Statements prime parsed");*/
}

/* Function Name: statement
 * Purpose: Matches one statement
 * Author: Danny Keller
 * FIRST(statement) =
 * { FIRST(assignment statement), FIRST(selection statement), FIRST(iteration statement), FIRST(input statement), FIRST(output statement) }
 * { AVID, SVID, IF, FOR, READ, WRITE }
 */
void statement(void) {
	/* { AVID, SVID, IF, FOR, READ, WRITE } */
	switch(lookahead.t_code){
   	case AVID_T:
      case SVID_T:
      	assignment_statement();
         break;
      case KW_T:
      	switch(lookahead.attribute.kwt_idx) {
         	case IF:
            	selection_statement();
               break;
            case FOR:
            	iteration_statement();
               break;
            case READ:
            	input_statement();
               break;
            case WRITE:
            	output_statement();
	            break;
            default:
            	syn_printe();
               break;
         }
         break;
      default:	/* There is no empty */
      	syn_printe();
      	break;
   }
/*   gen_imcode("PLATY: Statement parsed");*/
}

/* Function Name: assignment_statement
 * Purpose: Matches an assignment statement
 * Author: Danny Keller
 * FIRST(assignment statement) =
 *	{ FIRST(assignment expression) } = 
 *	{ AVID, SVID}
 */
void assignment_statement(void) {
	/* FIRST set { AVID, SVID } */
   assignment_expression();
   match(EOS_T, NO_ATTR);
   gen_imcode("PLATY: Assignment statement parsed");
}

/* Function Name: assignment_expression
 * Purpose: Matches an assignment expression
 * Author: Danny Keller
 * FIRST(assignment expression) = 
 * { AVID, SVID }
 */
void assignment_expression(void) {
	/* FIRST set = {AVID, SVID} */
   switch(lookahead.t_code) {
   	case AVID_T:
      	match(AVID_T, NO_ATTR);
         match(ASS_OP_T, NO_ATTR);
         arithmetic_expression();
		   gen_imcode("PLATY: Assignment expression (arithmetic) parsed");
         break;
      case SVID_T:
      	match(SVID_T, NO_ATTR);
         match(ASS_OP_T, NO_ATTR);
         string_expression();
         gen_imcode("PLATY: Assignment expression (string) parsed");
         break;
      default: /* Never comes here */
      	break;
   }
}

/* Function Name: input_statement
 * Purpose: Matches an input statement
 * Author: Danny Keller
 * FIRST(input statement) = 
 * { READ }
 */
void input_statement(void){
   match(KW_T,READ);match(LPR_T,NO_ATTR);variable_list();
   match(RPR_T,NO_ATTR); match(EOS_T,NO_ATTR);
   gen_imcode("PLATY: READ statement parsed");
}

/* Function Name: variable_list
 * Purpose: Matches one or more variables in a comma separated list
 * Author: Danny Keller
 * FIRST(variable list) =
 *	{ AVID, SVID }
 */
void variable_list(void) {
	/* FIRST set {AVID, SVID} */
   switch(lookahead.t_code) {
   	case SVID_T:
     		match(SVID_T, NO_ATTR);
         break;
   	case AVID_T:
     		match(AVID_T, NO_ATTR);
         break;
      default:
      	syn_printe();
   }
   variable_list_p();
   gen_imcode("PLATY: Variable list parsed");
}

/* Function Name: variable_list_p
 * Purpose: Matches one or more variables in a comma separated list
 * Author: Danny Keller
 * FIRST(variable list prime) =
 *	{ ","  , Î}
 */
void variable_list_p(void) {
	/* {COM} */
   if (lookahead.t_code == COM_T) {
		match(COM_T, NO_ATTR);
      switch(lookahead.t_code) {
      	case SVID_T:
      		match(SVID_T, NO_ATTR);
         	variable_list_p();
            break;
			case AVID_T:
      		match(AVID_T, NO_ATTR);
         	variable_list_p();
            break;
         default:
         	syn_printe();
            break;
   	}
   }  /* Empty */
     /*	gen_imcode("PLATY: Variable list_p parsed"); */
}

/* Function Name: output_statement
 * Purpose: Matches an output statement
 * Author: Danny Keller
 * FIRST(output statement)
 *   { WRITE }
 */
void output_statement(void){
   match(KW_T,WRITE);match(LPR_T,NO_ATTR);output_line();
   match(RPR_T,NO_ATTR); match(EOS_T,NO_ATTR);
   gen_imcode("PLATY: WRITE statement parsed");
}

/* Function Name: output_line
 * Purpose: Matches an output line for the output statement
 * Author: Danny Keller
 * FIRST(output line) =
 *	{ AVID, SVID, STRL, Î }
 */
void output_line(void) {
	switch(lookahead.t_code) {
   	case STR_T:
      	match(STR_T, NO_ATTR);
         gen_imcode("PLATY: Output list (string literal) parsed");
         break;
      case AVID_T:
      case SVID_T:
      	variable_list();
         break;
      default:  /* Empty */
	      gen_imcode("PLATY: Output list (empty) parsed");
         break;
   }

}

/* Function Name: selection_statement
 * Purpose: Matches an if/else statement
 * Author: Danny Keller
 * FIRST(selection statement) =
 *	{ FIRST(if statement) } =
 * { IF }
 */
void selection_statement(void) {
	if_statement();opt_else();opt_statement_terminator();
	gen_imcode("PLATY: IF statement parsed");
}

/* Function Name: if_statement
 * Purpose: Matches if portion of the selection statement
 * Author: Danny Keller
 * FIRST(if statement) = 
 *	{ IF }
 */
void if_statement (void) {
	match(KW_T, IF);
   match(LPR_T,NO_ATTR); conditional_expression(); match(RPR_T,NO_ATTR);

   match(KW_T, THEN);
   match(LBR_T, NO_ATTR); statements(); match(RBR_T, NO_ATTR);
/*	gen_imcode("PLATY: If statement parsed");*/
}

/* Function Name: opt_else
 * Purpose: Matches else portion of the selection statement (if existing)
 * Author: Danny Keller
 * FIRST(opt else) =
 * {ELSE, Î}
 */
void opt_else (void) {
	/* { ELSE, e } */
	switch(lookahead.attribute.get_int) {
   	case ELSE:
			match(KW_T, ELSE);
   		match(LBR_T, NO_ATTR); statements(); match(RBR_T, NO_ATTR);
         break;
      default:
      	break;
   }
/*	gen_imcode("PLATY: Opt_else parsed");*/
}

/* Function Name: opt_statement_terminator
 * Purpose: Matches an optional statement terminator
 * Author: Danny Keller
 * FIRST(opt statement terminator)
 * {; , Î}
 */
void opt_statement_terminator(void) {
	/* EOS, e */
	switch(lookahead.t_code) {
   	case EOS_T:
      	match(EOS_T, NO_ATTR);
         break;
      default:
      	break;
   }
/*   gen_imcode("PLATY: Opt_statement terminator parsed");*/
}

/* Function Name: opt_assignment_expression
 * Purpose: Matches an optional assignment expression
 * Author: Danny Keller
 * FIRST(opt assignment expression) = 
 *	{ FIRST(assignment expression), Î } =
 * { AVID, SVID, Î }
 */
void opt_assignment_expression (void) {
	/* { AVID, SVID, e }*/
	switch(lookahead.t_code) {
   	case AVID_T:
      case SVID_T:
			assignment_expression();
         break;
      default:
      	break;
   }
	/*gen_imcode("PLATY: Opt_assignment expression parsed");*/
}

/* Function Name: iteration_statement
 * Purpose: Matches a for statement
 * Author: Danny Keller
 * FIRST (iteration statement) = 
 *	{ FOR }
 */
void iteration_statement(void) {
	match(KW_T, FOR);
   match(LPR_T, NO_ATTR);
   	opt_assignment_expression(); match(COM_T, NO_ATTR);
   	conditional_expression(); match(COM_T, NO_ATTR);
      opt_assignment_expression();
   match(RPR_T, NO_ATTR);
   match(KW_T, DO);
   match(LBR_T, NO_ATTR);
   	opt_statements();
   match(RBR_T, NO_ATTR);

   opt_statement_terminator();
   gen_imcode("PLATY: FOR statement parsed");
}

/* Function Name: string_expression
 * Purpose: Matches a string concatination(optional) expression
 * Author: Danny Keller
 * FIRST(string expression) = 
 * { SVID, STRL }
 */
void string_expression(void) {
	primary_string_expression();
	string_expression_p();
   gen_imcode("PLATY: String expression parsed");
}

/* Function Name: string_expression_p
 * Purpose: Matches a string concatination(optional) expression
 * Author: Danny Keller
 * FIRST(string expression prime) = 
 * { << , Î }
 */
void string_expression_p(void) {
	/* FIRST set { <<, e } */
   switch(lookahead.t_code) {
   	case SCC_OP_T:
      	match(SCC_OP_T, NO_ATTR);
         primary_string_expression();
         string_expression_p();
         break;
      default:
/*      	gen_imcode("PLATY: String expression prime parsed");*/
			break;
   }
}

/* Function Name: primary_string_expression
 * Purpose: Matches a string literal or string VID
 * Author: Danny Keller
 * FIRST(primary string expression) =
 * { SVID, STRL }
 *
 */
void primary_string_expression(void) {
	/* FIRST set { STR literal, SVID } */
	switch(lookahead.t_code) {
   	case STR_T:
   		match(STR_T, NO_ATTR);
      	break;
   	case SVID_T:
	   	match(SVID_T, NO_ATTR);
         break;
      default:
      	syn_printe();
         break;
      }
   gen_imcode("PLATY: Primary string expression parsed");
}

/* Function Name: conditional_expression
 * Purpose: Matches a conditional expression
 * Author: Danny Keller
 * FIRST(conditional expression)  
 * { FIRST(logical OR  expression) } =
 * { FPL, IL, AVID, SVID, STRL }
 */
void conditional_expression(void) {
	logical_OR_expression();
   gen_imcode("PLATY: Conditional expression parsed");
}

/* Function Name: logical_OR_expression
 * Purpose: Matches a logical OR relational expression
 * Author: Danny Keller
 * FIRST(logical  OR expression) = 
 * { FIRST(logical AND expression) } = 
 * { FPL, IL, AVID, SVID, STRL }
 */
void logical_OR_expression() {
	logical_AND_expression();
   logical_OR_expression_p();
   /*gen_imcode("PLATY: Logical OR expression parsed");*/
}

/* Function Name: logical_OR_expression_p
 * Purpose: Matches a logical OR relational expression
 * Author: Danny Keller
 * FIRST(logical  OR expression prime) = 
 *	{ OR,  Î }
 */
void logical_OR_expression_p(void) {
	/* FIRST set { OR, e } */
   if (lookahead.t_code == LOG_OP_T && lookahead.attribute.log_op == OR) {
   	match(LOG_OP_T, OR);
      logical_AND_expression();
      logical_OR_expression_p();
      gen_imcode("PLATY: Logical OR expression parsed");
   } /* Empty */
     /*	gen_imcode("PLATY: Logical OR expression prime parsed");*/
}

/* Function Name: logical_AND_expression
 * Purpose: Matches a logical AND relational expression
 * Author: Danny Keller
 * FIRST(logical  AND expression) = 
 * { FIRST(relational expression) } = 
 * { FPL, IL, AVID, SVID, STRL }
 */
void logical_AND_expression() {
	relational_expression();
   logical_AND_expression_p();
/*   gen_imcode("PLATY: Logical AND expression parsed");*/
}

/* Function Name: logical_AND_expression_p
 * Purpose: Matches a logical AND relational expression
 * Author: Danny Keller
 * FIRST(logical  AND expression prime) = 
 *	{ AND,  Î }
 */
void logical_AND_expression_p(void) {
	/* FIRST set { OR, e } */
   if (lookahead.t_code == LOG_OP_T && lookahead.attribute.log_op == AND) {
   	match(LOG_OP_T, AND);
      relational_expression();
      logical_AND_expression_p();
      gen_imcode("PLATY: Logical AND expression parsed");
   }  /* Empty */
     /*	gen_imcode("PLATY: Logical AND expression prime parsed");*/
}

/* Function Name: arithmetic_expression
 * Purpose: Matches a math expression
 * Author: Danny Keller
 * FIRST (arithmetic expression) = 
 *	{ FIRST(unary arithmetic expression prime), FIRST(additive arithmetic expression) }
 * { +, -, AVID, FPL, IL, ( }
 */
void arithmetic_expression (void) {
	/* FIRST set { +, -, AVID, FPL, IL, ( } */
	switch(lookahead.t_code) {
   	case ART_OP_T: /* Special case */
      	unary_arithmetic_expression();
         break;
		case AVID_T:
      case FPL_T:
      case IL_T:
      case LPR_T:
	   	additive_arithmetic_expression();
         break;
      default:
      	syn_printe();
         break;
      }
  	gen_imcode("PLATY: Arithmetic expression parsed");
}

/* Function Name: unary_arithmetic_expression
 * Purpose: Matches a unary expression
 * Author: Danny Keller
 * FIRST(unary arithmetic expression) =
 * { +, - }
 */
void unary_arithmetic_expression(void)
{
	/* FIRST set { +, - } */
	/* Only here on t_code == ARR_OP_T, don't check for it */
	switch(lookahead.attribute.arr_op) {
   	case PLUS:
	   	match(ART_OP_T, PLUS);
         break;
      case MINUS:
	   	match(ART_OP_T, MINUS);
         break;
      default:
      	syn_printe();
   }
   primary_arithmetic_expression();
   gen_imcode("PLATY: Unary arithmetic expression parsed");
}

/* Function Name: additive_arithmetic_expression
 * Purpose: Matches a plus and minus expression
 * Author: Danny Keller
 * FIRST(additive arithmetic expression) = 
 * { FIRST(multiplicative arithmetic expression) } =
 * { AVID, FPL, IL, ( }  
 */
void additive_arithmetic_expression(void) {
	multiplicative_arithmetic_expression();
   additive_arithmetic_expression_p();
/*   gen_imcode("PLATY: Additive arithmetic expression parsed");*/
}

/* Function Name: additive_arithmetic_expression_p
 * Purpose: Matches a plus and minus expression
 * Author: Danny Keller
 * FIRST(additive arithmetic expression prime) = 
 * { +, -, Î }
 */
void additive_arithmetic_expression_p(void) {
	/* FIRST set { +, -, e } */
   if (lookahead.t_code == ART_OP_T) {/* Special case */
	   switch(lookahead.attribute.arr_op) {
      	case PLUS:
         	match(ART_OP_T, PLUS);
            multiplicative_arithmetic_expression();
		      additive_arithmetic_expression_p();
            gen_imcode("PLATY: Additive arithmetic expression parsed");
            break;
         case MINUS:
         	match(ART_OP_T, MINUS);
            multiplicative_arithmetic_expression();
		      additive_arithmetic_expression_p();
            gen_imcode("PLATY: Additive arithmetic expression parsed");
            break;
         default:
         	break;
      }

   }/* Else is empty */
/*   gen_imcode("PLATY: Additive arithmetic expression prime parsed");*/
}

/* Function Name: multiplicative_arithmetic_expression
 * Purpose: Matches a mult, div expression
 * Author: Danny Keller
 * FIRST(multiplicative arithmetic expression) = 
 * { FIRST(primary arithmetic expression) } =
 * { AVID, FPL, IL, ( }
 */
void multiplicative_arithmetic_expression(void) {
	primary_arithmetic_expression();
   multiplicative_arithmetic_expression_p();
   /*gen_imcode("PLATY: Multiplicative arithmetic expression parsed"); */
}

/* Function Name: multiplicative_arithmetic_expression_p
 * Purpose: Matches a mult, div expression
 * Author: Danny Keller
 * FIRST(multiplicative arithmetic expression prime) = 
 * {  *, /, Î }
 */
void multiplicative_arithmetic_expression_p(void) {
	/* FIRST set { /, *, e } */
   if (lookahead.t_code == ART_OP_T) {/* Special case */
	   switch(lookahead.attribute.arr_op) {
      	case DIV:
         	match(ART_OP_T, DIV);
            primary_arithmetic_expression();
      		multiplicative_arithmetic_expression_p();
            gen_imcode("PLATY: Multiplicative arithmetic expression parsed");
            break;
         case MULT:
         	match(ART_OP_T, MULT);
            primary_arithmetic_expression();
		      multiplicative_arithmetic_expression_p();
            gen_imcode("PLATY: Multiplicative arithmetic expression parsed");
            break;
         default:
         	break;
      }
   }/* Else is empty */
/*   gen_imcode("PLATY: Multiplicative arithmetic expression prime parsed");*/
}

/* Function Name: primary_arithmetic_expression
 * Purpose: Matches a basic expression
 * Author: Danny Keller
 * FIRST(primary arithmetic expression) =
 * { AVID, FPL, IL, ( }
 */
void primary_arithmetic_expression(void) {
	/* FIRST set { IL, FPL, AVID, ( } */
   switch(lookahead.t_code) {
   	case IL_T:
      	match(IL_T, NO_ATTR);
         break;
      case FPL_T:
      	match(FPL_T, NO_ATTR);
         break;
      case LPR_T:
      	match(LPR_T, NO_ATTR);
         arithmetic_expression();
         match(RPR_T, NO_ATTR);
         break;
      case AVID_T:
      	match(AVID_T, NO_ATTR);
         break;
      default:
      	syn_printe();
         break;
   }
   gen_imcode("PLATY: Primary arithmetic expression parsed");
}

/* Function Name: relational_expression
 * Purpose: Matches a basic relational expression
 * Author: Danny Keller
 * FIRST(relational expression) =
 *	{ FIRST(primary a_relational expression), FIRST(primary s_relational expression) } =
 *	{ FPL, IL, AVID, SVID, STRL }
 */
void relational_expression(void) {
	/* FIRST set {AVID, IL, FPL, SVID, STR} */
   switch(lookahead.t_code) {
   	case SVID_T:
	   case STR_T:
   		primary_s_relational_expression();
      	relational_operator();
      	primary_s_relational_expression();
      	break;
		case AVID_T:
   	case IL_T:
	   case FPL_T:
			primary_a_relational_expression();
	      relational_operator();
	      primary_a_relational_expression();
   	   break;
      default:
      	syn_printe();
         break;
   }
	gen_imcode("PLATY: Relational expression parsed");
}

/* Function Name: relational_operator
 * Purpose: Matches relational operator
 * Author: Danny Keller
 * FIRST(relational operator) =
 *	{ EQ, LT, NE, EQ }
 */
void relational_operator(void) {
	/* FIRST set { GT, LT, NE, EQ } */
	if (lookahead.t_code == REL_OP_T) {
		switch(lookahead.attribute.rel_op) {
			case GT:
		   	match(REL_OP_T, GT);
         	break;
         case LT:
	   		match(REL_OP_T, LT);
            break;
   		case NE:
		   	match(REL_OP_T, NE);
            break;
   		case EQ:
		   	match(REL_OP_T, EQ);
            break;
         default:
         	syn_printe();
            break;
      }
   } else
   	syn_printe();
/*   gen_imcode("PLATY: Relational operator parsed");*/
}

/* Function Name: primary_s_relational_expression
 * Purpose: Matches string literal or SVID
 * Author: Danny Keller
 * FIRST(primary s_relational expression)
 * {SVID, STRL}
 */
void primary_s_relational_expression(void) {
	switch(lookahead.t_code) {
      case STR_T:
      case SVID_T:
      	primary_string_expression();
         break;
      default:
      	syn_printe();
         break;
   }
	gen_imcode("PLATY: Primary s_relational expression parsed");
}

/* Function Name: primary_a_relational_expression
 * Purpose: Matches a FPL, IL, or AVID
 * Author: Danny Keller
 * FIRST(primary a_relational expression)
 *  {FPL, IL, AVID}
 */
void primary_a_relational_expression(void) {
	switch(lookahead.t_code) {
   	case IL_T:
	   	match(IL_T, NO_ATTR);
         break;
      case FPL_T:
	   	match(FPL_T, NO_ATTR);
         break;
   	case AVID_T:
	   	match(AVID_T, NO_ATTR);
         break;
      default:
      	syn_printe();
         break;
   }
	gen_imcode("PLATY: Primary a_relational expression parsed");
}
