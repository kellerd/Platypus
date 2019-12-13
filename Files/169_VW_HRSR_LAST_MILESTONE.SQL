-- Start of DDL Script for View TIPS.VW_HRSR_LAST_MILESTONE
-- Generated 2019-10-04 11:51:47 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_last_milestone (
   hrsr_request_cd,
   milestone_cd,
   date_milestone_met_dte,
   milestone_enm,
   milestone_fnm )
AS
SELECT hrsr_request_cd,
       milestone_cd,
       date_milestone_met_dte,
       milestone_enm,
       milestone_fnm
FROM ( SELECT a.hrsr_request_cd as hrsr_request_cd,
              a.milestone_cd as milestone_cd,
              a.date_milestone_met_dte as date_milestone_met_dte,
              b.milestone_enm as milestone_enm,
              b.milestone_fnm as milestone_fnm,
              row_number() over( partition by hrsr_request_cd
                 ORDER BY a.date_last_update_dte desc,
                 a.hrsr_progress_tracker_id DESC ) as rn
      FROM ah107_hrsr_progress_tracker a,
           th202_milestone b
      WHERE a.milestone_cd = b.milestone_cd
        AND a.milestone_cd != 'NEW')
 WHERE rn = 1
/

-- Create synonym VW_HRSR_LAST_MILESTONE
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_last_milestone
  FOR vw_hrsr_last_milestone
/

-- Grants for View
GRANT SELECT ON vw_hrsr_last_milestone TO lexx
/
GRANT SELECT ON vw_hrsr_last_milestone TO tipsuser
/
GRANT SELECT ON vw_hrsr_last_milestone TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_LAST_MILESTONE

