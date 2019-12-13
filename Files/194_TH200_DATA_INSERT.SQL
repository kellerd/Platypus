
INSERT INTO TH200_HRSR_FORM (hrsr_form_enm, hrsr_form_fnm, hrsr_form_etxt, hrsr_form_ftxt,
 hrsr_english_form_num, hrsr_french_form_num,
 hrsr_form_location_etxt,hrsr_form_location_ftxt  )
  VALUES ('Oath / Solemn Affirmation','Serment / Affirmation solennelle',
   'The Oath or Solemn Affirmation is a condition of employment that applies on initial appointment/deployment to the Public Service.',
   'Le serment ou l’affirmation solennelle est une condition d’emploi qui s’applique lors de la nomination/l’affectation initiale au sein de la fonction publique.',
   '10-0559 (0710-02)', '10-0559 (0710-02)', 
   'http://tcapps/Corp-Serv-Gen/5/forms-formulaires/download/10-0559_BI_PX',
   'http://tcapps/Corp-Serv-Gen/5/forms-formulaires/download/10-0559_BI_PX');
   
INSERT INTO TH200_HRSR_FORM (hrsr_form_enm, hrsr_form_fnm, hrsr_form_etxt, hrsr_form_ftxt,
 hrsr_english_form_num, hrsr_french_form_num,
 hrsr_form_location_etxt,hrsr_form_location_ftxt  )
  VALUES ('Student Eligibility Form','Formulaire d’admissibilité pour étudiant(e)',
   'Student Eligibility Form to confirm the candidate is a current student, and will be either returning to school or graduating at the end of the program',
   'Student Eligibility Form to confirm the candidate is a current student, and will be either returning to school or graduating at the end of the program',
   'RDIMS 6516782', 'SGDDI 6516782', 
   'pcdocs://RDIMS/6516782/R',
   'pcdocs://RDIMS/6516782/R');   
   
   
INSERT INTO TH201_XREF_TH048_TH200_FORM (action_cd, hrsr_form_id, applicable_ind)
  SELECT '28', hrsr_form_id, 0 
    FROM TH200_HRSR_FORM
   WHERE hrsr_form_enm = 'Oath / Solemn Affirmation';
   
INSERT INTO TH201_XREF_TH048_TH200_FORM (action_cd, hrsr_form_id, applicable_ind)
  SELECT '28', hrsr_form_id, 0
    FROM TH200_HRSR_FORM
   WHERE hrsr_form_enm = 'Student Eligibility Form';   

COMMIT;



