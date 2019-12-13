-- Start of DDL Script for Procedure TIPS.SP_VALIDATE_ACTING_WARNINGS
-- Generated 2019-11-25 11:12:40 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE sp_validate_acting_warnings
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
--          * Check if Start Date or End Date falls on a Weekend (new asn only)
--          * Check if start date or end date falls on a Stat Holiday
--          * Check if another person is acting in this position
--          * Check if the candidate meets the language profile of the position
--          * Check if the substantive position is a secondment (B1)
--          * Check if there are overlapping acting assignments (this check will
--            be made for EX positions when the actor is not HR (4). Other cases
---           of overlapping acting assignments will be returned as an error.
--
--   Return value: Success = 0
--                 Unsuccessful = Error message text (possibly multiple errors)
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--

   v_hrsr_actor_cd         ah027_hrsr_request.rqt_hrsr_actor_cd%TYPE;
   v_acting_group_ind      assignments.asn_classn_group_ind%TYPE;
   v_acting_subgroup_ind   assignments.asn_classn_subgroup_ind%TYPE;
   v_acting_level_ind      assignments.asn_classn_level_ind%TYPE;
   v_extension_cd          ah029_hrsr_staffing.stf_extension_cd%TYPE;

BEGIN

  -- Set the actor who the HRSR is currently assigned to:
  SELECT NVL(MAX(rqt_hrsr_actor_cd),1)
    INTO v_hrsr_actor_cd
    FROM ah027_hrsr_request
   WHERE rqt_hrsr_request_cd = v_hrsr_request_cd;

  SELECT stf_extension_cd
    INTO v_extension_cd
    FROM ah029_hrsr_staffing
   WHERE stf_hrsr_request_cd = v_hrsr_request_cd;

  -- Set the classn variables for the new acting assignment:
  SELECT MAX(pos_group_ind),
         MAX(pos_subgroup_ind),
         MAX(pos_level_ind)
    INTO v_acting_group_ind,
         v_acting_subgroup_ind,
         v_acting_level_ind
    FROM positions
   WHERE pos_position_nmbr = v_position_nmbr;

  -- Check if Start Date falls on a Weekend:
  IF TRIM(TO_CHAR(v_asn_start_dte, 'DAY')) IN ('SATURDAY','SUNDAY') AND
     v_extension_cd = 'N' THEN
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
    IF TRUNC(v_asn_start_dte) =  TRUNC(stat_holiday_rec.sth_holiday_date) AND
       v_extension_cd = 'N' THEN
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

  -- Loop through the employee's substantive assignments:
  -- Get the incumbent assignment information to compare the Acting against:
  FOR incumbent_assignment_rec IN (
       SELECT *
         FROM tips.assignments
        WHERE asn_employee_pin = v_employee_pin
          AND  NVL(asn_hrsr_request_cd,'NULL') != v_hrsr_request_cd
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

     -- Check if the substantive position is a secondment (B1). Seconded
     -- employees cannot act in another position:
     IF incumbent_assignment_rec.asn_assignment_type_code = 'B1' THEN
        v_error_num := 32;
        v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(32)||' <BR> ';
        v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(32)||' <BR> ';
     END IF;
     EXIT WHEN v_error_num = 32;
  END LOOP;

  -- Check if there's another person Acting in the Acting position number.
  FOR overlapping_asn_rec IN (
      SELECT *
        FROM assignments
       WHERE asn_employee_pin != v_employee_pin
         AND asn_position_nmbr = v_position_nmbr
         AND NVL(asn_hrsr_request_cd,'NULL') != v_hrsr_request_cd
         AND (v_asn_start_dte BETWEEN asn_effective_start_date AND
              NVL(asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY'))
             OR
             (NVL(v_asn_end_dte, SYSDATE + 1) BETWEEN asn_effective_start_date AND
              NVL(asn_effective_end_date, NVL(v_asn_end_dte, SYSDATE + 1) + 10)))
  ) LOOP

    IF overlapping_asn_rec.asn_assignment_type_code IN ('A1', 'A2') AND
       (v_error_num IS NULL OR v_error_num != 11) THEN
       -- There is another person acting in the position. Return only 1 error FOR
       -- this scenario:
       v_error_num := 11;
       v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(11)||' <BR> ';
       v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(11)||' <BR> ';
    END IF;
    EXIT WHEN v_error_num = 11;
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

  -- Overlapping acting assignments:
  --
  -- Overlapping assignments will return an warning message if it is a long term
  -- acting (acting where the length of the assignment is > 4 mths) OR
  -- if the assignment is an acting under 4 months but are "at level"; defined
  -- as either at the same classn group and level or when the MAX pay rate of
  -- the new acting assignment classn is less then or the same as as the max pay
  -- rate of the the existing assigment classn (no pay bump).
  --
  -- These checks will be made if the position an EX position and is assiged TO
  -- anyone other than HR (actor = 4). Note: EX processes assigned to HR will
  -- return an error message.
  --
  -- Overlapping assignments are defined as:
  -- * The entire new acting assignment falls within an exsiting Acting assignment
  -- * The new assignment Start Date falls within the existing Acting assignment
  -- * The new assignment End Date falls within the existing Acting assignment
  -- * The existing acting assignment falls within the new Acting assignment
  FOR overlapping_acting_rec IN (
      SELECT *
        FROM tips.assignments
       WHERE asn_position_nmbr = v_position_nmbr
         AND asn_employee_pin = v_employee_pin
         AND asn_assignment_type_code IN ('A1','A2')
         AND NVL(asn_hrsr_request_cd,'NULL') != v_hrsr_request_cd
         AND ((v_asn_start_dte BETWEEN asn_effective_start_date AND
               NVL(asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY')))
              OR (v_asn_end_dte BETWEEN asn_effective_start_date AND
                  NVL(asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY')))
              OR (asn_effective_start_date BETWEEN v_asn_start_dte AND v_asn_end_dte AND
                  asn_effective_end_date BETWEEN v_asn_start_dte AND v_asn_end_dte))
       ORDER BY NVL(asn_effective_end_date, TO_DATE('31-DEC-2099','DD-MON-YYYY')) DESC,
                    asn_effective_start_date DESC
  ) LOOP

    IF overlapping_acting_rec.asn_classn_group_ind IN ('EX', 'DM', 'OC') AND
       v_hrsr_actor_cd != 4 THEN

       -- Overlap is a Long Term Acting, "at level" or less than:
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
          v_error_num := 48;
          v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(48)||' <BR> ';
          v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(48)||' <BR> ';

       ELSE
         -- Overlap is an acting is is less than 4 months and "at level" or lower:
         IF v_acting_group_ind = overlapping_acting_rec.asn_classn_group_ind AND
            v_acting_level_ind <= overlapping_acting_rec.asn_classn_level_ind THEN
            -- Overlapping assignments cannot be the same classification:
            v_error_num := 48;
            v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(48)||' <BR> ';
            v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(48)||' <BR> ';

         ELSIF fn_get_max_salary_for_classn(v_acting_group_ind,
                                            v_acting_subgroup_ind,
                                            v_acting_level_ind ) <
               fn_get_max_salary_for_classn(overlapping_acting_rec.asn_classn_group_ind,
                                            overlapping_acting_rec.asn_classn_subgroup_ind,
                                            overlapping_acting_rec.asn_classn_level_ind) THEN
            v_error_num := 48;
            v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(48)||' <BR> ';
            v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(48)||' <BR> ';

         END IF ;
       END IF;
    END IF;
  EXIT WHEN v_error_num = 48;
  END LOOP;


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
                             'Start Dte: '||TO_CHAR(v_asn_start_dte, 'DD-MON-YYYY HH:MI:SS am')||', '||
                             'End Dte: '||TO_CHAR(v_asn_end_dte, 'DD-MON-YYYY HH:MI:SS am')||' -->'||
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
     RETURN ;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM SP_VALIDATE_ACTING_WARNINGS
  FOR TIPS.SP_VALIDATE_ACTING_WARNINGS
/ 

-- Grants for Procedure
GRANT EXECUTE ON sp_validate_acting_warnings TO tipsuser
/
GRANT EXECUTE ON sp_validate_acting_warnings TO everything_in_tips
/

