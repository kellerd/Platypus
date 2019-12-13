-- DELETE FROM TH190_XREF_TH048_TH189 WHERE act_action_cd IN ('26','27','28');
-- DELETE FROM TH056_XREF_TH048_FUA WHERE xaf_action_cd IN ('26','27','28');
-- DELETE FROM TH057_XREF_TH048_TH053 WHERE xex_action_cd IN ('26','27','28');
-- DELETE FROM TH048_HRSR_ACTION WHERE ACT_ACTION_CD IN ('26','27','28');

INSERT INTO TH048_HRSR_ACTION (ACT_ACTION_CD,ACT_HRSR_TYPE_CD,ACT_HRSR_ACTION_ENM,ACT_HRSR_ACTION_FNM,ACT_ACTION_DESCRIPTION_ETXT,ACT_ACTION_DESCRIPTION_FTXT,ACT_ACTION_EXPLANATION_ETXT,ACT_ACTION_EXPLANATION_FTXT,ACT_DATE_START_DTE,ACT_DATE_END_DTE,ACT_DISPLAY_ORDER_SEQ_NUM)
VALUES('26','STF','Acting less than 4 months', 'Intérimaire moins de 4 mois',
'An acting appointment is the temporary assignment of an employee to the duties of a higher position (i.e. where the difference in the maximum rates of pay constitutes a promotion).  This action type will be used for all actions related to acting appointments less than 4 months in length.  This includes new acting and extensions to existing acting.',
'La nomination intérimaire est la nomination temporaire d’un employé à un poste supérieur (pour lequel l’augmentation du taux maximal de rémunération représente une promotion). Ce type de mesure est utilisé pour toutes les mesures de nomination intérimaire, y compris la nomination de nouveaux employés et la prolongation de la durée d’affectation.',
'Please refer to the Express Lane Staffing Manager''s Guide located on myTC (RDIMS 14157018).  There is no right of recourse for acting appointment of less than four months.  When the acting period is four months or more or when an acting appointment is extended beyond four months, the right of recourse must be issued.  The TIPS action type will depend on what type of acting action is being requested.  If the acting period (cumulative, including any extensions) is greater than, or equal to four months, then a B/F will be created in the TIPS Staffing application.  If the Acting period (cumulative, including extensions) is not more than four months, then the request will be handled through the TIPS Temporary Assignments application.',
'Veuillez-vous reporter au Guide du gestionnaire de la Dotation accélérée situé sur monTC (SGDDI 14470041).  Aucun droit de recours n’est accordé pour une nomination intérimaire inférieure à quatre mois.  Par contre, l’employé intérimaire nommé pour une période minimale de quatre mois ou dont la durée d’affectation est prolongée au-delà de quatre mois doit avoir un droit de recours.  Le type de mesure créé dans le SIPT dépend de la mesure de nomination demandée. Si la période de nomination (incluant les prolongations) est égale ou supérieure à quatre mois, un rappel sera créé dans le module de Dotation du SIPT.  Si la période de nomination (incluant les prolongations) est inférieure à quatre mois, la demande sera traitée dans le module des Affectations Temporaires du SIPT.',
TRUNC(SYSDATE),NULL,0);

INSERT INTO TH048_HRSR_ACTION (ACT_ACTION_CD,ACT_HRSR_TYPE_CD,ACT_HRSR_ACTION_ENM,ACT_HRSR_ACTION_FNM,ACT_ACTION_DESCRIPTION_ETXT,ACT_ACTION_DESCRIPTION_FTXT,ACT_ACTION_EXPLANATION_ETXT,ACT_ACTION_EXPLANATION_FTXT,ACT_DATE_START_DTE,ACT_DATE_END_DTE,ACT_DISPLAY_ORDER_SEQ_NUM)
VALUES('27','STF','Casual','Employé Occasionnel',
'Casual employment offers flexibility to meet unforeseen needs, to meet emergencies, to replace employees for short period of absences, such as vacation leave, sick leave, training, etc., or to conduct short-term projects where funding is unpredictable.  It is not subject to the provisions of the PSEA, and therefore establishing merit is not required.  Casual workers are not employees and are not eligible to be considered for appointment in an internal (to the federal government) appointment process.  They may not be employed for more than 90 working days in one calendar year in any particular department or organization.',
'L’embauche d’employés temporaires permet de répondre aux besoins imprévus et urgents, de remplacer les employés qui s’absentent pendant de courtes périodes (vacances, congés de maladie, formation, etc.) ou d’entreprendre des projets à court terme au financement imprévisible. L’emploi temporaire n’étant pas assujetti à la LEFP, il n’est pas nécessaire d’établir le mérite des candidats. Les employés temporaires ne peuvent pas être nommés par voie d’un processus interne (au gouvernement fédéral). Ils ne peuvent être embauchés dans un ministère ou un organisme pour plus de 90 jours ouvrables dans une année civile.',
'Please refer to the Express Lane Staffing Manager''s Guide located on myTC (RDIMS 14157018).  CASUAL: Attaching some or all documents, identified below, to your HRSR request will expedite processing your request.· Statement of duties or Statement of Merit Criteria· Rationale for Choice of appointment process· HR Plan - Attach relevant section(s)· Explanation of right fit for selected person',
'Veuillez-vous reporter au Guide du gestionnaire de la Dotation accélérée situé sur monTC (SGDDI 14470041). TRAVAILLEUR OCCASIONNEL :Si vous soumettez plusieurs ou tous les documents identifiés ci-dessous avec votre demande de service, votre demande sera traitée plus rapidement.· Énoncé des fonctions ou Énoncé de critères de mérite· Justification du Choix du processus de nomination· Plan des RH - Soumettre section(s) pertinente(s)· Explication du choix de la bonne personne',
TRUNC(SYSDATE),NULL,0);


INSERT INTO TH048_HRSR_ACTION (ACT_ACTION_CD,ACT_HRSR_TYPE_CD,ACT_HRSR_ACTION_ENM,ACT_HRSR_ACTION_FNM,ACT_ACTION_DESCRIPTION_ETXT,ACT_ACTION_DESCRIPTION_FTXT,ACT_ACTION_EXPLANATION_ETXT,ACT_ACTION_EXPLANATION_FTXT,ACT_DATE_START_DTE,ACT_DATE_END_DTE,ACT_DISPLAY_ORDER_SEQ_NUM)
VALUES('28','STF','Student', 'Étudiant',
'In partnership with participating academic institutions, the Federal Public Service of Canada plays an important role in providing secondary and post-secondary students with relevant and practical work experience and career opportunities.  The types of programs are as follows:  FSWEP, COOP/Internship, Non-Paid Secondary Student and International Exchange',
'De concert avec les maisons d’enseignement, la fonction publique du Canada joue un rôle de premier plan en permettant aux étudiants de niveau secondaire et postsecondaire d’acquérir une expérience de travail pratique et pertinente pour élargir leurs perspectives de carrière.  Les types de programmes sont comme suit:  PFETE, COOP/Internat, Secondaires non rémunérés, et Échange international',
'Please refer to the Express Lane Staffing Manager''s Guide located on myTC (RDIMS 14157018).  Attaching some or all documents, identified below, to your HRSR request will expedite processing your request.· Statement of duties· Rationale for Choice of appointment process· HR Plan - Attach relevant section(s)',
'Veuillez-vous reporter au Guide du gestionnaire de la Dotation accélérée situé sur monTC (SGDDI 14470041). Si vous soumettez plusieurs ou tous les documents identifiés ci-dessous avec votre demande de service, votre demande sera traitée plus rapidement.· Énoncé des fonctions· Justification du Choix du processus de nomination· Plan des RH - Soumettre section(s) pertinente(s)',
TRUNC(SYSDATE),NULL,0);

COMMIT;

--SELECT * FROM TH057_XREF_TH048_TH053 WHERE xex_action_cd IN ('26','27')
-- Delete from TH057_XREF_TH048_TH053 where xex_action_cd IN ('26','27')  ;

-- Acting less than 4 months
INSERT INTO TH057_XREF_TH048_TH053
     VALUES ('26', 'E');
     
INSERT INTO TH057_XREF_TH048_TH053
     VALUES ('26', 'N');     

-- Casual (New or Extension)
-- Note: Part Time Worker (type 13) stays with HRSR version 1.0
--       Casual breaks off onto HRSR 2.0
INSERT INTO TH057_XREF_TH048_TH053
     VALUES ('27', 'C');     

INSERT INTO TH057_XREF_TH048_TH053
     VALUES ('27', 'X');
     
-- Student / TA
INSERT INTO TH057_XREF_TH048_TH053
     VALUES ('28', 'N');
     
INSERT INTO TH057_XREF_TH048_TH053
     VALUES ('28', 'E');     

-- Acting < 4 mths:
INSERT INTO TH056_XREF_TH048_FUA
     VALUES ('26','TA','T03','N');

INSERT INTO TH056_XREF_TH048_FUA
     VALUES ('26','TA','T04','E');
     
-- Casual:  
INSERT INTO TH056_XREF_TH048_FUA
     VALUES ('27','TA','T01','C');  
     
INSERT INTO TH056_XREF_TH048_FUA
     VALUES ('27','TA','T02','X');   

-- Student:
INSERT INTO TH056_XREF_TH048_FUA
     VALUES ('28','TA','T12','N');

INSERT INTO TH056_XREF_TH048_FUA
     VALUES ('28','TA','T13','E');

-- Associate new Action Code with Acting Employment Types:
INSERT INTO TH190_XREF_TH048_TH189 (act_action_cd, employment_type_cd) 
     SELECT '26', 
            eap_employment_type_code 
       FROM employment_assignment_pairs 
      WHERE eap_assignment_type_code = 'A1'
        AND eap_employment_type_code != 'I'; 
            -- Exclude PT Worker
      
-- Associate new Action Code with CASUAL Employment Types:    
INSERT INTO TH190_XREF_TH048_TH189 (act_action_cd, employment_type_cd) 
     SELECT '27', 
            eap_employment_type_code 
       FROM employment_assignment_pairs 
      WHERE eap_assignment_type_code = 'X1'
        AND eap_employment_type_code != 'I'; 
            -- Exclude PT Worker
        
-- Associate new Action Code with STUDENT Employment Types:    
INSERT INTO TH190_XREF_TH048_TH189 (act_action_cd, employment_type_cd) 
     SELECT DISTINCT '28', 
            eap_employment_type_code 
       FROM employment_assignment_pairs 
      WHERE eap_assignment_type_code LIKE 'J%'
        AND eap_employment_type_code IN ('V','W','Y');   
        
INSERT INTO TH053_EXTENSION_CD (ext_extension_cd, ext_extension_name_enm, ext_extension_name_fnm)
  VALUES ('W', 'Rehire (within TC)', 'Réembauche (de TC)');
  
INSERT INTO TH053_EXTENSION_CD (ext_extension_cd, ext_extension_name_enm, ext_extension_name_fnm)
  VALUES ('O', 'Rehire (Other Federal Organizations)', 'Réembauche (autre organisation fédérale)');  
  
INSERT INTO TH057_XREF_TH048_TH053 VALUES ('28','W');
INSERT INTO TH057_XREF_TH048_TH053 VALUES ('28','O');
  
COMMIT;
      

