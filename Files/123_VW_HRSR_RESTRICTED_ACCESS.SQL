-- Start of DDL Script for View TIPS.VW_HRSR_RESTRICTED_ACCESS
-- Generated 2019-06-10 1:40:34 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_restricted_access (
   hsc_hrsr_request_cd,
   hsc_employee_pin,
   hsc_date_start_dte,
   employee_name )
AS
SELECT hrsr_request_cd,
       employee_pin,
       date_restricted_start_dte,
       RTRIM(tips.get_person_name(employee_pin)) AS EMPLOYEE_NAME
  FROM ah108_hrsr_restricted_access
 WHERE date_restricted_end_dte IS NULL
/

CREATE OR REPLACE PUBLIC SYNONYM VW_HRSR_RESTRICTED_ACCESS FOR TIPS.VW_HRSR_RESTRICTED_ACCESS;

GRANT SELECT ON VW_HRSR_RESTRICTED_ACCESS TO TIPSUSER;
GRANT SELECT ON VW_HRSR_RESTRICTED_ACCESS TO EVERYTHING_IN_TIPS;

-- End of DDL Script for View TIPS.VW_HRSR_RESTRICTED_ACCESS

