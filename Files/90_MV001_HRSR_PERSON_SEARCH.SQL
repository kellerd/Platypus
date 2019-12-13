--DROP materialized VIEW MV001_HRSR_PERSON_SEARCH;


CREATE MATERIALIZED VIEW MV001_HRSR_PERSON_SEARCH
BUILD IMMEDIATE 
REFRESH START WITH TRUNC(SYSDATE+1)+3/24 NEXT SYSDATE + 1/24 
AS
SELECT  A.PER_PIN                 AS EMPLOYEE_PIN,
        A.PER_GIVEN_NAME          AS EMPLOYEE_FIRST_NAME,
        A.PER_FAMILY_NAME         AS EMPLOYEE_LAST_NAME,
        DECODE(A.PER_GIVEN_NAME, NULL, A.PER_FAMILY_NAME,
               A.PER_FAMILY_NAME || ', ' || A.PER_GIVEN_NAME) AS EMPLOYEE_DISPLAY_NAME,
        A.PER_SEARCH_NAME          AS EMPLOYEE_SEARCH_NAME,
        D.POS_POSITION_NMBR        AS POSITION_NMBR,
        d.POS_ALTERNATE_TITLE_E    AS POSITION_TITLE_ENM,
        d.POS_ALTERNATE_TITLE_F    AS POSITION_TITLE_FNM,
        D.POS_REGION_IND           AS REGION_CD,
        E.REG_REGION_DESC_E        AS REGION_ENM,
        E.REG_REGION_DESC_F        AS REGION_FNM,
        D.POS_ADMIN_GROUP_IND      AS ADMIN_GROUP_CD,
        B.ADM_ADMIN_GROUP_NAME_ENM AS ADMIN_GROUP_ENM,
        B.ADM_ADMIN_GROUP_NAME_FNM AS ADMIN_GROUP_FNM,
        t.asn_effective_start_date AS ASSIGNMENT_START_DTE,
        t.asn_effective_end_date   AS ASSIGNMENT_END_DTE,
        t.asn_employment_type_code AS EMPLOYMENT_TYPE_CD,
        t.asn_assignment_type_code AS ASSIGNMENT_TYPE_CD,
        a.per_type_code            AS PERSON_TYPE_CD,
        emp.emp_active_code        AS EMPLOYEE_ACTIVE_CD,
        CASE WHEN emp.emp_active_code IN ('1', '2')
              AND SYSDATE BETWEEN t.asn_effective_start_date
                  AND NVL(t.asn_effective_end_date, SYSDATE + 1) THEN 1
             ELSE NULL
             END                   AS EMPLOYEE_ACTIVE_IND,
        CASE WHEN emp.emp_active_code IN ('1', '2')
              AND SYSDATE BETWEEN t.asn_effective_start_date
                  AND NVL(t.asn_effective_end_date, SYSDATE + 1) THEN NULL
             ELSE 1
             END                   AS EMPLOYEE_INACTIVE_IND,
        CASE WHEN a.per_type_code IN ('6', '7' ) THEN 1 -- Secondments
             WHEN emp.emp_active_code IN ('2','3') THEN 1 -- SOS AND TSOS
             ELSE NULL
             END                   AS SECONDMENT_CANDIDATE_IND,
        CASE WHEN a.per_type_code = '1'
              AND emp.emp_active_code = '1'
              AND t.asn_assignment_type_code NOT LIKE 'J%'
              AND t.asn_employment_type_code IN ('A', 'B', 'E', 'F', 'G',
                                                 'H', 'S', 'T') THEN 1
             ELSE NULL
             END                   AS INTERNAL_CANDIDATE_IND,
        CASE WHEN NVL(t.asn_effective_end_date,SYSDATE + 1) >= SYSDATE - 30 THEN 1
             ELSE NULL
             END                   AS CANDIDATE_IND,
        CASE WHEN emp.emp_active_code IN ('1', '2')
              AND SYSDATE BETWEEN t.asn_effective_start_date
                  AND NVL(t.asn_effective_end_date, SYSDATE + 1) THEN 1
             ELSE NULL
             END                   AS HRSR_INITIATOR_IND,
        CASE WHEN EXISTS (SELECT * FROM VH010_HRSR_RECOMMENDER
                           WHERE PER_PIN = EMPLOYEE_PIN) THEN 1
             ELSE NULL
             END                   AS HRSR_RECOMMENDER_IND,
        CASE WHEN EXISTS (SELECT * FROM VH011_HRSR_APPROVER
                           WHERE PER_PIN = EMPLOYEE_PIN) THEN 1
             ELSE NULL
             END                   AS HRSR_APPROVER_IND,
        CASE WHEN EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind IN ('CLSGP1', 'CLSGP3',
                                                         'CLSGP4', 'CLSGP5', 
                                                         'STFS2',  'STFS3',
                                                         'SYSGR1' )
                             AND pou_user_id = uss_user_id) THEN 1
             ELSE NULL
             END                   AS HRSR_ADVISOR_IND,
        CASE WHEN EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind IN ('STFS2',  'STFS3',
                                                         'SYSGR1' )
                             AND pou_user_id = uss_user_id) THEN 1
             ELSE NULL
             END                   AS HRSR_STAFF_ADVISOR_IND, 
        CASE WHEN EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind IN ('CLSGP1', 'CLSGP3',
                                                         'CLSGP4', 'CLSGP5',
                                                         'SYSGR1' )
                             AND pou_user_id = uss_user_id) THEN 1
             ELSE NULL
             END                   AS HRSR_CLASSN_ADVISOR_IND,                           
        CASE WHEN EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind = 'STFS3'
                             AND pou_user_id = uss_user_id) AND 
                  EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind = 'STFS2'
                             AND pou_user_id = uss_user_id) THEN 1
             WHEN EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind = 'SYSGR1'
                             AND pou_user_id = uss_user_id) THEN 1                             
             ELSE NULL
             END                   AS HRSR_EX_STAFFING_IND,   
        CASE WHEN EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind = 'STFS3'
                             AND pou_user_id = uss_user_id) AND 
                  EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind IN ('CLSGP4', 'CLSGP5')
                             AND pou_user_id = uss_user_id) THEN 1
             WHEN EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind = 'SYSGR1'
                             AND pou_user_id = uss_user_id) THEN 1                              
             ELSE NULL
             END                   AS HRSR_EX_CLASSN_IND,  
        CASE WHEN EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind LIKE 'SYS%'
                             AND pou_user_id = uss_user_id) THEN 1 
             END                   AS HRSR_ADMIN_USER_IND,                                                                 
        POU_USER_ID                AS USER_ID            
   FROM tips.PERSONS A
   JOIN tips.ASSIGNMENTS t       ON t.asn_employee_pin = a.per_pin
   JOIN tips.POSITIONS D         ON D.POS_POSITION_NMBR = t.ASN_POSITION_NMBR
   JOIN tips.REGIONS E           ON E.REG_REGION_IND = D.POS_REGION_IND
   JOIN tips.TH017_ADMIN_GROUP B ON B.ADM_ADMIN_GROUP_CD = D.POS_ADMIN_GROUP_IND
   JOIN tips.EMPLOYEES emp       ON emp.emp_pin = a.PER_PIN
   LEFT OUTER JOIN tips.portal_users ON pou_pri = emp.emp_pin 
  WHERE a.per_type_code = (SELECT MIN(z.per_type_code)
                             FROM persons z
                            WHERE z.per_pin = a.per_pin)
   AND emp.emp_active_code IN ('1','2')
   AND SYSDATE BETWEEN asn_effective_start_date AND
       NVL(asn_effective_end_date, SYSDATE + 1)
   AND per_pin NOT LIKE '000000%'
UNION ALL 
SELECT  A.PER_PIN                 AS EMPLOYEE_PIN,
        A.PER_GIVEN_NAME          AS EMPLOYEE_FIRST_NAME,
        A.PER_FAMILY_NAME         AS EMPLOYEE_LAST_NAME,
        DECODE(A.PER_GIVEN_NAME, NULL, A.PER_FAMILY_NAME,
               A.PER_FAMILY_NAME || ', ' || A.PER_GIVEN_NAME) AS EMPLOYEE_DISPLAY_NAME,
        A.PER_SEARCH_NAME          AS EMPLOYEE_SEARCH_NAME,
        D.POS_POSITION_NMBR        AS POSITION_NMBR,
        d.POS_ALTERNATE_TITLE_E    AS POSITION_TITLE_ENM,
        d.POS_ALTERNATE_TITLE_F    AS POSITION_TITLE_FNM,
        D.POS_REGION_IND           AS REGION_CD,
        E.REG_REGION_DESC_E        AS REGION_ENM,
        E.REG_REGION_DESC_F        AS REGION_FNM,
        D.POS_ADMIN_GROUP_IND      AS ADMIN_GROUP_CD,
        B.ADM_ADMIN_GROUP_NAME_ENM AS ADMIN_GROUP_ENM,
        B.ADM_ADMIN_GROUP_NAME_FNM AS ADMIN_GROUP_FNM,
        t.asn_effective_start_date AS ASSIGNMENT_START_DTE,
        t.asn_effective_end_date   AS ASSIGNMENT_END_DTE,
        t.asn_employment_type_code AS EMPLOYMENT_TYPE_CD,
        t.asn_assignment_type_code AS ASSIGNMENT_TYPE_CD,
        a.per_type_code            AS PERSON_TYPE_CD,
        emp.emp_active_code        AS EMPLOYEE_ACTIVE_CD,
        NULL                       AS EMPLOYEE_ACTIVE_IND,
        CASE WHEN emp.emp_active_code = '3' THEN 1
             ELSE NULL
             END                   AS EMPLOYEE_INACTIVE_IND,
        CASE WHEN a.per_type_code IN ('6', '7' ) THEN 1 -- Secondments
             WHEN emp.emp_active_code IN ('2','3') THEN 1 -- SOS AND TSOS
             ELSE NULL
             END                   AS SECONDMENT_CANDIDATE_IND,
        NULL                       AS INTERNAL_CANDIDATE_IND,
        NULL                       AS CANDIDATE_IND,
        NULL                       AS HRSR_INITIATOR_IND,
        NULL                       AS HRSR_RECOMMENDER_IND,
        NULL                       AS HRSR_APPROVER_IND,
        NULL                       AS HRSR_ADVISOR_IND,
        NULL                       AS HRSR_STAFF_ADVISOR_IND, 
        NULL                       AS HRSR_CLASSN_ADVISOR_IND,         
        NULL                       AS HRSR_EX_STAFFING_IND,   
        NULL                       AS HRSR_EX_CLASSN_IND,
        NULL                       AS HRSR_ADMIN_USER_IND,          
        POU_USER_ID                AS USER_ID           
   FROM tips.PERSONS A
   JOIN tips.ASSIGNMENTS t        ON t.asn_employee_pin = a.per_pin
   JOIN tips.ALL_POSITIONS D      ON D.POS_POSITION_NMBR = t.ASN_POSITION_NMBR
   JOIN tips.REGIONS E            ON E.REG_REGION_IND = D.POS_REGION_IND
   JOIN tips.TH017_ADMIN_GROUP B  ON B.ADM_ADMIN_GROUP_CD = D.POS_ADMIN_GROUP_IND
   JOIN tips.EMPLOYEES emp        ON emp.emp_pin = a.PER_PIN
   LEFT OUTER JOIN tips.portal_users ON pou_pri = emp.emp_pin 
  WHERE a.per_type_code = (SELECT MIN(z.per_type_code)
                             FROM persons z
                            WHERE z.per_pin = a.per_pin)
   AND (emp.emp_active_code = '3' OR 
        NOT EXISTS (SELECT * FROM assignments i 
                     WHERE i.asn_employee_pin = a.per_pin
                       AND SYSDATE BETWEEN i.asn_effective_start_date AND 
                           NVL(asn_effective_end_date, SYSDATE+1)))
   AND t.asn_effective_start_date =
          (SELECT MAX(asn_effective_start_date)
             FROM tips.assignments c
            WHERE c.asn_employee_pin = emp_pin
              AND c.asn_effective_start_date <= SYSDATE
              AND c.asn_assignment_type_code NOT IN ('A1','A2')
              AND NVL(c.asn_effective_end_date,
                      TO_DATE('31-DEC-2099', 'DD-MON-YYYY')) =
                        (SELECT MAX(
                                  NVL(asn_effective_end_date,
                                  TO_DATE('31-DEC-2099', 'DD-MON-YYYY')))
                           FROM tips.assignments d
                          WHERE d.asn_employee_pin = emp_pin
                            AND d.asn_effective_start_date <= SYSDATE
                            AND d.asn_assignment_type_code NOT IN ('A1','A2')))
   AND NVL(t.asn_effective_end_date,
           TO_DATE('31-DEC-2099', 'DD-MON-YYYY')) =
               (SELECT MAX(
                         NVL(asn_effective_end_date,
                         TO_DATE('31-DEC-2099', 'DD-MON-YYYY')))
                 FROM tips.assignments b
                WHERE b.asn_employee_pin = emp_pin
                  AND b.asn_effective_start_date <= SYSDATE
                  AND b.asn_assignment_type_code NOT IN ('A1','A2'))
UNION ALL
SELECT  A.PER_PIN                 AS EMPLOYEE_PIN,
        A.PER_GIVEN_NAME          AS EMPLOYEE_FIRST_NAME,
        A.PER_FAMILY_NAME         AS EMPLOYEE_LAST_NAME,
        DECODE(A.PER_GIVEN_NAME, NULL, A.PER_FAMILY_NAME,
               A.PER_FAMILY_NAME || ', ' || A.PER_GIVEN_NAME) AS EMPLOYEE_DISPLAY_NAME,
        A.PER_SEARCH_NAME          AS EMPLOYEE_SEARCH_NAME,
        D.POS_POSITION_NMBR        AS POSITION_NMBR,
        d.POS_ALTERNATE_TITLE_E    AS POSITION_TITLE_ENM,
        d.POS_ALTERNATE_TITLE_F    AS POSITION_TITLE_FNM,
        D.POS_REGION_IND           AS REGION_CD,
        E.REG_REGION_DESC_E        AS REGION_ENM,
        E.REG_REGION_DESC_F        AS REGION_FNM,
        D.POS_ADMIN_GROUP_IND      AS ADMIN_GROUP_CD,
        B.ADM_ADMIN_GROUP_NAME_ENM AS ADMIN_GROUP_ENM,
        B.ADM_ADMIN_GROUP_NAME_FNM AS ADMIN_GROUP_FNM,
        t.asn_effective_start_date AS ASSIGNMENT_START_DTE,
        t.asn_effective_end_date   AS ASSIGNMENT_END_DTE,
        t.asn_employment_type_code AS EMPLOYMENT_TYPE_CD,
        t.asn_assignment_type_code AS ASSIGNMENT_TYPE_CD,
        a.per_type_code            AS PERSON_TYPE_CD,
        emp.emp_active_code        AS EMPLOYEE_ACTIVE_CD,
        NULL                       AS EMPLOYEE_ACTIVE_IND,
        CASE WHEN emp.emp_active_code = '3' THEN 1
             ELSE NULL
             END                   AS EMPLOYEE_INACTIVE_IND,
        CASE WHEN a.per_type_code IN ('6', '7' ) THEN 1 -- Secondments
             WHEN emp.emp_active_code IN ('2','3') THEN 1 -- SOS AND TSOS
             ELSE NULL
             END                   AS SECONDMENT_CANDIDATE_IND,
        NULL                       AS INTERNAL_CANDIDATE_IND,
        NULL                       AS CANDIDATE_IND,
        NULL                       AS HRSR_INITIATOR_IND,
        NULL                       AS HRSR_RECOMMENDER_IND,
        NULL                       AS HRSR_APPROVER_IND,
        NULL                       AS HRSR_ADVISOR_IND,
        NULL                       AS HRSR_STAFF_ADVISOR_IND, 
        NULL                       AS HRSR_CLASSN_ADVISOR_IND,        
        NULL                       AS HRSR_EX_STAFFING_IND, 
        NULL                       AS HRSR_EX_CLASSN_IND,    
        NULL                       AS HRSR_ADMIN_USER_IND,                    
        POU_USER_ID                AS USER_ID           
   FROM tips.PERSONS A
   JOIN tips.OLD_ASSIGNMENTS t    ON t.asn_employee_pin = a.per_pin
   JOIN tips.ALL_POSITIONS D      ON D.POS_POSITION_NMBR = t.ASN_POSITION_NMBR
   JOIN tips.REGIONS E            ON E.REG_REGION_IND = D.POS_REGION_IND
   JOIN tips.TH017_ADMIN_GROUP B  ON B.ADM_ADMIN_GROUP_CD = D.POS_ADMIN_GROUP_IND
   JOIN tips.EMPLOYEES emp        ON emp.emp_pin = a.PER_PIN
   LEFT OUTER JOIN tips.portal_users ON pou_pri = emp.emp_pin 
  WHERE NOT EXISTS (SELECT *
                      FROM assignments xx
                     WHERE per_pin = xx.asn_employee_pin
                       AND xx.asn_assignment_type_code NOT IN ('A1','A2')
                       AND xx.asn_effective_start_date <= SYSDATE)
    AND a.per_type_code = (SELECT MIN(z.per_type_code)
                             FROM persons z
                            WHERE z.per_pin = a.per_pin)
   AND emp.emp_active_code = '3'
   AND t.asn_effective_start_date =
          (SELECT MAX(asn_effective_start_date)
             FROM tips.old_assignments c
            WHERE c.asn_employee_pin = emp_pin
              AND c.asn_effective_start_date <= SYSDATE
              AND c.asn_assignment_type_code NOT IN ('A1','A2')
              AND NVL(c.asn_effective_end_date,
                      TO_DATE('31-DEC-2099', 'DD-MON-YYYY')) =
                        (SELECT MAX(
                                  NVL(asn_effective_end_date,
                                  TO_DATE('31-DEC-2099', 'DD-MON-YYYY')))
                           FROM tips.old_assignments d
                          WHERE d.asn_employee_pin = emp_pin
                            AND d.asn_effective_start_date <= SYSDATE
                            AND d.asn_assignment_type_code NOT IN ('A1','A2')))
   AND NVL(t.asn_effective_end_date,
           TO_DATE('31-DEC-2099', 'DD-MON-YYYY')) =
               (SELECT MAX(
                         NVL(asn_effective_end_date,
                         TO_DATE('31-DEC-2099', 'DD-MON-YYYY')))
                 FROM tips.old_assignments b
                WHERE b.asn_employee_pin = emp_pin
                  AND b.asn_effective_start_date <= SYSDATE
                  AND b.asn_assignment_type_code NOT IN ('A1','A2'))
UNION ALL 

SELECT  A.PER_PIN                 AS EMPLOYEE_PIN,
        A.PER_GIVEN_NAME          AS EMPLOYEE_FIRST_NAME,
        A.PER_FAMILY_NAME         AS EMPLOYEE_LAST_NAME,
        DECODE(A.PER_GIVEN_NAME, NULL, A.PER_FAMILY_NAME,
               A.PER_FAMILY_NAME || ', ' || A.PER_GIVEN_NAME) AS EMPLOYEE_DISPLAY_NAME,
        A.PER_SEARCH_NAME          AS EMPLOYEE_SEARCH_NAME,
        NULL                       AS POSITION_NMBR,
        NULL                       AS POSITION_TITLE_ENM,
        NULL                       AS POSITION_TITLE_FNM,
        PER_REGION_IND             AS REGION_CD,
        E.REG_REGION_DESC_E        AS REGION_ENM,
        E.REG_REGION_DESC_F        AS REGION_FNM,
        NULL                       AS ADMIN_GROUP_CD,
        NULL                       AS ADMIN_GROUP_ENM,
        NULL                       AS ADMIN_GROUP_FNM,
        NULL                       AS ASSIGNMENT_START_DTE,
        NULL                       AS ASSIGNMENT_END_DTE,
        NULL                       AS EMPLOYMENT_TYPE_CD,
        NULL                       AS ASSIGNMENT_TYPE_CD,
        '1'                        AS PERSON_TYPE_CD,
        '1'                        AS EMPLOYEE_ACTIVE_CD,
        1                          AS EMPLOYEE_ACTIVE_IND,
        NULL                       AS EMPLOYEE_INACTIVE_IND,
        NULL                       AS SECONDMENT_CANDIDATE_IND,
        NULL                       AS INTERNAL_CANDIDATE_IND,
        NULL                       AS CANDIDATE_IND, 
        NULL                       AS HRSR_INITIATOR_IND,
        NULL                       AS HRSR_RECOMMENDER_IND,
        NULL                       AS HRSR_APPROVER_IND,
        1                          AS HRSR_ADVISOR_IND,
        CASE WHEN EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind IN ('STFS2',  'STFS3')
                             AND usr_user_id = uss_user_id) THEN 1
             ELSE NULL
             END                   AS HRSR_STAFF_ADVISOR_IND, 
        CASE WHEN EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind IN ('CLSGP1', 'CLSGP3',
                                                         'CLSGP4', 'CLSGP5')
                             AND usr_user_id = uss_user_id) THEN 1
             ELSE NULL
             END                   AS HRSR_CLASSN_ADVISOR_IND,        
        CASE WHEN EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind = 'STFS3'
                             AND usr_user_id = uss_user_id) AND 
                  EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind = 'STFS2'
                             AND usr_user_id = uss_user_id) THEN 1
             ELSE NULL
             END                   AS HRSR_EX_STAFFING_IND,   
        CASE WHEN EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind = 'STFS3'
                             AND uss_user_id = usr_user_id) AND 
                  EXISTS (SELECT * FROM user_services uss
                           WHERE uss.uss_service_ind IN ('CLSGP4', 'CLSGP5')
                             AND uss_user_id = usr_user_id) THEN 1
             ELSE NULL
             END                   AS HRSR_EX_CLASSN_IND,  
        NULL                       AS HRSR_ADMIN_USER_IND,                                      
        usr_user_id                AS USER_ID            
   FROM tips.persons a,
        users,
        tips.regions e  
  WHERE usr_pin = per_pin 
    AND per_region_ind = reg_region_ind(+)
    AND a.per_type_code = (SELECT MIN(z.per_type_code)
                             FROM persons z
                            WHERE z.per_pin = a.per_pin)
    AND per_pin IN ('000000013','000000014','000000023','000000024')                  
/

CREATE OR REPLACE PUBLIC SYNONYM MV001_HRSR_PERSON_SEARCH FOR tips.MV001_HRSR_PERSON_SEARCH;

CREATE OR REPLACE PUBLIC SYNONYM VH053_HRSR_PERSON_SEARCH FOR tips.MV001_HRSR_PERSON_SEARCH;

GRANT SELECT ON MV001_HRSR_PERSON_SEARCH TO tipsuser;
GRANT SELECT ON MV001_HRSR_PERSON_SEARCH to everything_in_tips;
GRANT SELECT ON MV001_HRSR_PERSON_SEARCH TO hsrgp1;
