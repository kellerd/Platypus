--SELECT * FROM TH198_HRSR_WORK_HOURS;

INSERT INTO TH198_HRSR_WORK_HOURS (hrsr_work_hours_cd, hrsr_work_hours_enm, hrsr_work_hours_fnm)
  VALUES ('FT', 'Full time', 'Plein temps');
  
INSERT INTO TH198_HRSR_WORK_HOURS (hrsr_work_hours_cd, hrsr_work_hours_enm, hrsr_work_hours_fnm)
  VALUES ('PT', 'Part time', 'Temps partiel');  
  
INSERT INTO TH198_HRSR_WORK_HOURS (hrsr_work_hours_cd, hrsr_work_hours_enm, hrsr_work_hours_fnm)
  VALUES ('AS', 'As and when required', 'Travail selon les besoins');    

COMMIT;  

