CREATE OR REPLACE PACKAGE ARTHUS.PK_MAIL IS

/* Table declaration for storing e-mail attachment file names. */
type attachment is record (filename varchar2(100));
type tab_of_attachments is table of attachment;
/* Package Function and procedures. */
 /*
    Insere un Mail dans Envoi Mail
 */
PROCEDURE CREER_MAIL( I_envoi_mail IN OUT ENVOI_MAIL%ROWTYPE,
                      i_desactiv_ctrl_doublon IN VARCHAR2  DEFAULT 'N');

FUNCTION  CHECK_DROIT_ENVOI_MAIL(   i_entite IN VARCHAR2,
                                                                    i_numutil IN UTILISATEURS.NUMUTIL%TYPE)
                                                                    RETURN BOOLEAN;

FUNCTION  CHECK_DEMAT_INDIV(p_numindiv IN individu.numindiv%TYPE)RETURN NUMBER;
FUNCTION  CHECK_DEMAT_CLI(p_numindiv IN individu.numindiv%TYPE)RETURN NUMBER;
FUNCTION  CHECK_DEMAT_PREV(p_numindiv IN individu.numindiv%TYPE,p_numcli IN individu.numindiv%TYPE DEFAULT NULL) RETURN NUMBER;
PROCEDURE P_SEND_ALL_MAIL_JOB (i_type_mail IN NUMBER);
PROCEDURE P_SEND_ALL_MAILING (i_type_mail IN NUMBER);
PROCEDURE P_SEND_RAPPORT_ENVOI_MAIL(i_nb_mail_error NUMBER,nb_total_msg number, i_date_session DATE, i_mails_in_error ty_mail_in_error);

PROCEDURE MAIL_JOB (i_job IN VARCHAR2, nb_mess_erreur IN OUT NUMBER );

PROCEDURE P_ORDRE_PC (pc1 IN OUT VARCHAR2,
                                            pc2 IN OUT VARCHAR2,
                                            pc3 IN OUT VARCHAR2,
                                            pc4 IN OUT VARCHAR2);

PROCEDURE mail( i_smtp IN param_machine%ROWTYPE,
                                sender IN VARCHAR2,
                                recipients IN VARCHAR2,
                                cc IN VARCHAR2 default null,
                                bcc IN VARCHAR2 default null,
                                subject IN VARCHAR2,
                                message IN VARCHAR2);

FUNCTION begin_mail(i_smtp IN param_machine%ROWTYPE,
                                        sender IN VARCHAR2,
                                        recipients IN VARCHAR2,
                                        cc IN VARCHAR2 default null,
                                        bcc IN VARCHAR2 default null,
                                        subject IN VARCHAR2,
                                        mime_type IN VARCHAR2 DEFAULT 'text/plain',
                                        priority IN PLS_INTEGER DEFAULT NULL)
    RETURN utl_smtp.connection;

PROCEDURE write_text(   conn IN OUT NOCOPY utl_smtp.connection,
                                            message IN VARCHAR2);

PROCEDURE write_mb_text(conn IN OUT NOCOPY utl_smtp.connection,
                                                message IN VARCHAR2);

PROCEDURE write_raw(conn IN OUT NOCOPY utl_smtp.connection,
                                        message IN RAW);

PROCEDURE attach_text(conn IN OUT NOCOPY utl_smtp.connection,
                                            data IN VARCHAR2,
                                            mime_type IN VARCHAR2 DEFAULT 'text/plain',
                                            inline IN BOOLEAN DEFAULT TRUE,
                                            filename IN VARCHAR2 DEFAULT NULL,
                                            last IN BOOLEAN DEFAULT FALSE);

PROCEDURE attach_mb_text(conn IN OUT NOCOPY utl_smtp.connection,
                                                data IN VARCHAR2,
                                                mime_type IN VARCHAR2 DEFAULT 'text/plain',
                                                inline IN BOOLEAN DEFAULT TRUE,
                                                filename IN VARCHAR2 DEFAULT NULL,
                                                last IN BOOLEAN DEFAULT FALSE);

PROCEDURE attach_base64(conn IN OUT NOCOPY utl_smtp.connection,
                                                data IN RAW,mime_type IN VARCHAR2 DEFAULT 'application/octet',
                                                inline IN BOOLEAN DEFAULT TRUE,
                                                filename IN VARCHAR2 DEFAULT NULL,
                                                last IN BOOLEAN DEFAULT FALSE);

PROCEDURE ATTACH_IMAGE( conn IN OUT NOCOPY utl_smtp.connection,
                        typeimage IN VARCHAR2 DEFAULT 'jpg',
                        inline IN BOOLEAN DEFAULT TRUE,
                        filename IN VARCHAR2 DEFAULT NULL,
                        last IN BOOLEAN DEFAULT FALSE);

PROCEDURE begin_attachment(conn IN OUT NOCOPY utl_smtp.connection,
                                                    mime_type IN VARCHAR2 DEFAULT 'text/plain',
                                                    inline IN BOOLEAN DEFAULT TRUE,
                                                    filename IN VARCHAR2 DEFAULT NULL,
                                                    transfer_enc IN VARCHAR2 DEFAULT NULL);

PROCEDURE end_attachment(conn IN OUT NOCOPY utl_smtp.connection,
                                                 last IN BOOLEAN DEFAULT FALSE);

PROCEDURE end_mail(conn IN OUT NOCOPY utl_smtp.connection);

FUNCTION BEGIN_SESSION (i_smtp param_machine%ROWTYPE)  RETURN utl_smtp.connection;

PROCEDURE begin_mail_in_session(conn IN OUT NOCOPY utl_smtp.connection,
                                                                sender IN VARCHAR2,
                                                                recipients IN VARCHAR2,
                                                                cc IN VARCHAR2 default null,
                                                                bcc IN VARCHAR2 default null,
                                                                subject IN VARCHAR2,
                                                                mime_type IN VARCHAR2 DEFAULT 'text/plain',
                                                                priority IN PLS_INTEGER DEFAULT NULL);


PROCEDURE end_mail_in_session(conn IN OUT NOCOPY utl_smtp.connection);

PROCEDURE end_session(conn IN OUT NOCOPY utl_smtp.connection);

PROCEDURE transcode_template(   template_mail IN OUT CLOB,
                                corps_msg IN CLOB,
                                numindiv IN NUMBER,
                                numbene IN NUMBER,
                                sujet_msg IN VARCHAR2 ) ;

FUNCTION F_MARQUE_template(l_num_destinataire individu.numindiv%type) return VARCHAR2;

PROCEDURE send_email(   P_RECIPIENT IN VARCHAR2,
                        P_CC IN VARCHAR2,
                        P_BCC IN VARCHAR2,
                        P_SUBJECT IN VARCHAR2,
                        P_BODY IN CLOB,
                        P_NUMUTIL       IN NUMBER,
                        P_ATTACHMENT1 IN VARCHAR2 default null,
                        P_ATTACHMENT2 IN VARCHAR2 default null,
                        P_ATTACHMENT3 IN VARCHAR2 default null,
                        P_ATTACHMENT4 IN VARCHAR2 default null,
                        P_SENDER IN VARCHAR2,
                        P_numindiv_dest IN individu.numindiv%type,
                        p_template      IN NUMBER DEFAULT 0,
                        P_ERROR OUT VARCHAR2);



/* Encodage base64 */
FUNCTION encode(r IN RAW) RETURN VARCHAR2;

PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);

FUNCTION F_DUPLIQ_MAIL(i_NUMENVOIMAIL envoi_mail.numenvoimail%type) RETURN NUMBER;

/*PROCEDURE INIT_MAP;*/
PROCEDURE P_CHARGE_MAIL_MASSE;
PROCEDURE P_CHARGE_DCPT;
PROCEDURE P_CHARGE_DCPT_PREV;
PROCEDURE P_CHARGE_PIECE;
PROCEDURE P_CHARGE_CARTE_TP;
PROCEDURE P_CHARGE_ADH_INSTANCE;
PROCEDURE P_CHARGE_ADHESION_VIGUEUR;
PROCEDURE P_CHARGE_ADHESION_OPTION;
PROCEDURE P_CHARGE_QUITTANCE;
PROCEDURE P_CHARGE_RUM;
PROCEDURE P_CHARGE_VCOTIS;
PROCEDURE P_CHARGE_PB2B;
PROCEDURE P_CHARGE_RESIL;
PROCEDURE P_CHARGE_COT_INDIV (P_date DATE);
END PK_MAIL;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_MAIL IS

/* Boundary is an arbitrary string used as seperator marker for different
sections of the of the e-mail. Separates various parts of e-mail and attachments. */



  PROCEDURE CLOSEFILE(fil IN OUT BFILE);


 -- -- Déclaration des variables globales   ----------------------------------
  g_session         journal_adm.id_session%TYPE DEFAULT 1;
  g_nom_traitement  journal_adm.nom_traitement%TYPE:='MA02T';
  g_niv_msg         journal_adm.niv_msg%TYPE;
  g_idligne         journal_adm.idligne%TYPE default 0;
  g_msg_adm         journal_adm.msg_adm%TYPE;


   /* Declaration parametres mail */

 /* smtp_host param_machine.nom_machine%TYPE;
  smtp_port PLS_INTEGER;
  smtp_domain param_machine.domaine%TYPE;
  v_compte_mail utilisateurs.email%TYPE;
  v_password utilisateurs.password_email%TYPE;*/


    /*
        Procédure inserant le mail dans Envoi_Mail.
    */
PROCEDURE CREER_MAIL( I_envoi_mail IN OUT ENVOI_MAIL%ROWTYPE,
                      i_desactiv_ctrl_doublon IN VARCHAR2  DEFAULT 'N') IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  loc_doublon  ENVOI_MAIL.NUMENVOIMAIL%TYPE;
  loc_etat ENVOI_MAIL.ETAT%TYPE;
  loc_type_interloc NUMBER;
  loc_sujet ENVOI_MAIL.SUJET%TYPE;
  loc_corps ENVOI_MAIL.CORPS%TYPE;
BEGIN

  P_INS_journal(3,'dans la procédure de création');
  -- Gestion des doublons de mail
  IF i_desactiv_ctrl_doublon = 'N' THEN
  BEGIN
    --recherche de doublon de mail, on ne peut pas envoyé deux fois dans la même journée un même e-mail (idtexte)
    SELECT NUMENVOIMAIL,ETAT INTO loc_doublon, loc_etat
    FROM ENVOI_MAIL
    WHERE numindiv_dest = I_envoi_mail.numindiv_dest
    --AND type_mail = I_envoi_mail.type_mail
    --AND etendue = I_envoi_mail.etendue
    --AND clef = I_envoi_mail.clef
    AND idtexte = I_envoi_mail.idtexte
    AND nvl(I_envoi_mail.sujet,sujet)  = sujet
    AND type_mail <> 2  -- controle de doublon uniquemet pour les mails auto ou de masse
      AND trunc(date_creation) = trunc(sysdate)    --envoyé le même jour
    AND (etat = 0 --non envoyé
       OR (etat = 1 AND TRUNC(datemis) = TRUNC(SYSDATE)))
      FETCH FIRST 1 ROWS ONLY;


  EXCEPTION
  WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN
	P_INS_journal(1,'CREER_MAIL erreur'||SQLERRM);
	return;
  END;

  --pour les prises en charge hospitalière et pièce télétrans, on met a jour le mail avec le dernier numedit (si le gestionnaire réédite plusieurs fois le même courrier)
  IF loc_doublon IS NOT NULL  AND I_envoi_mail.numedit IS NOT NULL AND loc_etat = 0  AND I_envoi_mail.idtexte in(18,17) THEN
    UPDATE ENVOI_mail set numedit = I_envoi_mail.numedit
    WHERE numindiv_dest = I_envoi_mail.numindiv_dest
      AND type_mail = I_envoi_mail.type_mail
      AND etendue = I_envoi_mail.etendue
      AND numbene = I_envoi_mail.numbene
      AND clef = I_envoi_mail.clef
      AND etat = 0;
    COMMIT;
    RETURN;
  ELSIF loc_doublon IS NOT NULL  AND I_envoi_mail.numedit IS  NULL THEN
	P_INS_journal(1,'CREER_MAIL doublon de mail detecté pour individu'||I_envoi_mail.numindiv_dest);
    RETURN;
  END IF;
  -- FinSi Controle doublon
  END IF;

  SELECT NUMENVOIMAIL.nextval INTO I_envoi_mail.NUMENVOIMAIL FROM DUAL;
  I_envoi_mail.etat :=0;

  -- récuperation du message paramétré dans mail_texte lorsque l'email est automatique
  --conserver pour l'email de type 5 au cas où on réaliserait des emails de masse sur des mails pro
  IF I_envoi_mail.type_mail  IN (1,3,5) THEN
    BEGIN
      SELECT corps_msg, sujet_msg, type_interlocuteur
      INTO loc_corps,loc_sujet,loc_type_interloc
      FROM mail_texte
	    WHERE id_texte = I_envoi_mail.idtexte;

      --enrichissement seulement si non vide pour ne pas écraser les textes dynamiques #VALEUR
      IF I_envoi_mail.corps IS NULL OR I_envoi_mail.sujet IS NULL THEN
        I_envoi_mail.corps:=loc_corps;
        I_envoi_mail.sujet:=loc_sujet;
      END IF;

       --mail pro M6649 mail 29 multi contexte assuré / RH prise en compte du template
      IF NVL(loc_type_interloc,0) =1 OR (loc_type_interloc=0 AND I_envoi_mail.template_mail  in (2,5))  THEN
        I_envoi_mail.destinataire:= f_coordonne_contact(I_envoi_mail.numindiv_dest,4,1);
      ELSE
        I_envoi_mail.destinataire:= NVL(f_coordonne_contact(I_envoi_mail.numindiv_dest,4,2),f_coordonne_contact(I_envoi_mail.numindiv_dest,4,1))  ;
      END IF ;

    EXCEPTION
      WHEN no_data_found THEN  I_envoi_mail.etat := 3;
    END;
  ELSIF I_envoi_mail.destinataire IS NULL THEN
    I_envoi_mail.destinataire :=NVL(f_coordonne_contact(I_envoi_mail.numindiv_dest,4,2),f_coordonne_contact(I_envoi_mail.numindiv_dest,4,1)) ; --adresse perso puis pro par défaut
  END IF;



  INSERT INTO ENVOI_MAIL VALUES I_envoi_mail ;

  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
    P_INS_journal(3,'[Creation mail]impossible, numDest['||I_envoi_mail.numindiv_dest||'] étendue['||I_envoi_mail.etendue||'] clef['||I_envoi_mail.clef||']');
    g_idligne :=0; -- remise a 0 de l'id ligne pour les opéarations réalisées par le ws qui as toujours la même sessions et par conséquente ne remet pas 0 le package
    ROLLBACK;
END CREER_MAIL;


PROCEDURE P_SEND_ALL_MAIL_JOB (i_type_mail IN NUMBER)is
  -- MUR M0005764 ajout idtexte 33 - Accusé de reception demande affiliation  -  pour envoi du mail au fil de l'eau
  -- ABO M0005769 ajout idtexte 31 - mail hebdo pour RH récapitulatif
  -- PBO M0006241 Email manuel texte 34 à envoyer le lendemain
  CURSOR c_liste_mails IS
  SELECT  numenvoimail FROM envoi_mail
    WHERE type_mail = i_type_mail
    AND nvl(etat,0) = 0 -- on prend les mails a envoyer
    AND datemis IS NULL -- double sécurité, on ne prend que les mail n'ayant pas de date d'émission.
    AND(  (i_type_mail = 2 AND NVL(IDTEXTE,0)!=34)         -- mail manuel différent de texte 34 - ajout nvl sur idtexte M0006301
	  -- AND(  i_type_mail = 2-- mail manuel
      OR( i_type_mail = 2 AND IDTEXTE=34 AND TRUNC(date_creation)=TRUNC(SYSDATE-1)) -- Email manuel texte 34 de la veille
       OR(
       ((i_type_mail = 1 AND TRUNC(date_creation)=TRUNC(SYSDATE-1)) --mail unitaire auto généré au fil de l'eau la veille
        OR  ( i_type_mail = 3
          AND (TRUNC(date_creation)=TRUNC(SYSDATE) OR
              (NUMENVOI_ORIGINE IS NOT NULL AND TRUNC(date_creation)=TRUNC(SYSDATE-1) )
              ) -- prise en compte des email régénré de type masse
            )
          )
        AND idtexte in (select id_texte from mail_texte where actif = 1)  -- blocage des autre envoi de mail ( pris en compte uniquement pour les mails auto )
       )
     )
  UNION
    SELECT numenvoimail FROM envoi_mail   --EVO EXTRANET 2018 on envoi les accusés de reception Corbeille (type 3) en même temps que les mails manuels
      WHERE type_mail = 3
      AND  i_type_mail= 2
      and  idtexte in (29 , 33)
      AND nvl(etat,0) = 0 -- on prend les mails a envoyer
      AND datemis IS NULL
     ;

  mails_in_error ty_mail_in_error;
  nb_msg_err NUMBER(5) :=0;
  nb_msg_err_copy NUMBER(5) :=0;
  nb_msg_tot NUMBER(5) :=0;
  date_session Date := sysdate;
  Rec_mail  c_liste_mails%ROWTYPE;
BEGIN


  mails_in_error  :=  ty_mail_in_error();
  -- selection des mails a envoyer
  OPEN c_liste_mails;
  LOOP
    FETCH c_liste_mails INTO Rec_mail;
    EXIT WHEN c_liste_mails%NOTFOUND;
        nb_msg_tot := nb_msg_tot+1;
         P_INS_journal(3,'Id  de mail a envoyer ' || Rec_mail.numenvoimail  );
         PK_MAIL.MAIL_JOB(Rec_mail.numenvoimail,nb_msg_err);
         if nb_msg_err > nb_msg_err_copy THEN
           nb_msg_err_copy := nb_msg_err;
           mails_in_error.extend;
           mails_in_error(nb_msg_err) := Rec_mail.numenvoimail;
         END IF;
    END LOOP;
    --fermeture du curseur
    IF c_liste_mails%ISOPEN THEN
           CLOSE c_liste_mails;
    END IF;

  P_INS_journal(3,'P_SEND_ALL_MAIL_JOB Nb mail en erreur =['||nb_msg_err||']');
  /*P_SEND_RAPPORT_ENVOI_MAIL(i_nb_mail_error=>nb_msg_err,
                            nb_total_msg =>nb_msg_tot,
                            i_date_session=>date_session,
                            i_mails_in_error => mails_in_error
                            );  */ --POUR TU EA PREV 12/03/2020
END P_SEND_ALL_MAIL_JOB;

PROCEDURE P_SEND_ALL_MAILING (i_type_mail IN NUMBER) IS

  CURSOR c_liste_mails IS
  SELECT  numenvoimail FROM envoi_mail
    WHERE type_mail = i_type_mail
    AND nvl(etat,0) = 0 -- on prend les mails a envoyer
    AND datemis IS NULL ;-- double sécurité, on ne prend que les mail n'ayant pas de date d'émission.

  mails_in_error ty_mail_in_error;
  nb_msg_err NUMBER(5) :=0;
  nb_msg_err_copy NUMBER(5) :=0;
  nb_msg_tot NUMBER(5) :=0;
  date_session Date := sysdate;
  Rec_mail  c_liste_mails%ROWTYPE;
  loc_heure NUMBER;
  loc_min   NUMBER;

BEGIN

  mails_in_error  :=  ty_mail_in_error();
  -- selection des mails a envoyer
  FOR Rec_mail IN c_liste_mails LOOP
    loc_heure:= to_char(sysdate, 'hh24');
    loc_min  :=  to_char(sysdate, 'mi') ;
    IF loc_heure >=23 AND loc_min>0 THEN
      EXIT;--dernier traitement à 23h00
    END IF;
    nb_msg_tot := nb_msg_tot+1;
    --P_INS_journal(3,'Id  de mail a envoyer ' || Rec_mail.numenvoimail  );
    --envoi du mail
    PK_MAIL.MAIL_JOB(Rec_mail.numenvoimail,nb_msg_err);
    --gestion des erreurs
    IF nb_msg_err > nb_msg_err_copy THEN
      nb_msg_err_copy := nb_msg_err;
      mails_in_error.extend;
      mails_in_error(nb_msg_err) := Rec_mail.numenvoimail;
    END IF;
  END LOOP;

END P_SEND_ALL_MAILING;

PROCEDURE P_SEND_RAPPORT_ENVOI_MAIL(i_nb_mail_error NUMBER, nb_total_msg number, i_date_session DATE, i_mails_in_error ty_mail_in_error)
IS
  loc_envoi envoi_mail%ROWTYPE;
  l_ERROR   VARCHAR2(200);
  text  CLOB;
  list_email varchar(4000) :='';
  list_email_unit varchar(1000) :='';
  l_nom_machine  param_machine.nom_machine%type;
  i number :=1;
BEGIN

  IF i_nb_mail_error > 0 THEN

    SELECT 1, 1, compte_mail
    INTO loc_envoi.NUMINDIV_DEST, loc_envoi.NUMBENE, loc_envoi.destinataire
    FROM param_machine
    WHERE id_machine= 'SERVEUR_MAIL';

    SELECT nom_machine into l_nom_machine
    FROM param_machine
    WHERE ID_MACHINE = 'SERVEUR_BDD';

    WHILE i <= i_mails_in_error.count LOOP
    -- DBMS_OUTPUT.PUT_LINE(i_mails_in_error(i));
      SELECT 'Numéro de l''email : '|| numenvoimail ||', Destinataire : '|| Numindiv_dest || ', ' ||'Bénéficiaire : '||numbene || ', Créé le : '|| d2e(date_creation)
      INTO  list_email_unit
      FROM envoi_mail
      WHERE numenvoimail = i_mails_in_error(i) ;
      list_email := list_email ||list_email_unit||CHR(10)||CHR(13);
      i := i + 1;
    END LOOP;

    loc_envoi.sujet :='[Rapport_ARTHUS] Rapport d''envoi de mail du '||i_date_session || ' via le serveur '||l_nom_machine;
    loc_envoi.corps := 'Nombre total de mail dans la file d''envoi = '||nb_total_msg||
    CHR(10)||CHR(13)||'Nombre de mail en erreur = '||i_nb_mail_error||'.'||CHR(10)||CHR(13)||
    'Liste des mails en erreur:'||CHR(10)||CHR(13)||list_email ;
    GET_HTML_VARCHAR_FROM_FS('MAILS_IN', 'template_mail_rapport.html', text);
    PK_MAIL.transcode_template( template_mail=>text,
                                corps_msg =>loc_envoi.corps,
                                numindiv=>'',
                                numbene=>'',
                                sujet_msg =>loc_envoi.sujet);
    SEND_EMAIL(
    P_RECIPIENT     =>'affiliation@gerep.fr',--loc_envoi.destinataire ,
    P_CC            => null,
    P_BCC           => null, -- MUR M0005618  --'Support@arthus-progiciels.com',
    P_SUBJECT       => '[Rapport_ARTHUS] Rapport d''envoi de mail du '||e2d(i_date_session),
    P_BODY          => text,
    P_NUMUTIL       => 8,
    P_SENDER        => loc_envoi.destinataire ,
    p_numindiv_dest => loc_envoi.numindiv_dest,
    P_ERROR        => l_ERROR);

  END IF;
   EXCEPTION
      WHEN  OTHERS THEN
        P_INS_journal(1,sqlerrm );
END P_SEND_RAPPORT_ENVOI_MAIL;

PROCEDURE MAIL_JOB (i_job IN VARCHAR2, nb_mess_erreur  in out NUMBER) is

  loc_envoi           envoi_mail%ROWTYPE;
   loc_type_interloc number;
  po_err_msg          varchar2(1000);
  loc_idtexte         envoi_mail.idtexte%TYPE;
  loc_lib_nom         param_texte.lib_nom%TYPE;
  loc_type_mail       ENVOI_MAIL.TYPE_MAIL%TYPE;
  loc_corps_clob       CLOB;
  text CLOB:='';
  logo_clob_64 CLOB:='';
  l_templatename VARCHAR2(100);
  l_adresse_envoyeur VARCHAR2(100);


  BEGIN
  P_INS_journal(1,'Envoi du mail['||i_job||']');
  /* Le numenvoimail doit etre obligatoirement egal au numero du job */
    BEGIN
      SELECT * INTO  loc_envoi
      FROM   envoi_mail
      WHERE numenvoimail = i_job;
    EXCEPTION -- Gestion des exceptions: PBO ARTGEREP-439
      WHEN no_data_found THEN
        P_INS_journal(1,'MAIL_JOB erreur: i_job inconnu');
        RETURN;
      WHEN OTHERS THEN
        P_INS_journal(1,'MAIL_JOB erreur: '||SQLERRM);
        RETURN;
    END;

    -- récuperation du message paramétré dans mail_texte lorsque l'email est automatique
    IF loc_envoi.type_mail  IN (1,3) AND loc_envoi.sujet IS NULL THEN
      BEGIN
        SELECT corps_msg, sujet_msg, template_mail -- PBO M0006130 ajout du template_mail
        INTO loc_corps_clob,loc_envoi.sujet, loc_envoi.template_mail  -- PBO M0006130 ajout du template_mail
        FROM mail_texte
        WHERE id_texte = loc_envoi.idtexte;

	   -- misea jour de l'objet(sujet) du mail avec le sujet  de MAIL_TEXT
       UPDATE envoi_mail SET sujet = loc_envoi.sujet , corps = loc_corps_clob, template_mail = loc_envoi.template_mail  -- PBO M0006130 ajout du template_mail
       WHERE numenvoimail = i_job;

      EXCEPTION
        WHEN no_data_found THEN
          loc_corps_clob := loc_envoi.corps;
      END;
    ELSE
      loc_corps_clob := loc_envoi.corps;
    END IF;

    --recherche du template mail paramétré, 1 modèle par défaut
    IF loc_envoi.template_mail  = 3 -- PBO M0006130 ajout d'un template html dedie a l'Email de bienvenue
	    AND loc_envoi.etendue = 2 THEN     -- PBO M0006130 valide l'etendue 2
      loc_envoi.template_mail  := 3 ;--conserver au cas pour éviter les TNR
    ELSIF loc_envoi.template_mail IS NULL AND loc_envoi.etendue in (2,7,9,28,6,13) THEN  -- ajout du template dynamique selon la marque de contrat
      loc_envoi.template_mail :=6;
      --l_templatename :=trim('template_mail_assure'||F_MARQUE_template( loc_envoi.numindiv_dest))||'.html';
    END IF;

    BEGIN
      SELECT libelle  INTO l_templatename
      FROM LIBELLE
      WHERE mnemo = 'TEMP_MAIL'
      AND code =  NVL(loc_envoi.template_mail,1);
    EXCEPTION
      WHEN OTHERS THEN  l_templatename:= 'template_mail_defaut.html';
    END;
    l_templatename := l_templatename||TRIM(F_MARQUE_template( loc_envoi.numindiv_dest))||'.html';


    -- M0006912 - Iris Radiation
    --  BCO :pour faire plus propre il faudrait ajouter une colonne dans MAIL_TEXTE qui identifie les modèles de mail au format HTML pur
    --       qui n'ont pas besoin de transco
    IF loc_envoi.idtexte IN (47,48,49,50,51) THEN
      NULL;
    ELSE
      /* remplacement des caracteres speciaux  au format HTML */
      loc_corps_clob := replace(loc_corps_clob, '"', '&' || 'quot;');
    END IF;

    DBMS_LOB.createtemporary(text, true);
    text:='';
    -- Build the start of the HTML document, i
    --recupération de l'entete html du message
    GET_HTML_VARCHAR_FROM_FS('MAILS_IN', l_templatename, text);

    PK_MAIL.transcode_template( template_mail=>text,
                                corps_msg =>loc_corps_clob,
                                numindiv=>loc_envoi.numindiv_dest,
                                numbene=>loc_envoi.numbene,
                                sujet_msg =>loc_envoi.sujet);

    --récuperation de l'adresse de l'expéditeur en fonction du domaine fonctionnel
    BEGIN
      IF loc_envoi.type_mail IN (1,3,5)THEN       -- les mail automatiques parte avec l'adresse toutes opération.
        SELECT NVL(f_coordonne_contact(interlocuteur,4,2),f_coordonne_contact(interlocuteur,4,1))
        INTO l_adresse_envoyeur
        FROM interlocuteur where NUMINDIV=1
        AND OPE_CRRR = 0;
      ELSE                                   -- les mails manuels dépendent du contexte
       SELECT NVL(f_coordonne_contact(interlocuteur,4,2),f_coordonne_contact(interlocuteur,4,1))
        INTO l_adresse_envoyeur
        from interlocuteur where NUMINDIV=1
        and OPE_CRRR =decode(loc_envoi.etendue,  -- voir STD pour les types courrier
                              8,1,
                              7,2,
                              1,7,
                              2,4,
                              9,4,
                              13,4,
                              0);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN  --si pas d'interlocuteur pour l'étendue, prendre l'interlocuteur par default
      SELECT NVL(f_coordonne_contact(interlocuteur,4,2),f_coordonne_contact(interlocuteur,4,1))
            INTO l_adresse_envoyeur
            from interlocuteur where NUMINDIV=1
            and OPE_CRRR = 0;
    END;

    --récupération de l'adresse email du destinataire
    IF loc_envoi.destinataire IS NULL THEN
      SELECT type_interlocuteur
      INTO loc_type_interloc
      FROM mail_texte
      WHERE id_texte =  loc_envoi.idtexte;

      --mail pro M6649 mail 29 multi contexte assuré / RH prise en compte du template
      IF NVL(loc_type_interloc,0) =1 OR (loc_type_interloc=0 AND loc_envoi.template_mail  in (2,5))  THEN
        loc_envoi.destinataire:= f_coordonne_contact(loc_envoi.numindiv_dest,4,1);
      ELSE
        loc_envoi.destinataire:= NVL(f_coordonne_contact(loc_envoi.numindiv_dest,4,2),f_coordonne_contact(loc_envoi.numindiv_dest,4,1))  ;
      END IF ;
    END IF;

    IF loc_envoi.destinataire IS NULL THEN
      po_err_msg:='E-mail du destinataire non renseigné';
    ELSE
      SEND_EMAIL
        ( P_RECIPIENT => loc_envoi.destinataire,
          P_CC => loc_envoi.cc,
          P_BCC => loc_envoi.cci,
          P_SUBJECT => loc_envoi.sujet,
          P_BODY => text,
          P_NUMUTIL => loc_envoi.numutil,
          P_ATTACHMENT1 => loc_envoi.pc1,
          P_ATTACHMENT2 => loc_envoi.pc2,
          P_ATTACHMENT3 => loc_envoi.pc3,
          P_ATTACHMENT4 => loc_envoi.pc4,
          P_SENDER => l_adresse_envoyeur,
          p_numindiv_dest => loc_envoi.numindiv_dest,
          p_template      => loc_envoi.template_mail,
          P_ERROR => po_err_msg);
    END IF;

    IF (po_err_msg ='' OR po_err_msg is null) THEN
      UPDATE ENVOI_MAIL e SET e.ETAT = 1, datemis=sysdate
      WHERE e.NUMENVOIMAIL = i_job;  --on passe mail a envoyé
    ELSE
      UPDATE ENVOI_MAIL e SET e.ETAT = 2, datemis=sysdate, mess_erreur =   po_err_msg
      WHERE e.NUMENVOIMAIL = i_job;  --on passe mail en erreur
      nb_mess_erreur :=nb_mess_erreur+1;
      --P_INS_journal(1,'NUMENVOI DU MAIL=['||i_job||']'||po_err_msg);
    END IF;
    COMMIT;

END MAIL_JOB;

PROCEDURE P_ORDRE_PC (pc1 IN OUT VARCHAR2, pc2 IN OUT VARCHAR2, pc3 IN OUT VARCHAR2, pc4 IN OUT VARCHAR2) is

BEGIN

  FOR i in 1..3 LOOP
    IF pc1 IS NULL THEN
      pc1 := pc2;
      pc2 := NULL;
    END IF;
    IF pc2 IS NULL THEN
      pc2 := pc3;
      pc3 := NULL;
    END IF;
    IF pc3 IS NULL THEN
      pc3 := pc4;
      pc4 := NULL;
    END IF;
  END LOOP;

END P_ORDRE_PC;


FUNCTION GET_ADDRESS(addr_list IN OUT VARCHAR2) RETURN VARCHAR2 IS
  addr VARCHAR2(256);
  i pls_integer;

  FUNCTION LOOKUP_UNQUOTED_CHAR (str IN VARCHAR2,chrs IN VARCHAR2) RETURN pls_integer AS
    c VARCHAR2(5);
    i pls_integer;
    len pls_integer;
    inside_quote BOOLEAN;

  BEGIN
    inside_quote := false;
    i := 1;
    len := length(str);

    WHILE (i <= len) LOOP
      c := substr(str, i, 1);
      IF (inside_quote) THEN
        IF (c = '"') THEN
          inside_quote := false;
        ELSIF (c = '\') THEN --'
          i := i + 1; -- Skip the quote character
        END IF;
      END IF;

      IF (c = '"') THEN
        inside_quote := true;
      END IF;

      IF (instr(chrs, c) >= 1) THEN
        RETURN i;
      END IF;

      i := i + 1;
    END LOOP;
    RETURN 0;
  END LOOKUP_UNQUOTED_CHAR;

  BEGIN
    addr_list := ltrim(addr_list);
    i := lookup_unquoted_char(addr_list, ',;');
    IF (i >= 1) THEN
      addr := substr(addr_list, 1, i - 1);
      addr_list := substr(addr_list, i + 1);
    ELSE
      addr := addr_list;
      addr_list := '';
    END IF;

    i := lookup_unquoted_char(addr, '<');
    IF (i >= 1) THEN
      addr := substr(addr, i + 1);
      i := instr(addr, '>');
      IF (i >= 1) THEN
        addr := substr(addr, 1, i - 1);
      END IF;
    END IF;

  RETURN addr;

END GET_ADDRESS;

PROCEDURE WRITE_MIME_HEADER (conn IN OUT NOCOPY utl_smtp.connection,name IN VARCHAR2,value IN VARCHAR2) IS
  BEGIN
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw(name || ': ' || value || utl_tcp.CRLF));
END WRITE_MIME_HEADER;

PROCEDURE WRITE_BOUNDARY(conn IN OUT NOCOPY utl_smtp.connection,last IN BOOLEAN DEFAULT FALSE) AS
  BOUNDARY CONSTANT VARCHAR2(256) := '__7D81B75CCC90D2974F7A1CBD__';
  FIRST_BOUNDARY CONSTANT VARCHAR2(256) := '--' || BOUNDARY || utl_tcp.CRLF;
  LAST_BOUNDARY CONSTANT VARCHAR2(256) := '--' || BOUNDARY || '--' || utl_tcp.CRLF;

  BEGIN
    IF (last) THEN
      utl_smtp.write_data(conn, LAST_BOUNDARY);
    ELSE
      utl_smtp.write_data(conn, FIRST_BOUNDARY);
    END IF;
END WRITE_BOUNDARY;

PROCEDURE MAIL(i_smtp IN param_machine%ROWTYPE,sender IN VARCHAR2,recipients IN VARCHAR2,cc IN VARCHAR2 default null,bcc IN VARCHAR2 default null,subject IN VARCHAR2,message IN VARCHAR2) IS
  conn utl_smtp.connection;
  BEGIN
    conn := begin_mail(i_smtp,sender, recipients, cc, bcc, subject);
    write_text(conn, message);
    end_mail(conn);
END MAIL;

FUNCTION BEGIN_MAIL(i_smtp IN param_machine%ROWTYPE,sender IN VARCHAR2,recipients IN VARCHAR2,cc IN VARCHAR2 default null,bcc IN VARCHAR2 default null,subject IN VARCHAR2,mime_type IN VARCHAR2 DEFAULT 'text/plain',priority IN PLS_INTEGER DEFAULT NULL)
RETURN utl_smtp.connection IS
  conn utl_smtp.connection;
  BEGIN
    conn := begin_session (i_smtp);
    begin_mail_in_session(conn, sender, recipients, cc, bcc, subject, mime_type,priority);
  RETURN conn;
END BEGIN_MAIL;

PROCEDURE WRITE_TEXT(conn IN OUT NOCOPY utl_smtp.connection,message IN VARCHAR2) IS
  BEGIN
    utl_smtp.write_data(conn, message);
END WRITE_TEXT;

PROCEDURE WRITE_MB_TEXT(conn IN OUT NOCOPY utl_smtp.connection,message IN VARCHAR2) IS
  BEGIN
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw(message));
END WRITE_MB_TEXT;

PROCEDURE write_raw(conn IN OUT NOCOPY utl_smtp.connection,message IN RAW) IS
  BEGIN
    utl_smtp.write_raw_data(conn, message);
END;

PROCEDURE ATTACH_TEXT(conn IN OUT NOCOPY utl_smtp.connection,data IN VARCHAR2,mime_type IN VARCHAR2 DEFAULT 'text/plain',inline IN BOOLEAN DEFAULT TRUE,filename IN VARCHAR2 DEFAULT NULL,last IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    begin_attachment(conn, mime_type, inline, filename);
    write_text(conn, data);
    end_attachment(conn, last);
END ATTACH_TEXT;

PROCEDURE ATTACH_MB_TEXT(conn IN OUT NOCOPY utl_smtp.connection,data IN VARCHAR2,mime_type IN VARCHAR2 DEFAULT 'text/plain',inline IN BOOLEAN DEFAULT TRUE,filename IN VARCHAR2 DEFAULT NULL,last IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    begin_attachment(conn, mime_type, inline, filename);
    utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw(data));
    end_attachment(conn, last);
END ATTACH_MB_TEXT;

PROCEDURE ATTACH_BASE64(conn IN OUT NOCOPY utl_smtp.connection,data IN RAW,mime_type IN VARCHAR2 DEFAULT 'application/octet',inline IN BOOLEAN DEFAULT TRUE,filename IN VARCHAR2 DEFAULT NULL,last IN BOOLEAN DEFAULT FALSE) IS
  i PLS_INTEGER;
  len PLS_INTEGER;
  MAX_BASE64_LINE_WIDTH CONSTANT PLS_INTEGER := 76 / 4 * 3; -- do not change this line.
  BEGIN
    begin_attachment(conn, mime_type, inline, filename, 'base64');
    i := 1;
    len := utl_raw.length(data);
    WHILE (i < len) LOOP
      IF (i + MAX_BASE64_LINE_WIDTH < len) THEN
        utl_smtp.write_raw_data(conn,utl_encode.base64_encode(utl_raw.substr(data, i,MAX_BASE64_LINE_WIDTH)));
      ELSE
        utl_smtp.write_raw_data(conn,utl_encode.base64_encode(utl_raw.substr(data, i)));
      END IF;
      utl_smtp.write_data(conn, utl_tcp.CRLF);
      i := i + MAX_BASE64_LINE_WIDTH;
    END LOOP;
      end_attachment(conn, last);
END ATTACH_BASE64;


PROCEDURE ATTACH_IMAGE(conn IN OUT NOCOPY utl_smtp.connection, typeimage IN VARCHAR2 DEFAULT 'jpg',inline IN BOOLEAN DEFAULT TRUE,filename IN VARCHAR2 DEFAULT NULL,last IN BOOLEAN DEFAULT FALSE) IS
  i PLS_INTEGER;
  len PLS_INTEGER;
  image clob  ;
  l_step  PLS_INTEGER := 12000;
  BEGIN
    begin_attachment(conn, 'image/'||typeimage, true, filename, 'base64');
    get_enc_img_from_fs ('MAILS_IN', filename, image);
    FOR i IN 0 .. TRUNC((DBMS_LOB.getlength(image) - 1 )/l_step) LOOP
      UTL_SMTP.write_data(conn, DBMS_LOB.substr(image, l_step, i * l_step + 1));
    END LOOP;
    --utl_smtp.write_data(conn,image);
    utl_smtp.write_data(conn, utl_tcp.CRLF);
    end_attachment(conn, last);
END ATTACH_IMAGE;

PROCEDURE BEGIN_ATTACHMENT (conn IN OUT NOCOPY utl_smtp.connection,mime_type IN VARCHAR2 DEFAULT 'text/plain',
  inline IN BOOLEAN DEFAULT TRUE,filename IN VARCHAR2 DEFAULT NULL,transfer_enc IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    write_boundary(conn);
    write_mime_header(conn, 'Content-Type', mime_type);
    IF (filename IS NOT NULL) THEN
      IF (inline) THEN
        write_mime_header(conn, 'Content-Disposition','inline; filename="'||filename||'"');
      ELSE
        write_mime_header(conn, 'Content-Disposition','attachment; filename="'||filename||'"');
      END IF;
        UTL_SMTP.write_data (conn, 'Content-ID' || ': ' || '<'||filename||'>' || UTL_TCP.CRLF);
    END IF;
    IF (transfer_enc IS NOT NULL) THEN
      write_mime_header(conn, 'Content-Transfer-Encoding', transfer_enc);
    END IF;
    utl_smtp.write_data(conn, utl_tcp.CRLF);
END BEGIN_ATTACHMENT;

PROCEDURE END_ATTACHMENT(conn IN OUT NOCOPY utl_smtp.connection,last IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    utl_smtp.write_data(conn, utl_tcp.CRLF);
    IF (last) THEN
      write_boundary(conn, last);
    END IF;
END END_ATTACHMENT;

PROCEDURE end_mail(conn IN OUT NOCOPY utl_smtp.connection) IS
  BEGIN
    end_mail_in_session(conn);
    end_session(conn);
END;

FUNCTION BEGIN_SESSION (i_smtp param_machine%ROWTYPE)  RETURN utl_smtp.connection IS
  conn utl_smtp.connection;
  BEGIN
    --P_INS_journal(1,'smtp_host : ' || smtp_host  );
    --P_INS_journal(1,'smtp_port : ' || smtp_port  );
    --P_INS_journal(1,'PK_MAIL_GLOBAL.smtp_domain : ' || smtp_domain  );
    conn := utl_smtp.open_connection(i_smtp.nom_machine, i_smtp.port_machine);
    -- PK_MAIL_GLOBAL.init_map;
    utl_smtp.helo(conn, i_smtp.domaine);
    ---  TEST ENVOI EN RECETTE CAT, VERS DU GMAIL ou autre---
    /*utl_smtp.command(conn, 'AUTH LOGIN');
    utl_smtp.command(conn, encode(utl_raw.cast_to_raw(v_compte_mail)));
    utl_smtp.command(conn, encode(utl_raw.cast_to_raw(v_password)));*/
     --------------------------------------------------------------
  RETURN conn;
  EXCEPTION
      WHEN  OTHERS THEN
        P_INS_journal(1,sqlerrm );
END BEGIN_SESSION;

PROCEDURE BEGIN_MAIL_IN_SESSION ( conn IN OUT NOCOPY utl_smtp.connection,
                                  sender IN VARCHAR2,
                                  recipients IN VARCHAR2,
                                  cc IN VARCHAR2 default null,
                                  bcc IN VARCHAR2 default null,
                                  subject IN VARCHAR2,
                                  mime_type IN VARCHAR2 DEFAULT 'text/plain',
                                  priority IN PLS_INTEGER DEFAULT NULL) IS
  my_recipients VARCHAR2(32767) := recipients;
  my_sender VARCHAR2(32767) := sender;
  my_cc varchar2(32767) := cc;
  my_bcc varchar2(32767) := bcc;
  MAILER_ID CONSTANT VARCHAR2(256) := 'Mailer by Oracle UTL_SMTP';

  BEGIN

    utl_smtp.mail(conn, get_address(my_sender));
    WHILE (my_recipients IS NOT NULL) LOOP
      utl_smtp.rcpt(conn, get_address(my_recipients));
    END LOOP;
    WHILE (my_cc IS NOT NULL) LOOP
      utl_smtp.rcpt(conn, get_address(my_cc));
    END LOOP;
    WHILE (my_bcc IS NOT NULL) LOOP
      utl_smtp.rcpt(conn, get_address(my_bcc));
    END LOOP;
    utl_smtp.open_data(conn);
    write_mime_header(conn, 'From', sender);
    write_mime_header(conn, 'To', recipients);
    write_mime_header(conn, 'CC', cc);
    write_mime_header(conn, 'BCC', bcc);
    --write_mime_header(conn, 'BCC', 'testcl@cat-amania.com');  --mise en copie automatique pour la recette CLI
    write_mime_header(conn, 'Subject', subject);
    write_mime_header(conn, 'Content-Type', mime_type);
    write_mime_header(conn, 'X-Mailer', MAILER_ID);
    IF (priority IS NOT NULL) THEN
      write_mime_header(conn, 'X-Priority', priority);
    END IF;
      utl_smtp.write_data(conn, utl_tcp.CRLF);
    IF (mime_type LIKE 'multipart/mixed%') THEN
      write_text(conn, 'This is a multi-part message in MIME format.' ||utl_tcp.crlf);
    END IF;
END BEGIN_MAIL_IN_SESSION;

PROCEDURE END_MAIL_IN_SESSION(conn IN OUT NOCOPY utl_smtp.connection) IS
BEGIN
  utl_smtp.close_data(conn);
END END_MAIL_IN_SESSION;

PROCEDURE END_SESSION(conn IN OUT NOCOPY utl_smtp.connection) IS
BEGIN
  utl_smtp.quit(conn);
END END_SESSION;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_journal                                             */
/* Type         :  Privee                                                    */
/* Description  :  Insertion dans journal_adm                                */
/* Entree       :  P_niv, P_msg, P_msg                                       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null)
IS

BEGIN
  IF g_niv_msg IS NULL THEN
    BEGIN
      SELECT decode(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
        INTO g_niv_msg
        FROM PARAM_BATCH
       WHERE NUMBATCH = g_nom_traitement;
    EXCEPTION
      WHEN OTHERS THEN
        g_niv_msg := 1;
    END;
  END IF;

  IF g_niv_msg >= P_niv THEN
    g_idligne := g_idligne +1;
    PK_trace.P_INS_journal_adm (
        I_nom_traitement => g_nom_traitement,
        I_session  => NVL(g_session, sid),
        I_niv_msg  => P_niv,
        I_msg_adm  => substr(P_msg||' '||P_msg2,1,132),
        I_idligne  => g_idligne);
  END IF;

END P_INS_journal;

--------------------------------------------------------------------------------------------------------
------------------------------------------- Main email procedure ---------------------------------------
--------------------------------------------------------------------------------------------------------

PROCEDURE SEND_EMAIL(
  P_RECIPIENT     IN VARCHAR2,
  P_CC            IN VARCHAR2,
  P_BCC           IN VARCHAR2,
  P_SUBJECT       IN VARCHAR2,
  P_BODY          IN CLOB,
  P_NUMUTIL       IN NUMBER,
  P_ATTACHMENT1   IN VARCHAR2 default null,
  P_ATTACHMENT2   IN VARCHAR2 default null,
  P_ATTACHMENT3   IN VARCHAR2 default null,
  P_ATTACHMENT4   IN VARCHAR2 default null,
  P_SENDER        IN VARCHAR2,
  P_numindiv_dest IN individu.numindiv%type,
  p_template      IN NUMBER DEFAULT 0,
  P_ERROR         OUT VARCHAR2) is

  fil BFILE;
  file_len PLS_INTEGER;
  MAX_LINE_WIDTH PLS_INTEGER := 54;
  buf RAW(2100);
  amt BINARY_INTEGER := 672 * 3; /* ensures proper format; 2016 */
  pos PLS_INTEGER := 1; /* pointer for each piece */
  filepos PLS_INTEGER := 1; /* pointer for the file */
  t_file1 VARCHAR2(100) := P_ATTACHMENT1; /* binary file attachment */
  t_file2 VARCHAR2(100) := P_ATTACHMENT2; /* binary file attachment */
  t_file3 VARCHAR2(100) := P_ATTACHMENT3; /* binary file attachment */
  t_file4 VARCHAR2(100) := P_ATTACHMENT4; /* binary file attachment */
  v_file_name VARCHAR2(100) := null; /* ascii file attachment */
  v_file_handle UTL_FILE.FILE_TYPE;
  loc_smtp param_machine%ROWTYPE;
  v_corps CLOB := P_BODY;
  v_subject VARCHAR2(1000) := P_SUBJECT;
  v_line VARCHAR2(2000);
  v_rline RAW(1000);
  conn UTL_SMTP.CONNECTION;
  mesg VARCHAR2(32767);
  mesg_len NUMBER;
  crlf VARCHAR2(2) := chr(13) || chr(10);
  data RAW(2100);
  chunks PLS_INTEGER;
  len PLS_INTEGER := 1;
  modulo PLS_INTEGER;
  pieces PLS_INTEGER;

  err_num NUMBER;
  err_msg VARCHAR2(100);
  --v_mime_type_bin varchar2(30) := 'application/pdf';
  --v_mime_type_bin varchar2(30) := 'application/doc';
  --v_mime_type_bin varchar2(30) := 'application/jpg';

  /* Use this mime type when multiple attachments of different types are sent. */
  v_mime_type_bin varchar2(30) := 'application/octet-stream';
  BOUNDARY CONSTANT VARCHAR2(256) := '__7D81B75CCC90D2974F7A1CBD__';
  MULTIPART_MIME_TYPE CONSTANT VARCHAR2(256) := 'multipart/related;type="multipart/alternative"; boundary="'||BOUNDARY || '"';

  -- working storage
  files tab_of_attachments;
  t_file_count number := 0;

  CURSOR c_images (i_mnemo libelle.mnemo%type, i_template NUMBER) IS
    SELECT libelle as filename, codapli as type
      FROM libelle
      WHERE mnemo = nvl(i_mnemo,'IMG_MAIL')
        AND code =i_template;
  rec_image     c_images%ROWTYPE;


  BEGIN
    /*remise en ordre des pieces jointe*/
    P_ORDRE_PC(t_file1, t_file2, t_file3, t_file4);
   -- PK_MAIL_GLOBAL.v_compte_mail:=P_SENDER;
    SELECT *
    INTO loc_smtp
    FROM param_machine
    WHERE srv_type='M';

    ------------------------------
    v_corps := replace(v_corps, 'à', '&' || 'agrave;');
    v_corps := replace(v_corps, 'è', '&' || 'egrave;');
    v_corps := replace(v_corps, 'é', '&' || 'eacute;');
    v_corps := replace(v_corps, 'ê', '&' || 'ecirc;');
    v_corps := replace(v_corps, 'ê', '&' || 'ecirc;');
    v_corps := replace(v_corps, 'ç', '&' || 'ccedil;');
    v_corps := replace(v_corps, 'â', '&' || 'acirc;');
    v_corps := replace(v_corps, 'î', '&' || 'icirc;');
    v_corps := replace(v_corps, 'ï', '&' || 'iuml;');
    v_corps := replace(v_corps, 'œ', '&' || 'oelig;');
    v_corps := replace(v_corps, 'ù', '&' || 'ugrave;');
    v_corps := replace(v_corps, 'û', '&' || 'ucirc;');
    v_corps := replace(v_corps, 'À', '&' || 'Agrave;');
    v_corps := replace(v_corps, 'Â', '&' || 'Acirc;');
    v_corps := replace(v_corps, 'É', '&' || 'Eacute;');
    v_corps := replace(v_corps, 'È', '&' || 'Egrave;');
    v_corps := replace(v_corps, 'Ê', '&' || 'Ecirc;');
    v_corps := replace(v_corps, 'Î', '&' || 'Icirc;');
    v_corps := replace(v_corps, 'Ï', '&' || 'Iuml;');
    v_corps := replace(v_corps, 'Œ', '&' || 'OElig;');
    v_corps := replace(v_corps, 'Ù', '&' || 'Ugrave;');
    v_corps := replace(v_corps, 'Û', '&' || 'Ucirc;');
    v_corps := replace(v_corps, 'Ç', '&' || 'Ccedil;');
    v_corps := replace(v_corps, 'ô', '&' || 'ocirc;');
    v_corps := replace(v_corps, 'Ô', '&' || 'Ocirc;');
    v_corps := replace(v_corps, 'Ô', '&' || 'Ocirc;');
    v_corps := replace(v_corps, 'Ô', '&' || 'Ocirc;');
    v_corps := replace(v_corps, '°', '&' || 'deg;');

    --ARGEREP-332
    --Les mails émis par Arthus étant de type "multipart" , le sujet du message doit utiliser la forme dite « encoded-word » de MIME (RFC 2047):
    --=?encodage?méthode?texte?=
    --Exemple avec la méthode "Q" Quoted-Printable
    --=?windows-1252?Q?Votre carte de Tiers-Payant est bient=F4t disponible !?=
    -- De plus :
    --  - la RFC 2047 indique que les lignes des champs du HEADER sont limitées à 76 caractères (géré pas la fonction MIMEHEADER_ENCODE)
    --  - la RFC 2822 précise que les champs multi-ligne doivent être préfixés par un ESPACE (non géré par la fonction MIMEHEADER_ENCODE)
    v_subject := UTL_ENCODE.MIMEHEADER_ENCODE(
        BUF => v_subject,
        encode_charset => 'we8mswin1252',
        ENCODING => UTL_ENCODE.QUOTED_PRINTABLE);
    v_subject := REPLACE(v_subject,'we8mswin1252','windows-1252') ;
    v_subject := REPLACE(v_subject, UTL_TCP.CRLF, UTL_TCP.CRLF || ' ') ;

    -- put the attachments into the pl/sql table
    IF t_file1 IS NOT NULL THEN
      files := tab_of_attachments(null);
      files(1).filename := t_file1;
      t_file_count := 1;
      IF t_file2 IS NOT NULL THEN
        files.extend(1);
        files(2).filename := t_file2;
        t_file_count := 2;
      END IF;
      IF t_file3 IS NOT NULL THEN
        files.extend(1);
        files(3).filename := t_file3;
        t_file_count := 3;
      END IF;
      IF t_file4 IS NOT NULL THEN
        files.extend(1);
        files(4).filename := t_file4;
        t_file_count := 4;
      END IF;
    ELSE
      t_file_count := 0;
    END IF;

    BEGIN
      conn := begin_mail( i_smtp => loc_smtp,
                          sender => P_SENDER,
                                  recipients => P_RECIPIENT,
                                  cc => P_CC,
                                  bcc => P_BCC,
                                  subject => v_SUBJECT,
                                  mime_type => MULTIPART_MIME_TYPE);
    END ;

    BEGIN
      attach_text(conn => conn,data => v_corps,mime_type => 'text/html');
    END attach_text;

    BEGIN
      OPEN c_images(trim('IMG_MAIL'||F_MARQUE_template(p_numindiv_dest)), p_template);
      LOOP
        FETCH c_images INTO rec_image;
        EXIT WHEN c_images%NOTFOUND;
        ATTACH_IMAGE(conn=> conn,  typeimage =>rec_image.type ,inline=> true ,filename => rec_image.filename ,last => false);
      END LOOP;
      IF c_images%ISOPEN THEN
         CLOSE c_images;
      END IF;
    END ATTACH_IMAGES;


    BEGIN
      -- check to see if there are any attachments (otherwise the loop will error!)
      IF t_file_count > 0 THEN
        -- loop through attachments
        FOR i in 1..files.COUNT LOOP
          begin_attachment(conn => conn, mime_type => v_mime_type_bin, inline => TRUE, filename => files(i).filename, transfer_enc => 'base64');

          BEGIN
            filepos := 1; --Insures we are pointing to beginning of file.
            amt := 672 * 3; --Insures amount is re-initialize for each file
            --v_directory_name
            fil := BFILENAME(loc_smtp.dir_tmp, files(i).filename);
            file_len := dbms_lob.getlength(fil);
            modulo := mod(file_len, amt);

            pieces := trunc(file_len / amt);

            IF (modulo <> 0) then
              pieces := pieces + 1;
            END IF;

            dbms_lob.fileopen(fil, dbms_lob.file_readonly);
            dbms_lob.read(fil, amt, filepos, buf);
            data := NULL;

            FOR i IN 1..pieces LOOP
              filepos := i * amt + 1;
              file_len := file_len - amt;
              data := utl_raw.concat(data, buf);
              chunks := trunc(utl_raw.length(data) / MAX_LINE_WIDTH);

              IF (i <> pieces) THEN
                chunks := chunks - 1;
              END IF;
              write_raw( conn => conn,
              message => utl_encode.base64_encode(data ) );
              data := NULL;

              IF (file_len < amt and file_len > 0) then
                amt := file_len;
              END IF;
              -- Insures we only read again if there is more data.
              --Commented and changed on 18-Apr-2008
              --if (file_len > amt) then
              --dbms_lob.read(fil, amt, filepos, buf);
              --end if;
              ---Changed code----------
              IF ( file_len=0) THEN
                 null;
              ELSE
                 dbms_lob.read(fil, amt, filepos, buf);
              END IF;
              -----------------------------
            END LOOP;
          END;
          CLOSEFILE(fil);


          end_attachment(conn => conn );

        END LOOP;
      END IF;

    END begin_attachment;


    end_mail(conn => conn);

    EXCEPTION
    WHEN no_data_found THEN
      --end_attachment( conn => conn );
      CLOSEFILE(fil);
      P_ERROR := 'Aucune données trouvées pour l''email, lors de l''envoi';
      P_INS_journal(3,'Probléme lors de l''envoi du mail =[' || P_ERROR||']');
    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SUBSTR(SQLERRM, 1, 100);
      P_ERROR := 'Err '||err_msg;
      P_INS_journal(3,P_ERROR);
      --dbms_output.put_line('Error number is ' || err_num);
      --dbms_output.put_line('Error message is ' || err_msg);
      --end_attachment( conn => conn );

      CLOSEFILE(fil);
END SEND_EMAIL;




--NASSU_AUTO : Création d'un nouvel assuré
--NASSU_MAN : Création d'un nouvel assuré
--NASSU_DSN : Création d'un nouvel assuré
--ADDR_AUTO : Modification de l'adresse automatiquement
--ADDR_MAN : Modification de l'adresse manuellement
--ADDR_DSN : Modification de l'adresse via la DSN
--MRIB_AUTO : Modification de l'adresse automatiquement
--MRIB_MAN : Modification de l'adresse manuellement
--MSS_AUTO : Modification du numéro de sécurité sociale, automatiquement
--MSS_MAN : Modification du numéro de sécurité sociale manuellement
--MRSS_AUTO : Modification du régime ou de la caisse, automatiquement
--MRSS_MAN : Modification du régime ou de la caisse, manuellement
--DEVIS_MAN : Validation d'un devis?
--NPEC_MAN : Prise en charge hospitalière
--DPADD_MAN : Demande piéce Pour Compléter une adhésion
--DOSS_MAN : Dossier Sante, Validation du dossier
--RESI_AUTO : Résiliation d'un contrat
--RESI_MAN : Résiliation d'un contrat
--RAD_MAN : Radiation d'un bénéficiaire
--RAD_AUTO : Radiation d'un bénéficiaire
--TELE_MAN : Piéce télétransmission
FUNCTION  CHECK_DROIT_ENVOI_MAIL(   i_entite IN VARCHAR2,
                                                                    i_numutil IN UTILISATEURS.NUMUTIL%TYPE)
RETURN BOOLEAN
IS
  l_isUserAuto PORTE_PARAM.NUMPORTE%TYPE := 0;
  suffix_entite VARCHAR2(10) :='_AUTO';
  o_is_ok_to_insert Number := 0;
BEGIN
        -- on determine si l'email vient d'un utilisateur de traitement automatique (EXTRANET)
        BEGIN
      SELECT NVL(MIN(numporte),0) INTO l_isuserauto
      FROM porte_param
      WHERE numutil = i_numutil;

        EXCEPTION
      WHEN OTHERS THEN l_isuserauto :=0;
        END;
        -- determine le suffix du code libelle
        BEGIN
            IF  l_isUserAuto >0 AND F_NOMUTIL(i_numutil)='DSN' THEN  -- si la modification vient de la DSN on regarde si la régle permet l'insertion de mail
                    suffix_entite:='_DSN';
            ELSIF  l_isUserAuto =0 THEN
                suffix_entite:='_MAN';
            END IF;

      SELECT sens INTO o_is_ok_to_insert
            FROM libelle_bis
            WHERE mnemo = 'RG_MAIL'
                AND CODE = i_entite||suffix_entite;

        EXCEPTION WHEN NO_DATA_FOUND THEN
            o_is_ok_to_insert:= 0;
        END;

  RETURN o_is_ok_to_insert = 1;

END CHECK_DROIT_ENVOI_MAIL;


FUNCTION  CHECK_DEMAT_INDIV(p_numindiv IN individu.numindiv%TYPE)
RETURN NUMBER  -- 0 => pas de dematrialisation, 1=> dématerialisation ouverte
IS
l_is_demat_ok NUMBER(1):=0;
  BEGIN
    SELECT DISTINCT 1 INTO l_is_demat_ok
    FROM courrier_info
    WHERE numindiv = p_numindiv
      AND type_crrr=28
      AND moyen_info = 2;

      return  l_is_demat_ok;
    EXCEPTION
      WHEN OTHERS THEN
        return 0;
END CHECK_DEMAT_INDIV;

FUNCTION  CHECK_DEMAT_CLI(p_numindiv IN individu.numindiv%TYPE)
RETURN NUMBER  -- 0 => pas de dematrialisation, 1=> dématerialisation ouverte type_crrr = 55 pour société
IS
l_is_demat_ok NUMBER(1):=0;
  BEGIN
    SELECT DISTINCT 1 INTO l_is_demat_ok
    FROM courrier_info
    WHERE numindiv = p_numindiv
      AND type_crrr=55
      AND moyen_info = 2;

      return  l_is_demat_ok;
    EXCEPTION
      WHEN OTHERS THEN
        return 0;
END CHECK_DEMAT_CLI;

FUNCTION  CHECK_DEMAT_PREV(p_numindiv IN individu.numindiv%TYPE,p_numcli IN individu.numindiv%TYPE DEFAULT NULL)
RETURN NUMBER  -- 0 => pas de dematrialisation, 1=> mail pro et interlocuteur de type 9
IS
l_is_demat_ok NUMBER(1):=0;
  BEGIN
    SELECT DISTINCT 1 INTO l_is_demat_ok
    FROM interlocuteur
    WHERE numindiv = NVL(p_numcli,numindiv)
    AND interlocuteur = p_numindiv
    AND f_coordonne_contact(interlocuteur,4,1) IS NOT NULL
    AND valide='O'
    AND ope_crrr=9;

      RETURN  l_is_demat_ok;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
END CHECK_DEMAT_PREV;
-- Initialize the Base64 mapping
/*PROCEDURE INIT_MAP IS
BEGIN
  map(0) :='A'; map(1) :='B'; map(2) :='C'; map(3) :='D'; map(4) :='E';
  map(5) :='F'; map(6) :='G'; map(7) :='H'; map(8) :='I'; map(9):='J';
  map(10):='K'; map(11):='L'; map(12):='M'; map(13):='N'; map(14):='O';
  map(15):='P'; map(16):='Q'; map(17):='R'; map(18):='S'; map(19):='T';
  map(20):='U'; map(21):='V'; map(22):='W'; map(23):='X'; map(24):='Y';
  map(25):='Z'; map(26):='a'; map(27):='b'; map(28):='c'; map(29):='d';
  map(30):='e'; map(31):='f'; map(32):='g'; map(33):='h'; map(34):='i';
  map(35):='j'; map(36):='k'; map(37):='l'; map(38):='m'; map(39):='n';
  map(40):='o'; map(41):='p'; map(42):='q'; map(43):='r'; map(44):='s';
  map(45):='t'; map(46):='u'; map(47):='v'; map(48):='w'; map(49):='x';
  map(50):='y'; map(51):='z'; map(52):='0'; map(53):='1'; map(54):='2';
  map(55):='3'; map(56):='4'; map(57):='5'; map(58):='6'; map(59):='7';
  map(60):='8'; map(61):='9'; map(62):='+'; map(63):='/';
END INIT_MAP;*/

FUNCTION ENCODE(r IN RAW) RETURN VARCHAR2 IS
  i pls_integer;
  x pls_integer;
  y pls_integer;
  v VARCHAR2(32767);
    /* Declaration encodage*/
  TYPE vc2_table IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  map vc2_table;-- := pk_mail_global.map;


BEGIN
  map(0) :='A'; map(1) :='B'; map(2) :='C'; map(3) :='D'; map(4) :='E';
  map(5) :='F'; map(6) :='G'; map(7) :='H'; map(8) :='I'; map(9):='J';
  map(10):='K'; map(11):='L'; map(12):='M'; map(13):='N'; map(14):='O';
  map(15):='P'; map(16):='Q'; map(17):='R'; map(18):='S'; map(19):='T';
  map(20):='U'; map(21):='V'; map(22):='W'; map(23):='X'; map(24):='Y';
  map(25):='Z'; map(26):='a'; map(27):='b'; map(28):='c'; map(29):='d';
  map(30):='e'; map(31):='f'; map(32):='g'; map(33):='h'; map(34):='i';
  map(35):='j'; map(36):='k'; map(37):='l'; map(38):='m'; map(39):='n';
  map(40):='o'; map(41):='p'; map(42):='q'; map(43):='r'; map(44):='s';
  map(45):='t'; map(46):='u'; map(47):='v'; map(48):='w'; map(49):='x';
  map(50):='y'; map(51):='z'; map(52):='0'; map(53):='1'; map(54):='2';
  map(55):='3'; map(56):='4'; map(57):='5'; map(58):='6'; map(59):='7';
  map(60):='8'; map(61):='9'; map(62):='+'; map(63):='/';
  -- For every 3 bytes, split them into 4 6-bit units and map them to
  -- the Base64 characters
  i := 1;
  WHILE ( i + 2 <= utl_raw.length(r) ) LOOP
    x := to_number(utl_raw.substr(r, i, 1), '0X') * 65536 +
        to_number(utl_raw.substr(r, i + 1, 1), '0X') * 256 +
        to_number(utl_raw.substr(r, i + 2, 1), '0X');
    y := floor(x / 262144); v := v || map(y); x := x - y * 262144;
    y := floor(x / 4096);     v := v || map(y); x := x - y * 4096;
    y := floor(x / 64);     v := v || map(y); x := x - y * 64;
                           v := v || map(x);
    i := i + 3;
  END LOOP;

  -- Process the remaining bytes that has fewer than 3 bytes.
  IF ( utl_raw.length(r) - i = 0) THEN
    x := to_number(utl_raw.substr(r, i, 1), '0X');
    y := floor(x / 4);     v := v || map(y); x := x - y * 4;
    x := x * 16;            v := v || map(x);
    v := v || '==';
  ELSIF ( utl_raw.length(r) - i = 1) THEN
    x := to_number(utl_raw.substr(r, i, 1), '0X') * 256 +
    to_number(utl_raw.substr(r, i + 1, 1), '0X');
    y := floor(x / 1024);     v := v || map(y); x := x - y * 1024;
    y := floor(x / 16);     v := v || map(y); x := x - y * 16;
    x := x * 4;             v := v || map(x);
    v := v || '=';
  END IF;

  RETURN v;

END ENCODE;

PROCEDURE TRANSCODE_TEMPLATE (template_mail IN OUT CLOB, corps_msg IN CLOB, numindiv IN NUMBER, numbene IN NUMBER, sujet_msg IN VARCHAR2  )  iS
  corps clob := corps_msg;
  l_politesse varchar2(6):='';
  l_nom varchar2(100):='';
  l_numindiv number := numindiv;

  BEGIN
       BEGIN
          SELECT
            DECODE(sexe, 2,'Chère',1,'Cher','Chère' /* les sociétés n'ont pas de sexe*/)
           -- Nom avec civilité, mais sans le prénom. 999=> Pas de limite de taille sur la chaîne de caractères renvoyée (M0006626)
           ,REPLACE(pk_personne.f_nom(individu.numindiv,999),INITCAP(nvl(individu.prenom,' '))||' ','')
          INTO l_politesse
              ,l_nom
          FROM individu
          WHERE individu.numindiv = l_numindiv;
          EXCEPTION WHEN OTHERS THEN
             l_politesse:= 'Cher';
            /* dbms_output.put_line('une erreur c est produite'||sqlerrm);   */
       END;
       --  affichag des lien de connections uniquement si le mail ngénérer n'est pas concomittant a une demande de souscription
       IF pk_ws_web_maj_back.f_is_hors_bia(numindiv ) = 0 THEN
        template_mail:= replace(template_mail,'#DISPLAY_LIEN','hidden');
         ELSE
        template_mail:= replace(template_mail,'#DISPLAY_LIEN','');
       END IF;

      -- ATTENTION BCO Les lignes d'un mail SMTP sont limités à 1000 caractères entre 2 retours chariots
      -- sinon c'est le serveur SMTP qui coupe la ligne, et s'il le fait au milieu d'un mot HTML (href, style, ...) ça pète dans le client mail
      --  il faut donc laisser les <LF> (càd chr(10)) dans la commande suivante
      --  de plus <br/> est du xHTML (qui est obsolète), vive le HTML5 <br>
      --corps := replace(corps, chr(10), '' || '<br/>') ;
      corps := replace(corps, chr(10), chr(10) || '<br>') ;
      P_INS_journal(3,'Replace de numindiv '||to_char(numindiv));
      template_mail:= replace(template_mail,'#SUJET',sujet_msg);
      template_mail:= replace(template_mail,'#CORPS_MESSAGE',corps);
      template_mail:= replace(template_mail,'#POLITESSE',l_politesse);
      template_mail:= replace(template_mail,'#NOMDESTINATAIRE',l_nom);
      template_mail:= replace(template_mail,'#NUMINDIV',to_char(numindiv));
      template_mail:= replace(template_mail,'#NOMBENE',PK_PERSONNE.F_NOM(numbene));
END TRANSCODE_TEMPLATE;

PROCEDURE CLOSEFILE(fil IN OUT BFILE) IS
BEGIN
  dbms_lob.fileclose(fil);
  EXCEPTION WHEN OTHERS THEN NULL;
END CLOSEFILE;

/*============================================================================*/
/* Auteur       : CLI                                                         */
/* Création     : 27/04/2017                                                  */
/* Description  : Fonction permttant en fonction de la marque de renvoyer le  */
/*              : bon template                                                */
/*              : retourne le numéro d'un message                             */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

FUNCTION F_MARQUE_template(l_num_destinataire individu.numindiv%type) return VARCHAR2
 IS
   CURSOR c_contrats  IS
   select distinct cr.marque ,adc.idadhesion
   from adhesion a , adhe_cntrt adc, contrat c, contrat_ref cr
   where a.numindiv = l_num_destinataire
   and adc.idadhesion = a.idadhesion
   and  sysdate between adc.date_adhe and add_months(nvl(adc.date_fin_adhe, sysdate),9)     -- adhesion en cours ou a moins de 9 mois.
   and a.numgar = c.numgar
   and c.numgar_ref = cr.numgar_ref
   order by adc.idadhesion desc  ;

BEGIN

FOR R_contrat in c_contrats LOOP
  IF  R_contrat.marque in (2,3) AND F_CLIENT = 12 THEN    -- POUR WELCARE  uniquement
     return 'H';
  ELSE
     RETURN ' ';
  END IF;

  RETURN ' '; -- par defaut on prend le template normal
END LOOP;

  RETURN ' '; -- par defaut on prend le template normal
END F_MARQUE_template;
/*============================================================================*/
/* Auteur       : CLI                                                         */
/* Création     : 27/04/2017                                                  */
/* Description  : duplication d'un mail au vue de son renvoi                  */
/*              : retourne le numéro d'un message                             */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/
FUNCTION F_DUPLIQ_MAIL(I_NUMENVOIMAIL envoi_mail.numenvoimail%type) RETURN NUMBER IS
 loc_envoi  envoi_mail%rowtype;
BEGIN
   BEGIN
    SELECT *
    INTO loc_envoi
    FROM ENVOI_MAIL where numenvoimail = I_NUMENVOIMAIL
     AND NOT EXISTS ( SELECT 1 FROM ENVOI_MAIL
                        WHERE NUMENVOI_ORIGINE = I_NUMENVOIMAIL
                          AND ETAT = 0
                          AND trunc(DATE_CREATION) = trunc(SYSDATE)
                          AND  DATEMIS IS NULL
      );
    EXCEPTION WHEN NO_DATA_FOUND THEN
    -- Si une duplication existe et est non envoyé alors on renvois met a jour le MAIL.
         UPDATE envoi_mail
        SET
              destinataire =NVL(f_coordonne_contact(numindiv_dest,4,2),f_coordonne_contact(numindiv_dest,4,1)),
              etat = 0,
              datemis = null
        WHERE NUMENVOI_ORIGINE = I_NUMENVOIMAIL
          AND ETAT = 0
          AND trunc(DATE_CREATION) = trunc(SYSDATE)
          AND  DATEMIS IS NULL;
           COMMIT;
          RETURN 2290; -- Destinataire mis à jour
       END;

      /* mise a niveau des information */
      Loc_envoi.destinataire :=NVL(f_coordonne_contact(loc_envoi.numindiv_dest,4,2),f_coordonne_contact(loc_envoi.numindiv_dest,4,1)) ; --adresse perso puis pro par défaut
      loc_envoi.NUMUTIL:= F_NUMUTIL;
       loc_envoi.DATE_CREATION:=SYSDATE;
      loc_envoi.NUMENVOI_ORIGINE := nvl (loc_envoi.NUMENVOI_ORIGINE,I_NUMENVOIMAIL );     -- on garde le mail d'orgine si depulication de duplication
      loc_envoi.DATEMIS  := NULL;
      loc_envoi.ETAT    := 0;
      CREER_MAIL(loc_envoi) ;

      return 2291; -- Email dupliqué

END F_DUPLIQ_MAIL;

PROCEDURE P_CHARGE_MAIL_MASSE IS

BEGIN
  P_CHARGE_DCPT;
  IF F_CLIENT <>12 THEN   -- Wlecare n'as pas encore les autres mails
    P_CHARGE_PIECE;
    P_CHARGE_DCPT_PREV; --EA PREV LOT2
    P_CHARGE_CARTE_TP;
    P_CHARGE_ADH_INSTANCE;
    P_CHARGE_ADHESION_OPTION;
    P_CHARGE_ADHESION_VIGUEUR;
    PK_WS_WEB_MAJ_BACK.P_MAIL_INTERLOCUTEUR;
    P_CHARGE_RUM;
    P_CHARGE_VCOTIS;
    P_CHARGE_PB2B;
    P_CHARGE_RESIL;-- IRIS ENTRP radiation
    P_CHARGE_COT_INDIV(TRUNC(SYSDATE)-1);
  END IF;
  PK_MAIL.P_SEND_ALL_MAIL_JOB(3);
END;

/*============================================================================*/
/* Auteur       : ABO                                                         */
/* Création     : 27/04/2017                                                  */
/* Description  : Insertion des demandes de pièces dans la                    */
/*                table envoi_mail pour permettre ensuite l'envoi des mails   */
/*                aux assurés par un job                                      */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : PBO M0006252 ajout des adhésions dans le futur validées RH  */
/*                et Gerep                                                    */
/*============================================================================*/
PROCEDURE P_CHARGE_ADH_INSTANCE IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_mail_exist NUMBER:=0;

  CURSOR c_adh_instance IS
      SELECT   adc.idadhesion, adc.numadhe, adc.date_adhe, c.numgar  -- PBO M006252
         FROM ADHESION ad , adhe_cntrt adc, contrat c , histo_adhesion had,  gar_cntrt gcnt, courrier_info cour, formule f
          WHERE adc.idadhesion = ad.idadhesion
          AND had.idadhesion = ad.idadhesion
          AND cour.numindiv = adc.numadhe
          AND f.numfor = ad.numfor
          AND gcnt.NUMFOR = ad.NUMFOR
          AND c.numgar = adc.numgar
          AND cour.type_crrr = 28 -- individu dématerialisé
          AND cour.moyen_info = 2
          AND f.typgar = 1 -- garantie de base
          AND gcnt.type = 1 -- SANTE
          AND trunc(had.datsai) = trunc(sysdate-2) -- permet de prendre les adhesions saisie il a 3 jours
          AND NOT EXISTS (SELECT clef FROM envoi_mail em WHERE em.numindiv_dest = adc.numadhe AND em.etendue = 2  AND em.idtexte in (5,11,24)) --mail pas déjà envoyé
          AND c.gest_prest = 1  --prestations gérées
          AND ad.typfor = 1 --couverture santé
          AND ad.rang=1 --non surco
          AND adc.date_adhe >= trunc(sysdate-2)  -- adhesion creer dans le futur par rapport a il y a 3 jours
          AND (ad.datper is  null OR trunc(ad.datper) > trunc(ad.DATAPLI))
          AND PK_WS_WEB_BACK.F_ETAT_ADHE_WS(ad.idadhesion, sysdate) = 0 -- adhesion en instance a ce jour -- hotfix M0006343
          and had.motif not in (58,59,60) -- MUR hotfix
          AND NOT EXISTS (SELECT *      -- verification des transfert des contrats
              FROM ADHESION  a, CONTRAT c1, formule f1
              WHERE a.numindiv = ad.numindiv
                AND c1.numgar = a.numgar
                AND a.idadhesion <> ad.idadhesion
                AND f1.numfor = a.numfor
                AND f1.typgar = f.typgar -- contrainte sur le même type de garantie que l'adhésion créée
                AND c1.gest_prest = 1  --prestations gérées
                AND a.typfor = 1 --couverture santé
                AND (sysdate BETWEEN a.datapli AND NVL(a.datper,sysdate) --couverture en cours
                    OR (a.datper IS NOT NULL AND add_months(a.datper,6) > sysdate)  --couverture datant de moins de 6 mois
                --  OR (a.datapli> sysdate) --couverture dans le futur
                    OR (a.datper is not null and a.maj > sysdate-7 )))  --cloture de la garantie précedente datant de moins de 7 jours
      -- PBO M0006252 on ajoute les adhésions dans le futur validée RH et Gerep
     UNION
      SELECT distinct datas.idadhesion,
             datas.numadhe,
             a1.date_adhe,
             c.numgar
         FROM(
          SELECT distinct adhe_cntrt.numadhe, adhe_cntrt.idadhesion,adhe_cntrt.date_adhe,c.numgar
           FROM  histo_adhesion,
                 adhe_cntrt,
                 adhesion ad ,
                 contrat c
              WHERE
                 histo_adhesion.IDADHESION = adhe_cntrt.IDADHESION
                 AND adhe_cntrt.IDADHESION = ad.IDADHESION
                 AND c.NUMGAR = ad.NUMGAR
                 AND histo_adhesion.etat   =1    -- Adhésion en vigueur
                 AND trunc(DATSAI) >= trunc(sysdate-1)  	-- Saisie la veille
                 AND TRUNC(DEBUT) > TRUNC(sysdate)		-- Adhesion dans le futur uniquement
                 AND histo_adhesion.motif = 57			-- Affiliation pré-aff validée par Gerep
                 AND c.gest_prest = 1
                 AND ad.typfor = 1
                 AND ad.rang=1
                 AND greatest(adhe_cntrt.date_adhe,sysdate) between datapli and nvl( datper,greatest(adhe_cntrt.date_adhe,sysdate))
                 AND NOT EXISTS (                           --mail pas déjà envoyé
                            select 1 from envoi_mail
                            where numindiv_dest = adhe_cntrt.numadhe
                            and idtexte in(5,24)
                           )
                 AND NOT EXISTS(
                            select * from adhe_cntrt ad_ante
                            where ad_ante.IDADHESION <> adhe_cntrt.IDADHESION
                            and ad_ante.numadhe = adhe_cntrt.numadhe
                            and ad_ante.DATE_ADHE < adhe_cntrt.DATE_ADHE
                            and  sysdate between  ad_ante.DATE_ADHE and nvl(add_months(ad_ante.DATE_FIN_ADHE,6),sysdate)
                            )
             ) datas
              ,adhe_cntrt a1, contrat c,produit p
               where datas.idadhesion = a1.idadhesion
               and a1.numgar = c.numgar
               and c.numprod = p.numprod
        ;


        -- TODO controler les cas de tranfert de contrat en s'inspirant de la requete suivante:
           --- verifie que l'assuré est vraiment un nouvel assuré en comptant les couvertures existantes
        /*SELECT count(idadhesion) INTO loc_is_exist_before
          FROM ADHESION  a, CONTRAT c
          WHERE numindiv = t_adhesion(j).numindiv
        AND c.numgar = a.numgar
        AND c.gest_prest = 1  --prestations gérées
        AND a.typfor = 1 --couverture santé
        AND a.rang=1 --non surco
        AND (sysdate BETWEEN a.datapli AND NVL(a.datper,sysdate) --couverture en cours
            OR (a.datper IS NOT NULL AND add_months(a.datper,6) > sysdate)  --couverture datant de moins de 6 mois
        --  OR (a.datapli> sysdate) --couverture dans le futur
          OR (a.datper is not null and a.maj > sysdate-7 ))

    */

BEGIN
 PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADH_INSTANCE', I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  ' début traitement', I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('AINST',F_NUMUTIL) THEN
    FOR  rec_adh_instance   IN  c_adh_instance  LOOP
     PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADH_INSTANCE',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  ' autorisation de creation de mail pour numindiv '||rec_adh_instance.numadhe,                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST:=rec_adh_instance.numadhe;
      loc_envoi.NUMBENE:=rec_adh_instance.numadhe;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      loc_envoi.etendue:=2;     -- adhesion
      loc_envoi.clef:= rec_adh_instance.idadhesion;
      loc_envoi.IDTEXTE:= 24;   --  mail de bienvenue
      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
	    loc_envoi.TEMPLATE_MAIL:= 3; -- Template mail de bienvenue
	    io_envoi:=loc_envoi;

       PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADH_INSTANCE',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>  'mail valide trouvé', I_idligne  => 4);
      PK_MAIL.CREER_MAIL(io_envoi);


    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADH_INSTANCE',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);
END P_CHARGE_ADH_INSTANCE;
    /*============================================================================*/
/* Auteur       : CLI                                                         */
/* Création     : CLI                                                         */
/* Description  : Insertion des Cartes TP pour envoi de mail                  */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :  14/11/2017                                                 */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

PROCEDURE P_CHARGE_CARTE_TP IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_sujet      ENVOI_MAIL.sujet%type;
  loc_corps      ENVOI_MAIL.corps%type;
  l_jour         VARCHAR2(8);
  l_date_debut   DATE;
  l_date_fin     DATE;
  l_date_du_jour DATE := sysdate;

  CURSOR c_carte_tp IS
      SELECT DISTINCT adhe.NUMADHE, dtpad.debut, pa.IDADHESION
      FROM remise_externe re, porte_adhesion pa, adhe_cntrt adhe, demande_tp_ad dtpad , courrier_info ci
      WHERE re.numremise  = pa.NUMREMISE
        AND ci.numindiv   = adhe.NUMADHE
        AND re.valide = 'O'
        AND ci.type_crrr  = 50 -- courrier info de la carte tp
        AND ci.moyen_info = 2  -- en demat
        AND re.numporte   = 2
        AND re.nature     = 3
        AND adhe.NUMADHE  = pa.numindiv -- On envoi un mail par adhérent, donc 2 mails en cas d'adhésion croisées.
        AND adhe.idadhesion  = pa.idadhesion
        AND dtpad.IDPORTE = pa.IDPORTE
        AND re.date_trans >= l_date_debut and re.date_trans <l_date_fin
        AND dtpad.debut IS NOT NULL
        AND NOT EXISTS(
          SELECT numindiv_dest
          FROM envoi_mail
          where numindiv_dest =adhe.NUMADHE
          AND idtexte = 23
          AND etat in( 0,1)
          AND datemis>re.date_trans) ;

BEGIN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_CARTE_TP',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  =>  'Début de traitement',
                               I_idligne  => 1);

  l_jour:=TO_CHAR(l_date_du_jour, 'DAY', 'NLS_DATE_LANGUAGE=French');
  --la date_trans n'est pas horodatée donc une règle borne de fin exclue est mise en place
  CASE
    WHEN trim(l_jour) IN ('LUNDI') THEN
      -- on prend du jeudi 0h00 au jeudi 23h59
      l_date_debut := TRUNC(l_date_du_jour - 4);
      l_date_fin   := TRUNC(l_date_du_jour - 3);
    WHEN trim(l_jour) IN ('MARDI') THEN
      -- on prend du vendredi 0h00 au samedi 23h59
      l_date_debut := TRUNC(l_date_du_jour - 4);
      l_date_fin   := TRUNC(l_date_du_jour - 2);
    WHEN trim(l_jour) IN ('JEUDI') THEN
      -- on prend du dimanche 0h00 au lundi 23h59
      l_date_debut := TRUNC(l_date_du_jour - 4);
      l_date_fin   := TRUNC(l_date_du_jour - 2);
    WHEN trim(l_jour) IN ('MERCREDI', 'DIMANCHE') THEN
      -- on prend rien
      l_date_fin   := NULL;
      l_date_debut := NULL;
    ELSE
      -- VENDREDI : on prend du Mardi 0h00 au mardi 23h59
      -- SAMEDI : on prend du Mercredi 0h00 au mercredi 23h59
      l_date_debut := TRUNC(l_date_du_jour - 3);
      L_date_fin   := TRUNC(l_date_du_jour - 2);
  END CASE;

  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_CARTE_TP',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  =>  'Cas '||l_JOUR||' '|| TO_CHAR(l_date_du_jour,'DD/MM/YYYY HH24:MI:SS') ||
                                              ' on prend les carte tp transférées entre '    ||
                                              TO_CHAR(l_date_debut,'DD/MM/YYYY HH24:MI:SS') ||' et '||
                                              TO_CHAR(l_date_fin,'DD/MM/YYYY HH24:MI:SS'),
                               I_idligne  => 1);

  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('CRTP',F_NUMUTIL) THEN
    BEGIN
      SELECT corps_msg, sujet_msg
      INTO loc_corps,loc_sujet
      FROM mail_texte
      WHERE id_texte = 23;
    EXCEPTION
      WHEN OTHERS THEN
        PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_CARTE_TP',
                                     I_session  => SID,
                                     I_niv_msg  => 1,
                                     I_msg_adm  => 'Erreur recherche message:'||SQLERRM,
                                     I_idligne  => 6);
        PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_CARTE_TP',
                                     I_session  => SID,
                                     I_niv_msg  => 1,
                                     I_msg_adm  => 'ARRET TRAITEMENT',
                                     I_idligne  => 6);
      RETURN;
    END;

    loc_envoi.NUMUTIL         := F_NUMUTIL;
    loc_envoi.DATE_CREATION   := SYSDATE;
    loc_envoi.etendue         := 2;   -- Carte Tp
    IF to_char(SYSDATE,'MM') = '12' THEN
     loc_envoi.TYPE_MAIL      := 5; -- Envoi soir et weekend pour forte volumétrie en décembre uniquement
    ELSE
     loc_envoi.TYPE_MAIL      := 3; -- Envoi massif après création
    END IF;
    loc_envoi.IDTEXTE         := 23;  -- votre carte tp  #ANNEE est disponibles sur l'extranet...


    FOR rec_carte_tp IN c_carte_tp LOOP
      loc_envoi.NUMINDIV_DEST   := rec_carte_tp.NUMADHE;
      loc_envoi.NUMBENE         := rec_carte_tp.NUMADHE;
      loc_envoi.clef            := rec_carte_tp.IDADHESION;
      -- valorisation de la date dans le message
      loc_envoi.sujet := replace(loc_sujet,'#ANNEE',to_char(to_date(rec_carte_tp.debut),'YYYY'));
      loc_envoi.corps := replace(loc_corps,'#ANNEE',to_char(to_date(rec_carte_tp.debut),'YYYY'));
      io_envoi:=loc_envoi;
      PK_MAIL.CREER_MAIL(io_envoi);
    END LOOP;
  END IF;

  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_CARTE_TP',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Fin de traitement',
                               I_idligne  => 9);

EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_CARTE_TP',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'Erreur: '||SQLERRM,
                                 I_idligne  => 6);

END P_CHARGE_CARTE_TP;
/*============================================================================*/
/* Auteur       : JBO                                                         */
/* Création     : JBO                                                         */
/* Description  : Insertion des décomptes virement soins santé édités dans la */
/*                table envoi_mail pour permettre ensuite l'envoi des mails   */
/*                aux assurés par un job                                      */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

PROCEDURE P_CHARGE_DCPT IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_mail_exist NUMBER:=0;
  loc_date_pivot DATE := sysdate -1;
  CURSOR c_decpt_sante_vir
      IS

	SELECT max(decompte.NUMDEC ) numdec,
         sum(decompte.MONTANT_D) somme,
         decompte.NUMINDIV
    FROM decompte, affectation, decaismt
    WHERE decaismt.codope =affectation.codope
      AND affectation.codope =1
      AND affectation.numaffec = decompte.numdec
      AND affectation.numdecaismt = decaismt.NUMDECAISMT
      AND decaismt.datpay IS NOT NULL
    --AND decompte.numdec >0
      AND decaismt.MODPMT IN  (2,7) -- virement et virement manuel   (MOPM)
      AND decaismt.REFPMT > 0
      AND to_char(decaismt.DATPAY,'DD/MM/YYYY') =to_char(loc_date_pivot,'DD/MM/YYYY')
      AND decaismt.FLAGPAY =1
      AND decompte.typbene=1
      AND (EXISTS(SELECT 1 FROM courrier_info WHERE type_crrr = 28 AND moyen_info = 2 AND courrier_info.numindiv = decompte.numindiv)  OR F_CLIENT = 12)-- on fait sauter la condition pour welcare
      group by  decompte.NUMINDIV;



BEGIN
 -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_DCPT', I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_CHARGE_DCPT : début traitement', I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('DCPT',F_NUMUTIL) THEN
    FOR  rec_decpt_sante_vir  IN      c_decpt_sante_vir  LOOP

     -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_DCPT',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_CHARGE_DCPT : autorisation de creation de mail pour numindiv '||rec_decpt_sante_vir.NUMINDIV,                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST:=rec_decpt_sante_vir.NUMINDIV;
      loc_envoi.NUMBENE:=rec_decpt_sante_vir.NUMINDIV;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      loc_envoi.etendue:=28;     -- Décompte soins de santé
      loc_envoi.clef:= rec_decpt_sante_vir.NUMDEC;
      loc_envoi.IDTEXTE:= 10;    -- Nous vous informons qu''un décompte soins de santé est disponible sur votre espace assuré(MAIL_TEXTE.ID_TEXTE =10)
    -- valorisation des décomptes
      SELECT corps_msg, sujet_msg
    	  INTO loc_envoi.corps,loc_envoi.sujet
    	  FROM mail_texte
    	  WHERE id_texte = loc_envoi.idtexte;
      loc_envoi.corps := replace(loc_envoi.corps, '#SOMME', trim(to_char(rec_decpt_sante_vir.somme, 9999999.99)));
      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
	    io_envoi:=loc_envoi;
      --  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_DCPT',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>  'P_CHARGE_DCPT : mail valide trouvé', I_idligne  => 4);
      PK_MAIL.CREER_MAIL(io_envoi);
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_DCPT',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);

END P_CHARGE_DCPT;
/*============================================================================*/
/* Auteur       : RKO                                                         */
/* Création     : P_CHARGE_DCPT_PREV                                    */
/* Description  : Insertion des décomptes prevoyance dans la                  */
/*                table envoi_mail pour permettre ensuite l'envoi des mails   */
/*                aux interlocuteurs Utilisateur Espace Prevoyance
                  de la sociétés                                              */
/*                                                                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

PROCEDURE P_CHARGE_DCPT_PREV IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_mail_exist NUMBER:=0;
  loc_date_pivot DATE := sysdate -1;

  CURSOR c_decpt_prev
      IS

	SELECT max(decompte_prev.NUMDEC ) numdec,
         decaismt.numdest,interlocuteur.interlocuteur
    FROM decompte_prev, affectation, decaismt, interlocuteur
    WHERE decaismt.codope =affectation.codope
      AND affectation.codope =2
      AND affectation.numaffec = decompte_prev.numdec
      AND affectation.numdecaismt = decaismt.NUMDECAISMT
      AND decaismt.datpay IS NOT NULL
      AND decaismt.MODPMT IN  (2,7) -- virement et virement manuel   (MOPM)
      AND decaismt.REFPMT > 0
      AND to_char(decaismt.DATPAY,'DD/MM/YYYY') = to_char(( sysdate -1),'DD/MM/YYYY')
      AND decaismt.FLAGPAY =1
      AND interlocuteur.numindiv = decaismt.numdest
      AND f_coordonne_contact(interlocuteur.interlocuteur,4,1) IS NOT NULL
      AND interlocuteur.valide='O'
      AND ope_crrr=9
     GROUP BY  decaismt.numdest, interlocuteur.interlocuteur
      ;


BEGIN
 -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_DCPT_PREV', I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_CHARGE_DCPT_PREV : début traitement', I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('DCPT',F_NUMUTIL) THEN
    FOR  rec_decpt_prev  IN      c_decpt_prev  LOOP

      loc_envoi.NUMINDIV_DEST:=rec_decpt_prev.interlocuteur;
      loc_envoi.NUMBENE:=null;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      loc_envoi.etendue:=18;--Décompte soins prévoyance
      loc_envoi.clef:= rec_decpt_prev.NUMDEC;
      loc_envoi.template_mail :=2;
      loc_envoi.IDTEXTE:= 37;
    -- valorisation des décomptes
     /* SELECT corps_msg, sujet_msg         --RKO afin que le mail se genere sur mail pro en appelant creer_mail
    	  INTO loc_envoi.corps,loc_envoi.sujet
    	  FROM mail_texte
    	  WHERE id_texte = loc_envoi.idtexte;
      loc_envoi.corps := loc_envoi.corps;--replace(loc_envoi.corps, '#SOMME', trim(to_char(rec_decpt_prev.somme, 9999999.99))); */
      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
	    io_envoi:=loc_envoi;

      PK_MAIL.CREER_MAIL(io_envoi);
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_DCPT_PREV',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);

END P_CHARGE_DCPT_PREV;


/*============================================================================*/
/* Auteur       : CLI                                                         */
/* Création     : P_CHARGE_ADHESION_OPTION                                    */
/* Description  : Génération des mails concernant les nouvelles adhésions     */
/*              : Optionnelles                                                */
/*                                                                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

PROCEDURE P_CHARGE_ADHESION_OPTION IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_sujet       ENVOI_MAIL.sujet%type;
  loc_corps       ENVOI_MAIL.corps%type;
  loc_mail_exist NUMBER:=0;
  date_pivot  DATE := trunc(sysdate-2);   -- date de saisie des options -- M0006343 idem bienvenue adhesions en instance
  -- date_pivot  DATE := trunc(sysdate-1);
  CURSOR c_adhesions
      IS
      SELECT ad.idadhesion, h.datsai, ad.NUMINDIV, adhe.NUMADHE, adhe.mregl,adhe.date_adhe, ad.datapli, ad.datper
      FROM adhesion ad, adhe_cntrt adhe, histo_adhesion h, formule f, courrier_info cour
      WHERE
      ad.IDADHESION     = adhe.IDADHESION
      AND ad.IDADHESION = h.IDADHESION
      AND ad.NUMFOR     = f.numfor
      AND ad.numindiv   = adhe.numadhe -- uniquement pour les adhérents
      AND cour.numindiv = adhe.numadhe
      AND cour.type_crrr = 28 -- individu dématerialisé
      AND cour.moyen_info = 2
      AND h.etat in (0,1)  -- adhesion en instance ou en vigeur
      and h.motif not in (60,59) -- les validation du RH ne compte pas - MUR hotfix reprise livrable BIA
      AND trunc(h.DATSAI) =  date_pivot   -- adhesion souscrite la veille
      AND (date_pivot  BETWEEN ad.datapli AND  nvl(ad.datper, to_date(date_pivot)+1) OR (ad.datapli> sysdate) )-- couverture en cour ou dans le futur
      AND ad.datapli <> nvl(ad.datper, ad.datapli+1)
      AND f.typgar = 2  -- option
      AND NOT EXISTS (SELECT *      -- verification des transfert de contrats juste pour les optionnels
              FROM ADHESION  a, CONTRAT c1, formule f1
              WHERE a.numindiv = ad.numindiv
                AND c1.numgar = a.numgar
                AND a.idadhesion <> ad.idadhesion
                AND c1.gest_prest = 1  --prestations gérées
                AND f1.numfor = a.numfor
                AND f1.typgar = f.typgar -- contrainte sur le même type de garantie que l'adhésion créée
                AND a.typfor = 1 --couverture santé
                AND (sysdate BETWEEN a.datapli AND NVL(a.datper,sysdate) --couverture en cours
                    OR (a.datper IS NOT NULL AND add_months(a.datper,6) > sysdate)  --couverture datant de moins de 6 mois
                --  OR (a.datapli> sysdate) --couverture dans le futur
                    OR (a.datper is not null and a.maj > sysdate-7 )))
      AND not exists (select 1 from rappel where numassu = ad.numindiv and type = 27 and trunc(creation) = date_pivot)  --CLI 22/11/2019 on envoi pas de mail optionnel si l'option viens du BIA
      AND NOT EXISTS (SELECT clef FROM envoi_mail em WHERE em.numindiv_dest = adhe.numadhe AND em.etendue = 2  AND em.idtexte in (5,24) AND trunc(em.date_creation) = trunc(sysdate)) -- pas de création d'AR de souscription d'option le même jour qu'un Email de bienvenue (5/24) -- PBO M0006343
      --ARTGEREP-609 ne pas creer de mail d'option le jour meme de l'envoi de l'email de bienvenue (5,24) , ni au lendemain de l'envoi de l'email de bienvenue
      AND NOT EXISTS (SELECT clef FROM envoi_mail em WHERE em.numindiv_dest = adhe.numadhe AND em.etendue = 2  AND em.idtexte in (5,24) AND em.date_creation between trunc(sysdate-1) and sysdate)
      ORDER BY ad.idadhesion;



BEGIN
 -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADHESION_OPTION', I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_CHARGE_ADHESION_OPTION : début traitement', I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('OPT',F_NUMUTIL) THEN
    FOR  rec_adhesion  IN      c_adhesions  LOOP
     -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADHESION_OPTION',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_CHARGE_ADHESION_OPTION : autorisation de creation de mail pour numindiv '||rec_decpt_sante_vir.NUMINDIV,                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST:=rec_adhesion.NUMADHE;
      loc_envoi.NUMBENE:=rec_adhesion.NUMINDIV;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      loc_envoi.etendue:=2;     -- Décompte soins de santé
      loc_envoi.clef:= rec_adhesion.IDADHESION;
      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
      IF   rec_adhesion.MREGL IN (1,2) THEN
        loc_envoi.IDTEXTE:= 25;    -- Modele de mail gerep ( prelevement et chéque)
      ELSE
       loc_envoi.IDTEXTE:= 26; -- Modéle de mail par virement ( société)
      END IF;

      SELECT corps_msg, sujet_msg
        INTO loc_corps,loc_sujet
        FROM mail_texte
        WHERE id_texte = loc_envoi.idtexte;
      -- valorisation de la date dans le message
      loc_envoi.sujet := replace(loc_sujet,'#DATE_ADHE',d2e(rec_adhesion.DATE_ADHE));
      loc_envoi.corps := replace(loc_corps,'#DATE_ADHE',d2e(rec_adhesion.DATE_ADHE));
      io_envoi:=loc_envoi;


	     io_envoi:=loc_envoi;

      --  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADHESION_OPTION',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>  'P_CHARGE_ADHESION_OPTION : mail valide trouvé', I_idligne  => 4);
      PK_MAIL.CREER_MAIL(io_envoi);


    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADHESION_OPTION',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);

END P_CHARGE_ADHESION_OPTION;

/*============================================================================*/
/* Auteur       : CLI                                                         */
/* Création     : P_CHARGE_ADHESION_VIGUEUR                                    */
/* Description  : Génération des mails concernant les nouvelles adhésions     */
/*              : en vigueur                                                */
/*                                                                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

PROCEDURE P_CHARGE_ADHESION_VIGUEUR IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_sujet       ENVOI_MAIL.sujet%type;
  loc_corps       ENVOI_MAIL.corps%type;
  loc_mail_exist NUMBER:=0;
  date_pivot  DATE := trunc(sysdate-1);   -- date de saisie des option

  -- deux scenarios possibles soit les adhesions on été mis en instance et passent vigueur
    CURSOR c_adhesions
      IS

SELECT distinct c.numgar,
       -- c.refcie,
        --c.numprod,
        --p.libelle,
        datas.numadhe,
        datas.idadhesion
        --f_etat_adhe(datas.idadhesion, greatest(datas.date_adhe,sysdate)) etat_adhesion
  FROM(
    SELECT distinct adhe_cntrt.numadhe, adhe_cntrt.idadhesion,adhe_cntrt.date_adhe
    FROM  histo_adhesion,
          adhe_cntrt,
          adhesion ad ,
          contrat c
    WHERE
          histo_adhesion.IDADHESION = adhe_cntrt.IDADHESION
      AND adhe_cntrt.IDADHESION = ad.IDADHESION
      AND c.NUMGAR = ad.NUMGAR
      AND histo_adhesion.etat   =1
      AND trunc(DATSAI) >= trunc(sysdate-1)    -- mouvement effectué hier
      AND TRUNC(DEBUT) <= TRUNC(sysdate) -- ABO M0006252 hotfix: si saisi au 30/10 avec debut le 01/11, on envoie le mail 5 le 01/11
      AND c.gest_prest = 1
      AND ad.typfor = 1
      AND ad.rang=1
      AND greatest(adhe_cntrt.date_adhe,sysdate) between datapli and nvl( datper,greatest(adhe_cntrt.date_adhe,sysdate))
    and not exists (
                    select 1 from envoi_mail
                    where numindiv_dest = adhe_cntrt.numadhe
                    and idtexte in(5,24)
                   )
    and not exists(
                    select * from adhe_cntrt ad_ante, adhesion adh_sante
                    where ad_ante.IDADHESION <> adhe_cntrt.IDADHESION
                    and ad_ante.numadhe = adhe_cntrt.numadhe
                    and ad_ante.DATE_ADHE < adhe_cntrt.DATE_ADHE
                    and sysdate between  ad_ante.DATE_ADHE and nvl(add_months(ad_ante.DATE_FIN_ADHE,6),sysdate)
                    and ad_ante.idadhesion = adh_sante.idadhesion
                    and ad_ante.numadhe    = adh_sante.numindiv
                    and adh_sante.typfor   = 1 --santé uniquement
                    )
       ) datas
       ,adhe_cntrt a1, contrat c,produit p
       where datas.idadhesion = a1.idadhesion
       and a1.numgar = c.numgar
       and c.numprod = p.numprod;

BEGIN
 -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADHESION_VIGUEUR', I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_CHARGE_ADHESION_VIGUEUR : début traitement', I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('NASSU',F_NUMUTIL) THEN
    FOR  rec_adhesion  IN      c_adhesions  LOOP
    loc_envoi :=  io_envoi;
     -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADHESION_VIGUEUR',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_CHARGE_ADHESION_VIGUEUR : autorisation de creation de mail pour numindiv '||rec_decpt_sante_vir.NUMINDIV,                                   I_idligne  => 2);
     IF  pk_mail.CHECK_DEMAT_INDIV(rec_adhesion.NUMADHE) =1 THEN
      loc_envoi.NUMINDIV_DEST:=rec_adhesion.NUMADHE;
      loc_envoi.NUMBENE:=rec_adhesion.NUMADHE;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      loc_envoi.etendue:=2;     -- Adhesion
      loc_envoi.clef:= rec_adhesion.IDADHESION;
      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
      loc_envoi.IDTEXTE:= 5; --Mail de bienvenue
      loc_envoi.TEMPLATE_MAIL:= 3; -- PBO M0006130 Template mail de bienvenue

      SELECT corps_msg, sujet_msg
        INTO loc_corps,loc_sujet
        FROM mail_texte
        WHERE id_texte = loc_envoi.idtexte;

       PK_MAIL.CREER_MAIL(loc_envoi);
      END IF;

    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_ADHESION_VIGUEUR',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);

END ;
/*============================================================================*/
/* Auteur       : ABO                                                         */
/* Création     : 27/04/2017                                                  */
/* Description  : Insertion des demandes de pièces dans la                    */
/*                table envoi_mail pour permettre ensuite l'envoi des mails   */
/*                aux assurés par un job                                      */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/
PROCEDURE P_CHARGE_PIECE IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_mail_exist NUMBER:=0;
  loc_nopiece    PIECES.NOPIECE%TYPE;

  CURSOR c_piece (p_nopiece NUMBER) IS
  SELECT distinct NUMINDIV_DEST,NUMBENE,CONTEXTE,ENTITE, MAX(NBREL) NBREL,decode(nopiece,p_nopiece,1,0) piece_detail
    FROM PIECES
    WHERE CONTEXTE  IN (4,12,20,19 ) --adhésion et dossier santé uniquement (télétransmission est traitée unitairement) -- MUR M0005618 ajout contexte 19 - pièces télétransmises
      AND TRUNC(NVL(DATEREL,DATEAVIS)) = TRUNC(SYSDATE-1)
      AND NVL(DATEREL,DATEAVIS) IS NOT NULL
      AND DATERECEP IS NULL --non déjà réceptionnée
      AND DATANNUL IS NULL --non annulée
      AND NVL(DATEREL,DATEAVIS) > add_months(sysdate,-12) -- datant de moins d'un an
      AND EXISTS(SELECT 1 FROM courrier_info WHERE type_crrr = 28 AND moyen_info = 2 AND courrier_info.numindiv =pieces.NUMINDIV_DEST) -- vérification que l assuré possède un circuit à 28
    --AND  (CONTEXTE<> 4 OR( CONTEXTE= 4 AND NOPIECE NOT IN (1,2,5,6,7) )) --black list présente aussi sur WS de consultation
	  AND EXISTS (SELECT 1 FROM adhesion a, contrat c --au moins une couverture santé
                  WHERE NUMINDIV = pieces.NUMBENE
                  AND c.numgar = a.numgar
	                AND c.gest_prest = 1  --prestations gérées
	                AND a.typfor = 1 --couverture santé
                  AND (sysdate BETWEEN a.datapli AND NVL(add_months(a.datper,3),sysdate) OR a.datapli > sysdate))
   AND nbrel < 80 -- ne pas tenir compte des pieces pour courrier d’information sur les limites d’âge
	 GROUP BY NUMINDIV_DEST,NUMBENE,CONTEXTE,ENTITE,NOPIECE
   ORDER BY 1;


   CURSOR c_piece_prev IS         --RKO EA PREV
   SELECT distinct  interlocuteur_dest.interlocuteur ,NUMBENE,CONTEXTE,ENTITE, MAX(NBREL) NBREL
    FROM PIECES, interlocuteur , interlocuteur interlocuteur_dest
    WHERE CONTEXTE  = 17 --contexte prevoyance pour société souscriptrice
      AND TRUNC(NVL(DATEREL,DATEAVIS)) = TRUNC(SYSDATE-1)
      AND NVL(DATEREL,DATEAVIS) IS NOT NULL
      AND DATERECEP IS NULL --non déjà réceptionnée
      AND DATANNUL IS NULL --non annulée
      AND NVL(DATEREL,DATEAVIS) > add_months(sysdate,-12) -- datant de moins d'un an
	  AND EXISTS (SELECT 1 FROM adhesion a, contrat c  --au moins une couverture santé
                  WHERE NUMINDIV = pieces.NUMBENE
                  AND c.numgar = a.numgar
	                AND a.typfor = 2 --couverture prévoyance
                  AND (sysdate BETWEEN a.datapli AND NVL(add_months(a.datper,3),sysdate) OR a.datapli > sysdate))

     AND PIECES.numindiv_dest = interlocuteur.numindiv   --le destinataire doit avoir un email valide et être un interloc utilisateur de l'espace prevoy.
     AND interlocuteur.valide ='O'
     AND interlocuteur_dest.numindiv = interlocuteur.numindiv --meme société  (dans le cas ou l'interloc de la société du dossier prevoy n'est pas ouvert au domaine 9 on envoi quand meme aux autres interloc de la meme société qui sont en domaine 9)
     AND interlocuteur_dest.ope_crrr =9
     AND interlocuteur_dest .valide ='O'
   AND nvl(nbrel,0) in (0,1,2)
   AND f_coordonne_contact(interlocuteur_dest.interlocuteur,4,1) IS NOT NULL
	 GROUP BY interlocuteur_dest.interlocuteur,NUMBENE,CONTEXTE,ENTITE,NOPIECE
   ORDER BY 1;

BEGIN
 -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_PIECE', I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_CHARGE_PIECE : début traitement', I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('PIECE',F_NUMUTIL) THEN
    loc_nopiece :=to_number(f_get_transco('EA','SCOLA_N', 2,2));

    FOR  rec_piece  IN  c_piece(loc_nopiece)  LOOP
     -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_PIECE',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_CHARGE_PIECE : autorisation de creation de mail pour numindiv '||rec_decpt_sante_vir.NUMINDIV,                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST:=rec_piece.NUMINDIV_DEST;
      loc_envoi.NUMBENE:=rec_piece.NUMBENE;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      IF rec_piece.CONTEXTE = 20 THEN
        loc_envoi.etendue:=7;     -- soins de santé
        loc_envoi.clef:= rec_piece.NUMINDIV_DEST;
        loc_envoi.IDTEXTE:= 18;
         -- MUR M0005618
      ELSIF rec_piece.CONTEXTE = 19 THEN
         loc_envoi.etendue := 7 ; -- soins de santé
         loc_envoi.clef := rec_piece.NUMINDIV_DEST ;
         loc_envoi.IDTEXTE:= 30;
      ELSE
        loc_envoi.etendue:=2;     -- adhésion
        loc_envoi.clef:= rec_piece.ENTITE;
        IF rec_piece.NBREL = 0  AND rec_piece.piece_detail=0 THEN
		      loc_envoi.IDTEXTE:= 7;
        ELSIF rec_piece.NBREL = 1 AND rec_piece.piece_detail=0  THEN
          loc_envoi.IDTEXTE:= 27;
        ELSIF rec_piece.NBREL = 0  AND rec_piece.piece_detail=1 THEN --spécif certificat de sco avis
		      loc_envoi.IDTEXTE:= 35;
        ELSIF rec_piece.NBREL = 1 AND rec_piece.piece_detail=1  THEN --spécif certificat de sco relance
          loc_envoi.IDTEXTE:= 36;
        ELSIF rec_piece.NBREL > 1 THEN
          loc_envoi.IDTEXTE:= 28;
        END IF;
      END IF;

      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
	    io_envoi:=loc_envoi;

      --  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_PIECE',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>  'P_CHARGE_PIECE : mail valide trouvé', I_idligne  => 4);
      PK_MAIL.CREER_MAIL(io_envoi);
    END LOOP;

    --Génération des mails de pièces prévoyance
    FOR  rec_piece_prev  IN  c_piece_prev LOOP
      loc_envoi.NUMINDIV_DEST:=rec_piece_prev.interlocuteur;
      loc_envoi.NUMBENE:=rec_piece_prev.NUMBENE;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      IF rec_piece_prev.CONTEXTE = 17 THEN
        loc_envoi.etendue:=1;    --prevoyance
        loc_envoi.clef:= rec_piece_prev.interlocuteur;
        loc_envoi.IDTEXTE:= NULL;
        IF rec_piece_prev.NBREL = 0  THEN
		      loc_envoi.IDTEXTE:= 38;
        ELSIF   rec_piece_prev.NBREL = 1  THEN--Relance 1
          loc_envoi.IDTEXTE:= 39;
        ELSE loc_envoi.IDTEXTE:= 40;    --Relance 2
        END IF;
      END IF;

      loc_envoi.TEMPLATE_MAIL:=2;
      loc_envoi.TYPE_MAIL:=3;   -- Automatique
      loc_envoi.DATE_CREATION:=SYSDATE;
	    io_envoi:=loc_envoi;


      PK_MAIL.CREER_MAIL(io_envoi);
    END LOOP;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_PIECE',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);
END P_CHARGE_PIECE;

/*============================================================================*/
/* Auteur       : CLI                                                         */
/* Création     : 27/04/2017                                                  */
/* Description  : Génération massive de mail suite a lédition des appels de   */
/*              :   cotisation a j+1                                          */
/*              :                                                             */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/
PROCEDURE P_CHARGE_QUITTANCE IS

  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_mail_exist NUMBER:=0;
  loc_date_pivot DATE := trunc(sysdate);
  -- curseur pris de F_COTISATION DE PK_WS_WEB_BACK
  CURSOR C_SEL_QTTC_ADHE
  /*(
      V_NUMINDIV V_QTTC_ADHE.NUMQUERABLE%TYPE,
      V_IDADHESION V_QTTC_ADHE.IDADHESION%TYPE,
      V_NUMPORTE PORTE_CONTRAT.NUMPORTE%TYPE
      )  */
      IS
     SELECT
     distinct
      qttc_global.numgar,
      qttc_global.numquit,
      qttc_global.numquerable,
      qttc_global.numindiv,
     -- qttc_global.nat_calc,qttc_global.type_qttc,qttc_global.debut,qttc_global.fin,
		  qttc_global.idadhesion,
      facture.mregl,
      facture.echeance,
      numrelance,
      --grnts.refcie CNTREF_REFCIE, grnts.numorg,grnts.typgar,grnts.numcli,querable.nom || ' ' || querable.prenom nomquerable,sousc.nom || ' ' || sousc.prenom nomsousc,
     -- libelle.libelle LIBMREGL, facture.montant montant,facture.montant_d montant_d, qttc_global.mt_net_d,qttc_global.mt_affec_d mt_regl_d,
    /*  DECODE (qttc_global.comptant,
              'N', 'Prévisionnelle',
              DECODE (f_datemis (4, qttc_global.numquit, 1, 99),
                      'Non annulé', NVL (TO_CHAR (qttc_global.mt_affec_d,
                                                  '9999999.99'
                                                 ),
                                         'Non réglé'
                                        ),
                      'Annulé'
                     )
             ) mt_affec_d,*/
    -- qttc_global.monnaie_d,
     e.datemis edatemis
    --( select max (datemis) from emission where emission.numquit = qttc_global.numquit) edatemis
     FROM libelle,
          indvs querable,
          indvs sousc,
          grnts,
          porte_contrat p,
          qttc_global
          left outer join indvs assu on (  assu.numindiv = qttc_global.numindiv),
          facture,
          emission e
    WHERE libelle.mnemo = 'MREGL'
      AND libelle.code = facture.mregl
      and e.numfact = facture.numfact
      --and e.numrelance = 0 -- peut importe le niveau de relance
      and  trunc(e.DATEMIS) = loc_date_pivot
      AND facture.codope = 4
      AND facture.numfact = qttc_global.numquit
      AND querable.numindiv = qttc_global.numquerable
      AND sousc.numindiv = grnts.numcli
      AND grnts.numgar = qttc_global.numgar
      AND grnts.numgar = p.numgar
      AND facture.mregl in (1,2)
      AND p.NUMPORTE = 25 -- V_NUMPORTE    -- TODO QUELlE PORTE?
      --AND qttc_global.NUMQUERABLE = V_NUMINDIV    -- retirer pour avoir toute les QTTC
     -- AND qttc_global.IDADHESION = NVL(V_IDADHESION,qttc_global.IDADHESION)
      AND qttc_global.MONNAIE_D = pk_devise.devise_ref --uniquement euro
      AND qttc_global.comptant <>'R'
      AND (qttc_global.comptant='N' OR NVL( e.DATEMIS, e2d('01/01/1900') ) > ADD_MONTHS(SYSDATE,-24) )--emission de moins de 24 mois ou prévisionnelle
      AND TO_CHAR(facture.echeance ,'YYYY') = to_char(sysdate,'YYYY') --uniquement les quittances à payer sur l'année en cours
      AND NOT EXISTS ( --ne pas affichée les régularisée
        SELECT numquit FROM emission
        WHERE emission.numfact = facture.numfact
        AND numrelance IN (4,99)
        AND type_doc = 1
      )
      ORDER BY qttc_global.numquit ;

BEGIN
 -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_QUITTANCE', I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_CHARGE_QUITTANCE : début traitement', I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('QTTC',F_NUMUTIL) THEN
    FOR  R_QTTC  IN  C_SEL_QTTC_ADHE  LOOP
     -- PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_QUITTANCE',   I_session  => SID, I_niv_msg  => 1,   I_msg_adm  =>  'P_CHARGE_QUITTANCE : autorisation de creation de mail pour numindiv '||rec_decpt_sante_vir.NUMINDIV,                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST:=R_QTTC.numquerable;
      loc_envoi.NUMBENE:=R_QTTC.numindiv;
      loc_envoi.NUMUTIL:= F_NUMUTIL;
      /*     -- TODO definir l'id texte selon le numrelance
      IF rec_piece.CONTEXTE = 20 THEN
        loc_envoi.etendue:=7;     -- soins de santé
        loc_envoi.clef:= rec_piece.NUMINDIV_DEST;
        loc_envoi.IDTEXTE:= 18;
      ELSE
        loc_envoi.etendue:=2;     -- adhésion
        loc_envoi.clef:= rec_piece.ENTITE;
        IF rec_piece.NBREL = 0 THEN
		      loc_envoi.IDTEXTE:= 7;
        ELSIF rec_piece.NBREL = 1 THEN
          loc_envoi.IDTEXTE:= 27;
    		ELSIF rec_piece.NBREL > 1 THEN
    		  loc_envoi.IDTEXTE:= 28;
    		END IF;
      END IF;
      */
    loc_envoi.TYPE_MAIL:=3;   -- Automatique
    loc_envoi.DATE_CREATION:=SYSDATE;
    io_envoi:=loc_envoi;

      --  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_QUITTANCE',     I_session  => SID,  I_niv_msg  => 1,  I_msg_adm  =>  'P_CHARGE_QUITTANCE : mail valide trouvé', I_idligne  => 4);
      PK_MAIL.CREER_MAIL(io_envoi);


    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_QUITTANCE',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  =>  ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);
END P_CHARGE_QUITTANCE;

/*============================================================================*/
/* Auteur       : BCO                                                         */
/* Création     : BCO                                                         */
/* Description  : SEPA B2B - Envoi d'un mail automatique à la création d'un   */
/*                RUM attaché à un querable prélévement collectif             */
/*                                                                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/
PROCEDURE P_CHARGE_RUM IS
  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_corps         MAIL_TEXTE.CORPS_MSG%TYPE;
  loc_sujet         MAIL_TEXTE.SUJET_MSG%TYPE;
  loc_template_mail MAIL_TEXTE.TEMPLATE_MAIL%TYPE;
  loc_type_interloc MAIL_TEXTE.TYPE_INTERLOCUTEUR%TYPE;

  loc_date_pivot DATE := sysdate - 1 ;

  CURSOR c_new_rum (typI IN INTERLOCUTEUR.OPE_CRRR%TYPE) IS
  SELECT DISTINCT
    hm.mandat,
    hq.numquerable,
    it.interlocuteur,
    ct.numcli,
    cp.ICS
  FROM       histo_mandat   hm
  INNER JOIN histo_querable hq on hq.mandat   = hm.mandat
  INNER JOIN interlocuteur  it on it.numindiv = hq.numquerable
  INNER JOIN contrat        ct on ct.numgar   = hq.numgar
  -- Compte de prelèvement de Cotis
  INNER JOIN compte         cp on cp.NUMCPTE  = f_param_compte (ct.numgar_ref, 4, 2)
  WHERE
        TRUNC(hm.creation) = TRUNC(loc_date_pivot)
    AND hm.statut = 1
    AND hq.etat   = 1
    AND hq.mregl  = 2
    AND NVL(hq.idadhesion,0) = 0
    -- Critères sur l'interlocureur
    AND f_coordonne_contact(it.interlocuteur,4,1) IS NOT NULL
    AND it.valide   = 'O'
    AND it.ope_crrr = typI;

BEGIN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RUM',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_CHARGE_RUM : début traitement',
                               I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('RUM',F_NUMUTIL) THEN
    loc_envoi.idtexte :=  42 ;
    SELECT corps_msg,
           sujet_msg,
           type_interlocuteur,
           template_mail
    INTO loc_corps,
         loc_sujet,
         loc_type_interloc,
         loc_template_mail
    FROM mail_texte
    WHERE id_texte = loc_envoi.idtexte;

    FOR rec_new_rum IN c_new_rum ( 1 ) LOOP   -- 1 - Cotisation
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RUM',
                                   I_session  => SID,
                                   I_niv_msg  => 1,
                                   I_msg_adm  =>  'P_CHARGE_RUM : Traitement ' || rec_new_rum.numquerable || '- Mandat :' || trim(rec_new_rum.mandat),
                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST := rec_new_rum.interlocuteur;
      loc_envoi.NUMBENE       := rec_new_rum.numcli;
      loc_envoi.NUMUTIL       := F_NUMUTIL;
      loc_envoi.etendue       := 13;
      loc_envoi.clef          := rec_new_rum.numquerable;
      loc_envoi.sujet         := loc_sujet;
      loc_envoi.corps         := loc_corps;
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#CLIENT', f_nom(1));
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#NOMBENE',f_nom(rec_new_rum.numquerable));
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#RUM', trim(rec_new_rum.mandat)) ;
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#ICS', NVL(rec_new_rum.ICS,''));
      loc_envoi.template_mail := loc_template_mail;
      loc_envoi.TYPE_MAIL     := 3;   -- Automatique
      loc_envoi.DATE_CREATION := SYSDATE;

      io_envoi:=loc_envoi;
      PK_MAIL.CREER_MAIL(I_envoi_mail => io_envoi,
                         i_desactiv_ctrl_doublon => 'O');
      IF io_envoi.numenvoimail IS NOT NULL THEN
        PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RUM',
                                     I_session  => SID,
                                     I_niv_msg  => 1,
                                     I_msg_adm  => 'P_CHARGE_RUM : mail créé',
                                     I_idligne  => 4);
      END IF;
    END LOOP;
  END IF;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RUM',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_CHARGE_RUM : fin traitement',
                               I_idligne  => 9);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RUM',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);
END P_CHARGE_RUM;



/*============================================================================*/
/* Auteur       : BCO                                                         */
/* Création     : BCO                                                         */
/* Description  : SEPA B2B - Envoi d'un mail automatique à la validation      */
/*                de la cotisation en prélèvement                             */
/*                                                                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/
PROCEDURE P_CHARGE_VCOTIS IS
  loc_envoi         ENVOI_MAIL%ROWTYPE;
  io_envoi          ENVOI_MAIL%ROWTYPE;
  loc_corps         MAIL_TEXTE.CORPS_MSG%TYPE;
  loc_sujet         MAIL_TEXTE.SUJET_MSG%TYPE;
  loc_template_mail MAIL_TEXTE.TEMPLATE_MAIL%TYPE;
  loc_type_interloc MAIL_TEXTE.TYPE_INTERLOCUTEUR%TYPE;

  loc_trimestre     VARCHAR(10);
  loc_annee         VARCHAR(10);


  loc_date_pivot DATE := sysdate - 1 ;

  CURSOR c_new_vcotis (typI IN INTERLOCUTEUR.OPE_CRRR%TYPE) IS
    SELECT DISTINCT
       qg.numquerable
      ,it.interlocuteur
      ,ct.numcli
      ,cp.ICS
    FROM       qttc_global   qg
    INNER JOIN interlocuteur it ON it.numindiv = qg.numquerable
    INNER JOIN contrat       ct ON ct.numgar   = qg.numgar
    INNER JOIN facture       ft ON ft.numfact  = qg.numquit
                               AND ft.codope   = 4
  -- Compte de prelèvement de Cotis
    INNER JOIN compte        cp ON cp.NUMCPTE  = f_param_compte (ct.numgar_ref, 4, 2)
    WHERE
        qg.valid               = 'O'
    AND TRUNC(qg.dat_valid)    = TRUNC(loc_date_pivot)
    -- exclusion des cotisations régularisées et annulées
    AND qg.comptant           <> 'R'
    AND qg.type_qttc          <> 3
    AND ft.mregl               = 2
    -- Critères sur l'interlocureur
    AND f_coordonne_contact(it.interlocuteur,4,1) IS NOT NULL
    AND it.valide   = 'O'
    AND it.ope_crrr = typI;


  CURSOR c_mnt_vcotis (i_numquerable IN QTTC_GLOBAL.NUMQUERABLE%TYPE, i_numcli CONTRAT.NUMCLI%TYPE) IS
    SELECT
       ct.numgar
      ,ct.refcie
      ,ct.college
      ,ct.type_contrat
      ,NVL(ft.montant_d,0) - NVL(qg.mt_affec_D,0) solde_d
      ,TO_CHAR(qg.debut,'YYYY') annee
      ,TO_CHAR(qg.debut,'Q')    trimestre

    FROM       qttc_global   qg
    INNER JOIN contrat       ct ON ct.numgar   = qg.numgar
    INNER JOIN facture       ft ON ft.numfact  = qg.numquit
                               AND ft.codope   = 4
    WHERE
        qg.numquerable         = i_numquerable
    AND ct.numcli              = i_numcli
    AND qg.valid               = 'O'
    AND TRUNC(qg.dat_valid)    = TRUNC(loc_date_pivot)
    -- exclusion des cotisations régularisées et annulées
    AND qg.comptant           <> 'R'
    AND qg.type_qttc          <> 3
    AND ft.mregl               = 2
    ORDER BY
     TO_CHAR(qg.debut,'YYYY')
    ,TO_CHAR(qg.debut,'Q')
    ,ct.type_contrat
    ,ct.refcie ;


BEGIN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_VCOTIS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_CHARGE_VCOTIS : début traitement',
                               I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('VCOTI',F_NUMUTIL) THEN
    loc_envoi.idtexte :=  43 ;
    SELECT corps_msg,
           sujet_msg,
           type_interlocuteur,
           template_mail
    INTO loc_corps,
         loc_sujet,
         loc_type_interloc,
         loc_template_mail
    FROM mail_texte
    WHERE id_texte = loc_envoi.idtexte;
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_VCOTIS',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => 'P_CHARGE_VCOTIS : Mail VCOTIS autorisé',
                                 I_idligne  => 1);
    FOR rec_new_vcotis IN c_new_vcotis ( 1 ) LOOP   -- 1 - Cotisation
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_VCOTIS',
                                   I_session  => SID,
                                   I_niv_msg  => 1,
                                   I_msg_adm  =>  'P_CHARGE_VCOTIS : Traitement ' || rec_new_vcotis.numquerable,
                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST := rec_new_vcotis.interlocuteur ;
      loc_envoi.NUMBENE       := rec_new_vcotis.numcli ;
      loc_envoi.NUMUTIL       := F_NUMUTIL;
      loc_envoi.etendue       := 13;
      loc_envoi.clef          := rec_new_vcotis.numquerable;
      loc_envoi.TYPE_MAIL     := 3;   -- Automatique
      loc_envoi.DATE_CREATION := SYSDATE;
      loc_envoi.sujet         := loc_sujet;
      loc_envoi.corps         := loc_corps;
      loc_envoi.template_mail := loc_template_mail;
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#CLIENT', f_nom(1));
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#NOMQUER',f_nom(rec_new_vcotis.numquerable));
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#NOMBENE',f_nom(rec_new_vcotis.numcli));
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#ICS', NVL(rec_new_vcotis.ICS,''));

      loc_trimestre := NULL ;
      loc_annee     := NULL ;
      FOR rec_mnt_vcotis IN c_mnt_vcotis ( rec_new_vcotis.numquerable, rec_new_vcotis.numcli) LOOP
        -- si rupture sur annee/trimestre
        IF   loc_trimestre = rec_mnt_vcotis.trimestre
         AND loc_annee     = rec_mnt_vcotis.annee THEN
          NULL;
        ELSE
          loc_trimestre   := rec_mnt_vcotis.trimestre ;
          loc_annee       := rec_mnt_vcotis.annee ;

          loc_envoi.corps := loc_envoi.corps || CHR(10) || CHR(10);
          CASE rec_mnt_vcotis.trimestre
            WHEN '1' THEN
              loc_envoi.corps := loc_envoi.corps || '1er trimestre '   || rec_mnt_vcotis.annee ;
            WHEN '2' THEN
              loc_envoi.corps := loc_envoi.corps || '2ième trimestre ' || rec_mnt_vcotis.annee ;
            WHEN '3' THEN
              loc_envoi.corps := loc_envoi.corps || '3ième trimestre ' || rec_mnt_vcotis.annee ;
            WHEN '4' THEN
              loc_envoi.corps := loc_envoi.corps || '4ième trimestre ' || rec_mnt_vcotis.annee ;
            ELSE
              loc_envoi.corps := loc_envoi.corps || rec_mnt_vcotis.annee ;
          END CASE;
          loc_envoi.corps := loc_envoi.corps || CHR(10) || 'Détail du prélèvement par contrat : ';
        END IF;
        loc_envoi.corps := loc_envoi.corps || CHR(10);
        loc_envoi.corps := loc_envoi.corps ||
                  f_lble('TYP_CONT',rec_mnt_vcotis.type_contrat) ||
                 ' - ' || rec_mnt_vcotis.refcie ||
                 ' - ' || f_lble('COLLEGE',rec_mnt_vcotis.college) ||
                 ' : '  || LTRIM(TO_CHAR(rec_mnt_vcotis.solde_d,'9999990.99')) || ' euros';
      END LOOP;


      io_envoi                := loc_envoi;
      PK_MAIL.CREER_MAIL(I_envoi_mail => io_envoi,
                         i_desactiv_ctrl_doublon => 'O');


      IF io_envoi.numenvoimail IS NOT NULL THEN
        PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_VCOTIS',
                                     I_session  => SID,
                                     I_niv_msg  => 1,
                                     I_msg_adm  => 'P_CHARGE_VCOTIS : mail créé',
                                     I_idligne  => 4);
      END IF;
    -- fin boucle querable/interlocuteur
    END LOOP;
  END IF;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_VCOTIS',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_CHARGE_VCOTIS : fin traitement',
                               I_idligne  => 9);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_VCOTIS',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);
END P_CHARGE_VCOTIS;



/*============================================================================*/
/* Auteur       : BCO                                                         */
/* Création     : BCO                                                         */
/* Description  : SEPA B2B - Envoi d'un mail automatique à la génération d'un */
/*                bordereau de prélèvement B2B validé                         */
/*                                                                            */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/
PROCEDURE P_CHARGE_PB2B IS
  loc_envoi      ENVOI_MAIL%ROWTYPE;
  io_envoi       ENVOI_MAIL%ROWTYPE;
  loc_corps         MAIL_TEXTE.CORPS_MSG%TYPE;
  loc_sujet         MAIL_TEXTE.SUJET_MSG%TYPE;
  loc_template_mail MAIL_TEXTE.TEMPLATE_MAIL%TYPE;
  loc_type_interloc MAIL_TEXTE.TYPE_INTERLOCUTEUR%TYPE;

  loc_date_pivot DATE := sysdate -1 ;

  CURSOR c_new_pb2b (typI IN INTERLOCUTEUR.OPE_CRRR%TYPE) IS
  SELECT
     pr.numremise
    ,pr.numquerable
    ,SUM(NVL(pr.montant,0)) smontant
    ,rp.eche_prelev_sepa
    ,it.interlocuteur
  FROM       remise_prelev rp
  INNER JOIN prelevement   pr ON pr.numremise = rp.numremise
  INNER JOIN interlocuteur it ON it.numindiv  = pr.numquerable
  WHERE rp.typesepa = 2
    AND rp.valide   = 'O'
    AND TRUNC(rp.datdisk) = TRUNC(loc_date_pivot)
    -- Critères sur l'interlocureur
    AND f_coordonne_contact(it.interlocuteur,4,1) IS NOT NULL
    AND it.valide   = 'O'
    AND it.ope_crrr = typI
  GROUP BY
     pr.numremise
    ,pr.numquerable
    ,rp.eche_prelev_sepa
    ,it.interlocuteur
    ;

  CURSOR c_numcli_pb2b (i_numremise   IN PRELEVEMENT.NUMREMISE%TYPE,
                        i_numquerable IN PRELEVEMENT.NUMQUERABLE%TYPE) IS
  SELECT DISTINCT
    ct.numcli
  FROM       remise_prelev      rp
  INNER JOIN prelevement        pr ON pr.numremise = rp.numremise
  INNER JOIN prelevement_detail pd ON pd.numprelev = pr.numprelev
  INNER JOIN qttc_global        qg ON qg.numquit   = pd.numfact
  INNER JOIN contrat            ct ON ct.numgar    = qg.numgar
  WHERE rp.numremise     = i_numremise
    AND pr.numquerable   = i_numquerable
    AND rp.typesepa      = 2
    AND rp.valide        = 'O'
    AND TRUNC(rp.datdisk) = TRUNC(loc_date_pivot)
    ;

BEGIN
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_PB2B',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_CHARGE_PB2B : début traitement',
                               I_idligne  => 1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('PB2B',F_NUMUTIL) THEN
    loc_envoi.idtexte :=  44 ;
    SELECT corps_msg,
           sujet_msg,
           type_interlocuteur,
           template_mail
    INTO loc_corps,
         loc_sujet,
         loc_type_interloc,
         loc_template_mail
    FROM mail_texte
    WHERE id_texte = loc_envoi.idtexte;

    FOR rec_new_pb2b IN c_new_pb2b ( 1 ) LOOP   -- 1 - Cotisation
      PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_PB2B',
                                   I_session  => SID,
                                   I_niv_msg  => 1,
                                   I_msg_adm  =>  'P_CHARGE_PB2B : Traitement ' || rec_new_pb2b.numremise,
                                   I_idligne  => 2);
      loc_envoi.NUMINDIV_DEST := rec_new_pb2b.interlocuteur;
      loc_envoi.NUMBENE       := rec_new_pb2b.numquerable;
      loc_envoi.NUMUTIL       := F_NUMUTIL;
      loc_envoi.etendue       := 13;
      loc_envoi.clef          := rec_new_pb2b.numquerable;
      loc_envoi.sujet         := loc_sujet;
      loc_envoi.corps         := loc_corps;
      loc_envoi.template_mail := loc_template_mail;
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#MNT', LTRIM(TO_CHAR(rec_new_pb2b.smontant,'9999990.99')));
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#DATEPRELEV', TO_CHAR(TO_DATE(rec_new_pb2b.eche_prelev_sepa,'DDMMYYYY'),'DD/MM/YYYY')) ;
      loc_envoi.TYPE_MAIL     := 3;   -- Automatique
      loc_envoi.DATE_CREATION := SYSDATE;

      FOR rec_numcli_pb2b IN c_numcli_pb2b ( rec_new_pb2b.numremise ,rec_new_pb2b.numquerable ) LOOP
        loc_envoi.corps := loc_envoi.corps || CHR(10);
        loc_envoi.corps := loc_envoi.corps || f_nom(rec_numcli_pb2b.numcli) ;
      END LOOP;

      io_envoi:=loc_envoi;
      PK_MAIL.CREER_MAIL(I_envoi_mail => io_envoi,
                         i_desactiv_ctrl_doublon => 'O');
      IF io_envoi.numenvoimail IS NOT NULL THEN
        PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_PB2B',
                                     I_session  => SID,
                                     I_niv_msg  => 1,
                                     I_msg_adm  => 'P_CHARGE_PB2B : mail créé',
                                     I_idligne  => 4);
      END IF;
    END LOOP;
  END IF;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_PB2B',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_CHARGE_PB2B : fin traitement',
                               I_idligne  => 9);
EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_PB2B',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => ' Erreur: '||SQLERRM,
                                 I_idligne  => 6);
END P_CHARGE_PB2B;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_CHARGE_RESIL                                          */
/* Type         :  Public                                                    */
/* Description  :  Les adhésions santé et/ou prevoy. résiliées manuellement
                      et/ou via ws RAD_ADHESION                              */
/* Entree       :  numéro de l'assuré principal                              */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_CHARGE_RESIL IS

  CURSOR c_adhesion_resil(p_motif NUMBER) IS
    SELECT distinct ad.numadhe,ad.idadhesion, ha.datsai, ha.motif, cr.numgar, cr.numprod, cr.numcli,a.datper
    FROM adhe_cntrt ad, histo_adhesion ha,adhesion a, contrat_ref cr
    WHERE ad.idadhesion = a.idadhesion
    AND ad.idadhesion = ha.idadhesion
    AND ad.numadhe = a.numindiv
    AND cr.numgar = a.numgar
	and cr.numprod NOT IN (select code from LIBELLE where mnemo like 'PRODEXCLU' and code <> -2) --RKO M0006951 exlusion des produits 198,204 et 384
	AND cr.numprod IS NOT NULL
	AND cr.type_contrat = 1--contrat santé RG3 exclusion des contrats prévoyance de l'envoi des mails et courriers
    AND trunc(a.datapli) <> NVL(a.datper,e2d('01/01/1900'))
    AND pk_ws_web_back.F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    => greatest(ad.date_adhe, sysdate),  a_type=>1) in (1,3) -- en vigueur à la date du jour et resilié dans le futur ou resilié à la date du jour
    AND pk_mail.check_demat_indiv(ad.numadhe) =1 -- assuré dématérialisé
    AND ha.etat = 3
    AND a.datper = ha.debut
	AND trunc(a.datper)> trunc(sysdate -90) -- pas de mail si radiation trop ancienne
    AND trunc(ha.datsai) = trunc(sysdate -1)   -- adhérents radiés dont le mouvement de radiation a été effectué la veille
    AND to_number(LPAD(ha.motif,4,0)) IN ( SELECT distinct to_number(substr(substr(code,6,9),1,4)) FROM libelle_bis WHERE mnemo LIKE 'MOTIF_PROD') --les motifs paramétrés selon le type de produit
    --AND ha.motif NOT IN (select distinct to_number(substr(substr(code,6,9),1,4)) FROM libelle_bis WHERE mnemo LIKE 'MOTIF_PROD' and substr(code,10,10)=1)  -- hors motif=18 fin de maintien de garantie Mail généré à M-1
    AND ha.motif <> p_motif -- hors motif=18 --fin de maintien de garantie --Mail généré à M-1
	AND NOT EXISTS (SELECT 1 FROM histo_adhesion ha3 where ha3.idadhesion = ha.idadhesion and ha3.IDHISTOADHE > ha.IDHISTOADHE )     -- pas de mouvement autre plus recent que la radiation
    AND 1 in (SELECT etat
            FROM histo_adhesion ha2
            WHERE ha2.idadhesion = a.idadhesion
            AND ha2.debut <= ha.debut
            AND ha2.IDHISTOADHE < ha.IDHISTOADHE
            order by ha2.IDHISTOADHE desc
            fetch first 1 row only)
    and  not exists (select distinct ad2.* from adhe_cntrt ad2, adhesion a2, histo_adhesion ha2, contrat_ref cr2 --verif si pas d'adhesion en vigueur/instance postérieure sur un autre contrat
                where ad2.numadhe=ad.numadhe --413077
                and ad2.idadhesion=a2.idadhesion
                and ad2.numgar=cr2.numgar
                and a2.numgar in (select cr2.numgar
                from contrat_ref cr2 where cr2.type_contrat = 1 ) -- sur contrat santé et pas d'obligation que le souscript soit le meme
                and ha2.etat in (0,1)
				AND trunc(a2.datapli) <> NVL(a2.datper,e2d('01/01/1900'))
                and trunc(a2.datapli)>trunc(a.datper) --trunc(sysdate)
				and pk_ws_web_back.F_ETAT_ADHE_WS(a_idadhesion=> a2.idadhesion, a_date    => greatest(ad2.date_adhe, sysdate),  a_type=>1) in (0,1) --en vigueur ou en instance

				)
    UNION
    SELECT distinct ad.numadhe, ad.idadhesion, ha.datsai, ha.motif, cr.numgar, cr.numprod, cr.numcli, a.datper
    FROM adhe_cntrt ad, histo_adhesion ha,adhesion a, contrat_ref cr
    WHERE ad.idadhesion = a.idadhesion
    AND ad.idadhesion = ha.idadhesion
    AND ad.numadhe = a.numindiv
    AND cr.numgar = a.numgar
	and cr.numprod NOT IN (select code from LIBELLE where mnemo like 'PRODEXCLU' and code <> -2) --RKO M0006951 exlusion des produits 198,204 et 384
	AND cr.numprod IS NOT NULL
	AND cr.type_contrat = 1--contrat santé RG3 exclusion des contrats prévoyance de l'envoi des mails et courriers
    AND trunc(a.datapli) <> NVL(a.datper,e2d('01/01/1900'))
    AND pk_ws_web_back.F_ETAT_ADHE_WS(a_idadhesion=> a.idadhesion, a_date    =>add_months(sysdate,1) ,  a_type=>1) = 3 --resilié  dans un mois
    AND pk_mail.check_demat_indiv(ad.numadhe) =1 --assuré dématérialisé
    AND ha.etat = 3
    --AND ha.motif IN (select distinct to_number(substr(substr(code,6,9),1,4)) FROM libelle_bis WHERE mnemo LIKE 'MOTIF_PROD' and substr(code,10,10)=1)  -- motif=18 --fin de maintien de garantie --Mail généré à M-1
    AND ha.motif = p_motif -- motif=18 --fin de maintien de garantie --Mail généré à M-1
	AND a.datper = ha.debut
	AND trunc(a.datper)> trunc(sysdate -90) -- pas de mail si radiation trop ancienne
    AND NOT EXISTS (SELECT idadhesion FROM adhesion a2 where a2.idadhesion =ad.idadhesion AND a2.datper IS NULL) --verif si pas couverture ouverte
    AND ((TRUNC(a.datper) = TRUNC(add_months(sysdate,1))) --fin de couverture dans un mois       -- exple  adhesion 482180 et 471804 finissent dans 1mois par rapport au 02/09 avec motif 18 --> Mail à M-1
       OR (TRUNC(a.datper) < TRUNC (add_months(sysdate,1)) AND TRUNC(ha.datsai)=TRUNC(sysdate-1)) -- saisie tardive de radiation
       OR TRUNC(sysdate) BETWEEN TRUNC(add_months(a.datper,-1)) AND TRUNC(add_months(a.datper,+1)) --mail envoyé à J+1 (date du jour) si la date du jour est dans la période comprise entre date de radiation-1mois (M-1) et date de radiation + 1mois (M+1). Dans le futur, on attend le M-1 de la date de radiation, pour emettre le mail à J + 1.
       )
    AND NOT EXISTS (SELECT 1 FROM histo_adhesion ha3 WHERE ha3.idadhesion = ha.idadhesion AND ha3.IDHISTOADHE > ha.IDHISTOADHE )     -- pas de mouvement autre plus recent que la radiation
    AND 1 in (SELECT etat
            FROM histo_adhesion ha2
            WHERE ha2.idadhesion = a.idadhesion
            AND ha2.debut <= ha.debut
            AND ha2.IDHISTOADHE < ha.IDHISTOADHE
            order by ha2.IDHISTOADHE desc
            fetch first 1 row only)

	;

  loc_envoi             ENVOI_MAIL%ROWTYPE;
  io_envoi              ENVOI_MAIL%ROWTYPE;
  loc_corps             MAIL_TEXTE.CORPS_MSG%TYPE;
  loc_sujet             MAIL_TEXTE.SUJET_MSG%TYPE;
  loc_template_mail     MAIL_TEXTE.TEMPLATE_MAIL%TYPE;
  loc_type_interloc     MAIL_TEXTE.TYPE_INTERLOCUTEUR%TYPE;
  loc_idlig             NUMBER:=0;
  v_prod_motif          libelle_bis.code%TYPE;
  v_idtexte             Number;
  loc_doubl_mail_resil  NUMBER;
  loc_motif_18          NUMBER;
  v_motif_profil3       NUMBER;
  v_deb                 NUMBER;
  v_delai               NUMBER;

BEGIN
	v_deb:=DBMS_UTILITY.GET_TIME;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_CHARGE_RESIL : début traitement '|| v_deb,
                               I_idligne  => loc_idlig+1);
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('RESIL',F_NUMUTIL) THEN
    BEGIN
		select distinct to_number(substr(substr(code,6,9),1,4)) into loc_motif_18
		FROM libelle_bis WHERE mnemo LIKE 'MOTIF_PROD' and substr(code,10,10)=1;
	EXCEPTION
		WHEN OTHERS THEN loc_motif_18 :=18;
	END;

    FOR  r_adhesion_resil  IN c_adhesion_resil(loc_motif_18)  LOOP
		BEGIN
            BEGIN
                select distinct to_number(substr(substr(code,6,9),1,4)) into v_motif_profil3  --RKO M0006959
                from libelle_bis
                WHERE mnemo LIKE 'MOTIF_PROD'
                and substr(code,1,5) =0 and tableau ='P3'
                and to_number(substr(substr(code,6,9),1,4))= r_adhesion_resil.motif;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN v_motif_profil3 := null;
                PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RESIL_REPRISE',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'ce n''est pas un profil 3 ou paramétrage manquant adhésion '||r_adhesion_resil.idadhesion ||' motif ' ||r_adhesion_resil.motif||' produit '||r_adhesion_resil.numprod||' idtexte '||loc_envoi.idtexte,
                               I_idligne  =>1);
            END;
			--recherche idtexte selon le numproduit et le motif de résil.
            IF v_motif_profil3 IS NOT NULL THEN   -- RKO M0006959
                select sens into v_idtexte --profil 3
                from libelle_bis
                where to_number(substr(substr(code,6,9),1,4))= v_motif_profil3--r_adhesion_resil.motif
                and mnemo LIKE 'MOTIF_PROD'
                ;
            --END IF;
			ELSE
				SELECT TO_CHAR(LPAD(decode(r_adhesion_resil.numprod,272,272,0),5,0)||LPAD(r_adhesion_resil.motif,4,0)) INTO v_prod_motif FROM dual;
				SELECT  sens /*(qui est idtexte)*/ INTO v_idtexte FROM libelle_bis WHERE mnemo LIKE 'MOTIF_PROD' and substr(code,1,9) = v_prod_motif;
			END IF;
			loc_envoi.idtexte := v_idtexte;
            PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'adhesion '||r_adhesion_resil.idadhesion ||' motif ' ||r_adhesion_resil.motif||' produit '||r_adhesion_resil.numprod||' idtexte '||loc_envoi.idtexte,
                               I_idligne  =>1);

        EXCEPTION
			WHEN OTHERS THEN v_prod_motif :=null; v_idtexte :=null; loc_envoi.idtexte :=null;
				PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Absence de paramétrage produit-motif pour mail. Motif :'||r_adhesion_resil.motif||' produit '||r_adhesion_resil.numprod||' adhesion '||r_adhesion_resil.idadhesion,
                               I_idligne  =>1);

		END;

        IF loc_envoi.idtexte IS NOT NULL THEN  --on creer le mail que s'il ya paramétrage

			SELECT corps_msg,
				  sujet_msg,
				  type_interlocuteur,
				  template_mail
			INTO loc_corps,
				loc_sujet,
				loc_type_interloc,
				loc_template_mail
			FROM mail_texte
			WHERE id_texte = loc_envoi.idtexte;

			loc_envoi.NUMINDIV_DEST:=r_adhesion_resil.numadhe;
			loc_envoi.NUMBENE:=r_adhesion_resil.numadhe;
			loc_envoi.NUMUTIL:= F_NUMUTIL;
			loc_envoi.etendue:=2; --adhesion
			loc_envoi.clef:= r_adhesion_resil.idadhesion;
			loc_envoi.NUMUTIL       := F_NUMUTIL;
			loc_envoi.sujet         := loc_sujet;
			loc_envoi.corps         := REPLACE(loc_corps, '#DATEFINADH', TO_CHAR(r_adhesion_resil.datper,'DD/MM/YYYY')) ;
			loc_envoi.template_mail := loc_template_mail;
			loc_envoi.TYPE_MAIL     := 3;   -- Automatique
			loc_envoi.DATE_CREATION := SYSDATE;
			io_envoi:=loc_envoi;

			IF r_adhesion_resil.motif = loc_motif_18 THEN	-- Uniquement pour le motif=18
				--On n'émet pas de mail si l'assuré a déjà été recu un mail l'informant de la radiation de son adhesion dans l'intervalle M-1 M+1 de la date debut de radiation
				select count(numenvoimail) INTO loc_doubl_mail_resil
				FROM envoi_mail
				where /*clef=r_adhesion_resil.idadhesion --RKO M0006950
				AND*/ numindiv_dest= r_adhesion_resil.numadhe
				AND numbene=r_adhesion_resil.numadhe
				AND trunc(date_creation) BETWEEN TRUNC(add_months(r_adhesion_resil.datper,-1)) AND TRUNC(add_months(r_adhesion_resil.datper,+1))
				AND TYPE_MAIL = 3
				AND idtexte in (SELECT  distinct sens FROM libelle_bis WHERE mnemo LIKE 'MOTIF_PROD'and sens<>1)--sécurité en cas de changement de motif dans les 90jrs
				AND (etat = 0 --non envoyé
					OR (etat = 1 AND TRUNC(datemis) BETWEEN TRUNC(add_months(r_adhesion_resil.datper,-1)) AND TRUNC(add_months(r_adhesion_resil.datper,+1)))
				)FETCH FIRST 1 ROWS ONLY;

				IF loc_doubl_mail_resil>0 THEN continue; --on ne cree pas le mail
				ELSE
					PK_MAIL.CREER_MAIL(io_envoi,'O');   -- désactivation du controle de doublon dans l'appel de creer_mail  RKO M0006950
					PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RESIL',
								   I_session  => SID,
								   I_niv_msg  => 3,
								   I_msg_adm  => 'P_CHARGE_RESIL : motif 18 mail crée assuré: '||io_envoi.numbene||' sur adhesion '||io_envoi.clef,
								   I_idligne  =>loc_idlig+1);
				END IF;
			ELSE
				PK_MAIL.CREER_MAIL(io_envoi);
				PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RESIL',
								   I_session  => SID,
								   I_niv_msg  => 3,
								   I_msg_adm  => 'P_CHARGE_RESIL : autre motif mail crée pour assuré: '||io_envoi.numbene||' sur io_envoi.clef '||io_envoi.clef,
								   I_idligne  =>loc_idlig+1);
			END IF;
        ELSE --si pas de paramétrage on trace
            PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RESIL_REPRISE',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'attention mail non crée car absence de paramétrage adhesion'||r_adhesion_resil.idadhesion ||'io_envoi.idtexte'|| io_envoi.idtexte,
                               I_idligne  =>1);
		END IF;--loc_envoi.idtexte IS NOT NULL

    END LOOP;
  END IF;
  v_delai:=DBMS_UTILITY.GET_TIME - v_deb;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RESIL',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'P_CHARGE_RESIL : temps de traitement en sec : '||v_delai/100,
                               I_idligne  =>loc_idlig+1);


EXCEPTION
  WHEN OTHERS THEN
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_RESIL',
                                 I_session  => SID,
                                 I_niv_msg  => 1,
                                 I_msg_adm  => ' Erreur: '||SQLERRM,
                                 I_idligne  => 1);
END P_CHARGE_RESIL;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_CHARGE_COT_INDIV                                        */
/* Type         :  Public                                                    */
/* Description  :  Mailing emission de cotisations individuelles             */
/*   exécuter lors de période de renouvellement uniquement                   */
/* Entree       :  P_date : date pivot de l'évènement déclencheur            */
/* Retour       :  aucun                                                     */
/*---------------------------------------------------------------------------*/
PROCEDURE P_CHARGE_COT_INDIV (P_date DATE) IS
  --cas fonctionnel N étant l'année d'appel de la procédure
  -- emission de cotisation N+1 en décembre ==> envoi en décembre et echéance de cotisation année suivante
  -- émission de cotisation N en janvier ==> envoi en décembre et echéance de cotisation année en cours
  --contrôle de doublon en lien pour gérer le cas des multi option émis à des dates différentes et des régularisations sous 10 mois

  CURSOR C_COT_INDIV (i_date DATE,p_idtexte NUMBER) IS
    SELECT q.numquerable ,MIN(idadhesion) idadhesion, TRUNC(f.echeance,'YEAR') echeance
    FROM emission e
    INNER JOIN facture f ON ( f.numfact = e.numfact AND f.codope = e.codope )
    INNER JOIN qttc_global q ON (q.numquit = f.numfact)
    INNER JOIN porte_contrat p ON (p.numgar = f_numgar_ref(q.numgar))
    WHERE TRUNC(e.datemis) = i_date
    AND q.type_qttc = 2 --non prévisionnelle
    AND q.idadhesion <>0 --indiv uniquement
    AND e.numrelance = 0
    AND e.codope = 4
    AND p.NUMPORTE = 25 --paramétrable ??
    AND NOT EXISTS (SELECT 1 FROM facture_annul WHERE facture_annul.numfact =  f.numfact AND codope =4) --non annulée
    AND NOT EXISTS (SELECT 1 FROM facture_regul WHERE facture_regul.numfact_regul =  f.numfact AND codope =4) --non régularisée
    AND EXISTS (SELECT 1 FROM courrier_info WHERE type_crrr = 28 AND moyen_info = 2 AND courrier_info.numindiv = q.numquerable)
    AND NOT EXISTS (SELECT 1 FROM envoi_mail WHERE  idtexte = p_idtexte AND numindiv_dest = q.numquerable  AND etat IN( 0,1)
      AND (datemis IS NULL OR ADD_MONTHS(datemis,10)>SYSDATE ))
    AND ((TO_CHAR(i_date,'MM') = '12'
        AND q.debut BETWEEN ADD_MONTHS(TRUNC(i_date,'YEAR'),12) AND ADD_MONTHS(TRUNC(i_date,'YEAR'),24)-1)
      OR (TO_CHAR(i_date,'MM') = '01'
        AND q.debut BETWEEN TRUNC(i_date,'YEAR') AND  ADD_MONTHS(TRUNC(i_date,'YEAR'),12)-1 ))
    GROUP BY numquerable, TRUNC(f.echeance,'YEAR');

   loc_envoi envoi_mail%ROWTYPE;
   io_envoi envoi_mail%ROWTYPE;
BEGIN
 PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_COT_INDIV',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Début traitement',
                               I_idligne  => 1);
  IF P_date IS NULL THEN RETURN;
  END IF;

  --traitement uniquement du 15/12 au 31/01
  IF PK_MAIL.CHECK_DROIT_ENVOI_MAIL('COTI',F_NUMUTIL)
    AND (P_date>= e2d('15/12/'||to_char(P_date,'YYYY'))
    OR  P_date<= e2d('31/01/'||to_char(P_date,'YYYY'))) THEN
    --initialisation de loc_envoi
    loc_envoi.idtexte :=  52 ;
    loc_envoi.NUMUTIL       := F_NUMUTIL;
    loc_envoi.DATE_CREATION := SYSDATE;
    loc_envoi.etendue       := 2;
    loc_envoi.TYPE_MAIL     := 5;   -- campagne mailing
    SELECT corps_msg,
           sujet_msg,
           template_mail
    INTO loc_envoi.corps,
         loc_envoi.sujet ,
         loc_envoi.template_mail
    FROM mail_texte
    WHERE id_texte = loc_envoi.idtexte;
    PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_COT_INDIV',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Intialisation du mail effectuée',
                               I_idligne  => 1);
    --création des emails de cotisations
    FOR R_COT_INDIV IN C_COT_INDIV(P_date,loc_envoi.idtexte)  LOOP

      loc_envoi.NUMINDIV_DEST := R_COT_INDIV.numquerable;
      loc_envoi.NUMBENE       := R_COT_INDIV.numquerable;
      loc_envoi.clef          := R_COT_INDIV.idadhesion;
      loc_envoi.sujet         := REPLACE(loc_envoi.sujet, '#ANNEE', TO_CHAR(R_COT_INDIV.echeance,'YYYY')) ;
      loc_envoi.corps         := REPLACE(loc_envoi.corps, '#ANNEE', TO_CHAR(R_COT_INDIV.echeance,'YYYY')) ;

      io_envoi:=loc_envoi;
      PK_MAIL.CREER_MAIL(I_envoi_mail => io_envoi,
                         i_desactiv_ctrl_doublon => 'O');

    END LOOP;
  END IF;
  PK_trace.P_INS_journal_adm ( I_nom_traitement => 'P_CHARGE_COT_INDIV',
                               I_session  => SID,
                               I_niv_msg  => 1,
                               I_msg_adm  => 'Fin traitement',
                               I_idligne  => 9);

END P_CHARGE_COT_INDIV;
END PK_MAIL;
/
