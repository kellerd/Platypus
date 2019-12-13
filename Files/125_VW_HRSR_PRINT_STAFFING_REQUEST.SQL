-- Start of DDL Script for View TIPS.VW_HRSR_PRINT_STAFFING_REQUEST
-- Generated 2019-07-08 9:47:05 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_print_staffing_request (
   hrsr_request_cd,
   hrsr_type_cd,
   hrsr_type_enm,
   hrsr_type_fnm,
   request_type_cd,
   request_type_enm,
   request_type_fnm,
   date_effective_dte,
   hrsr_status_cd,
   hrsr_status_enm,
   hrsr_status_fnm,
   status_dte,
   selection_process_nmbr,
   candidate_pin,
   candidate_name,
   initiator_name,
   recommender_name,
   approver_name,
   hr_advisor_name,
   assigned_to_name,
   asn_start_dte,
   asn_end_dte,
   position_nmbr,
   position_classn,
   position_title_enm,
   position_title_fnm,
   supervisor_pos_nmbr,
   supervisor_pos_title_enm,
   supervisor_pos_title_fnm,
   region_enm,
   region_fnm,
   branch_ind,
   branch_enm,
   branch_fnm,
   admin_group_cd,
   admin_group_enm,
   admin_group_fnm,
   directorate_ind,
   directorate_enm,
   directorate_fnm,
   financial_cd,
   hrsr_comment_count,
   action_description_etxt,
   action_description_ftxt,
   action_explanation_etxt,
   action_explanation_ftxt,
   action_disclaimer_etxt,
   action_disclaimer_ftxt )
AS
SELECT rqt_hrsr_request_cd                               AS hrsr_request_cd,
       act_hrsr_type_cd                                  AS hrsr_type_cd,
       typ_hrsr_type_etxt                                AS hrsr_type_enm,
       typ_hrsr_type_ftxt                                AS hrsr_type_fnm,
       rqt_action_cd                                     AS request_type_cd,
       act_hrsr_action_enm                               AS request_type_enm,
       act_hrsr_action_fnm                               AS request_type_fnm,
       rqt_date_effective_dte                            AS date_effective_dte,
       rqt_hrsr_status_cd                                AS hrsr_status_cd,
       sts_description_etxt                              AS hrsr_status_enm,
       sts_description_ftxt                              AS hrsr_status_fnm,
       NULL                                              AS status_dte,
       CASE
         WHEN rqt_action_cd IN ('13', '27',       -- Casual
                                '20', '28') THEN  -- Student
              TO_CHAR(SYSDATE,'YY')||'-'||
              (SELECT glv_val_value_ind
                 FROM global_validations
                WHERE glv_val_name LIKE 'FEDERAL_DEPARTMENTS')||'-'||
              DECODE(rqt_action_cd, '13', 'CEO',  -- Casual
                                    '27', 'CEO',  -- Casual
                                    '20', 'SE',   -- Student
                                    '28', 'SE')   -- Student
              ||'-AUT-'|| SUBSTR(rqt_hrsr_request_cd, 6, 10)
         END                                             AS selection_process_nmbr,
       stf_candidate_pin                                 AS candidate_pin,
       CASE
        WHEN stf_candidate_family_name_txt IS NULL THEN
             tips.get_person_name(stf_candidate_pin)
        ELSE stf_candidate_family_name_txt||', '||
             stf_candidate_given_name_txt
        END                                              AS candidate_name,
       RTRIM(tips.get_person_name(rqt_initiator_pin))    AS initiator_name,
       RTRIM(tips.get_person_name(rqt_recommender_pin))  AS recommender_name,
       RTRIM(tips.get_person_name(rqt_approver_pin))     AS approver_name,
       RTRIM(tips.get_person_name(rqt_advisor_pin))      AS hr_advisor_name,
       RTRIM(tips.get_person_name(rqt_assigned_to_pin))  AS assigned_to_name,
       CASE
         WHEN stf_extension_cd IN ('E', 'X') THEN  -- Extension
              TRUNC(stf_asn_end_date_dte + 1) + 11/24 -- Prev end date + 1
         ELSE
              TRUNC(stf_asn_start_date_dte) + 11/24
         END                                             AS asn_start_dte,
       CASE
         WHEN stf_extension_cd IN ('E', 'X') THEN -- Extension
              TRUNC(stf_asn_new_end_date_dte) + 23/24
         ELSE
              TRUNC(stf_asn_end_date_dte) + 23/24
         END                                             AS asn_end_dte,
       rqt_position_nmbr                                 AS position_nmbr,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              php_group_ind||php_subgroup_ind||php_level_ind
         ELSE pos_group_ind||pos_subgroup_ind||pos_level_ind
         END                                             AS position_classn,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              NVL(php_pos_title_enm,'Phantom position')
         ELSE
              pos_alternate_title_e
         END                                             AS position_title_enm,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              NVL(php_pos_title_fnm,'Poste fantôme')
         ELSE
              pos_alternate_title_f
         END                                             AS position_title_fnm,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              php_parent_position_nmbr
         ELSE
              pos_parent_position_nmbr
         END                                             AS supervisor_pos_nmbr,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              (SELECT pos_alternate_title_e
                 FROM positions parent
                WHERE pos_position_nmbr = php_parent_position_nmbr)
         ELSE
              (SELECT pos_alternate_title_e
                 FROM positions parent
                WHERE pos_position_nmbr = pos.pos_parent_position_nmbr)
         END                                             AS supervisor_pos_title_enm,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              (SELECT MAX(pos_alternate_title_f)
                 FROM all_positions parent
                WHERE parent.pos_position_nmbr = php_parent_position_nmbr)
         ELSE
              (SELECT MAX(pos_alternate_title_f)
                 FROM all_positions parent
                WHERE parent.pos_position_nmbr = pos.pos_parent_position_nmbr)
         END                                             AS supervisor_pos_title_fnm,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              (SELECT reg_region_desc_e
                 FROM regions
                WHERE reg_region_ind = (SELECT pos_region_ind
                                          FROM positions parent
                                         WHERE parent.pos_position_nmbr =
                                               php_parent_position_nmbr))
         ELSE
              (SELECT reg_region_desc_e
                 FROM regions
                WHERE reg_region_ind = pos_region_ind)
         END                                             AS region_enm,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              (SELECT reg_region_desc_f
                 FROM regions
                WHERE reg_region_ind = (SELECT pos_region_ind
                                          FROM positions parent
                                         WHERE parent.pos_position_nmbr =
                                               php_parent_position_nmbr))
         ELSE
              (SELECT reg_region_desc_f
                 FROM regions
                WHERE reg_region_ind = pos_region_ind)
         END                                             AS region_fnm,
       pos_branch_ind                                    AS branch_ind,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              (SELECT bra_branch_name_e
                 FROM branch
                WHERE bra_branch_ind = (SELECT pos_branch_ind
                                          FROM positions b
                                         WHERE b.pos_position_nmbr =
                                               php_parent_position_nmbr))
         ELSE
              (SELECT bra_branch_name_e
                 FROM branch
                WHERE bra_branch_ind = pos_branch_ind)
         END                                             AS branch_enm,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              (SELECT bra_branch_name_f
                 FROM branch
                WHERE bra_branch_ind = (SELECT pos_branch_ind
                                          FROM positions b
                                         WHERE b.pos_position_nmbr =
                                               php_parent_position_nmbr))
         ELSE
              (SELECT bra_branch_name_f
                 FROM branch
                WHERE bra_branch_ind = pos_branch_ind)
         END                                             AS branch_fnm,
       pos_admin_group_ind                               AS admin_group_cd,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              (SELECT adm_admin_group_name_enm
                 FROM th017_admin_group
                WHERE adm_admin_group_cd = (SELECT pos_admin_group_ind
                                              FROM positions b
                                             WHERE b.pos_position_nmbr =
                                                    php_parent_position_nmbr))
         ELSE
              (SELECT adm_admin_group_name_enm
                 FROM th017_admin_group
                WHERE adm_admin_group_cd = pos_admin_group_ind)
         END                                             AS admin_group_enm,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              (SELECT adm_admin_group_name_fnm
                 FROM th017_admin_group
                WHERE adm_admin_group_cd = (SELECT pos_admin_group_ind
                                               FROM positions b
                                              WHERE b.pos_position_nmbr =
                                                    php_parent_position_nmbr))
         ELSE
              (SELECT adm_admin_group_name_fnm
                 FROM th017_admin_group
                WHERE adm_admin_group_cd = pos_admin_group_ind)
         END                                             AS admin_group_fnm,
       pos_directorate_ind                               AS directorate_ind,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              (SELECT dir_directorate_name_e
                 FROM directorates
                WHERE dir_directorate_ind = (SELECT pos_directorate_ind
                                               FROM positions b
                                              WHERE b.pos_position_nmbr =
                                                    php_parent_position_nmbr))
         ELSE
              (SELECT dir_directorate_name_e
                 FROM directorates
                WHERE dir_directorate_ind = pos_directorate_ind)
         END                                             AS directorate_enm,
       CASE
         WHEN stf_phantom_required_ind = 1 THEN
              (SELECT dir_directorate_name_f
                 FROM directorates
                WHERE dir_directorate_ind = (SELECT pos_directorate_ind
                                               FROM positions b
                                              WHERE b.pos_position_nmbr =
                                                    php_parent_position_nmbr))
         ELSE
              (SELECT dir_directorate_name_f
                 FROM directorates
                WHERE dir_directorate_ind = pos_directorate_ind)
         END                                             AS directorate_fnm,
       stf_employee_cost_code_txt                        AS financial_cd,
       (SELECT COUNT(*)
          FROM ah033_hrsr_request_comment
         WHERE cmt_hrsr_request_cd =
               rqt_hrsr_request_cd)                      AS hrsr_comment_count,
       act_action_description_etxt                       AS action_description_etxt,
       act_action_description_ftxt                       AS action_description_ftxt,
       act_action_explanation_etxt                       AS action_explanation_etxt,
       act_action_explanation_ftxt                       AS action_explanation_ftxt,
       act_approver_disclaimer_etxt                      AS action_disclaimer_etxt,
       act_approver_disclaimer_ftxt                      AS action_disclaimer_ftxt
  FROM ah027_hrsr_request,
       ah029_hrsr_staffing,
       th047_hrsr_type,
       th048_hrsr_action,
       th050_hrsr_status,
       positions pos,
       ah030_hrsr_phantom_position
 WHERE rqt_hrsr_request_cd = stf_hrsr_request_cd
   AND act_hrsr_type_cd    = typ_hrsr_type_cd(+)
   AND rqt_action_cd       = act_action_cd(+)
   AND rqt_hrsr_status_cd  = sts_hrsr_status_cd(+)
   AND rqt_hrsr_request_cd = php_hrsr_request_cd(+)
   AND rqt_position_nmbr   = pos_position_nmbr(+)
/

-- Create synonym VW_HRSR_PRINT_STAFFING_REQUEST
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_print_staffing_request
  FOR vw_hrsr_print_staffing_request
/

-- Grants for View
GRANT SELECT ON vw_hrsr_print_staffing_request TO tipsuser
/
GRANT SELECT ON vw_hrsr_print_staffing_request TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_PRINT_STAFFING_REQUEST

