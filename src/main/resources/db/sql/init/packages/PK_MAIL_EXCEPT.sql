CREATE OR REPLACE PACKAGE ARTHUS.PK_MAIL_EXCEPT IS

/* Table declaration for storing e-mail attachment file names. */
type attachment is record (filename varchar2(100));
type tab_of_attachments is table of attachment;
/* Package Function and procedures. */
 /*
    Insere un Mail dans Envoi Mail
 */
PROCEDURE CREER_MAIL( I_envoi_mail IN OUT ENVOI_MAIL%ROWTYPE);

PROCEDURE MAIL_JOB (i_job IN VARCHAR2, nb_mess_erreur  in out NUMBER,i_template IN VARCHAR2);

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
                        P_ERROR OUT VARCHAR2);


PROCEDURE P_CREATE_MAILING;
PROCEDURE P_SEND_ALL_MAILING (i_type_mail IN NUMBER);
PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);


END PK_MAIL_EXCEPT;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_MAIL_EXCEPT IS


  PROCEDURE CLOSEFILE(fil IN OUT BFILE);


 -- -- Déclaration des variables globales   ----------------------------------
  g_session         journal_adm.id_session%TYPE DEFAULT 1;
  g_nom_traitement  journal_adm.nom_traitement%TYPE:='MA02T';
  g_niv_msg         journal_adm.niv_msg%TYPE;
  g_idligne         journal_adm.idligne%TYPE default 0;
  g_msg_adm         journal_adm.msg_adm%TYPE;

PROCEDURE P_CREATE_MAILING IS
    loc_envoi ENVOI_MAIL%ROWTYPE;

    CURSOR c_popu IS  -- PBO M0006922 Périmètre d'envoi du 14/12/2020
      SELECT DISTINCT
        i.numindiv                                                                 --  ADHERENT
--       ,f_nom(i.numindiv)                                                            NOM_PRENOM
--       ,ad.idadhesion                                                                ADHESION
--      ,c.coordonnee                                                                 EMAIL
--       ,DECODE(c.type,1,'Pro',2,'Perso')                                             TYPE_EMAIL
--       ,ad.numgar                                                                    CONTRAT
      FROM individu i
      INNER JOIN adhe_cntrt ac    ON ac.numadhe    = i.numindiv
      INNER JOIN adhesion ad      ON ad.idadhesion = ac.idadhesion
      INNER JOIN contact c        ON ac.numadhe    = c.numindiv
      INNER JOIN gar_cntrt_ref gc ON gc.numgar     = ad.numgar
      INNER JOIN formule f       ON f.numfor      = gc.numfor
      WHERE 1=1
        AND ad.numindiv = ac.numadhe                                                                    -- 1 adhésion/adherent (question de performance)
        AND pk_ws_web_back.F_ETAT_ADHE_WS(ad.idadhesion, greatest(sysdate,ac.date_adhe)) = 1            -- adhésions en vigueur à date ou dans le futur
        AND ad.rang = 1                                                                                 -- rang 1 dans l'ordre de prise en compte de la garantie dans les calculs de prestation (Uniquement en Santé)
        AND TRUNC(ad.datapli) <> NVL(TRUNC(ad.datper), e2d('01/01/1900'))                               -- exclusion des adhesions ouvertes et fermees le mm jour
        AND (c.nature= 4 AND c.flag = 'O')                                                              -- avec une adresse Email renseignée par défaut quelqu'en soit la nature
        AND c.coordonnee = NVL(f_coordonne_contact(i.numindiv,4,2),f_coordonne_contact(i.numindiv,4,1))
        AND ad.typfor = 1                                                                               -- Garantie soins de santé
        AND f.typgar = 1                                                                                -- garantie de base
 ;

BEGIN
for r_indiv in c_popu loop
loc_envoi := null;
    loc_envoi.corps := NULL;
    loc_envoi.sujet := '=?windows-1252?Q?Votre carte de Tiers-Payant est bient=F4t disponible !?='; --PBO M0006922 Périmètre d'envoi du 14/12/2020
    loc_envoi.NUMINDIV_DEST:=r_indiv.numindiv;
    loc_envoi.NUMBENE:=r_indiv.numindiv;
    loc_envoi.NUMUTIL:= 8;
    loc_envoi.etendue:= 0;   -- rendre le contexte dynam
    loc_envoi.clef:= 0;        -- changer le contexte
    loc_envoi.IDTEXTE:= null;
    loc_envoi.TYPE_MAIL:=5;   -- Rapport
    loc_envoi.DATE_CREATION:=SYSDATE;
    --loc_envoi.template_mail :=i_template; -- permet de savoir quel template utiliser
    PK_MAIL.CREER_MAIL(loc_envoi);
end loop;
END P_CREATE_MAILING;

PROCEDURE P_SEND_ALL_MAILING (i_type_mail IN NUMBER)is
  -- MUR M0005764 ajout idtexte 33 - Accusé de reception demande affiliation  -  pour envoi du mail au fil de l'eau
  -- ABO M0005769 ajout idtexte 31 - mail hebdo pour RH récapitulatif
  CURSOR c_liste_mails IS
  SELECT  numenvoimail FROM envoi_mail
    WHERE type_mail = i_type_mail
    AND nvl(etat,0) = 0 -- on prend les mails a envoyer
    AND datemis IS NULL -- double sécurité, on ne prend que les mail n'ayant pas de date d'émission.
    AND sujet = '=?windows-1252?Q?Votre carte de Tiers-Payant est bient=F4t disponible !?=';   --PBO M0006922 Périmètre d'envoi du 14/12/2020

   mails_in_error ty_mail_in_error;
  nb_msg_err NUMBER(5) :=0;
  nb_msg_err_copy NUMBER(5) :=0;
  nb_msg_tot NUMBER(5) :=0;
  date_session Date := sysdate;
  Rec_mail  c_liste_mails%ROWTYPE;
  loc_heure number;
  loc_min   number;
BEGIN


  mails_in_error  :=  ty_mail_in_error();
  -- selection des mails a envoyer
  OPEN c_liste_mails;
  LOOP
    FETCH c_liste_mails INTO Rec_mail;
    EXIT WHEN c_liste_mails%NOTFOUND;
      SELECT to_char(sysdate, 'hh24') into loc_heure FROM DUAL;
      SELECT to_char(sysdate, 'mi') into loc_min FROM DUAL;
      IF loc_heure >=23 AND loc_min>30 THEN
        EXIT;--dernier traitement à 23h30
      END IF;
        nb_msg_tot := nb_msg_tot+1;
         P_INS_journal(3,'Id  de mail a envoyer ' || Rec_mail.numenvoimail  );
         PK_MAIL_EXCEPT.MAIL_JOB(Rec_mail.numenvoimail,nb_msg_err, 'Emailing_DISPO_Carte_TP_ENVOI2.html');            -- PBO M0006922 Périmètre d'envoi du 14/12/2020
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
  dbms_output.put_line ('P_SEND_ALL_MAIL_JOB Nb mail en erreur =['||nb_msg_err||']');
/*  P_SEND_RAPPORT_ENVOI_MAIL(i_nb_mail_error=>nb_msg_err,
                            nb_total_msg =>nb_msg_tot,
                            i_date_session=>date_session,
                            i_mails_in_error => mails_in_error
                            );*/
END P_SEND_ALL_MAILING;

    /*
        Procédure inserant le mail dans Envoi_Mail.
    */
PROCEDURE CREER_MAIL( I_envoi_mail IN OUT ENVOI_MAIL%ROWTYPE)IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  loc_doublon  ENVOI_MAIL.NUMENVOIMAIL%TYPE;
  loc_etat ENVOI_MAIL.ETAT%TYPE;
BEGIN

  P_INS_journal(3,'dans la procédure de création');
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
    AND trunc(date_creation) = trunc(sysdate)
    AND (etat = 0 --non envoyé
     OR (etat = 1 AND TRUNC(datemis) = TRUNC(SYSDATE)));    --envoyé le même jour

  EXCEPTION
  WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN return;--plusieurs doublons
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
    RETURN;
  END IF;

  SELECT NUMENVOIMAIL.nextval INTO I_envoi_mail.NUMENVOIMAIL FROM DUAL;
  I_envoi_mail.etat :=0;

  IF I_envoi_mail.destinataire IS NULL THEN
     I_envoi_mail.destinataire :=NVL(f_coordonne_contact(I_envoi_mail.numindiv_dest,4,2),f_coordonne_contact(I_envoi_mail.numindiv_dest,4,1)) ; --adresse perso puis pro par défaut
    -- P_INS_journal(1,'Destinataire :' ||I_envoi_mail.destinataire);
  END IF;

  IF I_envoi_mail.sujet IS NULL  THEN
    RETURN;
  END IF;

  IF I_envoi_mail.destinataire  IS NOT NULL THEN
    INSERT INTO ENVOI_MAIL VALUES I_envoi_mail ;
  END IF;

  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN

    P_INS_journal(3,'[Creation mail]impossible, numDest['||I_envoi_mail.numindiv_dest||'] étendue['||I_envoi_mail.etendue||'] clef['||I_envoi_mail.clef||']');
    g_idligne :=0; -- remise a 0 de l'id ligne pour les opéarations réalisées par le ws qui as toujours la même sessions et par conséquente ne remet pas 0 le package
    ROLLBACK;
END CREER_MAIL;

PROCEDURE MAIL_JOB (i_job IN VARCHAR2, nb_mess_erreur  in out NUMBER,i_template IN VARCHAR2) is

  loc_envoi           envoi_mail%ROWTYPE;
   loc_type_interloc number;
  po_err_msg          varchar2(1000);
  loc_idtexte         envoi_mail.idtexte%TYPE;
  loc_lib_nom         param_texte.lib_nom%TYPE;
  loc_type_mail       ENVOI_MAIL.TYPE_MAIL%TYPE;
  loc_corps_clob       CLOB;
  text CLOB:='';
  logo_clob_64 CLOB:='';
  l_templatename VARCHAR2(100):='template_mail_defaut.html';
  l_adresse_envoyeur VARCHAR2(100);


  BEGIN
  P_INS_journal(1,'Envoi du mail['||i_job||']');
  /* Le numenvoimail doit etre obligatoirement egal au numero du job */
    SELECT *
    INTO  loc_envoi
    FROM   envoi_mail
    where numenvoimail = i_job;

    -- récuperation du message paramétré dans mail_texte lorsque l'email est automatique
   /* IF loc_envoi.type_mail  IN (1,3,5) AND loc_envoi.sujet IS NULL THEN
      BEGIN
        SELECT corps_msg, sujet_msg
        INTO loc_corps_clob,loc_envoi.sujet
        FROM mail_texte
        WHERE id_texte = loc_envoi.idtexte;

	   -- misea jour de l'objet(sujet) du mail avec le sujet  de MAIL_TEXT
       UPDATE envoi_mail SET sujet = loc_envoi.sujet , corps = loc_corps_clob  WHERE numenvoimail = i_job;

      EXCEPTION
        WHEN no_data_found THEN
          loc_corps_clob := loc_envoi.corps;
      END;
    ELSE
      loc_corps_clob := loc_envoi.corps;
    END IF;*/


    l_templatename := i_template;

    /* remplacement des caracteres speciaux  au format HTML */
    loc_corps_clob := replace(loc_corps_clob, '"', '&' || 'quot;');

    DBMS_LOB.createtemporary(text, true);
    dbms_output.put_line(l_templatename);
    text:='';
    -- Build the start of the HTML document, i
    --recupération de l'entete html du message
    GET_HTML_VARCHAR_FROM_FS('MAILS_IN', l_templatename, text);

    /*PK_MAIL.transcode_template( template_mail=>text,
                                corps_msg =>loc_corps_clob,
                                numindiv=>loc_envoi.numindiv_dest,
                                numbene=>loc_envoi.numbene,
                                sujet_msg =>loc_envoi.sujet);*/

    --récuperation de l'adresse de l'expéditeur en fonction du domaine fonctionnel
    BEGIN
      IF loc_envoi.type_mail IN (1 ,3,5 )THEN       -- les mail automatiques parte avec l'adresse toutes opération.
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
    EXCEPTION WHEN NO_DATA_FOUND THEN  --si pas d'interlocuteur pour l'étendue, prendre l'interlocuteur par default
     SELECT NVL(f_coordonne_contact(interlocuteur,4,2),f_coordonne_contact(interlocuteur,4,1))
            INTO l_adresse_envoyeur
            from interlocuteur where NUMINDIV=1
            and OPE_CRRR = 0;
    END;

    IF loc_envoi.destinataire IS NULL THEN
        select count(type_interlocuteur)
        into loc_type_interloc
        from mail_texte
        where id_texte =  loc_envoi.idtexte;
        IF loc_type_interloc =1 then
          loc_envoi.destinataire:= NVL(f_coordonne_contact(loc_envoi.numindiv_dest,4,1),f_coordonne_contact(loc_envoi.numindiv_dest,4,2))  ;
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
          P_ERROR => po_err_msg);
    END IF;

    IF (po_err_msg ='' OR po_err_msg is null) THEN
      UPDATE ENVOI_MAIL e SET e.ETAT = 1, datemis=sysdate
      WHERE e.NUMENVOIMAIL = i_job;  --on passe mail a envoyé
    ELSE
      UPDATE ENVOI_MAIL e SET e.ETAT = 2, datemis=sysdate, mess_erreur =   po_err_msg
      WHERE e.NUMENVOIMAIL = i_job;  --on passe mail en erreur
      nb_mess_erreur :=nb_mess_erreur+1;
      P_INS_journal(1,'NUMENVOI DU MAIL=['||i_job||']'||po_err_msg);
    END IF;
    COMMIT;
    /*if loc_numedit is not null then
    UTL_FILE.FREMOVE('DIR_PDF_OUT', 'Piecejointe1.PDF');
    end if;*/
END MAIL_JOB;





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
  v_subject VARCHAR2(150) := P_SUBJECT;
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


  /* Use this mime type when multiple attachments of different types are sent. */
  v_mime_type_bin varchar2(30) := 'application/octet-stream';
  BOUNDARY CONSTANT VARCHAR2(256) := '__7D81B75CCC90D2974F7A1CBD__';
  MULTIPART_MIME_TYPE CONSTANT VARCHAR2(256) := 'multipart/related;type="multipart/alternative"; boundary="'||BOUNDARY || '"';

  -- working storage
  files tab_of_attachments;
  t_file_count number := 0;

  CURSOR c_images (i_mnemo libelle.mnemo%type) IS

     --PBO M0006922 périmètre d'envoi du 14/12/2020
     SELECT  'appstore_badge.jpg' as filename,'jpg' as type FROM DUAL
     UNION SELECT 'Bouton_creation_IRIS.jpg' as filename,'jpg' as type FROM DUAL
     UNION SELECT 'Bouton_IRIS_Carte_TP.jpg' as filename,'jpg' as type FROM DUAL
     UNION SELECT 'google-play-badge.jpg' as filename,'jpg' as type FROM DUAL
     UNION SELECT 'IRIS_DISPO_TP.jpg' as filename,'jpg' as type FROM DUAL
     UNION SELECT 'Logo_Gerep_Couleurs_BD.jpg' as filename,'jpg' as type FROM DUAL
     UNION SELECT 'Tampon_IRIS_48H.jpg' as filename,'jpg' as type   FROM DUAL
     ;

  rec_image     c_images%ROWTYPE;


  BEGIN
    /*remise en ordre des pieces jointe*/
    PK_MAIL.P_ORDRE_PC(t_file1, t_file2, t_file3, t_file4);
    SELECT *
    INTO loc_smtp
    FROM param_machine
    WHERE srv_type='M';

    -- on n'utilise plus le compte mail des utilisateurs mais un compte mail par étendue (domaine fonctionnel)
    DBMS_OUTPUT.PUT_LINE('avant requette param_machine');

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
    v_corps := replace(v_corps, 'Ô', '&' || 'Ocirc;'); -- M0006922
    --v_corps := replace(v_corps, '€', '&' || 'euro;');     non compatible avec tout les navigateurs.

     -- cli supprime les accent dans le sujet du mail, mais pas dans le corps.
    v_subject := replace(v_subject, 'à',  'a');
    v_subject := replace(v_subject, 'è',  'e');
    v_subject := replace(v_subject, 'é',  'e');
    v_subject := replace(v_subject, 'ê',  'e');
    v_subject := replace(v_subject, 'ê',  'e');
    v_subject := replace(v_subject, 'ç',  'c');
    v_subject := replace(v_subject, 'â',  'a');
    v_subject := replace(v_subject, 'î',  'i');
    v_subject := replace(v_subject, 'ï',  'i');
    v_subject := replace(v_subject, 'œ',  'oe');
    v_subject := replace(v_subject, 'ù',  'u');
    v_subject := replace(v_subject, 'û',  'u');
    v_subject := replace(v_subject, 'À',  'A');
    v_subject := replace(v_subject, 'Â',  'A');
    v_subject := replace(v_subject, 'É',  'E');
    v_subject := replace(v_subject, 'È',  'E');
    v_subject := replace(v_subject, 'Ê',  'E');
    v_subject := replace(v_subject, 'Î',  'I');
    v_subject := replace(v_subject, 'Ï',  'I');
    v_subject := replace(v_subject, 'Œ',  'OE');

    v_subject := replace(v_subject, 'Ù',  'U');
    v_subject := replace(v_subject, 'Û',  'U');
    v_subject := replace(v_subject, 'Ç',  'C');
    v_subject := replace(v_subject, 'ô',  'o'); --RKO M0006570
    v_subject := replace(v_subject, '–',  '-');

DBMS_OUTPUT.PUT_LINE('aprés requette param_machine');

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
      conn := PK_MAIL.begin_mail( i_smtp => loc_smtp,
                          sender => P_SENDER,
                                  recipients => P_RECIPIENT,
                                  cc => P_CC,
                                  bcc => P_BCC,
                                  subject => v_SUBJECT,
                                  mime_type => MULTIPART_MIME_TYPE);
    END ;
DBMS_OUTPUT.PUT_LINE('après connection');

    BEGIN
      PK_MAIL.attach_text(conn => conn,data => v_corps,mime_type => 'text/html');
    END attach_text;

DBMS_OUTPUT.PUT_LINE('après attache text');

   BEGIN
    OPEN c_images(trim('IMG_MAIL'||PK_MAIL.F_MARQUE_template(p_numindiv_dest)));
    LOOP
      FETCH c_images INTO rec_image;
      dbms_output.put_line(rec_image.filename) ;
      EXIT WHEN c_images%NOTFOUND;
      BEGIN
      PK_MAIL.ATTACH_IMAGE(conn=> conn,  typeimage =>rec_image.type ,inline=> true ,filename => rec_image.filename ,last => false);
      EXCEPTION
      WHEN OTHERS THEN
      dbms_output.put_line(rec_image.filename ||'-ERR '||SQLERRM) ;
      END;
    END LOOP;
    IF c_images%ISOPEN THEN
       CLOSE c_images;
    END IF;
     DBMS_OUTPUT.PUT_LINE('après images');
   END ATTACH_IMAGES;

    BEGIN
      -- check to see if there are any attachments (otherwise the loop will error!)
      IF t_file_count > 0 THEN
        -- loop through attachments
        FOR i in 1..files.COUNT LOOP
          PK_MAIL.begin_attachment(conn => conn, mime_type => v_mime_type_bin, inline => TRUE, filename => files(i).filename, transfer_enc => 'base64');

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
              PK_MAIL.write_raw( conn => conn,
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


          PK_MAIL.end_attachment(conn => conn );

        END LOOP;
      END IF;

    END begin_attachment;


    PK_MAIL.end_mail(conn => conn);

    EXCEPTION
    WHEN no_data_found THEN
      --end_attachment( conn => conn );
      CLOSEFILE(fil);
      P_ERROR := 'Aucune données trouvées pour l''email, lors de l''envoi';
      P_INS_journal(3,'Probléme lors de l''envoi du mail =[' || P_ERROR||']');
    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SUBSTR(SQLERRM, 1, 100);
      P_ERROR := 'Mail en erreur: '||err_num||' - '||err_msg;
      P_INS_journal(3,'Probléme lors de l''envoi du mail =[' || P_ERROR||']');
      --dbms_output.put_line('Error number is ' || err_num);
      --dbms_output.put_line('Error message is ' || err_msg);
      --end_attachment( conn => conn );

      CLOSEFILE(fil);
END SEND_EMAIL;



PROCEDURE CLOSEFILE(fil IN OUT BFILE) IS
BEGIN
  dbms_lob.fileclose(fil);
  EXCEPTION WHEN OTHERS THEN NULL;
END CLOSEFILE;

END PK_MAIL_EXCEPT;
/
