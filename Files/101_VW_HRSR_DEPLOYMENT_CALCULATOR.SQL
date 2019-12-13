-- Start of DDL Script for View TIPS.VW_HRSR_DEPLOYMENT_CALCULATOR
-- Generated 2019-11-14 3:09:11 PM from TIPS@TIPSUAT.WORLD

CREATE OR REPLACE VIEW vw_hrsr_deployment_calculator (
   pra_group_ind,
   pra_subgroup_ind,
   pra_level_ind,
   pra_step_ind,
   pra_bud_code,
   pra_effective_date,
   pra_rate_base,
   pra_salary_amount,
   step_increment )
AS
SELECT pra_group_ind,
       pra_subgroup_ind,
       pra_level_ind,
       pra_step_ind,
       pra_bud_code,
       pra_effective_date,
       pra_rate_base,
       CASE
         WHEN pra_rate_base = '9' THEN
              pra_salary_amount
         WHEN pra_rate_base = '1' AND pra_group_ind IN ('GL','GS') THEN
              pra_salary_amount * (40 * 52)
         WHEN pra_rate_base = '1' AND pra_group_ind NOT IN ('GL','GS') THEN
              pra_salary_amount * (37.5 * 52)
         END AS pra_salary_amount,
       CASE
         WHEN pra_step_ind = '000' THEN
              NULL
         WHEN pra_step_ind = 'MAX' AND pra_group_ind = 'EX' THEN
              (SELECT MIN(step.pra_salary_amount)* 0.05
                 FROM pay_rates step
                WHERE step.pra_step_ind = 'MIN'
                  AND step.pra_group_ind = pra.pra_group_ind
                  AND step.pra_subgroup_ind = pra.pra_subgroup_ind
                  AND step.pra_level_ind = pra.pra_level_ind
                  AND step.pra_effective_date = pra.pra_effective_date
                  AND step.pra_bud_code = pra.pra_bud_code)
          WHEN pra_step_ind = 'MAX' AND pra_rate_base = '1' AND
               pra_group_ind NOT IN ('GL','GS') THEN
               (SELECT (MIN(step.pra_salary_amount) * (37.5 * 52)) * 0.04
                  FROM pay_rates step
                 WHERE pra_step_ind = 'MIN'
                  AND step.pra_group_ind = pra.pra_group_ind
                  AND step.pra_subgroup_ind = pra.pra_subgroup_ind
                  AND step.pra_level_ind = pra.pra_level_ind
                  AND step.pra_effective_date = pra.pra_effective_date
                  AND step.pra_bud_code = pra.pra_bud_code)
          WHEN pra_step_ind = 'MAX' AND pra_rate_base = '1' AND
               pra_group_ind IN ('GL','GS') THEN
               (SELECT (MIN(step.pra_salary_amount) * (40 * 52)) * 0.04
                  FROM pay_rates step
                 WHERE pra_step_ind = 'MIN'
                  AND step.pra_group_ind = pra.pra_group_ind
                  AND step.pra_subgroup_ind = pra.pra_subgroup_ind
                  AND step.pra_level_ind = pra.pra_level_ind
                  AND step.pra_effective_date = pra.pra_effective_date
                  AND step.pra_bud_code = pra.pra_bud_code)
         WHEN pra_step_ind = 'MAX' AND pra_group_ind != 'EX' THEN
              (SELECT MIN(step.pra_salary_amount)* 0.04
                 FROM pay_rates step
                WHERE step.pra_step_ind = 'MIN'
                  AND step.pra_group_ind = pra.pra_group_ind
                  AND step.pra_subgroup_ind = pra.pra_subgroup_ind
                  AND step.pra_level_ind = pra.pra_level_ind
                  AND step.pra_effective_date = pra.pra_effective_date
                  AND step.pra_bud_code = pra.pra_bud_code)
         WHEN pra_step_ind NOT LIKE '0%' THEN
              NULL
         ELSE
            CASE
              WHEN pra_rate_base = '9' THEN
                   (SELECT MAX(pra.pra_salary_amount - step.pra_salary_amount)
                      FROM pay_rates step
                     WHERE TO_NUMBER(pra.pra_step_ind)-1 = TO_NUMBER(step.pra_step_ind)
                       AND pra_step_ind LIKE '0%'
                       AND step.pra_group_ind = pra.pra_group_ind
                       AND step.pra_subgroup_ind = pra.pra_subgroup_ind
                       AND step.pra_level_ind = pra.pra_level_ind
                       AND step.pra_effective_date = pra.pra_effective_date
                       AND step.pra_bud_code = pra.pra_bud_code)
              WHEN pra_rate_base = '1' AND pra_group_ind IN ('GL','GS') THEN
                   (SELECT MAX(pra.pra_salary_amount - step.pra_salary_amount) * (40 * 52)
                      FROM pay_rates step
                     WHERE TO_NUMBER(pra.pra_step_ind)-1 = TO_NUMBER(step.pra_step_ind)
                       AND pra_step_ind LIKE '0%'
                       AND step.pra_group_ind = pra.pra_group_ind
                       AND step.pra_subgroup_ind = pra.pra_subgroup_ind
                       AND step.pra_level_ind = pra.pra_level_ind
                       AND step.pra_effective_date = pra.pra_effective_date
                       AND step.pra_bud_code = pra.pra_bud_code)
              WHEN pra_rate_base = '1' AND pra_group_ind NOT IN ('GL','GS') THEN
                   (SELECT MAX(pra.pra_salary_amount - step.pra_salary_amount) * (37.5 * 52)
                      FROM pay_rates step
                     WHERE TO_NUMBER(pra.pra_step_ind)-1 = TO_NUMBER(step.pra_step_ind)
                       AND pra_step_ind LIKE '0%'
                       AND step.pra_group_ind = pra.pra_group_ind
                       AND step.pra_subgroup_ind = pra.pra_subgroup_ind
                       AND step.pra_level_ind = pra.pra_level_ind
                       AND step.pra_effective_date = pra.pra_effective_date
                       AND step.pra_bud_code = pra.pra_bud_code)
              END
           END AS step_increment
  FROM pay_rates pra
 WHERE pra.pra_pay_zone = '000'
   AND pra.pra_effective_date =
       (SELECT MAX(pra_effective_date)
          FROM pay_rates max_pra
         WHERE max_pra.pra_group_ind = pra.pra_group_ind
           AND NVL(max_pra.pra_subgroup_ind,'   ') = NVL(pra.pra_subgroup_ind,'   ')
           AND pra_pay_zone = '000'
           AND pra_effective_date BETWEEN ADD_MONTHS(SYSDATE,-120) AND SYSDATE + 1)
   AND EXISTS (SELECT *
                 FROM positions
                WHERE pos_group_ind = pra.pra_group_ind
                  AND NVL(pos_subgroup_ind,'   ') = NVL(pra.pra_subgroup_ind,'   '))
/

-- Create synonym VW_HRSR_DEPLOYMENT_CALCULATOR
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_deployment_calculator
  FOR vw_hrsr_deployment_calculator
/

-- Grants for View
GRANT SELECT ON vw_hrsr_deployment_calculator TO tipsuser
/
GRANT SELECT ON vw_hrsr_deployment_calculator TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_DEPLOYMENT_CALCULATOR

