CREATE OR REPLACE PACKAGE ARTHUS."PK_GEST_COTIS_AF06T"
AS
/*============================================================================*/
/* PACKAGE      : PK_GEST_COTIS_AF06T.sql                                     */
/* Domaine      : Interfaces                                                  */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 26/05/2016                                                  */
/* Description  : Package permettant la gestion des cotisations suite aux     */
/*                intégrations techniques des fichiers d'affiliations/cotis   */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

-- Tableau
Tab_RG  PK_CTRL_AFFIL.T_RG_TAB;

PROCEDURE P_GestCotisations ( i_Porte         IN   AFFIL_PORTE.NUMPORTE%TYPE
                            , i_numremise     IN   AFFIL_FICHIER.NUMREMISE%TYPE
                            , i_numcli        IN   AFFIL_FICHIER.NUMCLI%TYPE
                            , i_numgar        IN   AFFIL_PORTE_ADH.NUMGAR%TYPE
                            , i_Date_deb      IN   DATE
                            , i_Date_fin      IN   DATE
                            , i_session       IN   JOURNAL_ADM.ID_SESSION%TYPE
                            , i_traitement    IN   file_edition.batchid%TYPE
                            , i_idligne       IN   JOURNAL_ADM.IDLIGNE%TYPE
                            , i_numligne      IN   AFFIL_PORTE.NUMLIGNE%TYPE DEFAULT NULL
                            , i_flag_Ident    IN   NUMBER DEFAULT NULL
                            , o_erreur        OUT  VARCHAR2);


PROCEDURE AnnulImportCotisations ( I_numquit      IN   QTTC_GLOBAL.NUMQUIT%TYPE
                                 , i_session      IN   JOURNAL_ADM.ID_SESSION%TYPE
                                 , i_traitement   IN   JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                                 , i_idligne      IN   JOURNAL_ADM.IDLIGNE%TYPE
                                 , o_erreur       OUT  VARCHAR2);

PROCEDURE P_Calcul_a_blanc( I_numquit qttc_global.numquit%TYPE);

PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);

-- ------------------------------------------------- Fin des procedures publiques --
END PK_GEST_COTIS_AF06T;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_GEST_COTIS_AF06T
As
/*============================================================================*/
/* PACKAGE      : PK_GEST_COTIS_AF06T.sql                                     */
/* Domaine      : Production                                                  */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 09/03/2015                                                  */
/* Description  : Package permettant la gestion des affiliations suite aux    */
/*                intégrations techniques des fichiers d'affiliations         */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

   -- -- TYPES PRIVEES ------------------------------------------------------


   -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
--
   -- -- PROCEDURES ET FONCTIONS PRIVEES -----------------------------------------
PROCEDURE MAJ_STATUT_QTTC ( i_numremise     IN   AFFIL_FICHIER.NUMREMISE%TYPE
                            , i_Porte         IN   AFFIL_PORTE.NUMPORTE%TYPE
                            , i_numcli        IN   AFFIL_FICHIER.NUMCLI%TYPE
                            , i_numgar        IN   AFFIL_PORTE_ADH.NUMGAR%TYPE
                            , i_Date_deb      IN   DATE
                            , i_Date_fin      IN   DATE);

   -- -- Déclaration des variables globales   ----------------------------------
  g_session         journal_adm.id_session%TYPE          DEFAULT 1;
  g_nom_traitement  journal_adm.nom_traitement%TYPE:=NULL;
  g_niv_msg         journal_adm.niv_msg%TYPE;
  g_idligne         journal_adm.idligne%TYPE;
  g_msg_adm         journal_adm.msg_adm%TYPE;

  g_numutil         PORTE_PARAM.NUMUTIL%TYPE:=0;

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
/* Nom          :  P_GestCotisations                                         */
/* Type         :  Public                                                    */
/* Description  :  Permet de gérer les cotisations issues de la DSN mensuelle*/
/*                                                                           */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
PROCEDURE P_GestCotisations ( i_Porte         IN   AFFIL_PORTE.NUMPORTE%TYPE
                            , i_numremise     IN   AFFIL_FICHIER.NUMREMISE%TYPE
                            , i_numcli        IN   AFFIL_FICHIER.NUMCLI%TYPE
                            , i_numgar        IN   AFFIL_PORTE_ADH.NUMGAR%TYPE
                            , i_Date_deb      IN   DATE
                            , i_Date_fin      IN   DATE
                            , i_session       IN   JOURNAL_ADM.ID_SESSION%TYPE
                            , i_traitement    IN   file_edition.batchid%TYPE
                            , i_idligne       IN   JOURNAL_ADM.IDLIGNE%TYPE
                            , i_numligne      IN   AFFIL_PORTE.NUMLIGNE%TYPE DEFAULT NULL
                            , i_flag_Ident    IN   NUMBER DEFAULT NULL
                            , o_erreur        OUT  VARCHAR2)
IS


  -- Curseur recherchant les quittances Arthus par contrat à partir des infos issues des fichiers cotisations DSN
  -- pour les statuts 2(a intégré) et 3 (bloqué) pour une période donnée  et une société donnée
  CURSOR C_QUITTANCE(p_statut1  IN    AFFIL_PORTE_QTTC.STATUT%TYPE, p_statut2  IN    AFFIL_PORTE_QTTC.STATUT%TYPE) IS
  SELECT distinct qttc.numquit, adh.numgar,--greatest(qttc.deb_base,af.datefic) datequit,
   af.datefic datequit, af.numcli
  FROM AFFIL_FICHIER af , AFFIL_PORTE_CNTRT cntrt, AFFIL_PORTE_ADH adh, AFFIL_PORTE_QTTC qttc,AFFIL_PORTE ap
  WHERE af.NUMCLI = NVL(i_numcli,af.NUMCLI)
  AND af.numremise = i_numremise
  AND af.numporte = i_porte
  AND af.numporte = adh.numporte
  AND af.numporte=cntrt.numporte
  AND af.numporte=qttc.numporte
  AND cntrt.numremise = af.numremise
  AND adh.numremise = af.numremise
  AND qttc.numremise = af.numremise
  AND cntrt.entreprise = af.entreprise
  AND cntrt.etabli = af.etabli
  AND cntrt.num_ordre = af.num_ordre
  AND cntrt.numporte=ap.numporte
  AND cntrt.numremise = ap.numremise
  AND cntrt.entreprise = ap.entreprise
  AND cntrt.etabli = ap.etabli
  AND cntrt.num_ordre = ap.num_ordre
  AND cntrt.ref_ext_cntrt=adh.ref_ext_cntrt
  AND adh.numligne = ap.numligne
  AND qttc.ref_ext_cntrt = adh.ref_ext_cntrt
  AND qttc.ref_ext_adh = adh.ref_ext_adh
  AND adh.numligne = qttc.numligne
  AND adh.numayd=0               -- ayant droit non pris en compte
  AND qttc.statut IN (p_statut1,p_statut2)
  AND adh.numgar = i_numgar
  AND adh.numgar IS NOT NULL
  AND af.datefic = i_Date_deb
  AND  af.datefic = trunc(qttc.deb_base,'MONTH')
  --AND greatest(qttc.deb_base,af.datefic) BETWEEN i_Date_deb AND i_Date_fin --pour pouvoir valoriser numquit sur hors period jsutifié ==> ôter car on commence par exclure...
  AND qttc.numquit IS NULL
  AND af.num_annulante IS NULL
  AND ap.etat<>4;

  -- identification des bases de cotisations  par contrat à partir des infos issues des fichiers cotisations DSN
  -- pour les statuts 2(a intégré) et 3 (bloqué) pour une période donnée  et une société donnée pour permettre
  -- la mise à jour des données trouvées dans les tables de travail DSN incluant les montants forfaitaires
  CURSOR C_BASE IS
  SELECT distinct  adh.numgar,qttc.numquit,elt.type_elt, adh.refgarantie,adh.code_opt
  FROM  AFFIL_PORTE_ADH adh, AFFIL_PORTE_QTTC qttc, AFFIL_PORTE_QTTC_ELT elt,AFFIL_PORTE ap
  WHERE ap.numremise = i_numremise
  AND ap.numporte = i_porte
  AND ap.numporte = adh.numporte
  AND ap.numporte=qttc.numporte
  AND ap.numporte=elt.numporte
  AND adh.numremise = ap.numremise
  AND qttc.numremise = ap.numremise
  AND elt.numremise = ap.numremise
  AND adh.numligne = ap.numligne
  AND qttc.ref_ext_cntrt = adh.ref_ext_cntrt
  AND qttc.ref_ext_adh = adh.ref_ext_adh
  AND qttc.statut  IN (2,3,5)
  AND adh.numligne = qttc.numligne
  AND qttc.numligne = elt.numligne
  AND qttc.num_qttc = elt.num_qttc
  AND adh.numgar = i_numgar
  AND adh.numayd=0                               -- ayant droit non pris en compte
  AND adh.numgar IS NOT NULL
  AND adh.refgarantie IS NOT NULL
  AND qttc.numquit IS NOT NULL
  AND elt.id_variable IS NULL
  AND ap.etat<>4;


  loc_numremise               AFFIL_PORTE.NUMREMISE%TYPE:=NULL;
  loc_AFFIL_PORTE             AFFIL_PORTE%ROWTYPE;
  loc_code_ano_regul          AFFIL_ANO.NUMANO%TYPE:=0;
  loc_code_ano_numquit        AFFIL_ANO.NUMANO%TYPE:=0;
  loc_code_ano_idvariable     AFFIL_ANO.NUMANO%TYPE:=0;
  loc_code_ano_ventil         AFFIL_ANO.NUMANO%TYPE:=0;
  v_somme_idvar               NUMBER(11,2);
  v_taux                      qttc_variable.taux%TYPE;
  v_deb NUMBEr;
  v_delai NUMBER;

  i                           VARCHAR2(100):=NULL;
  loc_AFFIL_FICHIER           AFFIL_FICHIER%ROWTYPE;
  loc_AFFIL_PORTE_QTTC_ELT    AFFIL_PORTE_QTTC_ELT%ROWTYPE;
  loc_AFFIL_ANO               AFFIL_ANO%ROWTYPE;
  loc_numquit                 AFFIL_PORTE_QTTC.NUMQUIT%TYPE:=NULL;
  loc_idvariable              AFFIL_PORTE_QTTC_ELT.ID_VARIABLE%TYPE:=NULL;
  loc_valeur_mt_forfait       AFFIL_PORTE_QTTC_ELT.VALEUR%TYPE;
  loc_mt_calc                 QTTC_GLOBAL.MT_TTC%TYPE:=NULL;
  loc_log VARCHAR2(50);



BEGIN
  -- TRAITEMENT AF06T : Import fonctionnelle des cotisations
  G_nom_traitement:=i_traitement;
  G_idligne:=i_idligne;
  G_Session := i_session;


  P_INS_journal(3, 'DEBUT P_GestCotisations le '||TO_CHAR(SYSDATE));

    --------------- Récupération de l utilisateur de la porte  ------------------------
  g_numutil:=PK_CTRL_AFFIL.F_FIND_PORTE_NUMUTIL(i_Porte);
  --P_INS_journal(3, 'Utilisateur '||TO_CHAR(g_numutil)|| ' Porte '||i_Porte);

    --------------- Affichage des règles de gestion ----------------------------------
  loc_log := i_numremise||'-'||i_numgar|| ',';
  P_INS_journal(3, loc_log||'Société '||i_numcli||'Fichier du '||i_Date_deb|| ' au '||i_Date_fin);

  -- Alimentation du tableau des règles de gestion
  Tab_RG:=PK_CTRL_AFFIL.F_GET_REG_AFFIL(i_Porte);

  P_INS_journal(3, loc_log||'RG');
  ---------------------------------------------------------------------------------------
  --                             ETAPE IDENTIFICATION                                  --
  ---------------------------------------------------------------------------------------

  loc_AFFIL_ANO.NUMANO:=NULL;

  ---- Détermination des statuts--------------------------------------------------------
  -- 0 - annulées, liées au fichier AR DSN
  -- 2 - en attente
  -- 3 - quittance (numquit) identifié - générallement la quittance n'était pas créé au moment de l'intégration
  -- 5 - pour qttc_elt uniquement quand la variable de cotisation est identifiée (idvariable)
  -- 6 - date des éléments de cotisations hors de l'exercice ou hors trimestre d'intégration ou contrat sans délégation cotisation
  -- 9 - exclusion réalisée manuellement par l'interface. l'interface parle de gestion mentionne les annulées aussi dans les exclues
  -- ==> le statut d'un qttc est issu du MIN du statut de ses éléments qttc_elt
  ---------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------
  -- exclusion des contrats dont la cotisation n'est pas gérées c.gest_cotis =3 statut => 6
  ---------------------------------------------------------------------------------------
 v_deb:=DBMS_UTILITY.GET_TIME;

  UPDATE AFFIL_PORTE_QTTC qttc SET STATUT = 6
   WHERE numporte= i_Porte
   AND qttc.numremise = i_numremise
   --AND qttc.deb_base between i_Date_deb and i_Date_fin
   AND EXISTS (
   SELECT numligne FROM AFFIL_PORTE_ADH adh, contrat c
    WHERE qttc.numremise = adh.numremise
     AND qttc.numporte = adh.numporte
     AND qttc.ref_ext_cntrt = adh.ref_ext_cntrt
     AND qttc.ref_ext_adh = adh.ref_ext_adh
     AND qttc.numligne = adh.numligne
     AND adh.numgar = i_NUMGAR
     AND adh.numgar = c.numgar
     AND c.gest_cotis =3
     );

   IF SQL%ROWCOUNT >0 THEN
    P_INS_journal(3, loc_log||' contrat sans cot gérée :'||SQL%ROWCOUNT);
    RETURN;
   END IF;
   v_delai:=DBMS_UTILITY.GET_TIME- v_deb;
   P_INS_journal(3, loc_log||'Délai ='|| v_delai);
   ---------------------------------------------------------------------------------------
  -- exclusion des contrats résiliés statut => 6
  ---------------------------------------------------------------------------------------
 v_deb:=DBMS_UTILITY.GET_TIME;
  UPDATE AFFIL_PORTE_QTTC qttc SET STATUT = 6
   WHERE numporte= i_Porte
   AND qttc.numremise = i_numremise
   --AND qttc.deb_base between i_Date_deb and i_Date_fin
   AND EXISTS (
   SELECT numligne FROM AFFIL_PORTE_ADH adh, contrat c
    WHERE qttc.numremise = adh.numremise
     AND qttc.numporte = adh.numporte
     AND qttc.ref_ext_cntrt = adh.ref_ext_cntrt
     AND qttc.ref_ext_adh = adh.ref_ext_adh
     AND qttc.numligne = adh.numligne
     AND adh.numgar = i_NUMGAR
     AND adh.numgar = c.numgar
     AND pk_histo_contrat.f_sel_etat(c.numgar,i_Date_deb) =3
     );
   IF SQL%ROWCOUNT >0 THEN
    P_INS_journal(3, loc_log||' contrat résilié : '||SQL%ROWCOUNT);
     v_delai:=DBMS_UTILITY.GET_TIME- v_deb;    P_INS_journal(3, loc_log||'Délai ='|| v_delai);
    RETURN;
   END IF;


  ---------------------------------------------------------------------------------------
  -- Blocage des régularisations hors excercies civile statut => 6
  ---------------------------------------------------------------------------------------
  IF Tab_RG.EXISTS('COT_REGEXE') THEN
    v_deb:=DBMS_UTILITY.GET_TIME;
    UPDATE AFFIL_PORTE_QTTC SET STATUT = 6
    WHERE NUMREMISE = i_numremise
    AND NUMPORTE = i_Porte
    AND (STATUT <> 6  OR statut IS NULL)
    AND (numligne,ref_ext_cntrt, ref_ext_adh, num_qttc) IN
      (SELECT distinct qttc.numligne,qttc.ref_ext_cntrt, qttc.ref_ext_adh, qttc.num_qttc
      FROM AFFIL_FICHIER af, AFFIL_PORTE_ADH adh, qttc_global cot, AFFIL_PORTE_QTTC qttc, AFFIL_PORTE ap
      WHERE adh.NUMGAR = i_numgar
      AND af.NUMREMISE =i_numremise
      AND af.numporte = i_porte
      AND af.numporte = adh.numporte
      AND af.numremise = ap.numremise
      AND af.entreprise = ap.entreprise
      AND af.etabli = ap.etabli
      AND af.num_ordre = ap.num_ordre
      AND adh.numligne = ap.numligne
      AND adh.numremise = af.numremise
      AND adh.numayd=0                   -- ayant droit non pris en compte
      AND cot.numgar =adh.numgar
      AND af.DATEFIC BETWEEN cot.debut AND cot.fin
      AND qttc.numremise = adh.numremise
      AND qttc.numporte = adh.numporte
      AND qttc.REF_EXT_CNTRT = adh.REF_EXT_CNTRT
      AND qttc.REF_EXT_ADH = adh.REF_EXT_ADH
      AND qttc.numligne = adh.numligne
      AND TO_CHAR(af.DATEFIC,'YYYY')<> TO_CHAR(qttc.deb_base,'YYYY'));
  -- IF SQL%ROWCOUNT >0 THEN
    P_INS_journal(3, loc_log||' cot hors exe :'||SQL%ROWCOUNT);
   --END IF;
    v_delai:=DBMS_UTILITY.GET_TIME- v_deb;    P_INS_journal(3, loc_log||'Délai ='|| v_delai);
  ---------------------------------------------------------------------------------------
  -- Blocage des régularisations hors trimestre statut => 6
  ---------------------------------------------------------------------------------------
  ELSIF Tab_RG.EXISTS('COT_REGUL') THEN

     --prend en compte le fractionnement contrat par la jointure sur qttc_global
    v_deb:=DBMS_UTILITY.GET_TIME;
    UPDATE AFFIL_PORTE_QTTC SET STATUT = 6
    WHERE NUMREMISE = i_numremise
    AND NUMPORTE = i_Porte
    AND statut IS NOT NULL
    AND statut NOT IN (6,0)--pas déjà exclu ou annulée
    AND (numligne,ref_ext_cntrt, ref_ext_adh, num_qttc) IN
      (SELECT distinct qttc.numligne,qttc.ref_ext_cntrt, qttc.ref_ext_adh, qttc.num_qttc
      FROM AFFIL_FICHIER af, AFFIL_PORTE_ADH adh, qttc_global cot, AFFIL_PORTE_QTTC qttc, AFFIL_PORTE ap
      WHERE adh.NUMGAR = i_numgar
      AND af.NUMREMISE =i_numremise
      AND af.numporte = i_porte
      AND af.numporte = adh.numporte
      AND af.numremise = ap.numremise
      AND af.entreprise = ap.entreprise
      AND af.etabli = ap.etabli
      AND af.num_ordre = ap.num_ordre
      AND adh.numligne = ap.numligne
      AND adh.numremise = af.numremise
      AND adh.numayd=0                   -- ayant droit non pris en compte
      AND cot.numgar =adh.numgar
      AND af.DATEFIC BETWEEN cot.debut AND cot.fin
      AND qttc.numremise = adh.numremise
      AND qttc.numporte = adh.numporte
      AND qttc.REF_EXT_CNTRT = adh.REF_EXT_CNTRT
      AND qttc.REF_EXT_ADH = adh.REF_EXT_ADH
      AND qttc.numligne = adh.numligne
      AND qttc.deb_base NOT BETWEEN  cot.debut AND cot.fin);
   --IF SQL%ROWCOUNT >0 THEN
    P_INS_journal(3, loc_log||' cot hors TRIM :'||SQL%ROWCOUNT);
  -- END IF;
    v_delai:=DBMS_UTILITY.GET_TIME- v_deb;    P_INS_journal(3, loc_log||'Délai ='|| v_delai);

  ---------------------------------------------------------------------------------------
  -- Blocage des régularisations hors trimestre statut => 6
  ---------------------------------------------------------------------------------------
  ELSIF  Tab_RG.EXISTS('COT_REGMENS') THEN
  --le meme update mais en mensuel uniquement TO_CHAR(af.DATEFIC,'MMYYYY') = TO_CHAR(qttc.deb_base,'MMYYYY')
    v_deb:=DBMS_UTILITY.GET_TIME;
    UPDATE AFFIL_PORTE_QTTC SET STATUT = 6
    WHERE NUMREMISE = i_numremise
    AND NUMPORTE = i_Porte
    AND NVL(STATUT,1) NOT IN (6,0)--pas déjà exclu ou annulée
    AND (numligne,ref_ext_cntrt, ref_ext_adh, num_qttc) IN
      (SELECT distinct qttc.numligne,qttc.ref_ext_cntrt, qttc.ref_ext_adh, qttc.num_qttc
      FROM AFFIL_FICHIER af, AFFIL_PORTE_ADH adh, qttc_global cot, AFFIL_PORTE_QTTC qttc, AFFIL_PORTE ap
      WHERE adh.NUMGAR = i_numgar
      AND af.NUMREMISE =i_numremise
      AND af.numporte = i_porte
      AND af.numporte = adh.numporte
      AND af.numremise = ap.numremise
      AND af.entreprise = ap.entreprise
      AND af.etabli = ap.etabli
      AND af.num_ordre = ap.num_ordre
      AND adh.numligne = ap.numligne
      AND adh.numremise = af.numremise
      AND adh.numayd=0                   -- ayant droit non pris en compte
      AND cot.numgar =adh.numgar
      AND af.DATEFIC BETWEEN cot.debut AND cot.fin
      AND qttc.numremise = adh.numremise
      AND qttc.numporte = adh.numporte
      AND qttc.REF_EXT_CNTRT = adh.REF_EXT_CNTRT
      AND qttc.REF_EXT_ADH = adh.REF_EXT_ADH
      AND qttc.numligne = adh.numligne
      AND TO_CHAR(af.DATEFIC,'MMYYYY')<> TO_CHAR(qttc.deb_base,'MMYYYY'));
   --IF SQL%ROWCOUNT >0 THEN
    P_INS_journal(3, loc_log||' cot hors MOIS :'||SQL%ROWCOUNT);
   --END IF;
    v_delai:=DBMS_UTILITY.GET_TIME- v_deb;    P_INS_journal(3, loc_log||'Délai ='|| v_delai);

  END IF;

  --mise à jour commune du statut sur QTTC_ELT en cohérence avec QTTC ==> pas de filtre sur le contrat donc c redondant
  v_deb:=DBMS_UTILITY.GET_TIME;
  UPDATE AFFIL_PORTE_QTTC_ELT SET STATUT = 6
    WHERE NUMREMISE = i_numremise
    AND NUMPORTE = i_Porte
    AND NVL(STATUT,1) NOT IN (6,0)--pas déjà exclu ou annulée
    AND (numligne, ref_ext_adh, num_qttc) IN
      (SELECT distinct numligne, ref_ext_adh, num_qttc
      FROM AFFIL_PORTE_QTTC
      WHERE NUMREMISE = i_numremise
      AND NUMPORTE = i_Porte
      AND STATUT = 6);
 --  IF SQL%ROWCOUNT >0 THEN
    P_INS_journal(3, loc_log||' Maj statut 6 qttc_elt :'||SQL%ROWCOUNT);
  -- END IF;
    v_delai:=DBMS_UTILITY.GET_TIME- v_deb;    P_INS_journal(3, loc_log||'Délai ='|| v_delai);
  ---------------------------------------------------------------------------------------
  -- identification de la quittance par contrat
  -- les lignes exclues sont quand même identifiée sur la quittance afin d'avoir une interface cohérente
  ---------------------------------------------------------------------------------------

  FOR REC_QUITTANCE IN  C_QUITTANCE(2,3) LOOP


    loc_numquit:=F_FIND_NUMQUIT ( REC_QUITTANCE.NUMGAR
                                , REC_QUITTANCE.datequit
                                , loc_code_ano_numquit);

   v_deb:=DBMS_UTILITY.GET_TIME;
    IF loc_code_ano_numquit > 0 THEN
      P_INS_journal(1, loc_log||'Quittance non identifiée :'||REC_QUITTANCE.datequit||'- ano :'||loc_code_ano_numquit);
      /*loc_AFFIL_ANO.NUMANO:=loc_code_ano_numquit;
      loc_AFFIL_ANO.ETATANO :=3;
      PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
      loc_AFFIL_ANO.NUMANO:=NULL;*/

      -- Mise à jour du statut à 3 si aucune quittance n'est trouvée
      UPDATE AFFIL_PORTE_QTTC qttc SET STATUT = 3
      WHERE numporte= i_porte
      AND qttc.numremise = i_numremise
      --AND qttc.deb_base between i_Date_deb and i_Date_fin
      AND statut NOT IN (0,6)
      AND EXISTS (
        SELECT numligne FROM AFFIL_PORTE_ADH adh
        WHERE qttc.numremise = adh.numremise
        AND qttc.numporte = adh.numporte
        AND qttc.ref_ext_cntrt = adh.ref_ext_cntrt
        AND qttc.ref_ext_adh = adh.ref_ext_adh
        AND qttc.numligne = adh.numligne
        AND adh.numgar = i_numgar);
      P_INS_journal(3, loc_log||' Maj statut 3 qttc :'||SQL%ROWCOUNT);

    ELSE
      ---------------------------------------------------------------------------------------
      -- Mise à jour des quittances par contrat à l'identique du curseur !
      -- on met à jour également les données exclues pour avoir un affichage cohérent
      ---------------------------------------------------------------------------------------
      UPDATE  AFFIL_PORTE_QTTC qttc set numquit = loc_numquit,statut = 3
      WHERE numporte= i_porte
      AND qttc.numremise = i_numremise
      --AND qttc.deb_base between i_Date_deb and i_Date_fin
      AND statut NOT IN (0)
      AND EXISTS (
        SELECT numligne FROM AFFIL_PORTE_ADH adh
        WHERE qttc.numremise = adh.numremise
        AND qttc.numporte = adh.numporte
        AND qttc.ref_ext_cntrt = adh.ref_ext_cntrt
        AND qttc.ref_ext_adh = adh.ref_ext_adh
        AND qttc.numligne = adh.numligne
        AND adh.numgar = i_numgar);

      P_INS_journal(1,loc_log|| 'Quittance identifiée '||TO_CHAR(loc_numquit)||'-'||REC_QUITTANCE.datequit|| 'nb:'||SQL%ROWCOUNT);

    END IF;
     v_delai:=DBMS_UTILITY.GET_TIME- v_deb;    P_INS_journal(3, loc_log||'Délai ='|| v_delai);
  END LOOP;
  ---------------------------------------------------------------------------------------
  -- identification des bases de cotisations
  ---------------------------------------------------------------------------------------
  FOR REC_BASE IN C_BASE LOOP

    P_INS_journal(1, 'Identification base qttc '||REC_BASE.NUMQUIT);
    v_deb:=DBMS_UTILITY.GET_TIME;
    loc_idvariable:=F_FIND_BASE_QTTC( REC_BASE.refgarantie
                                    , REC_BASE.code_opt
                                    , REC_BASE.NUMQUIT
                                    , REC_BASE.TYPE_ELT
                                    , loc_code_ano_idvariable);
     v_delai:=DBMS_UTILITY.GET_TIME- v_deb;    P_INS_journal(3, loc_log||'Délai ='|| v_delai);

    --Dbms_Output.Put_Line('Identification des variables :'||loc_idvariable ||' option:'||REC_BASE.CODE_OPT ||' Anomalie :'||loc_code_ano_idvariable);
    IF loc_idvariable =0 THEN
      P_INS_journal(1, loc_log||'Variable non identifiée '||loc_code_ano_idvariable || ' qttc : '||REC_BASE.NUMQUIT || ' gar:'||REC_BASE.refgarantie|| ' elt:'||REC_BASE.TYPE_ELT);
      CONTINUE; --identification suivante
    END IF;



    ---------------------------------------------------------------------------------------
    --                             MONTANT FORFAITAIRE                                   --
    ---------------------------------------------------------------------------------------
    --Les montants forfaitaires sont à traiter par qttc_elt et donc par salarié
    -- l'état à 5 permet avec valeur à null
    -- si un montant forfaitaire est communiqué(i_type_elt = 20), il faut contrôler sa cohérence
    --pour le moment on ne remonte pas d'anomalie pour les cotisations /montant forfaitaires

    IF REC_BASE.type_elt =20 THEN
      SELECT NVL(SUM(TAUX),0) INTO v_taux
      FROM QTTC_VARIABLE qv
      WHERE qv.numquit = REC_BASE.NUMQUIT
      AND qv.idbase = loc_idvariable
      AND qv.typtaux = 2; --forfait et non %

      --pour éviter les divisions par 0
      IF v_taux = 0 THEN
        P_INS_journal(1,loc_log||'Taux nul qttc : '||REC_BASE.NUMQUIT || ' gar:'||REC_BASE.refgarantie|| ' var :'||loc_idvariable|| ' elt:'||REC_BASE.TYPE_ELT);
        CONTINUE; --identification suivante
      END IF;

    END IF;

      --Faire un curseur indiquant les cotisations forfaitaires ne respectant pas le montant attendu
      -- nouvelle boucle car c_base ne regarde pas les dates d'échéance...
      --ou alors ne faire l'update que de l'idvariable et sortir la partie valeur pour les forfaits ?
      --deux cas de figures :
      -- montant > forfait contractuelle ===> ano à porter sur le salarié et statut particulier
      -- montant < forfait contractuelle et échéance de cotisation non entière (qttc.deb_base) pour gérer les proratas
      -- montant < forfait mais échéance complète ===> ano à porter sur le salarié et statut particulier

      --revoir en conséquence l'update avec le décode ci dessous
    v_deb:=DBMS_UTILITY.GET_TIME;
    IF REC_BASE.type_elt =20 THEN
      UPDATE AFFIL_PORTE_QTTC_ELT SET ID_VARIABLE = loc_idvariable , STATUT=5,
                                      VALEUR = decode(MOD(mt_elt,v_taux),0,mt_elt/v_taux,mt_elt,null,null)
      WHERE numporte = i_porte
      AND type_elt = REC_BASE.type_elt
      AND statut NOT IN (0,6,9) --on ne prend pas en compte les variables annulées,hors périodes, exlcues
      AND (numremise ,numligne, ref_ext_adh, num_qttc) IN
      (SELECT distinct  adh.numremise,adh.numligne,adh.ref_ext_adh ,qttc.num_qttc
        FROM AFFIL_PORTE_ADH adh, AFFIL_PORTE_QTTC qttc, AFFIL_PORTE_QTTC_ELT elt
        WHERE adh.numremise = i_numremise
        AND adh.numporte = i_porte
        AND adh.numporte =qttc.numporte
        AND adh.numporte =elt.numporte
        AND coalesce(adh.code_opt,'0') = coalesce(REC_BASE.code_opt,'0')
        AND qttc.numremise = adh.numremise
        AND elt.numremise = adh.numremise
        AND qttc.ref_ext_cntrt = adh.ref_ext_cntrt
        AND qttc.ref_ext_adh = adh.ref_ext_adh
        AND qttc.statut IN (2,3,5) --laissé état 5 car plusieurs éléments dans un qttc
        AND adh.numligne = qttc.numligne
        AND adh.numayd=0                           -- ayant droit non pris en compte
        AND qttc.numligne = elt.numligne
        AND qttc.num_qttc = elt.num_qttc
        AND adh.numgar = REC_BASE.NUMGAR
        AND adh.refgarantie = REC_BASE.refgarantie
        AND adh.numgar IS NOT NULL
        AND qttc.numquit = REC_BASE.NUMQUIT
        AND qttc.numquit IS NOT NULL
        AND elt.type_elt = REC_BASE.type_elt
        AND elt.id_variable IS NULL
      );
      --création d'un signalement sur l'affiliation lorsque le montant forfaitaire est incohérent (sans contrôle de proratisation deb_base)
      INSERT INTO AFFIL_ANO (NUMPORTE,NUMREMISE,NUMLIGNE,NUMANO,DATANO,ETATANO)
      SELECT NUMPORTE,NUMREMISE,NUMLIGNE, 96, SYSDATE,7
      FROM AFFIL_PORTE_QTTC_ELT elt
      WHERE elt.numremise = i_numremise
        AND elt.numporte = i_porte
        AND elt.valeur IS NULL
        AND elt.statut = 5
        and elt.id_variable = loc_idvariable
        and not exists (
          select 1 from affil_ano
          where numremise = i_numremise
          and numporte= i_porte
          AND numano = 96
          and numligne=elt.numligne);
    ELSE
      UPDATE AFFIL_PORTE_QTTC_ELT SET ID_VARIABLE = loc_idvariable , STATUT=5,
                                      VALEUR =  mt_elt
      WHERE numporte = i_porte
      AND type_elt = REC_BASE.type_elt
      AND statut NOT IN (0,6,9) --on ne prend pas en compte les variables annulées,hors périodes, exlcues
      AND (numremise ,numligne, ref_ext_adh, num_qttc) IN
      (SELECT distinct  adh.numremise,adh.numligne,adh.ref_ext_adh ,qttc.num_qttc
        FROM AFFIL_PORTE_ADH adh, AFFIL_PORTE_QTTC qttc, AFFIL_PORTE_QTTC_ELT elt
        WHERE adh.numremise = i_numremise
        AND adh.numporte = i_porte
        AND adh.numporte =qttc.numporte
        AND adh.numporte =elt.numporte
        AND coalesce(adh.code_opt,'0') = coalesce(REC_BASE.code_opt,'0')
        AND qttc.numremise = adh.numremise
        AND elt.numremise = adh.numremise
        AND qttc.ref_ext_cntrt = adh.ref_ext_cntrt
        AND qttc.ref_ext_adh = adh.ref_ext_adh
        AND qttc.statut IN (2,3,5) --laissé état 5 car plusieurs éléments dans un qttc
        AND adh.numligne = qttc.numligne
        AND adh.numayd=0                           -- ayant droit non pris en compte
        AND qttc.numligne = elt.numligne
        AND qttc.num_qttc = elt.num_qttc
        AND adh.numgar = REC_BASE.NUMGAR
        AND adh.refgarantie = REC_BASE.refgarantie
        AND adh.numgar IS NOT NULL
        AND qttc.numquit = REC_BASE.NUMQUIT
        AND qttc.numquit IS NOT NULL
        AND elt.type_elt = REC_BASE.type_elt
        AND elt.id_variable IS NULL
      );
   END IF;

   P_INS_journal(3, loc_log||' variable :'||loc_idvariable ||' nb:'||SQL%ROWCOUNT);
    v_delai:=DBMS_UTILITY.GET_TIME- v_deb;    P_INS_journal(3, loc_log||'Délai ='|| v_delai);



  END LOOP;
  --TO DO UTILE ???
    ---------------------------------------------------------------------------------------
  -- Mise à jour du statut de qttc faite en dehors de la boucle pour les quittances identifiées
  ---------------------------------------------------------------------------------------
   v_deb:=DBMS_UTILITY.GET_TIME;
   P_INS_journal(1, loc_log||'Mise à jour du statut contrat '||i_numgar);
   MAJ_STATUT_QTTC ( i_numremise,i_Porte, i_numcli, i_numgar, i_Date_deb , i_Date_fin );
   v_delai:=DBMS_UTILITY.GET_TIME- v_deb;    P_INS_journal(3, loc_log||'Délai ='|| v_delai);

   COMMIT;

  P_INS_journal(3, 'FIN PK_GEST_COTIS_AF06T.P_GestCotisations le '||TO_CHAR(SYSDATE));
  o_erreur:='Fin normale du traitement';

 END P_GestCotisations;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_ValCotisations                                         */
/* Type         :  Public                                                    */
/* Description  :  Permet de gérer les cotisations issues de la DSN mensuelle*/
/*                                                                           */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
PROCEDURE P_ValCotisations ( i_numremise     IN   AFFIL_FICHIER.NUMREMISE%TYPE
                            , i_Porte         IN   AFFIL_PORTE.NUMPORTE%TYPE
                            , i_numcli        IN   AFFIL_FICHIER.NUMCLI%TYPE
                            , i_numgar        IN   AFFIL_PORTE_ADH.NUMGAR%TYPE
                            , i_Date_deb      IN   DATE
                            , i_Date_fin      IN   DATE
                            , i_session       IN   JOURNAL_ADM.ID_SESSION%TYPE
                            , i_traitement    IN   file_edition.batchid%TYPE
                            , i_idligne       IN   JOURNAL_ADM.IDLIGNE%TYPE
                            , i_numligne      IN   AFFIL_PORTE.NUMLIGNE%TYPE DEFAULT NULL
                            , i_flag_Ident    IN   NUMBER DEFAULT NULL
                            , o_erreur        OUT  VARCHAR2)
IS
 -- Curseur parcourant les quittances Arthus trouvées par contrat à partir des infos issues des fichiers cotisations DSN
  -- pour les statuts 5 'Identifiée mais non ventilée' pour une période donnée  et une société donnée afin de sommer les valeures
  -- par idvariable puis ventiller
  CURSOR C_NUMQUIT IS
  SELECT distinct qttc.numquit, adh.numgar,af.numcli
  FROM AFFIL_FICHIER af , AFFIL_PORTE_CNTRT cntrt, AFFIL_PORTE_ADH adh, AFFIL_PORTE_QTTC qttc,affil_porte ap
  WHERE af.NUMCLI = NVL(i_numcli,af.NUMCLI)
  AND af.numporte = i_porte
  AND af.numporte = adh.numporte
  AND af.numporte=cntrt.numporte
  AND af.numporte=qttc.numporte
  AND cntrt.numremise = af.numremise
  AND adh.numremise = af.numremise
  AND qttc.numremise = af.numremise
  AND cntrt.entreprise = af.entreprise
  AND cntrt.etabli = af.etabli
  AND cntrt.num_ordre = af.num_ordre
  AND cntrt.numporte=ap.numporte
  AND cntrt.numremise = ap.numremise
  AND cntrt.entreprise = ap.entreprise
  AND cntrt.etabli = ap.etabli
  AND cntrt.num_ordre = ap.num_ordre
  AND adh.numligne = ap.numligne
  AND qttc.ref_ext_cntrt = adh.ref_ext_cntrt
  AND qttc.ref_ext_adh = adh.ref_ext_adh
  AND adh.numligne = qttc.numligne
  AND adh.numayd=0               -- ayant droit non pris en compte
  AND adh.numgar = i_numgar
  AND adh.numgar IS NOT NULL
  AND af.datefic BETWEEN i_Date_deb AND NVL(i_Date_fin,af.datefic)
  AND greatest(qttc.deb_base,af.datefic) BETWEEN i_Date_deb AND NVL(i_Date_fin,af.datefic)
  AND qttc.numquit IS NOT NULL
  AND qttc.statut>= 5
  AND af.num_annulante IS NULL
  AND ap.etat<>4;


  CURSOR C_ventilation(P_numquit   IN    AFFIL_PORTE_QTTC.NUMQUIT%TYPE)
      IS
  SELECT  qttc.numquit , vv.idvariable , vv.usermaj,qttc.debut,qttc.fin
    FROM qttc_global qttc
       , VAL_VARIABLE vv
  WHERE qttc.numquit =  P_numquit
    AND qttc.numgar = i_numgar
    AND vv.NUMGAR= qttc.numgar
    AND vv.etendue = 2
    AND qttc.debut = vv.debut
    AND qttc.fin=vv.fin;


  loc_numremise               AFFIL_PORTE.NUMREMISE%TYPE:=NULL;
  loc_AFFIL_PORTE             AFFIL_PORTE%ROWTYPE;
  loc_code_ano_regul          AFFIL_ANO.NUMANO%TYPE:=0;
  loc_code_ano_numquit        AFFIL_ANO.NUMANO%TYPE:=0;
  loc_code_ano_idvariable     AFFIL_ANO.NUMANO%TYPE:=0;
  loc_code_ano_ventil         AFFIL_ANO.NUMANO%TYPE:=0;
  v_somme_idvar               NUMBER(11,2);
  v_taux                      qttc_variable.taux%TYPE;

  i                           VARCHAR2(100):=NULL;
  loc_AFFIL_FICHIER           AFFIL_FICHIER%ROWTYPE;
  loc_AFFIL_PORTE_QTTC_ELT    AFFIL_PORTE_QTTC_ELT%ROWTYPE;
  loc_AFFIL_ANO               AFFIL_ANO%ROWTYPE;
  loc_numquit                 AFFIL_PORTE_QTTC.NUMQUIT%TYPE:=NULL;
  loc_idvariable              AFFIL_PORTE_QTTC_ELT.ID_VARIABLE%TYPE:=NULL;
  loc_valeur_mt_forfait       AFFIL_PORTE_QTTC_ELT.VALEUR%TYPE;
  loc_mt_calc                 QTTC_GLOBAL.MT_TTC%TYPE:=NULL;
BEGIN

 --to do faire un insert affil_ano de masse pour les salariés dont qttc.valeur à null et idvariable valorisé => montant forfaitaire non cohérent ano 95
  ---------------------------------------------------------------------------------------
  --                             ETAPE VENTILLATION                                    --
  ---------------------------------------------------------------------------------------
  P_INS_journal(1, 'Identification: '||i_flag_Ident);
  -- On ne fait pas l'étape de ventilation si le paramétrage du traitement AF06T avec le param1=1
  IF NVL(i_flag_Ident,0) = 0 THEN
    -- On parcours toutes les quittances au statut 5 'Identifié mais non ventillé' afin de sommer les valeures
    -- par idvariable puis ventiller

    FOR REC_NUMQUIT IN  C_NUMQUIT LOOP
      loc_code_ano_ventil:=0;

      -- Vérification si l'échéance a été déjà calculée
      SELECT NVL(MAX(q.MT_TTC),0)
        INTO loc_mt_calc
       FROM qttc_global q
      WHERE q.NUMQUIT= REC_NUMQUIT.numquit;

      IF loc_mt_calc > 0 THEN
        loc_code_ano_ventil:=8; -- Ventil impossible:échéance déjà calculée
      END IF; --pour le moment on  bloque les déjà calculée
      --ELSE
      P_INS_journal(2, 'Quittance :'||REC_NUMQUIT.numquit ||' du contrat :'||REC_NUMQUIT.numgar);
      FOR REC_ventilation IN  C_ventilation(REC_NUMQUIT.numquit) LOOP

         IF  REC_ventilation.usermaj<> g_numutil AND Tab_RG.EXISTS('COT_MAN') THEN
            loc_code_ano_ventil:=10; -- Ventil impossible:échéance saisi manuellement
            P_INS_journal(3, 'Ventilation, numquit :'||REC_NUMQUIT.numquit ||'variable :'||REC_ventilation.idvariable);
            --TO DO rajout d'un statut 10 correspondant à une ano 93 ?
            CONTINUE;
        END IF;
         P_INS_journal(3, 'Ventilation, numquit :'||REC_NUMQUIT.numquit ||'variable :'||REC_ventilation.idvariable);

        --on somme les valeurs DSN pour chaque idvariable
        --index à vérifier sur le numquit notamment

        v_somme_idvar:=0;
        BEGIN
          SELECT NVL(sum(elt.valeur),0) INTO v_somme_idvar
            FROM affil_porte_qttc qttc
               , AFFIL_PORTE_QTTC_ELT elt
          WHERE elt.statut >=5 --uniqument les identifiées
            AND elt.statut NOT IN (0,6,9) --ni annulées ni exclu ni hors période
            AND elt.statut IS NOT NULL
            AND qttc.statut  NOT IN (0,6)
            AND qttc.statut IS NOT NULL
            AND elt.ID_VARIABLE = REC_ventilation.idvariable
            AND qttc.numquit =  REC_ventilation.numquit
            AND elt.valeur IS NOT NULL --important pour les montants forfaitaires
            AND qttc.numporte = i_porte
            AND qttc.numporte = elt.numporte
            AND qttc.numremise = elt.numremise
            AND qttc.NUM_QTTC = elt.NUM_QTTC
            AND qttc.numligne = elt.numligne;

        EXCEPTION
          WHEN OTHERS THEN v_somme_idvar:=0;
        END;

        -- Vérification si l'échéance a été saisie/modifiée manuellement

          -- Mise à jour de la somme dans la table VAL_VARIABLE
          UPDATE VAL_VARIABLE vv
             SET vv.VALEUR  = v_somme_idvar , usermaj = g_numutil
           WHERE vv.idvariable = REC_ventilation.idvariable
             AND vv.NUMGAR = REC_NUMQUIT.numgar
             AND vv.etendue = 2
             AND REC_ventilation.debut = vv.debut
             AND REC_ventilation.fin=vv.fin;
          IF SQL%ROWCOUNT > 0 THEN loc_code_ano_ventil:=15;--Integré
          ELSE loc_code_ano_ventil :=11;
          END IF;

        P_INS_journal(1, 'Quittance :'||REC_NUMQUIT.numquit || ' variable:'||REC_ventilation.idvariable||' valeur :'||v_somme_idvar ||' état:'||loc_code_ano_ventil);

        UPDATE AFFIL_PORTE_QTTC_ELT SET STATUT =loc_code_ano_ventil
        WHERE numporte = i_porte
          AND ID_VARIABLE = REC_ventilation.idvariable
          AND (numremise ,numligne, ref_ext_adh, num_qttc) IN
          (SELECT distinct  elt.numremise,elt.numligne,elt.ref_ext_adh ,elt.num_qttc
            FROM affil_porte_qttc qttc
               , AFFIL_PORTE_QTTC_ELT elt
         WHERE elt.statut >=5 --uniqument les identifiées
            AND elt.statut NOT IN (0,6,9) --ni annulées ni exclu ni hors période
            AND elt.statut IS NOT NULL
            AND qttc.statut  NOT IN (0,6)
            AND elt.NUM_QTTC = qttc.NUM_QTTC
            AND elt.NUMLIGNE = qttc.NUMLIGNE
            AND elt.ID_VARIABLE = REC_ventilation.idvariable
            AND qttc.numquit =  REC_ventilation.numquit
            AND elt.valeur IS NOT NULL --important pour les montants forfaitaires
            AND qttc.numporte = i_porte
            AND qttc.numporte = elt.numporte
            AND qttc.numremise = elt.numremise
           );


      END LOOP;

    END LOOP;
  END IF; -- IF NVL(loc_param1,0) < 0 THEN

  ---------------------------------------------------------------------------------------
  -- Mise à jour du statut de qttc faite en dehors de la boucle pour les quittances identifiées
  ---------------------------------------------------------------------------------------
   P_INS_journal(1, 'Mise à jour du statut contrat '||i_numgar);
   MAJ_STATUT_QTTC (i_numremise, i_Porte, i_numcli, i_numgar, i_Date_deb , i_Date_fin );

   COMMIT;

  P_INS_journal(3, 'FIN PK_GEST_COTIS_AF06T.P_GestCotisations le '||TO_CHAR(SYSDATE));
  o_erreur:='Fin normale du traitement';

EXCEPTION
  WHEN OTHERS THEN
    -- Annulation
    ROLLBACK;
    P_INS_journal(1,'P_GestCotisations '||SUBSTR(SQLERRM,1,132));
    o_erreur:='Fin anormale P_GestCotisations '||SUBSTR(SQLERRM,1,132);
END P_ValCotisations;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  MAJ_STATUT_QTTC                                           */
/* Type         :  Privée                                                    */
/* Description  :  met à jour le statut d'une ligne de cot en fct des elts   */
/* Entree       :  I_numquit, numéro de quittance                            */
/*                 i_session ,                                               */
/*                 i_traitement                                              */
/*                 i_idligne                                                 */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/

PROCEDURE MAJ_STATUT_QTTC (  i_numremise     IN   AFFIL_FICHIER.NUMREMISE%TYPE
                            , i_Porte         IN   AFFIL_PORTE.NUMPORTE%TYPE
                            , i_numcli        IN   AFFIL_FICHIER.NUMCLI%TYPE
                            , i_numgar        IN   AFFIL_PORTE_ADH.NUMGAR%TYPE
                            , i_Date_deb      IN   DATE
                            , i_Date_fin      IN   DATE) IS

BEGIN

  UPDATE AFFIL_PORTE_QTTC qttc2 SET STATUT = NVL((
   SELECT MIN(elt.statut) FROM affil_porte_qttc_elt elt
   WHERE elt.numporte = qttc2.numporte
   AND elt.numremise = qttc2.numremise
   AND elt.numligne = qttc2.numligne
   AND elt.ref_ext_adh = qttc2.ref_ext_adh
   AND elt.num_qttc = qttc2.num_qttc
   AND elt.statut<>9     ),9)
  WHERE qttc2.numporte = i_porte
  AND qttc2.numremise = i_numremise
  AND qttc2.numquit IS NOT NULL -- quittance identifiée uniquement
  AND  qttc2.statut NOT IN (0,6,9) --cotisation hors période
  AND (numremise,numligne,ref_ext_cntrt, ref_ext_adh, num_qttc) IN
  (SELECT distinct qttc.numremise,qttc.numligne,qttc.ref_ext_cntrt, qttc.ref_ext_adh, qttc.num_qttc
   FROM AFFIL_FICHIER af , AFFIL_PORTE_CNTRT cntrt, AFFIL_PORTE_ADH adh, affil_porte ap, AFFIL_PORTE_QTTC qttc
    WHERE af.NUMCLI = NVL(i_numcli,af.NUMCLI)
    AND af.numporte = i_porte
    AND af.numremise = i_numremise
    AND af.numporte = adh.numporte
    AND af.numporte=cntrt.numporte
    AND af.numporte=qttc.numporte
    AND cntrt.numremise = af.numremise
    AND adh.numremise = af.numremise
    AND qttc.numremise = af.numremise
    AND cntrt.entreprise = af.entreprise
    AND cntrt.etabli = af.etabli
    AND cntrt.num_ordre = af.num_ordre
    AND af.numremise = ap.numremise
    AND af.entreprise = ap.entreprise
    AND af.etabli = ap.etabli
    AND af.num_ordre = ap.num_ordre
    AND adh.numligne = ap.numligne
    AND qttc.ref_ext_cntrt = adh.ref_ext_cntrt
    AND qttc.ref_ext_adh = adh.ref_ext_adh
    AND adh.numligne = qttc.numligne
    AND adh.numayd=0
    AND adh.numgar = i_numgar
    AND adh.numgar IS NOT NULL
    AND af.datefic = i_Date_deb
    AND qttc.numquit IS NOT NULL -- quittance identifiée uniquement
    AND qttc.statut NOT IN (0,6,9) --cotisation hors période
    );
END MAJ_STATUT_QTTC;


/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  AnnulImportCotisations                                    */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire l' annulation de l import fonctionnelles  */
/*                 des cotisations DSN                                       */
/* Entree       :  I_numquit, numéro de quittance                            */
/*                 i_session ,                                               */
/*                 i_traitement                                              */
/*                 i_idligne                                                 */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
PROCEDURE AnnulImportCotisations ( I_numquit      IN   QTTC_GLOBAL.NUMQUIT%TYPE
                                  , i_session      IN   JOURNAL_ADM.ID_SESSION%TYPE
                                 , i_traitement   IN   JOURNAL_ADM.NOM_TRAITEMENT%TYPE
                                 , i_idligne      IN   JOURNAL_ADM.IDLIGNE%TYPE
                                 , o_erreur       OUT  VARCHAR2)
IS

BEGIN
  -- TRAITEMENT AF07T : annulation de l import fonctionnelle des cotisations
  G_nom_traitement:=i_traitement;
  G_Session := i_session;
  G_idligne:=i_idligne;
  P_INS_journal(2, 'DEBUT PK_IMPORT_AFFIL.AnnulImportCotisations le '||TO_CHAR(SYSDATE));
  P_INS_journal(3, 'NUMREMISE en cours d annulation '||TO_CHAR(I_numquit));
  -- Annulation : Le traitement remet à blanc : affil_porte_qttc.numquit = NULL
  PK_CTRL_AFFIL.P_ANNULATION_COTISATION (I_numquit, o_erreur) ;
  IF  o_erreur IS NOT NULL THEN
    P_INS_journal(1, o_erreur);
    ROLLBACK;
  ELSE
    COMMIT;
  END IF;

  P_INS_journal(2, 'FIN PK_IMPORT_AFFIL.AnnulImportCotisations le '||TO_CHAR(SYSDATE));

EXCEPTION
  WHEN OTHERS THEN
    -- Annulation de l annulation de l import
    ROLLBACK;
    P_INS_journal(1,SUBSTR(SQLERRM,1,132));
END AnnulImportCotisations;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_Calcul_a_blanc                                          */
/* Type         :  Public                                                    */
/* Description  :  procedure de calcul à blanc unitaire de cotisations       */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_Calcul_a_blanc( I_numquit qttc_global.numquit%TYPE)
IS
  res           varchar2(100);
BEGIN

  P_INS_journal(1,' P_Calcul_a_blanc, numquit:'||to_char(I_numquit));--TODO uniformisation
  --
  -- Lancement de QG05_xit
  --
  res :='';
  res := qg05_xit (I_numquit,'pasforcage','put','totale');
  --exemple de résultat qg05:22314.88; ==> testé sur gerepd 03/2022 OK

EXCEPTION
  WHEN OTHERS THEN
  P_INS_journal(3,' P_Calcul_a_blanc'||SUBSTR(SQLERRM,1,132)); --TODO uniformisation
END P_Calcul_a_blanc;

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
        I_session  => NVL(g_session, sid),
        I_niv_msg  => P_niv,
        I_msg_adm  => substr(P_msg||' '||P_msg2,1,132),
        I_idligne  => G_idligne);
  END IF;

END P_INS_journal;

END PK_GEST_COTIS_AF06T;
/
