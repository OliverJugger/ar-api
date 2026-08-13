CREATE OR REPLACE PACKAGE ARTHUS.PK_FRAIS_RESEAUX
AS
/******************************************************************************/
/*============================================================================*/
/* Package      : PK_FRAIS_RESEAUX.sql                                        */
/* Domaine      : Facturation frais de reseaux Sante                          */
/* Version      : V1.0                                                        */
/* Auteur       : PBO                                                         */
/* Creation     :                                                             */
/* Description  : Facturation des frais de reseaux aux assureurs elligibles   */
/*              : a facturation                                               */
/*              :                                                             */
/*============================================================================*/
/*Commentaire  :                                                              */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/


  PROCEDURE P_FACT_FRAIS_RES_SANTE_MENSUEL;


  PROCEDURE P_FACT_FRAIS_RES_SANTE (
    i_numporte     IN     NUMBER DEFAULT NULL,
    i_datsin       IN     DATE
  );


  -- Generation des sinsitres fictifs
  PROCEDURE P_CREATE_SINISTRE_FRES (
    i_numporte     IN     NUMBER,
    i_datsin       IN     DATE,
    o_traitOK      OUT    CHAR,
    o_msg          OUT    VARCHAR2
    );

  -- Contitution des decomptes
  PROCEDURE P_CREER_DECOMPTE_FRES (
    i_numporte   IN      NUMBER,
    o_traitOK    OUT     CHAR,
    o_msg        OUT     VARCHAR2
    );

  -- Constitution des decaissements
  PROCEDURE P_CREER_DECAISMT_FRES (
    i_numporte   IN     NUMBER,
    o_traitOK    OUT    CHAR,
    o_msg        OUT    VARCHAR2
  );

  -- Génération des Emails
  PROCEDURE P_SEND_RAPPORT_ENVOI_MAIL
    (i_date_session IN DATE,
    i_cptrendu     IN VARCHAR2,
    o_traitOK      IN CHAR
  );

  -- Insertion journal ADM
  PROCEDURE P_INS_journal
    (i_niv IN NUMBER,
    i_msg IN VARCHAR2
  );

END PK_FRAIS_RESEAUX;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_FRAIS_RESEAUX AS

/******************************************************************************/
/*============================================================================*/
/* Package      : P_FRAIS_RESEAUX.sql                                        */
/* Domaine      : Facturation frais de reseaux Sante                          */
/* Version      : V1.0                                                        */
/* Auteur       : PBO                                                         */
/* Creation     :                                                             */
/* Description  : Facturation des frais de reseaux Sante                      */
/*              :                                                             */
/*============================================================================*/
/*Commentaire  :                                                              */
/*============================================================================*/
/* Correction   :                                                             */
/*============================================================================*/

--VARIABLES GLOBALES
g_nom_traitement  journal_adm.nom_traitement%TYPE DEFAULT 'FRE01T';
g_niv_msg         journal_adm.niv_msg%TYPE := NULL;
g_idligne         journal_adm.idligne%TYPE := 0;
g_session         NUMBER;

/*===========================================================================*/
/* Procedure    : P_FACT_FRAIS_RES_SANTE_MENSUEL                             */
/* Domaine      : Prestation SANTE                                           */
/* Version      : V1.0                                                       */
/* Auteur       : PBO                                                        */
/* Creation     : 16/10/2020                                                 */
/* Description  : Procédure pour traitement automatisé en batch              */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/
PROCEDURE P_FACT_FRAIS_RES_SANTE_MENSUEL IS

  BEGIN
    P_FACT_FRAIS_RES_SANTE (NULL,SYSDATE);


 END P_FACT_FRAIS_RES_SANTE_MENSUEL;

/*===========================================================================*/
/* Procedure    : P_FACT_FRAIS_RES_SANTE                                     */
/* Domaine      : Prestation SANTE                                           */
/* Version      : V1.0                                                       */
/* Auteur       : PBO                                                        */
/* Creation     : 09/10/2020                                                 */
/* Description  : Mise en oeuvre des frais de reseau a partir des parametres */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/
PROCEDURE P_FACT_FRAIS_RES_SANTE (
          i_numporte     IN     NUMBER DEFAULT NULL,
          i_datsin       IN     DATE)
          IS


  v_ctrl_itelis_stclair NUMBER;
  v_datsin              DATE DEFAULT SYSDATE;
  v_traitOK             CHAR(1):='O';
  loc_rapportOK           CHAR(1):='O';
  loc_msg               VARCHAR2(5000):='';
  loc_cptrendu          VARCHAR2(30000):='';

  -- Curseur récupérant les numérots de portes des réseaux de soins de santé
  CURSOR C_numporte IS
    SELECT DISTINCT sens AS numporte
    FROM libelle
    WHERE mnemo = 'RES_SANTE'
      AND sens > 1;

  -- Curseur de ctrl si Itelis et SanteClair sont sur les mm contrats
  CURSOR C_ctrl_itelis_stclair IS
    SELECT pc1.numgar
      FROM porte_contrat pc1, porte_contrat pc2
      WHERE pc2.numgar   = pc1.numgar
      AND pc1.numporte = 16  -- Itelis
      AND pc2.numporte = 22  -- StClair
      AND pk_histo_contrat.f_sel_etat (pc1.numgar,i_datsin)=1; -- Contrat ouvert à date

  BEGIN

  -- ********* --
  -- Init      --
  -- ********* --
    loc_msg := 'Traitement des frais de réseaux de soins en date du ' || TO_CHAR(i_datsin,'DD/MM/YYYY');
    loc_cptrendu := loc_msg ;
    loc_rapportOK := 'O';
    P_INS_journal(1, loc_msg);


    -- ********* --
    -- Contrôles --
    -- ********* --
    -- ctrl des parametres
    IF TRIM(i_numporte) IS NOT NULL THEN
      loc_msg := 'Le traitement est limité au réseau de soins '|| f_nom_reso (i_numporte) || '.';
      loc_cptrendu := loc_cptrendu ||CHR(13)||CHR(10)|| loc_msg ;
      P_INS_journal(1, loc_msg);
    END IF;

    IF i_datsin IS NULL THEN
      loc_rapportOK := 'N';
      loc_msg := 'Anomalie 001: Date de selection non renseignée. Arrêt du traitement';
      loc_cptrendu := loc_cptrendu ||CHR(13)||CHR(10)|| loc_msg ;
      P_INS_journal(1, loc_msg);
      P_SEND_RAPPORT_ENVOI_MAIL(sysdate,loc_cptrendu,loc_rapportOK);
      RETURN; -- on arrete la procedure
    END IF;

    -- Boucle de ctrl Itelis et SanteClair sur les mm contrats
    FOR R_ctrl_itelis_stclair IN C_ctrl_itelis_stclair LOOP

      IF R_ctrl_itelis_stclair.numgar IS NOT NULL THEN
        loc_rapportOK := 'N';
        loc_msg := 'Anomalie 001: Portes Santéclair et ITELIS ouvertes sur le contrat ' || R_ctrl_itelis_stclair.numgar ;
        loc_cptrendu := loc_cptrendu ||CHR(13)||CHR(10)
                      || 'Le traitement a été arrêté par l''anomalie suivante' ||CHR(13)||CHR(10)
                      || loc_msg ||CHR(13)||CHR(10)
                      || 'Arrêt du traitement.' ;
        P_INS_journal(1, loc_msg);
        P_SEND_RAPPORT_ENVOI_MAIL(sysdate,loc_cptrendu,loc_rapportOK);
        ROLLBACK;
        RETURN; -- on arrete la procedure
      END IF;

    END LOOP;


    -- Boucle sur les portes (cad les reseaux)
    FOR R_numporte IN C_numporte LOOP

      -- Si une porte est passée en paramètre, on saute les autres portes
      IF   i_numporte IS NOT NULL
      AND R_numporte.numporte <> i_numporte THEN
        CONTINUE;
      END IF;

      loc_msg := 'Traitement pour '|| f_nom_reso (R_numporte.numporte) || '.' ;
      loc_cptrendu := loc_cptrendu ||CHR(13)||CHR(10)||CHR(13)||CHR(10)|| loc_msg ;
      P_INS_journal(1, loc_msg);

      -- Generation des sinitres fictifs
      P_CREATE_SINISTRE_FRES(R_numporte.numporte, TRUNC(i_datsin), v_traitOK, loc_msg);
      IF v_traitOK = 'N' THEN
        loc_rapportOK := 'N';
        loc_cptrendu := loc_cptrendu ||CHR(13)||CHR(10)
                      || 'Le traitement a été arrêté par l''anomalie suivante' ||CHR(13)||CHR(10)
                      || loc_msg ||CHR(13)||CHR(10)
                      || 'Arrêt du traitement.' ;
        P_INS_journal(1, loc_msg);
        ROLLBACK;
        CONTINUE; -- on continue pour les autres portes
      ELSE
        IF TRIM (loc_msg) IS NOT NULL THEN
          loc_cptrendu := loc_cptrendu ||CHR(13)||CHR(10) || loc_msg;
        END IF;
      END IF;

      -- Contitution des décomptes
      P_CREER_DECOMPTE_FRES(R_numporte.numporte, v_traitOK, loc_msg);
      IF v_traitOK = 'N' THEN
        loc_rapportOK := 'N';
        loc_cptrendu := loc_cptrendu ||CHR(13)||CHR(10)
                      || 'Le traitement a été arrêté par l''anomalie suivante' ||CHR(13)||CHR(10)
                      || loc_msg ||CHR(13)||CHR(10)
                      || 'Arrêt du traitement.' ;
        P_INS_journal(1, loc_msg);
        ROLLBACK;
        CONTINUE; -- on continue pour les autres portes
      ELSE
        IF TRIM (loc_msg) IS NOT NULL THEN
          loc_cptrendu := loc_cptrendu ||CHR(13)||CHR(10) || loc_msg;
        END IF;
      END IF;

      -- Constitution des decaissements
      P_CREER_DECAISMT_FRES(R_numporte.numporte, v_traitOK, loc_msg);
      IF v_traitOK = 'N' THEN
        loc_rapportOK := 'N';
        loc_cptrendu := loc_cptrendu ||CHR(13)||CHR(10)
                      || 'Le traitement a été arrêté par l''anomalie suivante' ||CHR(13)||CHR(10)
                      || loc_msg ||CHR(13)||CHR(10)
                      || 'Arrêt du traitement.' ;
        P_INS_journal(1, loc_msg);
        ROLLBACK;
        CONTINUE; -- on continue pour les autres portes
      ELSE
        IF TRIM (loc_msg) IS NOT NULL THEN
          loc_cptrendu := loc_cptrendu ||CHR(13)||CHR(10) || loc_msg;
        END IF;
      END IF;

      -- COMMIT pour la porte/réseau en cours
      loc_msg := 'COMMIT pour le reseau ' || R_numporte.numporte;
      P_INS_journal(1, loc_msg);

      COMMIT;
    -- FinBoucle portes
    END LOOP;

  P_SEND_RAPPORT_ENVOI_MAIL(sysdate,loc_cptrendu,loc_rapportOK);

END P_FACT_FRAIS_RES_SANTE;

/*****************************************************************************/
/*===========================================================================*/
/* Procedure    : P_CREATE_SINISTRE_FRES                                     */
/* Domaine      : Prestation SANTE => Sinistre                               */
/* Version      : V1.0                                                       */
/* Auteur       : PBO                                                        */
/* Creation     : 06/10/2020                                                 */
/* Description  : Creation de sinsitre fictifs dans le cadre de la           */
/*              : facturation des frais de reseaux de soins                  */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/
PROCEDURE P_CREATE_SINISTRE_FRES (
          i_numporte     IN    NUMBER,
          i_datsin       IN    DATE,
          o_traitOK      OUT   CHAR,
          o_msg          OUT   VARCHAR2)
          IS

  v_numsin                sinistre.numsin%TYPE DEFAULT NULL;
  v_compteur_sinistre     NUMBER;
  v_code                  VARCHAR2(10);
  v_devise_ref            NUMBER;
  v_indice                NUMBER;
  v_numindiv              NUMBER;
  v_numutil_reso          NUMBER;
  loc_nbacte              NUMBER;
  loc_nbacte_res          NUMBER;
  loc_msg                 VARCHAR2(5000):='';

  /*=======================*/
  /* Curseur des sinistres */
  /*=======================*/
  CURSOR C_sinistre_fres IS
  SELECT
    c.numgar                   NUMGAR
    ,TRUNC(i_datsin)            DATSIN -- Date en parametre -- GD03T (constitution des decomptes) ne fonctionne qu'avec des dates tronquees (VARCHAR (11))
    ,TRUNC(SYSDATE)             DATSAI -- Date de selection -- GD03T (constitution des decomptes) ne fonctionne qu'avec des dates tronquees (VARCHAR (11))
    ,COUNT(DISTINCT a.numindiv) NBACTE -- nombre de beneficiaires limitee a 999
    ,MIN(a.numfor)              NUMFOR -- 1ere garantie de base sante sur le contrat
  FROM contrat c, adhesion a, formule f, porte_contrat p

  -- Jointures
  WHERE 1= 1
    AND c.numgar = a.numgar
    AND f.numfor = a.numfor
    AND p.numgar = c.numgar

    -- Predicats
    AND p.numporte     = i_numporte
    AND c.type_contrat = 1  -- Contrat sante
    AND f.typgar       = 1  -- Garantie de base
    AND a.typfor       = 1  -- Garantie soins de sante
    AND a.rang         = 1  --  Beneficiaire de rang 1
    AND f.numass IN (SELECT DISTINCT(code) FROM libelle WHERE mnemo = 'ASSU_FRES' AND sens = i_numporte) -- uniquement les assureurs eligibles
    AND f_etat_adhe(a.idadhesion ,TRUNC(i_datsin)) = 1 -- uniquement les adhesions en vigueur a date

    -- gestion des dates
    -- Pas 2 traitements avec les mm parametres le mm jour
    AND NOT EXISTS (SELECT 1 FROM sinistre
  --                    WHERE sinistre.sens    = 1
                      WHERE sinistre.codfrais = v_code
                        AND sinistre.datsin   = TRUNC(i_datsin))
    AND TRUNC(i_datsin) BETWEEN a.datapli AND NVL(a.datper, TRUNC(i_datsin)) -- uniquement les adhesions ouvertes a la date de selection
    AND a.datapli <> NVL(a.datper,e2d('01/01/1000')) -- exclusion des adhesions ouvertes et fermees le mm jour

  GROUP BY c.numgar
  ;

  BEGIN
    -- Init
    o_traitOK := 'O';
    o_msg     := '';
  -- ************************ --
  -- Collecte des valeurs --
  -- ************************ --

  -- recupere le code d'acte fictif
    BEGIN
  SELECT code INTO v_code
    FROM libelle_bis
      WHERE mnemo = 'RES_ACTE'
      AND SENS = i_numporte;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 003: Code acte fictif du réseau ' || f_nom_reso (i_numporte) || ' non trouvé (RES_ACTE).';
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
      WHEN OTHERS THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 003: Erreur de recherche du code acte fictif (RES_ACTE) du réseau ' || f_nom_reso (i_numporte) || ': ' || sqlerrm ;
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
    END;
--  DBMS_OUTPUT.PUT_LINE ('v_code =  '|| v_code);

    -- recupere la devise de reference
    v_devise_ref := pk_devise.devise_ref();
    IF v_devise_ref = 0 OR v_devise_ref IS NULL THEN
      o_traitOK := 'N';
      loc_msg := 'Anomalie 003: Erreur de recherche de la devise de référence: ' || v_devise_ref ;
      P_INS_journal(1, loc_msg);
      o_msg := loc_msg;
      RETURN;
    END IF ;
--  DBMS_OUTPUT.PUT_LINE ('v_devise_ref =  '|| v_devise_ref);

    -- la valeur de l'indice est fonction du reseau et de la date en parametre
    BEGIN
    SELECT ind.valeur INTO v_indice
      FROM libelle l1
      INNER JOIN libelle l2 ON LTRIM(l1.libelle, 'COEFF ') = l2.libelle,
      indice ind
        WHERE l1.mnemo = 'INDC'
        AND l2.mnemo = 'RES_SANTE'
        AND l2.sens = i_numporte
        AND ind.indice = l1.code
        AND TRUNC(i_datsin) BETWEEN ind.datapli AND NVL(ind.datper, TRUNC(i_datsin));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 003: Pas d''indice RES_SANTE paramétré pour le réseau '|| f_nom_reso (i_numporte) || '.';
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
      WHEN OTHERS THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 003: Erreur de recherche de la valeur d''indice RES_SANTE pour le réseau '|| f_nom_reso (i_numporte) || ' à la date '|| NVL(TO_CHAR(i_datsin,'DD/MM/YYYY'),'NULL') || ':' || sqlerrm ;
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
    END;
--  DBMS_OUTPUT.PUT_LINE ('v_indice =  '|| v_indice);

    -- Numindiv du reseau appele
    BEGIN
    SELECT code INTO v_numindiv
      FROM libelle
        WHERE mnemo = 'RES_SANTE'
        AND sens = i_numporte
        AND code in (SELECT numindiv FROM individu);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 003: Identifiant individu du réseau de soins porte ' || i_numporte ||' non trouvé.';
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
      WHEN OTHERS THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 003: Erreur de recherche d''identifiant individu de réseau de soins pour la porte' || i_numporte || ':' || sqlerrm ;
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
    END;
--  DBMS_OUTPUT.PUT_LINE ('v_numindiv =  '|| v_numindiv);

    -- on recupere le numutil du reseau de soins
    BEGIN
      SELECT porte_param.numutil INTO v_numutil_reso
        FROM porte_param
          WHERE porte_param.numporte = i_numporte;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          o_traitOK := 'N';
          loc_msg := 'Anomalie 003: Identifiant utilisateur du réseau '|| f_nom_reso (i_numporte) || ' non trouvé.';
          P_INS_journal(1, loc_msg);
          o_msg := loc_msg;
          RETURN;
        WHEN OTHERS THEN
          o_traitOK := 'N';
          loc_msg := 'Anomalie 003: Erreur de recherche d''identifiant utilisateur pour le réseau ' || f_nom_reso (i_numporte) || ':' || sqlerrm ;
          P_INS_journal(1, loc_msg);
          o_msg := loc_msg;
          RETURN;
    END;
--  DBMS_OUTPUT.PUT_LINE ('v_numutil_reso =  '|| v_numutil_reso);


  -- ************ --
  -- Ctrl Curseur --
  -- ************ --
    FOR R_sinistre_fres IN C_sinistre_fres LOOP

      v_compteur_sinistre := 0;

      loc_nbacte_res := R_sinistre_fres.NBACTE;

      WHILE loc_nbacte_res > 0 LOOP
        loc_nbacte := LEAST(999, loc_nbacte_res); -- nombre d'actes max 999

      /*=============================*/
      /* Inserts dans table sinistre */
      /*=============================*/
      BEGIN
        SELECT NUMSIN.NEXTVAL INTO v_numsin FROM DUAL;
      EXCEPTION
        WHEN OTHERS THEN
          o_traitOK := 'N';
          loc_msg := 'Anomalie 004: Erreur technique à l''allocation du sinistre pour le réseau '|| f_nom_reso (i_numporte) || '.';
          P_INS_journal(1, loc_msg);
          o_msg := loc_msg;
          RETURN;
      END;

      -- Exceptions de l'insert sinistre et de l'insert sinistre_dev non différenciées
      BEGIN

        INSERT
        INTO sinistre(
            codfrais,
            numgar,
            numindiv,
            datsin,
            mtprest,
            mtremb,
            mtfrais,
            datsai,
            nbacte,
            autrb,
            mtfran,
            sens,
            mtmax,
            mtreel,
            numdec,
            numassu,
            numbene,
            numsin,
            numannul,
            username,
            flagam,
            typbene,
            numpopu,
            numfor,
            nummath,
            idadhesion,
            x,
            y,
            numpc,
            monnaie,
            pdsqls,
            racmon,
            spe_exe,
            fra_dep,
            baseremb,
            taux,
            cas
          )
        VALUES (
          v_code,                                          -- codfrais, -- Acte fictif dediee au frais de reseaux sante
          R_sinistre_fres.numgar,                          -- numgar,
          v_numindiv,                                      -- numindiv,
          R_sinistre_fres.datsin,                          -- datsin,
          loc_nbacte * v_indice,                           -- mtprest,
          0,                                               -- mtremb,
          loc_nbacte * v_indice,                           -- mtfrais,
          TRUNC(R_sinistre_fres.datsai),                   -- datsai,
          loc_nbacte,                                      -- nbacte,
          0,                                               -- autrb,
          NULL,                                            -- mtfran,
          1,                                               -- sens, -- pas de dossier de prestation
          NULL,                                            -- mtmax,
          loc_nbacte * v_indice,                           -- mtreel,
          0,                                               -- numdec,
          v_numindiv,                                      -- numassu,
          v_numindiv,                                      -- numbene,
          v_numsin,                                        -- numsin,
          NULL,                                            -- numannul,
          v_numutil_reso,                                  -- username,
          'p',                                             -- flagam,
          2,                                               -- typbene,
          R_sinistre_fres.numfor,                          -- numpopu,
          R_sinistre_fres.numfor,                          -- numfor,
          NULL,                                            -- nummath,
          NULL,                                            -- idadhesion,
          NULL,                                            -- x,
          NULL,                                            -- y,
          NULL,                                            -- numpc,
          v_devise_ref,                                    -- monnaie,
          NULL,                                            -- pdsqls,
          NULL,                                            -- racmon,
          NULL,                                            -- spe_exe,
          NULL,                                            -- fra_dep,
          NULL,                                            -- baseremb,
          NULL,                                            -- taux,
          NULL);                                           -- cas

        -- Inserts dans table sinistre_dev
        INSERT
        INTO sinistre_dev
          (
            numsin,
            dev_ct,
            dev_in,
            dev_out,
            mtfrais_ct,
            mtfrais_in,
            mtfrais_out,
            mtprest_ct,
            mtprest_in,
            mtprest_out,
            mtremb_ct,
            mtremb_in,
            mtremb_out,
            mtreel_ct,
            mtreel_in,
            mtreel_out,
            autrb_ct,
            autrb_in,
            autrb_out
          )
        VALUES (v_numsin,                                 -- numsin,
                v_devise_ref,                             -- dev_ct,
                v_devise_ref,                             -- dev_in,
                v_devise_ref,                             -- dev_out,
                NVL(loc_nbacte * v_indice,0),             -- mtfrais_ct,
                NVL(loc_nbacte * v_indice,0),             -- mtfrais_in,
                NVL(loc_nbacte * v_indice,0),             -- mtfrais_out,
                NVL(loc_nbacte * v_indice,0),             -- mtprest_ct,
                NVL(loc_nbacte * v_indice,0),             -- mtprest_in,
                NVL(loc_nbacte * v_indice,0),             -- mtprest_out,
                0,                                        -- mtremb_ct,
                0,                                        -- mtremb_in,
                0,                                        -- mtremb_out,
                NVL(loc_nbacte * v_indice,0),             -- mtreel_ct,
                NVL(loc_nbacte * v_indice,0),             -- mtreel_in,
                NVL(loc_nbacte * v_indice,0),             -- mtreel_out,
                0,                                        -- autrb_ct,
                0,                                        -- autrb_in,
                0);                                       -- autrb_out

      EXCEPTION
        WHEN OTHERS THEN
          o_traitOK := 'N';
          loc_msg := 'Anomalie 004: Erreur lors de la création du sinistre du contrat ' || R_sinistre_fres.numgar || ' pour le réseau '|| f_nom_reso (i_numporte) || ': '|| sqlerrm ;
          P_INS_journal(1, loc_msg);
          o_msg := loc_msg;
          RETURN;
      END;

      v_compteur_sinistre := v_compteur_sinistre + 1;
      loc_nbacte_res      := loc_nbacte_res - loc_nbacte; -- on recupere le residu

      -- FinBoucle loc_nbacte_res
    END LOOP;
  --FinBoucle C_sinistre_fres
  END LOOP;

  -- Ctrl Curseur si vide
  IF v_compteur_sinistre = 0 THEN
    o_traitOK := 'N';
    loc_msg := 'Anomalie 002: Pas de bénéficiaires pour le réseau '|| f_nom_reso (i_numporte) || '.';
    o_msg := loc_msg;
    P_INS_journal(1, loc_msg);
    RETURN;
  END IF;

END P_CREATE_SINISTRE_FRES;

/*****************************************************************************/
/*===========================================================================*/
/* Procedure    : P_CREER_DECOMPTE_FRES                                      */
/* Domaine      : Prestation SANTE => Decompte                               */
/* Version      : V1.0                                                       */
/* Auteur       : PBO                                                        */
/* Creation     : 06/10/2019                                                 */
/* Description  : Creation des decomptes des sinistres fictifs des           */
/*              : reseaux de soins                                           */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/
 PROCEDURE P_CREER_DECOMPTE_FRES (i_numporte   IN     NUMBER,
                                  o_traitOK    OUT    CHAR,
                                  o_msg        OUT    VARCHAR2)
                                  IS

  L_found         NUMBER(2);
  L_nombre_sntr   NUMBER(7);
  L_porte_numutil NUMBER(7);
  ID_SESSION      NUMBER;
  loc_erreur      NUMBER:= 0;
  loc_msg         VARCHAR2(5000):='';

  CURSOR C_ctrl_decompte IS
    SELECT sntr.numgar, sntr.numindiv
      FROM sinistre sntr
        WHERE sntr.numdec = 0
        AND sntr.username = L_porte_numutil
        AND sntr.flagam   = 'p'
        AND (sntr.sens    != -1 OR sntr.sens IS NULL)
        AND sntr.mtreel   >=0;

  BEGIN
    -- Init
    o_traitOK := 'O';
    o_msg     := '';

    -- Numutil du reseau de soins
    BEGIN
    SELECT porte_param.numutil INTO L_porte_numutil
    FROM porte_param WHERE porte_param.numporte = i_numporte;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 003: Identifiant utilisateur du réseau '|| f_nom_reso (i_numporte) || ' non trouvé.';
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
      WHEN OTHERS THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 003: Erreur de recherche de l''identifiant utilisateur du réseau '|| f_nom_reso (i_numporte) || ':' || sqlerrm ;
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
    END;

    pk_gd03b.P_gd03b(I_numporte => i_numporte,   -- réseau de soins
                     I_param1 => 2,              -- parametre frais de reseaux
                     I_session => sid,
                     I_niv_msg => 1,
                     I_pause => 0,      --  0  ?
                     O_found => L_found,
                     O_erreur => loc_erreur
                     );

    IF NVL(L_found, 0) != 0 OR loc_erreur IS NOT NULL THEN
      o_traitOK := 'N';
      loc_msg := 'Anomalie 005: Erreur lors de la création du décompte pour le réseau '|| f_nom_reso (i_numporte) || '.' ;
      P_INS_journal(1, loc_msg);
      o_msg := loc_msg;
      RETURN;
    END IF;

    -- recherche les sinistres non decomptes
    FOR R_ctrl_decompte IN C_ctrl_decompte LOOP

      IF R_ctrl_decompte.numgar IS NOT NULL THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 005: Erreur lors de la création du décompte du contrat '|| R_ctrl_decompte.numgar ||' pour le réseau '|| f_nom_reso (i_numporte) || '.' ;
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
    o_traitOK := 'N';
    loc_msg := 'Anomalie 005: Erreur du traitement de création décompte pour le réseau '|| f_nom_reso (i_numporte) || ': '|| SQLERRM;
    P_INS_journal(1, loc_msg);
    o_msg := loc_msg;

END P_CREER_DECOMPTE_FRES;

/*****************************************************************************/
/*===========================================================================*/
/* Procedure    : P_CREER_DECAISMT_FRES                                      */
/* Domaine      : Prestation SANTE => Decaissement                           */
/* Version      : V1.0                                                       */
/* Auteur       : PBO                                                        */
/* Creation     : 07/10/2019                                                 */
/* Description  : Creation des decaismt des sinistres fictifs des            */
/*              : reseaux de soins                                           */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : trigramme / date / commentaire                             */
/*===========================================================================*/
PROCEDURE P_CREER_DECAISMT_FRES (i_numporte   IN     NUMBER,
                                 o_traitOK    OUT    CHAR,
                                 o_msg        OUT    VARCHAR2)
                                   IS

  v_numindiv                   NUMBER;
  loc_msg                      VARCHAR2(5000):='';


  -- Curseur récupérant les informations pour le décaissement à créer pour le réseau de soins
  CURSOR C_paiement IS
    SELECT 1                           CODOPE,
           COUNT(NUMAFFEC)            NB_AFFEC,
           SUM(MONTANT)               MT_TOTAL,
           MAX(MONNAIE)               MONNAIE,
           COUNT(DISTINCT MONNAIE)    NB_MONNAIE,
           MAX(NUMCLI)                NUMCLI,
           COUNT(DISTINCT NUMCLI)     NB_NUMCLI,
           SUM(MONTANT_D)             MT_TOTAL_D,
           MAX(MONNAIE_D)             MONNAIE_D,
           COUNT(DISTINCT MONNAIE_D)  NB_MONNAIE_D,
           SUM(MONTANT_CT)            MT_TOTAL_CT,
           MAX(DEVISE_CT)             DEVISE_CT,
           COUNT(DISTINCT DEVISE_CT)  NB_DEVISE_CT
         FROM AFFECTATION
              WHERE  numcli = v_numindiv
                AND  codope = 1
                AND  numdecaismt IS NULL
                -- Controle dérivé de PK_VIAMEDIS_FACT => voir si pertinent
                AND  NOT EXISTS (
                     SELECT 1 FROM compte_client
                              WHERE compte_client.codope  = 1
                                AND compte_client.numfact = AFFECTATION.numaffec
                                AND compte_client.numcli  =  AFFECTATION.numcli )
                AND numaffec IN (SELECT DISTINCT NUMDEC FROM sinistre WHERE sinistre.NUMDEC > 0 )
             ;
  --

  loc_erreur        NUMBER;
  v_monnaie_d       affectation.monnaie_d%TYPE;
  v_numdecaismt     decaismt.numdecaismt%TYPE;

  BEGIN
    -- Init
    o_traitOK := 'O';
    o_msg     := '';

    -- Numindiv du reseau appele
    BEGIN
    SELECT code INTO v_numindiv
      FROM libelle
        WHERE mnemo = 'RES_SANTE'
        AND sens = i_numporte
        AND code in (SELECT numindiv FROM individu);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 003: Identifiant individu du réseau '|| f_nom_reso (i_numporte) || ' non trouvé.';
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
      WHEN OTHERS THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 003: Erreur de recherche de l''identifiant individu du réseau '|| f_nom_reso (i_numporte) || ':' || sqlerrm ;
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
    END;



    FOR R_paiement IN C_paiement LOOP

    -- ********* --
    -- Contrôles --
    -- ********* --
      -- affectation en attente
      IF R_paiement.nb_affec = 0 THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 006: Aucun décaissement à créer pour le réseau '|| f_nom_reso (i_numporte) || '.';
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
      END IF;

      -- montant total >= 0 :
      IF R_paiement.mt_total_d < 0 THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 006: Décaissement invalide, montant négatif pour le réseau '|| f_nom_reso (i_numporte) || '!';
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
      END IF;

      -- ************************ --
      -- Création du décaissement --
      -- ************************ --
      BEGIN
        SELECT NUMDECAISMT.NEXTVAL INTO v_numdecaismt FROM DUAL;
      EXCEPTION
        WHEN OTHERS THEN
          o_traitOK := 'N';
          loc_msg := 'Anomalie 006: Erreur technique à l''allocation du décaissement pour le réseau '|| f_nom_reso (i_numporte) || '.';
          P_INS_journal(1, loc_msg);
          o_msg := loc_msg;
          RETURN;
      END;

      BEGIN
        INSERT INTO DECAISMT (
                              CODOPE, -- 1
                              NUMDECAISMT,
                              NUMCPTE,
                              NUMCHQ, -- 0
                              MODPMT,
                              MONTANT,
                              MONNAIE,
                              REFPMT,
                              DATPAY, -- SYSDATE
                              TYPBENE, -- 2 A confirmer
                              NUMBENE,
                              DEBIT, -- 0
                              DATCOMP, -- SYSDATE
                              NUMUTIL, -- f_numutil
                              NUMEDIT, -- 0 (pour permettre l'édition)
                              DATCOMPTA,
                              NUMDEST, -- numcli
                              IDCOMPTA,
                              DATEDIT,
                              FLAGPAY, -- 1 (-1 = annulé)
                              ID_DEBIT,
                              DATE_DEBIT,
                              TYPDOMI,
                              NUMDOMI,
                              MONNAIE_D,
                              MONTANT_D,
                              DEBIT_D,
                              MONTANT_EC,
                              TYPE_EC,
                              SENS_EC,
                              IDRELEVE_COMPTE,
                              DEVISE_EC,
                              MONTANT_CT,
                              DEVISE_CT,
                              CREATION, -- SYSDATE
                              DATAFFEC,
                              NUMDCPTCIE, -- 0
                              NUMDCPTCIE_SIN -- 0
                              )
        VALUES                (
                              1,                         -- CODOPE
                              v_numdecaismt,             -- NUMDECAISMT
                              1,                         -- NUMCPTE
                              0,                         -- NUMCHQ
                              7,                         -- MODPMT
                              R_paiement.mt_total,       -- MONTANT
                              R_paiement.monnaie,        -- MONNAIE
                              0,                         -- REFPMT
                              SYSDATE,                   -- DATPAY
                              2,                         -- TYPBENE
                              R_paiement.numcli,         -- NUMBENE
                              0,                         -- DEBIT
                              SYSDATE,                   -- DATCOMP
                              f_numutil,                 -- NUMUTIL
                              0,                         -- NUMEDIT
                              NULL,                      -- DATCOMPTA
                              R_paiement.numcli,         -- NUMDEST
                              NULL,                      -- IDCOMPTA
                              TRUNC(SYSDATE),            -- DATEDIT
                              1,                         -- FLAGPAY
                              NULL,                      -- ID_DEBIT
                              SYSDATE,                   -- DATE_DEBIT
                              NULL,                      -- TYPDOMI
                              NULL,                      -- NUMDOMI
                              R_paiement.monnaie_d,      -- MONNAIE_D
                              R_paiement.mt_total_d,     -- MONTANT_D
                              NULL,                      -- DEBIT_D
                              NULL,                      -- MONTANT_EC
                              NULL,                      -- TYPE_EC
                              NULL,                      -- SENS_EC
                              NULL,                      -- IDRELEVE_COMPTE
                              NULL,                      -- DEVISE_EC
                              R_paiement.mt_total_ct,    -- MONTANT_CT
                              R_paiement.devise_ct,      -- DEVISE_CT
                              SYSDATE,                   -- CREATION
                              SYSDATE,                   -- DATAFFEC
                              0,                         -- NUMDCPTCIE
                              0                          -- NUMDCPTCIE_SIN
                              );

      EXCEPTION
        WHEN OTHERS THEN
          o_traitOK := 'N';
          loc_msg := 'Anomalie 006: Erreur lors de la création du décaissement pour le réseau ' || f_nom_reso (i_numporte) || '.';
          P_INS_journal(1, loc_msg);
          o_msg := loc_msg;
          RETURN;

      END;

    -- Détail pour le rapport mail
    loc_msg := 'Décaissement '|| v_numdecaismt
               ||' d''un montant de '|| R_paiement.mt_total_d ||' Euros'
               ||' pour le réseau '|| f_nom(v_numindiv,100) || '.';
    P_INS_journal(1, loc_msg);
    o_msg := loc_msg;

    END LOOP;

    -- **************************** --
    -- Mise à jour des affectations --
    -- **************************** --
    UPDATE affectation
      SET numdecaismt = v_numdecaismt,
          dataffec    = GREATEST(SYSDATE,dataffec)
        WHERE numcli in (SELECT code FROM libelle
                         WHERE mnemo = 'RES_SANTE' AND sens = i_numporte)
          AND  codope = 1
          AND  numdecaismt IS NULL
          -- Controle dérivé de PK_VIAMEDIS_FACT => voir si pertinent
          AND NOT EXISTS (
              SELECT 1 FROM compte_client
                       WHERE compte_client.codope  = 1
                         AND compte_client.numfact = AFFECTATION.numaffec
                         AND compte_client.numcli  =  AFFECTATION.numcli )
          AND numaffec IN (SELECT DISTINCT NUMDEC FROM sinistre WHERE sinistre.NUMDEC > 0 )
    ;

    BEGIN

      -- Ctrl sur décaissement/affectation
      SELECT 1 INTO loc_erreur
                FROM decaismt,
                     ( SELECT  COUNT(NUMAFFEC)            NB_AFFEC,
                               SUM(MONTANT)               MT_TOTAL,
                               MAX(MONNAIE)               MONNAIE,
                               COUNT(DISTINCT MONNAIE)    NB_MONNAIE,
                               MAX(NUMCLI)                NUMCLI,
                               COUNT(DISTINCT NUMCLI)     NB_NUMCLI,
                               SUM(MONTANT_D)             MT_TOTAL_D,
                               MAX(MONNAIE_D)             MONNAIE_D,
                               COUNT(DISTINCT MONNAIE_D)  NB_MONNAIE_D,
                               SUM(MONTANT_CT)            MONTANT_CT,
                               MAX(DEVISE_CT)             DEVISE_CT,
                               COUNT(DISTINCT DEVISE_CT)  NB_DEVISE_CT
                               FROM AFFECTATION
                                WHERE  numcli = v_numindiv
                                  AND  codope = 1
                                  AND  numdecaismt = v_numdecaismt ) CTRL_AFFEC
        WHERE decaismt.numdecaismt = v_numdecaismt
          AND (
                 CTRL_AFFEC.NB_MONNAIE   <> 1 OR
                 CTRL_AFFEC.NB_NUMCLI    <> 1 OR
                 CTRL_AFFEC.NB_MONNAIE_D <> 1 OR
                 CTRL_AFFEC.NB_DEVISE_CT <> 1 OR
                 CTRL_AFFEC.MT_TOTAL_D   <> decaismt.MONTANT_D
              )
          ;
    -- si pas de données, contrôle ok, pas d'anomalies si erreur ORACLE pb.
    EXCEPTION
              WHEN NO_DATA_FOUND THEN
                loc_erreur := 0;
              WHEN OTHERS THEN
        o_traitOK := 'N';
        loc_msg := 'Anomalie 006: Erreur technique sur le controle décaissement/affectation pour le pour le réseau ' || f_nom_reso (i_numporte) || ': ' || SQLERRM;
        P_INS_journal(1, loc_msg);
        o_msg := loc_msg;
        RETURN;
    END;

    -- en cas d'écart, le problème vient d'une intervention sur une affectation en cours de traitement, annuler le traitement...
    IF NVL(loc_erreur, 0) > 0 THEN
      o_traitOK := 'N';
      loc_msg := 'Anomalie 006: Veuillez relancer le traitement! Au moins une affectation était en cours pour le réseau ' || f_nom_reso (i_numporte) || '.';
      P_INS_journal(1, loc_msg);
      o_msg := loc_msg;
      RETURN;
    END IF;

  -- Exception générale de la procédure
  EXCEPTION
    WHEN OTHERS THEN
      o_traitOK := 'N';
      loc_msg := 'Anomalie 006: Erreur du traitement de création de décaissement pour le réseau ' || f_nom_reso (i_numporte) || ': ' || SQLERRM;
      P_INS_journal(1, loc_msg);
      o_msg := loc_msg;
      RETURN;

END P_CREER_DECAISMT_FRES;

/***********************Procédure d'envoi de mail ****************************/
/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_SEND_RAPPORT_ENVOI_MAIL                                 */
/* Type         :  Public                                                     */
/* Description  :                                                            */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_SEND_RAPPORT_ENVOI_MAIL(i_date_session IN DATE
                                   ,i_cptrendu     IN VARCHAR2
                                   ,o_traitOK      IN CHAR)
  IS
    loc_envoi          ENVOI_MAIL%ROWTYPE;
    l_error            VARCHAR2(200);
    l_clob_body        CLOB;
    l_destinataire     VARCHAR2(60);

    CURSOR C_interlocuteurs IS
      SELECT DISTINCT(interlocuteur)
        FROM interlocuteur
        WHERE numindiv =  1     -- GEREP
        AND ope_crrr   = 10     -- Gestion GEREP
        AND VALIDE     = 'O';

  BEGIN

    IF o_traitOK = 'O' THEN
      loc_envoi.sujet := '[Rapport_ARTHUS] Rapport de traitement des frais de réseaux de soins du '
                        || TO_CHAR(i_date_session,'DD/MM/YYYY HH24:MI');
    ELSE
      loc_envoi.sujet := '[Rapport_ARTHUS] Anomalie traitement des frais de réseaux de soins du '
                        || TO_CHAR(i_date_session,'DD/MM/YYYY HH24:MI');
    END IF;

    loc_envoi.corps :=   CHR(13)||CHR(10)|| i_cptrendu ;

    GET_HTML_VARCHAR_FROM_FS('MAILS_IN', 'template_mail_rapport.html', l_clob_body);
    PK_MAIL.TRANSCODE_TEMPLATE( template_mail => l_clob_body
                              ,corps_msg     => loc_envoi.corps
                              ,numindiv      => NULL
                              ,numbene       => NULL
                              ,sujet_msg     => loc_envoi.sujet);

    FOR R_interlocuteur IN C_interlocuteurs LOOP

      l_destinataire  := f_coordonne_contact(R_interlocuteur.interlocuteur,4,1);  -- 4 = Email / 1 = Pro

      PK_MAIL.SEND_EMAIL( P_RECIPIENT     => l_destinataire
                        ,P_CC            => NULL
                        ,P_BCC           => NULL
                        ,P_SUBJECT       => loc_envoi.sujet
                        ,P_BODY          => l_clob_body
                        ,P_NUMUTIL       => 8
                        ,P_SENDER        => 'no-reply@gerep.fr'
                        ,P_NUMINDIV_DEST => NULL
                        ,P_ERROR         => l_ERROR);
      -- trace
--      DBMS_OUTPUT.PUT_LINE ('*** Debut mail ***');
--      DBMS_OUTPUT.PUT_LINE (loc_envoi.sujet);
--      DBMS_OUTPUT.PUT_LINE (l_clob_body);
--      DBMS_OUTPUT.PUT_LINE ('*** fin   mail ***');

    END LOOP;

  EXCEPTION
    WHEN  OTHERS THEN
    P_INS_journal(1,'PK_FRAIS_RESEAUX.P_SEND_RAPPORT_ENVOI_MAIL:' || sqlerrm );

END P_SEND_RAPPORT_ENVOI_MAIL;

/*---------------------------------------------------------------------------*/
/* PROCEDURE                                                                 */
/* Nom          :  P_INS_journal                                             */
/* Type         :  Public                                                    */
/* Description  :  procedure d'insertion dans journal ADM                    */
/* Retour       :                                                            */
/*---------------------------------------------------------------------------*/
PROCEDURE P_INS_journal(i_niv in NUMBER,
                        i_msg in VARCHAR2)
                        IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

  IF g_niv_msg IS NULL THEN
    BEGIN
      SELECT DECODE(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
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
        I_session  => NVL(g_session,SID),
        I_niv_msg  => i_niv,
        I_msg_adm  => SUBSTR(i_msg,1,132),
        I_idligne  => g_idligne);
  END IF;

END P_INS_journal;




END PK_FRAIS_RESEAUX;
/
