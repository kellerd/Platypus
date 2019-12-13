-- Start of DDL Script for View TIPS.VH059_HRSR_PERSON_SECONDMENT
-- Generated 2019-04-08 1:28:01 PM from TIPS@TIPSD.WORLD

CREATE OR REPLACE VIEW VH059_HRSR_PERSON_SECONDMENT (
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
  WHERE (a.per_type_code IN ('6', '7' ) -- Secondments
         OR NVL(emp.emp_active_code,'') IN ('2','3')) -- SOS AND TSOS
    AND NVL(t.asn_effective_end_date, SYSDATE) >= ADD_MONTHS(SYSDATE, -12)
/

CREATE OR REPLACE PUBLIC SYNONYM VH059_HRSR_PERSON_SECONDMENT FOR VH059_HRSR_PERSON_SECONDMENT;

-- Grants for View
GRANT SELECT ON VH059_HRSR_PERSON_SECONDMENT TO tipsuser
/
GRANT SELECT ON VH059_HRSR_PERSON_SECONDMENT TO everything_in_tips
/
GRANT SELECT ON VH059_HRSR_PERSON_SECONDMENT TO hsrgp1
/
-- End of DDL Script for View TIPS.VH059_HRSR_PERSON_SECONDMENT

