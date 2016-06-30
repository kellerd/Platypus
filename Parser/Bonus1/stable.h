/* Filename: stable.h
 * Author: Danny Keller - 040 439 834 - leek0001@algonquincollege.com
 * Course: CST8152 - Lab: 11
 * Assignment: 3 - Symbol Table
 * Date: July 13, 2004
 * Version: 1.3
 * Professor: Sv. Ranev
 * Purpose:  Provides function, structure and union declarations for use in the
 *				 Symbol table
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
 */

#ifndef  STABLE_H_
#define  STABLE_H_

#ifndef BUFFER_H_
#include "buffer.h"
#endif

#ifndef TOKEN_H_
#include "token.h"
#endif

#ifndef NULL
#include <_null.h> /* NULL pointer constant is defined there */
#endif

#include "malloc.h"
#include "string.h"
#include "stdlib.h"

/* Bit masks */
#define UPDATE		0x0001
#define TYPE_FLT 	0x0002
#define TYPE_INT 	0x0004
#define TYPE_STR 	0x0006
#define DEFAULT	0xFFF8

#define ERR -1 /* Error */
#define SORTED 1 /* No Error on sort */

#define NOTFOUND -1 /* Symbol table lookup */

#define FLT_CHR 'F' /* Character for float */
#define INT_CHR 'I' /* Character for ints */
#define STR_CHR 'S' /* Character for strings */

#define STBL_FILE "$stable.ste"

typedef union InitialValue {
  int int_val;   /* integer variable initial value */
  float fpl_val; /* floating-point variable initial value */
  int str_offset; /* string variable initial value (offset) */
} InitialValue;

typedef struct SymbolTableVidRecord {
  unsigned short status_field;  /* variable record status field*/
  char * plex;                 /*  pointer to lexeme (VID name) in CA */
  int f_line;       /* first line of appearance */
     InitialValue i_value; /* variable initial value */
  size_t ds_offset;/*offset from the beginning of data segment*/
}STVRS;

typedef struct SymbolTableDescriptor {
  STVRS *pstvrs;         /* pointer to array of STVRS */
  int st_size;		  /* size in number of STVRS elements */
  int st_offset;      /*offset in number of STVRS elements */
  Buffer *plsbd; /* pointer to the lexeme storage buffer descriptor */
} STD;

/* Prototypes */
STD st_install(int st_size);
int st_vrinsert(STD sym_table,char *lexeme, int line);
int st_lookup(STD sym_table,char *lexeme);
int st_update_type(STD sym_table,int vid_offset, char v_type);
int st_update_value(STD sym_table, int vid_offset, InitialValue i_value);
char get_type (STD sym_table, int vid_offset);
void st_destroy(STD sym_table);
int st_print(STD sym_table);
int st_store(STD sym_table);
int st_sort(STD sym_table);

#endif

