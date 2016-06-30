/* Filename: Interperate.h
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

#include "buffer.h"
#include "token.h"
#include "stable.h"
#include "List.h"
#include "Stack.h"

void evaluate(ListNode * Start);
void post_fix(List * psStack);

int Evaluate;
extern STD sym_table;
List sem_analisys;			/* Semantic analysis stack a = 6; */
List re_arrange;				/* Converting Infix to Postfix */

#endif