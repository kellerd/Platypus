-- Start of DDL Script for Procedure TIPS.SP_VALIDATE_PT_HOURS_SCHEDULER
-- Generated 2019-09-17 3:11:03 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE sp_validate_pt_hours_scheduler
  ( v_hrsr_request_cd         ah029_hrsr_staffing.stf_hrsr_request_cd%TYPE,
    v_error_num          OUT  th191_hrsr_error_message.hrsr_error_message_num%TYPE,
    v_error_message_etxt OUT  VARCHAR2,
    v_error_message_ftxt OUT  VARCHAR2
  )
IS
--
-- Purpose: Procedure to validate the part time hours scheduler against the
--          assigned work week hours of the HRSR.
--
--   Return value: Success = 0
--                 Unsuccessful = Error message number and text
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--

   v_pt_total_hrs_num   ah029_hrsr_staffing.stf_assigned_work_week_hrs_num%TYPE;

BEGIN

  FOR part_time_hrsr IN (
      SELECT NVL(stf_assigned_work_week_hrs_num,0) AS stf_assigned_work_week_hrs_num,
             stf_hrsr_work_hours_cd
        FROM ah029_hrsr_staffing
       WHERE stf_hrsr_request_cd = v_hrsr_request_cd
         AND (stf_hrsr_work_hours_cd IS NULL OR 
              stf_hrsr_work_hours_cd = 'PT') -- Part Time
  ) LOOP

    -- Get the total number of hours in the 2 week part time hours scheduler FOR
    -- this HRSR:
    SELECT NVL(MAX(
               NVL(monday1_hours_num,0) +
               NVL(tuesday1_hours_num,0) +
               NVL(wednesday1_hours_num,0) +
               NVL(thursday1_hours_num,0) +
               NVL(friday1_hours_num,0) +
               NVL(saturday1_hours_num,0) +
               NVL(sunday1_hours_num,0) +
               NVL(monday2_hours_num,0) +
               NVL(tuesday2_hours_num,0) +
               NVL(wednesday2_hours_num,0) +
               NVL(thursday2_hours_num,0) +
               NVL(friday2_hours_num,0) +
               NVL(saturday2_hours_num,0) +
               NVL(sunday2_hours_num,0)),0)
      INTO v_pt_total_hrs_num
      FROM ah101_hrsr_pt_hour_schedule
     WHERE hrsr_request_cd = v_hrsr_request_cd;

    -- Missing Hours of Work Code
    IF part_time_hrsr.stf_hrsr_work_hours_cd IS NULL THEN
       v_error_num := 40;
       v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(40)||' <BR> ';
       v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(40)||' <BR> ';
    END IF;

    -- Missing Assigned Work Week Hours:
    IF part_time_hrsr.stf_assigned_work_week_hrs_num IS NULL THEN
       v_error_num := 47;
       v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(47)||' <BR> ';
       v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(47)||' <BR> ';
    END IF;

    -- No part time hours scheduler
    IF v_pt_total_hrs_num = 0 THEN
       v_error_num := 45;
       v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(45)||' <BR> ';
       v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(45)||' <BR> ';
    END IF;

    -- Part time hours scheduler does not match the assigned work week hours:
    IF v_pt_total_hrs_num != 0 AND
       v_pt_total_hrs_num != (part_time_hrsr.stf_assigned_work_week_hrs_num * 2)  THEN
       v_error_num := 46;
       v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(46)||' <BR> ';
       v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(46)||' <BR> ';
    END IF;

  END LOOP;

  IF v_error_num IS NULL THEN
     -- Set return message to Success:
     v_error_num := 0;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(0);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(0);
  END IF;


EXCEPTION
   WHEN OTHERS THEN
     -- Return Unknown Error:
     v_error_num := 999;
     v_error_message_etxt := 'Error '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
     v_error_message_ftxt := 'Error '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
     RETURN ;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM SP_VALIDATE_PT_HOURS_SCHEDULER
  FOR SP_VALIDATE_PT_HOURS_SCHEDULER;
  
GRANT EXECUTE ON SP_VALIDATE_PT_HOURS_SCHEDULER TO tipsuser;
GRANT EXECUTE ON SP_VALIDATE_PT_HOURS_SCHEDULER TO everything_in_tips;
  

-- End of DDL Script for Procedure TIPS.SP_VALIDATE_PT_HOURS_SCHEDULER

