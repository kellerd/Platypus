/*  File name: platy_bt.c
 *  Purpose:This is the main program for Assignment #1, CST8152, S04)
 *  Version; 1.12
 *  Author: S^R
 *  Date: 9 May 2004
 */   

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include "buffer.h"

/* constant definitions */
#define INIT_CAPACITY 32767 /* initial buffer capacity */
#define CAPACITY_INC 15   /* initial buffer capacity increment */
#define INC_FACTOR 0.15F   /* capacity increment factor */

#define ANSIC 0
#if defined(__STDC__)
#undef ANSIC
#define ANSIC 1
#endif

/*  Declaration of an error printing function with
 *  variable number of arguments
 */
void err_printf(char *fmt, ...);
/*  Declaration of a buffer contents display function */
void display (Buffer *ptr_buffer); 
long get_filesize(char *fname);

int main(int argc, char **argv){
	
   Buffer *ptr_buffer;  /* pointer to Buffer structure */
   FILE *fi;            /* input file handle */
   int loadsize = 0; /*the size of the file loaded in the buffer */
   int c_inc = 0;       /* capacity incremenet */
   int ansic = !ANSIC;
   
/* Check if the compiler option is set to compile ANSI C */
/* __DATE__, __TIME__, __LINE__, __FILE__, __STDC__ are predefined preprocessor macros*/
  if(ansic){
    err_printf("Date: %s  Time: %s",__DATE__, __TIME__);
    err_printf("ERROR: Compiler is not ANSI C compliant!\n");
    exit(1);
  }

/* missing file name or/and mode parameter */
  if (argc <= 2){

     err_printf("\nDate: %s  Time: %s",__DATE__, __TIME__);
     err_printf("\nRuntime error at line %d in file %s\n", __LINE__, __FILE__);
	  err_printf("%s\b\b\b\b%s%s",argv[0],": ","Missing parameters.");
	  err_printf("Usage: platybt source_file_name mode");
	  exit(1);
	}
	
/* create source input buffer */		
	switch(*argv[2]){
	 case 's': c_inc = CAPACITY_INC; break;
	 case 'i': c_inc = -1; break;
	 case 'n': c_inc = 0; break;
	 default:
	  err_printf("%s%s%s",argv[0],": ","Wrong mode parameter.");
	  exit(1);
	}
    ptr_buffer = b_create(INIT_CAPACITY,c_inc,INC_FACTOR);

	if (ptr_buffer == NULL){
		err_printf("%s%s%s",argv[0],": ","Could not create buffer.");
		exit(1);
	}
	
/* open source file */
	if ((fi = fopen(argv[1],"r")) == NULL){
		err_printf("%s%s%s%s",argv[0],": ", "Cannot open file: ",argv[1]);
		exit (1);
	}

/* load source file into input buffer  */
     printf("Reading file %s ....Please wait\n",argv[1]);
     loadsize = load (fi,ptr_buffer);
     if(loadsize == R_FAIL1)
       err_printf("%s%s%s",argv[0],": ","Error in loading buffer.");

/* close source file */	
 	fclose(fi);
/*find the size of the file  */
    if (loadsize == LOAD_FAIL){
     printf("The input file %s %s\n", argv[1],"is not completely loaded.");
     printf("Input file size: %ld\n", get_filesize(argv[1]));
    } 
/* set a mark */
  cb_setmark(ptr_buffer,cb_getsize(ptr_buffer));

/* display the contents of buffer */	  
   display(ptr_buffer);

/* pack the buffer 
 * add end of file character (EOF) to the buffer
 * display again
 */
  if(cb_pack(ptr_buffer)){         
    if(!cb_putc(ptr_buffer, EOF))
      err_printf("%s%s%s",argv[0],": ","Error in writing to buffer.");
    display(ptr_buffer);
  }  


/* destroy the buffer */  
  b_destroy(ptr_buffer);
  ptr_buffer = NULL;

	return (0);
}

/* error printing function with variable number of arguments*/
void err_printf( char *fmt, ... ){
     
  va_list ap;
  va_start(ap, fmt);
     
  (void)vfprintf(stderr, fmt, ap);
   va_end(ap);

  /* Move to new line */
  if( strchr(fmt,'\n') == NULL )
     fprintf(stderr,"\n");
}

void display (Buffer *ptr_buffer){
  printf("\nPrinting buffer parameters:\n\n");
  printf("The capacity of the buffer is:  %d\n",cb_getcapacity(ptr_buffer));
  printf("The current size of the buffer is:  %d\n",cb_getsize(ptr_buffer));
  printf("The operational mode of the buffer is:   %d\n",cb_getmode(ptr_buffer));
  printf("The current increment of the buffer is:  %d\n",ptr_buffer->capacity_inc);
  printf("The current mark of the buffer is:  %d\n",cb_getmark(ptr_buffer));
  printf("The number of reallocations is:   %d\n",ptr_buffer->r_count);
  printf("The reallocation flag is:   %d\n",ptr_buffer->r_flag);
  printf("\nPrinting buffer contents:\n\n");
  cb_print(ptr_buffer);
}

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

