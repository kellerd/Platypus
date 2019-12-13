-- Start of DDL Script for View TIPS.VH056_HRSR_PERSON_APPROVER
-- Generated 2019-07-16 11:19:34 AM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vh056_hrsr_person_approver (
   pin,
   persontypecode,
   fisrtname,
   lastname,
   displayname,
   searchname,
   geocode,
   positiontitleen,
   positiontitlefr,
   regioncode,
   regionen,
   regionfr,
   admingroupen,
   admingroupfr,
   pos_position_nmbr,
   activecode )
AS
SELECT DISTINCT
    a.per_pin pin,
    a.per_type_code PersonTypeCode,
    a.per_given_name FisrtName,
    a.per_family_name LastName,
    DECODE(a.per_given_name,NULL,a.per_family_name,a.per_family_name || ', ' || a.per_given_name) || nvl(' ' || initcap(a.per_middle_name),'') DisplayName,
    a.per_search_name SearchName,
    a.per_geo_code GeoCode,
    d.POS_ALTERNATE_TITLE_E PositionTitleEn,
    d.POS_ALTERNATE_TITLE_F PositionTitleFr,
    d.POS_REGION_IND RegionCode,
    e.REG_REGION_DESC_E RegionEn,
    e.REG_REGION_DESC_F RegionFr,        
    b.ADM_ADMIN_GROUP_NAME_ENM AdminGroupEn,
    b.ADM_ADMIN_GROUP_NAME_FNM AdminGroupFr,
    d.pos_position_nmbr,
    emp.emp_active_code ActiveCode
FROM
    tips.persons a
    JOIN tips.EMPLOYEES emp on a.PER_PIN = emp.emp_pin
    INNER JOIN tips.assignments c ON a.per_pin = c.asn_employee_pin
    JOIN tips.positions d ON c.asn_position_nmbr = d.pos_position_nmbr
    JOIN tips.regions e ON d.pos_region_ind = e.reg_region_ind
    JOIN tips.th017_admin_group b ON d.pos_admin_group_ind = b.adm_admin_group_cd
    JOIN VH011_HRSR_APPROVER r ON a.per_pin = r.employee_pin
WHERE
    SYSDATE BETWEEN c.asn_effective_start_date AND nvl(c.asn_effective_end_date,SYSDATE)
    AND a.per_type_code = (SELECT MIN(per_type_code) FROM tips.persons p2 WHERE p2.per_pin = a.per_pin)
/

-- Create synonym VH056_HRSR_PERSON_APPROVER
CREATE OR REPLACE PUBLIC SYNONYM vh056_hrsr_person_approver
  FOR vh056_hrsr_person_approver
/

-- Grants for View
GRANT SELECT ON vh056_hrsr_person_approver TO tipsuser
/
GRANT SELECT ON vh056_hrsr_person_approver TO everything_in_tips
/

-- End of DDL Script for View TIPS.VH056_HRSR_PERSON_APPROVER

