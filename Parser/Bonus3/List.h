#ifndef LIST_H__
#define LIST_H__

#include <stdlib.h>
#include <limits.h>

#ifndef NULL
#include <null.h>
#endif

#include "Token.h"

typedef char BOOL;

/* A boolean true or false */
#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif 

#ifndef ERR
#define ERR -66						/* Error code */
#endif

#define list_head(list) list->plnHead
#define list_tail(list) list->plnTail
#define next_node(node) node->plnNextPointer
#define prev_node(node) node->plnPrevPointer
#define node_data(node) node->pData
#define list_size(list) ((list == NULL) ? 0 : (list->nNumItems))
#define list_is_full(list) ((list)->nNumItems == UINT_MAX) ? 1 : 0

typedef struct ListNode_ {
	Token pData;
	struct ListNode_ * plnNextPointer;
	struct ListNode_ * plnPrevPointer;
} ListNode;						/* A node in the list */

/*static ListNode * listnode_init (void * pNewData, ListNode * pNextNode, ListNode * pPrevNode);*/
/*static void listnode_delete (ListNode * plnNode, unsigned char dataAlso);*/

typedef struct List_ {
	ListNode * plnHead;
	ListNode * plnTail;
	unsigned int nNumItems;
} List;

List list_init (void);

int list_destroy (List * plList);
void list_clear (List * plList);

unsigned int list_getNumItems (List * plList);

int list_addhead (List * plList, Token pData);
int list_addtail (List * plList, Token pData);

/*static void * list_delete (List * plList, ListNode * pToDelete)*/

Token list_deletetail (List * plList);
Token list_deletehead (List * plList);
Token list_peek (List * plList, unsigned int Offset);
BOOL list_is_in_list (List * plList, Token SearchObj);

int list_display(List * plList, void (*print)(Token), BOOL backwards);
int list_merge(List*, List*);


#endif