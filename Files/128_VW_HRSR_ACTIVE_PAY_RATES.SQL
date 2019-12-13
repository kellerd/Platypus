-- Start of DDL Script for View TIPS.VW_HRSR_ACTIVE_PAY_RATES
-- Generated 2019-06-13 7:12:19 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_active_pay_rates (
   classn_group_ind,
   classn_subgroup_ind,
   classn_level_ind,
   pay_step_id,
   pay_effective_dte,
   salary_amt,
   disbursement_rate_cd,
   pay_zone,
   excluded_pay_rate,
   student_assignment_type,
   ti_profile_cd,
   bud_code )
AS
SELECT pra_group_ind       AS classn_group_ind,
       pra_subgroup_ind    AS classn_subgroup_ind,
       pra_level_ind       AS classn_level_ind,
       pra_step_ind        AS pay_step_id,
       pra_effective_date  AS pay_effective_dte,
       pra_salary_amount   AS salary_amt,
       CASE
         WHEN pra_rate_base = '9' THEN 'Y'
         WHEN pra_rate_base = '1' THEN 'H'
         ELSE pra_rate_base
         END               AS disbursement_rate_cd,
       CASE
         WHEN pra_group_ind = 'NU' AND pra_pay_zone = 'A01' THEN
              'Zone 1'
         WHEN pra_group_ind = 'NU' AND pra_pay_zone = 'A02' THEN
              'Zone 2'
         ELSE pra_pay_zone
         END               AS pay_zone,
       CASE
         WHEN pra_pay_zone = 'EXC' THEN
              1
         ELSE 0
         END               AS excluded_pay_rate,
       CASE
         WHEN pra_subgroup_ind = 'STU' THEN
              (SELECT DISTINCT assignment_type_cd
                 FROM th196_student_bud_code
                WHERE bud_code_txt = pra_bud_code)
         END               AS student_assignment_type,
       CASE
         WHEN pra_group_ind = 'TI' THEN
              (SELECT DISTINCT ti_profile_cd
                 FROM th197_ti_profile
                WHERE ti_bud_code_txt = pra_bud_code)
         END               AS ti_profile_cd,
       pra_bud_code        AS bud_code
  FROM pay_rates a
 WHERE a.pra_effective_date = (SELECT MAX(b.pra_effective_date)
                                 FROM pay_rates b
                                WHERE b.pra_group_ind = a.pra_group_ind
                                  AND b.pra_subgroup_ind = a.pra_subgroup_ind )
  AND EXISTS (SELECT *
                FROM positions
               WHERE pos_group_ind = a.pra_group_ind
                 AND pos_subgroup_ind = a.pra_subgroup_ind)
/

-- Create synonym VW_HRSR_ACTIVE_PAY_RATES
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_active_pay_rates
  FOR vw_hrsr_active_pay_rates
/

-- Grants for View
GRANT SELECT ON vw_hrsr_active_pay_rates TO tipsuser
/
GRANT SELECT ON vw_hrsr_active_pay_rates TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_ACTIVE_PAY_RATES

