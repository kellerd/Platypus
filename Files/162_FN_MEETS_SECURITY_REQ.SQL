-- Start of DDL Script for Function TIPS.FN_MEETS_SECURITY_REQ
-- Generated 2019-08-13 12:02:07 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_meets_security_req
  ( v_employee_pin    persons.per_pin%TYPE,
    v_position_nmbr   positions.pos_position_nmbr%TYPE,
    v_hrsr_request_cd ah029_hrsr_staffing.stf_hrsr_request_cd%TYPE
  )
  RETURN  INTEGER IS
--
-- Purpose: Function to return if the candidate / employee meets the security
--          profile of the position.
--
--          Security values (high to low):
--          T   Top Secret
--          S   Secret
--          R   Reliability
--
--          Return Values:
--          0 = Success, Employee meets the security requirement
--          1 = Warning, Employee does not have a security requirement
--          2 = Warning, Employee does not meet the security requirement
--
--          ********************************************************************
--          THIS FUNCTION WILL NOT BE USED IN HRSR VALIDATION AS THE SECURITY
--          INFORMATION OF THE EMPLOYEE IS NOT THERE. I will leave this code IN
--          case we ever need to reuse it.
--          ********************************************************************
--
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--

   v_position_security_cd    positions.pos_security_clearance_ind%TYPE;
   v_candidate_security_cd   persons.per_security_screen_result%TYPE;

BEGIN

  -- Get the position security profile:
  SELECT NVL(pos_security_clearance_ind,'R')
    INTO v_position_security_cd
    FROM positions
   WHERE pos_position_nmbr = v_position_nmbr;

   -- Get the employee / candidate security profile:
   SELECT GREATEST(
            MAX(per_security_screen_result),
            MAX(stf_security_clearance_ind))
     INTO v_candidate_security_cd
     FROM persons,
          ah029_hrsr_staffing
    WHERE per_pin = v_employee_pin
      AND stf_hrsr_request_cd = v_hrsr_request_cd;

  IF v_candidate_security_cd IS NULL THEN
     -- Candidate has no security profile.
     -- Return error message, does not meet:
     RETURN 1;
  ELSIF v_candidate_security_cd = 'R' AND
        v_position_security_cd IN ('S','T') THEN
     -- Position has Secret or Top Secret, but candidate has Reliablity
     -- Return error message, does not meet:
     RETURN 2;
  ELSIF v_candidate_security_cd = 'S' AND
        v_position_security_cd = 'T' THEN
     -- Position has Top Secret, but candidate has Secret
     -- Return error message, does not meet:
     RETURN 2;
  ELSE
     RETURN 0;  -- Meets security profile
  END IF;

EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL;
END;
/

-- Grants for Function
GRANT EXECUTE ON fn_meets_security_req TO tipsuser
/
GRANT EXECUTE ON fn_meets_security_req TO everything_in_tips
/


-- End of DDL Script for Function TIPS.FN_MEETS_SECURITY_REQ

