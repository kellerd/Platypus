INSERT INTO global_validations
VALUES ('GLB', 'HRSR_VERSION', '2.0', TRUNC(SYSDATE), '000', 
        'DB Changes made: '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS am'),
        'Changements à la BD effectués: '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MI:SS am'),NULL,NULL,NULL,NULL);
        
COMMIT;

