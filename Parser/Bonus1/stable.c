/* File Name: stable.c
 * Author: Danny Keller - 040 439 834 - leek0001@algonquincollege.com
 * Course: CST8152 - Lab: 11
 * Assignment: 3 - Symbol Table
 * Date: July 13, 2004
 * Version: 1.5
 * Professor: Sv. Ranev
 * PURPOSE:
 *    STABLE.C: Functions that implement a Symbol Table
 *    as required for CST 8152, Assignment #3, Summer 2004.
 *	Function List:
 *	st_install
 * st_vrinsert
 * st_lookup
 * st_update_type
 * st_update_value
 * get_type
 * st_destroy
 * st_print
 * st_store
 * st_sort
 * st_incoffset
 * st_setsize
 * compare
 */

/* project header files */
#include "stable.h"
#ifndef DEBUG
#define DEBUG
#endif
/*#undef DEBUG*/

extern STD sym_table;

/* Function Name: st_lookup
 * Purpose: Searches for a vid name in the current symbol table
 * Author: Danny Keller
 * Version: 1.03
 * Called Functions:
 * Parameters:
 		sym_table - type: STD
          	 purpose: A symbol table
 * Return Value: Index of found index, or -1 on not found
 * Algorithm:
 *		I <- sym_table.offset
 *		WHILE (I > 0)
 *			IF (sym_table.entry[I] == lexeme)
 *				RETURN I
 *			ENDIF
 *		ENDWHILE
 *		RETURN I
 */
int st_lookup(STD sym_table,char *lexeme)
{
	if (lexeme == NULL || sym_table.st_size <= 0)
   	return ERR;
	for (sym_table.st_offset--;sym_table.st_offset >= 0; sym_table.st_offset--)
   	if (strcmp(sym_table.pstvrs[sym_table.st_offset].plex,lexeme) == 0)
		   break;
   return sym_table.st_offset;
}
/* Function Name: st_update_type
 * Purpose: Updates the type of the specified vid
 * Author: Danny Keller
 * Version: 1.2
 * Called Functions:
 * Parameters:
 		sym_table - type: STD
          	 purpose: the symbol table
      vid_offset - type: int
             purpose: the integer offset of the vid to change
 		v_type - type: char
             purpose: the new type of variable to set the variable to
 * Return Value: vid_offset on success, -1 on failure
 * Algorithm:
 *		sym_table[offset].type <- sym_table[offset].type BITWISE-AND newtype
 */
int st_update_type(STD sym_table,int vid_offset, char v_type)
{
	unsigned short status_mask; /* Bit fields on the updated part */
   unsigned short temp_store; /* Bit fields of other information */
   /* Check parameters */
	if (vid_offset < 0 || vid_offset > sym_table.st_offset || sym_table.pstvrs == NULL || sym_table.st_size <= 0)
		return ERR;

   /* If type is a string, we cannot do anything, but when type is string
      UPDATE will be set also */
   if ((sym_table.pstvrs[vid_offset].status_field & UPDATE) == UPDATE)
   	return ERR;
   /* Store the first part of the status field */
   temp_store = sym_table.pstvrs[vid_offset].status_field & DEFAULT;
   /* Set status_mask to the new type */
	switch(v_type) {
   	case INT_CHR:
      	status_mask = TYPE_INT | UPDATE;
      	break;
      case FLT_CHR:
      	status_mask = TYPE_FLT | UPDATE;
      	break;
      default:
      	return ERR;
   }
   /* Example default | int | update           0xFFF8     | 0x0003 */
	sym_table.pstvrs[vid_offset].status_field = temp_store | status_mask;
   return vid_offset;
}

/* Function Name: st_update_value
 * Purpose: Updates the value of the specified vid
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions:
 * Parameters:
 		sym_table - type: STD
          	 purpose: the symbol table
      vid_offset - type: int
             purpose: the integer offset of the vid to change
 		i_value - type: InitialValue
             purpose: the new value that the variable will get
 * Return Value: vid_offset on success, -1 on failure
 * Algorithm:
 *		sym_table[offset].value <- newvalue
 */
int st_update_value(STD sym_table, int vid_offset, InitialValue i_value)
{
	if (sym_table.pstvrs == NULL || vid_offset < 0 || vid_offset > sym_table.st_offset || sym_table.st_size <= 0)
   	return ERR;
	sym_table.pstvrs[vid_offset].i_value = i_value;
   return vid_offset;
}

/* Function Name: get_type
 * Purpose: Gets the current type of the variable at vid_offset
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions:
 * Parameters:
 		sym_table - type: STD
          	 purpose: the symbol table
      vid_offset - type: int
             purpose: the integer offset of the vid to get the type of
 * Return Value: type of variable on success, -1 on fail
 * Algorithm:
 *		sym_table[offset].value <- newvalue
 */
char get_type (STD sym_table, int vid_offset)
{
	if (sym_table.pstvrs == NULL || vid_offset < 0 || sym_table.st_size <= 0)
   	return ERR;
   /* sym_table.pstvrs & TYPE_STR will get the 1st and second bytes */
   switch(sym_table.pstvrs[vid_offset].status_field & TYPE_STR) {
   	case TYPE_STR:
      	return STR_CHR;
      case TYPE_FLT:
      	return FLT_CHR;
      case TYPE_INT:
      	return INT_CHR;
      default:
      	return ERR;
   }
}

/* Function Name: st_print
 * Purpose: Prints the symbol table to the screen
 * Author: Danny Keller
 * Version: 1.15
 * Called Functions: printf
 * Parameters:
 		sym_table - type: STD
          	 purpose: the symbol table to print
 * Return Value: Number of variables output, -1 on error
 * Algorithm:
 *		FOR each variable
 *			PUT LineNumber of variable
 *			PUT VariableName of variable
 *
 */
int st_print(STD sym_table) {
	int i;
   /* If symbol table non existant */
   if (sym_table.pstvrs == NULL || sym_table.st_size <= 0)
   	return ERR;
	printf("\nSymbol Table\n____________\n\nLine Number Variable Identifier\n");
   #ifdef DEBUG
   	printf("Vid Type ----------Vid Update\n");
   #endif
   /* For each record */
   for (i = 0; i < sym_table.st_offset; i++)
   	/* As long as record is not null */
   	if (sym_table.pstvrs[i].plex != NULL) {
		   printf("%2d          %s\n", sym_table.pstvrs[i].f_line, sym_table.pstvrs[i].plex);
         #ifdef DEBUG
   			printf("%c          %d\n\n", get_type(sym_table, i), sym_table.pstvrs[i].status_field & UPDATE);
		   #endif
      } else {
      	return ERR;
      }
   return i;

}

/* Function Name: st_store
 * Purpose: Stores the symbol table into a file $stable.ste
 * Author: Danny Keller
 * Version: 1.2
 * Called Functions: get_type, fopen, fclose, fprintf, printf
 * Parameters: sym_table - type: STD
          	 	purpose: the symbol table to store
 * Return Value: the number of records stored; it returns -1 on failure
 * Algorithm:
 *		OPEN the file
 *		FOR each variable
 *
 */
int st_store(STD sym_table)
{
	/* Try and open the file */
	FILE * st_file = fopen(STBL_FILE, "wt");
   int i;

   /* Open failed */
   if (st_file == NULL)
   	return ERR;
   if (sym_table.st_size <= 0) {
   	fclose(st_file);
      return ERR;
   }

   /* No size on the symbol table, but still store it */
   fprintf(st_file, "%d", sym_table.st_size);
   /* For each item in the symbol table */
   for (i = 0; i < sym_table.st_offset; i++) {
   	fprintf(st_file, " %X %d %s %d ", sym_table.pstvrs[i].status_field,
      		strlen(sym_table.pstvrs[i].plex),
            sym_table.pstvrs[i].plex,
            sym_table.pstvrs[i].f_line);
      /* For whatever type the item is, print the initial value */
      switch(get_type(sym_table, i)) {
      	case FLT_CHR:
         	fprintf(st_file, "%.2f",sym_table.pstvrs[i].i_value.fpl_val);
            break;
         case INT_CHR:
         	fprintf(st_file, "%d",sym_table.pstvrs[i].i_value.int_val);
            break;
         case STR_CHR:
         	fprintf(st_file, "%d",sym_table.pstvrs[i].i_value.str_offset);
            break;
         default:
         	fclose(st_file);
         	return ERR;
      }
   }
   fclose(st_file);
   printf("\nSymbol Table stored\n");
   return i;
}

/* Function Name: st_setsize
 * Purpose: Sets the size of the symbol table to 0
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions: None
 * Parameters: None
 * Return Value: None
 * Algorithm:
 *		symbol_table.size <- 0
 *
 */
static void st_setsize(void)
{
	sym_table.st_size = 0;
}

/* Function Name: st_install
 * Purpose: Initializes a new symbol table
 * Author: Danny Keller
 * Version: 1.2
 * Called Functions: malloc, b_create, free
 * Parameters:
 		st_size - type: int
          	 purpose: the initial size of the symbol table
 * Return Value: A new symbol table
 * Algorithm:
 *		NewStd <- a new STD structure
 *		SET all variables to 0
 *		ALLOCATE memory for the symbol table
 *		ALLOCATE memory for the lexeme buffer
 *		IF all allocation was a success
 *			NewStd.size <- size
 *		RETURN NewStd
 */
STD st_install(int st_size)
{
	STD NewStd;			/* the new Symbol table Descriptor */
   int NewSize;	/* The calculation of the new vars */

   NewStd.st_offset = 0;
   NewStd.st_size = 0;
   NewStd.pstvrs = NULL;
   NewStd.plsbd = NULL;
   /* If size is bad, skip over it and return a bad st */
   if (st_size > 0) {
   	/* Sizeof STD is 16, vid_len is 16*/

      NewSize = st_size * sizeof(STVRS);
      if (NewSize < 0)
      	return NewStd;

   	NewStd.pstvrs = (STVRS*)malloc((size_t)NewSize);
      if (NewStd.pstvrs == NULL)
      	return NewStd;

   	/* Else it worked */
      /* New size of buffer will be max VID length * st_size
      	and min st_size for one char per var
      */

      NewStd.plsbd = b_create(st_size, VID_LEN, 0.0f);
      /* Error, clear pstvrs, set ptr to null */
      if (NewStd.plsbd == NULL) {
      	free(NewStd.pstvrs);
         NewStd.pstvrs = NULL;
      	return NewStd;
      }

      /* Everything worked, set st_size */
      NewStd.st_offset = 0;
      NewStd.st_size = st_size;
   }
   /* If st_size is invalid, everything in NewStd has been initialized
      to NULL/0 */
   return NewStd;
}

/* Function Name: st_destroy
 * Purpose: De-allocates a symbol table
 * Author: Danny Keller
 * Version: 1.1
 * Called Functions: free, b_destroy
 * Parameters:
 		sym_table - type: STD
          	 purpose: the symbol table
 * Return Value:
 * Algorithm:
 *		DEALLOCATE symbol table
 *		DEALLOCATE the lexeme buffer
 *
 */
void st_destroy(STD sym_table) {
	if (sym_table.pstvrs != NULL || sym_table.st_size <= 0)
   	free(sym_table.pstvrs);
   if (sym_table.plsbd != NULL)
   	b_destroy(sym_table.plsbd);
   st_setsize();
}

/* Function Name: st_incoffset
 * Purpose: Increments the st_offset varaible of sym_table
 *				Not used by any other file
 *				Must be incorperated or all functions that add items to the
 *				table will not be able to increment the offset to the next available
 *				space
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions: None
 * Parameters: None
 * Return Value: None
 * Algorithm:
 *		symbol_table.offset <- symbol_table.offset
 *
 */
static void st_incoffset(void)
{
	sym_table.st_offset++;
}

/* Function Name: st_vrinsert
 * Purpose: Inserts a variable into the symbol table
 * Author: Danny Keller
 * Version: 1.41
 * Called Functions:
 * Parameters:
 		sym_table - type: STD
          	 purpose: the symbol table to insert into
      lexeme - type: char *
      		 purpose: the varaible name to insert
 		line - type: int
      		 purpose: the line number the the variable was found
 * Return Value: offset of new variable
 * Algorithm:
 *		IF lexeme is in symbol table
 *			RETURN the offset
 *		ELSE
 *			ADD the lexeme to the lexeme buffer
 *			IF the adding resulted re-location of pointers
 *				RECALCULATE the plex pointers
 *			ENDIF
 *			SET all symbol table fields
 *			INCREMENT st_offset
 *			RETURN st_offset
 *		ENDIF
 */
int st_vrinsert(STD sym_table,char *lexeme, int line)
{
	int location; /* Search location of lexeme in current symbol table */
   int realoc = 0;  /* Realocation flag */
   int i;	/* Counter */
   int length;

	if (sym_table.pstvrs == NULL || sym_table.st_size <= 0
   	|| lexeme == NULL || line <= 0)
   	return ERR;
	location = st_lookup(sym_table, lexeme);

   if (location != NOTFOUND)
   	return location;
   else	/* Not in the list, check the size */
   	if (sym_table.st_offset >= sym_table.st_size)
      	return ERR;

   length = strlen(lexeme);

   /* Get the new address that the lexeme will take */
   sym_table.pstvrs[sym_table.st_offset].plex = &sym_table.plsbd->ca_head[cb_getsize(sym_table.plsbd)];
   for (i = 0; i <= length; i++) {
   	if (cb_putc(sym_table.plsbd, lexeme[i]) == NULL)
      	return ERR;
      /* Check for re-allocation */
      if (sym_table.plsbd->r_flag == REALLOC)
      	realoc = REALLOC;
   }
   /* No need to put null byte at end, for loop did it NULL byte at the end */

   /* Set all flags and values */
   sym_table.pstvrs[sym_table.st_offset].status_field = DEFAULT;

   if (lexeme[strlen(lexeme) - 1] == '$') {
	   sym_table.pstvrs[sym_table.st_offset].status_field |= TYPE_STR | UPDATE;
      sym_table.pstvrs[sym_table.st_offset].i_value.str_offset = -1;
   } else if (*lexeme == 'i' || *lexeme == 'n' || *lexeme == 'l') {
   	sym_table.pstvrs[sym_table.st_offset].status_field |= TYPE_INT;
      sym_table.pstvrs[sym_table.st_offset].i_value.int_val = 0;
   } else {
      sym_table.pstvrs[sym_table.st_offset].status_field |= TYPE_FLT;
      sym_table.pstvrs[sym_table.st_offset].i_value.fpl_val = 0.0f;
   }

   sym_table.pstvrs[sym_table.st_offset].f_line = line;
   sym_table.pstvrs[sym_table.st_offset].ds_offset = 0;
   st_incoffset();

   /* Realocation of pointers happened, re-initialize pointers */
   if (realoc) {
   	char * NewLoc = sym_table.plsbd->ca_head; /* New plexs - search variable */
   	/* For each plex variable */
   	for (i = 0; i <= sym_table.st_offset; i++) {
      	sym_table.pstvrs[i].plex = NewLoc;
         for (; *NewLoc != '\0' && NewLoc - sym_table.plsbd->ca_head < cb_getsize(sym_table.plsbd); NewLoc++)
         	;
         NewLoc++;
		}
   }
   #ifdef DEBUG
   	printf("Inserted: %s Value: %d Type: %d\n", sym_table.pstvrs[sym_table.st_offset].plex, sym_table.pstvrs[sym_table.st_offset].i_value.fpl_val, sym_table.pstvrs[sym_table.st_offset].status_field & TYPE_STR);
   #endif
	return sym_table.st_offset;
}

/* Function Name: compare
 * Purpose: Compare function for the qsort library function
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions: strcmp
 * Parameters: pstr1 - type : const void *
 *					purpose : element 1 to compare
 *				   pstr2 - type : const void *
 *					purpose : element 2 to compare
 * Return Value: < 1 if str1 < str2, 0 if equal, >1 if >
 * Algorithm:
 *		RETURN
 *
 */
static int compare(const void * pstr1,const void * pstr2)
{
	return strcmp(*(char**)pstr1, *(char**)pstr2);
}

/* Function Name: st_sort
 * Purpose: Sorts the symbol table using the Q-Sort function and a psort_table
 * Author: Danny Keller
 * Version: 1.6
 * Called Functions: qsort, strcmp, malloc
 * Parameters: sym_table - type: STD
          	 	purpose: the symbol table to sort
 * Return Value: the number of records stored; it returns -1 on failure
 * Algorithm:
 *		COPY all plex strings into the psort table
 *		CALL qsort on psort_table
 *		FOR ALL elements in the psort table
 *			FOR ALL elements in the sym_table
 *				IF psort lexeme = sym_table lexeme
 *					SWAP two indexes in the symbol table
 *				ENDIF
 *			ENDFOR
 *		ENDFOR
 *
 */
int st_sort(STD sym_table)
{
	char ** psort_table;
   STVRS Temp;
   int i, j;
	if (sym_table.st_size <= 0 || sym_table.st_offset < 0)
   	return ERR;
   psort_table = (char**)malloc(sizeof(char*) * sym_table.st_offset);
   if (psort_table == NULL)
   	return ERR;
   /* Copy all of the plex pointers */
   for (i = 0; i < sym_table.st_offset; i++)
		psort_table[i] = sym_table.pstvrs[i].plex;
   qsort((void*)psort_table, (size_t)sym_table.st_offset, sizeof(char*), compare);
   /* For every element in the psort_table */
   for (i = sym_table.st_offset - 1; i >= 0; i--) {
		/* Search for pointers that match psort_table and plex */
      for (j = i; j >= 0; j--) {
      	/* If pointers found that match, swap them */
         if (psort_table[i] == sym_table.pstvrs[j].plex) {
         	/* If we need to swap them, then do so */
            if (i != j) {
            	Temp = sym_table.pstvrs[i];
               sym_table.pstvrs[i] = sym_table.pstvrs[j];
					sym_table.pstvrs[j] = Temp;
            }
				break;
         }
      }
   }
   free(psort_table);
   return SORTED;
}
