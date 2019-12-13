-- Start of DDL Script for Procedure TIPS.SP_VALIDATE_STUDENT_ASSIGNMENT
-- Generated 2019-09-03 7:00:22 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE sp_validate_student_assignment
  ( v_employee_pin            assignments.asn_employee_pin%TYPE,
    v_position_nmbr           assignments.asn_position_nmbr%TYPE,
    v_asn_start_dte           assignments.asn_effective_start_date%TYPE,
    v_asn_end_dte             assignments.asn_effective_end_date%TYPE,
    v_hrsr_request_cd         ah029_hrsr_staffing.stf_hrsr_request_cd%TYPE,
    v_error_num          OUT  th191_hrsr_error_message.hrsr_error_message_num%TYPE,
    v_error_message_etxt OUT  th191_hrsr_error_message.hrsr_error_message_etxt%TYPE,
    v_error_message_ftxt OUT  th191_hrsr_error_message.hrsr_error_message_ftxt%TYPE
  )
IS
--
-- Purpose: Procedure to validate the student assignment
--
--          Checks made:
--          * Missing fields
--
--   Return value: Success = 0
--                 Unsuccessful = Error message text with exact error
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--

   v_min_days_acting       agreements.agr_min_days_acting%TYPE;
   v_min_days_acting_sub   agreements.agr_min_days_acting%TYPE;
   v_incumbent_asn_exists  INTEGER := 0;
   v_promotion_txt         VARCHAR2(30);
   v_acting_bud_code_txt   assignments.asn_bud_code%TYPE;
   v_acting_group_ind      assignments.asn_classn_group_ind%TYPE;
   v_acting_subgroup_ind   assignments.asn_classn_subgroup_ind%TYPE;
   v_acting_level_ind      assignments.asn_classn_level_ind%TYPE;
   v_position_count        INTEGER;
   v_province_cd           geographic_locations.gel_geo_province_code%TYPE;
   v_stat_holiday_count    INTEGER;

BEGIN

  IF fn_position_classn_flag(v_position_nmbr, v_hrsr_request_cd) = 2 THEN
     -- The position has been flagged by classifction not to be staffed.
     -- Return error message to user that the user has to contact the
     -- Classification advisor to continue the process.
     v_error_num := 31;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(31);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(31);
     RETURN;
  END IF;

  -- Do basic checks to make sure there is a value in all the variables:
  IF v_asn_start_dte IS NULL THEN
     -- The HRSR is missing data: Start date
     v_error_num := 3;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(3);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(3);
     RETURN;
  ELSIF v_asn_end_dte IS NULL THEN
     -- The HRSR is missing data: End date
     v_error_num := 4;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(4);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(4);
     RETURN;
/*  ELSIF v_employee_pin IS NULL THEN
     -- The HRSR is missing data: Candidate PIN
     v_error_num := 2;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(2);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(2);
     RETURN;
  ELSIF v_position_nmbr IS NULL THEN
     -- The HRSR is missing data: Position Number
     v_error_num := 5;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(5);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(5);
     RETURN;*/
  END IF;


  -- Check if Acting assignment already exists:
  FOR asn_exists IN (
      SELECT *
        FROM assignments
       WHERE asn_employee_pin = v_employee_pin
         AND asn_position_nmbr = v_position_nmbr
         AND TRUNC(asn_effective_start_date) = TRUNC(v_asn_start_dte)
         AND asn_classn_group_ind = v_acting_group_ind
         AND asn_classn_level_ind = v_acting_level_ind
  ) LOOP

     -- An assignment already exists for these HRSR details.
     v_error_num := 10;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(10);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(10);
     RETURN;

  END LOOP;


     -- Success, no errors found:
     v_error_num := 0;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(0);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(0);
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

CREATE OR REPLACE PUBLIC SYNONYM SP_VALIDATE_STUDENT_ASSIGNMENT
   FOR tips.SP_VALIDATE_STUDENT_ASSIGNMENT
/   

-- Grants for Procedure
GRANT EXECUTE ON SP_VALIDATE_STUDENT_ASSIGNMENT TO tipsuser
/
GRANT EXECUTE ON SP_VALIDATE_STUDENT_ASSIGNMENT TO everything_in_tips
/


-- End of DDL Script for Procedure TIPS.SP_VALIDATE_STUDENT_ASSIGNMENT

