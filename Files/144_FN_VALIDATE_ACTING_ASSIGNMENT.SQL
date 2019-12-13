-- Start of DDL Script for Function TIPS.FN_VALIDATE_ACTING_ASSIGNMENT
-- Generated 2019-07-12 7:35:46 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_validate_acting_assignment
  ( v_employee_pin                 assignments.asn_employee_pin%TYPE,
    v_position_nmbr                assignments.asn_position_nmbr%TYPE,
    v_asn_start_dte                assignments.asn_effective_start_date%TYPE,
    v_asn_end_dte                  assignments.asn_effective_end_date%TYPE,
    v_hrsr_request_cd              ah029_hrsr_staffing.stf_hrsr_request_cd%TYPE
  )
  RETURN  VARCHAR2 IS
--
-- Purpose: Function to validate the acting assignment against the employee's
--          substantive assignment.
--
--   Return value: Success = 0
--                 Unsuccessful = Error message text with exact error
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--

   v_min_days_acting       agreements.agr_min_days_acting%TYPE;
   v_incumbent_asn_exists  INTEGER := 0;
   v_promotion_txt         VARCHAR2(30);
   v_acting_bud_code_txt   assignments.asn_bud_code%TYPE;
   v_acting_group_ind      assignments.asn_classn_group_ind%TYPE;
   v_acting_subgroup_ind   assignments.asn_classn_subgroup_ind%TYPE;
   v_acting_level_ind      assignments.asn_classn_level_ind%TYPE;
   v_error_message_txt     VARCHAR2(1000);

BEGIN

  -- Do basic checks to make sure there is a value in all the variables:
  IF v_asn_start_dte IS NULL THEN
     v_error_message_txt := 'This HRSR record is missing data: Start date';
     RETURN v_error_message_txt;
  ELSIF v_asn_end_dte IS NULL THEN
     v_error_message_txt := 'This HRSR record is missing data: End date';
     RETURN v_error_message_txt;
  ELSIF v_employee_pin IS NULL THEN
     v_error_message_txt := 'This HRSR record is missing data: Employee PIN';
     RETURN v_error_message_txt;
  ELSIF v_position_nmbr IS NULL THEN
     v_error_message_txt := 'This HRSR record is missing data: Position number';
     RETURN v_error_message_txt;
  END IF;


  -- Do basic checks to make sure the position number exists in POSITIONS:
  SELECT CASE
           WHEN MAX(pos_position_nmbr) IS NULL THEN
           'The position number chosen does not exist or may be archived.'
           END
    INTO v_error_message_txt
    FROM positions
   WHERE pos_position_nmbr = v_position_nmbr;

     IF v_error_message_txt IS NOT NULL THEN
        RETURN v_error_message_txt;
     END IF;

  -- Get the Acting Bud Code, and classification variables:

  SELECT pos_group_ind,
         pos_subgroup_ind,
         pos_level_ind,
         CASE
          WHEN v_acting_bud_code_txt IS NULL THEN
           CASE
             WHEN pos.pos_supervisory_grid_code IS NOT NULL AND
                  pos.pos_group_ind IN ('GS','GL','AI') THEN
                   (SELECT MAX(gbc_bud_code)
                      FROM group_bud_codes
                     WHERE gbc_active_flag = '1'
                       AND pos.pos_group_ind = gbc_group_ind
                       AND pos.pos_subgroup_ind = gbc_subgroup_ind)
             ELSE
               (SELECT MIN(gbc_bud_code)
                  FROM group_bud_codes
                 WHERE gbc_active_flag = '1'
                   AND pos.pos_group_ind = gbc_group_ind
                   AND pos.pos_subgroup_ind = gbc_subgroup_ind)
             END
          END AS bud_code_txt
    INTO v_acting_group_ind,
         v_acting_subgroup_ind,
         v_acting_level_ind,
         v_acting_bud_code_txt
    FROM positions           pos
   WHERE pos_position_nmbr = v_position_nmbr;

  -- If the group is TI and there is a TI profile assigned to the HRSR, then
  -- assign the TI bud code:

  IF v_acting_group_ind = 'TI' THEN
     -- Check for TI bud code:
     SELECT NVL(MAX(ti_bud_code_txt), v_acting_bud_code_txt)
       INTO v_acting_bud_code_txt
       FROM th197_ti_profile
      WHERE ti_profile_cd = (SELECT ah029.stf_ti_profile_cd
                               FROM ah029_hrsr_staffing ah029
                              WHERE ah029.stf_hrsr_request_cd =
                                    v_hrsr_request_cd);
  END IF;

  -- Check if the Acting assignment meets the minimum number of days according
  -- to the collective agreement of the group:

  SELECT agr_min_days_acting
    INTO v_min_days_acting
    FROM agreements
   WHERE agr_group_ind = v_acting_group_ind
     AND agr_expiry_date IS NULL;

  IF v_asn_end_dte - v_asn_start_dte < v_min_days_acting THEN
     v_error_message_txt := 'Acting assignment must be longer than minimum period for the collective agreement ('||
                            v_acting_group_ind|| ' group = '||v_min_days_acting||' days)';
     RETURN v_error_message_txt;
  END IF;

  -- Check if Acting assignment already exists:
  FOR asn_exists IN (
      SELECT *
        FROM assignments
       WHERE asn_employee_pin = v_employee_pin
         AND asn_position_nmbr = v_position_nmbr
         AND asn_employment_type_code IN ('A1', 'A2')
         AND TRUNC(asn_effective_start_date) = TRUNC(v_asn_start_dte)
         AND asn_classn_group_ind = v_acting_group_ind
         AND asn_classn_level_ind = v_acting_level_ind
  ) LOOP

    -- An assignment already exists for this record.
    v_error_message_txt := 'An Acting assignment already exists for these details';
    RETURN v_error_message_txt;

  END LOOP;

  -- Check if there's another person Acting in the Acting position number.
  -- Only one person can be acting in the assignment at a time.
  FOR overlapping_asn_rec IN (
      SELECT *
        FROM assignments
       WHERE asn_employee_pin != v_employee_pin
         AND asn_position_nmbr = v_position_nmbr
         AND (v_asn_start_dte BETWEEN asn_effective_start_date AND
              NVL(asn_effective_end_date, v_asn_start_dte + 1)
             OR
             (NVL(v_asn_end_dte, SYSDATE + 1) BETWEEN asn_effective_start_date AND
              NVL(asn_effective_end_date, NVL(v_asn_end_dte, SYSDATE + 1) + 10)))
  ) LOOP

    IF overlapping_asn_rec.asn_assignment_type_code IN ('A1', 'A2') THEN
       -- RETURN error: Cannot have 2 Acting assignments for the same position.
       v_error_message_txt := 'There is an overlapping acting assignment for another employee for the same position number';
       RETURN v_error_message_txt;
    END IF;
  END LOOP;


  -- Acting assignments:
  -- Check if there is an Incumbent position for the candidate for the entire
  -- period of the assignment
  FOR incumbent_assignment_rec IN (
       SELECT *
         FROM tips.assignments
        WHERE asn_position_nmbr != v_position_nmbr
          AND asn_employee_pin = v_employee_pin
          AND ((v_asn_start_dte BETWEEN asn_effective_start_date AND
                NVL(asn_effective_end_date, v_asn_start_dte + 1)) OR
               (v_asn_end_dte BETWEEN asn_effective_start_date AND
                NVL(asn_effective_end_date, v_asn_end_dte + 1)))
          AND EXISTS (SELECT *
                        FROM assignment_types
                       WHERE ast_incumbent_type_flag = '1'
                         AND ast_assignment_type_code = asn_assignment_type_code)
        ORDER BY NVL(asn_effective_end_date, '31-DEC-2099') DESC,
                     asn_effective_start_date DESC

     ) LOOP

       IF v_asn_start_dte BETWEEN
            incumbent_assignment_rec.asn_effective_start_date AND
            NVL(incumbent_assignment_rec.asn_effective_end_date,
                v_asn_start_dte + 1) AND
          v_asn_end_dte BETWEEN
            incumbent_assignment_rec.asn_effective_start_date AND
            NVL(incumbent_assignment_rec.asn_effective_end_date,
                v_asn_end_dte + 1) THEN
          -- Entire Acting assignment falls within the Incumbent Assignment.
          -- There is an incumbent assignment for the new Acting.
          v_incumbent_asn_exists := 1;

       ELSE
         -- Either the start date or the end date of the assignment are outside
         -- the incumbent dates. Check if there are other incumbent assignments
         -- with less than a 1 day break that overlaps the new acting assignment
         IF v_incumbent_asn_exists = 0 AND
            v_asn_start_dte <
            incumbent_assignment_rec.asn_effective_start_date THEN
            -- Check if there is a previous incument assignment with less than
            -- a 1 day break.  If not, return error message:
            SELECT COUNT(*)
              INTO v_incumbent_asn_exists
              FROM assignments
             WHERE asn_employee_pin = incumbent_assignment_rec.asn_employee_pin
               AND asn_effective_end_date =
                   incumbent_assignment_rec.asn_effective_start_date + 1
               AND v_asn_start_dte BETWEEN
                   asn_effective_start_date AND asn_effective_end_date
               AND EXISTS (SELECT *
                             FROM assignment_types
                            WHERE ast_incumbent_type_flag = '1'
                              AND ast_assignment_type_code =
                                  asn_assignment_type_code);

            -- RETURN error: Acting must have an underlying Incumbent Assignment
            -- for the same period, Start date of Acting does not have overlapping
            -- incumbent assignment.
            IF v_incumbent_asn_exists = 0 THEN
               v_error_message_txt := 'The start date of the acting assignment being entered, ' ||
                  TO_CHAR(v_asn_start_dte,'DD-MON-YYYY') ||
                  ', cannot be before the incumbent assignment start date of the candidate ('||
                  TO_CHAR(incumbent_assignment_rec.asn_effective_start_date,
                  'DD-MON-YYYY')||')' ;
               RETURN v_error_message_txt;
            END IF;

         ELSIF v_incumbent_asn_exists = 0 AND
            v_asn_end_dte >
            NVL(incumbent_assignment_rec.asn_effective_end_date,
                v_asn_end_dte + 1) THEN
            -- Check if there is a future incument assignment with less than
            -- a 1 day break.  If not, return error message:
            SELECT COUNT(*)
              INTO v_incumbent_asn_exists
              FROM assignments
             WHERE asn_employee_pin = incumbent_assignment_rec.asn_employee_pin
               AND asn_effective_start_date =
                   incumbent_assignment_rec.asn_effective_end_date + 1
               AND v_asn_end_dte BETWEEN
                   asn_effective_start_date AND
                   NVL(asn_effective_end_date,
                       v_asn_end_dte + 1)
               AND EXISTS (SELECT *
                             FROM assignment_types
                            WHERE ast_incumbent_type_flag = '1'
                              AND ast_assignment_type_code =
                                  asn_assignment_type_code);

            -- RETURN error: Acting must have an underlying Incumbent Assignment
            -- for the same period, End date of Acting does not have overlapping
            -- incumbent assignment.
            IF v_incumbent_asn_exists = 0 THEN
               v_error_message_txt := 'The end date being entered for acting assignment, ' ||
                TO_CHAR(v_asn_end_dte,'DD-MON-YYYY') ||
                ' cannot be after the incumbent assignment end date: '||
                TO_CHAR(incumbent_assignment_rec.asn_effective_end_date, 'DD-MON-YYYY') ;
             RETURN v_error_message_txt;
            END IF;
         END IF;
         END IF;
       END LOOP;

  -- Check if the Acting and the Substantive assignment of the employee passes
  -- the promo rules (promotion, demotion, or deployment).
  -- Loop through the employee's substantive assignments:

  -- Get the incumbent assignment information to compare the Acting against:
  FOR incumbent_assignment_rec IN (
       SELECT *
         FROM tips.assignments
        WHERE asn_position_nmbr != v_position_nmbr
          AND asn_employee_pin = v_employee_pin
          AND ((v_asn_start_dte BETWEEN asn_effective_start_date AND
                NVL(asn_effective_end_date, v_asn_start_dte + 1)) OR
               (v_asn_end_dte BETWEEN asn_effective_start_date AND
                NVL(asn_effective_end_date, v_asn_end_dte + 1)))
          AND EXISTS (SELECT *
                        FROM assignment_types
                       WHERE ast_incumbent_type_flag = '1'
                         AND ast_assignment_type_code = asn_assignment_type_code)
        ORDER BY NVL(asn_effective_end_date, '31-DEC-2099') DESC,
                     asn_effective_start_date DESC

     ) LOOP

       -- Check if the acting assignment meets the definition of a Promotion:
       v_promotion_txt :=
           tips.fn_deployment_calculator(
                incumbent_assignment_rec.asn_classn_group_ind,
                incumbent_assignment_rec.asn_classn_subgroup_ind,
                incumbent_assignment_rec.asn_classn_level_ind,
                incumbent_assignment_rec.asn_bud_code,
                v_acting_group_ind,
                v_acting_subgroup_ind,
                v_acting_level_ind,
                v_acting_bud_code_txt);

       IF v_promotion_txt != 'PROMOTION' THEN
          -- Return an error message:
             v_error_message_txt := 'The acting classification (' ||
                 v_acting_group_ind||
                 REPLACE(v_acting_subgroup_ind,'   ','-')||
                 v_acting_level_ind||
                ') and substantive classification ('||
                incumbent_assignment_rec.asn_classn_group_ind||
                REPLACE(incumbent_assignment_rec.asn_classn_subgroup_ind,'   ','-')||
                incumbent_assignment_rec.asn_classn_level_ind||
                '), does not meet the definition of acting / promotion. Actual definition: '||
                LOWER(v_promotion_txt)  ;
             RETURN v_error_message_txt;
       ELSE
          v_error_message_txt := '0';
          RETURN v_error_message_txt;
       END IF;

     END LOOP;

     IF v_incumbent_asn_exists = 0 THEN
        -- No overlapping incumbent assignments were returned in the loop.
        -- RETURN error: Acting must have an underlying Incumbent Assignment
        -- for the same period:
        v_error_message_txt := 'Acting assignments must have an overlapping incumbent assignment for the candidate.';
        RETURN v_error_message_txt;
     END IF;

     v_error_message_txt := '0';
     RETURN v_error_message_txt;

EXCEPTION
   WHEN OTHERS THEN
       v_error_message_txt := 'Unknown Error';
       RETURN v_error_message_txt ;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM fn_validate_acting_assignment 
  FOR tips.fn_validate_acting_assignment
/

-- Grants for Function
GRANT EXECUTE ON fn_validate_acting_assignment TO tipsuser
/
GRANT EXECUTE ON fn_validate_acting_assignment TO everything_in_tips
/


-- End of DDL Script for Function TIPS.FN_VALIDATE_ACTING_ASSIGNMENT

