-- Start of DDL Script for Trigger TIPS.TH205_TG1_BIUD_AUDIT
-- Generated 2019-09-17 9:19:48 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER th205_tg1_biud_audit
 BEFORE
  INSERT OR DELETE OR UPDATE
 ON TH205_XREF_TH048_ASN_TYPE
REFERENCING NEW AS NEW OLD AS OLD
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, Sep 17 2019
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


-- End of DDL Script for Trigger TIPS.TH205_TG1_BIUD_AUDIT

