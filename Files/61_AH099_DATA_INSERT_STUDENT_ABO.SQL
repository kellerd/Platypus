--SELECT * FROM ah098_hrsr_letter;
--DELETE FROM ah099_hrsr_letter_body where hrsr_letter_id = '2' ;
--SELECT * FROM th188_hrsr_letter_section;

INSERT INTO ah098_hrsr_letter (hrsr_letter_enm, hrsr_letter_fnm)
VALUES ('Student: Aboriginal', 'Étudiant: Autochtone');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '1', 1,
          'PROTECTED A 
          
<v_current_date_etxt>', 
          '« Protégé A » 
          
<v_current_date_ftxt>');
          
INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '3', 1,
          '<v_candidate_given_name> <v_candidate_family_name>',
          '<v_candidate_given_name> <v_candidate_family_name>');          

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '2', 1,
'         Subject:                 <v_position_title_enm>  
         Directorate:             <v_directorate_enm>   
         Region:                  <v_region_enm>
         Reference:               <v_selection_process_nmbr>', 
'         Subject:                 <v_position_title_fnm>        
         Direction:               <v_directorate_fnm>  
         Région:                  <v_region_enm>
         Référence:               <v_selection_process_nmbr>');
         
INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '5', 1,
          'On behalf of Transport Canada (TC), I am pleased to offer you employment as part of the <assignment_type_enm> program for the period of <v_assignment_start_dte> to <v_assignment_end_dte>. ', 
          'FRENCH:
           On behalf of Transport Canada (TC), I am pleased to offer you employment as part of the <assignment_type_fnm> program for the period of <v_assignment_start_dte> to <v_assignment_end_dte>. ');
        
INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '5', 2,
          'You will be required to work <v_aww> hours per week. ', 
          'FRENCH:
           You will be required to work <v_aww> hours per week. ');
           
INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '5', 3,
          'Your salary will be <v_salary_enm>, in accordance to the Terms and Conditions of Employment for Students. ', 
          'FRENCH:
           Your salary will be <v_salary_fnm>, in accordance to the Terms and Conditions of Employment for Students. ');         

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '5', 4,
          'Nothing in this letter should be construed as an indeterminate appointment, nor should you anticipate continuing employment in the public service as a result of this offer. Your services may be required for a shorter period depending upon the availability of work and the continuance of the duties to be performed.', 
          'FRENCH:
           Nothing in this letter should be construed as an indeterminate appointment, nor should you anticipate continuing employment in the public service as a result of this offer. Your services may be required for a shorter period depending upon the availability of work and the continuance of the duties to be performed.');           

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '5', 5,
          'This position requires a <v_security_clearance_enm> security clearance. Our records indicate that you meet this condition of employment. You have a responsibility to maintain this level throughout this appointment. ', 
          'FRENCH:
           This position requires a <v_security_clearance_fnm> security clearance. Our records indicate that you meet this condition of employment. You have a responsibility to maintain this level throughout this appointment. ');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '5', 6,
          'Please note that students are not eligible to apply in internal appointment processes unless specifically stated in the area of selection.', 
          'FRENCH:
           Please note that students are not eligible to apply in internal appointment processes unless specifically stated in the area of selection.');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '5', 7,
          'We are committed to having a healthy and respectful work environment. This means that you will be offered an orientation that introduces you to the Public Service values, to the vision of our organization and to your role in contributing to our organizational objectives, as well as to introduce you to your workplace and colleagues. Your manager will be clear about the expectations we have of you, provide an opportunity for meaningful work, and ensure timely access to the tools and training you need to do your work. Your manager will give you regular feedback on your performance, and help you learn and develop professionally. During your employment, you will have regularly scheduled discussions in which your manager will seek your feedback and answer any questions you may have.', 
          'FRENCH:
           We are committed to having a healthy and respectful work environment. This means that you will be offered an orientation that introduces you to the Public Service values, to the vision of our organization and to your role in contributing to our organizational objectives, as well as to introduce you to your workplace and colleagues. Your manager will be clear about the expectations we have of you, provide an opportunity for meaningful work, and ensure timely access to the tools and training you need to do your work. Your manager will give you regular feedback on your performance, and help you learn and develop professionally. During your employment, you will have regularly scheduled discussions in which your manager will seek your feedback and answer any questions you may have.');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '5', 8,
          'Your employment is governed by the Terms and Conditions of Employment for Students. Although you are not governed by any collective agreement, for the purposes of establishing your hours of work or should you be required to work overtime, your entitlements would be based on the <v_collective_agreement_enm> collective agreement.
 
As this employment opportunity involves selection from a Treasury Board of Canada Secretariat approved student employment programs used to increase the representation of Aboriginal peoples, or of designated groups, including Aboriginal peoples, you are required to complete the attached Affirmation of Aboriginal Affiliation Form. Please return a copy with your signed letter of offer.', 
          'FRENCH:
           Your employment is governed by the Terms and Conditions of Employment for Students. Although you are not governed by any collective agreement, for the purposes of establishing your hours of work or should you be required to work overtime, your entitlements would be based on the <v_collective_agreement_fnm> collective agreement.
 
As this employment opportunity involves selection from a Treasury Board of Canada Secretariat approved student employment programs used to increase the representation of Aboriginal peoples, or of designated groups, including Aboriginal peoples, you are required to complete the attached Affirmation of Aboriginal Affiliation Form. Please return a copy with your signed letter of offer.');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '5', 9,
          'All employees, including students, are required to observe the Values and Ethics Code for the Public Sector, the Conflict of Interest and Post-Employment Policy, and the Transport Canada Values and Ethics Code. These key documents are part of your conditions of employment. By accepting this offer you undertake to comply with the requirements contained in these documents. 

•   Treasury Board Secretariat’s Values and Ethics Code for the Public Sector 
•   Transport Canada’s Code of Values and Ethics (attached) 
•   Transport Canada’s Policy on Conflict of Interest and Post-Employment (attached)', 
          'FRENCH:
           All employees, including students, are required to observe the Values and Ethics Code for the Public Sector, the Conflict of Interest and Post-Employment Policy, and the Transport Canada Values and Ethics Code. These key documents are part of your conditions of employment. By accepting this offer you undertake to comply with the requirements contained in these documents. 

•   Treasury Board Secretariat’s Values and Ethics Code for the Public Sector 
•   Transport Canada’s Code of Values and Ethics (attached) 
•   Transport Canada’s Policy on Conflict of Interest and Post-Employment (attached)');
    
INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '5', 10,
          'You must complete the attached Declaration of Conflict of Interest and Post-Employment even if it is a NIL declaration.
          
For more information on how the Policy requirements are applied, please refer to the attached Transport Canada’s Guidelines on Conflict of Interest and Post-Employment.          

A condition of employment is the requirement to take the oath/solemn affirmation. It will be administered before the end of the first day of your appointment. Please note that your appointment may not take effect before the date on which you take the oath/solemn affirmation. <v_custom_emp_cond_etxt>

Should you have workplace accommodation needs, please inform your manager prior to your start date or as soon as possible.    

The method of payment for new employees including students is by direct deposit to the financial institution chosen by the employee. By accepting this offer of employment, you are agreeing to provide the information required to activate the direct deposit. ', 
          'FRENCH:
           You must complete the attached Declaration of Conflict of Interest and Post-Employment even if it is a NIL declaration.
          
For more information on how the Policy requirements are applied, please refer to the attached Transport Canada’s Guidelines on Conflict of Interest and Post-Employment.          

A condition of employment is the requirement to take the oath/solemn affirmation. It will be administered before the end of the first day of your appointment. Please note that your appointment may not take effect before the date on which you take the oath/solemn affirmation. <v_custom_emp_cond_ftxt>

Should you have workplace accommodation needs, please inform your manager prior to your start date or as soon as possible.

The method of payment for new employees including students is by direct deposit to the financial institution chosen by the employee. By accepting this offer of employment, you are agreeing to provide the information required to activate the direct deposit. ');
           

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '6', 1,
          'For more information, please contact your manager or Human Resources (HR) Advisor.

Yours sincerely,



<v_signature_line>', 
          'FRENCH:
For more information, please contact your manager or Human Resources (HR) Advisor.

Yours sincerely,



<v_signature_line>
<v_title>');


INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '6', 2,
'

___     I accept this offer and related terms and conditions of employment. 

___     I reject this offer. 



__________________________________      ______________________________
Signature                               DATE

',
'FRENCH:

___     I accept this offer and related terms and conditions of employment. 

___     I reject this offer. 



__________________________________      ______________________________
Signature                               DATE

');


INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '8', 1,
          'Attachments:

•   Affirmation of Aboriginal Affiliation Form ', 
          'Attachments:

•   Affirmation of Aboriginal Affiliation Form ');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '8', 2,
          '•   Declaration of Conflict of Interest and Post-Employment', 
          '•   Formulaire de déclaration de conflit d''intérêts et d''après-mandat');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '8', 3,
          '•   Transport Canada’s Code of Values and Ethics', 
          '•   Code de valeurs et d''éthique de Transports Canada');

INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '8', 4,
          '•   Transport Canada’s Policy on Conflict of Interest and Post-Employment', 
          '•   Politique sur les conflits d''intérêts et l''après-mandat de Transports Canada');
     
INSERT INTO ah099_hrsr_letter_body (hrsr_letter_id, hrsr_letter_section_id, display_order_num, hrsr_letter_body_etxt,hrsr_letter_body_ftxt)
  VALUES ('2', '8', 5,
          '•   Guidelines on Conflict of Interest and Post-Employment', 
          '•   Lignes directrices de Transports Canada sur les conflits d''intérêts et l''après-mandat');
            
COMMIT;     

