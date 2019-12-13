-- Start of DDL Script for Trigger TIPS.AH031_TG1_BIUD_AUDIT
-- Generated 2019-10-22 7:27:04 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER AH031_TG1_BIUD_AUDIT
 BEFORE 
 INSERT OR DELETE OR UPDATE
 ON AH031_HRSR_CASUAL
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, July 24 2008
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- Hynes, J.  07-OCT-09  HRSR_DSRH-01430: Removed CSL_SECURITY_CLEARANCE_IND
--
   v_audit_id                audit_master.aum_audit_row_id%TYPE;
   v_event_id                audit_master.aum_event_id%TYPE;
   v_event_ind               audit_master.aum_event_ind%TYPE;
   v_event_datetime          audit_master.aum_event_datetime%TYPE := SYSDATE;
   v_count                   INTEGER;
BEGIN
  IF UPDATING THEN
     v_event_ind := 'U';
     v_audit_id := :OLD.CSL_AUDIT_ROW_ID;
  ELSIF DELETING THEN
     v_event_ind := 'D';
     v_audit_id := :OLD.CSL_AUDIT_ROW_ID;
  ELSE
  -- INSERTING
    SELECT LPAD(TO_CHAR(audit_row_id_seq.NEXTVAL),20,'0')
      INTO :NEW.CSL_AUDIT_ROW_ID
      FROM DUAL;
    v_event_ind := 'I';
    v_audit_id := :NEW.CSL_AUDIT_ROW_ID;
  END IF;

  IF INSERTING OR UPDATING THEN
     :NEW.CSL_LAST_UPDATE_DTE := SYSDATE;
     :NEW.CSL_LAST_UPDATE_BY_USER_ID := FN_GET_USER;
  END IF;

  SELECT LPAD(TO_CHAR(audit_event_id_seq.NEXTVAL),20,'0')
    INTO v_event_id
    FROM dual;

  -- UPDATE the audit_master table using the audit_master_web_update procedure
  AUDIT_MASTER_UPDATE (v_event_id,
                       v_audit_id,
                       v_event_datetime,
                       v_event_ind,
                       'AH031_HRSR_CASUAL');
  -- ADD a record to the audit_details table for each column changed
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_HRSR_REQUEST_CD',
                        :OLD.CSL_HRSR_REQUEST_CD,
                        :NEW.CSL_HRSR_REQUEST_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_ADDRESS_TXT',
                        :OLD.CSL_ADDRESS_TXT,
                        :NEW.CSL_ADDRESS_TXT);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_BUS_TELEPHONE_NUM',
                        TO_CHAR(:OLD.CSL_BUS_TELEPHONE_NUM),
                        TO_CHAR(:NEW.CSL_BUS_TELEPHONE_NUM));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_HOME_TELEPHONE_NUM',
                        TO_CHAR(:OLD.CSL_HOME_TELEPHONE_NUM),
                        TO_CHAR(:NEW.CSL_HOME_TELEPHONE_NUM));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_CASUAL_REASON_IND',
                        :OLD.CSL_CASUAL_REASON_IND,
                        :NEW.CSL_CASUAL_REASON_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_DAYS_OF_WEEK_TXT',
                        :OLD.CSL_DAYS_OF_WEEK_TXT,
                        :NEW.CSL_DAYS_OF_WEEK_TXT);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_PAYMENT_AMOUNT_AMT',
                        TO_CHAR(:OLD.CSL_PAYMENT_AMOUNT_AMT),
                        TO_CHAR(:NEW.CSL_PAYMENT_AMOUNT_AMT));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_DISBURSEMENT_RATE_CD',
                        :OLD.CSL_DISBURSEMENT_RATE_CD,
                        :NEW.CSL_DISBURSEMENT_RATE_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_IRREGULAR_SHIFT_WORK_IND',
                        TO_CHAR(:OLD.CSL_IRREGULAR_SHIFT_WORK_IND),
                        TO_CHAR(:NEW.CSL_IRREGULAR_SHIFT_WORK_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_ASSIGNED_WORK_WEEK_HRS_NUM',
                        :OLD.CSL_ASSIGNED_WORK_WEEK_HRS_NUM,
                        :NEW.CSL_ASSIGNED_WORK_WEEK_HRS_NUM);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_SHIFT_WORK_IND',
                        TO_CHAR(:OLD.CSL_SHIFT_WORK_IND),
                        TO_CHAR(:NEW.CSL_SHIFT_WORK_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_ISOLATED_POST_IND',
                        TO_CHAR(:OLD.CSL_ISOLATED_POST_IND),
                        TO_CHAR(:NEW.CSL_ISOLATED_POST_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_MEAL_IND',
                        TO_CHAR(:OLD.CSL_MEAL_IND),
                        TO_CHAR(:NEW.CSL_MEAL_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_OTHER_IND',
                        TO_CHAR(:OLD.CSL_OTHER_IND),
                        TO_CHAR(:NEW.CSL_OTHER_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_ALLOWANCE_OTHER_TXT',
                        :OLD.CSL_ALLOWANCE_OTHER_TXT,
                        :NEW.CSL_ALLOWANCE_OTHER_TXT);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_LAST_UPDATE_BY_USER_ID',
                        :OLD.CSL_LAST_UPDATE_BY_USER_ID,
                        :NEW.CSL_LAST_UPDATE_BY_USER_ID);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CSL_LAST_UPDATE_DTE',
                        TO_CHAR(:OLD.CSL_LAST_UPDATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.CSL_LAST_UPDATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'));
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


-- End of DDL Script for Trigger TIPS.AH031_TG1_BIUD_AUDIT

