-- Start of DDL Script for Trigger TIPS.AH027_TG1_BIUD_AUDIT
-- Generated 2019-11-19 9:05:14 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER AH027_TG1_BIUD_AUDIT
 BEFORE 
 INSERT OR DELETE OR UPDATE
 ON AH027_HRSR_REQUEST
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, July 24 2008
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- Hynes, J.  15-JAN-19  HRSR 2.0: Added column RQT_ASSIGNED_TO_PIN and added
--                       code to populate it. Trigger on 
--                       AH035_HRSR_REQUEST_HISTORY will also update column when
--                       HRSR_STATUS_CD = 1 as RQH_WORKFLOW_ACTION_CD changes.
--
-- Hynes, J.  12-AUG-10  HRSR_DSRH-01519: Added column RQT_EX_PROCESS_IND
--
-- Hynes, J.  07-OCT-09  HRSR_DSRH-01436: Removed column RQT_CASE_NMBR
--
   v_audit_id                audit_master.aum_audit_row_id%TYPE;
   v_event_id                audit_master.aum_event_id%TYPE;
   v_event_ind               audit_master.aum_event_ind%TYPE;
   v_event_datetime          audit_master.aum_event_datetime%TYPE := SYSDATE;
   v_count                   INTEGER;
BEGIN

  IF UPDATING THEN
     v_event_ind := 'U';
     v_audit_id := :OLD.RQT_AUDIT_ROW_ID;
  ELSIF DELETING THEN
     v_event_ind := 'D';
     v_audit_id := :OLD.RQT_AUDIT_ROW_ID;
  ELSE
  -- INSERTING
    SELECT LPAD(TO_CHAR(audit_row_id_seq.NEXTVAL),20,'0')
      INTO :NEW.RQT_AUDIT_ROW_ID
      FROM DUAL;
    v_event_ind := 'I';
    v_audit_id := :NEW.RQT_AUDIT_ROW_ID;
  END IF;
  SELECT LPAD(TO_CHAR(audit_event_id_seq.NEXTVAL),20,'0')
    INTO v_event_id
    FROM dual;

  IF INSERTING OR UPDATING THEN
     :NEW.RQT_LAST_UPDATE_DTE := SYSDATE;
     :NEW.RQT_LAST_UPDATE_BY_USER_ID := FN_GET_USER;
  END IF;

  -- For HRSR 2.0: Set the EX Process flag dynamically:
  
  IF :NEW.RQT_ACTION_CD >= 26 AND  -- New HRSR 2.0 Codes
     UPDATING AND
     :OLD.RQT_POSITION_NMBR IS NOT NULL AND
     :NEW.RQT_POSITION_NMBR IS NULL THEN
     
     -- Reset the ex process flag when position number is removed.
     :NEW.RQT_EX_PROCESS_IND := 0;
      
  ELSIF :NEW.RQT_ACTION_CD >= 26 AND  -- New HRSR 2.0 Codes
     ((INSERTING AND :NEW.RQT_POSITION_NMBR IS NOT NULL) OR
      (UPDATING AND :NEW.RQT_POSITION_NMBR !=
       NVL(:OLD.RQT_POSITION_NMBR,'NULL'))) THEN

      SELECT DECODE(COUNT(*),0,0,1)
        INTO :NEW.RQT_EX_PROCESS_IND
        FROM positions
       WHERE pos_position_nmbr = :NEW.rqt_position_nmbr
         AND pos_group_ind IN ('EX','DM','OC');
   END IF;

  -- Change the Assigned To if there's a change in Status:
  
  -- HRSR 1.0 CODES:
  IF :NEW.RQT_ACTION_CD < 26 THEN
     IF INSERTING OR
        (UPDATING AND :NEW.RQT_HRSR_STATUS_CD != :OLD.RQT_HRSR_STATUS_CD)  THEN
     
        IF :NEW.RQT_HRSR_STATUS_CD IN ('2','3','4','5','6','0') THEN
           :NEW.RQT_ASSIGNED_TO_PIN := :NEW.RQT_ADVISOR_PIN;
        
        ELSIF :NEW.RQT_HRSR_STATUS_CD = '1' THEN
          -- Trigger on AH035_HRSR_REQUEST_HISTORY will also update when
          -- HRSR_STATUS_CD = 1 as RQH_WORKFLOW_ACTION_CD changes.
           :NEW.RQT_ASSIGNED_TO_PIN := :NEW.RQT_INITIATOR_PIN;
           
        ELSE
           :NEW.RQT_ASSIGNED_TO_PIN := :NEW.RQT_INITIATOR_PIN;
        END IF;
     END IF;
  END IF;

  -- New HRSR 2.0 codes:
  -- New codes will have the assigned to based on the actor code instead of
  -- status
  IF :NEW.RQT_ACTION_CD >= 26 THEN
     IF :NEW.RQT_HRSR_ACTOR_CD = '1' AND
        NVL(:OLD.RQT_HRSR_ACTOR_CD,'NULL') != :NEW.RQT_HRSR_ACTOR_CD THEN
         -- Set the Assigned to PIN to the new Initiator PIN:
        :NEW.RQT_ASSIGNED_TO_PIN := :NEW.RQT_INITIATOR_PIN;

     ELSIF :NEW.RQT_HRSR_ACTOR_CD = '2' AND
        NVL(:OLD.RQT_HRSR_ACTOR_CD,'NULL') != :NEW.RQT_HRSR_ACTOR_CD THEN
        -- Set the Assigned to PIN to the new Recommender PIN:
        :NEW.RQT_ASSIGNED_TO_PIN := :NEW.RQT_RECOMMENDER_PIN;
        
     ELSIF :NEW.RQT_HRSR_ACTOR_CD = '3' AND
        NVL(:OLD.RQT_HRSR_ACTOR_CD,'NULL') != :NEW.RQT_HRSR_ACTOR_CD THEN
        -- Set the Assigned to PIN to the new Approver PIN:
        :NEW.RQT_ASSIGNED_TO_PIN := :NEW.RQT_APPROVER_PIN;
     
     ELSIF :NEW.RQT_HRSR_ACTOR_CD = '4' AND
        NVL(:OLD.RQT_HRSR_ACTOR_CD,'NULL') != :NEW.RQT_HRSR_ACTOR_CD THEN
        -- Set the Assigned to PIN to the HR Triage User:
       :NEW.RQT_ASSIGNED_TO_PIN := '000000023';
       
     END IF;
  
  END IF;
  
  -- Change the Assigned To if there's a change in Actor PRI and the HRSR is
  -- currently assigned to the Actor:
  -- 1  Initiator
  -- 2  Recommender
  -- 3  Approver
  -- 4  HR Advisor
  IF UPDATING AND
     :NEW.RQT_INITIATOR_PIN != :OLD.RQT_INITIATOR_PIN AND
     :OLD.RQT_INITIATOR_PIN = :OLD.RQT_ASSIGNED_TO_PIN AND
     :NEW.RQT_HRSR_ACTOR_CD = '1' THEN
     -- Set the Assigned to PIN to the new Initiator PIN:
     :NEW.RQT_ASSIGNED_TO_PIN := :NEW.RQT_INITIATOR_PIN;
     
  ELSIF UPDATING AND
     :NEW.RQT_RECOMMENDER_PIN != :OLD.RQT_RECOMMENDER_PIN AND
     :OLD.RQT_RECOMMENDER_PIN = :OLD.RQT_ASSIGNED_TO_PIN AND
     :NEW.RQT_HRSR_ACTOR_CD = '2' THEN
     -- Set the Assigned to PIN to the new Recommender PIN:
     :NEW.RQT_ASSIGNED_TO_PIN := :NEW.RQT_RECOMMENDER_PIN;
     
  ELSIF UPDATING AND
     :NEW.RQT_APPROVER_PIN != :OLD.RQT_APPROVER_PIN AND
     :OLD.RQT_APPROVER_PIN = :OLD.RQT_ASSIGNED_TO_PIN AND
     :NEW.RQT_HRSR_ACTOR_CD = '3' THEN
     -- Set the Assigned to PIN to the new Approver PIN:
     :NEW.RQT_ASSIGNED_TO_PIN := :NEW.RQT_APPROVER_PIN;

  ELSIF UPDATING AND
     :NEW.RQT_ADVISOR_PIN != :OLD.RQT_ADVISOR_PIN AND
     :OLD.RQT_ADVISOR_PIN = :OLD.RQT_ASSIGNED_TO_PIN AND
     :NEW.RQT_HRSR_ACTOR_CD = '4' THEN
     -- Set the Assigned to PIN to the new HR Advisor PIN:
     :NEW.RQT_ASSIGNED_TO_PIN := :NEW.RQT_ADVISOR_PIN;

  END IF;

  -- UPDATE the audit_master table using the audit_master_web_update procedure
  AUDIT_MASTER_UPDATE (v_event_id,
                       v_audit_id,
                       v_event_datetime,
                       v_event_ind,
                       'AH027_HRSR_REQUEST');
  -- ADD a record to the audit_details table for each column changed
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_HRSR_REQUEST_CD',
                        :OLD.RQT_HRSR_REQUEST_CD,
                        :NEW.RQT_HRSR_REQUEST_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_ACTION_CD',
                        :OLD.RQT_ACTION_CD,
                        :NEW.RQT_ACTION_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_HRSR_STATUS_CD',
                        :OLD.RQT_HRSR_STATUS_CD,
                        :NEW.RQT_HRSR_STATUS_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_HRSR_ACTOR_CD',
                        :OLD.RQT_HRSR_ACTOR_CD,
                        :NEW.RQT_HRSR_ACTOR_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_INITIATOR_PIN',
                        :OLD.RQT_INITIATOR_PIN,
                        :NEW.RQT_INITIATOR_PIN);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_RECOMMENDER_PIN',
                        :OLD.RQT_RECOMMENDER_PIN,
                        :NEW.RQT_RECOMMENDER_PIN);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_APPROVER_PIN',
                        :OLD.RQT_APPROVER_PIN,
                        :NEW.RQT_APPROVER_PIN);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_ADVISOR_PIN',
                        :OLD.RQT_ADVISOR_PIN,
                        :NEW.RQT_ADVISOR_PIN);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_POSITION_NMBR',
                        :OLD.RQT_POSITION_NMBR,
                        :NEW.RQT_POSITION_NMBR);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_DATE_EFFECTIVE_DTE',
                        TO_CHAR(:OLD.RQT_DATE_EFFECTIVE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.RQT_DATE_EFFECTIVE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_PRIORITY_NUM',
                        TO_CHAR(:OLD.RQT_PRIORITY_NUM),
                        TO_CHAR(:NEW.RQT_PRIORITY_NUM));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_LAST_UPDATE_BY_USER_ID',
                        :OLD.RQT_LAST_UPDATE_BY_USER_ID,
                        :NEW.RQT_LAST_UPDATE_BY_USER_ID);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_LAST_UPDATE_DTE',
                        TO_CHAR(:OLD.RQT_LAST_UPDATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.RQT_LAST_UPDATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_EX_PROCESS_IND',
                        TO_CHAR(:OLD.RQT_EX_PROCESS_IND),
                        TO_CHAR(:NEW.RQT_EX_PROCESS_IND));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_ASSIGNED_TO_PIN',
                        :OLD.RQT_ASSIGNED_TO_PIN,
                        :NEW.RQT_ASSIGNED_TO_PIN);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQT_ALT_ADVISOR_PIN',
                        :OLD.RQT_ALT_ADVISOR_PIN,
                        :NEW.RQT_ALT_ADVISOR_PIN);
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


-- End of DDL Script for Trigger TIPS.AH027_TG1_BIUD_AUDIT

