-- Start of DDL Script for View TIPS.VW_HRSR_STUDENT_LETTER_DATA
-- Generated 30-05-2019 11:31:57 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_student_letter_data (
   hrsr_request_cd,
   selection_process_nmbr,
   position_nmbr,
   candidate_pin,
   candidate_family_name_txt,
   candidate_given_name_txt,
   initiator_pin,
   recommender_pin,
   approver_pin,
   approver_name,
   hrsr_action_cd,
   extension_cd,
   asn_start_dte,
   asn_end_dte,
   aww,
   sww,
   phantom_required_ind,
   assignment_type_cd,
   assignment_type_enm,
   assignment_type_fnm,
   position_title_enm,
   position_title_fnm,
   position_location,
   salary_enm,
   salary_fnm,
   security_clearance_ind,
   security_clearance_enm,
   security_clearance_fnm,
   admin_group_enm,
   admin_group_fnm,
   collective_agreement_enm,
   collective_agreement_fnm,
   aboriginal_program_ind,
   region_enm,
   region_fnm,
   directorate_enm,
   directorate_fnm,
   custom_cond_of_employ_etxt,
   custom_cond_of_employ_ftxt,
   cond_of_employ_etxt,
   cond_of_employ_ftxt )
AS
SELECT ah027.rqt_hrsr_request_cd           AS hrsr_request_cd,
       CASE
         WHEN ah027.rqt_action_cd IN ('20', '28') THEN  -- Student
              TO_CHAR(SYSDATE,'YY')||'-'||
                 (SELECT glv_val_value_ind
                    FROM global_validations
                   WHERE glv_val_name LIKE 'FEDERAL_DEPARTMENTS')||'-'||
                 DECODE(ah027.rqt_action_cd, '20', 'SE',   -- Student
                                             '28', 'SE')   -- Student
                 ||'-AUT-'|| SUBSTR(ah027.rqt_hrsr_request_cd, 6, 10)
         END AS selection_process_nmbr,
       ah027.rqt_position_nmbr             AS position_nmbr,
       ah029.stf_candidate_pin             AS candidate_pin,
       ah029.stf_candidate_family_name_txt AS candidate_family_name_txt,
       ah029.stf_candidate_given_name_txt  AS candidate_given_name_txt,
       ah027.rqt_initiator_pin             AS initiator_pin,
       ah027.rqt_recommender_pin           AS recommender_pin,
       ah027.rqt_approver_pin              AS approver_pin,
       RTRIM(tips.get_first_last_name(ah027.rqt_approver_pin)) AS approver_name,
 /*      (SELECT MAX(email_address)
          FROM vw_email_addresses
         WHERE user_id = (SELECT pou_user_id
                            FROM portal_users
                           WHERE pou_pri = ah027.rqt_approver_pin)) AS approver_email_txt,*/
       ah027.rqt_action_cd                 AS hrsr_action_cd,
       ah029.stf_extension_cd              AS extension_cd,
       CASE
         WHEN ah029.stf_extension_cd IN ('E', 'X') THEN -- Extension
              ah029.stf_asn_end_date_dte + 1 -- Previous end date + 1
         ELSE
              ah029.stf_asn_start_date_dte
         END AS asn_start_dte,
       CASE
         WHEN ah029.stf_extension_cd IN ('E', 'X') THEN -- Extension
              ah029.stf_asn_new_end_date_dte
         ELSE
              ah029.stf_asn_end_date_dte
         END AS asn_end_dte,
       ah029.stf_assigned_work_week_hrs_num  AS aww,
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
         ah029.stf_phantom_required_ind AS phantom_required_ind,
         ah029.stf_assignment_type_code AS assignment_type_cd,
         CASE
           WHEN ah029.stf_assignment_type_code = 'J1' AND
                NVL(ah095.aboriginal_program_ind,0) != 1 THEN
               'Federal Student Work Experience Program (FSWEP)'
           WHEN ah029.stf_assignment_type_code = 'J1' AND
                ah095.aboriginal_program_ind = 1 THEN
               'Federal Student Work Experience Program (FSWEP) - Indigenous Youth Summer Employment Opportunity (ISEO)'
           WHEN ah029.stf_assignment_type_code = 'J2' THEN
               'Post-Secondary Co-op/Internship Program'
           WHEN ah029.stf_assignment_type_code = 'J3' THEN
               'International Exchange Program'
           WHEN ah029.stf_assignment_type_code = 'J4' THEN
               'Secondary School Co-op Education Program'
           WHEN ah029.stf_assignment_type_code = 'J5' THEN
               'Research Affiliate Program (RAP)'
           ELSE
               'Student'
           END AS assignment_type_enm,
         CASE
           WHEN ah029.stf_assignment_type_code = 'J1' AND
                NVL(ah095.aboriginal_program_ind,0) != 1 THEN
               'Programme fédéral d''expérience de travail étudiant (PFETÉ)'
           WHEN ah029.stf_assignment_type_code = 'J1' AND
                ah095.aboriginal_program_ind = 1 THEN
               'Programme fédéral d''expérience de travail étudiant (PFETÉ) - - Opportunité d''emploi pour étudiants autochtones'
           WHEN ah029.stf_assignment_type_code = 'J2' THEN
               'Programme postsecondaire d''enseignement coopératif/de stages'
           WHEN ah029.stf_assignment_type_code = 'J3' THEN
               'Programme d''échanges internationaux'
           WHEN ah029.stf_assignment_type_code = 'J4' THEN
               'Programme d''enseignement coopératif des écoles secondaires'
           WHEN ah029.stf_assignment_type_code = 'J5' THEN
               'Programme des adjoints de recherche'
           ELSE
               'Étudiant'
           END AS assignment_type_fnm,
        CASE
           WHEN ah029.stf_phantom_required_ind = 1 THEN
                NVL(ah030.php_pos_title_enm, pos.pos_alternate_title_e)
           ELSE
                pos.pos_alternate_title_e
           END  AS position_title_enm,
            CASE
              WHEN ah029.stf_phantom_required_ind = 1 THEN
                   NVL(ah030.php_pos_title_fnm, pos.pos_alternate_title_f)
              ELSE
                   pos.pos_alternate_title_f
              END  AS position_title_fnm,
         CASE
           WHEN ah029.stf_phantom_required_ind = 1 THEN
                (SELECT TRIM(gel_geo_desc)||' '||gel_province
                   FROM geographic_locations
                  WHERE gel_geo_province_code =
                        ah030.php_geo_province_code
                    AND gel_geo_detail_code =
                        ah030.php_geo_detail_code)
           ELSE
                (SELECT TRIM(gel_geo_desc)||' '||gel_province
                   FROM geographic_locations
                  WHERE pos.pos_geo_code =
                        gel_geo_province_code||gel_geo_detail_code)
           END  AS position_location,
        '$'||NVL(TO_CHAR(ah095.payment_amount_amt),'--') ||'/'||
              CASE
                WHEN ah095.disbursement_rate_cd IS NULL OR
                     ah095.disbursement_rate_cd = 'H' THEN
                     'hour'
                WHEN ah095.disbursement_rate_cd = 'A' THEN
                    'annually'
                END AS salary_enm,
       NVL(TO_CHAR(ah095.payment_amount_amt),'--') ||' $/'||
              CASE
                WHEN ah095.disbursement_rate_cd IS NULL OR
                     ah095.disbursement_rate_cd = 'H' THEN
                     'heure'
                WHEN ah095.disbursement_rate_cd = 'A' THEN
                     'an'
                END AS salary_fnm,
       NVL(ah029.stf_security_clearance_ind, 'R')  AS security_clearance_ind,
       tips.get_global_value('GLB','SECURITY_CLEARANCE',
                             NVL(ah029.stf_security_clearance_ind, 'R'),0)
                             AS security_clearance_enm,
       tips.get_global_value('GLB','SECURITY_CLEARANCE',
                             NVL(ah029.stf_security_clearance_ind, 'R'),1)
                             AS security_clearance_fnm,
       th017.adm_admin_group_name_enm       AS admin_group_enm,
       th017.adm_admin_group_name_fnm       AS admin_group_fnm,
       coa.coa_agreement_desc_e             AS collective_agreement_enm,
       coa.coa_agreement_desc_f             AS collective_agreement_fnm,
       NVL(ah095.aboriginal_program_ind,0)  AS aboriginal_program_ind,
       reg.reg_region_desc_e                AS region_enm,
       reg.reg_region_desc_f                AS region_fnm,
       dir.dir_directorate_name_e           AS directorate_enm,
       dir.dir_directorate_name_f           AS directorate_fnm,
      (SELECT LISTAGG(
               DECODE(custom_condition_of_empl_etxt, NULL,  NULL,
                      CHR(13)||'•   '||custom_condition_of_empl_etxt||' '))
               WITHIN GROUP (ORDER BY custom_condition_id )
          FROM ah103_custom_condition_of_empl ah103
         WHERE ah103.hrsr_request_cd = ah027.rqt_hrsr_request_cd
           AND ah103.date_deleted_dte IS NULL)  AS custom_cond_of_employ_etxt ,
       (SELECT LISTAGG(
               DECODE(custom_condition_of_empl_ftxt, NULL,  NULL,
                      CHR(13)||'•   '||custom_condition_of_empl_ftxt||' '))
               WITHIN GROUP (ORDER BY custom_condition_id )
          FROM ah103_custom_condition_of_empl ah103
         WHERE ah103.hrsr_request_cd = ah027.rqt_hrsr_request_cd
           AND ah103.date_deleted_dte IS NULL)  AS custom_cond_of_employ_ftxt ,
       (SELECT LISTAGG(
               DECODE(condition_of_employment_etxt, NULL,  NULL,
                      CHR(13)||'•   '||condition_of_employment_etxt||' '))
               WITHIN GROUP (ORDER BY condition_of_employment_id )
          FROM th193_condition_of_employment th193
         WHERE EXISTS (SELECT *
                         FROM ah100_xref_ah029_th193 ah100
                        WHERE ah100.condition_of_employment_id =
                              th193.condition_of_employment_id
                          AND ah100.hrsr_request_cd =
                              ah027.rqt_hrsr_request_cd
                          AND ah100.date_deleted_dte IS NULL )
           AND th193.date_deleted_dte IS NULL) AS cond_of_employ_etxt,
       (SELECT LISTAGG(
               DECODE(condition_of_employment_etxt, NULL,  NULL,
                      CHR(13)||'•   '||condition_of_employment_ftxt||' '))
               WITHIN GROUP (ORDER BY condition_of_employment_id )
          FROM th193_condition_of_employment th193
         WHERE EXISTS (SELECT *
                         FROM ah100_xref_ah029_th193 ah100
                        WHERE ah100.condition_of_employment_id =
                              th193.condition_of_employment_id
                          AND ah100.hrsr_request_cd =
                              ah027.rqt_hrsr_request_cd
                          AND ah100.date_deleted_dte IS NULL )
           AND th193.date_deleted_dte IS NULL)   AS cond_of_employ_ftxt
    FROM ah027_hrsr_request          ah027,
         ah029_hrsr_staffing         ah029,
         ah030_hrsr_phantom_position ah030,
         ah095_hrsr_student_detail   ah095,
         positions                   pos,
         assignment_types            ast,
         th017_admin_group           th017,
         collective_agreements       coa,
         regions                     reg,
         directorates                dir
   WHERE ah027.rqt_hrsr_request_cd = ah029.stf_hrsr_request_cd
     AND ah027.rqt_hrsr_request_cd = ah095.hrsr_request_cd(+)
     AND ah027.rqt_hrsr_request_cd = ah030.php_hrsr_request_cd(+)
     AND ah030.php_parent_position_nmbr = pos.pos_position_nmbr(+)
     AND ah029.stf_assignment_type_code = ast.ast_assignment_type_code(+)
     AND pos.pos_admin_group_ind   = th017.adm_admin_group_cd(+)
     AND pos.pos_region_ind        = reg.reg_region_ind(+)
     AND pos.pos_directorate_ind   = dir.dir_directorate_ind(+)
     AND ah095.coa_collective_agreement_ind = coa.coa_collective_agreement_ind(+)
     AND ah027.rqt_action_cd IN ('20', '28')
/

-- Create synonym VW_HRSR_STUDENT_LETTER_DATA
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_student_letter_data
  FOR vw_hrsr_student_letter_data
/

-- Grants for View
GRANT SELECT ON vw_hrsr_student_letter_data TO tipsuser
/
GRANT SELECT ON vw_hrsr_student_letter_data TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_STUDENT_LETTER_DATA

