CREATE OR REPLACE PACKAGE ARTHUS."PK_GEST_AFFIL"
AS
/*============================================================================*/
/* PACKAGE      : PK_GEST_AFFIL.sql                                           */
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

-- Tableau
Tab_RG  PK_CTRL_AFFIL.T_RG_TAB;
TYPE T_cntrt IS RECORD (PREV NUMBER);
TYPE TAB_T_cntrt IS TABLE OF T_cntrt index by binary_integer;

PROCEDURE P_GestAffiliation ( i_Numremise    IN   AFFIL_PORTE.NUMREMISE%TYPE
                            , i_Porte        IN   AFFIL_PORTE.NUMPORTE%TYPE
                            , i_Naturedeb    IN   AFFIL_FICHIER.NATURE%TYPE
                            , i_Naturefin    IN   AFFIL_FICHIER.NATURE%TYPE
                            , i_session      IN   JOURNAL_ADM.ID_SESSION%TYPE
                            , i_traitement   IN   file_edition.batchid%TYPE
                            , i_idligne      IN   JOURNAL_ADM.IDLIGNE%TYPE
                            , i_numligne     IN   AFFIL_PORTE.NUMLIGNE%TYPE DEFAULT NULL
                            , i_flag_Ident   IN   NUMBER DEFAULT NULL
                            , o_erreur       OUT  VARCHAR2);

FUNCTION F_GestLigneAffil ( I_AFFIL_PORTE IN OUT   AFFIL_PORTE%ROWTYPE
                          , I_TAB_CNTRT IN  TAB_T_cntrt
                          , I_AFFIL_FICHIER IN OUT AFFIL_FICHIER%ROWTYPE
                          , I_ANO_SOCIETE IN NUMBER
                      --    , IO_exc_recursif IN OUT EXCEPTION
                          )
RETURN NUMBER;

PROCEDURE P_GestAYD ( I_AFFIL_PORTE    IN       AFFIL_PORTE%ROWTYPE
                    , i_log          IN  OUT  JOURNAL_ADM.MSG_ADM%TYPE
                    , i_ano              OUT  AFFIL_ANO.NUMANO%TYPE);

FUNCTION F_GestLigneAYD ( I_AFFIL_PORTE     IN          AFFIL_PORTE%ROWTYPE
                        , I_AFFIL_PORTE_AYD IN  OUT     AFFIL_PORTE_AYD%ROWTYPE
                        , i_log             IN  OUT     JOURNAL_ADM.MSG_ADM%TYPE
                        , o_erreur              OUT     VARCHAR2)
RETURN NUMBER;

PROCEDURE P_INS_journal(P_niv in NUMBER,
                        P_msg in VARCHAR2,
                        p_msg2 in varchar2 := null);

-- ------------------------------------------------- Fin des procedures publiques --
END PK_GEST_AFFIL;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_GEST_AFFIL
As
/*============================================================================*/
/* PACKAGE      : PK_GEST_AFFIL.sql                                           */
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
/* Nom          :  P_GestAffiliation                                         */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire                                           */
/*                                                                           */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
PROCEDURE P_GestAffiliation ( i_Numremise    IN   AFFIL_PORTE.NUMREMISE%TYPE
                            , i_Porte        IN   AFFIL_PORTE.NUMPORTE%TYPE
                            , i_Naturedeb    IN   AFFIL_FICHIER.NATURE%TYPE
                            , i_Naturefin    IN   AFFIL_FICHIER.NATURE%TYPE
                            , i_session      IN   JOURNAL_ADM.ID_SESSION%TYPE
                            , i_traitement   IN   file_edition.batchid%TYPE
                            , i_idligne      IN   JOURNAL_ADM.IDLIGNE%TYPE
                            , i_numligne     IN   AFFIL_PORTE.NUMLIGNE%TYPE DEFAULT NULL
                            , i_flag_Ident   IN   NUMBER DEFAULT NULL
                            , o_erreur       OUT  VARCHAR2)
IS
  loc_numremise            AFFIL_PORTE.NUMREMISE%TYPE:=NULL;
  loc_AFFIL_FICHIER        AFFIL_FICHIER%ROWTYPE;
  loc_AFFIL_PORTE          AFFIL_PORTE%ROWTYPE;
  loc_AFFIL_PORTE_FORCAGE  AFFIL_PORTE_FORCAGE%ROWTYPE;
  loc_ano                  NUMBER:=0;
  loc_ano_societe          NUMBER:=0;
  loc_ano_numfor           NUMBER:=0;
  i                        VARCHAR2(100):=NULL;
  v_numgar                 AFFIL_PORTE_ADH.NUMGAR%TYPE;
  v_numfor                 AFFIL_PORTE_ADH.REFGARANTIE%TYPE;
  --cpt_ano                  NUMBER:=0;
  l_tabcntrt               TAB_T_cntrt;
  l_cntrt                  T_cntrt;
  loc_log                  VARCHAR2(200);
  loc_exc_recursif         EXCEPTION;



  CURSOR C_AFFIL_FICHIER(p_Numremise AFFIL_PORTE.NUMREMISE%TYPE, p_Porte AFFIL_PORTE.NUMPORTE%TYPE,p_naturedeb AFFIL_FICHIER.NATURE%TYPE,p_naturefin AFFIL_FICHIER.NATURE%TYPE) IS
  SELECT *
  FROM AFFIL_FICHIER
  WHERE NUMREMISE = p_Numremise
  AND NUMPORTE = p_Porte
  AND NATURE BETWEEN NVL(p_naturedeb,NATURE) AND NVL(p_naturefin,NATURE);

  CURSOR C_AFFIL_PORTE(p_Numremise AFFIL_PORTE.NUMREMISE%TYPE, p_Porte AFFIL_PORTE.NUMPORTE%TYPE, p_numligne  AFFIL_PORTE.NUMLIGNE%TYPE,
  p_entreprise AFFIL_PORTE.ENTREPRISE%TYPE, p_etabli AFFIL_PORTE.ETABLI%TYPE,p_num_ordre AFFIL_PORTE.NUM_ORDRE%TYPE)
      IS
  SELECT *
   FROM AFFIL_PORTE
  WHERE  AFFIL_PORTE.NUMREMISE = p_Numremise       -- TODO : Vérifier si le ou les numéros de remises seront nécéssaire
    AND AFFIL_PORTE.NUMPORTE = p_Porte
    AND AFFIL_PORTE.NUMLIGNE = NVL(p_numligne,AFFIL_PORTE.NUMLIGNE)
    AND AFFIL_PORTE.ETAT = NVL(2,AFFIL_PORTE.ETAT)
    AND AFFIL_PORTE.ENTREPRISE = p_entreprise
    AND AFFIL_PORTE.ETABLI = p_etabli
    AND AFFIL_PORTE.NUM_ORDRE = p_num_ordre
  ORDER BY NUMREMISE, NUMLIGNE ASC;

  CURSOR c_contrat( P_numremise  AFFIL_PORTE.NUMREMISE%TYPE
                  , P_numporte   AFFIL_PORTE.NUMPORTE%TYPE
                  , p_etabli     AFFIL_PORTE.ETABLI%TYPE
                  , P_entreprise AFFIL_PORTE.ENTREPRISE%TYPE
                  , P_num_ordre  AFFIL_PORTE.NUM_ORDRE%TYPE)
      IS
  SELECT distinct adh.ref_ext_cntrt, cntrt.ref_orgn_cntrt,/*f_get_transco('DSN', 'COLLEGE',adh.code_pop,2)*/ adh.code_pop,adh.numgar
     FROM affil_porte_adh adh, affil_porte_cntrt cntrt, affil_porte p
    WHERE cntrt.numremise = P_numremise
    AND cntrt.numporte = P_numporte
    AND cntrt.num_ordre = P_num_ordre
    AND cntrt.etabli = p_etabli
    AND cntrt.entreprise = P_entreprise
    AND cntrt.numremise = adh.numremise
    AND cntrt.numporte = adh.numporte
    AND cntrt.numremise = p.numremise
    AND cntrt.numporte = p.numporte
    AND adh.numligne = p.numligne
    AND adh.ref_ext_cntrt = cntrt.ref_ext_cntrt
    AND adh.numayd = 0
    AND cntrt.etabli = p.etabli
    AND cntrt.entreprise = p.entreprise
    AND cntrt.num_ordre = p.num_ordre;
   -- AND adh.numgar IS NULL;


  CURSOR C_adh (p_numremise Affil_porte_adh.numremise%TYPE
              , p_numporte Affil_porte_adh.numporte%TYPE
              , p_ref Affil_porte_adh.ref_ext_cntrt%TYPE
              , p_etabli     AFFIL_PORTE.ETABLI%TYPE
              , P_entreprise AFFIL_PORTE.ENTREPRISE%TYPE
              , P_num_ordre  AFFIL_PORTE.NUM_ORDRE%TYPE)is
  SELECT distinct adh.numligne
  FROM Affil_porte_adh adh, affil_porte ap
  WHERE adh.numremise = p_numremise
  AND adh.numporte = p_numporte
  AND adh.ref_ext_cntrt = p_ref
  AND ap.numremise = adh.numremise
  AND ap.numporte = adh.numporte
  AND ap.etabli = p_etabli
  AND ap.entreprise = P_entreprise
  AND ap.num_ordre =P_num_ordre
  AND ap.numligne = adh.numligne;

  CURSOR c_gar ( P_numremise  AFFIL_PORTE.NUMREMISE%TYPE
              , P_numporte   AFFIL_PORTE.NUMPORTE%TYPE
              , p_etabli   AFFIL_PORTE.ETABLI%TYPE
              , P_entreprise     AFFIL_PORTE.ENTREPRISE%TYPE
              , P_num_ordre  AFFIL_PORTE.NUM_ORDRE%TYPE)
      IS
  SELECT distinct adh.code_opt,adh.numgar
    FROM affil_porte_adh adh, affil_porte_cntrt cntrt, affil_porte p
    WHERE cntrt.numremise = P_numremise
    AND cntrt.numporte = P_numporte
    AND cntrt.etabli = p_etabli
    AND cntrt.entreprise = P_entreprise
    AND cntrt.num_ordre = P_num_ordre
    AND cntrt.numremise = adh.numremise
    AND cntrt.numporte = adh.numporte
    AND cntrt.numremise = p.numremise
    AND cntrt.numporte = p.numporte
    AND adh.numligne = p.numligne
    AND adh.ref_ext_cntrt = cntrt.ref_ext_cntrt
    --AND adh.numayd = 0 -- il faut prendre en compte tous les ayd
    AND cntrt.etabli = p.etabli
    AND cntrt.entreprise = p.entreprise
    AND adh.numgar IS NOT NULL
    AND adh.refgarantie IS NULL;

BEGIN

  G_nom_traitement:=i_traitement;
  G_idligne:=i_idligne;
  G_Session := i_session;

 P_INS_journal(3, 'DEBUT PK_GEST_AFFIL.P_GestAffiliation le '||TO_CHAR(SYSDATE));
  P_INS_journal(3, 'G_nom_traitement :'||G_nom_traitement||', G_Session : '||TO_CHAR(G_Session));

    --------------- Récupération de l utilisateur de la porte  ------------------------
  g_numutil:=PK_CTRL_AFFIL.F_FIND_PORTE_NUMUTIL(i_Porte);
  P_INS_journal(3, 'g_numutil '||TO_CHAR(g_numutil)||'i_Porte '||TO_CHAR(i_Porte));


    --------------- Affichage des règles de gestion ----------------------------------
  Tab_RG:=PK_CTRL_AFFIL.F_GET_REG_AFFIL(i_Porte);
  i := Tab_RG.FIRST;  -- Get first element of array
  WHILE i IS NOT NULL LOOP
  --  DBMS_Output.PUT_LINE ('Tab_RG of ' || i || ' is ' || Tab_RG(i));
    P_INS_journal(3, 'TABLEAU RG: '|| i || ' is ' || Tab_RG(i));
    i := Tab_RG.NEXT(i);  -- Get next element of array
  END LOOP;


  PK_CTRL_AFFIL.P_DEL_AFFIL_ANO_ETAT(i_Numremise,i_Porte,2);

  --------------- Parcours des fichiers d'une remise --------------
  --impact doublon de fichier ordonnancement de la log non intuitif
  FOR Rec_AFFIL_FICHIER IN C_AFFIL_FICHIER (i_Numremise,
                                            i_Porte,
                                            to_number(f_get_transco('DSN', 'FIC_IMP',i_Naturedeb)),
                                            to_number(f_get_transco('DSN', 'FIC_IMP',i_Naturefin)))LOOP
    loc_AFFIL_FICHIER := Rec_AFFIL_FICHIER;
    loc_ano_societe:=0;
    P_INS_journal(2, loc_log||',loc_AFFIL_FICHIER.NATURE:'||loc_AFFIL_FICHIER.NATURE);
    ---------------------------------------------------------------------------------
    -- **********************RECHERCHE SOCIETE **************************************
    ---------------------------------------------------------------------------------
    -- Recheche du souscripteur du contrat avec le numéro de siren de l'entreprise et du NIC établissement
    IF loc_AFFIL_FICHIER.NUMCLI IS NULL THEN
      loc_AFFIL_FICHIER.NUMCLI:=PK_CTRL_AFFIL.F_FIND_SOCIETE(loc_AFFIL_FICHIER.ENTREPRISE, loc_AFFIL_FICHIER.ETABLI,loc_ano_societe);
      IF loc_AFFIL_FICHIER.NUMCLI IS NOT NULL AND Rec_AFFIL_FICHIER.NUMCLI IS NULL THEN
        PK_CTRL_AFFIL.P_MAJ_AFFIL_FICHIER_NUMCLI(loc_AFFIL_FICHIER);
      END IF;
    END IF;

    -- création d'un tableau de tous les contrats de la remise pour en faciliter le référencement dans la suite
    FOR R_cntrt IN (SELECT * FROM AFFIL_PORTE_CNTRT WHERE NUMREMISE  = i_Numremise AND NUMPORTE =i_Porte
                    AND ETABLI =loc_AFFIL_FICHIER.ETABLI AND ENTREPRISE = loc_AFFIL_FICHIER.ENTREPRISE AND NUM_ORDRE =loc_AFFIL_FICHIER.NUM_ORDRE) LOOP
      --Forçage de masse ancienne référence DADS portant le caractère spécial ':'
      IF INSTR(R_cntrt.REF_ORGN_CNTRT,':')>0 THEN
        loc_AFFIL_PORTE_FORCAGE.numremise := R_cntrt.numremise;
        loc_AFFIL_PORTE_FORCAGE.entite := 'AFFIL_PORTE_CNTRT';
        loc_AFFIL_PORTE_FORCAGE.donnee := 'REF_ORGN_CNTRT';
        loc_AFFIL_PORTE_FORCAGE.numzone :=0;
        loc_AFFIL_PORTE_FORCAGE.valeur := R_cntrt.REF_ORGN_CNTRT;
        loc_AFFIL_PORTE_FORCAGE.numutil := g_numutil;

        FOR R_adh IN C_adh(i_Numremise,i_Porte,R_cntrt.REF_EXT_CNTRT, R_cntrt.ETABLI,R_cntrt.ENTREPRISE,R_cntrt.NUM_ORDRE) LOOP
          loc_AFFIL_PORTE_FORCAGE.numligne := R_adh.numligne;
          --si insertion du forcage réussie alors on met à jour la référence de contrat forcée SANS l'extension DADS
          IF PK_CTRL_AFFIL.F_INS_AFFIL_PORTE_FORCAGE(loc_AFFIL_PORTE_FORCAGE) THEN
            R_cntrt.REF_ORGN_CNTRT:=SUBSTR(R_cntrt.REF_ORGN_CNTRT,0,INSTR(R_cntrt.REF_ORGN_CNTRT,':')-1);
          END IF;
        END LOOP;
        -- Mise à jour de AFFIL_PORTE_CNTRT
        PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_CNTRT(R_cntrt);
      END IF;
    END LOOP;

    loc_log:=TO_CHAR(loc_AFFIL_FICHIER.NUMREMISE)|| '- client :' ||TO_CHAR(loc_AFFIL_FICHIER.NUMCLI);
    P_INS_journal(2, loc_log||',Société :'||loc_AFFIL_FICHIER.entreprise||' NIC'||loc_AFFIL_FICHIER.etabli||' identifiée:'||loc_AFFIL_FICHIER.NUMCLI);

    ---------------------------------------------------------------------------------
    -- ********************** CONTRAT ***********************************************
    ---------------------------------------------------------------------------------
    IF loc_AFFIL_FICHIER.NUMCLI IS NOT NULL THEN
      -- Boucle pour identifier les contrats (santé, prévoyance) uniquement si la société est identifiée et contrat non identifié pour un fichier
      -- la mise à jour du numgar se faisant en masse dans la boucle
      --RECHERCHE DU CONTRAT uniquement si null
      FOR  rec_contrat  IN c_contrat( loc_AFFIL_FICHIER.NUMREMISE
                                , loc_AFFIL_FICHIER.NUMPORTE
                                , loc_AFFIL_FICHIER.etabli
                                , loc_AFFIL_FICHIER.entreprise
                                , loc_AFFIL_FICHIER.num_ordre)  LOOP

        v_numgar:=NULL;
        IF rec_contrat.numgar IS NULL THEN

          v_numgar:=PK_CTRL_AFFIL.F_FIND_CONTRAT(loc_AFFIL_FICHIER,rec_contrat.REF_ORGN_CNTRT,rec_contrat.code_pop );
          P_INS_journal(2, loc_log||',contrat :'||v_numgar ||' pour CODE_POP:'||rec_contrat.CODE_POP||' REF_ORGN_CNTRT:'||rec_contrat.REF_ORGN_CNTRT || ' REF_EXT_CNTRT:'||rec_contrat.REF_EXT_CNTRT);
          IF PK_CTRL_AFFIL.F_GEST_CONTRAT(loc_AFFIL_FICHIER, rec_contrat.REF_EXT_CNTRT,rec_contrat.code_pop,v_numgar )>0 THEN
           -- cpt_ano:=cpt_ano+1;
            NULL;
          END IF;
          P_INS_journal(2, loc_log||',Contrat identifié:'||v_numgar);

          IF v_numgar IS NOT NULL THEN
            -- Mise à jour uniquement du numgar de AFFIL_PORTE_ADH mais en masse pour tous les références de contrat
            PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_ADH_NUMGAR(loc_AFFIL_FICHIER, rec_contrat.REF_EXT_CNTRT,rec_contrat.code_pop,v_numgar );
          END IF;
        ELSE v_numgar :=  rec_contrat.numgar;
        END IF;

        --pour tous les contrats identifiés ou non , on les mets dans un tableau
        IF v_numgar IS NOT NULL AND NOT l_tabcntrt.EXISTS(v_numgar) THEN
          l_cntrt.prev:=0;
          BEGIN
            SELECT COUNT(TYPE_CONTRAT) INTO l_cntrt.prev FROM CONTRAT WHERE NUMGAR = v_numgar AND TYPE_CONTRAT = 2;
          EXCEPTION
            WHEN OTHERS THEN l_cntrt.prev:=0;
          END;
          l_tabcntrt(v_numgar) := l_cntrt;
        END IF;

      END LOOP;
      ---------------------------------------------------------------------------------
      -- ********************** GARANTIE **********************************************
      ---------------------------------------------------------------------------------

      FOR rec_gar  IN c_gar( loc_AFFIL_FICHIER.NUMREMISE
                           , loc_AFFIL_FICHIER.NUMPORTE
                           , loc_AFFIL_FICHIER.etabli
                           , loc_AFFIL_FICHIER.entreprise
                           , loc_AFFIL_FICHIER.num_ordre)  LOOP
        loc_ano_numfor:=0;
        IF Tab_RG.EXISTS('CODEOPT') AND rec_gar.code_opt IS NULL  THEN
          P_INS_journal(1 , loc_log||', Recherche impossible de la garantie : code option vide');
         loc_ano_numfor :=76;--on force l'ano Code option vide: garantie non trouvée
        END IF;
        v_numfor :=PK_CTRL_AFFIL.F_FIND_NUMFOR(rec_gar.numgar,rec_gar.code_opt,loc_AFFIL_FICHIER, loc_ano_numfor);
        P_INS_journal(3 , loc_log||', Recherche de la garantie :'||v_numfor ||' Anomalie :'||loc_ano_numfor);
        IF v_numfor IS NOT NULL THEN
          PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_ADH_NUMFOR(loc_AFFIL_FICHIER, rec_gar.numgar,rec_gar.code_opt,v_numfor);
        END IF;
      END LOOP;
    END IF;

    IF NVL(i_flag_Ident,0) = 0 THEN
      ---------------------------------------------------------------------------------
      -- ********************** SALARIES***********************************************
      ---------------------------------------------------------------------------------
      --Parcours des salariés d'un fichier ou un seul salarié selon la demande
      FOR Rec_C_AFFIL_PORTE IN C_AFFIL_PORTE(i_Numremise,i_Porte,i_numligne,Rec_AFFIL_FICHIER.entreprise, Rec_AFFIL_FICHIER.etabli,Rec_AFFIL_FICHIER.num_ordre)  LOOP
        BEGIN
          Rec_C_AFFIL_PORTE.USERNAME_FORCAGE :=g_numutil;
          loc_ano:=F_GestLigneAffil(Rec_C_AFFIL_PORTE , l_tabcntrt, loc_AFFIL_FICHIER,loc_ano_societe);
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            P_INS_journal(1,'Erreur Salarié n°'||i_numligne||'-'||SUBSTR(SQLERRM,1,132));
            o_erreur:='Fin anormale P_GestAffiliation '||SUBSTR(SQLERRM,1,132);
        END;
      END LOOP;
      COMMIT;
    END IF;
  END LOOP;




  P_INS_journal(3, 'FIN PK_GEST_AFFIL.P_GestAffiliation le '||TO_CHAR(SYSDATE));
  o_erreur:='Fin normale du traitement';

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    P_INS_journal(1,'Erreur P_GestAffiliation '||SUBSTR(SQLERRM,1,132));
    o_erreur:='Fin anormale P_GestAffiliation '||SUBSTR(SQLERRM,1,132);
END P_GestAffiliation;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_GestLigneAffil                                          */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire                                           */
/*                                                                           */
/* Entree       :                                                            */
/* Retour       :  1 pour OK, 0 pour KO                                      */
/*---------------------------------------------------------------------------*/
FUNCTION F_GestLigneAffil ( I_AFFIL_PORTE IN OUT   AFFIL_PORTE%ROWTYPE
                          , I_TAB_CNTRT IN  TAB_T_cntrt
                          , I_AFFIL_FICHIER IN OUT AFFIL_FICHIER%ROWTYPE
                          , I_ANO_SOCIETE IN NUMBER
                       --   , IO_exc_recursif IN OUT EXCEPTION
                          )
RETURN NUMBER
IS
  -- variables
  cpt_ano_tot        NUMBER:=0;
  cpt_ano            NUMBER;

  loc_ano_techno     AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_indiv      AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_ayd             AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_histophys  AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_adr        AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_ctc        AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_rib        AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_mvt        AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_affil      AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_adhesion   AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_numfor     AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_resil      AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_susp       AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_lieunaiss  AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_nomjf      AFFIL_ANO.NUMANO%TYPE:=NULL;


  --loc_ano_societe    AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_cpt_ano_adh    NUMBER;
  loc_cpt_cntrt      NUMBER;
  loc_warning        NUMBER:=0;
  loc_warning1       NUMBER:=0;
  loc_lib_warning    VARCHAR2(150):=NULL;
  loc_warning_adr    NUMBER:=0;
  loc_warning_resil  NUMBER:=0;
  loc_warning_opt    NUMBER:=0;
  loc_idadhesion     ADHESION.IDADHESION%TYPE:=NULL;

  loc_numgarOuvert   NUMBER:=0;
  loc_log            JOURNAL_ADM.MSG_ADM%TYPE:=NULL;
  loc_flag_newindiv  NUMBER:=0;

  loc_numindiv       INDIVIDU.NUMINDIV%TYPE:=NULL;
 /* loc_numassu        INDIVIDU.NUMINDIV%TYPE:=NULL;
  loc_cpt_numassu    NUMBER:=0;
  loc_cpt_numindiv   NUMBER:=0;*/
  loc_cpt_adhesion   NUMBER :=0;
  loc_nomjf          INDIVIDU.NOMJF%TYPE:=NULL;
  loc_nom            INDIVIDU.NOM%TYPE:=NULL;
  loc_lieunais       INDIVIDU.LIEUNAIS%TYPE:=NULL;
  loc_mt_cot         NUMBER(11,2);
  loc_CtrlCot       NUMBER :=1;

  -- Objets
  loc_AFFIL_ANO         AFFIL_ANO%ROWTYPE;
  loc_INDIVIDU          INDIVIDU%ROWTYPE;
  loc_INDIVIDU_vide     INDIVIDU%ROWTYPE;
  loc_PORTE_REMISE      PORTE_REMISE%ROWTYPE;
  loc_PERS_HISTO_PHYS   PERS_HISTO_PHYS%ROWTYPE;
  loc_PERS_ADRESSE      PERS_ADRESSE%ROWTYPE;
  loc_CONTACT           CONTACT%ROWTYPE;

  loc_AFFIL_PORTE_ADH   AFFIL_PORTE_ADH%ROWTYPE;
  loc_AFFIL_RESIL       AFFIL_PORTE_ADH%ROWTYPE;
  loc_AFFIL_PORTE_AYD_sal   AFFIL_PORTE_AYD%ROWTYPE;
  loc_AFFIL_PORTE_FORCAGE AFFIL_PORTE_FORCAGE%ROWTYPE;
  loc_AFFIL_TRACE       AFFIL_TRACE%ROWTYPE;



  -- exception
  exc_technique            EXCEPTION;
  exc_societe              EXCEPTION;
  exc_participant          EXCEPTION;
  exc_indiv_inconnu_SI     EXCEPTION;
  exc_datnais_dif          EXCEPTION;
  exc_matorg_dif           EXCEPTION;

  exc_indiv_doublon        EXCEPTION;
  exc_nom_long             EXCEPTION;
  exc_prenom_long          EXCEPTION;
  exc_mail_long            EXCEPTION;
  exc_individu             EXCEPTION;
  exc_individu_bia         EXCEPTION;
  exc_histophys            EXCEPTION;
  exc_pers_adresse         EXCEPTION;
  exc_contact              EXCEPTION;
  /*exc_numgar               EXCEPTION;
  exc_numgar_doublons      EXCEPTION;
  exc_numgar_ko            EXCEPTION;*/
  exc_mvt_ko               EXCEPTION;
  exc_contrat_ouvert       EXCEPTION;
  exc_adhesion             EXCEPTION;
  exc_code_opt             EXCEPTION;
  exc_numfor               EXCEPTION;
  exc_affiliation          EXCEPTION;
  exc_resiliation          EXCEPTION;
  exc_suspension           EXCEPTION;
  exc_lieunaiss            EXCEPTION;
  exc_nomjf                EXCEPTION;
  exc_rib                  EXCEPTION;


  CURSOR c_affil_porte_adh2( P_numremise  NUMBER
                           , P_numporte   NUMBER
                           , P_numligne   NUMBER
                           , P_numindiv   NUMBER)
      IS
  SELECT apa.*
    FROM AFFIL_PORTE_ADH apa
   WHERE apa.NUMREMISE=P_numremise
     AND apa.NUMPORTE=P_numporte
     AND apa.NUMLIGNE=P_numligne
     AND P_numindiv IS NOT NULL
     AND apa.NUMAYD=0 -- uniquement les salariés
    -- AND apa.NUMGAR IS NOT NULL --uniquement les contrats identifiés
     ;
  --parcourt base + option liée par dépendance pour résiliation
  CURSOR c_adhesion_resil (P_numindiv   individu.NUMINDIV%TYPE, p_idadhesion adhe_cntrt.idadhesion%TYPE,p_numgar adhe_cntrt.numgar%TYPE , p_datefic DATE) IS
    SELECT ac.idadhesion, ac.numgar,2,c.TYPEQUIT
    FROM ADHE_CNTRT ac, contrat c
    WHERE ac.idadhesion=p_idadhesion
    AND c.numgar = ac.numgar
    UNION
    SELECT DISTINCT ac.idadhesion,  ac.numgar,1, c.TYPEQUIT
      FROM DEPENDANCE d,  CONTRAT c, ADHE_CNTRT ac
     WHERE d.numde = ac.NUMGAR --contrat option
       AND c.numgar=ac.numgar
       AND d.numenvers=p_numgar --contrat base
       AND ac.numadhe = P_numindiv
       AND ac.idadhesion <> p_idadhesion
       AND c.TYPEQUIT<>1 --echéancier sur adhésion indiv
       AND ac.date_fin_adhe IS NULL
       AND d.role = 2 --  A pour contrat de base
       AND p_datefic BETWEEN d.datapli AND NVL(d.datper,p_datefic)
       AND F_ETAT_ADHE(ac.idadhesion,SYSDATE)=1
      order by 3
     ;

BEGIN

  BEGIN
    cpt_ano            :=0;
    cpt_ano_tot        :=0;
    loc_warning        :=0;
    loc_warning1       :=0;
    loc_warning_adr    :=0;
    loc_warning_resil  :=0;
    loc_flag_newindiv  :=0;
    loc_ano_indiv      :=0;

    loc_log:=TO_CHAR(I_AFFIL_PORTE.NUMREMISE)|| '-' ||TO_CHAR(I_AFFIL_PORTE.NUMLIGNE);
    P_INS_journal(3 , loc_log||', début F_GestLigneAffil');

    ---------------------------------------------------------------------------------------------------------
    -- Initialisation de l'objet loc_AFFIL_ANO pour d eventuelles anomalies d integration fonctionnelle
    ---------------------------------------------------------------------------------------------------------
    PK_CTRL_AFFIL.P_INIT_AFFIL_ANO(I_AFFIL_PORTE,loc_AFFIL_ANO,loc_ano_techno);
    IF loc_ano_techno > 0 THEN
      RAISE exc_technique;
    END IF;
    COMMIT;

    I_AFFIL_PORTE.NUMCLI:= I_AFFIL_FICHIER.NUMCLI;
    P_INS_journal(3, loc_log||','||I_AFFIL_PORTE.NUMCLI||' SIREN: '||I_AFFIL_FICHIER.ENTREPRISE||', établissement: '||(I_AFFIL_FICHIER.ETABLI)|| ',Ano:'||I_ANO_SOCIETE);
    IF NVL(I_AFFIL_FICHIER.NUMCLI,0)= 0 THEN
      RAISE exc_societe;
    END IF;

    ---------------------------------------------------------------------------------
    -- ********************** RECHERCHE MOUVEMENT ***********************************
    ---------------------------------------------------------------------------------
    P_INS_journal(3, loc_log||',Date fichier:'||TO_CHAR(I_AFFIL_FICHIER.DATEFIC));
    IF I_AFFIL_PORTE.TYPE_MVT IS NULL THEN
      I_AFFIL_PORTE.TYPE_MVT:=PK_CTRL_AFFIL.F_FIND_MVT(I_AFFIL_PORTE,I_AFFIL_FICHIER,loc_ano_mvt);
      P_INS_journal(1, loc_log||',Type de mouvement:'||TO_CHAR(I_AFFIL_PORTE.TYPE_MVT)||' Anomalie :'||loc_ano_mvt);
      IF loc_ano_mvt > 0 THEN
        RAISE exc_mvt_ko;
      ELSIF  loc_ano_mvt = -1 THEN    -- Portage
        loc_warning1:=loc_warning1+1;
        loc_AFFIL_ANO.NUMANO:=111;
        loc_AFFIL_ANO.ETATANO :=7;
        PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
        loc_AFFIL_ANO.NUMANO:=NULL;
      END IF;
    END IF;



    ---------------------------------------------------------------------------------
    -- **********************RECHERCHE INDIVIDU *************************************
    ---------------------------------------------------------------------------------
    -- Identification/Création du salarié
    loc_AFFIL_ANO.NUMANO:=NULL;
    loc_INDIVIDU :=loc_INDIVIDU_vide;


    IF I_AFFIL_PORTE.NUMINDIV IS NULL THEN
      I_AFFIL_PORTE.NUMINDIV:=PK_CTRL_AFFIL.F_FIND_SALARIE(I_AFFIL_PORTE.NUMSSA
                                                        , I_AFFIL_PORTE.NOMSAL
                                                        , I_AFFIL_PORTE.PRENOM
                                                        , I_AFFIL_PORTE.NOMNAIS
                                                        , I_AFFIL_PORTE.DATNAI
                                                        , 1 -- rang à 1 pour le salarié principal
                                                        , loc_ano_indiv
                                                         );
    END IF;

    IF loc_ano_indiv IN (3) THEN       -- Inconnu du SI
      loc_AFFIL_ANO.NUMANO:=104; -- Assuré inconnu du SI
      RAISE exc_indiv_inconnu_SI;
    ELSIF loc_ano_indiv =  2 THEN   -- Doublon de salarié
      loc_AFFIL_ANO.NUMANO:=105;     -- Doublon de salarié
      RAISE exc_indiv_doublon;
    ELSIF loc_ano_indiv =  4 THEN   -- -- La date de naissance est différente entre le SI et le fichier
      loc_AFFIL_ANO.NUMANO:=78;-- La date de naissance est différente entre le SI et le fichier
      RAISE exc_datnais_dif;
    ELSIF loc_ano_indiv =  5 THEN
      RAISE exc_matorg_dif;
    END IF;

   P_INS_journal(2, loc_log||',***Salarié trouvé :'||I_AFFIL_PORTE.NUMINDIV);

   IF TRIM(SUBSTR(I_AFFIL_PORTE.NUMSSA,0,13)) IS NULL AND Tab_RG.EXISTS('MAT_VIDE') AND  I_AFFIL_PORTE.NUMINDIV IS NULL THEN

      loc_warning1:=loc_warning1+1;
      loc_AFFIL_ANO.NUMANO:=79;
      loc_AFFIL_ANO.ETATANO :=7;
      PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
      loc_AFFIL_ANO.NUMANO:=NULL;
      P_INS_journal(3 , loc_log||','|| Tab_RG('MAT_VIDE'));--,Enregistrement du matricule dans la référence externe de l'individu
   END IF;


    IF loc_ano_indiv = 4 AND I_AFFIL_PORTE.NUMINDIV IS NOT NULL AND Tab_RG.EXISTS('DATNAI_DIF') THEN
        --ne pas bloquer la continuité du process
        cpt_ano:=cpt_ano+1;
        loc_AFFIL_ANO.NUMANO:=78;-- La date de naissance est différente entre le SI et le fichier
        loc_AFFIL_ANO.ETATANO:=3;
        PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
        loc_AFFIL_ANO.NUMANO:=NULL;
    END IF;

    IF I_AFFIL_PORTE.NUMINDIV IS NOT NULL  THEN
      loc_nomjf:=NULL;
      loc_nom:=NULL;
      SELECT PK_CTRL_AFFIL.F_FORMAT(a.NOMJF),PK_CTRL_AFFIL.F_FORMAT(a.NOM)
        INTO loc_nomjf, loc_nom
        FROM INDIVIDU a
       WHERE a.NUMINDIV= I_AFFIL_PORTE.NUMINDIV;

      IF  SUBSTR(I_AFFIL_PORTE.NUMSSA,1,1)=2 AND I_AFFIL_PORTE.NOMNAIS IS NOT NULL AND I_AFFIL_PORTE.NOMNAIS <> I_AFFIL_PORTE.NOMSAL  THEN
        --nom de jeune fille non alimenté, on l'alimente toujours
        --nom de jeune fille alimenté en BDD et différént et RG non existante alors on écrase
        IF loc_nomjf IS NULL
          OR  (loc_nomjf <> PK_CTRL_AFFIL.F_FORMAT(I_AFFIL_PORTE.NOMNAIS) AND NOT Tab_RG.EXISTS('NOMJF_DIF'))
        THEN
          PK_CTRL_AFFIL.P_MAJ_INDIVIDU_NOMJF(I_AFFIL_PORTE.NUMINDIV,PK_CTRL_AFFIL.F_FORMAT(I_AFFIL_PORTE.NOMNAIS),loc_ano_nomjf);
          IF loc_ano_nomjf>0 THEN
              RAISE exc_nomjf;
          ELSE
             -- Insertion dans AFFIL_TRACE
            loc_AFFIL_TRACE.ETENDUE:=4;--INDIVIDU
            loc_AFFIL_TRACE.CLEF:=I_AFFIL_PORTE.NUMINDIV;
            loc_AFFIL_TRACE.CLEF2:=I_AFFIL_PORTE.NOMNAIS;
            loc_AFFIL_TRACE.ACTION:='U';--mise a jour
            loc_AFFIL_TRACE.NUMREMISE:=I_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
            loc_AFFIL_TRACE.NUMLIGNE:=I_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
            loc_AFFIL_TRACE.NUMPORTE:=I_AFFIL_PORTE.NUMPORTE;
            loc_AFFIL_TRACE.OBJET:='INDIVIDU';--Table impactée
            loc_AFFIL_TRACE.COLONNE:='NOMJF';--Colonne impactée
            IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE)=FALSE THEN
              RAISE exc_nomjf;
            END IF;
          END IF;
        --nom de jeune fille différent, anomalie remontée uniquement si RG présente
        ELSIF loc_nomjf <> PK_CTRL_AFFIL.F_FORMAT(I_AFFIL_PORTE.NOMNAIS) AND Tab_RG.EXISTS('NOMJF_DIF') THEN
           --ne pas bloquer la continuité du process
            loc_warning1:=loc_warning1+1;
            loc_AFFIL_ANO.NUMANO:=97;-- Le nom de jeune fille est différente entre le SI et le fichier
            loc_AFFIL_ANO.ETATANO:=7;
            PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
            loc_AFFIL_ANO.NUMANO:=NULL;
        END IF;
      END IF;

      IF loc_nom <> PK_CTRL_AFFIL.F_FORMAT(I_AFFIL_PORTE.NOMSAL) THEN
          --ABO 24/02/2017 modification du blocage en averstissement

          loc_warning1:=loc_warning1+1;
          loc_AFFIL_ANO.NUMANO:=101;-- Le nom d'usage est différent de celui d'Arthus
          loc_AFFIL_ANO.ETATANO:=7;
          PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
          loc_AFFIL_ANO.NUMANO:=NULL;
      END IF;
    END IF;--I_AFFIL_PORTE.NUMINDIV IS NOT NULL

    IF I_AFFIL_PORTE.NUMINDIV IS NOT NULL AND Tab_RG.EXISTS('LNAI_DIF') AND I_AFFIL_PORTE.LIEUNAIS IS NOT NULL THEN
      SELECT LIEUNAIS
        INTO loc_lieunais
        FROM INDIVIDU a
       WHERE a.NUMINDIV= I_AFFIL_PORTE.NUMINDIV;

      -- Mise à jour du lieu de naissance si celui du SI est vide
      IF loc_lieunais IS NULL THEN
        PK_CTRL_AFFIL.P_MAJ_INDIVIDU_LIEUNAIS(I_AFFIL_PORTE.NUMINDIV,PK_CTRL_AFFIL.F_FORMAT(I_AFFIL_PORTE.LIEUNAIS),loc_ano_lieunaiss);
        IF loc_ano_lieunaiss>0 THEN
          RAISE exc_lieunaiss;
        ELSE
           -- Insertion dans AFFIL_TRACE
          loc_AFFIL_TRACE.ETENDUE:=4;--INDIVIDU
          loc_AFFIL_TRACE.CLEF:=I_AFFIL_PORTE.NUMINDIV;
          loc_AFFIL_TRACE.CLEF2:=I_AFFIL_PORTE.LIEUNAIS;--pourquoi c'était en commentaire ???
          loc_AFFIL_TRACE.ACTION:='U';--mise a jour
          loc_AFFIL_TRACE.NUMREMISE:=I_AFFIL_PORTE.NUMREMISE;--remise de l affiliation
          loc_AFFIL_TRACE.NUMLIGNE:=I_AFFIL_PORTE.NUMLIGNE;--ligne de l affiliation
          loc_AFFIL_TRACE.NUMPORTE:=I_AFFIL_PORTE.NUMPORTE;
          loc_AFFIL_TRACE.OBJET:='INDIVIDU';--Table impactée
          loc_AFFIL_TRACE.COLONNE:='LIEUNAIS';--Colonne impactée
          IF PK_CTRL_AFFIL.F_INSERT_AFFIL_TRACE(loc_AFFIL_TRACE)=FALSE THEN
            RAISE exc_lieunaiss;
          END IF;
        END IF;
      ELSIF  PK_CTRL_AFFIL.F_FORMAT(loc_lieunais) <>  PK_CTRL_AFFIL.F_FORMAT(I_AFFIL_PORTE.LIEUNAIS) THEN
        --ne pas bloquer la continuité du process
        loc_warning1:=loc_warning1+1;
        loc_AFFIL_ANO.NUMANO:=98;-- La lieu de naissance est différente entre le SI et le fichier
        loc_AFFIL_ANO.ETATANO:=7;
        PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
        loc_AFFIL_ANO.NUMANO:=NULL;
      END IF;
    END IF;--Tab_RG.EXISTS('LNAI_DIF')

    IF I_AFFIL_PORTE.NUMINDIV IS NOT NULL THEN
      -- Recheche du n°SS à partir du NUMIDIV
      I_AFFIL_PORTE.MATORGINDIV:=PK_CTRL_AFFIL.F_FIND_MATORG(I_AFFIL_PORTE.NUMINDIV);
      IF I_AFFIL_PORTE.MATORGINDIV IS NULL AND Tab_RG.EXISTS('NSS_VIDE') THEN
           loc_warning1:=loc_warning1+1;
           loc_AFFIL_ANO.NUMANO:=80;
           loc_AFFIL_ANO.ETATANO :=7;
           PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
           loc_AFFIL_ANO.NUMANO:=NULL;
           P_INS_journal(3 , loc_log||','|| Tab_RG('NSS_VIDE'));
      END IF;

    ELSIF I_AFFIL_PORTE.NUMINDIV IS  NULL AND loc_ano_indiv=1 AND Tab_RG.EXISTS('INS_SAL') THEN

      ---------------------------------------------------------------------------------
      -- **********************CREATION INDIVIDU **************************************
      ---------------------------------------------------------------------------------
      IF (PK_CTRL_AFFIL.F_VERIF_COLONNE('INDIVIDU','NOM') < LENGTH(I_AFFIL_PORTE.NOMSAL)) AND  Tab_RG.EXISTS('LONG_NOM') THEN
        P_INS_journal(3 , loc_log||','|| Tab_RG('LONG_NOM'));
        RAISE exc_nom_long;
      END IF;

      IF (PK_CTRL_AFFIL.F_VERIF_COLONNE('INDIVIDU','PRENOM') < LENGTH(I_AFFIL_PORTE.PRENOM)) AND  Tab_RG.EXISTS('LONG_NOM') THEN
        P_INS_journal(3 , loc_log||','|| Tab_RG('LONG_NOM'));
        RAISE exc_prenom_long;
      END IF;
      --on récupère AYD salarié pour les mises à jour
      BEGIN
        SELECT * INTO loc_AFFIL_PORTE_AYD_sal
        FROM AFFIL_PORTE_AYD
        WHERE numremise = I_AFFIL_PORTE.NUMREMISE
        AND numporte= I_AFFIL_PORTE.NUMPORTE
        AND numligne =I_AFFIL_PORTE.NUMLIGNE
        AND numayd = 0;
      EXCEPTION
        WHEN OTHERS THEN loc_AFFIL_PORTE_AYD_sal:=NULL;
      END;

      PK_CTRL_AFFIL.P_GestionIndividu( I_AFFIL_PORTE
                                     , loc_AFFIL_PORTE_AYD_sal
                                     , loc_INDIVIDU
                                     , loc_ano_indiv);

      IF loc_ano_indiv>0 THEN
        RAISE exc_individu;
      ELSIF loc_INDIVIDU.NUMINDIV IS NULL THEN
        RAISE exc_individu_bia;
      END IF;

      I_AFFIL_PORTE.NUMINDIV:=loc_INDIVIDU.NUMINDIV; --affectation du nouveau salarié
      loc_flag_newindiv:=1; -- Flag pour la suite, pour la gestion d une absence ou résiliation
      IF TRIM(I_AFFIL_PORTE.NUMSSA) <>  TRIM(loc_INDIVIDU.MATORG) AND Tab_RG.EXISTS('NSS_DIFF') THEN
        loc_warning1:=loc_warning1+1;
        loc_AFFIL_ANO.NUMANO:=80;
        loc_AFFIL_ANO.ETATANO :=7;
        PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
        loc_AFFIL_ANO.NUMANO:=NULL;
        P_INS_journal(3 , loc_log||','|| Tab_RG('NSS_DIFF'));
      END IF;

      I_AFFIL_PORTE.MATORGINDIV:=loc_INDIVIDU.MATORG;

      IF Tab_RG.EXISTS('MAT_INS') THEN
        loc_INDIVIDU.REFCIE:=TO_CHAR(I_AFFIL_PORTE.MATRIC);
        loc_AFFIL_ANO.NUMANO:=82;
        P_INS_journal(3 , loc_log||','|| Tab_RG('MAT_INS'));
      ELSE
        loc_INDIVIDU.REFCIE:=NULL;
      END IF;

    END IF; --ano + création salarié

    P_INS_journal(3, loc_log||', **** FIN salarié :'||loc_INDIVIDU.NUMINDIV||' ,Anomalie:'||loc_ano_indiv);

    IF I_AFFIL_PORTE.NUMINDIV IS NOT NULL THEN

      ---------------------------------------------------------------------------------
      -- **********************CREATION PERS_HISTO_PHYS *******************************
      ---------------------------------------------------------------------------------
      IF Tab_RG.EXISTS('INS_CARSAL') AND
        (I_AFFIL_PORTE.SITFAM  IS NOT NULL OR I_AFFIL_PORTE.CADRNC IS NOT NULL OR I_AFFIL_PORTE.CATEGP IS NOT NULL ) THEN
        P_INS_journal(3 , loc_log||','|| Tab_RG('INS_CARSAL'));
        PK_CTRL_AFFIL.P_Gestion_Pers_histo_phys( I_AFFIL_PORTE
                                               , I_AFFIL_FICHIER
                                               , NULL
                                               , NULL
                                               , loc_PERS_HISTO_PHYS
                                               , loc_ano_histophys);
        P_INS_journal(3, loc_log||',Controle de Pers_histo_phys loc_ano_histophys:'||loc_ano_histophys);
        IF loc_ano_histophys>0 THEN
          RAISE exc_histophys;
        END IF;
      END IF;


        ---------------------------------------------------------------------------------
      -- ********************** PERS_ADRESSE ******************************************
      ---------------------------------------------------------------------------------
      IF I_AFFIL_FICHIER.NATURE NOT IN (2,4,5) THEN        -- on ne fait pas ce test pour des fichiers de signalements
        IF TRIM(I_AFFIL_PORTE.ADREVOIE) IS NULL AND TRIM(I_AFFIL_PORTE.COMPLAD) IS NULL THEN
          cpt_ano:=cpt_ano+1;
          loc_affil_ano.etatano:=3;
          loc_affil_ano.numano:=117;            -- Aucun nom de voie pour l adresse
          PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_affil_ano);
          loc_affil_ano.numano:=NULL;
        END IF;
      END IF;
      IF TRIM(I_AFFIL_PORTE.ADREVOIE) IS NULL AND TRIM(I_AFFIL_PORTE.COMPLAD) IS NOT NULL THEN
        I_AFFIL_PORTE.ADREVOIE:=I_AFFIL_PORTE.COMPLAD;
        loc_warning1:=loc_warning1+1;
        I_AFFIL_PORTE.COMPLAD:=NULL;
        loc_affil_ano.etatano:=7;
        loc_affil_ano.numano:=116;           -- Adresse principal vide, maj par le complément
        PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_affil_ano);
        loc_affil_ano.numano:=NULL;
        -- enregistrement du forçage de la zone COMPLAD
        loc_AFFIL_PORTE_FORCAGE.numremise := I_AFFIL_PORTE.NUMREMISE;
        loc_AFFIL_PORTE_FORCAGE.numligne  := I_AFFIL_PORTE.NUMLIGNE;
        loc_AFFIL_PORTE_FORCAGE.entite := 'AFFIL_PORTE';
        loc_AFFIL_PORTE_FORCAGE.donnee := 'ADREVOIE';
        loc_AFFIL_PORTE_FORCAGE.numzone :=0;
        loc_AFFIL_PORTE_FORCAGE.valeur := NULL;
        loc_AFFIL_PORTE_FORCAGE.numutil := g_numutil;
        IF PK_CTRL_AFFIL.F_INS_AFFIL_PORTE_FORCAGE(loc_AFFIL_PORTE_FORCAGE) THEN
          NULL;
        END IF;
      END IF;

      IF I_AFFIL_PORTE.ADREVOIE IS NOT NULL THEN
        IF Tab_RG.EXISTS('AD_FR') THEN -- Création d''adresse uniquement française, avertissement sinon
          IF TRIM(I_AFFIL_PORTE.PAYS) <> 'FR' AND TRIM(I_AFFIL_PORTE.PAYS) IS NOT NULL THEN
            loc_warning1:=loc_warning1+1;
            loc_AFFIL_ANO.NUMANO:=83;
            loc_AFFIL_ANO.ETATANO :=7;
            loc_warning_adr:=1;    -- Flag pour ne pas créer l adresse
            PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
            loc_AFFIL_ANO.NUMANO:=NULL;
            P_INS_journal(3 , loc_log||','|| Tab_RG('AD_FR'));
          ELSIF TRIM(I_AFFIL_PORTE.PAYS) IS NULL THEN
            P_INS_journal(3, loc_log||',WARNING Code pays vide');
            loc_AFFIL_ANO.NUMANO:=NULL;
            I_AFFIL_PORTE.PAYS:='FR'; -- on affecte FR à l'adresse par défaut, si le code pays n est pas renseigné
          END IF;
        END IF;
        IF Tab_RG.EXISTS('INS_ADR') AND loc_warning_adr=0 THEN
          P_INS_journal(3 , loc_log||','|| Tab_RG('INS_ADR'));
          loc_lib_warning:=NULL;
          loc_ano_adr:=0;

          PK_CTRL_AFFIL.P_Gestion_Pers_adresse( I_AFFIL_PORTE
                                              , loc_PERS_ADRESSE
                                              , I_AFFIL_FICHIER.datefic
                                              , Tab_RG.EXISTS('ADR_DIFF')
                                              , loc_lib_warning
                                              , loc_ano_adr);
          P_INS_journal(3, loc_log||',Controle de Pers_adresse loc_ano_adr :'||loc_ano_adr||'-'||loc_lib_warning);
          IF loc_ano_adr>0 THEN
            RAISE exc_pers_adresse;
          ELSIF TRIM(loc_lib_warning) IS NOT NULL THEN
            loc_warning1:=loc_warning1+1;
            P_INS_journal(3 , loc_log||','|| Tab_RG('ADR_DIFF'));
            loc_AFFIL_ANO.NUMANO:=84;
            loc_AFFIL_ANO.ETATANO :=7;
            PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
            loc_AFFIL_ANO.NUMANO:=NULL;
          END IF;
        END IF;
      END IF;

      ---------------------------------------------------------------------------------
      -- ********************** CONTACT ***********************************************
      ---------------------------------------------------------------------------------
      IF I_AFFIL_PORTE.MAIL IS NOT NULL THEN
        IF (PK_CTRL_AFFIL.F_VERIF_COLONNE('CONTACT','COORDONNEE') < LENGTH(I_AFFIL_PORTE.MAIL)) AND  Tab_RG.EXISTS('LONG_MAIL') THEN
          P_INS_journal(3 , loc_log||','|| Tab_RG('LONG_MAIL'));
          RAISE exc_mail_long;
        END IF;
        IF Tab_RG.EXISTS('INS_MAIL')   THEN    --LONG_MAIL
          P_INS_journal(3 , loc_log||','|| Tab_RG('INS_MAIL'));
          loc_CONTACT.NUMINDIV:=I_AFFIL_PORTE.NUMINDIV;
          loc_CONTACT.NATURE:=4;   -- Email
          loc_CONTACT.TYPE:=2;     -- Personnel
          loc_CONTACT.COORDONNEE:=LOWER(TRIM(I_AFFIL_PORTE.MAIL));
          loc_CONTACT.FLAG:='O';
          loc_CONTACT.CREATION:=SYSDATE;
          loc_CONTACT.NUMUTIL:=g_numutil; -- I_AFFIL_PORTE.USERNAME_FORCAGE;

          PK_CTRL_AFFIL.P_Gestion_Contact( I_AFFIL_PORTE
                                         , loc_CONTACT
                                         , loc_ano_ctc);
          P_INS_journal(3, loc_log||',Controle du contact loc_ano_ctc :'||loc_ano_ctc);
          IF loc_ano_ctc>0 THEN
            RAISE exc_contact;
          END IF;
        END IF;
      END IF;


      ---------------------------------------------------------------------------------
      -- ********************** RIB ***************************************************
      ---------------------------------------------------------------------------------
      PK_CTRL_AFFIL.P_GEST_RIB(I_AFFIL_PORTE, loc_log, loc_ano_rib);
      IF  loc_ano_rib in(1,2) THEN
        RAISE exc_rib;
      END IF;

    END IF; -- IF loc_INDIVIDU.NUMINDIV is not null THEN

    ---------------------------------------------------------------------------------
    -- ********************** GESTION DES AYANTS DROITS******************************
    ---------------------------------------------------------------------------------
    P_GestAYD( I_AFFIL_PORTE
             , loc_log
             , loc_ano_ayd);
    IF loc_ano_ayd>0 THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=loc_ano_ayd;
      loc_AFFIL_ANO.ETATANO:=3;
      PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
      loc_AFFIL_ANO.NUMANO:=NULL;
    END IF;
    -- apres on gére les adh pour les membres et couvertures

    loc_cpt_cntrt:=0;

    ---------------------------------------------------------------------------------
    -- ********************** ADHESION **********************************************
    ---------------------------------------------------------------------------------

    -- Boucle sur les contrats identifiés du salarié identifié, on parcours néanmoins toutes les adhésions
    FOR  rec_affil_porte_adh2         IN c_affil_porte_adh2( I_AFFIL_PORTE.NUMREMISE
                                                           , I_AFFIL_PORTE.NUMPORTE
                                                           , I_AFFIL_PORTE.NUMLIGNE
                                                           , I_AFFIL_PORTE.NUMINDIV)     LOOP

      loc_cpt_cntrt := loc_cpt_cntrt+1; --compteur du nombre d'adhesion contrat du salarié (identifié ou non)

      IF rec_affil_porte_adh2.NUMGAR IS NULL  THEN
       cpt_ano:=cpt_ano+1;

      ELSE
        IF rec_affil_porte_adh2.REFGARANTIE IS NULL THEN
          cpt_ano:=cpt_ano+1;-- la non identification de la garantie ne doit pas bloquer la suite du traitement contrairement au contrat
        END IF;

        BEGIN
        ---------------------------------------------------------------------------------
        -- ********************** GESTION AFFILIATIONS *********************************
        ---------------------------------------------------------------------------------
        -- ********************** GESTION RADIATIONS ***********************************
        ---------------------------------------------------------------------------------

        -- Recherche de l adhesion sauf pour une nouvelle affiliation
        loc_ano_adhesion:=0;
        loc_AFFIL_PORTE_ADH:=rec_affil_porte_adh2;
        loc_AFFIL_PORTE_ADH.NUMINDIV  := I_AFFIL_PORTE.NUMINDIV;
        PK_CTRL_AFFIL.P_MAJ_AFFIL_PRT_ADH_INDIV(loc_AFFIL_PORTE_ADH);
        PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_AYD(loc_AFFIL_PORTE_ADH);


          --ABO 29/09 en cas de multiple code option pour une adhésion, la 1ère ligne adh permet de créer l'adhe_cntrt, la 2ème ligne doit donc identifié l'idadhesion créée en BD
          IF loc_AFFIL_PORTE_ADH.IDADHESION  IS NULL THEN
            loc_AFFIL_PORTE_ADH.IDADHESION:=PK_CTRL_AFFIL.F_FIND_ADHESION(loc_AFFIL_PORTE_ADH , I_AFFIL_PORTE, I_AFFIL_FICHIER, loc_ano_adhesion);
            PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_ADH(loc_AFFIL_PORTE_ADH);
            P_INS_journal(3, loc_log||',Recherche Adhesion, numgar:'||loc_AFFIL_PORTE_ADH.NUMGAR||' anomalie:'||loc_ano_adhesion);
            P_INS_journal(3, loc_log||',Recherche IDADHESION:'||loc_AFFIL_PORTE_ADH.IDADHESION);
          END IF;

          IF NVL(I_AFFIL_PORTE.TYPE_MVT,0) NOT IN (1,7)   THEN
            P_INS_journal(2, loc_log||',Adhesion trouvée:'||loc_AFFIL_PORTE_ADH.IDADHESION ||' pour le contrat :'||loc_AFFIL_PORTE_ADH.numgar);
            P_INS_journal(3, loc_log||',Contrat prévoyance / santé:'||I_TAB_CNTRT(loc_AFFIL_PORTE_ADH.numgar).prev);
            IF  Tab_RG.EXISTS('AFFIL_PREV') AND NVL(loc_AFFIL_PORTE_ADH.IDADHESION,0) =0 AND I_TAB_CNTRT(loc_AFFIL_PORTE_ADH.numgar).prev >0 THEN
              loc_ano_adhesion :=0;
            ELSIF NVL(loc_AFFIL_PORTE_ADH.IDADHESION,0)=0 THEN
              RAISE exc_adhesion;--attention codano  =0
            END IF;
          END IF;

          -- recherche d un contrat prévoyance/santé dejà ouvert ==> donc blocage
          loc_numgarOuvert:= PK_CTRL_AFFIL.F_FIND_NUMGAR_OUVERT(I_AFFIL_PORTE.NUMINDIV,
                                                                I_AFFIL_PORTE.TYPE_MVT ,
                                                                I_AFFIL_FICHIER.NUMCLI,
                                                                rec_affil_porte_adh2.NUMGAR,
                                                                e2d(I_AFFIL_PORTE.debutc),
                                                                rec_affil_porte_adh2.REFGARANTIE);
          -- mnemo AFFILANO
          IF    loc_numgarOuvert = 109
             OR loc_numgarOuvert = 126 THEN
            RAISE exc_contrat_ouvert;
          END IF;

      ---------------------------------------------------------------------------------
      -- ********************** GARANTIE **********************************************
      ---------------------------------------------------------------------------------
          -- Recherche couverture par la garantie préccédemment identifiée => attention on peut avoir plusieurs garanties pour un même code option
          -- Recherche nécessite le n° adhesion, quand adh prev est bloquée alors on ne recherche pas la couverture
          IF loc_AFFIL_PORTE_ADH.REFGARANTIE IS NOT NULL AND loc_AFFIL_PORTE_ADH.IDADHESION IS NOT NULL THEN
              loc_ano_numfor:=PK_CTRL_AFFIL.F_COUVERT_GAR(loc_AFFIL_PORTE_ADH,I_AFFIL_PORTE,I_AFFIL_FICHIER);

              IF loc_ano_numfor >0 THEN
                P_INS_journal(3, loc_log||',Anomalie de couverture adhesion :'||loc_AFFIL_PORTE_ADH.idadhesion||' ano :'||TO_CHAR(loc_ano_numfor));
                loc_warning1:=loc_warning1+1;
                loc_AFFIL_ANO.NUMANO:=loc_ano_numfor;
                loc_AFFIL_ANO.ETATANO :=7;
                PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
                loc_AFFIL_ANO.NUMANO:=NULL;
              END IF;
          END IF;

        ---------------------------------------------------------------------------------
        -- ********************** GESTION DES MOUVEMENTS *********************************
        ---------------------------------------------------------------------------------
          IF I_AFFIL_PORTE.TYPE_MVT IN( 1,7) THEN
            ---------------------------------------------------------------------------------
            -- ********************** NOUVELLE AFFILIATION **********************************
            ---------------------------------------------------------------------------------
            P_INS_journal(3, loc_log||', Nouvelle affiliation');
            loc_warning:=0;
            loc_ano_affil:=0;
            IF Tab_RG.EXISTS('INS_AFFIL') THEN
              --montant des cotisations
              SELECT SUM(mt_base) INTO loc_mt_cot
              FROM AFFIL_PORTE_QTTC_INDIV
              WHERE numremise = loc_AFFIL_PORTE_ADH.numremise
              AND numligne    = loc_AFFIL_PORTE_ADH.numligne
              AND numporte = loc_AFFIL_PORTE_ADH.numporte;

              IF Tab_RG.EXISTS('INS_AFFILC') AND loc_mt_cot=0  THEN
                loc_ano_affil := -15;
              ELSE
                IF NVL(loc_AFFIL_PORTE_ADH.IDADHESION,0) = 0 THEN
                  PK_CTRL_AFFIL.P_GestionAffiliation(I_AFFIL_PORTE, loc_AFFIL_PORTE_ADH,loc_ano_affil);
                  PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_ADH(loc_AFFIL_PORTE_ADH);

                  --------------------------------------------------------------------------------
                  -- ********************** MEMBRES AYANTS DROITS **********************************
                  ---------------------------------------------------------------------------------
                  P_INS_journal(2, loc_log||',MEMBRES AYANTS DROITS IDADHESION:'||loc_AFFIL_PORTE_ADH.IDADHESION ||' NUMINDIV:'||loc_AFFIL_PORTE_ADH.NUMINDIV);
                  PK_CTRL_AFFIL.P_INS_ADHE_CNTRT_MEMBRE(loc_AFFIL_PORTE_ADH,loc_ano_affil);

                END IF;

                --------------------------------------------------------------------------------
                -- ********************** COUVERTURES    **********************************
                ---------------------------------------------------------------------------------
                IF loc_AFFIL_PORTE_ADH.REFGARANTIE IS NOT NULL THEN
                  PK_CTRL_AFFIL.P_INS_COUVERTURES(loc_AFFIL_PORTE_ADH,I_AFFIL_PORTE.USERNAME_FORCAGE,e2d(I_AFFIL_PORTE.debutc),e2d(I_AFFIL_PORTE.fincon),loc_ano_affil);
                END IF;
              END IF;
                IF loc_ano_affil < 0 THEN
                  CASE loc_ano_affil
                    WHEN -4  THEN loc_AFFIL_ANO.NUMANO:=18;   -- Insertion adhésion impossible
                    WHEN -6  THEN loc_AFFIL_ANO.NUMANO:=20;   -- Insertion de l histo adhésion impossible
                    WHEN -9  THEN loc_AFFIL_ANO.NUMANO:=23;   -- Insertion de l adhe membre impossible
                    WHEN -12 THEN loc_AFFIL_ANO.NUMANO:=26;   -- Insertion des couvertures impossible
                    WHEN -14 THEN loc_AFFIL_ANO.NUMANO:=28;   -- Gestion de l adhésion impossible
                    WHEN -15 THEN loc_AFFIL_ANO.NUMANO:=107;   -- affiliation impossible, cotisation nulle
                    ELSE NULL;
                  END CASE;
                  RAISE exc_affiliation;
                END IF;--loc_ano_affil
              END IF;
              -------------------------- NOTION DE CONTRAT DEJA CLOTURE pour une nouvelle affiliation
              -- Recherche de la date de fin du contrat pour résilier l'adhésion a cette date
              BEGIN
                SELECT LEAST (D2E(pk_histo_contrat.f_sel_date_resil(loc_AFFIL_PORTE_ADH.numgar)),I_AFFIL_PORTE.FINCON)
                INTO I_AFFIL_PORTE.FINCON
                FROM DUAL
                WHERE PK_HISTO_CONTRAT.F_SEL_ETAT(loc_AFFIL_PORTE_ADH.numgar) = 3;
              --taguer le forçage ???
              EXCEPTION
                WHEN OTHERS THEN NULL;
              END;

              IF I_AFFIL_PORTE.FINCON IS NOT NULL AND  Tab_RG.EXISTS('INS_RES') AND NVL(loc_AFFIL_PORTE_ADH.IDADHESION,0) <> 0 THEN-- mouvement 1 sur contrat radié et 7
                -- Avertissement
                  loc_warning1:=loc_warning1+1;
                  IF PK_HISTO_CONTRAT.F_SEL_MOTIF(loc_AFFIL_PORTE_ADH.NUMGAR) = '42' THEN
                    loc_AFFIL_ANO.NUMANO:=110;    -- Affiliation sur un contrat transféré
                  END IF;
                  PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
                  loc_AFFIL_ANO.NUMANO:=NULL;
              END IF;


          ELSIF I_AFFIL_PORTE.TYPE_MVT IN( 2,9) THEN
            ---------------------------------------------------------------------------------
            -- ********************** CONTINUITÉ AFFILIATION ********************************
            ---------------------------------------------------------------------------------
            P_INS_journal(3, loc_log||', Continuité d’affiliation');
            loc_warning:=0;
            IF (Tab_RG.EXISTS('DATECNTR1') AND loc_ano_adhesion=67) THEN
              P_INS_journal(3 , loc_log||','|| Tab_RG('DATECNTR1'));  -- Date d entrée postèrieure à l''affiliation
              loc_warning1:=loc_warning1+1;
              loc_AFFIL_ANO.NUMANO:=85;-- Début d''affil. antérieur à la date d''adh.
              loc_AFFIL_ANO.ETATANO :=7;
              PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
              loc_AFFIL_ANO.NUMANO:=NULL;
            ELSE
              P_INS_journal(3, loc_log||',OK,  Date d entrée du salarié postèrieure à l''affiliation');
            END IF;

          ELSIF I_AFFIL_PORTE.TYPE_MVT IN( 3) THEN
            ---------------------------------------------------------------------------------
            -- ********************** NOUVELLE SUSPENSION ***********************************
            ---------------------------------------------------------------------------------
            P_INS_journal(3, loc_log||', Suspension');
            loc_warning_resil:=0;
            loc_ano_susp:=0;
            loc_warning_opt:=0;
            IF Tab_RG.EXISTS('INS_SUS') THEN    --INS_SUS
              P_INS_journal(3 , loc_log||','|| Tab_RG('INS_SUS'));
              IF Tab_RG.EXISTS('CTRLRESCOT') THEN
                loc_CtrlCot:=0;
              ELSE
                loc_CtrlCot:=1;
              END IF;
              PK_CTRL_AFFIL.P_GestionRadiation( I_AFFIL_PORTE
                                              , loc_AFFIL_PORTE_ADH
                                              , 2
                                              , loc_flag_newindiv
                                              , loc_CtrlCot
                                              , loc_ano_susp
                                              , loc_warning_resil);
              IF NVL(loc_warning_resil,0) <>0 THEN
                loc_warning1:=loc_warning1+1;
                loc_AFFIL_ANO.NUMANO:=loc_warning_resil;--124
                loc_AFFIL_ANO.ETATANO :=7;
                PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
                loc_AFFIL_ANO.NUMANO:=NULL;
              END IF;

              IF loc_ano_susp > 0 THEN
                RAISE exc_suspension;
              END IF;

              IF I_TAB_CNTRT(loc_AFFIL_PORTE_ADH.numgar).prev =0 THEN
                loc_warning_opt:=PK_CTRL_AFFIL.F_CTRL_MEMBRE_HORS_ADHESION(loc_AFFIL_PORTE_ADH.idadhesion
                                                                              , I_AFFIL_PORTE.NUMINDIV
                                                                              , I_AFFIL_PORTE.NUMGAR);
                IF NVL(loc_warning_opt,0) > 1 THEN
                  loc_warning1:=loc_warning1+1;
                  loc_AFFIL_ANO.NUMANO:=48;       -- Un membre a une adhésion sur un autre contrat
                  loc_AFFIL_ANO.ETATANO :=7;
                  PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
                  loc_AFFIL_ANO.NUMANO:=NULL;
                END IF;
              END IF;


            END IF;
          ELSIF I_AFFIL_PORTE.TYPE_MVT IN(4) THEN
              P_INS_journal(3, loc_log||', Continuité de suspension');

          ELSIF I_AFFIL_PORTE.TYPE_MVT IN( 6) THEN
              P_INS_journal(3, loc_log||', Continuité de radiation');
              ---------------------------------------------------------------------------------
              -- ********************** CONTINUITÉ RADIATION ***********************************
              ---------------------------------------------------------------------------------
        END IF;

         ---------------------------------------------------------------------------------
         -- ********************** NOUVELLE RADIATION ou affiliation sur contrat résilié**
         ---------------------------------------------------------------------------------
        IF I_AFFIL_PORTE.TYPE_MVT IN( 5,7) OR  (I_AFFIL_PORTE.TYPE_MVT=1 AND I_AFFIL_PORTE.FINCON IS NOT NULL) THEN
         -- P_INS_journal(3, loc_log||', Radiation');
          IF Tab_RG.EXISTS('INS_RES') AND NVL(loc_AFFIL_PORTE_ADH.IDADHESION,0) <> 0 THEN
              --P_INS_journal(3 , loc_log||','|| Tab_RG('INS_RES'));
              P_INS_journal(3, loc_log||', *****Parcours avec adhesion de base '||loc_AFFIL_PORTE_ADH.idadhesion);
              -------------------------- --parcourt base + options liées par dépendance pour résiliation dont le salarié est adhérent
              FOR rec_adhesion_resil  IN c_adhesion_resil (I_AFFIL_PORTE.NUMINDIV,loc_AFFIL_PORTE_ADH.idadhesion,loc_AFFIL_PORTE_ADH.numgar, I_AFFIL_FICHIER.DATEFIC) LOOP
                BEGIN
                loc_warning_resil:=0;
                loc_ano_resil:=0;
                loc_warning_opt:=0;
                loc_AFFIL_RESIL.numgar :=rec_adhesion_resil.numgar;
                loc_AFFIL_RESIL.idadhesion :=rec_adhesion_resil.idadhesion;
                P_INS_journal(2 , loc_log||', Radiation adhesion :'|| loc_AFFIL_RESIL.idadhesion);
                IF  Tab_RG.EXISTS('CTRLRESCOT') THEN
                  loc_CtrlCot:=0;
                ELSE  loc_CtrlCot:=1;
                END IF;
                PK_CTRL_AFFIL.P_GestionRadiation( I_AFFIL_PORTE
                                                , loc_AFFIL_RESIL
                                                , 3
                                                , loc_flag_newindiv
                                                , loc_CtrlCot
                                                , loc_ano_resil
                                                , loc_warning_resil
                                               );
                IF NVL(loc_warning_resil,0) <>0  AND loc_CtrlCot =1 THEN
                  loc_warning1:=loc_warning1+1;
                  loc_AFFIL_ANO.NUMANO:=loc_warning_resil;--122
                  loc_AFFIL_ANO.ETATANO :=7;
                  PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
                  loc_AFFIL_ANO.NUMANO:=NULL;
                END IF;

                IF loc_ano_resil > 0 THEN
                  RAISE exc_resiliation;
                END IF;
                /********* AUTRE ADHESION*****/
                -- Fonction identifiant une adhésion individuelle en cours hors un contrat donné couvrant un bénéficiaire donné.
                -- Un warning est detecté si un membre de ce groupe est identifié sur une autre adhésion en cours
                -- on appele ce contrôle uniquement sur les adhésion de base collective sante
                IF rec_adhesion_resil.typequit=1 AND I_TAB_CNTRT(loc_AFFIL_PORTE_ADH.numgar).prev =0 THEN
                  P_INS_journal(2 , loc_log||', Contrôle hors membre adhesion :'|| loc_AFFIL_RESIL.idadhesion);
                  loc_warning_opt:=PK_CTRL_AFFIL.F_CTRL_MEMBRE_HORS_ADHESION(loc_AFFIL_RESIL.idadhesion
                                                                             , I_AFFIL_PORTE.NUMINDIV
                                                                             , loc_AFFIL_RESIL.NUMGAR);


                  IF NVL(loc_warning_opt,0) > 0 THEN
                    loc_warning1:=loc_warning1+1;
                    loc_AFFIL_ANO.NUMANO:=48;    -- Un membre a une adhésion sur un autre contrat
                    loc_AFFIL_ANO.ETATANO :=7;
                    PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
                    loc_AFFIL_ANO.NUMANO:=NULL;
                  END IF;
                END IF;

                 /*?????????????????????????????????????*/
                /*SELECT  nvl(max(numassu),0) INTO loc_numassu FROM individu WHERE numindiv = I_AFFIL_PORTE.NUMINDIV;  --TODO pourquoi pas f_numassu ?

                SELECT  COUNT(IDADHESION) INTO loc_cpt_numassu FROM  adhe_cntrt
                 WHERE numadhe=loc_numassu
                   AND idadhesion IN
                    ( SELECT idadhesion FROM v_adhe_cntrt_membre WHERE v_adhe_cntrt_membre.numindiv = loc_numassu );
                SELECT  COUNT(IDADHESION) INTO loc_cpt_numindiv FROM  adhe_cntrt
                 WHERE numadhe=I_AFFIL_PORTE.NUMINDIV
                   AND idadhesion IN
                    ( SELECT idadhesion FROM v_adhe_cntrt_membre WHERE v_adhe_cntrt_membre.numindiv = I_AFFIL_PORTE.NUMINDIV ) ;
                */
                EXCEPTION
                  WHEN exc_resiliation THEN
                    cpt_ano:=cpt_ano+1;
                    loc_AFFIL_ANO.NUMANO:=loc_ano_resil;
                    loc_AFFIL_ANO.ETATANO :=3;
                    PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
                    loc_AFFIL_ANO.NUMANO:=NULL;
                END;

              END LOOP;
              P_INS_journal(3, loc_log||', *****FIN Parcours avec adhesion de base '||loc_AFFIL_PORTE_ADH.idadhesion);

          END IF;--Tab_RG.EXISTS('INS_RES')
        END IF;--I_AFFIL_PORTE.TYPE_MVT IN( 5,7)
        --on passe à l'adhésion suivante
        EXCEPTION
          WHEN exc_adhesion THEN
           cpt_ano:=cpt_ano+1;
           --on peut avoir une ano par adhésion individuelle
           loc_AFFIL_ANO.NUMANO:=loc_ano_adhesion;  -- Adhésion non traitée ou trouvée
           loc_AFFIL_ANO.ETATANO:=3;
           PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
           loc_AFFIL_ANO.NUMANO:=NULL;
          WHEN exc_contrat_ouvert THEN
           cpt_ano:=cpt_ano+1;
           loc_AFFIL_ANO.NUMANO:=loc_numgarOuvert;  -- 109, 126 de AFFILANO
           loc_AFFIL_ANO.ETATANO:=3;
           PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
           loc_AFFIL_ANO.NUMANO:=NULL;
        END;
      END IF; --IF rec_affil_porte_adh2.NUMGAR IS NULL  THEN
    END LOOP;


     --on recherche les couvertures du salarié pour lesquelles il n'est pas adhérent de l'adhesion
     IF I_AFFIL_PORTE.TYPE_MVT IN( 5,7)  THEN
      SELECT count(ad.idadhesion) INTO loc_cpt_adhesion
      FROM adhesion ad, adhe_cntrt cn
      WHERE ad.numindiv = I_AFFIL_PORTE.NUMINDIV
      AND ad.idadhesion = cn.idadhesion
      AND cn.numadhe <> I_AFFIL_PORTE.NUMINDIV
      AND I_AFFIL_FICHIER.DATEFIC BETWEEN ad.datapli AND NVL(ad.datper,I_AFFIL_FICHIER.DATEFIC);

      IF  loc_cpt_adhesion >0 THEN
        loc_warning1:=loc_warning1+1;
        loc_AFFIL_ANO.NUMANO:=121;       -- l assuré n est pas adhérent sur un contrat
        loc_AFFIL_ANO.ETATANO :=7;
        PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
        loc_AFFIL_ANO.NUMANO:=NULL;
      END IF;
    END IF;

    -- si assuré inconnu mais un seul contrat prévoyance alors on en bloque pas l'assuré
    IF loc_ano_indiv>0  AND loc_cpt_cntrt=1 AND loc_AFFIL_PORTE_ADH.numgar IS NOT NULL
       AND  I_TAB_CNTRT(loc_AFFIL_PORTE_ADH.numgar).prev >0 AND Tab_RG.EXISTS('AFFILPREVS') THEN
      loc_ano_indiv :=0;
    END IF;

    --declenchement des anomalies salariés non bloquantes
    IF loc_ano_indiv > 0 AND I_AFFIL_PORTE.NUMINDIV IS  NULL THEN
      CASE loc_ano_indiv
        WHEN 1 THEN loc_AFFIL_ANO.NUMANO:=11;--salarié inconnu
        WHEN 2 THEN loc_AFFIL_ANO.NUMANO:=2;-- Anomalie doublon de salarié
        ELSE loc_AFFIL_ANO.NUMANO:=12; --erreur technique
      END CASE;
      loc_AFFIL_ANO.ETATANO:=3;
      PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=NULL;
    END IF;

  EXCEPTION
    WHEN exc_societe THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=I_ANO_SOCIETE;  -- 1 introuvable ou 86 doublon
    WHEN exc_datnais_dif THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=78;       -- La date de naissance est différente entre le SI et le fichier
    WHEN exc_matorg_dif THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=108;       -- Le n°ss est différent entre le SI et le fichier
    WHEN exc_indiv_inconnu_SI THEN
      loc_AFFIL_ANO.NUMANO:=104;      -- Assuré inconnu du SI
      cpt_ano:=cpt_ano+1;
    WHEN exc_indiv_doublon THEN
      loc_AFFIL_ANO.NUMANO:=105;     -- Doublon de salarié
      cpt_ano:=cpt_ano+1;
    WHEN exc_individu THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=3;  -- Anomalie de création du salarié
    WHEN exc_individu_bia THEN
      cpt_ano:=cpt_ano+1;--ne pas ôter car permet de couvrir la mises en ano pour non identification contrat et garantie
      loc_AFFIL_ANO.NUMANO:=123;  -- Rétention création salarié
    WHEN exc_histophys THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=9;  -- donnée complémentaire incohérente
    WHEN exc_technique THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=56;  -- Erreur indéterminée
    WHEN exc_pers_adresse THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=5;   -- Anomalie d initialisation de l adresse
    WHEN exc_nom_long THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=57;   -- Nom du salarié trop long
    WHEN exc_prenom_long THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=58;   -- prenom du salarié trop long
    WHEN exc_mail_long THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=59;   -- Adresse email du salarié trop longue
    WHEN exc_contact THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=60;   -- Impossible d intégrer l adresse mail
    WHEN exc_lieunaiss THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=100;
    WHEN exc_nomjf     THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=99;
    WHEN exc_rib THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=103;   -- Impossible d intégrer le rib
    WHEN exc_mvt_ko THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=loc_ano_mvt;
   /* WHEN exc_adhesion THEN
       cpt_ano:=cpt_ano+1;
       loc_AFFIL_ANO.NUMANO:=loc_ano_adhesion;  -- Adhésion non traitée ou trouvée*/
    WHEN exc_code_opt THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=76;        -- Code option vide: garantie non trouvée
    WHEN exc_numfor THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=loc_ano_numfor;  -- 63,64,65,66 de AFFILANO
    WHEN exc_affiliation THEN
      cpt_ano:=cpt_ano+1;
   /* WHEN exc_resiliation THEN
      cpt_ano:=cpt_ano+1;
      loc_AFFIL_ANO.NUMANO:=loc_ano_resil;  -- 68, 70, 35 de AFFILANO
      P_INS_journal(1, loc_log||',F_GestLigneAffil loc_ano_resil '||loc_ano_resil);*/
    WHEN exc_suspension THEN
      cpt_ano:=cpt_ano+1;
       loc_AFFIL_ANO.NUMANO:=loc_ano_resil;  -- 69, 71, 73 de AFFILANO
    WHEN OTHERS THEN
      ROLLBACK;
      loc_AFFIL_ANO.NUMANO:=56;  -- Erreur indéterminée
      P_INS_journal(1, loc_log||',F_GestLigneAffil 1 '||SUBSTR(SQLERRM,1,132));
      RETURN 0;
  END;

  ---------------------------------------------------------------------------------------------------------
  -- Si une ou plusieurs anomalies sont détectées on bloque l affiliation avec l état à 3 : Bloquée
  ---------------------------------------------------------------------------------------------------------

  IF cpt_ano>0 THEN
   -- ROLLBACK; -- enlever car adh non à jour => mettre dans des transactions séparées affiliation et radiations ?
    cpt_ano_tot:=cpt_ano_tot+1;
    IF loc_AFFIL_ANO.NUMANO IS NOT NULL THEN
      loc_AFFIL_ANO.ETATANO:=3;
      PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
    END IF;
    I_AFFIL_PORTE.ETAT:=3;
  END IF;

  IF cpt_ano=0 THEN
    ---------------------------------------------------------------------------------------------------------
    -- Si un ou plusieurs warning sont détectées on passe l affiliation avec l état à 7 : importée avec avertissement
    ---------------------------------------------------------------------------------------------------------
    IF loc_warning1 > 0 THEN
      I_AFFIL_PORTE.ETAT:=7;
      PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);

    END IF;

    ---------------------------------------------------------------------------------------------------------
    -- Si aucun warning ou aucune anomalie n'est détectée on passe l affiliation avec l état à 1 : importée
    ---------------------------------------------------------------------------------------------------------
    IF (loc_warning1 = 0 AND cpt_ano=0) THEN
      I_AFFIL_PORTE.ETAT:=1;
    END IF;
  END IF;
  PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE(I_AFFIL_PORTE);


  COMMIT;

  RETURN 1;

EXCEPTION
  WHEN OTHERS THEN
    -- Annulation de la validation de l import CFE et de l'ensemble des transactions dans Arthus
    ROLLBACK;
    P_INS_journal(1, loc_log||',F_GestLigneAffil 2 '||SUBSTR(SQLERRM,1,132));
    RETURN 0;
END F_GestLigneAffil;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_GestAYD                                                 */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire                                           */
/*                                                                           */
/* Entree       :                                                            */
/* Retour       :  o_erreur, Message d erreur en cas d echec d envoi des flux*/
/*---------------------------------------------------------------------------*/
PROCEDURE P_GestAYD ( i_affil_porte  IN       AFFIL_PORTE%ROWTYPE
                    , i_log          IN  OUT  JOURNAL_ADM.MSG_ADM%TYPE
                    , i_ano              OUT  AFFIL_ANO.NUMANO%TYPE)
IS

  loc_ano      NUMBER:=0;
  loc_erreur   VARCHAR2(200):=NULL;
  loc_etendue  NUMBER:=1;

  CURSOR c_affil_porte_ayd( P_numremise  NUMBER
                          , P_numporte   NUMBER
                          , P_numligne   NUMBER
                          )
      IS
  SELECT ayd.*
    FROM AFFIL_PORTE_AYD ayd
   WHERE ayd.NUMREMISE=P_numremise
     AND ayd.NUMPORTE=P_numporte
     AND ayd.NUMLIGNE=P_numligne
     AND ayd.NUMAYD<>0
  ORDER BY ayd.NUMLIGNE, ayd.NUMAYD ASC
     ;

BEGIN

  FOR rec_affil_porte_ayd IN  c_affil_porte_ayd(i_affil_porte.Numremise,i_affil_porte.numPorte,i_affil_porte.numligne) LOOP
    IF NVL(rec_affil_porte_ayd.NOMUSAGE,rec_affil_porte_ayd.NOM) IS NULL
          OR rec_affil_porte_ayd.NUMSSA IS NULL
          OR rec_affil_porte_ayd.TYPEAD IS NULL THEN
          i_ano:=106;
          EXIT;
    END IF;
    BEGIN
      loc_ano:=F_GestLigneAYD(i_affil_porte,rec_affil_porte_ayd , i_log, loc_erreur);
      P_INS_journal(3,i_log ||'P_GestAYD loc_erreur:'||loc_erreur);
      --i_ano:= loc_ano; --erreur non interprétable...
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        P_INS_journal(3,i_log ||'P_GestAYD '||SUBSTR(SQLERRM,1,132));
    END;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    -- Annulation de la validation de l import CFE et de l'ensemble des transactions dans Arthus
   -- ROLLBACK;
    P_INS_journal(3, i_log ||',Fin anormale P_GestAYD  '||SUBSTR(SQLERRM,1,132));
   -- o_erreur:=i_log ||', Fin anormale P_GestAYD '||SUBSTR(SQLERRM,1,132);
END P_GestAYD;

/*---------------------------------------------------------------------------*/
/* FONCTION                                                                  */
/* Nom          :  F_GestLigneAYD                                            */
/* Type         :  Public                                                    */
/* Description  :  Permet de faire                                           */
/*                                                                           */
/* Entree       :                                                            */
/* Retour       :  1 pour OK, 0 pour KO                                      */
/*---------------------------------------------------------------------------*/
FUNCTION F_GestLigneAYD ( I_AFFIL_PORTE     IN          AFFIL_PORTE%ROWTYPE
                        , I_AFFIL_PORTE_AYD IN  OUT     AFFIL_PORTE_AYD%ROWTYPE
                        , i_log             IN  OUT     JOURNAL_ADM.MSG_ADM%TYPE
                        , o_erreur              OUT     VARCHAR2)
RETURN NUMBER
IS
  -- variables

  cpt_ano_tot        NUMBER:=0;
  cpt_ano            NUMBER;

  loc_ano_techno     AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_indiv      AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_numgar     AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_numfor     AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_affil      AFFIL_ANO.NUMANO%TYPE:=NULL;
  loc_ano_numassu    AFFIL_ANO.NUMANO%TYPE:=NULL;

  loc_cpt_ano_ayd    NUMBER;
  loc_warning        NUMBER:=0;
  loc_lib_warning    VARCHAR2(150):=NULL;


  -- Objets
  loc_AFFIL_FICHIER       AFFIL_FICHIER%ROWTYPE;
  loc_AFFIL_ANO           AFFIL_ANO%ROWTYPE;
  loc_INDIVIDU            INDIVIDU%ROWTYPE;
  loc_AFFIL_PORTE_ADH     AFFIL_PORTE_ADH%ROWTYPE;
  loc_AFFIL_PORTE_AYD     AFFIL_PORTE_AYD%ROWTYPE;
  loc_AFFIL_PORTE_FORCAGE AFFIL_PORTE_FORCAGE%ROWTYPE;
  loc_AFFIL_TRACE         AFFIL_TRACE%ROWTYPE;

  loc_numgar              CONTRAT.NUMGAR%TYPE:=NULL;
  loc_idadhesion          ADHESION.IDADHESION%TYPE:=NULL;
  loc_numfor              GAR_PARAM_DETAIL.NUMFOR%TYPE:=NULL;

  -- exception
  exc_individu_exist       EXCEPTION;
  exc_technique            EXCEPTION;
  exc_individu             EXCEPTION;
  exc_numgar               EXCEPTION;
  exc_code_opt             EXCEPTION;
  exc_numfor               EXCEPTION;
  exc_affiliation          EXCEPTION;
  exc_numassu              EXCEPTION;


BEGIN

  BEGIN
    cpt_ano            :=0;
    cpt_ano_tot        :=0;
    loc_cpt_ano_ayd    :=0;
    loc_warning        :=0;
    loc_ano_indiv      :=0;
    loc_ano_techno     :=0;
    loc_ano_indiv      :=0;
    loc_ano_numfor     :=0;
    loc_ano_numgar     :=0;

  --  loc_log:=TO_CHAR(I_AFFIL_PORTE_AYD.NUMREMISE)|| '-' ||TO_CHAR(I_AFFIL_PORTE_AYD.NUMLIGNE);

    ---------------------------------------------------------------------------------
    -- ********************** AYANT DROIT *******************************************
    ---------------------------------------------------------------------------------
    P_INS_journal(3, i_log||',***AYANT DROIT :'||I_AFFIL_PORTE_AYD.NUMINDIV||' SS :'||I_AFFIL_PORTE_AYD.NUMSSA||' Nom :'||I_AFFIL_PORTE_AYD.NOMUSAGE||' '||I_AFFIL_PORTE_AYD.PRENOM||' né le '||I_AFFIL_PORTE_AYD.DATNAIS);

    IF I_AFFIL_PORTE_AYD.NUMINDIV IS NULL THEN
      I_AFFIL_PORTE_AYD.NUMINDIV:=PK_CTRL_AFFIL.F_FIND_SALARIE(I_AFFIL_PORTE_AYD.NUMSSA
                                                             , I_AFFIL_PORTE_AYD.NOMUSAGE
                                                             , I_AFFIL_PORTE_AYD.PRENOM
                                                             , I_AFFIL_PORTE_AYD.NOM
                                                             , I_AFFIL_PORTE_AYD.DATNAIS
                                                             , NVL(I_AFFIL_PORTE_AYD.RANG,1)
                                                             , loc_ano_indiv
                                                         );
    END IF;

    IF I_AFFIL_PORTE_AYD.NUMINDIV >0 THEN
      RAISE exc_individu_exist;
    END IF;
    P_INS_journal(3, i_log||',  Création de l ayant droit :'||loc_ano_indiv ||' =>1 si inconnu SI');
    PK_CTRL_AFFIL.P_GestionIndividu( I_AFFIL_PORTE -- NULL
                                   , I_AFFIL_PORTE_AYD
                                   , loc_INDIVIDU
                                   , loc_ano_indiv);

    P_INS_journal(3, i_log||', **** Nouveau ayant droit :'||loc_INDIVIDU.NUMINDIV||' Anomalie:'||loc_ano_indiv);

    IF loc_ano_indiv>0 THEN
      P_INS_journal(3, i_log||',  Anomalie:'||loc_ano_indiv);
      RAISE exc_individu;
    END IF;

    I_AFFIL_PORTE_AYD.NUMINDIV:=loc_INDIVIDU.NUMINDIV; --affectation du nouveau salarié

    P_INS_journal(3, i_log||',***Salarié :'||I_AFFIL_PORTE_AYD.NUMINDIV);

   -- NOEMISATION
   IF (TRIM(I_AFFIL_PORTE_AYD.EDI) <> 'O' OR TRIM(I_AFFIL_PORTE_AYD.EDI) IS NULL)  AND Tab_RG.EXISTS('INS_NOEMIE') THEN
      loc_warning:=loc_warning+1;
      IF I_AFFIL_PORTE_AYD.NUMAYD = 0 THEN
        loc_AFFIL_ANO.NUMANO:=102; -- Noémisation non acceptée
        loc_AFFIL_ANO.ETATANO :=7;
        loc_AFFIL_ANO.NUMPORTE :=I_AFFIL_PORTE_AYD.NUMPORTE;
        loc_AFFIL_ANO.NUMREMISE :=I_AFFIL_PORTE_AYD.NUMREMISE;
        loc_AFFIL_ANO.NUMLIGNE :=I_AFFIL_PORTE_AYD.NUMLIGNE;
        PK_CTRL_AFFIL.P_INS_AFFIL_ANO(loc_AFFIL_ANO);
        loc_AFFIL_ANO.NUMANO:=NULL;
      END IF;
      --P_INS_journal(3 , i_log||','|| Tab_RG('INS_NOEMIE'));
   END IF;

  EXCEPTION
    WHEN exc_technique THEN
       cpt_ano:=cpt_ano+1;
       P_INS_journal(1, i_log||',Erreur technique :'||I_AFFIL_PORTE_AYD.NUMINDIV);
    WHEN exc_individu_exist THEN
      -- cpt_ano:=cpt_ano+1;
       P_INS_journal(3, i_log||', Ayant droit déjà existant :'||I_AFFIL_PORTE_AYD.NUMINDIV);
    WHEN exc_individu THEN
       cpt_ano:=cpt_ano+1;
       P_INS_journal(1, i_log||',Erreur création individu :'||I_AFFIL_PORTE_AYD.NUMINDIV);
    WHEN exc_numgar THEN
       cpt_ano:=cpt_ano+1;
       P_INS_journal(1, i_log||',Erreur recherche contrat :'||I_AFFIL_PORTE_AYD.NUMINDIV);
    WHEN exc_numfor THEN
       cpt_ano:=cpt_ano+1;
       P_INS_journal(1, i_log||',Erreur création couvertures :'||I_AFFIL_PORTE_AYD.NUMINDIV);
    WHEN exc_code_opt THEN
       cpt_ano:=cpt_ano+1;
       P_INS_journal(1, i_log||',Erreur code option non renseigné :'||I_AFFIL_PORTE_AYD.NUMINDIV);
    WHEN exc_affiliation THEN
       cpt_ano:=cpt_ano+1;
       P_INS_journal(1, i_log||',Erreur rattachement membre :'||I_AFFIL_PORTE_AYD.NUMINDIV);
    WHEN exc_numassu THEN
       cpt_ano:=cpt_ano+1;
       P_INS_journal(1, i_log||',Erreur mise à jour numassu :'||I_AFFIL_PORTE_AYD.NUMINDIV);
    WHEN OTHERS THEN
      ROLLBACK;
       P_INS_journal(1, i_log||',WHEN OTHERS :'||I_AFFIL_PORTE_AYD.NUMINDIV);
      RETURN 0;
  END;

  ---------------------------------------------------------------------------------------------------------
  -- Si une ou plusieurs anomalies sont détectées on bloque l affiliation avec l état à 3 : Bloquée
  ---------------------------------------------------------------------------------------------------------
  PK_CTRL_AFFIL.P_MAJ_AFFIL_PORTE_AYD(I_AFFIL_PORTE_AYD);
  PK_CTRL_AFFIL.P_MAJ_AFFIL_PRT_ADH_INDIV(I_AFFIL_PORTE_AYD);


  RETURN 1;

EXCEPTION
  WHEN OTHERS THEN
    -- Annulation de la validation de l import CFE et de l'ensemble des transactions dans Arthus
    ROLLBACK;
    P_INS_journal(1, i_log||',F_GestLigneAYD '||SUBSTR(SQLERRM,1,132));
    RETURN 0;
END F_GestLigneAYD;

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

END PK_GEST_AFFIL;
/
