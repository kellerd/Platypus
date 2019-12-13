-- Start of DDL Script for View TIPS.VW_HRSR_POSITION_INFO_DETAILS
-- Generated 22-Nov-19 13:23:34 from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_position_info_details (
   position_nmbr,
   classn_group_ind,
   classn_subgroup_ind,
   classn_level_ind,
   position_classn_txt,
   position_title_enm,
   position_title_fnm,
   supervisor_position_nmbr,
   position_geo_cd,
   position_geo_location,
   position_region_ind,
   position_region_enm,
   position_region_fnm,
   position_admin_group_cd,
   position_admin_group_enm,
   position_admin_group_fnm,
   position_directorate_cd,
   position_directorate_enm,
   position_directorate_fnm,
   position_branch_cd,
   position_branch_enm,
   position_branch_fnm,
   position_effective_dte,
   position_security_ind,
   position_security_enm,
   position_security_fnm,
   tenure_cd,
   tenure_enm,
   tenure_fnm,
   classification_flag_enm,
   classification_flag_fnm,
   language_req_cd,
   language_effective_dte,
   language_req_enm,
   language_req_fnm,
   eng_lang_profile_txt,
   fre_lang_profile_txt,
   exclusion_status_cd,
   exlcusion_status_enm,
   exlcusion_status_fnm,
   essential_designation_cd,
   essential_designation_enm,
   essential_designation_fnm,
   profile_enm,
   profile_fnm,
   delegation_enm,
   delegation_fnm,
   ex_position_ind )
AS
SELECT pos_position_nmbr          AS position_nmbr,
       pos_group_ind              AS classn_group_ind,
       pos_subgroup_ind           AS classn_subgroup_ind,
       pos_level_ind              AS classn_level_ind,
       pos_group_ind||
        pos_subgroup_ind||
        pos_level_ind             AS position_classn_txt,
       pos_alternate_title_e      AS position_title_enm,
       pos_alternate_title_f      AS position_title_fnm,
       pos_parent_position_nmbr   AS supervisor_position_nmbr,
       pos_geo_code               AS position_geo_cd,
       gel_geo_desc||', '||
         gel_province             AS position_geo_location,
       pos_region_ind             AS position_region_ind,
       reg_region_desc_e          AS position_region_enm,
       reg_region_desc_f          AS position_region_fnm,
       pos_admin_group_ind        AS position_admin_group_cd,
       adm_admin_group_name_enm   AS position_admin_group_enm,
       adm_admin_group_name_fnm   AS position_admin_group_fnm,
       pos_directorate_ind        AS position_directorate_cd,
       dir_directorate_name_e     AS position_directorate_enm,
       dir_directorate_name_f     AS position_directorate_fnm,
       pos_branch_ind             AS position_branch_cd,
       bra_branch_name_e          AS position_branch_enm,
       bra_branch_name_f          AS position_branch_fnm,
       pos_creation_date          AS position_effective_dte,
       pos_security_clearance_ind AS position_security_ind,
       sec.glv_val_desc_e         AS position_security_enm,
       sec.glv_val_desc_f         AS position_security_fnm,
       pos_employment_type_code   AS tenure_cd,
       employment_type_enm        AS tenure_enm,
       employment_type_fnm        AS tenure_fnm,
      (SELECT LISTAGG(
               DECODE(pcl_classification_flag, NULL,  NULL,
                      '• '||pcl_classification_flag||' - '||glv_val_desc_e||' '||CHR(13)))
               WITHIN GROUP (ORDER BY pcl_classification_flag )
          FROM position_classification_flag,
               global_validations
         WHERE pos_position_nmbr = pcl_position_nmbr
           AND SYSDATE BETWEEN pcl_start_date AND NVL(pcl_end_date, SYSDATE + 1)
           AND glv_val_category_ind = 'CLS'
           AND glv_val_name = 'CLASSIFICATION_FLAG'
           AND glv_val_value_ind = pcl_classification_flag)
       ||
       CASE
         WHEN POS_OVERSIGHT_POSITION_IND = 1 THEN
              '• Position identified as oversight '||CHR(13)
         END
       ||
       CASE
         WHEN POS_OCEAN_PROTECTION_PROG_IND = 1 THEN
              '• Position identified as Oceans Protection Program '||CHR(13)
         END
       ||
       CASE
         WHEN POS_NATIONAL_FLAG = 1 THEN
              '• National Flag '||CHR(13)
         END
                                   AS classification_flag_enm,
      (SELECT LISTAGG(
               DECODE(pcl_classification_flag, NULL,  NULL,
                      '• '||DECODE(pcl_classification_flag, 'OL','LO',pcl_classification_flag)
                          ||' - '||glv_val_desc_f||' '||CHR(13)))
               WITHIN GROUP (ORDER BY pcl_classification_flag )
          FROM position_classification_flag,
               global_validations
         WHERE pos_position_nmbr = pcl_position_nmbr
           AND SYSDATE BETWEEN pcl_start_date AND NVL(pcl_end_date, SYSDATE + 1)
           AND glv_val_category_ind = 'CLS'
           AND glv_val_name = 'CLASSIFICATION_FLAG'
           AND glv_val_value_ind = pcl_classification_flag)
       ||
       CASE
         WHEN POS_OVERSIGHT_POSITION_IND = 1 THEN
              '• Poste identifié comme poste de surveillance '||CHR(13)
         END
       ||
       CASE
         WHEN POS_OCEAN_PROTECTION_PROG_IND = 1 THEN
              '• Poste identifié comme Plan de protection des océans '||CHR(13)
         END
       ||
       CASE
         WHEN POS_NATIONAL_FLAG = 1 THEN
              '• Indicateur national '||CHR(13)
         END
                                   AS classification_flag_fnm,
       lpr_language_requirement_ind AS language_req_cd,
       lpr_effective_date           AS language_effective_dte,
       lang_req.glv_val_desc_e      AS language_req_enm ,
       lang_req.glv_val_desc_f      AS language_req_fnm ,
       NVL(lpr_english_read,' ')||
         NVL(lpr_english_write,' ')||
         NVL(lpr_english_oral,' ')  AS eng_lang_profile_txt,
       NVL(lpr_french_read,' ')||
         NVL(lpr_french_write,' ')||
         NVL(lpr_french_oral,' ')  AS fre_lang_profile_txt,
       pos_exclusion_status_ind    AS exclusion_status_cd,
       exclusion.glv_val_desc_e    AS exlcusion_status_enm,
       exclusion.glv_val_desc_f    AS exlcusion_status_fnm,
       des_actual_designation_ind  AS essential_designation_cd,
       essential.glv_val_desc_e    AS essential_designation_enm,
       essential.glv_val_desc_f    AS essential_designation_fnm,
      (SELECT LISTAGG(
               DECODE(pro_profile_name_enm, NULL,  NULL,
                      '• '||pro_profile_name_enm||' '||CHR(13)))
               WITHIN GROUP (ORDER BY pro_profile_name_enm )
          FROM ah012_position_profile_detail,
               th022_profile_code
         WHERE pos_position_nmbr = pop_position_nmbr
           AND pop_profile_cd = pro_profile_cd
           AND SYSDATE BETWEEN pop_profile_start_dte AND
                NVL(pop_profile_end_dte, SYSDATE + 1)
            AND pop_date_delete_dte IS NULL )
                                   AS profile_enm ,
      (SELECT LISTAGG(
               DECODE(pro_profile_name_fnm, NULL,  NULL,
                      '• '||pro_profile_name_fnm||' '||CHR(13)))
               WITHIN GROUP (ORDER BY pro_profile_name_fnm )
          FROM ah012_position_profile_detail,
               th022_profile_code
         WHERE pos_position_nmbr = pop_position_nmbr
           AND pop_profile_cd = pro_profile_cd
           AND SYSDATE BETWEEN pop_profile_start_dte AND
                NVL(pop_profile_end_dte, SYSDATE + 1)
            AND pop_date_delete_dte IS NULL )
                                   AS profile_fnm,
      (SELECT LISTAGG(
               DECODE(dau_delegation_name_enm, NULL,  NULL,
                      '• '||dau_delegation_name_enm||' '||CHR(13)))
               WITHIN GROUP (ORDER BY dau_delegation_name_enm )
          FROM ah012_position_profile_detail,
               th022_profile_code,
               th023_delegation_authority
         WHERE pos_position_nmbr = pop_position_nmbr
           AND pop_profile_cd = pro_profile_cd
           AND pro_delegation_authority_cd IS NOT NULL
           AND pro_delegation_authority_cd = dau_delegation_authority_cd
           AND SYSDATE BETWEEN pop_profile_start_dte AND
                NVL(pop_profile_end_dte, SYSDATE + 1)
            AND pop_date_delete_dte IS NULL )
                                   AS delegation_enm ,
      (SELECT LISTAGG(
               DECODE(dau_delegation_name_fnm, NULL,  NULL,
                      '• '||dau_delegation_name_fnm||' '||CHR(13)))
               WITHIN GROUP (ORDER BY dau_delegation_name_fnm )
          FROM ah012_position_profile_detail,
               th022_profile_code,
               th023_delegation_authority
         WHERE pos_position_nmbr = pop_position_nmbr
           AND pop_profile_cd = pro_profile_cd
           AND pro_delegation_authority_cd IS NOT NULL
           AND pro_delegation_authority_cd = dau_delegation_authority_cd
           AND SYSDATE BETWEEN pop_profile_start_dte AND
                NVL(pop_profile_end_dte, SYSDATE + 1)
            AND pop_date_delete_dte IS NULL )
                                   AS delegation_fnm,
       CASE
         WHEN pos_group_ind IN ('EX', 'DM', 'OC') THEN 1
         ELSE 0
         END  AS ex_position_ind
  FROM positions,
       regions,
       geographic_locations,
       th017_admin_group,
       directorates,
       branch,
       global_validations sec,
       th189_employment_type,
       linguistic_profiles,
       designations,
       global_validations lang_req,
       global_validations exclusion,
       global_validations essential
 WHERE pos_region_ind                     = reg_region_ind(+)
   AND SUBSTR(pos_geo_code,1,2)           = gel_geo_province_code(+)
   AND SUBSTR(pos_geo_code,3,5)           = gel_geo_detail_code(+)
   AND pos_admin_group_ind                = adm_admin_group_cd(+)
   AND pos_directorate_ind                = dir_directorate_ind(+)
   AND pos_branch_ind                     = bra_branch_ind(+)
   AND sec.glv_val_category_ind(+)        = 'GLB'
   AND sec.glv_val_name(+)                = 'SECURITY_CLEARANCE'
   AND sec.glv_val_value_ind(+)           = NVL(pos_security_clearance_ind,'R')
   AND pos_employment_type_code           = employment_type_cd
   AND pos_position_nmbr                  = lpr_position_nmbr(+)
   AND NVL(lpr_status_ind(+), 1)          = 1
   AND lpr_language_requirement_ind       = lang_req.glv_val_value_ind(+)
   AND lang_req.glv_val_category_ind(+)   = 'OL'
   AND lang_req.glv_val_name(+)           = 'OLIF_LANG_REQUIREMENT'
   AND exclusion.glv_val_category_ind(+)  = 'STR'
   AND exclusion.glv_val_name(+)          = 'POSITION_STATUS'
   AND exclusion.glv_val_value_ind(+)     = pos_exclusion_status_ind
   AND pos_position_nmbr                  = des_position_nmbr(+)
   AND des_status_ind(+)                  = '1'
   AND essential.glv_val_category_ind(+)  = 'STR'
   AND essential.glv_val_name(+)          = 'DESIGNATION_TYPE'
   AND essential.glv_val_value_ind(+)     = des_actual_designation_ind
/

-- Create synonym VW_HRSR_POSITION_INFO_DETAILS
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_position_info_details
  FOR vw_hrsr_position_info_details
/

-- Grants for View
GRANT SELECT ON vw_hrsr_position_info_details TO tipsuser
/
GRANT SELECT ON vw_hrsr_position_info_details TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_POSITION_INFO_DETAILS

