-- Start of DDL Script for View TIPS.VW_HRSR_MILESTONE_PROGRESS
-- Generated 2019-11-13 10:15:51 AM from TIPS@TIPSUAT.WORLD

CREATE OR REPLACE VIEW vw_hrsr_milestone_progress (
   hrsr_progress_tracker_id,
   hrsr_request_cd,
   milestone_cd,
   date_milestone_met_dte,
   milestone_enm,
   milestone_fnm,
   employee_display_nm )
AS
SELECT a.hrsr_progress_tracker_id,
       a.hrsr_request_cd,
       a.milestone_cd,
       a.date_milestone_met_dte,
       b.milestone_enm,
       b.milestone_fnm,
       CASE
         WHEN a.user_last_update_id = 'TIPS' THEN 'TIPS'
         ELSE
           (SELECT NVL(MAX(c.employee_display_name), '')
              FROM mv001_hrsr_person_search c
             WHERE a.user_last_update_id = c.user_id(+))
         END as employee_display_nm
  FROM ah107_hrsr_progress_tracker a,
       th202_milestone b
 WHERE a.milestone_cd = b.milestone_cd
/

-- Create synonym VW_HRSR_MILESTONE_PROGRESS
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_milestone_progress
  FOR vw_hrsr_milestone_progress
/

-- Grants for View
GRANT SELECT ON vw_hrsr_milestone_progress TO tipsuser
/
GRANT SELECT ON vw_hrsr_milestone_progress TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_MILESTONE_PROGRESS

