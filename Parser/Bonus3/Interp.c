/* File Name: Interp.c
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

#include "Interp.h"
#ifndef DEBUG
#define DEBUG
#endif
#undef DEBUG
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
		printf("AVID_T\t\t");
		switch (get_type(sym_table, t.attribute.vid_stoffset)) {
      	    case 'F':
				printf("%f\n", sym_table.pstvrs[t.attribute.vid_stoffset].i_value.fpl_val);
            	 break;
           case 'I':
                printf("%d\n", sym_table.pstvrs[t.attribute.vid_stoffset].i_value.int_val);
                break;
	          case 'S':
                if (sym_table.pstvrs[t.attribute.vid_stoffset].i_value.str_offset != -1)
	   	        printf("%s\n", &str_table->ca_head[sym_table.pstvrs[t.attribute.vid_stoffset].i_value.str_offset]);
      	       break;
          }
		break;
	case  7:
		printf("SCC_OP_T\n" );
	break;
   case STR_T:
	   printf("STR_T\t\t%s\n", &str_table->ca_head[t.attribute.str_offset]);
   	break;
   case KW_T:
   	printf("%s\n", kw_table[t.attribute.get_int]);
	break;
	case SVID_T:
		printf("SVID_T\t\t");
		switch (get_type(sym_table, t.attribute.vid_stoffset)) {
      	    case 'F':
				printf("%f\n", sym_table.pstvrs[t.attribute.vid_stoffset].i_value.fpl_val);
            	 break;
           case 'I':
                printf("%d\n", sym_table.pstvrs[t.attribute.vid_stoffset].i_value.int_val);
                break;
	          case 'S':
                if (sym_table.pstvrs[t.attribute.vid_stoffset].i_value.str_offset != -1)
	   	        printf("%s\n", &str_table->ca_head[sym_table.pstvrs[t.attribute.vid_stoffset].i_value.str_offset]);
      	       break;
          }
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
 * Called Functions: st_update_value, get_type, printf
 * Parameters: string
 *				 type: char *
 *				 purpose: storage place of string to output
 * Return Value: None
 * Algorithm:
 * 	execute whatever type of statement it is
 */

ListNode * evaluate (ListNode * Start) {
	if (Start == NULL)
   	return NULL;
	/* If evaluating this statement */
	if (Evaluate) {
   	if (Start->pData.t_code == AVID_T)
			Start = assignment_evaluate(Start); /* This is rather big to have inside this function */
	   else if (Start->pData.t_code == SVID_T) {
	      int VidToChange = Start->pData.attribute.vid_stoffset;
         int Changed = FALSE; /* For Null Byte */
         InitialValue updateValue;
         unsigned int i;
         updateValue.str_offset = cb_getsize(str_table);

         /* Now skip the vid */
      	Start = Start->plnPrevPointer;
         while (Start != NULL && Start->pData.t_code != EOS_T && Start->pData.t_code != COM_T) {
         	char * Location = NULL;
         	switch(Start->pData.t_code) {
            	case SVID_T:
               	Location = &str_table->ca_head[sym_table.pstvrs[Start->pData.attribute.vid_stoffset].i_value.str_offset];
                  break;
               case STR_T:
	               Location = &str_table->ca_head[Start->pData.attribute.str_offset];
                  break;
               default:
               	Location = NULL;
            }
            for (i = 0; i < strlen(Location); i++)
         		if (cb_putc(str_table, Location[i]) == NULL)
						exit(R_FAIL1);
            Start = Start->plnPrevPointer;
            Changed = TRUE;
         }
         /* If the variable changed, add a null to the str table and change it */
         if (Changed == TRUE) {
	         if (cb_putc(str_table, '\0') == NULL)
						exit(R_FAIL1);
            st_update_value(sym_table, VidToChange, updateValue);
         }
         #ifdef DEBUG
         	if (sym_table.pstvrs[VidToChange].i_value.str_offset != -1)
            	printf("Attempt to update variable: %s with value: %s\n", sym_table.pstvrs[VidToChange].plex, &str_table->ca_head[sym_table.pstvrs[VidToChange].i_value.str_offset]);
         #endif
      } else if (Start->pData.t_code == KW_T) {
      	if (Start->pData.attribute.kwt_idx == READ) {
         	InitialValue ivalue;
            unsigned int i;
            char newString[256];
         	/* For each variable */
            for (Start = Start->plnPrevPointer; Start != NULL && Start->pData.t_code != EOS_T; Start = Start->plnPrevPointer) {
            	if (Start->pData.t_code != AVID_T && Start->pData.t_code != SVID_T)
               	break;
               /* Get the input from the user based on type */
					switch (get_type(sym_table, Start->pData.attribute.vid_stoffset)) {
               	case 'F':
							scanf("%f", &ivalue.fpl_val);
                     break;
                  case 'I':
                  	scanf("%d", &ivalue.int_val);
                     break;
                  case 'S':
                  	scanf("%s", newString);
                     ivalue.str_offset = cb_getsize(str_table);
                     /* Put strings in string literal table */
                     for (i = 0; i < strlen(newString) + 1; i++)
                     	if (cb_putc(str_table, newString[i]) == NULL)
                        	exit(R_FAIL1);
                     break;
				  default:
					  ivalue.int_val = 0;
               }
               /* Update the value in the sym_table */
               st_update_value(sym_table, Start->pData.attribute.vid_stoffset, ivalue);
            }


         } else if (Start->pData.attribute.kwt_idx == WRITE) {
         	int i, NumOp = 0;
         	for (Start = Start->plnPrevPointer; Start != NULL && Start->pData.t_code != EOS_T; Start = Start->plnPrevPointer) {
            	if (Start->pData.t_code == AVID_T || Start->pData.t_code == SVID_T) {
	               /* Get the input from the user based on type */
						switch (get_type(sym_table, Start->pData.attribute.vid_stoffset)) {
      	         	case 'F':
								printf("%f ", sym_table.pstvrs[Start->pData.attribute.vid_stoffset].i_value.fpl_val);
            	         break;
               	   case 'I':
                  		printf("%d ", sym_table.pstvrs[Start->pData.attribute.vid_stoffset].i_value.int_val);
                     	break;
	                  case 'S':
                     	if (sym_table.pstvrs[Start->pData.attribute.vid_stoffset].i_value.str_offset != -1) {
                        for (i = sym_table.pstvrs[Start->pData.attribute.vid_stoffset].i_value.str_offset; str_table->ca_head[i] != '\0'; i++) {
                        		if (str_table->ca_head[i] == '\\' && str_table->ca_head[i+1] == 'n') {
                              	printf("\n");
                                 i++;
                                 continue;
                              }
                           	printf("%c", str_table->ca_head[i]);
                           }
                        }
      	               break;
                  }
                  NumOp++;
               } else if (Start->pData.t_code == STR_T) {
               	for (i = Start->pData.attribute.str_offset; str_table->ca_head[i] != '\0'; i++) {
                  	if (str_table->ca_head[i] == '\\' && str_table->ca_head[i+1] == 'n') {
                       	printf("\n");
                     	i++;
                        continue;
                  	}
                   	printf("%c", str_table->ca_head[i]);
               	}
                  NumOp++;
               }
            }
            if (!NumOp)
	           	printf("\n");
         } else if (Start->pData.attribute.kwt_idx == IF) {
            /* Num loops for end of if statements */
            int Num = Start->plnPrevPointer->pData.attribute.get_int;
            ListNode * LastStart = NULL;

            Start = Start->plnPrevPointer;

         	LastStart = conditional_evaluate(Start->plnPrevPointer);

       	   while (LastStart != NULL &&
     	             LastStart->plnPrevPointer != NULL &&
					 LastStart->plnPrevPointer->plnPrevPointer != NULL) {
                   /* While there are more statements in the IF part */
                 	 /* It ends with either ELSE or }; */
              	if (
               	(LastStart->plnPrevPointer->pData.t_code == KW_T &&
           	        LastStart->plnPrevPointer->pData.attribute.kwt_idx == ELSE &&
                    LastStart->plnPrevPointer->plnPrevPointer->pData.t_code == EOS_T &&
     	              LastStart->plnPrevPointer->plnPrevPointer->pData.attribute.get_int == Num) ||

        	          (LastStart->plnPrevPointer->pData.t_code == RBR_T &&
     	              LastStart->plnPrevPointer->pData.attribute.get_int == IF &&
                     LastStart->plnPrevPointer->plnPrevPointer->pData.t_code == EOS_T &&
     	              LastStart->plnPrevPointer->plnPrevPointer->pData.attribute.get_int == Num)
  	                )
						break; /* Break on else or end if */
            	if (Evaluate) /* If evaluate, evaluate IF portion */
	               LastStart = evaluate(LastStart->plnPrevPointer);
         		else /* If not evaluate, skip IF portion */
               	LastStart = LastStart->plnPrevPointer;
            }
		   /* Swap evaluate */
		   Evaluate = (Evaluate == TRUE) ? FALSE : TRUE;
            /* skip the else OR execute it*/
            while (LastStart != NULL &&
     	             LastStart->plnPrevPointer != NULL &&
					 LastStart->plnPrevPointer->plnPrevPointer != NULL) {
                   /* While there are more statements in the IF part */
                 	 /* It ends with either ELSE or }; */
              	if ((LastStart->plnPrevPointer->pData.t_code == RBR_T &&
     	              LastStart->plnPrevPointer->pData.attribute.get_int == IF &&
                     LastStart->plnPrevPointer->plnPrevPointer->pData.t_code == EOS_T &&
     	              LastStart->plnPrevPointer->plnPrevPointer->pData.attribute.get_int == Num)
  	                )
						break; /* Break on else or end if */
				   if (Evaluate) /* If evaluate, skip ELSE portion */
               	LastStart = evaluate(LastStart->plnPrevPointer);
               else /* If not evaluate, evaluate ELSE portion */
               	LastStart = LastStart->plnPrevPointer;
            }
				Start = LastStart->plnPrevPointer->plnPrevPointer;

				/* Start at beginning of for loop */
				/* Go to end of for loop to the } */
				Evaluate = TRUE;
	      } else if (Start->pData.attribute.kwt_idx == FOR) {
	         int Num = Start->plnPrevPointer->pData.attribute.get_int;
				ListNode * LastStart = NULL;
				ListNode * End = NULL;
            Start = Start->plnPrevPointer;

	         /* Conditional expression first */
				LastStart = conditional_evaluate(Start->plnPrevPointer);
            if (Evaluate == FALSE) {
            	while (LastStart != NULL &&
     	             LastStart->plnPrevPointer != NULL &&
					 LastStart->plnPrevPointer->plnPrevPointer != NULL) {
                   /* While there are more statements in the IF part */
                 	 /* It ends with either ELSE or }; */
              	if ((LastStart->plnPrevPointer->pData.t_code == RBR_T &&
     	              LastStart->plnPrevPointer->pData.attribute.get_int == FOR &&
                     LastStart->plnPrevPointer->plnPrevPointer->pData.t_code == EOS_T &&
     	              LastStart->plnPrevPointer->plnPrevPointer->pData.attribute.get_int == Num)
  	                )
                   break;
					LastStart = LastStart->plnPrevPointer;
				}
				End = LastStart->plnPrevPointer;
            }
				while (Evaluate == TRUE && LastStart != NULL) {
					while (LastStart != NULL &&
     	             LastStart->plnPrevPointer != NULL &&
					 LastStart->plnPrevPointer->plnPrevPointer != NULL) {
                   /* While there are more statements in the FOR part */
              			if ((LastStart->plnPrevPointer->pData.t_code == RBR_T &&
     							LastStart->plnPrevPointer->pData.attribute.get_int == FOR &&
								LastStart->plnPrevPointer->plnPrevPointer->pData.t_code == EOS_T &&
     							LastStart->plnPrevPointer->plnPrevPointer->pData.attribute.get_int == Num)
  						   )
							break; /* Break on end for */
                  /* Execute */
						LastStart = evaluate(LastStart->plnPrevPointer);
					}
					End = LastStart->plnPrevPointer;
					LastStart = conditional_evaluate(Start->plnPrevPointer);
         	}
				/* Start at beginning of for loop */
				/* Go to end of for loop to the } */
				Start = End->plnPrevPointer;
				Evaluate = TRUE;
         }
      }
   }
   return Start;
}
/* Function Name: assignment_evaluate
 * Purpose: Evaluates a arithmetic statement that is stored in the stack
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions: printf, stack_init, list_deletehead, stack_push, stack_pop
                     get_type, st_update_value, st_update_type
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
ListNode * assignment_evaluate(ListNode * Start) {
	char oldType, newType;
	int VidToChange = Start->pData.attribute.vid_stoffset;
	int NumOfNumbers = 0, NumOfVids = 0; /* Useful for changing var types */
	Token Operand1, Operand2, NewToken;
   Stack TempEval = stack_init();

	/* Changing types and values */
	/* Skip the VID */
	Start = Start->plnPrevPointer;
	/* a = 5 3 2 * + 4 - */
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
				if (stack_push(&TempEval, NewToken) == ERR)
            	exit(ERR);
				NumOfNumbers++;
				NumOfVids++;
				break;
			case IL_T:
			case FPL_T:
				/* Push number on temp stack */
				if (stack_push(&TempEval, Start->pData) == ERR)
            	exit(ERR);
				NumOfNumbers++;
				break;
			case ART_OP_T:
				/* Operation = Start->pData */
				/* Pop 2 operands off */
				Operand2 = list_deletehead(&TempEval);

				if (TempEval.plnHead != NULL &&
            	(TempEval.plnHead->pData.t_code == IL_T || TempEval.plnHead->pData.t_code == FPL_T) &&
               (Start->pData.attribute.arr_op != NEGATE && Start->pData.attribute.arr_op != POSATE)) {
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
				/* Take the two numbers and perform the operation */
				switch(Start->pData.attribute.arr_op) {
            	case NEGATE:
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
               case POSATE:
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
							} else {
								if (Operand2.attribute.i_value == 0)
									NewToken.attribute.i_value = 0;
								else
									NewToken.attribute.i_value = Operand1.attribute.i_value / Operand2.attribute.i_value;
							}
						}
						break;
				} /* End switch */
				/* Push the answer on the stack */
				if(stack_push(&TempEval, NewToken) == ERR)
            	exit(ERR);
				break;
			default:
				break;
		}
		Start = Start->plnPrevPointer;
	} while (Start != NULL && Start->pData.t_code != EOS_T && Start->pData.t_code != COM_T);
	/* TempEval will contain one result */
	NewToken = stack_pop(&TempEval);

	/* Perform the setting operationon the variable */
	/* Get old and new types for the variables */
	oldType = get_type(sym_table, VidToChange);
	newType = (NewToken.t_code == FPL_T) ? 'F' : 'I';
	/* Record type to change to */
	if (NumOfNumbers == 1 && NumOfVids == 0) {
		/* If constant expression, try to change it */
		if (st_update_type(sym_table, VidToChange, newType) == ERR)
			newType = oldType;
	} else
		newType = oldType;
		/* Old type used now for casting NewToken */
	oldType = (NewToken.t_code == IL_T) ? 'I' : 'F';

	if (newType == 'I') { /* Becoming I */

		InitialValue ivalue;
   	if (oldType == 'I') /* Was I, still is I */
			ivalue.int_val = NewToken.attribute.i_value;
		else /* Newtoken was F, change to I */
			ivalue.int_val = (int)NewToken.attribute.f_value;
		st_update_value(sym_table, VidToChange, ivalue);

		#ifdef DEBUG
		if (newType == 'I')
			printf("Attempt To Update: %s Value: %d Type: %c\n", sym_table.pstvrs[VidToChange].plex, sym_table.pstvrs[VidToChange].i_value.int_val, 'I');
		else
			printf("Attempt To Update: %s Value: %f Type: %c\n", sym_table.pstvrs[VidToChange].plex, sym_table.pstvrs[VidToChange].i_value.fpl_val, 'F');
		#endif

	} else { /* New Type is F */
		InitialValue ivalue;
		if (oldType == 'I') /* Was I, still is I */
			ivalue.fpl_val = (float)NewToken.attribute.i_value;
		else /* Newtoken was F, change to I */
			ivalue.fpl_val = NewToken.attribute.f_value;
		st_update_value(sym_table, VidToChange, ivalue);
		#ifdef DEBUG
		if (newType == 'I')
			printf("Attempt To Update: %s Value: %d Type: %c\n", sym_table.pstvrs[VidToChange].plex, sym_table.pstvrs[VidToChange].i_value.int_val, 'I');
		else
			printf("Attempt To Update: %s Value: %f Type: %c\n", sym_table.pstvrs[VidToChange].plex, sym_table.pstvrs[VidToChange].i_value.fpl_val, 'F');
		#endif
	}
	stack_destroy(&TempEval);
	return Start;
}
/* Function Name: post_fix
 * Purpose: Changes an expression from infix to post fix
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: plList
 *				 type: List *
 *				 purpose: Place of thing to convert
 * Return Value: None
 * Algorithm:
 *
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
	         if (stack_push(&psStack, Start->pData) == ERR)
            	exit(ERR);
            break;
         case IL_T:
         case FPL_T:
		 case AVID_T:
   			if (stack_push(&psOutput, Start->pData) == ERR)
            	exit(ERR);
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
							if (stack_push(&psOutput, stack_pop(&psStack)) == ERR)
                     	exit(ERR);
						}
   			}
			if (stack_push(&psStack,Start->pData) == ERR)
         	exit(ERR);
            break;
         case RPR_T:
         	while (psStack.plnHead != NULL && psStack.plnHead->pData.t_code != LPR_T)
            	if (stack_push(&psOutput, stack_pop(&psStack)) == ERR)
               	exit(ERR);
			if (psStack.plnHead != NULL && psStack.plnHead->pData.t_code == LPR_T)
				stack_pop(&psStack);
            break;
      }
   	Start = prev_node(Start);
   }
   /* While still more to output */
	while (psStack.plnHead != NULL)
     	if (stack_push(&psOutput, stack_pop(&psStack)) == ERR)
      	exit(ERR);
   list_destroy(plList);
   *plList = psOutput;
}

/* Function Name: conditional_fix
 * Purpose: Changes an expression from infix to post fix
 *		NOTE: Operands come in sets of 3
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: plList
 *				 type: List *
 *				 purpose: Place of thing to convert
 * Return Value: None
 * Algorithm:
 */
void conditional_fix(List * plList) {
	ListNode * Start;
   Stack psStack = stack_init();
   Stack psOutput = stack_init();

	if (plList == NULL)
   	return;
	Start = list_tail(plList);
   /* While there are items in the list */
	while (Start != NULL) {
		switch(Start->pData.t_code) {

        case IL_T:
        case FPL_T:
		  case AVID_T:
        case STR_T:
        case SVID_T:
        		/* Push the vid/il/fpl/str */
   			if (stack_push(&psOutput, Start->pData) == ERR)
            	exit(ERR);
            Start = prev_node(Start);
            /* Push the relational operator */
            if (stack_push(&psOutput, Start->pData) == ERR)
            	exit(ERR);
            Start = prev_node(Start);
            /* Push the vid/il/fpl/str */
            if (stack_push(&psOutput, Start->pData) == ERR)
            	exit(ERR);
            break;
        case LOG_OP_T:
          	/* Pop off until lower precedence OR ( */
         	if (psStack.plnHead != NULL) {

	            	while (psStack.plnHead != NULL) {

	                  /* Plus / 2 = 0, Mult / 2 = 1 */
                     if (psStack.plnHead->pData.t_code == LOG_OP_T &&
	                  		psStack.plnHead->pData.attribute.log_op >
   		            		Start->pData.attribute.arr_op)
                        break;
							if (stack_push(&psOutput, stack_pop(&psStack)) == ERR)
                     	exit(ERR);
						}
   			}
				if (stack_push(&psStack,Start->pData) == ERR)
         		exit(ERR);
            break;
      }
   	Start = prev_node(Start);
   }
   /* While still more to output */
	while (psStack.plnHead != NULL)
     	if (stack_push(&psOutput, stack_pop(&psStack)) == ERR)
      	exit(ERR);
   list_destroy(plList);
   *plList = psOutput;
}

/* Function Name: conditional_evaluate
 * Purpose: Evaluates a conditional expression that is stored in the stack
 * Author: Danny Keller
 * Version: 1.00
 * Called Functions:
 * Parameters: The start of the expression to evaluate
 *				 type: char *
 *				 purpose: storage place of string to output
 * Return Value: None
 * Algorithm:
 * 	repeat
 *		if (next input is an expression)
 *			compute it
 *			push onto a stack
 *    else
 *       Read Operation
 *       Pop two numbers off stack
 *          Evaluate operation
 *       Push result on stack
 */
ListNode * conditional_evaluate(ListNode * Start) {
	int rel_operand;
   Token attr1, attr2;
   Token result;
   Stack TempEval = stack_init();
   result.t_code = IL_T;	/* This will contain 1 or 0 for the ANDS and ORS */

	do {
		switch (Start->pData.t_code) {
			case AVID_T:
         	/* Get values of VID */
				switch(get_type(sym_table, Start->pData.attribute.vid_stoffset)) {
					case 'I':
						attr1.t_code = IL_T;
						attr1.attribute.i_value = sym_table.pstvrs[Start->pData.attribute.vid_stoffset].i_value.int_val;
						break;
					case 'F':
						attr1.t_code = FPL_T;
						attr1.attribute.f_value = sym_table.pstvrs[Start->pData.attribute.vid_stoffset].i_value.fpl_val;
						break;
				}
			case IL_T:
			case FPL_T:
         	/* If the number hasn't been allready gathered by AVID_T */
         	if (Start->pData.t_code == FPL_T || Start->pData.t_code == IL_T) {
					attr1 = Start->pData;
            }

				Start = Start->plnPrevPointer;
				rel_operand = Start->pData.attribute.rel_op;
            Start = Start->plnPrevPointer;
            /* Do the same check for the second arguement */
            switch(Start->pData.t_code) {
            	case AVID_T:
         		/* Get values of VID */
						switch(get_type(sym_table, Start->pData.attribute.vid_stoffset)) {
						case 'I':
							attr2.t_code = IL_T;
							attr2.attribute.i_value = sym_table.pstvrs[Start->pData.attribute.vid_stoffset].i_value.int_val;
							break;
						case 'F':
							attr2.t_code = FPL_T;
							attr2.attribute.f_value = sym_table.pstvrs[Start->pData.attribute.vid_stoffset].i_value.fpl_val;
							break;
						}
                  break;
					case IL_T:
					case FPL_T:
               	if (Start->pData.t_code == FPL_T || Start->pData.t_code == IL_T) {
							attr2 = Start->pData;
		            }
            }

            /* attr1 and attr2 will only contain IL and FPL */
            switch(rel_operand) {
            	/* First ternary is for result of operation */
               /* Result = 1 or 0 */
               /* second ones are for which type to use FPL or IL */
            	case EQ:
               	result.attribute.i_value = (((attr1.t_code == IL_T) ? attr1.attribute.i_value : attr1.attribute.f_value) == ((attr2.t_code == IL_T) ? attr2.attribute.i_value : attr2.attribute.f_value)) ? 1 : 0;
               	break;
               case NE:
               	result.attribute.i_value = (((attr1.t_code == IL_T) ? attr1.attribute.i_value : attr1.attribute.f_value) != ((attr2.t_code == IL_T) ? attr2.attribute.i_value : attr2.attribute.f_value)) ? 1 : 0;
               	break;
               case GT:
	               result.attribute.i_value = (((attr1.t_code == IL_T) ? attr1.attribute.i_value : attr1.attribute.f_value) > ((attr2.t_code == IL_T) ? attr2.attribute.i_value : attr2.attribute.f_value)) ? 1 : 0;
               	break;
               case LT:
               	result.attribute.i_value = (((attr1.t_code == IL_T) ? attr1.attribute.i_value : attr1.attribute.f_value) < ((attr2.t_code == IL_T) ? attr2.attribute.i_value : attr2.attribute.f_value)) ? 1 : 0;
                 	break;
            }

            /* Push number on temp stack */
            if (stack_push(&TempEval, result) == ERR)
            	exit(ERR);
				break;
         case SVID_T:
				attr1.t_code = STR_T;
            attr1.attribute.str_offset = sym_table.pstvrs[Start->pData.attribute.vid_stoffset].i_value.str_offset;
         case STR_T:
            if (Start->pData.t_code == STR_T)
	         	attr1 = Start->pData;

            Start = Start->plnPrevPointer;
				rel_operand = Start->pData.attribute.rel_op;
            Start = Start->plnPrevPointer;
				switch(Start->pData.t_code) {
		         case SVID_T:
						attr2.t_code = STR_T;
      		      attr2.attribute.str_offset = sym_table.pstvrs[Start->pData.attribute.vid_stoffset].i_value.str_offset;
                  break;
         		case STR_T:
            		if (Start->pData.t_code == STR_T)
	         			attr2 = Start->pData;
                  break;
  				}
            switch(rel_operand) {
            	/* First ternary is for result of operation */
               /* Result = 1 or 0 */
               /* second ones are for which type to use FPL or IL */
            	case EQ:
               	result.attribute.i_value = (strcmp(&str_table->ca_head[attr1.attribute.str_offset], &str_table->ca_head[attr2.attribute.str_offset]) == 0 ) ? 1 : 0;
               	break;
               case NE:
               	result.attribute.i_value = (strcmp(&str_table->ca_head[attr1.attribute.str_offset], &str_table->ca_head[attr2.attribute.str_offset]) != 0 ) ? 1 : 0;
               	break;
               case GT:
               	result.attribute.i_value = (strcmp(&str_table->ca_head[attr1.attribute.str_offset], &str_table->ca_head[attr2.attribute.str_offset]) > 0 ) ? 1 : 0;
               	break;
               case LT:
               	result.attribute.i_value = (strcmp(&str_table->ca_head[attr1.attribute.str_offset], &str_table->ca_head[attr2.attribute.str_offset]) < 0 ) ? 1 : 0;
                 	break;
            }
            /* Push number on temp stack */
            if (stack_push(&TempEval, result) == ERR)
            	exit(ERR);
            break;
			case LOG_OP_T:
         	/* The stack TempVal should contain only 1's and 0's as integer literals */
         	attr2 = stack_pop(&TempEval);
            attr1 = stack_pop(&TempEval);
            if (Start->pData.attribute.log_op == OR) {
            	result.t_code = IL_T;
               result.attribute.i_value = attr1.attribute.i_value || attr2.attribute.i_value;
            } else {
					result.t_code = IL_T;
               result.attribute.i_value = attr1.attribute.i_value && attr2.attribute.i_value;
            }
			/* Push result back onto the stack */
			if (stack_push(&TempEval, result) == ERR)
         	exit(ERR);
		}
		Start = Start->plnPrevPointer;
	} while (Start != NULL && Start->pData.t_code != RPR_T && Start->pData.t_code != COM_T);
	/* TempEval will contain one result */
	result = stack_pop(&TempEval);
   Evaluate = result.attribute.i_value;
	stack_destroy(&TempEval);
	return Start;
}
