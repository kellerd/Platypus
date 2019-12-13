-- Start of DDL Script for Trigger TIPS.AH029_TG1_BIUD_AUDIT
-- Generated 2019-11-06 8:58:02 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER AH029_TG1_BIUD_AUDIT
 BEFORE 
 INSERT OR DELETE OR UPDATE
 ON AH029_HRSR_STAFFING
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, July 24 2008
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- Hynes, J.  08-JUN-19  HRSR 2.0: Modified to write a record to
--                       AH107_HRSR_PROGRESS_TRACKER when there's a change to
--                       the Candidate PIN and a record exists in
--                       AH109_HRSR_CANDIDATE_SIN.
--
-- Hynes, J.  25-MAY-18  CR-2246: Added STF_CLEARANCE_CONFIRM_IND.
--
-- Hynes, J.  16-APR-12  HRSR_DSRH-1520: Added STF_ASN_GREATER_4_MTHS_IND and
--                       STF_ASN_GREATER_12_MTHS_IND
--
-- Hynes, J.  21-OCT-11  HRSR_DSRH-01642: Added STF_STUDENT_BRIDGING_IND
--
-- Hynes, J.  07-OCT-09  HRSR_DSRH-01430: Added STF_SECURITY_CLEARANCE_IND
--
   v_audit_id                audit_master.aum_audit_row_id%TYPE;
   v_event_id                audit_master.aum_event_id%TYPE;
   v_event_ind               audit_master.aum_event_ind%TYPE;
   v_event_datetime          audit_master.aum_event_datetime%TYPE := SYSDATE;
   v_count                   INTEGER;
   v_hr_user_ind             INTEGER;
BEGIN

  -- Write a milestone record:
  IF UPDATING AND
     :OLD.STF_CANDIDATE_PIN IS NULL AND 
     :NEW.STF_CANDIDATE_PIN LIKE '0%' THEN
     -- Check if the user making the change is an HR User and if a record exists
     -- in AH109_HRSR_CANDIDATE_SIN:
     
     SELECT COUNT(*)
       INTO v_hr_user_ind
       FROM user_services
      WHERE uss_user_id = FN_GET_USER -- User logged in
        AND uss_service_ind IN ('CLSGP1', 'CLSGP3',
                                'CLSGP4', 'CLSGP5',
                                'STFS2',  'STFS3',
                                'SYSGR1')
        AND EXISTS (SELECT *
                      FROM AH109_HRSR_CANDIDATE_SIN
                     WHERE HRSR_REQUEST_CD = :NEW.STF_HRSR_REQUEST_CD);
                     
     IF v_hr_user_ind > 0 THEN
        INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                   (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
            VALUES (:NEW.stf_hrsr_request_cd, 'PRI', SYSDATE);
     END IF;
  END IF;
  
   IF UPDATING AND
    NVL(:OLD.STF_LETTER_OF_OFFER_RDIMS_NBR, 1) != :NEW.STF_LETTER_OF_OFFER_RDIMS_NBR AND
    :NEW.STF_OATH_DTE IS NOT NULL THEN
     -- Signed Letter of Offer Uploaded, check if Oath Date is set
     INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                 (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
          VALUES (:NEW.stf_hrsr_request_cd, 'LOU', SYSDATE);
   END IF;
  
  IF UPDATING AND
     (:OLD.STF_OATH_DTE IS NULL OR :OLD.STF_DATE_LOO_SIGNED_DTE IS NULL) AND
     :NEW.STF_OATH_DTE IS NOT NULL AND :NEW.STF_DATE_LOO_SIGNED_DTE IS NOT NULL THEN
     -- Post Hire Complete
     INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                 (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
          VALUES (:NEW.stf_hrsr_request_cd, 'PHC', SYSDATE);
   END IF;

  -- Delete the record from the table AH109_HRSR_CANDIDATE_SIN when a real PRI 
  -- is assigned to the STF_CANDIDATE_PIN:
  IF UPDATING AND
     :OLD.STF_CANDIDATE_PIN IS NULL AND
     :NEW.STF_CANDIDATE_PIN LIKE '0%' THEN
     
     DELETE FROM AH109_HRSR_CANDIDATE_SIN
      WHERE HRSR_REQUEST_CD = :NEW.STF_HRSR_REQUEST_CD;
     
  END IF;
  
  IF UPDATING THEN
     v_event_ind := 'U';
     v_audit_id := :OLD.STF_AUDIT_ROW_ID;
  ELSIF DELETING THEN
     v_event_ind := 'D';
     v_audit_id := :OLD.STF_AUDIT_ROW_ID;
  ELSE
  -- INSERTING
    SELECT LPAD(TO_CHAR(audit_row_id_seq.NEXTVAL),20,'0')
      INTO :NEW.STF_AUDIT_ROW_ID
      FROM DUAL;
    v_event_ind := 'I';
    v_audit_id := :NEW.STF_AUDIT_ROW_ID;
  END IF;

  IF INSERTING OR UPDATING THEN
     :NEW.STF_LAST_UPDATE_DTE := SYSDATE;
     :NEW.STF_LAST_UPDATE_BY_USER_ID := FN_GET_USER;
  END IF;

  SELECT LPAD(TO_CHAR(audit_event_id_seq.NEXTVAL),20,'0')
    INTO v_event_id
    FROM dual;

  -- UPDATE the audit_master table using the audit_master_web_update procedure
  AUDIT_MASTER_UPDATE (v_event_id,
                       v_audit_id,
                       v_event_datetime,
                       v_event_ind,
                       'AH029_HRSR_STAFFING');
  -- ADD a record to the audit_details table for each column changed
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_HRSR_REQUEST_CD',
                        :OLD.STF_HRSR_REQUEST_CD,
                        :NEW.STF_HRSR_REQUEST_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_RELATED_PLAN_IND',
                        TO_CHAR(:OLD.STF_RELATED_PLAN_IND),
                        TO_CHAR(:NEW.STF_RELATED_PLAN_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_REFERENCE_PLAN_TXT',
                        :OLD.STF_REFERENCE_PLAN_TXT,
                        :NEW.STF_REFERENCE_PLAN_TXT);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_EXTENSION_CD',
                        :OLD.STF_EXTENSION_CD,
                        :NEW.STF_EXTENSION_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_ADVERTISED_IND',
                        TO_CHAR(:OLD.STF_ADVERTISED_IND),
                        TO_CHAR(:NEW.STF_ADVERTISED_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_INTERNAL_IND',
                        TO_CHAR(:OLD.STF_INTERNAL_IND),
                        TO_CHAR(:NEW.STF_INTERNAL_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_ANTICIPATORY_PROCESS_IND',
                        TO_CHAR(:OLD.STF_ANTICIPATORY_PROCESS_IND),
                        TO_CHAR(:NEW.STF_ANTICIPATORY_PROCESS_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_PHANTOM_REQUIRED_IND',
                        TO_CHAR(:OLD.STF_PHANTOM_REQUIRED_IND),
                        TO_CHAR(:NEW.STF_PHANTOM_REQUIRED_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_EMPLOYMENT_TYPE_ID',
                        :OLD.STF_EMPLOYMENT_TYPE_ID,
                        :NEW.STF_EMPLOYMENT_TYPE_ID);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_ASSIGNED_WORK_WEEK_HRS_NUM',
                        TO_CHAR(:OLD.STF_ASSIGNED_WORK_WEEK_HRS_NUM),
                        TO_CHAR(:NEW.STF_ASSIGNED_WORK_WEEK_HRS_NUM));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_BILINGUAL_NON_IMP_IND',
                        TO_CHAR(:OLD.STF_BILINGUAL_NON_IMP_IND),
                        TO_CHAR(:NEW.STF_BILINGUAL_NON_IMP_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_NON_IMPERATIVE_CD',
                        :OLD.STF_NON_IMPERATIVE_CD,
                        :NEW.STF_NON_IMPERATIVE_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_MEDICAL_EXAM_REQ_IND',
                        TO_CHAR(:OLD.STF_MEDICAL_EXAM_REQ_IND),
                        TO_CHAR(:NEW.STF_MEDICAL_EXAM_REQ_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_CANDIDATE_PIN',
                        :OLD.STF_CANDIDATE_PIN,
                        :NEW.STF_CANDIDATE_PIN);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_CANDIDATE_FAMILY_NAME_TXT',
                        :OLD.STF_CANDIDATE_FAMILY_NAME_TXT,
                        :NEW.STF_CANDIDATE_FAMILY_NAME_TXT);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_CANDIDATE_GIVEN_NAME_TXT',
                        :OLD.STF_CANDIDATE_GIVEN_NAME_TXT,
                        :NEW.STF_CANDIDATE_GIVEN_NAME_TXT);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_SLE_RESULT_TXT',
                        :OLD.STF_SLE_RESULT_TXT,
                        :NEW.STF_SLE_RESULT_TXT);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_ASN_START_DATE_DTE',
                        TO_CHAR(:OLD.STF_ASN_START_DATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.STF_ASN_START_DATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_ASN_END_DATE_DTE',
                        TO_CHAR(:OLD.STF_ASN_END_DATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.STF_ASN_END_DATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_ASN_NEW_END_DATE_DTE',
                        TO_CHAR(:OLD.STF_ASN_NEW_END_DATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.STF_ASN_NEW_END_DATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_TENURE_REASON_CD',
                        :OLD.STF_TENURE_REASON_CD,
                        :NEW.STF_TENURE_REASON_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_SELECTION_METHOD_IND',
                        :OLD.STF_SELECTION_METHOD_IND,
                        :NEW.STF_SELECTION_METHOD_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_STAFFING_METHOD_IND',
                        :OLD.STF_STAFFING_METHOD_IND,
                        :NEW.STF_STAFFING_METHOD_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_PROCESS_TXT',
                        :OLD.STF_PROCESS_TXT,
                        :NEW.STF_PROCESS_TXT);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_ASSIGNMENT_TYPE_CODE',
                        :OLD.STF_ASSIGNMENT_TYPE_CODE,
                        :NEW.STF_ASSIGNMENT_TYPE_CODE);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_SAPP_TYPE_CD',
                        :OLD.STF_SAPP_TYPE_CD,
                        :NEW.STF_SAPP_TYPE_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_EMPLOYEE_COST_CODE_TXT',
                        :OLD.STF_EMPLOYEE_COST_CODE_TXT,
                        :NEW.STF_EMPLOYEE_COST_CODE_TXT);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_LAST_UPDATE_BY_USER_ID',
                        :OLD.STF_LAST_UPDATE_BY_USER_ID,
                        :NEW.STF_LAST_UPDATE_BY_USER_ID);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_SECURITY_CLEARANCE_IND',
                        :OLD.STF_SECURITY_CLEARANCE_IND,
                        :NEW.STF_SECURITY_CLEARANCE_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_STUDENT_BRIDGING_IND',
                        TO_CHAR(:OLD.STF_STUDENT_BRIDGING_IND),
                        TO_CHAR(:NEW.STF_STUDENT_BRIDGING_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_ASN_GREATER_4_MTHS_IND',
                        TO_CHAR(:OLD.STF_ASN_GREATER_4_MTHS_IND),
                        TO_CHAR(:NEW.STF_ASN_GREATER_4_MTHS_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_ASN_GREATER_12_MTHS_IND',
                        TO_CHAR(:OLD.STF_ASN_GREATER_12_MTHS_IND),
                        TO_CHAR(:NEW.STF_ASN_GREATER_12_MTHS_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_CLEARANCE_CONFIRM_IND',
                        TO_CHAR(:OLD.STF_CLEARANCE_CONFIRM_IND),
                        TO_CHAR(:NEW.STF_CLEARANCE_CONFIRM_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_TI_PROFILE_CD',
                        :OLD.STF_TI_PROFILE_CD,
                        :NEW.STF_TI_PROFILE_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_DATE_CANDIDATE_BIRTH_DTE',
                        TO_CHAR(:OLD.STF_DATE_CANDIDATE_BIRTH_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.STF_DATE_CANDIDATE_BIRTH_DTE,
                                'DD-MON-YYYY HH:MI:SS am'));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_HRSR_WORK_HOURS_CD',
                        :OLD.STF_HRSR_WORK_HOURS_CD,
                        :NEW.STF_HRSR_WORK_HOURS_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_ALL_CONDITIONS_MET_IND',
                        TO_CHAR(:OLD.STF_ALL_CONDITIONS_MET_IND),
                        TO_CHAR(:NEW.STF_ALL_CONDITIONS_MET_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_CANDIDATE_INITIAL_NAME_TXT',
                        :OLD.STF_CANDIDATE_INITIAL_NAME_TXT,
                        :NEW.STF_CANDIDATE_INITIAL_NAME_TXT);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_PREFERRED_LANGUAGE_CD',
                        :OLD.STF_PREFERRED_LANGUAGE_CD,
                        :NEW.STF_PREFERRED_LANGUAGE_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_LETTER_OF_OFFER_RDIMS_NBR',
                        TO_CHAR(:OLD.STF_LETTER_OF_OFFER_RDIMS_NBR),
                        TO_CHAR(:NEW.STF_LETTER_OF_OFFER_RDIMS_NBR));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_UNDERFILL_GROUP_IND',
                        :OLD.STF_UNDERFILL_GROUP_IND,
                        :NEW.STF_UNDERFILL_GROUP_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_UNDERFILL_SUBGROUP_IND',
                        :OLD.STF_UNDERFILL_SUBGROUP_IND,
                        :NEW.STF_UNDERFILL_SUBGROUP_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_UNDERFILL_LEVEL_IND',
                        :OLD.STF_UNDERFILL_LEVEL_IND,
                        :NEW.STF_UNDERFILL_LEVEL_IND);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_DISCLAIMER_CONFIRM_IND',
                        TO_CHAR(:OLD.STF_DISCLAIMER_CONFIRM_IND),
                        TO_CHAR(:NEW.STF_DISCLAIMER_CONFIRM_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_END_AT_LEVEL_ACTING_IND',
                        TO_CHAR(:OLD.STF_END_AT_LEVEL_ACTING_IND),
                        TO_CHAR(:NEW.STF_END_AT_LEVEL_ACTING_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_OATH_DTE',
                        TO_CHAR(:OLD.STF_OATH_DTE,'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.STF_OATH_DTE,'DD-MON-YYYY HH:MI:SS am'));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_LANGUAGE_REQ_MET_IND',
                        TO_CHAR(:OLD.STF_LANGUAGE_REQ_MET_IND),
                        TO_CHAR(:NEW.STF_LANGUAGE_REQ_MET_IND));                        
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'STF_DATE_LOO_SIGNED_DTE',
                        TO_CHAR(:OLD.STF_DATE_LOO_SIGNED_DTE,'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.STF_DATE_LOO_SIGNED_DTE,'DD-MON-YYYY HH:MI:SS am'));                                               
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


-- End of DDL Script for Trigger TIPS.AH029_TG1_BIUD_AUDIT

