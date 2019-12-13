--SELECT * FROM TH192_CONDITION_CATEGORY;
--SELECT * FROM TH193_CONDITION_OF_EMPLOYMENT;

INSERT INTO TH192_CONDITION_CATEGORY (condition_category_cd,condition_category_enm,condition_category_fnm)
  VALUES ('OT','Overtime','Heures supplémentaires'); 
INSERT INTO TH192_CONDITION_CATEGORY (condition_category_cd,condition_category_enm,condition_category_fnm)
  VALUES ('DL','Driver License','Permis de conduire');   
INSERT INTO TH192_CONDITION_CATEGORY (condition_category_cd,condition_category_enm,condition_category_fnm)
  VALUES ('TR','Travel','Voyages');  
INSERT INTO TH192_CONDITION_CATEGORY (condition_category_cd,condition_category_enm,condition_category_fnm)
  VALUES ('MD','Medical (General)','Examen médical (général)');   
INSERT INTO TH192_CONDITION_CATEGORY (condition_category_cd,condition_category_enm,condition_category_fnm)
  VALUES ('O','Other','Autres');    
INSERT INTO TH192_CONDITION_CATEGORY (condition_category_cd,condition_category_enm,condition_category_fnm)
  VALUES ('C','Custom','Custom');         
  
COMMIT;

INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'OT', 'Work overtime, occasionally on short notice', 'Work overtime, occasionally on short notice',
   'Willingness and ability to work overtime, occasionally on short notice',
   'Consentir à faire des heures supplémentaires à l’occasion et à court préavis, et être en mesure de le faire');
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'OT', 'Work overtime with minimum or no advance notice',' Work overtime with minimum or no advance notice',
   'Willingness and ability to work overtime with minimum or no advance notice.',
   'Consentir à faire des heures supplémentaires à court préavis, voire sans préavis, et être en mesure de le faire.');
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'OT', 'Work overtime and irregular hours as assigned','Work overtime and irregular hours as assigned',
   'Required to work overtime and irregular hours as assigned - including on short notice',
   'Tenu de faire des heures supplémentaires et des heures irrégulières selon ce qu’on lui confie, notamment moyennant un court préavis.');   
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'OT', 'Work overtime, including nights and weekends; and, including stand-by',
                  'Work overtime, including nights and weekends; and, including stand-by', 
   'Willingness and ability to work overtime, including nights and weekends; and, including stand-by.',
   'Accepter et être en mesure de faire des heures supplémentaires, y compris durant la nuit et les fins de semaine, et d’être en disponibilité.');
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'OT', 'Perform overtime on short notice during an incident/crisis',
   'Perform overtime on short notice during an incident/crisis',
   'During an incident/crisis response, you may be required to perform overtime on short notice.',
   'Au cours d’une intervention en cas d’incident ou de crise, il se peut que vous deviez faire des heures supplémentaires à court préavis.');
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'OT', 'Work shift work as part of a 24/7 operation Centre',
                  'Work shift work as part of a 24/7 operation Centre',
   'All employees are required to work shift work as part of a 24/7 operation Centre (24 hours per day, 7 days per week, open all year).',
   'Tous les employés sont tenus de travailler par quarts dans le cadre d’un centre d’opérations (24 heures sur 24, 7 jours sur 7, ouvert en tout temps).');   
   
 
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'DL', 'Valid Canadian Provincial or Territorial Driver''s License',
   'Valid Canadian Provincial or Territorial Driver''s License',
   'Possession of a valid Canadian Provincial or Territorial Driver''s License or mobility normally associated with a driver''s license.' ,
   'Posséder un permis de conduire valide délivré par une province ou un territoire, ou être en mesure de se déplacer au même titre qu’une personne qui en possède un.');
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'DL', 'Valid Canadian driver’s license',
                  'Valid Canadian driver’s license',
   'Possession of a valid Canadian driver’s license.',
   'Détenir un permis de conduire valide au Canada.'); 


INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'TR', 'Willingness and ability to travel',
                  'Willingness and ability to travel',
   'Willingness and ability to travel by various means and modes.',     
   'Consentir à voyager par divers moyens de transport et être en mesure de le faire.');  
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'TR', 'Willingness to travel occasionally.',
   'Volonté de voyager à l’occasion.',
   'Willingness to travel occasionally.',
   'Volonté de voyager à l’occasion.'); 
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'TR', 'Travel frequently',
   'Travel frequently',
   'Must be willing and able to travel frequently.',
   'Être disponible et consentir à voyager fréquemment.');
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'TR', 'Travel for extended periods of time', 'Travel for extended periods of time',
   'Willingness and ability to travel for extended periods of time, using all modes of transportation, throughout the region and – on occasion – outside the region.',       
   'Accepter et être en mesure de voyager pendant de longues périodes, en utilisant tous les modes de transport, dans toute la région - à l''occasion - en dehors de la région.');
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'TR', 'Possession of a valid Canadian Passport.', 
   'Être titulaire d’un passeport Canadien valide.',
   'Possession of a valid Canadian Passport.',
   'Être titulaire d’un passeport Canadien valide.'); 
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'TR', 'Travel within and outside Canada',
   'Travel within and outside Canada',
   'Willing and able to travel within and outside Canada.',
   'Être disposé et en mesure de voyager à l''intérieur et à l''extérieur du Canada.');
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'TR', 'Travel for extended periods up to 4 weeks',
   'Travel for extended periods up to 4 weeks',
   'Willing and capable to travel for extended periods up to 4 weeks at a time.',      
   'Être disposé et en mesure de voyager sur de longues périodes pouvant aller jusqu’à 4 semaines.');
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'TR', 'Travel at short notice for extended periods',
   'Travel at short notice for extended periods',
   'Willingness and ability to travel at short notice for extended periods within Canada using all modes of transportation.',
   'Volonté et capacité de se déplacer à court préavis et pendant des périodes prolongées pour des déplacements à l''intérieur du Canada en utilisant tous les modes de transport.');


INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'MD', 'Pre-employment medical examination', 
   'l’examen médical de pré-embauche',
   'Satisfactory completion of a pre-employment medical examination.',
   'Avoir réussi l’examen médical de pré-embauche.'); 


INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'O', 'Work in inclement weather conditions',
   'Work in inclement weather conditions',
   'Willingness and ability to work in inclement weather conditions.',
   'Accepter et être en mesure de travailler dans des conditions météorologiques défavorables.');
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'O', 'Work in immediate proximity to dangerous goods',
   'Work in immediate proximity to dangerous goods',
   'Willingness and ability to work in noisy, dusty and dirty conditions in immediate proximity to dangerous goods.',
   'Accepter et être en mesure de travailler dans un milieu bruyant, poussiéreux et sale à proximité immédiate de marchandises');      
INSERT INTO TH193_CONDITION_OF_EMPLOYMENT (condition_category_cd, condition_of_employment_enm, condition_of_employment_fnm, condition_of_employment_etxt, condition_of_employment_ftxt)
   VALUES ( 'O', 'Work alone in isolated areas',
   'Work alone in isolated areas',
   'Willingness and ability to work alone in isolated areas.',
   'Accepter et être en mesure de travailler seul dans des endroits isolés.');  
   
COMMIT;
       
    
