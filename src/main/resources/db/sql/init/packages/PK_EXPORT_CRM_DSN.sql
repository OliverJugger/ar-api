CREATE OR REPLACE PACKAGE ARTHUS.PK_EXPORT_CRM_DSN
AS
/*============================================================================*/
/* Package      : PK_EXPORT_CRM_DSN.sql                                       */
/* Domaine      : Compte-rendu Metier DSN (CRM)                               */
/* Version      : V1.0                                                        */
/* Auteur       : BCO                                                         */
/* Création     : 07/07/2020                                                  */
/* Description  : Constitution d un bordereau de CRM DSN  (AF14T)             */
/*              : Annulation d un bordereau de CRM DSN    (AF15T)             */
/*              : Génération du fichier CRM DSN           (AF16T)             */
/*============================================================================*/



PROCEDURE P_GENERER_CRM_DSN_AUTO;

-- Génération d un bordereau de CRM DSN    (AF14T)
PROCEDURE P_AF14 ( i_traitement    IN    TYP_BATCH.BATCHID%TYPE
                  ,i_numporte      IN    REMISE_EXTERNE.NUMPORTE%TYPE
                  ,i_numremise     IN    PORTE_REMISE.NUMREMISE%TYPE DEFAULT NULL
                  ,i_session       IN    JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1
                  ,o_numremise_crm OUT   REMISE_EXTERNE.NUMREMISE%TYPE
                  ,o_cptrendu      IN OUT   CLOB);

-- Annulation d un bordereau de CRM DSN    (AF15T)
PROCEDURE P_AF15 ( i_traitement    IN  TYP_BATCH.BATCHID%TYPE
                  ,i_numporte_ext  IN  REMISE_EXTERNE.NUMPORTE%TYPE
                  ,i_numremise_ext IN  REMISE_EXTERNE.NUMREMISE%TYPE
                  ,i_session       IN  JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1
                  ,i_niv_msg       IN  NUMBER);


-- Génération du fichier CRM DSN           (AF16T)
PROCEDURE P_AF16 ( i_traitement    IN  TYP_BATCH.BATCHID%TYPE
                  ,i_numremise_ext IN  REMISE_EXTERNE.NUMREMISE%TYPE
                  ,i_session       IN  JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1
                  ,i_niv_msg       IN  NUMBER DEFAULT 1
                  ,o_cptrendu      IN OUT   CLOB);

-- Renvoie le libellé d'un bloc ou d'un champs DSN
--   par exemple S21.G00.15.002 => 'Code organisme de Prévoyance'
--               S21.G00.15     => 'Adhésion Prévoyance'
FUNCTION F_LIB_ENTITE_DSN (i_entiteDSN IN VARCHAR2 ) RETURN VARCHAR2;


PROCEDURE P_INS_journal( i_niv  in NUMBER,
                         i_msg  in VARCHAR2,
                         i_msg2 in varchar2 := null);


END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_EXPORT_CRM_DSN AS
/*============================================================================*/
/* Package      : PK_EXPORT_CRM_DSN.sql                                       */
/* Domaine      : Compte-rendu Metier DSN (CRM)                               */
/* Version      : V1.0                                                        */
/* Auteur       : BCO                                                         */
/* Création     : 07/07/2020                                                  */
/* Description  : Constitution d un bordereau de CRM DSN  (AF14T)             */
/*              : Annulation d un bordereau de CRM DSN    (AF15T)             */
/*              : Génération du fichier CRM DSN           (AF16T)             */
/*============================================================================*/

--VARIABLES GLOBALES
g_nom_traitement  journal_adm.nom_traitement%TYPE DEFAULT 'AF14T';
g_niv_msg         journal_adm.niv_msg%TYPE := NULL;
g_idligne         journal_adm.idligne%TYPE := 0;
g_msg_adm         journal_adm.msg_adm%TYPE;
g_session         NUMBER;



/*---------------------------------------------------------------------------*/
/* Fonction                                                                  */
/* Nom          :  F_CRM_FILENAME                                            */
/* Type         :  Public                                                    */
/* Description  :  Détermine le nom du fichier CRM DSN à produire            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_CRM_FILENAME( i_concentrateur  IN DSN_CRM.CONCENTRATEUR%TYPE
                        ,i_numremise_ext  IN REMISE_EXTERNE.NUMREMISE%TYPE
                        -- date/heure de ref
                        ,i_timestamp      IN DATE
                        -- Code organisme S21.G00.15.002
                        ,i_orgn           IN AFFIL_PORTE_CNTRT.ORGN%TYPE
                        -- Code délégataire de gestion S21.G00.15.003
                        ,i_deleg          IN AFFIL_PORTE_CNTRT.DELEG%TYPE
                        -- N° ordre déclaration S20.G00.05.004
                        ,i_num_ordre      IN AFFIL_FICHIER.NUM_ORDRE%TYPE
                        -- Identifiant déclaration S20.G00.96.902
                        ,i_iddeclardsn    IN AFFIL_FICHIER.IDDECLARDSN%TYPE
                        -- Identifiant de l'envoi S10.G00.95.900
                        ,i_idenvoi        IN AFFIL_FICHIER.IDENVOI%TYPE
                        ,i_idTechniqueFichierCRMCetip IN VARCHAR2
                        ,i_VersionCRM     IN NUMBER
                        ,i_Iddsncrm       IN DSN_CRM.IDDSNCRM%TYPE
                       ) RETURN VARCHAR2
IS
  o_filename           VARCHAR2(100);

BEGIN

  CASE i_concentrateur
    WHEN 'FFSA' THEN
      -- DSN_CRM_{idTechniqueFichier}_AAAAMMJJ-HHMMSS.xml
      o_filename := 'DSN_CRM'
                 || '_' || TO_CHAR(i_numremise_ext)
                 || '_' || TO_CHAR(i_timestamp,'YYYYMMDD"-"HH24MISS')
                 || '.xml' ;
    WHEN 'CTIP' THEN
     -- «DSN_CRM_{idTechniqueFichier}_{VersionCRM}_{codeProducteurCrm}_{identifiantObjetCRM}.xml»
     --    * idTechniqueFichier (Numérique) : Identifiant technique, interne au concentrateur IP, de
     --        la déclaration faisant l’objet du CRM (identifiant précédemment transmis dans le nom de la DSN).
     --        Cet identifiant permet au concentrateur IP de rattacher à la déclaration d’origine un ou
     --        plusieurs CRM produits par l’IP et/ou le délégataire. Numérique sur 10 caractères au plus.
     --    * VersionCRM (Numérique) : Numéro de version du schéma utilisé par le CRM, correspondant à
     --        l’attribut « VersionCRM » du CRM XML. Numérique sur 3 caractères. Valeurs autorisées à ce
     --        jour : « 113 » et « 114 ».
     --    * codeProducteurCrm (Chaîne de caractères) : Code du producteur du CRM (identifiant de l’OPS ou d’un
     --        délégataire de gestion), alphanumérique de 5, 6 ou 9 caractères suivant [P][0-9]{4} ou [A][0-9A-Z]{5}
     --        ou [0-9]{9} ou [D][0-9A-Z]{5} ou [G][0-9A-Z]{5}
     --    * identifiantObjetCRM (Chaîne de caractères) : Identifiant de l'objet CRM pour l'émetteur du CRM (nom
     --        de fichier par exemple, ou toute autre information permettant à l’émetteur d’identifier sans ambigüité
     --        l’objet CRM produit). Alphanumérique de 1 à 30 caractères.

      o_filename := 'DSN_CRM'
                 || '_' || TO_CHAR(i_idTechniqueFichierCRMCetip)
                 || '_' || TO_CHAR(i_VersionCRM)
                 || '_' || i_deleg
                 || '_' || TO_CHAR(i_Iddsncrm)
                 || '_' || TO_CHAR(i_timestamp,'YYYYMMDD"-"HH24MISS')
                 || '.xml' ;


    WHEN 'FNMF' THEN
        -- <Identifiant de l’émetteur du CRM>_<Identifiant de la DSN>_<AAAAMMJJ-HHMMSS>.xml
        -- Avec :
        -- - Identifiant de l’émetteur :
                  -- SIREN du porteur de risque ou code du délégataire (6 à 9 caractères)

        -- - Identifiant de la DSN : [id ops]-[code délégataire]-[num rang]- [num déclaration]-[id flux] :
        --             [id ops] = S21.G00.15.002 (9 caractères)
        --             [code délégataire] = S21.G00.15.003, ou « PASDLG » si la rubrique est non renseignée, (6 caractères)
        --             [num rang] = S20.G00.05.004 (1 à 15 caractères)
        --             [num déclaration] = S20.G00.96.902 (6 caractères)
        --             [id flux] = S10.G00.95.900 (50 caractères)
        --             _CRM : suffixe d’identification du contenu du fichier
        -- - Horodatage du flux par l’émetteur (15 caractères)
      o_filename := i_deleg
                 || '_' || i_orgn
                 || '-' || NVL(i_deleg,'PASDLG')
                 || '-' || i_num_ordre
                 || '-' || i_iddeclardsn
                 || '-' || i_idenvoi
                 || '_CRM_'
                 || TO_CHAR(i_timestamp,'YYYYMMDD"-"HH24MISS')
                 || '.xml' ;
    ELSE
      o_filename := NULL;

  END CASE;
  RETURN o_filename ;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_JOURNAL(1,'ERREUR F_CRM_FILENAME: impossible de déderminer le nom du fichier CRM à produire');
    P_INS_JOURNAL(1,'ERREUR F_CRM_FILENAME: ' ||sqlerrm);
    P_INS_JOURNAL(1,'ERREUR F_CRM_FILENAME i_concentrateur               '|| i_concentrateur             );
    P_INS_JOURNAL(1,'ERREUR F_CRM_FILENAME i_numremise_ext               '|| i_numremise_ext             );
    P_INS_JOURNAL(1,'ERREUR F_CRM_FILENAME i_timestamp                   '|| i_timestamp                 );
    P_INS_JOURNAL(1,'ERREUR F_CRM_FILENAME i_orgn                        '|| i_orgn                      );
    P_INS_JOURNAL(1,'ERREUR F_CRM_FILENAME i_deleg                       '|| i_deleg                     );
    P_INS_JOURNAL(1,'ERREUR F_CRM_FILENAME i_num_ordre                   '|| i_num_ordre                 );
    P_INS_JOURNAL(1,'ERREUR F_CRM_FILENAME i_iddeclardsn                 '|| i_iddeclardsn               );
    P_INS_JOURNAL(1,'ERREUR F_CRM_FILENAME i_idenvoi                     '|| i_idenvoi                   );
    P_INS_JOURNAL(1,'ERREUR F_CRM_FILENAME i_idTechniqueFichierCRMCetip  '|| i_idTechniqueFichierCRMCetip);
    P_INS_JOURNAL(1,'ERREUR F_CRM_FILENAME i_VersionCRM                  '|| i_VersionCRM                );

    RETURN NULL;

END F_CRM_FILENAME;

/*************Procédure d'envoi de mail *********/
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_SEND_RAPPORT_ENVOI_MAIL                                 */
/* Type         :  Privé                                                     */
/* Description  :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/

PROCEDURE P_SEND_RAPPORT_ENVOI_MAIL(i_date_session DATE
                                   ,i_cptrendu     CLOB)
IS
  l_error            VARCHAR2(200);
  l_clob_body        CLOB;

  l_sujet            VARCHAR2(2000);
  l_corps            CLOB;

  l_destinataire     VARCHAR2(60);
BEGIN


  l_destinataire  := 'dsn@gerep.fr';               -- TODO En dur à revoir
  --l_destinataire  := 'b.cortial@cat-amania.com';

  l_sujet := '[Rapport_ARTHUS] Rapport de génération de CRM DSN automatique '
                    || i_date_session
                    || ' sur l''instance '|| f_get_instance();
  l_corps := i_cptrendu ;

  GET_HTML_VARCHAR_FROM_FS('MAILS_IN', 'template_mail_rapport.html', l_clob_body);
  PK_MAIL.TRANSCODE_TEMPLATE( template_mail => l_clob_body
                             ,corps_msg     => l_corps
                             ,numindiv      => NULL
                             ,numbene       => NULL
                             ,sujet_msg     => l_sujet);

  PK_MAIL.SEND_EMAIL( P_RECIPIENT     => l_destinataire
                     ,P_CC            => NULL
                     ,P_BCC           => NULL
                     ,P_SUBJECT       => l_sujet
                     ,P_BODY          => l_clob_body
                     ,P_NUMUTIL       => 8
                     ,P_SENDER        => 'no-reply@gerep.fr'
                     ,P_NUMINDIV_DEST => NULL
                     ,P_ERROR         => l_ERROR);

EXCEPTION
  WHEN  OTHERS THEN
   P_INS_journal(1,'CRM P_SEND_RAPPORT_ENVOI_MAIL:' || sqlerrm );
END P_SEND_RAPPORT_ENVOI_MAIL;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_GENERER_CRM_DSN_AUTO                                    */
/* Type         :  Privé                                                     */
/* Description  :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_GENERER_CRM_DSN_AUTO
IS
  loc_erreur         VARCHAR2(500);
  loc_found          NUMBER;
  loc_numremise_ext  REMISE_EXTERNE.NUMREMISE%TYPE;
  loc_cptrendu       CLOB :='';

  CURSOR curs_remise_a_gen IS
   SELECT DISTINCT re.numremise
   FROM remise_externe re
   INNER JOIN  dsn_crm dc ON dc.numremise = re.numremise
   WHERE re.valide   = 'O'
     AND re.DATE_TRANS IS NULL
   ORDER BY re.numremise;

BEGIN

  -----------------------------------------------------------------------------------
  -- Constitution du bordereau des CRM DSN à traiter
  -----------------------------------------------------------------------------------
  PK_EXPORT_CRM_DSN.P_AF14 ( i_traitement    => 'AF14T'
                            ,i_numporte      => 20
                            ,i_numremise     => NULL
                            ,i_session       => sid
                            ,o_numremise_crm => loc_numremise_ext
                            ,o_cptrendu      => loc_cptrendu) ;


  IF NVL(loc_numremise_ext,0) <> 0 THEN
    -- validation de la remise générée par le traitement de masse
    UPDATE REMISE_EXTERNE
    SET VALIDE    = 'O'
       ,DATVALIDE = NVL(DATVALIDE,sysdate)
       ,DATEDIT   = NVL(DATEDIT,sysdate)
       ,NUMUTIL   = f_numutil
    WHERE numremise = loc_numremise_ext ;
  END IF;

  -- Commit nécessaire en cas de ROLLBACK dans un des appels à PK_EXPORT_CRM_DSN.P_AF16
  COMMIT;
  -----------------------------------------------------------------------------------
  -- Génération des fichiers CRM DSN des bordereaux validés,non émis
  -----------------------------------------------------------------------------------
  FOR rec_remise_a_gen IN curs_remise_a_gen LOOP
    loc_cptrendu := CONCAT (loc_cptrendu , CHR(13) || CHR(10) );
    PK_EXPORT_CRM_DSN.P_AF16 ( i_traitement    => 'AF16T'
                              ,i_numremise_ext => rec_remise_a_gen.numremise
                              ,i_session       => sid
                              ,i_niv_msg       => 3
                              ,o_cptrendu      => loc_cptrendu) ;

  END LOOP;

  COMMIT;

  P_SEND_RAPPORT_ENVOI_MAIL(i_date_session => sysdate
                           ,i_cptrendu     => loc_cptrendu);
  dbms_output.put_line('P_GENERER_CRM_DSN_AUTO:'|| ' ' || loc_cptrendu );


  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'P_GENERER_CRM_DSN_AUTO: Génération des CRM DSN stoppée');
    P_INS_journal(1,'P_GENERER_CRM_DSN_AUTO:'||SUBSTR(sqlerrm,1,132));
    P_INS_journal(1,'P_GENERER_CRM_DSN_AUTO:'||SUBSTR(sqlerrm,133,132));
    loc_cptrendu := CONCAT (loc_cptrendu ,
                       CHR(13) || CHR(10)|| 'P_GENERER_CRM_DSN_AUTO: Génération des CRM DSN stoppée'
                    || CHR(13) || CHR(10)|| 'P_GENERER_CRM_DSN_AUTO:'|| SUBSTR(sqlerrm,1,132)
                    || CHR(13) || CHR(10)|| 'P_GENERER_CRM_DSN_AUTO:'|| SUBSTR(sqlerrm,133,132));
    P_SEND_RAPPORT_ENVOI_MAIL(i_date_session => sysdate
                           ,i_cptrendu     => loc_cptrendu);
    dbms_output.put_line('P_GENERER_CRM_DSN_AUTO:'|| ' ' || loc_cptrendu );
    ROLLBACK;
END P_GENERER_CRM_DSN_AUTO;


/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_LIB_ENTITE_DSN                                          */
/* Type         :  PRIVE                                                     */
/* Description  :                                                            */
/* Retour       :  Renvoi le libellé d'une entité DSN Blocs de la forme      */
/*                 S21.G00.50, et Champs de la forme S21.G00.50.006          */
/*                 à partir des libellés BLKDSN et CHAMPDSN                  */
/*---------------------------------------------------------------------------*/
FUNCTION F_LIB_ENTITE_DSN (i_entiteDSN IN VARCHAR2 ) RETURN VARCHAR2
IS
  loc_lib_entite_dsn   VARCHAR2(500);

BEGIN
  IF i_entiteDSN IS NULL THEN
    RETURN NULL;
  END IF;

  -- 1ere partie UNION : les blocs DSN
  SELECT TRIM(LIBELLE)
  INTO loc_lib_entite_dsn
  FROM libelle_bis
  WHERE mnemo = 'BLKDSN'
    AND code  = TRIM(i_entiteDSN)
  UNION
  -- 2de partie UNION : les champs DSN
  -- (le code du champs est transcodé: par ex. 'S21.G00.50.008' => '210050008')
  SELECT TRIM(LIBELLE)
  FROM libelle_bis
  WHERE mnemo = 'CHAMPDSN'
    AND code  = REPLACE(REPLACE(REPLACE(i_entiteDSN,'S',''),'.',''),'G','')
  FETCH FIRST 1 ROW ONLY;

  RETURN loc_lib_entite_dsn;

EXCEPTION
  WHEN OTHERS THEN -- TODO BCO A compléter par une trace
    RETURN NULL;

END F_LIB_ENTITE_DSN;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_CREA_DSN_CRM_RETOUR                                     */
/* Type         :  PRIVE                                                     */
/* Description  :                                                            */
/* Retour       :  La fonction renvoit un idretour si un contexte metier     */
/*                 doit être créé, sinon dans le cas d'un regroupement de    */
/*                 retour metiers la fonction renvoie null                   */
/*---------------------------------------------------------------------------*/
FUNCTION F_CREA_DSN_CRM_RETOUR (i_IDDSNCRM             IN     DSN_CRM_RETOUR.IDDSNCRM%TYPE
                               ,i_MAXIDRETOUR          IN OUT DSN_CRM_RETOUR.IDRETOUR%TYPE
                               ,i_CODERETOURMETIER     IN     DSN_CRM_RETOUR.CODERETOURMETIER%TYPE
                               ,i_RUBRIQUEBLOCRETOUR   IN     DSN_CRM_RETOUR.RUBRIQUEBLOCRETOUR%TYPE
                               ,i_VALEURRUBRIQUEERREUR IN     DSN_CRM_RETOUR.VALEURRUBRIQUEERREUR%TYPE
                               ,i_DESCRIPTIONRETOUR    IN     DSN_CRM_RETOUR.DESCRIPTIONRETOUR%TYPE    DEFAULT NULL
                               ,i_DATEEVT              IN     DSN_CRM_RETOUR.DATEEVT%TYPE              DEFAULT NULL
                                ) RETURN DSN_CRM_RETOUR.IDRETOUR%TYPE
IS
  loc_dsn_crm_retour       DSN_CRM_RETOUR%ROWTYPE;
  loc_idretour             DSN_CRM_RETOUR.IDRETOUR%TYPE;

BEGIN
  IF  i_IDDSNCRM           IS NULL
   OR i_MAXIDRETOUR        IS NULL
   OR i_CODERETOURMETIER   IS NULL
   OR i_RUBRIQUEBLOCRETOUR IS NULL THEN
    RETURN NULL;
  END IF;

  -------------------------------
  -- Regroupement Retour
  -------------------------------
  -- Codes retour métiers exclus du regroupement
  IF i_CODERETOURMETIER NOT IN ('IFCT99','ECIN07') THEN
    -- Recherche d'un retour metier même code, même rubrique, même valeur
    BEGIN
      SELECT dcr.idretour
      INTO loc_idretour
      FROM DSN_CRM_RETOUR dcr
      WHERE dcr.iddsncrm           = i_IDDSNCRM
        AND dcr.coderetourmetier   = i_CODERETOURMETIER
        AND dcr.rubriqueblocretour = i_RUBRIQUEBLOCRETOUR
        AND ( (i_VALEURRUBRIQUEERREUR IS NULL AND dcr.valeurrubriqueerreur IS NULL )
          OR dcr.valeurrubriqueerreur = i_VALEURRUBRIQUEERREUR) ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        loc_idretour := NULL;
      WHEN OTHERS THEN
         -- TODO BCO trace
        RETURN NULL;
    END;

    -- Regroupement du Retour
    IF loc_idretour IS NOT NULL THEN
      BEGIN
        UPDATE DSN_CRM_RETOUR dcr
        SET dcr.NBERREURSSIMILAIRES = dcr.NBERREURSSIMILAIRES + 1
           ,dcr.datmaj = sysdate
        WHERE dcr.iddsncrm = i_IDDSNCRM
          AND dcr.idretour = loc_idretour ;
      EXCEPTION
        WHEN OTHERS THEN
         -- TODO BCO trace
          RETURN NULL;
      END;

      -- Fin procédure --
      RETURN NULL;
      -------------------
    --FinSi Regroupement
    END IF;
  -- Finsi code retour à regrouper
  END IF;

  -------------------------------
  -- Insert DSN_CRM_RETOUR
  -------------------------------
  loc_dsn_crm_retour := NULL;
  -- Limitation du nombre de retour dans la norme CRM
  IF i_MAXIDRETOUR >= 2000 THEN
    -- TODO BCO Trace
    RETURN NULL;
  ELSE
    i_MAXIDRETOUR := i_MAXIDRETOUR + 1;
  END IF;

  -- Identifiant du CRM DSN
  loc_dsn_crm_retour.IDDSNCRM := i_IDDSNCRM;
  -- Numéro d''ordre du retour
  loc_dsn_crm_retour.IDRETOUR := i_MAXIDRETOUR;
  -- Date de création
  loc_dsn_crm_retour.DATCRE := sysdate;
  -- Date de mise à jour
  loc_dsn_crm_retour.DATMAJ := sysdate;
  -- Nombre d'erreurs similaires
  loc_dsn_crm_retour.NBERREURSSIMILAIRES := 1;
  -- Code Retour Métier
  loc_dsn_crm_retour.CODERETOURMETIER := i_CODERETOURMETIER;
  -- Libellé correspondant au code retour métier
  loc_dsn_crm_retour.LIBELCODERETOURMETIER :=  PK_LIBELLE.F_LIB('CDRETCRM',i_CODERETOURMETIER);
  -- Criticité du code retour métier
  loc_dsn_crm_retour.CRITICITERETOUR := NULL;
  -- Rubrique ou Bloc à l'origine du retour Snn.Gnn.nn.nnn (si rubrique), Snn.Gnn.nn (si bloc)
  loc_dsn_crm_retour.RUBRIQUEBLOCRETOUR := i_RUBRIQUEBLOCRETOUR;
  -- Libellé de la rubrique ou du bloc concerné
  loc_dsn_crm_retour.LIBELRUBBLOCRETOUR := F_LIB_ENTITE_DSN(i_RUBRIQUEBLOCRETOUR);
  -- Valeur de la rubrique à l'origine du retour
  loc_dsn_crm_retour.VALEURRUBRIQUEERREUR := i_VALEURRUBRIQUEERREUR ;
  -- Libellé de la valeur à l'origine du retour
  loc_dsn_crm_retour.LIBELVALRUBRIQUEERREUR := NULL;
  -- Valeur corrigée ou attendue
  loc_dsn_crm_retour.VALEURCORRIGEEAJOUTEE := NULL;
  -- Libellé de la valeur corrigée ou attendue
  loc_dsn_crm_retour.LIBELVALCORRIGEEAJOUTEE := NULL;

  IF SUBSTR(i_CODERETOURMETIER,5,2) IN (98 ,99) THEN
    -- Message complémentaire: Message complémentaire libre, obligatoire pour toutes les erreurs ou informations
    -- génériques SXXXnn avec nn = 98 ou 99
    loc_dsn_crm_retour.DESCRIPTIONRETOUR := NVL(i_DESCRIPTIONRETOUR,'description banalisée');
    -- 'Date événement (explicite ou implicite) obligatoire lorsque le code retour métier
    --  concerne un événement non générique SEVTnn  avec nn différent de 98 ou 99
    loc_dsn_crm_retour.DATEEVT := NVL(i_DATEEVT,sysdate);
   ELSE
    loc_dsn_crm_retour.DESCRIPTIONRETOUR := NULL;
    loc_dsn_crm_retour.DATEEVT := NULL;

  END IF;

  BEGIN
    INSERT INTO DSN_CRM_RETOUR VALUES loc_dsn_crm_retour ;
  END;

  --incrément du nombre d'erreurs CRM
  IF SUBSTR(i_CODERETOURMETIER,1,1) = 'E' THEN
    BEGIN
      UPDATE DSN_CRM SET NBREERREUR = NVL(NBREERREUR,0) + 1 WHERE IDDSNCRM = i_IDDSNCRM;
    END;
  END IF;

  --incrément du nombre d'erreurs critique CRM
  IF SUBSTR(i_CODERETOURMETIER,1,1) = 'E'
   AND loc_dsn_crm_retour.CRITICITERETOUR = 'C' THEN
    BEGIN
      UPDATE DSN_CRM SET NBRECRITIQUE = NVL(NBRECRITIQUE,0) + 1 WHERE IDDSNCRM = i_IDDSNCRM;
    END;
  END IF;

  -- Modification du code retour CRM si première erreur
  -- 1 = "DSN acceptée, avec corrections à apporter"
  IF i_MAXIDRETOUR = 1 THEN
    BEGIN
      UPDATE DSN_CRM SET coderetourdecla = 1 WHERE IDDSNCRM = i_IDDSNCRM;
    END;
  END IF;


  RETURN i_MAXIDRETOUR;

END F_CREA_DSN_CRM_RETOUR;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_CREA_DSN_CRM_CONTEXTE                                   */
/* Type         :  Privé                                                     */
/* Description  :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM IN DSN_CRM_CONTEXTE.IDDSNCRM%TYPE
                                 ,i_IDRETOUR IN DSN_CRM_CONTEXTE.IDRETOUR%TYPE
                                 ,i_RUBRIQUE IN DSN_CRM_CONTEXTE.RUBRIQUE%TYPE
                                 ,i_VALEUR   IN DSN_CRM_CONTEXTE.VALEUR%TYPE )
IS

loc_dsn_crm_contexte       DSN_CRM_CONTEXTE%ROWTYPE := NULL;

BEGIN

  IF  i_IDRETOUR IS NULL
   OR i_IDDSNCRM IS NULL
   OR i_RUBRIQUE IS NULL
   OR i_VALEUR   IS NULL THEN
    RETURN;
  END IF;

  loc_dsn_crm_contexte.IDDSNCRM := i_IDDSNCRM;
  loc_dsn_crm_contexte.IDRETOUR := i_IDRETOUR;
  loc_dsn_crm_contexte.DATCRE := sysdate;
  loc_dsn_crm_contexte.DATMAJ := sysdate;
  loc_dsn_crm_contexte.RUBRIQUE := i_RUBRIQUE;
  loc_dsn_crm_contexte.LIBELLE := F_LIB_ENTITE_DSN(i_RUBRIQUE);
  loc_dsn_crm_contexte.VALEUR  := i_VALEUR;
  loc_dsn_crm_contexte.LIBELVAL := NULL;


  BEGIN
    INSERT INTO DSN_CRM_CONTEXTE VALUES loc_dsn_crm_contexte ;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;  -- TODO BCO
  END;

END P_CREA_DSN_CRM_CONTEXTE;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_FIND_OPTION                                             */
/* Type         :  Privé                                                     */
/* Description  :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_FIND_OPTION(i_numporte  IN  AFFIL_PORTE_ADH.NUMPORTE%TYPE
                       ,i_numremise IN  AFFIL_PORTE_ADH.NUMREMISE%TYPE
                       ,i_numligne  IN  AFFIL_PORTE_ADH.NUMLIGNE%TYPE
                       ,o_code_pop  OUT AFFIL_PORTE_ADH.CODE_POP%TYPE
                       ,o_code_opt  OUT AFFIL_PORTE_ADH.CODE_OPT%TYPE)
IS
-- Recherche code option et code population
BEGIN
  o_code_opt := NULL;
  o_code_pop := NULL;

  SELECT apa.code_opt
        ,apa.code_pop
  INTO o_code_opt
      ,o_code_pop
  FROM affil_porte_adh apa
  WHERE apa.numporte  = i_numporte
    AND apa.numremise = i_numremise
    AND apa.numligne  = i_numligne
  -- on trie en privilégiant les cas avec apa.refgarantie NULL
  ORDER BY apa.refgarantie ASC NULLS FIRST
  FETCH FIRST 1 ROW ONLY;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- BCO TODO ajout traces
    o_code_opt := NULL;
    o_code_pop := NULL;
    RETURN;
  WHEN OTHERS THEN
    o_code_opt := NULL;
    o_code_pop := NULL;
    -- BCO TODO ajout traces
    RETURN;

END P_FIND_OPTION;



/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_RETOUR_EADH03                                           */
/* Type         :  Privé                                                     */
/* Description  :  recherche et génération des retours                       */
/*                 EADH03 - Code OC de l'adhésion erroné                     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_RETOUR_EADH03(i_IDDSNCRM    IN     DSN_CRM_RETOUR.IDDSNCRM%TYPE
                         ,i_MAXIDRETOUR IN OUT DSN_CRM_RETOUR.IDRETOUR%TYPE
                         ,i_numporte    IN AFFIL_PORTE.NUMPORTE%TYPE
                         ,i_numremise   IN AFFIL_PORTE.NUMREMISE%TYPE
                         ,i_entreprise  IN AFFIL_PORTE.ENTREPRISE%TYPE
                         ,i_etabli      IN AFFIL_PORTE.ETABLI%TYPE
                         ,i_num_ordre   IN AFFIL_PORTE.NUM_ORDRE%TYPE
                         ,i_datefic     IN DATE)
IS
  loc_IdRetour             DSN_CRM_RETOUR.IDRETOUR%TYPE;
  loc_idfiche              DSN_FICHE.IDFICHE%TYPE;
  loc_pr                   DSN_FICHE.PR%TYPE;

  CURSOR curs_eadh03(p_numporte   AFFIL_PORTE.NUMPORTE%TYPE
                    ,p_numremise  AFFIL_PORTE.NUMREMISE%TYPE
                    ,p_entreprise AFFIL_PORTE.ENTREPRISE%TYPE
                    ,p_etabli     AFFIL_PORTE.ETABLI%TYPE
                    ,p_num_ordre  AFFIL_PORTE.NUM_ORDRE%TYPE
                    ,p_datefic    DATE) IS
    SELECT DISTINCT
       apc.ref_orgn_cntrt
      ,apc.orgn
      ,apc.deleg
      ,af.numcli
    FROM affil_porte_cntrt   apc
    INNER JOIN affil_fichier af  ON af.numporte   = apc.numporte
                                AND af.numremise  = apc.numremise
                                AND af.entreprise = apc.entreprise
                                AND af.etabli     = apc.etabli
                                AND af.num_ordre  = apc.num_ordre
    WHERE apc.numporte   = p_numporte
      AND apc.numremise  = p_numremise
      AND apc.entreprise = p_entreprise
      AND apc.etabli     = p_etabli
      AND apc.num_ordre  = p_num_ordre
      AND af.numcli IS NOT NULL
    ORDER BY
      apc.ref_orgn_cntrt
     ,apc.orgn
     ,apc.deleg;

BEGIN
  -- Curseur de recherche de cas
  FOR rec_eadh03 IN curs_eadh03 (i_numporte
                                ,i_numremise
                                ,i_entreprise
                                ,i_etabli
                                ,i_num_ordre
                                ,i_datefic) LOOP
    -- recherche de la derniere fiche de paramétrage transmise pour le client et le contrat
    BEGIN
      SELECT
         df.idfiche
        ,df.pr
      INTO
         loc_idfiche
        ,loc_pr
      FROM       dsn_fiche         df
      INNER JOIN dsn_fiche_contrat dfc ON dfc.idfiche  = df.idfiche
      INNER JOIN remise_externe    re  ON re.numremise = df.numremise
      WHERE df.numcli   = rec_eadh03.numcli
        AND dfc.refcie  = rec_eadh03.ref_orgn_cntrt
        -- Fiche transmise
        AND re.date_trans IS NOT NULL
      -- dernière fiche transmise
      ORDER BY re.date_trans DESC
      FETCH FIRST 1 ROW ONLY;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- BCO TODO ajout traces
        CONTINUE;
      WHEN OTHERS THEN
        -- BCO TODO ajout traces
        CONTINUE;
    END;

    -- si le code organisme porteur de risque transmis est différent
    IF TRIM(loc_pr) <> TRIM(rec_eadh03.orgn) THEN
    loc_IdRetour := F_CREA_DSN_CRM_RETOUR(i_IDDSNCRM             => i_IDDSNCRM
                                         ,i_MAXIDRETOUR          => i_MAXIDRETOUR
                                         ,i_CODERETOURMETIER     => 'EADH03'
                                         ,i_RUBRIQUEBLOCRETOUR   => 'S21.G00.15.002'  --CODE OC
                                         ,i_VALEURRUBRIQUEERREUR => rec_eadh03.orgn);
    -- Si loc_IdRetour n'est pas null, alors un contexte peut être créé
    IF loc_IdRetour IS NOT NULL THEN
      P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                             ,i_IDRETOUR => loc_IdRetour
                             ,i_RUBRIQUE => 'S21.G00.15.001'  -- REFERENCE CONTRAT
                             ,i_VALEUR   => rec_eadh03.ref_orgn_cntrt);
      P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                             ,i_IDRETOUR => loc_IdRetour
                             ,i_RUBRIQUE => 'S21.G00.15.002'  -- CODE OC
                             ,i_VALEUR   => rec_eadh03.orgn);
      P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                             ,i_IDRETOUR => loc_IdRetour
                             ,i_RUBRIQUE => 'S21.G00.15.003'  -- CODE DELEG
                             ,i_VALEUR   => rec_eadh03.deleg);
    END IF;
    -- FinSi code organisme différent
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    -- BCO TODO ajout traces
    RETURN;

END P_RETOUR_EADH03;



/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_RETOUR_EADH04                                           */
/* Type         :  Privé                                                     */
/* Description  :  recherche et génération des retours                       */
/*                 EADH04 - Code DELEG de l'adhésion erroné                  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_RETOUR_EADH04(i_IDDSNCRM    IN     DSN_CRM_RETOUR.IDDSNCRM%TYPE
                         ,i_MAXIDRETOUR IN OUT DSN_CRM_RETOUR.IDRETOUR%TYPE
                         ,i_numporte    IN AFFIL_PORTE.NUMPORTE%TYPE
                         ,i_numremise   IN AFFIL_PORTE.NUMREMISE%TYPE
                         ,i_entreprise  IN AFFIL_PORTE.ENTREPRISE%TYPE
                         ,i_etabli      IN AFFIL_PORTE.ETABLI%TYPE
                         ,i_num_ordre   IN AFFIL_PORTE.NUM_ORDRE%TYPE
                         ,i_deleg       IN AFFIL_PORTE_CNTRT.DELEG%TYPE)
IS
  loc_IdRetour             DSN_CRM_RETOUR.IDRETOUR%TYPE;

  CURSOR curs_eadh04(p_numporte   AFFIL_PORTE.NUMPORTE%TYPE
                    ,p_numremise  AFFIL_PORTE.NUMREMISE%TYPE
                    ,p_entreprise AFFIL_PORTE.ENTREPRISE%TYPE
                    ,p_etabli     AFFIL_PORTE.ETABLI%TYPE
                    ,p_num_ordre  AFFIL_PORTE.NUM_ORDRE%TYPE
                    ,p_deleg      AFFIL_PORTE_CNTRT.DELEG%TYPE) IS
    SELECT DISTINCT
       ap.numporte
      ,ap.numremise
      ,ap.entreprise
      ,ap.etabli
      ,ap.num_ordre
      ,apc.ref_orgn_cntrt
      ,apc.orgn
      ,apc.deleg
    FROM affil_porte ap
    INNER JOIN affil_porte_cntrt apc ON apc.numremise  = ap.numremise
                                    AND apc.entreprise = ap.entreprise
                                    AND apc.etabli     = ap.etabli
                                    AND apc.num_ordre  = ap.num_ordre
    WHERE ap.numporte   = p_numporte
      AND ap.numremise  = p_numremise
      AND ap.entreprise = p_entreprise
      AND ap.etabli     = p_etabli
      AND ap.num_ordre  = p_num_ordre
      AND apc.deleg    <> p_deleg
    ORDER BY
     ap.numporte
    ,ap.numremise
    ,ap.entreprise
    ,ap.etabli
    ,ap.num_ordre
    ,apc.ref_orgn_cntrt
    ,apc.orgn
    ,apc.deleg;

BEGIN
  -- Curseur de recherche de cas
  FOR rec_eadh04 IN curs_eadh04 (i_numporte
                                ,i_numremise
                                ,i_entreprise
                                ,i_etabli
                                ,i_num_ordre
                                ,i_deleg ) LOOP
    loc_IdRetour := F_CREA_DSN_CRM_RETOUR(i_IDDSNCRM             => i_IDDSNCRM
                                         ,i_MAXIDRETOUR          => i_MAXIDRETOUR
                                         ,i_CODERETOURMETIER     => 'EADH04'
                                         ,i_RUBRIQUEBLOCRETOUR   => 'S21.G00.15.003'  --CODE DELEG
                                         ,i_VALEURRUBRIQUEERREUR => rec_eadh04.deleg);
    -- Si loc_IdRetour n'est pas null, alors un contexte peut être créé
    IF loc_IdRetour IS NOT NULL THEN
      P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                             ,i_IDRETOUR => loc_IdRetour
                             ,i_RUBRIQUE => 'S21.G00.15.001'  -- REFERENCE CONTRAT
                             ,i_VALEUR   => rec_eadh04.ref_orgn_cntrt);
      P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                             ,i_IDRETOUR => loc_IdRetour
                             ,i_RUBRIQUE => 'S21.G00.15.002'  -- CODE OC
                             ,i_VALEUR   => rec_eadh04.orgn);
      P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                             ,i_IDRETOUR => loc_IdRetour
                             ,i_RUBRIQUE => 'S21.G00.15.003'  -- CODE DELEG
                             ,i_VALEUR   => rec_eadh04.deleg);
    END IF;
  END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    -- BCO TODO ajout traces
    RETURN;

END P_RETOUR_EADH04;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_RETOUR_IFCT99                                           */
/* Type         :  Privé                                                     */
/* Description  :  recherche et génération des retours                       */
/*                 IFCT99 - Information fin de contrat                       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_RETOUR_IFCT99(i_IDDSNCRM    IN     DSN_CRM_RETOUR.IDDSNCRM%TYPE
                         ,i_MAXIDRETOUR IN OUT DSN_CRM_RETOUR.IDRETOUR%TYPE
                         ,i_numporte    IN AFFIL_PORTE.NUMPORTE%TYPE
                         ,i_numremise   IN AFFIL_PORTE.NUMREMISE%TYPE
                         ,i_entreprise  IN AFFIL_PORTE.ENTREPRISE%TYPE
                         ,i_etabli      IN AFFIL_PORTE.ETABLI%TYPE
                         ,i_num_ordre   IN AFFIL_PORTE.NUM_ORDRE%TYPE)
IS
  loc_IdRetour             DSN_CRM_RETOUR.IDRETOUR%TYPE;

  CURSOR curs_ifct99(p_numporte   AFFIL_PORTE.NUMPORTE%TYPE
                    ,p_numremise  AFFIL_PORTE.NUMREMISE%TYPE
                    ,p_entreprise AFFIL_PORTE.ENTREPRISE%TYPE
                    ,p_etabli     AFFIL_PORTE.ETABLI%TYPE
                    ,p_num_ordre  AFFIL_PORTE.NUM_ORDRE%TYPE) IS
    SELECT DISTINCT
       ap.numporte
      ,ap.numremise
      ,ap.entreprise
      ,ap.etabli
      ,ap.num_ordre
      ,ap.numligne
      ,ap.numssa
    FROM       affil_porte ap
    -- BCO: On remonte les fins de de contrat même si il y a echec à l'intégration fonctionnelle (càd il n'y a pas de affil_trace)
    --      conservation du code pour info
    -- INNER JOIN affil_trace aft ON aft.numporte  = ap.numporte
                              -- AND aft.numremise = ap.numremise
                              -- AND aft.numligne  = ap.numligne
                              -- AND aft.objet     = 'HISTO_ADHESION'
                              -- AND aft.action    = 'I'
    WHERE ap.numporte   = p_numporte
      AND ap.numremise  = p_numremise
      AND ap.entreprise = p_entreprise
      AND ap.etabli     = p_etabli
      AND ap.num_ordre  = p_num_ordre
      AND ap.type_mvt   = 5
    ORDER BY ap.numporte
            ,ap.numremise
            ,ap.entreprise
            ,ap.etabli
            ,ap.num_ordre
            ,ap.numligne
            ,ap.numssa;

BEGIN
  -- Curseur de recherche de cas
  FOR rec_ifct99 IN curs_ifct99 (i_numporte
                                ,i_numremise
                                ,i_entreprise
                                ,i_etabli
                                ,i_num_ordre) LOOP
    loc_IdRetour := F_CREA_DSN_CRM_RETOUR(i_IDDSNCRM             => i_IDDSNCRM
                                         ,i_MAXIDRETOUR          => i_MAXIDRETOUR
                                         ,i_CODERETOURMETIER     => 'IFCT99'
                                         ,i_RUBRIQUEBLOCRETOUR   => 'S21.G00.62'  -- Bloc "Fin du contrat"
                                         ,i_VALEURRUBRIQUEERREUR => NULL
                                         ,i_DESCRIPTIONRETOUR    => 'Prise en compte de la radiation de l''assuré'
                                         ,i_DATEEVT              => sysdate);
    -- Si loc_IdRetour n'est pas null, alors un contexte peut être créé
    IF loc_IdRetour IS NOT NULL THEN
      P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                             ,i_IDRETOUR => loc_IdRetour
                             ,i_RUBRIQUE => 'S21.G00.30.001'  -- NIR
                             ,i_VALEUR   => rec_ifct99.numssa);
    END IF;
  END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    -- BCO TODO ajout traces
    RETURN;

END P_RETOUR_IFCT99;




/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_RETOUR_ECIN0X                                           */
/* Type         :  Privé                                                     */
/* Description  :  recherche et génération des retours Cotisation            */
/*                 ECIN05 - Composant base assujettie manquant               */
/*                 ECIN07 - Montant de composant erroné                      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_RETOUR_ECIN0X(i_IDDSNCRM    IN     DSN_CRM_RETOUR.IDDSNCRM%TYPE
                         ,i_MAXIDRETOUR IN OUT DSN_CRM_RETOUR.IDRETOUR%TYPE
                         ,i_numporte    IN AFFIL_PORTE.NUMPORTE%TYPE
                         ,i_numremise   IN AFFIL_PORTE.NUMREMISE%TYPE
                         ,i_entreprise  IN AFFIL_PORTE.ENTREPRISE%TYPE
                         ,i_etabli      IN AFFIL_PORTE.ETABLI%TYPE
                         ,i_num_ordre   IN AFFIL_PORTE.NUM_ORDRE%TYPE)
IS
  loc_IdRetour             DSN_CRM_RETOUR.IDRETOUR%TYPE;
  loc_idfiche              DSN_FICHE_CONTRAT.IDFICHE%TYPE;

  loc_count                NUMBER;
  loc_mt_elt               NUMBER(11,2);

  -- recherche des cotisations présentes dans la DSN
  CURSOR curs_qttc(p_numporte   AFFIL_PORTE.NUMPORTE%TYPE
                  ,p_numremise  AFFIL_PORTE.NUMREMISE%TYPE
                  ,p_entreprise AFFIL_PORTE.ENTREPRISE%TYPE
                  ,p_etabli     AFFIL_PORTE.ETABLI%TYPE
                  ,p_num_ordre  AFFIL_PORTE.NUM_ORDRE%TYPE) IS
    SELECT DISTINCT
       ap.numporte
      ,ap.numremise
      ,ap.entreprise
      ,ap.etabli
      ,ap.num_ordre
      ,ap.numligne
      ,ap.numssa
      ,af.numcli
      ,apc.ref_orgn_cntrt
      ,apc.orgn
      ,apc.deleg
      ,apa.numgar
      ,apa.code_opt
      ,apa.code_pop
      ,qttc.ref_ext_adh
      ,qttc.deb_base
      ,qttc.fin_base
    FROM       affil_porte       ap
    INNER JOIN affil_fichier     af   ON af.numporte   = ap.numporte
                                     AND af.numremise  = ap.numremise
                                     AND af.entreprise = ap.entreprise
                                     AND af.etabli     = ap.etabli
                                     AND af.num_ordre  = ap.num_ordre
    INNER JOIN affil_porte_qttc  qttc ON qttc.numporte  = ap.numporte
                                     AND qttc.numremise = ap.numremise
                                     AND qttc.numligne  = ap.numligne
    INNER JOIN affil_porte_cntrt apc  ON apc.numremise  = ap.numremise
                                     AND apc.entreprise = ap.entreprise
                                     AND apc.etabli     = ap.etabli
                                     AND apc.num_ordre  = ap.num_ordre
                                     AND apc.ref_ext_cntrt = qttc.ref_ext_cntrt
    INNER JOIN affil_porte_adh   apa  ON apa.numporte  = ap.numporte
                                     AND apa.numremise = ap.numremise
                                     AND apa.numligne  = ap.numligne
                                     AND apa.ref_ext_adh = qttc.ref_ext_adh
    WHERE ap.numporte   = p_numporte
      AND ap.numremise  = p_numremise
      AND ap.entreprise = p_entreprise
      AND ap.etabli     = p_etabli
      AND ap.num_ordre  = p_num_ordre
    ORDER BY
        ap.numporte
       ,ap.numremise
       ,ap.entreprise
       ,ap.etabli
       ,ap.num_ordre
       ,ap.numligne
       ,qttc.ref_ext_adh;

BEGIN
  --  Recherche des cotisations présentes dans la DSN
  FOR rec_qttc IN curs_qttc (i_numporte
                            ,i_numremise
                            ,i_entreprise
                            ,i_etabli
                            ,i_num_ordre) LOOP
    -- recherche de la derniere fiche de paramétrage transmise pour l'entreprise, l'etablissement et le contrat
    BEGIN
      SELECT
         dfc.idfiche
      INTO
         loc_idfiche
      FROM       dsn_fiche         df
      INNER JOIN dsn_fiche_contrat dfc ON dfc.idfiche  = df.idfiche
      INNER JOIN remise_externe    re  ON re.numremise = df.numremise
      WHERE df.numcli   = rec_qttc.numcli
        AND dfc.numgar  = rec_qttc.numgar
        AND rec_qttc.deb_base BETWEEN dfc.debut AND NVL(dfc.fin,e2d('01/01/2099'))
        -- Fiche transmise
        AND re.date_trans IS NOT NULL
      -- dernière fiche transmise
      ORDER BY re.date_trans DESC
      FETCH FIRST 1 ROW ONLY;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- BCO TODO ajout traces
        CONTINUE;
      WHEN OTHERS THEN
        -- BCO TODO ajout traces
        CONTINUE;
    END;

    -------------------------------------------------------------
    -- ECIN05
    --  1) On verifie qu'il existe au moins un élément de calcul de la fiche de paramétrage DSN présent dans la DSN
    -- Sinon retour ECIN05 Composant base assujettie manquant
    --  2) si pas de ECIN05 en 1) , on vérifie que si la fiche de parametrage présente un TA, un PMSS ou un montant forfaitaire,
    --     ces éléments doivent être present dans la DSN, sinon ECIN05
    -------------------------------------------------------------
    IF TRIM(rec_qttc.code_pop) IS NOT NULL THEN
      BEGIN
        SELECT COUNT(*)
        INTO loc_count
        FROM DSN_FICHE_TARIF dft
        INNER JOIN AFFIL_PORTE_QTTC apq ON apq.numporte    = rec_qttc.numporte
                                       AND apq.numremise   = rec_qttc.numremise
                                       AND apq.numligne    = rec_qttc.numligne
                                       AND apq.ref_ext_adh = rec_qttc.ref_ext_adh
        INNER JOIN AFFIL_PORTE_QTTC_ELT elt  ON elt.numporte  = apq.numporte
                                            AND elt.numremise = apq.numremise
                                            AND elt.numligne  = apq.numligne
                                            AND elt.num_qttc  = apq.num_qttc
                                             AND elt.type_elt  = COALESCE(dft.elt_calcul,dft.elt_calcul_spe)
        WHERE dft.idfiche     = loc_idfiche
          AND dft.numgar      = rec_qttc.numgar
          AND NVL(dft.code_option, -1) = NVL(rec_qttc.code_opt, -1)
          AND dft.code_pop    = rec_qttc.code_pop ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          loc_count := 1;
          -- BCO TODO ajout traces
        WHEN OTHERS THEN
          -- BCO TODO ajout traces
          loc_count := 1;
      END;

      IF loc_count = 0 THEN -- ECIN05 Au moins un element de la fiche de param
        P_INS_JOURNAL(3,'ECIN05 trouvé (Au moins un element).'
              || ' re:'  ||   rec_qttc.numremise
              || ' es:'  ||   rec_qttc.entreprise
              || ' et:'  ||   rec_qttc.etabli
              || ' or:'  ||   rec_qttc.num_ordre
              || ' lg;'  ||   rec_qttc.numligne
              || ' nir:' ||   rec_qttc.numssa
              || ' cl:'  ||   rec_qttc.numcli
              || ' ga:'  ||   rec_qttc.numgar
              || ' opt:' ||   rec_qttc.code_opt
              || ' pop:' ||   rec_qttc.code_pop
              || ' ref:' ||   rec_qttc.ref_ext_adh
              || ' deb:' ||   TO_CHAR(rec_qttc.deb_base,'DD/MM/YYYY')
              || ' fi:'  ||   loc_idfiche);

        loc_IdRetour := F_CREA_DSN_CRM_RETOUR(i_IDDSNCRM             => i_IDDSNCRM
                                             ,i_MAXIDRETOUR          => i_MAXIDRETOUR
                                             ,i_CODERETOURMETIER     => 'ECIN05'
                                             ,i_RUBRIQUEBLOCRETOUR   => 'S21.G00.79'  -- BLOC composant de base assujettie
                                             ,i_VALEURRUBRIQUEERREUR => NULL);
        -- Si loc_IdRetour n'est pas null, alors un contexte peut être créé
        IF loc_IdRetour IS NOT NULL THEN
          P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                                 ,i_IDRETOUR => loc_IdRetour
                                 ,i_RUBRIQUE => 'S21.G00.15.001'  -- REFERENCE CONTRAT
                                 ,i_VALEUR   => rec_qttc.ref_orgn_cntrt);
          P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                                 ,i_IDRETOUR => loc_IdRetour
                                 ,i_RUBRIQUE => 'S21.G00.15.002'  -- CODE OC
                                 ,i_VALEUR   => rec_qttc.orgn);
          P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                                 ,i_IDRETOUR => loc_IdRetour
                                 ,i_RUBRIQUE => 'S21.G00.15.003'  -- CODE DELEG
                                 ,i_VALEUR   => rec_qttc.deleg);
          P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                                 ,i_IDRETOUR => loc_IdRetour
                                 ,i_RUBRIQUE => 'S21.G00.70.004'  -- CODE OPTION
                                 ,i_VALEUR   => rec_qttc.code_opt);
          P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                                 ,i_IDRETOUR => loc_IdRetour
                                 ,i_RUBRIQUE => 'S21.G00.70.005'  -- CODE POPULATION
                                 ,i_VALEUR   => rec_qttc.code_pop);
          P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                                 ,i_IDRETOUR => loc_IdRetour
                                 ,i_RUBRIQUE => 'S21.G00.78.002'  -- Date de début de période de rattachement
                                 ,i_VALEUR   => TO_CHAR(rec_qttc.deb_base,'DDMMYYYY'));
          P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                                 ,i_IDRETOUR => loc_IdRetour
                                 ,i_RUBRIQUE => 'S21.G00.78.003'  -- Date de fin de période de rattachement
                                 ,i_VALEUR   => TO_CHAR(rec_qttc.fin_base,'DDMMYYYY'));

        -- FinSi contexte à créer
        END IF;
      -- FinSi -- ECIN05 Au moins un element de la fiche de param
      ELSE
        --
    BEGIN
          loc_count := 0;
          -- on compte les éléments 10,11,20 présents dans la fiche et absent de de la DSN
      SELECT COUNT(*)
      INTO loc_count
          FROM DSN_FICHE_TARIF dft
          WHERE dft.idfiche     = loc_idfiche
            AND dft.numgar      = rec_qttc.numgar
            AND dft.code_pop    = rec_qttc.code_pop
            AND NVL(dft.code_option, -1) = NVL(rec_qttc.code_opt, -1)
            AND dft.elt_calcul IN (10,11,20)
            AND NOT EXISTS (SELECT elt.numporte
                            FROM AFFIL_PORTE_QTTC apq
                            INNER JOIN AFFIL_PORTE_QTTC_ELT elt ON elt.numporte  = apq.numporte
                                                               AND elt.numremise = apq.numremise
                                                               AND elt.numligne  = apq.numligne
                                                               AND elt.num_qttc  = apq.num_qttc
                            WHERE apq.numporte     = rec_qttc.numporte
                              AND apq.numremise    = rec_qttc.numremise
                              AND apq.numligne     = rec_qttc.numligne
                              AND apq.ref_ext_adh  = rec_qttc.ref_ext_adh
                              AND elt.type_elt     = dft.elt_calcul );
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        loc_count := 0;
        -- BCO TODO ajout traces
      WHEN OTHERS THEN
        -- BCO TODO ajout traces
        loc_count := 0;
    END;

        -- ECIN05 éléments 10,11,20 de la fiche obligatoires dans le DSN
        IF loc_count > 0 THEN
      loc_IdRetour := F_CREA_DSN_CRM_RETOUR(i_IDDSNCRM             => i_IDDSNCRM
                                           ,i_MAXIDRETOUR          => i_MAXIDRETOUR
                                               ,i_CODERETOURMETIER     => 'ECIN05'
                                               ,i_RUBRIQUEBLOCRETOUR   => 'S21.G00.79'  -- BLOC composant de base assujettie
                                               ,i_VALEURRUBRIQUEERREUR => NULL);
      -- Si loc_IdRetour n'est pas null, alors un contexte peut être créé
      IF loc_IdRetour IS NOT NULL THEN
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.15.001'  -- REFERENCE CONTRAT
                               ,i_VALEUR   => rec_qttc.ref_orgn_cntrt);
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.15.002'  -- CODE OC
                               ,i_VALEUR   => rec_qttc.orgn);
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.15.003'  -- CODE DELEG
                               ,i_VALEUR   => rec_qttc.deleg);
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.70.004'  -- CODE OPTION
                               ,i_VALEUR   => rec_qttc.code_opt);
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.70.005'  -- CODE POPULATION
                               ,i_VALEUR   => rec_qttc.code_pop);
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.78.002'  -- Date de début de période de rattachement
                               ,i_VALEUR   => TO_CHAR(rec_qttc.deb_base,'DDMMYYYY'));
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.78.003'  -- Date de fin de période de rattachement
                               ,i_VALEUR   => TO_CHAR(rec_qttc.fin_base,'DDMMYYYY'));
      END IF;
        -- FinSi ECIN05 éléments 10,11,20 de la fiche obligatoires dans le DSN
    END IF;
      -- FinOu -- ECIN05 Au moins un element de la fiche de param
      END IF;
    -- FinSi code_pop IS NOT NULL
    END IF;


    -------------------------------------------------------------
    -- On verifie que, s'il existe dans la DSN un élément de calcul 18 - Base forfaitaire Prévoyance Alors
    -- il est un multiple de l'indice PMSS à date
    -- Sinon retour ECIN07 Montant de composant erroné
    -------------------------------------------------------------
    BEGIN
      loc_mt_elt := NULL ;
      SELECT elt18.mt_elt
      INTO loc_mt_elt
      FROM AFFIL_PORTE_QTTC apq
      INNER JOIN AFFIL_PORTE_QTTC_ELT elt18 ON elt18.numporte  = apq.numporte
                                           AND elt18.numremise = apq.numremise
                                           AND elt18.numligne  = apq.numligne
                                           AND elt18.num_qttc  = apq.num_qttc
      INNER JOIN AFFIL_PORTE ap ON ap.numporte  = rec_qttc.numporte
                               AND ap.numremise = rec_qttc.numremise
                               AND ap.numligne  = rec_qttc.numligne
      WHERE apq.numporte     = rec_qttc.numporte
        AND apq.numremise    = rec_qttc.numremise
        AND apq.numligne     = rec_qttc.numligne
        AND apq.ref_ext_adh  = rec_qttc.ref_ext_adh
        --
        AND NVL(ap.type_mvt,0)  NOT IN ( 1 , 5 )
        --
        AND elt18.type_elt  = 18
        --    Le composant n'est pas un multiple de PMSS
        --    OU le composant est nul
        AND ( MOD(elt18.mt_elt, ind(1,rec_qttc.deb_base)) > 0.0
           OR elt18.mt_elt = 0.0 )
        FETCH FIRST 1 ROW ONLY;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        loc_mt_elt := NULL;
        -- BCO TODO ajout traces
      WHEN OTHERS THEN
        -- BCO TODO ajout traces
        loc_mt_elt := NULL;
    END;

    IF loc_mt_elt IS NOT NULL THEN -- ECIN07
      loc_IdRetour := F_CREA_DSN_CRM_RETOUR(i_IDDSNCRM             => i_IDDSNCRM
                                           ,i_MAXIDRETOUR          => i_MAXIDRETOUR
                                           ,i_CODERETOURMETIER     => 'ECIN07'
                                           ,i_RUBRIQUEBLOCRETOUR   => 'S21.G00.79.004'  -- Montant de composant de base assujettie
                                           ,i_VALEURRUBRIQUEERREUR => NULL);
      -- Si loc_IdRetour n'est pas null, alors un contexte peut être créé
      IF loc_IdRetour IS NOT NULL THEN
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.15.001'  -- REFERENCE CONTRAT
                               ,i_VALEUR   => rec_qttc.ref_orgn_cntrt);
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.15.002'  -- CODE OC
                               ,i_VALEUR   => rec_qttc.orgn);
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.15.003'  -- CODE DELEG
                               ,i_VALEUR   => rec_qttc.deleg);
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.70.004'  -- CODE OPTION
                               ,i_VALEUR   => rec_qttc.code_opt);
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.70.005'  -- CODE POPULATION
                               ,i_VALEUR   => rec_qttc.code_pop);
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.78.002'  -- Date de début de période de rattachement
                               ,i_VALEUR   => TO_CHAR(rec_qttc.deb_base,'DDMMYYYY'));
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.78.003'  -- Date de fin de période de rattachement
                               ,i_VALEUR   => TO_CHAR(rec_qttc.fin_base,'DDMMYYYY'));
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.79.001'  -- Type de composant de base assujettie
                               ,i_VALEUR   => TO_CHAR(18,'FM00'));
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.30.001'  -- NIR
                               ,i_VALEUR   => rec_qttc.numssa);
        P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => i_IDDSNCRM
                               ,i_IDRETOUR => loc_IdRetour
                               ,i_RUBRIQUE => 'S21.G00.79.004'  -- Montant de composant de base assujettie
                               ,i_VALEUR   => loc_mt_elt);
      -- FinSi contexte à créer
      END IF;
    -- FinSi ECIN07
    END IF;

  -- Fin boucle recherche des cotisations présentes dans la DSN curs_qttc
  END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    -- BCO TODO ajout traces
    RETURN;

END P_RETOUR_ECIN0X;




/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_AF14                                                    */
/* Type         :  Public                                                    */
/* Description  :  Constitution d un bordereau de CRM DSN                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_AF14 ( i_traitement    IN    TYP_BATCH.BATCHID%TYPE
                  ,i_numporte      IN    REMISE_EXTERNE.NUMPORTE%TYPE
                  ,i_numremise     IN    PORTE_REMISE.NUMREMISE%TYPE DEFAULT NULL
                  ,i_session       IN    JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1
                  ,o_numremise_crm OUT   REMISE_EXTERNE.NUMREMISE%TYPE
                  ,o_cptrendu      IN OUT CLOB)
IS
  -- Constantes
  const_versioncrm         NUMBER := 114;

  -- var locales
  loc_param_batch          PARAM_BATCH%ROWTYPE;
  -- timestamp de ref (unique pour le traitement)
  loc_timestamp_ref        DATE;
  loc_numremise_ext        REMISE_EXTERNE.NUMREMISE%TYPE;
  loc_idlotcrm             DSN_CRM.IDLOTCRM%TYPE;
  loc_erreur               JOURNAL_ADM.MSG_ADM%TYPE := NULL;
  loc_cpt_crm              NUMBER := 0;
  loc_telcontact           VARCHAR2(15);
  loc_orgn                 AFFIL_PORTE_CNTRT.ORGN%TYPE;
  loc_deleg                AFFIL_PORTE_CNTRT.DELEG%TYPE;

  loc_code_opt             AFFIL_PORTE_ADH.CODE_OPT%TYPE;
  loc_code_pop             AFFIL_PORTE_ADH.CODE_POP%TYPE;

  loc_maxIdRetour          DSN_CRM_RETOUR.IDRETOUR%TYPE;
  loc_IdRetour             DSN_CRM_RETOUR.IDRETOUR%TYPE;

  loc_dsn_crm              DSN_CRM%ROWTYPE;
  loc_dsn_crm_retour       DSN_CRM_RETOUR%ROWTYPE;
  loc_dsn_crm_contexte     DSN_CRM_CONTEXTE%ROWTYPE;

  -- exception
  exc_dep                  EXCEPTION;

  -- identification des DSN pour lesquels un CRM est à produire
  CURSOR cur_dsn(p_numporte  PORTE_REMISE.NUMPORTE%TYPE
                ,p_numremise PORTE_REMISE.NUMREMISE%TYPE) IS
    SELECT
      pr.dateremise
     ,af.fichier
     ,af.numremise
     ,af.numporte
     ,af.entreprise
     ,af.etabli
     ,af.num_ordre
     ,af.num_ordre_ini
     ,af.iddeclardsn
     ,af.nature
     ,af.type
     ,af.fractiondecla
     ,af.num_annul
     ,af.datefic
     ,af.datemoisdec
     ,af.dateconstitution
     ,af.idmetierdsn
     ,af.chamdecdsn
     ,af.natevendsn
     ,af.modepot
     ,af.idenvoi
     ,af.ptdepot
     ,af.datdepot
     ,af.nomdeclarant
     ,af.prenomdeclarant
     ,af.siretdeclarant
     ,af.sirenemett || af.nicemett     siretemett
     ,af.nomemett
     ,af.typenvoidsn
     ,af.norme
     ,af.codenvoidsn
    FROM       PORTE_REMISE  pr
    INNER JOIN AFFIL_FICHIER af ON af.numremise = pr.numremise
                               AND af.numporte  = pr.numporte
                               --  IDENVOI et NUM_ORDRE_INI sont non NULL pour les DSN post-Projet CRM 2020
                               --   on exclu les DSN pre-Projet CRM 2020 (!)
                               AND af.idenvoi       IS NOT NULL
                               AND af.num_ordre_ini IS NOT NULL
    WHERE
        pr.numporte = p_numporte
    AND ((p_numremise IS NULL
          -- La remise DSN ne fait pas partie d'un bordereau CRM DSN
          AND NOT EXISTS (SELECT crm.iddsncrm FROM DSN_CRM crm
                          WHERE crm.numremise_dsn  = af.numremise
                            AND crm.numporte_dsn   = af.numporte
                            AND crm.entreprise_dsn = af.entreprise
                            AND crm.etabli_dsn     = af.etabli
                            AND crm.num_ordre_dsn  = af.num_ordre_ini)
          -- la DSN a moins de 3 mois
          AND pr.dateremise > ADD_MONTHS(sysdate,-3))
       -- ou forcage de la DSN selectionnée
       OR pr.numremise = p_numremise )
    ORDER BY af.numremise
            ,af.fichier
            ,af.numporte
            ,af.entreprise
            ,af.etabli
            ,af.num_ordre;

  -- identification des RetourMetier à produire (en fonction de la transco des numano en code retour crm)
  --    ( hors EETB01)
  CURSOR curs_retour(p_numporte   AFFIL_PORTE.NUMPORTE%TYPE
                    ,p_numremise  AFFIL_PORTE.NUMREMISE%TYPE
                    ,p_entreprise AFFIL_PORTE.ENTREPRISE%TYPE
                    ,p_etabli     AFFIL_PORTE.ETABLI%TYPE
                    ,p_num_ordre  AFFIL_PORTE.NUM_ORDRE%TYPE) IS
    SELECT DISTINCT
       ap.numporte
      ,ap.numremise
      ,ap.entreprise
      ,ap.etabli
      ,ap.num_ordre
      ,ap.numligne
      ,ap.numssa
      ,ap.motifs
      ,ap.motifa
      ,apc.ref_orgn_cntrt
      ,apc.orgn
      ,apc.deleg
      ,aano.numano
      ,F_GET_TRANSCO('DSNCRM','CODERR',aano.numano,1) coderr
    FROM affil_porte ap
    INNER JOIN affil_porte_adh   apa  ON apa.numporte   = ap.numporte
                                     AND apa.numremise  = ap.numremise
                                     AND apa.numligne   = ap.numligne
    INNER JOIN affil_porte_cntrt apc  ON apc.numremise  = ap.numremise
                                     AND apc.entreprise = ap.entreprise
                                     AND apc.etabli     = ap.etabli
                                     AND apc.num_ordre  = ap.num_ordre
                                     AND apc.ref_ext_cntrt = apa.ref_ext_cntrt
    INNER JOIN affil_ano        aano  ON aano.numporte  = ap.numporte
                                     AND aano.numremise = ap.numremise
                                     AND aano.numligne  = ap.numligne
    WHERE ap.numporte   = p_numporte
      AND ap.numremise  = p_numremise
      AND ap.entreprise = p_entreprise
      AND ap.etabli     = p_etabli
      AND ap.num_ordre  = p_num_ordre
      AND aano.NUMANO IS NOT NULL
      AND F_GET_TRANSCO('DSNCRM','CODERR',AANO.NUMANO,1) IS NOT NULL
      AND ( F_GET_TRANSCO('DSNCRM','CODERR',AANO.NUMANO,1) NOT IN ( 'EETB01', 'EAFF06')
        OR  (  F_GET_TRANSCO('DSNCRM','CODERR',AANO.NUMANO,1) = 'EAFF06'
           AND apa.numgar IS NULL ) )
    ORDER BY
       ap.numporte
      ,ap.numremise
      ,ap.entreprise
      ,ap.etabli
      ,ap.num_ordre
      ,ap.numligne
      ,ap.numssa
      ,aano.numano;


  -- identification des RetourMetier EETB01 à produire
  CURSOR curs_retour_EETB01(p_numporte   AFFIL_PORTE.NUMPORTE%TYPE
                    ,p_numremise  AFFIL_PORTE.NUMREMISE%TYPE
                    ,p_entreprise AFFIL_PORTE.ENTREPRISE%TYPE
                    ,p_etabli     AFFIL_PORTE.ETABLI%TYPE
                    ,p_num_ordre  AFFIL_PORTE.NUM_ORDRE%TYPE) IS
    SELECT DISTINCT
       ap.numporte
      ,ap.numremise
      ,ap.entreprise
      ,ap.etabli
      ,ap.num_ordre
      ,apc.ref_orgn_cntrt
      ,apc.orgn
      ,apc.deleg
      ,aano.numano
      ,F_GET_TRANSCO('DSNCRM','CODERR',aano.numano,1) coderr
    FROM affil_porte ap
    INNER JOIN affil_porte_adh   apa  ON apa.numporte   = ap.numporte
                                     AND apa.numremise  = ap.numremise
                                     AND apa.numligne   = ap.numligne
    INNER JOIN affil_porte_cntrt apc  ON apc.numremise  = ap.numremise
                                     AND apc.entreprise = ap.entreprise
                                     AND apc.etabli     = ap.etabli
                                     AND apc.num_ordre  = ap.num_ordre
                                     AND apc.ref_ext_cntrt = apa.ref_ext_cntrt
    INNER JOIN affil_ano        aano  ON aano.numporte  = ap.numporte
                                     AND aano.numremise = ap.numremise
                                     AND aano.numligne  = ap.numligne
    WHERE ap.numporte   = p_numporte
      AND ap.numremise  = p_numremise
      AND ap.entreprise = p_entreprise
      AND ap.etabli     = p_etabli
      AND ap.num_ordre  = p_num_ordre
      AND aano.NUMANO IS NOT NULL
      AND F_GET_TRANSCO('DSNCRM','CODERR',aano.numano,1) = 'EETB01'
    ORDER BY
       ap.numporte
      ,ap.numremise
      ,ap.entreprise
      ,ap.etabli
      ,ap.num_ordre
      ,aano.numano;



BEGIN
 -----------------------------------------------------------------------------
  G_nom_traitement  := i_traitement;
  G_idligne         := 1;
  G_session         := i_session;
  loc_timestamp_ref := SYSDATE ;
  P_INS_journal(1,'Traitement <'||i_traitement||'> de constitution bdx CRM de paramétrage porte <'||i_numporte||'>');
  o_cptrendu :=  CONCAT( o_cptrendu , CHR(13) || CHR(10)
               || 'Compte-rendu du Traitement <'||i_traitement||'> de constitution bdx CRM de paramétrage porte <'||i_numporte||'>' || CHR(13) || CHR(10));
  o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                 || 'Debut du traitement: ' || TO_CHAR(sysdate,'DD/MM/YYYY HH24:MI:SS'));
  -----------------------------------------------------------------------------
  -- Paramètres du traitement
  -----------------------------------------------------------------------------
  BEGIN
    SELECT * INTO loc_param_batch  FROM PARAM_BATCH
    WHERE NUMBATCH = g_nom_traitement;
  EXCEPTION
    WHEN OTHERS THEN
      P_INS_JOURNAL(1,'Probleme accès au paramètrage du traitement <'||g_nom_traitement||'> => Arret');
      P_INS_journal(1,SUBSTR(sqlerrm,1,132));
      P_INS_journal(1,SUBSTR(sqlerrm,133,132));
      o_cptrendu :=  CONCAT( o_cptrendu , CHR(13) || CHR(10)
                  || 'Probleme d''accès au paramètrage du traitement <'||g_nom_traitement||'> => Arret');
      RETURN;
  END;

  IF TRIM(loc_param_batch.param1) NOT IN ('CRC','CRT') THEN
    P_INS_JOURNAL(1,'Type de CRM paramétré incohérent <'||g_nom_traitement
                    ||' P1=' || NVL(TO_CHAR(loc_param_batch.param1),'(vide)')||'> => Arret' );
    P_INS_JOURNAL(1,'Type de CRM : valeur attendue ''CRC'' ''CRT''' );
    RETURN;
  END IF;
  P_INS_JOURNAL(1,'Type de CRM paramétré: <'||loc_param_batch.param1||'>');

  IF TRIM(loc_param_batch.param2) IS NULL THEN
    P_INS_JOURNAL(1,'Code Producteur CRM paramétré absent P2 <'||g_nom_traitement ||'> => Arret' );
      o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                  || 'Code Producteur CRM paramétré absent P2 <'||g_nom_traitement ||'> => Arret');
    RETURN;
  END IF;
  P_INS_JOURNAL(1,'Code Producteur CRM paramétré: <'||loc_param_batch.param2||'>');


  -- TODO - A revoir, ne marche pas : PARAM_BATCH.PARAM3  VARCHAR2(10)  => une adresse mail ne rentre pas !!
  --IF TRIM(loc_param_batch.param3) IS NULL THEN
  --  P_INS_JOURNAL(1,'Courriel du contact paramétré absent P3 <'||g_nom_traitement ||'> => Arret' );
  --  RETURN;
  --END IF;
  --P_INS_JOURNAL(1,'Courriel du contact paramétré: <'||loc_param_batch.param3||'>');

  BEGIN
    SELECT f_coordonne_contact (interlocuteur ,1,1)
    INTO loc_telcontact
    FROM interlocuteur
    WHERE numindiv = 1
      AND ope_crrr = 1 -- 1 = Cotisations    TODO à confirmer
      AND valide   = 'O'
      AND defaut   = 'O'
    FETCH FIRST 1 ROW ONLY;
   EXCEPTION
    WHEN OTHERS THEN
      P_INS_JOURNAL(1,'Probleme accès au téléphone de contact => Arret');
      P_INS_journal(1,SUBSTR(sqlerrm,1,132));
      P_INS_journal(1,SUBSTR(sqlerrm,133,132));
      o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                  || 'Probleme accès au téléphone de contact => Arret');
      RETURN;
   END;

  -----------------------------------------------------------------------------
  -- Boucle CRM à déclarer
  -----------------------------------------------------------------------------
  FOR rec_dsn IN cur_dsn(i_numporte,i_numremise) LOOP
    -- si premier appel, création de la remise externe 'CRM DSN'
    IF loc_numremise_ext IS NULL THEN
      PK_TPE.P_GESTION_REMISE_EXTERNE(i_numporte   => i_numporte
                                     ,i_nat_porte  => 8
                                     ,o_numremise  => loc_numremise_ext
                                     ,o_erreur     => loc_erreur) ;
      P_INS_JOURNAL(2,'Numéro de remise externe CRM DSN créée <'||loc_numremise_ext||'> ');
      IF NVL(loc_numremise_ext,0) = 0 THEN
        P_INS_journal(1,'Erreur: création de la remise externe impossible, '||loc_erreur);
        P_INS_journal(1,'ROLLBACK');
        o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                  || 'Erreur: création de la remise externe impossible, ' || loc_erreur || '=> Arret');
        ROLLBACK;
        RETURN;
      END IF;

      o_numremise_crm := loc_numremise_ext;

      -- Détermination de l'identifiant lotCRM (spécif FFSA)
      loc_idlotcrm := 'L'||TO_CHAR(sysdate,'YYDDD')||'R'||TO_CHAR(loc_numremise_ext);

    -- FinSi premier appel
    END IF;

    -- init
    loc_dsn_crm := NULL;

    P_INS_journal(2,'*Traitement de la DSN -'
                   ||'  fichier:'     ||   rec_dsn.fichier
                   ||'  numremise:'   ||   rec_dsn.numremise
                   ||'  numporte:'    ||   rec_dsn.numporte
                   ||'  entreprise:'  ||   rec_dsn.entreprise
                   ||'  etabli:'      ||   rec_dsn.etabli
                   ||'  num_ordre:'   ||   rec_dsn.num_ordre
                   ||'  iddeclardsn:' ||   rec_dsn.iddeclardsn );

    -- Identifiant du CRM DSN
    BEGIN
      SELECT SEQ_DSN_CRM.NEXTVAL INTO loc_dsn_crm.IDDSNCRM FROM DUAL;
    EXCEPTION
      WHEN OTHERS THEN
        P_INS_journal(1,'   Impossible d''allouer un nouveau retour CRM pour la remise :'
                   ||'  fichier:'     ||   rec_dsn.fichier
                   ||'  numremise:'   ||   rec_dsn.numremise
                   ||'  numporte:'    ||   rec_dsn.numporte
                   ||'  entreprise:'  ||   rec_dsn.entreprise
                   ||'  etabli:'      ||   rec_dsn.etabli
                   ||'  num_ordre:'   ||   rec_dsn.num_ordre
                   ||'  iddeclardsn:' ||   rec_dsn.iddeclardsn );
        P_INS_journal(1,'   Erreur :' || SQLERRM);
        P_INS_journal(1,'   fin de traitement de la remise DSN');
      CONTINUE;
    END;

    -- Récupération "Code organisme" et "Code délégataire de gestion"
    BEGIN
      SELECT
         apc.orgn
        ,apc.deleg
      INTO loc_orgn
          ,loc_deleg
      FROM affil_porte_cntrt apc
      WHERE
           apc.numremise     = rec_dsn.numremise
       AND apc.entreprise    = rec_dsn.entreprise
       AND apc.etabli        = rec_dsn.etabli
       AND apc.num_ordre     = rec_dsn.num_ordre
      FETCH FIRST 1 ROW ONLY;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_INS_journal(1,'   Impossible de trouver "Code organisme" et "Code délégataire de gestion" pour la remise:' || rec_dsn.numremise
        || ' entreprise:' || rec_dsn.entreprise
        || ' etabli:'     || rec_dsn.etabli
        || ' num_ordre:'  || rec_dsn.num_ordre);
        P_INS_journal(1,'   fin de traitement de la remise DSN');
        o_cptrendu :=  CONCAT( o_cptrendu , CHR(13) || CHR(10)
                  || '   Impossible de trouver "Code organisme" et "Code délégataire de gestion" pour la remise:' || rec_dsn.numremise
                  || ' entreprise:' || rec_dsn.entreprise
                  || ' etabli:'     || rec_dsn.etabli
                  || ' num_ordre:'  || rec_dsn.num_ordre);
        CONTINUE;
      WHEN OTHERS THEN
        P_INS_journal(1,'   Erreur lors de la recherche "Code organisme" et "Code délégataire de gestion" pour la remise:' || rec_dsn.numremise
        || ' entreprise:' || rec_dsn.entreprise
        || ' etabli:'     || rec_dsn.etabli
        || ' num_ordre:'  || rec_dsn.num_ordre);
        P_INS_journal(1,'   Erreur :' || SQLERRM);
        P_INS_journal(1,'   fin de traitement de la remise DSN');
        CONTINUE;
    END;

    -- Date de création
    loc_dsn_crm.DATCRE := sysdate ;
    -- Date de mise à jour
    loc_dsn_crm.DATMAJ := sysdate ;
    -- Concentrateur
    --  Détermination du concentrateur à partir du nom de fichier DSN -- TODO à confirmer
    loc_dsn_crm.CONCENTRATEUR :=  PK_FICHIER.F_SPLIT(p_list=> rec_dsn.fichier
                                                    ,p_pos => 1
                                                    ,p_sep => '_') ;

    IF loc_dsn_crm.CONCENTRATEUR NOT IN ('FFSA','CTIP','FNMF')  THEN
      P_INS_journal(1,'   Concentrateur non géré par le traitement: ' ||loc_dsn_crm.CONCENTRATEUR
                      || ' pour le fichier DSN d''origine:'|| rec_dsn.fichier);
      P_INS_journal(1,'   => Arrêt traitement de la DSN');
      CONTINUE;
    ELSE
      -- P_INS_journal(2,'   Concentrateur identifié: ' ||loc_dsn_crm.CONCENTRATEUR);
      NULL;
    END IF;

    -- Identificant lot CRM (spécifif. FFSA)
    IF loc_dsn_crm.CONCENTRATEUR = 'FFSA' THEN
      loc_dsn_crm.IDLOTCRM := loc_idlotcrm;
    ELSE
      loc_dsn_crm.IDLOTCRM := NULL;
    END IF;
    -- Numéro de remise externe Arthus
    loc_dsn_crm.NUMREMISE  := loc_numremise_ext ;
    -- Nom du fichier CRM
    loc_dsn_crm.NOMFICHIER := F_CRM_FILENAME(i_concentrateur  => loc_dsn_crm.concentrateur
                                            ,i_numremise_ext  => loc_numremise_ext
                                            -- date/heure de ref
                                            ,i_timestamp      => loc_timestamp_ref
                                            -- Code organisme S21.G00.15.002
                                            ,i_orgn           => loc_orgn
                                            -- Code délégataire de gestion S21.G00.15.003
                                            ,i_deleg          => loc_param_batch.param2
                                            -- N° ordre déclaration S20.G00.05.004
                                            ,i_num_ordre      => nvl(rec_dsn.num_ordre_ini,rec_dsn.num_ordre)
                                            -- Identifiant déclaration S20.G00.96.902
                                            ,i_iddeclardsn    => rec_dsn.iddeclardsn
                                            -- Identifiant de l'envoi S10.G00.95.900
                                            ,i_idenvoi        => rec_dsn.idenvoi
                                            ,i_idTechniqueFichierCRMCetip => PK_FICHIER.F_SPLIT(p_list=> rec_dsn.fichier
                                                                                               ,p_pos => 3
                                                                                               ,p_sep => '_')
                                            ,i_VersionCRM     => const_versioncrm
                                            ,i_Iddsncrm       => loc_dsn_crm.IDDSNCRM);
    --P_INS_journal(3,'   Nom du fichier CRM : ' ||loc_dsn_crm.NOMFICHIER);

    -- Porte de remise Arthus de la DSN l'origine du retour CRM
    loc_dsn_crm.NUMPORTE_DSN := rec_dsn.numporte;
    -- Numéro de remise Arthus de la DSN l'origine du retour CRM
    loc_dsn_crm.NUMREMISE_DSN := rec_dsn.numremise ;
    -- Entreprise de la DSN l''origine du retour CRM (AFFIL_FICHIER.ENTREPRISE)
    loc_dsn_crm.ENTREPRISE_DSN := rec_dsn.entreprise;
    -- Etablissement de la DSN l'origine du retour CRM (AFFIL_FICHIER.ETABLI)
    loc_dsn_crm.ETABLI_DSN := rec_dsn.etabli;
    -- NUM_ORDRE de la DSN l'origine du retour CRM (AFFIL_FICHIER.NUM_ORDRE_INI)
    -- AFFIL_PORTE.NUM_ORDRE est modifié par le traitemnt d'intégration DSN, AFFIL_PORTE.NUM_ORDRE_INI correspond au contenu du fichier DSN
    loc_dsn_crm.NUM_ORDRE_DSN := NVL(rec_dsn.num_ordre_ini,rec_dsn.num_ordre);
    -- Version du CRM: Numéro de version du modèle de CRM
    loc_dsn_crm.VERSIONCRM := const_versioncrm ;
    -- Identifiant de l'envoi: Identifiant du flux attribué par le bloc 1 DSN
    loc_dsn_crm.IDENVOI   := rec_dsn.idenvoi ;
    ---------------------------------------------------
    -- Type de CRM: 1 (AR simple accusé de réception)
    --              2 (CRT compte-rendu basique)
    --              3 (CRC compte-rendu complet)
    CASE
      -- Fichier DSN test
      WHEN rec_dsn.codenvoidsn = 01 THEN
        P_INS_journal(2,'   Type de CRM: 1 (DSN code envoi: Test)');
        loc_dsn_crm.TYPCRM   := 2;
      -- Fichier DSN néant
      WHEN rec_dsn.type = 02 THEN
        P_INS_journal(2,'   Type de CRM: 2 (DSN type: Néant)');
        loc_dsn_crm.TYPCRM   := 2;
      -- paramètrage traitement
      WHEN TRIM(loc_param_batch.param1) = 'CRC' THEN
        P_INS_journal(2,'   Type de CRM: 3 (Paramétrage traitement)');
        loc_dsn_crm.TYPCRM   := 3;
      -- paramètrage traitement
      WHEN TRIM(loc_param_batch.param1) = 'CRT' THEN
        P_INS_journal(2,'   Type de CRM: 2 (Paramétrage traitement)');
        loc_dsn_crm.TYPCRM   := 2;
      ELSE
        P_INS_journal(2,'   Type de CRM: 2 (à Défaut)');
        loc_dsn_crm.TYPCRM   := 2;
    END CASE;
    -- Mode de dépôt: Mode de dépôt (upload ou Upload ou MtoM ou mtom) (S10.G00.95.006)
    loc_dsn_crm.MODEPOT := rec_dsn.modepot ;
    -- Site déposant: SIRET déposant dans le cas du MtoM (S10.G00.95.007)
    loc_dsn_crm.SITEDEPOSANT := NULL;
    -- Point de dépôt: Identification du point de dépôt bloc 1 (01=Net-Entreprises, 02=MSA) (S10.G00.00.007)
    loc_dsn_crm.PTDEPOT := rec_dsn.ptdepot;
    -- Taille du fichier: Taille du fichier en kilo octets
    loc_dsn_crm.TAILLEFICHIER := NULL;
    -- Date / Heure de réception sur le point de dépôt (S10.G00.95.008)
    loc_dsn_crm.DATDEPOT := rec_dsn.datdepot ;
    -- Nom du déclarant inscrit (S10.G00.95.001)
    loc_dsn_crm.NOMDEPOSANT := rec_dsn.nomdeclarant ;
    -- Prénom du déclarant inscrit (S10.G00.95.002)
    loc_dsn_crm.PRENOMDEPOSANT := rec_dsn.prenomdeclarant ;
    -- SIRET du déclarant inscrit (S10.G00.95.003)
    loc_dsn_crm.SIRETDEPOSANT := rec_dsn.siretdeclarant ;
    -- SIRET de l'émetteur du fichier reçu (S10.G00.01.001/002)
    loc_dsn_crm.SIRETEMETT := rec_dsn.siretemett;
    -- Nom/Raison sociale émetteur du fichier reçu (S10.G00.01.003)
    loc_dsn_crm.NOMEMETTEUR := rec_dsn.nomemett ;
    -- Type de l'envoi (01 = normal, 02 = néant) (S10.G00.00.008)
    loc_dsn_crm.TYPENVOIDSN := rec_dsn.typenvoidsn ;
    -- Version de la norme (P18V01 ou P19V01 ou P20V01) (S10.G00.00.006)
    loc_dsn_crm.VERSIONNORME := rec_dsn.norme;
    -- Code envoi du fichier d'essai ou réel (S10.G00.00.005)
    loc_dsn_crm.CODENVOIDSN := rec_dsn.CODENVOIDSN ;
    -- Date / heure à laquelle a été reçu le fichier par l'organisme porteur de risque
    CASE loc_dsn_crm.CONCENTRATEUR
      WHEN 'CTIP' THEN
        loc_dsn_crm.DATEHEURERECEPTIONOC := NULL;
      WHEN 'FFSA' THEN
        loc_dsn_crm.DATEHEURERECEPTIONOC := sysdate;
      WHEN 'FNMF' THEN
        loc_dsn_crm.DATEHEURERECEPTIONOC := NULL;
      ELSE
        loc_dsn_crm.DATEHEURERECEPTIONOC := NULL;
    END CASE;
    -- Date / Heure de réception par le délégataire de gestion
    loc_dsn_crm.DATEHEURERECEPTIONDELEG := sysdate ;
    -- Identifiant déclaration: Numéro relatif de la déclaration au sein du fichier reçu sur le bloc 1 (S20.G00.96.902)
    loc_dsn_crm.IDDECLARDSN := rec_dsn.iddeclardsn ;
    -- Nature de la déclaration  (S20.G00.05.001)
    loc_dsn_crm.NATUREDECLA := rec_dsn.nature;
    -- Type de la déclaration (01=normale, 02=normale néant, 03=annule et remplace intégral, 04=annule, 05=annule et remplace néant) (S20.G00.05.002)
    loc_dsn_crm.TYPEDECLA := rec_dsn.type ;
    -- Numéro de fraction de la déclaration (S20.G00.05.003)
    loc_dsn_crm.FRACTIONDECLA := rec_dsn.fractiondecla ;
    -- Identifiant de la déclaration initiale annulée ou remplacée (S20.G00.05.006)
    loc_dsn_crm.IDDECAR := rec_dsn.NUM_ANNUL;
    -- Date du mois principal déclaré (si nature mensuelle) (S20.G00.05.005)
    loc_dsn_crm.DATEMOISDEC := rec_dsn.DATEMOISDEC;
    -- Date de constitution du fichier (S20.G00.05.007)
    loc_dsn_crm.DATECONSTITUTION   := rec_dsn.DATECONSTITUTION;
    -- Identifiant métier (pour toutes les natures de DSN) (S20.G00.05.009)
    loc_dsn_crm.IDMETIERDSN :=  rec_dsn.IDMETIERDSN ;
    -- Champ de la déclaration  (S20.G00.05.008)
    loc_dsn_crm.CHAMDECDSN :=rec_dsn.CHAMDECDSN ;
    -- Nature de l'événement déclencheur du signalement
    loc_dsn_crm.NATUREEVENT := rec_dsn.NATEVENDSN ;
    -- NIC de l'établissement siège (S21.G00.06.002)
    loc_dsn_crm.NICSIEGEDECLA   := NULL ;
    -- Code de l'organisme porteur de risques (S21.G00.15.002)
    loc_dsn_crm.CODEOC := loc_orgn ;
    -- Code délégataire de gestion éventuel (Dxxxxx) ou (Gxxxxx) (S21.G00.15.003)
    loc_dsn_crm.CODEDELEG := loc_deleg ;
    -- Code organisme ou délégataire producteur du CRM
    loc_dsn_crm.CODEPRODUCTEURCRM := TRIM(loc_param_batch.param2) ;
    -- Raison sociale du producteur du CRM
    loc_dsn_crm.NOMPRODUCTEURCRM := TRIM(f_nom(1)) ;
    -- Date / Heure de production du CRM
    loc_dsn_crm.DATEHEUREPRODUCTIONCRM := sysdate ;
    -- Nombre de blocs S21.G00.30 présents dans la déclaration (1 pour un signalement, 1 à n pour une mensuelle normale, 0 pour une mensuelle néant)
    loc_dsn_crm.NBRESAL := NULL ;
    IF loc_dsn_crm.TYPCRM = 3 THEN
      -- Nombre d'erreurs de code Exxxnn dans la déclaration (obligatoire si CRCcompte-rendu complet)
      loc_dsn_crm.NBREERREUR   := 0;
    -- Nombre total d'erreurs critiques
      loc_dsn_crm.NBRECRITIQUE := 0 ;
    ELSE
      loc_dsn_crm.NBREERREUR   := NULL;
      loc_dsn_crm.NBRECRITIQUE := NULL ;
    END IF;
    -- Nombre total d'affiliations à prendre en compte
    loc_dsn_crm.NBREAFF := NULL ;
    -- Nombre total de radiations prises en compte
    loc_dsn_crm.NBRERAD := NULL ;
    -- Nom du contact chez le producteur du CRM
    loc_dsn_crm.NOMCONTACT := 'DSN ' || TRIM(f_nom(1)) ;
    -- Téléphone du contact
    loc_dsn_crm.TELCONTACT := loc_telcontact ;
    -- Courriel du contact
    --loc_dsn_crm.MAILCONTACT := TRIM(loc_param_batch.param3) ;
    loc_dsn_crm.MAILCONTACT := 'dsn@gerep.fr';
    -- Code retour global:
      -- 0 = DSN acceptée
      -- 1 = DSN acceptée, avec corrections à apporter
      -- 2 = DSN partiellement prise en compte
      -- 3 = DSN non prise en compte par l'organisme
    loc_dsn_crm.CODERETOURDECLA := 0 ;
    -- Complément explicatif du code retour global.
    -- Obligatoire si code retour global présent et différent de 0, en l'absence du niveau 3 (RetourMetier). Non requis si le niveau 3 est présent.
    loc_dsn_crm.COMPLEMENTRETOURDECLA := NULL ;

    -- Insert dans DSN_CRM
    P_INS_journal(3,'   Insert DSN_CRM iddsncrm: ' || loc_dsn_crm.IDDSNCRM);
    BEGIN
      INSERT INTO DSN_CRM VALUES loc_dsn_crm ;
    EXCEPTION
      WHEN OTHERS THEN
        P_INS_journal(1,'Erreur insert DSN_CRM: numremise ext:' || loc_dsn_crm.numremise
                      || ' iddsncrm: ' || loc_dsn_crm.IDDSNCRM
                      || ' '           || sqlerrm  );
        CONTINUE;
    END;

    -----------------------------------------------------------------------------
    -- Retours Métier à déclarer si CRM complet
    --       * Recherche des retours métiers issus de blocages (numano)
    --       * Recherche des retours métiers Autres)
    -----------------------------------------------------------------------------
    IF loc_dsn_crm.TYPCRM = 3 THEN
      -- init IdRetour (Numéro d'ordre du retour)
      loc_maxIdRetour := 0;
      -- Recherche des retours métiers issu de blocages
      P_INS_journal(3,'   Recherche Retours metier issus de blocages (numano)');
      FOR rec_retour in curs_retour (rec_dsn.numporte
                                    ,rec_dsn.numremise
                                    ,rec_dsn.entreprise
                                    ,rec_dsn.etabli
                                    ,rec_dsn.num_ordre ) LOOP
        loc_dsn_crm_retour := NULL;
        loc_dsn_crm_retour.coderetourmetier := rec_retour.coderr;
        --P_INS_journal(3,'      Retour metier trouvé  CodeCRM:' || loc_dsn_crm_retour.coderetourmetier);
        CASE loc_dsn_crm_retour.coderetourmetier
          WHEN 'EADH02' THEN -- Référence Contrat de l'adhésion erronée
            loc_IdRetour := F_CREA_DSN_CRM_RETOUR(i_IDDSNCRM             => loc_dsn_crm.iddsncrm
                                                 ,i_MAXIDRETOUR          => loc_maxIdRetour
                                                 ,i_CODERETOURMETIER     => loc_dsn_crm_retour.coderetourmetier
                                                 ,i_RUBRIQUEBLOCRETOUR   => 'S21.G00.15.001'  -- REFERENCE CONTRAT
                                                 ,i_VALEURRUBRIQUEERREUR => rec_retour.ref_orgn_cntrt);
            -- Si loc_IdRetour n'est pas null, alors un contexte peut être créé
            IF loc_IdRetour IS NOT NULL THEN
              P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                     ,i_IDRETOUR => loc_IdRetour
                                     ,i_RUBRIQUE => 'S21.G00.15.001'  -- REFERENCE CONTRAT
                                     ,i_VALEUR   => rec_retour.ref_orgn_cntrt);
              P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                     ,i_IDRETOUR => loc_IdRetour
                                     ,i_RUBRIQUE => 'S21.G00.15.002'  -- CODE OC
                                     ,i_VALEUR   => rec_retour.orgn);
              P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                     ,i_IDRETOUR => loc_IdRetour
                                     ,i_RUBRIQUE => 'S21.G00.15.003'  -- CODE DELEG
                                     ,i_VALEUR   => rec_retour.deleg);
            END IF;

          WHEN 'EFCT98' THEN -- Erreur fin de contrat
          -- Attention ce code peut être remonté en cas d'incident technique ou de donnée dans la BO incohérent.
          -- Il doit donc être cumulé avec un motif vide
            IF   TRIM(rec_retour.motifs) IS NULL
             AND TRIM(rec_retour.motifa) IS NULL THEN
              loc_IdRetour := F_CREA_DSN_CRM_RETOUR(i_IDDSNCRM             => loc_dsn_crm.iddsncrm
                                                   ,i_MAXIDRETOUR          => loc_maxIdRetour
                                                   ,i_CODERETOURMETIER     => loc_dsn_crm_retour.coderetourmetier
                                                   ,i_RUBRIQUEBLOCRETOUR   => 'S21.G00.62'  -- Fin du contrat
                                                   ,i_VALEURRUBRIQUEERREUR => NULL
                                                   ,i_DESCRIPTIONRETOUR    => 'Impossibilité de radier l''assuré'
                                                   ,i_DATEEVT              => sysdate);
              -- Si loc_IdRetour n'est pas null, alors un contexte peut être créé
              IF loc_IdRetour IS NOT NULL THEN
                P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                       ,i_IDRETOUR => loc_IdRetour
                                       ,i_RUBRIQUE => 'S21.G00.30.001'  -- NIR
                                       ,i_VALEUR   => rec_retour.numssa);
              END IF;
            END IF;

          WHEN 'EAFF03' THEN -- Code option erroné
            loc_IdRetour := F_CREA_DSN_CRM_RETOUR(i_IDDSNCRM             => loc_dsn_crm.iddsncrm
                                                 ,i_MAXIDRETOUR          => loc_maxIdRetour
                                                 ,i_CODERETOURMETIER     => loc_dsn_crm_retour.coderetourmetier
                                                 ,i_RUBRIQUEBLOCRETOUR   => 'S21.G00.70.004'  -- CODE OPTION
                                                 ,i_VALEURRUBRIQUEERREUR => NULL); -- TODO BCO A confirmer si on renseigne ou non
            IF loc_IdRetour IS NOT NULL THEN
              P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                     ,i_IDRETOUR => loc_IdRetour
                                     ,i_RUBRIQUE => 'S21.G00.15.001'  -- REFERENCE CONTRAT
                                     ,i_VALEUR   => rec_retour.ref_orgn_cntrt);
              P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                     ,i_IDRETOUR => loc_IdRetour
                                     ,i_RUBRIQUE => 'S21.G00.15.002'  -- CODE OC
                                     ,i_VALEUR   => rec_retour.orgn);
              P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                     ,i_IDRETOUR => loc_IdRetour
                                     ,i_RUBRIQUE => 'S21.G00.15.003'  -- CODE DELEG
                                     ,i_VALEUR   => rec_retour.deleg);
              P_FIND_OPTION(i_numporte  => rec_retour.numporte
                           ,i_numremise => rec_retour.numremise
                           ,i_numligne  => rec_retour.numligne
                           ,o_code_pop  => loc_code_pop
                           ,o_code_opt  => loc_code_opt);
              P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                     ,i_IDRETOUR => loc_IdRetour
                                     ,i_RUBRIQUE => 'S21.G00.70.004'  -- CODE OPTION
                                     ,i_VALEUR   => loc_code_opt);
              P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                     ,i_IDRETOUR => loc_IdRetour
                                     ,i_RUBRIQUE => 'S21.G00.70.005'  -- CODE POPULATION
                                     ,i_VALEUR   => loc_code_pop);
            END IF;

          WHEN 'EAFF06' THEN -- Code population erroné
            loc_IdRetour := F_CREA_DSN_CRM_RETOUR(i_IDDSNCRM             => loc_dsn_crm.iddsncrm
                                                 ,i_MAXIDRETOUR          => loc_maxIdRetour
                                                 ,i_CODERETOURMETIER     => loc_dsn_crm_retour.coderetourmetier
                                                 ,i_RUBRIQUEBLOCRETOUR   => 'S21.G00.70.005'  -- CODE POPULATION
                                                 ,i_VALEURRUBRIQUEERREUR => NULL); -- TODO BCO A confirmer si on renseigne ou non
            IF loc_IdRetour IS NOT NULL THEN
              P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                     ,i_IDRETOUR => loc_IdRetour
                                     ,i_RUBRIQUE => 'S21.G00.15.001'  -- REFERENCE CONTRAT
                                     ,i_VALEUR   => rec_retour.ref_orgn_cntrt);
              P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                     ,i_IDRETOUR => loc_IdRetour
                                     ,i_RUBRIQUE => 'S21.G00.15.002'  -- CODE OC
                                     ,i_VALEUR   => rec_retour.orgn);
              P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                     ,i_IDRETOUR => loc_IdRetour
                                     ,i_RUBRIQUE => 'S21.G00.15.003'  -- CODE DELEG
                                     ,i_VALEUR   => rec_retour.deleg);
              P_FIND_OPTION(i_numporte  => rec_retour.numporte
                           ,i_numremise => rec_retour.numremise
                           ,i_numligne  => rec_retour.numligne
                           ,o_code_pop  => loc_code_pop
                           ,o_code_opt  => loc_code_opt);
              P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                     ,i_IDRETOUR => loc_IdRetour
                                     ,i_RUBRIQUE => 'S21.G00.70.005'  -- CODE POPULATION
                                     ,i_VALEUR   => loc_code_pop);
            END IF;

          ELSE
            P_INS_journal(2,'Code Retour Metier <'||loc_dsn_crm_retour.coderetourmetier|| '>'
                            ||' non géré.');  -- TODO BCO à compléter
        END CASE;
      END LOOP ;

      -- Recherche des retours métiers issu de blocages EETB01
      P_INS_journal(3,'   Recherche Retours metier issus de blocages EETB01 (numano)');
      FOR rec_retour_EETB01 in curs_retour_EETB01 (rec_dsn.numporte
                                                  ,rec_dsn.numremise
                                                  ,rec_dsn.entreprise
                                                  ,rec_dsn.etabli
                                                  ,rec_dsn.num_ordre ) LOOP
        loc_dsn_crm_retour := NULL;
        loc_dsn_crm_retour.coderetourmetier := rec_retour_EETB01.coderr;
        --P_INS_journal(3,'      Retour metier trouvé  CodeCRM:' || loc_dsn_crm_retour.coderetourmetier);
        loc_IdRetour := F_CREA_DSN_CRM_RETOUR(i_IDDSNCRM             => loc_dsn_crm.iddsncrm
                                             ,i_MAXIDRETOUR          => loc_maxIdRetour
                                             ,i_CODERETOURMETIER     => loc_dsn_crm_retour.coderetourmetier
                                             ,i_RUBRIQUEBLOCRETOUR   => 'S21.G00.11'  -- Bloc Etablissement
                                             ,i_VALEURRUBRIQUEERREUR => NULL); -- Pas de valeur car Bloc entier
        -- Si loc_IdRetour n'est pas null, alors un contexte peut être créé
        IF loc_IdRetour IS NOT NULL THEN
          P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                 ,i_IDRETOUR => loc_IdRetour
                                 ,i_RUBRIQUE => 'S21.G00.15.001'  -- REFERENCE CONTRAT
                                 ,i_VALEUR   => rec_retour_EETB01.ref_orgn_cntrt);
          P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                 ,i_IDRETOUR => loc_IdRetour
                                 ,i_RUBRIQUE => 'S21.G00.15.002'  -- CODE OC
                                 ,i_VALEUR   => rec_retour_EETB01.orgn);
          P_CREA_DSN_CRM_CONTEXTE(i_IDDSNCRM => loc_dsn_crm.iddsncrm
                                 ,i_IDRETOUR => loc_IdRetour
                                 ,i_RUBRIQUE => 'S21.G00.15.003'  -- CODE DELEG
                                 ,i_VALEUR   => rec_retour_EETB01.deleg);
        END IF;
      END LOOP;



      -- Recherche et génération des retours EADH03 - Code OC de l'adhésion erroné
      P_INS_journal(3,'   Recherche des retours métiers Autres');
      P_RETOUR_EADH03(i_IDDSNCRM    => loc_dsn_crm.iddsncrm
                     ,i_MAXIDRETOUR => loc_maxIdRetour
                     ,i_numporte    => rec_dsn.numporte
                     ,i_numremise   => rec_dsn.numremise
                     ,i_entreprise  => rec_dsn.entreprise
                     ,i_etabli      => rec_dsn.etabli
                     ,i_num_ordre   => rec_dsn.num_ordre
                     ,i_datefic     => rec_dsn.datefic);
      -- Recherche et génération des retours EADH04 - Code DELEG de l'adhésion erroné
      P_RETOUR_EADH04(i_IDDSNCRM    => loc_dsn_crm.iddsncrm
                     ,i_MAXIDRETOUR => loc_maxIdRetour
                     ,i_numporte    => rec_dsn.numporte
                     ,i_numremise   => rec_dsn.numremise
                     ,i_entreprise  => rec_dsn.entreprise
                     ,i_etabli      => rec_dsn.etabli
                     ,i_num_ordre   => rec_dsn.num_ordre
                      -- Le code délégataire de GEREP est fixe. Il est passé en paramètre fixe du traitement
                     ,i_deleg       => TRIM(loc_param_batch.param2));
      -- Recherche et génération des retours IFCT99 - Information fin de contrat
      P_RETOUR_IFCT99(i_IDDSNCRM    => loc_dsn_crm.iddsncrm
                     ,i_MAXIDRETOUR => loc_maxIdRetour
                     ,i_numporte    => rec_dsn.numporte
                     ,i_numremise   => rec_dsn.numremise
                     ,i_entreprise  => rec_dsn.entreprise
                     ,i_etabli      => rec_dsn.etabli
                     ,i_num_ordre   => rec_dsn.num_ordre );
      -- Recherche et génération des retours ECINxx - Cotisations
      P_RETOUR_ECIN0X(i_IDDSNCRM    => loc_dsn_crm.iddsncrm
                     ,i_MAXIDRETOUR => loc_maxIdRetour
                     ,i_numporte    => rec_dsn.numporte
                     ,i_numremise   => rec_dsn.numremise
                     ,i_entreprise  => rec_dsn.entreprise
                     ,i_etabli      => rec_dsn.etabli
                     ,i_num_ordre   => rec_dsn.num_ordre );
    -- FinSi CRM Complet
    END IF ;

  END LOOP ;

  BEGIN
    SELECT COUNT(*)
    INTO loc_cpt_crm
    FROM DSN_CRM dc
    WHERE dc.numremise = loc_numremise_ext ;
  EXCEPTION
    WHEN OTHERS THEN
      loc_cpt_crm := 0;
  END;

  IF loc_cpt_crm > 0 THEN
    o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
             || 'Le traitement a constitué ' || TO_CHAR(loc_cpt_crm, '999990') || ' CRM DSN pour la remise externe '||  loc_numremise_ext);
  ELSE
    o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
             || 'Le traitement n''a constitué aucun CRM DSN');
  END IF;


  P_INS_journal(1,'Fin P_AF14');
  o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                 || 'Fin du traitement: ' || TO_CHAR(sysdate,'DD/MM/YYYY HH24:MI:SS'));

  -----------------------------------------------------------------------------

EXCEPTION
  WHEN exc_dep THEN
    P_INS_journal(1,'Paramétrage P1 du traitement absent');
  WHEN OTHERS THEN
    P_INS_journal(1,'Fin du traitement KO:' || SQLERRM);
    P_INS_journal(1,SUBSTR(sqlerrm,1,132));
    P_INS_journal(1,SUBSTR(sqlerrm,133,132));
    o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                  || 'Fin du traitement KO:' || SQLERRM );
    ROLLBACK;
END P_AF14;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_AF15                                                    */
/* Type         :  Public                                                    */
/* Description  :  Annulation d un bordereau de CRM DSN                      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_AF15 ( i_traitement    IN  TYP_BATCH.BATCHID%TYPE
                  ,i_numporte_ext  IN  REMISE_EXTERNE.NUMPORTE%TYPE
                  ,i_numremise_ext IN  REMISE_EXTERNE.NUMREMISE%TYPE
                  ,i_session       IN  JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1
                  ,i_niv_msg       IN  NUMBER)
IS

BEGIN

  G_nom_traitement  := i_traitement;
  G_idligne         := 1;
  G_session         := i_session;

  P_INS_journal(1,'Annulation de la remise CRM < '||i_numremise_ext||'>');

  BEGIN
    DELETE DSN_CRM_CONTEXTE ct
    WHERE ct.IDDSNCRM IN (SELECT cr.IDDSNCRM
                          FROM DSN_CRM cr
                          WHERE cr.NUMREMISE = i_numremise_ext);
  EXCEPTION
    WHEN OTHERS THEN
      P_INS_journal(1,'Erreur delete DSN_CRM_CONTEXTE. Fin du traitement KO:' || SQLERRM);
      ROLLBACK;
  END;

  BEGIN
    DELETE DSN_CRM_RETOUR rt
    WHERE rt.IDDSNCRM IN (SELECT cr.IDDSNCRM
                          FROM DSN_CRM cr
                          WHERE cr.NUMREMISE = i_numremise_ext);
  EXCEPTION
    WHEN OTHERS THEN
      P_INS_journal(1,'Erreur delete DSN_CRM_RETOUR. Fin du traitement KO:' || SQLERRM);
      ROLLBACK;
  END;

  BEGIN
    DELETE DSN_CRM
    WHERE NUMREMISE = i_numremise_ext;
  EXCEPTION
    WHEN OTHERS THEN
      P_INS_journal(1,'Erreur delete DSN_CRM. Fin du traitement KO:' || SQLERRM);
      ROLLBACK;
  END;

  BEGIN
    DELETE REMISE_EXTERNE
    WHERE NUMREMISE = i_numremise_ext
      AND NUMPORTE  = i_numporte_ext;
  EXCEPTION
    WHEN OTHERS THEN
      P_INS_journal(1,'Erreur delete REMISE_EXTERNE. Fin du traitement KO:' || SQLERRM);
      ROLLBACK;
  END;

  P_INS_journal(1,'Fin du traitement '|| I_traitement);

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'Fin du traitement KO:' || SQLERRM);
    ROLLBACK;

END P_AF15;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_AF16                                                    */
/* Type         :  Public                                                    */
/* Description  :  Génération des fichiers CRM DSN d'un bordereau (NUMREMISE)*/
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_AF16 ( i_traitement    IN  TYP_BATCH.BATCHID%TYPE
                  ,i_numremise_ext IN  REMISE_EXTERNE.NUMREMISE%TYPE
                  ,i_session       IN  JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1
                  ,i_niv_msg       IN  NUMBER DEFAULT 1
                  ,o_cptrendu      IN OUT CLOB)
IS

  -- Constantes
  const_versioncrm         NUMBER := 114;
  o_erreur                 VARCHAR2(5000);

  loc_repertoire           TYP_BATCH.REPERTOIRE%TYPE;
  loc_repertoire_archives  TYP_BATCH.REPERTOIRE%TYPE;

  loc_idenvoi              VARCHAR2(50);
  loc_param_batch          PARAM_BATCH%ROWTYPE;

  v_xml                    XMLTYPE;
  v_count                  NUMBER(9):=0;
  cpt_erreur               NUMBER:=0;
  cpt_fic                  NUMBER:=0;

  exc_fichier              EXCEPTION;

  loc_NomProducteur        VARCHAR2(50);
  loc_CodeProducteur       VARCHAR2(50);
  loc_EmailProducteur      VARCHAR2(50);

  -- Curseur de génération XML
  CURSOR  cur_crm ( p_numremise NUMBER) IS
    -- Première partie de l'union pour pour les fichiers de lot de CRMs (spécif FFSA)
    SELECT
       'LOT'    typxml
      ,lotcrm.concentrateur
      ,lotcrm.nomfichier
      ,XMLROOT(
         XMLELEMENT("LotCrm"
          ,XMLATTRIBUTES( lotcrm.IDLOTCRM AS "Id"
                        ,TO_CHAR(sysdate,'YYYY-MM-DD"T"HH24:MI:SS') AS "DateTimeGeneration"   -- format attendu "AAAA-MM-JJTHH:mm:ss"
                        ,loc_NomProducteur                          AS "NomProducteur"
                        ,loc_CodeProducteur                         AS "CodeProducteur"
                        ,loc_EmailProducteur                        AS "EmailProducteur"
                        ,TO_CHAR(const_versioncrm,'FM000')          AS "Version")
          ,(SELECT XMLAGG ( XMLELEMENT("Fichier"
                          ,XMLATTRIBUTES(  TO_CHAR(cr.versioncrm,'FM000')                         AS "VersionCRM"
                                         , cr.idenvoi                                             AS "IdEnvoi"
                                         , cr.typcrm                                              AS "TypCRM"
                                         , cr.modepot                                             AS "ModeDepot"
                                         , cr.sitedeposant                                        AS "SiteDeposant"
                                         , TO_CHAR(cr.ptdepot,'FM00')                             AS "PointDepot"
                                         , cr.taillefichier                                       AS "TailleFichier"
                                         , TO_CHAR(cr.datdepot,'YYYYMMDDHH24MISS')                AS "DateHeureReceptionDep"
                                         , cr.nomdeposant                                         AS "NomDeposant"
                                         , cr.prenomdeposant                                      AS "PrenomDeposant"
                                         , TO_CHAR(cr.siretdeposant,'FM00000000000000')           AS "SiretDeposant"
                                         , TO_CHAR(cr.siretemett,'FM00000000000000')              AS "SiretEmetteur"
                                         , REPLACE(REPLACE(cr.nomemetteur,'"',' '),'&',' ')       AS "NomEmetteur"
                                         , TO_CHAR(cr.typenvoidsn,'FM00')                         AS "TypeEnvoi"
                                         , cr.versionnorme                                        AS "VersionNorme"
                                         , TO_CHAR(cr.codenvoidsn,'FM00')                         AS "CodeEnvoi"
                                         , TO_CHAR(cr.dateheurereceptionoc,'YYYYMMDDHH24MISS')    AS "DateHeureReceptionOC"
                                         , TO_CHAR(cr.dateheurereceptiondeleg,'YYYYMMDDHH24MISS') AS "DateHeureReceptionDELEG"
                                         , 'http://www.w3.org/2001/XMLSchema-instance'            AS "xmlns:xsi")
                          ,XMLELEMENT("Declaration"
                            ,XMLATTRIBUTES( cr.iddeclardsn                                        AS "IdDec"
                                           ,TO_CHAR(cr.naturedecla,'FM00')                        AS "NatureDecla"
                                           ,TO_CHAR(cr.typedecla,'FM00')                          AS "TypeDecla"
                                           ,TO_CHAR(cr.fractiondecla,'FM00')                      AS "FractionDecla"
                                           ,cr.num_ordre_dsn                                      AS "NoOrdreDecla"
                                           ,cr.iddecar                                            AS "IdDecAR"
                                           ,TO_CHAR(cr.datemoisdec,'DDMMYYYY')                    AS "DateMoisDec"
                                           ,TO_CHAR(cr.dateconstitution,'DDMMYYYY')               AS "DateConstitution"
                                           ,cr.idmetierdsn                                        AS "IdEvt"
                                           ,TO_CHAR(cr.chamdecdsn,'FM00')                         AS "ChampDec"
                                           ,TO_CHAR(cr.natureevent,'FM00')                        AS "NatureEvent"
                                           ,TO_CHAR(cr.entreprise_dsn,'FM000000000')              AS "SirenDecla"
                                           ,TO_CHAR(cr.nicsiegedecla,'FM00000')                   AS "NicSiegeDecla"
                                           ,TO_CHAR(cr.etabli_dsn,'FM00000')                      AS "NicAffectation"
                                           ,cr.codeoc                                             AS "CodeOC"
                                           ,cr.codedeleg                                          AS "CodeDELEG"
                                           ,cr.codeproducteurcrm                                  AS "CodeProducteurCRM"
                                           ,cr.nomproducteurcrm                                   AS "NomProducteurCRM"
                                           ,TO_CHAR(cr.dateheureproductioncrm,'YYYYMMDDHH24MISS') AS "DateHeureProductionCRM"
                                           ,cr.nbresal                                            AS "NbreSal"
                                           ,cr.nbreerreur                                         AS "NbreErreur"
                                           ,cr.nbrecritique                                       AS "NbreCritique"
                                           ,cr.nbreaff                                            AS "NbreAff"
                                           ,cr.nbrerad                                            AS "NbreRad"
                                           ,cr.nomcontact                                         AS "NomContact"
                                           ,TO_CHAR(cr.telcontact,'FM0000000000')                 AS "TelContact"
                                           ,cr.mailcontact                                        AS "MailContact"
                                           ,cr.coderetourdecla                                    AS "CodeRetourDecla"
                                           ,cr.complementretourdecla                              AS "ComplementRetourDecla")
              ,(SELECT XMLAGG(XMLELEMENT("RetourMetier"
                ,XMLATTRIBUTES(  ret.IDRETOUR                     AS "IdRetour"
                               , ret.nberreurssimilaires          AS "NbErreursSimilaires"
                               , ret.coderetourmetier             AS "CodeRetourMetier"
                               , ret.libelcoderetourmetier        AS "LibelCodeRetourMetier"
                               , ret.criticiteretour              AS "CriticiteRetour"
                               , ret.descriptionretour            AS "DescriptionRetour"
                               , ret.rubriqueblocretour           AS "RubriqueBlocRetour"
                               , ret.libelrubblocretour           AS "LibelRubBlocRetour"
                               , ret.valeurrubriqueerreur         AS "ValeurRubriqueErreur"
                               , ret.libelvalrubriqueerreur       AS "LibelValRubriqueErreur"
                               , ret.valeurcorrigeeajoutee        AS "ValeurCorrigeeAjoutee"
                               , ret.libelvalcorrigeeajoutee      AS "LibelValCorrigeeAjoutee"
                               , TO_CHAR(ret.dateevt,'DDMMYYYY')  AS "DateEvt")
                ,(SELECT XMLAGG(XMLELEMENT("ContexteRetourMetier"
                        ,XMLATTRIBUTES( ctx.rubrique     AS "Rubrique"
                                       ,ctx.libelle      AS "Libelle"
                                       ,ctx.valeur       AS "Valeur"
                                       ,ctx.libelval     AS "LibelVal" ) )
                              ) FROM DSN_CRM_CONTEXTE ctx
                                -- sélection des aggregats Entités "ContexteRetourMetier"
                                WHERE  ctx.IDDSNCRM  = ret.IDDSNCRM
                                   AND ctx.IDRETOUR  = ret.IDRETOUR )
                            )) FROM DSN_CRM_RETOUR ret
                            -- sélection des aggregats Entités "RetourMetier"
                             WHERE ret.IDDSNCRM = cr.IDDSNCRM)
                ))
                          ) FROM DSN_CRM cr
                          -- sélection des aggregats Entités "Fichier" + "Déclaration"
                            WHERE cr.IDLOTCRM   = lotcrm.IDLOTCRM
                             AND  cr.numremise  = lotcrm.numremise
                             AND  cr.nomfichier = lotcrm.nomfichier))
        ,VERSION '1.0" encoding="ISO-8859-1') crm_xml_file
    FROM (SELECT DISTINCT
             cr.numremise
            ,cr.concentrateur
            ,cr.IDLOTCRM
            ,cr.nomfichier
          FROM DSN_CRM cr
          WHERE cr.numremise     = p_numremise
            AND cr.concentrateur ='FFSA'
         ) lotcrm
    UNION ALL
    -- seconde partie de l'union pour pour les fichiers CRMs (hors spécif FFSA)
    SELECT
       'FIC'    typxml
      ,ficcrm.concentrateur
      ,ficcrm.nomfichier
      ,XMLROOT(
         (SELECT XMLAGG ( XMLELEMENT("Fichier"
                          ,XMLATTRIBUTES(  TO_CHAR(cr.versioncrm,'FM000')                         AS "VersionCRM"
                                         , cr.idenvoi                                             AS "IdEnvoi"
                                         , cr.typcrm                                              AS "TypCRM"
                                         , cr.modepot                                             AS "ModeDepot"
                                         , cr.sitedeposant                                        AS "SiteDeposant"
                                         , TO_CHAR(cr.ptdepot,'FM00')                             AS "PointDepot"
                                         , cr.taillefichier                                       AS "TailleFichier"
                                         , TO_CHAR(cr.datdepot,'YYYYMMDDHH24MISS')                AS "DateHeureReceptionDep"
                                         , cr.nomdeposant                                         AS "NomDeposant"
                                         , cr.prenomdeposant                                      AS "PrenomDeposant"
                                         , TO_CHAR(cr.siretdeposant,'FM00000000000000')           AS "SiretDeposant"
                                         , TO_CHAR(cr.siretemett,'FM00000000000000')              AS "SiretEmetteur"
                                         , REPLACE(REPLACE(cr.nomemetteur,'"',' '),'&',' ')       AS "NomEmetteur"
                                         , TO_CHAR(cr.typenvoidsn,'FM00')                         AS "TypeEnvoi"
                                         , cr.versionnorme                                        AS "VersionNorme"
                                         , TO_CHAR(cr.codenvoidsn,'FM00')                         AS "CodeEnvoi"
                                         , TO_CHAR(cr.dateheurereceptionoc,'YYYYMMDDHH24MISS')    AS "DateHeureReceptionOC"
                                         , TO_CHAR(cr.dateheurereceptiondeleg,'YYYYMMDDHH24MISS') AS "DateHeureReceptionDELEG"
                                         , 'http://www.w3.org/2001/XMLSchema-instance'            AS "xmlns:xsi")
                          ,XMLELEMENT("Declaration"
                            ,XMLATTRIBUTES( cr.iddeclardsn                                        AS "IdDec"
                                           ,TO_CHAR(cr.naturedecla,'FM00')                        AS "NatureDecla"
                                           ,TO_CHAR(cr.typedecla,'FM00')                          AS "TypeDecla"
                                           ,TO_CHAR(cr.fractiondecla,'FM00')                      AS "FractionDecla"
                                           ,cr.num_ordre_dsn                                      AS "NoOrdreDecla"
                                           ,cr.iddecar                                            AS "IdDecAR"
                                           ,TO_CHAR(cr.datemoisdec,'DDMMYYYY')                    AS "DateMoisDec"
                                           ,TO_CHAR(cr.dateconstitution,'DDMMYYYY')               AS "DateConstitution"
                                           ,cr.idmetierdsn                                        AS "IdEvt"
                                           ,TO_CHAR(cr.chamdecdsn,'FM00')                         AS "ChampDec"
                                           ,TO_CHAR(cr.natureevent,'FM00')                        AS "NatureEvent"
                                           ,TO_CHAR(cr.entreprise_dsn,'FM000000000')              AS "SirenDecla"
                                           ,TO_CHAR(cr.nicsiegedecla,'FM00000')                   AS "NicSiegeDecla"
                                           ,TO_CHAR(cr.etabli_dsn,'FM00000')                      AS "NicAffectation"
                                           ,cr.codeoc                                             AS "CodeOC"
                                           ,cr.codedeleg                                          AS "CodeDELEG"
                                           ,cr.codeproducteurcrm                                  AS "CodeProducteurCRM"
                                           ,cr.nomproducteurcrm                                   AS "NomProducteurCRM"
                                           ,TO_CHAR(cr.dateheureproductioncrm,'YYYYMMDDHH24MISS') AS "DateHeureProductionCRM"
                                           ,cr.nbresal                                            AS "NbreSal"
                                           ,cr.nbreerreur                                         AS "NbreErreur"
                                           ,cr.nbrecritique                                       AS "NbreCritique"
                                           ,cr.nbreaff                                            AS "NbreAff"
                                           ,cr.nbrerad                                            AS "NbreRad"
                                           ,cr.nomcontact                                         AS "NomContact"
                                           ,TO_CHAR(cr.telcontact,'FM0000000000')                 AS "TelContact"
                                           ,cr.mailcontact                                        AS "MailContact"
                                           ,cr.coderetourdecla                                    AS "CodeRetourDecla"
                                           ,cr.complementretourdecla                              AS "ComplementRetourDecla")
              ,(SELECT XMLAGG(XMLELEMENT("RetourMetier"
                ,XMLATTRIBUTES(  ret.IDRETOUR                     AS "IdRetour"
                               , ret.nberreurssimilaires          AS "NbErreursSimilaires"
                               , ret.coderetourmetier             AS "CodeRetourMetier"
                               , ret.libelcoderetourmetier        AS "LibelCodeRetourMetier"
                               , ret.criticiteretour              AS "CriticiteRetour"
                               , ret.descriptionretour            AS "DescriptionRetour"
                               , ret.rubriqueblocretour           AS "RubriqueBlocRetour"
                               , ret.libelrubblocretour           AS "LibelRubBlocRetour"
                               , ret.valeurrubriqueerreur         AS "ValeurRubriqueErreur"
                               , ret.libelvalrubriqueerreur       AS "LibelValRubriqueErreur"
                               , ret.valeurcorrigeeajoutee        AS "ValeurCorrigeeAjoutee"
                               , ret.libelvalcorrigeeajoutee      AS "LibelValCorrigeeAjoutee"
                               , TO_CHAR(ret.dateevt,'DDMMYYYY')  AS "DateEvt")
                ,(SELECT XMLAGG(XMLELEMENT("ContexteRetourMetier"
                        ,XMLATTRIBUTES( ctx.rubrique     AS "Rubrique"
                                       ,ctx.libelle      AS "Libelle"
                                       ,ctx.valeur       AS "Valeur"
                                       ,ctx.libelval     AS "LibelVal" ) )
                              ) FROM DSN_CRM_CONTEXTE ctx
                                -- sélection des aggregats Entités "ContexteRetourMetier"
                                WHERE  ctx.IDDSNCRM  = ret.IDDSNCRM
                                   AND ctx.IDRETOUR  = ret.IDRETOUR )
                            )) FROM DSN_CRM_RETOUR ret
                            -- sélection des aggregats Entités "RetourMetier"
                             WHERE ret.IDDSNCRM = cr.IDDSNCRM)
                ))
                          ) FROM DSN_CRM cr
                          -- sélection des aggregats Entités "Fichier" + "Déclaration"
                            WHERE cr.numremise  = ficcrm.numremise
                             AND  cr.nomfichier = ficcrm.nomfichier)
        ,VERSION '1.0" encoding="ISO-8859-1') crm_xml_file
    FROM (SELECT DISTINCT
             cr.numremise
            ,cr.concentrateur
            ,cr.nomfichier
          FROM DSN_CRM cr
          WHERE cr.numremise     = p_numremise
            AND cr.concentrateur <> 'FFSA'
         ) ficcrm ;


BEGIN


  -----------------------------------------------------------------------------
  -- Paramètres du traitement
  -----------------------------------------------------------------------------
  G_nom_traitement:=i_traitement;
  G_idligne:=0;
  G_session:=i_session;
  P_INS_journal(1,'Traitement <'||i_traitement||'>, Génération des CRM de la remise <'||i_numremise_ext||'>');

  o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10) || CHR(13) || CHR(10)
               || 'Compte-rendu du Traitement <'||i_traitement||'> Génération des fichier CRM de la remise <'||i_numremise_ext||'>' || CHR(13) || CHR(10));
  o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                 || 'Debut du traitement: ' || TO_CHAR(sysdate,'DD/MM/YYYY HH24:MM:SS'));


  BEGIN
    SELECT * INTO loc_param_batch  FROM PARAM_BATCH
    WHERE NUMBATCH = g_nom_traitement;
  EXCEPTION
    WHEN OTHERS THEN
      P_INS_JOURNAL(1,'Probleme accès au paramètrage du traitement <'||g_nom_traitement||'> => Arret');
      P_INS_journal(1,SUBSTR(sqlerrm,1,132));
      P_INS_journal(1,SUBSTR(sqlerrm,133,132));
      o_cptrendu :=  CONCAT( o_cptrendu , CHR(13) || CHR(10)
                  || 'Probleme d''accès au paramètrage du traitement <'||g_nom_traitement||'> => Arret');
      RETURN;
  END;


  IF TRIM(loc_param_batch.param1) IS NULL THEN
    P_INS_JOURNAL(1,'Code Producteur CRM paramétré absent P1<'||g_nom_traitement ||'> => Arret' );
    o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                  || 'Code Producteur CRM paramétré absent du paramètre P1 du traitement <'||g_nom_traitement ||'> => Arret');
    RETURN;
  END IF;
  loc_CodeProducteur := TRIM(loc_param_batch.param1);
  P_INS_JOURNAL(1,'Code Producteur CRM paramétré: <'||loc_CodeProducteur||'>');

  -- TODO - A revoir, ne marche pas : PARAM_BATCH.PARAM3  VARCHAR2(10)  => une addresse mail ne rentre pas !!
  -- IF TRIM(loc_param_batch.param2) IS NULL THEN
  --   P_INS_JOURNAL(1,'Courriel du contact paramétré absent P2 <'||g_nom_traitement ||'> => Arret' );
  --   RETURN;
  -- END IF;
  -- loc_EmailProducteur := TRIM(loc_param_batch.param2);
  loc_EmailProducteur := 'dsn@gerep.fr';
  P_INS_JOURNAL(1,'Courriel du contact paramétré: <'||loc_EmailProducteur||'>');

  loc_NomProducteur  := TRIM(f_nom(1));

  -----------------------------------------------------------------------------
  -- Génération XML + Contrôles XSD
  -----------------------------------------------------------------------------
  P_INS_journal(1,'DEBUT controle CRM');
  FOR rec_crm IN cur_crm(i_numremise_ext) LOOP
    P_INS_journal(1,'Contrôle '
                 || 'TypXML:'         || rec_crm.typxml
                 || ' concentrateur:' || rec_crm.concentrateur
                 || ' fichier CRM:'   || rec_crm.nomfichier);
    BEGIN
      SELECT DIRECTORY_NAME INTO loc_repertoire FROM ALL_DIRECTORIES
      WHERE DIRECTORY_NAME = 'EXPORT_CRM_' || TRIM(rec_crm.concentrateur);
    EXCEPTION
      WHEN OTHERS THEN
        P_INS_journal(1,'Répertoire logique du Concentrateur ' || rec_crm.concentrateur || ' non trouvé'|| sqlerrm);
        o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                  || 'Répertoire logique du Concentrateur ' || rec_crm.concentrateur || ' non trouvé'|| sqlerrm || ' => Arret');
        RAISE exc_fichier;
    END;

    -- Si fichier de type LotCRM (spécif FFSA),
    -- alors Controle XSD des entités "LotCRM"
    IF rec_crm.typxml = 'LOT' THEN
      BEGIN
        v_xml := rec_crm.crm_xml_file.EXTRACT('/LotCrm[1]') ;
        v_xml := v_xml.createSchemaBasedXML('CDDACN_Modele_Entete_ACN_114.xsd');
        xmltype.schemaValidate(v_xml);
        P_INS_journal(1,'LotCRM => OK');
      EXCEPTION
        WHEN OTHERS THEN
          cpt_erreur := cpt_erreur + 1;
          loc_idenvoi := v_xml.extract('/LotCrm/@Id').getStringVal();
          o_erreur := 'Erreur rencontrée à la validation LotCRM du fichier CRM <' || rec_crm.nomfichier
                   || '> et LotCrm Id ' || loc_idenvoi
                   || ' :'           || SQLERRM;
          P_INS_journal(1,o_erreur);
          o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                  || o_erreur);
          o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                  || SQLERRM );
      END;
    END IF;

    -- Ctrl il existe une entité Fichier
    BEGIN
      IF rec_crm.crm_xml_file.existsNode('//Fichier[1]') = 1 THEN
        NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        cpt_erreur := cpt_erreur + 1;
        o_erreur := 'Erreur rencontrée sur le test de validation de l''entité "Fichier" du fichier ' || rec_crm.nomfichier
                    || ': XML sans Entité fichier.'
                    || ' :' || SUBSTR(SQLERRM,1,132);
        P_INS_journal(1,o_erreur);
        o_cptrendu :=  CONCAT( o_cptrendu , CHR(13) || CHR(10)
                || o_erreur);
        CONTINUE;
    END;

    -- Controle XSD des entités "Fichier"
    BEGIN
      v_count := 1;
      -- boucle sur les éléments "Fichier"
      -- "//Fichier" <=> tous les noeuds "Fichier" (qu'ils soient /Fichier ou /LotCRM/Fichier)
      WHILE rec_crm.crm_xml_file.existsNode('//Fichier[' || v_count || ']') = 1 LOOP
        P_INS_journal(1,'Analyse entité Fichier[' || v_count || ']');
        v_xml := rec_crm.crm_xml_file.EXTRACT('//Fichier[' || v_count || ']');
        -- Faire le test de validité XML pour connaitre l erreur
        BEGIN
          v_xml := v_xml.createSchemaBasedXML('CRM-DSN-OC-P3-V1.1.4.xsd');
          xmltype.schemaValidate(v_xml);
          P_INS_journal(1,'Fichier[' || v_count || '] => OK');
        EXCEPTION
          WHEN OTHERS THEN
            cpt_erreur := cpt_erreur + 1;
            loc_idenvoi := v_xml.extract('/Fichier/@IdEnvoi').getStringVal();
            o_erreur := 'Erreur rencontrée pour la validation Fichier du fichier ' || rec_crm.nomfichier
                        || ' et IdEnvoi ' || loc_idenvoi
                        || ' :'           || SUBSTR(SQLERRM,1,132);
            P_INS_journal(1,'Fichier[' || v_count || '] => ERREUR');
            P_INS_journal(1,o_erreur);
            o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                    || o_erreur);
        END;

        v_count := v_count + 1;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        cpt_erreur := cpt_erreur + 1;
        o_erreur := 'Erreur rencontrée sur le test de validation de l''entité "Fichier" du fichier ' || rec_crm.nomfichier
                    || ' :'           || SUBSTR(SQLERRM,1,132);
        P_INS_journal(1,'Fichier[' || v_count || '] => ERREUR');
        P_INS_journal(1,o_erreur);
        o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                || o_erreur);
    END;

    IF v_count = 1 THEN
      cpt_erreur := cpt_erreur+1;
      o_erreur := 'Aucune entité crm "Fichier" pour le fichier '|| rec_crm.nomfichier ;
      P_INS_journal(1,o_erreur);
      o_cptrendu :=  CONCAT( o_cptrendu , CHR(13) || CHR(10)
                  || o_erreur );
    END IF;

  END LOOP;
  P_INS_journal(1,'FIN controle CRM');


  IF cpt_erreur > 0 THEN
    o_erreur := 'Erreur: ' || cpt_erreur || ' erreur(s) ont été trouvée(s) à la validation structurelle des fichiers CRM.';
    P_INS_journal(1,o_erreur);
    o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                  || o_erreur);
    o_erreur := '=> Les fichiers CRM ne seront pas produits';
    P_INS_journal(1,o_erreur);
    o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                  || o_erreur);
  ELSE
    BEGIN
      SELECT DIRECTORY_NAME INTO loc_repertoire_archives FROM ALL_DIRECTORIES
      WHERE DIRECTORY_NAME = 'EXPORT_CRM_ARCHIVES';
    EXCEPTION
      WHEN OTHERS THEN
        P_INS_journal(1,'Répertoire logique archives CRM non trouvé:'|| sqlerrm);
        RAISE exc_fichier;
    END;

    -----------------------------------------------------------------------------
    -- Génération XML + Ecriture fichiers
    -----------------------------------------------------------------------------
    P_INS_journal(1,'DEBUT ecriture CRM');
    FOR rec_crm IN cur_crm(i_numremise_ext) LOOP
      P_INS_journal(1,'Ecriture'
                   || 'TypXML:'         || rec_crm.typxml
                   || ' concentrateur:' || rec_crm.concentrateur
                   || ' fichier CRM:'   || rec_crm.nomfichier);
      BEGIN
        SELECT DIRECTORY_NAME INTO loc_repertoire FROM ALL_DIRECTORIES
        WHERE DIRECTORY_NAME = 'EXPORT_CRM_' || TRIM(rec_crm.concentrateur);
      EXCEPTION
        WHEN OTHERS THEN
          P_INS_journal(1,'Répertoire logique du Concentrateur ' || rec_crm.concentrateur || ' non trouvé:'|| sqlerrm);
          RAISE exc_fichier;
      END;

      -- dbms_xmlgen.convert permet de ne pas 'echapper' les caractères ( ' en apos par exemple )
      DBMS_XSLPROCESSOR.clob2file( dbms_xmlgen.convert(rec_crm.crm_xml_file.getclobval(),1)
                                 , loc_repertoire
                                 , rec_crm.nomfichier);
      cpt_fic := cpt_fic + 1;

      -- Ecriture dans le repertoire d'archives
      DBMS_XSLPROCESSOR.clob2file( dbms_xmlgen.convert(rec_crm.crm_xml_file.getclobval(),1)
                                 , loc_repertoire_archives
                                 , rec_crm.nomfichier);

    END LOOP;
    PK_TPE.P_MAJ_REMISE_EXTERN_DATE_TRANS(i_numremise_ext);
    P_INS_journal(1,'FIN ecriture CRM');
  -- FinSi pas d'erreur
  END IF;

  o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                || 'Le traitement a généré ' || cpt_fic || ' fichiers CRM.');

  P_INS_journal(1,'Fin du traitement <'||i_traitement||'>');

  o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                 || 'Fin du traitement: ' || TO_CHAR(sysdate,'DD/MM/YYYY HH24:MI:SS'));

  COMMIT;


EXCEPTION
  WHEN exc_fichier THEN
    P_INS_journal(1,'Génération des CRM DSN impossible de la remise <'||i_numremise_ext||'>');
    ROLLBACK;
  WHEN OTHERS THEN
    --P_INS_journal(1,'Fin du traitement KO:' ||SQLERRM);
    P_INS_journal(1,'Anomalie traitement : '||SUBSTR(sqlerrm,1,132));
    P_INS_journal(1,'Anomalie traitement : '||SUBSTR(sqlerrm,133,132));
    o_cptrendu :=  CONCAT(o_cptrendu , CHR(13) || CHR(10)
                 || 'Anomalie traitement : '||sqlerrm);
    ROLLBACK;

END P_AF16;





/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_journal                                             */
/* Type         :  Public                                                    */
/* Description  :  procedure d'insertion dans journal ADM                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_journal(i_niv in NUMBER,
                        i_msg in VARCHAR2,
                        i_msg2 in varchar2 := null
                       )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
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

  IF g_niv_msg >= i_niv THEN
     g_idligne := g_idligne +1;
     PK_trace.P_INS_journal_adm (
        I_nom_traitement => g_nom_traitement,
        I_session  => nvl(g_session,SID),
        I_niv_msg  => i_niv,
        I_msg_adm  => substr(i_msg||' '||i_msg2,1,132),
        I_idligne  => g_idligne);
  END IF;
  COMMIT;
END P_INS_journal;



END PK_EXPORT_CRM_DSN;
/
