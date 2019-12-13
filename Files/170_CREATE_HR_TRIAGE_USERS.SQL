--SELECT * FROM persons WHERE per_pin LIKE '%00000002%' ORDER BY per_pin;
--SELECT * FROM services;


-- HR Triage Generic User:
INSERT INTO users (usr_user_id, usr_password_change_date, usr_person_type_code, usr_pin, usr_region_ind, usr_client_service_group_ind)
   VALUES ('HRSR_TRIAGE', SYSDATE,1,'000000023','A','OTT');

INSERT INTO user_services (uss_service_type_ind, uss_service_group_ind,uss_service_ind, uss_region_ind, uss_user_id,uss_access_type, uss_start_date, uss_role_id)
       VALUES ('100','100','HSRGP1','A','HRSR_TRIAGE','1',TRUNC(SYSDATE),'116');

INSERT INTO persons (per_pin, per_type_code, per_region_ind, per_preferred_lang_code, per_family_name, per_given_name)
       VALUES ('000000023',1,'A',1,'HR Triage','Triage RH');
       
       
-- HR Triage PRI Generic User:
INSERT INTO users (usr_user_id, usr_password_change_date, usr_person_type_code, usr_pin, usr_region_ind, usr_client_service_group_ind)
   VALUES ('HRSR_PRI_TRIAGE', SYSDATE,1,'000000024','A','OTT');

INSERT INTO user_services (uss_service_type_ind, uss_service_group_ind,uss_service_ind, uss_region_ind, uss_user_id,uss_access_type, uss_start_date, uss_role_id)
       VALUES ('100','100','HSRGP1','A','HRSR_PRI_TRIAGE','1',TRUNC(SYSDATE),'116');

INSERT INTO persons (per_pin, per_type_code, per_region_ind, per_preferred_lang_code, per_family_name, per_given_name)
       VALUES ('000000024',1,'A',1,'HR PRI Triage','Triage RH (CIDP)');

COMMIT;

