-- Start of DDL Script for Procedure TIPS.SP_VALIDATE_CASUAL_ASSIGNMENT
-- Generated 2019-09-03 7:50:07 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE sp_validate_casual_assignment
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
--          *
--
--   Return value: Success = 0
--                 Unsuccessful = Error message text with exact error
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--

   v_person_type_cd        persons.per_type_code%TYPE;

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


  SELECT MIN(per_type_code)
    INTO v_person_type_cd
    FROM persons
   WHERE per_pin = v_employee_pin;

   IF v_person_type_cd = '7' THEN  -- Unpaid Secondment, NOT an employee
      -- Candidate does not exist as an employee.
      v_error_num := 23;
      v_error_message_etxt := REPLACE(
                                 fn_get_hrsr_error_message_etxt(23),
                                 '<v_candidate_pin>', v_employee_pin);
      v_error_message_ftxt := REPLACE(
                                 fn_get_hrsr_error_message_ftxt(23),
                                 '<v_candidate_pin>', v_employee_pin);
      RETURN;
   END IF;

  -- If the action type = Casual, the Position must allow casual assignments.
  -- If not, return error message:
  FOR casual_allowed_rec IN (
      SELECT *
        FROM ah029_hrsr_staffing,
             ah030_hrsr_phantom_position,
             positions
       WHERE stf_hrsr_request_cd = v_hrsr_request_cd
         AND stf_hrsr_request_cd = php_hrsr_request_cd(+)
         AND pos_position_nmbr = v_position_nmbr
         AND ((stf_phantom_required_ind = 1 AND
              NOT EXISTS (SELECT *
                            FROM all_levels lvl
                           WHERE lvl_group_ind = php_group_ind
                             AND lvl_subgroup_ind = php_subgroup_ind
                             AND lvl_level_ind = php_level_ind
                             AND lvl_casual_allow_flag = '1')) OR
              NOT EXISTS (SELECT *
                            FROM all_levels lvl
                           WHERE lvl_group_ind = pos_group_ind
                             AND lvl_subgroup_ind = pos_subgroup_ind
                             AND lvl_level_ind = pos_level_ind
                             AND lvl_casual_allow_flag = '1'))
    ) LOOP

      -- Casual assignment is not allowed for this position classification.
      v_error_num := 22;
      v_error_message_etxt := fn_get_hrsr_error_message_etxt(22);
      v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(22);
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

CREATE OR REPLACE PUBLIC SYNONYM SP_VALIDATE_CASUAL_ASSIGNMENT
   FOR tips.SP_VALIDATE_CASUAL_ASSIGNMENT
/   

-- Grants for Procedure
GRANT EXECUTE ON SP_VALIDATE_CASUAL_ASSIGNMENT TO tipsuser
/
GRANT EXECUTE ON SP_VALIDATE_CASUAL_ASSIGNMENT TO everything_in_tips
/


-- End of DDL Script for Procedure TIPS.SP_VALIDATE_CASUAL_ASSIGNMENT

