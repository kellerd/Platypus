#ifndef STACK_H__
#define STACK_H__

#include "List.h"

#define Stack List
#define StackNode ListNode

#define stack_init list_init
#define stack_destroy list_destroy
#define stack_clear list_clear
#define stack_getNumItems list_getNumItems
#define stack_push list_addhead
#define stack_pop list_deletehead
#define stack_peek list_peek
#define stack_isFound list_is_in_list
#define stack_display list_display


#endif