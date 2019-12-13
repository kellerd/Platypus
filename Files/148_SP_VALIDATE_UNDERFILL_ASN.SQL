-- Start of DDL Script for Procedure TIPS.SP_VALIDATE_UNDERFILL_ASN
-- Generated 2019-11-15 1:08:25 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE sp_validate_underfill_asn
  ( v_employee_pin            assignments.asn_employee_pin%TYPE,
    v_position_nmbr           assignments.asn_position_nmbr%TYPE,
    v_asn_start_dte           assignments.asn_effective_start_date%TYPE,
    v_asn_end_dte             assignments.asn_effective_end_date%TYPE,
    v_hrsr_request_cd         ah029_hrsr_staffing.stf_hrsr_request_cd%TYPE,
    v_underfill_group_ind     ah029_hrsr_staffing.stf_underfill_group_ind%TYPE,
    v_underfill_subgroup_ind  ah029_hrsr_staffing.stf_underfill_subgroup_ind%TYPE,
    v_underfill_level_ind     ah029_hrsr_staffing.stf_underfill_level_ind%TYPE,
    v_error_num          OUT  th191_hrsr_error_message.hrsr_error_message_num%TYPE,
    v_error_message_etxt OUT  th191_hrsr_error_message.hrsr_error_message_etxt%TYPE,
    v_error_message_ftxt OUT  th191_hrsr_error_message.hrsr_error_message_ftxt%TYPE
  )
IS
--
-- Purpose: Procedure to validate the acting assignment underfill payment option
--
--   Return value: Success = 0
--                 Unsuccessful = Error message number and text
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ---------------------------------------------------------
--

   v_incumbent_asn_exists  INTEGER := 0;
   v_promotion_txt         VARCHAR2(30);
   v_acting_bud_code_txt   assignments.asn_bud_code%TYPE;
   v_acting_group_ind      assignments.asn_classn_group_ind%TYPE;
   v_acting_subgroup_ind   assignments.asn_classn_subgroup_ind%TYPE;
   v_acting_level_ind      assignments.asn_classn_level_ind%TYPE;
   v_position_count        INTEGER;

BEGIN

  -- Do basic checks to make sure there is a value in all the variables:
  IF v_asn_start_dte IS NULL THEN
     -- The HRSR is missing data: Start date
     v_error_num := 3;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(3);
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(3);
     RETURN;
  ELSIF v_asn_end_dte IS NULL THEN
     -- The HRSR is missing data: End date
     v_error_num := 4;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(4);
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(4);
     RETURN;
  ELSIF v_employee_pin IS NULL THEN
     -- The HRSR is missing data: Candidate PIN
     v_error_num := 2;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(2);
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(2);
     RETURN;
  ELSIF v_position_nmbr IS NULL THEN
     -- The HRSR is missing data: Position Number
     v_error_num := 5;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(5);
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(5);
     RETURN;
  END IF;


  -- Do basic checks to make sure the position number exists in POSITIONS:
  SELECT COUNT(*)
    INTO v_position_count
    FROM positions
   WHERE pos_position_nmbr = v_position_nmbr;

  IF v_position_count = 0 THEN
     -- The position number chosen does not exist or may be archived
     v_error_num := 6;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(6);
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(6);
     RETURN;
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

  -- Underfill classification cannot be the same as the acting position
  -- classification:
  IF v_acting_group_ind = v_underfill_group_ind AND
     v_acting_level_ind = v_underfill_level_ind THEN
     -- Pay As / Underfill classification cannot be the same as acting classn:
     v_error_num := 17;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(17);
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(17);
     RETURN;
  END IF;

  IF v_acting_group_ind = v_underfill_group_ind AND
     v_acting_level_ind < v_underfill_level_ind THEN
     -- Pay As / Underfill classification cannot be greater than acting classn:
     v_error_num := 18;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(18);
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(18);
     RETURN;
  END IF;

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

  -- Check if the Acting and the Substantive assignment of the employee passes
  -- the PROMO rules (promotion, demotion, or deployment).
  -- 3 checks:
  --   1.) Acting is a promo over the substantive classn
  --   2.) Acting is a promo over the pay as / underfill classn
  --   3.) Pay as / underfill is a promo over the substantive classn

  -- Loop through the employee's substantive assignments:
  -- Get the incumbent assignment information to compare the Acting against:
  FOR incumbent_assignment_rec IN (
       SELECT *
         FROM tips.assignments
        WHERE asn_position_nmbr != v_position_nmbr
          AND asn_employee_pin = v_employee_pin
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

       -- 1.) Check if the Acting assignment meets the definition of a Promotion
       -- against the Incumbent assignment:

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
          RETURN;
       END IF;

       -- 2.) Check if the Acting assignment meets the definition of a Promotion
       -- against the pay as / underfill assignment. The Acting pay should be a
       -- greater than the the underfill. So if the Underfill classn comes back
       -- as a promotion, return error:
       v_promotion_txt :=
           tips.fn_deployment_calculator(
                v_acting_group_ind,
                v_acting_subgroup_ind,
                v_acting_level_ind,
                v_acting_bud_code_txt,
                v_underfill_group_ind,
                v_underfill_subgroup_ind,
                v_underfill_level_ind,
                NULL);

       IF v_promotion_txt = 'PROMOTION' THEN
          -- Return an error message:
          v_error_num := 18;
          v_error_message_etxt := v_error_message_etxt||' • '||
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
              fn_get_hrsr_error_message_etxt(18),
              '<v_acting_classn>',      v_acting_group_ind||
                                        REPLACE(v_acting_subgroup_ind,'   ','-')||
                                        v_acting_level_ind),
              '<v_underfill_classn>',   v_underfill_group_ind||
                                        REPLACE(v_underfill_subgroup_ind,'   ','-')||
                                        v_underfill_level_ind),
              '<v_promotion_txt>',      LOWER(v_promotion_txt)),
              'N/A',                    'unknown error')||' <BR> ';
          v_error_message_ftxt := v_error_message_ftxt||' • '||
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
              fn_get_hrsr_error_message_ftxt(18),
              '<v_acting_classn>',      v_acting_group_ind||
                                        REPLACE(v_acting_subgroup_ind,'   ','-')||
                                        v_acting_level_ind),
              '<v_underfill_classn>',   v_underfill_group_ind||
                                        REPLACE(v_underfill_subgroup_ind,'   ','-')||
                                        v_underfill_level_ind),
              '<v_promotion_txt>',      v_promotion_txt),
              'DEMOTION',               'démotion'),
              'DEPLOYMENT',             'déploiement'),
              'N/A',                    'inconnu erreur') ||' <BR> ';
          RETURN;
       END IF;

       -- 3.) Check if the underfill classification meets the definition
       -- of a Promotion against the incumbent classification :
       v_promotion_txt :=
           tips.fn_deployment_calculator(
                incumbent_assignment_rec.asn_classn_group_ind,
                incumbent_assignment_rec.asn_classn_subgroup_ind,
                incumbent_assignment_rec.asn_classn_level_ind,
                incumbent_assignment_rec.asn_bud_code,
                v_underfill_group_ind,
                v_underfill_subgroup_ind,
                v_underfill_level_ind,
                NULL);

       IF v_promotion_txt != 'PROMOTION' THEN
          -- Return an error message:
          v_error_num := 20;
          v_error_message_etxt := v_error_message_etxt||' • '||
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
              fn_get_hrsr_error_message_etxt(20),
              '<v_substantive_classn>', incumbent_assignment_rec.asn_classn_group_ind||
                                        REPLACE(incumbent_assignment_rec.asn_classn_subgroup_ind,'   ','-')||
                                        incumbent_assignment_rec.asn_classn_level_ind),
              '<v_underfill_classn>',   v_underfill_group_ind||
                                        REPLACE(v_underfill_subgroup_ind,'   ','-')||
                                        v_underfill_level_ind),
              '<v_promotion_txt>',      LOWER(v_promotion_txt)),
              'N/A',                    'unknown error')||' <BR> ';
          v_error_message_ftxt := v_error_message_ftxt||' • '||
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
            REPLACE(
              fn_get_hrsr_error_message_ftxt(20),
              '<v_substantive_classn>', incumbent_assignment_rec.asn_classn_group_ind||
                                        REPLACE(incumbent_assignment_rec.asn_classn_subgroup_ind,'   ','-')||
                                        incumbent_assignment_rec.asn_classn_level_ind),
              '<v_underfill_classn>',   v_underfill_group_ind||
                                        REPLACE(v_underfill_subgroup_ind,'   ','-')||
                                        v_underfill_level_ind),
              '<v_promotion_txt>',      v_promotion_txt),
              'DEMOTION',               'démotion'),
              'DEPLOYMENT',             'déploiement'),
              'N/A',                    'inconnu erreur') ||' <BR> ';
          RETURN;
       END IF;


     END LOOP;

     -- Success:
     v_error_num := 0;
     v_error_message_etxt := v_error_message_etxt||' • '||fn_get_hrsr_error_message_etxt(0);
     v_error_message_ftxt := v_error_message_ftxt||' • '||fn_get_hrsr_error_message_ftxt(0);
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
     RETURN ;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM sp_validate_underfill_asn
  FOR tips.sp_validate_underfill_asn
/  

-- Grants for Procedure
GRANT EXECUTE ON sp_validate_underfill_asn TO tipsuser
/
GRANT EXECUTE ON sp_validate_underfill_asn TO everything_in_tips
/


-- End of DDL Script for Procedure TIPS.SP_VALIDATE_UNDERFILL_ASN

