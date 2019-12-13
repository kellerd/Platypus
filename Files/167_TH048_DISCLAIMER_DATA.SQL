--SELECT act_hrsr_action_enm, length(act_initiator_disclaimer_etxt) FROM th048_hrsr_action WHERE act_initiator_disclaimer_etxt IS NOT null;

BEGIN 

-- ACTING:
UPDATE th048_hrsr_action
  SET act_action_description_etxt =
'Acting appointment of less than four months are frequently used to provide a rapid solution to the staffing of a vacancy, as well as to provide developmental opportunities to employees. They are well-suited to meet short term needs in a number of situations, such as:
<BR><BR> 
•   to cover the temporary absence of an incumbent (e.g. vacation leave, sick leave);<BR>
•   as a short-term measure while awaiting the completion of an advertised appointment process;<BR>
•   to meet short term operational requirements due to unforeseen or urgent circumstances.<BR><BR>
Although the manager must ensure that the acting employee''s qualifications are consistent with the duties to be performed, employees acting for a period of under 4 months are excluded from meeting the qualifications of the position, including the language requirements.
<BR><BR>
An acting under 4 months may <B>not</B> be used to extend an acting employee if the cumulative period of the acting will be four months or more.',
      act_action_description_ftxt = 
'Les nominations intérimaires de moins de 4 mois sont souvent utilisées pour combler rapidement un poste vacant et pour offrir des possibilités de perfectionnement aux employés. Elles sont appropriées pour répondre à des besoins à court terme dans de nombreuses situations;
<BR><BR>
•   pour remplacer l''absence temporaire d''un employé (p. ex. congé annuel, congé de maladie);  <BR>
•   comme mesure à court terme en attente de l''achèvement d''un processus de nomination annoncé; <BR>
•   pour rencontrer les exigences opérationnelles à court terme en raison de circonstances imprévues ou urgentes.
<BR><BR>
Bien que le gestionnaire doit s''assurer que les qualifications de l''employé intérimaire correspondent aux tâches à exécuter, les employés intérimaires pour moins de 4 mois sont exclus de rencontrer les qualifications du poste, y compris les exigences linguistiques.
<BR><BR>
La nomination intérimaire à court terme ne peut <B>pas</B> être utilisée si la période cumulative de l''intérimaire est égale ou supérieure à quatre mois.'
WHERE act_action_cd = '26';
END;
/


DECLARE 
  v_act_approver_disclaimer_etxt CLOB := 
'Last updated:  2019-12-04<BR><BR>
This action is completely automated (except for assignments involving EX positions) and will not be sent to HR. As soon as you approve this request, the assignment will be created and Compensation will be advised. Because of the financial impact, it is imperative that all the information is entered correctly. 
<BR><BR>
Extensions should be completed well in advance of the end date of the current assignment to ensure that the employee''s pay is not interrupted. 
<BR><BR>
If an employee has overlapping acting assignments, you will have the option to change the dates in your request or to contact your HR Advisor to make modifications to existing assignment. In some cases, you will be given the option to modify the end date of the existing assignment yourself. It is important to consider the financial implications in these situations. 
<BR><BR>
The manager should inform the employee if the acting position''s classification is not part of their current collective agreement. The rules for leave, overtime, allowances and other factors might differ from the substantive classification. For example, an employee in an EX position cannot submit requests for overtime in LEX. If the acting assignment is greater than one calendar month, the employee would pay / not pay union dues based on the acting assignment.
<BR><BR>
When an employee from another Department is acting at Transport Canada, it is the sub-delegated manager''s responsibility to provide the acting information to the employee''s home organisation in order for them to process the acting in their HR system to ensure the appropriate payment in Phoenix. 
<BR><BR>
The employee must meet the conditions of employment of the acting position, including the security requirements. In certain situations, employees can act in a position for which they do not meet the security requirements if it can be arranged that the employee will not be performing the duties associated with the higher security profile.
<BR><BR>
If acting less than four (4) months is to a vacant bilingual position, managers must attempt to fill the position with a candidate who meets the language requirements (PSER 14(2)a).
<BR><BR>
It is recognized that operational requirements may necessitate consecutive acting appointments that could lead to an acting beyond 4 months which are subject to the application of merit including official language proficiency and recourse rights. Using a different position number to avoid these requirements is circumventing the staffing values that are inherent in the PSEA.
<BR><BR>
A manager may not rotate a new person who does not meet the language requirements of the position into a vacant acting position if the cumulative* period of the acting appointments of all persons in that position is four months or longer.
<BR><BR>
<I>* Cumulative period of appointment is defined as being the calculation of all the period of acting appointment in the same position, no matter if there is a break in acting period or not.</I>
<BR><BR>
<B>Please consult your HR Advisor in the following situation: </B>
<BR><BR>
•   If there is a requirement to extend this acting to 4 months or more <BR>
•   If the acting extension will result in a cumulative period of acting equal or greater to 4 months <BR>
•   If rotational short-term acting appointments are being considered <BR>
•   If the employee is entitled to acting pay but you are getting an error saying that it does not qualify as an acting (for example non-promotional acting or supervisory differential)
<BR><BR>
Please refer to the Staffing Bulletin RDIMS # 15269503 for additional information on acting appointments.';

v_act_approver_disclaimer_ftxt CLOB := 
'Dernière mise à jour :  2019-12-04 <BR><BR>
Cette action est entièrement automatisée (sauf pour les affectations impliquant des postes EX) et ne sera pas envoyé aux RH. Dès que vous aurez approuvé cette demande, l''affectation sera créée et la Rémunération en sera avisée. En raison de l''impact financier, il est impératif que toutes les informations soient saisies correctement.
<BR><BR>
Les prolongations doivent être terminées bien avant la date de fin de l''affectation en cours afin de s''assurer que la rémunération de l''employé n''est pas interrompue. 
<BR><BR>
Si un employé a des affectations intérimaires qui se chevauchent, vous aurez l''option de modifier les dates dans votre demande ou de communiquer avec votre conseiller(ère) en ressources humaines pour modifier les dates de l''affectation existante. Dans certains cas, vous aurez l''option de modifier la date de fin de l''affectation existante vous-même. Il est important d''examiner les impacts financiers de ces situations.
<BR><BR>
Le gestionnaire doit informer l''employé si la classification du poste intérimaire ne fait pas partie de sa convention collective. Les règles pour les congés, les heures supplémentaires, les indemnités et d''autres facteurs pourraient différer de la classification du poste d''attache. Par exemple, un employé occupant un poste EX ne peut pas soumettre de demandes d''heures supplémentaires dans LEX. Si l''affectation intérimaire dure plus d''un mois civil, l''employé paiera ou non les cotisations syndicales en fonction de l''affectation intérimaire.
<BR><BR>
Lorsqu''un employé d''un autre ministère occupe un poste intérimaire à Transports Canada, c''est la responsabilité du gestionnaire subdélégué de fournir les renseignements sur l’intérimaire à l''organisation d''attache de l''employé afin qu''elle puisse traiter l’intérimaire dans son système des RH afin d’assurer le paiement approprié de Phénix.
<BR><BR>
L''employé doit satisfaire aux conditions d''emploi du poste dans lequel il sera intérimaire, incluant les exigences de sécurité du poste. Dans certaines situations, les employés peuvent faire de l''intérimaire dans un poste pour lequel ils ne satisfont pas aux exigences en matière de sécurité s''il est possible de faire en sorte que l''employé n''exerce pas les fonctions associées au profil de sécurité supérieur.
<BR><BR>
Si la nomination intérimaire est pour un poste vacant et bilingue, le gestionnaire devrait s''efforcer de combler le poste avec un candidat qui répond aux exigences linguistiques (REFP 14(2)a).
<BR><BR>
Il est reconnu que les exigences opérationnelles peuvent nécessiter des nominations intérimaires consécutives qui pourraient mener à des intérimaires au-delà de 4 mois qui, eux,  sont assujetties à l''application du mérite, y compris les compétences linguistiques officielles et les droits de recours. L''utilisation d''un numéro de poste différent pour éviter ces exigences contourne les valeurs de dotation qui sont inhérentes à la LEFP.
<BR><BR>
Pour les nominations par rotation, le gestionnaire ne peut pas combler le poste avec un candidat qui ne répond pas aux exigences linguistiques du poste si celui-ci est vacant et que la période cumulative* globale de la nomination intérimaire de tous les employés est de quatre mois ou plus.
<BR><BR>
<I>*La période de nomination cumulative est définie comme étant le compte de toute la période de nomination intérimaire dans la même position, peu importe s''il y a une interruption de la période d''intérim ou non.</I>
<BR><BR>
<B>Veuillez consulter votre conseiller(ère) en ressources humaines pour les situations suivantes :</B>
<BR><BR>
•   S''il y a un besoin de prolonger cette nomination intérimaire pour quatre mois ou plus.<BR>
•   Si la prolongation de l''intérimaire entraînera une situation de nominations intérimaires cumulatives de quatre mois et plus.<BR>
•   Si des nominations intérimaires à court terme par rotation sont considérées, <BR>
•   Si l''employés a le  à une rémunération intérimaire mais que vous obtenez un message d''erreur disant que ça ne qualifie pas d''intérimaire (par exemple un intérimaire promotionnel ou une prime de surveillance)
<BR><BR>
Veuillez consulter le bulletin de dotation SGDDI  # 15270229  pour toutes informations additionnelles sur les nominations intérimaires.';

BEGIN 
UPDATE th048_hrsr_action
  SET act_approver_disclaimer_etxt = v_act_approver_disclaimer_etxt,
      act_approver_disclaimer_ftxt = v_act_approver_disclaimer_ftxt
WHERE act_action_cd = '26';
END;
/

BEGIN
-- STUDENT:
UPDATE th048_hrsr_action
   SET act_action_description_etxt = 
'Students can be hired for a variety of work on a full-time or part-time basis through one of the following programs: Federal Student Work Experience Program (FSWEP), the Coop/Internship program (COOP) or the Research Affiliate Program (RAP). It allows secondary and post-secondary students to gain relevant and practical work experience and access to career opportunities.',
       act_action_description_ftxt = 
'Les étudiants peuvent être embauchés pour du travail varié à temps plein ou à temps partiel via l''un des programmes suivants: Programme fédéral d''expérience de travail étudiant (PFETE), Programme coopératif/de stage (COOP) ou Programme des adjoints de recherches (PAR) ). Il permet aux étudiants secondaires et du postsecondaires d''acquérir une expérience de travail pertinente et pratique et d''avoir accès à des perspectives de carrière.'
WHERE act_action_cd = '28';
END;
/

DECLARE
  v_stu_approver_disclaimer_etxt CLOB := 
    'This action is completely automated and will not be sent to HR; you will automatically create the assignment and Compensation will be advised. For this reason and because of the financial impact, it is imperative that all the information is entered correctly.
<BR><BR>
Additional information on student hiring can be found through the Manager''s Guide to Students RDIMS # 14296922.
<BR><BR>
<B>Steps to hire/extend a student in HRSR 2.0:</B>
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   1.&nbsp;&nbsp;  Carefully enter all the necessary data and attach all required documents
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   2.&nbsp;&nbsp;  Approve request (Staffing Delegated Manager)
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   3.&nbsp;&nbsp;  Generate and review letter of offer (approver, recommender or initiator)
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   4.&nbsp;&nbsp;  If there are any errors on the letter of offer, do not make the changes manually on the letter. The assignment will be based on the information in HRSR. You must modify the request in HRSR and re-approve it.
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   5.&nbsp;&nbsp;  Sign letter of offer (HRSR approver and employee).  Refer to note below for employees not currently working at TC.
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   6.&nbsp;&nbsp;  Print and get employee to sign oath, Aboriginal Affiliation Form (if applicable), and student learning plan (see references below)
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   7.&nbsp;&nbsp;  Attach RDIMS link for signed letter of offer, oath and Aboriginal Affiliation Form (if applicable) 
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   8.&nbsp;&nbsp;  CREATE ASSIGNMENT
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   9.&nbsp;&nbsp;  Assignment is created and Compensation is advised. If the employee does not have a PRI, the request will be briefly redirected to HR to enter the PRI
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   10.&nbsp;&nbsp; Provide employee with the information required to have their pay started.
<BR><BR>
Note that employees not currently working at TC will not have access to the RDMIS documents that are referenced in the letter of offer, so please be sure to enclose PDF copies of the required documents with the letter:
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;  Transport Canada''s Code of Values and Ethics (English RDIMS# 6587068, French RDIMS# 6588937)
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;   Transport Canada''s Guidelines on Conflict of Interest and Post Employment (English RDIMS# 7139901, French RDIMS# 8096263)
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;   Declaration of Conflict of Interest and Post-Employment form (English RDIMS# 6913295, French RDIMS# 6913295)<BR><BR>
<B>References:</B>
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;  <U>Oath / Solemn Affirmation Oath/Solemn Affirmation</U>: It is very important to note that you must administer and complete the Oath/Solemn Affirmation form no later than their first day of work as this effects the appointment date of the student.  The date of appointment is used in the determination of an employee''s benefits (i.e. statutory increment date, pension and insurance eligibility, leave entitlements).  For further details please read the Oaths and Affirmations Procedures (RDIMS: 1400198). 
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;  <U>Affirmation of Aboriginal Affiliation Form</U>: If this employment opportunity involves selection from a Treasury Board of Canada Secretariat approved student employment programs used to increase the representation of Aboriginal peoples, or of designated groups, including Aboriginal peoples, the student is required to complete the Affirmation of Aboriginal Affiliation Form (RDIMS# 5847824) and upload this document to the HRSR.
<BR><BR>
For each student assignment, the manager/supervisor must create a structured learning plan RDIMS# 13190269. This learning plan defines what a student will accomplish during their employment with TC. It is not necessary to save and upload the learning plan into RDIMS. 
<BR><BR>
Extensions should be completed well in advance of the end date of the current assignment to ensure that the employee''s pay is not interrupted. If a student extension is entered more than thirty days after the end date, the original assignment will have been archived so the extension must be entered as a <U>New</U> Student. 
<BR><BR>
If an employee has overlapping student assignments, you will be given the option to modify the end date of the existing assignment. It is important to consider the financial implications in these situations.
<BR><BR>
When hiring a student on an as-and-when-required basis, the start date of the assignment should be the first day that the employee worked or will work. The Record of Employment requires earnings in the first and last pay period. Note that when a predictable pattern of specific work hours exist, part-time should be selected and the hours of work should be specified in the letter of offer. As-and-when-required should not be selected in this situation. 
<BR><BR>
Timesheet for As-and-when required employees:  You must complete and submit a timesheet RDIMS # 11838039 to PayCompensationOpsAPRBC@tc.gc.ca  to request payment for the as-and-when-required employee. You should submit one time sheet for each pay period RDIMS # 13317638 that the employee has hours to report. 
<BR><BR>
Should you need advice or to consult a professional in order to complete your HRSR request, please contact your Human Resources Advisor.';

  v_stu_approver_disclaimer_ftxt CLOB := 
    'This action is completely automated and will not be sent to HR; you will automatically create the assignment and Compensation will be advised. For this reason and because of the financial impact, it is imperative that all the information is entered correctly.
<BR><BR>
Additional information on student hiring can be found through the Manager''s Guide to Students RDIMS # 14296922.
<BR><BR>
<B>Steps to hire/extend a student in HRSR 2.0:</B>
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   1.&nbsp;&nbsp;  Carefully enter all the necessary data and attach all required documents
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   2.&nbsp;&nbsp;  Approve request (Staffing Delegated Manager)
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   3.&nbsp;&nbsp;  Generate and review letter of offer (approver, recommender or initiator)
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   4.&nbsp;&nbsp;  If there are any errors on the letter of offer, do not make the changes manually on the letter. The assignment will be based on the information in HRSR. You must modify the request in HRSR and re-approve it.
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   5.&nbsp;&nbsp;  Sign letter of offer (HRSR approver and employee).  Refer to note below for employees not currently working at TC.
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   6.&nbsp;&nbsp;  Print and get employee to sign oath, Aboriginal Affiliation Form (if applicable), and student learning plan (see references below)
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   7.&nbsp;&nbsp;  Attach RDIMS link for signed letter of offer, oath and Aboriginal Affiliation Form (if applicable) 
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   8.&nbsp;&nbsp;  CREATE ASSIGNMENT
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   9.&nbsp;&nbsp;  Assignment is created and Compensation is advised. If the employee does not have a PRI, the request will be briefly redirected to HR to enter the PRI
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;   10.&nbsp;&nbsp; Provide employee with the information required to have their pay started.
<BR><BR>
Note that employees not currently working at TC will not have access to the RDMIS documents that are referenced in the letter of offer, so please be sure to enclose PDF copies of the required documents with the letter:
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;  Transport Canada''s Code of Values and Ethics (English RDIMS# 6587068, French RDIMS# 6588937)
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;  Transport Canada''s Guidelines on Conflict of Interest and Post Employment (English RDIMS# 7139901, French RDIMS# 8096263)
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;  Declaration of Conflict of Interest and Post-Employment form (English RDIMS# 6913295, French RDIMS# 6913295)<BR><BR>
<B>References:</B>
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;  <U>Oath / Solemn Affirmation Oath/Solemn Affirmation</U>: It is very important to note that you must administer and complete the Oath/Solemn Affirmation form no later than their first day of work as this effects the appointment date of the student.  The date of appointment is used in the determination of an employee''s benefits (i.e. statutory increment date, pension and insurance eligibility, leave entitlements).  For further details please read the Oaths and Affirmations Procedures (RDIMS: 1400198). 
<BR><BR>
&nbsp;&nbsp;&nbsp;&nbsp;•&nbsp;&nbsp;  <U>Affirmation of Aboriginal Affiliation Form</U>: If this employment opportunity involves selection from a Treasury Board of Canada Secretariat approved student employment programs used to increase the representation of Aboriginal peoples, or of designated groups, including Aboriginal peoples, the student is required to complete the Affirmation of Aboriginal Affiliation Form (RDIMS# 5847824) and upload this document to the HRSR.
<BR><BR>
For each student assignment, the manager/supervisor must create a structured learning plan RDIMS# 13190269. This learning plan defines what a student will accomplish during their employment with TC. It is not necessary to save and upload the learning plan into RDIMS. 
<BR><BR>
Extensions should be completed well in advance of the end date of the current assignment to ensure that the employee''s pay is not interrupted. If a student extension is entered more than thirty days after the end date, the original assignment will have been archived so the extension must be entered as a <U>New</U> Student. 
<BR><BR>
If an employee has overlapping student assignments, you will be given the option to modify the end date of the existing assignment. It is important to consider the financial implications in these situations.
<BR><BR>
When hiring a student on an as-and-when-required basis, the start date of the assignment should be the first day that the employee worked or will work. The Record of Employment requires earnings in the first and last pay period. Note that when a predictable pattern of specific work hours exist, part-time should be selected and the hours of work should be specified in the letter of offer. As-and-when-required should not be selected in this situation. 
<BR><BR>
Timesheet for As-and-when required employees:  You must complete and submit a timesheet RDIMS # 11838039 to PayCompensationOpsAPRBC@tc.gc.ca  to request payment for the as-and-when-required employee. You should submit one time sheet for each pay period RDIMS # 13317638 that the employee has hours to report. 
<BR><BR>
Should you need advice or to consult a professional in order to complete your HRSR request, please contact your Human Resources Advisor.';


BEGIN 

UPDATE th048_hrsr_action
  SET act_approver_disclaimer_etxt = v_stu_approver_disclaimer_etxt,
      act_approver_disclaimer_ftxt = v_stu_approver_disclaimer_ftxt
WHERE act_action_cd = '28';  

END;
/


-- CASUAL:
UPDATE th048_hrsr_action
   SET act_action_description_etxt = 
'Casual employment offers flexibility to meet unforeseen needs, to meet emergencies, to replace employees for short periods of absence, such as vacation leave, sick leave, training, etc., or to conduct short-term projects where funding is unpredictable. It is not subject to the provisions of the PSEA, and therefore establishing and demonstrating merit, including official language requirements, is not required. Casual workers are not employees and cannot participate in an internal (to the federal government) appointment process. They may not be employed for more than 90 working days in one calendar year in any particular department or organization.',   
       act_action_description_ftxt = 
'L''embauche d''employés occasionnels permet de répondre aux besoins imprévus et urgents, de remplacer les employés qui s''absentent pendant de courtes périodes (vacances, congés de maladie, formation, etc.) ou d''entreprendre des projets à court terme au financement imprévisible. L''emploi occasionnel n''étant pas assujetti à la LEFP, il n''est pas nécessaire d''établir ou de démontrer le mérite, incluant les exigences en matière de langues officielles. Les employés occasionnels ne peuvent pas participer aux processus internes (au gouvernement fédéral). Ils ne peuvent qu''être embauchés pour une période ne dépassant pas 90 jours par année civile dans un ministère ou organisme.',       
       act_approver_disclaimer_etxt = 
'This action is completely automated and will not be sent to HR; you will automatically create the assignment and Compensation will be advised. For this reason and because of the financial impact, it is imperative that all the information is entered correctly.
Steps to hire/extend a casual in HRSR 2.0:
1.  Carefully enter all the necessary data and attach all required documents
2.  Approve request (Staffing Delegated Manager)
3.  Generate and review letter of offer (approver, recommender or initiator)
4.  If there are any errors on the letter of offer, do not make the changes manually on the letter. The assignment will be based on the information in HRSR. You must modify the request in HRSR and re-approve it.
5.  Sign letter of offer (HRSR approver and employee).  Refer to note below for employees not currently working at TC. 
6.  Attach RDIMS link for signed letter of offer 
7.  CREATE ASSIGNMENT
8.  Assignment is created and Compensation is advised. If the employee does not have a PRI, the request will be briefly redirected to HR to enter the PRI
9.  Provide employee with the information required to have their pay started.
Note: employees not currently working at TC will not have access to the RDMIS documents that are referenced in the letter of offer, so please be sure to enclose PDF copies of the required documents with the letter:
•   Transport Canada''s Code of Values and Ethics (English RDIMS# 6587068, French RDIMS# 6588937)
•   Transport Canada''s Guidelines on Conflict of Interest and Post Employment (English RDIMS# 7139901, French RDIMS# 8096263)
•   Declaration of Conflict of Interest and Post-Employment form (English RDIMS# 6913295, French RDIMS# 6913295)
Extensions should be completed well in advance of the end date of the current assignment to ensure that the employee''s pay is not interrupted. If a casual extension is entered more than thirty days after the end date, the original assignment will have been archived so the extension must be entered as a New Casual. It is important that you abide by the rules of 90 working days in a calendar year. Note that a partial day counts as a full day when calculating the 90 days.
<BR><BR>
If an employee has overlapping casual assignments, you will be given the option to modify the end date of the existing assignment. It is important to consider the financial implications in these situations.
<BR><BR>
When using a phantom position, both English and French titles are mandatory fields. This is an Official Languages requirement and is the responsibility of the delegated manager approving the request.
<BR><BR>
If your employee is a pensioner, please ensure that they look into potential impacts to their pension before accepting a casual offer. 
<BR><BR>
When hiring a casual on an as-and-when-required basis, the start date of the assignment should be the first day that the employee worked or will work. The Record of Employment requires earnings in the first and last pay period. Note that when a predictable pattern of specific work hours exist, part-time should be selected and the hours of work should be specified in the letter of offer. As-and-when-required should not be selected in this situation.
<BR><BR>
Timesheet for As-and-when required employees:  You must complete and submit a timesheet RDIMS # 11838039 to PayCompensationOpsAPRBC@tc.gc.ca  to request payment for the “as and when required” employee. You should submit one time sheet for each pay period RDIMS # 13317638 for which the employee has hours to report. 
<BR><BR>
Should you need advice or to consult a professional in order to complete your HRSR request, please contact your Human Resources Advisor.',
act_approver_disclaimer_ftxt = 
'This action is completely automated and will not be sent to HR; you will automatically create the assignment and Compensation will be advised. For this reason and because of the financial impact, it is imperative that all the information is entered correctly.
Steps to hire/extend a casual in HRSR 2.0:
1.  Carefully enter all the necessary data and attach all required documents
2.  Approve request (Staffing Delegated Manager)
3.  Generate and review letter of offer (approver, recommender or initiator)
4.  If there are any errors on the letter of offer, do not make the changes manually on the letter. The assignment will be based on the information in HRSR. You must modify the request in HRSR and re-approve it.
5.  Sign letter of offer (HRSR approver and employee).  Refer to note below for employees not currently working at TC. 
6.  Attach RDIMS link for signed letter of offer 
7.  CREATE ASSIGNMENT
8.  Assignment is created and Compensation is advised. If the employee does not have a PRI, the request will be briefly redirected to HR to enter the PRI
9.  Provide employee with the information required to have their pay started.
Note: employees not currently working at TC will not have access to the RDMIS documents that are referenced in the letter of offer, so please be sure to enclose PDF copies of the required documents with the letter:
•   Transport Canada''s Code of Values and Ethics (English RDIMS# 6587068, French RDIMS# 6588937)
•   Transport Canada''s Guidelines on Conflict of Interest and Post Employment (English RDIMS# 7139901, French RDIMS# 8096263)
•   Declaration of Conflict of Interest and Post-Employment form (English RDIMS# 6913295, French RDIMS# 6913295)
Extensions should be completed well in advance of the end date of the current assignment to ensure that the employee''s pay is not interrupted. If a casual extension is entered more than thirty days after the end date, the original assignment will have been archived so the extension must be entered as a New Casual. It is important that you abide by the rules of 90 working days in a calendar year. Note that a partial day counts as a full day when calculating the 90 days.
<BR><BR>
If an employee has overlapping casual assignments, you will be given the option to modify the end date of the existing assignment. It is important to consider the financial implications in these situations.
<BR><BR>
When using a phantom position, both English and French titles are mandatory fields. This is an Official Languages requirement and is the responsibility of the delegated manager approving the request.
<BR><BR>
If your employee is a pensioner, please ensure that they look into potential impacts to their pension before accepting a casual offer. 
<BR><BR>
When hiring a casual on an as-and-when-required basis, the start date of the assignment should be the first day that the employee worked or will work. The Record of Employment requires earnings in the first and last pay period. Note that when a predictable pattern of specific work hours exist, part-time should be selected and the hours of work should be specified in the letter of offer. As-and-when-required should not be selected in this situation.
<BR><BR>
Timesheet for As-and-when required employees:  You must complete and submit a timesheet RDIMS # 11838039 to PayCompensationOpsAPRBC@tc.gc.ca  to request payment for the “as and when required” employee. You should submit one time sheet for each pay period RDIMS # 13317638 for which the employee has hours to report. 
<BR><BR>
Should you need advice or to consult a professional in order to complete your HRSR request, please contact your Human Resources Advisor.'
WHERE act_action_cd = '27';

COMMIT;
