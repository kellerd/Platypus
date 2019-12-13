CREATE OR REPLACE TRIGGER th204_tg1_biud_audit
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON TH204_XREF_STAFFING_VALIDATION
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, Sep 11 2019
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- 
--

   v_user_id  users.usr_user_id%TYPE := FN_GET_USER;

BEGIN
  
  IF INSERTING THEN
     :NEW.STAFFING_VALIDATION_ID := TH204_STAFF_VALIDATE_SEQ.NEXTVAL; 
     :NEW.DATE_CREATED_DTE := SYSDATE;  
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;     
  ELSIF INSERTING OR UPDATING THEN
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;
  END IF;
END;
/

