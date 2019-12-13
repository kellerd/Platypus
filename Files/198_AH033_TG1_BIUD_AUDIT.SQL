-- Start of DDL Script for Trigger TIPS.AH033_TG1_BIUD_AUDIT
-- Generated 2019-10-22 6:50:28 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER AH033_TG1_BIUD_AUDIT
 BEFORE 
 INSERT OR DELETE OR UPDATE
 ON AH033_HRSR_REQUEST_COMMENT
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
     v_audit_id := :OLD.CMT_AUDIT_ROW_ID;
  ELSIF DELETING THEN
     v_event_ind := 'D';
     v_audit_id := :OLD.CMT_AUDIT_ROW_ID;
  ELSE
  -- INSERTING
    SELECT LPAD(TO_CHAR(audit_row_id_seq.NEXTVAL),20,'0'),
           AH033_SQ1_CMT_ID.NEXTVAL
      INTO :NEW.CMT_AUDIT_ROW_ID,
           :NEW.CMT_ID
      FROM DUAL;
    v_event_ind := 'I';
    v_audit_id := :NEW.CMT_AUDIT_ROW_ID;
  END IF;

  IF INSERTING OR UPDATING THEN
     :NEW.CMT_LAST_UPDATE_DTE := SYSDATE;
     :NEW.CMT_LAST_UPDATE_BY_USER_ID := FN_GET_USER;
  END IF;

  SELECT LPAD(TO_CHAR(audit_event_id_seq.NEXTVAL),20,'0')
    INTO v_event_id
    FROM dual;

  -- UPDATE the audit_master table using the audit_master_web_update procedure
  AUDIT_MASTER_UPDATE (v_event_id,
                       v_audit_id,
                       v_event_datetime,
                       v_event_ind,
                       'AH033_HRSR_REQUEST_COMMENT');
  -- ADD a record to the audit_details table for each column changed
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CMT_ID',
                        TO_CHAR(:OLD.CMT_ID),
                        TO_CHAR(:NEW.CMT_ID));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CMT_HRSR_REQUEST_CD',
                        :OLD.CMT_HRSR_REQUEST_CD,
                        :NEW.CMT_HRSR_REQUEST_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CMT_LAST_UPDATE_BY_USER_ID',
                        :OLD.CMT_LAST_UPDATE_BY_USER_ID,
                        :NEW.CMT_LAST_UPDATE_BY_USER_ID);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CMT_LAST_UPDATE_DTE',
                        TO_CHAR(:OLD.CMT_LAST_UPDATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.CMT_LAST_UPDATE_DTE,
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


-- End of DDL Script for Trigger TIPS.AH033_TG1_BIUD_AUDIT

