-- Start of DDL Script for Trigger TIPS.AH028_TG1_BIUD_AUDIT
-- Generated 2019-10-22 7:22:03 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER AH028_TG1_BIUD_AUDIT
 BEFORE 
 INSERT OR DELETE OR UPDATE
 ON AH028_HRSR_CLASSIFICATION
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, July 24 2008
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- Hynes, J.  17-AUG-11  HRSR_DSRH-01625: Added column CLS_OL_OTHER_CD
--
   v_audit_id                audit_master.aum_audit_row_id%TYPE;
   v_event_id                audit_master.aum_event_id%TYPE;
   v_event_ind               audit_master.aum_event_ind%TYPE;
   v_event_datetime          audit_master.aum_event_datetime%TYPE := SYSDATE;
   v_count                   INTEGER;
BEGIN
  IF UPDATING THEN
     v_event_ind := 'U';
     v_audit_id := :OLD.CLS_AUDIT_ROW_ID;
  ELSIF DELETING THEN
     v_event_ind := 'D';
     v_audit_id := :OLD.CLS_AUDIT_ROW_ID;
  ELSE
  -- INSERTING
    SELECT LPAD(TO_CHAR(audit_row_id_seq.NEXTVAL),20,'0')
      INTO :NEW.CLS_AUDIT_ROW_ID
      FROM DUAL;
    v_event_ind := 'I';
    v_audit_id := :NEW.CLS_AUDIT_ROW_ID;
  END IF;
  SELECT LPAD(TO_CHAR(audit_event_id_seq.NEXTVAL),20,'0')
    INTO v_event_id
    FROM dual;

  IF INSERTING OR UPDATING THEN
     :NEW.CLS_LAST_UPDATE_DTE := SYSDATE;
     :NEW.CLS_LAST_UPDATE_BY_USER_ID := FN_GET_USER;
  END IF;

  -- UPDATE the audit_master table using the audit_master_web_update procedure
  AUDIT_MASTER_UPDATE (v_event_id,
                       v_audit_id,
                       v_event_datetime,
                       v_event_ind,
                       'AH028_HRSR_CLASSIFICATION');
  -- ADD a record to the audit_details table for each column changed
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_HRSR_REQUEST_CD',
                        :OLD.CLS_HRSR_REQUEST_CD,
                        :NEW.CLS_HRSR_REQUEST_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_POSITION_NMBR',
                        :OLD.CLS_POSITION_NMBR,
                        :NEW.CLS_POSITION_NMBR);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_GWD_MODEL_IND',
                        :OLD.CLS_GWD_MODEL_IND,
                        :NEW.CLS_GWD_MODEL_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_POSITION_TITLE_E',
                        :OLD.CLS_POSITION_TITLE_E,
                        :NEW.CLS_POSITION_TITLE_E);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_POSITION_TITLE_F',
                        :OLD.CLS_POSITION_TITLE_F,
                        :NEW.CLS_POSITION_TITLE_F);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_PARENT_POSITION_NMBR',
                        :OLD.CLS_PARENT_POSITION_NMBR,
                        :NEW.CLS_PARENT_POSITION_NMBR);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_EMPLOYMENT_TYPE_CODE',
                        :OLD.CLS_EMPLOYMENT_TYPE_CODE,
                        :NEW.CLS_EMPLOYMENT_TYPE_CODE);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_GROUP_IND',
                        :OLD.CLS_GROUP_IND,
                        :NEW.CLS_GROUP_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_SUBGROUP_IND',
                        :OLD.CLS_SUBGROUP_IND,
                        :NEW.CLS_SUBGROUP_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_LEVEL_IND',
                        :OLD.CLS_LEVEL_IND,
                        :NEW.CLS_LEVEL_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_REGION_IND',
                        :OLD.CLS_REGION_IND,
                        :NEW.CLS_REGION_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_ADMIN_GROUP_CD',
                        :OLD.CLS_ADMIN_GROUP_CD,
                        :NEW.CLS_ADMIN_GROUP_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_DIRECTORATE_IND',
                        :OLD.CLS_DIRECTORATE_IND,
                        :NEW.CLS_DIRECTORATE_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_BRANCH_IND',
                        :OLD.CLS_BRANCH_IND,
                        :NEW.CLS_BRANCH_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_GEO_PROVINCE_CODE',
                        :OLD.CLS_GEO_PROVINCE_CODE,
                        :NEW.CLS_GEO_PROVINCE_CODE);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_GEO_DETAIL_CODE',
                        :OLD.CLS_GEO_DETAIL_CODE,
                        :NEW.CLS_GEO_DETAIL_CODE);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_LANGUAGE_REQUIREMENT_IND',
                        :OLD.CLS_LANGUAGE_REQUIREMENT_IND,
                        :NEW.CLS_LANGUAGE_REQUIREMENT_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_ENGLISH_READ_IND',
                        :OLD.CLS_ENGLISH_READ_IND,
                        :NEW.CLS_ENGLISH_READ_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_ENGLISH_WRITE_IND',
                        :OLD.CLS_ENGLISH_WRITE_IND,
                        :NEW.CLS_ENGLISH_WRITE_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_ENGLISH_ORAL_IND',
                        :OLD.CLS_ENGLISH_ORAL_IND,
                        :NEW.CLS_ENGLISH_ORAL_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_FRENCH_READ_IND',
                        :OLD.CLS_FRENCH_READ_IND,
                        :NEW.CLS_FRENCH_READ_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_FRENCH_WRITE_IND',
                        :OLD.CLS_FRENCH_WRITE_IND,
                        :NEW.CLS_FRENCH_WRITE_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_FRENCH_ORAL_IND',
                        :OLD.CLS_FRENCH_ORAL_IND,
                        :NEW.CLS_FRENCH_ORAL_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_SECURITY_CLEARANCE_IND',
                        :OLD.CLS_SECURITY_CLEARANCE_IND,
                        :NEW.CLS_SECURITY_CLEARANCE_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_DATE_EXPIRY_DTE',
                        TO_CHAR(:OLD.CLS_DATE_EXPIRY_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.CLS_DATE_EXPIRY_DTE,
                                'DD-MON-YYYY HH:MI:SS am'));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_OL_SERV_PUBLIC_CD',
                        :OLD.CLS_OL_SERV_PUBLIC_CD,
                        :NEW.CLS_OL_SERV_PUBLIC_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_OL_PER_SERV_CD',
                        :OLD.CLS_OL_PER_SERV_CD,
                        :NEW.CLS_OL_PER_SERV_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_OL_GRIEVANCES_CD',
                        :OLD.CLS_OL_GRIEVANCES_CD,
                        :NEW.CLS_OL_GRIEVANCES_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_OL_CENTRAL_SERV_CD',
                        :OLD.CLS_OL_CENTRAL_SERV_CD,
                        :NEW.CLS_OL_CENTRAL_SERV_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_OL_SUPERVISERY_SERV_CD',
                        :OLD.CLS_OL_SUPERVISERY_SERV_CD,
                        :NEW.CLS_OL_SUPERVISERY_SERV_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_LAST_UPDATE_BY_USER_ID',
                        :OLD.CLS_LAST_UPDATE_BY_USER_ID,
                        :NEW.CLS_LAST_UPDATE_BY_USER_ID);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_LAST_UPDATE_DTE',
                        TO_CHAR(:OLD.CLS_LAST_UPDATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.CLS_LAST_UPDATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'CLS_OL_OTHER_CD',
                        :OLD.CLS_OL_OTHER_CD,
                        :NEW.CLS_OL_OTHER_CD);
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


-- End of DDL Script for Trigger TIPS.AH028_TG1_BIUD_AUDIT

