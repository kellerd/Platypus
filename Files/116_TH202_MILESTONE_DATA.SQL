--SELECT * FROM TH202_MILESTONE;
--SELECT * FROM TH203_XREF_TH048_TH202;
--SELECT * FROM TH052_HRSR_ACTOR;

-- Status Changes:

INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('NEW', 'HRSR Created', 'DSRH créée');
  
INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('APP', 'HRSR Approved', 'DSRH approvée');    
-- Status Change 4 Submitted to TIPS
  
INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('WTD', 'HRSR Withdrawn', 'DSRH désistée');  
-- Status Change 5 Withdrawn

INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('COM', 'HRSR Completed', 'DSRH complétée');  
-- Status Change 6 Complete 

INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('CNC', 'HRSR Cancelled', 'DSRH annulée');  
-- Status Change 8 Cancelled 


-- Assigned to ACTOR (TH052_HRSR_ACTOR):

INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('INT', 'Assigned to Initiator', 'Assigné à l''initiateur');  
  
INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('REC', 'Assigned to Recommender', 'Assigné au recommandataire');  
  
INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('APR', 'Assigned to Approver', 'Assigné à l''approbateur');  
  
INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('HR', 'Assigned to HR', 'Assigné aux RH');  

-- Reassigned to ACTOR (TH052_HRSR_ACTOR):

INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('RIN', 'Reassigned to Initiator', 'Réassigné à l''initiateur');  
    
INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('RRC', 'Reassigned to Recommender', 'Réassigné au recommandataire'); 
  
INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('RAP', 'Reassigned to Approver', 'Réassigné à l''approbateur');   
  
INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('HRT', 'Assigned to HR Triage', 'Assigné au triage RH');  
  
INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('HRP', 'Assigned to HR PRI Triage', 'Assigné au triage du CIDP des RH');      

INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('HRA', 'Assigned to HR Advisor', 'Assigné au conseiller en RH');   
  
-- Misc:
INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('LOG', 'Letter of Offer Generated', 'Lettre d''offre générée');   

INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('LOU', 'Signed Letter of Offer Uploaded', 'Lettre d''offre signée téléchargée'); 

INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('PRI', 'PRI assigned to candidate', 'CIDP assigné au candidat');  
  
INSERT INTO TH202_MILESTONE (milestone_cd, milestone_enm, milestone_fnm)
  VALUES ('PHC', 'Post Hire Complete', 'Post-embauche complété');      

COMMIT;

INSERT INTO TH203_XREF_TH048_TH202
           (act_action_cd, milestone_cd)
    SELECT act_action_cd, milestone_cd
      FROM th048_hrsr_action,
           th202_milestone
     WHERE act_action_cd IN ('26','27', '28') ; 
     
COMMIT;
     
 
