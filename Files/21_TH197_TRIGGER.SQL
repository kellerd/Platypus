CREATE OR REPLACE TRIGGER th197_tg1_biud_audit
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON TH197_TI_PROFILE
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, May 16 2019
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

