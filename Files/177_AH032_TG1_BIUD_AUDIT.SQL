-- Start of DDL Script for Trigger TIPS.AH032_TG1_BIUD_AUDIT
-- Generated 2019-09-10 2:25:14 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER AH032_TG1_BIUD_AUDIT
 BEFORE 
 INSERT OR DELETE OR UPDATE
 ON AH032_HRSR_RDIMS_ATTACHMENT
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, July 24 2008
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
     v_audit_id := :OLD.ATT_AUDIT_ROW_ID;
  ELSIF DELETING THEN
     v_event_ind := 'D';
     v_audit_id := :OLD.ATT_AUDIT_ROW_ID;
  ELSE
  -- INSERTING
    SELECT LPAD(TO_CHAR(audit_row_id_seq.NEXTVAL),20,'0')
      INTO :NEW.ATT_AUDIT_ROW_ID
      FROM DUAL;
    v_event_ind := 'I';
    v_audit_id := :NEW.ATT_AUDIT_ROW_ID;
  END IF;

  IF INSERTING OR UPDATING THEN
     :NEW.ATT_LAST_UPDATE_DTE := SYSDATE;
     :NEW.ATT_LAST_UPDATE_BY_USER_ID := FN_GET_USER;
  END IF;

  SELECT LPAD(TO_CHAR(audit_event_id_seq.NEXTVAL),20,'0')
    INTO v_event_id
    FROM dual;

  -- UPDATE the audit_master table using the audit_master_web_update procedure
  AUDIT_MASTER_UPDATE (v_event_id,
                       v_audit_id,
                       v_event_datetime,
                       v_event_ind,
                       'AH032_HRSR_RDIMS_ATTACHMENT');
  -- ADD a record to the audit_details table for each column changed
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'ATT_HRSR_REQUEST_CD',
                        :OLD.ATT_HRSR_REQUEST_CD,
                        :NEW.ATT_HRSR_REQUEST_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'ATT_RDIMS_NBR',
                        TO_CHAR(:OLD.ATT_RDIMS_NBR),
                        TO_CHAR(:NEW.ATT_RDIMS_NBR));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'ATT_RDIMS_TXT',
                        :OLD.ATT_RDIMS_TXT,
                        :NEW.ATT_RDIMS_TXT);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'ATT_LAST_UPDATE_BY_USER_ID',
                        :OLD.ATT_LAST_UPDATE_BY_USER_ID,
                        :NEW.ATT_LAST_UPDATE_BY_USER_ID);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'ATT_LAST_UPDATE_DTE',
                        TO_CHAR(:OLD.ATT_LAST_UPDATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.ATT_LAST_UPDATE_DTE,
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


-- End of DDL Script for Trigger TIPS.AH032_TG1_BIUD_AUDIT

