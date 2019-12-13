-- Start of DDL Script for Function TIPS.FN_GET_USER
-- Generated 2019-05-07 7:56:41 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_get_user
 RETURN VARCHAR2
 IS
--
-- Created by:  H,HU, May 03 2019
--
-- Purpose: This function will get userID passed in as a connection parameter,
--          if no userID passed in then return login USER
--
-- MODIFICATION HISTORY
--
-- Person      Date       Comments
-- ----------  ---------  ------------------------------------------------------
--
   v_user_id      VARCHAR2(100);

BEGIN

 SELECT NVL(SYS_CONTEXT('userenv', 'client_identifier'),USER)
   INTO v_user_id
   FROM dual;

 RETURN v_user_id;

END;
/

CREATE OR REPLACE PUBLIC SYNONYM FN_GET_USER FOR TIPS.FN_GET_USER
/
GRANT EXECUTE ON FN_GET_USER TO TIPSUSER
/
GRANT EXECUTE ON FN_GET_USER TO EVERYTHING_IN_TIPS
/


-- End of DDL Script for Function TIPS.FN_GET_USER

