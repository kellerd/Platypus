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
extern void print_token(Token t);

/* Function Name: parser
 * Purpose: Starts the parser
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions: stack_init
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

  sem_analisys = stack_init();
  re_arrange = stack_init();

  Evaluate = TRUE;

  lookahead = get_next_token(sc_buf);
  program();match(SEOF_T,NO_ATTR, &sem_analisys);

  /* Items have been pushed from within the match function, so the interperator's
     implimentation will have less change */
  stack_destroy(&sem_analisys);	/* Will clean up other items inserted */
  stack_destroy(&re_arrange);

  gen_imcode("PLATY: Source file parsed");
}

/* Function Name: match
 * Purpose: Matches the token found in lookahead to the items
 				found in the parameters
 * Author: Danny Keller
 * Version: 1.50
 * Called Functions: get_next_token, syn_eh
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
void match(int token_code,int attribute_code, List * plListToInsert)
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
      /* For semantic analysis, push the correct ones */
      /* If match, then token_code is same as lookahead.t_code */
	   if (plListToInsert != NULL) {
		   /* Failsafe for IF statement and gobbling until end of IF statement */
		   if (lookahead.t_code == EOS_T)
			   lookahead.attribute.get_int = -1;
			if (list_addhead(plListToInsert, lookahead) == ERR)
         	exit(ERR);
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
 * Called Functions: get_next_token, syn_printe, exit
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
 * Called Functions: printf
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
   exit(synerrno);
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
	if (string != NULL)return;
/*   	printf("%s\n", string);*/
}

/* Function Name: program
 * Purpose: Matches the main program
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(program) =
 * 	{ PLATYPUS }
 *
 * Algorithm:
 * 	See Grammar
 */
void program(void) {
	match(KW_T,PLATYPUS, NULL);match(LBR_T,NO_ATTR, NULL);opt_statements();
	match(RBR_T,NO_ATTR, NULL);
	gen_imcode("PLATY: Program parsed");
}

/* Function Name: opt_statements
 * Purpose: Matches 0 or more statements
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(opt statements)
 *	{ FIRST(statements), e }
 *	{ AVID, SVID, IF, FOR, READ, WRITE, e }
 * Algorithm:
 * 	See Grammar
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(statements) =
 * { FIRST(statement) } =
 * { AVID, SVID, IF, FOR, READ, WRITE }
 * Algorithm:
 * 	See Grammar
 */
void statements(void) {
	statement();
   statements_p();
   /*gen_imcode("PLATY: Statements parsed");*/
}

/* Function Name: statements_p
 * Purpose: Matches one or more statements
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(statements_prime) =
 * { FIRST(statement), e } =
 * { AVID, SVID, IF, FOR, READ, WRITE, e }
 * Algorithm:
 * 	See Grammar
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(statement) =
 * { FIRST(assignment statement), FIRST(selection statement), FIRST(iteration statement), FIRST(input statement), FIRST(output statement) }
 * { AVID, SVID, IF, FOR, READ, WRITE }
 * Algorithm:
 * 	See Grammar
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(assignment statement) =
 *	{ FIRST(assignment expression) } =
 *	{ AVID, SVID}
 * Algorithm:
 * 	See Grammar
 */
void assignment_statement(void) {
	ListNode * Start;
	/* FIRST set { AVID, SVID } */
   assignment_expression();

   /* Get back "VID =" as start */
   /* All others were placed in re_arrange */
   Start = sem_analisys.plnHead;

   /* Only post fix on AVID_T */
   if (Start->pData.t_code == AVID_T)
      post_fix(&re_arrange);

   /* Numbers and operands are stored in &re_arrange */
   if (list_merge(&sem_analisys,&re_arrange) == ERR)
      exit(ERR);

   match(EOS_T, NO_ATTR, &sem_analisys);
   evaluate(Start);
   /* Pop until Start */
   if (numLoops == 0) {
	   while (Start != sem_analisys.plnHead && sem_analisys.plnHead != NULL)
   		list_deletehead(&sem_analisys);
   	/* And once more for start */
   	list_deletehead(&sem_analisys);
   }
   gen_imcode("PLATY: Assignment statement parsed");
}

/* Function Name: assignment_expression
 * Purpose: Matches an assignment expression
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(assignment expression) =
 * { AVID, SVID }
 * Algorithm:
 * 	See Grammar
 */
void assignment_expression(void) {
	/* FIRST set = {AVID, SVID} */
   switch(lookahead.t_code) {
   	case AVID_T:
      	match(AVID_T, NO_ATTR, &sem_analisys);
         match(ASS_OP_T, NO_ATTR, NULL);
         arithmetic_expression();
		   gen_imcode("PLATY: Assignment expression (arithmetic) parsed");
         break;
      case SVID_T:
      	match(SVID_T, NO_ATTR, &sem_analisys);
         match(ASS_OP_T, NO_ATTR, NULL);
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(input statement) =
 * { READ }
 * Algorithm:
 * 	See Grammar
 */
void input_statement(void){
	ListNode * Start;

   match(KW_T,READ, &sem_analisys);
   Start = sem_analisys.plnHead;

   match(LPR_T,NO_ATTR, NULL);variable_list();
   match(RPR_T,NO_ATTR, NULL); match(EOS_T,NO_ATTR, &sem_analisys);

   evaluate(Start);

   if (numLoops == 0) {
	   while (Start != sem_analisys.plnHead && sem_analisys.plnHead != NULL)
   		list_deletehead(&sem_analisys);
   	/* And once more for start */
   	list_deletehead(&sem_analisys);
   }
   gen_imcode("PLATY: READ statement parsed");
}

/* Function Name: variable_list
 * Purpose: Matches one or more variables in a comma separated list
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(variable list) =
 *	{ AVID, SVID }
 * Algorithm:
 * 	See Grammar
 */
void variable_list(void) {
	/* FIRST set {AVID, SVID} */
   switch(lookahead.t_code) {
   	case SVID_T:
     		match(SVID_T, NO_ATTR, &sem_analisys);
         break;
   	case AVID_T:
     		match(AVID_T, NO_ATTR, &sem_analisys);
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(variable list prime) =
 *	{ ","  , e}
 * Algorithm:
 * 	See Grammar
 */
void variable_list_p(void) {
	/* {COM} */
   if (lookahead.t_code == COM_T) {
		match(COM_T, NO_ATTR, NULL);
      switch(lookahead.t_code) {
      	case SVID_T:
      		match(SVID_T, NO_ATTR, &sem_analisys);
         	variable_list_p();
            break;
			case AVID_T:
      		match(AVID_T, NO_ATTR, &sem_analisys);
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(output statement)
 *   { WRITE }
 * Algorithm:
 * 	See Grammar
 */
void output_statement(void){
   ListNode * Start;
   match(KW_T,WRITE, &sem_analisys);
   Start = sem_analisys.plnHead;

   match(LPR_T,NO_ATTR, NULL);output_line();
   match(RPR_T,NO_ATTR, NULL); match(EOS_T,NO_ATTR, &sem_analisys);

   evaluate(Start);

   if (numLoops == 0) {
	   while (Start != sem_analisys.plnHead && sem_analisys.plnHead != NULL)
   		list_deletehead(&sem_analisys);
   	/* And once more for start */
   	list_deletehead(&sem_analisys);
   }

   gen_imcode("PLATY: WRITE statement parsed");
}

/* Function Name: output_line
 * Purpose: Matches an output line for the output statement
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(output line) =
 *	{ AVID, SVID, STRL, e }
 * Algorithm:
 * 	See Grammar
 */
void output_line(void) {
	switch(lookahead.t_code) {
   	case STR_T:
      	match(STR_T, NO_ATTR, &sem_analisys);
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(selection statement) =
 *	{ FIRST(if statement) } =
 * { IF }
 * Algorithm:
 * 	See Grammar
 */
void selection_statement(void) {
	int oldEvaluate = Evaluate;
   ListNode * Start;
   Token NewToken;

	numLoops++;
   Evaluate = FALSE;
	Start = if_statement();

   opt_else();opt_statement_terminator();

   /* Put the IF terminator on the stack */
	NewToken.t_code = RBR_T;
   NewToken.attribute.get_int = IF;
	if (list_addhead(&sem_analisys, NewToken) == ERR)
   	exit(ERR);

   NewToken.t_code = EOS_T;
   NewToken.attribute.get_int = numLoops;
   /* Add an eos on the end of last assignment expression */
   if (list_addhead(&sem_analisys, NewToken) == ERR)
   	exit(ERR);

   /* Add a } to signify the end of the FOR */

   Evaluate = oldEvaluate;
   evaluate(Start);
   numLoops--;
   if (numLoops == 0) {
	   while (Start != sem_analisys.plnHead && sem_analisys.plnHead != NULL)
   		list_deletehead(&sem_analisys);
   	/* And once more for start */
   	list_deletehead(&sem_analisys);
   }
	gen_imcode("PLATY: IF statement parsed");
}

/* Function Name: if_statement
 * Purpose: Matches if portion of the selection statement
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(if statement) =
 *	{ IF }
 * Algorithm:
 * 	See Grammar
 */
ListNode * if_statement (void) {
   ListNode * Return;
   Token NewToken;
   
	match(KW_T, IF, &sem_analisys);
	Return = sem_analisys.plnHead;

   /* Used to match up the end of the loop to the beginning of the if statement */
   NewToken.t_code = EOS_T;
   NewToken.attribute.get_int = numLoops;
	if (list_addhead(&sem_analisys, NewToken) == ERR)
   	exit(ERR);

   match(LPR_T,NO_ATTR, NULL); conditional_expression(); match(RPR_T,NO_ATTR, &sem_analisys);
   evaluate(Return);
   match(KW_T, THEN, NULL);
   match(LBR_T, NO_ATTR, NULL); statements(); match(RBR_T, NO_ATTR, NULL);
   return Return;
/*	gen_imcode("PLATY: If statement parsed");*/
}

/* Function Name: opt_else
 * Purpose: Matches else portion of the selection statement (if existing)
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(opt else) =
 * {ELSE, e}
 * Algorithm:
 * 	See Grammar
 */
void opt_else () {
	Token NewToken;
	/* { ELSE, e } */
   /* Store old evaluate because this else could be inside another conditional
      statement, and we do not want to overwrite the old result */
   /*int oldEvaluate = Evaluate;*/
	switch(lookahead.attribute.get_int) {
   	case ELSE:
			match(KW_T, ELSE, &sem_analisys);
			NewToken.t_code = EOS_T;
			NewToken.attribute.get_int = numLoops;
			if (list_addhead(&sem_analisys, NewToken) == ERR)
	   		exit(ERR);
   		match(LBR_T, NO_ATTR, NULL); statements(); match(RBR_T, NO_ATTR, NULL);
         break;
      default:
      	break;
   }
/*	gen_imcode("PLATY: Opt_else parsed");*/
}

/* Function Name: opt_statement_terminator
 * Purpose: Matches an optional statement terminator
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(opt statement terminator)
 * {; , e}
 * Algorithm:
 * 	See Grammar
 */
void opt_statement_terminator(void) {
	/* EOS, e */
	switch(lookahead.t_code) {
   	case EOS_T:
      	match(EOS_T, NO_ATTR, NULL);
         break;
      default:
      	break;
   }
/*   gen_imcode("PLATY: Opt_statement terminator parsed");*/
}

/* Function Name: opt_assignment_expression
 * Purpose: Matches an optional assignment expression
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(opt assignment expression) =
 *	{ FIRST(assignment expression), e } =
 * { AVID, SVID, e }
 * Algorithm:
 * 	See Grammar
 */
int opt_assignment_expression (void) {
   int hasAssignmentExpression = TRUE;
	/* { AVID, SVID, e }*/
	switch(lookahead.t_code) {
   	case AVID_T:
      case SVID_T:
			assignment_expression();
         break;
      default:
      	hasAssignmentExpression = FALSE;
      	break;
   }
	/*gen_imcode("PLATY: Opt_assignment expression parsed");*/
   return hasAssignmentExpression;
}

/* Function Name: iteration_statement
 * Purpose: Matches a for statement
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST (iteration statement) =
 *	{ FOR }
 * Algorithm:
 * 	See Grammar
 */
void iteration_statement(void) {
   int oldEvaluate = Evaluate;
	ListNode * Start;
	ListNode * AssignmentStart;
   List plTemp = list_init();
   Token NewToken;
   NewToken.t_code = KW_T;
   NewToken.attribute.kwt_idx = FOR;

	match(KW_T, FOR, NULL);
   match(LPR_T, NO_ATTR, NULL);
   AssignmentStart = (opt_assignment_expression() == TRUE) ? sem_analisys.plnHead : NULL;
	if (AssignmentStart != NULL) {
	   /* Only post fix on AVID_T */
   	if (AssignmentStart->pData.t_code == AVID_T)
      	post_fix(&re_arrange);

	   /* Numbers and operands are stored in &re_arrange */
   	if (list_merge(&sem_analisys,&re_arrange) == ERR)
      	exit(ERR);

   	match(COM_T, NO_ATTR, &sem_analisys);
		/* Execute the initial statement */
	   evaluate(AssignmentStart);
      if (numLoops == 0) {
		   while (AssignmentStart != sem_analisys.plnHead && sem_analisys.plnHead != NULL)
   			list_deletehead(&sem_analisys);
   		/* And once more for start */
   		list_deletehead(&sem_analisys);
   	}
   } else
   	match(COM_T, NO_ATTR, NULL); /* Still match the comma if no assignment */

	/* Assignment statement will be deleted if the current for loop is not nested
   	if not, when upper loop is deleted, assignment will be deleted */
	Evaluate = FALSE;
	
	/* Put FOR on the list, since it was matched before */
	if (list_addhead(&sem_analisys, NewToken) == ERR)
   	exit(ERR);
	Start = sem_analisys.plnHead;


   numLoops++;
   /* Add the number of loops so far */
	NewToken.t_code = EOS_T;
	NewToken.attribute.get_int = numLoops;
	if (list_addhead(&sem_analisys, NewToken) == ERR)
   	exit(ERR);

   /* List will be (if assignment statement not deleted):
   	a = 4 3 8 * + , FOR a == b str$ > "abcd" OR, statements... ;*/

   conditional_expression();
   match(COM_T, NO_ATTR, &sem_analisys);

	AssignmentStart = (opt_assignment_expression() == TRUE) ? sem_analisys.plnHead : NULL;
	if (AssignmentStart != NULL) {
	   /* Only post fix on AVID_T */
   	if (AssignmentStart->pData.t_code == AVID_T)
      	post_fix(&re_arrange);
	   	if (list_merge(&sem_analisys,&re_arrange) == ERR)
      		exit(ERR);
		/* Grab back until comma */
	   while(sem_analisys.plnHead != NULL && sem_analisys.plnHead->pData.t_code != COM_T) {
			list_addtail(&plTemp, list_deletehead(&sem_analisys));
	   }

	}

   match(RPR_T, NO_ATTR, NULL);
   match(KW_T, DO, NULL);
   match(LBR_T, NO_ATTR, NULL);
   	opt_statements();
   match(RBR_T, NO_ATTR, NULL);

   opt_statement_terminator();
   if (AssignmentStart != NULL) {
		if (list_merge(&sem_analisys,&plTemp) == ERR)
			exit(ERR);
		/* For switching the end expression to the end of the for statement */

		NewToken.attribute.get_int = -1;
		NewToken.t_code = EOS_T;
      /* Add an eos on the end of last assignment expression */
		if (list_addhead(&sem_analisys, NewToken) == ERR)
      	exit(ERR);

   }

   NewToken.t_code = RBR_T;
	NewToken.attribute.get_int = FOR;
   /* Add a } to signify the end of the FOR */
	if (list_addhead(&sem_analisys, NewToken) == ERR)
      	exit(ERR);

	NewToken.t_code = EOS_T;
	NewToken.attribute.get_int = numLoops;
	if (list_addhead(&sem_analisys, NewToken) == ERR)
   	exit(ERR);
   /* Turn evaluation back on if it was before */
   Evaluate = oldEvaluate;

	/* Evaluate the loop here */
   evaluate(Start);

   numLoops--;

   if (numLoops == 0) {
	   while (Start != sem_analisys.plnHead && sem_analisys.plnHead != NULL)
   		list_deletehead(&sem_analisys);
   	/* And once more for start */
   	list_deletehead(&sem_analisys);
   }

   gen_imcode("PLATY: FOR statement parsed");
   list_destroy(&plTemp);
}

/* Function Name: string_expression
 * Purpose: Matches a string concatination(optional) expression
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(string expression) =
 * { SVID, STRL }
 * Algorithm:
 * 	See Grammar
 */
void string_expression(void) {
	primary_string_expression();
	string_expression_p();
   gen_imcode("PLATY: String expression parsed");
}

/* Function Name: string_expression_p
 * Purpose: Matches a string concatination(optional) expression
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(string expression prime) =
 * { << , e }
 * Algorithm:
 * 	See Grammar
 */
void string_expression_p(void) {
	/* FIRST set { <<, e } */
   switch(lookahead.t_code) {
   	case SCC_OP_T:
      	match(SCC_OP_T, NO_ATTR, NULL);
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(primary string expression) =
 * { SVID, STRL }
 *
 * Algorithm:
 * 	See Grammar
 */
void primary_string_expression(void) {
	/* FIRST set { STR literal, SVID } */
	switch(lookahead.t_code) {
   	case STR_T:
   		match(STR_T, NO_ATTR, &re_arrange);
      	break;
   	case SVID_T:
	   	match(SVID_T, NO_ATTR, &re_arrange);
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(conditional expression)
 * { FIRST(logical OR  expression) } =
 * { FPL, IL, AVID, SVID, STRL }
 * Algorithm:
 * 	See Grammar
 */
void conditional_expression(void) {
	logical_OR_expression();
   conditional_fix(&re_arrange);
   list_merge(&sem_analisys, &re_arrange);
   gen_imcode("PLATY: Conditional expression parsed");
}

/* Function Name: logical_OR_expression
 * Purpose: Matches a logical OR relational expression
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(logical  OR expression) =
 * { FIRST(logical AND expression) } =
 * { FPL, IL, AVID, SVID, STRL }
 * Algorithm:
 * 	See Grammar
 */
void logical_OR_expression() {
	logical_AND_expression();
   logical_OR_expression_p();
   /*gen_imcode("PLATY: Logical OR expression parsed");*/
}

/* Function Name: logical_OR_expression_p
 * Purpose: Matches a logical OR relational expression
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(logical  OR expression prime) =
 *	{ OR,  e }
 * Algorithm:
 * 	See Grammar
 */
void logical_OR_expression_p(void) {
	/* FIRST set { OR, e } */
   if (lookahead.t_code == LOG_OP_T && lookahead.attribute.log_op == OR) {
   	match(LOG_OP_T, OR, &re_arrange);
      logical_AND_expression();
      logical_OR_expression_p();
      gen_imcode("PLATY: Logical OR expression parsed");
   } /* Empty */
     /*	gen_imcode("PLATY: Logical OR expression prime parsed");*/
}

/* Function Name: logical_AND_expression
 * Purpose: Matches a logical AND relational expression
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(logical  AND expression) =
 * { FIRST(relational expression) } =
 * { FPL, IL, AVID, SVID, STRL }
 * Algorithm:
 * 	See Grammar
 */
void logical_AND_expression() {
	relational_expression();
   logical_AND_expression_p();
/*   gen_imcode("PLATY: Logical AND expression parsed");*/
}

/* Function Name: logical_AND_expression_p
 * Purpose: Matches a logical AND relational expression
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(logical  AND expression prime) =
 *	{ AND,  e }
 * Algorithm:
 * 	See Grammar
 */
void logical_AND_expression_p(void) {
	/* FIRST set { OR, e } */
   if (lookahead.t_code == LOG_OP_T && lookahead.attribute.log_op == AND) {
   	match(LOG_OP_T, AND, &re_arrange);
      relational_expression();
      logical_AND_expression_p();
      gen_imcode("PLATY: Logical AND expression parsed");
   }  /* Empty */
     /*	gen_imcode("PLATY: Logical AND expression prime parsed");*/
}

/* Function Name: arithmetic_expression
 * Purpose: Matches a math expression
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST (arithmetic expression) =
 *	{ FIRST(unary arithmetic expression prime), FIRST(additive arithmetic expression) }
 * { +, -, AVID, FPL, IL, ( }
 * Algorithm:
 * 	See Grammar
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(unary arithmetic expression) =
 * { +, - }
 * Algorithm:
 * 	See Grammar
 */
void unary_arithmetic_expression(void)
{
	Token NewToken;
   NewToken.t_code = ART_OP_T;
	/* FIRST set { +, - } */
	/* Only here on t_code == ARR_OP_T, don't check for it */
	switch(lookahead.attribute.arr_op) {
   	case PLUS:
	   	match(ART_OP_T, PLUS, NULL);
         /* This is for order of precedence */
			NewToken.attribute.arr_op = POSATE;
         if (list_addhead(&re_arrange,NewToken) == ERR)
         	exit(ERR);
         break;
      case MINUS:
	   	match(ART_OP_T, MINUS, NULL);
         /* This is for order of precedence */
         NewToken.attribute.arr_op = NEGATE;
         if (list_addhead(&re_arrange,NewToken) == ERR)
         	exit(ERR);
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(additive arithmetic expression) =
 * { FIRST(multiplicative arithmetic expression) } =
 * { AVID, FPL, IL, ( }
 * Algorithm:
 * 	See Grammar
 */
void additive_arithmetic_expression(void) {
	multiplicative_arithmetic_expression();
   additive_arithmetic_expression_p();
/*   gen_imcode("PLATY: Additive arithmetic expression parsed");*/
}

/* Function Name: additive_arithmetic_expression_p
 * Purpose: Matches a plus and minus expression
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(additive arithmetic expression prime) =
 * { +, -, e }
 * Algorithm:
 * 	See Grammar
 */
void additive_arithmetic_expression_p(void) {
	/* FIRST set { +, -, e } */
   if (lookahead.t_code == ART_OP_T) {/* Special case */
	   switch(lookahead.attribute.arr_op) {
      	case PLUS:
         	match(ART_OP_T, PLUS, &re_arrange);
            multiplicative_arithmetic_expression();
		      additive_arithmetic_expression_p();
            gen_imcode("PLATY: Additive arithmetic expression parsed");
            break;
         case MINUS:
         	match(ART_OP_T, MINUS, &re_arrange);
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(multiplicative arithmetic expression) =
 * { FIRST(primary arithmetic expression) } =
 * { AVID, FPL, IL, ( }
 * Algorithm:
 * 	See Grammar
 */
void multiplicative_arithmetic_expression(void) {
	primary_arithmetic_expression();
   multiplicative_arithmetic_expression_p();
   /*gen_imcode("PLATY: Multiplicative arithmetic expression parsed"); */
}

/* Function Name: multiplicative_arithmetic_expression_p
 * Purpose: Matches a mult, div expression
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(multiplicative arithmetic expression prime) =
 * {  *, /, e }
 * Algorithm:
 * 	See Grammar
 */
void multiplicative_arithmetic_expression_p(void) {
	/* FIRST set { /, *, e } */
   if (lookahead.t_code == ART_OP_T) {/* Special case */
	   switch(lookahead.attribute.arr_op) {
      	case DIV:
         	match(ART_OP_T, DIV, &re_arrange);
            primary_arithmetic_expression();
      		multiplicative_arithmetic_expression_p();
            gen_imcode("PLATY: Multiplicative arithmetic expression parsed");
            break;
         case MULT:
         	match(ART_OP_T, MULT, &re_arrange);
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(primary arithmetic expression) =
 * { AVID, FPL, IL, ( }
 * Algorithm:
 * 	See Grammar
 */
void primary_arithmetic_expression(void) {
	/* FIRST set { IL, FPL, AVID, ( } */
   switch(lookahead.t_code) {
   	case IL_T:
      	match(IL_T, NO_ATTR, &re_arrange);
         break;
      case FPL_T:
      	match(FPL_T, NO_ATTR, &re_arrange);
         break;
      case LPR_T:
      	match(LPR_T, NO_ATTR, &re_arrange);
         arithmetic_expression();
         match(RPR_T, NO_ATTR, &re_arrange);
         break;
      case AVID_T:
      	match(AVID_T, NO_ATTR, &re_arrange);
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(relational expression) =
 *	{ FIRST(primary a_relational expression), FIRST(primary s_relational expression) } =
 *	{ FPL, IL, AVID, SVID, STRL }
 * Algorithm:
 * 	See Grammar
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(relational operator) =
 *	{ EQ, LT, NE, EQ }
 * Algorithm:
 * 	See Grammar
 */
void relational_operator(void) {
	/* FIRST set { GT, LT, NE, EQ } */
	if (lookahead.t_code == REL_OP_T) {
		switch(lookahead.attribute.rel_op) {
			case GT:
		   	match(REL_OP_T, GT, &re_arrange);
         	break;
         case LT:
	   		match(REL_OP_T, LT, &re_arrange);
            break;
   		case NE:
		   	match(REL_OP_T, NE, &re_arrange);
            break;
   		case EQ:
		   	match(REL_OP_T, EQ, &re_arrange);
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(primary s_relational expression)
 * {SVID, STRL}
 * Algorithm:
 * 	See Grammar
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
 * Version: 1.00
 * Called Functions:
 * Parameters: None
 * Return Value: None
 * FIRST(primary a_relational expression)
 *  {FPL, IL, AVID}
 * Algorithm:
 * 	See Grammar
 */
void primary_a_relational_expression(void) {
	switch(lookahead.t_code) {
   	case IL_T:
	   	match(IL_T, NO_ATTR, &re_arrange);
         break;
      case FPL_T:
	   	match(FPL_T, NO_ATTR, &re_arrange);
         break;
   	case AVID_T:
	   	match(AVID_T, NO_ATTR, &re_arrange);
         break;
      default:
      	syn_printe();
         break;
   }
	gen_imcode("PLATY: Primary a_relational expression parsed");
}
