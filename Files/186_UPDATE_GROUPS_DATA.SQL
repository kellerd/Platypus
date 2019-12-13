--SELECT * FROM VW_HRSR_COLLECTIVE_AGREEMENTS WHERE  classn_group_enm IS NULL 
--  ORDER BY collective_agreement_ind, classn_group_ind;

-- Inactivate groups:
UPDATE GROUPS
   SET GRP_HRSR_ACTIVE_IND = '0'
 WHERE grp_group_ind IN ('AM', 'AT', 'CA', 'GI', 'MM', 
                         'OC', 'OM', 'PL', 'ES', 'SI');

UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Air Traffic Control',
       GRP_GROUP_FNM = 'Contrôle du trafic aérien'
 WHERE grp_group_ind = 'AI'; 
 
UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Aircraft Operations',
       GRP_GROUP_FNM = 'Navigation aérienne'
 WHERE grp_group_ind = 'AO';    
 
 -- AV
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Auditing',
       GRP_GROUP_FNM = 'Vérification'
 WHERE grp_group_ind = 'AU'; 
UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Commerce',
       GRP_GROUP_FNM = 'Commerce'
 WHERE grp_group_ind = 'CO';  
UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Purchasing and Supply',
       GRP_GROUP_FNM = 'Achat et approvisionnement'
 WHERE grp_group_ind = 'PG';  
 
UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Computer Systems',
       GRP_GROUP_FNM = 'Systèmes d''ordinateurs'
 WHERE grp_group_ind = 'CS'; 
 
UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Deputy Minister',
       GRP_GROUP_FNM = 'Sous-ministre'
 WHERE grp_group_ind = 'DM'; 
 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Education',
       GRP_GROUP_FNM = 'Enseignement'
 WHERE grp_group_ind = 'ED'; 
 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Economics and Social Science Services',
       GRP_GROUP_FNM = 'Économique et services de sciences sociales'
 WHERE grp_group_ind = 'EC';  
 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Electronics',
       GRP_GROUP_FNM = 'Électronique'
 WHERE grp_group_ind = 'EL';  
 
 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Executive',
       GRP_GROUP_FNM = 'Direction'
 WHERE grp_group_ind = 'EX';  
   
 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Financial Management',
       GRP_GROUP_FNM = 'Gestion financière'
 WHERE grp_group_ind = 'FI';  
 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Law',
       GRP_GROUP_FNM = 'Droit'
 WHERE grp_group_ind = 'LC';  
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Law Practitioner',
       GRP_GROUP_FNM = 'Praticien du droit'
 WHERE grp_group_ind = 'LP'; 
 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Minister''s Exempt Staff',
       GRP_GROUP_FNM = 'Personnel exonéré des cabinets des ministres'
 WHERE grp_group_ind = 'MS';  
 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Engineering and Land Survey',
       GRP_GROUP_FNM = 'Génie et Arpentage'
 WHERE grp_group_ind = 'EN'; 
 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Order in Council',
       GRP_GROUP_FNM = 'Décret en conseil'
 WHERE grp_group_ind = 'OC';  
 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Organization and Methods - Unrepresented Group',
       GRP_GROUP_FNM = 'Services des programmes et de l''administration - Non représenté'
 WHERE grp_group_ind = 'OM';  
 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Administrative Services ',
       GRP_GROUP_FNM = 'Services administratifs'
 WHERE grp_group_ind = 'AS'; 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Clerical and Regulatory',
       GRP_GROUP_FNM = 'Commis aux écritures et aux règlements'
 WHERE grp_group_ind = 'CR'; 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Information Services',
       GRP_GROUP_FNM = 'Services d’information'
 WHERE grp_group_ind = 'IS'; 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Programme Administration',
       GRP_GROUP_FNM = 'Administration des programmes'
 WHERE grp_group_ind = 'PM'; 
 UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Secretarial, Stenographic and Typing',
       GRP_GROUP_FNM = 'Secrétariat, sténographie et dactylographie'
 WHERE grp_group_ind = 'ST';
   
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Personnel Administration - Unrepresented Group',
       GRP_GROUP_FNM = 'Gestion du personnel - Non représenté'
 WHERE grp_group_ind = 'PE';    
 
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Leadership Programs',
       GRP_GROUP_FNM = 'Programmes en leadership'
 WHERE grp_group_ind = 'PL'; 
 
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Student',
       GRP_GROUP_FNM = 'Étudiant'
 WHERE grp_group_ind = 'ZZ';
 
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Drafting and Illustration',
       GRP_GROUP_FNM = 'Dessin et illustrations'
 WHERE grp_group_ind = 'DD';
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Engineering and Scientific Support',
       GRP_GROUP_FNM = 'Soutien technologique et scientifique'
 WHERE grp_group_ind = 'EG';  
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Technical Inspection',
       GRP_GROUP_FNM = 'Inspection technique'
 WHERE grp_group_ind = 'TI'; 
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'General Technical',
       GRP_GROUP_FNM = 'Techniciens divers'
 WHERE grp_group_ind = 'GT'; 
 
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Medicine',
       GRP_GROUP_FNM = 'Médecine'
 WHERE grp_group_ind = 'MD';
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Nursing',
       GRP_GROUP_FNM = 'Sciences infirmières'
 WHERE grp_group_ind = 'NU';  
 
 
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'General Labour and Trades',
       GRP_GROUP_FNM = 'Manoeuvres et hommes de métier'
 WHERE grp_group_ind = 'GL';
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'General Services',
       GRP_GROUP_FNM = 'Services divers'
 WHERE grp_group_ind = 'GS';  
 
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Chemistry',
       GRP_GROUP_FNM = 'Chimie'
 WHERE grp_group_ind = 'CH';
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Meteorology',
       GRP_GROUP_FNM = 'Météorologie'
 WHERE grp_group_ind = 'MT';
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Physical Sciences',
       GRP_GROUP_FNM = 'Sciences physiques'
 WHERE grp_group_ind = 'PC';
  UPDATE GROUPS 
   SET GRP_GROUP_ENM = 'Scientific Regulation',
       GRP_GROUP_FNM = 'Réglementation scientifique'
 WHERE grp_group_ind = 'SG';    
 
COMMIT;
 
 
 
