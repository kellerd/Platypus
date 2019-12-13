-- Start of DDL Script for Trigger TIPS.CAST01
-- Generated 2019-10-22 7:31:30 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER CAST01
 BEFORE 
 INSERT OR DELETE OR UPDATE
 ON CASE_FILE_STATE_HISTORY
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
-- Written by: Jennifer Hynes, 18-APR-2005
--             CLASSIF-01021 (Release 10.5)
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
--
   v_audit_id                audit_master.aum_audit_row_id%TYPE;
   v_event_id                audit_master.aum_event_id%TYPE;
   v_event_ind               audit_master.aum_event_ind%TYPE;
   v_event_datetime          audit_master.aum_event_datetime%TYPE := SYSDATE;
   v_count                   INTEGER;

BEGIN
  IF UPDATING THEN
      v_event_ind := 'U';
      v_audit_id := :OLD.CAS_AUDIT_ROW_ID;
  ELSIF DELETING THEN
      v_event_ind := 'D';
      v_audit_id := :OLD.CAS_AUDIT_ROW_ID;
  ELSE
     SELECT LPAD(TO_CHAR(audit_row_id_seq.NEXTVAL),20,'0')
       INTO :NEW.CAS_AUDIT_ROW_ID
       FROM DUAL;
     v_event_ind := 'I';
     v_audit_id := :NEW.CAS_AUDIT_ROW_ID;
  END IF;
   :NEW.CAS_UPDATED_DATE := SYSDATE;
   :NEW.CAS_UPDATED_BY_USER_ID := FN_GET_USER;

  -- Audit information:
  SELECT LPAD(TO_CHAR(audit_event_id_seq.NEXTVAL),20,'0')
    INTO v_event_id
    FROM dual;
  -- UPDATE the audit_master table using the audit_master_update procedure
  AUDIT_MASTER_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        v_event_ind,
                        'CASE_FILE_STATE_HISTORY' );
  -- WRITE a row to the audit details table for each column changed.
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CAS_CASE_FILE_NMBR',
                        :OLD.CAS_CASE_FILE_NMBR,
                        :NEW.CAS_CASE_FILE_NMBR);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CAS_CASE_STATE_IND',
                        :OLD.CAS_CASE_STATE_IND,
                        :NEW.CAS_CASE_STATE_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CAS_ON_HOLD_DATE',
                        TO_CHAR(:OLD.CAS_ON_HOLD_DATE, 'YYYYDDDSSSSS'),
                        TO_CHAR(:NEW.CAS_ON_HOLD_DATE, 'YYYYDDDSSSSS'));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CAS_REASON_ON_HOLD',
                        :OLD.CAS_REASON_ON_HOLD,
                        :NEW.CAS_REASON_ON_HOLD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CAS_REACTIVATE_DATE',
                        TO_CHAR(:OLD.CAS_REACTIVATE_DATE, 'YYYYDDDSSSSS'),
                        TO_CHAR(:NEW.CAS_REACTIVATE_DATE, 'YYYYDDDSSSSS'));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CAS_UPDATED_BY_USER_ID',
                        :OLD.CAS_UPDATED_BY_USER_ID,
                        :NEW.CAS_UPDATED_BY_USER_ID);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CAS_UPDATED_DATE',
                        TO_CHAR(:OLD.CAS_UPDATED_DATE, 'YYYYDDDSSSSS'),
                        TO_CHAR(:NEW.CAS_UPDATED_DATE, 'YYYYDDDSSSSS'));
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


-- End of DDL Script for Trigger TIPS.CAST01

