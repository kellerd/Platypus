-- Start of DDL Script for Function TIPS.FN_ACTING_LAST_END_DTE
-- Generated 2019-11-15 2:19:12 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_acting_last_end_dte
  ( v_employee_pin    assignments.asn_employee_pin%TYPE,
    v_position_nmbr   assignments.asn_position_nmbr%TYPE,
    v_start_dte       assignments.asn_effective_start_date%TYPE
  )
  RETURN  DATE IS
--
-- Purpose: Function to return the last possible end date for acting less than
--          4 month assignment for an employee and position number. Concurrent
--          assignments are those with less than a 1 day break between the NEW
--          start date and the previous assignment end date.
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--

   v_earliest_start_dte  assignments.asn_effective_start_date%TYPE;
   v_acting_last_end_dte assignments.asn_effective_end_date%TYPE;

BEGIN

  v_earliest_start_dte  := v_start_dte;

  -- If the Acting is a new assignment, but an existing acting exists for the
  -- same position, check if there is less than a 1 day break. If there is,
  -- check if the total length of the new start date and the previous end date
  -- does not exceed 4 months less a day:
  FOR previous_acting_rec IN (
      SELECT TRUNC(asn_effective_start_date) + 11/24 AS asn_effective_start_date,
             TRUNC(asn_effective_end_date) + 23/24 AS asn_effective_end_date
        FROM assignments
       WHERE asn_employee_pin = v_employee_pin
         AND asn_position_nmbr = v_position_nmbr
         AND asn_assignment_type_code IN ('A1', 'A2')
         AND asn_effective_start_date < v_start_dte
       ORDER BY asn_effective_end_date DESC
  ) LOOP


    IF tips.get_working_days_between_dates(
            previous_acting_rec.asn_effective_end_date,
            v_earliest_start_dte) <= 1 THEN

       v_earliest_start_dte := previous_acting_rec.asn_effective_start_date;

    END IF;
  END LOOP;

  v_acting_last_end_dte := TRUNC(ADD_MONTHS(v_earliest_start_dte, 4) - 1);

  RETURN v_acting_last_end_dte;


EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL  ;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM FN_ACTING_LAST_END_DTE
  FOR TIPS.FN_ACTING_LAST_END_DTE
/  

-- Grants for Function
GRANT EXECUTE ON fn_acting_last_end_dte TO tipsuser
/
GRANT EXECUTE ON fn_acting_last_end_dte TO everything_in_tips
/


-- End of DDL Script for Function TIPS.FN_ACTING_LAST_END_DTE

