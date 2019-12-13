--SELECT * FROM TH204_XREF_STAFFING_VALIDATION order by assignment_type_cd, hrsr_work_hours_cd;

-- Acting Validation:
INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd,extension_cd)
  VALUES ('26', 'A1','M', 'AS', NULL);

INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd,extension_cd)
  VALUES ('26', 'A1','A', 'FT', NULL); 
  
INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd,extension_cd)
  VALUES ('26', 'A1','B', 'PT', NULL); 
  

-- Casual Validation:
INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd,extension_cd)
  VALUES ('27', 'X1','M', 'AS', NULL); 
  
INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd,extension_cd)
  VALUES ('27', 'X1','K', 'FT', 'C');   
  
INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd,extension_cd)
  VALUES ('27', 'X1','P', 'FT', 'X');   
  
INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd,extension_cd)
  VALUES ('27', 'X1','L', 'PT', 'C');    
  
INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd,extension_cd)
  VALUES ('27', 'X1','R', 'PT', 'X');     
 

-- Student Validation:
INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd, extension_cd)
  VALUES ('28', 'J1','W', NULL, NULL); 
  
INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd, extension_cd)
  VALUES ('28', 'J2','V', NULL ,NULL);  
  
INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd, extension_cd)
  VALUES ('28', 'J5','Y', NULL, NULL);  
  
-- As / When  
INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd, extension_cd)
  VALUES ('28', 'J1','M', 'AS', NULL); 
  
INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd, extension_cd)
  VALUES ('28', 'J2','M', 'AS' ,NULL); 
  
INSERT INTO TH204_XREF_STAFFING_VALIDATION (hrsr_action_cd,assignment_type_cd, employment_type_cd, hrsr_work_hours_cd, extension_cd)
  VALUES ('28', 'J5','M', 'AS', NULL);   
  
COMMIT;
 


