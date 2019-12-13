--SELECT * FROM ah098_hrsr_letter;
--DELETE FROM ah099_hrsr_letter_body where hrsr_letter_id = '4';
--SELECT * FROM th188_hrsr_letter_section;

INSERT INTO ah098_hrsr_letter (hrsr_letter_enm, hrsr_letter_fnm)
VALUES ('Casual', 'Temporaire');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '1', 1,
          'PROTECTED A 
          
<v_current_date_etxt>', 
          '« Protégé A » 
          
<v_current_date_ftxt>');
          
INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '2', 1,
          '<v_candidate_given_name> <v_candidate_family_name>
PRI: <v_candidate_pri>',
          '<v_candidate_given_name> <v_candidate_family_name>
PRI: <v_candidate_pri>');         

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '2', 2,
'Offer of Casual Employment <v_extension_enm>
Selection Process Number:          <v_selection_process_nmbr>
Position Number:                   <v_position_nmbr>
Position Title:                    <v_position_title_enm>
Group/Level:                       <v_position_classn_txt>
Language requirements:             <v_pos_lang_enm>
Position Security Clearance Level: <v_security_clearance_enm>        
Region:                            <v_region_enm> 
Directorate:                       <v_directorate_enm>
Pre-employment Medical:            <v_pre-medical_etxt>',
'FRENCH
Offer of Casual Employment <v_extension_fnm>
Selection Process Number:          <v_selection_process_nmbr>
Position Number:                   <v_position_nmbr>
Position Title:                    <v_position_title_enm>
Group/Level:                       <v_position_classn_txt>
Language requirements:             <v_pos_lang_fnm>
Position Security Clearance Level: <v_security_clearance_enm>        
Region:                            <v_region_enm> 
Directorate:                       <v_directorate_enm>
Pre-employment Medical:            <v_pre-medical_etxt>');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '5', 1,
          'On behalf of Transport Canada, I am pleased to offer you a specified period of casual employment from <v_asn_start_dte_enm> to <v_asn_end_dte_enm> at the rate of pay of <v_salary_enm>. <v_opt_allowances_enm>', 
          'FRENCH:
On behalf of Transport Canada, I am pleased to offer you a specified period of casual employment from <v_asn_start_dte_fnm> to <v_asn_end_dte_fnm> at the rate of pay of <v_salary_fnm>. <v_opt_allowances_fnm>');
        
INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '5', 2,
          'Your weekly hours of work are <v_aww> hours per week. ', 
          'FRENCH:
           Your weekly hours of work are <v_aww> hours per week. ');
           
INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '5', 3,
          'RDIMS # 11838039 contains a time sheet that you must complete and submit to Compensation Operations – APRBC to request payment for your as-and-when-required assignment. One time sheet should be submitted for each pay period that you have hours to report.', 
          'FRENCH:
           RDIMS # 11838039 contains a time sheet that you must complete and submit to Compensation Operations – APRBC to request payment for your as-and-when-required assignment. One time sheet should be submitted for each pay period that you have hours to report.');         

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '5', 4,
          'Days of the week on which work will be performed: 
<v_pt_hours_schedule_etxt>', 
          'FRENCH:
Days of the week on which work will be performed: 
<v_pt_hours_schedule_ftxt>');         


INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '5', 5,
          'Your employment period may be shorter based on operational requirements or termination of cause. Nothing in this offer should be construed as an offer of term or indeterminate (permanent) employment, nor should you in any way plan or anticipate continuing employment in the Public Service of Canada as a result of this offer.

During your casual employment period, you will not be eligible to apply for internal advertised appointment processes. The public Service Employment Act (PSEA) specifies that the period of employment of a casual worker may not exceed ninety (90) working days in one calendar year at any particular department or other organization. Any number of hours worked in a day counts as a full day of work.', 
          'FRENCH:
Your employment period may be shorter based on operational requirements or termination of cause. Nothing in this offer should be construed as an offer of term or indeterminate (permanent) employment, nor should you in any way plan or anticipate continuing employment in the Public Service of Canada as a result of this offer.

During your casual employment period, you will not be eligible to apply for internal advertised appointment processes. The public Service Employment Act (PSEA) specifies that the period of employment of a casual worker may not exceed ninety (90) working days in one calendar year at any particular department or other organization. Any number of hours worked in a day counts as a full day of work.');           

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '5', 6,
          'Conditions of Employment:
          
<v_custom_emp_cond_etxt>', 
          'FRENCH:
Conditions of Employment:
          
<v_custom_emp_cond_ftxt>');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '5', 7,
          'Should you need workplace accommodation, please inform your manager as soon as possible prior to the start of your casual employment period.

The method of payment (regular pay and supplementary payments) for employees is by direct deposit to the financial institution of choice. By accepting this offer of employment, you are agreeing to provide the information required to establish direct deposit.', 
          'FRENCH:
Should you need workplace accommodation, please inform your manager as soon as possible prior to the start of your casual employment period.

The method of payment (regular pay and supplementary payments) for employees is by direct deposit to the financial institution of choice. By accepting this offer of employment, you are agreeing to provide the information required to establish direct deposit.');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '5', 8,
          'You must complete the Declaration of Conflict of Interest and Post-Employment form (even if a NIL declaration) and return it to the Values and Ethics Office.
** Please note that the declaration form must be completed and submitted at the same time as you sign your contract.', 
          'FRENCH:
You must complete the Declaration of Conflict of Interest and Post-Employment form (even if a NIL declaration) and return it to the Values and Ethics Office.
** Please note that the declaration form must be completed and submitted at the same time as you sign your contract.');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '5', 9,
          'Acceptance of this casual offer of employment will also serve to certify that you:
          
•   have not worked more than 90 days, in this calendar year, on a casual basis for Transport Canada
•   have read and understood the Values and Ethics Code for the Public Sector (add link or RDIMS #)
•   have read and understood Transport Canada’s Code of Values and Ethics (add link or RDIMS #)
•   have read and understood Transport Canada’s Guidelines on Conflict of Interest and Post Employment (add link or RDIMS # for guidelines and form)
•   recognize that compliance with their terms and requirements is a condition of employment in the Public Service of Canada
•   will comply with the Codes, Policy and Guidelines', 
          'FRENCH:
Acceptance of this casual offer of employment will also serve to certify that you:

•   have not worked more than 90 days, in this calendar year, on a casual basis for Transport Canada
•   have read and understood the Values and Ethics Code for the Public Sector (add link or RDIMS #)
•   have read and understood Transport Canada’s Code of Values and Ethics (add link or RDIMS #)
•   have read and understood Transport Canada’s Guidelines on Conflict of Interest and Post Employment (add link or RDIMS # for guidelines and form)
•   recognize that compliance with their terms and requirements is a condition of employment in the Public Service of Canada
•   will comply with the Codes, Policy and Guidelines');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '5', 10,
          'TERMS AND CONDITIONS OF CASUAL EMPLOYMENT:
Your employment will be governed by the Directive on Terms and Conditions of Employment. The most significant provisions are:
•   Vacation pay of 4% of regular pay and overtime, if applicable.
•   Leave without pay at the discretion of your supervisor.
•   Casual workers who have 3 months continuous employment and whose employment is terminated prior to expiry date due to a lack of work or discontinuance of a function, will receive 2 weeks’ notice or 2 weeks’ pay in lieu, or pay for the remaining period of employment agreement, whichever is less. If applicable, this directive will also determine your compensation for overtime and work on a holiday, hours of work, statutory holidays, allowances and acting pay.', 
          'FRENCH:
TERMS AND CONDITIONS OF CASUAL EMPLOYMENT:
Your employment will be governed by the Directive on Terms and Conditions of Employment. The most significant provisions are:
•   Vacation pay of 4% of regular pay and overtime, if applicable.
•   Leave without pay at the discretion of your supervisor.
•   Casual workers who have 3 months continuous employment and whose employment is terminated prior to expiry date due to a lack of work or discontinuance of a function, will receive 2 weeks’ notice or 2 weeks’ pay in lieu, or pay for the remaining period of employment agreement, whichever is less. If applicable, this directive will also determine your compensation for overtime and work on a holiday, hours of work, statutory holidays, allowances and acting pay.');
    

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '6', 1,
          'For more information, please contact your manager or Human Resources (HR) Advisor.

If you are in receipt of a public service pension, please look into the impact this employment may have on your pension before accepting this offer.

Yours sincerely,



<v_signature_line>', 
          'FRENCH:
For more information, please contact your manager or Human Resources (HR) Advisor.

If you are in receipt of a public service pension, please look into the impact this employment may have on your pension before accepting this offer.


Yours sincerely,



<v_signature_line>
<v_title>');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '6', 2,
'
If you have previous service with Transport Canada or with the Federal Public Service, please complete the following section:

Select one of the following:

__ I attest that I did not receive a Transition Support Measure, pay in lieu of unfulfilled surplus period, or an educational allowance to a workforce adjustment situation.

__ I attest that I did receive a Transition Support Measure, pay in lieu of unfulfilled surplus period, or an educational allowance to a workforce adjustment situation.

Previous Core Public Administration Employer:  ________________________________________________________________

Termination date with the previous Core Public Administration Employer: ___________________________________________________',
'FRENCH

If you have previous service with Transport Canada or with the Federal Public Service, please complete the following section:

Select one of the following:

__ I attest that I did not receive a Transition Support Measure, pay in lieu of unfulfilled surplus period, or an educational allowance to a workforce adjustment situation.

__ I attest that I did receive a Transition Support Measure, pay in lieu of unfulfilled surplus period, or an educational allowance to a workforce adjustment situation.

Previous Core Public Administration Employer:  ________________________________________________________________

Termination date with the previous Core Public Administration Employer: ___________________________________________________');



INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('4', '6', 3,
'

___     I accept the offer of employment, the terms and conditions of employment and I have read and understood the Values and Ethics Code for the Public Sector, the Transport Canada Values and Ethics Code and the Policy on Conflict of Interest and Post-Employment.   

___     I refuse the offer of employment 



__________________________________      ______________________________
Signature                               DATE

',
'FRENCH:

___     I accept the offer of employment, the terms and conditions of employment and I have read and understood the Values and Ethics Code for the Public Sector, the Transport Canada Values and Ethics Code and the Policy on Conflict of Interest and Post-Employment.   

___     I refuse the offer of employment 



__________________________________      ______________________________
Signature                               DATE

');

            
COMMIT;
        



