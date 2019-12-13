-- Start of DDL Script for Procedure TIPS.HRSR_CAF_UPDATE_CLOSE_REQUEST
-- Generated 2019-05-08 7:45:22 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE hrsr_caf_update_close_request
 ( v_hrsr_request_cd ah067_xref_ah027_caf.rcf_hrsr_request_cd%TYPE,
   v_user_id         ah035_hrsr_request_history.rqh_last_update_by_user_id%TYPE,
   v_return_nmbr     OUT NUMBER
 )
IS
-- Created by: Jennifer Hynes, November 9, 2009
--
-- Purpose: Called by Staffing, Classification and Official Languages each time
--          a case file has a status updated to Closed (2), Cancelled (3) or
--          Rejected (5).
--
--          This procedure will check the status of the case files associated
--          with the HRSR Request, and update the HRSR Request where necessary
--
--          Created as per requirements of HRSR_DSRH-01436, Release 11.12.0
--
--          Return values:
--          1 = Successful
--          0 = Unsuccessful
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
-- Hynes, J.  08-MAY-19  HRSR 2.0: Only check the non-Pay case files. Pay case
--                       files will now be logged in AH067, however at the time
--                       of the procedure call, they can remain open.
--
   v_caf_total_count        INTEGER;
   v_caf_completed_count    INTEGER;
   v_caf_rejected_count     INTEGER;
   v_case_status_ind        case_files.caf_case_status_ind%TYPE;

BEGIN

  -- Determine the total number of case files for this HRSR Request, as well as
  -- the total number Rejected:
  SELECT MIN(DECODE(caf_case_status_ind,'2','2','3','3','5','5',NULL)),
         COUNT(caf_case_status_ind),
         SUM(DECODE(caf_case_status_ind,'2',1,'3',1,'5',1, 0)),
         SUM(DECODE(caf_case_status_ind,'5',1,0))
    INTO v_case_status_ind,
         v_caf_total_count,
         v_caf_completed_count,
         v_caf_rejected_count
    FROM case_files
   WHERE caf_category_ind != 'PAY' -- Exclude Pay case files, which remain open
     AND caf_case_nmbr IN (SELECT rcf_case_file_nmbr
                             FROM ah067_xref_ah027_caf
                            WHERE rcf_hrsr_request_cd = v_hrsr_request_cd);

  -- If all of the case files have been completed, process the HRSR Status.
  -- If not, do nothing.
  IF v_caf_total_count = v_caf_completed_count THEN
     -- All case files have been completed:

     -- Closed Case Files:
     IF v_case_status_ind = '2' THEN

        UPDATE ah027_hrsr_request
           SET rqt_hrsr_status_cd = '6' --(Complete)
         WHERE rqt_hrsr_request_cd = v_hrsr_request_cd;

        INSERT INTO ah035_hrsr_request_history
                  ( rqh_hrsr_request_cd,
                    rqh_workflow_action_cd,
                    rqh_last_update_by_user_id,
                    rqh_last_update_dte)
           VALUES ( v_hrsr_request_cd,
                    '9',   -- Complete
                    v_user_id,
                    SYSDATE );

     -- Cancelled Case Files:
     ELSIF v_case_status_ind = '3' THEN

        UPDATE ah027_hrsr_request
           SET rqt_hrsr_status_cd = '8' --(Cancelled)
         WHERE rqt_hrsr_request_cd = v_hrsr_request_cd;

        INSERT INTO ah035_hrsr_request_history
                  ( rqh_hrsr_request_cd,
                    rqh_workflow_action_cd,
                    rqh_last_update_by_user_id,
                    rqh_last_update_dte )
           VALUES ( v_hrsr_request_cd,
                    '11',   -- Cancelled
                    v_user_id,
                    SYSDATE );

     -- ELSE (all case files have status of 5 REJECTED) then
     ELSIF v_case_status_ind = '5' THEN

        IF v_caf_total_count = v_caf_rejected_count THEN
        -- All case files have been Rejected for this HRSR, therefore the
        -- overall Request can be Rejected:

           UPDATE ah027_hrsr_request
              SET rqt_hrsr_status_cd = '7' --(Rejected)
            WHERE rqt_hrsr_request_cd = v_hrsr_request_cd;

           INSERT INTO ah035_hrsr_request_history
                     ( rqh_hrsr_request_cd,
                       rqh_workflow_action_cd,
                       rqh_last_update_by_user_id,
                       rqh_last_update_dte )
              VALUES ( v_hrsr_request_cd,
                       '10',   -- Rejected
                       v_user_id,
                       SYSDATE );
        END IF;
     END IF;
     COMMIT;
  END IF;
  v_return_nmbr := 1; -- Success
EXCEPTION
  WHEN OTHERS THEN
  v_return_nmbr := 0; -- Failure
  ROLLBACK;
END;
/

-- End of DDL Script for Procedure TIPS.HRSR_CAF_UPDATE_CLOSE_REQUEST

