CREATE OR REPLACE PACKAGE ARTHUS.PK_TRANSFERT
AS
  /*============================================================================*/
  /* PACKAGE      : PK_TRANSFERT.sql                                            */
  /* Domaine      : Production                                                  */
  /* Version      : V1.0                                                        */
  /* Auteur       : ???                                                         */
  /* Création     : ???                                                         */
  /* Description  : Package de transfert d adhesions de contrat à contrat       */
  /*============================================================================*/
  /* Evolution    : Résilier toutes les adhésions d’un contrat donné(P201210001)*/
  /* Auteur       : JBO                                                         */
  /* Date         : 26/11/2012                                                  */
  /* Commentaire  : Création de la nouvelle procédure p_resil_massive_adhe      */
  /* Evolution    : Gestion des adhésions collectives pour résiliation massive  */
  /* Auteur       : PHA                                                         */
  /* Date         : 26/08/2014                                                  */
  /* Commentaire  :                                                             */
  /*============================================================================*/
  /* Correction   : JBO /06/12/2013/ Ajout du public Synonyme qui était manquant*/
  /*                PHA  14/09/2016  Fermeture garanties si résiliation contrat */
  /*                => mantis 0005013                                           */
  /*                                                                            */
  /* Evolution    : ABO 10/12/2015 Transfert gestion des conditions sur variable*/
  /*                M5006 Assistance GEREP transférer sur un portefeuille limité*/
  /*                contrat non résilié et avec gestion de prestation           */
  /* Evolution    : PHA 21/12/2016 Duplication adhesion 1 contrat a un autre    */
  /*                sans résiliation                                            */
  /* Evolution/correction p_dupli_adhe PHA 07/07/2017 sur date debut new adhe   */
  /*              = reprendre la date de l'ancienne adhe si > date debut param  */
  /* Correction   : PHA20/12/2017 p_dupli_adhe: supprimer les entêtes adhésions */
  /*             créées sans membres (pb contrôle des conditions à la création) */
  /*============================================================================*/
  -- Chaine de reconnaissance SCCS
  -- %W%  %E%
  -- -- CONSTANTES PUBLIQUE -----------------------------------------------------
  -- Aucune
  -- -------------------------------------------- Fin des constantes publiques --
  -- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
  -- Aucune
  -- -------------------------------------------- Fin des exceptions publiques --
  -- -- TYPES PUBLIQUES ---------------------------------------------------------
  -- Aucun
  -- ------------------------------------------------- Fin des types publiques --
  -- -- VARIABLES PUBLIQUES -----------------------------------------------------
  -- Aucune
  -- --------------------------------------------- Fin des variables publiques --
  -- -- PROCEDURES PUBLIQUES ----------------------------------------------------
  --
  PROCEDURE p_initialise(
      a_type_cle IN NUMBER,
      a_valeur   IN VARCHAR2,
      a_type     IN NUMBER );

      FUNCTION f_condition(
      a_condition  IN VARCHAR2,
      a_valeur_cle IN NUMBER,
      a_valeur     IN NUMBER )
    RETURN NUMBER;

    PRAGMA RESTRICT_REFERENCES (f_condition, WNDS, WNPS);

    PROCEDURE p_transfert_adhe(
      a_idporte    IN NUMBER,
      a_type       IN NUMBER,
      a_old_numgar IN NUMBER,
      a_numgar     IN NUMBER,
      a_debut      IN DATE,
      a_motif      IN VARCHAR2,
      a_numedit    IN NUMBER );

      PROCEDURE p_maj_variable(
      a_idporte    IN NUMBER,
      a_old_numgar IN NUMBER,
      a_debut      IN DATE,
      a_numedit    IN NUMBER );

      PROCEDURE p_maj_variable_transcod(
      a_idporte    IN NUMBER,
      a_idvariable IN NUMBER,
      a_cle_maj    IN NUMBER,
      a_old_numgar IN NUMBER DEFAULT NULL,
      a_numgar     IN NUMBER DEFAULT NULL,
      a_numedit    IN NUMBER );

      PROCEDURE p_maj_variable_externe(
      a_entite     IN NUMBER,
      a_colonne    IN NUMBER,
      a_idvariable IN NUMBER,
      a_numedit    IN NUMBER );

      PROCEDURE p_maj_variable_valeur(
      a_idvariable IN NUMBER,
      a_valeur     IN VARCHAR2 );

      PROCEDURE p_resilie_adhe(
      a_old_numgar     IN NUMBER,
      a_old_idadhesion IN NUMBER,
      a_numadhe        IN NUMBER,
      a_motif          IN NUMBER,
      a_debut          IN DATE,
      a_numutil        IN number default null, -- MUR M0005418
      a_flag           IN number default null);   --RKO Enrich. Iris entrp pour ws rad_adhesion

      PROCEDURE p_resil_massive_adhe(
      i_numgar     IN PARAM_DMNDE.VALDEB1%TYPE ,
      i_date_resil IN DATE ,
      I_motif_A    IN PARAM_DMNDE.VALDEB3%TYPE ,
      I_motif_C    IN PARAM_DMNDE.VALDEB4%TYPE ,
      i_traitement IN JOURNAL_ADM.NOM_TRAITEMENT%TYPE ,
      i_idligne    IN JOURNAL_ADM.IDLIGNE%TYPE ,
      i_session    IN FILE_EDITION.NUMEDIT%TYPE DEFAULT 1 ,
      i_niv_msg    IN JOURNAL_ADM.NIV_MSG%TYPE DEFAULT 1 ,
      o_found OUT NUMBER) ;

      PROCEDURE p_resil_contrat_ref(
      i_numgar  IN PARAM_DMNDE.VALDEB1%TYPE,
      i_motif_C IN NUMBER,
      i_debut   IN DATE);

      PROCEDURE p_resilie_contrat(
      a_old_numgar IN NUMBER,
      a_motif      IN NUMBER,
      a_debut      IN DATE );

      PROCEDURE p_defaire_adhe(
      a_numremise IN NUMBER);

      PROCEDURE p_del_refcie_null;

  PROCEDURE p_del_var_calculee(
      a_idvariable IN NUMBER);
  loc_numgar         NUMBER;
  loc_old_numgar     NUMBER;
  loc_numfor         NUMBER;
  loc_old_numfor     NUMBER;
  loc_typassu        NUMBER;
  loc_old_typassu    NUMBER;
  loc_numindiv       NUMBER;
  loc_old_numindiv   NUMBER;
  loc_refcie         VARCHAR2 (30);
  loc_old_refcie     VARCHAR2 (30);
  loc_regime         NUMBER;
  loc_old_regime     NUMBER;
  loc_numsoc         NUMBER;
  loc_old_numsoc     NUMBER;
  loc_idvariable     NUMBER;
  loc_old_idvariable NUMBER;
  loc_age            NUMBER;
  loc_old_age        NUMBER;
  loc_montant        NUMBER;
  loc_old_montant    NUMBER;
  loc_sexe           VARCHAR2 (1);
  loc_old_sexe       VARCHAR2 (1);
  loc_nb_adhe        NUMBER;
  loc_old_nb_adhe    NUMBER;

  PROCEDURE P_annul_report(
    i_numremise    IN CONTRAT_REF.numprod%TYPE  );

  PROCEDURE P_report_param_produit(
    i_traitement   IN    TYP_BATCH.BATCHID%TYPE,
    i_numprod      IN CONTRAT_REF.numprod%TYPE,
    i_numgar_deb   IN CONTRAT_REF.numgar%TYPE,
    i_numgar_fin   IN CONTRAT_REF.numgar%TYPE,
    i_numfor_ref   IN GAR_CNTRT.numfor%TYPE,
    i_numfor_c     IN GAR_CNTRT.numfor%TYPE,
    i_dateref      IN DATE default sysdate,
    i_report       IN NUMBER default 0,
    i_session      IN    JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1,
    i_niv_msg      IN    NUMBER DEFAULT 1,
    o_found        OUT   NUMBER,
    o_erreur       OUT   VARCHAR2);

  --PROCEDURE P_dynamic_compare(i_table IN VARCHAR2,o_tabmodif OUT TAB_T_REC_modif);

  PROCEDURE P_export_report_param_produit( i_traitement   IN    TYP_BATCH.BATCHID%TYPE,
                                           i_numremise    IN    HISTO_REPORT.NUMREMISE%TYPE,
                                           i_dateref      IN    DATE,
                                           i_session      IN    NUMBER,
                                           i_niv_msg      IN    NUMBER DEFAULT 1,
                                           o_erreur       OUT   VARCHAR2);

  FUNCTION f_creationFichier( i_repertoire   IN    TYP_BATCH.REPERTOIRE%TYPE,
                              i_fichier      IN    TYP_BATCH.RESSOURCE%TYPE,
                              i_numremise    IN    HISTO_REPORT.NUMREMISE%TYPE,
                              i_dateref      IN    DATE,
                              o_erreur       OUT   VARCHAR2)
  RETURN BOOLEAN;

  PROCEDURE EcrireEntete( ih_fichier IN UTL_FILE.file_type);

  FUNCTION ecrireLigne( i_repertoire   IN    TYP_BATCH.REPERTOIRE%TYPE,
                        i_fichier      IN    TYP_BATCH.RESSOURCE%TYPE,
                        i_numremise    IN    HISTO_REPORT.NUMREMISE%TYPE,
                        i_dateref      IN    DATE)
  RETURN BOOLEAN; 

  PROCEDURE P_INS_journal(
      P_niv  IN NUMBER,
      P_msg  IN VARCHAR2,
      p_msg2 IN VARCHAR2 := NULL);



  PROCEDURE p_dupli_adhe(
    a_idporte    IN NUMBER,
    a_type       IN NUMBER,
    a_old_numgar IN NUMBER,
    a_numgar     IN NUMBER,
    a_debut      IN DATE,
    a_motif      IN VARCHAR2,
    a_numedit    IN NUMBER );

  PROCEDURE p_transfert_adhe_resil(
    a_idporte    IN NUMBER,
    a_type       IN NUMBER,
    a_old_numgar IN NUMBER,
    a_numgar     IN NUMBER,
    a_debut      IN DATE,
    a_motif      IN VARCHAR2,
    a_numedit    IN NUMBER );

  --
  --
  ----------------------------------------------------------------------------
  -- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_TRANSFERT
AS
  /*============================================================================*/
  /* PACKAGE      : PK_TRANSFERT.sql                                            */
  /* Domaine      : Production                                                  */
  /* Version      : V1.0                                                        */
  /* Auteur       : ???                                                         */
  /* Création     : ???                                                         */  
  /* Description  : Package de transfert d adhesions de contrat à contrat       */
  /*============================================================================*/
  /* Evolution    : Résilier toutes les adhésions d’un contrat donné(P201210001)*/
  /* Auteur       : JBO                                                         */
  /* Date         : 26/11/2012                                                  */
  /* Commentaire  : Création de la nouvelle procédure p_resil_massive_adhe      */
  /*============================================================================*/
  /* Correction   : JBO /06/12/2013/ Ajout du public Synonyme qui était manquant*/
  /* Evolution    : ABO 10/12/2015 Transfert gestion des conditions sur variable*/
  /*                M5006 Assistance GEREP transférer sur un portefeuille limité*/
  /*                Correctif important rang / datper/ et datper = a_debut-1    */
  /* Evolution    : ABO 18/12/2015 Report de paramétrage produit sur contrat    */
  /*============================================================================*/
  -- Chaine de reconnaissance SCCS
  -- %W%  %E%
  -- -- CONSTANTES PRIVEES ------------------------------------------------------
  -- Aucune
  -- ---------------------------------------------- Fin des constantes privees --
  -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
  -- Aucune
  -- ---------------------------------------------- Fin des exceptions privees --
  -- -- TYPES PRIVEES -----------------------------------------------------------
  -- Aucun
  -- --------------------------------------------------- Fin des types privees --
  -- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
  -- -- Déclaration des variables globales   ----------------------------------
  g_session journal_adm.id_session%TYPE DEFAULT 1;
  g_nom_traitement journal_adm.nom_traitement%TYPE:=NULL;
  g_niv_msg journal_adm.niv_msg%TYPE;
  g_idligne journal_adm.idligne%TYPE := 0;
  g_msg_adm journal_adm.msg_adm%TYPE;

  e_par_repertoire_vide       EXCEPTION;
  e_par_fichier_vide          EXCEPTION;

  -- Déclaration des variables globales
  f_sortie                    UTL_FILE.file_type;

  -- Déclaration des constantes globales
  I_DELIMITEUR               CONSTANT  VARCHAR2(1)  := ';';

  -- -------------------------------------- Fin des variables globales privees --
  -- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
FUNCTION F_FIND_DATPER_ECART(i_TYPE    IN NUMBER,  
                             i_numfor  IN GAR_CNTRT.numfor%TYPE,
                                         i_codfrais IN natfrais.codfrais%TYPE,
                             i_datapli IN DATE) 
RETURN DATE ;
FUNCTION F_FIND_DATE_ECART(i_TYPE    IN NUMBER,  
                           i_numfor  IN GAR_CNTRT.numfor%TYPE,
                           i_codfrais IN natfrais.codfrais%TYPE)
RETURN DATE ;
  -- ----------------------------- Fin des declarations des procedures privees --
  -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
PROCEDURE p_initialise(
    a_type_cle IN NUMBER,
    a_valeur   IN VARCHAR2,
    a_type     IN NUMBER )
IS
BEGIN
  IF (a_type_cle      = 1) THEN
    IF (a_type        = 1) THEN
      loc_old_numgar := a_valeur;
    ELSE
      loc_numgar := a_valeur;
    END IF;
  ELSIF (a_type_cle   = 2) THEN
    IF (a_type        = 1) THEN
      loc_old_numfor := a_valeur;
    ELSE
      loc_numfor := a_valeur;
    END IF;
  ELSIF (a_type_cle    = 3) THEN
    IF (a_type         = 1) THEN
      loc_old_typassu := a_valeur;
    ELSE
      loc_typassu := a_valeur;
    END IF;
  ELSIF (a_type_cle     = 4) THEN
    IF (a_type          = 1) THEN
      loc_old_numindiv := a_valeur;
    ELSE
      loc_numindiv := a_valeur;
    END IF;
  ELSIF (a_type_cle   = 5) THEN
    IF (a_type        = 1) THEN
      loc_old_refcie := a_valeur;
    ELSE
      loc_refcie := a_valeur;
    END IF;
  ELSIF (a_type_cle   = 6) THEN
    IF (a_type        = 1) THEN
      loc_old_regime := a_valeur;
    ELSE
      loc_regime := a_valeur;
    END IF;
  ELSIF (a_type_cle   = 7) THEN
    IF (a_type        = 1) THEN
      loc_old_numsoc := a_valeur;
    ELSE
      loc_numsoc := a_valeur;
    END IF;
  ELSIF (a_type_cle       = 8) THEN
    IF (a_type            = 1) THEN
      loc_old_idvariable := a_valeur;
    ELSE
      loc_idvariable := a_valeur;
    END IF;
  ELSIF (a_type_cle = 9) THEN
    IF (a_type      = 1) THEN
      loc_old_age  := a_valeur;
    ELSE
      loc_age := a_valeur;
    END IF;
  ELSIF (a_type_cle    = 10) THEN
    IF (a_type         = 1) THEN
      loc_old_montant := a_valeur;
    ELSE
      loc_montant := a_valeur;
    END IF;
  ELSIF (a_type_cle = 11) THEN
    IF (a_type      = 1) THEN
      loc_old_sexe := a_valeur;
    ELSE
      loc_sexe := a_valeur;
    END IF;
  ELSIF (a_type_cle    = 12) THEN
    IF (a_type         = 1) THEN
      loc_old_nb_adhe := a_valeur;
    ELSE
      loc_nb_adhe := a_valeur;
    END IF;
  END IF;
END p_initialise;
FUNCTION f_condition(
    a_condition  IN VARCHAR2,
    a_valeur_cle IN NUMBER,
    a_valeur     IN NUMBER )
  RETURN NUMBER
IS
  loc_resultat NUMBER := 1;
BEGIN
  IF (a_condition   = '<') THEN
    IF (a_valeur    < a_valeur_cle) THEN
      loc_resultat := 0;
    ELSE
      loc_resultat := 1;
    END IF;
  ELSIF (a_condition = '>') THEN
    IF (a_valeur     > a_valeur_cle) THEN
      loc_resultat  := 0;
    ELSE
      loc_resultat := 1;
    END IF;
  ELSIF (a_condition = '<>') THEN
    IF (a_valeur    != a_valeur_cle) THEN
      loc_resultat  := 0;
    ELSE
      loc_resultat := 1;
    END IF;
  ELSIF (a_condition = '=') THEN
    IF (a_valeur     = a_valeur_cle) THEN
      loc_resultat  := 0;
    ELSE
      loc_resultat := 1;
    END IF;
  ELSIF (a_condition = '@') THEN
    IF (a_valeur     IS NOT NULL) THEN
      loc_resultat  := 0;
    ELSE
      loc_resultat := 1;
    END IF;  
  ELSIF (a_condition = '#') THEN
    IF (a_valeur     = a_valeur_cle) THEN
      loc_resultat  := 0;
    ELSE
      loc_resultat := 1;
    END IF;
  END IF;
  RETURN (loc_resultat);
END f_condition;


PROCEDURE p_transfert_adhe(
    a_idporte    IN NUMBER,
    a_type       IN NUMBER,
    a_old_numgar IN NUMBER,
    a_numgar     IN NUMBER,
    a_debut      IN DATE,
    a_motif      IN VARCHAR2,
    a_numedit    IN NUMBER )
IS
  CURSOR fetch_param_transcod
  IS
    SELECT param_transcod.idporte,
      param_transcod.cle1,
      param_transcod.type_cle1,
      param_transcod.cle2,
      param_transcod.type_cle2,
      param_transcod.cle3,
      param_transcod.type_cle3,
      param_transcod.cle1_interne,
      param_transcod.type_cle1_interne,
      param_transcod.cle2_interne,
      param_transcod.type_cle2_interne,
      param_transcod.condition
    FROM param_transcod
    WHERE param_transcod.idporte             = a_idporte
    AND ( ( param_transcod.type_cle1         = 1
    AND param_transcod.cle1                  = a_old_numgar )
    OR ( param_transcod.type_cle2            = 1
    AND param_transcod.cle2                  = a_old_numgar )
    OR ( param_transcod.type_cle3            = 1
    AND param_transcod.cle3                  = a_old_numgar ) )
    AND ( ( param_transcod.type_cle1_interne = 1
    AND param_transcod.cle1_interne          = a_numgar )
    OR ( param_transcod.type_cle2_interne    = 1
    AND param_transcod.cle2_interne          = a_numgar ) );
  loc_param_transcod fetch_param_transcod%ROWTYPE;

  CURSOR fetch_adhe
  IS
    SELECT adhe_cntrt.numgar,
      adhe_cntrt.numadhe,
      adhe_cntrt.idadhesion,
      adhe_cntrt.date_fin_adhe,
      adhe_cntrt.numquerable,
      adhe_cntrt.fract,
      adhe_cntrt.mregl,
      adhe_cntrt.delai,
      indvs.typadr,
      indvs.refcie,
      indvs.regime,
      indvs.sexe,
      (TO_CHAR (a_debut, 'yyyy') - TO_CHAR (indvs.datnais, 'yyyy') ) age
    FROM indvs,
      adhe_cntrt
    WHERE adhe_cntrt.numgar                      = a_old_numgar
    AND adhe_cntrt.numadhe                       = indvs.numindiv
    AND NVL (adhe_cntrt.date_fin_adhe, a_debut) >= a_debut;

  loc_adhe fetch_adhe%ROWTYPE;
  loc_old_idadhesion NUMBER;
  CURSOR fetch_transcod
  IS
    SELECT cle_primaire,
      type_cle_primaire,
      cle1,
      type_cle1,
      cle2,
      type_cle2,
      cle3,
      type_cle3,
      debut
    FROM transcod
    WHERE transcod.idporte = a_idporte;
  loc_transcod fetch_transcod%ROWTYPE;
  CURSOR fetch_adhe_membre
  IS
    SELECT adhe_cntrt_membre.numindiv,
      adhe_cntrt_membre.typadr,
      adhe_cntrt_membre.numbene
    FROM adhe_cntrt_membre
    WHERE adhe_cntrt_membre.idadhesion = loc_old_idadhesion
    AND EXISTS
      (SELECT 1
      FROM adhesion
      WHERE adhesion.idadhesion               = adhe_cntrt_membre.idadhesion
      AND adhesion.numindiv                   = adhe_cntrt_membre.numindiv
      AND adhesion.numfor                     = loc_old_numfor
      AND NVL (adhesion.datper, a_debut )     >= a_debut 
      );
  loc_adhe_membre fetch_adhe_membre%ROWTYPE;
  CURSOR fetch_gar
  IS
    SELECT gar_cntrt.numfor,
      gar_cntrt.datapli,
      gar_cntrt.datper,
      gar_cntrt.TYPE
    FROM gar_cntrt
    WHERE gar_cntrt.numgar    = a_numgar
    AND gar_cntrt.valide      = 'O'
    AND gar_cntrt.numfor NOT IN
      (SELECT grp_gar_def.numfor
      FROM grp_gar,
        grp_gar_def
      WHERE grp_gar_def.numgrpgar = grp_gar.numgrpgar
      AND grp_gar.etendue         = 2
      AND grp_gar.clef            = gar_cntrt.numgar
      AND grp_gar_def.numfor      = gar_cntrt.numfor
      )
  AND gar_cntrt.numfor = loc_numfor
  UNION
  SELECT grp_gar.numgrpgar,
    grp_gar.datapli,
    grp_gar.datper,
    3 TYPE
  FROM grp_gar
  WHERE grp_gar.etendue = 2
  AND grp_gar.clef      = a_numgar
  AND grp_gar.valide    = 'O'
  AND grp_gar.numgrpgar = loc_numfor;
  loc_gar fetch_gar%ROWTYPE;
  loc_idadhesion  NUMBER;
  loc_numorg      NUMBER;
  loc_typadr      NUMBER;
  loc_numassu     NUMBER;
  loc_continue    NUMBER := 1;
  loc_nombre      NUMBER := 0;
  loc_numremise   NUMBER := 0;
  loc_nombre_adhe NUMBER := 0;
  loc_debut       DATE;
  loc_fin         DATE;
  loc_valvar       VAL_VARIABLE.VALEUR%TYPE;
  flag_resil      BOOLEAN;
  flag_insert_adhe BOOLEAN;  
  loc_nb_aff_numfor NUMBER :=0;
BEGIN
SELECT NVL (MAX (remise_transfert.numremise), 0) + 1
INTO loc_numremise
FROM remise_transfert;
BEGIN
  flag_resil:=TRUE;
  IF (a_type = 2) THEN
    FOR loc_adhe IN fetch_adhe
    LOOP
     loc_idadhesion  := pk_adhesion.f_idadhesion;
      flag_insert_adhe :=FALSE;
      FOR loc_param_transcod IN fetch_param_transcod
      LOOP
        p_initialise (loc_param_transcod.type_cle1, loc_param_transcod.cle1, 1 );
        p_initialise (loc_param_transcod.type_cle2, loc_param_transcod.cle2, 1 );
        p_initialise (loc_param_transcod.type_cle3, loc_param_transcod.cle3, 1 );
        p_initialise (loc_param_transcod.type_cle1_interne, loc_param_transcod.cle1_interne, 2 );
        p_initialise (loc_param_transcod.type_cle2_interne, loc_param_transcod.cle2_interne, 2 );
        /* On compte le nombre d'adhesions par adherent */
       -- DBMS_OUTPUT.put_line ('Adherent  = ' || loc_adhe.numadhe);
        BEGIN
          SELECT COUNT (*)
          INTO loc_nombre_adhe
          FROM adhe_cntrt
          WHERE adhe_cntrt.numadhe                     = loc_adhe.numadhe
          AND NVL (adhe_cntrt.date_fin_adhe, a_debut) >= a_debut;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          loc_nombre_adhe := 0;
        END;
        --DBMS_OUTPUT.put_line ('Nb adhesions  = ' || loc_nombre_adhe);
        DBMS_OUTPUT.put_line ('Adherent  = ' || loc_adhe.numadhe);
        IF (loc_old_numgar      IS NULL) THEN
          loc_old_numgar        := a_old_numgar;
        ELSIF (loc_numgar       IS NULL) THEN
          loc_numgar            := a_numgar;
        ELSIF (loc_old_typassu  IS NULL) THEN
          loc_old_typassu       := loc_adhe.typadr;
        ELSIF (loc_typassu      IS NULL) THEN
          loc_typassu           := loc_adhe.typadr;
        ELSIF (loc_old_numindiv IS NULL) THEN
          loc_old_numindiv      := loc_adhe.numadhe;
        ELSIF (loc_numindiv     IS NULL) THEN
          loc_numindiv          := loc_adhe.numadhe;
        ELSIF (loc_old_refcie   IS NULL) THEN
          loc_old_refcie        := loc_adhe.refcie;
        ELSIF (loc_refcie       IS NULL) THEN
          loc_refcie            := loc_adhe.refcie;
        ELSIF (loc_old_regime   IS NULL) THEN
          loc_old_regime        := loc_adhe.regime;
        ELSIF (loc_regime       IS NULL) THEN
          loc_regime            := loc_adhe.regime;
        ELSIF (loc_old_age      IS NULL) THEN
          loc_old_age           := loc_adhe.age;
        ELSIF (loc_age          IS NULL) THEN
          loc_age               := loc_adhe.age;
        ELSIF (loc_old_sexe     IS NULL) THEN
          loc_old_sexe          := loc_adhe.sexe;
        ELSIF (loc_sexe         IS NULL) THEN
          loc_sexe              := loc_adhe.sexe;
        ELSIF (loc_nb_adhe      IS NULL) THEN
          loc_nb_adhe           := loc_nombre_adhe;
        ELSIF (loc_old_nb_adhe  IS NULL) THEN
          loc_old_nb_adhe       := loc_nombre_adhe;
        END IF;
        --M5006 transfert d'assuré pour un périmètre tagué en amont, on recherche la valeur de la val_variable

        IF (loc_param_transcod.condition     IS NOT NULL) THEN
          flag_resil:=FALSE;
          IF (loc_param_transcod.type_cle3    = 1) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.numgar );
          ELSIF (loc_param_transcod.type_cle3 = 2) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_old_numfor );
          ELSIF (loc_param_transcod.type_cle3 = 3) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.typadr );
          ELSIF (loc_param_transcod.type_cle3 = 4) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.numadhe );
          ELSIF (loc_param_transcod.type_cle3 = 5) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.refcie );
          ELSIF (loc_param_transcod.type_cle3 = 6) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.regime );
          ELSIF (loc_param_transcod.type_cle3 = 7) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_old_numsoc );
          ELSIF (loc_param_transcod.type_cle3 = 8) THEN
            IF loc_old_idvariable IS NOT NULL THEN       
              loc_valvar := F_VAL_VAR_ALL(loc_adhe.idadhesion,loc_old_idvariable,a_debut);
              --pk_trace.p_ins_journal_adm ('Pk_transfert.p_insere_adhe', a_numedit, 0, 'Transfert adhesion ' || TO_CHAR (loc_adhe.idadhesion) || ' loc_valvar ' || loc_valvar, SYSDATE );
              --on ne peut que contrôler une val_var existante ou non pour l'étendue 13 pour le moment
               DBMS_OUTPUT.put_line ('***Adherent  = ' || loc_adhe.numadhe ||' valeur:'||loc_valvar);
            END IF;
            IF loc_param_transcod.condition ='@' THEN
              loc_continue                     := f_condition (loc_param_transcod.condition, NULL, loc_valvar );
            ELSIF loc_param_transcod.condition ='#' AND loc_valvar IS NOT NULL THEN --comparaison avec le numfor cible
              loc_continue                     := f_condition (loc_param_transcod.condition, loc_numfor, loc_valvar );
            ELSE  loc_continue :=1;
            END IF;
          ELSIF (loc_param_transcod.type_cle3 = 9) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.age );
          ELSIF (loc_param_transcod.type_cle3 = 10) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_old_montant );
          ELSIF (loc_param_transcod.type_cle3 = 11) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.sexe );
          ELSIF (loc_param_transcod.type_cle3 = 12) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_nombre_adhe );
          END IF;
        ELSE
          loc_continue := 0;
        END IF;
       -- DBMS_OUTPUT.put_line ('loc_continue  = ' || loc_continue);
       -- pk_trace.p_ins_journal_adm ('Pk_transfert.p_insere_adhe', a_numedit, 0, 'Transfert adhesion ' || TO_CHAR (loc_adhe.idadhesion) || ' loc_continue ' || loc_continue, SYSDATE );

        --on vérifie qu'il y a au moins un numfor_old  éligible dans l'ancienne adhésion pour le contrat à traiter
        SELECT COUNT (numindiv) INTO loc_nb_aff_numfor
        FROM adhesion
        WHERE adhesion.idadhesion               = loc_adhe.idadhesion
        AND adhesion.numfor                     = loc_old_numfor
        AND NVL (adhesion.datper, a_debut )     >= a_debut ;

        IF loc_nb_aff_numfor =0 THEN
         loc_continue:=1; --on passee à l'adhérent suivant
        END IF;

        IF (loc_continue = 0) THEN
          BEGIN
            --adhésion pré-existante
            SELECT idadhesion INTO loc_idadhesion
              FROM adhe_cntrt
              WHERE adhe_cntrt.numgar = a_numgar
              AND adhe_cntrt.numadhe  = loc_adhe.numadhe ;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN 
            loc_idadhesion  := pk_adhesion.f_idadhesion;
          END;
        --  DBMS_OUTPUT.put_line ('Idadhesion  = ' || loc_idadhesion);
          -- On insere la nouvelle adhesion dans adhe_cntrt 
          INSERT
          INTO adhe_cntrt
            (
              idadhesion,
              ref_ext,
              numgar,
              numadhe,
              date_adhe,
              meme_gar,
              date_fin_adhe,
              numquerable,
              fract,
              echesuiv,
              mregl,
              delai,
              dsous,
              numutil
            )
          SELECT loc_idadhesion,
            loc_idadhesion
            || ' / '
            || SUBSTR (contrat.refcie, 1, 18),
            a_numgar,
            loc_adhe.numadhe,
            a_debut,
            'N',
            loc_adhe.date_fin_adhe,
            loc_adhe.numquerable,
            loc_adhe.fract,
            a_debut,
            loc_adhe.mregl,
            loc_adhe.delai,
            a_debut,
            f_numutil
          FROM contrat
          WHERE contrat.numgar = a_numgar
          AND NOT EXISTS
            (SELECT 1
            FROM adhe_cntrt
            WHERE adhe_cntrt.numgar = a_numgar
            AND adhe_cntrt.numadhe  = loc_adhe.numadhe
            );

          flag_insert_adhe :=TRUE;
          DBMS_OUTPUT.put_line ('Adherent  = ' || loc_adhe.numadhe);
          --On insere dans histo_adhesion 
          INSERT
          INTO histo_adhesion
            (
              idadhesion,
              debut,
              datsai,
              etat,
              motif,
              numutil
            )
          SELECT loc_idadhesion,
            a_debut,
            SYSDATE,
            1,
            a_motif,
            f_numutil
          FROM DUAL
          WHERE NOT EXISTS
            (SELECT 1
            FROM histo_adhesion,
              adhe_cntrt
            WHERE histo_adhesion.idadhesion = adhe_cntrt.idadhesion
            AND adhe_cntrt.numgar           = a_numgar
            AND adhe_cntrt.numadhe          = loc_adhe.numadhe
            );
          IF (loc_adhe.date_fin_adhe IS NOT NULL) THEN
            BEGIN
              INSERT INTO histo_adhesion
                (idadhesion, debut, datsai, etat, motif, numutil
                )
              SELECT loc_idadhesion,
                a.debut,
                SYSDATE,
                3,
                a.motif,
                f_numutil
              FROM histo_adhesion a
              WHERE a.idadhesion = loc_adhe.idadhesion
              AND a.debut        = loc_adhe.date_fin_adhe
              AND NOT EXISTS
                (SELECT 1
                FROM histo_adhesion,
                  adhe_cntrt
                WHERE histo_adhesion.idadhesion = adhe_cntrt.idadhesion
                AND histo_adhesion.debut        = loc_adhe.date_fin_adhe
                AND adhe_cntrt.numgar           = a_numgar
                AND adhe_cntrt.numadhe          = loc_adhe.numadhe
                );
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              pk_trace.p_ins_journal_adm ('Pk_transfert.p_insere_adhe', a_numedit, 1, 'Aucun histo_adhesion avec code etat 3 pour idadhesion ' || TO_CHAR (loc_adhe.idadhesion), SYSDATE );
            END;
          END IF;
          loc_old_idadhesion := loc_adhe.idadhesion;
         -- DBMS_OUTPUT.put_line ( 'OLD IDADHESION  = ' || loc_old_idadhesion );
          --On insere dans histo_adhe_cntrt_membre 
         -- DBMS_OUTPUT.put_line ('OLD NUMFOR  = ' || loc_old_numfor);
          FOR loc_adhe_membre IN fetch_adhe_membre
          LOOP
           -- pk_trace.p_ins_journal_adm ('TR05T', a_numedit, 0, 'insert into membre indv:' ||loc_adhe_membre.numindiv, SYSDATE );
            INSERT INTO adhe_cntrt_membre
              (idadhesion, numindiv, typadr, numbene
              )
            SELECT loc_idadhesion,
              loc_adhe_membre.numindiv,
              loc_adhe_membre.typadr,
              loc_adhe_membre.numbene
            FROM DUAL
            WHERE NOT EXISTS
              (SELECT 1
              FROM adhe_cntrt_membre,
                adhe_cntrt
              WHERE adhe_cntrt_membre.idadhesion = adhe_cntrt.idadhesion
              AND adhe_cntrt.numgar              = a_numgar
              AND adhe_cntrt_membre.numindiv     = loc_adhe_membre.numindiv
              AND adhe_cntrt.idadhesion          = loc_idadhesion
              );
            -- On insere dans adhesion 
            SELECT NVL (indvs.orgbase, 1)
            INTO loc_numorg
            FROM indvs
            WHERE indvs.numindiv = loc_adhe.numadhe;
            FOR loc_gar IN fetch_gar
            LOOP
              SELECT GREATEST (loc_gar.datapli, a_debut) INTO loc_debut FROM DUAL;
              SELECT GREATEST (loc_adhe.date_fin_adhe, NVL (loc_gar.datper, loc_adhe.date_fin_adhe ) )
              INTO loc_fin
              FROM DUAL;
              IF (loc_debut > loc_fin) THEN
                loc_fin    := '';
              END IF;
             --  pk_trace.p_ins_journal_adm ('TR05T', a_numedit, 0, 'insert into adhesion gar:' ||loc_gar.numfor, SYSDATE );
              INSERT INTO adhesion
                (
                  idadhesion,
                  numindiv,
                  numgar,
                  numfor,
                  datapli,
                  etat,
                  typfor,
                  numorg,
                  flag_regime,
                  dis_carence,
                  dis_franchise,
                  rang,
                  datper,
                  numutil,
                  creation,
                  maj
                )
              SELECT loc_idadhesion,
                adhesion.numindiv,
                a_numgar,
                loc_gar.numfor,
                GREATEST (loc_gar.datapli, a_debut),
                1,
                loc_gar.TYPE,
                loc_numorg,
                adhesion.flag_regime,
                adhesion.dis_carence,
                adhesion.dis_franchise,
                adhesion.rang,
                decode(adhesion.datper,NULL,NULL,adhesion.datper),
                f_numutil,
                SYSDATE,
                SYSDATE
              FROM adhesion
              WHERE adhesion.idadhesion =loc_adhe.idadhesion
              AND adhesion.numindiv =  loc_adhe_membre.numindiv
              AND NVL(adhesion.datper, a_debut) >= a_debut
              AND adhesion.numfor =loc_old_numfor
              AND NOT EXISTS
                (SELECT 1
                FROM adhesion a
                WHERE a.numgar = a_numgar
                AND a.numindiv = loc_adhe_membre.numindiv
                AND a.numfor   = loc_gar.numfor
                AND a.rang = adhesion.rang
                );

                    --ABO on vérifie qu'il existe encore au moins une couverture sur l'ancien contrat avant de l'ajouter dans les membres
           --  DBMS_OUTPUT.put_line ('NEW COUVERTURE INDIV ' || loc_adhe_membre.numindiv || 'NEW NUMFOR  = ' || loc_gar.numfor);
            END LOOP;--fetch_gar
          END LOOP;--fetch_adhe_membre


          INSERT INTO histo_transfert
            (numremise, new_numgar, old_numgar, numindiv
            )
          SELECT loc_numremise,
            loc_numgar,
            loc_old_numgar,
            loc_adhe.numadhe
          FROM DUAL
          WHERE NOT EXISTS
            (SELECT 1
            FROM histo_transfert
            WHERE numremise = loc_numremise
            AND new_numgar  = loc_numgar
            AND old_numgar  = loc_old_numgar
            AND numindiv    = loc_adhe.numadhe
            );


        END IF;
      END LOOP;--fetch_transod
      -- On resilie l'adhesion de l'ancien contrat lorsque tous les membres et numfor sont passés en revue et qu'on a bien eu une insertion
      IF flag_insert_adhe THEN
        p_resilie_adhe (loc_old_numgar, loc_adhe.idadhesion, loc_adhe.numadhe, a_motif, (a_debut - 1) );
        pk_trace.p_ins_journal_adm ('Pk_transfert.p_insere_adhe', a_numedit, 0, 'Resiliation adhesion :' || TO_CHAR (loc_adhe.idadhesion) || ' Insertion idadhesion :' || TO_CHAR (loc_idadhesion), SYSDATE );
        COMMIT;
      END IF;     
    END LOOP;--fetch_adhe

    --On resilie l'ancien contrat uniqument s'il n'y avait aucune condition lors du transfert
    IF flag_resil THEN
      p_resilie_contrat (a_old_numgar, a_motif, (a_debut - 1));
    END IF;

  ELSIF (a_type = 1) THEN
    FOR loc_param_transcod IN fetch_param_transcod
    LOOP
      FOR loc_transcod IN fetch_transcod
      LOOP
        p_initialise (loc_transcod.type_cle1, loc_transcod.cle1, 2);
        p_initialise (loc_transcod.type_cle2, loc_transcod.cle2, 2);
        p_initialise (loc_transcod.type_cle3, loc_transcod.cle3, 2);
        p_initialise (loc_transcod.type_cle_primaire, loc_transcod.cle_primaire, 2 );
        IF (loc_refcie IS NOT NULL) THEN
          BEGIN
            SELECT numindiv,
              typassu,
              typadr,
              NVL (regime, 1),
              numassu
            INTO loc_numindiv,
              loc_typassu,
              loc_typadr,
              loc_regime,
              loc_numassu
            FROM indvs
            WHERE refcie = loc_refcie;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            loc_numindiv := -1;
          END;
        ELSIF (loc_numindiv IS NOT NULL) THEN
          BEGIN
            SELECT refcie,
              typassu,
              typadr,
              NVL (regime, 1),
              numassu
            INTO loc_refcie,
              loc_typassu,
              loc_typadr,
              loc_regime,
              loc_numassu
            FROM indvs
            WHERE numindiv = loc_numindiv;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            loc_refcie := '-1';
          END;
        END IF;
        DBMS_OUTPUT.put_line ('personne  = ' || loc_numindiv);

        IF (loc_typassu = 1) THEN
         loc_idadhesion  := pk_adhesion.f_idadhesion;
          DBMS_OUTPUT.put_line ('idadhesion  = ' || loc_idadhesion);
          INSERT
          INTO adhe_cntrt
            (
              idadhesion,
              ref_ext,
              numgar,
              numadhe,
              date_adhe,
              meme_gar,
              date_fin_adhe,
              numquerable,
              fract,
              echesuiv,
              dereche,
              mregl,
              delai,
              dsous,
              numutil
            )
          SELECT loc_idadhesion,
            loc_idadhesion
            || '/'
            || contrat.refcie,
            loc_numgar,
            loc_numindiv,
            loc_transcod.debut,
            'N',
            '',
            loc_numindiv,
            contrat.fract,
            '',
            '',
            contrat.mregl,
            contrat.delai,
            loc_transcod.debut,
            f_numutil
          FROM contrat
          WHERE contrat.numgar = loc_numgar;
          DBMS_OUTPUT.put_line ( 'insertion adhe_cntrt  = ' || loc_idadhesion );
          INSERT INTO histo_adhesion
            (idadhesion, debut, datsai, etat, motif, numutil
            )
          SELECT loc_idadhesion,
            loc_transcod.debut,
            SYSDATE,
            1,
            a_motif,
            f_numutil
          FROM DUAL;
          DBMS_OUTPUT.put_line ( 'insertion histo_adhesion  = ' || loc_idadhesion );
        ELSE
          BEGIN
            SELECT adhe_cntrt.idadhesion
            INTO loc_idadhesion
            FROM adhe_cntrt
            WHERE numadhe = loc_numassu;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            loc_idadhesion := 0;
          END;
        END IF;

        INSERT INTO adhe_cntrt_membre
          (idadhesion, numindiv, typadr, numbene  )
        SELECT loc_idadhesion,
          loc_numindiv,
          loc_typadr,
          ''
        FROM DUAL
        WHERE EXISTS
          (SELECT 1 FROM adhe_cntrt WHERE idadhesion = loc_idadhesion
          )
        AND loc_idadhesion != 0
        AND NOT EXISTS(SELECT 1 FROM adhe_cntrt_membre WHERE idadhesion = loc_idadhesion AND numindiv = loc_numindiv);

        INSERT
        INTO adhesion
          (
            idadhesion,
            numindiv,
            numgar,
            numfor,
            datapli,
            etat,
            typfor,
            numorg,
            flag_regime,
            dis_carence,
            dis_franchise,
            rang,
            numutil,
            creation
          )
        SELECT loc_idadhesion,
          loc_numindiv,
          loc_numgar,
          loc_numfor,
          loc_transcod.debut,
          1,
          gar_cntrt.TYPE,
          loc_regime,
          'C',
          'O',
          'O',
          1,
          f_numutil,
          SYSDATE
        FROM gar_cntrt
        WHERE gar_cntrt.numfor = loc_numfor
        AND gar_cntrt.numgar   = loc_numgar
        AND loc_idadhesion    != 0;

        INSERT INTO histo_transfert
          (numremise, new_numgar, old_numgar, numindiv
          )
        SELECT loc_numremise,
          loc_numgar,
          loc_old_numgar,
          loc_numindiv
        FROM DUAL
        WHERE NOT EXISTS
          (SELECT 1
          FROM histo_transfert
          WHERE numremise = loc_numremise
          AND new_numgar  = loc_numgar
          AND old_numgar  = loc_old_numgar
          AND numindiv    = loc_adhe.numadhe
          );
      END LOOP;
    END LOOP;
  END IF;
EXCEPTION 
  WHEN OTHERS THEN 
  pk_trace.p_ins_journal_adm ('TR05T', a_numedit, 0, 'Adhesion en erreur :' ||loc_old_idadhesion, SYSDATE );
  pk_trace.p_ins_journal_adm ('TR05T', a_numedit, 0, 'Fin de traitement anormale :' || SQLERRM, SYSDATE );
END;

  BEGIN
    SELECT count(numindiv)
    INTO loc_nombre
    FROM histo_transfert
    WHERE numremise = loc_numremise
    AND new_numgar  = a_numgar
    AND old_numgar  = a_old_numgar;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    loc_nombre := 0;
  END;

  INSERT
  INTO remise_transfert
    (
      numremise,
      TYPE,
      old_numgar,
      new_numgar,
      debut,
      motif,
      creation,
      nombre
    )
  SELECT loc_numremise,
    a_type,
    a_old_numgar,
    a_numgar,
    a_debut,
    a_motif,
    SYSDATE,
    loc_nombre
  FROM DUAL;
END p_transfert_adhe;


PROCEDURE p_maj_variable(
    a_idporte    IN NUMBER,
    a_old_numgar IN NUMBER,
    a_debut      IN DATE,
    a_numedit    IN NUMBER )
IS
  CURSOR fetch_param
  IS
    SELECT param_transcod.cle1,
      param_transcod.type_cle1,
      param_transcod.cle2,
      param_transcod.type_cle2,
      param_transcod.cle3,
      param_transcod.type_cle3,
      param_transcod.cle1_interne,
      param_transcod.type_cle1_interne,
      param_transcod.cle2_interne,
      param_transcod.type_cle2_interne
    FROM param_transcod
    WHERE param_transcod.idporte     = a_idporte
    AND ( ( param_transcod.type_cle1 = 1
    AND param_transcod.cle1          = a_old_numgar )
    OR ( param_transcod.type_cle2    = 1
    AND param_transcod.cle2          = a_old_numgar )
    OR ( param_transcod.type_cle3    = 1
    AND param_transcod.cle3          = a_old_numgar ) );
  loc_param fetch_param%ROWTYPE;
  loc_valeur NUMBER;
  CURSOR fetch_adhe
  IS
    SELECT adhe_cntrt_membre.numindiv,
      adhe_cntrt_membre.idadhesion,
      adhe_cntrt_membre.typadr
    FROM adhe_cntrt_membre
    WHERE adhe_cntrt_membre.idadhesion IN
      (SELECT adhe_cntrt.idadhesion
      FROM adhe_cntrt
      WHERE adhe_cntrt.numgar                          = a_old_numgar
      AND NVL (adhe_cntrt.date_fin_adhe, a_debut - 1) >= a_debut - 1
      );
  loc_adhe fetch_adhe%ROWTYPE;
  new_idadhesion NUMBER;
BEGIN
  FOR loc_param IN fetch_param
  LOOP
    p_initialise (loc_param.type_cle1, loc_param.cle1, 1);
    p_initialise (loc_param.type_cle2, loc_param.cle2, 1);
    p_initialise (loc_param.type_cle3, loc_param.cle3, 1);
    p_initialise (loc_param.type_cle1_interne, loc_param.cle1_interne, 2);
    p_initialise (loc_param.type_cle2_interne, loc_param.cle2_interne, 2);
    DBMS_OUTPUT.put_line ('Cle1 = ' || loc_param.cle1);
    DBMS_OUTPUT.put_line ('Cle1_interne = ' || loc_param.cle1_interne);
    DBMS_OUTPUT.put_line ( 'Type Cle1_interne = ' || loc_param.type_cle1_interne );
    DBMS_OUTPUT.put_line ('Ancien Contrat = ' || loc_old_numgar);
    DBMS_OUTPUT.put_line ('Nouveau Contrat = ' || loc_numgar);
    FOR loc_adhe IN fetch_adhe
    LOOP
      DBMS_OUTPUT.put_line ('Ancien idadhesion = ' || loc_adhe.idadhesion );
      DBMS_OUTPUT.put_line ('Ancien numindiv = ' || loc_adhe.numindiv);
      DBMS_OUTPUT.put_line ('Ancien typadr = ' || loc_adhe.typadr);
      DBMS_OUTPUT.put_line ('Ancien idvariable = ' || loc_old_idvariable);
      /* On recherche la valeur de l'ancienne variable en fonction des parametres de
      param_transcod
      */
      BEGIN
        SELECT val_variable.valeur
        INTO loc_valeur
        FROM val_variable
        WHERE val_variable.idvariable = loc_old_idvariable
        AND val_variable.clef         = loc_adhe.idadhesion
        AND val_variable.etendue      = 13
        AND val_variable.valide       = 'O'
        AND val_variable.statique     = 'O'
        AND val_variable.debut        =
          (SELECT MAX (a.debut)
          FROM val_variable a
          WHERE a.idvariable            = val_variable.idvariable
          AND a.clef                    = val_variable.clef
          AND a.etendue                 = val_variable.etendue
          AND a.valide                  = 'O'
          AND a.statique                = 'O'
          AND NVL (a.fin, a_debut - 1) >= a_debut - 1
          )
        AND NVL (val_variable.fin, a_debut - 1) >= a_debut - 1
        UNION
        SELECT val_variable.valeur
        FROM val_variable
        WHERE val_variable.idvariable = loc_old_idvariable
        AND val_variable.clef         = loc_adhe.numindiv
        AND val_variable.etendue      = 4
        AND loc_adhe.typadr           = 0
        AND val_variable.valide       = 'O'
        AND val_variable.statique     = 'O'
        AND val_variable.debut        =
          (SELECT MAX (a.debut)
          FROM val_variable a
          WHERE a.idvariable            = val_variable.idvariable
          AND a.clef                    = val_variable.clef
          AND a.etendue                 = val_variable.etendue
          AND a.valide                  = 'O'
          AND a.statique                = 'O'
          AND NVL (a.fin, a_debut - 1) >= a_debut - 1
          )
        AND NVL (val_variable.fin, a_debut - 1) >= a_debut - 1
        UNION
        SELECT val_variable.valeur
        FROM val_variable
        WHERE val_variable.idvariable = loc_old_idvariable
        AND val_variable.clef         = loc_adhe.numindiv
        AND val_variable.etendue      = 12
        AND val_variable.valide       = 'O'
        AND val_variable.statique     = 'O'
        AND val_variable.debut        =
          (SELECT MAX (a.debut)
          FROM val_variable a
          WHERE a.idvariable            = val_variable.idvariable
          AND a.clef                    = val_variable.clef
          AND a.etendue                 = val_variable.etendue
          AND a.valide                  = 'O'
          AND a.statique                = 'O'
          AND NVL (a.fin, a_debut - 1) >= a_debut - 1
          )
        AND NVL (val_variable.fin, a_debut - 1) >= a_debut - 1;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        pk_trace.p_ins_journal_adm ('Pk_transfert.p_maj_variable', a_numedit, 1, 'Aucune valeur retrouvee pour idvariable ' || TO_CHAR (loc_old_idvariable) || ' et clef ' || TO_CHAR (loc_numindiv), SYSDATE );
        GOTO fin;
      END;
      DBMS_OUTPUT.put_line ('Valeur = ' || loc_valeur);
      DBMS_OUTPUT.put_line ('New_idvariable = ' || loc_idvariable);


        /* On update val_variable a la valeur loc_valeur */
      BEGIN
        SELECT adhe_cntrt.idadhesion
        INTO new_idadhesion
        FROM adhe_cntrt
        WHERE adhe_cntrt.numgar = loc_numgar
        AND adhe_cntrt.numadhe  = loc_adhe.numindiv;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        pk_trace.p_ins_journal_adm ('Pk_transfert.p_maj_variable', a_numedit, 1, 'Pas d''adhesion pour le numindiv ' || TO_CHAR (loc_adhe.numindiv), SYSDATE );
      END;
      UPDATE val_variable
      SET valeur          = loc_valeur
      WHERE numgar        = loc_numgar
      AND idvariable      = loc_idvariable
      AND ( (clef         = new_idadhesion
      AND etendue         = 13)
      OR ( clef           = loc_adhe.numindiv
      AND etendue         = 4
      AND loc_adhe.typadr = 0 )
      OR (clef            = loc_adhe.numindiv
      AND etendue         = 12) );
      IF (SQL%NOTFOUND) THEN
        pk_trace.p_ins_journal_adm ('Pk_transfert.p_maj_variable', a_numedit, 1, 'Pas d''update pour l''idvariable ' || TO_CHAR (loc_idvariable) || ' et le numindiv ' || TO_CHAR (loc_adhe.numindiv), SYSDATE );
      END IF;
      <<fin>>
      NULL;
    END LOOP;
  END LOOP;
END p_maj_variable;


PROCEDURE p_maj_variable_transcod(
    a_idporte    IN NUMBER,
    a_idvariable IN NUMBER,
    a_cle_maj    IN NUMBER,
    a_old_numgar IN NUMBER DEFAULT NULL,
    a_numgar     IN NUMBER DEFAULT NULL,
    a_numedit    IN NUMBER )
IS
  CURSOR fetch_transcod
  IS
    SELECT transcod.cle_primaire,
      transcod.type_cle_primaire,
      transcod.cle1,
      transcod.type_cle1,
      transcod.cle2,
      transcod.type_cle2,
      transcod.cle3,
      transcod.type_cle3,
      transcod.debut
    FROM transcod
    WHERE transcod.idporte    = a_idporte
    AND transcod.cle_primaire = DECODE (type_cle_primaire, 1, a_old_numgar, cle_primaire )
    AND transcod.cle1         = DECODE (type_cle1, 1, a_old_numgar, cle1)
    AND transcod.cle2         = DECODE (type_cle2, 1, a_old_numgar, cle2)
    AND transcod.cle3         = DECODE (type_cle3, 1, a_old_numgar, cle3);
  loc_transcod fetch_transcod%ROWTYPE;
  loc_etendue NUMBER;
  loc_clef    NUMBER;
BEGIN
  FOR loc_transcod IN fetch_transcod
  LOOP
    DBMS_OUTPUT.put_line ('Cle primaire = ' || loc_transcod.cle_primaire);
    DBMS_OUTPUT.put_line ('Cle1 = ' || loc_transcod.cle1);
    DBMS_OUTPUT.put_line ('Cle2 = ' || loc_transcod.cle2);
    DBMS_OUTPUT.put_line ('Cle3 = ' || loc_transcod.cle3);
    DBMS_OUTPUT.put_line ('idvariable = ' || a_idvariable);
    DBMS_OUTPUT.put_line ('cle maj = ' || a_cle_maj);
    p_initialise (loc_transcod.type_cle_primaire, loc_transcod.cle_primaire, 1 );
    DBMS_OUTPUT.put_line ('numindiv maj = ' || loc_numindiv);
    p_initialise (loc_transcod.type_cle1, loc_transcod.cle1, 1);
    DBMS_OUTPUT.put_line ('numgar maj = ' || loc_numgar);
    p_initialise (loc_transcod.type_cle2, loc_transcod.cle2, 1);
    p_initialise (loc_transcod.type_cle3, loc_transcod.cle3, 1);
    p_initialise (loc_transcod.type_cle_primaire, loc_transcod.cle_primaire, 2 );
    p_initialise (loc_transcod.type_cle1, loc_transcod.cle1, 2);
    p_initialise (loc_transcod.type_cle2, loc_transcod.cle2, 2);
    p_initialise (loc_transcod.type_cle3, loc_transcod.cle3, 2);
    SELECT def_variable.etendue
    INTO loc_etendue
    FROM def_variable
    WHERE def_variable.idvariable = a_idvariable;
    DBMS_OUTPUT.put_line ('etendue = ' || loc_etendue);
    DBMS_OUTPUT.put_line ('Numindiv = ' || loc_numindiv);
    IF (loc_etendue IN (4, 12)) THEN
      loc_clef        := loc_numindiv;
    ELSIF (loc_etendue = 13) THEN
      BEGIN
        SELECT adhe_cntrt.idadhesion
        INTO loc_clef
        FROM adhe_cntrt
        WHERE numgar = a_numgar
        AND numadhe  = loc_numindiv;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        loc_clef := 0;
      END;
    END IF;
    DBMS_OUTPUT.put_line ('LOC CLEF = ' || loc_clef);
    UPDATE val_variable
    SET valeur       = DECODE (a_cle_maj, 1, loc_transcod.cle_primaire, 2, loc_transcod.cle1, 3, loc_transcod.cle2, 4, loc_transcod.cle3 )
    WHERE idvariable = a_idvariable
    AND clef         = loc_clef
    AND etendue      = loc_etendue;
    IF (SQL%NOTFOUND) THEN
      pk_trace.p_ins_journal_adm ('p_maj_variable_transcod', a_numedit, 1, 'Aucun update pour l''idvariable clef et etendue ' || TO_CHAR (a_idvariable) || TO_CHAR (loc_clef) || TO_CHAR (loc_etendue), SYSDATE );
    END IF;
  END LOOP;
END p_maj_variable_transcod;


PROCEDURE p_maj_variable_externe(
    a_entite     IN NUMBER,
    a_colonne    IN NUMBER,
    a_idvariable IN NUMBER,
    a_numedit    IN NUMBER )
IS
  CURSOR fetch_variable
  IS
    SELECT val_variable.idvariable,
      val_variable.clef,
      val_variable.etendue
    FROM val_variable
    WHERE val_variable.idvariable = a_idvariable;
  loc_variable fetch_variable%ROWTYPE;
BEGIN
  DBMS_OUTPUT.put_line ('Idvariable = ' || a_idvariable);
  FOR loc_variable IN fetch_variable
  LOOP
    IF (loc_variable.etendue = 13) THEN
      BEGIN
        SELECT adhe_cntrt.numadhe
        INTO loc_numindiv
        FROM adhe_cntrt
        WHERE adhe_cntrt.idadhesion = loc_variable.clef;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        loc_numindiv := 0;
      END;
    END IF;
    DBMS_OUTPUT.put_line ('Clef = ' || loc_variable.clef);
    DBMS_OUTPUT.put_line ('Numindiv = ' || loc_numindiv);
    pk_donnee.charge_donnee (a_entite, loc_numindiv, pk_donnee.t_donnee);
    UPDATE val_variable
    SET valeur                    = pk_donnee.t_donnee (a_colonne)
    WHERE val_variable.idvariable = a_idvariable
    AND val_variable.clef         = loc_variable.clef
    AND val_variable.etendue      = loc_variable.etendue;
    IF (SQL%NOTFOUND) THEN
      pk_trace.p_ins_journal_adm ('Pk_transfert.p_maj_variable_externe', a_numedit, 1, 'Aucun update pour l''idvariable' || TO_CHAR (a_idvariable) || ' la clef ' || TO_CHAR (loc_variable.clef) || ' et etendue ' || TO_CHAR (loc_variable.etendue), SYSDATE );
    END IF;
  END LOOP;
END p_maj_variable_externe;


PROCEDURE p_maj_variable_valeur(
    a_idvariable IN NUMBER,
    a_valeur     IN VARCHAR2 )
IS
BEGIN
  UPDATE val_variable
  SET valeur       = a_valeur
  WHERE idvariable = a_idvariable
  AND valeur      IS NULL;
END p_maj_variable_valeur;


PROCEDURE p_resilie_adhe(
    a_old_numgar     IN NUMBER,
    a_old_idadhesion IN NUMBER,
    a_numadhe        IN NUMBER,
    a_motif          IN NUMBER,
    a_debut          IN DATE,
    a_numutil        IN NUMBER,
    a_flag           IN NUMBER)
IS
  CURSOR fetch_qttc
  IS
    SELECT qttc_global.numquit,
      qttc_global.type_qttc,
      qttc_global.mt_affec,
      qttc_global.debut,
      qttc_global.fin
    FROM qttc_global
    WHERE qttc_global.idadhesion = a_old_idadhesion;
  loc_qttc fetch_qttc%ROWTYPE;
  loc_test NUMBER;
BEGIN
  /* On ferme l'adhesion */
  INSERT
  INTO histo_adhesion
    (
      idadhesion,
      etat,
      motif,
      debut,
      datsai,
      numutil
    )
  SELECT a_old_idadhesion,
    3,
    a_motif,
    a_debut,
    SYSDATE,
    nvl(a_numutil,f_numutil)-- MUR M0005418 f_numutil
  FROM DUAL
  WHERE NOT EXISTS
    (SELECT 1
    FROM adhe_cntrt
    WHERE adhe_cntrt.idadhesion   = a_old_idadhesion
    AND adhe_cntrt.date_fin_adhe IS NOT NULL
    );
  UPDATE adhesion
  SET datper       = a_debut,
    motif          = a_motif
  WHERE idadhesion = a_old_idadhesion
  AND datper      IS NULL;

  IF a_flag=1 THEN    -- résiliation provenant du WS pk_ws_web_maj_back.rad_adhesion
    UPDATE adhesion -- flag ajouté afin de mettre à jour les date de fin de couvertures si fin de couverture postérieure à la date de radiation provenant du ws rad_adhesion
    SET datper       = a_debut,
    motif          = a_motif
    WHERE idadhesion = a_old_idadhesion
    AND trunc(datper) >trunc(a_debut);
  END IF;

  UPDATE adhe_cntrt
  SET date_fin_adhe  = a_debut
  WHERE idadhesion   = a_old_idadhesion
  AND date_fin_adhe IS NULL;
  /* On fetche les quittances */
  /*
  For loc_qttc in fetch_qttc
  Loop
  if (a_debut <= loc_qttc.debut and loc_qttc.type_qttc = 2) then
  Begin
  Select 1
  Into   loc_test
  From   Dual
  Where Not Exists (
  Select 1
  From   emission
  Where  codope = 4
  and    numfact = loc_qttc.numquit
  Union
  Select 1
  From   qttc_affec
  Where  qttc_affec.numquit = loc_qttc.numquit
  Union
  Select 1
  From   prelevement_detail
  Where  codope = 4
  and    numfact = loc_qttc.numquit);
  begin
  delete qttc_global where numquit = loc_qttc.numquit;
  Update adhe_cntrt
  Set    (echesuiv, dereche) =
  (Select max(qttc_global.debut),
  max(qttc_global.fin)+1
  From   qttc_global
  Where  qttc_global.idadhesion = a_old_idadhesion
  and    qttc_global.type_qttc = 2
  and    qttc_global.comptant != 'R')
  Where adhe_cntrt.idadhesion = a_old_idadhesion;
  end;
  Exception When No_data_found then Null;
  End;
  elsif (a_debut <= loc_qttc.debut and loc_qttc.type_qttc = 3) then
  begin
  delete qttc_global
  where numquit = loc_qttc.numquit;
  end;
  end if;
  End loop;
  */
END p_resilie_adhe;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  p_resil_massive_adhe                                      */
/* Type         :  Public                                                    */
/* Description  :  Traitement de résiliation massive d adhésions a une date  */
/*                 donnée en fonction du contrat et d un motif de resiliation*/
/* Entree       :  i_numgar, Numéro de contrat                               */
/*                 i_date_resil, Date de résiliation                         */
/*                 I_motif_A, Motif de résiliation                           */
/*                 i_numedit, Numéro d edition du traitement                 */
/*                 i_niv_msg, Niveau de trace du traitement                  */
/*                 i_messErreur, Message d erreur,informatif ou avertissement*/
/*---------------------------------------------------------------------------*/
PROCEDURE p_resil_massive_adhe(
    i_numgar     IN PARAM_DMNDE.VALDEB1%TYPE ,
    i_date_resil IN DATE ,
    I_motif_A    IN PARAM_DMNDE.VALDEB3%TYPE ,
    I_motif_C    IN PARAM_DMNDE.VALDEB4%TYPE ,
    i_traitement IN JOURNAL_ADM.NOM_TRAITEMENT%TYPE ,
    i_idligne    IN JOURNAL_ADM.IDLIGNE%TYPE ,
    i_session    IN FILE_EDITION.NUMEDIT%TYPE DEFAULT 1 ,
    i_niv_msg    IN JOURNAL_ADM.NIV_MSG%TYPE DEFAULT 1 ,
    o_found OUT NUMBER)
IS
  -- curseur selctionnant l'ensemble des adhésions a resilier a une date donnee pour un contrat
  CURSOR c_resil_adhe
  IS
    SELECT ac.idadhesion ,
      ac.numgar ,
      ac.date_adhe ,
      ac.numadhe ,
      ac.numutil ,
      ac.date_fin_adhe ,
      cr.typgar ,
      cr.type_contrat
    FROM adhe_cntrt ac , 
      contrat cr
      -- contrat_ref cr
    WHERE ac.numgar                                         =i_numgar
    AND ac.numgar                                           =cr.numgar -- cr.numgar_ref
    -- AND cr.typgar                                          <>3 -- Contrat groupe ouvert d’adhésions collectives
    AND (ac.date_fin_adhe                                   > i_date_resil
    OR ac.date_fin_adhe                                    IS NULL)
    AND ac.date_adhe                                        <i_date_resil -- La date de résiliation doit être supérieur à la date de début de l adhesion
    AND cr.datsous                                          <i_date_resil -- La date de résiliation doit être supérieur à la date de début du contrat
    AND F_ETAT_ADHE(ac.idadhesion, i_date_resil)           <> 3
    AND PK_HISTO_CONTRAT.F_SEL_etat(i_numgar, i_date_resil)<>3
    ORDER BY ac.date_fin_adhe ASC;

  CURSOR c_cotis_emis_post(i_idadhesion IN ADHESION.IDADHESION%TYPE)
  IS
    SELECT qg.numquit ,
      qg.type_qttc ,
      qg.mt_affec ,
      qg.debut ,
      qg.fin
    FROM qttc_global qg
    WHERE qg.idadhesion = i_idadhesion
    AND qg.comptant    != 'R'
    AND NOT EXISTS
      (SELECT 1
      FROM emission
      WHERE codope  = 4
      AND numfact   = qg.numquit
      AND numrelance=99
      )
  AND NOT EXISTS
    (SELECT 1 FROM facture_regul WHERE facture_regul.numfact = qg.numquit
    )
  ORDER BY debut;

  loc_resil_adhe c_resil_adhe%ROWTYPE;
  loc_cotis_emis_post c_cotis_emis_post%ROWTYPE;
  loc_cpt_adhesion  NUMBER:=0;
  loc_NbAdhe_Post   NUMBER:=0;
  loc_Nbcotis_Post  NUMBER:=0;
  loc_Nbcotis_Emis  NUMBER:=0;
  loc_cotis_NonEmis NUMBER:=0;
  loc_TotCotis_Post NUMBER:=0;
  loc_ano           NUMBER:=0;
BEGIN
  G_nom_traitement:=i_traitement;
  G_idligne       :=i_idligne;
  G_Session       := i_session;
  o_found         :=0;
  P_INS_journal(1, TO_CHAR(SYSDATE, 'dd/mm/yyyy - hh24:mi')|| '- Début normal du traitement ');
  -- Parcours de l ensemble des adhésions a resilier a une date donnee pour un contrat
  FOR loc_resil_adhe IN c_resil_adhe
  LOOP
    -- Si aucune date de résiliation postèrieures trouvées
    IF TRIM(loc_resil_adhe.date_fin_adhe) IS NULL THEN
      -- requete selctionnant le nombre de cotisations régularisées chevauchants ou postérieurs
      -- à la date de résiliation a resilier a une date donnee pour un contrat
      SELECT COUNT(qg.numquit)
      INTO loc_Nbcotis_Post
      FROM qttc_global qg
      WHERE qg.idadhesion = loc_resil_adhe.idadhesion
      AND qg.numgar       = i_numgar
      AND i_date_resil    < qg.debut
      AND EXISTS
        (SELECT 1 FROM facture_regul WHERE facture_regul.numfact = qg.numquit
        )
      AND NOT EXISTS
        (SELECT 1
        FROM emission
        WHERE codope  = 4
        AND numfact   = qg.numquit
        AND numrelance=99
        );
      IF loc_Nbcotis_Post =0 THEN
        -- Verification des cotisations non régularisées pour lesquels il existe
        -- des cotisations payés ou émises postèrieurement de la date de résiliation
        FOR loc_cotis_emis_post IN c_cotis_emis_post(loc_resil_adhe.idadhesion)
        LOOP
          IF (i_date_resil < loc_cotis_emis_post.fin AND loc_cotis_emis_post.type_qttc = 2) THEN
            BEGIN
              SELECT 1
              INTO loc_cotis_NonEmis
              FROM DUAL
              WHERE NOT EXISTS
                (SELECT 1
                FROM emission
                WHERE codope = 4
                AND numfact  = loc_cotis_emis_post.numquit
                UNION
                SELECT 1
                FROM qttc_affec
                WHERE qttc_affec.numquit = loc_cotis_emis_post.numquit
                UNION
                SELECT 1
                FROM prelevement_detail
                WHERE codope = 4
                AND numfact  = loc_cotis_emis_post.numquit
                );
              /* BEGIN
              DELETE qttc_global WHERE numquit = loc_cotis_emis_post.numquit;
              UPDATE adhe_cntrt
              SET (dereche,echesuiv) =
              (SELECT MAX(qttc_global.debut), MAX(qttc_global.fin)+1
              FROM qttc_global
              WHERE qttc_global.idadhesion = loc_resil_adhe.idadhesion
              AND qttc_global.type_qttc = 2
              AND qttc_global.comptant != 'R')
              WHERE adhe_cntrt.idadhesion = loc_resil_adhe.idadhesion;
              END;*/
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              loc_Nbcotis_Emis:=loc_Nbcotis_Emis+1;
            END;
            /* ELSIF (i_date_resil <= loc_cotis_emis_post.fin AND loc_cotis_emis_post.type_qttc = 3) THEN
            BEGIN
            DELETE qttc_global WHERE numquit = loc_cotis_emis_post.numquit;
            END;*/
          END IF;
        END LOOP;
        IF loc_Nbcotis_Emis = 0 THEN
          P_INS_journal(3, 'Avant p_resilie_adhe numgar <'||i_numgar||'>, idadhesion <'||loc_resil_adhe.idadhesion||'>');
          P_INS_journal(3, 'Avant p_resilie_adhe numadhe <'||loc_resil_adhe.numadhe||'>, I_motif_A <'||I_motif_A||'>');
          P_INS_journal(3, 'Avant p_resilie_adhe i_date_resil <'||TO_CHAR(i_date_resil)||'>');
          -- Mise à jour de la date de fin des garanties de l adhesion
          p_resilie_adhe( i_numgar , loc_resil_adhe.idadhesion , loc_resil_adhe.numadhe , I_motif_A , i_date_resil);
          loc_cpt_adhesion:=loc_cpt_adhesion+1;
          P_INS_journal(2, 'L''adhésion '||loc_resil_adhe.idadhesion||' est résiliée.');
        ELSE
          -- P_INS_journal(1,'Existence d’appels émis ou réglés chevauchants ou postérieurs à la date de résiliation pour l''adhésion '||loc_resil_adhe.idadhesion);
          P_INS_journal(1,'Exist. Appels sur Adhésion '||loc_resil_adhe.idadhesion);
        END IF;
      ELSE
        loc_TotCotis_Post:=loc_TotCotis_Post+loc_Nbcotis_Post;
        -- P_INS_journal(1, 'L''adhésion '||loc_resil_adhe.idadhesion||' possède des cotisations postèrieures à la date de résiliation saisie');
        P_INS_journal(1, 'Adhésion '||loc_resil_adhe.idadhesion||': cotisations post-résil');
      END IF;
    ELSE
      loc_NbAdhe_Post:=loc_NbAdhe_Post+1;
      P_INS_journal(1, 'Adhésion '||loc_resil_adhe.idadhesion||': déjà résil. post. date saisie');
    END IF;
  END LOOP;
  -- Résiliation du contrat que si aucunes adhesions ou cotisations posterieures à la date de résiliation
  IF (loc_NbAdhe_Post=0 AND loc_TotCotis_Post=0 AND loc_Nbcotis_Emis=0) THEN
    -- Clôture du contrat et de la couverture des garanties si toutes les adhésions du contrat sont résiliées
    p_resil_contrat_ref ( i_numgar , i_motif_C , i_date_resil);
  ELSE
    P_INS_journal(1, 'Contrat non résilié.');
  END IF;
  P_INS_journal(1, 'Nombre d''adhésions résiliées : '||loc_cpt_adhesion||', Motif Adhésion '||I_motif_A||', Motif contrat '||I_motif_C||'.');
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  P_INS_journal(1, 'Résiliation massive impossible des adhésions du contrat. Erreur Oracle :', SQLERRM);
  o_found:=1;
  ROLLBACK;
END p_resil_massive_adhe;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  p_resil_contrat_ref                                       */
/* Type         :  Public                                                    */
/* Description  :  Résiliation du contrat si toutes les adhésions sont       */
/*                 résiliées                                                 */
/* Entree       :  i_numgar, Numéro de contrat                               */
/*                 i_date_resil, Date de résiliation                         */
/*                 i_motif_C, Motif de résiliation                           */
/* Modification :  26/08/2014 prise en compte des adhésions collectives      */                 
/*---------------------------------------------------------------------------*/
PROCEDURE p_resil_contrat_ref(
    i_numgar  IN PARAM_DMNDE.VALDEB1%TYPE,
    i_motif_C IN NUMBER,
    i_debut   IN DATE)
IS
  -- requete selectionnant le nombre de cotisations régularisées chevauchants ou postérieurs
  -- à la date de résiliation a resilier a une date donnee pour un contrat
  CURSOR c_cotis_emis_post
  IS
    SELECT qg.numquit ,
      qg.type_qttc ,
      qg.mt_affec ,
      qg.debut ,
      qg.fin
    FROM qttc_global qg
    WHERE qg.numgar  = i_numgar
    AND qg.comptant != 'R'
    AND NOT EXISTS
      (SELECT 1
      FROM emission
      WHERE codope  = 4
      AND numfact   = qg.numquit
      AND numrelance=99
      )
  AND NOT EXISTS
    (SELECT 1 FROM facture_regul WHERE facture_regul.numfact = qg.numquit
    )
  ORDER BY debut;
  loc_cotis_emis_post c_cotis_emis_post%ROWTYPE;
  loc_Nbcotis_Post  NUMBER:=0;
  loc_Nbcotis_Emis  NUMBER:=0;
  loc_cotis_NonEmis NUMBER:=0;
  loc_debut         DATE;
  loc_FlagResil     NUMBER:=0;
  loc_FlagGarResil  NUMBER:=0;
BEGIN
  /*
  SELECT COUNT(cr.numgar)
  INTO loc_FlagResil
  FROM adhe_cntrt ac
  , contrat_ref cr -- Ne pas avoir les adhésions issues de contrat collectif
  WHERE ac.numgar=i_numgar
  AND ac.numgar=cr.numgar_ref
  AND cr.typgar<>3 -- Contrat groupe ouvert d’adhésions collectives
  AND (ac.date_fin_adhe > i_debut OR ac.date_fin_adhe IS NULL)
  AND ac.date_adhe<i_debut -- La date de résiliation doit être supérieur à la date de début de l adhesion
  AND cr.datsous<i_debut -- La date de résiliation doit être supérieur à la date de début du contrat
  AND F_ETAT_ADHE(ac.idadhesion, i_debut)<> 3
  AND PK_HISTO_CONTRAT.F_SEL_etat(i_numgar, i_debut)<>3;
  */
  SELECT COUNT(cr.numgar)
    INTO loc_FlagResil
  FROM contrat cr  -- contrat_ref cr  
  WHERE -- cr.typgar  AND                                 <>3  -- Contrat groupe ouvert d’adhésions collectives
        cr.numgar                                      =i_numgar
    AND PK_HISTO_CONTRAT.F_SEL_etat(i_numgar, i_debut) <>3;

  IF loc_FlagResil                                   >0 THEN
    -- requete selctionnant le nombre de cotisations régularisées chevauchants ou postérieurs
    -- à la date de résiliation a resilier a une date donnee pour un contrat
    SELECT COUNT(qg.numquit)
    INTO loc_Nbcotis_Post
    FROM qttc_global qg
    WHERE qg.numgar = i_numgar
      AND i_debut   < qg.debut
      AND EXISTS (SELECT 1 FROM facture_regul WHERE facture_regul.numfact = qg.numquit)
      AND NOT EXISTS (SELECT 1 FROM emission WHERE codope  = 4 AND numfact   = qg.numquit AND numrelance=99  );

    IF loc_Nbcotis_Post =0 THEN
      -- Verification des cotisations non régularisées pour lesquels il existe
      -- des cotisations payés ou émises postèrieurement de la date de résiliation
      FOR loc_cotis_emis_post IN c_cotis_emis_post
      LOOP
        IF (i_debut < loc_cotis_emis_post.fin AND loc_cotis_emis_post.type_qttc = 2) THEN
          BEGIN
            SELECT 1
            INTO loc_cotis_NonEmis
            FROM DUAL
            WHERE NOT EXISTS
              (SELECT 1
              FROM emission
              WHERE codope = 4
              AND numfact  = loc_cotis_emis_post.numquit
              UNION
              SELECT 1
              FROM qttc_affec
              WHERE qttc_affec.numquit = loc_cotis_emis_post.numquit
              UNION
              SELECT 1
              FROM prelevement_detail
              WHERE codope = 4
              AND numfact  = loc_cotis_emis_post.numquit
              );
            /*  BEGIN
            DELETE qttc_global WHERE numquit = loc_cotis_emis_post.numquit;
            UPDATE adhe_cntrt
            SET (dereche,echesuiv) =
            (SELECT MAX(qttc_global.debut), MAX(qttc_global.fin)+1
            FROM qttc_global
            WHERE qttc_global.numgar = i_numgar
            AND qttc_global.type_qttc = 2
            AND qttc_global.comptant != 'R')
            WHERE adhe_cntrt.numgar = i_numgar;
            END;*/
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            loc_Nbcotis_Emis:=loc_Nbcotis_Emis+1;
          END;
          /*  ELSIF (i_debut <= loc_cotis_emis_post.fin AND loc_cotis_emis_post.type_qttc = 3) THEN
          BEGIN
          DELETE qttc_global WHERE numquit = loc_cotis_emis_post.numquit;
          END;*/
        END IF;
      END LOOP;
      IF loc_Nbcotis_Emis=0 THEN
        -- requete vérifiant si le contrat n'est pas résilier a la date donnée
        IF PK_HISTO_CONTRAT.F_SEL_etat(i_numgar, i_debut)<>3 THEN
          -- M0005013
          SELECT COUNT(1) INTO loc_FlagGarResil FROM gar_cntrt_ref WHERE numgar = i_numgar AND NVL(datper,i_debut) > i_debut;
          IF loc_FlagGarResil = 0 THEN
            -- Fermeture des garanties ouvertes du contrat M0005013
            UPDATE formule
            SET fin = i_debut
            WHERE fin IS NULL
              AND numfor IN ( SELECT numfor FROM gar_cntrt_ref WHERE numgar = i_numgar );
            UPDATE garanties
            SET fin = i_debut
            WHERE fin IS NULL
              AND numfor IN ( SELECT numfor FROM gar_cntrt_ref WHERE numgar = i_numgar );
            UPDATE gar_cntrt_ref
            SET datper  = i_debut
            WHERE datper IS NULL
              AND numgar = i_numgar;
           -- fin M0005013

            INSERT
            INTO histo_contrat
              (
                numgar,
                debut,
                datsai,
                etat,
                motif,
                numutil
              )
              VALUES
              (
                i_numgar,
                i_debut,
                SYSDATE,
                3,
                I_motif_C,
                f_numutil
              );
            P_INS_journal(1, 'Contrat résilié '||i_numgar||' avec le motif '||I_motif_C||'.');
          ELSE
            P_INS_journal(1, 'Existence de garantie(s) fermée(s) postérieurement à la date de résiliation pour le contrat');
          END IF;
        END IF;
      ELSE
        P_INS_journal(1,'Existence d’appels émis ou réglés chevauchants ou postérieurs à la date de résiliation pour le contrat '||i_numgar);
      END IF;
    ELSE
      P_INS_journal(1, 'Le contrat '||i_numgar||' possède des cotisations postèrieures à la date de résiliation saisie');
    END IF;
  ELSE
    P_INS_journal(1, 'Aucune mise a jour effectuée sur le contrat '||i_numgar);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  P_INS_journal(1, 'Résiliation impossible du contrat. Erreur Oracle :', SQLERRM);
END p_resil_contrat_ref;
---------------------------------------------------------------------------------


PROCEDURE p_resilie_contrat
  (
    a_old_numgar IN NUMBER,
    a_motif      IN NUMBER,
    a_debut      IN DATE
  )
IS
  CURSOR fetch_qttc
  IS
    SELECT qttc_global.numquit,
      qttc_global.type_qttc,
      qttc_global.mt_affec,
      qttc_global.debut,
      qttc_global.fin
    FROM qttc_global
    WHERE qttc_global.numgar   = a_old_numgar
    AND qttc_global.idadhesion = 0;
  loc_qttc fetch_qttc%ROWTYPE;
  loc_nat_calc NUMBER;
  loc_test     NUMBER;
  loc_FlagGarResil NUMBER :=0;
BEGIN

  -- M0005013
  SELECT COUNT(1) INTO loc_FlagGarResil FROM gar_cntrt_ref WHERE numgar = a_old_numgar AND NVL(datper,a_debut) > a_debut;
  IF loc_FlagGarResil = 0 THEN
    -- Fermeture des garanties ouvertes du contrat M0005013
    UPDATE formule
    SET fin = a_debut
    WHERE fin IS NULL
      AND numfor IN ( SELECT numfor FROM gar_cntrt_ref WHERE numgar = a_old_numgar );
    UPDATE garanties
    SET fin = a_debut
    WHERE fin IS NULL
      AND numfor IN ( SELECT numfor FROM gar_cntrt_ref WHERE numgar = a_old_numgar );
    UPDATE gar_cntrt_ref
    SET datper  = a_debut
    WHERE datper IS NULL
      AND numgar = a_old_numgar;
   -- fin M0005013


    -- pk_histo_contrat.f_sel_date_resil a été changé
    -- L_debut:='01-jan-3000'; remplacé par : l_debut := SYSDATE + 1825;
    -- on fait de même pour pk_histo_contrat.f_sel_date_resil (a_old_numgar) = '01-jan-3000';
    IF pk_histo_contrat.f_sel_date_resil (a_old_numgar) = SYSDATE + 1825 THEN  --permet de ne pas résilier 2 fois
      INSERT
      INTO histo_contrat
        (
          numgar,
          debut,
          datsai,
          etat,
          motif,
          numutil
        )
      SELECT a_old_numgar,
        a_debut,
        SYSDATE,
        3,
        a_motif,
        f_numutil
      FROM DUAL;
    END IF;

    P_INS_journal(1, 'Contrat résilié '||a_old_numgar||' avec le motif '||a_motif||'.');
  ELSE
    P_INS_journal(1, 'Existence de garantie(s) fermée(s) postérieurement à la date de résiliation pour le contrat');
  END IF;
  /*SELECT contrat.nat_calc
  INTO loc_nat_calc
  FROM contrat
  WHERE contrat.numgar = a_old_numgar;

  If (loc_nat_calc!=1)
  Then
  For loc_qttc in fetch_qttc
  Loop
  if (a_debut <= loc_qttc.debut and loc_qttc.type_qttc = 2) then
  Begin
  Select 1
  Into   loc_test
  From   Dual
  Where Not Exists (
  Select 1
  From   emission
  Where  codope = 4
  and    numfact = loc_qttc.numquit
  Union
  Select 1
  From   qttc_affec
  Where  qttc_affec.numquit = loc_qttc.numquit
  Union
  Select 1
  From   prelevement_detail
  Where  codope = 4
  and    numfact = loc_qttc.numquit);
  begin
  delete qttc_global where numquit = loc_qttc.numquit;
  Update contrat
  Set    (echesuiv, dereche) =
  (Select max(qttc_global.debut),
  max(qttc_global.fin)+1
  From   qttc_global
  Where  qttc_global.numgar = a_old_numgar
  and    qttc_global.idadhesion=0
  and    qttc_global.type_qttc = 1
  and    qttc_global.comptant != 'R')
  Where contrat.numgar = a_old_numgar;
  end;
  Exception When No_data_found then Null;
  End;
  elsif (a_debut <= loc_qttc.debut and loc_qttc.type_qttc = 3) then
  begin
  delete qttc_global
  where numquit = loc_qttc.numquit;
  end;
  end if;
  End loop;
  End if;
  */
END p_resilie_contrat;


PROCEDURE p_defaire_adhe(
    a_numremise IN NUMBER)
IS
  loc_numgar     NUMBER;
  loc_old_numgar NUMBER;
  loc_motif      NUMBER;
  loc_debut      DATE;
BEGIN
  SELECT new_numgar,
    old_numgar,
    motif,
    debut - 1 debut
  INTO loc_numgar,
    loc_old_numgar,
    loc_motif,
    loc_debut
  FROM remise_transfert
  WHERE numremise = a_numremise;
  /* On delete val_variable,beneficiaire,adhesion,adhe_cntrt_membre,histo_adhesion
  adhe_cntrt du nouveau contrat
  */
  DELETE val_variable
  WHERE numgar = loc_numgar;
  DELETE beneficiaire
  WHERE idadhesion IN
    (SELECT idadhesion FROM adhe_cntrt WHERE numgar = loc_numgar
    );
  DELETE adhesion WHERE numgar = loc_numgar;
  DELETE adhe_cntrt_membre
  WHERE idadhesion IN
    (SELECT idadhesion FROM adhe_cntrt WHERE numgar = loc_numgar
    );
  DELETE histo_adhesion
  WHERE idadhesion IN
    (SELECT idadhesion FROM adhe_cntrt WHERE numgar = loc_numgar
    );
  DELETE adhe_cntrt WHERE numgar = loc_numgar;
  /* On reouvre les adhesions et le contrat sur l'ancien contrat */
  DELETE histo_contrat
  WHERE numgar = loc_old_numgar
  AND motif    = loc_motif
  AND etat     = 3
  AND debut    = loc_debut;
  -- réouverture des garanties fermées du contrat M0005013
  UPDATE formule
  SET fin = NULL
  WHERE fin = loc_debut
    AND numfor IN ( SELECT numfor FROM gar_cntrt_ref WHERE numgar = loc_old_numgar );
  UPDATE garanties
  SET fin = NULL
  WHERE fin = loc_debut
    AND numfor IN ( SELECT numfor FROM gar_cntrt_ref WHERE numgar = loc_old_numgar );
  UPDATE gar_cntrt_ref
  SET datper  = NULL
  WHERE datper  = loc_debut
    AND numgar = loc_old_numgar;
 -- fin M0005013
  UPDATE adhe_cntrt
  SET date_fin_adhe = ''
  WHERE numgar      = loc_old_numgar
  AND date_fin_adhe = loc_debut
  AND EXISTS
    (SELECT 1
    FROM histo_adhesion
    WHERE histo_adhesion.idadhesion = adhe_cntrt.idadhesion
    AND motif                       = loc_motif
    );
  DELETE histo_adhesion
  WHERE idadhesion IN
    (SELECT idadhesion
    FROM adhe_cntrt
    WHERE numgar = loc_old_numgar
    AND etat     = 3
    AND motif    = loc_motif
    AND debut    = loc_debut
    );
  DELETE remise_transfert WHERE numremise = a_numremise;
  DELETE histo_transfert WHERE numremise = a_numremise;
END p_defaire_adhe;


PROCEDURE p_del_refcie_null
IS
  CURSOR fetch_indvs
  IS
    SELECT indvs.numindiv FROM indvs WHERE refcie IS NULL AND TYPE = 1;
  loc_indvs fetch_indvs%ROWTYPE;
BEGIN
  FOR loc_indvs IN fetch_indvs
  LOOP
    DELETE beneficiaire WHERE numindiv = loc_indvs.numindiv;
    DELETE adhesion WHERE numindiv = loc_indvs.numindiv;
    DELETE adhe_cntrt_membre
    WHERE idadhesion IN
      (SELECT idadhesion FROM adhe_cntrt WHERE numadhe = loc_indvs.numindiv
      );
    DELETE adhe_cntrt WHERE numadhe = loc_indvs.numindiv;
    DELETE indvs WHERE numindiv = loc_indvs.numindiv;
  END LOOP;
END p_del_refcie_null;


PROCEDURE p_del_var_calculee(
    a_idvariable IN NUMBER)
IS
BEGIN
  DELETE val_variable WHERE idvariable = a_idvariable;
END p_del_var_calculee;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_annul_report                                            */
/* Type         :  Public                                                    */
/* Description  :  Annulation d'une remise et de son détail                  */ 
/* Entree       :  i_numremise, Numéro de remise                             */  
/*---------------------------------------------------------------------------*/
PROCEDURE P_annul_report(
    i_numremise    IN CONTRAT_REF.numprod%TYPE  )
IS

BEGIN
  DELETE histo_report where numremise =i_numremise;
  DELETE remise_report where numremise =i_numremise;
  COMMIT;

END P_annul_report;
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_report_param_produit                                    */
/* Type         :  Public                                                    */
/* Description  :                                                            */
/*                                                                           */
/* Entree       :  i_numprod, Numéro de produit source                       */
/*                 i_numgar_deb numéro de contrat cible de début ou unique   */
/*                 i_numgar_fin, numéro de contrat cible de fin              */
/*                 i_numfor_ref, numéro de la garantie produit               */
/*                 i_numfor_c, numéro de la garantie cible                   */
/*                 i_dateref, date de référence                              */
/*                 i_report, 1 pour enregistrer les écart dans le contrat    */
/*---------------------------------------------------------------------------*/
  PROCEDURE P_report_param_produit(
    i_traitement   IN    TYP_BATCH.BATCHID%TYPE,
    i_numprod      IN CONTRAT_REF.numprod%TYPE,
    i_numgar_deb   IN CONTRAT_REF.numgar%TYPE,
    i_numgar_fin   IN CONTRAT_REF.numgar%TYPE,
    i_numfor_ref   IN GAR_CNTRT.numfor%TYPE,
    i_numfor_c     IN GAR_CNTRT.numfor%TYPE,
    i_dateref      IN DATE default sysdate,
    i_report       IN NUMBER default 0,
    i_session      IN    JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1,
    i_niv_msg      IN    NUMBER DEFAULT 1,
    o_found        OUT   NUMBER,
    o_erreur       OUT   VARCHAR2)
IS

  loc_dateref DATE;

  --périmètre contrat cible tenant compte des paramètres et produit demandés
  --on permet une cible produit si le contrat est vide
  CURSOR C_CNTRT IS 
    SELECT gar_cntrt.numgar, gar_cntrt.numfor,gar_cntrt.libelle,f.debut,gar_cntrt.numfor_ref 
    FROM v_gar_cntrt gar_cntrt, v_gar gar_prdt, formule f, contrat c
    WHERE gar_prdt.clef = i_numprod 
    AND gar_prdt.etendue =7 
    AND gar_prdt.typfor =1 --garantie santé uniquement
    AND loc_dateref between gar_prdt.datapli AND NVL(gar_prdt.datper,loc_dateref)
    AND i_numfor_c IS NULL
    AND gar_prdt.numfor = NVL(i_numfor_ref,gar_prdt.numfor) --paramètre non obligatoire
    AND gar_prdt.numfor = gar_cntrt.numfor_ref 
    AND f.numfor = gar_cntrt.numfor
    AND gar_cntrt.numgar BETWEEN NVL(i_numgar_deb,gar_cntrt.numgar) AND NVL(i_numgar_fin,NVL(i_numgar_deb,gar_cntrt.numgar))
    AND loc_dateref BETWEEN f.debut AND NVL(f.fin,loc_dateref)
    AND PK_HISTO_CONTRAT.F_SEL_etat(gar_cntrt.numgar) =1 --contrat cible non résilié
    AND c.numgar = gar_cntrt.numgar
    AND c.GEST_PREST=1 --contrat cible gérant les prestations
    --AND gar_cntrt.numfor = 58554
    UNION
    --report garantie produit sur autre garantie produit (produit identique)
    SELECT 0 numgar, gar_cible.numfor,f.libelle,f.debut,gar_prdt.numfor numfor_ref
    FROM v_gar gar_cible, v_gar gar_prdt, formule f
    WHERE gar_prdt.clef = i_numprod 
    AND gar_prdt.etendue =7 
    AND gar_prdt.typfor =1 --garantie santé uniquement
    AND loc_dateref between gar_prdt.datapli AND NVL(gar_prdt.datper,loc_dateref)
    AND gar_prdt.numfor = NVL(i_numfor_ref,gar_prdt.numfor) --paramètre non obligatoire
    AND i_numfor_ref IS NOT NULL
    AND i_numgar_deb IS NULL
    AND i_numfor_c IS NOT NULL
    AND gar_cible.numfor = i_numfor_c
    AND gar_prdt.clef = gar_cible.clef
    AND gar_cible.etendue =7 
    AND f.numfor = gar_cible.numfor
    AND loc_dateref BETWEEN f.debut AND NVL(f.fin,loc_dateref)
    --AND gar_cntrt.numfor = 58554
    UNION 
    --report garantie contrat sur garantie contrat
    SELECT gar_cible.numgar, gar_cible.numfor,gar_cible.libelle,f.debut,i_numfor_ref numfor_ref
    FROM v_gar_cntrt gar_cible, v_gar_cntrt gar_src, formule f, contrat c
    WHERE i_numprod IS NULL
    AND i_numfor_ref IS NOT NULL
    AND gar_src.numfor = i_numfor_ref
    AND gar_src.typfor =1 --garantie santé uniquement
    AND loc_dateref between gar_src.debut AND NVL(gar_src.fin,loc_dateref)
    AND i_numfor_c IS NOT NULL
    AND i_numgar_deb IS NOT NULL
    AND gar_cible.numfor = i_numfor_c
    AND f.numfor = gar_cible.numfor
    AND gar_cible.typfor =1 
    AND gar_cible.numgar BETWEEN NVL(i_numgar_deb,gar_cible.numgar) AND NVL(i_numgar_fin,NVL(i_numgar_deb,gar_cible.numgar))
    AND loc_dateref BETWEEN f.debut AND NVL(f.fin,loc_dateref)
    AND PK_HISTO_CONTRAT.F_SEL_etat(gar_cible.numgar) =1 --contrat cible non résilié
    AND c.numgar = gar_cible.numgar
    AND c.GEST_PREST=1 --contrat cible gérant les prestations
    ORDER BY 1,2;

  CURSOR C_RUB (p_produit GAR_CNTRT.numfor%TYPE, p_contrat GAR_CNTRT.numfor%TYPE)IS
    SELECT rubprod.codfrais prod_codfrais,rubcntrt.codfrais cntrt_codfrais , rubprod.datper prod_datper , rubcntrt.datper cntrt_datper, rubprod.datapli prod_datapli ,rubprod.type_acte
    FROM  defrub rubprod left outer join defrub rubcntrt 
    ON (rubprod.codfrais=rubcntrt.codfrais 
      AND rubcntrt.numfor = p_contrat
      AND (loc_dateref BETWEEN rubcntrt.datapli AND NVL(rubcntrt.datper,loc_dateref) OR   loc_dateref < rubcntrt.datapli))
    WHERE rubprod.numfor = p_produit
    AND (loc_dateref BETWEEN rubprod.datapli AND NVL(rubprod.datper,loc_dateref) OR loc_dateref < rubprod.datapli)
    AND (rubcntrt.codfrais IS NULL OR (rubcntrt.datper IS NULL and  rubprod.datper IS NOT NULL))
    ORDER BY rubprod.codfrais;

  CURSOR C_ACTE (p_produit GAR_CNTRT.numfor%TYPE, p_contrat GAR_CNTRT.numfor%TYPE)IS
    SELECT calcprod.codfrais prod_codfrais,calcprod.rubrique , calccntrt.codfrais cntrt_codfrais
          ,calcprod.datper prod_datper , calccntrt.datper cntrt_datper, calcprod.datapli prod_datapli,calccntrt.datapli cntrt_datapli
          ,calcprod.nummath prod_math , calcprod.X prod_x, calcprod.Y prod_y, calcprod.type_acte,calcprod.numorg
          ,calccntrt.nummath cntrt_math , calccntrt.X cntrt_x, calccntrt.Y cntrt_y
    FROM  calcul calcprod left outer join calcul calccntrt 
    ON (calcprod.codfrais=calccntrt.codfrais 
      AND calccntrt.numfor = p_contrat
      AND (loc_dateref BETWEEN calccntrt.datapli AND NVL(calccntrt.datper,loc_dateref) OR   loc_dateref < calccntrt.datapli))
    WHERE calcprod.numfor = p_produit
    AND (loc_dateref BETWEEN calcprod.datapli AND NVL(calcprod.datper,loc_dateref) OR loc_dateref < calcprod.datapli)
    AND (calccntrt.codfrais IS NULL 
     OR (calccntrt.datper IS NULL and  calcprod.datper IS NOT NULL)
     OR (NVL(calccntrt.nummath,0) <> NVL(calcprod.nummath,0))
     OR (NVL(calccntrt.X,0) <> NVL(calcprod.X,0))
     OR (NVL(calccntrt.Y,0) <> NVL(calcprod.Y,0))
     )
    AND calcprod.rubrique <>'VIDE'
    AND NOT EXISTS(
     SELECT codfrais from calcul WHERE codfrais = calcprod.codfrais AND numfor = calccntrt.numfor 
      AND ((datapli >= calcprod.datapli  
        AND NVL(calcul.nummath,0) = NVL(calcprod.nummath,0)
        AND NVL(calcul.X,0) = NVL(calcprod.X,0)
        AND NVL(calcul.Y,0) = NVL(calcprod.Y,0)
        AND NVL(datper,e2d('01/01/1900')) = NVL(calcprod.datper,e2d('01/01/1900'))
        )
      OR ( datper = calcprod.datper AND datper IS NOT NULL AND calcprod.datper IS NOT NULL)  
      ))   
    --AND calcprod.codfrais = 'DC'
    ORDER BY calcprod.codfrais,calcprod.datapli;

  CURSOR C_PLAFOND (p_produit GAR_CNTRT.numfor%TYPE, p_contrat GAR_CNTRT.numfor%TYPE)IS
    SELECT maxprod.CODFRAIS pCODFRAIS, maxprod.DATAPLI pDATAPLI, maxprod.DATPER pDATPER ,maxprod.NBACTES pNBACTES,maxprod.MONTANT pMONTANT,maxprod.NUMORG pNUMORG,maxprod.INDICE pINDICE,maxprod.DATREF pDATREF,
    maxprod.NBINDICE pNBINDICE,maxprod.TAUX pTAUX,maxprod.ETENDUE pETENDUE,maxprod.DOMAINE pDOMAINE,maxprod.NUMMATH pNUMMATH,maxprod.NUMMATH_C pNUMMATH_C,
    maxcntrt.CODFRAIS cCODFRAIS, maxcntrt.DATPER cDATPER,maxcntrt.NBACTES cNBACTES,maxcntrt.MONTANT cMONTANT,maxcntrt.NUMORG cNUMORG ,maxcntrt.INDICE cINDICE,maxcntrt.DATREF cDATREF,
    maxcntrt.NBINDICE cNBINDICE,maxcntrt.TAUX cTAUX,maxcntrt.ETENDUE cETENDUE,maxcntrt.DOMAINE cDOMAINE,maxcntrt.NUMMATH cNUMMATH ,maxcntrt.NUMMATH_C cNUMMATH_C
    FROM  maxact maxprod left outer join maxact maxcntrt 
    ON (maxprod.codfrais=maxcntrt.codfrais 
    AND maxcntrt.numfor = p_contrat
    AND (loc_dateref BETWEEN maxcntrt.datapli AND NVL(maxcntrt.datper,loc_dateref) OR   loc_dateref < maxcntrt.datapli))
    WHERE maxprod.numfor = p_produit
    AND (loc_dateref BETWEEN maxprod.datapli AND NVL(maxprod.datper,loc_dateref) OR loc_dateref < maxprod.datapli)
    AND NOT EXISTS(
     SELECT codfrais FROM maxact WHERE codfrais = maxprod.codfrais AND numfor = maxcntrt.numfor 
      AND ((datapli >= maxprod.datapli  
        AND NVL(maxact.NBACTES,0) = NVL(maxprod.NBACTES,0)
        AND NVL(maxact.MONTANT,0) = NVL(maxprod.MONTANT,0)
        AND NVL(maxact.INDICE,0) = NVL(maxprod.INDICE,0)
        AND NVL(maxact.NBINDICE,0) = NVL(maxprod.NBINDICE,0)        
        AND NVL(maxact.TAUX,0) = NVL(maxprod.TAUX,0)
        AND NVL(maxact.ETENDUE,0) = NVL(maxprod.ETENDUE,0)
        AND NVL(maxact.NUMMATH,0) = NVL(maxprod.NUMMATH,0)
        AND NVL(maxact.NUMMATH_C,0) = NVL(maxprod.NUMMATH_C,0)
        AND NVL(maxact.datper,e2d('01/01/1900')) = NVL(maxprod.datper,e2d('01/01/1900'))
        )
      OR ( datper = maxprod.datper AND datper IS NOT NULL AND maxprod.datper IS NOT NULL)  
      ))   
    --AND maxprod.codfrais = 'DC'
    ORDER BY maxprod.codfrais,maxprod.datapli;

  CURSOR C_Texte (p_produit GAR_CNTRT.numfor%TYPE, p_contrat GAR_CNTRT.numfor%TYPE)IS
    SELECT rubprod.codfrais prod_codfrais,rubcntrt.codfrais cntrt_codfrais ,rubprod.def prod_def,rubcntrt.def cntrt_def,
    rubprod.sequence prod_seq,rubcntrt.sequence cntrt_seq,
    calcprod.datapli prod_datapli
    FROM  calcul calcprod, seqrub rubprod left outer join seqrub rubcntrt 
    ON (rubprod.codfrais=rubcntrt.codfrais 
      AND rubcntrt.numfor = p_contrat
      AND rubprod.sequence=rubcntrt.sequence 
     )
    WHERE calcprod.numfor = p_produit
    AND  calcprod.numfor = rubprod.numfor
    AND calcprod.codfrais = rubprod.codfrais
    AND (loc_dateref BETWEEN calcprod.datapli AND NVL(calcprod.datper,loc_dateref) OR loc_dateref < calcprod.datapli)
    AND (rubprod.def <> rubcntrt.def OR rubcntrt.def is NULL)
    --AND rubprod.codfrais = 'DC'
    ORDER BY rubprod.sequence;



  loc_numremise remise_report.NUMREMISE%TYPE;
  v_numfor formule.numfor%TYPE;
  v_gar_debut formule.debut%TYPE;
  v_date     DATE;
  v_datper   DATE;

  exc_remise EXCEPTION;

BEGIN
  -----------------------------------------------------------------------------
  -- Recupération des parametres du traitement
  G_nom_traitement:=i_traitement;
  G_niv_msg:=i_niv_msg;
  G_idligne:=0;
  G_session:=i_session;
  P_INS_journal(1,'Traitement <'||i_traitement||'> de report de paramétrage produit sur contrat');
  -----------------------------------------------------------------------------
  o_found:=0;
  --création d'une nouvelle remise
  BEGIN
  loc_dateref:= NVL(i_dateref,sysdate);
  SELECT numremise_report.nextval INTO loc_numremise FROM DUAL;
  INSERT INTO remise_report
    (NUMREMISE,DATECREA,USERCREA,DATE_REPORT,NUMPROD,NUMFOR_REF,NUMGAR_DEB,NUMGAR_FIN )
  SELECT loc_numremise, sysdate, f_numutil,loc_dateref, NVL(i_numprod,0),i_numfor_ref, i_numgar_deb ,i_numgar_fin FROM DUAL;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE exc_remise;

  END; 
  v_numfor:=NULL;



  --Parcourt du périmètre cible contrat
  FOR REC_C_CNTRT IN C_CNTRT LOOP

    --date d'application garantie REC_C_CNTRT.debut

    /*------------------------------------------------*/
    /*  on compare les FAMILLES d'acte des garanties  
    /* une famille d'acte est soit ouverte soit fermées - aucun autres critères*/
    /*------------------------------------------------*/
    FOR REC_C_RUB IN C_RUB(REC_C_CNTRT.numfor_ref,REC_C_CNTRT.numfor) LOOP
      --par défaut la date d'applicaiton est la date de début couverture de la famille
      v_date :=F_FIND_DATE_ECART(1,REC_C_CNTRT.numfor,REC_C_RUB.prod_codfrais);

      -- nouvelle famille produit type = 6 
      IF REC_C_RUB.cntrt_codfrais IS NULL THEN       
        --famille n'a jamais existée sur le contrat
        IF v_date IS NULL THEN
           v_date := greatest(REC_C_CNTRT.debut,REC_C_RUB.prod_datapli);
           INSERT INTO DEFRUB (numfor, codfrais, datapli,  type_acte)
           SELECT  REC_C_CNTRT.numfor, REC_C_RUB.prod_codfrais ,v_date,REC_C_RUB.type_acte
           FROM DUAL WHERE i_report =1 ;

        --famille déjà paramétrée
        ELSIF v_date IS NOT NULL THEN
          v_datper := F_FIND_DATPER_ECART(1,REC_C_CNTRT.numfor,REC_C_RUB.prod_codfrais,v_date);
          IF v_datper IS NULL THEN --non fermée donc on la ferme
            v_date := greatest(REC_C_CNTRT.debut,REC_C_RUB.prod_datapli,v_date);
            v_datper := v_date-1;
            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                   TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR ,DATE_ECART)
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            7,REC_C_RUB.prod_codfrais,REC_C_RUB.cntrt_codfrais,REC_C_RUB.prod_codfrais,NULL,REC_C_RUB.prod_datapli,REC_C_CNTRT.debut, v_datper FROM DUAL;

            UPDATE CALCUL SET datper = v_datper WHERE datper IS NULL AND codfrais = REC_C_RUB.prod_codfrais AND numfor = REC_C_CNTRT.numfor
            AND i_report =1;
          ELSE--famille fermée
            v_date := greatest(REC_C_CNTRT.debut,REC_C_RUB.prod_datapli,v_datper+1);                    
          END IF;
          --ouverture de la famille
          INSERT INTO DEFRUB (numfor, codfrais, datapli,type_acte )
          SELECT  REC_C_CNTRT.numfor, REC_C_RUB.prod_codfrais ,v_date, REC_C_RUB.type_acte
          FROM DUAL WHERE i_report =1 ;
        END IF;

        INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                   TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR ,DATE_ECART)
        SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
         6,REC_C_RUB.prod_codfrais,REC_C_RUB.cntrt_codfrais,REC_C_RUB.prod_codfrais,NULL,REC_C_RUB.prod_datapli,REC_C_CNTRT.debut, v_date FROM DUAL;

      --Cloture d'une famille produit 7 non fermée sur le contrat      
      ELSIF REC_C_RUB.prod_datper IS NOT NULL AND REC_C_RUB.cntrt_datper IS NULL THEN       
         INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                   TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR,DATE_ECART )
         SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
                7,REC_C_RUB.prod_datper,REC_C_RUB.cntrt_datper,REC_C_RUB.prod_codfrais,NULL,REC_C_RUB.prod_datper,REC_C_CNTRT.debut,REC_C_RUB.prod_datper FROM DUAL;

          UPDATE DEFRUB SET datper = REC_C_RUB.prod_datper WHERE datper IS NULL AND codfrais = REC_C_RUB.prod_codfrais AND numfor = REC_C_CNTRT.numfor
          AND i_report =1;     
      END IF;      
    END LOOP;

    /*------------------------------------------------*/
    /*  on compare les ACTES des garanties            */
    /*------------------------------------------------*/
    FOR REC_C_ACTE IN C_ACTE(REC_C_CNTRT.numfor_ref,REC_C_CNTRT.numfor) LOOP
      --identification de la date max d'application de l'acte
      v_date :=F_FIND_DATE_ECART(2,REC_C_CNTRT.numfor,REC_C_ACTE.prod_codfrais);
      -- nouvelle couverture produit type = 1, clef=REC_C_ACTE.prod_codfrais , date d'application produit REC_C_ACTE.prod_datapli
      IF REC_C_ACTE.cntrt_codfrais IS NULL THEN  
        --acte inexistant donc non paramétré du tout
        IF v_date IS NULL THEN
           v_date := greatest(REC_C_CNTRT.debut,REC_C_ACTE.prod_datapli);

        --acte déjà paramétré mais fermé dans le passé
        ELSIF v_date IS NOT NULL THEN
          v_datper := F_FIND_DATPER_ECART(2,REC_C_CNTRT.numfor,REC_C_ACTE.prod_codfrais,v_date);

          IF v_datper IS NULL THEN --non fermé
            v_date := greatest(REC_C_CNTRT.debut,REC_C_ACTE.prod_datapli,v_date);
            v_datper := v_date-1;

            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                         TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR ,DATE_ECART)
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            2,REC_C_ACTE.prod_datper,REC_C_ACTE.cntrt_datper,REC_C_ACTE.prod_codfrais,NULL,REC_C_ACTE.prod_datper,REC_C_CNTRT.debut,v_datper FROM DUAL;

            UPDATE CALCUL SET datper = v_datper WHERE datper IS NULL AND codfrais = REC_C_ACTE.prod_codfrais AND numfor = REC_C_CNTRT.numfor
            AND i_report =1;

          ELSE
            v_date := greatest(REC_C_CNTRT.debut,REC_C_ACTE.prod_datapli,v_datper+1);             
          END IF;

        END IF;

        --création de la nouvelle couverture
        INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                 TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR ,DATE_ECART)
        SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
        1,REC_C_ACTE.prod_codfrais,REC_C_ACTE.cntrt_codfrais,REC_C_ACTE.prod_codfrais,NULL,REC_C_ACTE.prod_datapli,REC_C_CNTRT.debut,v_date FROM DUAL;

        INSERT INTO CALCUL (numfor, codfrais, datapli, datper, numorg, nummath, type_acte,rubrique, X, Y )
        SELECT  REC_C_CNTRT.numfor, REC_C_ACTE.prod_codfrais ,v_date,REC_C_ACTE.prod_datper, REC_C_ACTE.numorg,REC_C_ACTE.prod_math ,
        REC_C_ACTE.type_acte,REC_C_ACTE.rubrique,REC_C_ACTE.prod_X,REC_C_ACTE.prod_Y
        FROM DUAL WHERE i_report =1 ;

      --modification de la couverture existante => on historise systématiquement ou rien
      ELSE 
        --Cloture d'un acte produit  type = 2 clef=REC_C_ACTE.prod_codfrais date d'application est celle du produit REC_C_ACTE.prod_datper
        IF REC_C_ACTE.prod_datper IS NOT NULL AND REC_C_ACTE.cntrt_datper IS NULL THEN
          IF REC_C_ACTE.prod_datper  >=  REC_C_ACTE.cntrt_datapli THEN
            v_datper := REC_C_ACTE.prod_datper;
          ELSE v_datper:=NULL;
          END IF;

          INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                         TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR ,DATE_ECART)
          SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
          2,REC_C_ACTE.prod_datper,REC_C_ACTE.cntrt_datper,REC_C_ACTE.prod_codfrais,NULL,REC_C_ACTE.prod_datper,REC_C_CNTRT.debut,v_datper FROM DUAL;

          --On met à jour la datper de l'ancienne ligne de paramétrage que si la datper > datapli
          UPDATE CALCUL SET datper = v_datper WHERE datper IS NULL AND codfrais = REC_C_ACTE.prod_codfrais AND numfor = REC_C_CNTRT.numfor
          AND v_datper is not NULL
          AND i_report =1;

        END IF;

        --la date d'écart doit tenir compte du paramétrage contrat. Pour ne pas créer de doublon de couverture on sécurise à prod_datapli>= v_date 
        -- on ne reporte les modfications que si le produit est historisé
        IF REC_C_ACTE.prod_datper IS NULL AND v_date IS NOT NULL THEN  
          --la couverture produit non historisée ne doit pas écrasé celle du contrat, on remonte juste les écarts 
          -- v_date étant la date de la dernière couverture elle ne peut être >= à la date d'application de la couverture produit
          IF  v_date < greatest(REC_C_CNTRT.debut,REC_C_ACTE.prod_datapli) THEN           
            v_date := greatest(REC_C_CNTRT.debut,REC_C_ACTE.prod_datapli);
            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                               TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR, DATE_ECART)
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            1,REC_C_ACTE.prod_codfrais,REC_C_ACTE.cntrt_codfrais,REC_C_ACTE.prod_codfrais,NULL,REC_C_ACTE.prod_datapli,REC_C_CNTRT.debut,v_date FROM DUAL;


            --On insère la ligne de paramétrage produit sur le contrat
            INSERT INTO CALCUL (numfor, codfrais, datapli,datper, numorg, nummath, type_acte,rubrique, X, Y )
            SELECT  REC_C_CNTRT.numfor, REC_C_ACTE.prod_codfrais ,v_date,REC_C_ACTE.prod_datper,REC_C_ACTE.numorg,REC_C_ACTE.prod_math ,
            REC_C_ACTE.type_acte,REC_C_ACTE.rubrique,REC_C_ACTE.prod_X,REC_C_ACTE.prod_Y
            FROM DUAL WHERE i_report =1 ;
          END IF;

          -- Formule de prestation différente type = 3 clef REC_C_ACTE.codfrais date d'application produit REC_C_ACTE.prod_datapli
          IF NVL(REC_C_ACTE.prod_math ,0) <> NVL(REC_C_ACTE.cntrt_math,0) THEN 
            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                               TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR, DATE_ECART)
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            3,REC_C_ACTE.prod_math,REC_C_ACTE.cntrt_math,REC_C_ACTE.prod_codfrais,NULL,REC_C_ACTE.prod_datapli,REC_C_CNTRT.debut,v_date FROM DUAL;

          END IF;

           -- Variable X de prestation différente type = 4 clef REC_C_ACTE.codfrais date d'application produit REC_C_ACTE.datapli
          IF NVL(REC_C_ACTE.prod_x ,0) <> NVL(REC_C_ACTE.cntrt_x,0) THEN 
            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                               TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR, DATE_ECART)
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            4,REC_C_ACTE.prod_x,REC_C_ACTE.cntrt_x,REC_C_ACTE.prod_codfrais,NULL,REC_C_ACTE.prod_datapli,REC_C_CNTRT.debut,v_date FROM DUAL;

          END IF;

           -- Variable Y de prestation différente type = 5 clef REC_C_ACTE.codfrais date d'application produit REC_C_ACTE.datapli
          IF NVL(REC_C_ACTE.prod_y ,0) <> NVL(REC_C_ACTE.cntrt_y,0) THEN 
            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                               TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR, DATE_ECART)
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            5,REC_C_ACTE.prod_y,REC_C_ACTE.cntrt_y,REC_C_ACTE.prod_codfrais,NULL,REC_C_ACTE.prod_datapli,REC_C_CNTRT.debut,v_date FROM DUAL;
          END IF;                                   
        END IF;
      END IF;
    END LOOP;

  --IF  REC_C_ACTE.prod_datper IS  NULL THEN
    /*------------------------------------------------*/
    /*  on compare les TEXTE d'acte uniquement si un acte a eu une modification  et si le produit est en cours*/
    /*------------------------------------------------*/
    FOR REC_C_TEXTE IN C_TEXTE(REC_C_CNTRT.numfor_ref,REC_C_CNTRT.numfor) LOOP
      --par défaut la date d'applicaiton est la date trouvée pour l'acte


      IF REC_C_TEXTE.cntrt_codfrais IS NULL OR REC_C_TEXTE.cntrt_seq IS NULL THEN
        -- nouveau texte type =17 , clef=REC_C_TEXTE.prod_codfrais  pour acte inexistante ou nouvelle ligne de texte
        INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                 TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR ,DATE_ECART)
        SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
        17,substr(REC_C_TEXTE.prod_def,0,30),substr(REC_C_TEXTE.cntrt_def,0,30),REC_C_TEXTE.prod_codfrais,REC_C_TEXTE.prod_seq,REC_C_TEXTE.prod_datapli,REC_C_CNTRT.debut, v_date FROM DUAL;

        INSERT INTO SEQRUB (numfor, codfrais, def,sequence)
        SELECT  REC_C_CNTRT.numfor, REC_C_TEXTE.prod_codfrais ,REC_C_TEXTE.prod_def, REC_C_TEXTE.prod_seq
        FROM DUAL WHERE i_report =1 
		AND NOT EXISTS (SELECT numfor FROM SEQRUB WHERE numfor =REC_C_CNTRT.numfor and codfrais = REC_C_TEXTE.prod_codfrais and sequence =REC_C_TEXTE.prod_seq) ;  

      ELSE
        -- modification texte existant  type =18 , clef=REC_C_TEXTE.prod_codfrais , date d'application de l'acte    
        INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                 TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR ,DATE_ECART)
        SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
        18,substr(REC_C_TEXTE.prod_def,0,30),substr(REC_C_TEXTE.cntrt_def,0,30),REC_C_TEXTE.prod_codfrais,REC_C_TEXTE.prod_seq,REC_C_TEXTE.prod_datapli,REC_C_CNTRT.debut, v_date FROM DUAL;

        UPDATE  SEQRUB set def = REC_C_TEXTE.prod_def
        WHERE numfor=  REC_C_CNTRT.numfor AND codfrais = REC_C_TEXTE.prod_codfrais AND sequence = REC_C_TEXTE.prod_seq
        AND i_report =1 ;     
      END IF;      
    END LOOP;
  --END IF;




    /*------------------------------------------------*/
    /*  on compare les PLAFONDS des ACTES             */
    /*------------------------------------------------*/
    FOR REC_C_PLAFOND IN C_PLAFOND(REC_C_CNTRT.numfor_ref,REC_C_CNTRT.numfor) LOOP
      --par défaut la date d'applicaiton est la date de début plafond de l'acte
      v_date :=F_FIND_DATE_ECART(3,REC_C_CNTRT.numfor,REC_C_PLAFOND.pCODFRAIS);

      -- nouveau plafond acte  type = 8, clef=REC_C_PLAFOND.prod_codfrais , date d'application produit REC_C_PLAFOND.pdatapli
      IF REC_C_PLAFOND.cCODFRAIS IS NULL THEN
        IF v_date IS NULL THEN
          v_date := greatest(REC_C_CNTRT.debut,REC_C_PLAFOND.pdatapli);

        --acte déjà paramétré mais fermé dans le passé
        ELSIF v_date IS NOT NULL THEN
          v_datper := F_FIND_DATPER_ECART(3,REC_C_CNTRT.numfor,REC_C_PLAFOND.pcodfrais,v_date);

          IF v_datper IS NULL THEN --non fermé
            v_date := greatest(REC_C_CNTRT.debut,REC_C_PLAFOND.pdatapli,v_date);
            v_datper := v_date-1;

            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                     TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR,DATE_ECART )
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            9,REC_C_PLAFOND.pCODFRAIS,REC_C_PLAFOND.cCODFRAIS,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatper,REC_C_CNTRT.debut,v_datper FROM DUAL;

            UPDATE MAXACT SET datper = v_datper WHERE datper IS NULL AND codfrais = REC_C_PLAFOND.pcodfrais AND numfor = REC_C_CNTRT.numfor
            AND i_report =1;
          ELSE
            v_date := greatest(REC_C_CNTRT.debut,REC_C_PLAFOND.pdatapli,v_datper+1);                    
          END IF;      
        END IF;       

        INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                   TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR,DATE_ECART )
        SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
        8,REC_C_PLAFOND.pCODFRAIS,REC_C_PLAFOND.cCODFRAIS,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatapli,REC_C_CNTRT.debut,v_date FROM DUAL;

        INSERT INTO MAXACT (NUMFOR, CODFRAIS, DATAPLI,DATPER,NBACTES, MONTANT, NUMORG, INDICE,DATREF,NBINDICE,TAUX,ETENDUE,DOMAINE,NUMMATH,NUMMATH_C)
        SELECT  REC_C_CNTRT.numfor, REC_C_PLAFOND.pcodfrais ,v_date,REC_C_PLAFOND.pdatper, REC_C_PLAFOND.pNBACTES, REC_C_PLAFOND.pMONTANT, REC_C_PLAFOND.pNUMORG,REC_C_PLAFOND.pINDICE,
        REC_C_PLAFOND.pDATREF,REC_C_PLAFOND.pNBINDICE,REC_C_PLAFOND.pTAUX,REC_C_PLAFOND.pETENDUE,REC_C_PLAFOND.pDOMAINE,REC_C_PLAFOND.pNUMMATH,REC_C_PLAFOND.pNUMMATH_C
        FROM DUAL WHERE i_report =1 ;

      --plafond existant
      ELSE       
        --historisation du plafond
        IF REC_C_PLAFOND.pDATPER IS NOT NULL AND REC_C_PLAFOND.pDATPER <> NVL(REC_C_PLAFOND.cDATPER,e2d('01/01/1900')) THEN
          IF REC_C_PLAFOND.pDATPER >= NVL(REC_C_PLAFOND.cDATPER,e2d('01/01/1900')) THEN
            v_datper := REC_C_PLAFOND.pDATPER;
          ELSE v_datper:=NULL;
          END IF;

          UPDATE MAXACT SET datper = v_datper WHERE datper IS NULL AND codfrais = REC_C_PLAFOND.pcodfrais AND numfor = REC_C_CNTRT.numfor
          AND i_report =1;

          INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                     TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR,DATE_ECART )
          SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
          9,REC_C_PLAFOND.pCODFRAIS,REC_C_PLAFOND.cCODFRAIS,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatper,REC_C_CNTRT.debut,v_datper FROM DUAL;
        END IF;


        IF  REC_C_PLAFOND.pDATPER IS NULL AND v_date IS NOT NULL THEN      
          --le plafond produit non historisé ne doit pas écrasé le plafond contrat, on remonte juste les écarts 
          -- v_date étant la date du dernier plafond elle ne peut être >= à la date d'application du plafond produit
          IF  v_date < greatest(REC_C_CNTRT.debut,REC_C_PLAFOND.pdatapli) THEN   
            v_date := greatest(REC_C_CNTRT.debut,REC_C_PLAFOND.pdatapli);

            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                   TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR,DATE_ECART )
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            8,REC_C_PLAFOND.pCODFRAIS,REC_C_PLAFOND.cCODFRAIS,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatapli,REC_C_CNTRT.debut,v_date FROM DUAL;

            INSERT INTO MAXACT (NUMFOR, CODFRAIS, DATAPLI,DATPER,NBACTES, MONTANT, NUMORG, INDICE,DATREF,NBINDICE,TAUX,ETENDUE,DOMAINE,NUMMATH,NUMMATH_C)
            SELECT  REC_C_CNTRT.numfor, REC_C_PLAFOND.pcodfrais ,v_date,REC_C_PLAFOND.pdatper, REC_C_PLAFOND.pNBACTES, REC_C_PLAFOND.pMONTANT, REC_C_PLAFOND.pNUMORG,REC_C_PLAFOND.pINDICE,
            REC_C_PLAFOND.pDATREF,REC_C_PLAFOND.pNBINDICE,REC_C_PLAFOND.pTAUX,REC_C_PLAFOND.pETENDUE,REC_C_PLAFOND.pDOMAINE,REC_C_PLAFOND.pNUMMATH,REC_C_PLAFOND.pNUMMATH_C
            FROM DUAL WHERE i_report =1 ;    

          END IF;


          IF NVL(REC_C_PLAFOND.pNBACTES,0) <> NVL(REC_C_PLAFOND.cNBACTES,0) THEN
            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                       TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR ,DATE_ECART)
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            10,REC_C_PLAFOND.pNBACTES,REC_C_PLAFOND.cNBACTES,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatapli,REC_C_CNTRT.debut,v_date FROM DUAL;
          END IF;

          IF NVL(REC_C_PLAFOND.pMONTANT,0) <> NVL(REC_C_PLAFOND.cMONTANT,0) THEN
            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                       TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR,DATE_ECART )
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            10,REC_C_PLAFOND.pMONTANT,REC_C_PLAFOND.cMONTANT,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatapli,REC_C_CNTRT.debut,v_date FROM DUAL;
          END IF;

          IF NVL(REC_C_PLAFOND.pNUMORG,0) <> NVL(REC_C_PLAFOND.cNUMORG,0) THEN
            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                       TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR,DATE_ECART )
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            10,REC_C_PLAFOND.pNUMORG,REC_C_PLAFOND.cNUMORG,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatapli,REC_C_CNTRT.debut,v_date FROM DUAL;
          END IF;

          IF NVL(REC_C_PLAFOND.pINDICE,0) <> NVL(REC_C_PLAFOND.cINDICE,0) THEN
           INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                       TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR,DATE_ECART )
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            10,REC_C_PLAFOND.pINDICE,REC_C_PLAFOND.cINDICE,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatapli,REC_C_CNTRT.debut,v_date FROM DUAL;
          END IF;

          IF NVL(REC_C_PLAFOND.pDATREF,e2d('01/01/1900')) <> NVL(REC_C_PLAFOND.cDATREF,e2d('01/01/1900')) THEN
           INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                       TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR,DATE_ECART )
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            10,REC_C_PLAFOND.pDATREF,REC_C_PLAFOND.cDATREF,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatapli,REC_C_CNTRT.debut,v_date FROM DUAL;
          END IF;

          IF NVL(REC_C_PLAFOND.pNBINDICE,0) <> NVL(REC_C_PLAFOND.cNBINDICE,0) THEN
            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                       TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR ,DATE_ECART)
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            10,REC_C_PLAFOND.pNBINDICE,REC_C_PLAFOND.cNBINDICE,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatapli,REC_C_CNTRT.debut,v_date FROM DUAL;
          END IF;

          IF NVL(REC_C_PLAFOND.pTAUX,0) <> NVL(REC_C_PLAFOND.cTAUX,0) THEN
            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                       TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR ,DATE_ECART)
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            10,REC_C_PLAFOND.pTAUX,REC_C_PLAFOND.cTAUX,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatapli,REC_C_CNTRT.debut,v_date FROM DUAL;
          END IF;

          IF NVL(REC_C_PLAFOND.pETENDUE,0) <> NVL(REC_C_PLAFOND.cETENDUE,0) THEN
            INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                       TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR ,DATE_ECART)
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            10,REC_C_PLAFOND.pETENDUE,REC_C_PLAFOND.cETENDUE,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatapli,REC_C_CNTRT.debut,v_date FROM DUAL;
          END IF;

          IF NVL(REC_C_PLAFOND.pDOMAINE,0) <> NVL(REC_C_PLAFOND.cDOMAINE,0) THEN
           INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                       TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR ,DATE_ECART)
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            10,REC_C_PLAFOND.pDOMAINE,REC_C_PLAFOND.cDOMAINE,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatapli,REC_C_CNTRT.debut,v_date FROM DUAL;
          END IF;

          IF NVL(REC_C_PLAFOND.pNUMMATH,0) <> NVL(REC_C_PLAFOND.cNUMMATH,0) THEN
           INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                       TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR,DATE_ECART )
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            10,REC_C_PLAFOND.pNUMMATH,REC_C_PLAFOND.cNUMMATH,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatapli,REC_C_CNTRT.debut,v_date FROM DUAL;
          END IF;

          IF NVL(REC_C_PLAFOND.pNUMMATH_C,0) <> NVL(REC_C_PLAFOND.cNUMMATH_C,0) THEN
           INSERT INTO histo_report (NUMREMISE,NUMPROD,NUMFOR_REF,NUMGAR,NUMFOR,
                                       TYPE_ECART,VAL_PROD,VAL_GAR,CLEF1,CLEF2,DATE_PROD,DATE_GAR,DATE_ECART )
            SELECT loc_numremise, NVL(i_numprod,0), REC_C_CNTRT.numfor_ref, REC_C_CNTRT.numgar,REC_C_CNTRT.numfor,
            10,REC_C_PLAFOND.pNUMMATH_C,REC_C_PLAFOND.cNUMMATH_C,REC_C_PLAFOND.pCODFRAIS,NULL,REC_C_PLAFOND.pdatapli,REC_C_CNTRT.debut,v_date FROM DUAL;
          END IF;
        END IF;
      END IF;
    END LOOP;


    --cas problématiques de plafonds
    /*select * from maxact where numfor =2140 and codfrais='LENJ'
    UNION 
    select * from maxact where numfor =2 and codfrais='LENJ';*/




    --Attention à la date de mise en effet date_ecart qui doit tenir compte du fait qu'un acte a pu déjà vivre depuis le début de la garantie

  END LOOP;

  -- Génération du fichier csv
  P_export_report_param_produit( G_nom_traitement,
                                loc_numremise,
                                loc_dateref,
                                 G_session,
                                 G_niv_msg,
                                 o_erreur);



  COMMIT;

  EXCEPTION
    WHEN exc_remise THEN
      P_INS_journal(1,'Création de la remise de report de paramétrage impossible : '||SQLERRM);
      dbms_output.put_line('Création de la remise de report de paramétrage impossible'||SQLERRM);
      o_found:=1;
      ROLLBACK;
    WHEN OTHERS THEN
      P_INS_journal(1,'Erreur d''exécution'||SQLERRM);
      dbms_output.put_line('Erreur d''exécution'||SQLERRM);
      o_found:=1;
      ROLLBACK;
END P_report_param_produit;

FUNCTION F_FIND_DATE_ECART(i_TYPE    IN NUMBER,  
                           i_numfor  IN GAR_CNTRT.numfor%TYPE,
                           i_codfrais IN natfrais.codfrais%TYPE)
RETURN DATE IS

 l_date_ecart DATE;
BEGIN
  --famille 
  IF i_TYPE = 1 THEN
    BEGIN
      SELECT MAX(datapli) INTO l_date_ecart FROM DEFRUB
      WHERE numfor = i_numfor
      AND codfrais = i_codfrais
      ;
    EXCEPTION
        WHEN OTHERS THEN l_date_ecart:= NULL;
    END;
  --codfrais
  ELSIF i_TYPE = 2 THEN
    BEGIN
      SELECT MAX(datapli) INTO l_date_ecart FROM CALCUL
      WHERE numfor = i_numfor
      AND codfrais = i_codfrais
      ;
    EXCEPTION
      WHEN OTHERS THEN l_date_ecart:= NULL;
    END;
  --maxact
  ELSIF i_TYPE = 3 THEN
    BEGIN
      SELECT MAX(datapli) INTO l_date_ecart FROM MAXACT
      WHERE numfor = i_numfor
      AND codfrais = i_codfrais
      ;
    EXCEPTION
      WHEN OTHERS THEN l_date_ecart:= NULL;
    END;

  ELSE NULL;

  END IF;
  RETURN l_date_ecart;

END F_FIND_DATE_ECART;  

FUNCTION F_FIND_DATPER_ECART(i_TYPE    IN NUMBER,  
                             i_numfor  IN GAR_CNTRT.numfor%TYPE,
                                         i_codfrais IN natfrais.codfrais%TYPE,
                             i_datapli IN DATE) 
RETURN DATE IS
 l_datper DATE;
BEGIN
  --famille 
  IF i_TYPE = 1 THEN
    BEGIN
      SELECT MAX(datper) INTO l_datper FROM DEFRUB
      WHERE numfor = i_numfor
      AND codfrais = i_codfrais
      AND datper IS NOT NULL
      AND datapli = NVL(i_datapli,datapli)
      ;
    EXCEPTION
        WHEN OTHERS THEN l_datper:= NULL;
    END;    
  --codfrais
  ELSIF i_TYPE = 2 THEN
    BEGIN
      SELECT MAX(datper) INTO l_datper FROM CALCUL
      WHERE numfor = i_numfor
      AND codfrais = i_codfrais
      AND datper IS NOT NULL
      AND datapli = NVL(i_datapli,datapli)
      ;
    EXCEPTION
        WHEN OTHERS THEN l_datper:= NULL;
    END;    
   ELSIF i_TYPE = 3 THEN
    BEGIN
      SELECT MAX(datper) INTO l_datper FROM MAXACT
      WHERE numfor = i_numfor
      AND codfrais = i_codfrais
      AND datper IS NOT NULL
      AND datapli = NVL(i_datapli,datapli)
      ;
    EXCEPTION
        WHEN OTHERS THEN l_datper:= NULL;
    END;    
  ELSE NULL;

  END IF;
  RETURN l_datper;

END F_FIND_DATPER_ECART;



/*SELECT  gar_cntrt.numgar, gar_cntrt.numfor,gar_cntrt.libelle,gar_cntrt.debut,gar_cntrt.numfor_ref 
FROM v_gar_cntrt gar_cntrt, v_gar gar_prdt
WHERE gar_prdt.clef = :i_numprod 
AND gar_prdt.etendue =7 
AND gar_prdt.typfor =1 --garantie santé uniquement
AND SYSDATE between gar_prdt.datapli AND NVL(gar_prdt.datper,SYSDATE)
AND gar_prdt.numfor = NVL(:i_numfor_ref,gar_prdt.numfor) --paramètre non obligatoire
AND gar_prdt.numfor = gar_cntrt.numfor_ref
AND gar_cntrt.numgar BETWEEN NVL(:i_numgar_deb,gar_cntrt.numgar) AND NVL(:i_numgar_fin,gar_cntrt.numgar)
AND SYSDATE BETWEEN gar_cntrt.debut AND NVL(gar_cntrt.fin,SYSDATE)
order by gar_cntrt.numgar, gar_cntrt.numfor;

SELECT rubprod.codfrais prod_codfrais,rubcntrt.codfrais cntrt_codfrais , rubprod.datper prod_datper , rubcntrt.datper cntrt_datper, rubprod.datapli prod_datapli
FROM  defrub rubprod left outer join defrub rubcntrt 
ON (rubprod.codfrais=rubcntrt.codfrais 
  AND rubcntrt.numfor = 2140
  AND (sysdate BETWEEN rubcntrt.datapli AND NVL(rubcntrt.datper,sysdate) OR   sysdate < rubcntrt.datapli))
WHERE rubprod.numfor = 2
AND (sysdate BETWEEN rubprod.datapli AND NVL(rubprod.datper,sysdate) OR sysdate < rubprod.datapli)
AND (rubcntrt.codfrais IS NULL OR (rubcntrt.datper IS NULL and  rubprod.datper IS NOT NULL))
ORDER BY rubprod.codfrais;

*/

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_dynamic_compare                             */
/* Type         :  Public                                                    */
/* Description  :         */
/*                                                                           */
/* Entree       :  i_numremise, numéro de remise unique à exporter           */
/*                 i_numgar_deb numéro de contrat cible de début ou unique   */
/*                 i_numgar_fin, numéro de contrat cible de fin              */
/*                 i_numfor, numéro de la garantie produit                   */               
/*---------------------------------------------------------------------------*/

/*PROCEDURE P_dynamic_compare(i_table IN varchar2,tab_modIF OUT TAB_T_REC_modif) IS


  --tab_modIF  TAB_T_REC_modif;
  cpt number;
  plsql_block varchar2(32000);
  prod_plfd maxact%ROWTYPE;
  cntrt_plfd maxact%ROWTYPE;


BEGIN
  plsql_block:=plsql_block||'declare'||chr(10);
  plsql_block:=plsql_block||'cpt number;'||chr(10);
  plsql_block:=plsql_block||'plsql_block varchar2(32000);'||chr(10);
  plsql_block:=plsql_block||'prod_plfd maxact%ROWTYPE;'||chr(10);
  plsql_block:=plsql_block||'cntrt_plfd maxact%ROWTYPE;'||chr(10);  
  plsql_block:=plsql_block||'begin'||chr(10);
      FOR i IN (SELECT column_name,data_type FROM user_tab_columns WHERE table_name=upper(i_table)) LOOP
          IF  i.data_type='DATE' THEN
            plsql_block:=plsql_block||' IF NVL(prod_plfd.'||i.column_name||',e2d(''01/01/1900'')) <> NVL(cntrt_plfd.'||i.column_name||',e2d(''01/01/1900'')) THEN'||chr(10);
          ELSE 
            plsql_block:=plsql_block||' IF NVL(prod_plfd.'||i.column_name||',0) <> NVL(cntrt_plfd.'||i.column_name||',0) THEN'||chr(10);
          END IF; 
           plsql_block:=plsql_block||'      tab_modif(cpt).fieldName:='''||i.column_name||''';'||chr(10);
           plsql_block:=plsql_block||'      tab_modif(cpt).prod_value:=prod_plfd.'||i.column_name||';'||chr(10);
           plsql_block:=plsql_block||'      tab_modif(cpt).cntrt_value:=cntrt_plfd.'||i.column_name||';'||chr(10);
         --  plsql_block:=plsql_block||'      tab_modif.extend;'||chr(10);
           plsql_block:=plsql_block||'      cpt:=cpt+1;'||chr(10);
           plsql_block:=plsql_block||'   END IF;'||chr(10)||chr(10);

      END LOOP;
      plsql_block:=plsql_block||'tab_modif.trim();'||chr(10);

     -- plsql_block:=plsql_block||'end;';
      dbms_output.put_line(plsql_block);
      execute immediate plsql_block;
      plsql_block:='';

END;*/

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_export_report_param_produit                             */
/* Type         :  Public                                                    */
/* Description  :  Permet d exporter les écarts de paramétrage de produits ou*/
/*                 garanties dans un fichiers au format csv                  */
/* Entree       :  i_numremise, n° unique de remise de report                */
/*                 i_fichier , fichier                                       */
/* Retour       :  o_erreur, Message d erreur en cas d echec                 */
/*---------------------------------------------------------------------------*/
PROCEDURE P_export_report_param_produit( i_traitement   IN    TYP_BATCH.BATCHID%TYPE,
                                         i_numremise    IN    HISTO_REPORT.NUMREMISE%TYPE,
                                         i_dateref      IN    DATE,
                                         i_session      IN    NUMBER,
                                         i_niv_msg      IN    NUMBER DEFAULT 1,
                                         o_erreur       OUT   VARCHAR2)
IS

  b_ok                BOOLEAN:=FALSE;

  i_repertoire        TYP_BATCH.REPERTOIRE%TYPE:=NULL;
  i_fichier           TYP_BATCH.RESSOURCE%TYPE:=NULL;

BEGIN

  -----------------------------------------------------------------------------
  -- Recupération des parametres du traitement
  G_nom_traitement:=i_traitement;
  G_niv_msg:=i_niv_msg;
  G_session:=i_session;

  -----------------------------------------------------------------------------
  -- Recupération du répertoire du fichier, et nommage du fichier en fonction du nom de traitement
--  BEGIN
  SELECT t.REPERTOIRE
       , REPLACE( t.RESSOURCE,t.RESSOURCE, t.RESSOURCE||'_'||t.batchid)||'_'||TO_CHAR(i_numremise)||'.csv'
    INTO i_repertoire
       , i_fichier
    FROM typ_batch t
   WHERE t.batchid=TRIM(i_traitement);

--  EXCEPTION
--    WHEN OTHERS THEN
--  END;

  P_INS_journal(1,'Début Traitement <'||i_traitement||'>'||', Répertoire <'||i_repertoire||'>'||', Fichier <'||i_fichier||'>');
  P_INS_journal(1,'Traitement de la remise <'||i_numremise||'>');


  -- Création du fichier
  b_ok:= f_creationFichier(i_repertoire,i_fichier, i_numremise,i_dateref, o_erreur);


  P_INS_journal(1,'Veuillez consulter le rapport simplifié ou détaillé');
  P_INS_journal(1,'Fin Traitement <'||i_traitement||'>');


EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal('TR18T',SUBSTR(SQLERRM,1,132));
END P_export_report_param_produit;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  f_creationFichier                                         */
/* Type         :  Privee                                                    */
/* Description  :  Création flux quotidiens au format csv                    */
/* Entree       :  i_repertoire, répertoire IMPORT                           */
/*                 i_fichier, Nom du fichier                                 */
/*                 i_numremise: numéro de remise                             */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*                 FALSE/TRUE                                                */
/*---------------------------------------------------------------------------*/
FUNCTION f_creationFichier( i_repertoire   IN    TYP_BATCH.REPERTOIRE%TYPE,
                            i_fichier      IN    TYP_BATCH.RESSOURCE%TYPE,
                            i_numremise    IN    HISTO_REPORT.NUMREMISE%TYPE,
                            i_dateref      IN    DATE,
                            o_erreur       OUT   VARCHAR2)
RETURN BOOLEAN
IS

  loc_ok     BOOLEAN;

BEGIN

  -- Formatage du nom du fichier
  -- TODO : A réaliser??


  -- Ouverture
  f_sortie := UTL_FILE.fopen (i_repertoire, i_fichier, 'W', 32767);

  IF i_repertoire IS NULL THEN
     RAISE e_par_repertoire_vide;
  END IF;

  IF i_fichier IS NULL OR i_fichier = ''
  THEN
     RAISE e_par_fichier_vide;
  END IF;

  -- Ecriture de l entête ainsi que chaque ligne du fichier
  loc_ok:=ecrireLigne(i_repertoire,i_fichier,i_numremise,i_dateref);

  -- Fermeture du fichier
  UTL_FILE.fclose (f_sortie);

  IF loc_ok THEN
    P_INS_journal(1,'Fin normale de génération du fichier <'||i_fichier||'> dans le répertoire <'||i_repertoire||'>.');
  ELSE
    P_INS_journal(1,'Fin anormale de génération du fichier <'||i_fichier||'> dans le répertoire <'||i_repertoire||'>.');
  END IF;

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
    P_INS_journal(1,'TR18T - ' || SUBSTR (SQLERRM (SQLCODE), 1, 128));
    IF UTL_FILE.is_open (f_sortie) THEN
      UTL_FILE.fclose (f_sortie);
    END IF;
    o_erreur:='TR18T - ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
    RETURN FALSE;
END f_creationFichier;

----------------------------------------------------------------------------
-- Procedure EcrireEntete
-- Ecrire l'entete d un fichier a generer
----------------------------------------------------------------------------
PROCEDURE EcrireEntete( ih_fichier IN UTL_FILE.file_type)
IS
  loc_ok     BOOLEAN;

BEGIN

  IF UTL_FILE.is_open(ih_fichier) THEN
    loc_ok:=PK_FICHIER.fPutLine(ih_fichier
          ,  'NUMREMISE'
          || I_DELIMITEUR
          || 'PRODUIT'
          || I_DELIMITEUR
          || 'NUMFOR_REF'
          || I_DELIMITEUR
          || 'CONTRAT'
          || I_DELIMITEUR
          || 'NUMFOR'
          || I_DELIMITEUR
          || 'DATE_CIBLE'
          || I_DELIMITEUR
          || 'FAMILLE_PRODUIT'
          || I_DELIMITEUR
          || 'DOMAINE'
          || I_DELIMITEUR
          || 'TYPE_ECART'
          || I_DELIMITEUR
          || 'LIB_ECART'
          || I_DELIMITEUR
          || 'VAL_PRODUIT'
          || I_DELIMITEUR
          || 'VAL_CIBLE'
          || I_DELIMITEUR
          || 'CONTEXTE'
          || I_DELIMITEUR
          || 'DATE_PRODUIT'
          || I_DELIMITEUR
          || 'DATE_ECART'
          || I_DELIMITEUR
          );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'Fin du traitement EcrireEntete KO:' || SQLERRM);
END EcrireEntete;

--------------------------------------------------------------------------------
-- FONCTION ecrireLigne
-- Extraction de toutes les données de la table HISTO_REPORT  pour une remise dans un
-- fichier
-- Retourne TRUE si le traitement c'est bien passe, FALSE dans le contraire
--------------------------------------------------------------------------------
FUNCTION ecrireLigne( i_repertoire   IN    TYP_BATCH.REPERTOIRE%TYPE,
                      i_fichier      IN    TYP_BATCH.RESSOURCE%TYPE,
                      i_numremise    IN    HISTO_REPORT.NUMREMISE%TYPE,
                      i_dateref      IN    DATE)
RETURN BOOLEAN
IS

  s_fichier             VARCHAR2(50):='';
  h_fichier             UTL_FILE.file_type;
  loc_ok                BOOLEAN;
  loc_cpt               NUMBER:=0;

  -- Liste des écarts d une remise
  CURSOR c_REMISE_EXPORT
     IS
  SELECT distinct h.numremise
       , h.numprod
       , h.numfor_ref
       , h.numgar
       , h.numfor
       , to_char(h.DATE_GAR,'DD/MM/YYYY') date_garantie
       , c.rubrique famille_produit
       , 'Acte' domaine
       , h.type_ecart
       , PK_LIBELLE.F_LIB('TYP_REPORT',h.TYPE_ECART) lib_ecart
       , h.val_prod val_produit
       , h.val_gar val_cible
       , h.clef1 contexte
       , to_char(h.date_prod,'DD/MM/YYYY') date_produit
       , to_char(h.date_ecart,'DD/MM/YYYY') date_ecart
    FROM histo_report h , natfrais n, calcul c
   WHERE numremise =i_numremise
     AND n.codfrais= h.clef1
    AND n.codfrais<>n.rubrique
     AND c.codfrais = h.clef1
     AND c.numfor = h.numfor_ref
     AND (i_dateref BETWEEN c.datapli AND NVL(c.datper,i_dateref) OR c.datapli>= i_dateref)
  UNION
  SELECT distinct h.numremise
       , h.numprod
       , h.numfor_ref
       , h.numgar
       , h.numfor
       , to_char(h.DATE_GAR,'DD/MM/YYYY') date_garantie
       , n.rubrique famille_produit
       , 'Famille' domaine
       , h.type_ecart
       , PK_LIBELLE.F_LIB('TYP_REPORT',h.TYPE_ECART) lib_ecart
       , h.val_prod val_produit
       , h.val_gar val_cible
       , h.clef1 contexte
       , to_char(h.date_prod,'DD/MM/YYYY') date_produit
       , to_char(h.date_ecart,'DD/MM/YYYY') date_ecart
    FROM histo_report h , natfrais n
   WHERE numremise =i_numremise
     AND n.codfrais= h.clef1
     AND n.codfrais=n.rubrique
  ORDER BY 5,7,13, 9;

BEGIN

  s_fichier:=i_fichier;
  -- Ouverture du fichier à generer
  h_fichier:=PK_FICHIER.fOpen(i_repertoire, s_fichier, 'W');
  EcrireEntete(h_fichier);

  FOR rec_REMISE_EXPORT IN c_REMISE_EXPORT LOOP


    --loc_ok:=PK_FICHIER.fPutLine(h_fichier
    UTL_FILE.PUT_LINE(h_fichier
            ,  rec_REMISE_EXPORT.numremise
            || I_DELIMITEUR
            || TO_CHAR(rec_REMISE_EXPORT.numprod)
            || I_DELIMITEUR
            || TO_CHAR(rec_REMISE_EXPORT.numfor_ref)
            || I_DELIMITEUR
            || TO_CHAR(rec_REMISE_EXPORT.numgar)
            || I_DELIMITEUR
            || TO_CHAR(rec_REMISE_EXPORT.numfor)
            || I_DELIMITEUR
            || rec_REMISE_EXPORT.date_garantie
            || I_DELIMITEUR
            || rec_REMISE_EXPORT.famille_produit
            || I_DELIMITEUR
            || rec_REMISE_EXPORT.domaine
            || I_DELIMITEUR
            || rec_REMISE_EXPORT.type_ecart
            || I_DELIMITEUR
            || rec_REMISE_EXPORT.lib_ecart
            || I_DELIMITEUR
            || TO_CHAR(rec_REMISE_EXPORT.val_produit)
            || I_DELIMITEUR
            || TO_CHAR(rec_REMISE_EXPORT.val_cible)
            || I_DELIMITEUR
            || TO_CHAR(rec_REMISE_EXPORT.contexte)
            || I_DELIMITEUR
            || rec_REMISE_EXPORT.date_produit
            || I_DELIMITEUR
            || TO_CHAR(rec_REMISE_EXPORT.date_ecart)
            || I_DELIMITEUR
            );
    loc_cpt:=loc_cpt+1;
  END LOOP;

  P_INS_journal(1,'Le nombre de lignes dans le fichier est de <' ||TO_CHAR(loc_cpt)||'>');
  UTL_FILE.FFLUSH(h_fichier);
  --  Fermeture du fichier
  UTL_FILE.FCLOSE(h_fichier);

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'Fin du traitement ecrireLigne KO:' || SQLERRM);
    UTL_FILE.FCLOSE(h_fichier);
    RETURN FALSE;
END ecrireLigne;
--
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_journal                                             */
/* Type         :  Privee                                                    */
/* Description  :  Insertion dans journal_adm                                */
/* Entree       :  P_niv, P_msg, P_msg                                       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_journal(
    P_niv  IN NUMBER,
    P_msg  IN VARCHAR2,
    p_msg2 IN VARCHAR2 := NULL)
IS
BEGIN
  IF G_niv_msg IS NULL THEN
    BEGIN
      SELECT DECODE(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
      INTO G_niv_msg
      FROM PARAM_BATCH
      WHERE NUMBATCH = G_nom_traitement;
    EXCEPTION
    WHEN OTHERS THEN
      G_niv_msg := 1;
    END;
  END IF;
  IF G_niv_msg >= P_niv THEN
    G_IDLIGNE  := G_IDLIGNE +1;
    PK_trace.P_INS_journal_adm ( I_nom_traitement => G_nom_traitement, I_session => g_session, I_niv_msg => P_niv, I_msg_adm => SUBSTR(P_msg||' '||P_msg2,1,132), I_idligne => G_idligne);
  END IF;
END P_INS_journal;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  p_dupli_adhe                                              */
/* Type         :  Public                                                    */
/* Description  :  Duplication adhesion d un contrat a un autre sans resil.  */
/*---------------------------------------------------------------------------*/
PROCEDURE p_dupli_adhe(
    a_idporte    IN NUMBER,
    a_type       IN NUMBER,
    a_old_numgar IN NUMBER,
    a_numgar     IN NUMBER,
    a_debut      IN DATE,
    a_motif      IN VARCHAR2,
    a_numedit    IN NUMBER )
IS
  CURSOR fetch_param_transcod
  IS
    SELECT param_transcod.idporte,
      param_transcod.cle1,
      param_transcod.type_cle1,
      param_transcod.cle2,
      param_transcod.type_cle2,
      param_transcod.cle3,
      param_transcod.type_cle3,
      param_transcod.cle1_interne,
      param_transcod.type_cle1_interne,
      param_transcod.cle2_interne,
      param_transcod.type_cle2_interne,
      param_transcod.condition
    FROM param_transcod
    WHERE param_transcod.idporte             = a_idporte
    AND ( ( param_transcod.type_cle1         = 1
    AND param_transcod.cle1                  = a_old_numgar )
    OR ( param_transcod.type_cle2            = 1
    AND param_transcod.cle2                  = a_old_numgar )
    OR ( param_transcod.type_cle3            = 1
    AND param_transcod.cle3                  = a_old_numgar ) )
    AND ( ( param_transcod.type_cle1_interne = 1
    AND param_transcod.cle1_interne          = a_numgar )
    OR ( param_transcod.type_cle2_interne    = 1
    AND param_transcod.cle2_interne          = a_numgar ) );
  loc_param_transcod fetch_param_transcod%ROWTYPE;

  CURSOR fetch_adhe
  IS
    SELECT adhe_cntrt.numgar,
      adhe_cntrt.numadhe,
      adhe_cntrt.idadhesion,
      adhe_cntrt.date_adhe,
      adhe_cntrt.date_fin_adhe,
      adhe_cntrt.numquerable,
      adhe_cntrt.fract,
      adhe_cntrt.mregl,
      adhe_cntrt.delai,
      indvs.typadr,
      indvs.refcie,
      indvs.regime,
      indvs.sexe,
      (TO_CHAR (a_debut, 'yyyy') - TO_CHAR (indvs.datnais, 'yyyy') ) age
    FROM indvs,
      adhe_cntrt
    WHERE adhe_cntrt.numgar                      = a_old_numgar
    AND adhe_cntrt.numadhe                       = indvs.numindiv
    AND NVL (adhe_cntrt.date_fin_adhe, a_debut) >= a_debut;

  loc_adhe fetch_adhe%ROWTYPE;
  loc_old_idadhesion NUMBER;
  CURSOR fetch_transcod
  IS
    SELECT cle_primaire,
      type_cle_primaire,
      cle1,
      type_cle1,
      cle2,
      type_cle2,
      cle3,
      type_cle3,
      debut
    FROM transcod
    WHERE transcod.idporte = a_idporte;
  loc_transcod fetch_transcod%ROWTYPE;
  CURSOR fetch_adhe_membre
  IS
    SELECT adhe_cntrt_membre.numindiv,
      adhe_cntrt_membre.typadr,
      adhe_cntrt_membre.numbene
    FROM adhe_cntrt_membre
    WHERE adhe_cntrt_membre.idadhesion = loc_old_idadhesion
    AND EXISTS
      (SELECT 1
      FROM adhesion
      WHERE adhesion.idadhesion               = adhe_cntrt_membre.idadhesion
      AND adhesion.numindiv                   = adhe_cntrt_membre.numindiv
      AND adhesion.numfor                     = loc_old_numfor
      AND NVL (adhesion.datper, a_debut )     >= a_debut
      );
  loc_adhe_membre fetch_adhe_membre%ROWTYPE;
  CURSOR fetch_gar
  IS
    SELECT gar_cntrt.numfor,
      gar_cntrt.datapli,
      gar_cntrt.datper,
      gar_cntrt.TYPE
    FROM gar_cntrt
    WHERE gar_cntrt.numgar    = a_numgar
    AND gar_cntrt.valide      = 'O'
    AND gar_cntrt.numfor NOT IN
      (SELECT grp_gar_def.numfor
      FROM grp_gar,
        grp_gar_def
      WHERE grp_gar_def.numgrpgar = grp_gar.numgrpgar
      AND grp_gar.etendue         = 2
      AND grp_gar.clef            = gar_cntrt.numgar
      AND grp_gar_def.numfor      = gar_cntrt.numfor
      )
  AND gar_cntrt.numfor = loc_numfor
  UNION
  SELECT grp_gar.numgrpgar,
    grp_gar.datapli,
    grp_gar.datper,
    3 TYPE
  FROM grp_gar
  WHERE grp_gar.etendue = 2
  AND grp_gar.clef      = a_numgar
  AND grp_gar.valide    = 'O'
  AND grp_gar.numgrpgar = loc_numfor;
  loc_gar fetch_gar%ROWTYPE;
  loc_idadhesion  NUMBER;
  loc_numorg      NUMBER;
  loc_typadr      NUMBER;
  loc_numassu     NUMBER;
  loc_continue    NUMBER := 1;
  loc_nombre      NUMBER := 0;
  loc_numremise   NUMBER := 0;
  loc_nombre_adhe NUMBER := 0;
  loc_debut       DATE;
  loc_fin         DATE;
  loc_valvar       VAL_VARIABLE.VALEUR%TYPE;
  flag_resil      BOOLEAN;
  flag_insert_adhe BOOLEAN;
BEGIN
SELECT NVL (MAX (remise_transfert.numremise), 0) + 1
INTO loc_numremise
FROM remise_transfert;
BEGIN
  flag_resil:=TRUE;
  IF (a_type = 2) THEN
    FOR loc_adhe IN fetch_adhe
    LOOP
     loc_idadhesion  := pk_adhesion.f_idadhesion;
      flag_insert_adhe :=FALSE;
      FOR loc_param_transcod IN fetch_param_transcod
      LOOP
        p_initialise (loc_param_transcod.type_cle1, loc_param_transcod.cle1, 1 );
        p_initialise (loc_param_transcod.type_cle2, loc_param_transcod.cle2, 1 );
        p_initialise (loc_param_transcod.type_cle3, loc_param_transcod.cle3, 1 );
        p_initialise (loc_param_transcod.type_cle1_interne, loc_param_transcod.cle1_interne, 2 );
        p_initialise (loc_param_transcod.type_cle2_interne, loc_param_transcod.cle2_interne, 2 );
        /* On compte le nombre d'adhesions par adherent */
        DBMS_OUTPUT.put_line ('Adherent  = ' || loc_adhe.numadhe);
        BEGIN
          SELECT COUNT (*)
          INTO loc_nombre_adhe
          FROM adhe_cntrt
          WHERE adhe_cntrt.numadhe                     = loc_adhe.numadhe
          AND NVL (adhe_cntrt.date_fin_adhe, a_debut) >= a_debut;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          loc_nombre_adhe := 0;
        END;
        DBMS_OUTPUT.put_line ('Nb adhesions  = ' || loc_nombre_adhe);
        DBMS_OUTPUT.put_line ('Adherent  = ' || loc_adhe.numadhe);
        IF (loc_old_numgar      IS NULL) THEN
          loc_old_numgar        := a_old_numgar;
        ELSIF (loc_numgar       IS NULL) THEN
          loc_numgar            := a_numgar;
        ELSIF (loc_old_typassu  IS NULL) THEN
          loc_old_typassu       := loc_adhe.typadr;
        ELSIF (loc_typassu      IS NULL) THEN
          loc_typassu           := loc_adhe.typadr;
        ELSIF (loc_old_numindiv IS NULL) THEN
          loc_old_numindiv      := loc_adhe.numadhe;
        ELSIF (loc_numindiv     IS NULL) THEN
          loc_numindiv          := loc_adhe.numadhe;
        ELSIF (loc_old_refcie   IS NULL) THEN
          loc_old_refcie        := loc_adhe.refcie;
        ELSIF (loc_refcie       IS NULL) THEN
          loc_refcie            := loc_adhe.refcie;
        ELSIF (loc_old_regime   IS NULL) THEN
          loc_old_regime        := loc_adhe.regime;
        ELSIF (loc_regime       IS NULL) THEN
          loc_regime            := loc_adhe.regime;
        ELSIF (loc_old_age      IS NULL) THEN
          loc_old_age           := loc_adhe.age;
        ELSIF (loc_age          IS NULL) THEN
          loc_age               := loc_adhe.age;
        ELSIF (loc_old_sexe     IS NULL) THEN
          loc_old_sexe          := loc_adhe.sexe;
        ELSIF (loc_sexe         IS NULL) THEN
          loc_sexe              := loc_adhe.sexe;
        ELSIF (loc_nb_adhe      IS NULL) THEN
          loc_nb_adhe           := loc_nombre_adhe;
        ELSIF (loc_old_nb_adhe  IS NULL) THEN
          loc_old_nb_adhe       := loc_nombre_adhe;
        END IF;
        --M5006 transfert d'assuré pour un périmètre tagué en amont, on recherche la valeur de la val_variable

        IF (loc_param_transcod.condition     IS NOT NULL) THEN
          flag_resil:=FALSE;
          IF (loc_param_transcod.type_cle3    = 1) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.numgar );
          ELSIF (loc_param_transcod.type_cle3 = 2) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_old_numfor );
          ELSIF (loc_param_transcod.type_cle3 = 3) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.typadr );
          ELSIF (loc_param_transcod.type_cle3 = 4) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.numadhe );
          ELSIF (loc_param_transcod.type_cle3 = 5) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.refcie );
          ELSIF (loc_param_transcod.type_cle3 = 6) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.regime );
          ELSIF (loc_param_transcod.type_cle3 = 7) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_old_numsoc );
          ELSIF (loc_param_transcod.type_cle3 = 8) THEN
            IF loc_old_idvariable IS NOT NULL THEN
              loc_valvar := F_VAL_VAR_ALL(loc_adhe.idadhesion,loc_old_idvariable,a_debut);
              --on ne peut que contrôler une val_var existante ou non pour l'étendue 13 pour le moment
            END IF;
            IF loc_param_transcod.condition ='@' THEN
              loc_continue                     := f_condition (loc_param_transcod.condition, NULL, loc_valvar );
            ELSIF loc_param_transcod.condition ='#' AND loc_valvar IS NOT NULL THEN --comparaison avec le numfor cible
              loc_continue                     := f_condition (loc_param_transcod.condition, loc_numfor, loc_valvar );
            ELSE  loc_continue :=1;
            END IF;
          ELSIF (loc_param_transcod.type_cle3 = 9) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.age );
          ELSIF (loc_param_transcod.type_cle3 = 10) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_old_montant );
          ELSIF (loc_param_transcod.type_cle3 = 11) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.sexe );
          ELSIF (loc_param_transcod.type_cle3 = 12) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_nombre_adhe );
          END IF;
        ELSE
          loc_continue := 0;
        END IF;
        DBMS_OUTPUT.put_line ('loc_continue  = ' || loc_continue);
        IF (loc_continue = 0) THEN
          DBMS_OUTPUT.put_line ('Idadhesion  = ' || loc_idadhesion);
          -- On insere la nouvelle adhesion dans adhe_cntrt
          INSERT
          INTO adhe_cntrt
            (
              idadhesion,
              ref_ext,
              numgar,
              numadhe,
              date_adhe,
              meme_gar,
              date_fin_adhe,
              numquerable,
              fract,
              echesuiv,
              mregl,
              delai,
              dsous,
              numutil
            )
          SELECT loc_idadhesion,
            loc_idadhesion
            || ' / '
            || SUBSTR (contrat.refcie, 1, 18),
            a_numgar,
            loc_adhe.numadhe,
            GREATEST (a_debut, loc_adhe.date_adhe),
            'N',
            loc_adhe.date_fin_adhe,
            loc_adhe.numquerable,
            contrat.fract,
            a_debut,
            contrat.mregl,
            contrat.delai,
            a_debut,
            f_numutil
          FROM contrat
          WHERE contrat.numgar = a_numgar
          AND NOT EXISTS
            (SELECT 1
            FROM adhe_cntrt
            WHERE adhe_cntrt.numgar = a_numgar
            AND adhe_cntrt.numadhe  = loc_adhe.numadhe
            );
          CONTINUE WHEN sql%rowcount =0 AND NOT flag_insert_adhe ; -- MUR 20180523 transfert Valspar
          flag_insert_adhe :=TRUE;
          DBMS_OUTPUT.put_line ('Adherent  = ' || loc_adhe.numadhe);
          --On insere dans histo_adhesion
          INSERT
          INTO histo_adhesion
            (
              idadhesion,
              debut,
              datsai,
              etat,
              motif,
              numutil
            )
          SELECT loc_idadhesion,
            GREATEST (a_debut, loc_adhe.date_adhe),
            SYSDATE,
            1,
            a_motif,
            f_numutil
          FROM DUAL
          WHERE NOT EXISTS
            (SELECT 1
            FROM histo_adhesion,
              adhe_cntrt
            WHERE histo_adhesion.idadhesion = adhe_cntrt.idadhesion
            AND adhe_cntrt.numgar           = a_numgar
            AND adhe_cntrt.numadhe          = loc_adhe.numadhe
            );
          IF (loc_adhe.date_fin_adhe IS NOT NULL) THEN
            BEGIN
              INSERT INTO histo_adhesion
                (idadhesion, debut, datsai, etat, motif, numutil
                )
              SELECT loc_idadhesion,
                a.debut,
                SYSDATE,
                3,
                a.motif,
                f_numutil
              FROM histo_adhesion a
              WHERE a.idadhesion = loc_adhe.idadhesion
              AND a.debut        = loc_adhe.date_fin_adhe
              AND NOT EXISTS
                (SELECT 1
                FROM histo_adhesion,
                  adhe_cntrt
                WHERE histo_adhesion.idadhesion = adhe_cntrt.idadhesion
                AND histo_adhesion.debut        = loc_adhe.date_fin_adhe
                AND adhe_cntrt.numgar           = a_numgar
                AND adhe_cntrt.numadhe          = loc_adhe.numadhe
                );
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              pk_trace.p_ins_journal_adm ('Pk_transfert.p_dupli_adhe', a_numedit, 1, 'Aucun histo_adhesion avec code etat 3 pour idadhesion ' || TO_CHAR (loc_adhe.idadhesion), SYSDATE );
            END;
          END IF;
          loc_old_idadhesion := loc_adhe.idadhesion;
          DBMS_OUTPUT.put_line ( 'OLD IDADHESION  = ' || loc_old_idadhesion );
          --On insere dans histo_adhe_cntrt_membre
          DBMS_OUTPUT.put_line ('OLD NUMFOR  = ' || loc_old_numfor);
          FOR loc_adhe_membre IN fetch_adhe_membre
          LOOP
           -- pk_trace.p_ins_journal_adm ('TR05T', a_numedit, 0, 'insert into membre indv:' ||loc_adhe_membre.numindiv, SYSDATE );
            INSERT INTO adhe_cntrt_membre
              (idadhesion, numindiv, typadr, numbene
              )
            SELECT loc_idadhesion,
              loc_adhe_membre.numindiv,
              loc_adhe_membre.typadr,
              loc_adhe_membre.numbene
            FROM DUAL
            WHERE NOT EXISTS
              (SELECT 1
              FROM adhe_cntrt_membre,
                adhe_cntrt
              WHERE adhe_cntrt_membre.idadhesion = adhe_cntrt.idadhesion
              AND adhe_cntrt.numgar              = a_numgar
              AND adhe_cntrt_membre.numindiv     = loc_adhe_membre.numindiv
              AND adhe_cntrt.idadhesion          = loc_idadhesion
              );
            -- On insere dans adhesion
            SELECT NVL (indvs.orgbase, 1)
            INTO loc_numorg
            FROM indvs
            WHERE indvs.numindiv = loc_adhe.numadhe;
            FOR loc_gar IN fetch_gar
            LOOP
              SELECT GREATEST (loc_gar.datapli, a_debut) INTO loc_debut FROM DUAL;
              SELECT GREATEST (loc_adhe.date_fin_adhe, NVL (loc_gar.datper, loc_adhe.date_fin_adhe ) )
              INTO loc_fin
              FROM DUAL;
              IF (loc_debut > loc_fin) THEN
                loc_fin    := '';
              END IF;
             --  pk_trace.p_ins_journal_adm ('TR05T', a_numedit, 0, 'insert into adhesion gar:' ||loc_gar.numfor, SYSDATE );
              INSERT INTO adhesion
                (
                  idadhesion,
                  numindiv,
                  numgar,
                  numfor,
                  datapli,
                  etat,
                  typfor,
                  numorg,
                  flag_regime,
                  dis_carence,
                  dis_franchise,
                  rang,
                  datper,
                  numutil,
                  creation,
                  maj
                )
              SELECT loc_idadhesion,
                adhesion.numindiv,
                a_numgar,
                loc_gar.numfor,
                GREATEST (GREATEST (loc_gar.datapli, a_debut), adhesion.datapli),
                1,
                loc_gar.TYPE,
                loc_numorg,
                adhesion.flag_regime,
                adhesion.dis_carence,
                adhesion.dis_franchise,
                adhesion.rang,
                decode(adhesion.datper,NULL,NULL,adhesion.datper),
                f_numutil,
                SYSDATE,
                SYSDATE
              FROM adhesion
              WHERE adhesion.idadhesion =loc_adhe.idadhesion
              AND adhesion.numindiv =  loc_adhe_membre.numindiv
              AND NVL(adhesion.datper, a_debut) >= a_debut
              AND adhesion.numfor =loc_old_numfor
              AND NOT EXISTS
                (SELECT 1
                FROM adhesion a
                WHERE a.numgar = a_numgar
                AND a.numindiv = loc_adhe_membre.numindiv
                AND a.numfor   = loc_gar.numfor
                AND a.rang = adhesion.rang
                );

                    --ABO on vérifie qu'il existe encore au moins une couverture sur l'ancien contrat avant de l'ajouter dans les membres
              DBMS_OUTPUT.put_line ('NEW COUVERTURE INDIV ' || loc_adhe_membre.numindiv || 'NEW NUMFOR  = ' || loc_gar.numfor);
            END LOOP;--fetch_gar
          END LOOP;--fetch_adhe_membre


          INSERT INTO histo_transfert
            (numremise, new_numgar, old_numgar, numindiv
            )
          SELECT loc_numremise,
            loc_numgar,
            loc_old_numgar,
            loc_adhe.numadhe
          FROM DUAL
          WHERE NOT EXISTS
            (SELECT 1
            FROM histo_transfert
            WHERE numremise = loc_numremise
            AND new_numgar  = loc_numgar
            AND old_numgar  = loc_old_numgar
            AND numindiv    = loc_adhe.numadhe
            );


        END IF;
      END LOOP;--fetch_transod

      -- supprimer les entêtes d'adhésions créées sans membres (pb contrôle des conditions à la création)
      DELETE FROM adhe_cntrt WHERE idadhesion = loc_idadhesion
      AND NOT EXISTS ( SELECT 1 FROM adhe_cntrt_membre WHERE adhe_cntrt_membre.idadhesion = adhe_cntrt.idadhesion  ) ;

      COMMIT;

    END LOOP;--fetch_adhe

  END IF;
EXCEPTION
  WHEN OTHERS THEN
  pk_trace.p_ins_journal_adm ('DUPAD', a_numedit, 0, 'Adhesion en erreur :' ||loc_old_idadhesion, SYSDATE );
  pk_trace.p_ins_journal_adm ('DUPAD', a_numedit, 0, 'Fin de traitement anormale :' || SQLERRM, SYSDATE );
END;

  BEGIN
    SELECT count(numindiv)
    INTO loc_nombre
    FROM histo_transfert
    WHERE numremise = loc_numremise
    AND new_numgar  = a_numgar
    AND old_numgar  = a_old_numgar;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    loc_nombre := 0;
  END;

  INSERT
  INTO remise_transfert
    (
      numremise,
      TYPE,
      old_numgar,
      new_numgar,
      debut,
      motif,
      creation,
      nombre
    )
  SELECT loc_numremise,
    a_type,
    a_old_numgar,
    a_numgar,
    a_debut,
    a_motif,
    SYSDATE,
    loc_nombre
  FROM DUAL;
END p_dupli_adhe;



PROCEDURE p_transfert_adhe_resil(
    a_idporte    IN NUMBER,
    a_type       IN NUMBER,
    a_old_numgar IN NUMBER,
    a_numgar     IN NUMBER,
    a_debut      IN DATE,
    a_motif      IN VARCHAR2,
    a_numedit    IN NUMBER )
IS
-- transfert des adhésions résiliées à DateParam -1 par création d'adhésion à la date DateParam sans date de fin
  CURSOR fetch_param_transcod
  IS
    SELECT param_transcod.idporte,
      param_transcod.cle1,
      param_transcod.type_cle1,
      param_transcod.cle2,
      param_transcod.type_cle2,
      param_transcod.cle3,
      param_transcod.type_cle3,
      param_transcod.cle1_interne,
      param_transcod.type_cle1_interne,
      param_transcod.cle2_interne,
      param_transcod.type_cle2_interne,
      param_transcod.condition
    FROM param_transcod
    WHERE param_transcod.idporte             = a_idporte
    AND ( ( param_transcod.type_cle1         = 1
    AND param_transcod.cle1                  = a_old_numgar )
    OR ( param_transcod.type_cle2            = 1
    AND param_transcod.cle2                  = a_old_numgar )
    OR ( param_transcod.type_cle3            = 1
    AND param_transcod.cle3                  = a_old_numgar ) )
    AND ( ( param_transcod.type_cle1_interne = 1
    AND param_transcod.cle1_interne          = a_numgar )
    OR ( param_transcod.type_cle2_interne    = 1
    AND param_transcod.cle2_interne          = a_numgar ) );
  loc_param_transcod fetch_param_transcod%ROWTYPE;

  CURSOR fetch_adhe
  IS
    SELECT adhe_cntrt.numgar,
      adhe_cntrt.numadhe,
      adhe_cntrt.idadhesion,
      adhe_cntrt.date_fin_adhe,
      adhe_cntrt.numquerable,
      adhe_cntrt.fract,
      adhe_cntrt.mregl,
      adhe_cntrt.delai,
      indvs.typadr,
      indvs.refcie,
      indvs.regime,
      indvs.sexe,
      (TO_CHAR (a_debut, 'yyyy') - TO_CHAR (indvs.datnais, 'yyyy') ) age
    FROM indvs,
      adhe_cntrt
    WHERE adhe_cntrt.numgar                      = a_old_numgar
    AND adhe_cntrt.numadhe                       = indvs.numindiv
    AND NVL (adhe_cntrt.date_fin_adhe, a_debut)  = a_debut-1;

  loc_adhe fetch_adhe%ROWTYPE;
  loc_old_idadhesion NUMBER;
  CURSOR fetch_transcod
  IS
    SELECT cle_primaire,
      type_cle_primaire,
      cle1,
      type_cle1,
      cle2,
      type_cle2,
      cle3,
      type_cle3,
      debut
    FROM transcod
    WHERE transcod.idporte = a_idporte;
  loc_transcod fetch_transcod%ROWTYPE;
  CURSOR fetch_adhe_membre
  IS
    SELECT adhe_cntrt_membre.numindiv,
      adhe_cntrt_membre.typadr,
      adhe_cntrt_membre.numbene
    FROM adhe_cntrt_membre
    WHERE adhe_cntrt_membre.idadhesion = loc_old_idadhesion
    AND EXISTS
      (SELECT 1
      FROM adhesion
      WHERE adhesion.idadhesion               = adhe_cntrt_membre.idadhesion
      AND adhesion.numindiv                   = adhe_cntrt_membre.numindiv
      AND adhesion.numfor                     = loc_old_numfor
      AND NVL (adhesion.datper, a_debut )     = a_debut-1
      );
  loc_adhe_membre fetch_adhe_membre%ROWTYPE;
  CURSOR fetch_gar
  IS
    SELECT gar_cntrt.numfor,
      gar_cntrt.datapli,
      gar_cntrt.datper,
      gar_cntrt.TYPE
    FROM gar_cntrt
    WHERE gar_cntrt.numgar    = a_numgar
    AND gar_cntrt.valide      = 'O'
    AND gar_cntrt.numfor NOT IN
      (SELECT grp_gar_def.numfor
      FROM grp_gar,
        grp_gar_def
      WHERE grp_gar_def.numgrpgar = grp_gar.numgrpgar
      AND grp_gar.etendue         = 2
      AND grp_gar.clef            = gar_cntrt.numgar
      AND grp_gar_def.numfor      = gar_cntrt.numfor
      )
  AND gar_cntrt.numfor = loc_numfor
  UNION
  SELECT grp_gar.numgrpgar,
    grp_gar.datapli,
    grp_gar.datper,
    3 TYPE
  FROM grp_gar
  WHERE grp_gar.etendue = 2
  AND grp_gar.clef      = a_numgar
  AND grp_gar.valide    = 'O'
  AND grp_gar.numgrpgar = loc_numfor;
  loc_gar fetch_gar%ROWTYPE;
  loc_idadhesion  NUMBER;
  loc_numorg      NUMBER;
  loc_typadr      NUMBER;
  loc_numassu     NUMBER;
  loc_continue    NUMBER := 1;
  loc_nombre      NUMBER := 0;
  loc_numremise   NUMBER := 0;
  loc_nombre_adhe NUMBER := 0;
  loc_debut       DATE;
  loc_fin         DATE;
  loc_valvar       VAL_VARIABLE.VALEUR%TYPE;
  flag_resil      BOOLEAN;
  flag_insert_adhe BOOLEAN;
BEGIN
SELECT NVL (MAX (remise_transfert.numremise), 0) + 1
INTO loc_numremise
FROM remise_transfert;
BEGIN
  flag_resil:=TRUE;
  IF (a_type = 2) THEN
    FOR loc_adhe IN fetch_adhe
    LOOP
      DBMS_OUTPUT.put_line ('Parcours - Adherent  = ' || loc_adhe.numadhe);
     loc_idadhesion  := pk_adhesion.f_idadhesion;
      flag_insert_adhe :=FALSE;
      FOR loc_param_transcod IN fetch_param_transcod
      LOOP
        p_initialise (loc_param_transcod.type_cle1, loc_param_transcod.cle1, 1 );
        p_initialise (loc_param_transcod.type_cle2, loc_param_transcod.cle2, 1 );
        p_initialise (loc_param_transcod.type_cle3, loc_param_transcod.cle3, 1 );
        p_initialise (loc_param_transcod.type_cle1_interne, loc_param_transcod.cle1_interne, 2 );
        p_initialise (loc_param_transcod.type_cle2_interne, loc_param_transcod.cle2_interne, 2 );
       DBMS_OUTPUT.put_line ('Source = ' ||loc_old_numgar||'-'||loc_old_numfor);
        /* On compte le nombre d'adhesions par adherent */

        BEGIN
          SELECT COUNT (*)
          INTO loc_nombre_adhe
          FROM adhe_cntrt
          WHERE adhe_cntrt.numadhe                     = loc_adhe.numadhe
          AND NVL (adhe_cntrt.date_fin_adhe, a_debut)  = a_debut-1;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          loc_nombre_adhe := 0;
        END;
        DBMS_OUTPUT.put_line ('Nb adhesions touvées = ' || loc_nombre_adhe);
        IF (loc_old_numgar      IS NULL) THEN
          loc_old_numgar        := a_old_numgar;
        ELSIF (loc_numgar       IS NULL) THEN
          loc_numgar            := a_numgar;
        ELSIF (loc_old_typassu  IS NULL) THEN
          loc_old_typassu       := loc_adhe.typadr;
        ELSIF (loc_typassu      IS NULL) THEN
          loc_typassu           := loc_adhe.typadr;
        ELSIF (loc_old_numindiv IS NULL) THEN
          loc_old_numindiv      := loc_adhe.numadhe;
        ELSIF (loc_numindiv     IS NULL) THEN
          loc_numindiv          := loc_adhe.numadhe;
        ELSIF (loc_old_refcie   IS NULL) THEN
          loc_old_refcie        := loc_adhe.refcie;
        ELSIF (loc_refcie       IS NULL) THEN
          loc_refcie            := loc_adhe.refcie;
        ELSIF (loc_old_regime   IS NULL) THEN
          loc_old_regime        := loc_adhe.regime;
        ELSIF (loc_regime       IS NULL) THEN
          loc_regime            := loc_adhe.regime;
        ELSIF (loc_old_age      IS NULL) THEN
          loc_old_age           := loc_adhe.age;
        ELSIF (loc_age          IS NULL) THEN
          loc_age               := loc_adhe.age;
        ELSIF (loc_old_sexe     IS NULL) THEN
          loc_old_sexe          := loc_adhe.sexe;
        ELSIF (loc_sexe         IS NULL) THEN
          loc_sexe              := loc_adhe.sexe;
        ELSIF (loc_nb_adhe      IS NULL) THEN
          loc_nb_adhe           := loc_nombre_adhe;
        ELSIF (loc_old_nb_adhe  IS NULL) THEN
          loc_old_nb_adhe       := loc_nombre_adhe;
        END IF;
        --M5006 transfert d'assuré pour un périmètre tagué en amont, on recherche la valeur de la val_variable

        IF (loc_param_transcod.condition     IS NOT NULL) THEN
          flag_resil:=FALSE;
          IF (loc_param_transcod.type_cle3    = 1) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.numgar );
          ELSIF (loc_param_transcod.type_cle3 = 2) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_old_numfor );
          ELSIF (loc_param_transcod.type_cle3 = 3) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.typadr );
          ELSIF (loc_param_transcod.type_cle3 = 4) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.numadhe );
          ELSIF (loc_param_transcod.type_cle3 = 5) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.refcie );
          ELSIF (loc_param_transcod.type_cle3 = 6) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.regime );
          ELSIF (loc_param_transcod.type_cle3 = 7) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_old_numsoc );
          ELSIF (loc_param_transcod.type_cle3 = 8) THEN
            IF loc_old_idvariable IS NOT NULL THEN
              loc_valvar := F_VAL_VAR_ALL(loc_adhe.idadhesion,loc_old_idvariable,a_debut-1);
              --pk_trace.p_ins_journal_adm ('Pk_transfert.p_insere_adhe', a_numedit, 0, 'Transfert adhesion ' || TO_CHAR (loc_adhe.idadhesion) || ' loc_valvar ' || loc_valvar, SYSDATE );
              --on ne peut que contrôler une val_var existante ou non pour l'étendue 13 pour le moment
            END IF;
            IF loc_param_transcod.condition ='@' THEN
              loc_continue                     := f_condition (loc_param_transcod.condition, NULL, loc_valvar );
            ELSIF loc_param_transcod.condition ='#' AND loc_valvar IS NOT NULL THEN --comparaison avec le numfor cible
              loc_continue                     := f_condition (loc_param_transcod.condition, loc_numfor, loc_valvar );
            ELSE  loc_continue :=1;
            END IF;
          ELSIF (loc_param_transcod.type_cle3 = 9) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.age );
          ELSIF (loc_param_transcod.type_cle3 = 10) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_old_montant );
          ELSIF (loc_param_transcod.type_cle3 = 11) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_adhe.sexe );
          ELSIF (loc_param_transcod.type_cle3 = 12) THEN
            loc_continue                     := f_condition (loc_param_transcod.condition, loc_param_transcod.cle3, loc_nombre_adhe );
          END IF;
        ELSE
          loc_continue := 0;
        END IF;
        DBMS_OUTPUT.put_line ('loc_continue  = ' || loc_continue);
       -- pk_trace.p_ins_journal_adm ('Pk_transfert.p_insere_adhe', a_numedit, 0, 'Transfert adhesion ' || TO_CHAR (loc_adhe.idadhesion) || ' loc_continue ' || loc_continue, SYSDATE );
        IF (loc_continue = 0) THEN
          DBMS_OUTPUT.put_line ('Adhésion à crééer  = ' || loc_idadhesion);
          -- On insere la nouvelle adhesion dans adhe_cntrt
          INSERT
          INTO adhe_cntrt
            (
              idadhesion,
              ref_ext,
              numgar,
              numadhe,
              date_adhe,
              meme_gar,
              date_fin_adhe,
              numquerable,
              fract,
              echesuiv,
              mregl,
              delai,
              dsous,
              numutil
            )
          SELECT loc_idadhesion,
            loc_idadhesion
            || ' / '
            || SUBSTR (contrat.refcie, 1, 18),
            a_numgar,
            loc_adhe.numadhe,
            a_debut,
            'N',
            NULL, --loc_adhe.date_fin_adhe,
            loc_adhe.numquerable,
            loc_adhe.fract,
            a_debut,
            loc_adhe.mregl,
            loc_adhe.delai,
            a_debut,
            f_numutil
          FROM contrat
          WHERE contrat.numgar = a_numgar
          AND NOT EXISTS
            (SELECT 1
            FROM adhe_cntrt
            WHERE adhe_cntrt.numgar = a_numgar
            AND adhe_cntrt.numadhe  = loc_adhe.numadhe
            );
          --on ne créé pas de couverture si l'adhésion au contrat est déjà existante pour l'adhérent  (créée manuelleement)
          --sinon on créé des adhésions mélangées avec d'autres adhérents et des doublons de couvertures avec adhésion manuelle
          CONTINUE WHEN sql%rowcount =0 AND NOT flag_insert_adhe;--ne continue pas, passe au tour de boucle suivant si l'adhésion était préexistante au traitement
          flag_insert_adhe:=TRUE;
          DBMS_OUTPUT.put_line ('Adhésion créée pour adhérent  = ' || loc_adhe.numadhe);
          --On insere dans histo_adhesion
          INSERT
          INTO histo_adhesion
            (
              idadhesion,
              debut,
              datsai,
              etat,
              motif,
              numutil
            )
          SELECT loc_idadhesion,
            a_debut,
            SYSDATE,
            1,
            a_motif,
            f_numutil
          FROM DUAL
          WHERE NOT EXISTS
            (SELECT 1
            FROM histo_adhesion,
              adhe_cntrt
            WHERE histo_adhesion.idadhesion = adhe_cntrt.idadhesion
            AND adhe_cntrt.numgar           = a_numgar
            AND adhe_cntrt.numadhe          = loc_adhe.numadhe
            );

          loc_old_idadhesion := loc_adhe.idadhesion;
          DBMS_OUTPUT.put_line ( 'à partir de l''adhésion  = ' || loc_old_idadhesion );
          --On insere dans histo_adhe_cntrt_membre
          DBMS_OUTPUT.put_line ('et pour l''ancien numfor  = ' || loc_old_numfor);
          FOR loc_adhe_membre IN fetch_adhe_membre
          LOOP
           -- pk_trace.p_ins_journal_adm ('TR05T', a_numedit, 0, 'insert into membre indv:' ||loc_adhe_membre.numindiv, SYSDATE );
            INSERT INTO adhe_cntrt_membre
              (idadhesion, numindiv, typadr, numbene
              )
            SELECT loc_idadhesion,
              loc_adhe_membre.numindiv,
              loc_adhe_membre.typadr,
              loc_adhe_membre.numbene
            FROM DUAL
            WHERE NOT EXISTS
              (SELECT 1
              FROM adhe_cntrt_membre,
                adhe_cntrt
              WHERE adhe_cntrt_membre.idadhesion = adhe_cntrt.idadhesion
              AND adhe_cntrt.numgar              = a_numgar
              AND adhe_cntrt_membre.numindiv     = loc_adhe_membre.numindiv
              AND adhe_cntrt.idadhesion          = loc_idadhesion
              );
            -- On insere dans adhesion
            SELECT NVL (indvs.orgbase, 1)
            INTO loc_numorg
            FROM indvs
            WHERE indvs.numindiv = loc_adhe.numadhe;
            FOR loc_gar IN fetch_gar
            LOOP
              SELECT GREATEST (loc_gar.datapli, a_debut) INTO loc_debut FROM DUAL;
              /*SELECT GREATEST (loc_adhe.date_fin_adhe, NVL (loc_gar.datper, loc_adhe.date_fin_adhe ) )
              INTO loc_fin
              FROM DUAL;
              IF (loc_debut > loc_fin) THEN
                loc_fin    := '';
              END IF;*/
             --  pk_trace.p_ins_journal_adm ('TR05T', a_numedit, 0, 'insert into adhesion gar:' ||loc_gar.numfor, SYSDATE );
              INSERT INTO adhesion
                (
                  idadhesion,
                  numindiv,
                  numgar,
                  numfor,
                  datapli,
                  etat,
                  typfor,
                  numorg,
                  flag_regime,
                  dis_carence,
                  dis_franchise,
                  rang,
                  datper,
                  numutil,
                  creation,
                  maj
                )
              SELECT loc_idadhesion,
                adhesion.numindiv,
                a_numgar,
                loc_gar.numfor,
                GREATEST (loc_gar.datapli, a_debut),
                1,
                loc_gar.TYPE,
                loc_numorg,
                adhesion.flag_regime,
                adhesion.dis_carence,
                adhesion.dis_franchise,
                adhesion.rang,
                NULL, --decode(adhesion.datper,NULL,NULL,adhesion.datper),
                f_numutil,
                SYSDATE,
                SYSDATE
              FROM adhesion
              WHERE adhesion.idadhesion =loc_adhe.idadhesion
              AND adhesion.numindiv =  loc_adhe_membre.numindiv
              AND NVL(adhesion.datper, a_debut)  = a_debut-1
              AND adhesion.numfor =loc_old_numfor
              AND NOT EXISTS
               (SELECT 1
                FROM adhesion a
                WHERE a.numgar = a_numgar
                AND a.numindiv = loc_adhe_membre.numindiv
                AND a.numfor   = loc_gar.numfor
                AND a.rang = adhesion.rang
                );


                    --ABO on vérifie qu'il existe encore au moins une couverture sur l'ancien contrat avant de l'ajouter dans les membres
              DBMS_OUTPUT.put_line ('NEW COUVERTURE INDIV ' || loc_adhe_membre.numindiv || 'NEW NUMFOR  = ' || loc_gar.numfor);
            END LOOP;--fetch_gar
          END LOOP;--fetch_adhe_membre


          INSERT INTO histo_transfert
            (numremise, new_numgar, old_numgar, numindiv
            )
          SELECT loc_numremise,
            loc_numgar,
            loc_old_numgar,
            loc_adhe.numadhe
          FROM DUAL
          WHERE NOT EXISTS
            (SELECT 1
            FROM histo_transfert
            WHERE numremise = loc_numremise
            AND new_numgar  = loc_numgar
            AND old_numgar  = loc_old_numgar
            AND numindiv    = loc_adhe.numadhe
            );


        END IF;
      END LOOP;--fetch_transod

      DELETE FROM adhe_cntrt WHERE idadhesion = loc_idadhesion
      AND NOT EXISTS ( SELECT 1 FROM adhe_cntrt_membre WHERE adhe_cntrt_membre.idadhesion = adhe_cntrt.idadhesion  ) ;
      -- On resilie l'adhesion de l'ancien contrat lorsque tous les membres et numfor sont passés en revue et qu'on a bien eu une insertion
      --IF flag_insert_adhe THEN
      --  p_resilie_adhe (loc_old_numgar, loc_adhe.idadhesion, loc_adhe.numadhe, a_motif, (a_debut - 1) );
      --  pk_trace.p_ins_journal_adm ('Pk_transfert.p_insere_adhe', a_numedit, 0, 'Resiliation adhesion :' || TO_CHAR (loc_adhe.idadhesion) || ' Insertion idadhesion :' || TO_CHAR (loc_idadhesion), SYSDATE );
        COMMIT;
      --END IF;
    END LOOP;--fetch_adhe

    --On resilie l'ancien contrat uniqument s'il n'y avait aucune condition lors du transfert
    --IF flag_resil THEN
    --  p_resilie_contrat (a_old_numgar, a_motif, (a_debut - 1));
    --END IF;

  ELSIF (a_type = 1) THEN
    FOR loc_param_transcod IN fetch_param_transcod
    LOOP
      FOR loc_transcod IN fetch_transcod
      LOOP
        p_initialise (loc_transcod.type_cle1, loc_transcod.cle1, 2);
        p_initialise (loc_transcod.type_cle2, loc_transcod.cle2, 2);
        p_initialise (loc_transcod.type_cle3, loc_transcod.cle3, 2);
        p_initialise (loc_transcod.type_cle_primaire, loc_transcod.cle_primaire, 2 );
        IF (loc_refcie IS NOT NULL) THEN
          BEGIN
            SELECT numindiv,
              typassu,
              typadr,
              NVL (regime, 1),
              numassu
            INTO loc_numindiv,
              loc_typassu,
              loc_typadr,
              loc_regime,
              loc_numassu
            FROM indvs
            WHERE refcie = loc_refcie;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            loc_numindiv := -1;
          END;
        ELSIF (loc_numindiv IS NOT NULL) THEN
          BEGIN
            SELECT refcie,
              typassu,
              typadr,
              NVL (regime, 1),
              numassu
            INTO loc_refcie,
              loc_typassu,
              loc_typadr,
              loc_regime,
              loc_numassu
            FROM indvs
            WHERE numindiv = loc_numindiv;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            loc_refcie := '-1';
          END;
        END IF;
        DBMS_OUTPUT.put_line ('personne  = ' || loc_numindiv);

        IF (loc_typassu = 1) THEN
         loc_idadhesion  := pk_adhesion.f_idadhesion;
          DBMS_OUTPUT.put_line ('idadhesion  = ' || loc_idadhesion);
          INSERT
          INTO adhe_cntrt
            (
              idadhesion,
              ref_ext,
              numgar,
              numadhe,
              date_adhe,
              meme_gar,
              date_fin_adhe,
              numquerable,
              fract,
              echesuiv,
              dereche,
              mregl,
              delai,
              dsous,
              numutil
            )
          SELECT loc_idadhesion,
            loc_idadhesion
            || '/'
            || contrat.refcie,
            loc_numgar,
            loc_numindiv,
            loc_transcod.debut,
            'N',
            NULL,
            loc_numindiv,
            contrat.fract,
            '',
            '',
            contrat.mregl,
            contrat.delai,
            loc_transcod.debut,
            f_numutil
          FROM contrat
          WHERE contrat.numgar = loc_numgar;
          DBMS_OUTPUT.put_line ( 'insertion adhe_cntrt  = ' || loc_idadhesion );
          INSERT INTO histo_adhesion
            (idadhesion, debut, datsai, etat, motif, numutil
            )
          SELECT loc_idadhesion,
            loc_transcod.debut,
            SYSDATE,
            1,
            a_motif,
            f_numutil
          FROM DUAL;
          DBMS_OUTPUT.put_line ( 'insertion histo_adhesion  = ' || loc_idadhesion );
        ELSE
          BEGIN
            SELECT adhe_cntrt.idadhesion
            INTO loc_idadhesion
            FROM adhe_cntrt
            WHERE numadhe = loc_numassu;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            loc_idadhesion := 0;
          END;
        END IF;

        INSERT INTO adhe_cntrt_membre
          (idadhesion, numindiv, typadr, numbene  )
        SELECT loc_idadhesion,
          loc_numindiv,
          loc_typadr,
          ''
        FROM DUAL
        WHERE EXISTS
          (SELECT 1 FROM adhe_cntrt WHERE idadhesion = loc_idadhesion
          )
        AND loc_idadhesion != 0
        AND NOT EXISTS(SELECT 1 FROM adhe_cntrt_membre WHERE idadhesion = loc_idadhesion AND numindiv = loc_numindiv);

        INSERT
        INTO adhesion
          (
            idadhesion,
            numindiv,
            numgar,
            numfor,
            datapli,
            etat,
            typfor,
            numorg,
            flag_regime,
            dis_carence,
            dis_franchise,
            rang,
            numutil,
            creation
          )
        SELECT loc_idadhesion,
          loc_numindiv,
          loc_numgar,
          loc_numfor,
          loc_transcod.debut,
          1,
          gar_cntrt.TYPE,
          loc_regime,
          'C',
          'O',
          'O',
          1,
          f_numutil,
          SYSDATE
        FROM gar_cntrt
        WHERE gar_cntrt.numfor = loc_numfor
        AND gar_cntrt.numgar   = loc_numgar
        AND loc_idadhesion    != 0;

        INSERT INTO histo_transfert
          (numremise, new_numgar, old_numgar, numindiv
          )
        SELECT loc_numremise,
          loc_numgar,
          loc_old_numgar,
          loc_numindiv
        FROM DUAL
        WHERE NOT EXISTS
          (SELECT 1
          FROM histo_transfert
          WHERE numremise = loc_numremise
          AND new_numgar  = loc_numgar
          AND old_numgar  = loc_old_numgar
          AND numindiv    = loc_adhe.numadhe
          );
      END LOOP;
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  pk_trace.p_ins_journal_adm ('TR05T', a_numedit, 0, 'Adhesion en erreur :' ||loc_old_idadhesion, SYSDATE );
  pk_trace.p_ins_journal_adm ('TR05T', a_numedit, 0, 'Fin de traitement anormale :' || SQLERRM, SYSDATE );
END;

  BEGIN
    SELECT count(numindiv)
    INTO loc_nombre
    FROM histo_transfert
    WHERE numremise = loc_numremise
    AND new_numgar  = a_numgar
    AND old_numgar  = a_old_numgar;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    loc_nombre := 0;
  END;

  INSERT
  INTO remise_transfert
    (
      numremise,
      TYPE,
      old_numgar,
      new_numgar,
      debut,
      motif,
      creation,
      nombre
    )
  SELECT loc_numremise,
    a_type,
    a_old_numgar,
    a_numgar,
    a_debut,
    a_motif,
    SYSDATE,
    loc_nombre
  FROM DUAL;
END p_transfert_adhe_resil;

END PK_TRANSFERT;
/
