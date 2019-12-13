-- Start of DDL Script for Procedure TIPS.SP_VALIDATE_ACTING_ASSIGNMENT
-- Generated 2019-11-26 12:38:19 PM from TIPS@TIPSUAT.WORLD

CREATE OR REPLACE 
PROCEDURE sp_validate_acting_assignment
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
--          substantive assignment.
--
--          Checks made:
--          * Missing fields
--          * Position exists as active position
--          * If the position is a term position, the assignment cannnot be
--            end beyond the position end date.
--          * Acting assignment must be longer than minimum period from the
--            collective agreement (minus any stat holidays) of the substantive
--            assignment of the candidate.
--          * If the acting or substantive position has a minimum acting period
--            in the collective agreement of 999, then no acting can take place.
--          * Check if acting assignment already exists for these details
--          * Check if incumbent assignment exists for the entire period of the
--            acting
--          * Check if the Acting and the Substantive assignment of the employee
--            passes the promo rules (promotion, demotion, or deployment)
--          * Check if position has been flagged by classifction not to be
--            staffed.
--          * Check if substantive assignment of candidate is allowed to act.
--          * Check if acting extension end date does not exceed 4 months less
--            a day from the original assignment.
--          * Check if assignment overlaps with an existing long term acting
--            assignment.
--          * Check if assignment overlaps with an existing acting < 4mths and
--            the acting is "at level"
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
   v_position_emp_type_cd  positions.pos_employment_type_code%TYPE;
   v_pos_next_review_dte   positions.pos_next_review_date%TYPE;
   v_province_cd           geographic_locations.gel_geo_province_code%TYPE;
   v_stat_holiday_count    INTEGER;
   v_earliest_start_dte    DATE  := v_asn_start_dte;
   v_hrsr_actor_cd         ah027_hrsr_request.rqt_hrsr_actor_cd%TYPE;
   v_min_asn_start_dte     DATE;
   v_max_asn_end_dte       DATE;
   v_end_at_level_act_ind  ah029_hrsr_staffing.stf_end_at_level_acting_ind%TYPE;
   v_pay_rate_exists       INTEGER;
   v_ti_profile_enm        th197_ti_profile.ti_profile_enm%TYPE;
   v_ti_profile_fnm        th197_ti_profile.ti_profile_fnm%TYPE;
   v_extension_cd          ah029_hrsr_staffing.stf_extension_cd%TYPE;

BEGIN

  -- Set variable of whether the acting is to be ended:
  SELECT NVL(stf_end_at_level_acting_ind,0),
         stf_extension_cd
    INTO v_end_at_level_act_ind,
         v_extension_cd
    FROM ah029_hrsr_staffing
   WHERE stf_hrsr_request_cd = v_hrsr_request_cd;

   IF v_extension_cd IS NULL THEN
      SELECT DECODE(COUNT(*), 0, 'N', 'E')
        INTO v_extension_cd
        FROM assignments
       WHERE asn_employee_pin = v_employee_pin
         AND asn_position_nmbr = v_position_nmbr
         AND asn_assignment_type_code = 'A1'
         AND TRUNC(asn_effective_end_date) = TRUNC(v_asn_start_dte - 1);
   END IF;

  -- Acting positions with a min number of acting days in the agreement of 999
  -- are not allowed to act:
  SELECT NVL(MAX(agr_min_days_acting),200)
    INTO v_min_days_acting
    FROM agreements
   WHERE agr_group_ind = (SELECT pos_group_ind
                            FROM positions
                           WHERE pos_position_nmbr = v_position_nmbr)
     AND agr_expiry_date IS NULL;

  IF v_min_days_acting = 999 THEN
     -- Acting position is in a group that cannot have acting assignments.
     -- Return error message.
     v_error_num := 33;
     v_error_message_etxt := ' • '||fn_get_hrsr_error_message_etxt(33)||' <BR> ';
     v_error_message_ftxt := ' • '||fn_get_hrsr_error_message_ftxt(33)||' <BR> ';
     RETURN; -- end the procedure, and return just this message
  END IF;

  IF fn_position_classn_flag(v_position_nmbr, '26') = 2 THEN
     -- The position has been flagged by classifction not to be staffed.
     -- Return error message to user that the user has to contact the
     -- Classification advisor to continue the process.
     v_error_num := 31;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(31)||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(31)||' <BR> ';
  END IF;

  -- Start Date has to be less than the end date:
  IF v_asn_start_dte > v_asn_end_dte THEN
     -- The HRSR is missing data: Start date
     v_error_num := 61;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(61)||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(61)||' <BR> ';
     RETURN;
  END IF;

  -- Do basic checks to make sure there is a value in all the variables:
  IF v_asn_start_dte IS NULL THEN
     -- The HRSR is missing data: Start date
     v_error_num := 3;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(3)||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(3)||' <BR> ';
  END IF;

  IF v_asn_end_dte IS NULL THEN
     -- The HRSR is missing data: End date
     v_error_num := 4;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(4)||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(4)||' <BR> ';
  END IF;

  IF v_employee_pin IS NULL THEN
     -- The HRSR is missing data: Candidate PIN
     v_error_num := 2;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(2)||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(2)||' <BR> ';
  END IF;

  IF v_hrsr_request_cd IS NULL THEN
     -- The HRSR is missing data: HRSR request number
     v_error_num := 52;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(52)||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(52)||' <BR> ';
     RETURN;
  END IF;

  IF v_position_nmbr IS NULL THEN
     -- The HRSR is missing data: Position Number
     v_error_num := 5;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(5)||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(5)||' <BR> ';
     RETURN;
  END IF;

  -- If any of the variables are blank, then return the error messages:
  IF v_error_num IS NOT NULL THEN
     RETURN;
  END IF;

  -- Do basic checks to make sure the position number exists in POSITIONS:
  SELECT COUNT(*),
         MAX(pos_employment_type_code),
         MAX(pos_next_review_date)
    INTO v_position_count,
         v_position_emp_type_cd,
         v_pos_next_review_dte
    FROM positions
   WHERE pos_position_nmbr = v_position_nmbr;

  IF v_position_count = 0 THEN
     -- The position number chosen does not exist or may be archived
     v_error_num := 6;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(6)||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(6)||' <BR> ';
     RETURN;
  END IF;

  IF v_position_emp_type_cd IN ('E','F', 'G','H','S','T') AND -- Term Position
     v_asn_end_dte > NVL(v_pos_next_review_dte, TO_DATE('31-DEC-2099','DD-MON-YYYY')) THEN
     -- The assignment end date is beyond the end date of the position, return
     -- error message:
     v_error_num := 53;
     v_error_message_etxt := v_error_message_etxt||' • '||
       REPLACE(
         fn_get_hrsr_error_message_etxt(53),
         '<v_position_end_dte>', TO_CHAR(v_pos_next_review_dte,'DD-MON-YYYY'))
         ||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||
       REPLACE(
         fn_get_hrsr_error_message_ftxt(53),
         '<v_position_end_dte>', TO_CHAR(v_pos_next_review_dte,'DD-MON-YYYY'))
         ||' <BR> ';
     RETURN;
  END IF;

  -- Get the Acting Bud Code, and classification variables:
  SELECT pos_group_ind,
         pos_subgroup_ind,
         pos_level_ind,
         CASE
          WHEN v_acting_bud_code_txt IS NULL THEN
            CASE
              WHEN stf_ti_profile_cd IS NOT NULL THEN -- TI Profile
                  (SELECT ti_bud_code_txt
                     FROM th197_ti_profile
                    WHERE ti_profile_cd = stf_ti_profile_cd)
              WHEN pos_supervisory_grid_code IS NOT NULL AND
                   pos_group_ind IN ('GS','GL','AI') THEN
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
    FROM positions           pos,
         ah029_hrsr_staffing
   WHERE pos_position_nmbr = v_position_nmbr
     AND stf_hrsr_request_cd = v_hrsr_request_cd;

  -- If the group is TI and there is a TI profile assigned to the HRSR, then
  -- assign the TI bud code:
  IF v_acting_group_ind = 'TI' THEN
     -- Check for TI bud code:
     SELECT NVL(MAX(ti_bud_code_txt), v_acting_bud_code_txt),
            MAX(ti_profile_enm),
            MAX(ti_profile_fnm)
       INTO v_acting_bud_code_txt,
            v_ti_profile_enm,
            v_ti_profile_fnm
       FROM th197_ti_profile
      WHERE ti_profile_cd = (SELECT ah029.stf_ti_profile_cd
                               FROM ah029_hrsr_staffing ah029
                              WHERE ah029.stf_hrsr_request_cd =
                                    v_hrsr_request_cd);

     IF v_ti_profile_enm IS NULL THEN
        v_error_num := 65;
        v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(65)||' <BR> ';
        v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(65)||' <BR> ';
     END IF;

  END IF;

  -- If acting assignment is an EX process (classn = EX, DM or OC) then SET
  -- the actor who the HRSR is currently assigned to:
  IF v_acting_group_ind IN ('EX', 'DM', 'OC') THEN
     SELECT NVL(MAX(rqt_hrsr_actor_cd),1)
       INTO v_hrsr_actor_cd
       FROM ah027_hrsr_request
      WHERE rqt_hrsr_request_cd = v_hrsr_request_cd;
  END IF;

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
         AND v_asn_start_dte >= asn_effective_start_date
         AND NVL(asn_hrsr_request_cd,'NULL') != v_hrsr_request_cd
         AND asn_assignment_type_code IN ('A1', 'A2')
       ORDER BY asn_effective_end_date DESC
  ) LOOP

    -- If there's less than a day between the previous end date and the start
    -- date, use the start date as the new earliest start date. This new earlier
    -- start date also has to pass the less than 4 months from the new assignment
    -- end date.
    IF tips.get_working_days_between_dates(
            previous_acting_rec.asn_effective_end_date,
            v_earliest_start_dte) <= 1 THEN

       v_earliest_start_dte := previous_acting_rec.asn_effective_start_date;

       IF MONTHS_BETWEEN(v_asn_end_dte, v_earliest_start_dte) >= 4 THEN
          -- Return error message: The acting assignment has a previous acting
          -- assignment for the same position, and the length exceeds 4 months:
          v_error_num := 39;
          v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(39)||' <BR> ';
          v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(39)||' <BR> ';
       END IF;
    END IF;

    EXIT WHEN v_error_num = 39;
  END LOOP;


  -- Check if Acting assignment already exists:
  FOR asn_exists IN (
      SELECT DISTINCT asn_employee_pin
        FROM assignments
       WHERE asn_employee_pin = v_employee_pin
         AND asn_position_nmbr = v_position_nmbr
         AND asn_assignment_type_code IN ('A1', 'A2')
         AND TRUNC(asn_effective_start_date) = TRUNC(v_asn_start_dte)
         AND asn_classn_group_ind = v_acting_group_ind
         AND asn_classn_level_ind = v_acting_level_ind
         AND NVL(asn_hrsr_request_cd,'NULL') != v_hrsr_request_cd
  ) LOOP

     -- An assignment already exists for these HRSR details.
     v_error_num := 10;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(10)||' <BR> ';
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(10)||' <BR> ';

     EXIT WHEN v_error_num = 10;
  END LOOP;

  -- Check if there is an Incumbent position for the candidate for the entire
  -- period of the assignment
  FOR incumbent_assignment_rec IN (
       SELECT *
         FROM tips.assignments
        WHERE asn_position_nmbr != v_position_nmbr
          AND asn_employee_pin = v_employee_pin
          AND NVL(asn_hrsr_request_cd,'NULL') != v_hrsr_request_cd
          AND ((v_asn_start_dte BETWEEN asn_effective_start_date AND
                NVL(asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY'))) OR
               (v_asn_end_dte BETWEEN asn_effective_start_date AND
                NVL(asn_effective_end_date,  TO_DATE('31-DEC-2099','DD-MON-YYYY'))))
          AND EXISTS (SELECT *
                        FROM assignment_types
                       WHERE ast_incumbent_type_flag = '1'
                         AND ast_assignment_type_code = asn_assignment_type_code)
        ORDER BY NVL(asn_effective_end_date,  TO_DATE('31-DEC-2099','DD-MON-YYYY')) DESC,
                     asn_effective_start_date DESC
  ) LOOP

    IF v_asn_start_dte BETWEEN incumbent_assignment_rec.asn_effective_start_date AND
         NVL(incumbent_assignment_rec.asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY')) AND
       v_asn_end_dte BETWEEN incumbent_assignment_rec.asn_effective_start_date AND
         NVL(incumbent_assignment_rec.asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY')) THEN
       -- Entire Acting assignment falls within the Incumbent Assignment.
       -- There is an incumbent assignment for the new Acting.
       v_incumbent_asn_exists := 1;

    ELSE
       -- Either the start date or the end date of the assignment are outside
       -- the incumbent dates. Loop through the rest of the assignments, and
       -- check if there are other incumbent assignments with less than a 1 day
       -- break that overlaps the new acting assignment

       -- Check if Start Date falls within the assignment and set the min start
       -- date variable:
       IF v_incumbent_asn_exists = 0 AND
          v_asn_start_dte BETWEEN
          incumbent_assignment_rec.asn_effective_start_date AND
          NVL(incumbent_assignment_rec.asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY')) THEN

          -- Check if there is an incument assignment with less than
          -- a 1 day break that covers the end date.
          --     |------|
          --       Acting
          --  |------| |--------|
          --   Sub#1    Sub#2
          SELECT COUNT(*)
            INTO v_incumbent_asn_exists
            FROM assignments
           WHERE asn_employee_pin = v_employee_pin
             AND asn_position_nmbr != v_position_nmbr
             AND NVL(asn_hrsr_request_cd,'NULL') != v_hrsr_request_cd
             AND v_asn_end_dte BETWEEN
                 asn_effective_start_date AND
                 NVL(asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY'))
             AND (NVL(incumbent_assignment_rec.asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY')) -
                 asn_effective_start_date) <= 1
             AND EXISTS (SELECT *
                           FROM assignment_types
                          WHERE ast_incumbent_type_flag = '1'
                            AND ast_assignment_type_code =
                                asn_assignment_type_code);

          -- There is no overlapping incumbent assignment for the end date of
          -- the HRSR, Return error:
          IF v_incumbent_asn_exists = 0 THEN
             v_error_num := 14;
             v_error_message_etxt := v_error_message_etxt||' • '||
               REPLACE(
               REPLACE(
                 fn_get_hrsr_error_message_etxt(14),
               '<v_acting_end_dte>',    TO_CHAR(v_asn_end_dte,'DD-MON-YYYY')),
               '<v_incumbent_end_dte>', TO_CHAR(incumbent_assignment_rec.asn_effective_end_date,'DD-MON-YYYY'))
               ||' <BR> ';
             v_error_message_ftxt := v_error_message_ftxt||' • '||
               REPLACE(
               REPLACE(
                 fn_get_hrsr_error_message_ftxt(14),
               '<v_acting_end_dte>',    TO_CHAR(v_asn_end_dte,'DD-MON-YYYY')),
               '<v_incumbent_end_dte>', TO_CHAR(incumbent_assignment_rec.asn_effective_end_date,'DD-MON-YYYY'))
               ||' <BR> ';
          END IF;
       END IF;

       -- Check if End Date falls within the assignment:
       IF v_incumbent_asn_exists = 0 AND
          v_asn_end_dte BETWEEN
          incumbent_assignment_rec.asn_effective_start_date AND
          NVL(incumbent_assignment_rec.asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY')) THEN

          -- Check if there is an incument assignment with less than
          -- a 1 day break that covers the start date.
          --      |------|
          --       Acting
          --  |------| |--------|
          --   Sub#1    Sub#2

          SELECT COUNT(*)
            INTO v_incumbent_asn_exists
            FROM assignments
           WHERE asn_employee_pin = v_employee_pin
             AND asn_position_nmbr != v_position_nmbr
             AND NVL(asn_hrsr_request_cd,'NULL') != v_hrsr_request_cd
             AND v_asn_start_dte BETWEEN
                 asn_effective_start_date AND
                 NVL(asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY'))
             AND incumbent_assignment_rec.asn_effective_start_date - asn_effective_end_date <= 1
             AND EXISTS (SELECT *
                           FROM assignment_types
                          WHERE ast_incumbent_type_flag = '1'
                            AND ast_assignment_type_code =
                                asn_assignment_type_code);

          -- There is no overlapping incumbent assignment for the start date of
          -- the HRSR, Return error:
          IF v_incumbent_asn_exists = 0 THEN
             v_error_num := 13;
             v_error_message_etxt := v_error_message_etxt||' • '||
               REPLACE(
               REPLACE(
                 fn_get_hrsr_error_message_etxt(13),
               '<v_acting_start_dte>',    TO_CHAR(v_asn_start_dte,'DD-MON-YYYY')),
               '<v_incumbent_start_dte>', TO_CHAR(incumbent_assignment_rec.asn_effective_start_date,'DD-MON-YYYY'))
               ||' <BR> ';
             v_error_message_ftxt := v_error_message_ftxt||' • '||
               REPLACE(
               REPLACE(
                 fn_get_hrsr_error_message_ftxt(13),
               '<v_acting_start_dte>',    TO_CHAR(v_asn_start_dte,'DD-MON-YYYY')),
               '<v_incumbent_start_dte>', TO_CHAR(incumbent_assignment_rec.asn_effective_start_date,'DD-MON-YYYY'))
               ||' <BR> ';
          END IF;
       END IF;
    END IF;
    -- Looped through substantive assignments and no errors found, so set the
    -- incumbent asn exists = 1:
    v_incumbent_asn_exists := 1;
  END LOOP;

  -- Loop through the employee's substantive assignments:
  -- Get the incumbent assignment information to compare the Acting against:
  FOR incumbent_assignment_rec IN (
       SELECT *
         FROM tips.assignments
        WHERE asn_employee_pin = v_employee_pin
          AND NVL(asn_hrsr_request_cd,'NULL') != v_hrsr_request_cd
          AND ((v_asn_start_dte BETWEEN asn_effective_start_date AND
                NVL(asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY'))) OR
               (v_asn_end_dte BETWEEN asn_effective_start_date AND
                NVL(asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY'))))
          AND EXISTS (SELECT *
                        FROM assignment_types
                       WHERE ast_incumbent_type_flag = '1'
                         AND ast_assignment_type_code = asn_assignment_type_code)
        ORDER BY NVL(asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY')) DESC,
                     asn_effective_start_date DESC
     ) LOOP

       -- If the substantive position number is the same as the acting position
       -- number, return an error message:
       IF v_position_nmbr = incumbent_assignment_rec.asn_position_nmbr THEN
          -- Return error message: The acting position number selected is the
          -- same as the candidate's substantive position:
          v_error_num := 38;
          v_error_message_etxt := ' • '||fn_get_hrsr_error_message_etxt(38)||' <BR> ';
          v_error_message_ftxt := ' • '||fn_get_hrsr_error_message_ftxt(38)||' <BR> ';
          RETURN;

       ELSE

         IF incumbent_assignment_rec.asn_classn_group_ind = 'EX' AND
            incumbent_assignment_rec.asn_classn_level_ind IN ('04','05') THEN
            -- Return error message: The substantive position is an EX-04 or EX-05
            -- and the candidate is not allowed to act:
            v_error_num := 63;
            v_error_message_etxt := ' • '||fn_get_hrsr_error_message_etxt(63)||' <BR> ';
            v_error_message_ftxt := ' • '||fn_get_hrsr_error_message_ftxt(63)||' <BR> ';
            RETURN;
         END IF;

         -- If the Acting candidate has a substantive assignmenent where the min
         -- number of acting days in the agreement is 999, then they are not
         -- allowed to act in any position.
         SELECT NVL(MAX(agr_min_days_acting),200)
           INTO v_min_days_acting_sub
           FROM agreements
          WHERE agr_group_ind = incumbent_assignment_rec.asn_classn_group_ind
            AND agr_expiry_date IS NULL;

         IF v_min_days_acting_sub = 999 THEN
            -- Substantive assignment is in a group that cannot have acting
            -- assignments. Return error message.
            v_error_num := 33;
            v_error_message_etxt := ' • '||fn_get_hrsr_error_message_etxt(33)||' <BR> ';
            v_error_message_ftxt := ' • '||fn_get_hrsr_error_message_ftxt(33)||' <BR> ';
            RETURN; -- end the procedure, and return just this message


         ELSE

         -- Check if the Acting assignment meets the minimum number of days
         -- according to the collective agreement of the substantive group:

         -- Get the number of stat holidays that occur between the start and
         -- end date of the assignment for the geo code prov of the position:
         SELECT NVL(SUBSTR(MAX(pos_geo_code),1,2), '35')
           INTO v_province_cd
           FROM ah027_hrsr_request,
                positions
          WHERE rqt_hrsr_request_cd = v_hrsr_request_cd
            AND pos_position_nmbr = NVL(v_position_nmbr,rqt_position_nmbr);

         SELECT COUNT(*)
           INTO v_stat_holiday_count
           FROM stat_holidays
          WHERE sth_geo_province_code = v_province_cd
            AND sth_holiday_date BETWEEN v_asn_start_dte AND v_asn_end_dte;


           IF v_extension_cd = 'N' THEN
              -- Only new Acting assignments have to meet the minimum number OF
              -- days acting requirement. Extensions would be assumed to have
              -- already met the requirement.

              IF incumbent_assignment_rec.asn_classn_group_ind IN ('EX', 'DM', 'OC') AND
                 v_min_days_acting_sub = 89 AND
                 MONTHS_BETWEEN(v_asn_end_dte, v_asn_start_dte) < 3 THEN
                 -- EX Acting assignment must be longer than minimum period for
                 -- the stubstantive assignment collective agreement, in
                 -- Calendar Days:
                 v_error_num := 67;
                 v_error_message_etxt := v_error_message_etxt||' • '||
                   REPLACE(
                     fn_get_hrsr_error_message_etxt(67),
                     '<v_sub_group_ind>', incumbent_assignment_rec.asn_classn_group_ind)||' <BR> ';
                 v_error_message_ftxt := v_error_message_ftxt||' • '||
                   REPLACE(
                     fn_get_hrsr_error_message_ftxt(67),
                     '<v_sub_group_ind>', incumbent_assignment_rec.asn_classn_group_ind)||' <BR> ';
              END IF;

              IF v_min_days_acting_sub != 89 AND
                 tips.get_working_days_between_dates(v_asn_start_dte,
                                                      v_asn_end_dte) -
                  v_stat_holiday_count < v_min_days_acting_sub THEN
                  -- Acting assignment must be longer than minimum period for the
                  -- stubstantive assignment collective agreement, minus any stat
                  -- holidays:
                  v_error_num := 12;
                  v_error_message_etxt := v_error_message_etxt||' • '||
                    REPLACE(
                     REPLACE(
                      fn_get_hrsr_error_message_etxt(12),
                      '<v_sub_group_ind>', incumbent_assignment_rec.asn_classn_group_ind),
                      '<v_min_days_acting>',  v_min_days_acting_sub) ||' <BR> ';
                  v_error_message_ftxt := v_error_message_ftxt||' • '||
                    REPLACE(
                     REPLACE(
                      fn_get_hrsr_error_message_ftxt(12),
                      '<v_sub_group_ind>', incumbent_assignment_rec.asn_classn_group_ind),
                      '<v_min_days_acting>',  v_min_days_acting_sub)||' <BR> ';
              END IF;
           END IF;
         END IF;

         -- Check if the Acting and the Substantive assignment of the employee
         -- passes the promo rules (promotion, demotion, or deployment).
         -- Check if the acting assignment meets the definition of a Promotion:

         -- Check to make sure there is a pay rate for the Group + Level + Bud
         -- Code combination:
         SELECT COUNT(*)
           INTO v_pay_rate_exists
           FROM vw_hrsr_deployment_calculator
          WHERE pra_group_ind = v_acting_group_ind
            AND pra_subgroup_ind = v_acting_subgroup_ind
            AND pra_level_ind = v_acting_level_ind
            AND pra_bud_code = v_acting_bud_code_txt;

         IF v_pay_rate_exists = 0 THEN
            -- Return the error that this classn and bud code does not have an
            -- active pay rate, is not valid with this bud code.
            v_error_num := 64;
            v_error_message_etxt := v_error_message_etxt||' • '||
              REPLACE(
              REPLACE(
                fn_get_hrsr_error_message_etxt(64),
                '<v_ti_profile_enm>',    v_ti_profile_enm),
                '<v_acting_classn>',      v_acting_group_ind||
                                          REPLACE(v_acting_subgroup_ind,'   ','-')||
                                          v_acting_level_ind)||' <BR> ';
            v_error_message_ftxt := v_error_message_ftxt||' • '||
              REPLACE(
              REPLACE(
                fn_get_hrsr_error_message_ftxt(64),
                '<v_ti_profile_fnm>',    v_ti_profile_fnm),
                '<v_acting_classn>',      v_acting_group_ind||
                                          REPLACE(v_acting_subgroup_ind,'   ','-')||
                                          v_acting_level_ind)||' <BR> ';
         ELSE

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
            v_error_num := 15;
            v_error_message_etxt := v_error_message_etxt||' • '||
              REPLACE(
              REPLACE(
              REPLACE(
              REPLACE(
                fn_get_hrsr_error_message_etxt(15),
                '<v_acting_classn>',      v_acting_group_ind||
                                          REPLACE(v_acting_subgroup_ind,'   ','-')||
                                          v_acting_level_ind),
                '<v_substantive_classn>', incumbent_assignment_rec.asn_classn_group_ind||
                                          REPLACE(incumbent_assignment_rec.asn_classn_subgroup_ind,'   ','-')||
                                          incumbent_assignment_rec.asn_classn_level_ind),
                '<v_promotion_txt>',      LOWER(v_promotion_txt)),
                'N/A',                    'unknown error')||' <BR> ';
            v_error_message_ftxt := v_error_message_ftxt||' • '||
              REPLACE(
              REPLACE(
              REPLACE(
              REPLACE(
              REPLACE(
              REPLACE(
                fn_get_hrsr_error_message_ftxt(15),
                '<v_acting_classn>',      v_acting_group_ind||
                                          REPLACE(v_acting_subgroup_ind,'   ','-')||
                                          v_acting_level_ind),
                '<v_substantive_classn>', incumbent_assignment_rec.asn_classn_group_ind||
                                          REPLACE(incumbent_assignment_rec.asn_classn_subgroup_ind,'   ','-')||
                                          incumbent_assignment_rec.asn_classn_level_ind),
                '<v_promotion_txt>',      v_promotion_txt),
                'DEMOTION',               'démotion'),
                'DEPLOYMENT',             'déploiement'),
                'N/A',                    'inconnu erreur') ||' <BR> ';
         END IF;
         END IF;
       END IF;
     END LOOP;

  -- Overlapping acting assignments:
  --
  -- Overlapping assignments will return an error message if it is a long term
  -- acting (acting where the length of the assignment is > 4 mths) OR
  -- if the assignment is an acting under 4 months but are "at level"; defined
  -- as either at the same classn group and level or when the MAX pay rate of
  -- the new acting assignment classn is less then or the same as as the max pay
  -- rate of the the existing assigment classn (no pay bump).
  --
  -- These checks will be made if the position is either:
  -- 1.) An EX position and is assiged to HR (EX processes assigned to anyone
  --     other than HR will recieve a warning only) OR
  -- 2.) All non-EX positions
  --
  -- Overlapping assignments are defined as:
  -- * The entire new acting assignment falls within an exsiting Acting assignment
  -- * The new assignment Start Date falls within the existing Acting assignment
  -- * The new assignment End Date falls within the existing Acting assignment
  -- * The existing acting assignment falls within the new Acting assignment
  FOR overlapping_acting_rec IN (
      SELECT DISTINCT
             asn_classn_group_ind,
             asn_classn_subgroup_ind,
             asn_classn_level_ind,
             asn_effective_start_date,
             asn_effective_end_date
        FROM tips.assignments
       WHERE asn_employee_pin = v_employee_pin
        -- AND asn_position_nmbr != v_position_nmbr
         AND asn_assignment_type_code IN ('A1','A2')
         AND NVL(asn_hrsr_request_cd,'NULL') != v_hrsr_request_cd
         AND ((v_asn_start_dte BETWEEN asn_effective_start_date AND
               NVL(asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY')))
              OR (v_asn_end_dte BETWEEN asn_effective_start_date AND
                  NVL(asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY')))
              OR (asn_effective_start_date BETWEEN v_asn_start_dte AND v_asn_end_dte AND
                  asn_effective_end_date BETWEEN v_asn_start_dte AND v_asn_end_dte))
       ORDER BY NVL(asn_effective_end_date, '31-DEC-2099') DESC,
                    asn_effective_start_date DESC
  ) LOOP

    IF overlapping_acting_rec.asn_classn_group_ind NOT IN ('EX', 'DM', 'OC') OR
       (overlapping_acting_rec.asn_classn_group_ind IN ('EX', 'DM', 'OC') AND
        v_hrsr_actor_cd = 4) THEN

       -- Overlap is a Long Term Acting, and "at level" or lower:
       IF MONTHS_BETWEEN(overlapping_acting_rec.asn_effective_end_date,
                         overlapping_acting_rec.asn_effective_start_date) >= 4 AND
          ((v_acting_group_ind = overlapping_acting_rec.asn_classn_group_ind AND
            v_acting_level_ind <= overlapping_acting_rec.asn_classn_level_ind ) OR
            (fn_get_max_salary_for_classn(v_acting_group_ind,
                                          v_acting_subgroup_ind,
                                          v_acting_level_ind ) <
             fn_get_max_salary_for_classn(overlapping_acting_rec.asn_classn_group_ind,
                                          overlapping_acting_rec.asn_classn_subgroup_ind,
                                          overlapping_acting_rec.asn_classn_level_ind))) THEN
          -- Existing acting assignment is greater than 4 months.
          -- Cannot overlap a new acting assignment. Dates must be corrected.
          v_error_num := 66;
          v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(66)||' <BR> ';
          v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(66)||' <BR> ';

       -- Overlap is an acting is is less than 4 months and "at level" or lower:
       ELSE
         IF (v_acting_group_ind = overlapping_acting_rec.asn_classn_group_ind AND
             v_acting_level_ind <= overlapping_acting_rec.asn_classn_level_ind ) OR
            (fn_get_max_salary_for_classn(v_acting_group_ind,
                                          v_acting_subgroup_ind,
                                          v_acting_level_ind ) <
             fn_get_max_salary_for_classn(overlapping_acting_rec.asn_classn_group_ind,
                                          overlapping_acting_rec.asn_classn_subgroup_ind,
                                          overlapping_acting_rec.asn_classn_level_ind) ) THEN

             -- The overlapping acting assignment is at the same level or the
             -- same classification. Check dates of overlap and return error:
             IF v_asn_start_dte BETWEEN
                overlapping_acting_rec.asn_effective_start_date AND
                overlapping_acting_rec.asn_effective_end_date AND
                v_asn_end_dte BETWEEN
                overlapping_acting_rec.asn_effective_start_date AND
                overlapping_acting_rec.asn_effective_end_date THEN
                -- The new assignment falls completely within an existing
                -- assignment. Contact HR to resolve this situation.
                v_error_num := 54;
                v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(54)||' <BR> ';
                v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(54)||' <BR> ';

             ELSIF v_asn_start_dte < overlapping_acting_rec.asn_effective_start_date AND
                v_asn_end_dte > overlapping_acting_rec.asn_effective_end_date THEN
                -- The new assignment completely covers an existing assignment.
                -- Split the new assignment into two assignments on either side
                -- of the existing assignment.
                v_error_num := 56;
                v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(56)||' <BR> ';
                v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(56)||' <BR> ';

             ELSIF v_asn_start_dte BETWEEN
                overlapping_acting_rec.asn_effective_start_date AND
                overlapping_acting_rec.asn_effective_end_date AND
                v_end_at_level_act_ind = 0 THEN
                -- The start date of the new assignment begins during an existing
                -- assignment. Change the start date of the new assignment to
                -- after the existing assignment or click the “End Overlapping
                -- Assignment Early” checkbox.
                v_error_num := 55;
                v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(55)||' <BR> ';
                v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(55)||' <BR> ';

             ELSIF v_asn_end_dte BETWEEN
                overlapping_acting_rec.asn_effective_start_date AND
                overlapping_acting_rec.asn_effective_end_date THEN
                -- The end of the new assignment overlaps into an existing
                -- assignment. Change the end date of the new assignment to
                -- before the existing assignment's start date.
                v_error_num := 57;
                v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(57)||' <BR> ';
                v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(57)||' <BR> ';

             ELSIF v_end_at_level_act_ind = 0 THEN
                v_error_num := 51;
                v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(51)||' <BR> ';
                v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(51)||' <BR> ';
             END IF;

         END IF ;
       END IF;
    END IF;
  END LOOP;

     IF v_incumbent_asn_exists = 0 THEN
        -- Acting assignments must have an overlapping incumbent assignment FOR
        -- the candidate.
        v_error_num := 16;
        v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(16)||' <BR> ';
        v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(16)||' <BR> ';

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
     v_error_message_etxt := 'UNKNOWN ERROR: HRSR:'||v_hrsr_request_cd||', '||
                             'PRI: '||v_employee_pin||', '||
                             'Position: '||v_position_nmbr||', '||
                             'Start Dte: '||TO_CHAR(v_asn_start_dte)||', '||
                             'End Dte: '||TO_CHAR(v_asn_end_dte)||' -->'||
                             SQLERRM||', '||
                             DBMS_UTILITY.FORMAT_ERROR_STACK() ||', '||
                             DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
     v_error_message_ftxt := 'INCONNU ERREUR : HRSR:'||v_hrsr_request_cd||', '||
                             'CIDP : '||v_employee_pin||', '||
                             'Poste : '||v_position_nmbr||', '||
                             'Date de début : '||TO_CHAR(v_asn_start_dte)||', '||
                             'Date de fin : '||TO_CHAR(v_asn_end_dte)||' -->'||
                             SQLERRM||', '||
                             DBMS_UTILITY.FORMAT_ERROR_STACK() ||', '||
                             DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

END;
/

CREATE OR REPLACE PUBLIC SYNONYM sp_validate_acting_assignment
  FOR sp_validate_acting_assignment
/  

-- Grants for Procedure
GRANT EXECUTE ON sp_validate_acting_assignment TO tipsuser
/
GRANT EXECUTE ON sp_validate_acting_assignment TO everything_in_tips
/


-- End of DDL Script for Procedure TIPS.SP_VALIDATE_ACTING_ASSIGNMENT


-- End of DDL Script for Procedure TIPS.SP_VALIDATE_ACTING_ASSIGNMENT

