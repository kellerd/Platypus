INSERT INTO email_message_text (emt_email_id, emt_tips_application, emt_email_description,
emt_subject_text_e, emt_subject_text_f, emt_message_text_e, emt_message_text_f,
emt_sender_email_address, emt_recipient_domain)
VALUES ('108','HRSR','HRSR 2 Transferred from / to Email',
'HR Service Request <hrsr_request_cd> transferred from <v_from_actor_enm> to <v_to_actor_enm>',
'Demande de service en RH <hrsr_request_cd> transferred from <v_from_actor_fnm> to <v_to_actor_fnm>',
'HR Service Request <hrsr_request_cd> has been transferred to you for review, as <v_to_actor_enm>, with the following comment: <v_comment>. <BR><BR>Please access the HRSR system for more information by using your current session or click on this link to open a new one: <BR><a href=http://tcapps.tc.gc.ca/Corp-Serv-Gen/3/ess_lse/ui/pages/login/ess.aspx?culture=0> http://tcapps.tc.gc.ca/Corp-Serv-Gen/3/ess_lse/ui/pages/login/ess.aspx?culture=0</a> <BR><BR>Please do not respond to this e-mail which is system generated.',
'La demande de service en RH <hrsr_request_cd> vous a été retournée pour révision en tant que <v_to_actor_fnm>, with the following comment: <v_comment>.. <BR><BR>Veuillez accéder au système DSRH pour obtenir plus de détails en utilisant votre session en cours ou cliquez sur ce lien pour en débuter une nouvelle : <BR><a href=http://tcapps.tc.gc.ca/Corp-Serv-Gen/3/ess_lse/ui/pages/login/ess.aspx?culture=1> http://tcapps.tc.gc.ca/Corp-Serv-Gen/3/ess_lse/ui/pages/login/ess.aspx?culture=1</a><BR><BR>Prière de ne pas répondre à ce courriel qui est envoyé par le système.',
'HRsystems/systemesRH@tc.gc.ca', '<V_USER_ID>');


INSERT INTO email_settings (ese_email_id, ese_mailhost, ese_mailport, ese_test_email_account)
  VALUES ('108','INTSMTP','25', 'TCTipsDevTeam@tc.gc.ca');

COMMIT;


