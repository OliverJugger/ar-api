CREATE OR REPLACE PACKAGE ARTHUS.PK_MA01T
AS
/*============================================================================*/
/* Package      : PK_MA01T.sql                                                */
/* Domaine      : Personnes                                                   */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 16/06/2016                                                  */
/* Description  : Importation d un fichier  de mails de GRITA vers ARTHUS     */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/

PROCEDURE P_MA01 ( i_traitement   IN    TYP_BATCH.BATCHID%TYPE,
                   i_repertoire   IN    VARCHAR2,
                   i_fichier      IN    VARCHAR2,
                   i_session      IN    NUMBER,
                   i_niv_msg      IN    NUMBER DEFAULT 1,
                   o_found        OUT   NUMBER,
                   o_erreur       OUT   VARCHAR2);

FUNCTION insertion_maj_mail ( i_repertoire  IN   VARCHAR2
                            , i_fichier     IN   VARCHAR2
                            , o_erreur      OUT  VARCHAR2)
RETURN BOOLEAN;

PROCEDURE P_INS_MAIL (i_items         IN       PK_FICHIER.TV_ITEMS
                    , o_flag             OUT   NUMBER);

FUNCTION F_INS_CONTACT(P_contact      CONTACT%ROWTYPE)
RETURN NUMBER;

PROCEDURE P_MAJ_CONTACT( P_Contact      IN  OUT CONTACT%ROWTYPE
                       , P_ano              OUT NUMBER);

FUNCTION F_INS_COURRIER_INFO( i_numindiv      IN     COURRIER_INFO.NUMINDIV%TYPE
                            , i_moyen_info    IN     COURRIER_INFO.MOYEN_INFO%TYPE
                            , i_type_crrr     IN     COURRIER_INFO.TYPE_CRRR%TYPE)
RETURN NUMBER;

PROCEDURE P_MAJ_COURRIER_INFO( i_numindiv            IN     COURRIER_INFO.NUMINDIV%TYPE
                             , i_moyen_info_avant    IN     COURRIER_INFO.MOYEN_INFO%TYPE
                             , i_moyen_info_apres    IN     COURRIER_INFO.MOYEN_INFO%TYPE
                             , i_type_crrr           IN     COURRIER_INFO.TYPE_CRRR%TYPE
                             , P_ano                    OUT NUMBER);


PROCEDURE P_INS_journal( i_niv  in NUMBER,
                         i_msg  in VARCHAR2,
                         i_msg2 in varchar2 := null);

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_MA01T AS
/*============================================================================*/
/* Package      : PK_MA01T.sql                                                */
/* Domaine      : Personnes                                                   */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 16/06/2016                                                  */
/* Description  : Importation d un fichier  de mails de GRITA vers ARTHUS     */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/

--VARIABLES GLOBALES
g_nom_traitement  journal_adm.nom_traitement%TYPE DEFAULT 'MA01T';
g_niv_msg         journal_adm.niv_msg%TYPE := NULL;
g_idligne         journal_adm.idligne%TYPE := 0;
g_msg_adm         journal_adm.msg_adm%TYPE;
g_session         NUMBER;

f_import          UTL_FILE.file_type;

-- -- TYPES PRIVEES -----------------------------------------------------------
TYPE  TV_ITEMS  IS  TABLE OF  VARCHAR2(256) INDEX BY BINARY_INTEGER;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MA01                                                    */
/* Type         :  Public                                                    */
/* Description  :  Importation du fichier csv de mails GRITA vers ARTHUS     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MA01 ( i_traitement   IN    TYP_BATCH.BATCHID%TYPE,
                   i_repertoire   IN    VARCHAR2,
                   i_fichier      IN    VARCHAR2,
                   i_session      IN    NUMBER,
                   i_niv_msg      IN    NUMBER DEFAULT 1,
                   o_found        OUT   NUMBER,
                   o_erreur       OUT   VARCHAR2)
IS

  loc_remise porte_remise.numremise%TYPE:=0;
  loc_fichier VARCHAR2(50);
  -- exception
  exc_technique                 EXCEPTION;
  exc_par_repertoire_vide       EXCEPTION;
  exc_par_fichier_vide          EXCEPTION;

BEGIN

  -----------------------------------------------------------------------------
  -- Recupération des parametres du traitement
  G_nom_traitement:=i_traitement;
  G_niv_msg:=i_niv_msg;
  G_idligne:=0;
  G_session:=i_session;
  P_INS_journal(1,'Début Traitement <'||i_traitement||'>'||', Répertoire <'||i_repertoire||'>');
  -----------------------------------------------------------------------------

  -- Enregistrement du fichier en base
  loc_fichier:=i_fichier;


  --------------- Controle du repertoire et du fichier ------------------------
  IF i_repertoire IS NULL THEN
     RAISE exc_par_repertoire_vide;
  END IF;

  IF i_fichier IS NULL OR i_fichier = ''
  THEN
     RAISE exc_par_fichier_vide;
  END IF;

  -- Insertion des données issues du fichier mails dans les tables Arthus
  IF insertion_maj_mail(i_repertoire, loc_fichier, o_erreur) THEN
    -- Validation de l import des mails et de l'ensemble des transactions dans Arthus
    COMMIT;
    P_INS_journal(1,'Veuillez consulter le rapport simplifié ou détaillé');
    o_found:=0;
  ELSE
    P_INS_journal(1, o_erreur);
    o_found:=1;
    ROLLBACK;
  END IF;

  P_INS_journal(1,'Fin Traitement <'||i_traitement||'>');

EXCEPTION
  WHEN exc_par_repertoire_vide THEN
    o_erreur:= O_erreur||'Nom du répertoire d''entrée manquant';
    o_found:=1;
  WHEN exc_par_fichier_vide THEN
    o_erreur:= O_erreur||'Nom du fichier d''entrée manquant';
    o_found:=1;
  WHEN OTHERS THEN
    o_found:=1;
    P_INS_journal(1,'Fin du traitement KO P_MA01:' || SQLERRM);
    ROLLBACK;
END P_MA01;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  insertion_maj_mail                                        */
/* Type         :  Privee                                                    */
/* Description  :  Insertion dans les differentes tables Arthus des données  */
/*                 issues du fichier des mails                               */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 s_fichier, Nom du fichier                                 */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*                 FALSE/TRUE                                                */
/*---------------------------------------------------------------------------*/
FUNCTION insertion_maj_mail ( i_repertoire  IN   VARCHAR2
                            , i_fichier     IN   VARCHAR2
                            , o_erreur      OUT  VARCHAR2)
RETURN BOOLEAN
IS
  f_import                 UTL_FILE.file_type;
  s_ligne                  VARCHAR2(5000):='';
  v_o_items                PK_FICHIER.TV_ITEMS;

  Loc_NUM_ASSURE           INDIVIDU.NUMINDIV%TYPE:=NULL;
  Loc_CIVILITE             INDIVIDU.QUALITE%TYPE:=NULL;
  Loc_Nom                  INDIVIDU.NOM%TYPE:=NULL;
  Loc_Prenom               INDIVIDU.PRENOM%TYPE:=NULL;
  Loc_Decomptes_Extranet   VARCHAR2(3):=NULL;

  loc_flag                 NUMBER:=NULL;
  loc_nb_ligne             NUMBER:=0;
  loc_nb_mail              NUMBER:=0;
  loc_nb_mail_OK           NUMBER:=0;
  loc_nb_mail_KO           NUMBER:=0;

  EXC_ENR_MSG                   EXCEPTION;
  exc_par_repertoire_vide       EXCEPTION;
  exc_par_fichier_vide          EXCEPTION;

BEGIN


  ------------------- Ouverture du fichier ------------------------------------
  f_import := UTL_FILE.fopen (i_repertoire, i_fichier, 'R', 32767);
  P_INS_journal(1,'insertion_maj_mail' );

  LOOP
    BEGIN
      loc_nb_ligne:=loc_nb_ligne+1;
      IF PK_FICHIER.fGetLine(f_import,s_ligne) THEN
        -- Vérification que l entête contient le bon nombre de colonne avec les libelles de chaque colonne conforme au cdc
        IF loc_nb_ligne = 1       THEN
          IF SUBSTR(s_ligne,0,44) =  'NUM_ASSURE;CIVILITE;NOM;PRENOM;MAIL;EXTRANET' THEN
          P_INS_journal(1,'Entete OK' );
        --  EXIT;
          ELSE
            P_INS_journal(1,'Structure du fichier non valide' );
            RAISE EXC_ENR_MSG;
          END IF;
        END IF;

          -- Convertire la ligne (avec séparateur) en tableau
          PK_FICHIER.pCreerTableau(s_ligne,v_o_items,';');

          IF SUBSTR(s_ligne,0,3) = 'NUM' THEN
           -- P_INS_journal(3,'Entête exclue s_ligne:' || SUBSTR(s_ligne,0,3));
           NULL;
          ELSE

            loc_nb_mail:=loc_nb_mail+1;
            --  P_INS_journal(3,'s_ligne:' || SUBSTR(s_ligne,0,3));
            -- Initialisation des variables
            Loc_NUM_ASSURE:=NULL;
            Loc_CIVILITE:=NULL;
            Loc_Nom:=NULL;
            Loc_Prenom:=NULL;
            Loc_Decomptes_Extranet:=NULL;

            ----------------------------------------------------------------------------
            -- Controle et insertion du mail
            ----------------------------------------------------------------------------
            P_INS_journal(1,'Traitement de la ligne  <' || TO_CHAR(loc_nb_ligne) || '> ');
            P_INS_MAIL(v_o_items, loc_flag);

            IF  loc_flag IN (1,2) THEN
              P_INS_journal(1,'La ligne <' || TO_CHAR(loc_nb_ligne) || '> est en erreur et n est pas importé');
              loc_nb_mail_KO:=loc_nb_mail_KO+1;
            ELSIF  loc_flag= 0 THEN
              loc_nb_mail_OK:=loc_nb_mail_OK+1;
            END IF;
          END IF;
     --   END IF; -- IF SUBSTR(s_ligne,0,128)
      ELSE
        EXIT;
      END IF;
    END;
  END LOOP;

  ---------- Fermeture du fichier ---------------------------------------------
  UTL_FILE.fclose (f_import);

  IF loc_flag = 2 THEN
    P_INS_journal(1,'Fin du traitement KO lors de l''importation des mails' );
    RETURN FALSE;
  ELSE
    --
    P_INS_journal(1,'Le nombre de mails traités est de <'||TO_CHAR(loc_nb_mail)||'>' );
    P_INS_journal(1,'Le nombre de création/maj avec succès de mails est de <'||TO_CHAR(loc_nb_mail_OK)||'>' );
    P_INS_journal(1,'Le nombre de mails en anomalie est de <'||TO_CHAR(loc_nb_mail_KO)||'>' );
    --
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN EXC_ENR_MSG THEN
    O_erreur := O_erreur|| ' Mauvaise structure du fichier ';
    RETURN FALSE;
  WHEN exc_par_repertoire_vide THEN
    o_erreur:= O_erreur||'Nom du répertoire d''entrée manquant';
    RETURN FALSE;
  WHEN exc_par_fichier_vide THEN
    o_erreur:= O_erreur||'Nom du fichier d''entrée manquant';
    RETURN FALSE;
  WHEN DBMS_LOB.operation_failed THEN
    UTL_FILE.fclose (f_import);
    o_erreur:=O_erreur||'Fichier '||i_fichier||' non présent dans le répertoire d''import';
    RETURN FALSE;
  WHEN UTL_FILE.internal_error THEN
    UTL_FILE.fclose (f_import);
    o_erreur:='UTL_FILE.INTERNAL_ERROR';
    RETURN FALSE;
  WHEN UTL_FILE.invalid_filehandle THEN
    UTL_FILE.fclose (f_import);
    o_erreur:='UTL_FILE.INVALID_FILEHANDLE';
    RETURN FALSE;
  WHEN UTL_FILE.invalid_mode THEN
    UTL_FILE.fclose (f_import);
    o_erreur:='UTL_FILE.INVALID_MODE';
    RETURN FALSE;
  WHEN UTL_FILE.invalid_operation THEN
    UTL_FILE.fclose (f_import);
    o_erreur:='UTL_FILE.INVALID_OPERATION';
    RETURN FALSE;
  WHEN UTL_FILE.invalid_path THEN
    UTL_FILE.fclose (f_import);
    o_erreur:='UTL_FILE.INVALID_PATH';
    RETURN FALSE;
  WHEN UTL_FILE.read_error THEN
    UTL_FILE.fclose (f_import);
    o_erreur:='UTL_FILE.READ_ERROR';
    RETURN FALSE;
  WHEN UTL_FILE.write_error THEN
    UTL_FILE.fclose (f_import);
    o_erreur:='UTL_FILE.WRITE_ERROR';
    RETURN FALSE;
  WHEN VALUE_ERROR THEN
    UTL_FILE.fclose (f_import);
    o_erreur:='VALUE_ERROR' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
    RETURN FALSE;
  WHEN OTHERS THEN
    IF UTL_FILE.is_open (f_import) THEN
      UTL_FILE.fclose (f_import);
    END IF;
    o_erreur:=G_nom_traitement||',' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
    RETURN FALSE;
END insertion_maj_mail;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_MAIL                                                  */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans RELEVE_COMPTE                  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_MAIL (i_items         IN       PK_FICHIER.TV_ITEMS
                    , o_flag             OUT   NUMBER)
IS

  loc_numindiv        INDIVIDU.NUMINDIV%TYPE:=NULL;
  loc_mail            CONTACT.COORDONNEE%TYPE:=NULL;
  loc_contact         CONTACT%ROWTYPE:=NULL;
  loc_dcpt            COURRIER_INFO.MOYEN_INFO%TYPE:=NULL;
  loc_info_dcpt       VARCHAR2(3):=NULL;          -- oui ou non


  loc_1                  NUMBER:=0;
  loc_2                  NUMBER:=0;
  loc_3                  NUMBER:=0;
  loc_4                  NUMBER:=0;

  loc_ok                 NUMBER:=0;
  loc_cpt                NUMBER:=0;

  exc_numindiv_null      EXCEPTION;
  exc_civilite_null      EXCEPTION;
  exc_nom_null           EXCEPTION;
  exc_prenom_null        EXCEPTION;
  exc_mail_null          EXCEPTION;
  exc_decompte_null      EXCEPTION;
  exc_numindiv_nofound   EXCEPTION;
  exc_ins_mail           EXCEPTION;
  exc_maj_mail           EXCEPTION;
  exc_ins_dcpt           EXCEPTION;
  exc_dcpt_invalide      EXCEPTION;
  exc_dcpt_nofound       EXCEPTION;
  exc_cpt_nofound        EXCEPTION;
  exc_maj_dcpt           EXCEPTION;

BEGIN
  o_flag :=0;
  loc_ok:=0;
  P_INS_journal(1,'Mail traité pour l individu <'|| i_items(1)||'>');

 ---------------------------------------------------------
 ------------------DEBUT CONTROLES -----------------------
 ---------------------------------------------------------

  -- Vérif que l individu est renseigné
  IF TRIM(i_items(1)) IS  NULL  THEN
    P_INS_journal(1,'Le numéro de l individu est vide');
    RAISE exc_numindiv_null;
  END IF;
  -- Vérif que la civilité est renseignée
  IF TRIM(i_items(2)) IS  NULL  THEN
    P_INS_journal(2,'La civilité est vide');
    RAISE exc_civilite_null;
  END IF;
  -- Vérif que le nom est renseigné
  IF TRIM(i_items(3)) IS  NULL  THEN
    P_INS_journal(2,'Le nom est vide');
    RAISE exc_nom_null;
  END IF;
  -- Vérif que le nom est renseigné
  IF TRIM(i_items(4)) IS  NULL  THEN
    P_INS_journal(2,'Le prénom est vide');
    RAISE exc_nom_null;
  END IF;
  -- Vérif que le mail est renseigné
  IF TRIM(i_items(5)) IS  NULL  THEN
    P_INS_journal(2,'Le mail est vide');
    RAISE exc_mail_null;
  END IF;
  -- Vérif que l info du décompte est renseigné
  IF TRIM(i_items(6)) IS  NULL  THEN
    P_INS_journal(2,'L info du décompte est vide');
    RAISE exc_decompte_null;
  END IF;

  -- Vérif que l'individu est existant en base de données ARTHUS ==> table INDIVIDU
  BEGIN
    SELECT NVL(max(numindiv),0)
      INTO loc_numindiv
      FROM individu
     WHERE numindiv=TO_NUMBER(i_items(1));

     IF loc_numindiv = 0 THEN
       P_INS_journal(1,'Individu inexistant en base de données');
       RAISE exc_numindiv_nofound;
     END IF;
  EXCEPTION
    WHEN exc_numindiv_nofound THEN
       RAISE exc_numindiv_nofound;
    WHEN OTHERS THEN
      P_INS_journal(1,'Individu inexistant en base de données, erreur indéterminée');
      RAISE exc_numindiv_nofound;
  END;

  -- Vérif que l'individu possède ou non une adresse mail personnel
  BEGIN
    SELECT NVL(max(numindiv),0)
      INTO loc_mail
      FROM contact
     WHERE numindiv=TO_NUMBER(i_items(1))
       AND nature=4    -- 4 ==> mail
       AND type=2      -- 2 ==> personnel
       ;
  EXCEPTION
    WHEN exc_numindiv_nofound THEN
       RAISE exc_numindiv_nofound;
    WHEN OTHERS THEN
      P_INS_journal(1,'Individu inexistant en base de données, erreur indéterminée');
      RAISE exc_numindiv_nofound;
  END;

 ---------------------------------------------------------
 ------------------FIN CONTROLES -------------------------
 ---------------------------------------------------------

 ------------------DEBUT MAIL-----------------------------
 ---------------------------------------------------------
 ------------------DEBUT INITIALISATION ------------------
 ---------------------------------------------------------

  loc_contact.NUMINDIV:=loc_numindiv;
  loc_contact.NATURE:=4;
  loc_contact.TYPE:=2;
  loc_contact.COORDONNEE:=TRIM(i_items(5));
  loc_contact.FLAG:='O';
  loc_contact.CREATION:=SYSDATE;
  loc_contact.MAJ:=SYSDATE;
  loc_contact.NUMUTIL:=F_NUMUTIL;
  SELECT idcontact.nextval INTO loc_contact.IDCONTACT FROM dual;

 ---------------------------------------------------------
 ------------------FIN INITIALISATION --------------------
 ---------------------------------------------------------

 ---------------------------------------------------------
 ------------------DEBUT INSERTION------------------------
 ---------------------------------------------------------

  -- Création de l''adresse mail
  IF loc_mail = 0 THEN
    P_INS_journal(1,'Création de l''adresse mail ');
    P_MAJ_CONTACT(loc_contact,loc_1); --loc_1:=F_INS_CONTACT(loc_contact);
    IF loc_1 = 1 THEN
      P_INS_journal(1,'Création impossible de l''adresse mail ');
      RAISE exc_ins_mail;
    END IF;

  END IF;
 ---------------------------------------------------------
 ------------------FIN INSERTION -------------------------
 ---------------------------------------------------------

 ---------------------------------------------------------
 ------------------DEBUT MODIFICATION --------------------
 ---------------------------------------------------------
  -- Modification de l''adresse mail si celle-ci est différente
  IF loc_mail > 0 THEN

    -- Vérif que l'individu possède ou non une adresse mail
    BEGIN
      SELECT UPPER(COORDONNEE)
        INTO loc_mail
        FROM contact
       WHERE numindiv=TO_NUMBER(i_items(1))
         AND nature=4    -- 4 ==> mail
         AND flag='O'    -- par défaut
         AND UPPER(TRIM(COORDONNEE))=UPPER(TRIM(i_items(5)))
         ;
      IF loc_mail IS NOT NULL THEN
        P_INS_journal(1,'Aucune modification a apportée sur le mail existant ');
      END IF;


    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         -- Mise à jour de la nouvelle adresse mail
        P_MAJ_CONTACT(loc_contact,loc_2);
        IF loc_2 = 1 THEN
          P_INS_journal(1,'Modification impossible de l''adresse mail ');
          RAISE exc_maj_mail;
        END IF;

      WHEN OTHERS THEN
        P_INS_journal(1,'Adresse mail ne pouvant être mise à jour, erreur indéterminée');
        RAISE exc_maj_mail;
    END;

  END IF;
 ---------------------------------------------------------
 ------------------FIN MODIFICATION ----------------------
 ---------------------------------------------------------
 --------------------FIN MAIL-----------------------------

 --------------------DEBUT DECOMPTE-----------------------

  -- Vérif que l'individu possède un le paramétrage pour recevoir un décompte santé
  -- Il doit être est existant en base de données ARTHUS ==> table COURRIER_INFO

  IF UPPER(TRIM(i_items(6))) = 'OUI' THEN
    loc_info_dcpt := 2;     -- extranet
  ELSIF UPPER(TRIM(i_items(6))) = 'NON' THEN
    loc_info_dcpt := 1;     -- decompte papier
  ELSE
    P_INS_journal(1,'L info. décompte est invalide: valeur attendue : <oui> ou <non>');
    RAISE exc_dcpt_invalide;
  END IF;


  BEGIN
    SELECT NVL(max(numindiv),0)
      INTO loc_numindiv
      FROM COURRIER_INFO
     WHERE numindiv=TO_NUMBER(i_items(1));

     IF loc_numindiv = 0 THEN
       P_INS_journal(1,'Info. décompte inexistant pour cet individu');
       RAISE exc_dcpt_nofound;
     END IF;
  EXCEPTION
    WHEN exc_dcpt_nofound THEN
      -- Création du contact
      IF loc_numindiv = 0 THEN
        P_INS_journal(1,'Création de l''Info. décompte ');
        loc_3:=F_INS_COURRIER_INFO(TO_NUMBER(i_items(1)), loc_info_dcpt, 28);
        IF loc_3 = 1 THEN
          P_INS_journal(1,'Création Info. décompte impossible');
          RAISE exc_ins_dcpt;
        END IF;
      END IF;
    WHEN OTHERS THEN
      P_INS_journal(1,'Création Info. décompte impossible, erreur indéterminée');
      RAISE exc_ins_dcpt;
  END;


  -- Modification de l''adresse mail si celle-ci est différente
  IF UPPER(TRIM(i_items(6))) IN ('OUI','NON')  THEN

  -- Vérif que l'individu possède ou non une info sur le type de décompte
    BEGIN
      SELECT NVL(MAX(MOYEN_INFO),0)
        INTO loc_dcpt
        FROM COURRIER_INFO
       WHERE numindiv=TO_NUMBER(i_items(1))
         AND TYPE_CRRR=28    -- 28 ==> on ne prend que les décomptes santé
         AND MOYEN_INFO =   loc_info_dcpt
         ;
      IF loc_dcpt = 0  THEN
        P_INS_journal(3,'Modification a apporter sur l info. décompte ');
        IF loc_info_dcpt = 1 THEN
          loc_dcpt := 2;     -- extranet
        ELSIF loc_info_dcpt = 2 THEN
          loc_dcpt := 1;     -- decompte papier
        END IF;
        RAISE exc_cpt_nofound;
      ELSE
        P_INS_journal(3,'Aucune modification a apportée sur l info. décompte ');
      END IF;


    EXCEPTION
      WHEN exc_cpt_nofound THEN
         -- Mise à jour de l info. décompte
      /*  P_INS_journal(1,'avant P_MAJ_COURRIER_INFO:'||i_items(1));
        P_INS_journal(1,'avant P_MAJ_COURRIER_INFO loc_dcpt:'||loc_dcpt);
        P_INS_journal(1,'avant P_MAJ_COURRIER_INFO loc_info_dcpt:'||loc_info_dcpt);
        P_INS_journal(1,'avant P_MAJ_COURRIER_INFO loc_4:'||loc_4);        */
        P_MAJ_COURRIER_INFO(TO_NUMBER(i_items(1)), loc_dcpt,loc_info_dcpt, 28, loc_4);
        IF loc_4 = 1 THEN
          P_INS_journal(3,'Modification impossible sur l info. décompte');
          RAISE exc_maj_dcpt;
        END IF;

      WHEN OTHERS THEN
        P_INS_journal(3,'sur l info. décompte ne pouvant être mise à jour, erreur indéterminée');
        RAISE exc_maj_dcpt;
    END;


  ELSE
    P_INS_journal(3,'L info. décompte est invalide: valeur attendue : <oui> ou <non>');
    RAISE exc_dcpt_invalide;
  END IF;



 --------------------FIN DECOMPTE-------------------------

EXCEPTION
  WHEN exc_numindiv_null THEN
    o_flag:=1;
  WHEN exc_civilite_null THEN
    o_flag:=1;
  WHEN exc_nom_null THEN
    o_flag:=1;
  WHEN exc_prenom_null THEN
    o_flag:=1;
  WHEN exc_mail_null THEN
    o_flag:=1;
  WHEN exc_decompte_null THEN
    o_flag:=1;
  WHEN exc_numindiv_nofound THEN
    o_flag:=1;
  WHEN exc_ins_mail THEN
    o_flag:=1;
  WHEN exc_maj_mail THEN
    o_flag:=1;
  WHEN exc_ins_dcpt THEN
    o_flag:=1;
  WHEN exc_maj_dcpt THEN
    o_flag:=1;
  WHEN exc_dcpt_invalide THEN
    o_flag:=1;
  WHEN OTHERS THEN
    o_flag:=2;
    P_INS_journal(1,'Fin du traitement KO:' || SQLERRM);
END P_INS_MAIL;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INS_COURRIER_INFO                                       */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans COURRIER_INFO                  */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_COURRIER_INFO( i_numindiv      IN     COURRIER_INFO.NUMINDIV%TYPE
                            , i_moyen_info    IN     COURRIER_INFO.MOYEN_INFO%TYPE
                            , i_type_crrr     IN     COURRIER_INFO.TYPE_CRRR%TYPE)
RETURN NUMBER
IS

BEGIN
  INSERT INTO COURRIER_INFO(NUMINDIV,MOYEN_INFO,TYPE_CRRR) VALUES (i_numindiv,i_moyen_info,i_type_crrr);
  RETURN 0;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 1;
END F_INS_COURRIER_INFO;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_INS_CONTACT                                             */
/* Type         :  Public                                                    */
/* Description  :  procedure d insertion dans CONTACT                        */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_INS_CONTACT(P_contact      CONTACT%ROWTYPE)
RETURN NUMBER
IS

BEGIN
  INSERT INTO CONTACT VALUES P_contact;
  RETURN 0;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 1;
END F_INS_CONTACT;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_COURRIER_INFO                                       */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour de moyen_info dans COURRIER_INFO */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_COURRIER_INFO( i_numindiv            IN     COURRIER_INFO.NUMINDIV%TYPE
                             , i_moyen_info_avant    IN     COURRIER_INFO.MOYEN_INFO%TYPE
                             , i_moyen_info_apres    IN     COURRIER_INFO.MOYEN_INFO%TYPE
                             , i_type_crrr           IN     COURRIER_INFO.TYPE_CRRR%TYPE
                             , P_ano                    OUT NUMBER)
IS

BEGIN
  P_ano:=0;

  -- Mise à jour du moyen_info : décompte papier ou extranet
  UPDATE COURRIER_INFO
     SET MOYEN_INFO=i_moyen_info_apres
   WHERE NUMINDIV=i_numindiv
     AND MOYEN_INFO=i_moyen_info_avant
     AND TYPE_CRRR=i_type_crrr;

EXCEPTION
  WHEN OTHERS THEN
  P_ano:=1;
  P_INS_journal(1,' Erreur : Mise a jour impossible de COURRIER_INFO.MOYEN_INFO:'||SUBSTR(SQLERRM,1,132));
END P_MAJ_COURRIER_INFO;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_MAJ_CONTACT                                             */
/* Type         :  Public                                                    */
/* Description  :  procedure de mise à jour des coordonnees dans CONTACT     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_MAJ_CONTACT( P_Contact      IN  OUT CONTACT%ROWTYPE
                       , P_ano              OUT NUMBER)
IS

  Loc_idcontact      CONTACT.IDCONTACT%TYPE:=NULL;

BEGIN
  P_ano:=0;
  /*
  loc_contact.NUMINDIV:=loc_numindiv;
  loc_contact.NATURE:=4;
  loc_contact.TYPE:=2;
  loc_contact.COORDONNEE:=TRIM(i_items(5));
  loc_contact.FLAG:='O';
  loc_contact.CREATION:=SYSDATE;
  loc_contact.MAJ:=SYSDATE;
  loc_contact.NUMUTIL:=F_NUMUTIL;

    */

  -- Récupération du dernier contact valide (adresse professionnel)
  SELECT NVL(max(IDCONTACT),0)
    INTO Loc_idcontact
    FROM CONTACT
   WHERE NUMINDIV=P_Contact.numindiv
     AND flag=P_Contact.flag
     AND nature=P_Contact.nature
    -- AND type=P_Contact.type
     ;
  BEGIN
  -- Mise à jour flag par défaut à N et mise à jour de la date
  UPDATE CONTACT
     SET FLAG='N' , MAJ=SYSDATE
   WHERE NUMINDIV=P_Contact.numindiv
     AND flag='O'
   --  AND nature=P_Contact.nature
   --  AND type=P_Contact.type
     ;
  EXCEPTION
    WHEN OTHERS THEN
         P_INS_journal(1,' Erreur : Mise a jour impossible de CONTACT:'||SUBSTR(SQLERRM,1,132));
  END;
  -- Récupération d'un nouveau identifiant pour le nouveau contact
  SELECT idcontact.nextval INTO P_Contact.idcontact FROM dual;

  -- Insertion du nouveau contact mail personnel
  P_ano:=F_INS_CONTACT(P_Contact);


EXCEPTION
  WHEN OTHERS THEN
  P_ano:=2;
  P_INS_journal(3,' Erreur : Mise a jour impossible de CONTACT.COORDONNEE:'||SUBSTR(SQLERRM,1,132));
END P_MAJ_CONTACT;

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


END PK_MA01T;
/
