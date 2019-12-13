-- Start of DDL Script for View TIPS.VW_HRSR_ACTIVE_SUBSTANTIVE_ASN
-- Generated 2019-07-09 9:09:46 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_active_substantive_asn (
   employee_pin,
   substantive_position_nmbr,
   asn_type_cd,
   asn_start_dte,
   asn_end_dte,
   classn_group_txt,
   classn_subgroup_txt,
   classn_level_txt,
   classn_txt,
   bud_code_txt,
   asn_title_enm,
   asn_title_fnm,
   aww,
   sww )
AS
SELECT asn_employee_pin                AS employee_pin,
       asn_position_nmbr               AS substantive_position_nmbr,
       asn_assignment_type_code        AS asn_type_cd,
       asn_effective_start_date        AS asn_start_dte,
       asn_effective_end_date          AS asn_end_dte,
       asn_classn_group_ind            AS classn_group_txt,
       asn_classn_subgroup_ind         AS classn_subgroup_txt,
       asn_classn_level_ind            AS classn_level_txt,
       asn_classn_group_ind||
           asn_classn_subgroup_ind||
           asn_classn_level_ind        AS classn_txt,
       asn_bud_code                    AS bud_code_txt,
       asn_title_e                     AS asn_title_enm,
       asn_title_f                     AS asn_title_fnm,
       asn_assigned_work_week_hours    AS aww,
        asn_standard_work_week_hours   AS sww
  FROM assignments
 WHERE NVL(asn_effective_end_date, SYSDATE + 100) > SYSDATE
   AND EXISTS (SELECT *
                 FROM assignment_types
                WHERE ast_assignment_type_code = asn_assignment_type_code
                  AND ast_incumbent_type_flag = '1' )
/

-- Create synonym VW_HRSR_ACTIVE_SUBSTANTIVE_ASN
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_active_substantive_asn
  FOR vw_hrsr_active_substantive_asn
/

-- Grants for View
GRANT SELECT ON vw_hrsr_active_substantive_asn TO tipsuser
/
GRANT SELECT ON vw_hrsr_active_substantive_asn TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_ACTIVE_SUBSTANTIVE_ASN

