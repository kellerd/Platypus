/* File Name: Interperate.c
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
 * 	extract
 */

#include "Interperate.h"
#ifndef DEBUG
#define DEBUG
#endif
/* #undef DEBUG */
void print_token(Token t){

	switch(t.t_code){
	case  SEOF_T:
		printf("SEOF_T\n" );
	break;
	case  FPL_T:
		printf("FPL_T\t\t%f\n",t.attribute.f_value);
	break;
	case  IL_T:
	        printf("IL_T\t\t%d\n",t.attribute.get_int);
	break;
	case AVID_T:
		printf("AVID_T\t\t%f\n", t.attribute.f_value);
		break;
	case  7:
		printf("SCC_OP_T\n" );
	break;
	case  ASS_OP_T:
		printf("ASS_OP_T\n" );
	break;
	case  ART_OP_T:
		printf("ART_OP_T\t%d\n",t.attribute.get_int);
	break;
	case  REL_OP_T:
		printf("REL_OP_T\t%d\n",t.attribute.get_int);
	break;
	case  LOG_OP_T:
		printf("LOG_OP_T\t%d\n",t.attribute.get_int);
	break;
	case  LPR_T:
		printf("LPR_T\n" );
	break;
	case  RPR_T:
	        printf("RPR_T\n" );
	break;
	case LBR_T:
	        printf("LBR_T\n" );
	break;
	case RBR_T:
	        printf("RBR_T\n" );
	break;
	case COM_T:
	        printf("COM_T\n");
	break;
	case EOS_T:
	        printf("EOS_T\n" );
	break;

	default:
	        printf("Scanner error: invalid token code: %d\n", t.t_code);
 }
}
/* Function Name: evaluate
 * Purpose: Evaluates a statement that is stored in the stack
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions: printf, stack_init, list_deletehead, stack_push, stack_pop
                     get_tape, st_update_value, st_update_type
 * Parameters: string
 *				 type: char *
 *				 purpose: storage place of string to output
 * Return Value: None
 * Algorithm:
 * 	repeat
 *		if (next input is number)
 *			push onto a stack
 *    else
 *       Read Operation
 *       Pop two numbers off stack
 *          Evaluate operation
 *       Push result on stack
 */

void evaluate (ListNode * Start) {
	Stack TempEval = stack_init();
	/* If evaluating this statement */
	if (Evaluate) {
   	if (Start != NULL && Start->pData.t_code == AVID_T) {
      	int VidToChange = Start->pData.attribute.vid_stoffset;
         int NumOfNumbers = 0; /* Useful for changing var types */
         Token Operand1, Operand2, NewToken;
		 
      	/* Changing types and values */
         /* Next will be an ='s so skip it*/
      	Start = Start->plnPrevPointer->plnPrevPointer;
         /* a = 5 3 2 * + 4 - 5 */
         do {
            int OperandNum = 1;
            switch (Start->pData.t_code) {
            	case AVID_T:
               	/* Get values of VID */
						switch(get_type(sym_table, Start->pData.attribute.vid_stoffset)) {
                  	case 'I':
                     	NewToken.t_code = IL_T;
                        NewToken.attribute.i_value = sym_table.pstvrs[Start->pData.attribute.vid_stoffset].i_value.int_val;
                        break;
                     case 'F':
	                     NewToken.t_code = FPL_T;
                        NewToken.attribute.f_value = sym_table.pstvrs[Start->pData.attribute.vid_stoffset].i_value.fpl_val;
                        break;
                  }
						stack_push(&TempEval, NewToken);
                  NumOfNumbers++;
                  break;
					case IL_T:
               case FPL_T:
						/* Push number on temp stack */
                  stack_push(&TempEval, Start->pData);
                  NumOfNumbers++;
                  break;
            	case ART_OP_T:
               	/* Operation = Start->pData */
                  /* Take 2 operands */
                  Operand2 = list_deletehead(&TempEval);

                  if (TempEval.plnHead->pData.t_code == IL_T || TempEval.plnHead->pData.t_code == FPL_T) {
	                  Operand1 = list_deletehead(&TempEval);
                  	OperandNum = 2; /* There are two operands */
                  }

						/* Cast operands */
                  if (Operand1.t_code == FPL_T || Operand2.t_code == FPL_T) {
                  	NewToken.t_code = FPL_T;
                     Operand2.attribute.f_value = (Operand2.t_code == FPL_T) ? Operand2.attribute.f_value : (float)Operand2.attribute.i_value;
                     if (OperandNum == 2)
	                     Operand1.attribute.f_value = (Operand1.t_code == FPL_T) ? Operand1.attribute.f_value : (float)Operand1.attribute.i_value;
                  } else {
							NewToken.t_code = IL_T;
                     Operand2.attribute.i_value = (Operand2.t_code == FPL_T) ? (int)Operand2.attribute.f_value : Operand2.attribute.i_value;
	                  if (OperandNum == 2)
   	                  Operand1.attribute.i_value = (Operand1.t_code == FPL_T) ? (int)Operand1.attribute.f_value : Operand1.attribute.i_value;
                  }

                  switch(Start->pData.attribute.arr_op) {
                  	case MINUS:
                     	if (OperandNum == 1) {
                        	if (NewToken.t_code == FPL_T)
                           	NewToken.attribute.f_value = - Operand2.attribute.f_value;
                           else
								  		NewToken.attribute.i_value = -Operand2.attribute.i_value;
                        } else {
                        	if (NewToken.t_code == FPL_T)
                           	NewToken.attribute.f_value = Operand1.attribute.f_value - Operand2.attribute.f_value;
                           else
								  		NewToken.attribute.i_value = Operand1.attribute.i_value - Operand2.attribute.i_value;
                        }
                     	break;
                     case PLUS:
	                     if (OperandNum == 1) {
                        	if (NewToken.t_code == FPL_T)
                           	NewToken.attribute.f_value = Operand2.attribute.f_value;
                           else
								  		NewToken.attribute.i_value = Operand2.attribute.i_value;
                        } else {
     	                  	if (NewToken.t_code == FPL_T)
        	                  	NewToken.attribute.f_value = Operand1.attribute.f_value + Operand2.attribute.f_value;
           	               else
								  		NewToken.attribute.i_value = Operand1.attribute.i_value + Operand2.attribute.i_value;
                        }
                        break;
                     case MULT:
                     	if (OperandNum == 2) {
                        	if (NewToken.t_code == FPL_T)
                           	NewToken.attribute.f_value = Operand1.attribute.f_value * Operand2.attribute.f_value;
                           else
								  		NewToken.attribute.i_value = Operand1.attribute.i_value * Operand2.attribute.i_value;
                        }
                        break;
                     case DIV:
                     	if (OperandNum == 2) {
                        	if (NewToken.t_code == FPL_T) {
                           	if (Operand2.attribute.f_value == 0.0f)
	                              NewToken.attribute.f_value = 0.0f;
                              else
                           		NewToken.attribute.f_value = Operand1.attribute.f_value / Operand2.attribute.f_value;
                           }
                           else {
                           	if (Operand2.attribute.i_value == 0)
	                              NewToken.attribute.i_value = 0;
                              else
                           		NewToken.attribute.i_value = Operand1.attribute.i_value / Operand2.attribute.i_value;
                           }
                        }
                     	break;
						} /* End switch */
                  stack_push(&TempEval, NewToken);
            }
         	Start = Start->plnPrevPointer;
         } while (Start != NULL && Start->pData.t_code != EOS_T);
			/* TempEval will contain one result */
			NewToken = stack_pop(&TempEval);
         switch(get_type(sym_table, VidToChange)) {
         	case 'I':
               if (NumOfNumbers == 1) { /* Constant expression */
               	char newType = (NewToken.t_code == FPL_T) ? 'F' : 'I';
               	if (st_update_type(sym_table, VidToChange, newType) != ERR) {
	                  InitialValue ivalue;
                     if (newType == 'I') /* Was I, still is I */
                     	ivalue.int_val = NewToken.attribute.i_value;
                     else /* NewToken == F and update succeeded*/
                     	ivalue.fpl_val = NewToken.attribute.f_value;
                     st_update_value(sym_table, VidToChange, ivalue);
							#ifdef DEBUG
					 		if (newType == 'I')
						 		printf("Attempt To Update: %s Value: %d Type: %c\n", sym_table.pstvrs[VidToChange].plex, sym_table.pstvrs[VidToChange].i_value.int_val, 'I');
							else
						 		printf("Attempt To Update: %s Value: %f Type: %c\n", sym_table.pstvrs[VidToChange].plex, sym_table.pstvrs[VidToChange].i_value.fpl_val, 'F');
					   #endif
                  } else { /* No updating must cast to int */
                    InitialValue ivalue;
                     if (newType == 'I') /* Was I, still is I */
                     	ivalue.int_val = NewToken.attribute.i_value;
                     else /* NewToken == F and update succeeded*/
                     	ivalue.int_val = (int)NewToken.attribute.f_value;
                     st_update_value(sym_table, VidToChange, ivalue);
							#ifdef DEBUG
   							printf("Attempt To Update: %s Value: %d Type: %c\n", sym_table.pstvrs[VidToChange].plex, sym_table.pstvrs[VidToChange].i_value.int_val, 'I');
					   	#endif
                  }
               } /* More than one number or variable, updated by interperator */
         		break;
            case 'F':
	         	if (NumOfNumbers == 1) { /* Constant expression */
               	char newType = (NewToken.t_code == FPL_T) ? 'F' : 'I';
               	if (st_update_type(sym_table, VidToChange, newType) != ERR) {
	                  InitialValue ivalue;
                     if (newType == 'I') /* Was F, now I */
                     	ivalue.int_val = NewToken.attribute.i_value;
                     else /* Was F now F*/
                     	ivalue.fpl_val = NewToken.attribute.f_value;
                     st_update_value(sym_table, VidToChange, ivalue);
						#ifdef DEBUG
                  if (newType == 'I')
                  	printf("Attempt To Update: %s Value: %d Type: %c\n", sym_table.pstvrs[VidToChange].plex, sym_table.pstvrs[VidToChange].i_value.int_val, 'I');
						else
                  	printf("Attempt To Update: %s Value: %f Type: %c\n", sym_table.pstvrs[VidToChange].plex, sym_table.pstvrs[VidToChange].i_value.fpl_val, 'F');
					   #endif
                  } else { /* No updating must cast to float */
                    InitialValue ivalue;
                     if (newType == 'I') /* Was I, still is I */
                     	ivalue.fpl_val = (float)NewToken.attribute.i_value;
                     else /* NewToken == F and update succeeded*/
                     	ivalue.fpl_val = NewToken.attribute.f_value;
                     st_update_value(sym_table, VidToChange, ivalue);
						#ifdef DEBUG
   						printf("Attempt To Update: %s Value: %f Type: %c\n", sym_table.pstvrs[VidToChange].plex, sym_table.pstvrs[VidToChange].i_value.fpl_val, 'F');
					   #endif
                  }
					   
               } /* More than one number or variable, updated by interperator */
            	break;
         }
      }
   }
   stack_destroy(&TempEval);
}

/* Function Name: post_fix
 * Purpose: Changes an expression from infix to post fix
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: string
 *				 type: char *
 *				 purpose: storage place of string to output
 * Return Value: None
 * Algorithm:
 * 	repeat
 *		if (next input is number)
 *			push onto a stack
 *    else
 *       Read Operation
 *       Pop two numbers off stack
 *          Evaluate operation
 *       Push result on stack
 */
void post_fix(List * plList) {
	ListNode * Start;
   Stack psStack = stack_init();
   Stack psOutput = stack_init();

	if (plList == NULL)
   	return;
	Start = list_tail(plList);
   /* While there are items in the list */
	while (Start != NULL) {
		switch(Start->pData.t_code) {

      	case LPR_T:
	         stack_push(&psStack, Start->pData);
            break;
         case IL_T:
         case FPL_T:
		 case AVID_T:
   			stack_push(&psOutput, Start->pData);
            break;
         case ART_OP_T:
          	/* Pop off until lower precedence OR ( */
         	if (psStack.plnHead != NULL) {

	            	while (psStack.plnHead != NULL) {

	                  /* Plus / 2 = 0, Mult / 2 = 1 */
                     if (psStack.plnHead->pData.t_code == LPR_T ||
                     	(psStack.plnHead->pData.t_code == ART_OP_T &&
	                  		psStack.plnHead->pData.attribute.arr_op / 2 <
   		            		Start->pData.attribute.arr_op  / 2))
                        break;
							stack_push(&psOutput, stack_pop(&psStack));
						}                  
   			}
			stack_push(&psStack,Start->pData);
            break;
         case RPR_T:
         	while (psStack.plnHead != NULL && psStack.plnHead->pData.t_code != LPR_T)
            	stack_push(&psOutput, stack_pop(&psStack));
			if (psStack.plnHead != NULL && psStack.plnHead->pData.t_code == LPR_T)
				stack_pop(&psStack);
            break;
      }
   	Start = prev_node(Start);
   }
   /* While still more to output */
	while (psStack.plnHead != NULL)
     	stack_push(&psOutput, stack_pop(&psStack));
   list_destroy(plList);
   *plList = psOutput;
}
