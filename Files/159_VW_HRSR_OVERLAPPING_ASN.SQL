-- Start of DDL Script for View TIPS.VW_HRSR_OVERLAPPING_ASN
-- Generated 25-Sep-19 7:39:55 from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_overlapping_asn (
   hrsr_request_cd,
   employee_pin,
   position_nmbr,
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
SELECT stf_hrsr_request_cd             AS hrsr_request_cd,
       stf_candidate_pin               AS employee_pin,
       asn_position_nmbr               AS position_nmbr,
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
  FROM ah029_hrsr_staffing,
       assignments
 WHERE stf_candidate_pin = asn_employee_pin
   AND stf_asn_start_date_dte BETWEEN asn_effective_start_date AND
       NVL(asn_effective_end_date, stf_asn_start_date_dte + 100)
   AND NVL(NVL(stf_asn_end_date_dte, stf_asn_new_end_date_dte), stf_asn_start_date_dte+100) BETWEEN
       asn_effective_start_date AND
       NVL(asn_effective_end_date, NVL(NVL(stf_asn_end_date_dte, stf_asn_new_end_date_dte), stf_asn_start_date_dte+100))
   AND stf_hrsr_request_cd != NVL(asn_hrsr_request_cd, 'NULL')
/

-- Create synonym VW_HRSR_OVERLAPPING_ASN
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_overlapping_asn
  FOR vw_hrsr_overlapping_asn
/

-- Grants for View
GRANT SELECT ON vw_hrsr_overlapping_asn TO tipsuser
/
GRANT SELECT ON vw_hrsr_overlapping_asn TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_OVERLAPPING_ASN
