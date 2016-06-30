#include "List.h"
#include "Token.h"

/**********************************************************************************
** Function Name:
**		ListNode * listnode_init(void * pNewData, ListNode * pNextPointer)
** Purpose: Initializes a list node
** Inputs to Function: Pointer to the location of the new data (must be malloced)
**                     Address of next ListNode to point to
** Outputs from Function: NULL on error, Listnode pointer on success
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
static ListNode * listnode_init (Token pNewData, ListNode * pNextPointer, ListNode * pPrevPointer)
{
   ListNode * sn;
	/* Create new list node */
	sn = (ListNode *)malloc(sizeof(ListNode));

	/* Set initial values */
	sn->pData = pNewData;
	next_node(sn) = pNextPointer;
	prev_node(sn) = pPrevPointer;

	return sn;
}

/**********************************************************************************
** Function Name:
**		void listnode_delete (ListNode * plnNode, BOOL dataAlso)
** Purpose: Deletes a list node and it's contents (both using free)
** Inputs to Function: Pointer to the node to delete, if to delete the data also TRUE OR FALSE
** Outputs from Function: None
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
static void listnode_delete (ListNode * plnNode)
{
	if (plnNode != NULL)
		free(plnNode);
}

/**********************************************************************************
** Function Name:
**		List list_init ()
** Purpose: Starts up a new list
** Inputs to Function: None
** Outputs from Function: A new list
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
List list_init (void)
{
	List l;
	l.nNumItems = 0;
	l.plnHead = NULL;
	l.plnTail = NULL;
	return l;
}

/**********************************************************************************
** Function Name:
**		list_destroy (List * plList)
** Purpose: Deletes a previously made list
** Inputs to Function: The list to delete
** Outputs from Function: None
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
int list_destroy (List * plList)
{
	ListNode * pToDelete;
   if (plList == NULL)
   	return ERR;
   /* While not at the end of the list */
	while (list_head(plList) != NULL)
	{
		/* Move to next */
		pToDelete = list_head(plList);
		list_head(plList) = next_node(list_head(plList));
		listnode_delete(pToDelete);
	}
   return 0;
}

/**********************************************************************************
** Function Name:
**		list_delete (List * plList)
** Purpose: Clears all nodes in a list
** Inputs to Function: The list to delete
** Outputs from Function: None
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
void list_clear (List * plList)
{
	if (list_destroy (plList) == ERR)
		return;
	/* Reset all values */
	plList->nNumItems = 0;
	list_tail(plList) = NULL;
}

/**********************************************************************************
** Function Name:
**		unsigned int list_getNumItems (List * plList)
** Purpose: Gets the number of items in the list
** Inputs to Function: The list to query
** Outputs from Function: The number of items in the list or 0 on error
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
unsigned int list_getNumItems (List * plList)
{
	return list_size(plList);
}

/**********************************************************************************
** Function Name:
**		int list_addhead (List * plList, void * pData)
** Purpose: Inserts a node at the head of the list
** Inputs to Function: Pointer of object to be inserted
** Outputs from Function: ERR on error, 0 on no error
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/

int list_addhead (List * plList, Token pData)
{
	ListNode * plnNewHead;
	if (plList == NULL || list_is_full(plList))
		return ERR;
	/* Create a new node, next node is old head, prev node is null*/
	plnNewHead = listnode_init(pData, list_head(plList), NULL);

	if (plnNewHead == NULL)
		return ERR;
	/* Old head's previous node = new head */
	/* Modify the list to have new node as head */
	if (list_head(plList) == NULL) {
   		list_head(plList) = list_tail(plList) = plnNewHead;
		plList->nNumItems++;
		return 0;
	}
   /* Head is not null, but tail prev is. Then this is second node in list */
	else if (prev_node(list_tail(plList)) == NULL)
		prev_node(list_tail(plList)) = plnNewHead;

	/* Old head's previous node = new head */
	/* Modify the list to have new node as head */
	list_head(plList) = prev_node(list_head(plList)) = plnNewHead;

	plList->nNumItems++;
	return 0;
}

/**********************************************************************************
** Function Name:
**		int list_addtail (List * plList, void * pData)
** Purpose: Inserts a node at the tail of the list
** Inputs to Function: Pointer of object to be inserted
** Outputs from Function: ERR on error, 0 on no error
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/

int list_addtail (List * plList, Token pData)
{
	ListNode * plnNewTail;
	if (plList == NULL || list_is_full(plList))
		return ERR;
	/* Create a new node, next node is NULL, prev node is last tail*/
	plnNewTail = listnode_init(pData, NULL, list_tail(plList));

	if (plnNewTail == NULL)
		return ERR;	

	if (list_tail(plList) == NULL) {
		list_tail(plList) = list_head(plList) = plnNewTail;
		plList->nNumItems++;
		return 0;
	}
   /* Head is not null, but tail prev is. Then this is second node in list */
	else if (next_node(list_head(plList)) == NULL) 
		next_node(list_head(plList)) = plnNewTail;
		/* Old tails's next node = new head */
	/* Modify the list to have new node as head */
	list_tail(plList) = next_node(list_tail(plList)) = plnNewTail;
	

	plList->nNumItems++;
	return 0;
}

/**********************************************************************************
** Function Name:
**		void * list_delete (List * plList)
** Purpose: Deletes a list node from a list
** Inputs to Function: Pointer of object to be inserted, list node to delete
** Outputs from Function: Data that was stored in the item
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
static Token list_delete (List * plList, ListNode * pToDelete)
{
	Token pReturnData = {ERR, ERR};

	if (plList == NULL || pToDelete == NULL)
		return pReturnData;

	/* Get the last data */
	pReturnData = node_data(pToDelete);

	/* next item fix */
	if (pToDelete == list_head(plList))
		list_head(plList) = next_node(pToDelete);
	else
		next_node(prev_node(pToDelete)) = next_node(pToDelete);

	/* Previous pointer fix */
	if (pToDelete == list_tail(plList))
		list_tail(plList) = prev_node(pToDelete);
	else
		prev_node(next_node(pToDelete)) = prev_node(pToDelete);

	/* Delete the node */
	listnode_delete(pToDelete);

	plList->nNumItems--;

	return pReturnData;
}

/**********************************************************************************
** Function Name:
**		void * list_deletetail (List * plList)
** Purpose: Inserts a node at the tail of the list
** Inputs to Function: Pointer to the list
** Outputs from Function: Data that was stored in the item
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
Token list_deletetail (List * plList)
{
	return list_delete(plList, list_tail(plList));
}

/**********************************************************************************
** Function Name:
**		void * list_deletehead (List * plList)
** Purpose: Deletes the head of the list
** Inputs to Function: Pointer to the list
** Outputs from Function: Data that was stored in the item
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
Token list_deletehead (List * plList)
{
	return list_delete(plList, list_head(plList));
}

/**********************************************************************************
** Function Name:
**		void * list_peek (List * plList, unsigned int Offset)
** Purpose: Looks at the list at a certain offset
** Inputs to Function: The list to search, an offset into the list
** Outputs from Function: TRUE on found, FALSE on error
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
Token list_peek (List * plList, unsigned int Offset)
{
	/* If offset > midway, use tail */
   Token pReturnData = {ERR, ERR};
	int Half = (Offset < list_size(plList) / 2) ? TRUE : FALSE;
	ListNode * pToPeek =  (Half == TRUE) ? list_head(plList) : list_tail(plList);
	unsigned int i = (Half == TRUE) ? 0 : list_size(plList);
   if (Offset >= list_size(plList))
   	return pReturnData;

	/* Check for running off end of file */

   if (Half == TRUE)
		while (pToPeek != NULL && ++i < Offset)
			pToPeek = next_node(pToPeek);
   else
	   while (pToPeek != NULL && --i > Offset)
			pToPeek = prev_node(pToPeek);

	if (Offset == i && pToPeek != NULL)
		return node_data(pToPeek);
	else
		return pReturnData;
}

/**********************************************************************************
** Function Name:
**		ListNode * list_searchln (List * plList, void * SearchObj, int(*equals)(void* eq1, void* eq2));
** Purpose: Uses the print function specified to display the list
** Inputs to Function: The list to search, a search object, an boolean comarison function
		0 for eq1 == eq2
		!0 for eq1 != eq2
** Outputs from Function: List node that was found
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
static ListNode * list_searchln (List * plList, Token SearchObj)
{
	/* Temporary next */
	ListNode * plnHeadSearch = list_head(plList);
	ListNode * plnTailSearch = list_tail(plList);

	/* No LIst */
	if (plnHeadSearch == NULL || plnTailSearch == NULL)
		return NULL;

	/* While they don't cross && tail not == search && head not == search */
	while (plnHeadSearch != plnTailSearch && SearchObj.t_code == node_data(plnHeadSearch).t_code && SearchObj.attribute.get_int == node_data(plnHeadSearch).attribute.get_int)
	{
		plnHeadSearch = next_node(plnHeadSearch);
		plnTailSearch = prev_node(plnTailSearch);
	}

	/* End of list, or empty list, no item found */
	if (SearchObj.t_code == node_data(plnHeadSearch).t_code && SearchObj.attribute.get_int == node_data(plnHeadSearch).attribute.get_int)
		return plnHeadSearch;
	else if (SearchObj.t_code == node_data(plnTailSearch).t_code && SearchObj.attribute.get_int == node_data(plnTailSearch).attribute.get_int)
		return plnTailSearch;
	/* plnCurrent is the item not found*/
	else
		return NULL;
}

/**********************************************************************************
** Function Name:
**		BOOL list_is_in_list (List * plList, void * SearchObj, int(*equals)(void* eq1, void* eq2));
** Purpose: Uses the print function specified to display the list
** Inputs to Function: The list to search, a search object, an boolean comarison function
		0 for eq1 == eq2
		!0 for eq1 != eq2
** Outputs from Function: TRUE on found, FALSE on not found
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
BOOL list_is_in_list (List * plList, Token SearchObj)
{
	return (list_searchln(plList, SearchObj) == NULL ? FALSE : TRUE);
}

/**********************************************************************************
** Function Name:
**		int list_display(List * plList, void (*print)(void*));
** Purpose: Uses the print function specified to display the list
** Inputs to Function: The list to display, the print function to use
** Outputs from Function: 0 on success, ERR on error
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
int list_display(List * plList, void (*print)(Token), BOOL backwards)
{
   ListNode * plnToDisplay;
	if (plList == NULL || print == NULL)
		return ERR;
	/*Start at head*/
	plnToDisplay = (backwards == FALSE) ? list_head(plList) : list_tail(plList);

	while (plnToDisplay != NULL)
	{
		/* Output one item */
		print(node_data(plnToDisplay));
		/* Move on to the next */
		plnToDisplay = (backwards == FALSE) ? next_node(plnToDisplay) : prev_node(plnToDisplay);
	}
   return 0;
}

/**********************************************************************************
** Function Name:
**		int list_merge(List * plList1, List * plList2)
** Purpose: Adds one list onto the head another, destorying internals of second list
				Since they get transported to other list
** Inputs to Function: Two lists to merge
** Outputs from Function: 0 on success, ERR on error
** External Inputs to Function: None
** External Outputs from Function: None
** Version: 1.0 - Danny Keller
/**********************************************************************************/
int list_merge(List * plList1, List * plList2) {
	if (plList1 == NULL || plList2 == NULL)
   	return ERR;
   if (UINT_MAX - plList2->nNumItems <= plList1->nNumItems)
   	return ERR;
   /* Add list to last list, re-link pointers */
	prev_node(list_head(plList1)) = list_tail(plList2);
   next_node(list_tail(plList2)) = list_head(plList1);
   /* New tail = old tail */
   list_head(plList1) = list_head(plList2);
   /* List two, reset head and tail so they aren't used by other item */
   list_head(plList2) = NULL;
   list_tail(plList2) = NULL;
   plList1->nNumItems += plList2->nNumItems;
   plList2->nNumItems = 0;
   return 0;
}