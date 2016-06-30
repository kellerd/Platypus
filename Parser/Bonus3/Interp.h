/* Filename: Interp.h
 * Items for interperator
 * CST8152, Assignment #4, Summer 2004.
 * Assignment: 4 - Parser
 * Date: July 13, 2004
 * Version: 1.0
 * Professor: Sv. Ranev
 * Provided by: Svillen Ranev
 */
#ifndef INTERPERATE_H_
#define INTERPERATE_H_

#include <stdio.h>
#include "buffer.h"
#include "token.h"
#include "stable.h"
#include "List.h"
#include "Stack.h"

ListNode * evaluate(ListNode * Start);
void post_fix(List * psStack);
ListNode * assignment_evaluate(ListNode * Start);
void conditional_fix(List * plList);
ListNode * conditional_evaluate(ListNode * Start);

extern char * kw_table[];

int Evaluate;
extern STD sym_table;
extern Buffer * str_table;
List sem_analisys;			/* Semantic analysis stack a = 6; */
List re_arrange;				/* Converting Infix to Postfix */
extern int numLoops;

#define DO 0
#define ELSE 1
#define FOR 2
#define IF 3
#define PLATYPUS 4
#define READ 5
#define THEN 6
#define WRITE 7

#endif