CREATE OR REPLACE PACKAGE ARTHUS.pk_sinistre AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_sinistre.sql  1.1  01/11/06

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
   PROCEDURE p_exe_gs14_usrxit (
      i_username_id   IN   travsn.username%TYPE,
      i_ref           IN   sntr_ref.REF%TYPE,
      i_sid           IN   travsn.SID%TYPE
   );

--
   PROCEDURE p_exe_gs14_proc (
      i_username_id   IN   travsn.username%TYPE,
      i_numremise     IN   sntr_ref.REF%TYPE,
      i_sid           IN   travsn.SID%TYPE
   );
--
----------------------------------------------------------------------------
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_sinistre AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_sinistre.sql  1.1  01/11/06

   -- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --

   -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions privees --

   -- -- TYPES PRIVEES -----------------------------------------------------------
--
   CURSOR c_travsn (
      p_username_id   travsn.username%TYPE,
      p_sid           travsn.SID%TYPE
   )
   IS
      SELECT numsin, username, codfrais, numgar, numindiv, mtfrais, nbacte,
             datsai, codmon, nummath, x, y, frcg1, frcg2, frcg3, frcg4, frcg5,
             frcg6, frcg7, frcg8, frcg9, frcg10
        FROM travsn
       WHERE username = p_username_id
         AND SID = p_sid
         AND (   1 IN
                    (frcg1,
                     frcg2,
                     frcg3,
                     frcg4,
                     frcg5,
                     frcg6,
                     frcg7,
                     frcg8,
                     frcg9,
                     frcg10
                    )
              OR 2 IN
                    (frcg1,
                     frcg2,
                     frcg3,
                     frcg4,
                     frcg5,
                     frcg6,
                     frcg7,
                     frcg8,
                     frcg9,
                     frcg10
                    )
              OR 3 IN
                    (frcg1,
                     frcg2,
                     frcg3,
                     frcg4,
                     frcg5,
                     frcg6,
                     frcg7,
                     frcg8,
                     frcg9,
                     frcg10
                    )
             );

-- JPF 08/01/2005 AND     mtprest   >= 0;
--
--
-- --------------------------------------------------- Fin des types privees --

   -- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
-- Aucune
-- -------------------------------------- Fin des variables globales privees --

   -- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--
   PROCEDURE p_lock_sntr;

   --
   PROCEDURE p_ins_sinistre (
      i_flag_amp      IN   NUMBER,
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   );

   --
   PROCEDURE p_ins_sinistre_dev (
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   );

   --
   PROCEDURE p_ins_sntr_ref_usrxit (
      i_username_id   IN   travsn.username%TYPE,
      i_ref           IN   sntr_ref.REF%TYPE,
      i_sid           IN   travsn.SID%TYPE
   );

   --
   PROCEDURE p_ins_sntr_ref_proc (
      i_username_id   IN   travsn.username%TYPE,
      i_numremise     IN   sntr_ref.REF%TYPE,
      i_sid           IN   travsn.SID%TYPE
   );

   --
   PROCEDURE p_upd_sinistre_porte (
      i_numremise     IN   sinistre_porte.numremise%TYPE,
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   );

   --
   PROCEDURE p_sel_travsn (
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   );

   --
   PROCEDURE p_sel_frcg1_a_10 (i_rec_c_travsn IN c_travsn%ROWTYPE);

   --
   PROCEDURE p_ins_forcage (
      i_rec_c_travsn   IN   c_travsn%ROWTYPE,
      i_type           IN   forcage.TYPE%TYPE
   );

   --
   PROCEDURE p_del_travsn (
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   );

   --
   PROCEDURE p_ins_plafond (
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   );

   PROCEDURE p_ins_sntr_saisi (
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   );

   -- ----------------------------- Fin des declarations des procedures privees --

   -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--
   PROCEDURE p_exe_gs14_usrxit (
      i_username_id   IN   travsn.username%TYPE,
      i_ref           IN   sntr_ref.REF%TYPE,
      i_sid           IN   travsn.SID%TYPE
   )
   IS
      --
      l_code_msg   mess_erreur.code_msg%TYPE;
      l_lib_msg    mess_erreur.lib_msg%TYPE;
   --
   BEGIN
      p_lock_sntr;
      --
      p_ins_sinistre (i_flag_amp         => 1,
                      i_username_id      => i_username_id,
                      i_sid              => i_sid
                     );
      --
      p_ins_sinistre_dev (i_username_id => i_username_id, i_sid => i_sid);
      --
      p_ins_sntr_ref_usrxit (i_username_id      => i_username_id,
                             i_ref              => i_ref,
                             i_sid              => i_sid
                            );
      --
      p_ins_plafond(i_username_id => i_username_id, i_sid => i_sid);
	  --
	  p_ins_sntr_saisi(i_username_id => i_username_id, i_sid => i_sid);
      --
      p_sel_travsn (i_username_id => i_username_id, i_sid => i_sid);
      --
      p_del_travsn (i_username_id => i_username_id, i_sid => i_sid);
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         l_code_msg := 20001;
         --
         -- Recherche du message dans la table
         l_lib_msg :=
            pk_trace.f_aff_mess_err (i_code_msg         => l_code_msg,
                                     i_code_pays        => 1,
                                     i_liste_param      => 'pk_sinistre '
                                    );
         --
         -- message de la table + erreur Oracle
         l_lib_msg :=
            l_lib_msg
            || SUBSTR (SQLERRM (SQLCODE), 1, 80 - LENGTH (l_lib_msg));
         --
         -- Retour du message vers les postes clients a trapper(dans Sqlforms) par
         -- le "when others" --> procedure "message_oracle" et STOP --> "RAISE
         -- Form_trigger_failure"
         raise_application_error ((l_code_msg * -1), l_lib_msg);
--
   END;

--
--
   PROCEDURE p_exe_gs14_proc (
      i_username_id   IN   travsn.username%TYPE,
      i_numremise     IN   sntr_ref.REF%TYPE,
      i_sid           IN   travsn.SID%TYPE
   )
   IS
--
      l_code_msg   mess_erreur.code_msg%TYPE;
      l_lib_msg    mess_erreur.lib_msg%TYPE;
--
   BEGIN
      p_lock_sntr;
      --
      p_ins_sinistre (i_flag_amp         => 3,
                      i_username_id      => i_username_id,
                      i_sid              => i_sid
                     );
      --
      p_ins_sntr_ref_proc (i_username_id      => i_username_id,
                           i_numremise        => i_numremise,
                           i_sid              => i_sid
                          );
      --
      p_upd_sinistre_porte (i_numremise        => i_numremise,
                            i_username_id      => i_username_id,
                            i_sid              => i_sid
                           );
      --
      p_del_travsn (i_username_id => i_username_id, i_sid => i_sid);
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         l_code_msg := 20001;
         --
         -- Recherche du message dans la table
         l_lib_msg :=
            pk_trace.f_aff_mess_err (i_code_msg         => l_code_msg,
                                     i_code_pays        => 1,
                                     i_liste_param      => 'pk_sinistre '
                                    );
         --
         -- message de la table + erreur Oracle
         l_lib_msg :=
            l_lib_msg
            || SUBSTR (SQLERRM (SQLCODE), 1, 80 - LENGTH (l_lib_msg));
         --
         -- Retour du message vers les postes clients(sqlforms)
         raise_application_error ((l_code_msg * -1), l_lib_msg);
--
   END;

--
-- ---------------------------------- Fin des corps des procedures publiques --

   -- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--
   PROCEDURE p_lock_sntr
   IS
--
   BEGIN
      LOCK TABLE sntr IN SHARE UPDATE MODE;
   END;

--
--
   PROCEDURE p_ins_sinistre (
      i_flag_amp      IN   NUMBER,
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   )
   IS
--
      l_flag_amp   VARCHAR2 (1);
--
   BEGIN
      --
      IF i_flag_amp = 1
      THEN
         l_flag_amp := 'a';
      ELSIF i_flag_amp = 2
      THEN
         l_flag_amp := 'm';
      ELSIF i_flag_amp = 3
      THEN
         l_flag_amp := 'p';
      END IF;
  /* pk_trace.P_INS_journal_adm  ( 'p_ins_sinistre',sid,3,'i_username_id:'||to_char(i_username_id),SYSDATE,1);
    pk_trace.P_INS_journal_adm  ( 'p_ins_sinistre',sid,3,' i_SID:'||to_char(i_sid),SYSDATE,1);
    pk_trace.P_INS_journal_adm  ( 'p_ins_sinistre',sid,3,'i_flag_amp:'||to_char(i_flag_amp),SYSDATE,1);
  */
      -- Insertion des sinistres
      INSERT
      INTO sinistre
        (
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
      SELECT codfrais,
        numgar,
        numindiv,
        datsin,
        mtprest,
        mtremb,
        mtfrais,
        NVL(datsai,sysdate),
        nbacte,
        autrb,
        NULL,
        sens,
        NULL,
        mtreel,
        0,
        numassu,
        numbene,
        numsin,
        NULL,
        username,
        l_flag_amp,
        typbene,
        numpopu,
        numpopu,
        nummath,
        idadhesion,
        x,
        y,
        numpc,
        codmon,
        pdsqls,
        racmon,
        spe_exe,
        fra_dep,
        baseremb,
        taux,
        cas
      FROM travsn
      WHERE travsn.username = i_username_id
      AND travsn.numsin    IS NOT NULL
      AND travsn.SID        = i_sid;
   -- JPF 08/01/2005 and   TRAVSN.MTPREST >= 0;

  --  pk_trace.P_INS_journal_adm  ( 'p_ins_sinistre',sid,3,'FIN OK:'||to_char(i_sid),SYSDATE,1);

   END;

--
--
   PROCEDURE p_ins_sinistre_dev (
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   )
   IS
   BEGIN
      -- Insertion dans sinistres_dev
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
      SELECT numsin,
        codmon,
        codmon,
        codmon,
        nvl(mtfrais,0),
        nvl(mtfrais,0),
        nvl(mtfrais,0),
        nvl(mtprest,0),
        nvl(mtprest,0),
        nvl(mtprest,0),
        nvl(mtremb,0),
        nvl(mtremb,0),
        nvl(mtremb,0),
        nvl(mtreel,0),
        nvl(mtreel,0),
        nvl(mtreel,0),
        nvl(autrb,0),
        nvl(autrb,0),
        nvl(autrb,0)
      FROM travsn
      WHERE travsn.username = i_username_id
      AND travsn.numsin    IS NOT NULL
      AND travsn.SID        = i_sid;
   -- JPF 08/01/2005   and   TRAVSN.MTPREST >= 0;
   END;

--
--
   PROCEDURE p_ins_sntr_ref_usrxit (
      i_username_id   IN   travsn.username%TYPE,
      i_ref           IN   sntr_ref.REF%TYPE,
      i_sid           IN   travsn.SID%TYPE
   )
   IS
   BEGIN
      INSERT INTO sntr_ref
                  (numsin, REF, numremise, numsin_porte)
         SELECT numsin, i_ref, NULL, NULL
           FROM travsn
          WHERE travsn.username = i_username_id
            AND travsn.numpc != 0
            AND travsn.SID = i_sid;
   END;

--
--
   PROCEDURE p_ins_sntr_ref_proc (
      i_username_id   IN   travsn.username%TYPE,
      i_numremise     IN   sntr_ref.REF%TYPE,
      i_sid           IN   travsn.SID%TYPE
   )
   IS
   BEGIN
      INSERT INTO sntr_ref
                  (numsin, REF, numremise, numsin_porte)
         SELECT numsin, i_numremise, i_numremise, numlig
           FROM travsn
          WHERE travsn.username = i_username_id AND travsn.SID = i_sid;
   END;

--
--
   PROCEDURE p_upd_sinistre_porte (
      i_numremise     IN   sinistre_porte.numremise%TYPE,
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   )
   IS
   BEGIN
      UPDATE sinistre_porte
         SET etat = 1
       WHERE numremise = i_numremise
         AND numsin IN (SELECT numlig
                          FROM travsn
                         WHERE username = i_username_id AND SID = i_sid);
   END;

--
--
   PROCEDURE p_sel_travsn (
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   )
   IS
--
-- Variable de type Curseur declare au niveau global Prive (PACKAGE BODY)
      rec_c_travsn   c_travsn%ROWTYPE;
--
   BEGIN
      OPEN c_travsn (p_username_id => i_username_id, p_sid => i_sid);

      LOOP
         FETCH c_travsn
          INTO rec_c_travsn;

         EXIT WHEN c_travsn%NOTFOUND;
         --
         -- Recherche des forcages ("frcg1 a frcg10=1" pour insertion dans forcage)
         p_sel_frcg1_a_10 (i_rec_c_travsn => rec_c_travsn);

      --
      END LOOP;

      CLOSE c_travsn;
   END;

--
--
   PROCEDURE p_sel_frcg1_a_10 (i_rec_c_travsn IN c_travsn%ROWTYPE)
   IS
   BEGIN
      IF i_rec_c_travsn.frcg1 = 1 OR i_rec_c_travsn.frcg1 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 1);
      END IF;

      --
      IF i_rec_c_travsn.frcg1 = 2 OR i_rec_c_travsn.frcg1 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 11);
      END IF;

      --
      IF i_rec_c_travsn.frcg2 = 1 OR i_rec_c_travsn.frcg2 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 2);
      END IF;

      --
      IF i_rec_c_travsn.frcg2 = 2 OR i_rec_c_travsn.frcg2 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 12);
      END IF;

      --
      IF i_rec_c_travsn.frcg3 = 1 OR i_rec_c_travsn.frcg3 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 3);
      END IF;

      --
      IF i_rec_c_travsn.frcg3 = 2 OR i_rec_c_travsn.frcg3 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 13);
      END IF;

      --
      IF i_rec_c_travsn.frcg4 = 1 OR i_rec_c_travsn.frcg4 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 4);
      END IF;

      --
      IF i_rec_c_travsn.frcg4 = 2 OR i_rec_c_travsn.frcg4 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 14);
      END IF;

      --
      IF i_rec_c_travsn.frcg5 = 1 OR i_rec_c_travsn.frcg5 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 5);
      END IF;

      --
      IF i_rec_c_travsn.frcg5 = 2 OR i_rec_c_travsn.frcg5 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 15);
      END IF;

      --
      IF i_rec_c_travsn.frcg6 = 1 OR i_rec_c_travsn.frcg6 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 6);
      END IF;

      --
      IF i_rec_c_travsn.frcg6 = 2 OR i_rec_c_travsn.frcg6 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 16);
      END IF;

      --
      IF i_rec_c_travsn.frcg7 = 1 OR i_rec_c_travsn.frcg7 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 7);
      END IF;

      --
      IF i_rec_c_travsn.frcg7 = 2 OR i_rec_c_travsn.frcg7 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 17);
      END IF;

      --
      IF i_rec_c_travsn.frcg8 = 1 OR i_rec_c_travsn.frcg8 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 8);
      END IF;

      --
      IF i_rec_c_travsn.frcg8 = 2 OR i_rec_c_travsn.frcg8 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 18);
      END IF;

      --
      IF i_rec_c_travsn.frcg9 = 1 OR i_rec_c_travsn.frcg9 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 9);
      END IF;

      --
      IF i_rec_c_travsn.frcg9 = 2 OR i_rec_c_travsn.frcg9 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 19);
      END IF;

      --
      IF i_rec_c_travsn.frcg10 = 1 OR i_rec_c_travsn.frcg10 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 10);
      END IF;

      --
      IF i_rec_c_travsn.frcg10 = 2 OR i_rec_c_travsn.frcg10 = 3
      THEN
         p_ins_forcage (i_rec_c_travsn => i_rec_c_travsn, i_type => 20);
      END IF;
   END;

--
--
  PROCEDURE P_INS_forcage(
      I_Rec_C_travsn IN C_travsn%ROWTYPE,
      I_type         IN Forcage.type%TYPE)
  IS
  BEGIN
    INSERT
    INTO FORCAGE
      (
        numsin,
        username,
        codfrais,
        numgar,
        numindiv,
        mtfrais,
        nbacte,
        datsai,
        codmon,
        nummath,
        x,
        y,
        type,
        MTFRAIS_D,
        CODMON_D
      )
      VALUES
      (
        I_Rec_C_travsn.numsin,
        I_Rec_C_travsn.username,
        I_Rec_C_travsn.codfrais,
        I_Rec_C_travsn.numgar,
        I_Rec_C_travsn.numindiv,
        I_Rec_C_travsn.mtfrais,
        I_Rec_C_travsn.nbacte,
        NVL(I_Rec_C_travsn.datsai, sysdate),
        I_Rec_C_travsn.codmon,
        I_Rec_C_travsn.nummath,
        I_Rec_C_travsn.x,
        I_Rec_C_travsn.y,
        I_type,
        I_Rec_C_travsn.mtfrais,
        I_Rec_C_travsn.codmon
      );
  END;

--
--
   PROCEDURE p_del_travsn (
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   )
   IS
   BEGIN

    DELETE FROM trav_plafond
    WHERE numsin IN (
      SELECT numsin FROM TRAVSN
            WHERE username = i_username_id AND SID = i_sid);
    DELETE FROM trav_saisie
    WHERE numsin IN (
      SELECT numsin FROM TRAVSN
            WHERE username = i_username_id AND SID = i_sid);
    --
      DELETE FROM travsn
            WHERE username = i_username_id AND SID = i_sid;
   --
   END;


   PROCEDURE p_ins_plafond (
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   )
   IS
   BEGIN
      -- Insertion dans histo_plafond
      INSERT
      INTO histo_plafond
        (
          numsin,
          numfor,
      codfrais,
      nature,
      etendue,
      nbactes,
      montant,
      indice,
      nbindice,
      taux,
      nummath,
      nummath_c,
      deb_conso,
      fin_conso,
      conso_mt,
      conso_nb,
      plfd_mt,
      plfd_nb,
      codano
        )
      SELECT numsin,
          numfor,
      codfrais,
      nature,
      etendue,
      nbactes,
      montant,
      indice,
      nbindice,
      taux,
      nummath,
      nummath_c,
      deb_conso,
      fin_conso,
      conso_mt,
      conso_nb,
      plfd_mt,
      plfd_nb,
      codano
      FROM trav_plafond
      WHERE numsin  IN (
      SELECT numsin FROM travsn
    WHERE username = i_username_id AND SID = i_sid);

   END;

   PROCEDURE p_ins_sntr_saisi (
      i_username_id   IN   travsn.username%TYPE,
      i_sid           IN   travsn.SID%TYPE
   )
   IS
   BEGIN
      -- Insertion dans sinsitre_dent
      INSERT INTO sinistre_dent  ( NUMLIG
        , USERNAME
        , NUMSIN
        , LOCDENT1
        , LOCDENT2
        , LOCDENT3
        , LOCDENT4
        , LOCDENT5
        , LOCDENT6
        , LOCDENT7
        , LOCDENT8
        , LOCDENT9
        , LOCDENT10
        , LOCDENT11
        , LOCDENT12
        , LOCDENT13
        , LOCDENT14
        , LOCDENT15
        , LOCDENT16
        )
      SELECT
         TRAV_SAISIE.NUMLIG
        , TRAV_SAISIE.USERNAME
        , TRAVSN.NUMSIN
        , LOCDENT1
        , LOCDENT2
        , LOCDENT3
        , LOCDENT4
        , LOCDENT5
        , LOCDENT6
        , LOCDENT7
        , LOCDENT8
        , LOCDENT9
        , LOCDENT10
        , LOCDENT11
        , LOCDENT12
        , LOCDENT13
        , LOCDENT14
        , LOCDENT15
        , LOCDENT16
     FROM TRAV_SAISIE, TRAVSN
   WHERE TRAVSN.USERNAME = TRAV_SAISIE.USERNAME
   AND TRAVSN.SID = TRAV_SAISIE.SID
   --AND TRAVSN.NUMSIN = TRAV_SAISIE.NUMSIN -- cas doubles numfor en saisie manuelle
   AND TRAVSN.NUMLIG = TRAV_SAISIE.NUMLIG
   AND TRAVSN.NUMSIN is not null
   AND TRAVSN.MTPREST >= 0
   AND TRAV_SAISIE.SID = i_sid
   AND TRAV_SAISIE.USERNAME = i_username_id;
   --AND TRAV_SAISIE.NUMSIN is not null;

  INSERT INTO SINISTRE_VERRE
    ( NUMLIG
    , USERNAME
    , NUMSIN
    , OEIL
    , SPHERE
    , CYLINDRE
    , ADDITION
    , AXE
    )
  SELECT
      TRAV_SAISIE.NUMLIG
    , TRAV_SAISIE.USERNAME
    , TRAVSN.NUMSIN
    , OEIL
    , SPHERE
    , CYLINDRE
    , ADDITION
    , AXE
 FROM TRAV_SAISIE , TRAVSN
 WHERE TRAVSN.USERNAME = TRAV_SAISIE.USERNAME
   AND TRAVSN.SID = TRAV_SAISIE.SID
   AND TRAVSN.NUMLIG = TRAV_SAISIE.NUMLIG
   AND TRAVSN.NUMSIN is not null
   AND TRAV_SAISIE.SID = i_sid
   AND TRAV_SAISIE.USERNAME = i_username_id
   AND TRAV_SAISIE.OEIL IS NOT NULL;
END p_ins_sntr_saisi;


-- ------------------------------------ Fin des corps des procedures privees --
END;
/
