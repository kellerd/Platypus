

CREATE SEQUENCE ah103_custom_condition_seq
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999999999999999999
  NOCYCLE
  NOORDER
  NOCACHE
/

CREATE OR REPLACE TRIGGER ah103_tg1_biud_audit
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON AH103_CUSTOM_CONDITION_OF_EMPL
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, May 25 2019
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- 
--

   v_user_id  users.usr_user_id%TYPE := FN_GET_USER;

BEGIN
  
  IF INSERTING THEN 
     :NEW.CUSTOM_CONDITION_ID := ah103_custom_condition_seq.NEXTVAL;
     :NEW.DATE_CREATED_DTE := SYSDATE;  
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;     
  ELSIF INSERTING OR UPDATING THEN
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;
  END IF;
END;
/

