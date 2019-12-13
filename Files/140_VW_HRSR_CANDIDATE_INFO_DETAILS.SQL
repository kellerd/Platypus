-- Start of DDL Script for View TIPS.VW_HRSR_CANDIDATE_INFO_DETAILS
-- Generated 2019-11-12 10:24:10 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_candidate_info_details (
   hrsr_request_cd,
   candidate_pin,
   candidate_family_name_txt,
   candidate_given_name_txt,
   candidate_initial_name_txt,
   preferred_lang_code_cd,
   preferred_lang_code_enm,
   preferred_lang_code_fnm,
   substantive_position_nmbr,
   position_title_enm,
   position_title_fnm,
   position_region_ind,
   position_region_enm,
   position_region_fnm,
   position_admin_group_cd,
   position_admin_group_enm,
   position_admin_group_fnm,
   supervisor_position_nmbr )
AS
SELECT ah027.rqt_hrsr_request_cd             AS hrsr_request_cd,
       ah029.stf_candidate_pin               AS candidate_pin,
       ah029.stf_candidate_family_name_txt   AS candidate_family_name_txt,
       ah029.stf_candidate_given_name_txt    AS candidate_given_name_txt,
       ah029.stf_candidate_initial_name_txt  AS candidate_initial_name_txt,
       NVL(a.per_preferred_lang_code,
           ah029.stf_preferred_language_cd)  AS preferred_lang_code_cd,
       CASE
         WHEN pref_lang.lng_language_name_enm = 'All' THEN
              NULL
         ELSE pref_lang.lng_language_name_enm
         END                                 AS preferred_lang_code_enm,
       CASE
         WHEN pref_lang.lng_language_name_enm = 'All' THEN
              NULL
         ELSE pref_lang.lng_language_name_fnm
         END                                 AS preferred_lang_code_fnm,
       asn_position_nmbr                     AS substantive_position_nmbr,
       pos_alternate_title_e                 AS position_title_enm,
       pos_alternate_title_f                 AS position_title_fnm,
       pos_region_ind                        AS position_region_ind,
       reg_region_desc_e                     AS position_region_enm,
       reg_region_desc_f                     AS position_region_fnm,
       pos_admin_group_ind                   AS position_admin_group_cd,
       adm_admin_group_name_enm              AS position_admin_group_enm,
       adm_admin_group_name_fnm              AS position_admin_group_fnm,
       pos_parent_position_nmbr              AS supervisor_position_nmbr
  FROM ah027_hrsr_request ah027,
       ah029_hrsr_staffing ah029,
       assignments,
       positions,
       persons a,
       regions,
       th017_admin_group,
       assignment_types,
       th019_language     pref_lang
 WHERE ah027.rqt_hrsr_request_cd        = ah029.stf_hrsr_request_cd
   AND ah029.stf_candidate_pin          = asn_employee_pin(+)
   AND ah029.stf_candidate_pin          = per_pin(+)
   AND NVL(a.per_type_code,'1')         = (SELECT NVL(MIN(b.per_type_code),'1')
                                             FROM persons b
                                            WHERE b.per_pin(+) = a.per_pin)
   AND SYSDATE BETWEEN asn_effective_start_date(+) AND
       NVL(asn_effective_end_date(+), SYSDATE + 1)
   AND asn_assignment_type_code         = ast_assignment_type_code(+)
   AND NVL(ast_incumbent_type_flag,'1') = '1'
   AND asn_position_nmbr                = pos_position_nmbr(+)
   AND pos_region_ind                   = reg_region_ind(+)
   AND pos_admin_group_ind              = adm_admin_group_cd(+)
   AND NVL(
         NVL(a.per_preferred_lang_code,
             ah029.stf_preferred_language_cd),'4')
                                        = pref_lang.lng_language_cd
/

-- Create synonym VW_HRSR_CANDIDATE_INFO_DETAILS
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_candidate_info_details
  FOR vw_hrsr_candidate_info_details
/

-- Grants for View
GRANT SELECT ON vw_hrsr_candidate_info_details TO tipsuser
/
GRANT SELECT ON vw_hrsr_candidate_info_details TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_CANDIDATE_INFO_DETAILS

