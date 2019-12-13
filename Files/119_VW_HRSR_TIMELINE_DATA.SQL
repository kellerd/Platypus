-- Start of DDL Script for View TIPS.VW_HRSR_TIMELINE_DATA
-- Generated 2019-08-09 9:27:43 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_timeline_data (
   hrsr_request_cd,
   hrsr_created_dte,
   assigned_to_initator_dte,
   assigned_to_recommender_dte,
   assigned_to_approver_dte,
   approved_dte,
   assigned_to_hr_dte,
   assigned_to_hr_triage_dte,
   assigned_to_hr_advisor_dte,
   loo_generated_dte,
   signed_loo_uploaded_dte,
   pri_assigned_dte,
   hrsr_complete_dte,
   hrsr_finalize_dte )
AS
SELECT rqt_hrsr_request_cd  AS hrsr_request_cd,
       (SELECT MAX(date_milestone_met_dte)
          FROM ah107_hrsr_progress_tracker
         WHERE rqt_hrsr_request_cd  = hrsr_request_cd
           AND milestone_cd = 'NEW') AS hrsr_created_dte,
       (SELECT MAX(date_milestone_met_dte)
          FROM ah107_hrsr_progress_tracker
         WHERE rqt_hrsr_request_cd  = hrsr_request_cd
           AND milestone_cd = 'INT') AS assigned_to_initator_dte,
       (SELECT MAX(date_milestone_met_dte)
          FROM ah107_hrsr_progress_tracker
         WHERE rqt_hrsr_request_cd  = hrsr_request_cd
           AND milestone_cd = 'REC') AS assigned_to_recommender_dte,
       (SELECT MAX(date_milestone_met_dte)
          FROM ah107_hrsr_progress_tracker
         WHERE rqt_hrsr_request_cd  = hrsr_request_cd
           AND milestone_cd = 'APR') AS assigned_to_approver_dte,
       (SELECT MAX(date_milestone_met_dte)
          FROM ah107_hrsr_progress_tracker
         WHERE rqt_hrsr_request_cd  = hrsr_request_cd
           AND milestone_cd = 'APP') AS approved_dte,
       (SELECT MAX(date_milestone_met_dte)
          FROM ah107_hrsr_progress_tracker
         WHERE rqt_hrsr_request_cd  = hrsr_request_cd
           AND milestone_cd = 'HR') AS assigned_to_hr_dte,
       (SELECT MAX(date_milestone_met_dte)
          FROM ah107_hrsr_progress_tracker
         WHERE rqt_hrsr_request_cd  = hrsr_request_cd
           AND milestone_cd = 'HRT') AS assigned_to_HR_triage_dte,
       (SELECT MAX(date_milestone_met_dte)
          FROM ah107_hrsr_progress_tracker
         WHERE rqt_hrsr_request_cd  = hrsr_request_cd
           AND milestone_cd = 'HRA') AS assigned_to_HR_advisor_dte,
       (SELECT MAX(date_milestone_met_dte)
          FROM ah107_hrsr_progress_tracker
         WHERE rqt_hrsr_request_cd  = hrsr_request_cd
           AND milestone_cd = 'LOG') AS loo_generated_dte,
       (SELECT MAX(date_milestone_met_dte)
          FROM ah107_hrsr_progress_tracker
         WHERE rqt_hrsr_request_cd  = hrsr_request_cd
           AND milestone_cd = 'LOU') AS signed_loo_uploaded_dte,
       (SELECT MAX(date_milestone_met_dte)
          FROM ah107_hrsr_progress_tracker
         WHERE rqt_hrsr_request_cd  = hrsr_request_cd
           AND milestone_cd = 'PRI') AS PRI_assigned_dte,
       (SELECT MAX(date_milestone_met_dte)
          FROM ah107_hrsr_progress_tracker
         WHERE rqt_hrsr_request_cd  = hrsr_request_cd
           AND milestone_cd = 'COM') AS hrsr_complete_dte,
       (SELECT MAX(date_milestone_met_dte)
          FROM ah107_hrsr_progress_tracker
         WHERE rqt_hrsr_request_cd  = hrsr_request_cd
           AND milestone_cd = 'FIN') AS hrsr_finalize_dte
  FROM ah027_hrsr_request
 WHERE SUBSTR(rqt_hrsr_request_cd,1,4) >=
       TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE,'YYYY'),-12),'YYYY')
/

-- Create synonym VW_HRSR_TIMELINE_DATA
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_timeline_data
  FOR vw_hrsr_timeline_data
/

-- Grants for View
GRANT SELECT ON vw_hrsr_timeline_data TO tipsuser
/
GRANT SELECT ON vw_hrsr_timeline_data TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_TIMELINE_DATA

