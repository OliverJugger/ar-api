CREATE OR REPLACE PACKAGE ARTHUS.PK_AF10
AS
/*============================================================================*/
/* Package      : PK_AF10.sql                                                 */
/* Domaine      : Paramétrage DSN                                             */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 21/09/2015                                                  */
/* Description  : Constitution d un bordereau de fiche de paramétrage DSN     */
/*              : Génération d un bordereau de fiche de paramétrage DSN       */
/*              : Annulation d un bordereau de fiche de paramétrage DSN       */

/*============================================================================*/
/* Evolution    :  automatisation des fiches de paramétrage                   */
/* Auteur       : CLI                                                         */
/* Date         : 17/04/2018                                                  */
/* Commentaire  : Automatiser la génération des fiches aprés modification des
                - Création de la porte DSN sur un contrat
                - Modification du collège
                - De la périodicité des cotisations (fractionnement)
                - De la référence assureur portée par le contrat (contrat_ref)
                - Modification du code option porté par la règle de calcul
                - de cotisation ou la garantie (gar_param_detail)
                - Ajout/modification d’une règle de calcul de cotisation (frml_prime_simple)
                  uniquement si une fiche de paramétrage existe déjà pour ce contrat (dsn_fiche_contrat) */
/*============================================================================*/
/* correction   : M0005610                                                    */
/* auteur       : MUR                                                         */
/* date         : 16/05/2018                                                  */
/*============================================================================*/

TYPE TAB_numcli   IS TABLE OF AFFIL_FICHE_DSN_INFO;

PROCEDURE P_AF10 ( i_traitement   IN    TYP_BATCH.BATCHID%TYPE,
                   i_numporte     IN    REMISE_EXTERNE.NUMPORTE%TYPE,
                   i_numcli       IN    CONTRAT.NUMCLI%TYPE,
                   i_siren        IN    PERS_MORALE.SIRET%TYPE,
                   i_nic          IN    PERS_MORALE.SIRET%TYPE,
                   i_datsous      IN    CONTRAT.DATSOUS%TYPE,
                   i_numproduit   IN    CONTRAT.NUMPROD%TYPE,
                   I_numproduitFin IN   CONTRAT.NUMPROD%TYPE,
                   i_session      IN    JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1,
                   i_version      IN    VARCHAR2,
                   i_code_prod    IN    VARCHAR2,
                   i_niv_msg      IN    NUMBER DEFAULT 1,
                   o_found        OUT   NUMBER,
                   o_erreur       OUT   VARCHAR2);


PROCEDURE P_AF11 ( i_traitement   IN    TYP_BATCH.BATCHID%TYPE,
                   i_numremise    IN    REMISE_EXTERNE.NUMREMISE%TYPE,
                   i_session      IN    JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1,
                   i_niv_msg      IN    NUMBER DEFAULT 1,
                   i_repertoire   IN    TYP_BATCH.REPERTOIRE%TYPE,
                   i_fichier      IN    TYP_BATCH.RESSOURCE%TYPE,
                   o_found        OUT   NUMBER,
                   o_erreur       OUT   VARCHAR2);



PROCEDURE P_AF13 ( I_traitement    IN  TYP_BATCH.BATCHID%TYPE,
                   i_numporte      IN  REMISE_EXTERNE.NUMPORTE%TYPE,
                   i_numremise     IN  REMISE_EXTERNE.NUMREMISE%TYPE,
                   I_session       IN  JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1,
                   I_niv_msg       IN  NUMBER,
                   o_found        OUT  NUMBER,
                   o_erreur       OUT  VARCHAR2);

PROCEDURE P_NOM_FICHIER ( i_numremise     IN     REMISE_EXTERNE.NUMREMISE%TYPE
                         ,i_concentrateur IN    DSN_FICHE.CONCENTRATEUR%TYPE
                        , i_traitement    IN     TYP_BATCH.BATCHID%TYPE
                        , i_fichier       IN     TYP_BATCH.RESSOURCE%TYPE
                        , o_fichier         OUT VARCHAR2
                        );

PROCEDURE P_INS_journal( i_niv  in NUMBER,
                         i_msg  in VARCHAR2,
                         i_msg2 in varchar2 := null);

PROCEDURE P_GENERER_FICHE_AUTO;

PROCEDURE P_SEND_RAPPORT_ENVOI_MAIL(i_date_session DATE, i_numclis TAB_numcli,i_manuels TAB_numcli, i_nb_total number);

procedure P_MAIL_REMISES_NON_VALIDEES ;
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_AF10 AS
/*============================================================================*/
/* Package      : PK_AF10.sql                                                 */
/* Domaine      : Paramétrage DSN                                             */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : 21/09/2015                                                  */
/* Description  : Constitution d un bordereau de fiche de paramétrage DSN     */
/*              : Génération d un bordereau de fiche de paramétrage DSN       */
/*              : Annulation d un bordereau de fiche de paramétrage DSN       */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/

--VARIABLES GLOBALES
g_nom_traitement  journal_adm.nom_traitement%TYPE DEFAULT 'AF10T';
g_niv_msg         journal_adm.niv_msg%TYPE := NULL;
g_idligne         journal_adm.idligne%TYPE := 0;
g_msg_adm         journal_adm.msg_adm%TYPE;
g_session         NUMBER;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_AF10                                                    */
/* Type         :  Public                                                    */
/* Description  :  Constitution d un bordereau de fiche de paramétrage DSN   */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_AF10 ( i_traitement   IN    TYP_BATCH.BATCHID%TYPE,
                   i_numporte     IN    REMISE_EXTERNE.NUMPORTE%TYPE,
                   i_numcli       IN    CONTRAT.NUMCLI%TYPE,
                   i_siren        IN    PERS_MORALE.SIRET%TYPE,
                   i_nic          IN    PERS_MORALE.SIRET%TYPE,
                   i_datsous      IN    CONTRAT.DATSOUS%TYPE,
                   i_numproduit   IN    CONTRAT.NUMPROD%TYPE,
                   I_numproduitFin IN   CONTRAT.NUMPROD%TYPE,
                   i_session      IN    JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1,
                   i_version      IN    VARCHAR2,
                   i_code_prod    IN    VARCHAR2,
                   i_niv_msg      IN    NUMBER DEFAULT 1,
                   o_found        OUT   NUMBER,
                   o_erreur       OUT   VARCHAR2)
IS

  -- On recupere les infos nécessaires à la constitution du bordereaux des fiches de paramétrages

  --TODO à enlever  AND  F_GET_TRANSCO('DSN','BASE',base.nom_variable) IS NOT NULL
  --                   , substr(m.SIRET ,9,5)                                              NIC_societe
  CURSOR c_constit_Bdx(p_code_prod VARCHAR2, p_version VARCHAR2,
                        p_numcli CONTRAT.NUMCLI%TYPE, p_datsous CONTRAT.DATSOUS%TYPE,
                        p_siren PERS_MORALE.SIRET%TYPE, p_nic PERS_MORALE.SIRET%TYPE,
                        p_numporte  PORTE_CONTRAT.NUMPORTE%TYPE,
                        p_role IN NUMBER)
      IS
SELECT DISTINCT 3                                                         regroup
      , c.numgar                                                          numgar
      , c.numcli                                                          numcli
      , c.numprod                                                         numprod
      , pk_libelle.f_lib('PROD',c.numprod)                                nom_produit
      , pk_libelle.f_lib('GESCO',c.gest_cotis)                            gestion_cotis
      , pk_libelle.f_lib('TYPQ',c.typequit )                              cot_niveau_appel
      , pk_libelle.f_lib('TYPC',c.type_calc)                              cot_niveau_calcul
      , g.numfor                                                          numfor
      , g.libelle                                                         libelle
      , pk_libelle.f_lib('RISQ',gar.natrisq)                              risque
      , p_version                                                         version_fichier
      , to_char(sysdate ,'dd/mm/yyy hh24:mi:ss')                          dh_creation
      , substr(m.SIRET ,0,9)                                              SIREN_societe
      , f_nom(c.numcli)                                                   raison_societe
      , substr(m.SIRET ,10,5)                                             NIC_societe
      , ''                                                                Ens_etablissement
      , p_code_prod                                                       Code_producteur
      , c.numinterm                                                       Code_societe_gest
      , f_nom(c.numinterm)                                                Raison_producteur
      , org.entete2                                                       Code_PR
      , org.entete3                                                       Concentrateur
      , '1'                                                               Groupe
      , 'Défaut'                                                          LIB_Groupe
      , 'indicateur ?'                                                    Indicateur
      , c.fract                                                           Period_paiement
      , greatest (p_datsous,c.datsous)                                    Debut_validite
      , ''                                                                Ancien_code_OC
      , decode(c.numinterm, NVL(gar.numass, gar.numorg),NULL, p_code_prod) Code_DG
      , ''                                                                Ancien_code_DG
      , decode(c.gest_cotis,1,p_code_prod,2,delegataire)                  DGC
      , decode(c.gest_prest,1,p_code_prod,2, deleg_prest)                 DGP
      , TRIM(replace(c.refcie ,'|',''))                                   Reference_contrat
      , pk_libelle.f_lib( 'TYP_CONT',c.TYPE_CONTRAT)        Lib_contrat  -- 'A définir par le client'
      , 'NEANT'                                                           Anc_ref_contrat
      , TO_CHAR(c.college)                                                code_population
      , pk_libelle.f_lib('COLLEGE', c.college)                            LIB_Code_Population
      , pk_libelle.f_lib('GARA', gar.baseopt)                             base_option
      , base.nom_variable                                                 nom_base
      , base.lib_variable                                                 lib_base
      , F_GET_TRANSCO('DSN','BASE',base.nom_variable)                     id_base
      , taux.nom_variable                                                 nom_taux
      , taux.lib_variable                                                 lib_taux
      , pk_libelle.f_lib('CONTE',taux.etendue)                            type_taux
      , pk_libelle.f_lib('V_FRMLVAR',taux.idformule)                      formule_taux
      ,decode(taux.etendue ,7 , to_number(F_VAL_VAR_ALL(c.numprod,taux.idvariable,p_datsous),'99999D999999','nls_numeric_characters=.,' )
                           ,2 , to_number(F_VAL_VAR_ALL(c.numgar,taux.idvariable,p_datsous),'99999D999999','nls_numeric_characters=.,' ) ,NULL )taux
      , cot.seq                                                           cot_seq
      , cot.contenu
   FROM contrat c
      , pers_morale m
      , porte_contrat p
      , v_GAR_CNTRT g
      , v_all_gar gar
      , pers_organisme org
      , def_variable base
      , FRML_PRIME_SIMPLE cot LEFT OUTER JOIN def_variable taux ON ( taux.idvariable = cot.taux)
  WHERE pk_histo_contrat.f_sel_etat(c.numgar,p_datsous) = 1
    AND m.numindiv = c.numcli
    AND substr(m.SIRET ,0,9) = NVL(p_siren, substr(m.SIRET ,0,9))
    AND substr(m.SIRET ,10,5) = NVL(p_nic, substr(m.SIRET ,10,5))
    AND c.numcli = NVL(p_numcli, c.numcli)
    AND c.numgar=g.numgar
    AND f_numgar_ref(c.numgar) = p.numgar
    AND p.numporte= p_numporte
    AND g.valide='O'
    AND p_datsous BETWEEN g.debut AND NVL(g.fin,p_datsous)
    AND c.NUMPROD BETWEEN nvl(i_numproduit,c.NUMPROD) AND nvl(nvl(i_numproduitFin, i_numproduit),c.NUMPROD)
    AND g.idgarantie = g.numfor
    AND g.numfor = gar.numfor
    AND cot.numfor = g.numfor
    AND cot.valide='O'
    AND p_datsous BETWEEN cot.debut AND NVL(cot.fin,p_datsous)
    AND base.idvariable = cot.base
    AND c.typequit=1 --attention ce critère fait que l'on n'emet pas de fiche de paramétrage lors de délégation unique de prestation
    AND c.gest_cotis = 1
    AND org.numindiv = NVL(gar.numass, gar.numorg)
    AND c.numcli not in (SELECT numde from dependance where role = p_role UNION Select numenvers from dependance where role = p_role )
  --  AND  F_GET_TRANSCO('DSN','BASE',base.nom_variable) IS NOT NULL --Artifice mis en place pour trouver des cas(mis en gestuin d erreur)
   -- AND  substr(m.SIRET ,0,9) <> '999999999' --Artifice mis en place pour trouver des cas(mis en gestuin d erreur)
   UNION
   SELECT DISTINCT decode (dep.numde,c.numcli,1,2)                        regroup
      , c.numgar                                                          numgar
      , c.numcli                                                          numcli
      , c.numprod                                                         numprod
      , pk_libelle.f_lib('PROD',c.numprod)                                nom_produit
      , pk_libelle.f_lib('GESCO',c.gest_cotis)                            gestion_cotis
      , pk_libelle.f_lib('TYPQ',c.typequit )                              cot_niveau_appel
      , pk_libelle.f_lib('TYPC',c.type_calc)                              cot_niveau_calcul
      , g.numfor                                                          numfor
      , g.libelle                                                         libelle
      , pk_libelle.f_lib('RISQ',gar.natrisq)                              risque
      , p_version                                                         version_fichier
      , to_char(sysdate ,'dd/mm/yyy hh24:mi:ss')                          dh_creation
      , substr(m.SIRET ,0,9)                                              SIREN_societe
      , f_nom(c.numcli)                                                   raison_societe
      , NULL                                                              NIC_societe
      , ''                                                                Ens_etablissement
      , p_code_prod                                                       Code_producteur
      , c.numinterm                                                       Code_societe_gest
      , f_nom(c.numinterm)                                                Raison_producteur
      , org.entete2                                                       Code_PR
      , org.entete3                                                       Concentrateur
      , '1'                                                               Groupe
      , 'Défaut'                                                          LIB_Groupe
      , 'indicateur ?'                                                    Indicateur
      , c.fract                                                           Period_paiement
      , greatest (p_datsous,c.datsous)                                    Debut_validite
      , ''                                                                Ancien_code_OC
      , decode(c.numinterm, NVL(gar.numass, gar.numorg),NULL, p_code_prod) Code_DG
      , ''                                                                Ancien_code_DG
      , decode(c.gest_cotis,1,p_code_prod,2,delegataire)                  DGC
      , decode(c.gest_prest,1,p_code_prod,2, deleg_prest)                 DGP
      , TRIM(replace(c.refcie,'|',''))                                    Reference_contrat
      , pk_libelle.f_lib( 'TYP_CONT',c.TYPE_CONTRAT)        Lib_contrat  -- 'A définir par le client'
      , 'NEANT'                                                           Anc_ref_contrat
      , TO_CHAR(c.college)                                                code_population
      , pk_libelle.f_lib('COLLEGE', c.college)                            LIB_Code_Population
      , pk_libelle.f_lib('GARA', gar.baseopt)                             base_option
      , base.nom_variable                                                 nom_base
      , base.lib_variable                                                 lib_base
      , F_GET_TRANSCO('DSN','BASE',base.nom_variable)                     id_base
      , taux.nom_variable                                                 nom_taux
      , taux.lib_variable                                                 lib_taux
      , pk_libelle.f_lib('CONTE',taux.etendue)                            type_taux
      , pk_libelle.f_lib('V_FRMLVAR',taux.idformule)                      formule_taux
      ,decode(taux.etendue ,7 , to_number(F_VAL_VAR_ALL(c.numprod,taux.idvariable,p_datsous),'99999D999999','nls_numeric_characters=.,' )
                           ,2 , to_number(F_VAL_VAR_ALL(c.numgar,taux.idvariable,p_datsous),'99999D999999','nls_numeric_characters=.,' ) ,NULL )taux
      , cot.seq                                                           cot_seq
      , cot.contenu
   FROM contrat c
      , pers_morale m
      , porte_contrat p
      , v_GAR_CNTRT g
      , v_all_gar gar
      , pers_organisme org
      , def_variable base
      , dependance dep
      , FRML_PRIME_SIMPLE cot LEFT OUTER JOIN def_variable taux ON ( taux.idvariable = cot.taux)
  WHERE pk_histo_contrat.f_sel_etat(c.numgar,p_datsous) = 1
    AND m.numindiv = c.numcli
    AND substr(m.SIRET ,0,9) = NVL(p_siren, substr(m.SIRET ,0,9))
    AND substr(m.SIRET ,10,5) = NVL(p_nic, substr(m.SIRET ,10,5))
    AND (dep.numenvers = NVL(p_numcli,dep.numenvers)   OR dep.numde = NVL(p_numcli, dep.numde) )
    AND( dep.numenvers = c.numcli OR c.numcli=dep.numde)  --maison mère + filiale
    AND dep.role = p_role
    AND c.numgar=g.numgar
    AND f_numgar_ref(c.numgar) = p.numgar
    AND p.numporte= p_numporte
    AND g.valide='O'
    AND p_datsous BETWEEN g.debut AND NVL(g.fin,p_datsous)
    AND c.NUMPROD BETWEEN nvl(i_numproduit,c.NUMPROD) AND nvl(nvl(i_numproduitFin, i_numproduit),c.NUMPROD)
    AND g.idgarantie = g.numfor
    AND g.numfor = gar.numfor
    AND cot.numfor = g.numfor
    AND cot.valide='O'
    AND p_datsous BETWEEN cot.debut AND NVL(cot.fin,p_datsous)
    AND base.idvariable = cot.base
    AND c.typequit=1 --attention ce critère fait que l'on n'emet pas de fiche de paramétrage lors de délégation unique de prestation
    AND c.gest_cotis = 1
    AND org.numindiv = NVL(gar.numass, gar.numorg)
  ORDER BY 1, 14,16,21,2,9;

  r_constit_Bdx            c_constit_Bdx%ROWTYPE;
  loc_numremise            remise_externe.numremise%TYPE:=0;
  loc_erreur               journal_adm.msg_adm%TYPE:=NULL;
  loc_role                 Varchar2(5);
  cpt_fiche                NUMBER:=0; -- compteur du nombre de fiche
  cpt_erreur               NUMBER:=0;

  loc_idfiche              DSN_FICHE.IDFICHE%TYPE:=NULL;
  loc_numgar               CONTRAT.NUMGAR%TYPE:=NULL;
  loc_siret                varchar2(100):=null;
  loc_contrat              varchar2(100):=null;
  loc_code_option          GAR_PARAM_DETAIL.CODE_OPTION%TYPE:=NULL;
  loc_lib_option           GAR_PARAM_DETAIL.LIB_OPTION%TYPE:=NULL;
  loc_interloc             INTERLOCUTEUR.NUMINDIV%TYPE:=NULL;
  loc_contact              CONTACT.COORDONNEE%TYPE:=NULL;
  loc_MT_SPE               DSN_FICHE_TARIF.MT_SPE%TYPE:=NULL;
  loc_taux                 DSN_FICHE_TARIF.TAUX%TYPE:=NULL;

  -- exception
  exc_technique            EXCEPTION;
  exc_societe              EXCEPTION;
  exc_producteur           EXCEPTION;
  exc_contact_tech         EXCEPTION;
  exc_contact_gest         EXCEPTION;
  exc_groupe               EXCEPTION;
  exc_contrat              EXCEPTION;
  exc_option               EXCEPTION;
  exc_population           EXCEPTION;
  exc_base                 EXCEPTION;
  exc_dep                  EXCEPTION;


BEGIN

  -----------------------------------------------------------------------------
  -- Recupération des parametres du traitement
  G_nom_traitement:=i_traitement;
  G_niv_msg:=i_niv_msg;
  G_idligne:=1;
  G_session:=i_session;
  P_INS_journal(1,'Traitement <'||i_traitement||'> de constitution bdx fiche de paramétrage porte <'||i_numporte||'>');
  -----------------------------------------------------------------------------
  BEGIN
      SELECT param3
    INTO loc_role
    FROM PARAM_BATCH
    WHERE NUMBATCH = g_nom_traitement;

  EXCEPTION
    WHEN OTHERS THEN
      loc_role:=NULL;
  END;
  IF loc_role IS NULL THEN
    RAISE  exc_dep;
  END IF;


  -----------------------------------------------------------------------------
  -- Selection et insertion de la remise externe
  PK_TPE.P_gestion_remise_externe(i_numporte,7, loc_numremise, loc_erreur);
  P_INS_journal(1,'Numéro de remise externe <'||loc_numremise||'> ');
  -----------------------------------------------------------------------------
  IF NVL(loc_numremise,0) <> 0 THEN

      -----------------------------------------------------------------------------
      -- Parcours des informations permettant de créer le bdx des fiches de paramétrage
    FOR r_constit_Bdx IN c_constit_Bdx(i_code_prod,i_version,i_numcli,i_datsous, i_siren, i_nic,i_numporte, loc_role) LOOP
      BEGIN
        -- Vérification que les champs obligatoires sont bien renseignés
        IF   TRIM(r_constit_Bdx.SIREN_societe)  IS NULL
        --  OR TRIM(r_constit_Bdx.NIC_societe)    IS NULL
          OR TRIM(r_constit_Bdx.raison_societe) IS NULL
        THEN
          RAISE exc_societe;
        ELSIF    TRIM(r_constit_Bdx.SIREN_societe) = '999999999' /*OR TRIM(r_constit_Bdx.NIC_societe) LIKE '999%'*/ THEN
          RAISE exc_societe;
        ELSE
          loc_contact:=NULL;
          loc_interloc:=NULL;
          -- recherche du contact de la société de gestion:
          SELECT DISTINCT NVL(MAX(interlocuteur),0)
            INTO loc_interloc
            FROM interlocuteur
            WHERE numindiv=r_constit_Bdx.Code_societe_gest
              AND OPE_CRRR=1  -- Cotisations
              AND valide='O'
              AND defaut='O';

          loc_contact:= NVL(F_COORDONNE_CONTACT(loc_interloc,1,1),F_COORDONNE_CONTACT(loc_interloc,4,1));  -- 1 ==> téléphone , 4 ==> mail

          IF TRIM(loc_contact) IS NULL THEN
            RAISE exc_contact_gest;
          END IF;
        END IF;

        IF   TRIM(r_constit_Bdx.Code_producteur) IS NULL
          OR TRIM(r_constit_Bdx.Code_PR)         IS NULL
          OR TRIM(r_constit_Bdx.concentrateur)   IS NULL
          OR TRIM(r_constit_Bdx.DGC)             IS NULL
        THEN
          RAISE exc_producteur;
        END IF;

        IF TRIM(r_constit_Bdx.groupe) IS NULL THEN
          RAISE exc_groupe;
        END IF;
        -- P_INS_journal(1,'SIRET n° : '||loc_siret ||'---'||r_constit_Bdx.SIREN_societe||r_constit_Bdx.NIC_societe);
        IF NVL(loc_siret,'0') <> r_constit_Bdx.SIREN_societe||r_constit_Bdx.NIC_societe || r_constit_Bdx.Code_PR  THEN

          loc_siret :=r_constit_Bdx.SIREN_societe||r_constit_Bdx.NIC_societe|| r_constit_Bdx.Code_PR;
          cpt_fiche:=cpt_fiche+1;

          SELECT SEQ_DSN_FICHE.NEXTVAL INTO loc_idfiche FROM DUAL;
          --  Insertion des fiches de paramétrage
          INSERT INTO DSN_FICHE(IDFICHE,NUMREMISE,SIREN,NIC , NUMCLI
                               ,RAISON,PRODUCTEUR,PR,CONCENTRATEUR,DELEGATAIRE
                               ,CONTACT_TECH,CONTACT_GEST,GROUPE,VERSION)
              VALUES (loc_idfiche, loc_numremise, r_constit_Bdx.SIREN_societe, r_constit_Bdx.NIC_societe , r_constit_Bdx.numcli
                    ,r_constit_Bdx.raison_societe, r_constit_Bdx.Code_producteur,r_constit_Bdx.Code_PR,r_constit_Bdx.Concentrateur, r_constit_Bdx.DGC
                    ,loc_interloc,loc_interloc,r_constit_Bdx.groupe, r_constit_Bdx.version_fichier);
        END IF;

        IF TRIM(r_constit_Bdx.Reference_contrat) IS NULL
           OR TRIM(r_constit_Bdx.Lib_contrat) IS NULL  THEN
          RAISE exc_contrat;
        END IF;
        --rupture sur le n° de contrat et de fiche sinon problème lors de l'insertion en BD !!!
         IF  NVL(loc_contrat,0)<> loc_idfiche||r_constit_Bdx.numgar  THEN
          -- Insertion des fiches de paramétrage avec les caractéristiques par contrat
          loc_contrat:= loc_idfiche||r_constit_Bdx.numgar;
          loc_numgar:= r_constit_Bdx.numgar;
          --  Insertion des fiches de paramétrage par groupe de contrats
          INSERT INTO DSN_FICHE_CONTRAT(IDFICHE,NUMGAR,REFCIE,LIB_CONTRAT
                                       ,FRACT,DEBUT,FIN)
              VALUES (loc_idfiche,r_constit_Bdx.numgar,r_constit_Bdx.Reference_contrat,r_constit_Bdx.Lib_contrat
                     ,r_constit_Bdx.Period_paiement,r_constit_Bdx.Debut_validite,NULL);
        END IF;

        --P_INS_journal(1,'pop n° : '||r_constit_Bdx.code_population);
        IF TRIM(r_constit_Bdx.code_population) IS NULL
           OR TRIM(r_constit_Bdx.LIB_Code_Population) IS NULL
        THEN
          RAISE exc_population;
        END IF;

        IF TRIM(r_constit_Bdx.nom_base) IS NULL OR r_constit_Bdx.id_base IS NULL THEN
          RAISE exc_base;
        END IF;

        ---------------------------------------------------------------------------------------------
        -- Recherche du code option afin de gérer la rupture pour l insertion dans la DSN_FICHE_TARIF
        ---------------------------------------------------------------------------------------------
        -- on part du princicpe que le code option n'est pas toujours valorisé
        -- on prend sa valeur au niveau cotisation s'il existe sinon au niveau garantie

        BEGIN
          SELECT g.CODE_OPTION, g.LIB_OPTION
            INTO loc_code_option, loc_lib_option
            FROM GAR_PARAM_DETAIL g
           WHERE g.NUMFOR=r_constit_Bdx.numfor
           AND   g.SEQ   = r_constit_Bdx.cot_seq;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT g.CODE_OPTION,  g.LIB_OPTION
                INTO loc_code_option, loc_lib_option
              FROM GAR_PARAM_DETAIL g
              WHERE g.NUMFOR=r_constit_Bdx.numfor
        AND g.SEQ = 0;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                loc_code_option:=NULL;
                loc_lib_option :=NULL;
              WHEN OTHERS THEN RAISE exc_option;
            END;
          WHEN OTHERS THEN RAISE exc_option;
        END;

         -- P_INS_journal(1,'Fiche:'||loc_idfiche||'Contrat <'||r_constit_Bdx.numgar||'>  société n°<'||r_constit_Bdx.numcli||'> code option non regroupable :' || loc_code_option);

        IF r_constit_Bdx.id_base not in (17,18,19,20,21) THEN
          INSERT INTO DSN_FICHE_TARIF (IDFICHE,NUMGAR,CODE_OPTION,LIB_OPTION,CODE_POP
                                      ,LIB_POP,ELT_CALCUL,TAUX,ELT_CALCUL_SPE,LIB_ELT_CALCUL_SPE,MT_SPE)
          SELECT loc_idfiche,r_constit_Bdx.numgar,loc_code_option,loc_lib_option,r_constit_Bdx.code_population
          ,r_constit_Bdx.LIB_Code_Population,r_constit_Bdx.id_base,r_constit_Bdx.taux, NULL,NULL,0
          FROM DUAL
          WHERE NOT EXISTS (
            SELECT IDFICHE FROM DSN_FICHE_TARIF
            WHERE IDFICHE= loc_idfiche
            AND   ( NUMGAR = r_constit_Bdx.numgar OR r_constit_Bdx.regroup<>3)
            AND   NVL(CODE_OPTION,0) = NVL(loc_code_option,0)
            AND   CODE_POP = r_constit_Bdx.code_population --population ne peut être vide
        --    AND   TAUX = r_constit_Bdx.taux     M0005197 : mise en commentaire ce qui empêche la création de doublon (sur contrat, code option, population,elt calcul, taux ou mt spe)
            AND   ELT_CALCUL = r_constit_Bdx.id_base
            --AND   NVL(ELT_CALCUL_SPE,0) = NVL(NULL,0)
          );
          loc_TAUX:=r_constit_Bdx.taux;
        ELSE
          loc_TAUX:=r_constit_Bdx.taux;
          loc_MT_SPE:=0;
          IF r_constit_Bdx.id_base IN(20,21) THEN    -- Si c'est du montant forfaitaire on alimente  MT_SPE
            loc_MT_SPE:=r_constit_Bdx.taux;
            loc_TAUX:=0;
          END IF;

          --P_INS_journal(1,'Fiche:'||loc_idfiche||'Contrat <'||r_constit_Bdx.numgar||'>  code_population n°<'||r_constit_Bdx.code_population||'> base:' ||r_constit_Bdx.id_base||' taux:'||r_constit_Bdx.taux);
          INSERT INTO DSN_FICHE_TARIF (IDFICHE,NUMGAR,CODE_OPTION,LIB_OPTION,CODE_POP
                                      ,LIB_POP,ELT_CALCUL,TAUX,ELT_CALCUL_SPE,LIB_ELT_CALCUL_SPE,MT_SPE)
          SELECT loc_idfiche,r_constit_Bdx.numgar,loc_code_option,loc_lib_option,r_constit_Bdx.code_population
          ,r_constit_Bdx.LIB_Code_Population,r_constit_Bdx.id_base,loc_TAUX,r_constit_Bdx.id_base,r_constit_Bdx.lib_base,loc_MT_SPE
          FROM DUAL
          WHERE NOT EXISTS (
            SELECT IDFICHE FROM DSN_FICHE_TARIF
            WHERE IDFICHE= loc_idfiche
            AND   ( NUMGAR = r_constit_Bdx.numgar OR r_constit_Bdx.regroup<>3)
            AND   NVL(CODE_OPTION,0) = NVL(loc_code_option,0)
            AND   CODE_POP = r_constit_Bdx.code_population --population ne peut être vide
            AND   ELT_CALCUL = r_constit_Bdx.id_base
         --   AND   TAUX = loc_TAUX     M0005197 : mise en commentaire ce qui empêche la création de doublon (sur contrat, code option, population,elt calcul, taux ou mt spe)
            AND   NVL(ELT_CALCUL_SPE,0) = NVL(r_constit_Bdx.id_base,0)
            --AND   MT_SPE = loc_MT_SPE
          );

        END IF;
        -- M5197 On signale à l'utilisateur qu'un des paramétrage n'a pas été inséré car en doublon
        IF SQL%ROWCOUNT= 0 THEN
          P_INS_journal(1,'Paramétrage non inséré car en doublon, fiche <'||loc_idfiche||'>, contrat <'||r_constit_Bdx.numgar||'> option <'||loc_code_option||'> element <'||r_constit_Bdx.id_base||'>.');
        END IF;
        -- M0005213 : Lorsque le taux est vide, une alerte doit être remontée à l'utilisateur afin qu'il corrige le paramétrage contrat.
        IF NVL(loc_TAUX,0)= 0 AND   r_constit_Bdx.id_base NOT IN(20,21) THEN
          P_INS_journal(1,'Le taux de la fiche <'||loc_idfiche||'>, contrat <'||r_constit_Bdx.numgar||'> option <'||loc_code_option||'> element <'||r_constit_Bdx.id_base||'> est vide.');
        END IF;

      EXCEPTION
        WHEN exc_societe THEN
          P_INS_journal(1,'Information manquante ou incohérente(SIRET, raison sociale) : contrat <'||r_constit_Bdx.numgar||'>  société n° <'||r_constit_Bdx.numcli||'>');
          cpt_erreur:=cpt_erreur+1;
        WHEN exc_contact_gest THEN
          P_INS_journal(1,'Information manquante(Tel., email) : contrat <'||r_constit_Bdx.numgar||'>  société n°<'||r_constit_Bdx.numcli||'>');
          cpt_erreur:=cpt_erreur+1;
        WHEN exc_producteur THEN
          P_INS_journal(1,'Information manquante (Code PR, DG, DGC ou concentrateur) contrat <'||r_constit_Bdx.numgar||'>  société n°<'||r_constit_Bdx.numcli||'>');
          cpt_erreur:=cpt_erreur+1;
        WHEN exc_groupe THEN
          P_INS_journal(1,'Information sur le numéro du groupe manquante : contrat <'||r_constit_Bdx.numgar||'>  société n°<'||r_constit_Bdx.numcli||'>');
          cpt_erreur:=cpt_erreur+1;
        WHEN exc_contrat THEN
          P_INS_journal(1,'Information manquante (reférence ou libélle contrat) : contrat <'||r_constit_Bdx.numgar||'>  société n°<'||r_constit_Bdx.numcli||'>');
          cpt_erreur:=cpt_erreur+1;
        WHEN exc_option THEN
          P_INS_journal(1,'Information manquante (code ou libélle option) : contrat <'||r_constit_Bdx.numgar||'>  société n°<'||r_constit_Bdx.numcli||'>');
          cpt_erreur:=cpt_erreur+1;
        WHEN exc_population THEN
          P_INS_journal(1,'Information manquante (code ou libélle population) : contrat <'||r_constit_Bdx.numgar||'>  société n°<'||r_constit_Bdx.numcli||'>');
          cpt_erreur:=cpt_erreur+1;
        WHEN exc_base THEN
          P_INS_journal(1,'Information manquante (code base) : contrat <'||r_constit_Bdx.numgar||'>  société n°<'||r_constit_Bdx.numcli||'>');
          cpt_erreur:=cpt_erreur+1;
        WHEN OTHERS THEN
          P_INS_journal(1,'Fiche:'||loc_idfiche||'Contrat <'||r_constit_Bdx.numgar||'>  société n°<'||r_constit_Bdx.numcli||'> Erreur indéterminée :' || SQLERRM);
          cpt_erreur:=cpt_erreur+1;
      END;
    END LOOP;

    IF cpt_erreur = 0 AND cpt_fiche > 0 THEN
      -- mise à jour du champ nombre dans remise_externe qui correspond au nombre de déclarations de fiche de paramétrage
      PK_TPE.P_MAJ_PORTE_ADHESION_NOMBRE(loc_numremise,i_numporte,cpt_fiche);
      P_INS_journal(1,'Le nombre de fiche de paramétrage de la remise <'||loc_numremise||'> est de <'||cpt_fiche||'> ');
      o_erreur :=  o_erreur||CHR(10)||CHR(13)||'Le nombre de fiche de paramétrage de la remise <'||loc_numremise||'> est de <'||cpt_fiche||'> ';
      COMMIT;
    ELSIF cpt_fiche = 0 THEN
      P_INS_journal(1,'Aucune fiche de générée pour la remise <'||loc_numremise||'>: ROLLBACK');
      o_erreur :=  o_erreur||CHR(10)||CHR(13)||'Aucune fiche de générée';
      ROLLBACK;
    ELSE
      P_INS_journal(1,'Le nombre d''erreurs rencontrées lors de la remise <'||loc_numremise||'> est de <'||cpt_erreur||'> : ROLLBACK');
      o_erreur :=  o_erreur||CHR(10)||CHR(13)||'Le nombre d''erreurs rencontrées lors de la remise <'||loc_numremise||'> est de <'||cpt_erreur||'> ';
      ROLLBACK;
    END IF;

  ELSE
    ROLLBACK;
    P_INS_journal(1,'Erreur création de la remise impossible, '||loc_erreur);
    --P_INS_journal(1,'ROLLBACK');
  END IF;

  -----------------------------------------------------------------------------

EXCEPTION
  WHEN exc_dep THEN
    P_INS_journal(1,'Paramétrage P3 du traitement pour la codification dépendance absent');
    cpt_erreur:=cpt_erreur+1;
  WHEN OTHERS THEN
    P_INS_journal(1,'Fin du traitement KO:' || SQLERRM);
    ROLLBACK;
END P_AF10;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_AF13                                                    */
/* Type         :  Public                                                    */
/* Description  :  Annulation d un bordereau de fiche de paramétrage DSN     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_AF13 ( I_traitement    IN  TYP_BATCH.BATCHID%TYPE,
                   i_numporte      IN  REMISE_EXTERNE.NUMPORTE%TYPE,
                   i_numremise     IN  REMISE_EXTERNE.NUMREMISE%TYPE,
                   I_session       IN  JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1,
                   I_niv_msg       IN  NUMBER,
                   o_found        OUT  NUMBER,
                   o_erreur       OUT  VARCHAR2)
IS

BEGIN
  P_INS_journal(1,'Annulation de la remise < '||i_numremise||'>');

  DELETE DSN_FICHE_TARIF dt WHERE dt.IDFICHE   IN (SELECT d.IDFICHE FROM DSN_FICHE d WHERE d.NUMREMISE = i_numremise AND d.IDFICHE = dt.IDFICHE );
  DELETE DSN_FICHE_CONTRAT dc WHERE dc.IDFICHE IN (SELECT d.IDFICHE FROM DSN_FICHE d WHERE d.NUMREMISE = i_numremise AND d.IDFICHE = dc.IDFICHE );
  DELETE DSN_FICHE WHERE NUMREMISE = i_numremise;
  DELETE REMISE_EXTERNE WHERE NUMREMISE = i_numremise AND NUMPORTE = i_numporte;

  P_INS_journal(1,'Fin du traitement '|| I_traitement);

EXCEPTION
  WHEN OTHERS THEN
    P_INS_journal(1,'Fin du traitement KO:' || SQLERRM);
    ROLLBACK;
END P_AF13;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_AF11                                                    */
/* Type         :  Public                                                    */
/* Description  :  Génération d un bordereau de fiche de paramétrage DSN     */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_AF11 ( i_traitement   IN    TYP_BATCH.BATCHID%TYPE,
                   i_numremise    IN    REMISE_EXTERNE.NUMREMISE%TYPE,
                   i_session      IN    JOURNAL_ADM.ID_SESSION%TYPE DEFAULT 1,
                   i_niv_msg      IN    NUMBER DEFAULT 1,
                   i_repertoire   IN    TYP_BATCH.REPERTOIRE%TYPE,
                   i_fichier      IN    TYP_BATCH.RESSOURCE%TYPE,
                   o_found        OUT   NUMBER,
                   o_erreur       OUT   VARCHAR2)
IS

   loc_fichier             VARCHAR2(100):=NULL;
   lob_xml_file            CLOB;
   --loc_message              mess_erreur.lib_msg%TYPE;

  CURSOR cur_remise
      IS
  SELECT distinct decode(concentrateur ,'FFSA','LOT','FICHE') typeFiche
    FROM dsn_fiche
   WHERE numremise=i_numremise ;


  CURSOR  cur_lot_fiche (p_etat NUMBER)
  IS
      SELECT   XMLROOT(XMLELEMENT("LotFicheParam",
                            XMLATTRIBUTES(T.version                                        AS "Version",
                                          'DSN'                                            AS "Norme")
                          , XMLELEMENT("IdLot",T.numremise||T.Concentrateur)
                          , XMLELEMENT("CodeReponse",'AR')
                          , XMLELEMENT("MailsAEnvoyer",'true')
                          , XMLELEMENT("AssureurEmetteur",
                              XMLELEMENT("SIREN",T.SIREN)
                            , XMLELEMENT("Mail",REPLACE(F_COORDONNE_CONTACT(T.contact_gest,4,1),' ','')))
                            , xmlagg(T.xml_file))

                                 --)
           , VERSION '1.0" encoding="ISO-8859-1').getclobval() lob_xml_file , count(T.xml_file)nbfiche ,concentrateur
 FROM (
 SELECT
   --XMLROOT(
              XMLELEMENT
                    ( "FICHE"
                    , XMLATTRIBUTES(TO_CHAR(d.IDFICHE)                                        AS "IdentifiantFiche"
                    ,               TO_CHAR(sysdate,'YYYY-MM-DD"T"HH24:MI:SS')                AS "DateHeureCreation"
                    ,               d.version                                                 AS "Version"
                    ,               'http://www.w3.org/2001/XMLSchema-instance'               AS "xmlns:xsi"
                   --,               'FICHE-PARAM-DSN-OC-V1.3.3.xsd'                           AS "xsi:noNamespaceSchemaLocation"--> ajouter l'attribute ensuite car les erreurs ne sont pas identiables
                   )
                    , XMLELEMENT
                        ("Entreprise"
                        , XMLATTRIBUTES(d.SIREN                                               AS "SIREN"
                        ,               d.RAISON                                              AS "RaisonSociale"
                        ,               d.NIC                                                 AS "NIC")
                        )
                    , XMLELEMENT
                        ("ProducteurFiche"
                        , XMLATTRIBUTES(d.producteur                                          AS "CodeProducteur"
                        -- MUR M0005610 ,               'GEREP'                                               AS "RaisonSocialeProducteur"  -- 'Raison Sociale de l IP'
                        ,               trim(f_nom(1))                                        AS "RaisonSocialeProducteur"  -- 'Raison Sociale de l IP'
                        ,               d.PR                                                  AS "CodePorteurDeRisque")
                        )
                    , XMLELEMENT
                        ("ContactTechniqueFiche"
                        , XMLATTRIBUTES(F_NOM(d.contact_tech)                                   AS "Nom"
                        ,               REPLACE(F_COORDONNE_CONTACT(d.contact_tech,1,1),' ','') AS "Tel"
                        ,               REPLACE(F_COORDONNE_CONTACT(d.contact_tech,4,1),' ','') AS "Mail")
                        )
                    , XMLELEMENT
                        ("ContactGestionnaireFiche"
                        , XMLATTRIBUTES(F_NOM(d.contact_tech)                                  AS "Nom"
                        ,               REPLACE(F_COORDONNE_CONTACT(d.contact_tech,1,1),' ','') AS "Tel"
                        ,               REPLACE(F_COORDONNE_CONTACT(d.contact_tech,4,1),' ','') AS "Mail")
                        )
                        ,XMLELEMENT
                          ("Message", pk_trace.F_AFF_mess_err(2286,1)--loc_message
                            )
                    , XMLELEMENT   ("GROUPE"
                        , XMLATTRIBUTES(d.groupe                                              AS "NumeroGrp"
                        ,               'Défaut'                                              AS "LibelleGrp")
                      ,( SELECT  XMLAGG(
                                    XMLELEMENT
                                      ("ParametresContrats"
                                      , XMLATTRIBUTES(to_char(cntr_opt.debut,'ddmmyyyy')                         AS "DateDebutValidite"
                                      ,               to_char(cntr_opt.fin,'ddmmyyyy')                           AS "DateFinValidite"
                                      ,               pk_libelle.f_lib('FRAC', cntr_opt.fract)                   AS "Periodicite")
                                      ,XMLELEMENT
                                        ("Organisme"
                                        , XMLATTRIBUTES(cntr_opt.pr                                              AS "CodeOC"
                                                      , cntr_opt.delegataire                                     AS "CodeDELEG") -- MUR M0005610
                                        )
                                      , XMLELEMENT
                                        ("Contrat"
                                        , XMLATTRIBUTES(cntr_opt.refcie                                          AS "ReferenceContrat"
                                        ,               cntr_opt.lib_contrat                                     AS "LibelleContrat")
                                        )
                                      , CASE
                                            WHEN cntr_opt.code_option IS NULL THEN NULL
                                            ELSE  XMLELEMENT  ("Option"
                                                              , XMLATTRIBUTES(cntr_opt.code_option                AS "CodeOption"
                                                              ,               cntr_opt.lib_option                 AS "LibelleOption"))
                                        END

                                      , XMLELEMENT
                                        ("Population"
                                        , XMLATTRIBUTES(cntr_opt.code_pop                                          AS "CodePopulation"
                                        ,               cntr_opt.lib_pop                                           AS "LibellePopulation"))

                                      , XMLELEMENT
                                        ("ElementsDeCalculAttendus"
                                        ,  (SELECT XMLAGG(
                                        DECODE(tarif.elt_calcul
                                             ,10,  XMLELEMENT("BrutPrev",XMLELEMENT("Taux", TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                             ,11,  XMLELEMENT("TAPrev",XMLELEMENT("Taux", TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                             ,12,  XMLELEMENT("T2Prev",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                             ,13,  XMLELEMENT("TBPrev",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                             ,14,  XMLELEMENT("TCPrev",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                             ,15,  XMLELEMENT("TDPrev",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                             ,16,  XMLELEMENT("TD1Prev",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                             ,17,  XMLELEMENT("BaseMontantSpecifique", XMLATTRIBUTES(tarif.elt_calcul AS "ValeurCodeNature", tarif.lib_elt_calcul_spe AS "LibelleCodeNature"),
                                                DECODE(tarif.taux,
                                                    0,  XMLELEMENT("Montant", TRIM(REPLACE(to_char(tarif.mt_spe,'990.99'),',','.'))) ,    --vide normalement
                                                        XMLELEMENT("Taux", TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))) ))
                                             ,18,  XMLELEMENT("BaseMontantSpecifique", XMLATTRIBUTES(tarif.elt_calcul AS "ValeurCodeNature", tarif.lib_elt_calcul_spe AS "LibelleCodeNature"),
                                                DECODE(tarif.taux,
                                                    0,  XMLELEMENT("Montant", TRIM(REPLACE(to_char(tarif.mt_spe,'990.99'),',','.'))) ,    --vide normalement
                                                        XMLELEMENT("Taux", TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))) ))
                                             ,20,  XMLELEMENT("BaseMontantSpecifique", XMLATTRIBUTES(tarif.elt_calcul AS "ValeurCodeNature", tarif.lib_elt_calcul_spe AS "LibelleCodeNature"),
                                                  XMLELEMENT("Montant", TRIM(REPLACE(to_char(tarif.mt_spe,'990.99'),',','.'))))
                                             ,21,  XMLELEMENT("BaseMontantSpecifique", XMLATTRIBUTES(tarif.elt_calcul AS "ValeurCodeNature", tarif.lib_elt_calcul_spe AS "LibelleCodeNature"),
                                                  XMLELEMENT("Montant", TRIM(REPLACE(to_char(tarif.mt_spe,'990.99'),',','.'))))
                                             , 24, XMLELEMENT("T2UPrev",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                             ,XMLELEMENT("Autre",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))) )   -- laisser cette balise afin de prévoir les autres cas
                                             )
                                           )
                                           FROM (
                                            SELECT t.elt_calcul, TRIM(replace(c.refcie,'|','')) refcie, t.lib_elt_calcul_spe,t.mt_spe,t.taux,t.code_option,t.code_pop,fiche.idfiche
                                            FROM DSN_FICHE_TARIF t ,DSN_FICHE_CONTRAT c, DSN_FICHE fiche
                                            WHERE c.idfiche = fiche.idfiche
                                            AND t.idfiche = fiche.idfiche
                                            AND c.numgar = t.numgar
                                         --   AND t.taux > 1
                                            AND fiche.NUMREMISE=i_numremise
                                            group by t.elt_calcul, c.refcie, t.lib_elt_calcul_spe,t.mt_spe,t.taux,t.code_option,t.code_pop ,fiche.idfiche) tarif
                                          WHERE tarif.refcie = cntr_opt.refcie
                                          AND NVL(tarif.code_option,0) = NVL(cntr_opt.code_option,0)
                      AND NVL(tarif.code_pop,0) = NVL(cntr_opt.code_pop,0)
                                          AND tarif.idfiche = cntr_opt.idfiche
                                          )
                                        )
                                      )
                                    )
                         FROM(
                            SELECT t.code_option, t.lib_option, c.lib_contrat,TRIM(replace(c.refcie,'|','')) refcie,c.fract,c.debut,c.fin ,fiche.pr, fiche.delegataire /* MUR M0005610 */ ,fiche.idfiche, t.code_pop, t.lib_pop
                              FROM DSN_FICHE fiche  ,DSN_FICHE_CONTRAT c, DSN_FICHE_TARIF t
                             WHERE c.idfiche = fiche.idfiche
                               AND t.idfiche = fiche.idfiche
                               AND c.numgar = t.numgar
                            --   AND t.taux > 1
                               AND fiche.NUMREMISE=i_numremise
                             GROUP BY  t.code_option, t.lib_option, c.lib_contrat,c.refcie,fiche.pr, fiche.delegataire /* MUR M0005610 */ ,c.fract,c.debut,c.fin,fiche.idfiche, t.code_pop, t.lib_pop)cntr_opt
                        WHERE cntr_opt.idfiche = d.idfiche
                             )
                          )
             )xml_file,concentrateur,d.contact_gest, substr(p.SIRET,0,9) SIREN, d.version,d.numremise
    FROM DSN_FICHE d, pers_morale p
   WHERE d.NUMREMISE=i_numremise
   AND p.numindiv =1 ) T
   WHERE XMLIsValid(T.xml_file,'FICHE-PARAM-DSN-OC-R1.3.8.xsd') = p_etat
     AND concentrateur ='FFSA'
   GROUP BY concentrateur,contact_gest, SIREN,version,numremise;


  CURSOR cur_fiche (p_etat NUMBER)
      IS
  SELECT   XMLROOT(xmlagg(T.xml_file)

                                   --)
             , VERSION '1.0" encoding="ISO-8859-1').getclobval() lob_xml_file , concentrateur,T.idfiche
   FROM (
   SELECT
     --XMLROOT(
                XMLELEMENT
                      ( "FICHE"
                      , XMLATTRIBUTES(TO_CHAR(d.IDFICHE)                                        AS "IdentifiantFiche"
                      ,               TO_CHAR(sysdate,'YYYY-MM-DD"T"HH24:MI:SS')                AS "DateHeureCreation"
                      ,               d.version                                                 AS "Version"
                      ,               'http://www.w3.org/2001/XMLSchema-instance'               AS "xmlns:xsi"
                     --,               'FICHE-PARAM-DSN-OC-V1.3.3.xsd'                           AS "xsi:noNamespaceSchemaLocation"--> ajouter l'attribute ensuite car les erreurs ne sont pas identiables
                     )
                      , XMLELEMENT
                          ("Entreprise"
                          , XMLATTRIBUTES(d.SIREN                                               AS "SIREN"
                          ,               d.RAISON                                              AS "RaisonSociale"
                          ,               d.NIC                                                 AS "NIC")
                          )
                      , XMLELEMENT
                          ("ProducteurFiche"
                          , XMLATTRIBUTES(d.producteur                                          AS "CodeProducteur"
                          -- MUR M0005610 ,               'GEREP'                                               AS "RaisonSocialeProducteur"  -- 'Raison Sociale de l IP'
                          ,               trim(f_nom(1))                                        AS "RaisonSocialeProducteur"  -- 'Raison Sociale de l IP'
                          ,               d.PR                                                  AS "CodePorteurDeRisque")
                          )
                      , XMLELEMENT
                          ("ContactTechniqueFiche"
                          , XMLATTRIBUTES(F_NOM(d.contact_tech)                                   AS "Nom"
                          ,               REPLACE(F_COORDONNE_CONTACT(d.contact_tech,1,1),' ','') AS "Tel"
                          ,               REPLACE(F_COORDONNE_CONTACT(d.contact_tech,4,1),' ','') AS "Mail")
                          )
                      , XMLELEMENT
                          ("ContactGestionnaireFiche"
                          , XMLATTRIBUTES(F_NOM(d.contact_tech)                                  AS "Nom"
                          ,               REPLACE(F_COORDONNE_CONTACT(d.contact_tech,1,1),' ','') AS "Tel"
                          ,               REPLACE(F_COORDONNE_CONTACT(d.contact_tech,4,1),' ','') AS "Mail")
                          )
                        ,XMLELEMENT
                          ("Message",pk_trace.F_AFF_mess_err(2286,1)-- loc_message
                            )
                      , XMLELEMENT   ("GROUPE"
                          , XMLATTRIBUTES(d.groupe                                              AS "NumeroGrp"
                          ,               'Défaut'                                              AS "LibelleGrp")
                        ,( SELECT  XMLAGG(
                                      XMLELEMENT
                                        ("ParametresContrats"
                                        , XMLATTRIBUTES(to_char(cntr_opt.debut,'ddmmyyyy')                         AS "DateDebutValidite"
                                        ,               to_char(cntr_opt.fin,'ddmmyyyy')                           AS "DateFinValidite"
                                        ,               pk_libelle.f_lib('FRAC', cntr_opt.fract)                   AS "Periodicite")
                                        ,XMLELEMENT
                                          ("Organisme"
                                          , XMLATTRIBUTES(cntr_opt.pr                                              AS "CodeOC"
                                                        , cntr_opt.delegataire                                     AS "CodeDELEG")
                                                   --     , cntr_opt.delegataire                                     AS "CodeDGC")
                                          )
                                        , XMLELEMENT
                                          ("Contrat"
                                          , XMLATTRIBUTES(cntr_opt.refcie                                          AS "ReferenceContrat"
                                          ,               cntr_opt.lib_contrat                                     AS "LibelleContrat")
                                          )
                                        , CASE
                                              WHEN cntr_opt.code_option IS NULL THEN NULL
                                              ELSE  XMLELEMENT  ("Option"
                                                                , XMLATTRIBUTES(cntr_opt.code_option                AS "CodeOption"
                                                                ,               cntr_opt.lib_option                 AS "LibelleOption"))
                                          END

                                        , XMLELEMENT
                                          ("Population"
                                          , XMLATTRIBUTES(cntr_opt.code_pop                                          AS "CodePopulation"
                                          ,               cntr_opt.lib_pop                                           AS "LibellePopulation"))

                                        , XMLELEMENT
                                          ("ElementsDeCalculAttendus"
                                          ,  (SELECT XMLAGG(
                                          DECODE(tarif.elt_calcul
                                               ,10,  XMLELEMENT("BrutPrev",XMLELEMENT("Taux", TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                               ,11,  XMLELEMENT("TAPrev",XMLELEMENT("Taux", TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                               ,12,  XMLELEMENT("T2Prev",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                               ,13,  XMLELEMENT("TBPrev",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                               ,14,  XMLELEMENT("TCPrev",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                               ,15,  XMLELEMENT("TDPrev",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                               ,16,  XMLELEMENT("TD1Prev",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                               ,17,  XMLELEMENT("BaseMontantSpecifique", XMLATTRIBUTES(tarif.elt_calcul AS "ValeurCodeNature", tarif.lib_elt_calcul_spe AS "LibelleCodeNature"),
                                                  DECODE(tarif.taux,
                                                      0,  XMLELEMENT("Montant", TRIM(REPLACE(to_char(tarif.mt_spe,'990.99'),',','.'))) ,    -- vide normalement
                                                          XMLELEMENT("Taux", TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))) ))
                                               ,18,  XMLELEMENT("BaseMontantSpecifique", XMLATTRIBUTES(tarif.elt_calcul AS "ValeurCodeNature", tarif.lib_elt_calcul_spe AS "LibelleCodeNature"),
                                                  DECODE(tarif.taux,
                                                      0,  XMLELEMENT("Montant", TRIM(REPLACE(to_char(tarif.mt_spe,'990.99'),',','.'))) ,    -- vide normalement
                                                          XMLELEMENT("Taux", TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))) ))  --
                                               ,20,  XMLELEMENT("BaseMontantSpecifique", XMLATTRIBUTES(tarif.elt_calcul AS "ValeurCodeNature", tarif.lib_elt_calcul_spe AS "LibelleCodeNature"),
                                                    XMLELEMENT("Montant", TRIM(REPLACE(to_char(tarif.mt_spe,'990.99'),',','.'))))
                                               ,21,  XMLELEMENT("BaseMontantSpecifique", XMLATTRIBUTES(tarif.elt_calcul AS "ValeurCodeNature", tarif.lib_elt_calcul_spe AS "LibelleCodeNature"),
                                                    XMLELEMENT("Montant", TRIM(REPLACE(to_char(tarif.mt_spe,'990.99'),',','.'))))
                                             , 24, XMLELEMENT("T2UPrev",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))))
                                               ,XMLELEMENT("Autre",XMLELEMENT("Taux",TRIM(REPLACE(to_char(tarif.taux,'90.999'),',','.'))) )   -- laisser cette balise afin de prévoir les autres cas
                                               )
                                             )
                                             FROM (
                                              SELECT t.elt_calcul, TRIM(replace(c.refcie,'|','')) refcie, t.lib_elt_calcul_spe,t.mt_spe,t.taux,t.code_option,t.code_pop,fiche.idfiche
                                              FROM DSN_FICHE_TARIF t ,DSN_FICHE_CONTRAT c, DSN_FICHE fiche
                                              WHERE c.idfiche = fiche.idfiche
                                              AND t.idfiche = fiche.idfiche
                                              AND c.numgar = t.numgar
                                           --   AND t.taux > 1
                                              AND fiche.NUMREMISE=i_numremise
                                              group by t.elt_calcul, c.refcie, t.lib_elt_calcul_spe,t.mt_spe,t.taux,t.code_option,t.code_pop ,fiche.idfiche) tarif
                                            WHERE tarif.refcie = cntr_opt.refcie
                                            AND NVL(tarif.code_option,0) = NVL(cntr_opt.code_option,0)
                      AND NVL(tarif.code_pop,0) = NVL(cntr_opt.code_pop,0)
                                            AND tarif.idfiche = cntr_opt.idfiche
                                            )
                                          )
                                        )
                                      )
                           FROM(
                              SELECT t.code_option, t.lib_option, c.lib_contrat,TRIM(replace(c.refcie,'|','')) refcie,c.fract,c.debut,c.fin ,fiche.pr, fiche.delegataire ,fiche.idfiche, t.code_pop, t.lib_pop
                                FROM DSN_FICHE fiche  ,DSN_FICHE_CONTRAT c, DSN_FICHE_TARIF t
                               WHERE c.idfiche = fiche.idfiche
                                 AND t.idfiche = fiche.idfiche
                                 AND c.numgar = t.numgar
                              --   AND t.taux > 1
                                 AND fiche.NUMREMISE=i_numremise
                               GROUP BY  t.code_option, t.lib_option, c.lib_contrat,c.refcie,fiche.pr , fiche.delegataire ,c.fract,c.debut,c.fin,fiche.idfiche, t.code_pop, t.lib_pop)cntr_opt
                          WHERE cntr_opt.idfiche = d.idfiche
                               )
                            )
               )xml_file,concentrateur,d.contact_gest, substr(p.SIRET,0,9) SIREN, d.version,d.numremise,d.idfiche
      FROM DSN_FICHE d, pers_morale p
     WHERE d.NUMREMISE=i_numremise
       AND p.numindiv =1 ) T
     WHERE XMLIsValid(T.xml_file,'FICHE-PARAM-DSN-OC-R1.3.8.xsd') = p_etat
     AND concentrateur IN ('CTIP','FNMF')
     GROUP BY concentrateur,contact_gest, SIREN,version,numremise,idfiche;

  xml_file                XMLTYPE;
  v_xml                   XMLTYPE;
  cpt_tot_lot_fiche_invalide NUMBER:=0;
  cpt_tot_fiche_invalide  NUMBER:=0;
  l_xml                   XMLTYPE;
  i                       NUMBER:=0;
  loc_IdentifiantFiche    NUMBER;
  exc_fichier             EXCEPTION;
  cpt_erreur              NUMBER:=0;
  loc_repertoire          TYP_BATCH.REPERTOIRE%TYPE:=NULL;

  cpt_fiche              NUMBER:=0;
BEGIN

  -----------------------------------------------------------------------------
  -- Recupération des parametres du traitement
  G_nom_traitement:=i_traitement;
  G_niv_msg:=i_niv_msg;
  G_idligne:=0;
  G_session:=i_session;
  P_INS_journal(1,'Traitement <'||i_traitement||'>, Génération de la fiche de paramétrage de la remise <'||i_numremise||'>');
 -- loc_message := ;
  -----------------------------------------------------------------------------
  -- Parcours des concentrateurs et des idfiche d une remise afin de générer un fichier avec des lots de fiche
  -- ou uniquement un fichier avec une fiche
  FOR rec_remise  IN  cur_remise  LOOP

    -----------------------------------------------------------------------------
    ------------------ CONCENTRATEUR FFSA  ==> 1 SEUL FICHIER CONTENANT DES LOTS DE FICHES
    -----------------------------------------------------------------------------
    IF rec_remise.typeFiche = 'LOT' THEN

      i:=0;--compteur des lot de fiches
      -- on parcourt les fiches invalides afin de les valider pour en sortir les erreurs des fiches
      -- on a un lot de fiche par remise donc par ligne de curseur
      FOR rec_lot_fiche  IN  cur_lot_fiche (0) LOOP
        BEGIN
          cpt_tot_lot_fiche_invalide:= cpt_tot_lot_fiche_invalide+rec_lot_fiche.nbfiche;

          -- Parcourir chaque fiche du lot,
          LOOP
            i:=i+1;
            BEGIN
              SELECT extract(xmltype(rec_lot_fiche.lob_xml_file),'LotFicheParam/FICHE['||i||']')
                INTO v_xml
                FROM DUAL;
              IF v_xml IS NULL THEN
                P_INS_journal(3,'exit fiche OK:');
                cpt_erreur:=cpt_erreur+1;
                EXIT;--on sort de la boucle des fiches
              END IF;

              IF i = 1 THEN
                o_erreur := 'Génération impossible des fiches, remise <'|| to_char(i_numremise) ||'>';
                P_INS_journal(1,'Génération impossible des fiches de paramétrage pour la remise <'|| to_char(i_numremise) ||'>');
              END IF;

              -- Faire le test de validité XML pour connaitre l erreur
              -- Historisation de l'erreur
              BEGIN
                v_xml := v_xml.createSchemaBasedXML('FICHE-PARAM-DSN-OC-R1.3.8.xsd');
                -- Test validité XML
                xmltype.schemaValidate(v_xml);

              EXCEPTION
                WHEN OTHERS THEN
                  cpt_erreur:=cpt_erreur+1;
                  SELECT extractvalue(xmltype(rec_lot_fiche.lob_xml_file),'LotFicheParam/FICHE['||i||']/@IdentifiantFiche')
                    INTO loc_IdentifiantFiche
                  FROM DUAL;
                   o_erreur := 'Génération impossible de la fiche <'|| to_char(loc_IdentifiantFiche) ||'>';
                   P_INS_journal(1,'Génération impossible de la fiche <'|| to_char(loc_IdentifiantFiche) ||'>');

                  CASE SQLCODE
                    WHEN '-31154'   THEN    -- ORA-31154: document XML non valide
                     o_erreur := 'Schéma non valide : '||SUBSTR(sqlerrm,133,45)||' imcomplète ou manquante';
                     P_INS_journal(1,'Schéma non valide : '||SUBSTR(sqlerrm,133,45)||' imcomplète ou manquante');
                  ELSE
                    o_erreur := 'Erreur rencontrées ' ||SUBSTR(SQLERRM,1,132);
                    P_INS_journal(1,'Erreur rencontrées ' ||SUBSTR(SQLERRM,1,132));
                  END CASE;
              END;
            EXCEPTION
               WHEN OTHERS THEN
                  o_erreur := 'Erreur rencontrées ' ||SQLERRM;
                  P_INS_journal(1,'Erreur rencontrées ' ||SQLERRM);
                  EXIT;
            END;

          END LOOP;

        EXCEPTION
          WHEN OTHERS THEN
            P_INS_journal(1,'fiche KO'|| sqlerrm);
        END;
      END LOOP;



    -----------------------------------------------------------------------------
    ------------------ CONCENTRATEUR CTIP ET FNMF  ==> 1 FICHIER PAR FICHE
    -----------------------------------------------------------------------------
    ELSE

      i:=0;--compteur des fiches
      -- on parcours les fiches invalides afin de les valider pour en sortir les erreurs des fiches
      -- on a une seule fiche par ligne de curseur
      FOR rec_fiche  IN  cur_fiche (0) LOOP
        BEGIN
          cpt_tot_fiche_invalide:= cpt_tot_fiche_invalide+1;

          -- Parcourir chaque fiche du lot,
          LOOP
            i:=i+1;
            BEGIN
              SELECT extract(xmltype(rec_fiche.lob_xml_file),'FICHE['||i||']')
                INTO v_xml
                FROM DUAL;
              IF v_xml IS NULL THEN
                P_INS_journal(3,'exit fiche OK:');
                cpt_erreur:=cpt_erreur+1;
                EXIT;--on sort de la boucle des fiches
              END IF;
              IF i = 1 THEN
              o_erreur :='Génération impossible des fiches de paramétrage pour la remise <'|| to_char(i_numremise) ||'>'  ;
                P_INS_journal(1,'Génération impossible des fiches de paramétrage pour la remise <'|| to_char(i_numremise) ||'>');
              END IF;

              -- Faire le test de validité XML pour connaitre l erreur
              -- Historisation de l'erreur
              BEGIN
                v_xml := v_xml.createSchemaBasedXML('FICHE-PARAM-DSN-OC-R1.3.8.xsd');
                -- Test validité XML
                xmltype.schemaValidate(v_xml);

              EXCEPTION
                WHEN OTHERS THEN
                  cpt_erreur:=cpt_erreur+1;
                  o_erreur := 'Génération impossible de la fiche <'|| to_char(rec_fiche.idfiche) ||'>'  ;
                  P_INS_journal(1,'Génération impossible de la fiche <'|| to_char(rec_fiche.idfiche) ||'>');

                  CASE SQLCODE
                    WHEN '-31154'   THEN    -- ORA-31154: document XML non valide
                      o_erreur := 'Schéma non valide : '||SUBSTR(sqlerrm,133,45)||' imcomplète ou manquante'  ;
                      P_INS_journal(1,'Schéma non valide : '||SUBSTR(sqlerrm,133,45)||' imcomplète ou manquante');
                  ELSE
                    o_erreur := 'Erreur rencontrées ' ||SUBSTR(SQLERRM,1,132)  ;
                    P_INS_journal(1,'Erreur rencontrées ' ||SUBSTR(SQLERRM,1,132));
                  END CASE;
              END;
            EXCEPTION
               WHEN OTHERS THEN
                  o_erreur := 'Erreur rencontrées ' ||SUBSTR(SQLERRM,1,132)  ;
                  P_INS_journal(1,'Erreur rencontrées ' ||SQLERRM);
                  EXIT;
            END;

          END LOOP;

        EXCEPTION
          WHEN OTHERS THEN
            o_erreur := 'fiche KO' ||SUBSTR(SQLERRM,1,132)  ;
            P_INS_journal(1,'fiche KO'|| sqlerrm);
        END;
      END LOOP;
    END IF;

  END LOOP;
   -----------------------------------------------------------------------------
   -- GENERATION DES FICHES UNIQUEMENT SI TOUTES LES FICHES SONT VALIDES
  -----------------------------------------------------------------------------
  IF NVL(cpt_tot_lot_fiche_invalide,0) = 0 AND NVL(cpt_tot_fiche_invalide,0) = 0  THEN
    -- on ecrit les fiches valides
    FOR rec_lot_fiche  IN  cur_lot_fiche (1) LOOP

      BEGIN
        SELECT DIRECTORY_NAME
          INTO loc_repertoire
          FROM ALL_DIRECTORIES
         WHERE DIRECTORY_NAME=TRIM(rec_lot_fiche.concentrateur);
      EXCEPTION
        WHEN OTHERS THEN
          P_INS_journal(1,'Répertoire logique du Concentrateur non trouvé'|| sqlerrm);
          RAISE exc_fichier;
      END;


      P_NOM_FICHIER(i_numremise,rec_lot_fiche.concentrateur,'AF10T',i_fichier,loc_fichier);

      DBMS_XSLPROCESSOR.clob2file( rec_lot_fiche.lob_xml_file
                                 , loc_repertoire
                                 , loc_fichier
                                       );
      --EXIT;--on sort de la boucle pour générer qu un seul fichier de lot de fiches

    END LOOP;
  END IF;

  IF NVL(cpt_tot_fiche_invalide,0) = 0 THEN
    -- on ecrit les fiches valides
    FOR rec_fiche  IN  cur_fiche(1)  LOOP

      BEGIN
        SELECT DIRECTORY_NAME
          INTO loc_repertoire
          FROM ALL_DIRECTORIES
         WHERE DIRECTORY_NAME=TRIM(rec_fiche.concentrateur);
      EXCEPTION
        WHEN OTHERS THEN
          P_INS_journal(1,'Répertoire logique du Concentrateur non trouvé'|| sqlerrm);
          RAISE exc_fichier;
      END;

  /*  IF rec_fiche.concentrateur = 'CTIP'  THEN   -- nommage spécifique pour le fichier du CTIP
      loc_fichier:='DSN_FP_136_'||TRIM(rec_fiche.concentrateur)||'_DGER_'||to_char(rec_fiche.idfiche)||'.xml';
      P_INS_journal(1,'Le nom du fichier reformaté est: '||loc_fichier);
    ELSIF rec_fiche.concentrateur = 'FNMF'  THEN  -- nommage spécifique pour le fichier du FNMF
      loc_fichier:='DSN_FP_136_'||TRIM(rec_fiche.concentrateur)||'_DGER_'||to_char(rec_fiche.idfiche)||'.xml';
      P_INS_journal(1,'Le nom du fichier reformaté est: '||loc_fichier);
    ELSE   */
      P_NOM_FICHIER(rec_fiche.idfiche,rec_fiche.concentrateur,'AF10T',i_fichier,loc_fichier);
 --   END IF;


    DBMS_XSLPROCESSOR.clob2file( rec_fiche.lob_xml_file
                               , loc_repertoire
                               , loc_fichier
                                     );

    END LOOP;
  END IF;




  IF cpt_erreur = 0 THEN
    PK_TPE.P_MAJ_REMISE_EXTERN_DATE_TRANS(i_numremise);
  ELSE
    P_INS_journal(1,'Le nombre d''erreur rencontré dans le traitement est de : '||to_CHAR(cpt_erreur));

  END IF;

  P_INS_journal(1,'Fin du traitement <'||i_traitement||'>');

EXCEPTION
  WHEN exc_fichier THEN
    P_INS_journal(1,'Génération des fiches de paramétrage impossible de la remise <'||i_numremise||'>');
    ROLLBACK;
  WHEN OTHERS THEN
    --P_INS_journal(1,'Fin du traitement KO:' ||SQLERRM);
      o_erreur := 'Anomalie traitement : '||SUBSTR(sqlerrm,1,132)  ;
    P_INS_journal(1,'Anomalie traitement : '||SUBSTR(sqlerrm,1,132));
    P_INS_journal(1,'Anomalie traitement : '||SUBSTR(sqlerrm,133,132));
    ROLLBACK;
END P_AF11;




/*********** Procédure de génération de fiche de paramétrage automatiquement */
PROCEDURE P_GENERER_FICHE_AUTO IS

  p_delais          date := trunc(sysdate-1);--RG délai : prise en compte le surlendemain
  I_param1          param_batch.param1%Type;
  I_param2          param_batch.param2%Type;
  I_param3          param_batch.param3%Type;
  I_param4          param_batch.param4%Type;
  I_param5          param_batch.param5%Type;
  l_traitement      TYP_BATCH.BATCHID%TYPE := 'AF10T';
  l_traitement_AF11 TYP_BATCH.BATCHID%TYPE := 'AF11T';

  l_fiche_existe NUMBER :=0; --variable qui vérifie si une fiche existe
  l_found        NUMBER;
  l_erreur       VARCHAR2(120);
  L_nom_fichier  typ_batch.RESSOURCE%TYPE;
  L_repertoire   typ_batch.REPERTOIRE%TYPE;


  TAB_numclis  TAB_numcli;
  TAB_num_fic_manu  TAB_numcli;    -- pour les fiches constituées manuellement
  l_nb_cli  number :=0;

  l_max_date_modif date ;
  CURSOR c_fiches_to_gen IS
   SELECT numcli,
          max(date_modif) date_modif,
          max(date_effet) date_effet
   FROM(
        SELECT  numgar,
                numcli,
                date_modif,
                date_effet
        FROM V_FICHE_TO_GEN
        WHERE trunc(date_modif)  =  p_delais  -- seule les modification
        AND exists(  SELECT  1    -- la porte DSN doit être ouverte pour le contrat
                    FROM porte_contrat pc, contrat_ref cr
                    WHERE pc.NUMGAR = cr.NUMGAR_REF
                    AND V_FICHE_TO_GEN.numgar = cr.NUMGAR_REF
                      AND numporte  = 20 )
         )
   GROUP BY NUMCLI -- on prends la dernière modification en compte pour la verification ultérieure de l'existance d'une fiche sur le numcli
   ;
  --prise en compte des fiches auto et manuelles validées
  CURSOR C_REMISE_TO_GEN IS
    SELECT  re.NUMREMISE, df.numcli
    FROM dsn_fiche df,  remise_externe re
      WHERE df.NUMREMISE = re.NUMREMISE
      AND trunc(re.datvalide) >= trunc(sysdate -1) --on prend en compte les fiches du jour et de la veille selon l'heure d'exécution du traitement
      AND re.DATE_TRANS is null
      AND re.VALIDE = 'O'
      ;
BEGIN
  G_nom_traitement := l_traitement;
  P_INS_journal(1,'Traitement auto de fiche DSN, debut de la constitution automatique');
  TAB_numclis := new TAB_numcli(null);


   -- récupération du paramétrage de génération de fiche DSN
   Select  Param1, Param2, Param3, Param4, LOWER(NVL(Param5,'NoTest'))
      Into  I_param1,I_param2,I_param3,I_param4,I_param5
      From  Param_Batch
     Where  NumBatch = l_traitement;

  --parcourt des fiches à générer
  FOR r_fiche_to_gene in c_fiches_to_gen LOOP

    BEGIN -- on verifie si une fiche existe deja pour le numcli et si la dernière modification pour le numcli a été pris en compte

      WITH ftg AS (SELECT max(date_modif) date_max   -- récupération de la dernière modification.
                    FROM v_fiche_to_gen
                    WHERE  numcli = r_fiche_to_gene.numcli
                    GROUP BY NUMCLI)
        SELECT DISTINCT 1
          INTO  l_fiche_existe
          FROM dsn_fiche df,  remise_externe re, ftg
            WHERE df.NUMREMISE = re.NUMREMISE
            AND df.numcli = r_fiche_to_gene.numcli
            AND trunc(re.date_remise) >= trunc(nvl(ftg.date_max, re.date_remise))
        ;

    EXCEPTION
      WHEN OTHERS THEN
       l_fiche_existe := 0;  -- pas de fiche trouvée postérieur a la dernière modification concernant le numcli => on regénére une fiche
    END;

    IF l_fiche_existe =0 THEN

      P_INS_journal(1,'Traitement auto de constit de fiche DSN pour la société['||r_fiche_to_gene.numcli||'] a la date['||d2e(trunc(sysdate))||'] pour une modification du ['||d2e(r_fiche_to_gene.date_modif)||']');
      l_nb_cli := l_nb_cli+1;
      PK_AF10.P_AF10( l_traitement,
                       20,-- DSN
                       to_char(r_fiche_to_gene.numcli),
                       null,--i_siren,
                       null,--i_nic,
                       r_fiche_to_gene.date_effet,
                       null,--i_numproduit,
                       null,--i_numproduitFin,
                       null,--i_session,
                       I_param1,
                       I_param2,
                       3,--I_param5,--l_niv_msg,
                       l_found,
                       l_erreur);

      -- gestion des erreurs:   deja gérées dans AF10
      IF TAB_numclis(TAB_numclis.count) IS NOT NULL THEN
        TAB_numclis.extend(1);
      END IF;

      TAB_numclis(TAB_numclis.count) :=  new AFFIL_FICHE_DSN_INFO(r_fiche_to_gene.numcli,l_erreur);
      l_erreur := '';
    ELSE
      P_INS_journal(1,'Pas de constit de fiche DSN auto pour la société['||r_fiche_to_gene.numcli||'] a la date['||d2e(trunc(sysdate))||'] car déjà constituée aprés le['||d2e(r_fiche_to_gene.date_modif)||']');
    END IF;

  END LOOP;

  -- MUR M0006475 bloquer validation des fiches constituées du samedi au lundi
  if to_char(sysdate, 'FMDay', 'NLS_DATE_LANGUAGE=french') not in ('Samedi','Dimanche','Lundi') then
    -- validation des fiches générées par le traitement de masse
    UPDATE REMISE_EXTERNE
    SET VALIDE = 'O',
        DATVALIDE = nvl(DATVALIDE,sysdate),
        DATEDIT = nvl(DATEDIT,sysdate),
        numutil = f_numutil
    WHERE numremise in ( SELECT  re.NUMREMISE
                         FROM dsn_fiche df,  remise_externe re
                         WHERE df.NUMREMISE = re.NUMREMISE
                         AND trunc(re.date_remise) >= trunc(sysdate-1)
                         AND df.numcli in (  SELECT  numcli
                                             FROM V_FICHE_TO_GEN
                                             WHERE trunc(date_modif) >= trunc(p_delais) ))
    AND DATVALIDE IS NULL;

    COMMIT;

    SELECT ressource, f_rep_imp_exp(repertoire, 'E', 'PKG')
    INTO  l_nom_fichier, l_repertoire
    FROM typ_batch
    WHERE batchid = l_traitement_AF11 ;

    TAB_num_fic_manu := new TAB_numcli(null);
    -- génération XML des fiches de paramétrage constituées et validées
    FOR R_REMISE_TO_GEN in C_REMISE_TO_GEN LOOP
      IF TAB_num_fic_manu(TAB_num_fic_manu.count) IS NOT NULL THEN
        TAB_num_fic_manu.extend(1);
      END IF;
       l_erreur := '';
      PK_AF10.P_AF11(
        i_traitement => l_traitement_AF11,
        i_numremise  => R_REMISE_TO_GEN.numremise,
        i_session    => 0,
        i_niv_msg    => 1,--I_param5,
        i_repertoire => l_repertoire,
        i_fichier    => l_nom_fichier,
        o_found      => L_found,
        o_erreur     => L_erreur
        );

      TAB_num_fic_manu(TAB_num_fic_manu.count) :=  new AFFIL_FICHE_DSN_INFO(R_REMISE_TO_GEN.numcli,l_erreur);
    END LOOP;

    COMMIT;
    P_SEND_RAPPORT_ENVOI_MAIL(sysdate, TAB_numclis ,TAB_num_fic_manu, l_nb_cli) ;--envoi de mail non tracé

  else -- envoi mail liste des fiches à valider manuellement
    P_MAIL_REMISES_NON_VALIDEES ;
    commit;
  end if ;

END P_GENERER_FICHE_AUTO;
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_NOM_FICHIER                                             */
/* Type         :  Public                                                    */
/* Description  :  Prodécedure de dénomination du fichier physique généré    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_NOM_FICHIER ( i_numremise     IN     REMISE_EXTERNE.NUMREMISE%TYPE
                         ,i_concentrateur IN     DSN_FICHE.CONCENTRATEUR%TYPE
                        , i_traitement    IN     TYP_BATCH.BATCHID%TYPE
                        , i_fichier       IN     TYP_BATCH.RESSOURCE%TYPE
                        , o_fichier         OUT VARCHAR2
                        )
IS

  loc_date         VARCHAR2(50):=NULL;
  loc_heure        VARCHAR2(50):=NULL;
  loc_producteur   PARAM_BATCH.PARAM2%TYPE:=NULL;
  exc_producteur   EXCEPTION;
  loc_idFicUnique  VARCHAR2(100):=NULL;


  BEGIN
    loc_idFicUnique := TRIM(TO_CHAR(i_numremise)||'_'||TO_CHAR(i_concentrateur));
    --
    -- Recherche du code producteur qui correspond au param1 du traitement AF10T
    BEGIN
      SELECT DISTINCT PARAM2
                 INTO loc_producteur
                 FROM param_batch
                WHERE NUMBATCH='AF10T';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE exc_producteur;
      WHEN OTHERS THEN
        RAISE exc_producteur;
    END;
    IF  TRIM(loc_producteur) IS NULL THEN
      RAISE exc_producteur;
    END IF;
    --
    loc_date := TO_CHAR (SYSDATE, 'YYYYMMDD');
    --
    SELECT REPLACE (TO_CHAR (SYSDATE, 'fmHH24:MI:SS'), ':', '-')
      INTO loc_heure
      FROM DUAL;

    --
    SELECT REPLACE (REPLACE ( REPLACE (REPLACE(i_fichier,'#PR',loc_producteur),'#REMISE',loc_idFicUnique), '#DT', loc_date), '#HR', loc_heure)
      INTO o_fichier
       FROM DUAL;
    P_INS_journal(1,'Le nom du fichier reformaté est: '||o_fichier);
  EXCEPTION
    WHEN exc_producteur THEN
      P_INS_journal(1,'Aucun code producteur paramétré pour le traitement');
      o_fichier:=NULL;
    WHEN OTHERS THEN
      P_INS_journal(1,'Fin du traitement KO:' || SQLERRM);
      o_fichier:=NULL;
END P_NOM_FICHIER;

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





/*************Procédure d'envoi de mail *********/

PROCEDURE P_SEND_RAPPORT_ENVOI_MAIL(i_date_session DATE, i_numclis TAB_numcli,i_manuels TAB_numcli, i_nb_total number)
IS
  loc_envoi envoi_mail%ROWTYPE;
  l_ERROR   VARCHAR2(200);
  text  CLOB;
  list_email varchar(4000) :='';
  list_email_unit varchar(1000) :='';

  list_email_m varchar(4000) :='';
  list_email_unit_m varchar(1000) :='';
  l_nom_machine  param_machine.nom_machine%type;

  l_destinataire varchar2(60);
  loc_interloc individu.numindiv%type;
  i number :=1;
  l_s varchar2(1) :='';
BEGIN

  IF i_nb_total > 0 THEN

    SELECT 1, 1, compte_mail
    INTO loc_envoi.NUMINDIV_DEST, loc_envoi.NUMBENE, loc_envoi.destinataire
    FROM param_machine
    WHERE id_machine= 'SERVEUR_MAIL';

    SELECT instance into l_nom_machine
    FROM parametres;


    SELECT DISTINCT NVL(MAX(interlocuteur),0)
    INTO loc_interloc
    FROM interlocuteur
    WHERE numindiv= 1 --
      AND OPE_CRRR=1  -- Cotisations
      AND valide='O'
      AND defaut='O';


    --l_destinataire:= NVL(F_COORDONNE_CONTACT(loc_interloc,4,1),F_COORDONNE_CONTACT(loc_interloc,4,2));
    l_destinataire  := 'dsn@gerep.fr';

    WHILE i <= i_numclis.count LOOP
    -- DBMS_OUTPUT.PUT_LINE(i_mails_in_error(i));
      list_email_unit :='- '||i_numclis(i).value || ' : ' ||PK_PERSONNE.F_NOM(i_numclis(i).value) ||' Informations :['||i_numclis(i).informations ||']';
      list_email := list_email ||list_email_unit||CHR(10)||CHR(13);
      i := i + 1;
    END LOOP;
      i:=1;
    -- information sur la génération de fiche
    WHILE i <= i_manuels.count LOOP
    -- DBMS_OUTPUT.PUT_LINE(i_mails_in_error(i));
      list_email_unit_m :='- '||i_manuels(i).value || ' : ' ||PK_PERSONNE.F_NOM(i_manuels(i).value) ||' Informations :['||i_manuels(i).informations ||']';
      list_email_m := list_email_m ||list_email_unit_m||CHR(10)||CHR(13);
      i := i + 1;
    END LOOP;

    if i_nb_total > 1 THEN
      l_s :='s';
    END IF;
    loc_envoi.sujet :='[Rapport_ARTHUS] Rapport de génération de fiche de paramétrage DSN automatique '||i_date_session || ' sur l''instance '||l_nom_machine;
    loc_envoi.corps := i_nb_total||' Fiche'||l_s||' de paramétrage générée'||l_s||' automatiquement, concernant le'||l_s||' client'||l_s||' suivant'||l_s||'  '|| CHR(10)||CHR(13)||   list_email ;
    loc_envoi.corps := loc_envoi.corps|| CHR(10)||CHR(13)||'Rapport de génération : '|| CHR(10)||CHR(13)||   list_email_m ;

    GET_HTML_VARCHAR_FROM_FS('MAILS_IN', 'template_mail_rapport.html', text);
    PK_MAIL.transcode_template( template_mail=>text,
                                corps_msg =>loc_envoi.corps,
                                numindiv=>'',
                                numbene=>'',
                                sujet_msg =>loc_envoi.sujet);
    pk_mail.SEND_EMAIL(
    P_RECIPIENT     => l_destinataire,--'testcl@cat-amania.com',--loc_envoi.destinataire ,
    P_CC            => null,
    P_BCC           => null, --'Support@arthus-progiciels.com',
    P_SUBJECT       => '[Rapport_ARTHUS] Rapport de génération de fiches de paramétrage DSN automatique du '||d2e(i_date_session),
    P_BODY          =>text,
    P_NUMUTIL       =>8,
    P_SENDER        => 'no-reply@gerep.fr',--l_destinataire,-- loc_envoi.destinataire ,
    P_numindiv_dest=> null,
    P_ERROR        => l_ERROR);

  END IF;
  -- EXCEPTION
    --  WHEN  OTHERS THEN
      --  P_INS_journal(1,sqlerrm );
END P_SEND_RAPPORT_ENVOI_MAIL;


-- MUR M0006475
PROCEDURE P_MAIL_REMISES_NON_VALIDEES
is

  l_nom_machine  param_machine.nom_machine%type;
  l_destinataire varchar2(60);
  loc_envoi      envoi_mail%ROWTYPE;
  text           CLOB;
  l_ERROR   VARCHAR2(200);

  cursor c_remise is
    SELECT  NUMREMISE, date_remise  , nombre
	FROM remise_externe re
    WHERE valide = 'N'
	and trunc(date_remise) = trunc(sysdate)
	and numporte = 20
    order by numremise ;
  r_remise c_remise%rowtype ;

  cursor c_fiche (i_numremise number) is
    select idfiche , siren , nic , raison , numcli
    from dsn_fiche
    where numremise  =  i_numremise
	;
  r_fiche c_fiche%rowtype ;

begin

  SELECT instance into l_nom_machine FROM parametres;

  l_destinataire  := 'dsn@gerep.fr';
  loc_envoi.sujet :='[Rapport_ARTHUS] Rapport de génération de fiche de paramétrage DSN non validées '||trunc(sysdate) || ' sur l''instance '||l_nom_machine;
  loc_envoi.corps := ' ' ;

  -- trt des remises du jour non validées
  for r_remise in c_remise loop
    loc_envoi.corps := loc_envoi.corps ||  'Remise ' || r_remise.numremise || ' à valider manuellement comprenant ' || r_remise.nombre || ' fiches dsn : ' ||CHR(10)||CHR(13) ;
    -- traiterment des fiches associées
	for r_fiche in c_fiche(r_remise.numremise) loop
	  loc_envoi.corps :=  loc_envoi.corps || 'fiche ' || r_fiche.idfiche || ' pour la société ' || r_fiche.numcli || ' ' || r_fiche.raison || ' ' || r_fiche.siren || ' ' || r_fiche.nic || ' ' ||CHR(10)||CHR(13) ;
	end loop;
  end loop ;

  if loc_envoi.corps  != ' ' then
    GET_HTML_VARCHAR_FROM_FS('MAILS_IN', 'template_mail_rapport.html', text);
    PK_MAIL.transcode_template( template_mail=>text,
                                corps_msg =>loc_envoi.corps,
                                numindiv=>'',
                                numbene=>'',
                                sujet_msg =>loc_envoi.sujet);

    pk_mail.SEND_EMAIL(
    P_RECIPIENT     => l_destinataire,
    P_CC            => null,
    P_BCC           => null, --'Support@arthus-progiciels.com',
    P_SUBJECT       => '[Rapport_ARTHUS] Rapport de génération de fiches de paramétrage DSN non validées du '|| trunc(sysdate),
    P_BODY          =>text,
    P_NUMUTIL       =>8,
    P_SENDER        => 'no-reply@gerep.fr',
    P_numindiv_dest=> null,
    P_ERROR        => l_ERROR);
  end if ;



exception
  when others then null ;
end P_MAIL_REMISES_NON_VALIDEES ;

END PK_AF10;
/
