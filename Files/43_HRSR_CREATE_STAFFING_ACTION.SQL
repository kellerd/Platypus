-- Start of DDL Script for Procedure TIPS.HRSR_CREATE_STAFFING_ACTION
-- Generated 2019-11-07 2:03:38 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
PROCEDURE hrsr_create_staffing_action (
  v_hrsr_request_cd     IN ah027_hrsr_request.rqt_hrsr_request_cd%TYPE,
  v_error_num          OUT  th191_hrsr_error_message.hrsr_error_message_num%TYPE,
  v_error_message_etxt OUT  VARCHAR2,
  v_error_message_ftxt OUT  VARCHAR2
)
IS
-- Created by: Jennifer Hynes
--             April 16, 2019
--
-- Purpose: Procedure to create HRSR Staffing Action and associated records.
--          HRSR version 2.0
--
--          Will be called to create the following actions:
--
--          TH048_HRSR_ACTION / FUNCTION_ACTIONS
--          26 : Acting (New or Extension)
--           (HRSR 1.0 = 10)
--               T03    New Acting Assignment
--               T04    Acting Extension
--
--          27 : Casual (New or Extension)
--           (HRSR 1.0 = 13)
--               T01    New Casual Assignment
--               T02    Casual Extension
--
--          28 : Student (New or Extension)
--           (HRSR 1.0 = 20)
--               T12    New Student Assignment
--               T13    Student Extension
--
--          Tables will already be populated for the request in:
--             AH027_HRSR_REQUEST
--             AH029_HRSR_STAFFING
--             AH031_HRSR_CASUAL
--             AH095_HRSR_STUDENT_DETAIL
--
--          Records will be created in the following tables:
--             AH030_HRSR_PHANTOM_POSITION
--             AH035_HRSR_REQUEST_HISTORY
--             AH080_HRSR_STATUS_HISTORY -- auto loaded via trigger AH027
--             CASE_FILES - EXC BF
--             CASE_FILES - BF to Pay
--             AH067_XREF_AH027_CAF
--             ASSIGNMENTS
--             POSITIONS
--
--
-- MODIFICATION HISTORY
--
-- Person      Date       Comments
-- ----------  ---------  ------------------------------------------------------
--
   v_caf_case_nmbr         case_files.caf_case_nmbr%TYPE;
   v_pay_case_nmbr         case_files.caf_case_nmbr%TYPE;
   v_close_hrsr_success_cd INTEGER;
   v_phantom_position_nmbr positions.pos_position_nmbr%TYPE;
   v_error_message_nmbr    error_messages.err_message_nmbr%TYPE;
   v_email_error_nmbr      error_messages.err_message_nmbr%TYPE;
   v_current_user_id       users.usr_user_id%TYPE := FN_GET_USER;
   v_incumbent_asn_exists  INTEGER := 0;
   v_position_region_cd    regions.reg_region_ind%TYPE;
   v_acting_salary_amt     pay_rates.pra_salary_amount%TYPE;
   v_sub_salary_amt        pay_rates.pra_salary_amount%TYPE;

BEGIN

 FOR hrsr_request_details IN (
     SELECT ah027.rqt_hrsr_request_cd           AS hrsr_request_cd,
            ah027.rqt_position_nmbr             AS position_nmbr,
            ah029.stf_candidate_pin             AS candidate_pin,
            ah029.stf_candidate_family_name_txt AS candidate_family_name_txt,
            ah029.stf_candidate_given_name_txt  AS candidate_given_name_txt,
            ah029.stf_candidate_initial_name_txt AS candidate_initial_name_txt,
            ah029.stf_date_candidate_birth_dte  AS date_candidate_birth_dte,
            ah029.stf_preferred_language_cd     AS preferred_language_cd,
            ah027.rqt_initiator_pin             AS initiator_pin,
            ah027.rqt_recommender_pin           AS recommender_pin,
            ah027.rqt_approver_pin              AS approver_pin,
            (SELECT NVL(MIN(asn_region_ind),'A')
               FROM assignments
              WHERE asn_employee_pin =
                    ah027.rqt_approver_pin
                AND SYSDATE BETWEEN asn_effective_start_date AND
                    NVL(asn_effective_end_date, SYSDATE + 1))
                                                AS approver_region_ind,
            TRIM(tips.get_person_name(ah027.rqt_approver_pin)) AS approver_name,
            ah027.rqt_action_cd                 AS hrsr_action_cd,
            ah029.stf_extension_cd              AS extension_cd,
            CASE
              WHEN ah029.stf_extension_cd IN ('E', 'X') THEN  -- Extension
                TRUNC(ah029.stf_asn_end_date_dte + 1) + 11/24 -- Prev end date + 1
              ELSE
                TRUNC(ah029.stf_asn_start_date_dte) + 11/24
              END                               AS asn_start_dte,
            CASE
              WHEN ah029.stf_extension_cd IN ('E', 'X') THEN -- Extension
                TRUNC(ah029.stf_asn_new_end_date_dte) + 23/24
              ELSE
                TRUNC(ah029.stf_asn_end_date_dte) + 23/24
              END                               AS asn_end_dte,
            CASE
              WHEN ah027.rqt_action_cd IN ('13', '27') AND  -- Casual
                   ah031.csl_assigned_work_week_hrs_num IS NOT NULL THEN
                   ah031.csl_assigned_work_week_hrs_num
              WHEN ah027.rqt_action_cd IN ('10','26') THEN  -- Acting
                  (SELECT NVL(MAX(grp_max_work_week_hours),'37.5')
                     FROM groups
                    WHERE grp_group_ind = pos.pos_group_ind)
              ELSE NVL(ah029.stf_assigned_work_week_hrs_num, '37.5')
              END                               AS aww,
            CASE
              WHEN ah029.stf_phantom_required_ind = 1 THEN
                   (SELECT NVL(MAX(grp_max_work_week_hours),'37.5')
                      FROM groups
                     WHERE grp_group_ind = ah030.php_group_ind)
              ELSE
                   (SELECT NVL(MAX(grp_max_work_week_hours),'37.5')
                      FROM groups
                     WHERE grp_group_ind = pos.pos_group_ind)
              END AS sww,
            ah029.stf_employee_cost_code_txt  AS employee_cost_code_txt,
            -- START TA BF INFO
            CASE
              WHEN ah027.rqt_action_cd IN ('10','26',      -- Acting
                                           '20','28') THEN -- Student
                   '2' -- Position
              WHEN ah027.rqt_action_cd IN ('13','27') THEN -- Casual
                   '4' -- Person
              END AS ta_object_ind,
            CASE
              WHEN ah027.rqt_action_cd IN ('10','26',      -- Acting
                                           '20','28') THEN -- Student
                   ah027.rqt_position_nmbr -- Position
              WHEN ah027.rqt_action_cd IN ('13','27') THEN -- Casual
                   ah029.stf_candidate_pin -- Person
              END AS  ta_object_cd,
            (SELECT MAX(xaf_action_ind)
               FROM th056_xref_th048_fua th056
              WHERE th056.xaf_action_cd = ah027.rqt_action_cd
                AND th056.ext_extension_cd = ah029.stf_extension_cd) AS ta_bf_type,
            CASE
             WHEN ah027.rqt_action_cd IN ('10', '26') THEN -- Acting
               ah027.rqt_hrsr_request_cd||' Acting assignment from HRSR.'
             WHEN ah027.rqt_action_cd IN ('20', '28') THEN
               ah027.rqt_hrsr_request_cd||' Student assignment from HRSR. '
             WHEN ah027.rqt_action_cd IN ('13', '27')  THEN
              ah027.rqt_hrsr_request_cd||' Casual assignment from HRSR.'
            END AS ta_case_txt,
            ah027.rqt_hrsr_request_cd||' '||ah029.stf_candidate_pin||' '||
               ah029.stf_candidate_family_name_txt||', '||
               ah029.stf_candidate_given_name_txt AS ta_case_ref_txt,
            -- END TA BF INFO
            CASE
              WHEN ah027.rqt_action_cd IN ('10','26') THEN     -- Acting
                CASE
                  WHEN ah029.stf_extension_cd = 'N' THEN 'A5' -- New: Acting Pay/Appointment
                  WHEN ah029.stf_extension_cd = 'E' THEN 'EA' -- Extension: Ext. of A/Pay-Appt
                  END
              WHEN ah027.rqt_action_cd IN ('20','28') THEN    -- Student
                CASE
                  WHEN ah029.stf_extension_cd = 'N' THEN 'E3' -- New: Taken ON Strength
                  WHEN ah029.stf_extension_cd = 'E' THEN      -- Extensions:
                    CASE
                      WHEN fn_get_previous_asn_type(
                             ah029.stf_candidate_pin,
                             ah029.stf_asn_start_date_dte) = 'X1' THEN
                           -- Previous assignment was a casual
                           'H3'                                -- TEN: Change in Tenure
                      WHEN fn_get_previous_asn_type(
                             ah029.stf_candidate_pin,
                             ah029.stf_asn_start_date_dte) IN
                              (SELECT ast_assignment_type_code
                                 FROM assignment_types
                                WHERE ast_assignment_type_code LIKE 'J%'
                                  AND ast_assignment_type_code !=
                                      ah029.stf_assignment_type_code) THEN
                           -- Previous assignment was a student, but a different
                           -- assignment type
                           'C9'                               -- MSA: Misc Staffing Action
                      ELSE 'ES'                               -- Extension: Student Extension
                      END
                  END
              WHEN ah027.rqt_action_cd IN ('13','27') THEN    -- Casual
                CASE
                  WHEN ah029.stf_extension_cd = 'C' THEN 'E3' -- New: Taken ON Strength
                  WHEN ah029.stf_extension_cd = 'X' THEN      -- Extension
                    CASE
                      WHEN fn_get_previous_asn_type(
                             ah029.stf_candidate_pin,
                             ah029.stf_asn_start_date_dte) IN
                              (SELECT ast_assignment_type_code
                                 FROM assignment_types
                                WHERE ast_assignment_type_code LIKE 'J%') THEN
                           'H3'                             -- TEN: Change in Tenure
                      ELSE 'EC'                             -- Extension: Casual Extension
                      END
                  END
              END AS pay_bf_type,
              ah027.rqt_hrsr_request_cd||' '||CHR(13)||
               CASE
                 WHEN ah027.rqt_action_cd IN ('13','27') THEN -- Casual
                     'Salary / Salaire: '||
                      TO_CHAR(ah031.csl_payment_amount_amt)||'/'||
                      LOWER(ah031.csl_disbursement_rate_cd)||' '||CHR(13)
                 WHEN ah027.rqt_action_cd IN ('20','28') THEN -- Student
                      'Salary / Salaire: '||
                      TO_CHAR(ah095.payment_amount_amt) ||'/'||
                      LOWER(ah095.disbursement_rate_cd)||' '||CHR(13)
                 END||
              CASE
                WHEN -- Acting Position IS NOT BILINGUAL
                  ah029.stf_candidate_pin IS NOT NULL AND
                  pos_position_nmbr IS NOT NULL AND
                  (SELECT COUNT(lpr_language_requirement_ind)
                     FROM linguistic_profiles
                    WHERE lpr_position_nmbr = pos_position_nmbr
                      AND lpr_language_requirement_ind = 1 -- Bilingual
                      AND lpr_status_ind = '1') = 0   THEN
                   '• Bilingual Bonus - Unilingual position / Prime au bilinguisme - Poste unilingue'||' '||CHR(13)
                WHEN -- Acting Position IS BILINGUAL
                  (SELECT COUNT(lpr_language_requirement_ind)
                     FROM linguistic_profiles
                    WHERE lpr_position_nmbr = pos_position_nmbr
                      AND lpr_language_requirement_ind = 1 -- Bilingual
                      AND lpr_status_ind = '1') > 0   THEN
                  -- Check if employee meets the acting language profile:
                  CASE
                    -- Employee MEETS Acting Profile:
                    WHEN fn_meets_language_profile(ah029.stf_candidate_pin,
                                                   ah027.rqt_position_nmbr,
                                                   ah027.rqt_hrsr_request_cd) = 0 AND
                        -- And employee meets Substantive Profile:
                        (SELECT fn_meets_language_profile
                                  (ah029.stf_candidate_pin,
                                   MAX(asn_position_nmbr),
                                   ah027.rqt_hrsr_request_cd)
                           FROM assignments
                          WHERE asn_employee_pin = ah029.stf_candidate_pin
                            AND EXISTS (SELECT 1
                                          FROM assignment_types
                                         WHERE ast_assignment_type_code =
                                               asn_assignment_type_code
                                           AND ast_incumbent_type_flag = '1')
                            AND DECODE(
                                  ah029.stf_extension_cd,
                                  'E', ah029.stf_asn_end_date_dte + 1, -- Previous end date + 1
                                  'X', ah029.stf_asn_end_date_dte + 1, -- Previous end date + 1
                                       ah029.stf_asn_start_date_dte) BETWEEN
                                asn_effective_start_date AND
                                NVL(asn_effective_end_date, TO_DATE('31-DEC-2099', 'DD-MON-YYYY')))  = 0 THEN
                         '• Bilingual Bonus - No change / Prime au bilinguisme - Aucun changement'
                    -- Employee MEETS Acting Profile:
                    WHEN fn_meets_language_profile(ah029.stf_candidate_pin,
                                                   ah027.rqt_position_nmbr,
                                                   ah027.rqt_hrsr_request_cd) = 0 AND
                        -- And employee does NOT MEET Substantive Profile:
                        (SELECT fn_meets_language_profile
                                  (ah029.stf_candidate_pin,
                                   MAX(asn_position_nmbr),
                                   ah027.rqt_hrsr_request_cd)
                           FROM assignments
                          WHERE asn_employee_pin = ah029.stf_candidate_pin
                            AND EXISTS (SELECT 1
                                          FROM assignment_types
                                         WHERE ast_assignment_type_code =
                                               asn_assignment_type_code
                                           AND ast_incumbent_type_flag = '1')
                            AND DECODE(
                                  ah029.stf_extension_cd,
                                  'E', ah029.stf_asn_end_date_dte + 1, -- Previous end date + 1
                                  'X', ah029.stf_asn_end_date_dte + 1, -- Previous end date + 1
                                       ah029.stf_asn_start_date_dte) BETWEEN
                                asn_effective_start_date AND
                                NVL(asn_effective_end_date, TO_DATE('31-DEC-2099', 'DD-MON-YYYY'))) != 0 THEN
                         '• Bilingual Bonus - Yes / Prime au bilinguisme - Oui'||' '||CHR(13)
                    -- Employee DOES NOT MEET Acting Profile:
                    WHEN fn_meets_language_profile(ah029.stf_candidate_pin,
                                                   ah027.rqt_position_nmbr,
                                                   ah027.rqt_hrsr_request_cd) != 0 AND
                        -- And employee does NOT MEET Substantive Profile:
                        (SELECT fn_meets_language_profile
                                  (ah029.stf_candidate_pin,
                                   MAX(asn_position_nmbr),
                                   ah027.rqt_hrsr_request_cd)
                           FROM assignments
                          WHERE asn_employee_pin = ah029.stf_candidate_pin
                            AND EXISTS (SELECT 1
                                          FROM assignment_types
                                         WHERE ast_assignment_type_code =
                                               asn_assignment_type_code
                                           AND ast_incumbent_type_flag = '1')
                            AND DECODE(
                                  ah029.stf_extension_cd,
                                  'E', ah029.stf_asn_end_date_dte + 1, -- Previous end date + 1
                                  'X', ah029.stf_asn_end_date_dte + 1, -- Previous end date + 1
                                       ah029.stf_asn_start_date_dte) BETWEEN
                                asn_effective_start_date AND
                                NVL(asn_effective_end_date, TO_DATE('31-DEC-2099', 'DD-MON-YYYY'))) != 0 THEN
                         '• Bilingual Bonus - No / Prime au bilinguisme - Non'||' '||CHR(13)

                    -- Employee DOES NOT MEET Acting Profile:
                    WHEN fn_meets_language_profile(ah029.stf_candidate_pin,
                                                   ah027.rqt_position_nmbr,
                                                   ah027.rqt_hrsr_request_cd) != 0 AND
                        -- And Substantive position is not bilingual:
                       (SELECT COUNT(lpr_language_requirement_ind)
                          FROM linguistic_profiles
                         WHERE lpr_position_nmbr =
                                  (SELECT MAX(asn_position_nmbr)
                                     FROM assignments
                                    WHERE asn_employee_pin = ah029.stf_candidate_pin
                                      AND EXISTS (SELECT 1
                                                    FROM assignment_types
                                                   WHERE ast_assignment_type_code =
                                                         asn_assignment_type_code
                                                     AND ast_incumbent_type_flag = '1')
                                      AND DECODE(
                                            ah029.stf_extension_cd,
                                            'E', ah029.stf_asn_end_date_dte + 1, -- Previous end date + 1
                                            'X', ah029.stf_asn_end_date_dte + 1, -- Previous end date + 1
                                                 ah029.stf_asn_start_date_dte) BETWEEN
                                          asn_effective_start_date AND
                                          NVL(asn_effective_end_date, TO_DATE('31-DEC-2099', 'DD-MON-YYYY')))
                           AND lpr_language_requirement_ind = 1 -- Bilingual
                           AND lpr_status_ind = '1') = 0  THEN
                         '• Bilingual Bonus - No / Prime au bilinguisme - Non'||' '||CHR(13)
                    -- Employee DOES NOT MEET Acting Profile:
                    WHEN fn_meets_language_profile(ah029.stf_candidate_pin,
                                                   ah027.rqt_position_nmbr,
                                                   ah027.rqt_hrsr_request_cd) != 0 AND
                        -- And employee meets Substantive Profile:
                        (SELECT fn_meets_language_profile
                                  (ah029.stf_candidate_pin,
                                   MAX(asn_position_nmbr),
                                   ah027.rqt_hrsr_request_cd)
                           FROM assignments
                          WHERE asn_employee_pin = ah029.stf_candidate_pin
                            AND EXISTS (SELECT 1
                                          FROM assignment_types
                                         WHERE ast_assignment_type_code =
                                               asn_assignment_type_code
                                           AND ast_incumbent_type_flag = '1')
                            AND DECODE(
                                  ah029.stf_extension_cd,
                                  'E', ah029.stf_asn_end_date_dte + 1, -- Previous end date + 1
                                  'X', ah029.stf_asn_end_date_dte + 1, -- Previous end date + 1
                                       ah029.stf_asn_start_date_dte) BETWEEN
                                asn_effective_start_date AND
                                NVL(asn_effective_end_date, TO_DATE('31-DEC-2099', 'DD-MON-YYYY')))  = 0 THEN
                         '• Bilingual Bonus - No change / Prime au bilinguisme - Aucun changement'
                    END
                END ||
              CASE
                WHEN pos_supervisory_grid_code IS NOT NULL AND
                     pos_group_ind IN ('GS','GL','AI') THEN
                    '• Supervisory Differential / Différentiel de surveillance'
                    ||' '||CHR(13)
                END ||
              CASE
                WHEN ah029.stf_underfill_group_ind IS NOT NULL AND
                     ah029.stf_underfill_level_ind IS NOT NULL THEN
                    '• Underfill / Sous-classement ('||
                       ah029.stf_underfill_group_ind||'-'||
                       DECODE(TRIM(ah029.stf_underfill_subgroup_ind),NULL,NULL,
                              ah029.stf_underfill_subgroup_ind||'-')||
                       ah029.stf_underfill_level_ind
                    ||') '||CHR(13)
                END ||
              CASE
                WHEN ah029.stf_ti_profile_cd IS NOT NULL THEN
                     (SELECT '• '||ti_profile_enm ||' / '|| ti_profile_fnm
                        FROM th197_ti_profile
                       WHERE ti_profile_cd = ah029.stf_ti_profile_cd)
                        ||' '||CHR(13)
                END  ||
                ------
                CASE
                  WHEN ah029.stf_ti_profile_cd IS NOT NULL OR
                       ah027.rqt_action_cd IN ('20','28') OR
                       pos.pos_group_ind IN ('GS','GL','AI') THEN
                        '• Bud Code / Bud Code: '||
                    CASE
                      WHEN ah029.stf_ti_profile_cd IS NOT NULL THEN -- TI Profile
                          (SELECT ti_bud_code_txt
                             FROM th197_ti_profile
                            WHERE ti_profile_cd = ah029.stf_ti_profile_cd)
                      WHEN ah027.rqt_action_cd IN ('20','28') THEN   -- Student
                           (SELECT MAX(bud_code_txt)
                              FROM th196_student_bud_code
                             WHERE assignment_type_cd = ah029.stf_assignment_type_code
                               AND education_level_cd =
                                   ah095.education_level_cd )
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
                      END ||CHR(13)
                  END||
               CASE
                 WHEN ah029.stf_hrsr_work_hours_cd = 'PT' THEN -- Part-Time
                      '• Part Time / Temps partiel'||' '||CHR(13)
                 WHEN NVL(
                      CASE -- AWW
                        WHEN ah027.rqt_action_cd IN ('13', '27') AND  -- Casual
                             ah031.csl_assigned_work_week_hrs_num IS NOT NULL THEN
                             ah031.csl_assigned_work_week_hrs_num
                        WHEN ah027.rqt_action_cd IN ('10', '26') THEN -- Acting
                             (SELECT NVL(MAX(grp_max_work_week_hours),'37.5')
                                FROM groups
                               WHERE grp_group_ind = pos.pos_group_ind)
                        ELSE ah029.stf_assigned_work_week_hrs_num
                        END,
                         '37.5') !=
                      CASE  -- SWW
                        WHEN ah029.stf_phantom_required_ind = 1 THEN
                           (SELECT NVL(MAX(grp_max_work_week_hours),'37.5')
                              FROM groups
                             WHERE grp_group_ind = ah030.php_group_ind)
                        ELSE
                           (SELECT NVL(MAX(grp_max_work_week_hours),'37.5')
                              FROM groups
                             WHERE grp_group_ind = pos.pos_group_ind)
                        END
                        THEN
                      '• Part Time / Temps partiel'||' '||CHR(13)
                 END ||
               CASE
                 WHEN ah029.stf_phantom_required_ind = 1 THEN
                   CASE
                     WHEN fn_get_previous_geo_province(
                             ah029.stf_candidate_pin,
                             ah029.stf_asn_start_date_dte) !=
                          (SELECT gel_province
                             FROM geographic_locations
                            WHERE gel_geo_province_code =
                                  ah030.php_geo_province_code
                              AND gel_geo_detail_code =
                                  ah030.php_geo_detail_code) THEN
                      '• Change of Province / Changement de province ('||
                         fn_get_previous_geo_province(
                             ah029.stf_candidate_pin,
                             ah029.stf_asn_start_date_dte) ||' to/à '||
                           (SELECT gel_province
                              FROM geographic_locations
                             WHERE gel_geo_province_code =
                                   ah030.php_geo_province_code
                               AND gel_geo_detail_code =
                                   ah030.php_geo_detail_code) ||')'||' '||CHR(13)
                     END
                 ELSE
                   CASE
                     WHEN fn_get_previous_geo_province(
                             ah029.stf_candidate_pin,
                             ah029.stf_asn_start_date_dte) !=
                          (SELECT (gel_province)
                             FROM geographic_locations
                            WHERE pos_geo_code =
                                  gel_geo_province_code||gel_geo_detail_code) THEN
                      '• Change of Province / Changement de province ('||
                         fn_get_previous_geo_province(
                             ah029.stf_candidate_pin,
                             ah029.stf_asn_start_date_dte) ||' to/à '||
                           (SELECT gel_province
                              FROM geographic_locations
                             WHERE pos_geo_code =
                                   gel_geo_province_code||gel_geo_detail_code) ||')'||' '||CHR(13)
                     END
                 END
              AS pay_bf_comments,
            ah029.stf_phantom_required_ind AS phantom_required_ind,
            CASE
              WHEN ah027.rqt_action_cd IN ('10','26') THEN   -- Acting
                CASE
                 WHEN ah029.stf_hrsr_work_hours_cd = 'AS' THEN -- As/When Req
                      'M' -- Special Employee, Works on an "as required" basis
                 WHEN ah029.stf_hrsr_work_hours_cd = 'FT' THEN -- Full-Time
                      'A' -- Indeterminate full time
                 WHEN ah029.stf_hrsr_work_hours_cd = 'PT' THEN -- Part-Time
                      'B' -- Indeterminate part TIME
                 ELSE
                     (SELECT MAX(emp_employment_type_code)
                        FROM employees
                       WHERE emp_pin = ah029.stf_candidate_pin )
                 END
              WHEN ah027.rqt_action_cd IN ('13', '27') THEN  -- Casual
                CASE
                 WHEN ah029.stf_hrsr_work_hours_cd = 'AS' THEN -- As/When Req
                      'M' -- Special Employee, Works on an "as required" basis
                 WHEN ah029.stf_hrsr_work_hours_cd = 'FT' AND -- Full-Time
                      ah029.stf_extension_cd = 'C' THEN       -- New casual
                      'K' -- Full Time New
                 WHEN ah029.stf_hrsr_work_hours_cd = 'FT' AND -- Full-Time
                      ah029.stf_extension_cd = 'X' THEN       -- Extension
                      'P' -- Full Time Extension
                 WHEN ah029.stf_hrsr_work_hours_cd = 'PT' AND -- Part-Time
                      ah029.stf_extension_cd = 'C' THEN       -- New casual
                      'L' -- Part Time New
                 WHEN ah029.stf_hrsr_work_hours_cd = 'PT' AND -- Part-Time
                      ah029.stf_extension_cd = 'X' THEN       -- Extension
                      'R' -- Part Time Extension
                 END
              WHEN ah027.rqt_action_cd IN ('20','28') THEN   -- Student
                CASE
                 WHEN ah029.stf_hrsr_work_hours_cd = 'AS' THEN -- As/When Req
                      'M' -- Special Employee, Works on an "as required" basis
                 WHEN ah029.stf_assignment_type_code = 'J1' THEN 'W' -- FSWEP
                 WHEN ah029.stf_assignment_type_code = 'J2' THEN 'V' -- Coop
                 WHEN ah029.stf_assignment_type_code = 'J3' THEN 'U' -- Intl Exchange
                 WHEN ah029.stf_assignment_type_code = 'J4' THEN 'N' -- Unpaid
                 WHEN ah029.stf_assignment_type_code = 'J5' THEN 'Y' -- RAP
                 END
              END AS employment_type_cd,
            CASE
              WHEN ah027.rqt_action_cd IN ('10','26') THEN   -- Acting
                   NVL(ah029.stf_assignment_type_code,'A1')
              WHEN ah027.rqt_action_cd IN ('13', '27') THEN  -- Casual
                   NVL(ah029.stf_assignment_type_code,'X1')
              WHEN ah027.rqt_action_cd IN ('20','28') THEN   -- Student
                   ah029.stf_assignment_type_code
              END AS assignment_type_cd,
            ah031.csl_casual_reason_ind AS casual_reason_ind,
            CASE
              WHEN ah027.rqt_action_cd IN ('10','26') THEN   -- Acting
                   pos.pos_exclusion_ind
              WHEN ah027.rqt_action_cd IN ('13', '27',       -- Casual
                                           '20', '28') THEN  -- Student
                   '79'  -- EXCLUDED - Non-employees, determinate < 3 months
              ELSE
                  (SELECT NVL(sre_bargaining_status_code,pos.pos_exclusion_ind)
                     FROM tips.sr_exclusions
                    WHERE sre_incumbent_pin = ah029.stf_candidate_pin
                      AND sre_position_nmbr = ah027.rqt_position_nmbr
                      AND sre_position_status_ind = '02')
              END AS exclusion_ind,
            CASE
              WHEN ah027.rqt_action_cd IN ('13', '27',       -- Casual
                                           '20', '28') THEN  -- Student
                   '04' -- Unrepresented by Union
              ELSE
                (SELECT DECODE(COUNT(*), 0, '04',  -- Unrepresented by Union
                                            '03')  -- Represented by Union
                   FROM bud_prefixes
                  WHERE bup_group_ind = NVL(pos.pos_group_ind,
                                            ah030.php_group_ind))
              END AS exclusion_status_ind,
            ah029.stf_staffing_method_ind AS staffing_method_ind,
            CASE
              WHEN pos_position_nmbr IS NOT NULL THEN
                   1
              ELSE 0
              END AS position_exists,
            stf_ti_profile_cd AS ti_prfile_cd,
            CASE
              WHEN ah029.stf_ti_profile_cd IS NOT NULL THEN -- TI Profile
                  (SELECT ti_bud_code_txt
                     FROM th197_ti_profile
                    WHERE ti_profile_cd = ah029.stf_ti_profile_cd)
              WHEN ah027.rqt_action_cd IN ('20','28') THEN   -- Student
                  (SELECT MAX(bud_code_txt)
                     FROM th196_student_bud_code
                    WHERE assignment_type_cd = ah029.stf_assignment_type_code
                      AND education_level_cd =
                          ah095.education_level_cd )
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
              END AS bud_code_txt,
            CASE
              WHEN ah029.stf_phantom_required_ind = 1 THEN
                   ah030.php_group_ind
              ELSE
                   pos.pos_group_ind
              END AS pos_group_ind,
            CASE
              WHEN ah029.stf_phantom_required_ind = 1 THEN
                   ah030.php_subgroup_ind
              ELSE
                   pos.pos_subgroup_ind
              END AS pos_subgroup_ind,
            CASE
              WHEN ah029.stf_phantom_required_ind = 1 THEN
                   ah030.php_level_ind
              ELSE
                   pos.pos_level_ind
              END AS pos_level_ind,
            CASE
              WHEN ah027.rqt_action_cd IN ('10','26') THEN   -- Acting
                   tips.get_substantive_asn_classn(
                        ah029.stf_candidate_pin,
                        CASE
                          WHEN ah029.stf_extension_cd IN ('E', 'X') THEN -- Extension
                               ah029.stf_asn_end_date_dte + 1 -- Previous end date + 1
                          ELSE
                               ah029.stf_asn_start_date_dte
                          END)
              END AS substantive_classn_ind,
            CASE
              WHEN ah027.rqt_action_cd IN ('13', '27',       -- Casual
                                           '20', '28') THEN  -- Student
                   TO_CHAR(SYSDATE,'YY')||'-'||
                   (SELECT glv_val_value_ind
                      FROM global_validations
                     WHERE glv_val_name LIKE 'FEDERAL_DEPARTMENTS')||'-'||
                   DECODE(ah027.rqt_action_cd, '13', 'CEO',  -- Casual
                                               '27', 'CEO',  -- Casual
                                               '20', 'SE',   -- Student
                                               '28', 'SE')   -- Student
                  ||'-AUT-'|| SUBSTR(ah027.rqt_hrsr_request_cd, 6, 10)
              END AS selection_process_nmbr,
            CASE
              WHEN ah027.rqt_action_cd IN ('13', '27') THEN  -- Casual
                   NULL
              ELSE
                  NULL
              END AS authorized_by_pin,
            fn_position_classn_flag(ah027.rqt_position_nmbr, ah027.rqt_action_cd)
              AS position_flagged_ind,
            ah029.stf_end_at_level_acting_ind  AS end_at_level_acting_ind,
            ah029.stf_oath_dte                 AS oath_dte,
            ah029.stf_underfill_group_ind      AS underfill_group_ind,
            ah029.stf_underfill_subgroup_ind   AS underfill_subgroup_ind,
            ah029.stf_underfill_level_ind      AS underfill_level_ind
       FROM ah027_hrsr_request          ah027,
            ah029_hrsr_staffing         ah029,
            ah030_hrsr_phantom_position ah030,
            ah031_hrsr_casual           ah031,
            ah095_hrsr_student_detail   ah095,
            positions                   pos
      WHERE ah027.rqt_hrsr_request_cd = ah029.stf_hrsr_request_cd
        AND ah027.rqt_hrsr_request_cd = ah031.csl_hrsr_request_cd(+)
        AND ah027.rqt_hrsr_request_cd = ah095.hrsr_request_cd(+)
        AND ah027.rqt_hrsr_request_cd = ah030.php_hrsr_request_cd(+)
        AND ah027.rqt_position_nmbr   = pos.pos_position_nmbr(+)
        AND ah027.rqt_hrsr_request_cd = v_hrsr_request_cd
  ) LOOP

  -- Validation Section:

  IF hrsr_request_details.position_flagged_ind = 2 THEN
     -- The position has been flagged by classifction not to be staffed, so the
     -- approval cannot happen. Return error message to user that the user has
     -- to contact the Classification advisor to continue the process.
     v_error_num := 31;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(31);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(31);
     RETURN;
  ELSIF hrsr_request_details.candidate_pin IS NULL THEN
     -- The HRSR is missing data: Candidate PIN
     v_error_num := 2;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(2);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(2);
     RETURN;
  ELSIF hrsr_request_details.position_nmbr IS NULL AND
        hrsr_request_details.phantom_required_ind != 1 THEN
     -- The HRSR is missing data: Position Number
     v_error_num := 5;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(5);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(5);
     RETURN;
  ELSIF hrsr_request_details.asn_start_dte IS NULL THEN
     -- The HRSR is missing data: Start date
     v_error_num := 3;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(3);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(3);
     RETURN;
  ELSIF hrsr_request_details.asn_end_dte IS NULL AND
     hrsr_request_details.hrsr_action_cd IN ('10', '26',      -- Acting
                                             '13', '27',      -- Casual
                                             '20', '28') THEN -- Student
     -- The HRSR is missing data: End date
     v_error_num := 4;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(4);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(4);
     RETURN;
  ELSIF hrsr_request_details.phantom_required_ind != 1 AND
     hrsr_request_details.position_exists = 0 THEN
     -- The position number chosen does not exist or may be archived
     v_error_num := 6;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(6);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(6);
     RETURN;
  ELSIF hrsr_request_details.employment_type_cd IS NULL THEN
     -- The HRSR is missing data: Employment Type Code
     v_error_num := 7;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(7);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(7);
     RETURN;
  ELSIF hrsr_request_details.assignment_type_cd IS NULL THEN
     -- The HRSR is missing data: Assignment Type Code
     v_error_num := 8;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(8);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(8);
     RETURN;
  ELSIF hrsr_request_details.extension_cd IS NULL THEN
     -- The HRSR is missing data: Extension Code (New or Extension)
     v_error_num := 9;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(9);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(9);
     RETURN;
  END IF;

  -- Check if assignment already EXISTS
  FOR asn_exists IN (
      SELECT *
        FROM assignments
       WHERE asn_employee_pin = hrsr_request_details.candidate_pin
         AND asn_position_nmbr = hrsr_request_details.position_nmbr
         AND asn_employment_type_code = hrsr_request_details.employment_type_cd
         AND TRUNC(asn_effective_start_date) = TRUNC(hrsr_request_details.asn_start_dte)
         AND asn_classn_group_ind = hrsr_request_details.pos_group_ind
         AND asn_classn_level_ind = hrsr_request_details.pos_level_ind
  ) LOOP

     -- An assignment already exists for these HRSR details.
     v_error_num := 10;
     v_error_message_etxt := fn_get_hrsr_error_message_etxt(10);
     v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(10);

  END LOOP;


  -- ACTING ASSIGNMENT VALIDATION:
  -- Validate the Acting assignment against the substantive assignment of the
  -- employee. Return message = 0 means no errors found.
  IF hrsr_request_details.hrsr_action_cd IN ('10','26') THEN -- Acting

     sp_validate_acting_assignment (
        hrsr_request_details.candidate_pin,
        hrsr_request_details.position_nmbr,
        hrsr_request_details.asn_start_dte,
        hrsr_request_details.asn_end_dte,
        v_hrsr_request_cd,
        v_error_num,
        v_error_message_etxt,
        v_error_message_ftxt);

     IF v_error_num IS NOT NULL AND v_error_num != 0 THEN
        RETURN;
     END IF;
  END IF;

  -- STUDENT ASSIGNMENT VALIDATION:
  -- Validate the student assignment
  -- Return message = 0 means no errors found.
  IF hrsr_request_details.hrsr_action_cd IN ('20', '28') THEN -- Student

     sp_validate_student_assignment (
        hrsr_request_details.candidate_pin,
        hrsr_request_details.position_nmbr,
        hrsr_request_details.asn_start_dte,
        hrsr_request_details.asn_end_dte,
        v_hrsr_request_cd,
        v_error_num,
        v_error_message_etxt,
        v_error_message_ftxt);

     IF v_error_num IS NOT NULL AND v_error_num != 0 THEN
        RETURN;
     END IF;
  END IF;

  -- CASUAL ASSIGNMENT VALIDATION:
  -- Validate the student assignment
  -- Return message = 0 means no errors found.
  IF hrsr_request_details.hrsr_action_cd IN ('13', '27') THEN -- Casual

     sp_validate_casual_assignment (
        hrsr_request_details.candidate_pin,
        hrsr_request_details.position_nmbr,
        hrsr_request_details.asn_start_dte,
        hrsr_request_details.asn_end_dte,
        v_hrsr_request_cd,
        v_error_num,
        v_error_message_etxt,
        v_error_message_ftxt);

     IF v_error_num IS NOT NULL AND v_error_num != 0 THEN
        RETURN;
     END IF;
  END IF;

  -- Create POSITIONS record if required:
  IF hrsr_request_details.position_nmbr IS NULL AND
     hrsr_request_details.phantom_required_ind = 1 THEN

     FOR phantom_position_rec IN (
         SELECT php_pos_title_enm,
                php_pos_title_fnm,
                php_parent_position_nmbr,
                php_language_requirement_ind,
                (SELECT MAX(pro_profile_cd)
                   FROM th022_profile_code
                  WHERE pro_delegation_authority_cd =
                        php_delegation_authority_cd) AS php_delegation_authority_cd,
                php_group_ind,
                php_subgroup_ind,
                php_level_ind,
                php_geo_province_code,
                php_geo_detail_code,
                (SELECT COUNT(*)
                   FROM bud_prefixes
                  WHERE bup_group_ind = php_group_ind) AS union_count
           FROM ah030_hrsr_phantom_position ah030
          WHERE ah030.php_hrsr_request_cd = v_hrsr_request_cd
     ) LOOP

     IF phantom_position_rec.php_parent_position_nmbr IS NULL THEN
        --Parent Position is Missing
        v_error_num := 24;
        v_error_message_etxt := fn_get_hrsr_error_message_etxt(24);
        v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(24);
        RETURN;
     ELSIF phantom_position_rec.php_group_ind IS NULL OR
        phantom_position_rec.php_subgroup_ind IS NULL OR
        phantom_position_rec.php_level_ind IS NULL THEN
        -- Classification for the phantom postition is missing or incomplete
        v_error_num := 25;
        v_error_message_etxt := fn_get_hrsr_error_message_etxt(25);
        v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(25);
        RETURN;
     END IF;

     -- CREATE a NEW phantom position number
     SELECT POS_REGION_IND || POS_REGION_IND ||'ZZZ' ||
            LTRIM(TO_CHAR(PHASEQ.NEXTVAL,'00009'))
       INTO v_phantom_position_nmbr
       FROM tips.all_positions
      WHERE pos_position_nmbr = phantom_position_rec.php_parent_position_nmbr;

     INSERT INTO positions (
                 pos_position_nmbr,
                 pos_admin_group_ind,
                 pos_creation_date,
                 pos_directorate_ind,
                 pos_employment_type_code,
                 pos_grievance_status_flag,
                 pos_group_ind,
                 pos_subgroup_ind,
                 pos_level_ind,
                 pos_last_review_date,
                 pos_next_review_date,
                 pos_national_flag,
                 pos_ok_to_staff_flag,
                 pos_parent_position_nmbr,
                 pos_region_ind,
                 pos_staffing_created_flag,
                 pos_status_date,
                 pos_status_ind,
                 pos_tips_converted_flag,
                 pos_title_e,
                 pos_title_f,
                 pos_vacant_flag,
                 pos_bud_category_code,
                 pos_effective_end_date,
                 pos_evaluation_total_points,
                 pos_exclusion_ind,
                 pos_function_subfunction,
                 pos_geo_code,
                 pos_label_code,
                 pos_location_ind,
                 pos_security_clearance_ind,
                 pos_structure_name_e,
                 pos_structure_name_f,
                 pos_supervisory_grid_code,
                 pos_exclusion_status_ind, -- 03 (Represented by Union) or 04 (Represented)
                 pos_middle_mngr_flag,
                 pos_noc_code,
                 pos_rc_code,
                 pos_model_ind,
                 pos_alternate_title_e,
                 pos_alternate_title_f,
                 pos_branch_ind,
                 pos_oversight_position_ind,
                 pos_ocean_protection_prog_ind )
          SELECT v_phantom_position_nmbr,
                 pos_admin_group_ind,
                 SYSDATE,
                 pos_directorate_ind,
                 hrsr_request_details.employment_type_cd,
                 '0',
                 phantom_position_rec.php_group_ind,
                 phantom_position_rec.php_subgroup_ind,
                 phantom_position_rec.php_level_ind,
                 SYSDATE,
                 SYSDATE,
                 '0',
                 '1',
                 pos_position_nmbr,
                 pos_region_ind,
                 '1',
                 SYSDATE,
                 '0',
                 '1',
                 'Phantom position',
                 'Poste fantôme',
                 '0',
                 hrsr_request_details.bud_code_txt,
                 SYSDATE,
                 NULL,
                 hrsr_request_details.exclusion_ind, -- Most will be 79
                 NULL,
                 phantom_position_rec.php_geo_province_code||
                    phantom_position_rec.php_geo_detail_code,
                 NULL,
                 NULL,
                 NULL,
                 pos_structure_name_e,
                 pos_structure_name_f,
                 NULL,
                 (SELECT DECODE(COUNT(*), 0, NULL,  -- Phantom Positions can have NULL
                                             '03')  -- Represented by Union
                   FROM bud_prefixes
                  WHERE bup_group_ind = phantom_position_rec.php_group_ind),
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NVL(phantom_position_rec.php_pos_title_enm,'Phantom position'),
                 NVL(phantom_position_rec.php_pos_title_fnm,'Poste fantôme'),
                 pos_branch_ind,
                 NULL,
                 NULL
            FROM positions
           WHERE pos_position_nmbr =
                 phantom_position_rec.php_parent_position_nmbr;


        -- If action type is Casual, and the delegation is identified
        -- (FIN or STF), send email to Training and Profiles (TAP) identifying
        -- this candidate requires delegation:
        IF hrsr_request_details.hrsr_action_cd IN ('13', '27') AND -- Casual
           phantom_position_rec.php_delegation_authority_cd IS NOT NULL THEN
           SEND_EMAIL_HRSR_TAP_PHANT_POS(
               v_phantom_position_nmbr,
               phantom_position_rec.php_delegation_authority_cd,
               hrsr_request_details.asn_start_dte,
               v_current_user_id,
               v_email_error_nmbr);

           IF v_email_error_nmbr IN (49, 999) THEN
              -- There was an email error, and email was not sent
              v_error_num := 49;
              v_error_message_etxt := fn_get_hrsr_error_message_etxt(49);
             v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(49);
           END IF;
        END IF;
     END LOOP;
  END IF;

  -- Create PERSONS record, if candidate has never been in TIPS database:

  INSERT INTO persons
             (per_pin,
              per_type_code,
              per_region_ind,
              per_canadian_citizen_ind,
              per_correspondence_lang_code,
              per_first_lang_code,
              per_preferred_lang_code,
              per_correspondence_title,
              per_date_of_birth,
              per_family_name,
              per_given_name,
              per_middle_name,
              per_search_name,
              per_geo_code,
              per_initials,
              per_marital_status_ind,
              per_self_id_contact_ok_ind,
              per_self_id_date,
              per_sex_code,
              per_specialty_txt,
              per_security_screen_date,
              per_security_screen_result,
              per_oath_date,
              per_initial_postal_code )
       SELECT hrsr_request_details.candidate_pin,
              '1', -- Employee
              (SELECT pos_region_ind
                 FROM positions
                WHERE pos_position_nmbr =
                      NVL(v_phantom_position_nmbr,
                          hrsr_request_details.position_nmbr)),
              NULL,
              hrsr_request_details.preferred_language_cd,
              NULL,
              hrsr_request_details.preferred_language_cd,
              NULL,
              hrsr_request_details.date_candidate_birth_dte,
              hrsr_request_details.candidate_family_name_txt,
              hrsr_request_details.candidate_given_name_txt,
              hrsr_request_details.candidate_initial_name_txt,
              NULL, -- trigger auto-populates
              NULL,
              SUBSTR(hrsr_request_details.candidate_given_name_txt,1,1)||
                SUBSTR(hrsr_request_details.candidate_initial_name_txt,1,1),
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              hrsr_request_details.oath_dte,
              NULL
         FROM dual
        WHERE NOT EXISTS (SELECT *
                            FROM persons
                           WHERE per_pin = hrsr_request_details.candidate_pin);

  -- Create EMPLOYEES record, if canidate has never been in TIPS database:

  INSERT INTO employees
             (emp_pin,
              emp_active_code,
              emp_dual_employment_flag,
              emp_employment_type_code,
              emp_group_ind,
              emp_subgroup_ind,
              emp_level_ind,
              emp_not_mobile_by_choice_flag,
              emp_payment_option_flag,
              emp_priority_asn_avail_flag,
              emp_priority_avail_start_date,
              emp_priority_case_contact,
              emp_prty_more_info_avail_flag,
              emp_prty_poten_place_flag,
              emp_region_ind,
              emp_taken_on_strength_date,
              emp_bud_code,
              emp_continuous_service_date,
              emp_dependents_nmbr,
              emp_exclusion_ind,
              emp_geo_code,
              emp_next_stat_increment_date,
              emp_pens_service_35_yr_date,
              emp_reason_leave_service_code,
              emp_routing_admin_group_ind,
              emp_routing_region_ind,
              emp_routing_symbol_detail,
              emp_struck_off_strength_date,
              emp_supervisory_grid_code,
              emp_total_service_years,
              emp_work_location,
              emp_dept_emp_start_date,
              emp_prev_dept_code,
              emp_prev_dept_start_date,
              emp_cont_empl_start_date,
              emp_full_time_equiv_ratio,
              emp_appt_lang_status,
              emp_biling_bonus_code,
              emp_disabil_ins_elig_code,
              emp_death_ben_elig_code,
              emp_pension_plan_code,
              emp_superannuation_number,
              emp_pens_serv_base_date,
              emp_pens_serv_years,
              emp_pens_contr_start_date,
              emp_elect_pens_serv_amt,
              emp_non_elect_pens_serv_amt,
              emp_forces_pens_serv_amt,
              emp_lex_year_end_status_ind,
              emp_lex_year_end_process_date,
              emp_lex_rollover_auth_date,
              emp_lex_banked_reduction,
              emp_lex_vac_anniversary_date,
              emp_compressed_work_week_flag,
              emp_vac_carry_over_flag,
              emp_comp_carry_over_flag,
              emp_lieu_carry_over_flag,
              emp_pay_garnished_flag,
              emp_term_initial_start_date,
              emp_rehab_flag,
              emp_term_calc_date_dte )
       SELECT hrsr_request_details.candidate_pin,
              '1',  -- Active
              '0',
              hrsr_request_details.employment_type_cd,
              hrsr_request_details.pos_group_ind,
              hrsr_request_details.pos_subgroup_ind,
              hrsr_request_details.pos_level_ind,
              '0',
              '0',
              '0',
              NULL,
              '0',
              '0',
              '0',
              pos_region_ind,
              hrsr_request_details.asn_start_dte,
              hrsr_request_details.bud_code_txt,
              NULL,
              NULL,
              NULL,
              pos_geo_code,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL
         FROM positions
        WHERE pos_position_nmbr =
              NVL(v_phantom_position_nmbr,
                  hrsr_request_details.position_nmbr)
          AND NOT EXISTS (SELECT *
                            FROM employees
                           WHERE emp_pin = hrsr_request_details.candidate_pin);



  -- Create a new BF to Staffing for this new assignment.
  -- Create CASE_FILE record, and associate it with the HRSR record:

  -- Create the CASE FILE NUMBER
  v_caf_case_nmbr := hrsr_request_details.approver_region_ind||'P'||
                     LPAD(CASESEQ.NEXTVAL,13,'0');

  INSERT INTO case_files (
              caf_case_nmbr,
              caf_destination_code,
              caf_destination_ind,
              caf_action_ind,
              caf_category_ind,
              caf_object_code,
              caf_object_ind,
              caf_owner_pin,
              caf_urgent_flag,
              caf_bf_sent_datetime,
              caf_bf_activate_date,
              caf_bf_sent_pin,
              caf_case_created_datetime,
              caf_case_created_pin,
              caf_case_status_ind,
              caf_status_change_datetime,
              caf_case_reference,
              caf_case_text,
              caf_additional_remark_txt,
              caf_source_case_nmbr,
              caf_cancelled_reason,
              caf_advertised_ind,
              caf_internal_ind  )
      VALUES (v_caf_case_nmbr,
              hrsr_request_details.approver_pin,
              '1',                -- Person
              hrsr_request_details.ta_bf_type,
              'TA',               -- Temporary Assignments
              DECODE(hrsr_request_details.ta_object_ind, '2', -- Position
                     NVL(hrsr_request_details.ta_object_cd, v_phantom_position_nmbr),
                     hrsr_request_details.ta_object_cd),
              hrsr_request_details.ta_object_ind,
              hrsr_request_details.approver_pin,
              '0', -- Not urgent
              SYSDATE,
              SYSDATE,
              hrsr_request_details.approver_pin,
              SYSDATE,
              hrsr_request_details.approver_pin,
              '2',  -- Closed Case Status
              SYSDATE,
              hrsr_request_details.ta_case_ref_txt,
              hrsr_request_details.ta_case_txt,
              NULL,
              v_hrsr_request_cd,
              '1',
              '0',
              '1'  );

  -- Associate the new BF / case file record with the HRSR record:
  INSERT INTO ah067_xref_ah027_caf (
              rcf_hrsr_request_cd,
              rcf_case_file_nmbr)
      VALUES (v_hrsr_request_cd,
              v_caf_case_nmbr);

  -- Create ASSIGNMENT RECORD, end at level acting assignments if required:

  -- Acting: End any overlapping at level actings if required:
  IF hrsr_request_details.hrsr_action_cd = '26' AND -- Acting
     hrsr_request_details.end_at_level_acting_ind = 1 THEN
     -- Acting: End at level overlapping assignments if:
     --   1.) new acting assignment is at LEVEL, defined as:
     --       - new and existing acting have same classification and level OR
     --       - max pay rate of the new assignment is less than or equal to the
     --         max pay rate of the existing acting assignment.
     --   2.) the new acting Start Date falls within the existing acting
     --       assignment start and end date.
     --   3.) the new acting End Date is after the existing assignment end date

     UPDATE assignments
        SET asn_effective_end_date =
            TRUNC(hrsr_request_details.asn_start_dte - 1) + 23/24
      WHERE asn_employee_pin = hrsr_request_details.candidate_pin
        AND asn_assignment_type_code = 'A1'
        AND hrsr_request_details.asn_start_dte BETWEEN
            asn_effective_start_date AND asn_effective_end_date
        AND hrsr_request_details.asn_end_dte > asn_effective_end_date
        -- Check "at level" defined as either at the same classn group and level
        AND ((asn_classn_group_ind = hrsr_request_details.pos_group_ind AND
              asn_classn_level_ind = hrsr_request_details.pos_level_ind)
        -- Or when the MAX pay rate of the new acting assignment classn is less
        -- then or the same as as the max pay rate of the the existing assigment
        -- classn (no pay bump).
            OR (SELECT MAX(salary_amt)
                  FROM vw_hrsr_active_pay_rates
                 WHERE classn_group_ind = hrsr_request_details.pos_group_ind
                   AND classn_subgroup_ind = hrsr_request_details.pos_subgroup_ind
                   AND classn_level_ind = hrsr_request_details.pos_level_ind) <=
               (SELECT MAX(salary_amt)
                  FROM vw_hrsr_active_pay_rates
                 WHERE classn_group_ind = asn_classn_group_ind
                   AND classn_subgroup_ind = asn_classn_subgroup_ind
                   AND classn_level_ind = asn_classn_level_ind))
        -- And the modified assignment still fulfills the minimum number of days
        -- acting according to the collective agreement:
        AND TRUNC(hrsr_request_details.asn_start_dte - 1) + 23/24 -
            asn_effective_start_date >=
              (SELECT NVL(MAX(agr_min_days_acting),200)
                 FROM agreements
                WHERE agr_group_ind = asn_classn_group_ind
                  AND agr_expiry_date IS NULL);
  END IF;

  INSERT INTO assignments (
              asn_position_nmbr,
              asn_employee_pin,
              asn_assignment_type_code,
              asn_employment_type_code,
              asn_staffed_by_pay_flag,
              asn_approval_received_date,
              asn_employee_assignment_date,
              asn_effective_start_date,
              asn_effective_end_date,
              asn_staffing_method_ind,
              asn_selection_process_nmbr,
              asn_process_seq_nmbr,
              asn_bud_code,
              asn_classn_group_ind,
              asn_classn_subgroup_ind,
              asn_classn_level_ind,
              asn_exclusion_ind,
              asn_geo_code,
              asn_termination_ind,
              asn_proposed_end_date,
              asn_term_reappoint_ind,
              asn_casual_reason_ind,
              asn_title_e,
              asn_title_f,
              asn_supervisory_grid_code,
              asn_bil_bonus_eligible_date,
              asn_bil_bonus_terminate_date,
              asn_routing_region_ind,
              asn_routing_admin_group_ind,
              asn_routing_symbol_detail,
              asn_salary_protected_flag,
              asn_standard_work_week_hours,
              asn_assigned_work_week_hours,
              asn_extension_flag,
              asn_compressed_work_week_flag,
              asn_compressed_week_desc,
              asn_probation_start_date,
              asn_probation_end_date,
              asn_probation_passed_ind,
              asn_salary_min_max_ind,
              asn_salary_above_min_ind,
              asn_employee_cost_code,
              asn_salary_start_date,
              asn_authorized_by_pin,
              asn_authorized_date,
              --asn_rost_reference_nmbr,
              asn_region_ind,
              asn_requested_date,
              asn_received_date,
              asn_exclusion_status_ind, -- 03 (Represented) or 04 (Unrepresented)
              asn_shift_premium_flag,
              asn_term_validity_start_date,
              asn_term_validity_end_date,
              asn_hrsr_request_cd,
              asn_phx_empl_rec_txt,
              appointee_source_cd,
              referral_source_cd,
              asn_audit_row_id )
       SELECT pos_position_nmbr,
              hrsr_request_details.candidate_pin,
              hrsr_request_details.assignment_type_cd,
              hrsr_request_details.employment_type_cd,
              '0',
              SYSDATE,
              SYSDATE,
              hrsr_request_details.asn_start_dte,
              hrsr_request_details.asn_end_dte,
              hrsr_request_details.staffing_method_ind,
              hrsr_request_details.selection_process_nmbr,
              '001',
              hrsr_request_details.bud_code_txt,
              CASE
                WHEN hrsr_request_details.underfill_group_ind IS NOT NULL AND
                     hrsr_request_details.underfill_level_ind IS NOT NULL THEN
                     hrsr_request_details.underfill_group_ind
                ELSE pos_group_ind
                END,
              CASE
                WHEN hrsr_request_details.underfill_group_ind IS NOT NULL AND
                     hrsr_request_details.underfill_level_ind IS NOT NULL THEN
                     NVL(hrsr_request_details.underfill_subgroup_ind,'   ')
                ELSE pos_subgroup_ind
                END,
              CASE
                WHEN hrsr_request_details.underfill_group_ind IS NOT NULL AND
                     hrsr_request_details.underfill_level_ind IS NOT NULL THEN
                     hrsr_request_details.underfill_level_ind
                ELSE pos_level_ind
                END,
              pos_exclusion_ind, -- 03 (Represented) or 04 (Unrepresented)
              pos_geo_code,
              NULL,
              hrsr_request_details.asn_end_dte,
              NULL,
              hrsr_request_details.casual_reason_ind,
              pos_title_e,
              pos_title_f,
              pos_supervisory_grid_code,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              '0',
              hrsr_request_details.sww,
              NVL(hrsr_request_details.aww, hrsr_request_details.sww),
              '0',
              '0',
              NULL,
              NULL,
              NULL,
              NULL,
              '1',
              NULL,
              hrsr_request_details.employee_cost_code_txt,
              TRUNC(hrsr_request_details.asn_start_dte),
              hrsr_request_details.authorized_by_pin,
              NULL,
              --asn_rost_reference_nmbr,  NULL, except Casual, see notes
              pos_region_ind,
              NULL,
              NULL,
              pos_exclusion_status_ind, -- 03 (Represented) or 04 (Unrepresented)
              '0',
              NULL,
              NULL,
              v_hrsr_request_cd,
              NULL,
              NULL,
              NULL,
              '0'
         FROM positions
        WHERE pos_position_nmbr = NVL(v_phantom_position_nmbr,
                                      hrsr_request_details.position_nmbr);

  -- CREATE BF TO PAY:

  -- Create the PAY CASE FILE NUMBER
  -- Default to NCR / Region A for all Pay Case Files

  v_pay_case_nmbr := hrsr_request_details.approver_region_ind||'P'||
                     LPAD(CASESEQ.NEXTVAL,13,'0');

  INSERT INTO case_files (
              caf_case_nmbr,
              caf_destination_code,
              caf_destination_ind,
              caf_action_ind,
              caf_category_ind,
              caf_object_code,
              caf_object_ind,
              caf_owner_pin,
              caf_urgent_flag,
              caf_source_case_nmbr,
              caf_bf_sent_datetime,
              caf_bf_activate_date,
              caf_bf_sent_pin,
              caf_case_created_datetime,
              caf_case_created_pin,
              caf_case_status_ind,
              caf_status_change_datetime,
              caf_case_reference,
              caf_case_text,
              caf_transmit_state_ind )
      VALUES (v_pay_case_nmbr,
              '000000002',        -- PAY1
              '1',                -- Person
              hrsr_request_details.pay_bf_type,
              'PAY',               -- Pay
              hrsr_request_details.candidate_pin,     -- Candidate PIN
              '1',                 -- Person
              '000000002',         -- PAY1            -- Owner is PAY1
              '0', -- Not urgent
              v_hrsr_request_cd,
              SYSDATE,
              hrsr_request_details.asn_start_dte,
              hrsr_request_details.approver_pin,
              SYSDATE,
              hrsr_request_details.approver_pin,
              '1',                  -- Open Case Status
              SYSDATE,
              hrsr_request_details.candidate_pin||' '||
                 hrsr_request_details.candidate_family_name_txt||', '||
                 hrsr_request_details.candidate_given_name_txt,
              hrsr_request_details.pay_bf_comments,
              '3' );

  INSERT INTO ah067_xref_ah027_caf (
              rcf_hrsr_request_cd,
              rcf_case_file_nmbr)
      VALUES (v_hrsr_request_cd,
              v_pay_case_nmbr);

  -- Close the HRSR and any associated case files on successful run of this
  -- procedure:
  HRSR_CAF_UPDATE_CLOSE_REQUEST(v_hrsr_request_cd,
                                hrsr_request_details.approver_name,
                                v_close_hrsr_success_cd);

  -- Update the employee to Active (emp_active_code = 1) if not active (SOS or TSOS)
  UPDATE employees
     SET emp_active_code = '1'
   WHERE emp_pin = hrsr_request_details.candidate_pin
     AND emp_active_code != '1';

  -- If the PERSON type is Applicant (2), make them an Employee (1):
  UPDATE persons
     SET per_type_code = '1'  -- Employee
   WHERE per_pin = hrsr_request_details.candidate_pin
     AND per_type_code = '2'; -- Applicant

  -- Set the position to not vacant:
  UPDATE positions
     SET pos_vacant_flag = '0'
   WHERE pos_position_nmbr = hrsr_request_details.position_nmbr;

   -- Update REGIONS in the following tables to the region of the POSITION:

   -- Get position region:
   SELECT MIN(pos_region_ind)
     INTO v_position_region_cd
     FROM positions
    WHERE pos_position_nmbr IN (v_phantom_position_nmbr,
                                hrsr_request_details.position_nmbr);

   UPDATE applicants
      SET app_region_ind = v_position_region_cd
    WHERE app_pin = hrsr_request_details.candidate_pin
      AND app_region_ind != v_position_region_cd;

   UPDATE employees
      SET emp_region_ind = v_position_region_cd
    WHERE emp_pin = hrsr_request_details.candidate_pin
      AND emp_region_ind != v_position_region_cd;

   UPDATE persons
      SET per_region_ind = v_position_region_cd
    WHERE per_pin = hrsr_request_details.candidate_pin
      AND per_region_ind != v_position_region_cd;


  -- Send email that case file was closed.
  SEND_EMAIL_HRSR('063',
                  hrsr_request_details.approver_pin,
                  v_hrsr_request_cd,
                  v_email_error_nmbr);

  IF v_email_error_nmbr IN (49, 999) THEN
      -- There was an email error, and email was not sent
      v_error_num := 49;
      v_error_message_etxt := fn_get_hrsr_error_message_etxt(49);
      v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(49);
  END IF;

  IF hrsr_request_details.hrsr_action_cd = '26' THEN

     -- Acting < 4 months will send email to Initiator, Recommender and Approver
     -- confirming HRSR has been approved and completed
     SEND_EMAIL_HRSR_REASSIGNED('117',v_hrsr_request_cd,'',v_email_error_nmbr);

     IF v_email_error_nmbr IN (49, 999) THEN
        -- There was an email error, and email was not sent
        v_error_num := 49;
        v_error_message_etxt := fn_get_hrsr_error_message_etxt(49);
        v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(49);
     END IF;

     -- Send email to Exclusions Unit if either:
     -- 1.) Candidate is acting in an excluded position:
     FOR excluded_position_rec IN (
         SELECT *
           FROM sr_exclusions
          WHERE sre_position_nmbr = hrsr_request_details.position_nmbr
            AND sre_position_status_ind = '02'
     ) LOOP
       -- Candidate is acting in an excluded position.
       -- Send email to Exclusions Unit:
       SEND_EMAIL_HRSR_EXCLUSION_UNIT(
            hrsr_request_details.candidate_pin,
            hrsr_request_details.position_nmbr,
            '118',
            v_email_error_nmbr);

       IF v_email_error_nmbr = 999 THEN
          -- There was an email error, and email was not sent
          v_error_num := 49;
          v_error_message_etxt := fn_get_hrsr_error_message_etxt(49);
          v_error_message_ftxt := fn_get_hrsr_error_message_ftxt(49);
       END IF;

     END LOOP;

     -- 2.) Candidate is excluded, and acting in a non-excluded position
     FOR excluded_candidate_rec IN (
         SELECT *
           FROM sr_exclusions a
          WHERE a.sre_incumbent_pin = hrsr_request_details.candidate_pin
            AND a.sre_position_nmbr != hrsr_request_details.position_nmbr
            AND a.sre_position_status_ind = '02'
            AND NOT EXISTS (SELECT *
                              FROM sr_exclusions b
                             WHERE b.sre_position_nmbr =
                                   hrsr_request_details.position_nmbr
                               AND b.sre_position_status_ind = '02')
     ) LOOP
       -- Candidate is excluded, and acting in a non-excluded position.
       -- Send email to Exclusions Unit:
       SEND_EMAIL_HRSR_EXCLUSION_UNIT(
            hrsr_request_details.candidate_pin,
            hrsr_request_details.position_nmbr,
            '119',
            v_email_error_nmbr);


     END LOOP;

  END IF;

  END LOOP;
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
     -- Return Unknown Error:
     v_error_num := 999;
     v_error_message_etxt := 'Unknown Error: '||SQLERRM||' ; '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
     v_error_message_ftxt := 'Inconnu Erreur: '||SQLERRM||' ; '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
     RETURN ;
END;
/

CREATE OR REPLACE PUBLIC SYNONYM sp_validate_acting_assignment
   FOR tips.sp_validate_acting_assignment
/   

-- Grants for Procedure
GRANT EXECUTE ON hrsr_create_staffing_action TO tipsuser
/
GRANT EXECUTE ON hrsr_create_staffing_action TO everything_in_tips
/


-- End of DDL Script for Procedure TIPS.HRSR_CREATE_STAFFING_ACTION

