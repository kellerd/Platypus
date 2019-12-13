
CREATE SEQUENCE AH107_PROGRESS_TRACKER_SEQ
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999999999999999999
  NOCYCLE
  NOORDER
  NOCACHE
/

CREATE OR REPLACE TRIGGER ah107_tg1_biud_audit
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON AH107_HRSR_PROGRESS_TRACKER
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, June 07 2019
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- 
--
   v_user_id  users.usr_user_id%TYPE := fn_get_user;

BEGIN
  
  IF INSERTING THEN 
     :NEW.HRSR_PROGRESS_TRACKER_ID := AH107_PROGRESS_TRACKER_SEQ.NEXTVAL;
     :NEW.DATE_CREATED_DTE := SYSDATE;  
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;     
  ELSIF INSERTING OR UPDATING THEN
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;
  END IF;
END;
/


CREATE OR REPLACE TRIGGER th202_tg1_biud_audit
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON TH202_MILESTONE
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, May 30 2019
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- 
--
   v_user_id  users.usr_user_id%TYPE := fn_get_user;

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


CREATE OR REPLACE TRIGGER th203_tg1_biud_audit
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON TH203_XREF_TH048_TH202
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, May 30 2019
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- 
--
   v_user_id  users.usr_user_id%TYPE := fn_get_user;
   
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

