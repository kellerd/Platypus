-- Start of DDL Script for View TIPS.VW_HRSR_ACTIVE_CLASSIFICATION
-- Generated 2019-11-18 10:22:36 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_active_classification (
   lvl_group_ind,
   lvl_subgroup_ind,
   lvl_level_ind )
AS
SELECT lvl_group_ind                 AS lvl_group_ind,
       NVL(lvl_subgroup_ind, '   ')  AS lvl_subgroup_ind,
       lvl_level_ind                 AS lvl_level_ind
  FROM all_levels
 WHERE EXISTS (SELECT * 
                 FROM groups
                WHERE grp_group_ind = lvl_group_ind
                  AND grp_hrsr_active_ind = 1) 
   AND EXISTS (SELECT *
                 FROM all_positions
                WHERE pos_group_ind = lvl_group_ind
                  AND NVL(pos_subgroup_ind,'   ') = NVL(lvl_subgroup_ind,'   ')
                  AND pos_level_ind = lvl_level_ind)
/

-- Create synonym VW_HRSR_ACTIVE_CLASSIFICATION
CREATE OR REPLACE PUBLIC SYNONYM vw_hrsr_active_classification
  FOR vw_hrsr_active_classification
/

-- Grants for View
GRANT SELECT ON vw_hrsr_active_classification TO tipsuser
/
GRANT SELECT ON vw_hrsr_active_classification TO everything_in_tips
/

-- End of DDL Script for View TIPS.VW_HRSR_ACTIVE_CLASSIFICATION

