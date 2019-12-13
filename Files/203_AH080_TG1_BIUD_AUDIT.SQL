-- Start of DDL Script for Trigger TIPS.AH080_TG1_BIUD_AUDIT
-- Generated 2019-10-22 7:29:28 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER AH080_TG1_BIUD_AUDIT
 BEFORE 
 INSERT OR DELETE OR UPDATE
 ON AH080_HRSR_STATUS_HISTORY
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, December 12, 2012
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
     v_audit_id := :OLD.HSH_AUDIT_ROW_ID;
     :NEW.HSH_CHANGE_MADE_BY_USER_ID := FN_GET_USER;
     :NEW.HSH_DATE_UPDATE_DTE := SYSDATE;
  ELSIF DELETING THEN
     v_event_ind := 'D';
     v_audit_id := :OLD.HSH_AUDIT_ROW_ID;
  ELSE
  -- INSERTING
    SELECT LPAD(TO_CHAR(audit_row_id_seq.NEXTVAL),20,'0'),
           AH080_SQ1_HSH_ID.NEXTVAL
      INTO :NEW.HSH_AUDIT_ROW_ID,
           :NEW.HSH_ID
      FROM DUAL;
    v_event_ind := 'I';
    v_audit_id := :NEW.HSH_AUDIT_ROW_ID;
    :NEW.HSH_CHANGE_MADE_BY_USER_ID := FN_GET_USER;
    :NEW.HSH_DATE_UPDATE_DTE := SYSDATE;
  END IF;

  SELECT LPAD(TO_CHAR(audit_event_id_seq.NEXTVAL),20,'0')
    INTO v_event_id
    FROM dual;

  -- UPDATE the audit_master table using the audit_master_web_update procedure
  AUDIT_MASTER_UPDATE (v_event_id,
                       v_audit_id,
                       v_event_datetime,
                       v_event_ind,
                       'AH080_HRSR_STATUS_HISTORY');
  -- ADD a record to the audit_details table for each column changed
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'HSH_ID',
                        TO_CHAR(:OLD.HSH_ID),
                        TO_CHAR(:NEW.HSH_ID));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'HSH_HRSR_REQUEST_CD',
                        :OLD.HSH_HRSR_REQUEST_CD,
                        :NEW.HSH_HRSR_REQUEST_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'HSH_CHANGE_MADE_BY_USER_ID',
                        :OLD.HSH_CHANGE_MADE_BY_USER_ID,
                        :NEW.HSH_CHANGE_MADE_BY_USER_ID);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'HSH_DATE_UPDATE_DTE',
                        TO_CHAR(:OLD.HSH_DATE_UPDATE_DTE,'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.HSH_DATE_UPDATE_DTE,'DD-MON-YYYY HH:MI:SS am'));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'HSH_OLD_HRSR_STATUS_CD',
                        :OLD.HSH_OLD_HRSR_STATUS_CD,
                        :NEW.HSH_OLD_HRSR_STATUS_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'HSH_NEW_HRSR_STATUS_CD',
                        :OLD.HSH_NEW_HRSR_STATUS_CD,
                        :NEW.HSH_NEW_HRSR_STATUS_CD);
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


-- End of DDL Script for Trigger TIPS.AH080_TG1_BIUD_AUDIT

