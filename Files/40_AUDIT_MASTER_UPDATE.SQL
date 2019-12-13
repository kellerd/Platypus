-- Start of DDL Script for Procedure TIPS.AUDIT_MASTER_UPDATE
-- Generated 2019-05-07 7:56:07 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE audit_master_update
 (V_EVENT_ID       AUDIT_MASTER.AUM_EVENT_ID%TYPE
 ,V_AUDIT_ID       AUDIT_MASTER.AUM_AUDIT_ROW_ID%TYPE
 ,V_EVENT_DATETIME DATE
 ,V_EVENT_IND      AUDIT_MASTER.AUM_EVENT_IND%TYPE
 ,V_TABLE_NAME     AUDIT_MASTER.AUM_TABLE_NAME%TYPE
 )
 IS
--
-- Created by Jennifer Hynes, 21-FEB-2000
--
-- Purpose: Audit master component of the audit triggers.
--
-- MODIFICATION HISTORY
--
-- Person      Date       Comments
-- ----------  ---------  ------------------------------------------------------
-- Hynes, J.  07-MAY-19   Modified to replace call to USER with FN_GET_USER.
--

BEGIN

  INSERT INTO audit_master (
              aum_event_id,
              aum_audit_row_id,
              aum_event_datetime,
              aum_event_ind,
              aum_table_name,
              aum_user_id )
     VALUES ( v_event_id,
              v_audit_id,
              v_event_datetime,
              v_event_ind,
              v_table_name,
              FN_GET_USER );
END;
/



-- End of DDL Script for Procedure TIPS.AUDIT_MASTER_UPDATE

