-- Start of DDL Script for View TIPS.VW_HRSR_GEOGRAPHIC_LOCATIONS
-- Generated 2019-04-01 2:32:56 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vw_hrsr_geographic_locations (
   region_ind,
   region_etxt,
   region_ftxt,
   geo_code_cd,
   geo_code_desc,
   geo_code_province )
AS
SELECT glr_region_ind AS region_ind,
       reg_region_desc_e AS region_etxt,
       reg_region_desc_f AS region_ftxt,
       gel_geo_province_code||gel_geo_detail_code AS geo_code_cd,
       gel_geo_desc AS geo_code_desc,
       gel_province AS geo_code_province
  FROM geographic_locations,
       geographic_locations_by_region,
       regions
 WHERE NVL(gel_used_by_tc_flag,'1') = '1'
   AND gel_geo_province_code = glr_province_code
   AND reg_region_ind = glr_region_ind
/

CREATE OR REPLACE PUBLIC SYNONYM VW_HRSR_GEOGRAPHIC_LOCATIONS FOR TIPS.VW_HRSR_GEOGRAPHIC_LOCATIONS
/

GRANT SELECT ON VW_HRSR_GEOGRAPHIC_LOCATIONS TO TIPSUSER;

GRANT SELECT ON VW_HRSR_GEOGRAPHIC_LOCATIONS TO EVERYTHING_IN_TIPS;

-- End of DDL Script for View TIPS.VW_HRSR_GEOGRAPHIC_LOCATIONS

