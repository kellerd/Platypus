-- Start of DDL Script for View TIPS.VW_HRSR_EMPLOYEE_INFO_DETAILS
-- Generated 2019-11-12 10:29:17 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_employee_info_details (
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
SELECT per_pin                               AS candidate_pin,
       per_family_name                       AS candidate_family_name_txt,
       per_given_name                        AS candidate_given_name_txt,
       per_initials                          AS candidate_initial_name_txt,
       per_preferred_lang_code               AS preferred_lang_code_cd,
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
  FROM assignments,
       positions,
       persons a,
       regions,
       th017_admin_group,
       assignment_types,
       th019_language     pref_lang
 WHERE per_pin                          = asn_employee_pin(+)
   AND per_type_code                    = (SELECT NVL(MIN(b.per_type_code),'1')
                                             FROM persons b
                                            WHERE b.per_pin = a.per_pin)
   AND SYSDATE BETWEEN asn_effective_start_date(+) AND
       NVL(asn_effective_end_date(+), SYSDATE + 1)
   AND asn_assignment_type_code         = ast_assignment_type_code(+)
   AND NVL(ast_incumbent_type_flag,'1') = '1'
   AND asn_position_nmbr                = pos_position_nmbr(+)
   AND pos_region_ind                   = reg_region_ind(+)
   AND pos_admin_group_ind              = adm_admin_group_cd(+)
   AND NVL(per_first_lang_code,1)       = pref_lang.lng_language_cd
/

-- Create synonym VW_HRSR_EMPLOYEE_INFO_DETAILS
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_employee_info_details
  FOR vw_hrsr_employee_info_details
/

-- Grants for View
GRANT SELECT ON vw_hrsr_employee_info_details TO tipsuser
/
GRANT SELECT ON vw_hrsr_employee_info_details TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_EMPLOYEE_INFO_DETAILS

