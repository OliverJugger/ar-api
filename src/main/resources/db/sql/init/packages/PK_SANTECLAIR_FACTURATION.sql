CREATE OR REPLACE PACKAGE ARTHUS."PK_SANTECLAIR_FACTURATION"
AS
/*============================================================================*/
/* PACKAGE      : PK_SANTECLAIR_FACTURATION.sql                               */
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

PROCEDURE P_GestionPecPerime (i_numporte     IN    NUMBER
                            , i_traitement   IN    VARCHAR2
                            , i_session      IN    NUMBER DEFAULT 1
                            , i_niv_msg      IN    NUMBER DEFAULT 1
                            , o_found        OUT   NUMBER
                            , o_erreur       OUT   VARCHAR2);

PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);
-- ------------------------------------------------- Fin des procedures publiques --
END PK_SANTECLAIR_FACTURATION;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_SANTECLAIR_FACTURATION
As
/*============================================================================*/
/* PACKAGE      : PK_SANTECLAIR_FACTURATION.sql                               */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 07/10/2011                                                  */
/* Description  : Package permettant la gestion des PEC périmés de SantéClair */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/



   -- -- PROCEDURES PRIVEES ----------------------------------------------------
--

  -- Déclaration des variables globales
  G_nom_traitement  journal_adm.nom_traitement%TYPE default 'TR16T';
  g_niv_msg         journal_adm.niv_msg%TYPE := 3;
  g_idligne         journal_adm.idligne%TYPE := 0;
  g_msg_adm         journal_adm.msg_adm%TYPE;
  g_session         NUMBER;
  g_numporte        NUMBER:=NULL;




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
    AND h.MOTIF IN (4,5,6,7)
    AND F_ETAT_DOSSIER_SANTE(ds.NUM_DOSSIER,SYSDATE,1)=1  -- Fermé
    AND F_ETAT_DOSSIER_SANTE(ds.NUM_DOSSIER,SYSDATE,2) IN (4,5,6,7)  -- Périmé
    AND F_ETAT_DOSSIER_SANTE(ds.NUM_DOSSIER,SYSDATE,2)<>3 --déjà traité
    AND ds.NUMPORTE=g_numporte
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
/* Nom          :  GestionPecPerime                                            */
/* Type         :  Public                                                    */
/* Description  :  Permet l envoi des 2 flux quotidiens au CETIP : Facturée  */
/*                 ou Annulée respectant une norme du CDC. Fichiers à plat   */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 i_fichierF, fichier Facturé                               */
/*                 i_fichierA, fichier Annulé                                */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
PROCEDURE P_GestionPecPerime (i_numporte     IN    NUMBER
                            , i_traitement   IN    VARCHAR2
                            , i_session      IN    NUMBER DEFAULT 1
                            , i_niv_msg      IN    NUMBER DEFAULT 1
                            , o_found        OUT   NUMBER
                            , o_erreur       OUT   VARCHAR2)
IS

  b_ok        BOOLEAN:=FALSE;
  nb_dossier  NUMBER:=0;
  i_cpt       NUMBER:=0;

BEGIN


  -- Recupération des parametres du traitement
  G_nom_traitement:=i_traitement;
  G_niv_msg:=i_niv_msg;
  G_idligne:=0;
  G_session:=i_session;
  g_numporte:=i_numporte;

  P_INS_journal(1,'Traitement des PEC périmées SantéClair le '||TO_CHAR(SYSDATE)||', pour la porte : '||to_char(i_numporte));

  -- Gestion des PEC périmées Santé Clair
  FOR record_PECP IN C_PEC_Perime LOOP
    i_cpt:=i_cpt+1;
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

     -- Mise à jour du dossier santé une fois la PEC périmé envoyé
     PK_CTRL_TP.P_ANNUL_DOSSIER(record_PECP.NUM_DOSSIER,8);
     -- mise à jour de la reférence externe de l'individu
     PK_CTRL_TP.P_MAJ_REF_EXTERNE(
            P_numindiv    => record_PECP.NUMINDIV,
            P_domaine     => '',
            P_num_dossier => record_PECP.NUM_DOSSIER,
            P_tiers       => 'SC',
            P_mnemo       => 'DOMGEREP');
    END IF;
  END LOOP;

  o_found:=0;
  P_INS_journal(1,'Fin du traitement des PEC périmées SantéClair');

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,SUBSTR(SQLERRM,1,132));
    o_erreur:=SUBSTR(SQLERRM,1,132);
    o_found:=1;
    ROLLBACK;
END P_GestionPecPerime;

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------

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
        I_session  => G_session,
        I_niv_msg  => P_niv,
        I_msg_adm  => substr(P_msg||' '||P_msg2,1,132),
        I_idligne  => G_idligne);
  END IF;
  COMMIT;
END P_INS_journal;

END PK_SANTECLAIR_FACTURATION;
/
