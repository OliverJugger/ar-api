CREATE OR REPLACE PACKAGE ARTHUS.PK_fic_ecrit AS

--
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
PROCEDURE P_TRAFIC_CPTA(I_Typ_Ecrit integer,
            I_Bordereau integer,
            I_Repertoire Varchar2,
            I_Fichier Varchar2,
            I_numedit Varchar2);
--
-- -------------------------------------------- Fin des procedures publiques --

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_fic_ecrit AS

-- Chaine de reconnaissance SCCS
-- %W%  %E%

-- -- CONSTANTES PRIVEES ------------------------------------------------------
--
-- ---------------------------------------------- Fin des constantes privees --

-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
--
E_PAR_REPERTOIRE_ABSENT  EXCEPTION;
E_PAR_FICHIER_ABSENT     EXCEPTION;
E_FICHIER_DESTRUCT       EXCEPTION;
-- ---------------------------------------------- Fin des exceptions privees --

-- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --

-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------




edatejours    varchar2(6);
-- G_BDX         varchar2(3);
G_DIR         varchar2(128);
G_FILE        varchar2(128);
G_SYMD        varchar2(8);
-- G_HEURE       varchar2(8);
f_w_compta    UTL_FILE.FILE_TYPE;

-- SCR 20091001 : Remise a niveau de la compta par rapport a V6(W)
-- Variables de sortie
g_date                      VARCHAR2 (8);
g_heure                     VARCHAR2 (8);
g_bdx                       VARCHAR2 (3);
g_repertoire                typ_batch.repertoire%TYPE;
g_fichier                   typ_batch.ressource%TYPE;
g_proc                      VARCHAR2 (80);
-- --

G_buffer      varchar2(512);

G_msg_adm    journal_adm.msg_adm%Type;
G_idsession  journal_adm.id_session%Type := 0;
G_idligne    journal_adm.idligne%TYPE := 0;
G_niv_msg    journal_adm.niv_msg%TYPE := 0;
G_numutil    util.numutil%Type;
G_numedit    file_edition.numedit%Type;


CURSOR C_central (I_Bordereau Number) IS
  SELECT ALL COMPTA_CENTRAL.NUMSOC,
        COMPTA_CENTRAL.CODOPE,
        COMPTA_CENTRAL.ROLESOC,
        COMPTA_CENTRAL.SCDOPE,
        COMPTA_CENTRAL.JOURNAL,
        COMPTA_CENTRAL.COMPTE,
-- SCR 20090716 : ajout compte_aux
        COMPTA_CENTRAL.COMPTE_AUX,
-- --
        COMPTA_CENTRAL.SENS,
        COMPTA_CENTRAL.MONNAIE_D,
        LTRIM(TO_CHAR((COMPTA_CENTRAL.MONTANT_D), '999999999990.00')) MONTANT_D ,
        LTRIM(TO_CHAR((COMPTA_CENTRAL.MONTANT), '999999999990.00')) MONTANT,
        COMPTA_CENTRAL.LIBELLE,
        TO_CHAR(COMPTA_CENTRAL.DATOPE, 'DD/MM/YYYY') DATOPE,
        COMPTA_CENTRAL.REFPIECE,
        TO_CHAR(COMPTA_CENTRAL.ECHEANCE, 'DD/MM/YYYY') ECHEANCE,
        COMPTA_CENTRAL.NATURE,
        COMPTA_CENTRAL.AXANA1,
        COMPTA_CENTRAL.AXANA2,
        COMPTA_CENTRAL.AXANA3,
        COMPTA_CENTRAL.AXANA4,
        COMPTA_CENTRAL.AXANA5,
        COMPTA_CENTRAL.ZONEX1,
        COMPTA_CENTRAL.ZONEX2,
        COMPTA_CENTRAL.ZONEX3,
        COMPTA_CENTRAL.ZONEX4,
        COMPTA_CENTRAL.ZONEX5,
        COMPTA_CENTRAL.ZONEX6,
        COMPTA_CENTRAL.ZONEX7,
        COMPTA_CENTRAL.ZONEX8,
        COMPTA_CENTRAL.ZONEX9,
        COMPTA_CENTRAL.ZONEX10,
        COMPTA_CENTRAL.ZONEX11,
        COMPTA_CENTRAL.ZONEX12,
        COMPTA_CENTRAL.ZONEX13,
        COMPTA_CENTRAL.ZSERV1,
        COMPTA_CENTRAL.ZSERV2,
        COMPTA_CENTRAL.ZSERV3,
        COMPTA_CENTRAL.ZSERV4,
        COMPTA_CENTRAL.ZSERV5
      FROM COMPTA_CENTRAL
      WHERE  idcompta = I_Bordereau
      ORDER BY
            COMPTA_CENTRAL.CODOPE,
            COMPTA_CENTRAL.SCDOPE,
            COMPTA_CENTRAL.JOURNAL,
            COMPTA_CENTRAL.REFPIECE,
            COMPTA_CENTRAL.COMPTE,
-- SCR 20090716 : ajout compte_aux
            COMPTA_CENTRAL.COMPTE_AUX,
-- --
            COMPTA_CENTRAL.SENS,
            COMPTA_CENTRAL.LIBELLE,
            COMPTA_CENTRAL.MONTANT;
          /*COMPTA_CENTRAL.ROLESOC,
          COMPTA_CENTRAL.CODOPE,
          COMPTA_CENTRAL.SCDOPE,
          COMPTA_CENTRAL.REFPIECE;*/

  R_central  C_central%ROWTYPE;
--
-- -------------------------------------- Fin des variables globales privees --

-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--
PROCEDURE p_nom_fichier;

PROCEDURE p_ins_journal;

-- ----------------------------------------------------------------------------------------
--
-- Formatage du nom de fichier (variable G_fichier)
--
-- ----------------------------------------------------------------------------------------
PROCEDURE p_nom_fichier
IS
BEGIN
--
      g_proc := 'p_nom_fichier';
--
   --
      g_date := TO_CHAR (SYSDATE, 'YYYYMMDD');

      --
      /*
      SELECT REPLACE (TO_CHAR (SYSDATE, 'fmHH24:MI:SS'), ':', '-')
        INTO g_heure
        FROM DUAL;
      */
      g_heure := REPLACE (TO_CHAR (SYSDATE, 'fmHH24:MI:SS'), ':', '-');


      --
      /*
      --SELECT REPLACE (REPLACE (REPLACE (g_fichier, '#DT', g_date),
      SELECT REPLACE (REPLACE (REPLACE (G_FILE, '#DT', g_date),
                               '#HR',
                               g_heure
                              ),
                      '#BDX',
                      g_bdx
                     )
        INTO G_FILE
        FROM DUAL;
      */
      G_FILE := REPLACE (REPLACE (REPLACE (G_FILE, '#DT', g_date),
                                  '#HR',
                                  g_heure
                                 ),
                         '#BDX',
                         g_bdx
                        );

--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         p_ins_journal;
--
END p_nom_fichier;


-- Insertion dans journal_adm
Procedure P_INS_journal
IS
BEGIN
  G_idligne := G_idligne + 1;
  PK_trace.P_INS_journal_adm (
    I_nom_traitement => 'PK_fic_ecrit',
    I_session   => G_idsession,
    I_niv_msg   => G_niv_msg,
    I_msg_adm   => G_msg_adm,
    I_idligne   => G_idligne);
END P_INS_journal;

-- ********************************************************************
--
-- ******************************************************************
-- Lecture du fichier des professionnels de santé et population des tables
-- de travail pour la future mise à jour du référentiel "personnes"

PROCEDURE P_TRAFIC_CPTA(I_Typ_Ecrit integer,
            I_Bordereau integer,
            I_Repertoire Varchar2,
            I_Fichier Varchar2,
            I_numedit Varchar2)
IS
BEGIN
--
  G_niv_msg    := 2;
  -- G_idsession   := G_idsession + 1;
  G_BDX          := lpad(nvl(to_char(I_Bordereau),'0'), 3, '0');
  G_idsession    := I_numedit;
  G_idligne     := 0;
  G_numedit    := I_numedit;
  G_SYMD          := To_Char(SYSDATE, 'YYYYMMDD');
  G_FILE       := NULL;
  G_DIR        := NULL;
    Select replace(to_char(sysdate,'fmHH24:MI:SS'),':','-')
            Into G_heure
            From dual;

  G_msg_adm    := 'Paramètres < '||TO_CHAR(I_Typ_Ecrit)||'>< '||to_char(I_Bordereau)||'>< '||
            to_char(I_Repertoire)||'>< '||to_char(I_Fichier)||'>< '||to_char(I_numedit)||'>';
  P_INS_journal;

-- SCR : 20091001 : Comme en DEV


  IF (i_repertoire IS NULL) OR (i_repertoire = '') THEN
    G_DIR := 'EXPORT';
  ELSE
    G_DIR := i_repertoire;
  END IF;

  IF (i_fichier IS NULL) OR (i_fichier = '') THEN
    G_FILE := 'CPT_#DT_#BDX_#HR.csv';
  ELSE
    G_FILE := i_fichier || '.csv';
    -- RAISE E_PAR_FICHIER_ABSENT;
  END IF;

-- SCR : 20091001
-- Formatage du nom de fichier
  p_nom_fichier;
-- --

  g_msg_adm :=
        'Paramètres < '
     || TO_CHAR (i_typ_ecrit)
     || '>< '
     || TO_CHAR (i_bordereau)
     || '>< '
     || TO_CHAR (G_DIR)
     || '>< '
     || TO_CHAR (G_FILE)
     || '>< '
     || TO_CHAR (g_numedit)
     || '>';
  p_ins_journal;




-- SCR 20091001 ; INUTILE
/*
  If I_Repertoire is not null or I_Repertoire <> '' Then
    G_DIR := I_Repertoire;
  else
    G_DIR := 'EXPORT';
  End If;
*/

-- SCR : 20091001
/*

  If I_Fichier is not null or I_Fichier <> '' Then
    -- G_FILE := I_Fichier||'_'||G_numedit||'.txt';
    G_FILE := UPPER(I_Fichier)||'_'||G_SYMD||'_'||G_BDX||'_'||G_heure||'.csv';
  else
    --G_FILE := G_FILE||G_numedit||'.txt';
    G_FILE := 'CPTA_'||G_SYMD||'_'||G_BDX||'_'||G_heure||'.csv';
  End If;
*/

  /* Recherche de l'utilisateur ayant fait la demande */
  SELECT
      util.numutil
  Into  G_numutil
  From  util,
      file_edition
  Where  util.nom = file_edition.userid
      and  file_edition.numedit = I_numedit;

  -- Ouverture du fichier des écritures comptables
  G_niv_msg    := 1;
  G_msg_adm    := 'Debut de traitement le ' ||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
  P_INS_journal;
  G_niv_msg    := 2;
  G_msg_adm    := 'Nom du fichier passe en parametre < '||TO_CHAR(G_FILE)||'>';
  P_INS_journal;
  --G_niv_msg    := 1;


  G_niv_msg    := 2;
  G_msg_adm    := 'Ouverture du fichier  < '||TO_CHAR(G_FILE)||'>';
  P_INS_journal;

  f_w_compta := UTL_FILE.FOPEN (G_DIR, G_FILE, 'W');

-- SCR : 20091001
  -- f_w_compta := UTL_FILE.FOPEN('EXPORT',G_FILE,'W');
  G_msg_adm    := 'Fichier  < '||TO_CHAR(G_FILE)||'> ouvert';
  P_INS_journal;

/* SCR 20091001 INUTILE
  IF (I_Typ_Ecrit = 1) THEN
    NULL;
  ELSE
*/

    /* Mise à jour de remise_compta_globale */
    UPDATE remise_compta_globale
       SET transmission = Sysdate,
           transmetteur = G_numutil
     WHERE idcompta = I_Bordereau;

    COMMIT;

        G_buffer := f_delimite('NUMSOC')||';'||
        f_delimite('CODOPE', '"' ) ||';'||
        f_delimite('ROLESOC', '"' ) ||';'||
        f_delimite('SCDOPE', '"' ) ||';'||
        f_delimite('JOURNAL', '"' ) ||';'||
        f_delimite('COMPTE', '"' ) ||';'||
        f_delimite('SENS', '"' ) ||';'||
        f_delimite('DEVISE') ||';'||
        f_delimite('MONTANT_D') ||';'||
        f_delimite('MONTANT') ||';'||
        f_delimite('LIBELLE','"' ) ||';'||
        f_delimite('DATOPE','"' ) ||';'||
        f_delimite('REFPIECE','"' ) ||';'||
        f_delimite('ECHEANCE','"' ) ||';'||
        f_delimite('NATURE','"' ) ||';'||
        f_delimite('AXANA1','"' ) ||';'||
        f_delimite('AXANA2','"' ) ||';'||
        f_delimite('AXANA3','"' ) ||';'||
        f_delimite('AXANA4','"' ) ||';'||
        f_delimite('AXANA5','"' ) ||';'||
        f_delimite('ZONEX1','"' ) ||';'||
        f_delimite('ZONEX2','"' ) ||';'||
        f_delimite('ZONEX3','"' ) ||';'||
        f_delimite('ZONEX4','"' ) ||';'||
        f_delimite('ZONEX5','"' ) ||';'||
        f_delimite('ZSERV1','"' ) ||';'||
        f_delimite('ZSERV2','"' ) ||';'||
        f_delimite('ZSERV3','"' ) ||';'||
        f_delimite('ZSERV4','"' ) ||';'||
        f_delimite('ZSERV5','"' ) ||';'||
-- SCR 20090716 : ajout compte_aux
        f_delimite('COMPTE_AUX', '"' ) ||';'||
        f_delimite('ZONEX6','"' ) ||';'||
        f_delimite('ZONEX7','"' ) ||';'||
        f_delimite('ZONEX8','"' ) ||';'||
        f_delimite('ZONEX9','"' ) ||';'||
        f_delimite('ZONEX10','"' ) ||';'||
        f_delimite('ZONEX11','"' ) ||';'||
        f_delimite('ZONEX12','"' ) ||';'||
        f_delimite('ZONEX13','"' );
-- --
        UTL_FILE.PUT_LINE(f_w_compta,G_buffer);

    FOR V_central IN C_central (I_Bordereau) LOOP
      R_central := V_central;
      G_buffer := '';
      SELECT
        R_CENTRAL.NUMSOC||';'||
        f_delimite (R_CENTRAL.CODOPE, '"' ) ||';'||
        f_delimite (R_CENTRAL.ROLESOC, '"' ) ||';'||
        f_delimite (R_CENTRAL.SCDOPE, '"' ) ||';'||
        f_delimite (R_CENTRAL.JOURNAL, '"' ) ||';'||
        f_delimite (R_CENTRAL.COMPTE, '"' ) ||';'||
        f_delimite (R_CENTRAL.SENS, '"' ) ||';'||
        substr(PK_DEVISE.SYMBOLE(R_CENTRAL.MONNAIE_D),1,3) ||';'||
        R_CENTRAL.MONTANT_D ||';'||
        R_CENTRAL.MONTANT ||';'||
        f_delimite(f_desaccentue(UPPER(R_CENTRAL.LIBELLE)),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.DATOPE),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.REFPIECE),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ECHEANCE),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.NATURE),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.AXANA1),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.AXANA2),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.AXANA3),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.AXANA4),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.AXANA5),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZONEX1),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZONEX2),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZONEX3),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZONEX4),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZONEX5),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZSERV1),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZSERV2),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZSERV3),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZSERV4),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZSERV5),'"' ) ||';'||
-- SCR 20090716 : ajout compte_aux
        f_delimite (R_CENTRAL.COMPTE_AUX, '"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZONEX6),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZONEX7),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZONEX8),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZONEX9),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZONEX10),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZONEX11),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZONEX12),'"' ) ||';'||
        f_delimite(f_desaccentue(R_CENTRAL.ZONEX13),'"' )
-- --
      Into  G_buffer
      From  Dual;
        UTL_FILE.PUT_LINE(f_w_compta,G_buffer);
            EXIT WHEN C_central%NOTFOUND;
    END LOOP;
    IF C_central%ISOPEN THEN
      CLOSE C_central;
    END IF;

-- SCR 20091001
--   END IF; /* FIN */



  UTL_FILE.FCLOSE(f_w_compta);


    G_niv_msg    := 1;
    G_msg_adm  := 'Fin Normale du traitement le ' ||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
    P_INS_journal;

EXCEPTION
  WHEN NO_DATA_FOUND then
  G_msg_adm    := 'Rien à écrire';
--  Insertion dans journal_adm du message d'erreur
  P_INS_journal;
  DBMS_OUTPUT.PUT_LINE(G_msg_adm);

  WHEN E_PAR_REPERTOIRE_ABSENT then
  G_msg_adm    := 'Nom du répertoire de sortie manquant';
--  Insertion dans journal_adm du message d'erreur
  P_INS_journal;
  DBMS_OUTPUT.PUT_LINE(G_msg_adm);

  WHEN E_PAR_FICHIER_ABSENT Then
  G_msg_adm    := 'Nom du fichier de sortie manquant';
--  Insertion dans journal_adm du message d'erreur
  P_INS_journal;
  DBMS_OUTPUT.PUT_LINE(G_msg_adm);

  WHEN E_FICHIER_DESTRUCT Then
  G_msg_adm    := 'Structure du fichier '||I_Fichier||' invalide';
--  Insertion dans journal_adm du message d'erreur
  P_INS_journal;
  DBMS_OUTPUT.PUT_LINE(G_msg_adm);

  WHEN UTL_FILE.INTERNAL_ERROR THEN
  --Rollback;
  G_msg_adm    := 'UTL_FILE.INTERNAL_ERROR';
--  Insertion dans journal_adm du message d'erreur
  P_INS_journal;
  DBMS_OUTPUT.PUT_LINE(G_msg_adm);
  UTL_FILE.FCLOSE(f_w_compta);

  WHEN UTL_FILE.INVALID_FILEHANDLE THEN
  --Rollback;
  G_msg_adm    := 'UTL_FILE.INVALID_FILEHANDLE';
--  Insertion dans journal_adm du message d'erreur
  P_INS_journal;
  DBMS_OUTPUT.PUT_LINE(G_msg_adm);
  UTL_FILE.FCLOSE(f_w_compta);

  WHEN UTL_FILE.INVALID_MODE THEN
  --Rollback;
  G_msg_adm    := 'UTL_FILE.INVALID_MODE';
--  Insertion dans journal_adm du message d'erreur
  P_INS_journal;
  DBMS_OUTPUT.PUT_LINE(G_msg_adm);
  UTL_FILE.FCLOSE(f_w_compta);

  WHEN UTL_FILE.INVALID_OPERATION THEN
  --Rollback;
  G_msg_adm    := 'UTL_FILE.INVALID_OPERATION';
--  Insertion dans journal_adm du message d'erreur
  P_INS_journal;
  DBMS_OUTPUT.PUT_LINE(G_msg_adm);
  UTL_FILE.FCLOSE(f_w_compta);

  WHEN UTL_FILE.INVALID_PATH THEN
  --Rollback;
  G_msg_adm    := 'UTL_FILE.INVALID_PATH';
--  Insertion dans journal_adm du message d'erreur
  P_INS_journal;
  DBMS_OUTPUT.PUT_LINE(G_msg_adm);
  UTL_FILE.FCLOSE(f_w_compta);

  WHEN UTL_FILE.READ_ERROR THEN
  --Rollback;
  G_msg_adm    := 'UTL_FILE.READ_ERROR';
--  Insertion dans journal_adm du message d'erreur
  P_INS_journal;
  DBMS_OUTPUT.PUT_LINE(G_msg_adm);
  UTL_FILE.FCLOSE(f_w_compta);

  WHEN UTL_FILE.WRITE_ERROR THEN
  --Rollback;
  G_msg_adm    := 'UTL_FILE.WRITE_ERROR';
--  Insertion dans journal_adm du message d'erreur
  P_INS_journal;
  DBMS_OUTPUT.PUT_LINE(G_msg_adm);
  UTL_FILE.FCLOSE(f_w_compta);

  WHEN OTHERS THEN
  --Rollback;
  G_msg_adm    := SUBSTR(SQLERRM(SQLCODE),1,128);
--  Insertion dans journal_adm du message d'erreur
  P_INS_journal;
  DBMS_OUTPUT.PUT_LINE(' ... Erreur ? ? ? ');
  DBMS_OUTPUT.PUT_LINE(G_msg_adm);
  if UTL_FILE.IS_OPEN(f_w_compta) then
    UTL_FILE.FCLOSE(f_w_compta);
  end if;
END P_TRAFIC_CPTA;

END PK_fic_ecrit;
/
