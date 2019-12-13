
CREATE SEQUENCE ah102_hrsr_loo_seq
  INCREMENT BY 1
  START WITH 1
  MINVALUE 1
  MAXVALUE 9999999999999999999999999999
  NOCYCLE
  NOORDER
  NOCACHE
/



-- Start of DDL Script for Trigger TIPS.AH102_TG1_BIUD_AUDIT
-- Generated 2019-06-08 6:17:12 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER AH102_TG1_BIUD_AUDIT
 BEFORE 
 INSERT OR DELETE OR UPDATE
 ON AH102_HRSR_LETTER_OF_OFFER
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, May 24 2019
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- 
--

   v_user_id  users.usr_user_id%TYPE := FN_GET_USER;

BEGIN
  
  IF INSERTING THEN 
     :NEW.HRSR_LETTER_OF_OFFER_ID := AH102_HRSR_LOO_SEQ.NEXTVAL;
     :NEW.DATE_CREATED_DTE := SYSDATE;  
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;

     -- Write a milestone record to AH107_HRSR_PROGRESS_TRACKER:
     -- Letter of Offer Generated
     INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                 (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
          VALUES (:NEW.hrsr_request_cd, 'LOG', SYSDATE);

  ELSIF INSERTING OR UPDATING THEN
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := v_user_id;
  END IF;
END;
/


-- End of DDL Script for Trigger TIPS.AH102_TG1_BIUD_AUDIT













