--SELECT * FROM TH050_HRSR_STATUS;

UPDATE TH050_HRSR_STATUS
   SET confirm_dialogue_etxt = 'I have read and understood the Accountability Agreement (RDIMS # &lt;a href=''pcdocs://RDIMS/6585675/r''&gt;6585675&lt;/a&gt;) whereby I commit to respect the key result values and the guiding values associated with a staffing action, as well as to provide all file documentation that is required for each key decision point, as per my staffing sub-delegated authorities and responsibilities as stated on my Letter of delegation.
- Are you sure you want to forward this Service Request?
- Click on Yes to submit the Service Request, otherwise click on No',
       confirm_dialogue_ftxt = 'J’ai lu et compris l’Entente de responsabilisation (SGGDI # &lt;a href=''pcdocs://RDIMS/6585675/r''&gt;6585675&lt;/a&gt;) par laquelle je m’engage à respecter les valeurs clés axés sur les résultats et les valeurs Directrices associées à une mesure de dotation ainsi qu’à fournir tous les documents nécessaires au dossier pour chaque point de décision clé, conformément à mes responsabilités et à mes pouvoirs de dotations subdélégués comme indiqué dans ma lettre de délégation.
- Êtes-vous sûr de vouloir transmettre la présente demande de service?
- Cliquez sur Oui pour soumettre la demande de service, sinon cliquez sur Non.'
 WHERE sts_hrsr_status_cd = '6';  
 
COMMIT;
     
