-- Start of DDL Script for View TIPS.VW_HRSR_COLLECTIVE_AGREEMENTS
-- Generated 2019-10-22 9:22:41 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_collective_agreements (
   classn_group_ind,
   classn_group_enm,
   classn_group_fnm,
   collective_agreement_ind,
   collective_agreement_enm,
   collective_agreement_fnm )
AS
SELECT cog_group_ind                 AS classn_group_ind,
       grp_group_enm                 AS classn_group_enm,
       grp_group_fnm                 AS classn_group_fnm,
       coa_collective_agreement_ind  AS collective_agreement_ind,
       coa_agreement_desc_e          AS collective_agreement_enm,
       coa_agreement_desc_f          AS collective_agreement_fnm
  FROM collective_agreements,
       collective_agreements_by_group,
       groups
 WHERE coa_collective_agreement_ind = cog_collective_agreement_ind
   AND cog_group_ind = grp_group_ind
   AND EXISTS (SELECT *
                 FROM agreements
                WHERE (agr_expiry_date IS NULL OR
                       agr_expiry_date >= SYSDATE)
                   AND agr_group_ind = cog_group_ind)
   AND grp_hrsr_active_ind = '1'
/

-- Create synonym VW_HRSR_COLLECTIVE_AGREEMENTS
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_collective_agreements
  FOR vw_hrsr_collective_agreements
/

-- Grants for View
GRANT SELECT ON vw_hrsr_collective_agreements TO tipsuser
/
GRANT SELECT ON vw_hrsr_collective_agreements TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_COLLECTIVE_AGREEMENTS

