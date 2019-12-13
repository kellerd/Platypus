-- Start of DDL Script for Procedure TIPS.SP_VALIDATE_STUDENT_WARNINGS
-- Generated 2019-09-03 2:23:51 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE SP_VALIDATE_STUDENT_WARNINGS
  ( v_employee_pin            assignments.asn_employee_pin%TYPE,
    v_position_nmbr           assignments.asn_position_nmbr%TYPE,
    v_asn_start_dte           assignments.asn_effective_start_date%TYPE,
    v_asn_end_dte             assignments.asn_effective_end_date%TYPE,
    v_hrsr_request_cd         ah029_hrsr_staffing.stf_hrsr_request_cd%TYPE,
    v_error_num          OUT  th191_hrsr_error_message.hrsr_error_message_num%TYPE,
    v_error_message_etxt OUT  VARCHAR2,
    v_error_message_ftxt OUT  VARCHAR2
  )
IS
--
-- Purpose: Procedure to validate the acting assignment against the employee's
--          substantive assignment, for conditions that will produce a warning,
--          but still allow the acting to continue.
--
--          Checks made:
--          * Check if Start Date or End Date falls on a Weekend
--          * Check if start date or end date falls on a Stat Holiday
--          * Check if another person is acting in this position
--          * Check if the candidate meets the language profile of the position
--
--   Return value: Success = 0
--                 Unsuccessful = Error message text (possibly multiple errors)
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--

BEGIN

  -- Check if Start Date falls on a Weekend:
  IF TRIM(TO_CHAR(v_asn_start_dte, 'DAY')) IN ('SATURDAY','SUNDAY') THEN
     v_error_num := 26;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(26)||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(26)||' <BR> ';
  END IF;

  -- Check if End Date falls on a Weekend:
  IF TRIM(TO_CHAR(v_asn_end_dte, 'DAY')) IN ('SATURDAY','SUNDAY') THEN
     v_error_num := 27;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(27)||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(27)||' <BR> ';
  END IF;

  -- Check if start date or end date falls on a Stat Holiday:
  FOR stat_holiday_rec IN (
      SELECT *
        FROM stat_holidays,
             positions
       WHERE pos_position_nmbr = v_position_nmbr
         AND sth_geo_province_code = SUBSTR(pos_geo_code,1,2)
         AND (TRUNC(v_asn_start_dte) =  TRUNC(sth_holiday_date) OR
              TRUNC(v_asn_end_dte) =  TRUNC(sth_holiday_date))
  ) LOOP

    -- Start date falls on Stat Holiday
    IF TRUNC(v_asn_start_dte) =  TRUNC(stat_holiday_rec.sth_holiday_date) THEN
        v_error_num := 28;
        v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(28)||' <BR> ';
        v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(28)||' <BR> ';
    END IF;

    -- End date falls on Stat Holiday
    IF TRUNC(v_asn_end_dte) =  TRUNC(stat_holiday_rec.sth_holiday_date) THEN
        v_error_num := 29;
        v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(29)||' <BR> ';
        v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(29)||' <BR> ';
    END IF;

  END LOOP;

  -- Check if candidate meets the language profile of the position:
  IF fn_meets_language_profile(v_employee_pin,v_position_nmbr, v_hrsr_request_cd) = 1 THEN
     -- Employee does not have a language profile, but position does:
     v_error_num := 36;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(36)||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(36)||' <BR> ';
  ELSIF fn_meets_language_profile(v_employee_pin,v_position_nmbr, v_hrsr_request_cd) = 2 THEN
     -- Employee does not meet the language requirement of the position:
     v_error_num := 37;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(37)||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(37)||' <BR> ';
  END IF;

  IF v_error_num IS NULL THEN
     -- Success:
     v_error_num := 0;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(0);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(0);
  END IF;

  RETURN;

EXCEPTION
   WHEN OTHERS THEN
     -- Return Unknown Error:
     v_error_num := 999;
     v_error_message_etxt := 'Error '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
     v_error_message_ftxt := 'Error '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
     RETURN ;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM SP_VALIDATE_STUDENT_WARNINGS
  FOR TIPS.SP_VALIDATE_STUDENT_WARNINGS
/  

-- Grants for Procedure
GRANT EXECUTE ON SP_VALIDATE_STUDENT_WARNINGS TO tipsuser
/
GRANT EXECUTE ON SP_VALIDATE_STUDENT_WARNINGS TO everything_in_tips
/


-- End of DDL Script for Procedure TIPS.SP_VALIDATE_STUDENT_WARNINGS



