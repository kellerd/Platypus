-- Start of DDL Script for View TIPS.VW_HRSR_CASUAL_LETTER_OF_OFFER
-- Generated 26-Apr-2019 7:53:12 from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_casual_letter_of_offer (
   hrsr_request_cd,
   new_hire_ind,
   extension_ind,
   candidate_pin,
   candidate_family_name,
   candidate_given_name,
   region_ind,
   region_enm,
   region_fnm,
   position_nmbr,
   position_title_etxt,
   position_title_ftxt,
   classification,
   admin_grp,
   admin_grp_enm,
   admin_grp_fnm,
   directorate_ind,
   directorate_enm,
   directorate_fnm,
   geo_code,
   pos_location,
   language_req,
   pos_security_clearance_ind,
   medical_exam_req_ind,
   other_ind,
   irregular_shift_worker_ind,
   aww,
   days_of_week,
   sun_work_ind,
   mon_work_ind,
   tues_work_ind,
   wed_work_ind,
   thurs_work_ind,
   fri_work_ind,
   sat_work_ind,
   sun_hrs,
   mon_hrs,
   tues_hrs,
   wed_hrs,
   thurs_hrs,
   fri_hrs,
   sat_hrs,
   as_and_when_req,
   disbursement_rate,
   payment_amount,
   start_dte,
   end_dte,
   new_end_dte,
   shift_worker_ind,
   isolated_post_ind,
   meal_ind,
   other_allowance_ind,
   phant_pos_title_enm,
   phant_pos_title_fnm,
   phant_classification,
   phant_language_req_ind,
   phant_parent_position_nmbr,
   phant_region_enm,
   phant_region_fnm,
   phant_admin_group_enm,
   phant_admin_group_fnm,
   phant_directorate_enm,
   phant_directorate_fnm,
   phant_location,
   approver_name )
AS
SELECT DISTINCT ah029.stf_hrsr_request_cd   AS hrsr_request_cd,
       DECODE(ah029.stf_extension_cd, 'C', 1,
                                      'N', 1,
                                      'P', 1,
                                           0) AS new_hire_ind,
       DECODE(ah029.stf_extension_cd, 'E', 1,
                                      'X', 1,
                                           0) AS extension_ind,
       ah029.stf_candidate_pin              AS candidate_pin,
       ah029.stf_candidate_family_name_txt  AS candidate_family_name,
       ah029.stf_candidate_given_name_txt   AS candidate_given_name,
       pos.pos_region_ind                   AS region_ind,
       reg.reg_region_desc_e                AS region_enm,
       reg.reg_region_desc_f                AS region_fnm,
       ah027.rqt_position_nmbr              AS position_nmbr,
       pos.pos_alternate_title_e            AS position_title_etxt,
       pos.pos_alternate_title_f            AS position_title_ftxt,
       pos.pos_group_ind||pos.pos_subgroup_ind||pos.pos_level_ind AS classification,
       th017.adm_admin_group_cd             AS admin_grp,
       th017.adm_admin_group_name_enm       AS admin_grp_enm,
       th017.adm_admin_group_name_fnm       AS admin_grp_fnm,
       pos.pos_directorate_ind              AS directorate_ind,
       dir.dir_directorate_name_e           AS directorate_enm,
       dir.dir_directorate_name_f           AS directorate_fnm,
       ah030.php_geo_province_code||
          ah030.php_geo_detail_code         AS geo_code,
       gel.gel_geo_desc ||
         DECODE(gel.gel_geo_desc,NULL,NULL,',')|| gel.gel_province  AS pos_location,
       lpr.lpr_language_requirement_ind     AS language_req,
       pos.pos_security_clearance_ind       AS pos_security_clearance_ind,  
       ah029.stf_medical_exam_req_ind       AS medical_exam_req_ind,
       ah031.csl_other_ind                  AS other_ind,
       ah031.csl_irregular_shift_work_ind   AS irregular_shift_worker_ind,  
       ah031.csl_assigned_work_week_hrs_num AS aww, 
       ah031.csl_days_of_week_txt           AS days_of_week,
       SUBSTR(ah031.csl_days_of_week_txt,1,1)           AS sun_work_ind,
       SUBSTR(ah031.csl_days_of_week_txt,2,1)           AS mon_work_ind,
       SUBSTR(ah031.csl_days_of_week_txt,3,1)           AS tues_work_ind,
       SUBSTR(ah031.csl_days_of_week_txt,4,1)           AS wed_work_ind,
       SUBSTR(ah031.csl_days_of_week_txt,5,1)           AS thurs_work_ind,
       SUBSTR(ah031.csl_days_of_week_txt,6,1)           AS fri_work_ind,
       SUBSTR(ah031.csl_days_of_week_txt,7,1)           AS sat_work_ind,
       DECODE(SUBSTR(ah031.csl_days_of_week_txt,1,1), 0, 0,
              DECODE(csl_assigned_work_week_hrs_num,
                     0, 0,
                     NULL, 0,
                    (ah031.csl_assigned_work_week_hrs_num /
                     REGEXP_COUNT(ah031.csl_days_of_week_txt,1)))) AS sun_hrs,
       DECODE(SUBSTR(ah031.csl_days_of_week_txt,2,1), 0, 0,
              DECODE(csl_assigned_work_week_hrs_num,
                     0, 0,
                     NULL, 0,
                    (ah031.csl_assigned_work_week_hrs_num /
                     REGEXP_COUNT(ah031.csl_days_of_week_txt,1)))) AS mon_hrs,
       DECODE(SUBSTR(ah031.csl_days_of_week_txt,3,1), 0, 0,
              DECODE(csl_assigned_work_week_hrs_num,
                     0, 0,
                     NULL, 0,
                    (ah031.csl_assigned_work_week_hrs_num /
                     REGEXP_COUNT(ah031.csl_days_of_week_txt,1)))) AS tues_hrs,
       DECODE(SUBSTR(ah031.csl_days_of_week_txt,4,1), 0, 0,
              DECODE(csl_assigned_work_week_hrs_num,
                     0, 0,
                     NULL, 0,
                    (ah031.csl_assigned_work_week_hrs_num /
                     REGEXP_COUNT(ah031.csl_days_of_week_txt,1)))) AS wed_hrs,
       DECODE(SUBSTR(ah031.csl_days_of_week_txt,5,1), 0, 0,
              DECODE(csl_assigned_work_week_hrs_num,
                     0, 0,
                     NULL, 0,
                    (ah031.csl_assigned_work_week_hrs_num /
                     REGEXP_COUNT(ah031.csl_days_of_week_txt,1)))) AS thurs_hrs,
       DECODE(SUBSTR(ah031.csl_days_of_week_txt,6,1), 0, 0,
              DECODE(csl_assigned_work_week_hrs_num,
                     0, 0,
                     NULL, 0,
                    (ah031.csl_assigned_work_week_hrs_num /
                     REGEXP_COUNT(ah031.csl_days_of_week_txt,1)))) AS fri_hrs,
       DECODE(SUBSTR(ah031.csl_days_of_week_txt,7,1), 0, 0,
              DECODE(csl_assigned_work_week_hrs_num,
                     0, 0,
                     NULL, 0,
                    (ah031.csl_assigned_work_week_hrs_num /
                     REGEXP_COUNT(ah031.csl_days_of_week_txt,1)))) AS sat_hrs,
       DECODE(pos.pos_employment_type_code,'M',1,0) AS as_and_when_req,
       ah031.csl_disbursement_rate_cd       AS disbursement_rate,   
       ah031.csl_payment_amount_amt         AS payment_amount,
       ah029.stf_asn_start_date_dte         AS start_dte,
       ah029.stf_asn_end_date_dte           AS end_dte,
       ah029.stf_asn_new_end_date_dte       AS new_end_dte,
       ah031.csl_shift_work_ind             AS shift_worker_ind,
       ah031.csl_isolated_post_ind          AS isolated_post_ind,
       ah031.csl_meal_ind                   AS meal_ind,
       ah031.csl_allowance_other_txt        AS other_allowance_ind,
       ah030.php_pos_title_enm              AS phant_pos_title_enm,
       ah030.php_pos_title_fnm              AS phant_pos_title_fnm,
       ah030.php_group_ind||ah030.php_subgroup_ind||ah030.php_level_ind AS phant_classification,
       ah030.php_language_requirement_ind   AS phant_language_req_ind,
       phant_pos.pos_position_nmbr          AS phant_parent_position_nmbr,
       phant_reg.reg_region_desc_e          AS phant_region_enm,
       phant_reg.reg_region_desc_f          AS phant_region_fnm,
       phant_th017.adm_admin_group_name_enm AS phant_admin_group_enm,
       phant_th017.adm_admin_group_name_fnm AS phant_admin_group_fnm,
       phant_dir.dir_directorate_name_e     AS phant_directorate_enm,
       phant_dir.dir_directorate_name_f     AS phant_directorate_fnm,
       phant_gel.gel_geo_desc||DECODE(phant_gel.gel_geo_desc,NULL,NULL,', ')||phant_gel.gel_province AS phant_location,
       RTRIM(tips.get_person_name(ah027.rqt_approver_pin)) AS approver_name
  FROM ah027_hrsr_request       ah027,
       ah029_hrsr_staffing      ah029,
       positions                pos,
       ah031_hrsr_casual        ah031,
       th017_admin_group        th017,
       directorates             dir,
       regions                  reg,
       geographic_locations     gel,
       linguistic_profiles      lpr,
       ah030_hrsr_phantom_position ah030,
       positions                phant_pos,
       th017_admin_group        phant_th017,
       directorates             phant_dir,
       regions                  phant_reg,
       geographic_locations     phant_gel,
       assignments              approver_asn,
       assignment_types         asn_type
 WHERE ah027.rqt_hrsr_request_cd = ah029.stf_hrsr_request_cd
   AND ah027.rqt_position_nmbr  = pos.pos_position_nmbr(+)
   AND ah027.rqt_hrsr_request_cd = ah031.csl_hrsr_request_cd(+)
   AND pos.pos_admin_group_ind = th017.adm_admin_group_cd(+)
   AND pos.pos_directorate_ind = dir.dir_directorate_ind(+)
   AND pos.pos_region_ind = reg.reg_region_ind(+)
   AND ah030.php_geo_province_code||ah030.php_geo_detail_code =
       gel.gel_geo_province_code(+)||gel.gel_geo_detail_code(+)
   AND pos.pos_position_nmbr = lpr.lpr_position_nmbr(+)
   AND (lpr.lpr_status_ind = 1 or lpr.lpr_status_ind IS NULL)
   AND ah027.rqt_hrsr_request_cd = ah030.php_hrsr_request_cd(+)
   AND ah030.php_parent_position_nmbr = phant_pos.pos_position_nmbr(+)
   AND phant_pos.pos_admin_group_ind = phant_th017.adm_admin_group_cd(+)
   AND phant_pos.pos_directorate_ind = phant_dir.dir_directorate_ind(+)
   AND phant_pos.pos_region_ind = phant_reg.reg_region_ind(+)
   AND phant_pos.pos_geo_code = phant_gel.gel_geo_province_code(+)||phant_gel.gel_geo_detail_code(+)
   AND ah027.rqt_approver_pin = approver_asn.asn_employee_pin(+)
   AND approver_asn.asn_effective_start_date =
          (SELECT MAX(asn_effective_start_date)
             FROM assignments max_asn
            WHERE ah027.rqt_approver_pin = max_asn.asn_employee_pin (+)
            and asn_type.ast_assignment_type_code=max_asn.asn_assignment_type_code
            and asn_type.ast_incumbent_type_flag='1')
   AND (approver_asn.asn_effective_end_date IS NULL
        or approver_asn.asn_effective_end_date > TRUNC(sysdate))
/

-- Create synonym VW_HRSR_CASUAL_LETTER_OF_OFFER
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_casual_letter_of_offer
  FOR vw_hrsr_casual_letter_of_offer
/

-- Grants for View
GRANT SELECT ON vw_hrsr_casual_letter_of_offer TO tipsuser
/
GRANT SELECT ON vw_hrsr_casual_letter_of_offer TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_CASUAL_LETTER_OF_OFFER

