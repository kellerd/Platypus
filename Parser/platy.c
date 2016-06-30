/* File name: platy.c
 * Purpose:This is the main program for Assignment#4,CST8152,Summer 2004)
 * Author: Svillen Ranev
 * Version: 1.12
 */ 

#include <stdio.h>
#include <stdlib.h> /* Constants for calls to exit()*/

#include <string.h>
#include <stdarg.h>

#include "buffer.h"
#include "token.h"
#include "stable.h" 

/* Input buffer parameters */
#define INIT_CAPACITY 100
#define CAPACITY_INC 50
#define INC_FACTOR 5
/* String Literal Table parameters */
#define STR_INIT_CAPACITY 100
#define STR_CAPACITY_INC 50
/* Symbol Table default size */
#define ST_DEF_SIZE 100 

#define ANSIC 0
#if defined(__STDC__)
#undef ANSIC
#define ANSIC 1
#endif

/* Global objects - variables */

static Buffer *sc_buf; /* pointer to input (source) buffer */

Buffer * str_table; /* this buffer implements String Literal Table */
                  /* it is used as a repository for string literals */
STD sym_table; /* Symbol Table Descriptor */
int scerrnum;     /* run-time error number = 0 by default (ANSI) */
extern int synerrno /* number of syntax errors */;
extern int line; /* source code line number - defined in scanner.c */

/* function declarations (prototypes) */
extern void parser(Buffer * sc_buf);
/* For testing purposes */
/* extern void scanner_init(Buffer * sc_buf);*/
/* extern Token find_next_token(Buffer * sc_buf);*/

void err_printf(char *fmt, ...);
void display (Buffer *ptrBuffer); 
long get_filesize(char *fname);
void garbage_collect(void);


/*  main function takes a PLATYPUS source file as
 *  an argument at the command line.
 *  usage: platy source.pls [-st size] [-sts]
 */    
int main(int argc, char ** argv){

	FILE *fi;       /* input file handle */
/*	Token t;   */     /* token produced by the scanner */
        int loadsize = 0; /*the size of the file loaded in the buffer */
        int st_def_size = ST_DEF_SIZE; /* Sumbol Table default size */
        int sort_st = 0;      /*Symbol Table sort switch */
        int ansic = !ANSIC;
/* Check if the compiler option is set to compile ANSI C */
/* __DATE__, __TIME__, __LINE__, __FILE__, __STDC__ are predefined preprocessor macros*/
  if(ansic){
    err_printf("Date: %s  Time: %s",__DATE__, __TIME__);
    err_printf("ERROR: Compiler is not ANSI C compliant!\n");
    exit(1);
  }

/*check for correct arrguments - source file name */
      if (argc <= 1){
/* __DATE__, __TIME__, __LINE__, __FILE__ are predefined preprocessor macros*/
       err_printf("Date: %s  Time: %s",__DATE__, __TIME__);
       err_printf("Runtime error at line %d in file %s", __LINE__, __FILE__);
       err_printf("%s%s%s",argv[0],": ","Missing source file name.");
       err_printf("%s%s%s","Usage: ", "platy", "  source_file_name [-st size][-sts]");
        exit(EXIT_FAILURE);
	}	

 /* check for optional switches - symbol table size and/or sort */
 if (argc == 3){
    if (strcmp(argv[2],"-sts")){
      err_printf("%s%s%s",argv[0],": ","Invalid switch.");
      err_printf("%s%s\b\b\b\b%s","Usage: ", argv[0], " source file name [-st size][-sts]");
      exit(EXIT_FAILURE);
    }
    sort_st = 1;
 }
/* symbol table size specified */ 
 if (argc == 4){
   if (strcmp(argv[2],"-st")){
     err_printf("%s%s%s",argv[0],": ","Invalid switch.");
     err_printf("%s%s\b\b\b\b%s","Usage: ", argv[0], " source file name [-st size][-sts]");
     exit(EXIT_FAILURE);
   }
/* convert the symbol table size */
    st_def_size = atoi(argv[3]);
      if (!st_def_size){
	err_printf("%s%s%s",argv[0],": ","Invalid switch.");
	err_printf("%s%s\b\b\b\b%s","Usage: ", argv[0], " source file name [-st size][-sts]");
	exit(EXIT_FAILURE);
      }
 }
if (argc == 5){
    if (strcmp(argv[4],"-sts")){
      err_printf("%s%s%s",argv[0],": ","Invalid switch.");
      err_printf("%s%s\b\b\b\b%s","Usage: ", argv[0], " source file name [-st size][-sts]");
      exit(EXIT_FAILURE);
    }
    sort_st = 1;
 }

 /* create source input buffer */	
	sc_buf = b_create(INIT_CAPACITY,CAPACITY_INC,INC_FACTOR);
	if (sc_buf == NULL){
	  err_printf("%s%s%s",argv[0],": ","Could not create source buffer");
	  exit(EXIT_FAILURE);
	}

/* create symbol table */
  sym_table = st_install(st_def_size);
  if (!sym_table.st_size){
    err_printf("%s%s%s",argv[0],": ","Could not create symbol table");
    exit (EXIT_FAILURE);
  }
/* load source file into input buffer  */
      /*open source file */
	if ((fi = fopen(argv[1],"r")) == NULL){
		err_printf("%s%s%s%s",argv[0],": ", "Cannot open file: ",argv[1]);
		exit (EXIT_FAILURE);
	}
     printf("Reading file %s ....Please wait\n",argv[1]);
     loadsize = load (fi,sc_buf);
     if(loadsize == R_FAIL1)
       err_printf("%s%s%s",argv[0],": ","Error in loading buffer.");

/* close source file */	
 	fclose(fi);
/*find the size of the file  */
    if (loadsize == LOAD_FAIL){
     printf("The input file %s %s\n", argv[1],"is not completely loaded.");
     printf("Input file size: %ld\n", get_filesize(argv[1]));
    }
/* pack and display the source buffer */

       if(cb_pack(sc_buf)){
         display(sc_buf);
  }
/* create string Literal Table */
 	
  str_table = b_create(STR_INIT_CAPACITY,STR_CAPACITY_INC,INC_FACTOR);
	if (str_table == NULL){
		err_printf("%s%s%s",argv[0],": ","Could not create string buffer");
		exit(EXIT_FAILURE);
	}

/*registrer exit function */	
 atexit(garbage_collect);
	
/*Testbed for buffer, scanner,symbol table and parser*/

/* Initialize scanner input buffer  
	scanner_init(sc_buf);
*/        
        line = 1;
        cb_putc (sc_buf, EOF);
        printf("\nParsing the source file...\n\n");
	
        parser(sc_buf);
        if(synerrno)
         printf("\nSyntax errors: %d\n",synerrno);
/* print Symbol Table */      
        if(sym_table.st_size && sort_st){   
           printf("\nSorting symbol table...\n");
           st_sort(sym_table);
           st_print(sym_table);       
        }
       
	return (0); /* same effect as exit(EXIT_SUCCESS) */

}

/* Error printing function with variable number of arguments
 */
void err_printf( char *fmt, ... ){

  va_list ap;
  va_start(ap, fmt);

  (void)vfprintf(stderr, fmt, ap);
	va_end(ap);

  /* Move to new line */
  if( strchr(fmt,'\n') == NULL )
	  fprintf(stderr,"\n");
}

/* The function return the size of an open file 
 */
long get_filesize(char  *fname){
   FILE *input;
   long flength;
   input = fopen(fname, "r");
   if(input == NULL)
      err_printf("%s%s","Cannot open file: ",fname);   
   fseek(input, 0L, SEEK_END);
   flength = ftell(input);   
   fclose(input);
   return flength;
}

/* The function display buffer contents 
 */
void display (Buffer *ptrBuffer){
  printf("\nPrinting input buffer parameters:\n\n");
  printf("The capacity of the buffer is:  %d\n",cb_getcapacity(ptrBuffer));
  printf("The current size of the buffer is:  %d\n",cb_getsize(ptrBuffer)); 
  printf("\nPrinting input buffer contents:\n\n");
	cb_print(ptrBuffer);
}

/* the functions frees the allocated memory */
void garbage_collect(void){
  printf("\nCollecting garbage...\n");
	b_destroy(sc_buf);
	b_destroy(str_table);  
	st_destroy(sym_table);
}


