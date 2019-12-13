-- Start of DDL Script for View TIPS.VW_HRSR_STUDENT_PAY_RATES
-- Generated 2019-09-04 7:43:25 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_student_pay_rates (
   student_assignment_type,
   assignment_type_enm,
   assignment_type_fnm,
   education_level_cd,
   education_level_enm,
   education_level_fnm,
   bud_code_txt,
   classn_group_ind,
   classn_subgroup_ind,
   classn_level_ind,
   pay_step_id,
   pay_effective_dte,
   salary_amt,
   disbursement_rate_cd,
   pay_zone )
AS
SELECT th196.assignment_type_cd     AS student_assignment_type,
       ast_assignment_type_desc_e   AS assignment_type_enm,
       ast_assignment_type_desc_f   AS assignment_type_fnm,
       th196.education_level_cd     AS education_level_cd,
       th195.education_level_enm    AS education_level_enm,
       th195.education_level_fnm    AS education_level_fnm,
       th196.bud_code_txt           AS bud_code_txt,
       pra_group_ind                AS classn_group_ind,
       pra_subgroup_ind             AS classn_subgroup_ind,
       pra_level_ind                AS classn_level_ind,
       pra_step_ind                 AS pay_step_id,
       pra_effective_date           AS pay_effective_dte,
       pra_salary_amount            AS salary_amt,
       CASE
         WHEN pra_rate_base = '9' THEN 'Y'
         WHEN pra_rate_base = '1' THEN 'H'
         ELSE pra_rate_base
         END                        AS disbursement_rate_cd,
       pra_pay_zone                 AS pay_zone
  FROM th196_student_bud_code  th196,
       th195_education_level   th195,
       assignment_types,
       pay_rates a
 WHERE bud_code_txt = pra_bud_code
   AND th196.education_level_cd = th195.education_level_cd
   AND th196.assignment_type_cd = ast_assignment_type_code
   AND a.pra_effective_date = (SELECT MAX(b.pra_effective_date)
                                 FROM pay_rates b
                                WHERE b.pra_group_ind = a.pra_group_ind
                                  AND b.pra_group_ind = 'ZZ' )
/

-- Create synonym VW_HRSR_STUDENT_PAY_RATES
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_student_pay_rates
  FOR vw_hrsr_student_pay_rates
/

-- Grants for View
GRANT SELECT ON vw_hrsr_student_pay_rates TO tipsuser
/
GRANT SELECT ON vw_hrsr_student_pay_rates TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_STUDENT_PAY_RATES

