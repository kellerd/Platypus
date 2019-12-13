-- Start of DDL Script for Trigger TIPS.AH027_TG1_AIUD_LOG
-- Generated 8-Nov-19 6:41:20 from TIPS@TIPSD.WORLD

CREATE OR REPLACE TRIGGER AH027_TG1_AIUD_LOG
 AFTER 
 INSERT OR DELETE OR UPDATE
 ON AH027_HRSR_REQUEST
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
DECLARE
-- Written by Jennifer Hynes, December 12 2012
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- Hynes, J.  08-JUN-19  HRSR 2.0: Populate AH107_HRSR_PROGRESS_TRACKER with
--                       milestone data on changes to actor or status.
--
BEGIN

  -- MILESTONE progress tracking
  -- Write a record to AH107_HRSR_PROGRESS_TRACKER for changes to Status or Actor:
  
  -- Summary Milestones:
  IF INSERTING THEN
     -- HRSR Created
     INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                 (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
          VALUES (:NEW.rqt_hrsr_request_cd, 'NEW', SYSDATE);
  END IF;

  -- LOG ANY CHANGES IN STATUS:
  IF UPDATING AND
     NVL(:OLD.RQT_HRSR_STATUS_CD,'OLD') != :NEW.RQT_HRSR_STATUS_CD THEN

     IF :NEW.RQT_HRSR_STATUS_CD = '4' THEN -- Approved
        -- HRSR Approved by Manager
        INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                    (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
             VALUES (:NEW.rqt_hrsr_request_cd, 'APP', SYSDATE);
             
     ELSIF :NEW.RQT_HRSR_STATUS_CD = '5' THEN -- Withdrawn
        -- HRSR Withdrawn
        INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                    (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
             VALUES (:NEW.rqt_hrsr_request_cd, 'WTD', SYSDATE);
          
     ELSIF :NEW.RQT_HRSR_STATUS_CD = '6' THEN -- Completed
        -- HRSR Completed
        INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                    (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
             VALUES (:NEW.rqt_hrsr_request_cd, 'COM', SYSDATE);
             
     ELSIF :NEW.RQT_HRSR_STATUS_CD = '8' THEN -- Cancelled
        -- HRSR Cancelled
        INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                    (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
             VALUES (:NEW.rqt_hrsr_request_cd, 'CNC', SYSDATE);
     END IF;
  END IF;

  -- LOG ANY CHANGES IN ACTOR:
  -- Check if there's been a change in Actor (ie: assigned or reassigned) and
  -- log the change
  
  -- ACTOR = INITIATOR (1):
  -- Assigned to Initiator
  IF (INSERTING OR UPDATING) AND :OLD.RQT_HRSR_ACTOR_CD IS NULL AND
     :NEW.RQT_HRSR_ACTOR_CD = '1' THEN
     INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                 (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
          VALUES (:NEW.rqt_hrsr_request_cd, 'INT', SYSDATE);

  -- Reassigned back to Initiator
  ELSIF :OLD.RQT_HRSR_ACTOR_CD != :NEW.RQT_HRSR_ACTOR_CD AND
    :OLD.RQT_HRSR_ACTOR_CD != '1' AND
    :NEW.RQT_HRSR_ACTOR_CD = '1' THEN
    INSERT INTO AH107_HRSR_PROGRESS_TRACKER
               (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
        VALUES (:NEW.rqt_hrsr_request_cd, 'RIN', SYSDATE);
  END IF;
  
  -- ACTOR = RECOMMENDER (2):
  -- Assigned to Recommender
  IF UPDATING AND :OLD.RQT_HRSR_ACTOR_CD != :NEW.RQT_HRSR_ACTOR_CD AND
     :NEW.RQT_HRSR_ACTOR_CD = '2' AND
     :OLD.RQT_HRSR_ACTOR_CD = '1' THEN
     INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
         VALUES (:NEW.rqt_hrsr_request_cd, 'REC', SYSDATE);

  -- Reassigned to Recommender (from any actor other than initiator)
  ELSIF UPDATING AND :OLD.RQT_HRSR_ACTOR_CD != :NEW.RQT_HRSR_ACTOR_CD AND
     :NEW.RQT_HRSR_ACTOR_CD = '2' AND
     :OLD.RQT_HRSR_ACTOR_CD != '1' THEN
     INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
         VALUES (:NEW.rqt_hrsr_request_cd, 'RRC', SYSDATE);
  END IF;
  
  -- ACTOR = APPROVER (3):
  -- Assigned to Approver
  IF UPDATING AND :OLD.RQT_HRSR_ACTOR_CD != :NEW.RQT_HRSR_ACTOR_CD AND
     :NEW.RQT_HRSR_ACTOR_CD = '3' AND
     :OLD.RQT_HRSR_ACTOR_CD IN ('1','2') THEN
     -- From Initator or Recommender
     INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
         VALUES (:NEW.rqt_hrsr_request_cd, 'APR', SYSDATE);

  -- Reassigned to Approver
  ELSIF UPDATING AND :OLD.RQT_HRSR_ACTOR_CD != :NEW.RQT_HRSR_ACTOR_CD AND
     :NEW.RQT_HRSR_ACTOR_CD = '3' AND
     :OLD.RQT_HRSR_ACTOR_CD NOT IN ('1', '2', '3') THEN
     INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
         VALUES (:NEW.rqt_hrsr_request_cd, 'RAP', SYSDATE);
  END IF;
  
  -- ACTOR = HR (4):
  -- Assigned to HR can be based on changes to the RQT_ADVISOR_PIN or changes to
  -- RQT_ASSIGNED_TO_PIN:
  
  IF UPDATING AND :OLD.RQT_HRSR_ACTOR_CD != :NEW.RQT_HRSR_ACTOR_CD AND
     :NEW.RQT_HRSR_ACTOR_CD = '4' THEN
     -- Assigned to HR:
     INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
         VALUES (:NEW.rqt_hrsr_request_cd, 'HR', SYSDATE);
  END IF;
  
  -- ASSIGNED TO SPECIFIC HR USER:
  
  -- Assigned to HR Triage:
  IF UPDATING AND :NEW.RQT_HRSR_ACTOR_CD = '4' AND
     :OLD.RQT_HRSR_ACTOR_CD != :NEW.RQT_HRSR_ACTOR_CD THEN
      INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                 (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
          VALUES (:NEW.rqt_hrsr_request_cd, 'HRT', SYSDATE);
          
   ELSIF UPDATING AND :NEW.RQT_HRSR_ACTOR_CD = '4' AND
     :OLD.RQT_HRSR_ACTOR_CD = :NEW.RQT_HRSR_ACTOR_CD AND
     -- HR Advisor has changed has changed to HR Triage:
     ((NVL(:OLD.RQT_ADVISOR_PIN,'NULL') != :NEW.RQT_ADVISOR_PIN AND
      :NEW.RQT_ADVISOR_PIN = '000000023') OR
     -- Assigned To has changed to HR Triage:
     (NVL(:OLD.RQT_ASSIGNED_TO_PIN,'NULL') != :NEW.RQT_ASSIGNED_TO_PIN AND
      :NEW.RQT_ASSIGNED_TO_PIN = '000000023')) THEN
      INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                 (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
          VALUES (:NEW.rqt_hrsr_request_cd, 'HRT', SYSDATE);

   -- Assigned to HR PRI Triage:
   ELSIF UPDATING AND :NEW.RQT_HRSR_ACTOR_CD = '4' AND
     :OLD.RQT_HRSR_ACTOR_CD = :NEW.RQT_HRSR_ACTOR_CD AND
     -- HR Advisor has changed has changed to HR PRI Triage:
     ((NVL(:OLD.RQT_ADVISOR_PIN,'NULL') != :NEW.RQT_ADVISOR_PIN AND
      :NEW.RQT_ADVISOR_PIN = '000000024') OR
     -- Assigned To has changed to HR PRI Triage:
     (NVL(:OLD.RQT_ASSIGNED_TO_PIN,'NULL') != :NEW.RQT_ASSIGNED_TO_PIN AND
      :NEW.RQT_ASSIGNED_TO_PIN = '000000024')) THEN
      INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                 (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
          VALUES (:NEW.rqt_hrsr_request_cd, 'HRP', SYSDATE);

   -- Assigned to specific HR Advisor:
   ELSIF UPDATING AND :NEW.RQT_HRSR_ACTOR_CD = '4' AND
     :OLD.RQT_HRSR_ACTOR_CD = :NEW.RQT_HRSR_ACTOR_CD AND
     -- HR Advisor has changed has changed to specific HR Advisor:
     ((NVL(:OLD.RQT_ADVISOR_PIN,'NULL') != :NEW.RQT_ADVISOR_PIN AND
      :NEW.RQT_ADVISOR_PIN NOT IN ('000000023', '000000024')) OR
     -- Assigned To has changed to specific HR Advisor:
     (NVL(:OLD.RQT_ASSIGNED_TO_PIN,'NULL') != :NEW.RQT_ASSIGNED_TO_PIN AND
      :NEW.RQT_ASSIGNED_TO_PIN NOT IN ('000000023', '000000024'))) THEN
      INSERT INTO AH107_HRSR_PROGRESS_TRACKER
                 (hrsr_request_cd, milestone_cd, date_milestone_met_dte)
          VALUES (:NEW.rqt_hrsr_request_cd, 'HRA', SYSDATE);
               
   END IF;

  -- HRSR 1.0 functionality
  IF (INSERTING OR UPDATING) AND
     NVL(:OLD.RQT_HRSR_STATUS_CD,'NEW') != NVL(:NEW.RQT_HRSR_STATUS_CD,'OLD') THEN
     -- All status changes are to be logged:
     INSERT INTO AH080_HRSR_STATUS_HISTORY
                 (HSH_HRSR_REQUEST_CD,
                  HSH_OLD_HRSR_STATUS_CD,
                  HSH_NEW_HRSR_STATUS_CD)
          VALUES (:NEW.RQT_HRSR_REQUEST_CD,
                  :OLD.RQT_HRSR_STATUS_CD,
                  :NEW.RQT_HRSR_STATUS_CD);
  END IF;
END;
/


-- End of DDL Script for Trigger TIPS.AH027_TG1_AIUD_LOG

