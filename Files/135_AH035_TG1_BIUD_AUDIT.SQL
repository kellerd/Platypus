-- Start of DDL Script for Trigger TIPS.AH035_TG1_BIUD_AUDIT
-- Generated 26-Jun-19 16:26:57 from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER AH035_TG1_BIUD_AUDIT
 BEFORE 
 INSERT OR DELETE OR UPDATE
 ON AH035_HRSR_REQUEST_HISTORY
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, July 24 2008
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- Hynes, J.  26-JUN-19  HRSR 2.0: Added new workflow 15, returned to Approver.
--
-- Hynes, J.  15-JAN-19  HRSR 2.0: Added code to populate AH027_HRSR_REQUEST
--                       RQT_ASSIGNED_TO_PIN when RQH_WORKFLOW_ACTION_CD IN 2,3,
--                       6,7.
--
-- Hu, H.    14-DEC-12   CR HRSR_DSRH-01735 modified to only calulate status code
--                       changing from 13 to 14)
--
-- Hu, H.    18-SEP-12   CR HRSR_DSRH-01735 calculate the number of days between
--                       status 13 and 14. The solution calculates days between
--                       any status change (not only 13 and 14)
--
-- Hynes, J. 19-JAN-09   SATS Release 1.0.0: Added column RQH_DATE_EFFECTIVE_DTE
--
   v_audit_id                audit_master.aum_audit_row_id%TYPE;
   v_event_id                audit_master.aum_event_id%TYPE;
   v_event_ind               audit_master.aum_event_ind%TYPE;
   v_event_datetime          audit_master.aum_event_datetime%TYPE := SYSDATE;
   v_count                   INTEGER;
   v_last_action_date        DATE;
BEGIN
  IF UPDATING THEN
     v_event_ind := 'U';
     v_audit_id := :OLD.RQH_AUDIT_ROW_ID;
  ELSIF DELETING THEN
     v_event_ind := 'D';
     v_audit_id := :OLD.RQH_AUDIT_ROW_ID;
  ELSE
  -- INSERTING
    SELECT LPAD(TO_CHAR(audit_row_id_seq.NEXTVAL),20,'0'),
           AH035_SQ1_RQH_ID.NEXTVAL
      INTO :NEW.RQH_AUDIT_ROW_ID,
           :NEW.RQH_ID
      FROM DUAL;
    v_event_ind := 'I';
    v_audit_id := :NEW.RQH_AUDIT_ROW_ID;
    
  IF :NEW.RQH_WORKFLOW_ACTION_CD IN ('3', '15') THEN
  
     UPDATE ah027_hrsr_request ah027
        SET rqt_assigned_to_pin = rqt_approver_pin
      WHERE rqt_hrsr_status_cd = '1'
        AND :NEW.rqh_hrsr_request_cd = rqt_hrsr_request_cd; 
        
  ELSIF :NEW.RQH_WORKFLOW_ACTION_CD IN ('6') THEN
  
     UPDATE ah027_hrsr_request ah027
        SET rqt_assigned_to_pin = rqt_initiator_pin
      WHERE rqt_hrsr_status_cd = '1'
        AND :NEW.rqh_hrsr_request_cd = rqt_hrsr_request_cd;         
  
  ELSIF :NEW.RQH_WORKFLOW_ACTION_CD IN ('2', '7') THEN
  
     UPDATE ah027_hrsr_request ah027
        SET rqt_assigned_to_pin = rqt_recommender_pin
      WHERE rqt_hrsr_status_cd = '1'
        AND :NEW.rqh_hrsr_request_cd = rqt_hrsr_request_cd; 
          
  ELSIF :NEW.RQH_WORKFLOW_ACTION_CD = '14' THEN
    --CR HRSR_DSRH-01735 calculate the number of days between status 13 and 14
    
    SELECT rqh_date_effective_dte
      INTO v_last_action_date
      FROM ah035_hrsr_request_history
     WHERE rqh_hrsr_request_cd = :NEW.rqh_hrsr_request_cd
       AND rqh_workflow_action_cd = '13'
       AND rqh_last_update_dte = (SELECT MAX(rqh_last_update_dte)
                                    FROM ah035_hrsr_request_history
                                   WHERE rqh_hrsr_request_cd = 
                                         :NEW.rqh_hrsr_request_cd);

    IF v_last_action_date IS NULL THEN --no previous record
        :NEW.rqh_calendar_days_nbr:=0;
        :NEW.rqh_working_days_nbr:=0;
    ELSE
        :NEW.rqh_calendar_days_nbr:=TRUNC(:NEW.rqh_date_effective_dte)-TRUNC(v_last_action_date);
        :NEW.rqh_working_days_nbr:= :NEW.rqh_calendar_days_nbr
              - get_user_days_weekend_stats( FN_GET_USER,
                                             TRUNC(v_last_action_date),
                                             TRUNC(:NEW.rqh_date_effective_dte));
    END IF;
    --END CR HRSR_DSRH-01735
   END IF;
  END IF;

  IF INSERTING OR UPDATING THEN
     :NEW.RQH_LAST_UPDATE_DTE := SYSDATE;
     :NEW.RQH_LAST_UPDATE_BY_USER_ID := FN_GET_USER;
  END IF;

  SELECT LPAD(TO_CHAR(audit_event_id_seq.NEXTVAL),20,'0')
    INTO v_event_id
    FROM dual;

  -- UPDATE the audit_master table using the audit_master_web_update procedure
  AUDIT_MASTER_UPDATE (v_event_id,
                       v_audit_id,
                       v_event_datetime,
                       v_event_ind,
                       'AH035_HRSR_REQUEST_HISTORY');
  -- ADD a record to the audit_details table for each column changed
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQH_ID',
                        TO_CHAR(:OLD.RQH_ID),
                        TO_CHAR(:NEW.RQH_ID));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQH_HRSR_REQUEST_CD',
                        :OLD.RQH_HRSR_REQUEST_CD,
                        :NEW.RQH_HRSR_REQUEST_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQH_WORKFLOW_ACTION_CD',
                        :OLD.RQH_WORKFLOW_ACTION_CD,
                        :NEW.RQH_WORKFLOW_ACTION_CD);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQH_LAST_UPDATE_BY_USER_ID',
                        :OLD.RQH_LAST_UPDATE_BY_USER_ID,
                        :NEW.RQH_LAST_UPDATE_BY_USER_ID);
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQH_LAST_UPDATE_DTE',
                        TO_CHAR(:OLD.RQH_LAST_UPDATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.RQH_LAST_UPDATE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'));
  AUDIT_DETAILS_UPDATE (v_event_id,
                        v_audit_id,
                        v_event_datetime,
                        'RQH_DATE_EFFECTIVE_DTE',
                        TO_CHAR(:OLD.RQH_DATE_EFFECTIVE_DTE,
                                'DD-MON-YYYY HH:MI:SS am'),
                        TO_CHAR(:NEW.RQH_DATE_EFFECTIVE_DTE,
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


-- End of DDL Script for Trigger TIPS.AH035_TG1_BIUD_AUDIT

