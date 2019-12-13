-- Start of DDL Script for View TIPS.VW_HRSR_CAF_SELECTION_PROCESS
-- Generated 2019-04-15 9:02:51 AM from TIPS@TIPSE.WORLD

CREATE OR REPLACE VIEW vw_hrsr_caf_selection_process (
   hrsr_request_cd,
   case_file_nmbr,
   selection_process_nmbr )
AS
SELECT rcf_hrsr_request_cd        AS hrsr_request_cd ,
       rcf_case_file_nmbr         AS case_file_nmbr,
       rea_selection_process_nmbr AS selection_process_nmbr
  FROM ah067_xref_ah027_caf,
       resource_activities
 WHERE rcf_case_file_nmbr = rea_case_nmbr
/

CREATE OR REPLACE PUBLIC SYNONYM VW_HRSR_CAF_SELECTION_PROCESS FOR TIPS.VW_HRSR_CAF_SELECTION_PROCESS;

GRANT SELECT ON VW_HRSR_CAF_SELECTION_PROCESS TO TIPSUSER;
GRANT SELECT ON VW_HRSR_CAF_SELECTION_PROCESS TO EVERYTHING_IN_TIPS;
GRANT SELECT ON VW_HRSR_CAF_SELECTION_PROCESS TO HSRGP1;

-- End of DDL Script for View TIPS.VW_HRSR_CAF_SELECTION_PROCESS

