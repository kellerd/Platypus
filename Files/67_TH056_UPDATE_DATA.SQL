

UPDATE TH056_XREF_TH048_FUA SET ext_extension_cd = 'E' -- extension
 WHERE xaf_action_ind IN ( 'A0S', 'T04', 'AAI', 'T13');
 
UPDATE TH056_XREF_TH048_FUA SET ext_extension_cd = 'N' -- New
 WHERE xaf_action_ind IN ( 'A0F', 'T03', 'A0I', 'T12' );
 
UPDATE TH056_XREF_TH048_FUA SET ext_extension_cd = 'X' -- Casual extension
 WHERE xaf_action_ind IN ( 'T02'); 
 
UPDATE TH056_XREF_TH048_FUA SET ext_extension_cd = 'C' -- New Casual 
 WHERE xaf_action_ind IN ( 'T01');  

COMMIT;





