-- Start of DDL Script for Trigger TIPS.TH050_TG1_BIUD_AUDIT
-- Generated 2019-07-30 11:05:49 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER TH050_TG1_BIUD_AUDIT
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON TH050_HRSR_STATUS
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, Jul 30 2019
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- 
--
   v_user_id  users.usr_user_id%TYPE := FN_GET_USER;

BEGIN
  
  IF INSERTING THEN 
     :NEW.DATE_CREATED_DTE := SYSDATE;  
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;     
  ELSIF INSERTING OR UPDATING THEN
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;
  END IF;
END;
/


-- End of DDL Script for Trigger TIPS.TH050_TG1_BIUD_AUDIT

