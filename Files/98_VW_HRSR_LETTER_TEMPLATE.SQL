-- Start of DDL Script for View TIPS.VW_HRSR_LETTER_TEMPLATE
-- Generated 2019-04-27 5:20:04 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_letter_template (
   hrsr_letter_id,
   hrsr_letter_enm,
   hrsr_letter_fnm,
   hrsr_letter_section_id,
   hrsr_letter_section_enm,
   hrsr_letter_section_fnm,
   section_display_order_num,
   hrsr_letter_body_etxt,
   hrsr_letter_body_ftxt,
   body_display_order_num )
AS
SELECT ah098.hrsr_letter_id,
       ah098.hrsr_letter_enm,
       ah098.hrsr_letter_fnm,
       ah099.hrsr_letter_section_id,
       th188.hrsr_letter_section_enm,
       th188.hrsr_letter_section_fnm,
       ah099.display_order_num,
       ah099.hrsr_letter_body_etxt,
       ah099.hrsr_letter_body_ftxt,
       th188.display_order_num
  FROM ah098_hrsr_letter          ah098,
       ah099_hrsr_letter_body     ah099,
       th188_hrsr_letter_section  th188
 WHERE ah099.hrsr_letter_id = ah098.hrsr_letter_id
   AND ah099.hrsr_letter_section_id = th188.hrsr_letter_section_id
/

CREATE OR REPLACE PUBLIC synonym VW_HRSR_LETTER_TEMPLATE FOR tips.VW_HRSR_LETTER_TEMPLATE
/
GRANT SELECT ON VW_HRSR_LETTER_TEMPLATE TO tipsuser
/
GRANT SELECT ON VW_HRSR_LETTER_TEMPLATE to everything_in_Tips
/


-- End of DDL Script for View TIPS.VW_HRSR_LETTER_TEMPLATE

