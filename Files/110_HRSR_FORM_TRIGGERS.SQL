

CREATE SEQUENCE th199_document_id_seq
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999999999999999999
  NOCYCLE
  NOORDER
  NOCACHE
/


CREATE SEQUENCE th200_form_id_seq
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999999999999999999
  NOCYCLE
  NOORDER
  NOCACHE
/

CREATE OR REPLACE TRIGGER th199_tg1_biud_audit
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON TH199_HRSR_DOCUMENT
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
   v_user_id  users.usr_user_id%TYPE := FN_GET_USER;

BEGIN
  
  IF INSERTING THEN 
     :NEW.HRSR_DOCUMENT_ID := TH199_DOCUMENT_ID_SEQ.NEXTVAL;
     :NEW.DATE_CREATED_DTE := SYSDATE;  
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;     
  ELSIF INSERTING OR UPDATING THEN
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER th200_tg1_biud_audit
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON TH200_HRSR_FORM
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
   v_user_id  users.usr_user_id%TYPE := FN_GET_USER;

BEGIN
  
  IF INSERTING THEN 
     :NEW.HRSR_FORM_ID := TH200_FORM_ID_SEQ.NEXTVAL;  
     :NEW.DATE_CREATED_DTE := SYSDATE;  
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;     
  ELSIF INSERTING OR UPDATING THEN
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;
  END IF;
END;
/


CREATE OR REPLACE TRIGGER th201_tg1_biud_audit
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON TH201_XREF_TH048_TH200_FORM
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

CREATE OR REPLACE TRIGGER ah105_tg1_biud_audit
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON AH105_XREF_AH027_TH200_FORM
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

CREATE OR REPLACE TRIGGER ah106_tg1_biud_audit
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON AH106_XREF_AH027_TH199_DOC
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


