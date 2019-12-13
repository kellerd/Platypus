
CREATE OR REPLACE TRIGGER AH108_TG1_BIUD_AUDIT
 BEFORE 
 INSERT OR DELETE OR UPDATE
 ON AH108_HRSR_RESTRICTED_ACCESS
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, June 10 2019
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





