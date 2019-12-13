-- Start of DDL Script for View TIPS.VW_HRSR_APPROVER_SEARCH
-- Generated 2019-04-01 3:36:41 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_approver_search (
   per_pin,
   pou_user_id,
   per_family_name,
   per_given_name,
   per_middle_name )
AS
SELECT per_pin,
       pou_user_id,
       per_family_name,
       per_given_name,
       per_middle_name
  FROM persons,
       portal_users
 WHERE per_pin = pou_pri(+)
   AND per_type_code = '1'
   AND EXISTS (SELECT *
                 FROM ah010_employee_profile_detail ,
                      th022_profile_code
                WHERE epr_employee_pin = per_pin
                  AND epr_profile_cd = pro_profile_cd
                  AND pro_delegation_authority_cd = 'STF'
                  AND NVL(pro_date_delete_dte, SYSDATE + 1) > SYSDATE
                  AND epr_date_delete_dte IS NULL
                  AND SYSDATE BETWEEN epr_profile_start_dte AND
                      NVL(epr_profile_end_dte,SYSDATE + 1))
   AND EXISTS (SELECT *
                 FROM assignments   
                WHERE asn_employee_pin = per_pin
                  AND SYSDATE BETWEEN asn_effective_start_date AND
                      NVL(asn_effective_end_date, SYSDATE + 1))
UNION
SELECT per_pin,
       pou_user_id,
       per_family_name,
       per_given_name,
       per_middle_name
  FROM persons,
       portal_users
 WHERE per_pin = pou_pri(+)
   AND per_type_code = '1'
   AND EXISTS (SELECT *
                 FROM ah027_hrsr_request a
                WHERE rqt_approver_pin = per_pin)
/

CREATE OR REPLACE PUBLIC SYNONYM VW_HRSR_APPROVER_SEARCH FOR tips.VW_HRSR_APPROVER_SEARCH
/

GRANT SELECT ON VW_HRSR_APPROVER_SEARCH TO tipsuser;
GRANT SELECT ON VW_HRSR_APPROVER_SEARCH TO everything_in_tips;


-- End of DDL Script for View TIPS.VW_HRSR_APPROVER_SEARCH

