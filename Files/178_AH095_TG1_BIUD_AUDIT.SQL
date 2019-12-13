-- Start of DDL Script for Trigger TIPS.AH095_TG1_BIUD_AUDIT
-- Generated 2019-09-10 2:53:18 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER AH095_TG1_BIUD_AUDIT
 BEFORE 
 INSERT OR DELETE OR UPDATE
 ON AH095_HRSR_STUDENT_DETAIL
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, May 25 2018
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- 
--
   v_audit_id                audit_master.aum_audit_row_id%TYPE;
   v_event_id                audit_master.aum_event_id%TYPE;
   v_event_ind               audit_master.aum_event_ind%TYPE;
   v_event_datetime          audit_master.aum_event_datetime%TYPE := SYSDATE;
   v_count                   INTEGER;
BEGIN
  IF UPDATING THEN
     v_event_ind := 'U';
     v_audit_id := :OLD.AUDIT_ROW_ID;
  ELSIF DELETING THEN
     v_event_ind := 'D';
     v_audit_id := :OLD.AUDIT_ROW_ID;
  ELSE
  -- INSERTING
    SELECT LPAD(TO_CHAR(audit_row_id_seq.NEXTVAL),20,'0')
      INTO :NEW.AUDIT_ROW_ID
      FROM DUAL;
    v_event_ind := 'I';
    v_audit_id := :NEW.AUDIT_ROW_ID;
  END IF;

  IF INSERTING THEN 
     :NEW.DATE_CREATED_DTE := SYSDATE;  
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := FN_GET_USER;     
  ELSIF INSERTING OR UPDATING THEN
     :NEW.DATE_LAST_UPDATE_DTE := SYSDATE;
     :NEW.USER_LAST_UPDATE_ID := FN_GET_USER;
  END IF;

  SELECT LPAD(TO_CHAR(audit_event_id_seq.NEXTVAL),20,'0')
    INTO v_event_id
    FROM dual;

  -- UPDATE the audit_master table using the audit_master_web_update procedure
  AUDIT_MASTER_UPDATE (v_event_id,
                       v_audit_id,
                       v_event_datetime,
                       v_event_ind,
                       'AH095_HRSR_STUDENT_DETAIL');
  -- ADD a record to the audit_details table for each column changed
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'HRSR_REQUEST_CD',
                        :OLD.HRSR_REQUEST_CD,
                        :NEW.HRSR_REQUEST_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PAYMENT_AMOUNT_AMT',
                        TO_CHAR(:OLD.PAYMENT_AMOUNT_AMT),
                        TO_CHAR(:NEW.PAYMENT_AMOUNT_AMT));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'DISBURSEMENT_RATE_CD',
                        :OLD.DISBURSEMENT_RATE_CD,
                        :NEW.DISBURSEMENT_RATE_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'EDUCATION_LEVEL_CD',
                        :OLD.EDUCATION_LEVEL_CD,
                        :NEW.EDUCATION_LEVEL_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'DAYS_OF_WEEK_TXT',
                        :OLD.DAYS_OF_WEEK_TXT,
                        :NEW.DAYS_OF_WEEK_TXT);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'ABORIGINAL_PROGRAM_IND',
                        TO_CHAR(:OLD.ABORIGINAL_PROGRAM_IND),
                        TO_CHAR(:NEW.ABORIGINAL_PROGRAM_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'COA_COLLECTIVE_AGREEMENT_IND',
                        :OLD.COA_COLLECTIVE_AGREEMENT_IND,
                        :NEW.COA_COLLECTIVE_AGREEMENT_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'IRREGULAR_SHIFT_WORKER_IND',
                        TO_CHAR(:OLD.IRREGULAR_SHIFT_WORKER_IND),
                        TO_CHAR(:NEW.IRREGULAR_SHIFT_WORKER_IND));
  -- Cleanup the audit_master table.  Delete the audit master record
  -- if no changes have actually been made to the audit details.
  SELECT COUNT(*)
    INTO v_count
    FROM audit_details
   WHERE aud_event_id = v_event_id;
  IF v_count = 0 THEN
     DELETE FROM audit_master
      WHERE aum_event_id = v_event_id;
  END IF;
END;
/


-- End of DDL Script for Trigger TIPS.AH095_TG1_BIUD_AUDIT

