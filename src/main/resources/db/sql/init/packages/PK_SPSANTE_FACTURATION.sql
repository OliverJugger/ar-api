CREATE OR REPLACE PACKAGE ARTHUS."PK_SPSANTE_FACTURATION"
AS
/*============================================================================*/
/* PACKAGE      : PK_SPSANTE_FACTURATION.sql                                  */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 07/10/2011                                                  */
/* Description  : Package permettant l envoi des 2 flux quotidiens au CETIP.  */
/*                Les 2 flux contiennent le nombre de PEC Facturée ou Périmée.*/
/*                Les 2 fichiers sont générés lors de l'import des avis de    */
/*                paiement et respecte la norme definis dans le CDC du CETIP  */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : JBO / 01/02/2013 / Mantis 3842, Modification du curseur des */
/*                prises en charges facturées afin de prendre en compte tous  */
/*               les états des PEC facturées(Jointure externe sur le curseur) */
/*============================================================================*/
/* Correction   : ABO / 15/01/2015 / optimisation des traitements pour la     */
/*                en compte des historiques de dossier
/*============================================================================*/

PROCEDURE envoiNbEtatPEC (i_repertoire   IN   VARCHAR2
                        , i_fichier      IN   VARCHAR2
                        , i_remise       IN   NUMBER
                        , o_erreur       OUT  VARCHAR2);

PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);
-- ------------------------------------------------- Fin des procedures publiques --
END PK_SPSANTE_FACTURATION;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_SPSANTE_FACTURATION" 
As
/*============================================================================*/
/* PACKAGE      : PK_SPSANTE_FACTURATION.sql                                  */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 07/10/2011                                                  */
/* Description  : Package permettant l envoi des 2 flux quotidiens au CETIP.  */
/*                Les 2 flux contiennent le nombre de PEC Facturée ou Périmée.*/
/*                Les 2 fichiers sont générés lors de l'import des avis de    */
/*                paiement et respecte la norme definis dans le CDC du CETIP  */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : JBO / 01/02/2013 / Mantis 3842, Modification du curseur des */
/*                prises en charges facturées afin de prendre en compte tous  */
/*               les états des PEC facturées(Jointure externe sur le curseur) */
/*============================================================================*/
/* Correction   : ABO / 15/01/2015 / optimisation des traitements pour la     */
/*                en compte des historiques de dossier
/*============================================================================*/

   -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
--
  e_par_repertoire_vide       EXCEPTION;
  e_par_fichier_vide          EXCEPTION;

   -- -- PROCEDURES PRIVEES ----------------------------------------------------
--
FUNCTION f_creationFichier(i_repertoire  IN   VARCHAR2
                         , i_fichier     IN   NUMBER
                         , o_erreur      OUT  VARCHAR2
                         , s_fichier     IN   VARCHAR2)
RETURN BOOLEAN;

PROCEDURE ecrireEnteteDebut;

PROCEDURE ecrireEnteteFin;

PROCEDURE ecrireLigne(i_fichier IN NUMBER);

PROCEDURE insertSTOCK_FACT_SP(i_fichier IN NUMBER);

  G_nom_traitement  Constant journal_adm.nom_traitement%TYPE default 'TR14T';
  G_niv_msg         journal_adm.niv_msg%TYPE;
  G_idligne         journal_adm.idligne%TYPE := 0;
  g_msg_adm         journal_adm.msg_adm%TYPE;

  -- Déclaration des variables globales
  f_sortie                    UTL_FILE.file_type;
  g_fichier                   VARCHAR2 (200);
  buffer                      CLOB;
  bufferFichier               CLOB;
  g_nbTot                     NUMBER(8):=2; -- Car on prend en compte la ligne de l'entête de début et l'entête de fin de fichier
  g_nbTot01                   NUMBER(8):=0;
  g_nbTot02                   NUMBER(8):=0;
  g_totMtDepense              NUMBER(10,2):=0;
  g_totMtRO                   NUMBER(10,2):=0;
  g_totMtRC                   NUMBER(10,2):=0;
  g_remise                    NUMBER:=NULL;
  g_id_stock_fact_sp          NUMBER:=NULL;

  -- Déclaration des curseurs globales
  CURSOR C_PEC_Facture
     IS
    SELECT DISTINCT ds.NUM_DOSSIER,
        SUM( s.MTFRAIS*100) MTFRAIS,
        SUM(s.MTREMB*100) MTREMB,
        SUM(s.MTREEL*100) MTREEL,
        (SUM(MTFRAIS) -SUM(MTREMB)-SUM(MTREEL))  MTRAC,
        ds.REF_DOSSIER,
        ds.NUM_FACT_PEC,
        ds.DATE_FACT_PEC,
        s.NUMINDIV,
        s.NUMBENE,
        i.NOM,
        i.PRENOM,
        i.MATORG || i.CLESS NUMSECU,
        i.DATNAIS,
        i.RANG,
        s.DATSIN,
        ds.CREATION,
        ds.DATEFERM,
        NULL PEREMPTION
   FROM  DOSSIER_SANTE ds
      , INDIVIDU i
      , SINISTRE s
      , SNTR_DOSSIER sd
      , HISTO_DOSSIER h
  WHERE sd.NUMSIN_SNTR = s.NUMSIN
    AND sd.num_dossier=ds.num_dossier
    AND ds.TYPE_DOSS=1
    AND ds.NUM_DOSSIER_PEC IS NOT NULL -- Concerne que les PEC
    AND ds.PEC = 1
    AND i.NUMINDIV = s.NUMINDIV
    AND h.num_dossier = ds.num_dossier
   AND  h.debut in (select max(h2.debut) from histo_dossier h2 where h2.num_dossier = h.num_dossier)
    AND h.etat= 0 
    AND h.motif =0
    AND ds.NUMPORTE=15
  GROUP BY ds.NUM_DOSSIER
         , ds.REF_DOSSIER
         , ds.NUM_FACT_PEC
         , ds.DATE_FACT_PEC
         , s.NUMINDIV
         , s.NUMBENE
         , i.NOM
         , i.PRENOM
         , i.MATORG || i.CLESS
         , i.DATNAIS
         , i.RANG
         , s.DATSIN
         , ds.CREATION
         , ds.DATEFERM;      

  record_PECF C_PEC_Facture%ROWTYPE;

  -- Prise en charge périmée
  CURSOR C_PEC_Perime
     IS
  SELECT DISTINCT ds.NUM_DOSSIER,
        SUM( s.MTFRAIS*100) MTFRAIS,
        SUM(s.MTREMB*100) MTREMB,
        SUM(s.MTREEL*100) MTREEL,
        (SUM(MTFRAIS) -SUM(MTREMB)-SUM(MTREEL)) MTRAC,
        ds.REF_DOSSIER,
        ds.NUM_FACT_PEC,
        ds.DATE_FACT_PEC,
        s.NUMINDIV,
        s.NUMBENE,
        i.NOM,
        i.PRENOM,
        i.MATORG || i.CLESS NUMSECU,
        i.DATNAIS,
        i.RANG,
        s.DATSIN,
        ds.CREATION,
        ds.DATEFERM,
        MIN(h.DEBUT)  PEREMPTION
   FROM DOSSIER_SANTE ds
      , INDIVIDU i
      , SINISTRE s
      , SNTR_DOSSIER sd
      , HISTO_DOSSIER h
  WHERE ds.NUM_DOSSIER=sd.NUM_DOSSIER
    AND ds.NUM_DOSSIER = h.NUM_DOSSIER
    AND ds.TYPE_DOSS=4  -- Concerne que les PEC
    AND sd.NUMSIN_SNTR = s.NUMSIN
    AND ds.NUM_DOSSIER_PEC IS NULL
    AND i.NUMINDIV = s.NUMINDIV
    AND h.ETAT = 1
    AND h.MOTIF = 2
    AND h.debut in (select max(h2.debut) from histo_dossier h2 where h2.num_dossier = h.num_dossier and h2.debut <= sysdate)
    AND ds.NUMPORTE=15
  GROUP BY ds.NUM_DOSSIER
         , ds.REF_DOSSIER
         , ds.NUM_FACT_PEC
         , ds.DATE_FACT_PEC
         , s.NUMINDIV
         , s.NUMBENE
         , i.NOM
         , i.PRENOM
         , i.MATORG || i.CLESS
         , i.DATNAIS
         , i.RANG
         , s.DATSIN
         , ds.CREATION
         , ds.DATEFERM;

  record_PECP C_PEC_Perime%ROWTYPE;

  -- Chaine de reconnaissance SCCS
  -- %W%  %E%
  -- ---------------------------------------------- Fin des constantes privees --

  -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
  -- Aucune
  -- ---------------------------------------------- Fin des exceptions privees --

  -- -- TYPES PRIVEES -----------------------------------------------------------
  -- Aucun
  -- --------------------------------------------------- Fin des types privees --

  -- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------

-- -- CORPS DES PROCEDURES ET FONCTIONS PUBLIQUES --------------------------

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  envoiNbEtatPEC                                            */
/* Type         :  Public                                                    */
/* Description  :  Permet l envoi des 2 flux quotidiens au CETIP : Facturée  */
/*                 ou Annulée respectant une norme du CDC. Fichiers à plat   */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 i_fichierF, fichier Facturé                               */
/*                 i_fichierA, fichier Annulé                                */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
PROCEDURE envoiNbEtatPEC (i_repertoire   IN   VARCHAR2
                        , i_fichier      IN   VARCHAR2
                        , i_remise       IN   NUMBER
                        , o_erreur       OUT  VARCHAR2)
IS

  b_ok        BOOLEAN:=FALSE;

BEGIN

  P_INS_journal(1,'DEBUT PK_SPSANTE_FACTURATION.envoiNbEtatPEC le '||TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS'));

  g_remise:=i_remise;
  g_fichier:=i_fichier;
  bufferFichier:='';

  -- Création du fichier des PEC facturées
  b_ok:= f_creationFichier(i_repertoire, 1, o_erreur, i_fichier);
  IF b_ok THEN
  -- Création du fichier des PEC périmées
    b_ok:= f_creationFichier(i_repertoire, 2, o_erreur, i_fichier);
  END IF;

  P_INS_journal(1,'FIN PK_SPSANTE_FACTURATION.envoiNbEtatPEC le '||TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS'));

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal('TR14T',SUBSTR(SQLERRM,1,132));
END envoiNbEtatPEC;

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  f_creationFichier                                         */
/* Type         :  Privee                                                    */
/* Description  :  Création flux quotidiens au CETIP : Facturée ou Annulée   */
/*                 respectant une norme du CDC. Fichiers à plat              */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 i_fichier, Nom du fichier                                 */
/*                 type, fichier Facturé(1) ou Annulé(2)                     */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*                 FALSE/TRUE                                                */
/*---------------------------------------------------------------------------*/
FUNCTION f_creationFichier(i_repertoire  IN   VARCHAR2
                         , i_fichier     IN   NUMBER
                         , o_erreur      OUT  VARCHAR2
                         , s_fichier     IN   VARCHAR2)
RETURN BOOLEAN
IS

BEGIN

  -- Formatage du nom du fichier
  g_id_stock_fact_sp:=NULL;
  g_fichier:=NULL;
  IF i_fichier = 1 THEN -- Facturé
    g_fichier:= REPLACE(REPLACE(s_fichier, '#CE', 'FCE'),'#3P', 'A3P');--REPLACE(s_fichier,'#','F');
  ELSIF i_fichier = 2 THEN -- Périmé
    g_fichier:= REPLACE(REPLACE(s_fichier, '#CE', 'ACE'),'#3P', 'T3P');--REPLACE(s_fichier,'#','A');
  END IF;

  SELECT ID_STOCK_FACT_SP.NEXTVAL
    INTO g_id_stock_fact_sp
    FROM DUAL;


  P_INS_journal(3,'g_fichier:'||g_fichier);
  P_INS_journal(3,'g_fichier:'||g_fichier);
  P_INS_journal(3,'i_repertoire:'||i_repertoire);
  P_INS_journal(3,'g_id_stock_fact_sp:'||g_id_stock_fact_sp);

  -- Ouverture
  f_sortie := UTL_FILE.fopen (i_repertoire, g_fichier, 'W', 32767);

  P_INS_journal(3,'fopen:'||i_repertoire);

  IF i_repertoire IS NULL THEN
     RAISE e_par_repertoire_vide;
  END IF;

  IF g_fichier IS NULL OR g_fichier = ''
  THEN
     RAISE e_par_fichier_vide;
  END IF;

  -- Ecriture de l entete de début du fichier
  ecrireEnteteDebut;

  -- Ecriture de chaque ligne de PEC
  ecrireLigne(i_fichier);

  -- Ecriture de l entete de fin du fichier
  ecrireEnteteFin;

  -- Fermeture du fichier
  UTL_FILE.fclose (f_sortie);

  -- Historisation du flux dans la table STOCK_FACT_SP
  insertSTOCK_FACT_SP(i_fichier);

  P_INS_journal(1,'Fin normale de génération du fichier <'||g_fichier||'> dans le répertoire <'||i_repertoire||'> le '||TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')||'.');

  RETURN TRUE;

EXCEPTION
  WHEN e_par_repertoire_vide THEN
    P_INS_journal(1,'Nom du répertoire de sortie manquant');
    o_erreur:='Nom du répertoire de sortie manquant';
    RETURN FALSE;
  WHEN e_par_fichier_vide THEN
    P_INS_journal(1,'Nom du fichier de sortie manquant');
      o_erreur:='Nom du fichier de sortie manquant';
    RETURN FALSE;
  WHEN UTL_FILE.internal_error THEN
    P_INS_journal(1,'UTL_FILE.INTERNAL_ERROR');
    UTL_FILE.fclose (f_sortie);
    o_erreur:='UTL_FILE.INTERNAL_ERROR';
    RETURN FALSE;
  WHEN UTL_FILE.invalid_filehandle THEN
    P_INS_journal(1,'UTL_FILE.INVALID_FILEHANDLE');
    UTL_FILE.fclose (f_sortie);
    o_erreur:='UTL_FILE.INVALID_FILEHANDLE';
    RETURN FALSE;
  WHEN UTL_FILE.invalid_mode THEN
    P_INS_journal(1,'UTL_FILE.INVALID_MODE');
    UTL_FILE.fclose (f_sortie);
    o_erreur:='UTL_FILE.INVALID_MODE';
    RETURN FALSE;
  WHEN UTL_FILE.invalid_operation THEN
    P_INS_journal(1,'UTL_FILE.INVALID_OPERATION');
    UTL_FILE.fclose (f_sortie);
    o_erreur:='UTL_FILE.INVALID_OPERATION';
    RETURN FALSE;
  WHEN UTL_FILE.invalid_path THEN
    P_INS_journal(1,'UTL_FILE.INVALID_PATH');
    UTL_FILE.fclose (f_sortie);
    o_erreur:='UTL_FILE.INVALID_PATH';
    RETURN FALSE;
  WHEN UTL_FILE.read_error THEN
    P_INS_journal(1,'UTL_FILE.READ_ERROR');
    UTL_FILE.fclose (f_sortie);
    o_erreur:='UTL_FILE.READ_ERROR';
    RETURN FALSE;
  WHEN UTL_FILE.write_error THEN
    P_INS_journal(1,'UTL_FILE.WRITE_ERROR');
    UTL_FILE.fclose (f_sortie);
    o_erreur:='UTL_FILE.WRITE_ERROR';
    RETURN FALSE;
  WHEN VALUE_ERROR THEN
    P_INS_journal(1,'VALUE_ERROR' || SUBSTR (SQLERRM (SQLCODE), 1, 128));
    UTL_FILE.fclose (f_sortie);
    o_erreur:='VALUE_ERROR' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
    RETURN FALSE;
  WHEN OTHERS THEN
    P_INS_journal(1,'TR14T - ' || SUBSTR (SQLERRM (SQLCODE), 1, 128));
    IF UTL_FILE.is_open (f_sortie) THEN
      UTL_FILE.fclose (f_sortie);
    END IF;
    o_erreur:='TR14T - ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
    RETURN FALSE;
END f_creationFichier;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  ecrireLigne                                               */
/* Type         :  Privee                                                    */
/* Description  :  Ecriture de chaque PEC de la journée : Facturée ou Annulée*/
/* Entree       :  type de fichier, 1 facturé, 2 périmé                      */
/*---------------------------------------------------------------------------*/
PROCEDURE ecrireLigne(i_fichier IN NUMBER)
IS

  nb_dossier  NUMBER:=0;
  i_cpt       NUMBER:=0;

BEGIN

  g_totMtDepense:=0;
  g_totMtRO:=0;
  g_totMtRC:=0;
  g_nbTot:=0;
  g_nbTot01:=0;
  i_cpt:=0;

  P_INS_journal(3,'ecrireLigne:'||g_id_stock_fact_sp);

  IF i_fichier = 1 THEN
    -- Parcours du nombre de PEC facturée
    FOR record_PECF IN C_PEC_Facture LOOP
      P_INS_journal(3,'record_PECF.NUM_DOSSIER:'||record_PECF.NUM_DOSSIER);
      i_cpt:=i_cpt+1;
      IF i_cpt>1500 THEN -- Mantis 4015
        EXIT;
      END IF;
      ------------------------------------------
      -- longueur totale 360 de la ligne d entete
      -------------------------------------------
      -- Type de ligne X(2)
      buffer := '01';
      -- Type PEC X(5)
      buffer := buffer || 'OPTIQ';
      -- Numéro PS X(9)
      buffer := buffer || RPAD(NVL(TO_CHAR(record_PECF.NUMBENE),' '),9, ' ');
      -- Identifiant PEC AMC X(16)
      buffer := buffer || RPAD(NVL(TO_CHAR(record_PECF.NUM_DOSSIER),' '),16, ' ');
      -- Date création accord PEC X(8)
      buffer := buffer || RPAD(NVL(TO_CHAR (record_PECF.CREATION, 'YYYYMMDD'),' '),8, ' ');
      -- Date début validité PEC X(8)
      buffer := buffer || RPAD(NVL(TO_CHAR (record_PECF.CREATION, 'YYYYMMDD'),' '),8, ' ');
      -- Date fin validité PEC X(8)
      buffer := buffer || RPAD(NVL(TO_CHAR (record_PECF.PEREMPTION, 'YYYYMMDD'),' '),8, ' ');
      -- Identifiant PEC Opérateur X(16)
      buffer := buffer || RPAD(NVL(TO_CHAR (record_PECF.REF_DOSSIER),' '),16, ' ');
      -- Date traitement PEC X(8)
      buffer := buffer || RPAD(NVL(TO_CHAR (record_PECF.CREATION, 'YYYYMMDD'),' '),8, ' ');
      -- Numéro organisme AMC X(10)
      buffer := buffer || RPAD(NVL('0000401554',' '),10, ' ');
      -- Nom du beneficaire X(32)
      buffer := buffer || RPAD(NVL(record_PECF.NOM,' '),32, ' ');
      -- Prenom du beneficaire X(32)
      buffer := buffer || RPAD(NVL(record_PECF.PRENOM,' '),32, ' ');
      -- Numero INSEE de l assuré X(15)
      buffer := buffer || RPAD(NVL(record_PECF.NUMSECU,' '),15, ' ');
      -- Numero INSEE du beneficiaire X(15)
      buffer := buffer || RPAD(NVL(record_PECF.NUMSECU,' '),15, ' ');
      -- Date de naissance du bénéficiaire X(8)
      buffer := buffer || RPAD(NVL(TO_CHAR(record_PECF.DATNAIS, 'YYYYMMDD'),' '),8, ' ');
      -- Rang de naissance du bénéficiaire X(1)
      buffer := buffer || RPAD(NVL(TO_CHAR(record_PECF.RANG),' '),1,' ');
      -- Numéro d adhérent du bénéficiaire X(15)
      buffer := buffer || RPAD(NVL(TO_CHAR(record_PECF.NUMINDIV),' '),15, ' ');
      -- Code garantie X(7)
      buffer := buffer || RPAD('OPTI',7,' ');
      --Montant dépense X(12)
      buffer := buffer || LPAD(NVL(TO_CHAR(record_PECF.MTFRAIS),'0'),12,'0');
      --Montant RO X(12)
      buffer := buffer || LPAD(NVL(TO_CHAR(record_PECF.MTREMB),'0'),12,'0');
      --Montant RAC X(12)
      buffer := buffer || LPAD(NVL(TO_CHAR(record_PECF.MTRAC),'0'),12,'0');
      --Montant RC X(12)
      buffer := buffer || LPAD(NVL(TO_CHAR(record_PECF.MTREEL),'0'),12,'0');
      -- Devise X(3)
      buffer := buffer || 'EUR';
      -- Code etat externe X(5)
      buffer := buffer || RPAD('F',5,' ');
      -- Date effet code etat externe X(8)
      buffer := buffer || RPAD(NVL(TO_CHAR (record_PECF.CREATION, 'YYYYMMDD'),' '),8, ' ');
      -- Reference facture X(9)
      buffer := buffer || LPAD(NVL(TO_CHAR (record_PECF.NUM_FACT_PEC),'0'),9,'0');
      -- Date de la facture liquidee X(8)
      buffer := buffer || RPAD(NVL(TO_CHAR (record_PECF.DATE_FACT_PEC, 'YYYYMMDD'),' '),8, ' ');
      -- Nombres lignes détails X(3)
      buffer := buffer || LPAD('00',3,'0');
      -- Version echange X(2)
      buffer := buffer || LPAD('03',2,'0');
      -- Origine du fichier X(5)
      buffer := buffer || 'OIAMC';
      -- Zone d echange X(23)
      buffer := buffer || RPAD(' ',23,' ');
      -- Specialite PS X(2)
      buffer := buffer || '64';
      -- Code état facture X(2)
      buffer := buffer || 'OK';
      -- Timestamp code état facture X(26)
      buffer := buffer || RPAD(' ',26,' ');-- RPAD(NVL(to_char(sysdate,'DD/MM/YYYY hh24:mi:ss'),' '), 26, ' ');
      -- Zone libre RUF X(43)
      buffer := buffer || RPAD(' ',41,' ');
      -- Ecriture de la l entete
      UTL_FILE.put_line (f_sortie, buffer);
      bufferFichier:=bufferFichier||buffer;
      buffer := '';
      -- Cumul des montants pour l entete de fin
      g_totMtDepense:=g_totMtDepense + record_PECF.MTFRAIS;
      g_totMtRO:=g_totMtRO + record_PECF.MTREMB;
      g_totMtRC:=g_totMtRC + record_PECF.MTREEL;
      g_nbTot:=g_nbTot+1;
      g_nbTot01:=g_nbTot01+1;
      -- Mise à jour des facturés envoyé
      PK_CTRL_TP.P_INS_HISTO_DOSSIER(record_PECF.NUM_DOSSIER,0,7);

      -- mise à jour de la reférence externe de l'individu
      PK_CTRL_TP.P_MAJ_REF_EXTERNE(
            P_numindiv    => record_PECF.NUMINDIV,
            P_domaine     => '',
            P_num_dossier => record_PECF.NUM_DOSSIER,
            P_tiers       => 'GRP',
            P_mnemo       => 'DOMSP');
    END LOOP;

  ELSIF i_fichier = 2 THEN
    -- Parcours du nombre de PEC périmée
    FOR record_PECP IN C_PEC_Perime LOOP
      i_cpt:=i_cpt+1;
      IF i_cpt>1500 THEN -- Mantis 4015
        EXIT;
      END IF;
      -- On controle si le dossier n est pas en cours de paiement
      nb_dossier:=0;
      SELECT COUNT(h.NUM_DOSSIER)
        INTO nb_dossier
        FROM HISTO_DOSSIER h
       WHERE h.etat=0  -- ouvert
         AND h.motif=6
         AND h.NUM_DOSSIER=record_PECP.NUM_DOSSIER;
      -- si le dossier est en cours de paiement on ne le traite pas
      IF nb_dossier = 0 THEN
        P_INS_journal(3,'record_PECP.NUM_DOSSIER:'||record_PECP.NUM_DOSSIER);
        ------------------------------------------
        -- longueur totale 360 de la ligne d entete
        -------------------------------------------
        -- Type de ligne X(2)
        buffer := '01';
        -- Type PEC X(5)
        buffer := buffer || 'OPTIQ';
        -- Numéro PS X(9) ==> TODO : a déterminer, non obligatoire
        buffer := buffer || RPAD(NVL(TO_CHAR(record_PECP.NUMBENE),' '),9, ' ');
        -- Identifiant PEC AMC X(16)
        buffer := buffer || RPAD(NVL(TO_CHAR(record_PECP.NUM_DOSSIER),' '),16, ' ');
        -- Date création accord PEC X(8)
        buffer := buffer || RPAD(NVL(TO_CHAR (record_PECP.CREATION, 'YYYYMMDD'),' '),8, ' ');
        -- Date début validité PEC X(8)
        buffer := buffer || RPAD(NVL(TO_CHAR (record_PECP.CREATION, 'YYYYMMDD'),' '),8, ' ');
        -- Date fin validité PEC X(8)
        buffer := buffer || RPAD(NVL(TO_CHAR (record_PECP.PEREMPTION, 'YYYYMMDD'),' '),8, ' ');
        -- Identifiant PEC Opérateur X(16)
        buffer := buffer || RPAD(NVL(TO_CHAR (record_PECP.REF_DOSSIER),' '),16, ' ');
        -- Date traitement PEC X(8)
        buffer := buffer || RPAD(NVL(TO_CHAR (record_PECP.CREATION, 'YYYYMMDD'),' '),8, ' ');
        -- Numéro organisme AMC X(10) ==> TODO : a déterminer,  obligatoire
        buffer := buffer || RPAD(NVL('0000401554',' '),10, ' ');
        -- Nom du beneficaire X(32)
        buffer := buffer || RPAD(NVL(record_PECP.NOM,' '),32, ' ');
        -- Prenom du beneficaire X(32)
        buffer := buffer || RPAD(NVL(record_PECP.PRENOM,' '),32, ' ');
        -- Numero INSEE de l assuré X(15)
        buffer := buffer || RPAD(NVL(record_PECP.NUMSECU,' '),15, ' ');
        -- Numero INSEE du beneficiaire X(15)
        buffer := buffer || RPAD(NVL(record_PECP.NUMSECU,' '),15, ' ');
        -- Date de naissance du bénéficiaire X(8)
        buffer := buffer || RPAD(NVL(TO_CHAR(record_PECP.DATNAIS, 'YYYYMMDD'),' '),8, ' ');
        -- Rang de naissance du bénéficiaire X(1)
        buffer := buffer || RPAD(NVL(TO_CHAR(record_PECP.RANG),' '),1,' ');
        -- Numéro d adhérent du bénéficiaire X(15)
        buffer := buffer || RPAD(NVL(TO_CHAR(record_PECP.NUMINDIV),' '),15, ' ');
        -- Code garantie X(7)
        buffer := buffer || RPAD('OPTI',7,' ');
        --Montant dépense X(12)
        buffer := buffer || LPAD(NVL(TO_CHAR(record_PECP.MTFRAIS),'0'),12,'0');
        --Montant RO X(12)
        buffer := buffer || LPAD(NVL(TO_CHAR(record_PECP.MTREMB),'0'),12,'0');
        --Montant RAC X(12)
        buffer := buffer || LPAD(NVL(TO_CHAR(record_PECP.MTRAC),'0'),12,'0');
        --Montant RC X(12)
        buffer := buffer || LPAD(NVL(TO_CHAR(record_PECP.MTREEL),'0'),12,'0');
        -- Devise X(3)
        buffer := buffer || 'EUR';
        -- Code etat externe X(5)
        buffer := buffer || RPAD('A',5,' ');
        -- Date effet code etat externe X(8)
        buffer := buffer || RPAD(NVL(TO_CHAR (record_PECP.CREATION, 'YYYYMMDD'),' '),8, ' ');
        -- Reference facture X(9)
        buffer := buffer || LPAD(NVL(TO_CHAR (record_PECP.NUM_FACT_PEC),'0'),9,'0');
        -- Date de la facture liquidee X(8)
        buffer := buffer || RPAD(NVL(TO_CHAR (record_PECP.DATE_FACT_PEC, 'YYYYMMDD'),' '),8, ' ');
        -- Nombres lignes détails X(3)
        buffer := buffer || LPAD('00',3,'0');
        -- Version echange X(2)
        buffer := buffer || LPAD('03',2,'0');
        -- Origine du fichier X(5)
        buffer := buffer || 'OIAMC';
        -- Zone d echange X(23)
        buffer := buffer || RPAD(' ',23,' ');
        -- Specialite PS X(2)
        buffer := buffer || '64';
        -- Code état facture X(2)
        buffer := buffer || 'AN';
        -- Timestamp code état facture X(26)
        buffer := buffer || RPAD(' ',26,' ');-- RPAD(NVL(to_char(sysdate,'DD/MM/YYYY hh24:mi:ss'),' '), 26, ' ');
        -- Zone libre RUF X(43)
        buffer := buffer || RPAD(' ',41,' ');
        -- Ecriture de la l entete
        UTL_FILE.put_line (f_sortie, buffer);
        bufferFichier:=bufferFichier||buffer;
        buffer := '';
        -- Cumul des montants pour l entete de fin
        g_totMtDepense:=g_totMtDepense + record_PECP.MTFRAIS;
        g_totMtRO:=g_totMtRO + record_PECP.MTREMB;
        g_totMtRC:=g_totMtRC + record_PECP.MTREEL;
        g_nbTot:=g_nbTot+1;
        g_nbTot01:=g_nbTot01+1;

       -- Mise à jour du dossier santé une fois la PEC périmé envoyé
       PK_CTRL_TP.P_ANNUL_DOSSIER(record_PECP.NUM_DOSSIER,3);
       -- mise à jour de la reférence externe de l'individu
       PK_CTRL_TP.P_MAJ_REF_EXTERNE(
              P_numindiv    => record_PECP.NUMINDIV,
              P_domaine     => '',
              P_num_dossier => record_PECP.NUM_DOSSIER,
              P_tiers       => 'GRP',
              P_mnemo       => 'DOMSP');
      END IF;
    END LOOP;
  END IF;
P_INS_journal(3,'ecrireLigne fin:'||g_id_stock_fact_sp);

END ecrireLigne;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  ecrireEnteteDebut                                         */
/* Type         :  Privee                                                    */
/* Description  :  Ecriture de l entete de debut du flux :Facturée ou Annulée*/
/* Entree       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE ecrireEnteteDebut
IS
BEGIN
  ------------------------------------------
  -- longueur totale 45 de la ligne d entete
  -------------------------------------------
  -- Type de ligne X(2)
  buffer := '00';
  -- Numéro de séquence X(10)
  buffer := buffer || LPAD(g_id_stock_fact_sp,10,'0');
  -- Version du fichier X(5)
  buffer := buffer || 'SPS02';
  -- Identifiant de l emetteur X(14)
  buffer := buffer || '04015554'||' TPOSP'; -- 00004015554
  -- Date création fichier X(8)
  buffer := buffer || TO_CHAR (SYSDATE, 'YYYYMMDD');
  -- Type de fichier X(5)
  buffer := buffer || 'PPECS';
  -- Zone libre RUF X(45)
  buffer := buffer || RPAD(' ',356,' ');

  -- Ecriture de la l entete
  UTL_FILE.put_line (f_sortie, buffer);
  bufferFichier:=buffer;
  buffer := '';

END ecrireEnteteDebut;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  ecrireEnteteFin                                           */
/* Type         :  Privee                                                    */
/* Description  :  Ecriture de l entete fin  du flux : Facturée ou Annulée   */
/* Entree       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE ecrireEnteteFin
IS
BEGIN

  ------------------------------------------
  -- longueur totale 100 de la ligne d entete
  -------------------------------------------
  -- Type de ligne X(2)
  buffer := '99';
  -- Numéro de séquence X(10)
  buffer := buffer || LPAD(g_id_stock_fact_sp,10,'0');
  -- Version du fichier X(5)
  buffer := buffer || 'SPS02';
  -- Identifiant de l emetteur X(14)==> TODO : a déterminer
  buffer := buffer || '04015554'||' TPOSP';
  -- Date création fichier X(8)
  buffer := buffer || TO_CHAR (SYSDATE, 'YYYYMMDD');
  -- Nombre d'enregistrements X(8)
  buffer := buffer || LPAD(NVL(TO_CHAR(g_nbTot),'0'),8,'0');
  -- Nombre d'enregistrements "01" X(8)
  buffer := buffer || LPAD(NVL(TO_CHAR(g_nbTot01),'0'),8,'0');
  -- Nombre d'enregistrements "02" X(8)
  buffer := buffer || LPAD(NVL(TO_CHAR(g_nbTot02),'0'),8,'0');
  -- Montant dépense total X(12)
  buffer := buffer || LPAD(NVL(TO_CHAR(g_totMtDepense),'0'),12,'0');
  -- Montant RO total X(12)
  buffer := buffer || LPAD(NVL(TO_CHAR(g_totMtRO),'0'),12,'0');
  -- Montant RC total  X(12)
  buffer := buffer || LPAD(NVL(TO_CHAR(g_totMtRC),'0'),12,'0');
  -- Zone libre RUF X(100)
  buffer := buffer || RPAD(' ',301,' ');
  -- Ecriture de la l entete
  UTL_FILE.put_line (f_sortie, buffer);
  bufferFichier:=bufferFichier||buffer;
  buffer := '';

END ecrireEnteteFin;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  insertSTOCK_FACT_SP                                       */
/* Type         :  Privee                                                    */
/* Description  :  Historisation du flux dans la table STOCK_FACT_SP         */
/* Entree       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE insertSTOCK_FACT_SP(i_fichier IN NUMBER)
IS
 i_type  VARCHAR2(1):=NULL;
BEGIN

  IF i_fichier = 1 THEN
    i_type:='F';
  ELSIF i_fichier = 2 THEN
    i_type:='A';
  END IF;

  INSERT INTO STOCK_FACT_SP(NUMREMISE, FLUX, NUMSEQ, TYPE, CREATION, USERCREA)
   VALUES(g_remise, bufferFichier, g_id_stock_fact_sp, i_type, SYSDATE, f_numutil);
 P_INS_journal(1,'fin de traitement ok');
 COMMIT;

EXCEPTION
  WHEN OTHERS THEN
     P_INS_journal(1,'fin de traitement ko');
    ROLLBACK;
END insertSTOCK_FACT_SP;

-- Insertion dans journal_adm
PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF G_niv_msg IS NULL THEN
     BEGIN
       SELECT decode(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
       INTO G_niv_msg
       FROM PARAM_BATCH
       WHERE NUMBATCH = G_nom_traitement;
     EXCEPTION
       WHEN OTHERS THEN
            G_niv_msg := 1;
    END;
  END IF;

  IF G_niv_msg >= P_niv THEN
     G_IDLIGNE := G_IDLIGNE +1;
     PK_trace.P_INS_journal_adm (
        I_nom_traitement => G_nom_traitement,
        I_session  => SID,
        I_niv_msg  => P_niv,
        I_msg_adm  => substr(P_msg||' '||P_msg2,1,132),
        I_idligne  => G_idligne);
  END IF;
  COMMIT;
END P_INS_journal;

END PK_SPSANTE_FACTURATION;
/
