CREATE OR REPLACE PACKAGE ARTHUS.PK_SP_FACT
AS
/*============================================================================*/
/* Package      : PK_SP_FACT.sql                                              */
/* Domaine      : TP Hospitalier                                              */
/* Version      : V1.0                                                        */
/* Auteur       : FNI, SDA, JBO                                               */
/* Création     : 27/08/2014                                                  */
/* Description  :                                                             */
/*              :                                                             */
/*              :                                                             */
/*============================================================================
 correction   :  4773
 Auteur       :  SDA forçage code regime a '01' par defautl
 Date         :  23/01/2015
 Commentaire  :
 correction   :  4777
 Auteur       :  SDA mise en place du champ T2cp-17 à la place du forcage par
                 default à '01'
 Date         :  28/01/2015
 Commentaire  :
==============================================================================*/
/* Correction   : PHA 15/05/2017  0005310: Erreur import fichier OISDREFP     */
/*============================================================================*/


PROCEDURE P_IMPORT_DRE (
  i_traitement   IN    VARCHAR2,
  i_numporte     IN    remise_externe.numporte%TYPE,
  i_session      IN    NUMBER DEFAULT 1,
  i_niv_msg      IN    NUMBER DEFAULT 3,
  i_repertoire   IN    VARCHAR2 DEFAULT NULL,
  i_fichier      IN    VARCHAR2 DEFAULT NULL,
  o_found        OUT   NUMBER,
  o_erreur       OUT   VARCHAR2
);

PROCEDURE P_EXPORT_ACC_REJ (
  i_traitement   IN    VARCHAR2,
  i_remise_exp   IN    remise_externe.numremise%TYPE,
  i_nature_exp   IN    VARCHAR2,
  i_session      IN    NUMBER DEFAULT 1,
  i_niv_msg      IN    NUMBER DEFAULT 1,
  i_repertoire   IN    VARCHAR2 DEFAULT NULL,
  i_fichier      IN    VARCHAR2 DEFAULT NULL,
  o_found        OUT   NUMBER,
  o_erreur       OUT   VARCHAR2
);

PROCEDURE P_EXPORT_ACC (
  i_traitement   IN    VARCHAR2,
  i_remise_exp   IN    remise_externe.numremise%TYPE,
  i_nature_exp   IN    VARCHAR2,
  i_session      IN    NUMBER DEFAULT 1,
  i_niv_msg      IN    NUMBER DEFAULT 1,
  i_repertoire   IN    VARCHAR2 DEFAULT NULL,
  i_fichier      IN    VARCHAR2 DEFAULT NULL,
  o_found        OUT   NUMBER,
  o_erreur       OUT   VARCHAR2
);


PROCEDURE P_EXPORT_REJ (
  i_traitement   IN    VARCHAR2,
  i_remise_exp   IN    remise_externe.numremise%TYPE,
  i_nature_exp   IN    VARCHAR2,
  i_session      IN    NUMBER DEFAULT 1,
  i_niv_msg      IN    NUMBER DEFAULT 1,
  i_repertoire   IN    VARCHAR2 DEFAULT NULL,
  i_fichier      IN    VARCHAR2 DEFAULT NULL,
  o_found        OUT   NUMBER,
  o_erreur       OUT   VARCHAR2
);

PROCEDURE formatage_900 (
  i_buffer_in    IN VARCHAR2,
  io_bufferfic   IN OUT VARCHAR2,
  io_sortie      IN OUT   UTL_FILE.file_type,
  io_count_line  IN OUT  PLS_INTEGER
);

PROCEDURE P_ANNUL_CONST_BORD (
  i_numremise    IN   remise_externe.numremise%TYPE,
  i_nature_exp   IN   remise_externe.nature%TYPE,
  i_session      IN   NUMBER DEFAULT 1,
  i_niv_msg      IN   NUMBER DEFAULT 1
);

PROCEDURE P_DEBLOCAGE_ASSURE(i_numremise    IN   remise_externe.numremise%TYPE, i_porte IN   remise_externe.numremise%TYPE);

FUNCTION F_CTRL_NUMBER(
    i_chaine IN VARCHAR2,
    i_debut  IN NUMBER,
    i_longueur IN NUMBER,
    i_ligne IN NUMBER,
    i_nom   IN VARCHAR2,
    o_erreur IN OUT BOOLEAN,
    i_format IN VARCHAR2 default 'N',
    i_entier IN NUMBER default null,
    i_decimale IN NUMBER default null

) RETURN NUMBER;

FUNCTION F_CTRL_NUMBER_VARCHAR(
    i_chaine IN VARCHAR2,
    i_debut  IN NUMBER,
    i_longueur IN NUMBER,
    i_ligne IN NUMBER,
    i_nom   IN VARCHAR2,
    o_erreur IN OUT BOOLEAN
) RETURN VARCHAR2;

FUNCTION F_CTRL_ALPHANUMBER(
    i_chaine IN VARCHAR2,
    i_debut  IN NUMBER,
    i_longueur IN NUMBER,
    i_ligne IN NUMBER,
    i_nom   IN VARCHAR2,
    o_erreur IN OUT BOOLEAN
) RETURN VARCHAR2;

FUNCTION F_FORMAT_NUMBER(
         i_chaine IN VARCHAR2,
         i_entier IN NUMBER,
         i_decimale IN NUMBER
) RETURN NUMBER;

FUNCTION F_FORMAT_DATENAIS(
         i_chaine IN VARCHAR2
) RETURN VARCHAR2;

FUNCTION F_CTRL_FORMAT_DATE(
         i_chaine IN VARCHAR2,
         i_debut  IN NUMBER,
         i_longueur IN NUMBER,
         i_ligne IN NUMBER,
         i_nom   IN VARCHAR2,
         o_erreur IN OUT BOOLEAN
) RETURN DATE;

FUNCTION F_NOM_FICHIER(
         i_fichier in VARCHAR2
        ,i_numporte in NUMBER default NULL
) RETURN VARCHAR2;

FUNCTION F_CHERCHE_ORDRE (
   i_ordre_in       IN   stock_entite.ordre%TYPE,
   i_niv_in         IN   VARCHAR2,
   i_numremise_in   IN   stock_entite.numremise%TYPE
) RETURN stock_entite.ordre%TYPE;

PROCEDURE P_INS_journal(
  i_niv IN NUMBER,
  i_msg IN VARCHAR2,
  i_msg2 IN VARCHAR2 := null
);

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_SP_FACT AS

--VARIABLES GLOBALES
g_nom_traitement  journal_adm.nom_traitement%TYPE default 'PK_SP_FACT';
g_niv_msg         journal_adm.niv_msg%TYPE := NULL;
g_idligne         journal_adm.idligne%TYPE := 0;
g_msg_adm         journal_adm.msg_adm%TYPE;
g_session         NUMBER;
exc_ins_suivi_fact_tpe EXCEPTION;
exc_ins_sinistre_porte EXCEPTION;



FUNCTION F_INS_PRESTATION(p_sinistre_porte IN OUT sinistre_porte%ROWTYPE,
                           p_suivi_fact_tpe IN OUT suivi_fact_tpe%ROWTYPE,
                           i_cpt_numsin NUMBER,
                           i_cpt_lig NUMBER)
                           RETURN VARCHAR2;
PROCEDURE P_INIT_PRESTATION(p_sinistre_porte IN OUT sinistre_porte%ROWTYPE, p_porte_remise IN porte_remise%ROWTYPE);
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_EXPORT_ACC_REJ                                          */
/* Type         :  Public                                                    */
/* Description  :  procedure d'import                                        */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_IMPORT_DRE (
  i_traitement   IN    VARCHAR2,
  i_numporte     IN    remise_externe.numporte%TYPE,
  i_session      IN    NUMBER DEFAULT 1,
  i_niv_msg      IN    NUMBER DEFAULT 3,
  i_repertoire   IN    VARCHAR2 DEFAULT NULL,
  i_fichier      IN    VARCHAR2 DEFAULT NULL,
  o_found        OUT   NUMBER,
  o_erreur       OUT   VARCHAR2
) IS
  --variable utilisation fichier
  fic_H_FIC   UTL_FILE.FILE_TYPE:=NULL;      -- Handle du fichier des encaissements
  fic_cpt_ligne NUMBER := 0;
  fic_getline BOOLEAN;
  fic_newfacture NUMBER := 0;
  fic_verif_import NUMBER := 0;

  --variable de chaine
  s_donnees VARCHAR2(5000):='';
  o_chaine  VARCHAR2(200);
  o_erreur_type BOOLEAN := false;


  --entite
  v_facture_annul		 NUMBER(1);
  v_test_entite          VARCHAR2(30);
  v_type_enreg           VARCHAR2(1);
  v_type_complement      VARCHAR(1);
  v_temp_matorgindiv     VARCHAR2(13);
  v_temp_matorgindiv_cle NUMBER(2);
  v_temp_nom             VARCHAR2(25);
  v_temp_prenom          VARCHAR2(25);
  v_temp_nompre          VARCHAR2(50);
  v_code_acte_1          VARCHAR2(1);
  v_code_acte_4          VARCHAR2(4);

  --cpt entite
  cpt_lig_entite0 NUMBER := 0;
  cpt_lig_entite1 NUMBER := 0;
  cpt_lig_entite2 NUMBER := 0;
  cpt_lig_entite3 NUMBER := 0;
  cpt_lig_entite4 NUMBER := 0;
  cpt_lig_entite5 NUMBER := 0;
  cpt_lig_entite6 NUMBER := 0;
  cpt_numsin NUMBER := 0;
  cpt_tot_prest NUMBER :=0;
  cpt_tot_fact NUMBER :=0;
  mtrc_tot_fact NUMBER :=0;
  loc_cod_spec_ps    NUMBER :=0;

  loc_nature             PORTE_REMISE.NATURE%TYPE;

  v_ins_porte_remise VARCHAR2(132) := null;
  v_ins_stock_entite VARCHAR2(132) := null;
  v_ins_stock_entite_P VARCHAR2(132) := null;
  v_ins_suivi_fact_tpe VARCHAR2(132) := null;
  v_ins_sinistre_porte VARCHAR2(132) := null;

  v_upd_porte_remise BOOLEAN := FALSE;

  TYPE type_tab_numremise IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  tab_numremise  type_tab_numremise;

  --variable rowtype
  v_porte_remise     porte_remise%ROWTYPE;
  v_sinistre_porte   sinistre_porte%ROWTYPE;
  v_suivi_fact_tpe   suivi_fact_tpe%ROWTYPE;
  v_stock_entite     stock_entite%ROWTYPE;
  v_stock_entite_p   stock_entite_p%ROWTYPE;

  v_sinistre_porte_init  sinistre_porte%ROWTYPE;
  v_suivi_fact_tpe_init  suivi_fact_tpe%ROWTYPE;

  --exception
  exc_fic_import_ctrl  EXCEPTION;
  exc_type_chaine      EXCEPTION;
  exc_ins_porte_remise EXCEPTION;
  exc_facture_annul    EXCEPTION;
  exc_fic_incorrect    EXCEPTION;
  --exc_ins_suivi_fact_tpe EXCEPTION;
  --exc_ins_sinistre_porte EXCEPTION;



BEGIN

  g_nom_traitement := i_traitement;
  g_session   := i_session;
  --initailisation des variables
  o_found := 0;
  o_erreur := null;
  o_erreur_type := false;
  cpt_tot_prest  :=0;
  cpt_tot_fact  :=0;
  mtrc_tot_fact  :=0;
  v_facture_annul:=0;



  --traitement de la nature pour porte remise selon le traitement (memo FIC_IMPORT)
  --traitement du code evefact selon  le traitement


  P_INS_journal(3,'DEBUT de l''import');
  P_INS_journal(3,'DEBUT de l''import ' || i_traitement);
  P_INS_journal(3,'DEBUT de l''import rep: ' || i_repertoire || '--> fic: ' || i_fichier);

  --verification de la configuration du nom de fichier
  IF (i_traitement ='NO33T' AND i_numporte=2 AND upper(i_fichier) not like  'SP_FP_%_%-%-%')  --porte sp sante et import de fichier facture (DRE2009)
    OR  (i_traitement ='NO34T' AND i_numporte=2 AND upper(i_fichier) not like  'SP_PP_%_%-%-%')  -- porte sp sante et import fichier paiements (DRE2009)
    OR (i_traitement ='NO33T' AND i_numporte=18 AND upper(i_fichier) not like  'IS_FP_%_%-%-%')  --porte ISANTE et import de fichier facture (DRE2009)
    OR (i_traitement ='NO34T' AND i_numporte=18 AND upper(i_fichier) not like  'IS_PP_%_%-%-%') then ----porte ISANTE et import de fichier paiements (DRE2009)
    RAISE exc_fic_incorrect;
   end if ;

  --test ouverture d'un fichier en PL/SQL
  -- le fichier ordrefp
  -- le fichier ordrepp
  --fic_H_FIC := PK_FICHIER.FOPEN(i_repertoire,i_fichier,'r');
  fic_H_FIC := UTL_FILE.fopen(i_repertoire,i_fichier,'r',32767);
  P_INS_journal(3,'DEBUT de fic_H_FIC ');
  WHILE PK_FICHIER.fGetLine(fic_H_FIC,s_donnees) LOOP
    BEGIN

      fic_cpt_ligne := fic_cpt_ligne + 1;
      v_type_enreg := SUBSTR(s_donnees,1,1);
	  IF v_facture_annul=1 AND v_type_enreg <>'9' THEN
		RAISE exc_facture_annul;
	  END IF;
      v_type_complement := null;
      v_stock_entite :=NULL;


      CASE v_type_enreg
       --entite 0
        WHEN '0' THEN
		  IF TRIM(substr(s_donnees,92,37)) <>'FACTURE INITIALE' THEN
		    v_facture_annul:=1;
			RAISE exc_facture_annul;
		  END IF;

          cpt_lig_entite0 := cpt_lig_entite0 + 1;
          cpt_lig_entite1:=0;
          v_porte_remise:=NULL;
          v_suivi_fact_tpe_init:=NULL;
          v_sinistre_porte_init:=NULL;


          IF i_traitement = 'NO33T' THEN
            v_porte_remise.nature := 2;
          ELSIF i_traitement = 'NO34T' THEN
            v_porte_remise.nature := 3;
          ELSE
            v_porte_remise.nature := 0;
          END IF;

          --T0-10
          v_porte_remise.dateporte := F_CTRL_FORMAT_DATE(s_donnees,56,6,fic_cpt_ligne,'T0-10',o_erreur_type);
          P_INS_journal(3,'v_porte_remise.dateporte: ' || v_porte_remise.dateporte);
          --T0-9
          v_porte_remise.ref_ext := F_CTRL_ALPHANUMBER(s_donnees,50,6,fic_cpt_ligne,'T0-9',o_erreur_type);
          P_INS_journal(3,'v_porte_remise.ref_ext: ' || v_porte_remise.ref_ext);
          IF v_porte_remise.ref_ext is null  THEN
            RAISE exc_fic_import_ctrl;
          END IF;


          --verification si import du fichier déjà effectué
          fic_verif_import := PK_TPE.F_VERIF_PORTE_REMISE(   i_numporte
                                                             ,v_porte_remise.nature
                                                             ,v_porte_remise.dateporte
                                                             ,v_porte_remise.ref_ext
                                                            );
          IF fic_verif_import <> 1 THEN
              RAISE exc_fic_import_ctrl;
          END IF;


          --insertion dans porte_remise
          --plusieur porte remise par fichier possible
          IF NOT(o_erreur_type) THEN
            --remise a zero pour le compteur de numsin
            cpt_numsin := 0;
            v_upd_porte_remise:=FALSE;
            SELECT MAX(numremise) + 1 INTO v_porte_remise.numremise FROM porte_remise;
            --initialisation
            --porte tph
            v_porte_remise.numporte := i_numporte;
            v_porte_remise.dateremise := sysdate;
            v_ins_porte_remise := PK_TPE.F_INS_PRTREM(v_porte_remise);
            --ajout dans un tableau du numero de remise pour pouvoir delete en cas d'erreur
            tab_numremise(cpt_lig_entite0) := v_porte_remise.numremise;
            IF v_ins_porte_remise <> 'OK' THEN
               RAISE exc_ins_porte_remise;
            END IF;
          END IF;

        --entite 1
        WHEN '1' THEN

          cpt_lig_entite1 := cpt_lig_entite1 + 1;

          v_sinistre_porte:=NULL;
          v_type_complement := SUBSTR(s_donnees,39,1);

          IF cpt_lig_entite1 = 1 THEN
            v_type_complement :=NULL;
            --T1-5
            v_sinistre_porte_init.numlot := F_CTRL_ALPHANUMBER(s_donnees,20,3,fic_cpt_ligne,'T1-5',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte.numlot:' || v_sinistre_porte_init.numlot);
            --T1-10 + T1-15
            v_porte_remise.norme := F_CTRL_ALPHANUMBER(s_donnees,70,2,fic_cpt_ligne,'T1-10',o_erreur_type) || F_CTRL_ALPHANUMBER(s_donnees,82,6,fic_cpt_ligne,'T1-15',o_erreur_type);
            P_INS_journal(3,'v_porte_remise.norme: ' || v_porte_remise.norme);
            fic_newfacture := 1;
            --T1-11
            v_sinistre_porte_init.datlot := F_CTRL_FORMAT_DATE(s_donnees,72,6,fic_cpt_ligne,'T1-11',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte_init.datlot:' || v_sinistre_porte_init.datlot);
            --T1-13
            v_sinistre_porte_init.categorie := F_CTRL_ALPHANUMBER(s_donnees,79,2,fic_cpt_ligne,'T1-13',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte_init.categorie:' || v_sinistre_porte_init.categorie);

            --T1-16
            /*v_sinistre_porte_init.codmon := F_CTRL_ALPHANUMBER(s_donnees,39,1,fic_cpt_ligne,'T1-16');
            IF v_sinistre_porte.codmon = '!' THEN
            o_erreur_type := TRUE;
            END IF;
            P_INS_journal(3,'v_suivi_fact_tpe.codtypfact:' || v_sinistre_porte.codmon);*/
            v_sinistre_porte_init.codmon := pk_devise.devise_ref;
            v_sinistre_porte_init.codmon_d := pk_devise.devise_ref;
            v_suivi_fact_tpe:=v_suivi_fact_tpe_init;
          END IF;

          CASE v_type_complement
          WHEN 'V' THEN
            NULL;
          WHEN 'W' THEN
            NULL;
          ELSE NULL;
          END CASE;

        --entite 2
        WHEN '2' THEN

          cpt_lig_entite1 := 0;
          cpt_lig_entite4 := 0;
          cpt_lig_entite2 := cpt_lig_entite2 + 1;


          --traitement du complement de type
          IF cpt_lig_entite2 > 1 THEN
             v_type_complement := SUBSTR(s_donnees,36,1);
             IF v_type_complement NOT IN ('B','C','M','P','X') THEN
                v_type_complement := SUBSTR(s_donnees,39,1);
             END IF;
          ELSE

            --T2CP-2
            v_suivi_fact_tpe.codadeli := F_CTRL_NUMBER(s_donnees,2,9,fic_cpt_ligne,'T2CP-2',o_erreur_type);
            P_INS_journal(3,'v_suivi_fact_tpe.codadeli:' || v_suivi_fact_tpe.codadeli);
            --T2CP-4 + T2CP-5
            --T2CP-4
            v_temp_matorgindiv := F_CTRL_ALPHANUMBER(s_donnees,12,13,fic_cpt_ligne,'T2CP-4',o_erreur_type);
            v_sinistre_porte_init.matorgindiv := v_temp_matorgindiv ;
            P_INS_journal(3,'v_sinistre_porte_init.matorgindiv:' || v_sinistre_porte_init.matorgindiv);
            --T2CP-5
            v_temp_matorgindiv_cle := F_CTRL_NUMBER(s_donnees,25,2,fic_cpt_ligne,'T2CP-5',o_erreur_type);
            v_suivi_fact_tpe.codbenefinsee := v_temp_matorgindiv;
            v_suivi_fact_tpe.codbenefcle := v_temp_matorgindiv_cle;
            P_INS_journal(3,'v_suivi_fact_tpe.codbenefcle:' || v_suivi_fact_tpe.codbenefcle);
            --T2CP-7
            --v_suivi_fact_tpe.numfact := F_CTRL_NUMBER_VARCHAR(s_donnees,30,9,fic_cpt_ligne,'T2CP-7',o_erreur_type);
            IF v_sinistre_porte_init.categorie ='CP' THEN
                v_suivi_fact_tpe.numfact := F_CTRL_NUMBER_VARCHAR(s_donnees,30,9,fic_cpt_ligne,'T2CP-7',o_erreur_type);
            ELSIF v_sinistre_porte_init.categorie ='ES' THEN
                v_suivi_fact_tpe.numfact := F_CTRL_NUMBER_VARCHAR(s_donnees,30,9,fic_cpt_ligne,'T2ES-7',o_erreur_type);
            ELSE
                v_suivi_fact_tpe.numfact := F_CTRL_NUMBER_VARCHAR(s_donnees,27,9,fic_cpt_ligne,'T2-6',o_erreur_type);
            END IF ;

            v_sinistre_porte_init.numfact := v_suivi_fact_tpe.numfact;
            P_INS_journal(3,'v_suivi_fact_tpe.numfact:' || v_suivi_fact_tpe.numfact);
            --T2-11
            IF v_sinistre_porte_init.categorie NOT IN('CP','ES') THEN
              v_suivi_fact_tpe.datfact := F_CTRL_FORMAT_DATE(s_donnees,40,6,fic_cpt_ligne,'T2-11',o_erreur_type);
            END IF;
            P_INS_journal(3,'v_suivi_fact_tpe.datfact:' || v_suivi_fact_tpe.datfact);
            --T2CP-8
            IF v_sinistre_porte_init.categorie ='CP' THEN
              v_suivi_fact_tpe.codtypfact := F_CTRL_ALPHANUMBER(s_donnees,39,1,fic_cpt_ligne,'T2CP-8',o_erreur_type);
            ELSIF v_sinistre_porte_init.categorie ='ES' THEN
              v_suivi_fact_tpe.codtypfact := F_CTRL_ALPHANUMBER(s_donnees,39,1,fic_cpt_ligne,'T2ES-8',o_erreur_type);
            ELSE
              v_suivi_fact_tpe.codtypfact := F_CTRL_ALPHANUMBER(s_donnees,47,1,fic_cpt_ligne,'T2-13',o_erreur_type);
            END IF;
            P_INS_journal(3,'v_suivi_fact_tpe.codtypfact:' || v_suivi_fact_tpe.codtypfact);
             --T2CP-10
            --v_sinistre_porte_init.regime := F_CTRL_NUMBER_VARCHAR(s_donnees,49,2,fic_cpt_ligne,'T2CP-10',o_erreur_type);
            --T2CP-17
            --SDA mantis 4773 remplacement de T2CP-10 par T2CP-17 ?
            --v_sinistre_porte_init.regime := F_CTRL_NUMBER_VARCHAR(s_donnees,74,3,fic_cpt_ligne,'T2CP-17',o_erreur_type);
            --P_INS_journal(3,'v_sinistre_porte_init.regime:' || v_sinistre_porte_init.regime);
            --SDA mantis 4777
            v_sinistre_porte_init.regime := SUBSTR(F_CTRL_NUMBER_VARCHAR(s_donnees,74,3,fic_cpt_ligne,'T2CP-17',o_erreur_type),2,2);
            IF v_sinistre_porte_init.regime = '00' or v_sinistre_porte_init.regime is null THEN
               v_sinistre_porte_init.regime := '01';
            END IF;
            P_INS_journal(3,'v_sinistre_porte_init.regime:' || v_sinistre_porte_init.regime);
            --T2CP-11
            v_sinistre_porte_init.caisse := F_CTRL_NUMBER_VARCHAR(s_donnees,51,3,fic_cpt_ligne,'T2CP-11',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte_init.caisse:' || v_sinistre_porte_init.caisse);
            --T2CP-12
            v_sinistre_porte_init.centre := F_CTRL_NUMBER_VARCHAR(s_donnees,54,4,fic_cpt_ligne,'T2CP-12',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte_init.centre:' || v_sinistre_porte_init.centre);
            --T2CP-23
            v_suivi_fact_tpe.datnaibenef := F_CTRL_ALPHANUMBER(s_donnees,96,6,fic_cpt_ligne,'T2CP-23',o_erreur_type);
            v_suivi_fact_tpe.datnaibenef := F_FORMAT_DATENAIS(v_suivi_fact_tpe.datnaibenef);
            v_sinistre_porte_init.datnais_indiv := v_suivi_fact_tpe.datnaibenef;
            P_INS_journal(3,'v_suivi_fact_tpe.datnaibenef:' || v_suivi_fact_tpe.datnaibenef);
            --T2CP-24
            v_suivi_fact_tpe.rangbenef := F_CTRL_NUMBER(s_donnees,102,1,fic_cpt_ligne,'T2CP-24',o_erreur_type);
            v_sinistre_porte_init.rang_indiv := v_suivi_fact_tpe.rangbenef;
            P_INS_journal(3,'v_suivi_fact_tpe.rangbenef:' || v_suivi_fact_tpe.rangbenef);
            --T2CP-29
            --update de la porte_remise avec le destinataire  (1 seul fois)
            IF NOT(v_upd_porte_remise) THEN
              v_porte_remise.destinataire := F_CTRL_ALPHANUMBER(s_donnees,119,128,fic_cpt_ligne,'T2CP-29',o_erreur_type);
              P_INS_journal(3,'v_porte_remise.destinataire: ' || v_porte_remise.destinataire);

              PK_TPE.P_UDT_PORTE_REMISE(v_porte_remise);
              v_upd_porte_remise := TRUE;

              P_INS_journal(3,'UPDATE de la PORTE_REMISE: ' || v_porte_remise.numremise);
            END IF;

          END IF;

          --traitement sous-entite 2 selon le complement type
          --si v_type_complement null cas de la 1er ligne CP
          CASE v_type_complement
          WHEN 'B' THEN

            --T2B-11
            --v_temp_nom := F_CTRL_ALPHANUMBER(s_donnees,43,25,fic_cpt_ligne,'T2B-11',o_erreur_type);
            --probleme cote sur nom
            --SDA mantis 4773
            v_temp_nom := RTRIM(SUBSTR(s_donnees,43,25));
            P_INS_journal(3,'v_temp_nom:' || v_temp_nom);
            --T2B-12
            --v_temp_prenom := F_CTRL_ALPHANUMBER(s_donnees,43,25,fic_cpt_ligne,'T2B-11',o_erreur_type);
            v_temp_prenom := RTRIM(SUBSTR(s_donnees,68,15));
            P_INS_journal(3,'v_temp_prenom:' || v_temp_prenom);
            v_temp_nompre := v_temp_nom || v_temp_prenom;
            v_sinistre_porte_init.nomprebene := SUBSTR(v_temp_nom||v_temp_nompre,1,29);
            P_INS_journal(3,'v_sinistre_porte_init.nomprebene:' || v_sinistre_porte_init.nomprebene);

          WHEN 'C' THEN
               null;

          WHEN 'M' THEN
               null;

          WHEN 'P' THEN

            --T2P-10
            --Récupération du code spécialité du PS. Ce paramètre permet de savoir si on est sur une vraie PEC ou une fausse --> voir alimentation de sinistre_porte.refcie
            P_INS_journal(3,'avant recup loc_cod_spec_ps: ' || loc_cod_spec_ps||' s_donnee:'||SUBSTR(s_donnees,1,60));
            loc_cod_spec_ps :=F_STR_TO_NUMBER(SUBSTR(s_donnees,49,2));
            P_INS_journal(3,'recup loc_cod_spec_ps :' || loc_cod_spec_ps);
            --T2P-11

            IF loc_cod_spec_ps = 64 THEN --PS opticien
              BEGIN
              --quand le numPEC est alimenté en alphanumerique(exple 123x056) --> c'est le PS qui l'a alimenté manuellement, donc il faut considérer qu'il n'y a pas de numéro de PEC (en BDD ne pas alimenter sinistre_porte.refcie)
                IF v_sinistre_porte_init.categorie ='ES' THEN
                  v_sinistre_porte_init.refcie := TRIM(F_CTRL_ALPHANUMBER(UPPER(s_donnees),83,16,fic_cpt_ligne,'T2P-12',o_erreur_type));
                ELSE
                  v_sinistre_porte_init.refcie := TRIM(F_CTRL_ALPHANUMBER(UPPER(s_donnees),83,16,fic_cpt_ligne,'T2P-11',o_erreur_type));
                END IF;
                --Controle sur le n°pec du flux si contient de l'alphanum/que du blanc
                v_sinistre_porte_init.refcie := F_STR_TO_NUMBER(v_sinistre_porte_init.refcie);

                IF v_sinistre_porte_init.refcie IS NULL THEN --n°pec du flux est alphanumerique/ou composé que de blancs
                  --Pour un OPTICIEN, si n°PEC du flux est composé que de blancs/alphanum alors on enregistre un numéro de PEC à 0 ou 1 car refcie sera = num PEC optique arthus
                  v_sinistre_porte_init.refcie :=1;
                END IF;
                IF TO_NUMBER(v_sinistre_porte_init.refcie) = 0 THEN --Ne pas considerer les n°PEC 00000000000
                  v_sinistre_porte_init.refcie :=null;
                  P_INS_journal(3,'ne pas considerer n°pec 0000 refcie=' || v_sinistre_porte_init.refcie);
                END IF;
              END;
            ELSE --autres PS
              --ne pas considerer le num pec pour les autres PS
              v_sinistre_porte_init.refcie :=null;
              P_INS_journal(3,'loc_cod_spec_ps <>64 refcie=' || v_sinistre_porte_init.refcie);
            END IF;
            P_INS_journal(3,'v_sinistre_porte_init.refcie:' || v_sinistre_porte_init.refcie);
            --T2P-16
            IF v_sinistre_porte_init.categorie ='CP' THEN
              v_suivi_fact_tpe.datfact := F_CTRL_FORMAT_DATE(s_donnees,103,6,fic_cpt_ligne,'T2P-16',o_erreur_type);
            ELSIF v_sinistre_porte_init.categorie ='ES' THEN
              v_suivi_fact_tpe.datfact := F_CTRL_FORMAT_DATE(s_donnees,103,6,fic_cpt_ligne,'T2P-17',o_erreur_type);
            END IF;
            P_INS_journal(3,'v_suivi_fact_tpe.datfact:' || v_suivi_fact_tpe.datfact);
            --T2P-19
            -- Le numero d'adhérent est majoritairement déterminé par le TRG via les infos ss
            IF v_sinistre_porte_init.categorie ='CP' THEN
              v_sinistre_porte_init.numindiv := F_CTRL_NUMBER(s_donnees,114,8,fic_cpt_ligne,'T2P-19',o_erreur_type);
            END IF;
            P_INS_journal(3,'v_sinistre_porte_init.numindiv:' || v_sinistre_porte_init.numindiv);

          WHEN 'S' THEN
            --T2S-10
            IF v_sinistre_porte_init.categorie in ('CP','ES') THEN
               v_suivi_fact_tpe.complt_titre := F_CTRL_NUMBER(s_donnees,42,6,fic_cpt_ligne,'T2S-10',o_erreur_type);
            END IF;
            v_sinistre_porte_init.complt_titre := v_suivi_fact_tpe.complt_titre;
            P_INS_journal(3,'v_suivi_fact_tpe.complt_titre:' || v_suivi_fact_tpe.complt_titre);
            --T2S-12
            --T2S-13

            v_sinistre_porte_init.noe_pdsqle := F_CTRL_ALPHANUMBER(s_donnees,121,1,fic_cpt_ligne,'T2S-19',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte_init.noe_pdsqle:' || v_sinistre_porte_init.noe_pdsqle);

          WHEN 'T' THEN
            null;

          WHEN 'X' THEN

            --T2X-8
            v_suivi_fact_tpe.datreceptor := F_CTRL_FORMAT_DATE(s_donnees,37,8,fic_cpt_ligne,'T2X-8',o_erreur_type);
            P_INS_journal(3,'v_suivi_fact_tpe.datreceptor:' || v_suivi_fact_tpe.datreceptor);
            --T2X-9
            v_suivi_fact_tpe.datlimiamc := F_CTRL_FORMAT_DATE(s_donnees,45,8,fic_cpt_ligne,'T2X-9',o_erreur_type);
            P_INS_journal(3,'v_suivi_fact_tpe.datlimiamc:' || v_suivi_fact_tpe.datlimiamc);
            --T2X-10
            v_suivi_fact_tpe.numcompos := F_CTRL_ALPHANUMBER(s_donnees,53,7,fic_cpt_ligne,'T2X-10',o_erreur_type);
            v_sinistre_porte_init.refdec := v_suivi_fact_tpe.numcompos;
            P_INS_journal(3,'v_suivi_fact_tpe.numcompos:' || v_suivi_fact_tpe.numcompos);
            --T2X-11
            --apparement vide dans les fichiers
            /*v_suivi_fact_tpe.codamcdet := F_CTRL_ALPHANUMBER(s_donnees,60,10,fic_cpt_ligne,'T2X-11');
            IF v_suivi_fact_tpe.codamcdet = '!' THEN
               o_erreur_type := TRUE;
            END IF;
            P_INS_journal(3,'v_suivi_fact_tpe.codamcdet:' || v_suivi_fact_tpe.codamcdet);*/
            v_suivi_fact_tpe.codamcdet := ' ';


            --avis de paiement uniquement
            IF i_traitement = 'NO34T' THEN
              --T2X-12
              v_suivi_fact_tpe.idcptebq := F_CTRL_ALPHANUMBER(s_donnees,70,1,fic_cpt_ligne,'T2X-12',o_erreur_type);
              P_INS_journal(3,'v_suivi_fact_tpe.idcptebq:' || v_suivi_fact_tpe.idcptebq);
              --T2X-13
              v_suivi_fact_tpe.reffin := F_CTRL_ALPHANUMBER(s_donnees,71,10,fic_cpt_ligne,'T2X-13',o_erreur_type);
              P_INS_journal(3,'v_suivi_fact_tpe.reffin:' || v_suivi_fact_tpe.reffin);
              --T2X-14
              v_suivi_fact_tpe.typavireg := F_CTRL_ALPHANUMBER(s_donnees,81,1,fic_cpt_ligne,'T2X-14',o_erreur_type);
              P_INS_journal(3,'v_suivi_fact_tpe.typavireg:' || v_suivi_fact_tpe.typavireg);

            END IF;


            v_suivi_fact_tpe.numremise_import := v_porte_remise.numremise;
            v_suivi_fact_tpe.codevefac :=10;
            P_INS_journal(3,'v_suivi_fact_tpe.codtypfact /typavireg: ' || v_suivi_fact_tpe.codtypfact ||v_suivi_fact_tpe.typavireg);
            IF v_suivi_fact_tpe.codtypfact IN ('D','C')   THEN  v_suivi_fact_tpe.codevefac :=10;
            ELSIF v_suivi_fact_tpe.codtypfact IN ('L','R')   THEN
              IF v_suivi_fact_tpe.typavireg ='A' THEN v_suivi_fact_tpe.codevefac :=60;
              ELSIF v_suivi_fact_tpe.typavireg ='N' THEN v_suivi_fact_tpe.codevefac :=50;
              END IF;
            END IF;
			     P_INS_journal(3,'v_suivi_fact_tpe.codevefac: ' || v_suivi_fact_tpe.codevefac);
            v_suivi_fact_tpe.idfactpe := F_IDFACTPE(
                                      v_suivi_fact_tpe.codadeli
                                      ,v_suivi_fact_tpe.numfact
                                      ,v_suivi_fact_tpe.datfact
                                      ,v_suivi_fact_tpe.codbenefinsee
                                      ,v_suivi_fact_tpe.codbenefcle
                                      ,v_suivi_fact_tpe.datnaibenef
                                      ,v_suivi_fact_tpe.rangbenef
                                      ,v_suivi_fact_tpe.complt_titre
                                      );
            P_INS_journal(3,'v_suivi_fact_tpe.idfactpe : ' || v_suivi_fact_tpe.idfactpe);

            --complément X toujours présent et arrive en dernier
            v_ins_suivi_fact_tpe:=PK_TPE.F_INS_SUIVIFACT(v_suivi_fact_tpe);
            P_INS_journal(3,'Insertion Facture TPE facture : ' || v_suivi_fact_tpe.numfact );
            IF v_ins_suivi_fact_tpe <> 'OK' THEN
              RAISE exc_ins_suivi_fact_tpe;
            END IF;

          ELSE NULL;
          END CASE;

        WHEN '3' THEN
          cpt_lig_entite3 := cpt_lig_entite3 + 1;
          cpt_lig_entite2 := 0;


          v_type_complement := SUBSTR(s_donnees,39,1);

          IF v_type_complement NOT IN ('S','E','F','H') THEN
            cpt_numsin := cpt_numsin + 1;
            v_sinistre_porte := v_sinistre_porte_init; --entité 2 et 1
            P_INIT_PRESTATION(v_sinistre_porte,v_porte_remise);
          END IF;
          IF v_type_complement NOT IN ('S','E','F','H') THEN
            v_type_complement:=NULL;
            v_sinistre_porte.numexec := F_CTRL_NUMBER(s_donnees,2,9,fic_cpt_ligne,'T3CP-2',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte.numexec:' || v_sinistre_porte.numexec);
            --est-ce que l'exécutant est le prescripteur ???

            v_sinistre_porte.modtrait := F_CTRL_NUMBER(s_donnees,39,2,fic_cpt_ligne,'T3CP-8',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte.modtrait:' || v_sinistre_porte.modtrait);

            v_sinistre_porte.dmt := F_CTRL_NUMBER(s_donnees,41,3,fic_cpt_ligne,'T3CP-9',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte.dmt:' || v_sinistre_porte.dmt);


            --N/A v_sinistre_porte.noe_zone :=
            --N/A v_sinistre_porte.noe_spec :=

            v_sinistre_porte.datsin := F_CTRL_FORMAT_DATE(s_donnees,44,6,fic_cpt_ligne,'T3CP-10',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte.datsin:' || v_sinistre_porte.datsin);
            IF v_sinistre_porte_init.categorie ='CP' THEN
              v_sinistre_porte.datfin := F_CTRL_FORMAT_DATE(s_donnees,50,6,fic_cpt_ligne,'T3CP-11',o_erreur_type);
            ELSIF v_sinistre_porte_init.categorie ='ES' THEN
              v_sinistre_porte.datfin := F_CTRL_FORMAT_DATE(s_donnees,50,6,fic_cpt_ligne,'T3ES-11',o_erreur_type);
            END IF;
            P_INS_journal(3,'v_sinistre_porte.datfin:' || v_sinistre_porte.datfin);
            v_code_acte_4 := TRIM(F_CTRL_ALPHANUMBER(s_donnees,56,4,fic_cpt_ligne,'T3CP-12',o_erreur_type));
            v_sinistre_porte.codfrais_porte := v_code_acte_4;
            P_INS_journal(3,'v_sinistre_porte.codfrais_porte:' || v_sinistre_porte.codfrais_porte);

            IF v_sinistre_porte_init.categorie ='CP' THEN
              v_sinistre_porte.quantite := F_CTRL_NUMBER(s_donnees,61,3,fic_cpt_ligne,'T3CP-13',o_erreur_type);
            ELSIF v_sinistre_porte_init.categorie ='ES' THEN
              v_sinistre_porte.quantite := F_CTRL_NUMBER(s_donnees,61,3,fic_cpt_ligne,'T3ES-13',o_erreur_type);
            END IF;
            P_INS_journal(3,'v_sinistre_porte.quantite:' || v_sinistre_porte.quantite);

            v_sinistre_porte.coeff := F_CTRL_NUMBER(s_donnees,65,5,fic_cpt_ligne,'T3CP-15',o_erreur_type,'O',3,2);
            P_INS_journal(3,'v_sinistre_porte.coeff:' || v_sinistre_porte.coeff);

            --N/A v_sinistre_porte.denombr :=

            v_sinistre_porte.mtunit := F_CTRL_NUMBER(s_donnees,76,7,fic_cpt_ligne,'T3CP-18',o_erreur_type,'O',5,2);
            P_INS_journal(3,'v_sinistre_porte.mtunit:' || v_sinistre_porte.mtunit);

            v_sinistre_porte.baseremb := F_CTRL_NUMBER(s_donnees,83,8,fic_cpt_ligne,'T3CP-19',o_erreur_type,'O',6,2);
            P_INS_journal(3,'v_sinistre_porte.baseremb:' || v_sinistre_porte.baseremb);

            v_sinistre_porte.taux := F_CTRL_NUMBER(s_donnees,91,3,fic_cpt_ligne,'T3CP-20',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte.taux:' || v_sinistre_porte.taux);

            v_sinistre_porte.mtremb := F_CTRL_NUMBER(s_donnees,94,8,fic_cpt_ligne,'T3CP-21',o_erreur_type,'O',6,2);
            v_sinistre_porte.mtremb_d := v_sinistre_porte.mtremb;
            v_sinistre_porte.totalmtremb := v_sinistre_porte.mtremb;
            P_INS_journal(3,'v_sinistre_porte.mtremb:' || v_sinistre_porte.mtremb);

            v_sinistre_porte.mtfrais := F_CTRL_NUMBER(s_donnees,102,8,fic_cpt_ligne,'T3CP-22',o_erreur_type,'O',6,2);
            P_INS_journal(3,'v_sinistre_porte.mtfrais:' || v_sinistre_porte.mtfrais);
            v_sinistre_porte.mtfrais_d := v_sinistre_porte.mtfrais;
            --v_sinistre_porte.racmon := ?;--TODO

            -- M5310 le 15/05/2017
            v_sinistre_porte.noe_qualif := TRIM(F_CTRL_ALPHANUMBER(s_donnees,120,1,fic_cpt_ligne,'T3CP-27',o_erreur_type));
            P_INS_journal(3,'v_sinistre_porte.noe_qualif:' || v_sinistre_porte.noe_qualif);

            --v_sinistre_porte.mtprest := F_CTRL_NUMBER(s_donnees,123,6,fic_cpt_ligne,'T3CP-29',o_erreur_type,'O',4,2);
            IF v_sinistre_porte_init.categorie ='CP' THEN
              v_sinistre_porte.mtprest := F_CTRL_NUMBER(s_donnees,122,7,fic_cpt_ligne,'T3CP-29',o_erreur_type,'O',5,2);
            ELSIF v_sinistre_porte_init.categorie ='ES' THEN
              v_sinistre_porte.mtprest := F_CTRL_NUMBER(s_donnees,122,7,fic_cpt_ligne,'T3ES-29',o_erreur_type,'O',5,2);
            END IF;
            v_sinistre_porte.mtprest_d := v_sinistre_porte.mtprest;
            v_sinistre_porte.mtrembOC := v_sinistre_porte.mtprest;
            P_INS_journal(3,'v_sinistre_porte.mtprest:' || v_sinistre_porte.mtprest);

          END IF;

          CASE v_type_complement
          WHEN 'S' THEN
            v_sinistre_porte.numprescrip := F_CTRL_NUMBER(s_donnees,42,9,fic_cpt_ligne,'T3S-10',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte.numprescrip:' || v_sinistre_porte.numprescrip);

            v_sinistre_porte.speprescrip := F_CTRL_NUMBER(s_donnees,52,2,fic_cpt_ligne,'T3S-12',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte.denombr:' || v_sinistre_porte.speprescrip);

            v_sinistre_porte.datpresc := F_CTRL_FORMAT_DATE(s_donnees,54,6,fic_cpt_ligne,'T3S-13',o_erreur_type);
            P_INS_journal(3,'v_sinistre_porte.datpresc:' || v_sinistre_porte.datpresc);

            v_sinistre_porte.noe_premtt := TRIM(F_CTRL_ALPHANUMBER(s_donnees,115,1,fic_cpt_ligne,'T3S-21',o_erreur_type));
            P_INS_journal(3,'v_sinistre_porte.noe_premtt:' || v_sinistre_porte.noe_premtt);

            v_ins_sinistre_porte := PK_TPE.F_UPD_SNTRPRT(v_sinistre_porte);
            IF v_ins_sinistre_porte <> 'OK' THEN
              RAISE exc_ins_sinistre_porte;
            END IF;

          ELSE
            NULL;
          END CASE;

          IF NOT(o_erreur_type) AND v_type_complement IS NULL THEN
            v_ins_sinistre_porte:=F_INS_PRESTATION(v_sinistre_porte, v_suivi_fact_tpe,cpt_numsin,cpt_lig_entite3);
            IF v_ins_sinistre_porte <> 'OK' THEN
              RAISE exc_ins_sinistre_porte;
            END IF;
          END IF;


        WHEN '4' THEN

           cpt_lig_entite2 := 0;
           cpt_lig_entite4 := cpt_lig_entite4 + 1;

           P_INS_journal(3,'Entité 4 sinistre :' || cpt_numsin);
           --v_sinistre_porte := v_sinistre_porte_init; --entité 2 et 1
           --P_INIT_PRESTATION(v_sinistre_porte,v_porte_remise);

          -- IF cpt_lig_entite4 > 1 THEN --on peut avoir plusieurs lignes prestations à la suite
           v_type_complement := SUBSTR(s_donnees,36,1);
           IF v_type_complement NOT IN ('B','C','M','P','X','S','T','E','D','F','R','H','U') THEN
              v_type_complement := SUBSTR(s_donnees,39,1);
           END IF;
           --1ère ligne de type 4 => plusieurs occurences possibles dans une entité 2
           IF v_type_complement NOT IN ('B','C','M','P','X','S','T','E','D','F','R','H','U') THEN
             v_type_complement:=NULL;
             cpt_numsin := cpt_numsin + 1;
             v_sinistre_porte := v_sinistre_porte_init; --entité 2 et 1

             P_INIT_PRESTATION(v_sinistre_porte,v_porte_remise);
             --T4CP-8
             v_sinistre_porte.modtrait := F_CTRL_NUMBER(s_donnees,39,2,fic_cpt_ligne,'T4CP-8',o_erreur_type);
             P_INS_journal(3,'v_sinistre_porte.modtrait:' || v_sinistre_porte.modtrait);

             --T4CP-9
             v_sinistre_porte.dmt := F_CTRL_NUMBER(s_donnees,41,3,fic_cpt_ligne,'T4CP-9',o_erreur_type);
             P_INS_journal(3,'v_sinistre_porte.dmt:' || v_sinistre_porte.dmt);
             --T4CP-10
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.numprescrip := F_CTRL_NUMBER(s_donnees,44,9,fic_cpt_ligne,'T4CP-10',o_erreur_type);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.numprescrip := F_CTRL_NUMBER(s_donnees,44,9,fic_cpt_ligne,'T4ES-10',o_erreur_type);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.numprescrip:' || v_sinistre_porte.numprescrip);
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.noe_premtt := TRIM(F_CTRL_ALPHANUMBER(s_donnees,53,1,fic_cpt_ligne,'T4CP-11',o_erreur_type));
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.noe_premtt := TRIM(F_CTRL_ALPHANUMBER(s_donnees,53,1,fic_cpt_ligne,'T4ES-11',o_erreur_type));
             END IF;
             P_INS_journal(3,'v_sinistre_porte.noe_premtt:' || v_sinistre_porte.noe_premtt);
             --T4CP-13
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.speprescrip := F_CTRL_NUMBER(s_donnees,55,2,fic_cpt_ligne,'T4CP-13',o_erreur_type);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.speprescrip := F_CTRL_NUMBER(s_donnees,55,2,fic_cpt_ligne,'T4ES-13',o_erreur_type);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.speprescrip:' || v_sinistre_porte.speprescrip);
             --T4CP-14
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.numexec := F_CTRL_NUMBER(s_donnees,57,9,fic_cpt_ligne,'T4CP-14',o_erreur_type);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.numexec := F_CTRL_NUMBER(s_donnees,57,9,fic_cpt_ligne,'T4ES-14',o_erreur_type);
             ELSE v_sinistre_porte.numexec := F_CTRL_NUMBER(s_donnees,55,9,fic_cpt_ligne,'T4-16',o_erreur_type);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.numexec:' || v_sinistre_porte.numexec); --diff de T4E-11 ???
             --T4CP-15
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.noe_zone := F_CTRL_NUMBER(s_donnees,66,2,fic_cpt_ligne,'T4CP-15',o_erreur_type);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.noe_zone := F_CTRL_NUMBER(s_donnees,66,2,fic_cpt_ligne,'T4ES-15',o_erreur_type);
             ELSE v_sinistre_porte.noe_zone := F_CTRL_NUMBER(s_donnees,64,2,fic_cpt_ligne,'T4-17',o_erreur_type);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.noe_zone:' || v_sinistre_porte.noe_zone);
             --T4CP-16
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.noe_spec := F_CTRL_NUMBER(s_donnees,68,2,fic_cpt_ligne,'T4CP-16',o_erreur_type);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.noe_spec := F_CTRL_NUMBER(s_donnees,68,2,fic_cpt_ligne,'T4ES-16',o_erreur_type);
             ELSE v_sinistre_porte.noe_spec := F_CTRL_NUMBER(s_donnees,66,2,fic_cpt_ligne,'T4-18',o_erreur_type);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.noe_spec:' || v_sinistre_porte.noe_spec);
             --T4CP-17
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.datsin := F_CTRL_FORMAT_DATE(s_donnees,70,6,fic_cpt_ligne,'T4CP-17',o_erreur_type);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.datsin := F_CTRL_FORMAT_DATE(s_donnees,70,6,fic_cpt_ligne,'T4ES-17',o_erreur_type);
             ELSE v_sinistre_porte.datsin := F_CTRL_FORMAT_DATE(s_donnees,68,6,fic_cpt_ligne,'T4-19',o_erreur_type);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.datsin:' || v_sinistre_porte.datsin);
             --T4CP-18 (4+1)
             --v_code_acte_1 := F_CTRL_ALPHANUMBER(s_donnees,80,1,fic_cpt_ligne,'T4CP-18',o_erreur_type);
             --v_sinistre_porte.codfrais_porte := v_code_acte_4 || v_code_acte_1;
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_code_acte_4 := RTRIM(LTRIM(F_CTRL_ALPHANUMBER(s_donnees,76,4,fic_cpt_ligne,'T4CP-18',o_erreur_type)));
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_code_acte_4 := RTRIM(LTRIM(F_CTRL_ALPHANUMBER(s_donnees,76,4,fic_cpt_ligne,'T4ES-18',o_erreur_type)));
             ELSE
               v_code_acte_4 := RTRIM(LTRIM(F_CTRL_ALPHANUMBER(s_donnees,74,4,fic_cpt_ligne,'T4-20',o_erreur_type)));
             END IF;
             v_sinistre_porte.codfrais_porte := v_code_acte_4;
             P_INS_journal(3,'v_sinistre_porte.codfrais_porte:' || v_sinistre_porte.codfrais_porte);
             --T4CP-19
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.quantite := F_CTRL_NUMBER(s_donnees,81,2,fic_cpt_ligne,'T4CP-19',o_erreur_type);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.quantite := F_CTRL_NUMBER(s_donnees,81,2,fic_cpt_ligne,'T4ES-19',o_erreur_type);
             ELSE v_sinistre_porte.quantite := F_CTRL_NUMBER(s_donnees,79,2,fic_cpt_ligne,'T4-21',o_erreur_type);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.quantite:' || v_sinistre_porte.quantite);
             --T4CP-20
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.coeff := F_CTRL_NUMBER(s_donnees,83,6,fic_cpt_ligne,'T4CP-20',o_erreur_type,'O',4,2);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.coeff := F_CTRL_NUMBER(s_donnees,83,6,fic_cpt_ligne,'T4ES-20',o_erreur_type,'O',4,2);
             ELSE v_sinistre_porte.coeff := F_CTRL_NUMBER(s_donnees,81,6,fic_cpt_ligne,'T4-22',o_erreur_type,'O',4,2);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.coeff:' || v_sinistre_porte.coeff);
             --T4CP-21
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.denombr := F_CTRL_NUMBER(s_donnees,89,2,fic_cpt_ligne,'T4CP-21',o_erreur_type);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.denombr := F_CTRL_NUMBER(s_donnees,89,2,fic_cpt_ligne,'T4ES-21',o_erreur_type);
             ELSE v_sinistre_porte.denombr := F_CTRL_NUMBER(s_donnees,87,2,fic_cpt_ligne,'T4-23',o_erreur_type);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.denombr:' || v_sinistre_porte.denombr);
             --T4CP-22
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.mtunit := F_CTRL_NUMBER(s_donnees,91,7,fic_cpt_ligne,'T4CP-22',o_erreur_type,'O',5,2);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.mtunit := F_CTRL_NUMBER(s_donnees,91,7,fic_cpt_ligne,'T4ES-22',o_erreur_type,'O',5,2);
             ELSE v_sinistre_porte.mtunit := F_CTRL_NUMBER(s_donnees,89,7,fic_cpt_ligne,'T4-24',o_erreur_type,'O',5,2);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.mtunit:' || v_sinistre_porte.mtunit);
             --T4CP-23
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.baseremb := F_CTRL_NUMBER(s_donnees,98,7,fic_cpt_ligne,'T4CP-23',o_erreur_type,'O',5,2);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.baseremb := F_CTRL_NUMBER(s_donnees,98,7,fic_cpt_ligne,'T4ES-23',o_erreur_type,'O',5,2);
             ELSE v_sinistre_porte.baseremb := F_CTRL_NUMBER(s_donnees,96,7,fic_cpt_ligne,'T4-25',o_erreur_type,'O',5,2);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.baseremb:' || v_sinistre_porte.baseremb);
             --T4CP-24
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.taux := F_CTRL_NUMBER(s_donnees,105,3,fic_cpt_ligne,'T4CP-24',o_erreur_type);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.taux := F_CTRL_NUMBER(s_donnees,105,3,fic_cpt_ligne,'T4ES-24',o_erreur_type);
             ELSE v_sinistre_porte.taux := F_CTRL_NUMBER(s_donnees,103,3,fic_cpt_ligne,'T4-26',o_erreur_type);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.taux:' || v_sinistre_porte.taux);
             --T4CP-25
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.mtremb := F_CTRL_NUMBER(s_donnees,108,7,fic_cpt_ligne,'T4CP-25',o_erreur_type,'O',5,2);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.mtremb := F_CTRL_NUMBER(s_donnees,108,7,fic_cpt_ligne,'T4ES-25',o_erreur_type,'O',5,2);
             ELSE v_sinistre_porte.mtremb := F_CTRL_NUMBER(s_donnees,106,7,fic_cpt_ligne,'T4-27',o_erreur_type,'O',5,2);
             END IF;
             v_sinistre_porte.mtremb_d := v_sinistre_porte.mtremb;
             v_sinistre_porte.totalmtremb := v_sinistre_porte.mtremb;
             P_INS_journal(3,'v_sinistre_porte.mtremb:' || v_sinistre_porte.mtremb);
             --T4CP-26
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.mtfrais := F_CTRL_NUMBER(s_donnees,115,7,fic_cpt_ligne,'T4CP-26',o_erreur_type,'O',5,2);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.mtfrais := F_CTRL_NUMBER(s_donnees,115,7,fic_cpt_ligne,'T4ES-26',o_erreur_type,'O',5,2);
             ELSE v_sinistre_porte.mtfrais := F_CTRL_NUMBER(s_donnees,113,7,fic_cpt_ligne,'T4-28',o_erreur_type,'O',5,2);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.mtfrais:' || v_sinistre_porte.mtfrais);
             v_sinistre_porte.mtfrais_d := v_sinistre_porte.mtfrais;

             --T4CP-27
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.noe_qualif := F_CTRL_ALPHANUMBER(s_donnees,122,1,fic_cpt_ligne,'T4CP-27',o_erreur_type);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.noe_qualif := F_CTRL_ALPHANUMBER(s_donnees,122,1,fic_cpt_ligne,'T4ES-27',o_erreur_type);
             ELSE v_sinistre_porte.noe_qualif := F_CTRL_ALPHANUMBER(s_donnees,120,1,fic_cpt_ligne,'T4-29',o_erreur_type);
             END IF;
             P_INS_journal(3,'v_sinistre_porte.noe_qualif:' || v_sinistre_porte.noe_qualif);

             --T4CP-28
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_sinistre_porte.mtprest := F_CTRL_NUMBER(s_donnees,123,6,fic_cpt_ligne,'T4CP-28',o_erreur_type,'O',4,2);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_sinistre_porte.mtprest := F_CTRL_NUMBER(s_donnees,123,6,fic_cpt_ligne,'T4ES-28',o_erreur_type,'O',4,2);
             ELSE v_sinistre_porte.mtprest := F_CTRL_NUMBER(s_donnees,122,7,fic_cpt_ligne,'T4-31',o_erreur_type,'O',5,2);
             END IF;
             v_sinistre_porte.mtprest_d := v_sinistre_porte.mtprest;
             v_sinistre_porte.mtrembOC := v_sinistre_porte.mtprest;
             P_INS_journal(3,'v_sinistre_porte.mtprest:' || v_sinistre_porte.mtprest);

           END IF;


           CASE v_type_complement
              WHEN 'S' THEN
                IF v_sinistre_porte_init.categorie in ('CP','ES') THEN
                  v_sinistre_porte.noe_crdopt := F_CTRL_ALPHANUMBER(s_donnees,40,1,fic_cpt_ligne,'T4S-10',o_erreur_type);
                END IF;
                P_INS_journal(3,'v_sinistre_porte.noe_crdopt:' || v_sinistre_porte.noe_crdopt);
				v_sinistre_porte.racmon := 0;
                P_INS_journal(3,'v_sinistre_porte.racmon:' || v_sinistre_porte.racmon);
                v_sinistre_porte.noe_prvtop := F_CTRL_ALPHANUMBER(s_donnees,125,1,fic_cpt_ligne,'T4S-25',o_erreur_type);
                P_INS_journal(3,'v_sinistre_porte.noe_prvtop:' || v_sinistre_porte.noe_prvtop);
                v_sinistre_porte.noe_prvqlf := F_CTRL_ALPHANUMBER(s_donnees,126,2,fic_cpt_ligne,'T4S-26',o_erreur_type);
                P_INS_journal(3,'v_sinistre_porte.noe_prvqlf:' || v_sinistre_porte.noe_prvqlf);

                v_ins_sinistre_porte := PK_TPE.F_UPD_SNTRPRT(v_sinistre_porte);
                IF v_ins_sinistre_porte <> 'OK' THEN
                    RAISE exc_ins_sinistre_porte;
                END IF;
              WHEN 'E' THEN
                null;
              WHEN 'F' THEN
               IF v_sinistre_porte_init.categorie NOT IN ('CP','ES') THEN
                 v_sinistre_porte.codelpp := SUBSTR(F_CTRL_ALPHANUMBER(s_donnees,43,13,fic_cpt_ligne,'T4F-10',o_erreur_type),1,7); --position 43 sur 13 caract, les 7caractères utiles cadrés à gauche! completé par des blancs ou 0, on s'en fou!
               END IF;
               P_INS_journal(3,'v_sinistre_porte.codelpp:' || v_sinistre_porte.codelpp);
               v_ins_sinistre_porte := PK_TPE.F_UPD_SNTRPRT(v_sinistre_porte);
               IF v_ins_sinistre_porte <> 'OK' THEN
                  RAISE exc_ins_sinistre_porte;
               END IF;
              WHEN 'H' THEN
               IF v_sinistre_porte_init.categorie IN ('CP','ES') THEN
                 v_sinistre_porte.codeucd :=F_CTRL_ALPHANUMBER(s_donnees,49,7,fic_cpt_ligne,'T4H-11',o_erreur_type); --position 43 sur 13 caract, les 7caractères utiles cadrés à gauche, completés par des blancs --> suppression des blancs à droite
               END IF;
               P_INS_journal(3,'v_sinistre_porte.codeucd:' || v_sinistre_porte.codeucd);
               v_ins_sinistre_porte := PK_TPE.F_UPD_SNTRPRT(v_sinistre_porte);
               IF v_ins_sinistre_porte <> 'OK' THEN
                  RAISE exc_ins_sinistre_porte;
               END IF;
              WHEN 'M' THEN
               --T4M-10
               v_sinistre_porte.codeccam := SUBSTR(F_CTRL_ALPHANUMBER(s_donnees,43,13,fic_cpt_ligne,'T4M-10',o_erreur_type),1,7);--on prend les 7premiers caractères
               P_INS_journal(3,'v_sinistre_porte.codeccam:' || v_sinistre_porte.codeccam);
               --T4M-12
               v_sinistre_porte.codeactiv:=F_CTRL_ALPHANUMBER(s_donnees,57,1,fic_cpt_ligne,'T4M-12',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.codeactiv:' || v_sinistre_porte.codeactiv);
               --T4M-19
               v_sinistre_porte.coderemb:=F_CTRL_ALPHANUMBER(s_donnees,64,1,fic_cpt_ligne,'T4M-19',o_erreur_type);  --valeur possible O (oui) N(non pour les actes rembrsables selon conditions), blanc par defaut
               P_INS_journal(3,'v_sinistre_porte.coderemb:' || v_sinistre_porte.coderemb);
               --T4M-21
               v_sinistre_porte.locdent1 := F_CTRL_ALPHANUMBER(s_donnees,71,2,fic_cpt_ligne,'T4M-21',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent1:' || v_sinistre_porte.locdent1);
                --T4M-22
               v_sinistre_porte.locdent2 := F_CTRL_ALPHANUMBER(s_donnees,73,2,fic_cpt_ligne,'T4M-22',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent1:' || v_sinistre_porte.locdent2);
                --T4M-23
               v_sinistre_porte.locdent3 := F_CTRL_ALPHANUMBER(s_donnees,75,2,fic_cpt_ligne,'T4M-23',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent3:' || v_sinistre_porte.locdent3);
                --T4M-24
               v_sinistre_porte.locdent4 := F_CTRL_ALPHANUMBER(s_donnees,77,2,fic_cpt_ligne,'T4M-24',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent4:' || v_sinistre_porte.locdent4);
                --T4M-25
               v_sinistre_porte.locdent5 := F_CTRL_ALPHANUMBER(s_donnees,79,2,fic_cpt_ligne,'T4M-25',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent5:' || v_sinistre_porte.locdent5);
                --T4M-26
               v_sinistre_porte.locdent6 := F_CTRL_ALPHANUMBER(s_donnees,81,2,fic_cpt_ligne,'T4M-26',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent6:' || v_sinistre_porte.locdent6);
                --T4M-27
               v_sinistre_porte.locdent7 := F_CTRL_ALPHANUMBER(s_donnees,83,2,fic_cpt_ligne,'T4M-27',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent7:' || v_sinistre_porte.locdent7);
                --T4M-28
               v_sinistre_porte.locdent8 := F_CTRL_ALPHANUMBER(s_donnees,85,2,fic_cpt_ligne,'T4M-28',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent8:' || v_sinistre_porte.locdent8);
                --T4M-29
               v_sinistre_porte.locdent9 := F_CTRL_ALPHANUMBER(s_donnees,87,2,fic_cpt_ligne,'T4M-29',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent9:' || v_sinistre_porte.locdent9);
                --T4M-30
               v_sinistre_porte.locdent10 := F_CTRL_ALPHANUMBER(s_donnees,89,2,fic_cpt_ligne,'T4M-30',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent10:' || v_sinistre_porte.locdent10);
                --T4M-31
               v_sinistre_porte.locdent11 := F_CTRL_ALPHANUMBER(s_donnees,91,2,fic_cpt_ligne,'T4M-31',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent11:' || v_sinistre_porte.locdent11);
                --T4M-32
               v_sinistre_porte.locdent12 := F_CTRL_ALPHANUMBER(s_donnees,93,2,fic_cpt_ligne,'T4M-32',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent12:' || v_sinistre_porte.locdent12);
                --T4M-33
               v_sinistre_porte.locdent13 := F_CTRL_ALPHANUMBER(s_donnees,95,2,fic_cpt_ligne,'T4M-33',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent13:' || v_sinistre_porte.locdent13);
                --T4M-34
               v_sinistre_porte.locdent14 := F_CTRL_ALPHANUMBER(s_donnees,97,2,fic_cpt_ligne,'T4M-34',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent14:' || v_sinistre_porte.locdent14);
                --T4M-35
               v_sinistre_porte.locdent15 := F_CTRL_ALPHANUMBER(s_donnees,99,2,fic_cpt_ligne,'T4M-35',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent15:' || v_sinistre_porte.locdent15);
                --T4M-36
               v_sinistre_porte.locdent16 := F_CTRL_ALPHANUMBER(s_donnees,101,2,fic_cpt_ligne,'T4M-36',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.locdent16:' || v_sinistre_porte.locdent16);
               --T4M-38
               v_sinistre_porte.codmodif1 := F_CTRL_ALPHANUMBER(s_donnees,104,1,fic_cpt_ligne,'T4M-36',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.codmodif1:' || v_sinistre_porte.codmodif1);
               --T4M-39
               v_sinistre_porte.codmodif2 := F_CTRL_ALPHANUMBER(s_donnees,105,1,fic_cpt_ligne,'T4M-36',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.codmodif2:' || v_sinistre_porte.codmodif2);
               --T4M-40
               v_sinistre_porte.codmodif3 := F_CTRL_ALPHANUMBER(s_donnees,106,1,fic_cpt_ligne,'T4M-36',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.codmodif3:' || v_sinistre_porte.codmodif3);
               --T4M-41
               v_sinistre_porte.codmodif4 := F_CTRL_ALPHANUMBER(s_donnees,107,1,fic_cpt_ligne,'T4M-36',o_erreur_type);
               P_INS_journal(3,'v_sinistre_porte.codmodif4:' || v_sinistre_porte.codmodif4);
               v_ins_sinistre_porte := PK_TPE.F_UPD_SNTRPRT(v_sinistre_porte);
               IF v_ins_sinistre_porte <> 'OK' THEN
                  RAISE exc_ins_sinistre_porte;
               END IF;

              WHEN 'P' THEN
              --T4P-11
                IF v_sinistre_porte_init.categorie NOT IN ('CP','ES') THEN
                  v_sinistre_porte.indicatsubstit := F_CTRL_ALPHANUMBER(s_donnees,44,1,fic_cpt_ligne,'T4P-11',o_erreur_type);
                END IF;
                P_INS_journal(3,'v_sinistre_porte.indicatsubstit:' || v_sinistre_porte.indicatsubstit);  --U : substitution pour Urgence ou Accord du médecin, N : refus de substitution, A blanc sinon.
                v_ins_sinistre_porte := PK_TPE.F_UPD_SNTRPRT(v_sinistre_porte);
                IF v_ins_sinistre_porte <> 'OK' THEN
                  RAISE exc_ins_sinistre_porte;
                END IF;
              WHEN 'T' THEN
                --T4T-11
                IF v_sinistre_porte_init.categorie NOT IN ('CP','ES') THEN
                  v_sinistre_porte.transporthospi := to_number(F_CTRL_ALPHANUMBER(s_donnees,47,1,fic_cpt_ligne,'T4T-11',o_erreur_type));
                END IF;
                P_INS_journal(3,'v_sinistre_porte.transporthospi:' || v_sinistre_porte.transporthospi);  --0: non, 1 : entrée/sortie, 2: transfert
                --T4T-12
                IF v_sinistre_porte_init.categorie NOT IN ('CP','ES') THEN
                  v_sinistre_porte.longdistance := to_number(F_CTRL_ALPHANUMBER(s_donnees,48,1,fic_cpt_ligne,'T4T-12',o_erreur_type));
                END IF;
                P_INS_journal(3,'v_sinistre_porte.longdistance:' || v_sinistre_porte.longdistance);  --0: pas de longue distance, 1 : longue distance
                --T4T-14
                IF v_sinistre_porte_init.categorie NOT IN ('CP','ES') THEN
                  v_sinistre_porte.forfait := to_number(F_CTRL_ALPHANUMBER(s_donnees,50,1,fic_cpt_ligne,'T4T-14',o_erreur_type));
                END IF;
                P_INS_journal(3,'v_sinistre_porte.forfait:' || v_sinistre_porte.forfait);  --0: pas de forfait, 1 : departement, 2: agglomeration, 3: spécifique region
                v_ins_sinistre_porte := PK_TPE.F_UPD_SNTRPRT(v_sinistre_porte);
                IF v_ins_sinistre_porte <> 'OK' THEN
                  RAISE exc_ins_sinistre_porte;
                END IF;
              WHEN 'B' THEN
                null;
              WHEN 'D' THEN
                null;
              WHEN 'H' THEN
                null;
              ELSE NULL;
           END CASE;
          P_INS_journal(3,'Fin Entité 4 sinistre :' || cpt_numsin);
          IF NOT(o_erreur_type) AND v_type_complement IS NULL THEN
            v_ins_sinistre_porte:=F_INS_PRESTATION(v_sinistre_porte, v_suivi_fact_tpe,cpt_numsin,cpt_lig_entite4);
            IF v_ins_sinistre_porte <> 'OK' THEN
              RAISE exc_ins_sinistre_porte;
            END IF;
          END IF;

        WHEN '5' THEN
          cpt_lig_entite2 := 0;
          cpt_lig_entite4 := 0;
          cpt_lig_entite5 := cpt_lig_entite5 + 1;

          v_type_complement := SUBSTR(s_donnees,39,1);
          IF v_type_complement NOT IN ('T','U') THEN
            v_type_complement :=NULL;
            --T5CP-14
            v_suivi_fact_tpe.montant := F_CTRL_NUMBER(s_donnees,82,8,fic_cpt_ligne,'T5CP-14',o_erreur_type,'O',6,2);
            P_INS_journal(3,'v_suivi_fact_tpe.montant : ' || v_suivi_fact_tpe.montant);
            --T5CP-15
             IF v_sinistre_porte_init.categorie ='CP' THEN
               v_suivi_fact_tpe.montant := v_suivi_fact_tpe.montant + F_CTRL_NUMBER(s_donnees,90,8,fic_cpt_ligne,'T5CP-15',o_erreur_type,'O',6,2);
             ELSIF v_sinistre_porte_init.categorie ='ES' THEN
               v_suivi_fact_tpe.montant := v_suivi_fact_tpe.montant + F_CTRL_NUMBER(s_donnees,90,8,fic_cpt_ligne,'T5ES-15',o_erreur_type,'O',6,2);
             END IF;
            P_INS_journal(3,'v_suivi_fact_tpe.montant : ' || v_suivi_fact_tpe.montant);

            --PK_TPE.P_MAJ_MT_SUIVI_FACT_TPE(v_porte_remise.numremise,rtrim(v_suivi_fact_tpe.idfactpe),v_suivi_fact_tpe.montant);
            --insertion dans suivi_fact_tPE
            v_ins_suivi_fact_tpe := PK_TPE.F_UPD_SUIVIFACT(v_suivi_fact_tpe);
            IF v_ins_suivi_fact_tpe <> 'OK' THEN
              RAISE exc_ins_suivi_fact_tpe ;
            END IF;
          END IF;


        WHEN '6' THEN
         cpt_lig_entite2 := 0;
         cpt_lig_entite4 := 0;
         cpt_lig_entite6 := cpt_lig_entite6 + 1;

         cpt_tot_prest := cpt_tot_prest+F_CTRL_NUMBER(s_donnees,14,4,fic_cpt_ligne,'T6-4',o_erreur_type,'O',4,0);
       --  P_INS_journal(1,'Nombre de prestations communiqué par lot : ' || cpt_tot_prest);
       --  P_INS_journal(1,'Compteur sinistre par lot : ' || cpt_numsin);
         cpt_tot_fact := cpt_tot_fact+ F_CTRL_NUMBER(s_donnees,11,3,fic_cpt_ligne,'T6-3',o_erreur_type,'O',3,0);
         mtrc_tot_fact := mtrc_tot_fact + F_CTRL_NUMBER(s_donnees,43,9,fic_cpt_ligne,'T6-5',o_erreur_type,'O',7,2);
        WHEN '9' THEN
		 v_facture_annul:=0;
        ELSE
          NULL;
      END CASE;

      --insertion dans stock_entite 'NO33T'
      --insertion dans stock_entite_p 'NO34T'
      IF NOT(o_erreur_type) THEN
        v_stock_entite.nom_fichier := i_fichier;
        v_stock_entite.numremise := v_porte_remise.numremise;
        v_stock_entite.cod_entite := 'T' || v_type_enreg || v_type_complement;
        v_stock_entite.entite := s_donnees;
        v_stock_entite.numsin := cpt_numsin;
        IF v_type_enreg IN ('3','4','5') THEN
          v_stock_entite.group_rejet :=  v_suivi_fact_tpe.idfactpe;
        ELSE
         v_stock_entite.group_rejet := NULL;
        END IF;
        v_stock_entite.flg_fin_ligne := 1;

       P_INS_journal(3,'Stock entité traitement : ' || i_traitement );
       IF i_traitement = 'NO33T' THEN
        v_ins_stock_entite := PK_TPE.F_INS_STOCKENT(v_stock_entite);
         --mise à jour des entité 2 précédent T2X
        -- v_ins_stock_entite:='';
        IF  v_stock_entite.cod_entite ='T2X' THEN
         v_stock_entite.group_rejet :=  v_suivi_fact_tpe.idfactpe;
         PK_TPE.P_UPD_STOCKENT_REJET(v_stock_entite,'T2');
         P_INS_journal(3,'v_stock_entite.group_rejet : ' || v_stock_entite.group_rejet );
        END IF;

       ELSIF i_traitement = 'NO34T' THEN
        v_ins_stock_entite := PK_TPE.F_INS_STOCKENT_P(v_stock_entite);
         --mise à jour des entité 2 précédent T2X
        IF  v_stock_entite.cod_entite ='T2X' THEN
          v_stock_entite.group_rejet :=  v_suivi_fact_tpe.idfactpe;
          PK_TPE.P_UPD_STOCKENT_P_REJET(v_stock_entite,'T2');
          P_INS_journal(3,'v_stock_entite.group_rejet : ' || v_stock_entite.group_rejet );
        END IF;
       ELSE
        NULL;
       END IF;
      END IF;


     EXCEPTION
        WHEN no_data_found THEN
           EXIT;
		WHEN exc_facture_annul THEN NULL; -- permet de sauter les lignes jusqu'à la ligne 9
     END;
   END LOOP;

   IF o_erreur_type THEN
      RAISE exc_type_chaine;
   END IF;

  -- Deblocage automatique sur les avis de paiements
  P_INS_journal(1,'DEBUT Deblocage automatique sur les avis de paiements');
  FOR cpt_tab IN 1..tab_numremise.COUNT LOOP
    P_INS_journal(1,'Deblocage automatique sur les avis de paiements - Remise '|| tab_numremise(cpt_tab));
    loc_nature := NULL ;
    BEGIN
      SELECT pr.nature
      INTO   loc_nature
      FROM   porte_remise pr
      WHERE pr.numremise = tab_numremise(cpt_tab)
        AND pr.numporte  = i_numporte ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_INS_journal(2,'Deblocage automatique - Remise '|| tab_numremise(cpt_tab)|| ' non trouvée');
        CONTINUE;
      WHEN OTHERS THEN
        P_INS_journal(2,'Deblocage automatique- Erreur accès remise '|| tab_numremise(cpt_tab)|| SQLERRM);
        CONTINUE;
    END;
    IF loc_nature = 3 THEN
      P_DEBLOCAGE_ASSURE(tab_numremise(cpt_tab), i_numporte);
    END IF;
  END LOOP;
  P_INS_journal(2,'FIN Deblocage automatique sur les avis de paiements');


   --fermeture du fichier
   IF UTL_FILE.IS_OPEN(fic_H_FIC) THEN
      UTL_FILE.FCLOSE(fic_H_FIC);
   END IF;

 --  P_INS_journal(1,'Nombre de prestations communiqué : ' || cpt_tot_prest);
  -- P_INS_journal(1,'Nombre de factures communiqué : ' || cpt_tot_fact);
   P_INS_journal(1,'Montant total RC facturé : ' || mtrc_tot_fact);

   P_INS_journal(3,'FIN de l''import');

EXCEPTION
 --nom de fichier saisi incorrect
 WHEN exc_fic_incorrect THEN --PROJET ROC
    o_found := 1;
    o_erreur := 'Nom de fichier incorrect';
    P_INS_journal(1,i_traitement,'exc_fic_incorrect :' || o_erreur||substr(i_fichier,1,30));
  --concerne l'ouverture du fichier
  WHEN UTL_FILE.INVALID_PATH THEN
    o_found := 1;
    o_erreur := 'Nom de répertoire ou de fichier invalide.';
    P_INS_journal(1,i_traitement,'INVALID_PATH:' || o_erreur||substr(i_fichier,1,30));
  WHEN UTL_FILE.INVALID_MODE THEN
    o_found := 1;
    o_erreur := 'Mode d''ouverture invalide.';
    P_INS_journal(1,i_traitement,'INVALID_MODE:' || o_erreur||substr(i_fichier,1,30));
  WHEN UTL_FILE.INVALID_OPERATION THEN
    o_found := 1;
    o_erreur := 'Le fihcier ne peut être ouvert.';
    P_INS_journal(1,i_traitement,'INVALID_OPERATION:' || o_erreur||substr(i_fichier,1,30));
    IF UTL_FILE.IS_OPEN(fic_H_FIC) THEN
      UTL_FILE.FCLOSE(fic_H_FIC);
    END IF;
  WHEN UTL_FILE.INVALID_MAXLINESIZE THEN
    o_found := 1;
    o_erreur := 'La valeur de taille_ligne_maxi est trop grande ou trop petite.';
    P_INS_journal(1,i_traitement,'INVALID_MAXLINESIZE:' || o_erreur||substr(i_fichier,1,30));
  --fin concerne l'ouverture du fichier
  --fichier deja traité
  WHEN exc_fic_import_ctrl THEN
    o_found := 1;
    o_erreur := 'Cette remise a déja été importée (remise '|| fic_verif_import ||').';
    P_INS_journal(1,i_traitement,o_erreur);
    FOR cpt_tab IN 1..tab_numremise.COUNT LOOP
        P_INS_journal(3,i_traitement,'delete numremise:' || tab_numremise(cpt_tab));
        PK_TPE.P_DELETE_INFOS_TPE(tab_numremise(cpt_tab),i_traitement,i_numporte);
    END LOOP;
    IF UTL_FILE.IS_OPEN(fic_H_FIC) THEN
      UTL_FILE.FCLOSE(fic_H_FIC);
    END IF;
  --erreur insert base
  WHEN exc_ins_porte_remise THEN
    o_found := 1;
    o_erreur := 'Erreur d''insertion dans PORTE_REMISE';
    P_INS_journal(1,o_erreur);
    P_INS_journal(1,v_ins_porte_remise);
    FOR cpt_tab IN 1..tab_numremise.COUNT LOOP
        P_INS_journal(3,i_traitement,'delete numremise:' || tab_numremise(cpt_tab));
        PK_TPE.P_DELETE_INFOS_TPE(tab_numremise(cpt_tab),i_traitement,i_numporte);
    END LOOP;
    IF UTL_FILE.IS_OPEN(fic_H_FIC) THEN
      UTL_FILE.FCLOSE(fic_H_FIC);
    END IF;
  WHEN exc_ins_suivi_fact_tpe THEN
    o_found := 1;
    o_erreur := 'Erreur d''insertion dans SUIVI_FACT_TPE';
    P_INS_journal(1,o_erreur);
    P_INS_journal(1,v_ins_suivi_fact_tpe);
    FOR cpt_tab IN 1..tab_numremise.COUNT LOOP
        P_INS_journal(3,i_traitement,'delete numremise:' || tab_numremise(cpt_tab));
        PK_TPE.P_DELETE_INFOS_TPE(tab_numremise(cpt_tab),i_traitement,i_numporte);
    END LOOP;
    IF UTL_FILE.IS_OPEN(fic_H_FIC) THEN
      UTL_FILE.FCLOSE(fic_H_FIC);
    END IF;
   WHEN exc_ins_sinistre_porte THEN
    o_found := 1;
    o_erreur := 'Erreur d''insertion dans SINISTRE_PORTE';
    P_INS_journal(1,o_erreur);
    P_INS_journal(1,v_ins_sinistre_porte);
    FOR cpt_tab IN 1..tab_numremise.COUNT LOOP
        P_INS_journal(3,i_traitement,'delete numremise:' || tab_numremise(cpt_tab));
        PK_TPE.P_DELETE_INFOS_TPE(tab_numremise(cpt_tab),i_traitement,i_numporte);
    END LOOP;
    IF UTL_FILE.IS_OPEN(fic_H_FIC) THEN
      UTL_FILE.FCLOSE(fic_H_FIC);
    END IF;
  --fin erreur base
  WHEN exc_type_chaine THEN
     o_found := 1;
     o_erreur := 'Le fichier comporte une anomalie de structure';
     P_INS_journal(1,o_erreur);
     FOR cpt_tab IN 1..tab_numremise.COUNT LOOP
        P_INS_journal(3,i_traitement,'delete numremise:' || tab_numremise(cpt_tab));
        PK_TPE.P_DELETE_INFOS_TPE(tab_numremise(cpt_tab),i_traitement,i_numporte);
     END LOOP;
     IF UTL_FILE.IS_OPEN(fic_H_FIC) THEN
      UTL_FILE.FCLOSE(fic_H_FIC);
     END IF;
  WHEN OTHERS THEN
     o_found := 1;
     P_INS_journal(1,i_traitement,'Erreur :' || SQLERRM);
     FOR cpt_tab IN 1..tab_numremise.COUNT LOOP
        P_INS_journal(3,i_traitement,'delete numremise:' || tab_numremise(cpt_tab));
        PK_TPE.P_DELETE_INFOS_TPE(tab_numremise(cpt_tab),i_traitement,i_numporte);
     END LOOP;
     IF UTL_FILE.IS_OPEN(fic_H_FIC) THEN
      UTL_FILE.FCLOSE(fic_H_FIC);
     END IF;
END P_IMPORT_DRE;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_EXPORT_ACC_REJ                                          */
/* Type         :  Public                                                    */
/* Description  :  procedure de gestion d'export                             */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_EXPORT_ACC_REJ (
  i_traitement   IN    VARCHAR2,
  i_remise_exp   IN    remise_externe.numremise%TYPE,
  i_nature_exp   IN    VARCHAR2,
  i_session      IN    NUMBER DEFAULT 1,
  i_niv_msg      IN    NUMBER DEFAULT 1,
  i_repertoire   IN    VARCHAR2 DEFAULT NULL,
  i_fichier      IN    VARCHAR2 DEFAULT NULL,
  o_found        OUT   NUMBER,
  o_erreur       OUT   VARCHAR2
) IS
  EXC_NAT_EXP EXCEPTION;
  o_found_export_acc NUMBER;
  o_erreur_export_acc VARCHAR2(200);
  o_found_export_rej NUMBER;
  o_erreur_export_rej VARCHAR2(200);
BEGIN

  -- Selon nature_exp, gérer les acceptations (à 5 et codevfac à 40) ou les rejets (à 4 et codevfac à 35)
  IF i_nature_exp = '4' THEN
    P_EXPORT_ACC(i_traitement,i_remise_exp,i_nature_exp,i_session,i_niv_msg,i_repertoire,i_fichier,o_found_export_acc,o_erreur_export_acc);
  ELSIF i_nature_exp = '5' THEN
    P_EXPORT_REJ(i_traitement,i_remise_exp,i_nature_exp,i_session,i_niv_msg,i_repertoire,i_fichier,o_found_export_rej,o_erreur_export_rej);
  ELSE
    RAISE EXC_NAT_EXP;
  END IF;

EXCEPTION
  WHEN EXC_NAT_EXP THEN
    o_found := 1;
    P_INS_journal(1,'P_EXPORT_ACC_REJ','ERROR nature_exp not in (4,5)');
  WHEN OTHERS THEN
    o_found := 1;
    P_INS_journal(1,'P_EXPORT_ACC_REJ','Others:' || SQLERRM);
END P_EXPORT_ACC_REJ;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_EXPORT_ACC                                              */
/* Type         :  Public                                                    */
/* Description  :  procedure d'export des acceptations                       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_EXPORT_ACC (
  i_traitement   IN    VARCHAR2,
  i_remise_exp   IN    remise_externe.numremise%TYPE,
  i_nature_exp   IN    VARCHAR2,
  i_session      IN    NUMBER DEFAULT 1,
  i_niv_msg      IN    NUMBER DEFAULT 1,
  i_repertoire   IN    VARCHAR2 DEFAULT NULL,
  i_fichier      IN    VARCHAR2 DEFAULT NULL,
  o_found        OUT   NUMBER,
  o_erreur       OUT   VARCHAR2
) IS
--
  CURSOR C_REMISE(io_remise_exp remise_externe.numremise%TYPE)IS
    SELECT DISTINCT numremise_import
      FROM suivi_fact_tpe
      WHERE codevefac = 40
      AND numremise_export = io_remise_exp;
--
  CURSOR C_ENTITE(io_numremise_import suivi_fact_tpe.numremise_import%TYPE)IS
    SELECT a.entite, a.cod_entite, a.ordre
    FROM stock_entite a
    WHERE (  EXISTS (
              SELECT NULL
                FROM suivi_fact_tpe
                WHERE idfactpe = a.group_rejet
                  AND codevefac = 40
                  AND numremise_import = io_numremise_import)
                  OR a.group_rejet IS NULL
           )
    AND a.numremise = io_numremise_import
    ORDER BY a.ordre;
--
  v_fichier             VARCHAR2(200);
  v_sortie              UTL_FILE.file_type;
  v_total_line          NUMBER := 0;
  v_eme                 VARCHAR2(200);
  v_dest                VARCHAR2(200);
  v_count_T2            NUMBER := 0;
  v_count_T6_T9         NUMBER := 0;
  v_count_T2_autre      NUMBER := 0;
  v_count_T1_autre      NUMBER := 0;
  v_count_T3_autre      NUMBER := 0;
  v_count_T4_autre      NUMBER := 0;
  v_count_T5_autre      NUMBER := 0;
--  v_count_T2_tous       NUMBER := 0;
  v_count_T3            NUMBER := 0;
  v_count_T4            NUMBER := 0;
 -- v_count_T3_T4         NUMBER := 0;
  v_count_T3_T6         NUMBER := 0;
  v_count_T4_T6         NUMBER := 0;
  v_count_T2_T6         NUMBER := 0;
  v_count_T5            NUMBER := 0;
  v_sum                  NUMBER := 0;
  v_montant_tot         NUMBER := 0; -- T6-7
  v_montant_tot_ro      NUMBER := 0; -- T6-8
  v_montant_tot_rc      NUMBER := 0; -- T6-9
  v_numporte            remise_externe.numporte%TYPE; --projet ROC

  ligne_T0              stock_entite.entite%TYPE;
  TYPE tab_ligne             IS TABLE OF  stock_entite.entite%TYPE index by binary_integer ;
  cpt_tab NUMBER;
  l_tab_ligne tab_ligne;
  l_tab_ligne_vide tab_ligne;
  loc_norme           VARCHAR2(2);
--
  EXC_repertoire_vide EXCEPTION;
--

BEGIN
  --
  -- Si repertoire ou fichier de sortie non precise alors le traitement s'arrete
  --
  IF i_repertoire IS NULL
  THEN
     RAISE EXC_repertoire_vide;
  END IF;
  g_nom_traitement:=i_traitement;
  g_session   := i_session;

  --recupération de la porte
  BEGIN
    select numporte into v_numporte from remise_externe where numremise=i_remise_exp;
  EXCEPTION
  WHEN OTHERS THEN v_numporte :=null;
  END;
  -- Formatage du nom de fichier
  v_fichier := F_NOM_FICHIER(i_fichier,v_numporte);
  -- Creation fichier
  v_sortie := UTL_FILE.fopen (i_repertoire, v_fichier, 'w', 32767);

  FOR R_REMISE IN C_REMISE(i_remise_exp) LOOP
    FOR R_ENTITE IN C_ENTITE(R_REMISE.numremise_import) LOOP

      CASE R_ENTITE.cod_entite
        WHEN 'T0' THEN
          ligne_T0:=NULL;
          -- Inversement des numéro d'émetteur et destinataire
          v_eme := SUBSTR(R_ENTITE.entite,4,16); -- Récupération de l'émetteur (type et numéro)
          v_dest := SUBSTR(R_ENTITE.entite,26,16);
          R_ENTITE.entite := REPLACE( R_ENTITE.entite, v_eme, '_BUFFER_');
          R_ENTITE.entite := REPLACE( R_ENTITE.entite, v_dest,v_eme);
          R_ENTITE.entite := REPLACE( R_ENTITE.entite, '_BUFFER_',v_dest);
          -- Remplacement du terme 'FACTURE INITIALE'
          R_ENTITE.entite := REPLACE( R_ENTITE.entite, 'FACTURE INITIALE', '                ');
          -- Remplacement de la date de création du fichier
          --R_ENTITE.entite := REPLACE( R_ENTITE.entite, SUBSTR(R_ENTITE.entite,56,6),TO_CHAR(SYSDATE,'YYMMDD'));
          R_ENTITE.entite := SUBSTR( R_ENTITE.entite,0,55)|| TO_CHAR(SYSDATE,'YYMMDD')||SUBSTR( R_ENTITE.entite,62);

          ligne_T0 :=R_ENTITE.entite;


        WHEN 'T1' THEN
        v_count_T2_T6    := 0;
        v_count_T4_T6    := 0;
        v_count_T3_T6    := 0;
        v_montant_tot    := 0; -- T6-7
        v_montant_tot_ro := 0; -- T6-8
        v_montant_tot_rc := 0; -- T6-9
        cpt_tab:=0;
        l_tab_ligne :=l_tab_ligne_vide;

        loc_norme := SUBSTR(R_ENTITE.entite,79,2); --projet ROC Recupération de la norme champs T1-13
        P_INS_journal(3,'P_EXPORT_ACC','loc_norme '||loc_norme);
        WHEN 'T2' THEN
        v_count_T2 := 1;
        v_count_T3       := 0;
        v_count_T4       := 0;
        v_count_T3_autre :=0;
        v_count_T4_autre :=0;

        v_count_T5       := 0;
        v_count_T5_autre :=0;
        --on écrit les entité T0 et T1 retenues uniquement si facture présentes
        IF ligne_T0 IS NOT NULL THEN
          UTL_FILE.put_line (v_sortie,ligne_T0);
          ligne_T0:=NULL;
          v_total_line := v_total_line + 1;
        END IF;
        FOR i in 1..l_tab_ligne.count LOOP
          UTL_FILE.put_line (v_sortie,l_tab_ligne(i));
          v_total_line := v_total_line + 1;
        END LOOP;

        WHEN 'T3' THEN
        v_count_T3 := v_count_T3 + 1;
        --P_INS_journal(3,'P_EXPORT_ACC','v_count_T3 '||v_count_T3);

        WHEN 'T4' THEN
        v_count_T4 := v_count_T4 + 1;
        --P_INS_journal(3,'P_EXPORT_ACC','v_count_T4 '||v_count_T4);

        WHEN 'T5' THEN
        IF v_count_T2 > 0 THEN
          v_count_T5 := v_count_T5 +1;

          --montant T3 + T4 avec complément de type
          --R_ENTITE.entite := REPLACE( R_ENTITE.entite, SUBSTR(R_ENTITE.entite,39,3),LPAD( TO_CHAR(v_count_T3+v_count_T3_autre+v_count_T4+v_count_T4_autre), 3 ,'0' ));
          R_ENTITE.entite := SUBSTR( R_ENTITE.entite,0,38)|| LPAD( TO_CHAR(v_count_T3+v_count_T3_autre+v_count_T4+v_count_T4_autre), 3 ,'0' )||SUBSTR( R_ENTITE.entite,42);
          IF loc_norme in ('CP','ES') THEN
            v_montant_tot    := v_montant_tot + TO_NUMBER(SUBSTR(R_ENTITE.entite,58,8)) + TO_NUMBER(SUBSTR(R_ENTITE.entite,115,8)); -- T6-7 = T5-11 + T5-17 --elle n'existe pas en autres nomes ne pas prendre en consideration (T5CP-17 montant total facturé pr prest hosp)
          ELSE--autres normes
            v_montant_tot    := v_montant_tot + TO_NUMBER(SUBSTR(R_ENTITE.entite,58,8));
          END IF;
          v_montant_tot_ro := v_montant_tot_ro + TO_NUMBER(SUBSTR(R_ENTITE.entite,66,8)); -- T6-8 = T5-12
          IF loc_norme in ('CP','ES') THEN
            v_montant_tot_rc := v_montant_tot_rc + TO_NUMBER(SUBSTR(R_ENTITE.entite,82,8)) + TO_NUMBER(SUBSTR(R_ENTITE.entite,90,8)); -- T6-9 = T5-14
          ELSE
            v_montant_tot_rc := v_montant_tot_rc + TO_NUMBER(SUBSTR(R_ENTITE.entite,82,8)) ; -- T6-9 = T5-14 + T5-15
          END IF;
          v_count_T4_T6 := v_count_T4_T6 + v_count_T4;
          v_count_T3_T6 := v_count_T3_T6 + v_count_T3;
          v_count_T2_T6 := v_count_T2_T6 + v_count_T2;
          --v_count_T5_T9 := v_count_T5_T9 + v_count_T5;
          P_INS_journal(3,'P_EXPORT_ACC','v_count_T4_T6 : ' || v_count_T4_T6);
          P_INS_journal(3,'P_EXPORT_ACC','v_count_T3_T6 : ' || v_count_T3_T6);
          P_INS_journal(3,'P_EXPORT_ACC','v_count_T2_T6 : ' || v_count_T2_T6);
          P_INS_journal(3,'P_EXPORT_ACC','v_count_T2 : ' || v_count_T2);
          l_tab_ligne :=l_tab_ligne_vide;
          v_count_T2:=0;
        END IF;

        WHEN 'T6' THEN
          IF v_count_T2_T6 > 0 THEN
            v_count_T6_T9:=v_count_T6_T9+1;
            P_INS_journal(3,'P_EXPORT_ACC','T6-8 === '||v_montant_tot);
            -- Insertion nombre de T2
            R_ENTITE.entite := REPLACE( R_ENTITE.entite, SUBSTR(R_ENTITE.entite,11,3),LPAD( TO_CHAR(v_count_T2_T6), 3 ,'0' ));
            -- Insertion nombre de T3 et T4 sans complément de Type
            R_ENTITE.entite := SUBSTR( R_ENTITE.entite,0,13)||  LPAD(TO_CHAR(v_count_T4_T6+v_count_T3_T6), 4 ,'0' )||SUBSTR( R_ENTITE.entite,18);
            -- Insertion nombre de tous les T2 avec complément de type

            R_ENTITE.entite := SUBSTR( R_ENTITE.entite,0,17)||  LPAD(TO_CHAR(v_count_T2_T6 + v_count_T2_autre), 4 ,'0' )||SUBSTR( R_ENTITE.entite,22);
            -- Insertion nombre enregistrement de T5 avec complément de type
            R_ENTITE.entite := SUBSTR( R_ENTITE.entite,0,21)|| LPAD( TO_CHAR(v_count_T5+v_count_T5_autre), 3 ,'0' )||SUBSTR( R_ENTITE.entite,25);
            -- Insertion montant total général du lot
            --R_ENTITE.entite := REPLACE( R_ENTITE.entite, SUBSTR(R_ENTITE.entite,25,9),LPAD( TO_CHAR(v_montant_tot), 9 ,'0' )); -- T6-7
             R_ENTITE.entite := SUBSTR( R_ENTITE.entite,0,24)|| LPAD( TO_CHAR(v_montant_tot), 9 ,'0' )||SUBSTR( R_ENTITE.entite,34);
            -- Insertion montant total ro du lot
            --R_ENTITE.entite := REPLACE( R_ENTITE.entite, SUBSTR(R_ENTITE.entite,34,9),LPAD( TO_CHAR(v_montant_tot_ro), 9 ,'0' )); -- T6-8
            R_ENTITE.entite := SUBSTR( R_ENTITE.entite,0,33)|| LPAD( TO_CHAR(v_montant_tot_ro), 9 ,'0' )||SUBSTR( R_ENTITE.entite,43);
            -- Insertion montant total rc du lot
            --R_ENTITE.entite := REPLACE( R_ENTITE.entite, SUBSTR(R_ENTITE.entite,43,9),LPAD( TO_CHAR(v_montant_tot_rc), 9 ,'0' )); -- T6-9
            R_ENTITE.entite := SUBSTR( R_ENTITE.entite,0,42)|| LPAD( TO_CHAR(v_montant_tot_rc), 9 ,'0' )||SUBSTR( R_ENTITE.entite,52);
          END IF;

        WHEN 'T9' THEN

            -- Inversement des numéro d'émetteur et destinataire
            v_eme := SUBSTR(R_ENTITE.entite,4,16); -- Récupération de l'émetteur (type et numéro)
            v_dest := SUBSTR(R_ENTITE.entite,26,16);
            R_ENTITE.entite := REPLACE( R_ENTITE.entite, v_eme, '_BUFFER_');
            R_ENTITE.entite := REPLACE( R_ENTITE.entite, v_dest,v_eme);
            R_ENTITE.entite := REPLACE( R_ENTITE.entite, '_BUFFER_',v_dest);
            -- Remplacement de l'identification du fichier par le numéro de remise
            --R_ENTITE.entite := REPLACE( R_ENTITE.entite, SUBSTR(R_ENTITE.entite,50,6),LPAD( R_REMISE.numremise_import, 6 ,'0' ));
            R_ENTITE.entite := SUBSTR( R_ENTITE.entite,0,49)|| LPAD( R_REMISE.numremise_import, 6 ,'0' )||SUBSTR( R_ENTITE.entite,56);
            R_ENTITE.entite := SUBSTR( R_ENTITE.entite,0,55)|| LPAD( v_total_line+1, 8 ,'0' )||SUBSTR( R_ENTITE.entite,64);
            R_ENTITE.entite := SUBSTR( R_ENTITE.entite,0,82)|| LPAD( v_count_T6_T9, 3 ,'0' )||SUBSTR( R_ENTITE.entite,86);
            v_count_T6_T9:=0;
            v_total_line:=-1;


        ELSE
          IF R_ENTITE.cod_entite LIKE 'T2%' THEN
            v_count_T2_autre := v_count_T2_autre + 1;
          ELSIF R_ENTITE.cod_entite LIKE 'T5%' THEN
            v_count_T5_autre := v_count_T5_autre + 1;
          ELSIF R_ENTITE.cod_entite LIKE 'T4%' THEN
            v_count_T4_autre := v_count_T4_autre + 1;
          ELSIF R_ENTITE.cod_entite LIKE 'T3%' THEN
            v_count_T3_autre := v_count_T3_autre + 1;
          ELSIF R_ENTITE.cod_entite LIKE 'T1%' THEN
            v_count_T1_autre := v_count_T1_autre + 1;
          END IF;

      END CASE;

      --Rétention des T1 avec ses suppléments
      IF R_ENTITE.cod_entite LIKE 'T1%' THEN
        cpt_tab:=cpt_tab+1;
        l_tab_ligne(cpt_tab) :=R_ENTITE.entite;
      --SDA rajout de la ligne T9 dans le 2eme OR (si on n'avait pas de T2 T6 on n'avait pas de creation de T9)
      ELSIF ((v_count_T2 +v_count_T2_T6 >0 AND ( R_ENTITE.cod_entite LIKE 'T5%' OR R_ENTITE.cod_entite LIKE 'T6%' OR R_ENTITE.cod_entite LIKE 'T9%'))
            OR ( R_ENTITE.cod_entite LIKE 'T2%' OR R_ENTITE.cod_entite LIKE 'T3%' OR R_ENTITE.cod_entite LIKE 'T4%' OR R_ENTITE.cod_entite LIKE 'T9%' ))THEN

       UTL_FILE.put_line (v_sortie,R_ENTITE.entite);
       v_total_line := v_total_line + 1;
      END IF;

    END LOOP;

    v_montant_tot    := 0; -- T6-7
    v_montant_tot_ro := 0; -- T6-8
    v_montant_tot_rc := 0; -- T6-9
  END LOOP;

  -- Mise à jour de la date de transmission de la remise
  UPDATE remise_externe
  SET date_trans = TRUNC (SYSDATE)
  WHERE numremise = i_remise_exp;

  --
  UTL_FILE.fclose (v_sortie);
  --P_INS_journal(1,'P_EXPORT_ACC','Fin de traitement le ' || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi'));
  --P_INS_journal(1,'P_EXPORT_ACC','Nombre de lignes insérés : ' || v_total_line);

EXCEPTION
  WHEN UTL_FILE.internal_error THEN
     o_found := 1;
     P_INS_journal(1,'P_EXPORT_ACC','UTL_FILE.INTERNAL_ERROR');
     UTL_FILE.fclose (v_sortie);
  WHEN UTL_FILE.invalid_filehandle THEN
     o_found := 1;
     P_INS_journal(1,'P_EXPORT_ACC','UTL_FILE.INVALID_FILEHANDLE');
     UTL_FILE.fclose (v_sortie);
  WHEN UTL_FILE.invalid_mode THEN
     o_found := 1;
     P_INS_journal(1,'P_EXPORT_ACC','UTL_FILE.INVALID_MODE');
     UTL_FILE.fclose (v_sortie);
  WHEN UTL_FILE.invalid_operation THEN
     o_found := 1;
     P_INS_journal(1,'P_EXPORT_ACC','UTL_FILE.INVALID_OPERATION');
     UTL_FILE.fclose (v_sortie);
  WHEN UTL_FILE.invalid_path THEN
     o_found := 1;
     P_INS_journal(1,'P_EXPORT_ACC','UTL_FILE.INVALID_PATH');
     UTL_FILE.fclose (v_sortie);
  WHEN UTL_FILE.read_error THEN
     o_found := 1;
     P_INS_journal(1,'P_EXPORT_ACC','UTL_FILE.READ_ERROR');
     UTL_FILE.fclose (v_sortie);
  WHEN UTL_FILE.write_error THEN
     o_found := 1;
     P_INS_journal(1,'P_EXPORT_ACC','UTL_FILE.WRITE_ERROR');
     UTL_FILE.fclose (v_sortie);
  WHEN VALUE_ERROR THEN
     o_found := 1;
     P_INS_journal(1,'P_EXPORT_ACC','UTL_FILE.VALUE_ERROR');
     UTL_FILE.fclose (v_sortie);
  WHEN EXC_repertoire_vide THEN
    o_found := 1;
    P_INS_journal(1,'P_EXPORT_ACC','Nom de(s) répertoire(s) de sortie manquant');
  WHEN OTHERS THEN
    o_found := 1;
    P_INS_journal(1,'P_EXPORT_ACC','Others:' || SQLERRM);
END P_EXPORT_ACC;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_EXPORT_REJ                                              */
/* Type         :  Public                                                    */
/* Description  :  procedure d'export des rejets                             */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_EXPORT_REJ (
  i_traitement   IN    VARCHAR2,
  i_remise_exp   IN    remise_externe.numremise%TYPE,
  i_nature_exp   IN    VARCHAR2,
  i_session      IN    NUMBER DEFAULT 1,
  i_niv_msg      IN    NUMBER DEFAULT 1,
  i_repertoire   IN    VARCHAR2 DEFAULT NULL,
  i_fichier      IN    VARCHAR2 DEFAULT NULL,
  o_found        OUT   NUMBER,
  o_erreur       OUT   VARCHAR2
) IS
--
  CURSOR C_REMISE_IMPORT(i_remise_exp remise_externe.numremise%TYPE)IS
    SELECT DISTINCT numremise_import
      FROM suivi_fact_tpe
      WHERE codevefac = 35
      AND numremise_export = i_remise_exp;
--
  CURSOR C_stock(i_numremise_import suivi_fact_tpe.numremise_import%TYPE)IS
    SELECT a.entite, a.cod_entite, a.ordre, a.numsin
    FROM stock_entite a
    WHERE (  EXISTS (
              SELECT NULL
                FROM suivi_fact_tpe
                WHERE idfactpe = a.group_rejet
                  AND codevefac = 35
                  AND numremise_import = i_numremise_import)
                  OR a.group_rejet IS NULL
           )
    AND a.numremise = i_numremise_import
    AND a.cod_entite in ('T0','T1','T2','T2S','T2P','T3','T4','T5','T9')
    ORDER BY a.ordre;

  CURSOR C_Stock580 (i_numremise_import suivi_fact_tpe.numremise_import%TYPE) IS
  SELECT   ent_020,ent_040, ent_071, ent_081,
          ent_102, ent_103, ent_199,ent_294
     FROM stock_entite_norm_580
    WHERE numremise = i_numremise_import
 ORDER BY ent_020,
          ent_040,
          ent_071,
          ent_081,
          ent_103,
          ent_199,
          ent_294;
--
  v_fichier             VARCHAR2(200);
  v_sortie              UTL_FILE.file_type;
  v_total_line          NUMBER;
  v_mut_mon             NUMBER;
--
  EXC_repertoire_vide   EXCEPTION;
--
  l_buffer              VARCHAR2 (32767);
  l_buffer_1019         VARCHAR2 (32767);
  l_longueur_chaine     PLS_INTEGER;
  l_count_line          PLS_INTEGER;
  l_total_line          PLS_INTEGER;


  l_count_020           PLS_INTEGER;--compteur niveau 02
  l_count_040           PLS_INTEGER;--compteur niveau 03
  l_count_071           PLS_INTEGER;--compteur niveau 04
  l_count_081           PLS_INTEGER;--compteur niveau 05
  l_count_102           PLS_INTEGER; --compteur niveau 99


  l_count_99            PLS_INTEGER;
  l_ordre               stock_entite.ordre%TYPE;
  l_ordre_fin           stock_entite.ordre%TYPE;
  l_true                PLS_INTEGER;


  --La norme défini des longueur fixent par entité
  l_020                 VARCHAR2 (21);--Mandataire du PS
  l_040                 VARCHAR2 (21);--destinataire de règlement
  l_071                 VARCHAR2 (86);--Date comptable et référence de virement
  l_081                 VARCHAR2 (22);--Type de retour et lieu d'éxécution
  l_102                 VARCHAR2 (40); --Facture
  l_103                 VARCHAR2 (152);--Assuré / Bénéficiaire
  l_199                 VARCHAR2 (49);--Part AMC  stockée dans ancienne entite 160
  l_294                 VARCHAR2 (153);--Rejet
  v_numporte            remise_externe.numporte%TYPE;
  loc_norme             VARCHAR2(2);



BEGIN
  g_nom_traitement:=i_traitement;
  g_session   := i_session;
  --
  -- Si repertoire ou fichier de sortie non precise alors le traitement s'arrete
  --
  IF i_repertoire IS NULL THEN
    RAISE EXC_repertoire_vide;
  END IF;
  --recupération de la porte
  BEGIN
    select numporte into v_numporte from remise_externe where numremise=i_remise_exp;
  EXCEPTION
  WHEN OTHERS THEN v_numporte :=null;
  END;
  -- Formatage du nom de fichier
  v_fichier := F_NOM_FICHIER(i_fichier,v_numporte);
  -- Creation fichier
  v_sortie := UTL_FILE.fopen (i_repertoire, v_fichier, 'w', 32767);

  -- Initialisation de la variable 'l_total_line' avant le LOOP :
  l_total_line := 0;
  --
  FOR Rec_Remise_Import IN C_Remise_Import(i_remise_exp)    LOOP
    l_ordre_fin := 0;
    l_count_line := 0;
    l_count_020 := 0;
    l_count_040 := 0;
    l_count_99 := 0;
    l_count_071 := 0;
    l_count_081 := 0;
    l_count_102 := 0;
    v_mut_mon   := 0;
    l_buffer := NULL;
    P_INS_journal(1,'Remise d''import traitée:'||Rec_Remise_Import.numremise_import);

     --
     -- On recupere les infos, dans la table stock_entite, qui correspondent aux factures rejetees
     -- CTT 14/11/2005 : Utilisation de l'identifiant unique IDFACTPE
    FOR Rec_stock IN C_stock(Rec_Remise_Import.numremise_import) LOOP

        P_INS_journal(3,'cod_entite:'|| Rec_stock.cod_entite|| ' ordre:'||Rec_stock.ordre ||' numsin:'||Rec_stock.numsin);
       --
       -- On recupere le prochain ordre correspondant a une entite 990 selon le niveau, ce qui va servir,
       -- par la suite, a determiner les niveaux superieurs qui n'ont pas de factures rejetees associees
       --
       IF Rec_stock.cod_entite = 'T0'
       THEN
          SELECT MIN (ordre)
            INTO l_ordre
            FROM stock_entite
           --WHERE ROWNUM = 1
          WHERE  ordre > Rec_stock.ordre
             AND cod_entite = 'T9'
             AND numremise = Rec_Remise_Import.numremise_import;
       --ORDER BY ordre;
         P_INS_journal(3,'FIN T9 l_ordre'||l_ordre);
       ELSIF Rec_stock.cod_entite = 'T1' THEN
        l_ordre:=F_CHERCHE_ORDRE (Rec_stock.ordre, 'T6', Rec_Remise_Import.numremise_import);

        P_INS_journal(3,'FIN T6 l_ordre'||l_ordre);

        loc_norme := SUBSTR(Rec_stock.entite,79,2); --projet ROC Recupération de la norme champs T1-13
      /* ELSIF Rec_stock.cod_entite = 'T2'
       THEN
          l_ordre:=F_CHERCHE_ORDRE (Rec_stock.ordre, 'T5', Rec_Remise_Import.numremise_import);
              P_INS_journal(1,'FIN T5 l_ordre'||l_ordre);*/
      /* ELSIF Rec_stock.cod_entite = '110'
       THEN
          l_ordre:=F_CHERCHE_ORDRE (Rec_stock.ordre, '03', Rec_Remise_Import.numremise_import);
       ELSIF Rec_stock.cod_entite = '127'
       THEN
          l_ordre:=F_CHERCHE_ORDRE (Rec_stock.ordre, '04', Rec_Remise_Import.numremise_import);
            P_INS_journal(1,'127 l_ordre'||l_ordre);
       ELSIF Rec_stock.cod_entite = '025'
       THEN
          l_ordre:=F_CHERCHE_ORDRE (Rec_stock.ordre, '05', Rec_Remise_Import.numremise_import);
       ELSIF Rec_stock.cod_entite = '045'
       THEN
          l_ordre:=F_CHERCHE_ORDRE (Rec_stock.ordre, '06', Rec_Remise_Import.numremise_import);*/
       ELSE
          l_true := 0;
          l_ordre := 0;
       END IF;

         --
         -- Permet de ne pas prendre en compte les niveaux superieurs qui n'ont plus de factures associees
         --
       -- CTT 14/11/2005 : Utilisation de l'identifiant unique IDFACTPE
       IF l_ordre > l_ordre_fin
       THEN
          BEGIN
             SELECT 1
               INTO l_true
               FROM stock_entite a
              WHERE (   EXISTS (
                           SELECT NULL
                             FROM suivi_fact_tpe
                            WHERE idfactpe = a.group_rejet
                              AND codevefac = 35
                              AND numremise_import =
                                               Rec_Remise_Import.numremise_import)
                     OR a.group_rejet IS NULL
                    )
                AND a.cod_entite = 'T2'
                AND a.ordre > Rec_stock.ordre
                AND a.ordre < l_ordre
                AND a.numremise = Rec_Remise_Import.numremise_import;
          EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
                l_ordre_fin := l_ordre;
                l_true := 0;
             WHEN TOO_MANY_ROWS
             THEN
                l_true := 1;
          END;
       END IF;
  --l_true := 1;
       --
       -- A partir de maintenant, on ecrit dans le fichier uniquement les factures rejetees et
       -- leurs niveaux superieurs associes
       --
       -- P_INS_journal(1,'---l_true:'||l_true||' l_ordre_fin'||l_ordre_fin);
       IF l_true = 1 OR (l_true = 0 AND Rec_stock.ordre > l_ordre_fin)
       THEN
          IF Rec_stock.cod_entite = 'T0'
          THEN

             UTL_FILE.put_line (v_sortie,
                               '0128000OC'
                                || LPAD (LTRIM (SUBSTR (Rec_stock.entite, 28, 14 )),14, '0')--emetteur
                                || RPAD(' ',6,' ')
                                || 'CS'
                                || LPAD (LTRIM (SUBSTR (Rec_stock.entite, 6,14 )),14, '0')--destinaire
                                || RPAD(' ',6,' ')
                                || 'TR'
                                || RPAD('nuremi',6,' ')   --code du fichier aller
                                || TO_CHAR (SYSDATE, 'DDMMYY')
                                || '580 '
                                || SUBSTR (Rec_stock.entite, 66, 37)
                                || RPAD ('0', 8, '0')
                                || RPAD ('0', 8, '0')
                                || SUBSTR (Rec_stock.entite, 119, 10)
                               );
             l_count_line := l_count_line + 1;
          ELSIF Rec_stock.cod_entite = 'T9'
          THEN
             l_020 := '0';
             l_040 := NULL;
             l_071 := NULL;
             l_081 := NULL;
             l_102 := NULL;
             l_199 := NULL;
             l_294 := NULL;

             --
             -- Lorsqu'on atteint l'entite 999, on ecrit dans le fichier de rejet les infos qu'on a precedemment
             -- stockees dans la table stock_entite_norm_580 lorsqu'on a atteint l'entite 255
             -- ( Voir le commentaire ins_stock_entite_norm_580 )
             --
             FOR Rec_Stock580 IN C_Stock580(Rec_Remise_Import.numremise_import) LOOP


                IF Rec_Stock580.ent_020 != l_020
                THEN
                   IF l_020 != '0'
                   THEN
           -- on l'ecrit, sinon on continue sur le prochain ELSIF ...
                      --
                      -- ... mais avant, on ecrit les entites 990 afin de boucler sur les niveaux
                      --
                      formatage_900 (   '99005'
                            || SUBSTR (l_102, 6, 9)
                            || '        '
                            || LPAD (TO_CHAR (l_count_99), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                     --  P_INS_journal(1,'ent_040'||l_buffer);
                      l_count_99 := 0;
                  formatage_900 (   '99004'
                            || SUBSTR (l_081, 6, 2)
                            || '               '
                            || LPAD (TO_CHAR (l_count_102), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                      l_count_102 := 0;
                     formatage_900 (   '99003'
                            || SUBSTR (l_071, 6, 6)
                            || '           '
                            || LPAD (TO_CHAR (l_count_081), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                      l_count_081 := 0;
                      formatage_900 (   '99002'
                            || SUBSTR (l_040, 6, 15)
                            || '  '
                            || LPAD (TO_CHAR (l_count_071), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                      l_count_071 := 0;
                      formatage_900 (   '99001'
                                     || SUBSTR (l_020, 6, 15)
                                     || '  '
                                     || LPAD (TO_CHAR (l_count_040),
                                              8,
                                              '0'
                                             )
                                     || '00000000000P@',l_buffer,v_sortie,l_count_line
                                    );
                      l_count_040 := 0;
                   END IF;

                   formatage_900 (Rec_Stock580.ent_020,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_040,l_buffer,v_sortie,l_count_line);
                                              -- On ecrit l'entite 040
                   formatage_900 (Rec_Stock580.ent_071,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_081,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_102,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_103,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_199,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_294,l_buffer,v_sortie,l_count_line);
                   l_count_99 := l_count_99 + 2;
                   l_count_102 := l_count_102 + 1;
                   l_count_081 := l_count_081 + 1;
                   l_count_071 := l_count_071 + 1;
                   l_count_040 := l_count_040 + 1;
                   l_count_020 := l_count_020 + 1;
                ELSIF Rec_Stock580.ent_040 != l_040
                THEN
   -- Si l'entite 040 est differente de l'entite 040 precedente alors
                  /* IF l_040 != '0'
                   THEN*/
           -- on l'ecrit, sinon on continue sur le prochain ELSIF ...
                      --
                      -- ... mais avant, on ecrit les entites 990 afin de boucler sur les niveaux
                      --
                       formatage_900 (   '99005'
                            || SUBSTR (l_102, 6, 9)
                            || '        '
                            || LPAD (TO_CHAR (l_count_99), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                      -- P_INS_journal(1,'ent_040'||l_buffer);
                      l_count_99 := 0;
                     formatage_900 (   '99004'
                            || SUBSTR (l_081, 6, 2)
                            || '               '
                            || LPAD (TO_CHAR (l_count_102), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                      l_count_102 := 0;
                     formatage_900 (   '99003'
                            || SUBSTR (l_071, 6, 6)
                            || '           '
                            || LPAD (TO_CHAR (l_count_081), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                      l_count_081 := 0;
                      formatage_900 (   '99002'
                            || SUBSTR (l_040, 6, 15)
                            || '  '
                            || LPAD (TO_CHAR (l_count_071), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                      l_count_071 := 0;
                 --  END IF;

                  formatage_900 (Rec_Stock580.ent_040,l_buffer,v_sortie,l_count_line);
                                              -- On ecrit l'entite 040
                   formatage_900 (Rec_Stock580.ent_071,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_081,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_102,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_103,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_199,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_294,l_buffer,v_sortie,l_count_line);
                   l_count_99 := l_count_99 + 2;
                   l_count_102 := l_count_102 + 1;
                   l_count_081 := l_count_081 + 1;
                   l_count_071 := l_count_071 + 1;
                   l_count_040 := l_count_040 + 1;
                ELSIF Rec_Stock580.ent_071 != l_071
                THEN                 -- Meme principe que precedemment
                  formatage_900 (   '99005'
                            || SUBSTR (l_102, 6, 9)
                            || '        '
                            || LPAD (TO_CHAR (l_count_99), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                   l_count_99 := 0;
                  formatage_900 (   '99004'
                            || SUBSTR (l_081, 6, 2)
                            || '               '
                            || LPAD (TO_CHAR (l_count_102), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                   l_count_102 := 0;
                  formatage_900 (   '99003'
                            || SUBSTR (l_071, 6, 6)
                            || '           '
                            || LPAD (TO_CHAR (l_count_081), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                   l_count_081 := 0;
                   formatage_900 (Rec_Stock580.ent_071,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_081,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_102,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_103,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_199,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_294,l_buffer,v_sortie,l_count_line);
                   l_count_99 := l_count_99 + 2;
                   l_count_102 := l_count_102 + 1;
                   l_count_081 := l_count_081 + 1;
                   l_count_071 := l_count_071 + 1;
                ELSIF Rec_Stock580.ent_081 != l_081
                THEN
                    formatage_900 (   '99005'
                            || SUBSTR (l_102, 6, 9)
                            || '        '
                            || LPAD (TO_CHAR (l_count_99), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                   l_count_99 := 0;
                   formatage_900 (   '99004'
                            || SUBSTR (l_081, 6, 2)
                            || '               '
                            || LPAD (TO_CHAR (l_count_102), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                   l_count_102 := 0;

                   formatage_900 (Rec_Stock580.ent_081,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_102,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_103,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_199,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_294,l_buffer,v_sortie,l_count_line);
                   l_count_99 := l_count_99 + 2;
                   l_count_102 := l_count_102 + 1;
                   l_count_081 := l_count_081 + 1;
                ELSIF Rec_Stock580.ent_102 != l_102
                THEN
                    formatage_900 (   '99005'
                            || SUBSTR (l_102, 6, 9)
                            || '        '
                            || LPAD (TO_CHAR (l_count_99), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
                   l_count_99 := 0;
                   formatage_900 (Rec_Stock580.ent_102,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_103,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_199,l_buffer,v_sortie,l_count_line);
                   formatage_900 (Rec_Stock580.ent_294,l_buffer,v_sortie,l_count_line);
                   l_count_99 := l_count_99 + 2;
                   l_count_102 := l_count_102 + 1;
                ELSIF Rec_Stock580.ent_294 != l_294
                THEN
                   formatage_900 (Rec_Stock580.ent_294,l_buffer,v_sortie,l_count_line);
                   l_count_99 := l_count_99 + 1;
                END IF;

                l_020 := Rec_Stock580.ent_020;
                l_040 := Rec_Stock580.ent_040;
                l_071 := Rec_Stock580.ent_071;
                l_081 := Rec_Stock580.ent_081;
                l_102 := Rec_Stock580.ent_102;
                l_103 := Rec_Stock580.ent_103; -- FNI
                l_199 := Rec_Stock580.ent_199;
                l_294 := Rec_Stock580.ent_294;
             END LOOP;

             --
             -- On purge cette table car les infos ont ete ecrites dans le fichier
             --
             DELETE      stock_entite_norm_580;

             --
             -- On ecrit les derniers 990 pour clore le fichier logique
             --
             formatage_900 (   '99005'
                            || SUBSTR (l_102, 6, 9)
                            || '        '
                            || LPAD (TO_CHAR (l_count_99), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
             l_count_99 := 0;
             formatage_900 (   '99004'
                            || SUBSTR (l_081, 6, 2)
                            || '               '
                            || LPAD (TO_CHAR (l_count_102), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
             l_count_102 := 0;
             formatage_900 (   '99003'
                            || SUBSTR (l_071, 6, 6)
                            || '           '
                            || LPAD (TO_CHAR (l_count_081), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
             l_count_081 := 0;
             formatage_900 (   '99002'
                            || SUBSTR (l_040, 6, 15)
                            || '  '
                            || LPAD (TO_CHAR (l_count_071), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
             l_count_071 := 0;
             formatage_900 (   '99001'
                            || SUBSTR (l_020, 6, 15)
                            || '  '
                            || LPAD (TO_CHAR (l_count_040), 8, '0')
                            || '00000000000P@',l_buffer,v_sortie,l_count_line
                           );
             l_count_040 := 0;


             --
             IF l_buffer IS NOT NULL
             THEN
                UTL_FILE.put_line (v_sortie,
                                      LPAD (TO_CHAR (LENGTH (l_buffer)),
                                            4,
                                            '0'
                                           )
                                   || l_buffer
                                  );
                l_count_line := l_count_line + 1;
                l_buffer := NULL;
             END IF;

             l_count_line := l_count_line + 1;
    --
    -- On ecrit le 999 rejet final
    --
            P_INS_journal(3,'=> ecriture T999');
             UTL_FILE.put_line (v_sortie,
                                   '0128999OC'
                                || LPAD (LTRIM (SUBSTR (Rec_stock.entite, 28, 14 )),14, '0')--emetteur
                                || RPAD(' ',6,' ')
                                || 'CS'
                                || LPAD (LTRIM (SUBSTR (Rec_stock.entite, 6,14 )),14, '0')--destinaire
                                || RPAD(' ',6,' ')
                                || 'TR'
                                || RPAD('nuremi',6,' ')
                                || LPAD (TO_CHAR (l_count_line),
                                         8,
                                         '0'
                                        )
                                || SUBSTR (Rec_stock.entite, 64, 19)
                                || LPAD (TO_CHAR (l_count_020), 3,
                                         '0')
                                || '00000000000'
                                || SUBSTR (Rec_stock.entite, 97, 32)
                               );
             l_total_line := l_total_line + l_count_line;
             l_count_line := 0;
             l_count_020 := 0;
            -- exit;
          --
          -- On reformate chaque entite norme 687 en norme 900
          --

          --TODO en fonction de la DRE avant il n'y avait pas tous les @
          ELSIF Rec_stock.cod_entite = 'T1' THEN
             P_INS_journal(3,'=> ecriture T1');
             l_020 := '02001' || '000000000000000'|| '@';
             l_102 := substr('10205' || RPAD(' ',9,' ')|| RPAD(' ',6,' ') || RPAD(' ',3,' ')|| LPAD('0',6,'0') || RPAD('X',1,' ') || LPAD('0',6,'0')|| '   ',0,39)||'@';
             l_102 := substr(l_102,0,20)|| RPAD(substr(Rec_stock.entite,20,3),3,' ') || substr(l_102,24);-- T1-5
             l_102 := substr(l_102,0,23)|| LPAD(substr(Rec_stock.entite,72,6),6,'0') || substr(l_102,30);-- T1-11
          ELSIF Rec_stock.cod_entite = 'T2' THEN
            P_INS_journal(3,'=> ecriture T2');
            l_040 := '04002' || LPAD(substr(Rec_stock.entite,2,9),15,'0') || '@';  --T2CP2 suivi_fact_tpe.codadeli
            l_071 := '07103' || TO_CHAR (SYSDATE, 'DDMMYY')||RPAD(' ',32,' ')||RPAD(' ',32,' ')||RPAD(' ',10,' ') || '@'; -- vérifier dans 900
            l_081 := '08104' || '01'||'              '|| '@'; --A analyse 01 ou 02 facture papier ou non
            IF loc_norme NOT IN ('CP','ES') THEN
              l_102 := substr(l_102,0,5)|| RPAD(substr(Rec_stock.entite,27,9),9,' ') || substr(l_102,15);-- T2-6
              l_102 := substr(l_102,0,30)|| RPAD(substr(Rec_stock.entite,44,2)||substr(Rec_stock.entite,42,2)||substr(Rec_stock.entite,40,2),6,' ') || substr(l_102,37);-- T2-11 format DDMMYY (DRE YYMMDD)
            END IF;
            l_199 := '19999' || LPAD('0',8,'0') ||'R00000000P' || LPAD('0',10,'0') || RPAD(' ',15,' ') || '@';     -- T5cp-14 + T5cp-15 ou T5-13
            l_103 := '10399' ||  RPAD(' ',13,' ') || LPAD('0',2,'0') || RPAD(' ',25,' ') || RPAD(' ',25,' ')
            || RPAD(' ',15,' ')  || LPAD(' ',13,' ')  || LPAD('0',2,'0')  || RPAD('0',6,'0')  || LPAD('0',1,'0') || RPAD(' ',25,' ')  || RPAD(' ',15,' ')
            ||'0000'|| '@';
            l_103 := substr(l_103,0,5)|| RPAD(substr(Rec_stock.entite,12,13),13,' ') || substr(l_103,19);-- T2CP-4 ou T2-4
            l_103 := substr(l_103,0,18)|| LPAD(substr(Rec_stock.entite,25,2),2,'0') || substr(l_103,21);-- T2CP-5   ou T2-5
            l_103 := substr(l_103,0,100)|| RPAD(substr(Rec_stock.entite,96,6),6,' ') || substr(l_103,107);-- T2CP-23 ou T2-27
            l_103 := substr(l_103,0,106)|| LPAD(substr(Rec_stock.entite,102,1),1,'0') || substr(l_103,108);-- T2CP-24  ou T2-28
            l_199 := substr(l_199,0,23) || LPAD(substr(Rec_stock.entite,119,10),10,'0') || substr(l_199,34);-- T2CP-29  ou T2-34
          ELSIF Rec_stock.cod_entite = 'T2S' THEN
          -- P_INS_journal(1,'=> ecriture T2S');
            IF loc_norme in ('CP','ES') THEN --projet ROC
              l_102 := substr(l_102,0,5)|| RPAD(substr(Rec_stock.entite,30,9),9,' ') || substr(l_102,15);-- T2CP-7
              l_102 := substr(l_102,0,14)|| RPAD(substr(Rec_stock.entite,42,6),6,' ') || substr(l_102,21);-- T2S-10
            END IF;
            l_103 := substr(l_103,0,85)|| RPAD(substr(Rec_stock.entite,50,13),13,' ') || substr(l_103,99);-- T2S-12  ou TS2-9 (hors CP et ES)
            l_103 := substr(l_103,0,98)|| LPAD(substr(Rec_stock.entite,63,2),2,'0') || substr(l_103,101);-- T2S-13   ou TS2-10 (hors CP et ES)

          ELSIF Rec_stock.cod_entite = 'T2P' THEN
            --P_INS_journal(1,'=> ecriture T2P');
            IF loc_norme in ('CP','ES') THEN
              l_102 := substr(l_102,0,30)|| RPAD(substr(Rec_stock.entite,103,6),6,' ') || substr(l_102,37);-- T2PCP-16 ou 17
              l_199 := substr(l_199,0,33) || RPAD(substr(Rec_stock.entite,114,8),8,' ') || substr(l_199,42);-- T2PCP-19
            END IF;
          ELSIF Rec_stock.cod_entite IN ( 'T3','T4') THEN
             -- P_INS_journal(1,'=> ecriture T3T4');
             DECLARE
                l_numano    sinistre_ano.numano%TYPE;
                l_codapli   libelle.codapli%TYPE;
                l_libelle   libelle.libelle%TYPE;
             BEGIN
                --
                -- On recupere la donnee de l'anomalie qui a cause le rejet de la facture
                --
                SELECT MIN (numano)
                  INTO l_numano
                  FROM sinistre_ano
                 WHERE numsin = Rec_stock.numsin
                   AND numremise = Rec_Remise_Import.numremise_import;
                    P_INS_journal(3,'=====> ecriture l_numano'||l_numano);

                IF l_numano IS NOT NULL
                THEN
                   BEGIN
                      SELECT codapli
                        INTO l_codapli
                        FROM libelle
                       WHERE code = l_numano AND mnemo = 'SNTRANO';

                      IF l_codapli IS NULL
                      THEN
                         l_codapli := 0;
                      END IF;

                      SELECT libelle
                        INTO l_libelle
                        FROM libelle
                       WHERE code = TO_NUMBER (l_codapli)
                         AND mnemo = 'TPE_REJETS';
                   EXCEPTION
                      WHEN NO_DATA_FOUND
                      THEN
                         l_libelle := 'CODE TPE INCONNU';
                   END;

                   --
                   -- ins_stock_entite_norm_580
                   --
                   INSERT INTO stock_entite_norm_580
                               (numremise,ent_020, ent_040,
                                ent_071, ent_081, ent_102,
                                ent_103, ent_199,
                                ent_294
                               )
                        VALUES (Rec_Remise_Import.numremise_import, l_020, l_040,
                                l_071, l_081, l_102,
                                l_103, l_199,
                                   '29499AAA'
                                || LPAD (l_codapli, 6, '0') || 'R'
                                || RPAD (l_libelle, 80,' ')
                                || 'FC'|| RPAD (' ', 11,' ')|| LPAD(' ',14,'0')|| RPAD (' ', 30,' ')
                                || '@'
                               );
                END IF;
             END;

          ELSIF Rec_stock.cod_entite = 'T5' THEN
           P_INS_journal(3,'=> ecriture T5');
           IF loc_norme in ('CP','ES') THEN
             v_mut_mon := TO_NUMBER(substr(Rec_stock.entite,82,8)) + TO_NUMBER(substr(Rec_stock.entite,90,8));
           ELSE
             v_mut_mon := TO_NUMBER(substr(Rec_stock.entite,82,8));
           END IF;
           -- P_INS_journal(1,'=> 199 :'||substr(l_199,0,5) || LPAD(TO_CHAR(v_mut_mon),8,'0') || substr(l_199,14));
           l_199 := substr(l_199,0,5) || LPAD(TO_CHAR(v_mut_mon),8,'0') || substr(l_199,14);-- T5cp-14 + T5cp-15
           P_INS_journal(3,'=> 199_2 :'||l_199);

          UPDATE stock_entite_norm_580 SET ent_199 = l_199
          WHERE ent_102 = l_102
          and ent_103 = l_103
          and ent_081 = l_081
          and ent_071 = l_071;

          END IF;
       END IF;

    END LOOP;
  END LOOP;

  --
  -- Mise à jour de la date de transmission
  UPDATE remise_externe
    SET date_trans = TRUNC (SYSDATE)
  WHERE numremise = i_remise_exp;

  --
  /*  g_msg_adm :=
       'Fichier rejets '
    || i_session
    || ' crÚe ('
    || TO_CHAR (l_total_line)
    || ' lignes)';
  p_ins_journal;*/
  IF UTL_FILE.is_open (v_sortie)
  THEN
    UTL_FILE.fclose (v_sortie);
  END IF;


EXCEPTION
  WHEN UTL_FILE.internal_error THEN
     o_found := 1;
      P_INS_journal(1,'UTL_FILE.INTERNAL_ERROR');
     UTL_FILE.fclose (v_sortie);
  WHEN UTL_FILE.invalid_filehandle THEN
     o_found := 1;
      P_INS_journal(1,'UTL_FILE.INVALID_FILEHANDLE');
     UTL_FILE.fclose (v_sortie);
  WHEN UTL_FILE.invalid_mode THEN
     o_found := 1;
      P_INS_journal(1,'UTL_FILE.INVALID_MODE');
     UTL_FILE.fclose (v_sortie);
  WHEN UTL_FILE.invalid_operation THEN
     o_found := 1;
      P_INS_journal(1,'UTL_FILE.INVALID_OPERATION');
     UTL_FILE.fclose (v_sortie);
  WHEN UTL_FILE.invalid_path THEN
     o_found := 1;
      P_INS_journal(1,'UTL_FILE.INVALID_PATH');
     UTL_FILE.fclose (v_sortie);
  WHEN UTL_FILE.read_error THEN
     o_found := 1;
      P_INS_journal(1,'UTL_FILE.READ_ERROR');
     UTL_FILE.fclose (v_sortie);
  WHEN UTL_FILE.write_error THEN
     o_found := 1;
      P_INS_journal(1,'UTL_FILE.WRITE_ERROR');
     UTL_FILE.fclose (v_sortie);
  WHEN VALUE_ERROR THEN
     o_found := 1;
      P_INS_journal(1,'UTL_FILE.VALUE_ERROR');
     UTL_FILE.fclose (v_sortie);
  WHEN EXC_repertoire_vide THEN
    o_found := 1;
     P_INS_journal(1,'Nom de(s) répertoire(s) de sortie manquant');

  WHEN OTHERS THEN
    o_found := 1;
     P_INS_journal(1,'Others:' || SQLERRM);
    IF UTL_FILE.is_open (v_sortie)
     THEN
        UTL_FILE.fclose (v_sortie);
     END IF;


END P_EXPORT_REJ;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  formatage_900                                        */
/* Type         :  Public                                                    */
/* Description  :  Formater l'écriture des rejet en norme 580         */
/*                 Récupérée du projet TPE (PK_TPE_687)                      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE formatage_900 (i_buffer_in IN VARCHAR2 ,io_bufferfic IN OUT VARCHAR2, io_sortie   IN OUT   UTL_FILE.file_type, io_count_line IN OUT  PLS_INTEGER)
/*
 Projet : Tiers payant etendu TPE
 Permet d'ecrire dans le fichier de rejet
 18/08/2005  W.ROUVRAY
*/
IS

  l_buffer_1019         VARCHAR2 (32767);
  --l_buffer              VARCHAR2 (32767);
  l_longueur_chaine     PLS_INTEGER;

 -- l_count_line          PLS_INTEGER;


BEGIN
 l_buffer_1019 := io_bufferfic;
 io_bufferfic := io_bufferfic || i_buffer_in;
 l_longueur_chaine := LENGTH (io_bufferfic);


  -- Version Oracle7.3.4 fournit un package UTL_FILE qui met 1023 caracteres maximum sur 1 ligne
 -- Ctt 07/11/2007 Mail  06/11/07 VÚronique MassÚ sur erreur retour fichier factures acceptÚes
 IF l_longueur_chaine = 1019
 THEN
    --UTL_FILE.PUT_LINE ( v_sortie, '1023'||l_buffer );
    UTL_FILE.put_line (io_sortie,
                          LPAD (TO_CHAR (LENGTH (io_bufferfic)), 4, '0')
                       || io_bufferfic
                      );
    io_count_line := io_count_line + 1;
    io_bufferfic := NULL;
 ELSIF l_longueur_chaine > 1019
 THEN
    UTL_FILE.put_line (io_sortie,
                          LPAD (TO_CHAR (LENGTH (l_buffer_1019)),
                                4,
                                '0'
                               )
                       || l_buffer_1019
                      );
    io_count_line := io_count_line + 1;
    io_bufferfic := i_buffer_in;
 END IF;
END formatage_900;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ANNUL_CONST_BORD                                        */
/* Type         :  Public                                                    */
/* Description  :  Annuler les bordereaux d'acceptation et de rejet          */
/*                 Récupérée du projet TPE (PK_TPE_687)                      */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_ANNUL_CONST_BORD (
      i_numremise    IN   remise_externe.numremise%TYPE,
      i_nature_exp   IN   remise_externe.nature%TYPE,
      i_session      IN   NUMBER DEFAULT 1,
      i_niv_msg      IN   NUMBER DEFAULT 1
   )
/*
   Projet : Tiers payant etendu TPE
   Permet d'annuler les bordereaux d'acceptation et de rejet
   20/09/2005  W.ROUVRAY
   07/12/2005  CTT : Annulation ciblÚe sur la nature de la remise : acceptation (4) ou rejet (5)
   21/06/2006 CTT :  L'Útat 20 est un Útat ÚphÚmÞre, l'Útat normal d'une facture potentiellement
              acceptÚe est 10 (fiche : 425).
*/
IS
BEGIN


      g_msg_adm :=
         'Début du traitement le ' || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi');
      P_INS_journal(1,'P_ANNUL_CONST_BORD',g_msg_adm);

      --
      IF i_nature_exp = '4'
      THEN
         UPDATE sinistre_porte s
            SET s.codevefac = 10
          WHERE EXISTS (
                   SELECT NULL
                     FROM suivi_fact_tpe
                    WHERE numremise_import = s.numremise
                      AND idfactpe = s.idfactpe
                      AND numremise_export = i_numremise)
            AND s.codevefac = 40;

         --
         g_msg_adm :=
               'Bordereau exportation '
            || TO_CHAR (i_numremise)
            || ' annulé pour  '
            || TO_CHAR (SQL%ROWCOUNT)
            || ' factures acceptÚes ';
         P_INS_journal(1,'P_ANNUL_CONST_BORD',g_msg_adm);
      --
      ELSIF i_nature_exp = '5'
      THEN
         UPDATE sinistre_porte s
            SET s.codevefac = 30
          WHERE EXISTS (
                   SELECT NULL
                     FROM suivi_fact_tpe
                    WHERE numremise_import = s.numremise
                      AND idfactpe = s.idfactpe
                      AND numremise_export = i_numremise)
            AND s.codevefac = 35;

         --
         g_msg_adm :=
               'Bordereau exportation '
            || TO_CHAR (i_numremise)
            || ' annulé pour  '
            || TO_CHAR (SQL%ROWCOUNT)
            || ' factures rejetées ';
         P_INS_journal(1,'P_ANNUL_CONST_BORD',g_msg_adm);
      --
      ELSE
         --
         g_msg_adm :=
               'Nature de bordereau export '
            || i_nature_exp
            || ' incompatible avec le traitement';
         P_INS_journal(1,'P_ANNUL_CONST_BORD',g_msg_adm);
      --
      END IF;

      --
      IF i_nature_exp = '4' OR i_nature_exp = '5'
      THEN
         DELETE      suivi_fact_tpe
               WHERE numremise_export = i_numremise;

         --
         DELETE      remise_externe
               WHERE numremise = i_numremise;
      END IF;

      --
      g_msg_adm :=
            'Fin du traitement le ' || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi');
      P_INS_journal(1,'P_ANNUL_CONST_BORD',g_msg_adm);
   --COMMIT;
END P_ANNUL_CONST_BORD;

/*-----------------------------------------------------------------------------------------*/
/* FUNCTION                                                                                */
/* Nom          :  P_DEBLOCAGE_ASSURE                                                      */
/* Type         :  Public                                                                  */
/* Paramètres   :  Numremise, numporte                                                     */
/* Description  :  permet de debloquer les sinistres (AVP) bloqués de la remise en se basant
                   sur les infos de la facture reçue précedemment qui ne sont autres que les
                   infos corrigées par le gestionnaire lors de l'intégration précedente des
                   fichiers factures, ainsi on évite au gestionnaire de les ressaisir à chaque
                   import des fichiers d'avis de paiement (AVP)                             */
/*------------------------------------------------------------------------------------------*/

PROCEDURE P_DEBLOCAGE_ASSURE(i_numremise    IN   remise_externe.numremise%TYPE, i_porte IN   remise_externe.numremise%TYPE)
IS
--les sinistres ano de la remise
cursor c_sin_ano IS
  select sp.numsin, sp.idfactpe, sa.numano
  from sinistre_porte sp, sinistre_ano sa
  where sp.numsin = sa.numsin
  and sp.numremise = sa.numremise
  and sa.numano in (40,41,46,71)
  and sp.numremise = i_numremise
  AND sa.numporte = i_porte
  ;
--recherche les numindiv et numassu du sinistre_porte de la facture (remise.nature =2) et idfactpe identique, le gestionnaire ayant deja saisi ces infos sur l'import des factures
CURSOR c_indiv(p_numsin IN NUMBER, p_idfactpe IN NUMBER ) IS
  select sp.numindiv, sp.numassu, sp.numremise,sp.numsin from sinistre_porte sp, porte_remise pr --, suivi_fact_tpe tpe
  where pr.numremise = sp.numremise
  AND pr.numporte = sp.numporte
  and pr.nature = 2 --facture
  and sp.idfactpe = p_idfactpe --ayant idfactpe identique au idfactpe de la remise importée
  ;
BEGIN
  P_INS_journal(3,'Debut P_DEBLOCAGE_ASSURE ' || i_porte || '-' || i_numremise);
  FOR rec_sin_ano IN c_sin_ano LOOP
    FOR rec_indiv IN c_indiv (rec_sin_ano.numsin, rec_sin_ano.idfactpe) LOOP
    --mettre à jour les sinistres avec les infos (assuré et indiv concerné) retrouvés provenant d'autres remises de type facture (avec le meme idfactpe) pour éviter au gestionnaire de resaisir ces infos pour les avis de paiements
      update sinistre_porte set numindiv = rec_indiv.numindiv, numassu = rec_indiv.numassu
      where numremise = i_numremise
      and numporte = i_porte
      and idfactpe = rec_sin_ano.idfactpe
      and numsin = rec_sin_ano.numsin
      ;
      P_INS_journal(3,'P_DEBLOCAGE_ASSURE - nb sinistre_porte modifiés=' || sql%rowcount );

      --enregistrement du forcage
      INSERT INTO sinistre_porte_forcage ( numremise, numsin,numordre,numzone,datfrcg, numutil,valeur)
      SELECT i_numremise,rec_sin_ano.numsin,nvl(max(numordre),0)+1,f_column_id('sinistre_porte', 'numindiv'),trunc(sysdate),f_numutil, rec_indiv.numindiv
      FROM sinistre_porte_forcage
      ;
      P_INS_journal(3,'P_DEBLOCAGE_ASSURE - nb sinistre_porte_forcage inseré=' || sql%rowcount );
    END LOOP;
    --suppression de l'anomalie debloquée
    delete sinistre_ano where numremise=i_numremise and numsin=rec_sin_ano.numsin and numano=rec_sin_ano.numano;
    P_INS_journal(3,'P_DEBLOCAGE_ASSURE - nb sinistre_ano supprimés=' || sql%rowcount );
  END LOOP;
  P_INS_journal(3,'Fin P_DEBLOCAGE_ASSURE ' || i_porte || '-' || i_numremise);
EXCEPTION
  WHEN OTHERS THEN
  P_INS_journal(3,'P_DEBLOCAGE_ASSURE' || 'Anomalie de deblocage sur la remise ' ||i_numremise || SQLERRM);
END;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_CTRL_NUMBER                                             */
/* Type         :  Public                                                    */
/* Description  :  Function qui verifie si chaine est un nombre              */
/*                    retourne -1 si erreur                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_CTRL_NUMBER(
    i_chaine IN VARCHAR2,
    i_debut  IN NUMBER,
    i_longueur IN NUMBER,
    i_ligne IN NUMBER,
    i_nom   IN VARCHAR2,
    o_erreur IN OUT BOOLEAN,
    i_format IN VARCHAR2 default 'N',
    i_entier IN NUMBER default null,
    i_decimale IN NUMBER default null
) RETURN NUMBER
IS
 v_test   VARCHAR2(50);
 v_chaine VARCHAR2(50);
BEGIN
     v_chaine := RTRIM(SUBSTR(i_chaine,i_debut,i_longueur));
     P_INS_journal(3,'ligne:' || i_ligne || ' v_chaine ' ||  i_nom || ' : ' || v_chaine);
     IF RTRIM(v_chaine) is not null THEN
         BEGIN
            SELECT translate(v_chaine, '.1234567890','.') INTO v_test FROM DUAL;
         EXCEPTION
            When NO_DATA_FOUND THEN
               v_test := null;
         END;
         IF v_test is not null THEN
            P_INS_journal(1,'Err ligne:' || i_ligne || ' type numerique chaine ' || i_nom || '(' || i_debut || ','|| i_longueur || '):' || v_chaine);
            o_erreur := TRUE;
            RETURN null;
         ELSE
             IF i_format = 'O' THEN
                RETURN F_FORMAT_NUMBER(v_chaine,i_entier,i_decimale);
             ELSE
                RETURN TO_NUMBER(v_chaine);
             END IF;

         END IF;
     ELSE
        RETURN NULL;
     END IF;
EXCEPTION
    WHEN OTHERS THEN
          P_INS_journal(1,'F_CTRL_NUMBER' || sqlerrm);
          RETURN null;
END F_CTRL_NUMBER;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_CTRL_NUMBER_VARCHAR                                     */
/* Type         :  Public                                                    */
/* Description  :  Function qui verifie si chaine est un nombre  et retourne */
/*                 un varchar                                                */
/*                                                                           */
/* Retour       :   ! si erreur  sinon chaine                                */
/*---------------------------------------------------------------------------*/
FUNCTION F_CTRL_NUMBER_VARCHAR(
    i_chaine IN VARCHAR2,
    i_debut  IN NUMBER,
    i_longueur IN NUMBER,
    i_ligne IN NUMBER,
    i_nom   IN VARCHAR2,
    o_erreur IN OUT BOOLEAN
) RETURN VARCHAR2
IS
 v_test   VARCHAR2(50);
 v_chaine VARCHAR2(50);
BEGIN
     v_chaine := RTRIM(SUBSTR(i_chaine,i_debut,i_longueur));
     P_INS_journal(3,'ligne:' || i_ligne || ' v_chaine ' ||  i_nom || ' : ' || v_chaine);
     IF RTRIM(v_chaine) is not null THEN
         BEGIN
            SELECT translate(v_chaine, '.1234567890','.') INTO v_test FROM DUAL;
         EXCEPTION
            When NO_DATA_FOUND THEN
               v_test := null;
         END;
         IF v_test is not null THEN
            P_INS_journal(1,'Err ligne:' || i_ligne || ' type numerique chaine ' || i_nom || '(' || i_debut || ','|| i_longueur || '):' || v_chaine);
            o_erreur := TRUE;
            RETURN null;
         ELSE
            RETURN v_chaine;
         END IF;
     ELSE
        RETURN NULL;
     END IF;
EXCEPTION
    WHEN OTHERS THEN
          P_INS_journal(1,'F_CTRL_NUMBER_VARCHAR' || sqlerrm);
          RETURN null;
END F_CTRL_NUMBER_VARCHAR;


/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_CTRL_ALPHANUMBER                                        */
/* Type         :  Public                                                    */
/* Description  :  Function qui verifie si chaine est une composé d'alphanum */
/*                 en cas d'erreur retourne '!'  sinon la chaine             */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_CTRL_ALPHANUMBER(
    i_chaine IN VARCHAR2,
    i_debut  IN NUMBER,
    i_longueur IN NUMBER,
    i_ligne IN NUMBER,
    i_nom   IN VARCHAR2,
    o_erreur IN OUT BOOLEAN
) RETURN VARCHAR2
IS
 v_test   VARCHAR2(50);
 v_chaine VARCHAR2(50);
BEGIN
    v_chaine := SUBSTR(i_chaine,i_debut,i_longueur);
    P_INS_journal(3,'ligne:' || i_ligne || ' v_chaine ' ||  i_nom || ' : ' || v_chaine);
    IF RTRIM(v_chaine) is not null THEN
        BEGIN
             --attention a l'espace enter le 0 et la cote ' pour gerer les cas de chaine 'AMI N'
          SELECT translate(v_chaine, '.ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 ','.') INTO v_test FROM DUAL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
                 v_test := NULL;
        END;
        IF v_test IS NOT NULL THEN
          P_INS_journal(1,'Erreur ligne:' || i_ligne || ' type alphanum chaine : ' || i_nom || '(' || i_debut || ','|| i_longueur || '):' || v_chaine);
          o_erreur := TRUE;
          RETURN NULL;
        ELSE
          --P_INS_journal(3,'v_chaine');
          RETURN v_chaine;
        END IF;
    ELSE
      P_INS_journal(3,'retour NULL');
      RETURN NULL;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
          P_INS_journal(1,'F_CTRL_ALPHANUMBER' || sqlerrm);
          RETURN null;
END F_CTRL_ALPHANUMBER;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FORMAT_NUMBER                                           */
/* Type         :  Public                                                    */
/* Description  :  format une chaine en number                               */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FORMAT_NUMBER(
         i_chaine IN VARCHAR2,
         i_entier IN NUMBER,
         i_decimale IN NUMBER
) RETURN NUMBER
IS
  v_number NUMBER;
  v_tampon_ent VARCHAR2(30);
  v_tampon_dec VARCHAR2(30);
BEGIN
      IF i_chaine is not null THEN
        v_tampon_ent := SUBSTR(i_chaine,1,i_entier);
        IF i_decimale = 0 THEN
            v_number := TO_NUMBER(v_tampon_ent);
        ELSE
            v_tampon_dec := SUBSTR(i_chaine,i_entier+1,i_decimale);
            v_number := TO_NUMBER(v_tampon_ent ||'.' || v_tampon_dec);
        END IF;
        RETURN v_number;
      ELSE
        RETURN null;
      END IF;

EXCEPTION
    WHEN OTHERS THEN
          P_INS_journal(3,'F_FORMAT_NUMBER;' || sqlerrm);
          RETURN null;
END F_FORMAT_NUMBER;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FORMAT_NUMBER                                           */
/* Type         :  Public                                                    */
/* Description  :  format une chaine en DATE                                 */
/*                   en entrée une chaine de format AAMMJJ ou AAMMJJHH       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_CTRL_FORMAT_DATE(
         i_chaine IN VARCHAR2,
         i_debut  IN NUMBER,
         i_longueur IN NUMBER,
         i_ligne IN NUMBER,
         i_nom   IN VARCHAR2,
         o_erreur IN OUT BOOLEAN
) RETURN DATE
IS
  v_test   VARCHAR2(1);
  v_chaine VARCHAR2(8);
  v_longueur NUMBER;
BEGIN
     v_chaine := SUBSTR(i_chaine,i_debut,i_longueur);
     P_INS_journal(3,'ligne:' || i_ligne || ' v_chaine : ' || v_chaine);
     BEGIN
        SELECT * INTO v_test FROM DUAL WHERE REGEXP_LIKE (v_chaine,'^[0-9]');
     EXCEPTION
        When NO_DATA_FOUND THEN
           v_test := null;
     END;
     IF v_test is null THEN
      P_INS_journal(1,'Erreur ligne:' || i_ligne || ' type DATE chaine : ' || i_nom || '(' || i_debut || ','|| i_longueur || '):' || v_chaine);
      o_erreur := TRUE;
      RETURN null;
     ELSE
         IF i_longueur = 6 THEN
           RETURN TO_DATE(v_chaine,'YYMMDD');
         ELSE
           RETURN TO_DATE(v_chaine,'YYMMDDHH24');
         END IF;
     END IF;

EXCEPTION
    WHEN OTHERS THEN
          P_INS_journal(3,'F_CTRL_FORMAT_DATE;' || sqlerrm);
          RETURN NULL;
END F_CTRL_FORMAT_DATE;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_FORMAT_DATENAIS                                         */
/* Type         :  Public                                                    */
/* Description  :  format une chaine AAMMJJ en chaine JJMMAA                 */
/*                   en entrée une chaine de format AAMMJJ                   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
FUNCTION F_FORMAT_DATENAIS(
         i_chaine IN VARCHAR2
) RETURN VARCHAR2
IS
 v_chaine VARCHAR2(6);
BEGIN
  IF i_chaine is not null THEN
   v_chaine :=  SUBSTR(i_chaine,5,2) || SUBSTR(i_chaine,3,2) || SUBSTR(i_chaine,1,2);
  END IF;
  RETURN v_chaine;
EXCEPTION
    WHEN OTHERS THEN
          P_INS_journal(3,'F_FORMAT_DATENAIS;' || sqlerrm);
          RETURN NULL;
END F_FORMAT_DATENAIS;

PROCEDURE P_INIT_PRESTATION(p_sinistre_porte IN OUT sinistre_porte%ROWTYPE, p_porte_remise IN porte_remise%ROWTYPE)IS

BEGIN
  p_sinistre_porte.numremise := p_porte_remise.numremise;
  p_sinistre_porte.numporte := p_porte_remise.numporte;
  p_sinistre_porte.username_forcage := f_numutil();
  p_sinistre_porte.dattrait := sysdate;
  p_sinistre_porte.etat := 2;
  p_sinistre_porte.numgar:= 0;
  p_sinistre_porte.numfor := 0;
  p_sinistre_porte.numbene := 0;
  p_sinistre_porte.numindiv := 0;
  p_sinistre_porte.numassu := 0;
  p_sinistre_porte.typbene := 0;
  --les montants
  p_sinistre_porte.autrb := 0;
  p_sinistre_porte.autrb_d := 0;
  p_sinistre_porte.mtrembam := 0;
  p_sinistre_porte.baseremboc := 0;
  p_sinistre_porte.mtbutoiroc := 0;
  p_sinistre_porte.totalmtremb := 0;
  /****ATTENTION ***********uniquement pour forcer la reconnaissance d'acte en attene de vrai fichier****/
  --p_sinistre_porte.regime := '01';
END P_INIT_PRESTATION;

FUNCTION F_INS_PRESTATION(p_sinistre_porte IN OUT sinistre_porte%ROWTYPE,
                           p_suivi_fact_tpe IN OUT suivi_fact_tpe%ROWTYPE,
                           i_cpt_numsin NUMBER,
                           i_cpt_lig NUMBER)
                           RETURN VARCHAR2 IS
v_ins_sinistre_porte Varchar2(200);
BEGIN

  p_sinistre_porte.idfactpe := p_suivi_fact_tpe.idfactpe;
  p_sinistre_porte.codevefac := p_suivi_fact_tpe.codevefac;
  p_sinistre_porte.numsin := i_cpt_numsin;

  ----insertion dans sinistre_porte
  RETURN PK_TPE.F_INS_SNTRPRT(p_sinistre_porte);


END;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  F_NOM_FICHIER                                             */
/* Type         :  Public                                                    */
/* Description  :  Formatage du nom de fichier                               */
/* Retour       :  i_fichier : fichier formaté                               */
/*---------------------------------------------------------------------------*/
FUNCTION F_NOM_FICHIER(
         i_fichier in VARCHAR2
         ,i_numporte in NUMBER default NULL
) RETURN VARCHAR2
IS
  v_date VARCHAR2(8);
  v_heure VARCHAR2(8);
  v_fichier VARCHAR2(200);
  v_reseau  VARCHAR2(2);
BEGIN

--
  v_date := TO_CHAR (SYSDATE, 'YYYYMMDD');
--
  SELECT REPLACE (TO_CHAR (SYSDATE, 'fmHH24:MI:SS'), ':', '-')
  INTO v_heure
  FROM DUAL;
 --Recupération du reseau en fonction de la porte projet ROC
  SELECT decode(i_numporte,2,'SP',18,'IS','tpe')
  INTO v_reseau
  FROM DUAL;

--
  v_fichier :=REPLACE (i_fichier, '#DT', v_date);  --remplacement de #DT par la date
  v_fichier := REPLACE (v_fichier, '#HR', v_heure);  --remplacement #HR par l'heure
  v_fichier := REPLACE (v_fichier,'#TPE',v_reseau);  -- remplacement #TPE par le reseau (SP, IS ou tpe)

  RETURN v_fichier;
--
EXCEPTION
    WHEN OTHERS THEN
    P_INS_journal(3,'F_NOM_FICHIER;' || sqlerrm);
    RETURN null;
--
END F_NOM_FICHIER;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  F_CHERCHE_ORDRE                                           */
/* Type         :  Public                                                    */
/* Description  :  Permet de recuperer l'ordre de la prochaine entite 990    */
/* Retour       :  v_ordre                                                   */
/*---------------------------------------------------------------------------*/
FUNCTION F_CHERCHE_ORDRE (
   i_ordre_in       IN   stock_entite.ordre%TYPE,
   i_niv_in         IN   VARCHAR2,
   i_numremise_in   IN   stock_entite.numremise%TYPE
) RETURN stock_entite.ordre%TYPE
IS
v_ordre  stock_entite.ordre%TYPE;
BEGIN
   SELECT MIN (ordre)
     INTO v_ordre
     FROM stock_entite
   WHERE  ordre > i_ordre_in
      AND SUBSTR (entite, 4, 2) = i_niv_in
      AND cod_entite = '990'
      AND numremise = i_numremise_in;

    RETURN v_ordre;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'F_CHERCHE_ORDRE','Others:' || SQLERRM);
    RETURN null;
END F_CHERCHE_ORDRE;

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

END PK_SP_FACT;
/
