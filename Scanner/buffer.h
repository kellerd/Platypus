/* File Name: buffer.h
 * Author: Danny Keller - 040 439 834 - leek0001@algonquincollege.com
 * Course: CST8152 - Lab: 11
 * Assignment: 1 - Buffer
 * Date: May 24, 2004
 * Version: 1.12
 * Professor: Sv. Ranev
 * History: 
 *		Original Author: S^R
 *		Date: May 9, 2009
 * Purpose: Declarations and prototypes necessary for buffer implementation 
 * as required for CST8152, Assignment #1, Summer 2004.
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
 *	
 */
#ifndef BUFFER_H_
#define BUFFER_H_

/* standard header files */
#include <stdio.h>  /* standard input/output */
#include <malloc.h> /* for dynamic memory allocation*/
#include <limits.h> /* implementation-defined data type limits */

/* constant definitions */
/* You can add your own constant definitions here */
#define R_FAIL1 -1         /* fail return value */
#define R_FAIL2 -2         /* fail return value */
#define LOAD_FAIL -2       /* load fail error */
#define NOT_EOF 0				/* return value of feof() if not eof */

#define FALSE 0		/* BOOLean FALSE return value */
#define TRUE 1		/* BOOLean TRUE return value */

#define REALLOC 1         /* realloc flag set value */
#define FIXED_SIZE 0		/* Buffer mode*/
#define SIMPLE_INCREMENT 1	/* Second buffer mode */
#define INTEL_INCREMENT -1	/* Third buffer mode */

#define INC_FACTOR_MAX 100.0f /* inc_factor max value */
#define INC_FACTOR_MIN 0.0f /* inc_factor max value */
#define INC_FACTOR_ADJUST 1.0f /* calculation of new increment adjustment */


/* data declarations */
typedef struct BufferDescriptor {
   char *ca_head;   /* pointer to beginning of character array (character buffer) */
   int capacity;     /* memory size (in chars) allocated by malloc()/realloc() */
   int capacity_inc; /* array increment (in chars) to add when growing the character buffer */
   int put_offset;   /* the offset (in chars) to the put-character location */
   int mark_offset;  /* the offset (in chars) to the mark location */
   char r_flag;     /* reallocation flag */
   float inc_factor; /* character buffer capacity increment factor */
   short r_count;   /* reallocation counter */
   char o_mode;          /*operational mode indicator*/
 } Buffer ; 

/* function declarations */
Buffer * b_create(int initial_capacity, int capacity_inc,float inc_factor);
Buffer * cb_putc(Buffer *pBD, char symbol);
int b_reset(Buffer *pBD);
void b_destroy(Buffer *pBD);
int cb_isfull(Buffer *pBD);
int cb_getsize(Buffer *pBD);
int cb_getcapacity(Buffer *pBD);
int cb_setmark(Buffer *pBD, int m_offset);
int cb_getmark(Buffer *pBD);
int cb_getmode(Buffer *pBD);
Buffer * cb_pack(Buffer *pBD);
int cb_print(Buffer *pBD);
int load(FILE *fi, Buffer *pBD);

#endif

