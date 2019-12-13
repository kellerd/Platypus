--SELECT * FROM email_message_text WHERE emt_tips_application like '%HRSR%';
--SELECT * FROM email_settings;

DELETE FROM email_message_text WHERE emt_email_id IN ( '109', '110', '111','112','113','114','115','116','117','118','119');
DELETE FROM email_settings WHERE ese_email_id IN ( '109', '110', '111','112','113','114','115','116','117','118','119');

-- Forward to Recommender:
INSERT INTO email_message_text (emt_email_id, emt_tips_application, emt_email_description,
   emt_subject_text_e, emt_subject_text_f,
   emt_message_text_e, emt_message_text_f,
   emt_sender_email_address, emt_recipient_domain)
VALUES ('109','HRSR','HRSR 2: Forwarded to Recommender',
   'HR Service Request <hrsr_request_cd> forwarded to Recommender',
   'Demande de service en RH <hrsr_request_cd> envoyée au recommandataire',
   '<HTML>** Le texte français suit l''anglais. **<BR><BR>
HR Service Request <hrsr_request_cd> has been sent to you for review, as Recommender.<BR><BR>
Details:<BR><BR>
Action:          <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification:  <classification> <BR>
Candidate Name:  <candidate_name> <BR>
Start Date:      <v_start_date> <BR>
End Date:        <v_end_date><BR><BR>
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.<BR><BR>
***************************************************************<BR><BR>
La demande de service en RH <hrsr_request_cd> vous a été envoyée pour révision en tant que recommandataire. <BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR>
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.
</HTML>',
   '<HTML>** English text follows French. **<BR><BR>
La demande de service en RH <hrsr_request_cd> vous a été envoyée pour révision en tant que recommandataire. <BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.<BR><BR>
***************************************************************<BR><BR>
HR Service Request <hrsr_request_cd> has been sent to you for review, as Recommender.<BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.
</HTML>',
'HRsystems/systemesRH@tc.gc.ca', '<V_USER_ID>')
/


-- Forwarded to Approver:
INSERT INTO email_message_text (emt_email_id, emt_tips_application, emt_email_description,
   emt_subject_text_e, emt_subject_text_f,
   emt_message_text_e, emt_message_text_f,
   emt_sender_email_address, emt_recipient_domain)
VALUES ('110','HRSR','HRSR 2: Forward to Approver',
   'HR Service Request <hrsr_request_cd> forwarded to Approver',
   'Demande de service en RH <hrsr_request_cd> envoyée à l''approbateur',
   '<HTML>** Le texte français suit l''anglais. **<BR><BR>
HR Service Request <hrsr_request_cd> has been sent to you for review and approval, as Approver.<BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR>
Comment:         <v_comment_txt> <BR><BR>  
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.<BR><BR>
***************************************************************<BR><BR>
La demande de service en RH <hrsr_request_cd> vous a été envoyée pour révision et approbation en tant qu''approbateur. <BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.
</HTML>',
   '<HTML>** English text follows French. **<BR><BR>
La demande de service en RH <hrsr_request_cd> vous a été envoyée pour révision et approbation en tant qu''approbateur. <BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR>
Commentaire : <v_comment_txt> <BR><BR>  
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.<BR><BR>
***************************************************************<BR><BR>
HR Service Request <hrsr_request_cd> has been sent to you for review and approval, as Approver.<BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.
</HTML>',
'HRsystems/systemesRH@tc.gc.ca', '<V_USER_ID>')
/


-- Iniatator:
INSERT INTO email_message_text (emt_email_id, emt_tips_application, emt_email_description,
   emt_subject_text_e, emt_subject_text_f,
   emt_message_text_e, emt_message_text_f,
   emt_sender_email_address, emt_recipient_domain)
VALUES ('111','HRSR','HRSR 2: Returned to Initiator',
   'HR Service Request <hrsr_request_cd> returned to Initiator',
   'Demande de service en RH <hrsr_request_cd> retournée à l''initiateur',
   '<HTML>** Le texte français suit l''anglais. **<BR><BR>
HR Service Request <hrsr_request_cd> has been returned to you for review, as Initiator.<BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.<BR><BR>
***************************************************************<BR><BR>
La demande de service en RH <hrsr_request_cd> vous a été retournée pour révision en tant qu''initiateur.<BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.
</HTML>',
   '<HTML>** English text follows French. **<BR><BR>
La demande de service en RH <hrsr_request_cd> vous a été retournée pour révision en tant qu''initiateur.<BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.<BR><BR>
***************************************************************<BR><BR>
HR Service Request <hrsr_request_cd> has been returned to you for review, as Initiator.<BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.
</HTML>',
'HRsystems/systemesRH@tc.gc.ca', '<V_USER_ID>')
/


-- Returned to Recommender:
INSERT INTO email_message_text (emt_email_id, emt_tips_application, emt_email_description,
   emt_subject_text_e, emt_subject_text_f,
   emt_message_text_e, emt_message_text_f,
   emt_sender_email_address, emt_recipient_domain)
VALUES ('112','HRSR','HRSR 2: Returned to Recommender',
   'HR Service Request <hrsr_request_cd> returned to Recommender',
   'Demande de service en RH <hrsr_request_cd> retournée au recommandataire',
   '<HTML>** Le texte français suit l''anglais. **<BR><BR>
HR Service Request <hrsr_request_cd> has been returned to you for review, as Recommender. <BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR>
Comment:         <v_comment_txt> <BR><BR>  
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.<BR><BR>
***************************************************************<BR><BR>
La demande de service en RH <hrsr_request_cd> vous a été retournée pour révision en tant que recommandataire. <BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.
</HTML>',
   '<HTML>** English text follows French. **<BR><BR>
La demande de service en RH <hrsr_request_cd> vous a été retournée pour révision en tant que recommandataire. <BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.<BR><BR>
***************************************************************<BR><BR>
HR Service Request <hrsr_request_cd> has been returned to you for review, as Recommender. <BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.
</HTML>',
'HRsystems/systemesRH@tc.gc.ca', '<V_USER_ID>')
/


-- Returned to Approver:
INSERT INTO email_message_text (emt_email_id, emt_tips_application, emt_email_description,
   emt_subject_text_e, emt_subject_text_f,
   emt_message_text_e, emt_message_text_f,
   emt_sender_email_address, emt_recipient_domain)
VALUES ('113','HRSR','HRSR 2: Returned to Approver',
   'HR Service Request <hrsr_request_cd> returned to Approver',
   'Demande de service en RH <hrsr_request_cd> retourné retournée à l’approbateur',
   '<HTML>** Le texte français suit l''anglais. **<BR><BR>
HR Service Request <hrsr_request_cd> has been returned to you for review, as Approver. <BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.<BR><BR>
***************************************************************<BR><BR>
La demande de service en RH <hrsr_request_cd> vous a été retournée pour révision e en tant qu''approbateur.<BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.
</HTML>',
   '<HTML>** English text follows French. **<BR><BR>
La demande de service en RH <hrsr_request_cd> vous a été retournée pour révision e en tant qu''approbateur.<BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR>
Commentaire : <v_comment_txt> <BR><BR>  
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.<BR><BR>
***************************************************************<BR><BR>
HR Service Request <hrsr_request_cd> has been returned to you for review, as Approver. <BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR>
Comment:         <v_comment_txt> <BR><BR>  
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.
</HTML>',
'HRsystems/systemesRH@tc.gc.ca', '<V_USER_ID>')
/

-- Withdrawn:
INSERT INTO email_message_text (emt_email_id, emt_tips_application, emt_email_description,
   emt_subject_text_e, emt_subject_text_f,
   emt_message_text_e, emt_message_text_f,
   emt_sender_email_address, emt_recipient_domain)
VALUES ('114','HRSR','HRSR 2: Withdrawn',
   'HR Service Request <hrsr_request_cd> has been withdrawn',
   'Demande de service en RH <hrsr_request_cd> retirée',
   '<HTML>** Le texte français suit l''anglais. **<BR><BR>
HR Service Request <hrsr_request_cd> has been withdrawn. <BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was created and withdrawn in HRSR 2.0.<BR><BR>
Please do not respond to this e-mail which is system generated.<BR><BR>
***************************************************************<BR><BR>
La demande de service en RH <hrsr_request_cd> a été retiré.<BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande a été créée et retirée dans l’application DSRH 2.0.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.<BR><BR>
</HTML>',
   '<HTML>** English text follows French. **<BR><BR>
La demande de service en RH <hrsr_request_cd> a été retiré.<BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande a été créée et retirée dans l’application DSRH 2.0.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.<BR><BR>
***************************************************************<BR><BR>
HR Service Request <hrsr_request_cd> has been withdrawn. <BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was created and withdrawn in HRSR 2.0.<BR><BR>
Please do not respond to this e-mail which is system generated.<BR><BR>
</HTML>',
'HRsystems/systemesRH@tc.gc.ca', '<V_USER_ID>')
/


-- Cancelled by HR:
INSERT INTO email_message_text (emt_email_id, emt_tips_application, emt_email_description,
   emt_subject_text_e, emt_subject_text_f,
   emt_message_text_e, emt_message_text_f,
   emt_sender_email_address, emt_recipient_domain)
VALUES ('115','HRSR','HRSR 2: Cancelled by HR',
   'HR Service Request <hrsr_request_cd> has been cancelled by HR',
   'Demande de service en RH <hrsr_request_cd> annulée par RH',
   '<HTML>** Le texte français suit l''anglais. **<BR><BR>
HR Service Request <hrsr_request_cd> has been cancelled by HR. <BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was cancelled by HR in HRSR 2.0.<BR><BR>
Please do not respond to this e-mail which is system generated.<BR><BR>
***************************************************************<BR><BR>
La demande de service en RH <hrsr_request_cd> a été annulée par RH.<BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande a été créée et annulée dans l’application DSRH 2.0.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.<BR><BR>
</HTML>',
   '<HTML>** English text follows French. **<BR><BR>
La demande de service en RH <hrsr_request_cd> a été annulée par RH.<BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande a été créée et annulée dans l’application DSRH 2.0.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.<BR><BR>
***************************************************************<BR><BR>
HR Service Request <hrsr_request_cd> has been cancelled by HR. <BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was cancelled by HR in HRSR 2.0.<BR><BR>
Please do not respond to this e-mail which is system generated.<BR><BR>
</HTML>',
'HRsystems/systemesRH@tc.gc.ca', '<V_USER_ID>')
/

-- CSA ONLY: submitted to Compensation for a PRI:
INSERT INTO email_message_text (emt_email_id, emt_tips_application, emt_email_description,
   emt_subject_text_e, emt_subject_text_f,
   emt_message_text_e, emt_message_text_f,
   emt_sender_email_address, emt_recipient_domain)
VALUES ('116','HRSR','HRSR 2: (CSA ONLY): Submitted to Compensation for a PRI',
   'HR Service Request <hrsr_request_cd> has been submitted to you for a PRI',
   'Demande de service en RH <hrsr_request_cd> envoyée à la Rémunération pour un CIDP',
   '<HTML>** Le texte français suit l''anglais. **<BR><BR>
HR Service Request <hrsr_request_cd> has been submitted to you for a PRI.<BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.<BR><BR>
***************************************************************<BR><BR>
Demande de service en RH <hrsr_request_cd> envoyée à la Rémunération pour un CIDP.<BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.<BR><BR>
</HTML>',
   '<HTML>** English text follows French. **<BR><BR>
Demande de service en RH <hrsr_request_cd> envoyée à la Rémunération pour un CIDP.<BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.<BR><BR>
***************************************************************<BR><BR>
HR Service Request <hrsr_request_cd> has been submitted to you for a PRI. <BR><BR>
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.<BR><BR>
</HTML>',
'HRsystems/systemesRH@tc.gc.ca', '<V_USER_ID>')
/
-- Forward to Recommender:
INSERT INTO email_message_text (emt_email_id, emt_tips_application, emt_email_description,
   emt_subject_text_e, emt_subject_text_f,
   emt_message_text_e, emt_message_text_f,
   emt_sender_email_address, emt_recipient_domain)
VALUES ('117','HRSR','HRSR 2: Acting < 4 months, Approved and Completed',
   'HR Service Request <hrsr_request_cd> has been approved and completed',
   'Demande de service en RH <hrsr_request_cd> approuvée et finalisée',
   '<HTML>** Le texte français suit l''anglais. **<BR><BR>
HR Service Request <hrsr_request_cd> has been approved and completed. <BR><BR>
This is also confirmation the assignment has been created in the HR system and a request for payment has been sent directly to compensation.<BR><BR>  
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.<BR><BR>
***************************************************************<BR><BR>
La demande de service en RH <hrsr_request_cd> a été approuvée et finalisée.<BR><BR>
Cela confirme également que l''affectation a été créée dans le système RH et qu''une demande de paiement a été envoyée directement à la Rémunération.<BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.
</HTML>',
   '<HTML>** English text follows French. **<BR><BR>
La demande de service en RH <hrsr_request_cd> a été approuvée et finalisée.<BR><BR>
Cela confirme également que l''affectation a été créée dans le système RH et qu''une demande de paiement a été envoyée directement à la Rémunération.<BR><BR>
Détails : <BR><BR>
Mesure : <action_type_fnm> <BR>
Numéro du poste : <position_number> <BR>
Classification : <classification> <BR>
Nom du candidat : <candidate_name> <BR>
Date de début : <v_start_date> <BR>
Date de fin : <v_end_date><BR><BR> 
Commentaire : <v_comment_txt> <BR><BR> 
Veuillez noter que cette demande est complétée dans l’application DSRH 2.0. Assurez-vous de cliquer sur le lien correspondant à l’application DSRH 2.0 dans le Portail Libre service RH, car vous ne pourrez pas accéder à cette demande dans DSRH 1.0.<BR><BR>
Lien : <a href="~/HRWSI/index.html?culture=fr-CA">Demande de service en ressources humaines 2.0</a>.<BR><BR>
Prière de ne pas répondre à ce courriel qui est envoyé par le système.<BR><BR>
***************************************************************<BR><BR>
HR Service Request <hrsr_request_cd> has been approved and completed. <BR><BR>
This is also confirmation the assignment has been created in the HR system and a request for payment has been sent directly to compensation.<BR><BR>  
Details:<BR><BR>
Action: <action_type_enm> <BR>
Position Number: <position_number> <BR>
Classification: <classification> <BR>
Candidate Name: <candidate_name> <BR>
Start Date: <v_start_date> <BR>
End Date: <v_end_date><BR><BR> 
Comment:         <v_comment_txt> <BR><BR> 
Please note that this request was submitted in HRSR 2.0. Please ensure that you click on the link for the HRSR 2.0 application in the HR Self-Service Portal as you will not be able to access this request in HRSR 1.0.<BR><BR>
Link: <a href="~/HRWSI/index.html?culture=en-CA">Human Resources Service Request 2.0</a>.<BR><BR>
Please do not respond to this e-mail which is system generated.
</HTML>',
'HRsystems/systemesRH@tc.gc.ca', '<V_USER_ID>')
/


-- LR Emails:

INSERT INTO email_message_text (EMT_EMAIL_ID,EMT_TIPS_APPLICATION,EMT_EMAIL_DESCRIPTION,EMT_SUBJECT_TEXT_E,EMT_SUBJECT_TEXT_F,EMT_MESSAGE_TEXT_E,EMT_MESSAGE_TEXT_F,EMT_SENDER_EMAIL_ADDRESS,EMT_RECIPIENT_DOMAIN)
  VALUES('118','HRSR',
  'HRSR 2: Email Exclusion Unit: Acting assignment functioning as excluded position',
  'Acting assignment in excluded position: <v_position_nmbr>',
  'Affectation intérimaire dans un poste exclu : <v_position_nmbr>',
  '** Le texte français suit l''anglais. ** <BR><BR>This is to inform you that <B><v_employee_name></B> is acting in the following excluded position: <B><v_position_nmbr></B>. Please action as required.',
  '***** <BR><BR>La présente vise à vous informer que <B><v_employee_name></B> est en affectation intérimaire dans le poste exclu suivant : <B><v_position_nmbr></B>. Veuillez prendre les mesures nécessaires.',
  'HRsystems/systemesRH@tc.gc.ca',
  'TC.ESandExclusions-SEetexclusions.TC@tc.gc.ca')
/  
  
INSERT INTO email_message_text (EMT_EMAIL_ID,EMT_TIPS_APPLICATION,EMT_EMAIL_DESCRIPTION,EMT_SUBJECT_TEXT_E,EMT_SUBJECT_TEXT_F,EMT_MESSAGE_TEXT_E,EMT_MESSAGE_TEXT_F,EMT_SENDER_EMAIL_ADDRESS,EMT_RECIPIENT_DOMAIN)
  VALUES('119','HRSR',
  'HRSR 2: Email Exclusion Unit: Excluded employee acting in a non-excluded position',
  'Excluded employee acting in a non-excluded position: <v_position_nmbr>',
  'Employé exclu intérimaire dans un poste non exclu : <v_position_nmbr>',
  '** Le texte français suit l''anglais. ** <BR><BR> This is to inform you that <B><v_employee_name></B>, who occupies an excluded position, is acting in the following non-excluded position: <B><v_position_nmbr></B>. Please action as required.',
  '***** <BR><BR>La présente vise à vous informer que <B><v_employee_name></B>, qui occupe un poste exclu, est en affectation intérimaire dans le poste non exclu suivant : <B><v_position_nmbr></B>. Veuillez prendre les mesures nécessaires.',
  'HRsystems/systemesRH@tc.gc.ca',
  'TC.ESandExclusions-SEetexclusions.TC@tc.gc.ca')
/    


INSERT INTO email_settings
  SELECT emt_email_id,
         'INTSMTP','25','andrew.monteiro@tc.gc.ca',NULL,NULL
   FROM email_message_text 
  WHERE emt_email_id IN ( '109', '110', '111','112','113','114','115','116','117','118','119');          

COMMIT;

   
    
