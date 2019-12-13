-- Start of DDL Script for View TIPS.VH007_EMPLOYMENT_TYPE
-- Generated 2019-04-30 11:58:16 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vh007_employment_type (
   glv_val_value_ind,
   glv_val_desc_e,
   glv_val_desc_f,
   glv_display_seq_nmbr,
   tya_id )
AS
SELECT th189.employment_type_cd   AS glv_val_value_ind,
       th189.employment_type_enm  AS glv_val_desc_e,
       th189.employment_type_fnm  AS glv_val_desc_f,
       LPAD(TO_CHAR(th189.display_order_num),3,'0')   AS glv_display_seq_nmbr,
       TO_NUMBER(th190.act_action_cd) AS tya_id
  FROM th189_employment_type  th189,
       th190_xref_th048_th189 th190
 WHERE th189.employment_type_cd = th190.employment_type_cd
/



-- End of DDL Script for View TIPS.VH007_EMPLOYMENT_TYPE

