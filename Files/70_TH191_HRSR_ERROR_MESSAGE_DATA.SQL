--SELECT * FROM TH191_HRSR_ERROR_MESSAGE;

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('0', 'Success', 'Succès');
    
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('999', 'Unknown Error', 'Inconnu Erreur');  
    
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('1', 'Error: This type of HRSR action must be created using HRSR 1.0.', 'Erreur : Ce type de mesure DSRH doit être créé dans DSRH 1.0.');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('2', 'This HRSR request is missing data: Candidate PRI.', 'Cette demande DSRH manque de données : CIDP du candidat.');
   
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('3', 'This HRSR request is missing data: Start date.', 'Cette demande DSRH manque de données : Date de début.');  
  
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('4', 'This HRSR request is missing data: End date.', 'Cette demande DSRH manque de données : Date de fin.');
 
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('5', 'This HRSR request is missing data: Position Number.', 'Cette demande DSRH manque de données : Numéro de poste.');
 
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('6', 'The position number chosen does not exist or may be archived.', 'Le numéro de poste choisi n''existe pas ou peut être archivé.');
  
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('7', 'This HRSR request is missing data: Employment Type Code.', 'Cette demande DSRH manque de données : Code du type d''emploi.');
  
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('8', 'This HRSR request is missing data: Assignment Type Code.', 'Cette demande DSRH manque de données : Code du type d''affectation.');
    
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('9', 'This HRSR request is missing data: Extension Code (New or Extension).', 'Cette demande DSRH manque de données : Code de prolongation (Nouveau ou Prolongation).');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('10', 'An assignment already exists for these HRSR details.', 'Une affectation existe déjà pour les détails de cette DSRH.');
   
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('11', 'There is an overlapping acting assignment for another employee for the same position number', 'Il y a un chevauchement d''une affectation intérimaire d''un autre employé pour le même numéro de poste.');
       
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('12', 'Acting assignment must be longer than minimum period for the collective agreement (<v_sub_group_ind> group = <v_min_days_acting> days).', 
                'L''affectation intérimaire doit être plus longue que la période minimale pour la convention collective (Groupe <v_sub_group_ind> = <v_min_days_acting> jours).');
 
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('13', 'The start date of the acting assignment being entered, <v_acting_start_dte>, cannot be before the employee''s assignment start date <v_incumbent_start_dte>.', 
                'La date de début de l''affectation intérimaire en cours d''entré, <v_acting_start_dte>, ne peut être avant la date de début de l''affectation de l''employé <v_incumbent_start_dte>.');
      
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('14', 'The end date of the acting assignment being entered, <v_acting_end_dte>, cannot be after the employee''s assignment end date <v_incumbent_end_dte>.', 
                'La date de fin de l''affectation intérimaire en cours d''entré, <v_acting_end_dte>, ne peut être après la date de fin de l''affectation de l''employé <v_incumbent_end_dte>.');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('15', 'The acting classification (<v_acting_classn>) and the substantive classification (<v_substantive_classn>) do not meet the definition of acting / promotion. Definition: <v_promotion_txt>.', 
                'La classification de l''intérimaire (<v_acting_classn>) et la classification titulaire (<v_substantive_classn>) ne rencontre pas la définition d''intérimaire / promotion.  Définition : <v_promotion_txt>');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('16', 'Acting assignments can only be processed for active employees. Please modify the start and/or end dates of the acting assignment.', 
                'Les affectations intérimaires ne peuvent être traitées que pour les employés actifs.  Veuillez modifier les dates de début et/ou de fin de l’affectation intérimaire.');
 
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('17', 'The "Pay As" / Underfill level cannot be the same as the acting level.', 
                'Le niveau de "Payé comme" / Niveau inférieur ne peut être pareille au niveau de l''intérimaire.');
 
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('18', 'The "Pay As" / Underfill level is not less than the acting level.', 
                'Le niveau de "Payé comme" / Niveau inférieur n''est pas moins que le niveau de l''intérimaire.');
 
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('19', 'The acting classification (<v_acting_classn>) and pay as / underfill level (<v_underfill_classn>) does not meet the definition of a promotion. Definition: <v_promotion_txt>.', 
                'La classification de l''intérimaire (<v_acting_classn>) et le niveau de payé comme / niveau inférieur (<v_underfill_classn>) ne rencontre pas la définition d''une promotion.  Définition : <v_promotion_txt>.');
                
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('20', 'The pay as / underfill level (<v_underfill_classn>) and substantive classification (<v_substantive_classn>) does not meet the definition of promotion. Definition: <v_promotion_txt>.', 
                'Le niveau de payé comme / niveau inférieur (<v_underfill_classn>)  et la classification titulaire (<v_substantive_classn>) ne rencontre pas la définition d''une promotion.  Définition : <v_promotion_txt>');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('21', 'There is an overlapping assignment that has an assignment type that cannot be combined with this assignment type.', 
                'Il y a un chevauchement d''une affectation qui a un type d''affectation qui ne peut pas être combiné avec ce type d''affectation.');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('22', 'Casual assignments are not allowed for this position''s classification.', 
                'Les affectations occasionnelles ne sont pas autosrisé pour la classification de ce poste.');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('23', 'The candidate PRI number <v_candidate_pin> does not exist as an employee. Please contact the HR Systems Help Desk.', 
                'Le numéro CIDP du candidat <v_candidate_pin> n''existe pas comme employé.  Veuillez communiquer avec le bureau d''aide des Systèmes RH.');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('24', 'Parent Position is missing.', 
                'Le numéro du parent est manquant.');
                
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('25', 'Classification for the phantom position is missing or incomplete.', 
                'La classification du poste fantôme est manquante ou incomplète.');                
                
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('26', 'Start date of the assignment falls on a weekend.', 
                'La date de début de l''affectation tombe pendant une fin de semaine.');
                
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('27', 'End date of the assignment falls on a weekend.', 
                'La date de fin de l''affectation tombe pendant une fin de semaine.');                

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('28', 'Start date of the assignment falls on a statutory holiday.', 
                'La date de début de l''affectation tombe sur un congé statutaire.');
                
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('29', 'End date of the assignment falls on a statutory holiday.', 
                'La date de fin de l''affectation tombe pendant un congé statutaire.'); 
                
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('30', 'This position is flagged, but you may continue with the process.', 
                'Ce poste a un indicateur, mais vous pouvez continuer avec le processus.');    
                
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('31', 'This position is flagged. Please send an email to TC.Classification.TC@tc.gc.ca to request a temporary suspension. You will not be able to complete this action unless the flag is suspended.', 
                'Ce poste a un indicateur. Veuillez envoyer un courriel à TC.Classification.TC@tc.gc.ca pour demander une suspension temporaire. Vous ne serez pas en mesure de terminer cette action à moins que l''indicateur sois suspendu.');                             
                
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('32', 'The candidate''s substantive assignment is a secondment. It is the host department manager''s responsibility to advise the employee''s home department manager to ensure that the employee is paid accordingly.', 
                'Le poste titulaire du candidat est un détachement. C''est la responsabilité du gestionnaire de l''organisation d''accueil d''nformer le gestionnaire de l''organisation d''attache, afin d''assurer que l''employé sera payé en conséquence.');
                
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('33', 'The selected candidate is in a group that is not allowed to act. Please contact your HR advisor.', 
                'Le candidat choisi fait partie d''un groupe qui n''est pas permis de faire de l''intérime.  Veuillez communiquer avec votre Conseiller en RH.');  
               
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('34', 'The selected candidate does not have a security profile. Please update the request with the security information.', 
                'Le candidat choisi n''a aucun profil de sécurité.  Veuillez mettre à jour la demande avec les renseignements sur la sécurité.');  

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('35', 'The selected candidate does not meet the security profile of the position.', 
                'Le candidat choisi ne rencontre pas le profil de sécurité du poste.'); 
                
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('36', 'The selected candidate does not have language testing results, but the position has a language profile. By completing this acting less than 4 months, the sub delegated manager certifies that proof has been provided that the candidate meets the language requirements of the position, or that no other candidate who meet the language requirements could be found for this acting. The cumulative period of the acting appointments of all persons who do not meet the language requirements of a position cannot exceed 4 months if the position is vacant, cannot exceed 12 months if the position is encumbered and cannot exceed 18 months if the incumbent is on language training. ', 
                'Le candidat choisi n''a aucun résultats d''évaluation des connaissances linguistiques mais le poste a un profil linguistique.  En complétant cet intérimaire de moins de quatre mois, le gestionnaire subdélégué atteste que la preuve a été fournie que le candidat répond aux exigences linguistiques du poste, ou qu''aucun autre candidat satisfaisant aux exigences linguistiques n''a pu être trouvé pour cet intérimaire. La durée cumulative des nominations intérimaires de toutes les personnes qui ne satisfont pas aux exigences linguistiques d''un poste ne peut excéder 4 mois si le poste est vacant, 12 mois si le poste est occupé et 18 mois si le titulaire est en formation linguistique.');  

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('37', 'The selected candidate does not meet the language requirements of the position. By completing this acting less than 4 months, the sub-delegated manager certifies that no other candidate who meet the language requirements could be found for this acting. The cumulative period of the acting appointments of all persons who do not meet the language requirements of a position cannot exceed 4 months if the position is vacant, cannot exceed 12 months if the position is encumbered and cannot exceed 18 months if the incumbent is on language training.', 
                'Le candidat choisi ne satisfait pas aux exigences linguistiques du poste. En complétant cet intérimaire de moins de quatre mois, le gestionnaire subdélégué atteste qu''aucun autre candidat satisfaisant aux exigences linguistiques n''a pu être trouvé pour cet intérimaire. La durée cumulative des nominations intérimaires de toutes les personnes qui ne satisfont pas aux exigences linguistiques d''un poste ne peut excéder 4 mois si le poste est vacant, 12 mois si le poste est occupé et 18 mois si le titulaire est en formation linguistique.');  
                
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('38', 'The acting position number selected is the same as the candidate''s substantive position.', 
                'Le numéro de poste choisi pour l''intérimaire est le même que que le poste titulaire du candidat.');                                  
   
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('39', 'The acting assignment extension, plus the original assignment now exceeds 4 months in length. Please shorten the extension length or change the HRSR action type.', 
                'La prolongation de l''affectation intérimaire, plus l''affectation initiale dépasse maintenant 4 mois de durée.  Veuillez raccourcir la longueur de la prolongation ou changer le type de mesure de la DSRH.');  
                
-- Student Errors:

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('40', 'This request is missing data: Hours of Work.', 
                'Cette demande manque de données :  Heures de travail.');
    
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('41', 'This request is missing data: Salary.', 
                'Cette demande manque de données :  Salaire.');
  
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('42', 'This request is missing data: Student Type.', 
                'Cette demande manque de données :  Type d''étudiant.');
                  
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('43', 'This request is missing data: Highest Education Level.', 
                'Cette demande manque de données :  Niveau d''étude le plus élevé.');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('44', 'The chosen salary is not a valid salary for the student type and education level selected.',
                'Le salaire choisi n''est pas un salaire valide pour le type d''étudiant et le niveau d''étude sélectionné.');
               
-- PT errors:  
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('45', 'This request has been identified as part time, but has no corresponding part time schedule.',
                'Cette demande a été identifiée comme étant à temps partiel mais n''a aucune horaire à temps partiel correspondante.');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('46', 'The hours in the part time schedule do not match the assigned work week hours chosen.', 
                'Les heures de l''horaire à temps partiel ne correspondent pas aux heures de semaine désignée de travail choisi.');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('47', 'This request is missing data: Assigned Work Week Hours.', 
                'Cette demande manque de données :  Semaine désignée de travail.');
      
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('48', 'There is an overlapping acting assignment for the candidate.',
                'Il y a un chevauchement d''affectation intérimaire pour ce candidat.');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('49', 'Email was not sent', 'Le courriel n''a pas été envoyé.');
  
-- Acting
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('50', 'The new acting assignment has a previous overlapping acting assignment at the same level', 
                'FRENCH: The new acting assignment has a previous overlapping acting assignment at the same level');  

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('51', 'The new acting assignment has a previous overlapping acting assignment with the same classification', 
                'FRENCH: The new acting assignment has a previous overlapping acting assignment with the same classification');  
             
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('52', 'This HRSR record is missing data: HRSR Request Number', 
                'Cette demande manque de données :  Numéro de la demande DSRH.');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('53', 'The new acting assignment end date must be before the end date of the position. You must change the end date of the acting assignment prior to <v_position_end_dte> or submit a Classification request in HRSR to request an extension to the position before entering a new assignment.',
                'La date de fin de la nouvelle affectation intérimaire doit être antérieur à la date de fin du poste. Vous devez modifier la date de fin de l''affectation intérimaire avant le <v_position_end_dte> ou soumettre une demande de Classification dans DSRH pour demander une prolongation du poste avant d''entrer une nouvelle affectation.');
   
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('54', 'The new assignment is completely within an existing assignment. Contact HR to resolve this situation.', 
                'La nouvelle affectation est entièrement dans une affectation existante.  Communiquez avec les RH pour résoudre cette situation.');  

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('55', 'The start date of the new assignment begins during an existing assignment. Change the start date of the new assignment to after the end date of the existing assignment or click the “End Overlapping Assignment Early” checkbox.', 
                'La date de début de la nouvelle affectation débute lors d''une affectation existante.  Modifiez la date de début de la nouvelle affectation pour après la date de fin the l''affectation existante ou clique sur la boîte à cocher "Fin de l''affectation de chevauchement anticipé".');  

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('56', 'The new assignment completely overlaps an existing assignment.  Split the new assignment into two assignments, before and after the existing assignment.', 
                'La nouvelle affectation chevauche entièrement une affecttion existante.  Divisez la nouvelle affectation en deux affectations, avant et après l''affectation existante.');  
        
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('57', 'The end of the new assignment overlaps into an existing assignment. Change the end date of the new assignment to before the start date of the existing assignment.', 
                'La fin de la nouvelle affectation chevauche dans une affectation existante.  Modifiez la date de fin de la nouvelle affectation à avant la date de début de l''affectation existante.');  

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('58', 'This request is missing data: Collective Agreement.', 
                'Cette demande manque de données :  Convention collective.');
        
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('59', 'This request is missing data: Geographic Location.', 
                'Cette demande manque de données :  Location géographique.');  

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('60', 'This request is missing data: Security Level.', 
                'Cette demande manque de données :  Niveau de sécurité.');  

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('61', 'The end date of the acting assignment being entered cannot be before the start date.', 
                'La date de fin de l''affectation intérimaire en cours d''entré ne peut être avant la date de début.');
     
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('62', 'The existing assignment cannot be ended early because the length of the existing assignment will not meet the minimum length of an acting assignment.', 
                'L''affectation courante ne peut être terminée tôt puisque la longueur de l''affectation courante ne rencontre pas la longueur minimal d''une affectation intérimaire.');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('63', 'The selected candidate is a member of the EX group at a level that is not allowed to act.  Please contact your HR Advisor regarding this situation.', 
                'Le candidat choisi est un membre du groupe EX à un niveau qui n''est pas alloué de faire de l''intérime.  Veuillez communiquer avec votre conseiller en RH concernant cette situation.');

INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('64', 'The group and level (<v_acting_classn>) of the selected position is not a valid combination with the profile (<v_ti_profile_enm>). Please modify your request or contact your HR Advisor if you have questions.',
                'Le groupe et niveau (<v_acting_classn>) du poste sélectionné n''est pas une combinaison valide avec le profil (<v_ti_profile_fnm>). Veuillez modifier votre demande ou communiquez avec votre Conseiller en RH si vous avez des questions.');
                                                                                       
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('65', 'You have selected a TI position. Please select the TI Profile (mode) in the Financial section of this request before proceeding.', 
                'Vous avez sélectionné un poste TI. Veuillez sélectionner le Profil TI (mode) dans la section des Données financières de cette demande avant de continuer.');
   
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('66', 'This action cannot be processed. The candidate has an overlapping acting assignment in another position that exceeds 4 months in length. Please contact your HR Advisor for more information.', 
                'Cette mesure ne peut être traitée.  Le candidat a une affectation intérimaire qui se chevauche dans un autre poste dépassant la durée de 4 mois. Veuillez communiquer avec votre Conseiller en RH.');  
                
INSERT INTO TH191_HRSR_ERROR_MESSAGE (hrsr_error_message_num, hrsr_error_message_etxt, hrsr_error_message_ftxt)
  VALUES ('67', 'Acting assignment must be longer than minimum period for the collective agreement (<v_sub_group_ind> group = 3 months).', 
                'L''affectation intérimaire doit être plus longue que la période minimale pour la convention collective (Groupe <v_sub_group_ind> = 3 mois).');
                
                
COMMIT;
                                                           



