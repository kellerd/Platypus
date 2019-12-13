-- Start of DDL Script for View TIPS.VH054_HRSR_PERSON_INACTIVE
-- Generated 2019-04-08 1:28:01 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW vh054_hrsr_person_inactive (
   pin,
   firstname,
   lastname,
   displayname,
   position,
   positiontitleen,
   positiontitlefr,
   regioncode,
   regionen,
   regionfr,
   admingroupen,
   admingroupfr,
   assignmentstartdate,
   assignmentenddate,
   activecode )
AS
SELECT  A.PER_PIN                 AS PIN,
        A.PER_GIVEN_NAME          AS FirstName,
        A.PER_FAMILY_NAME         AS LastName,
        DECODE(A.PER_GIVEN_NAME, NULL, A.PER_FAMILY_NAME,
               A.PER_FAMILY_NAME || ', ' || A.PER_GIVEN_NAME) AS DisplayName,
        D.POS_POSITION_NMBR        AS Position,
        d.POS_ALTERNATE_TITLE_E    AS PositionTitleEn,
        d.POS_ALTERNATE_TITLE_F    AS PositionTitleFr,
        D.POS_REGION_IND           AS RegionCode,
        E.REG_REGION_DESC_E        AS RegionEn,
        E.REG_REGION_DESC_F        AS RegionFr,
        B.ADM_ADMIN_GROUP_NAME_ENM AS AdminGroupEn,
        B.ADM_ADMIN_GROUP_NAME_FNM AS AdminGroupFr,
        t.asn_effective_start_date AS AssignmentStartDate,
        t.asn_effective_end_date   AS AssignmentEndDate,
        emp.emp_active_code        AS ActiveCode
   FROM tips.PERSONS A
   JOIN tips.ALL_ASSIGNMENTS t ON t.asn_employee_pin = a.per_pin
   JOIN tips.ALL_POSITIONS D on t.ASN_POSITION_NMBR = D.POS_POSITION_NMBR
   JOIN tips.REGIONS E on D.POS_REGION_IND = E.REG_REGION_IND
   JOIN tips.TH017_ADMIN_GROUP B on D.POS_ADMIN_GROUP_IND = B.ADM_ADMIN_GROUP_CD
   JOIN tips.EMPLOYEES emp on a.PER_PIN = emp.emp_pin
  WHERE emp.emp_active_code = '3'
    AND NVL(t.asn_effective_end_date, SYSDATE) >= ADD_MONTHS(SYSDATE, -12)
    AND a.per_type_code = (SELECT MIN(z.per_type_code)
                             FROM persons z
                            WHERE z.per_pin = a.per_pin)
/

CREATE OR REPLACE PUBLIC SYNONYM VH054_HRSR_PERSON_INACTIVE FOR VH054_HRSR_PERSON_INACTIVE;

-- Grants for View
GRANT SELECT ON VH054_HRSR_PERSON_INACTIVE TO tipsuser
/
GRANT SELECT ON VH054_HRSR_PERSON_INACTIVE TO everything_in_tips
/
GRANT SELECT ON VH054_HRSR_PERSON_INACTIVE TO hsrgp1
/
-- End of DDL Script for View TIPS.VH054_HRSR_PERSON_INACTIVE

