/* File Name: buffer.c
 * Author: Danny Keller - 040 439 834 - leek0001@algonquincollege.com
 * Course: CST8152 - Lab: 11
 * Assignment: 3 - Symbol Table
 * Date: July 13, 2004
 * Version: 1.7
 * Professor: Sv. Ranev
 * Purpose: Contains the function definitions and driver program
			nessessary for a buffer program for CST8152, Assignment #1, 
			Summer 2004.
 * Function List:
 *		b_create()
 *		cb_putc()
 *		b_reset()
 *		b_destroy()
 *		cb_isfull()
 *		cb_getsize()
 *		cb_getcapacity()
 *		cb_setmark()
 *		cb_getmark()
 *		cb_getmode()
 *		cb_pack()
 *		cb_print()
 *		load()
 */

#include "buffer.h"

/* Function Name: b_create
 * Purpose: Allocates memory for a new buffer. Initializes the buffer
			structure's variables and options.
 * Author: Danny Keller
 * Version: 1.3
 * Called Functions: malloc
 * Parameters:
		initial_capacity - type:int, purpose: initial size of the buffer(in chars)
      	Values: between 1 and INT_MAX if simple mode or fixed size
                 between 1 and INT_MAX - 1 if inteligent mode
		capacity_inc - type:int, purpose: the size to increment the char buffer by if it gets full.
      				also sets what mode the buffer is in
                  < 0 intelligent mode
                  0 fixed size
                  > 0 simple increment & size of the increments
		inc_factor - type:float used to calculate the capacity increment in intelligent-self-incrememnting mode
      			(must be between 0 and 100)
 * Return Value: Address of the newly created Buffer structure
				 NULL on error
 * Algorithm:
 *	ALLOCATE memory for the size of the buffer structure
 *	IF allocation failed
 *		RETURN NULL
 *	ENDIF
 *	ALLOCATE memory for (ca head) of buffer structure using initial_capacity
 *	IF allocation failed
 *    FREE the buffer
 *		RETURN NULL
 *	ENDIF
 *	New Buffer(capacity) <- initial_capacity
 *	New Buffer(capacity inc) <- absolute value of capacity_inc
 *	New Buffer(put offset) <- 0
 *	New Buffer(mark offset) <- 0
 *	New Buffer(r flag) <- 0
 *	New Buffer(inc factor) <- inc_factor
 *	New Buffer(r count) <- 0
 *	IF inc_factor EQUALS 0
 *		o_mode = 0
 *	ELSE IF inc_factor LESSTHAN 0
 *		o_mode = -1
 *	ELSE
 *		o_mode = 1
 *	ENDIF
 */
Buffer * b_create(int initial_capacity, int capacity_inc, float inc_factor)
{
   Buffer * pTheBuffer = NULL;
   /* Check the parameters to check range of values */
   if (initial_capacity <= 0)
	   return NULL;

   if (capacity_inc < 0 && /* If we are using intelligent increment */
   		(inc_factor <= INC_FACTOR_MIN || inc_factor > INC_FACTOR_MAX || initial_capacity > INT_MAX - 1)) /* check factor bounds */
	   return NULL;


   /* Allocate space for the buffer */
   pTheBuffer = (Buffer*)malloc((size_t)sizeof(Buffer));
   if (pTheBuffer == NULL)
      return NULL;

   /* Allocate space for the buffer string */
   pTheBuffer->ca_head = (char*)malloc(sizeof(char) * (size_t)initial_capacity);
   /* If string allocation failed */
   if (pTheBuffer->ca_head == NULL) {
      /* But the buffer still was allocated, so it must be freed */
      free(pTheBuffer);
      return NULL;
   }

   /* Set all the variables to initial values */
   pTheBuffer->capacity = initial_capacity;
   pTheBuffer->capacity_inc = capacity_inc;
   pTheBuffer->put_offset = 0;
   pTheBuffer->mark_offset = 0;
   pTheBuffer->r_flag = (char)0;
   pTheBuffer->r_count = (char)0;
   pTheBuffer->inc_factor = inc_factor;

   /* o_mode is dependant on capacity_inc's sign */
   if (capacity_inc == 0)
	   pTheBuffer->o_mode = (char)FIXED_SIZE;
   else if (capacity_inc < 0)
	   pTheBuffer->o_mode = (char)INTEL_INCREMENT;
   else
	   pTheBuffer->o_mode = (char)SIMPLE_INCREMENT;
   return pTheBuffer;
}

/* Function Name: cb_putc
 * Purpose: Attempt to put a character on the buffer string, reallocate if needed
 * Author: Danny Keller
 * Version: 1.20
 * Called Functions: realloc
 * Parameters: pBD - type:pointer to buffer structure, purpose:holding place of current buffer
			   symbol - type: char, purpose: item to be placed on the buffer
 * Return Value: Buffer pointer (used mainly when buffer has to be reallocated)
				 NULL on error
 * Algorithm:
 *	IF pBD(put offset) LESSTHAN pBD(capacity)
 *		pBD(ca head at offset(put offset)) <- symbol
 *		pBD(r flag) <- 0
 *		pBD(put offset) <- pBD(put offset) + 1
 *		RETURN pBD
 *	ELSE
 *		IF pBD(o mode) EQUALS FIXED_SIZE
 *			RETURN NULL
 *		ELSE IF pBD(o mode) EQUALS SIMPLE_INCREMENT
 *			IF MAXBUFFERSIZE - pBD(capacity) < pBD(capacity_inc)
 *				RETURN NULL
 *			ELSE
 *				pBD(capacity) <- pBD(capacity) + pBD(capacity_inc)
 *			ENDIF
 *		ELSE IF pBD(o mode) EQUALS INTEL_INCREMENT
 *			POSSIBLESPACE = MAXBUFFERSIZE - pBD(capacity)
 *			NEWINC = POSSIBLESPACE * pBD(inc_factor) / 100 - 1
 *			NEWCAP = pBD(capacity) + NEWINC
 *			IF NEWCAP LESSTHAN pBD(capacity) AND pBD(capacity) LESSTHAN MAXBUFFERSIZE
 *				NEWCAP <- MAXBUFFERSIZE - 1
 *			ENDIF
 *			IF NEWCAP LESSTHAN pBD(capacity)
 *				RETURN NULL
 *			ENDIF
 *			pBD(capacity_inc) <- NEWINC
 *			pBD(capacity) <- NEWCAP
 *		ENDIF
 *	ENDIF
 *	REALLOCATE with new values for capacity
 *	IF REALLOCATION fails
 *		RETURN NULL
 *	ENDIF
 *	pBD(ca head at offset(put offset)) <- symbol
 *	pBD(r flag) <- 1
 *	pBD(r count) <- pBD(r count) + 1
 *	pBD(put offset) <- pBD(put offset) + 1
 *	RETURN pBD
 */
Buffer * cb_putc(Buffer *pBD, char symbol)
{
	int iPossibleSpace, iNewInc = pBD->capacity_inc, iNewCap = pBD->capacity;
	char * TempBuffer = NULL;
	if (pBD == NULL)
		return NULL;
	if (pBD->ca_head == NULL)
		return NULL;
   /* Reset the r_flag every time */
   pBD->r_flag = (char)0;
	/* If there is room to put the character put it on the buffer */
	if (pBD->put_offset != pBD->capacity) {
		pBD->ca_head[pBD->put_offset] = symbol;
		/* Move put offset to the next place in memory */
		pBD->put_offset++;
		return pBD;
	} else {
		/* If no room and buffer is fixed size, then say that it is full */
		if (pBD->o_mode == (char)FIXED_SIZE)
			return NULL;
		else if (pBD->o_mode == (char)SIMPLE_INCREMENT)
      	/* If not enough space to add increment */
			if (INT_MAX - pBD->capacity < pBD->capacity_inc)
				return NULL;
			else
				/* Incriment the capacity of the buffer */
				iNewCap = pBD->capacity + pBD->capacity_inc;
		else if (pBD->o_mode == (char)INTEL_INCREMENT) {
      	/* Check if allready at maximum */
      	if (pBD->capacity == INT_MAX - 1) {
         	pBD->capacity_inc = 0;
				return NULL;
         }
			/* Use factor to find the optimum next capacity for the buffer */
			iPossibleSpace = INT_MAX - pBD->capacity;
         /*calculate a new increment*/
			iNewInc = (int)(iPossibleSpace * pBD->inc_factor / INC_FACTOR_MAX - INC_FACTOR_ADJUST);
			iNewCap = pBD->capacity + iNewInc;
			/* If new capacity was not found, but the capacity can still be enlarged */
			if (iNewCap <= pBD->capacity && pBD->capacity < INT_MAX) {
				/* Then set it to the maximum ammount allowed */
				iNewCap = INT_MAX - 1;
				iNewInc = iNewCap - pBD->capacity;
			}
			/* If size does not change. Return Error */
			if (iNewCap <= pBD->capacity) {
         	pBD->capacity_inc = 0;
				return NULL;
         }
		}
	}
	TempBuffer = (char*)realloc((void*)pBD->ca_head, (size_t)iNewCap);
	if (TempBuffer == NULL)
		return NULL;
   /* Did the realocation move the head? */
   if (TempBuffer != pBD->ca_head) {
   	pBD->r_flag = (char)REALLOC;
      pBD->ca_head = TempBuffer;
   }
	/* Set all of the variables from the updating of the character */
	pBD->capacity = iNewCap;
	pBD->capacity_inc = iNewInc;
	pBD->r_count += 1;
	pBD->ca_head[pBD->put_offset] = symbol;
   if (pBD->put_offset < INT_MAX)
		pBD->put_offset++;
   else
   	return NULL;
	return pBD;
}

/* Function Name: b_reset
 * Purpose: Resets the buffer so that it starts entering data from the start of the buffer.
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions: None
 * Parameters: pBD - type:Buffer Structure, purpose: points to the buffer structure that must be reset
 * Return Value: -1 on failure, 0 on success
 * Algorithm:
 *	SET pBD(put offset) to 0
 *	SET pBD(mark offset) to 0
 *	SET pBD(r flag) to 0
 *	SET pBD(r count) to 0
 */
int b_reset(Buffer *pBD)
{
   if (pBD == NULL)
      return R_FAIL1;
   else {
      pBD->put_offset = 0;
      pBD->mark_offset = 0;
      pBD->r_flag = (char)0;
      pBD->r_count = (char)0;
   }
   return 0;
}

/* Function Name: b_destroy
 * Purpose: De-allocates memory allocated by the structure
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions: free
 * Parameters: pBD - type: Pointer to buffer structure, purpose: location of buffer to "free"
 * Return Value: None
 * Algorithm:
 *	IF pBD exists
 *		IF pBD(ca head) exists
 *			DEALLOCATE pBD(ca head)
 *		ENDIF
 *		DEALLOCATE pBD
 *	ENDIF
 */
void b_destroy(Buffer *pBD)
{
   if (pBD != NULL) {
      if (pBD->ca_head != NULL) {
			free(pBD->ca_head);
			pBD->ca_head = NULL;
		}
		free(pBD);
   }
}

/* Function Name: cb_isfull
 * Purpose: Checks if the buffer structure is full
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions: None
 * Parameters: pBD - type: Pointer to buffer structure, purpose: location of buffer structure to check
 * Return Value: TRUE on buffer full, FALSE on not full, -1 on Error
 * Algorithm:
 *	IF pBD(put offset) EQUALS pBD(capacity)
 *		RETURN TRUE
 *	ENDIF
 *	RETURN FALSE
 */
int cb_isfull(Buffer *pBD)
{
   if (pBD == NULL)
      return R_FAIL1;
   else
      if (pBD->put_offset == pBD->capacity)
         return TRUE;
      else
         return FALSE;
}

/* Function Name: cb_getsize
 * Purpose: Get the current size of the buffer
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions: None
 * Parameters: pBD - type: Pointer to buffer structure, purpose: location of buffer structure to compute
 * Return Value: The size of the buffer, -1 on error
 * Algorithm: RETURN pBD(put offset)
 */
int cb_getsize(Buffer *pBD)
{
   if (pBD == NULL)
      return R_FAIL1;
   else
      return pBD->put_offset;
}

/* Function Name: cb_getcapacity
 * Purpose: Reutrns the capacity of the buffer structure
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions: None
 * Parameters: pBD - type: Pointer to buffer structure, purpose: location of buffer structure to compute
 * Return Value: The current capacity of the buffer, -1 on error
 * Algorithm: RETURN pBD(capacity)
 */
int cb_getcapacity(Buffer *pBD)
{
   if (pBD == NULL)
      return R_FAIL1;
   else
      return pBD->capacity;
}

/* Function Name: cb_setmark
 * Purpose: Sets the mark_offset of the current buffer
 * Author: Danny Keller
 * Version: 1.1
 * Called Functions: None
 * Parameters: pBD - type: Pointer to buffer structure, purpose: location of buffer structure to use
			   m_offset - type: int, purpose: new value of mark_offset
 * Return Value: m_offset on success, -1 on failure
 * Algorithm:
 *	IF m_offset is not within the valid range
 *		RETURN -1
 *	ENDIF
 *	SET mark_offset
 *	RETURN m_offset
 */
int cb_setmark(Buffer *pBD, int m_offset)
{
   if (pBD == NULL)
      return R_FAIL1;
   else
      /* if m_offset out of bounds, or after the current place to put characters */
      if (m_offset > pBD->capacity || m_offset < 0)
         return R_FAIL1;
      else
         pBD->mark_offset = m_offset;
   return m_offset;
}

/* Function Name: cb_getmark
 * Purpose: Returns the mark_offset of the buffer structure
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions: None
 * Parameters: pBD - type: Pointer to buffer structure, purpose: location of buffer structure
 * Return Value: int - the mark_offset of the buffer
 * Algorithm: RETURN pBD(mark offset)
 */
int cb_getmark(Buffer *pBD)
{
   if (pBD == NULL)
      return R_FAIL1;
   else
      return pBD->mark_offset;
}

/* Function Name: cb_getmode
 * Purpose: Returns the mode used by the function
 * Author: Danny Keller
 * Version: 1.1
 * Called Functions: None
 * Parameters: pBD - type: Pointer to buffer structure, purpose: location of buffer structure
 * Return Value: int - the mode of the buffer, R_FAIL2 on fail
 * Algorithm: RETURN pBD(mode)
 */
int cb_getmode(Buffer *pBD)
{
   if (pBD == NULL)
      return R_FAIL2;
   else
      return (int)pBD->o_mode;
}

/* Function Name: cb_pack
 * Purpose: Reallocates the buffer to a size of(put_offset +1) - updates variables accordingly
 * Author: Danny Keller
 * Version: 1.70
 * Called Functions: realloc
 * Parameters: pBD - type: Pointer to buffer structure, purpose: location of buffer structure
 * Return Value: Pointer to the buffer or null on error
 * Algorithm:
 *	REALLOCATE the space needed by the buffer string(ca head) to pBD[put offset]  + 1
 *	IF the reallocation failed
 *		RETURN NULL
 *	ENDIF
 *	SET r flag
 *	SET capacity
 *	RETURN pBD
 */
Buffer * cb_pack(Buffer *pBD)
{
	char * TempBuffer;
   /* Check if error OR put offset is invalid or at maximum */
	if (pBD == NULL || pBD->put_offset < 0
   		|| pBD->put_offset == INT_MAX || pBD->ca_head == NULL)
		return NULL;
   pBD->r_flag = 0;
   if (pBD->put_offset + 1 == pBD->capacity)
   	return pBD;

   if (pBD->o_mode == (char)INTEL_INCREMENT && pBD->put_offset >= INT_MAX - 1)
   	return NULL;
   else if (pBD->put_offset == INT_MAX)
   	return NULL;

   /* Re-allocate the buffer */
	TempBuffer = (char*)realloc((void*)pBD->ca_head, (size_t)(pBD->put_offset + 1));
   /* Check for errors and if it has been moved */
	if (TempBuffer == NULL)
		return NULL;
   if (TempBuffer != pBD->ca_head) {
   	pBD->r_flag = (char)REALLOC;
		pBD->ca_head = TempBuffer;
   }
	pBD->capacity = pBD->put_offset + 1;
	return pBD;
}

/* Function Name: cb_print
 * Purpose: Print the buffer character by character
 * Author: Danny Keller
 * Version: 1.01
 *		History - If buffer empty, return R_FAIL1
 * Called Functions: printf()
 * Parameters: pBD - type: Pointer to buffer structure, purpose: location of buffer structure
 * Return Value: number of characters printed, -1 on error
 * Algorithm:
 *	WHILE there is still more in the buffer that has not been printed
 *		PUT the next character
 *	ENDWHILE
 */
int cb_print(Buffer *pBD)
{
   int i;
   if (pBD == NULL)
      return R_FAIL1;
   else {
      /* FOR each character in the buffer */
      for (i = 0; i < pBD->put_offset; i++)
         /* Print the character */
         printf("%c", pBD->ca_head[i]);
      /* Return the cursor to the beginning of the line */
   }
   printf("\n");
   return pBD->put_offset;
}

/* Function Name: load
 * Purpose: load the contents of a file into a buffer
 * Author: Danny Keller
 * Version: 1.0
 * Called Functions: fgetc(), cb_putc() - feof, ferror macros
 * Parameters: fi - type:File structure pointer, purpose contains information on a file to open
 *			   pBD - type: Pointer to buffer structure, purpose: location of buffer structure
 * Return Value: The number of characters put into the buffer
 *				 -2(LOAD_FAIL) on open error
 *				 -1 on other error
 * Algorithm:
 *	CharsRead <- 0
 *	WHILE not and the end of the file
 *		READ a character from the file
 *		PUT the character on the buffer
 *		IF PUT failed
 *			RETURN LOAD_FAIL
 *		ENDIF
 *		CharsRead <- CharsRead + 1
 *	ENDWHILE
 *	RETURN CharsRead
 */
int load(FILE *fi, Buffer *pBD)
{
   int CharsRead;
   char TheCharacter;
   if (fi == NULL)
   	return R_FAIL1;
   for (CharsRead = 0; feof(fi) == NOT_EOF; CharsRead++) {
      TheCharacter = (char)fgetc(fi);
      if (ferror(fi) != 0)
         return R_FAIL1;
      if (feof(fi) == NOT_EOF)
	      if (cb_putc(pBD, TheCharacter) == NULL)
   	      return LOAD_FAIL;
   }
   return CharsRead;
}