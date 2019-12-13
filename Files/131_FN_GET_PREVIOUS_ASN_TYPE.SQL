-- Start of DDL Script for Function TIPS.FN_GET_PREVIOUS_ASN_TYPE
-- Generated 24-09-2019 4:30:44 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_get_previous_asn_type
  ( v_employee_pin                assignments.asn_employee_pin%TYPE,
    v_new_assignment_start_dte    assignments.asn_effective_start_date%TYPE
  )
  RETURN  assignment_types.ast_assignment_type_code%TYPE IS
--
-- Purpose: Function to return the assignment type for the previous assignment
--          to the HRSR application.
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--


BEGIN
  FOR previous_assignment_rec IN (
       SELECT *
         FROM assignments
        WHERE asn_employee_pin = v_employee_pin
          AND TRUNC(asn_effective_end_date) <= TRUNC(v_new_assignment_start_dte)
          AND v_new_assignment_start_dte - asn_effective_end_date < 5
        ORDER BY NVL(asn_effective_end_date,
                 TO_DATE('31-DEC-2099','DD-MON-YYYY')) DESC
  ) LOOP

    IF TRUNC(v_new_assignment_start_dte) -
       TRUNC(previous_assignment_rec.asn_effective_end_date) <= 1 THEN
       -- 1 day break, return the assignment type of previous asn
          RETURN previous_assignment_rec.asn_assignment_type_code;

    ELSIF TRIM(TO_CHAR(previous_assignment_rec.asn_effective_end_date,'DAY')) IN
       ('FRIDAY', 'SATURDAY', 'SUNDAY') AND
       TRIM(TO_CHAR(v_new_assignment_start_dte,'DAY')) IN ('SATURDAY','SUNDAY','MONDAY') THEN
       -- Previous assignment ends on Friday - Sunday, so new assignment would
       -- start on Monday, or in the case of a stat holiday, Tuesday. Return the
       -- assignment type of previous assignment.
          RETURN previous_assignment_rec.asn_assignment_type_code;

    ELSIF TRIM(TO_CHAR(previous_assignment_rec.asn_effective_end_date,'DAY')) IN
       ('FRIDAY', 'SATURDAY', 'SUNDAY') AND
       TRIM(TO_CHAR(v_new_assignment_start_dte,'DAY')) = 'TUESDAY' THEN
       -- A Tuesday start date would indicate that the Monday must be a stat .
       -- holiday. Check if the Monday was a stat holiday.
       FOR stat_holiday_rec IN (
           SELECT *
             FROM stat_holidays
            WHERE sth_holiday_date = trunc(v_new_assignment_start_dte) - 1
       ) LOOP

          RETURN previous_assignment_rec.asn_assignment_type_code;
       END LOOP;

    END IF;

   END LOOP;

   RETURN NULL;
EXCEPTION
   WHEN OTHERS THEN
       RETURN NULL  ;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM FN_GET_PREVIOUS_ASN_TYPE
  FOR FN_GET_PREVIOUS_ASN_TYPE;
  
GRANT EXECUTE ON FN_GET_PREVIOUS_ASN_TYPE TO TIPSUSER;
GRANT EXECUTE ON FN_GET_PREVIOUS_ASN_TYPE TO EVERYTHING_IN_TIPS;  

-- End of DDL Script for Function TIPS.FN_GET_PREVIOUS_ASN_TYPE

