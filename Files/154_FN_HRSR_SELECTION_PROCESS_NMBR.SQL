-- Start of DDL Script for Function TIPS.FN_HRSR_SELECTION_PROCESS_NMBR
-- Generated 2019-07-23 11:10:20 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE 
FUNCTION fn_hrsr_selection_process_nmbr(
  v_hrsr_request_cd   IN ah027_hrsr_request.rqt_hrsr_request_cd%TYPE)
RETURN assignments.asn_selection_process_nmbr%TYPE
IS
--
-- Created by: Jennifer Hynes, Jul 18, 2019
--
-- Purpose: Returns the selection process number for the HRSR number passed in
--
-- MODIFICATION HISTORY
-- Person     Date       Comments
-- ---------  ---------  -------------------------------------------------------
--

BEGIN
  FOR hrsr_request_rec IN (
      SELECT CASE
               WHEN ah027.rqt_action_cd IN ('13', '27',       -- Casual
                                            '20', '28') THEN  -- Student
                    TO_CHAR(SYSDATE,'YY')||'-'||
                   (SELECT glv_val_value_ind
                      FROM global_validations
                     WHERE glv_val_name LIKE 'FEDERAL_DEPARTMENTS')||'-'||
                   DECODE(ah027.rqt_action_cd, '13', 'CEO',  -- Casual
                                               '27', 'CEO',  -- Casual
                                               '20', 'SE',   -- Student
                                               '28', 'SE')   -- Student
                 ||'-AUT-'|| SUBSTR(ah027.rqt_hrsr_request_cd, 6, 10)
               END AS selection_process_nmbr
        FROM ah027_hrsr_request ah027
       WHERE ah027.rqt_hrsr_request_cd = v_hrsr_request_cd
  ) LOOP
    RETURN hrsr_request_rec.selection_process_nmbr;
  END LOOP;
  -- If there is no matching HRSR record, return NULL
  RETURN NULL;
END fn_hrsr_selection_process_nmbr;
/

CREATE OR REPLACE PUBLIC SYNONYM fn_hrsr_selection_process_nmbr 
  FOR tips.fn_hrsr_selection_process_nmbr
/

GRANT EXECUTE ON fn_hrsr_selection_process_nmbr TO tipsuser
/ 
GRANT EXECUTE ON fn_hrsr_selection_process_nmbr TO everything_in_tips
/  


-- End of DDL Script for Function TIPS.FN_HRSR_SELECTION_PROCESS_NMBR

