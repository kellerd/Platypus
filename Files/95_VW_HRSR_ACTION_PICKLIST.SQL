-- Start of DDL Script for View TIPS.VW_HRSR_ACTION_PICKLIST
-- Generated 2019-05-15 6:27:48 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_action_picklist (
   request_type_cd,
   request_type_enm,
   request_type_fnm,
   action_cd,
   action_enm,
   action_fnm,
   extension_cd,
   extension_enm,
   extension_fnm,
   funtion_action_cd,
   funtion_action_enm,
   funtion_action_fnm,
   employment_type_cd,
   employment_type_enm,
   employment_type_fnm )
AS
SELECT th056.xaf_category_ind       AS category_type_cd,
       th047.typ_hrsr_type_etxt     AS category_type_enm,
       th047.typ_hrsr_type_ftxt     AS category_type_fnm,
       th048.act_action_cd          AS hrsr_action_cd,
       th048.act_hrsr_action_enm    AS hrsr_action_enm,
       th048.act_hrsr_action_fnm    AS hrsr_action_fnm,
       th053.ext_extension_cd       AS extension_cd,
       th053.ext_extension_name_enm AS extension_enm,
       th053.ext_extension_name_fnm AS extension_fnm,
       fua.fua_action_code_e        AS funtion_action_cd,
       fua.fua_action_desc_e        AS funtion_action_enm,
       fua.fua_action_desc_f        AS funtion_action_fnm,
       th189.employment_type_cd     AS employment_type_cd,
       th189.employment_type_enm    AS employment_type_enm,
       th189.employment_type_fnm    AS employment_type_fnm
  FROM th047_hrsr_type        th047,
       th056_xref_th048_fua   th056,
       th048_hrsr_action      th048,
       th053_extension_cd     th053,
       function_actions       fua,
       th189_employment_type  th189,
       th190_xref_th048_th189 th190 
 WHERE th047.typ_hrsr_type_cd = th048.act_hrsr_type_cd
   AND th056.xaf_action_cd    = th048.act_action_cd
   AND th056.xaf_action_ind   = fua.fua_action_ind
   AND th056.xaf_category_ind = fua.fua_category_ind
   AND th056.ext_extension_cd = th053.ext_extension_cd(+)
   AND th056.xaf_category_ind IN ('STF','TA')
   AND th048.act_action_cd    = th190.act_action_cd(+)
   AND th189.employment_type_cd(+) = th190.employment_type_cd
   AND th056.xaf_category_ind = th047.typ_hrsr_type_cd
/

-- Create synonym VW_HRSR_ACTION_PICKLIST
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_action_picklist
  FOR vw_hrsr_action_picklist
/

-- Grants for View
GRANT SELECT ON vw_hrsr_action_picklist TO tipsuser
/
GRANT SELECT ON vw_hrsr_action_picklist TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_ACTION_PICKLIST

