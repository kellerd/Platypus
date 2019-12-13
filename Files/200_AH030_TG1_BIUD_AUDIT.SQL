-- Start of DDL Script for Trigger TIPS.AH030_TG1_BIUD_AUDIT
-- Generated 2019-10-22 7:24:49 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER AH030_TG1_BIUD_AUDIT
 BEFORE 
 INSERT OR DELETE OR UPDATE
 ON AH030_HRSR_PHANTOM_POSITION
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
     v_audit_id := :OLD.PHP_AUDIT_ROW_ID;
  ELSIF DELETING THEN
     v_event_ind := 'D';
     v_audit_id := :OLD.PHP_AUDIT_ROW_ID;
  ELSE
  -- INSERTING
    SELECT LPAD(TO_CHAR(audit_row_id_seq.NEXTVAL),20,'0')
      INTO :NEW.PHP_AUDIT_ROW_ID
      FROM DUAL;
    v_event_ind := 'I';
    v_audit_id := :NEW.PHP_AUDIT_ROW_ID;
  END IF;

  IF INSERTING OR UPDATING THEN
     :NEW.PHP_LAST_UPDATE_DTE := SYSDATE;
     :NEW.PHP_LAST_UPDATE_BY_USER_ID := FN_GET_USER;
  END IF;

  SELECT LPAD(TO_CHAR(audit_event_id_seq.NEXTVAL),20,'0')
    INTO v_event_id
    FROM dual;

  -- UPDATE the audit_master table using the audit_master_web_update procedure
  AUDIT_MASTER_UPDATE (v_event_id,
                       v_audit_id,
                       v_event_datetime,
                       v_event_ind,
                       'AH030_HRSR_PHANTOM_POSITION');
  -- ADD a record to the audit_details table for each column changed
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PHP_HRSR_REQUEST_CD',
                        :OLD.PHP_HRSR_REQUEST_CD,
                        :NEW.PHP_HRSR_REQUEST_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PHP_POS_TITLE_ENM',
                        :OLD.PHP_POS_TITLE_ENM,
                        :NEW.PHP_POS_TITLE_ENM);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PHP_POS_TITLE_FNM',
                        :OLD.PHP_POS_TITLE_FNM,
                        :NEW.PHP_POS_TITLE_FNM);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PHP_PARENT_POSITION_NMBR',
                        :OLD.PHP_PARENT_POSITION_NMBR,
                        :NEW.PHP_PARENT_POSITION_NMBR);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PHP_LANGUAGE_REQUIREMENT_IND',
                        :OLD.PHP_LANGUAGE_REQUIREMENT_IND,
                        :NEW.PHP_LANGUAGE_REQUIREMENT_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PHP_DELEGATION_AUTHORITY_CD',
                        :OLD.PHP_DELEGATION_AUTHORITY_CD,
                        :NEW.PHP_DELEGATION_AUTHORITY_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PHP_GROUP_IND',
                        :OLD.PHP_GROUP_IND,
                        :NEW.PHP_GROUP_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PHP_SUBGROUP_IND',
                        :OLD.PHP_SUBGROUP_IND,
                        :NEW.PHP_SUBGROUP_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PHP_LEVEL_IND',
                        :OLD.PHP_LEVEL_IND,
                        :NEW.PHP_LEVEL_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PHP_GEO_PROVINCE_CODE',
                        :OLD.PHP_GEO_PROVINCE_CODE,
                        :NEW.PHP_GEO_PROVINCE_CODE);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PHP_GEO_DETAIL_CODE',
                        :OLD.PHP_GEO_DETAIL_CODE,
                        :NEW.PHP_GEO_DETAIL_CODE);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PHP_LAST_UPDATE_BY_USER_ID',
                        :OLD.PHP_LAST_UPDATE_BY_USER_ID,
                        :NEW.PHP_LAST_UPDATE_BY_USER_ID);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'PHP_LAST_UPDATE_DTE',
                        TO_CHAR(:OLD.PHP_LAST_UPDATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.PHP_LAST_UPDATE_DTE,
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


-- End of DDL Script for Trigger TIPS.AH030_TG1_BIUD_AUDIT

