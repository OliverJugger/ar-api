CREATE OR REPLACE PACKAGE ARTHUS."PK_DEV_QG08B"
AS
--
   PROCEDURE p_dev_qg08b (
      i_deb_numsoc     IN       v_trav_reversement.numsoc%TYPE DEFAULT NULL,
      i_fin_numsoc     IN       v_trav_reversement.numsoc%TYPE DEFAULT NULL,
      i_deb_numorg     IN       v_trav_reversement.numorg%TYPE DEFAULT NULL,
      i_fin_numorg     IN       v_trav_reversement.numorg%TYPE DEFAULT NULL,
      i_deb_ref_chap   IN       v_trav_reversement.refcie_chapeau%TYPE
            DEFAULT NULL,
      i_fin_ref_chap   IN       v_trav_reversement.refcie_chapeau%TYPE
            DEFAULT NULL,
      i_deb_numgar     IN       v_trav_reversement.numgar%TYPE DEFAULT NULL,
      i_fin_numgar     IN       v_trav_reversement.numgar%TYPE DEFAULT NULL,
      i_dataffec       IN       VARCHAR2 DEFAULT NULL,
      i_dateche        IN       VARCHAR2 DEFAULT NULL,
      i_session        IN       NUMBER DEFAULT 1,
      i_niv_msg        IN       NUMBER DEFAULT 1,
      i_pause          IN       NUMBER DEFAULT 0,
      o_found          OUT      NUMBER,
      o_erreur         OUT      VARCHAR2
   );
--

--
-- Chaine de reconnaissance SCCS
-- %W%   %E%

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
-- Aucune
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_DEV_QG08B"
AS
-- Chaine de reconnaissance SCCS
-- %W%   %E%

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
-- Aucune
-- -------------------------------------- Fin des variables globales privees --

   -- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--
--
   PROCEDURE p_traitement_principal;

--
   PROCEDURE p_entete_idaffec;

--
   PROCEDURE p_corps_idaffec;

--
   PROCEDURE p_pied_idaffec;

--
   PROCEDURE p_maj_qttc_affec;

--
   PROCEDURE p_maj_qttc_affec_tfc;

--
   PROCEDURE p_select_idrevers;

--
   PROCEDURE p_ins_revers;

--
   PROCEDURE p_debut_traitement;

--
   PROCEDURE p_fin_traitement;

--
   PROCEDURE p_ins_journal;

--
-- ----------------------------- Fin des declarations des procedures privees --

   -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
-- Aucune
-- ---------------------------------- Fin des corps des procedures publiques --
--
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --

   -- Variables de sortie
--

   --G_dataffec      VARCHAR2(11);
--G_dateche    VARCHAR2(11);
   g_dataffec                  DATE;
   g_dateche                   DATE;
   g_flag_test                 VARCHAR2 (1);
   g_idrevers                  NUMBER (10);
   g_montant_total             NUMBER (11, 2);
   g_montant_total_d           NUMBER (11, 2);
   g_pre_numsoc                NUMBER (10);
   g_pre_numorg                NUMBER (10);
   g_trait_entete              VARCHAR2 (1);
--

   -- Variables globales priv¿es
--
   g_numsoc                    v_trav_reversement.numsoc%TYPE;
   g_numorg                    v_trav_reversement.numorg%TYPE;
   g_numquit                   v_trav_reversement.numquit%TYPE;
   g_numfor                    v_trav_reversement.numfor%TYPE;
   g_idaffec                   v_trav_reversement.idaffec%TYPE;
   g_montant                   v_trav_reversement.montant%TYPE;
   g_monnaie                   v_trav_reversement.monnaie%TYPE;
   g_montant_d                 v_trav_reversement.montant_d%TYPE;
   g_monnaie_d                 v_trav_reversement.monnaie_d%TYPE;
--
--
   g_numsoc_deb                v_trav_reversement.numsoc%TYPE;
   g_numorg_deb                v_trav_reversement.numorg%TYPE;
   g_ref_chap_deb              v_trav_reversement.refcie_chapeau%TYPE;
   g_numgar_deb                v_trav_reversement.numgar%TYPE;
   g_numsoc_fin                v_trav_reversement.numsoc%TYPE;
   g_numorg_fin                v_trav_reversement.numorg%TYPE;
   g_ref_chap_fin              v_trav_reversement.refcie_chapeau%TYPE;
   g_numgar_fin                v_trav_reversement.numgar%TYPE;
--
-- Flag de commit ou rollback a retourner a Forms
   g_commit                    BOOLEAN                               := FALSE;
   g_rollback                  BOOLEAN                               := FALSE;
   g_auto_valide               BOOLEAN                               := FALSE;
--
   g_flag_test                 NUMBER;
   g_proc                      VARCHAR2 (80);
-- Variables de P_INS_journal
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE
                                                           DEFAULT 'pk_QG08B';
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE          DEFAULT 1;
   g_niv_msg                   journal_adm.niv_msg%TYPE                 := 1;
   g_max_msg                   journal_adm.niv_msg%TYPE                 := 3;
   g_idligne                   journal_adm.idligne%TYPE                 := 0;
   g_erreur                    journal_adm.msg_adm%TYPE;

-- G_niv_msg prend les Valeurs :
-- 0 --> Message d'erreurs (Erreur ORACLE)
-- 1 --> Message informatif(tout se passe bien)
-- 2 et + Niveau de detail
---------------------- Fin des variables globales privees --
----------------------------------------------------------------------------
--
-- DEFINITION DES CURSEURS PRIVES ------------------------------------------
--@curs
--
----------------------------------------------------------------------------
   --ABO : 10/06/2011 les preneurs de risque configurés pour PRDG ne doivent plus apparaître
   CURSOR c_select_idaffec
   IS
      SELECT   v_trav_reversement.numsoc, v_trav_reversement.numorg,
               v_trav_reversement.numquit, v_trav_reversement.numfor,
               v_trav_reversement.idaffec, v_trav_reversement.montant,
               v_trav_reversement.monnaie, v_trav_reversement.montant_d,
               v_trav_reversement.monnaie_d
          FROM v_trav_reversement
--       ,
--       pers_organisme
      WHERE    v_trav_reversement.idrevers = 0
           --AND numorg NOT IN (SELECT numindiv FROM prdgprfx pf where pf.idprdgflux=1)
           AND v_trav_reversement.numsoc + 0 =
                             NVL (g_numsoc_deb, v_trav_reversement.numsoc + 0)
           AND v_trav_reversement.dataffec <= g_dataffec
           AND v_trav_reversement.numorg BETWEEN NVL
                                                    (TO_NUMBER (g_numorg_deb),
                                                     v_trav_reversement.numorg
                                                    )
                                             AND NVL
                                                   (TO_NUMBER (g_numorg_fin),
                                                    NVL
                                                       (TO_NUMBER
                                                                 (g_numorg_deb),
                                                        v_trav_reversement.numorg
                                                       )
                                                   )
           AND v_trav_reversement.refcie_chapeau || '-'
                  BETWEEN NVL (g_ref_chap_deb,
                               v_trav_reversement.refcie_chapeau
                              ) || '-'
                      AND NVL (g_ref_chap_fin,
                               NVL (g_ref_chap_deb,
                                    v_trav_reversement.refcie_chapeau
                                   )
                              ) || '-'
           AND DECODE (v_trav_reversement.nat_calc,
                       1, (v_trav_reversement.fin + 1),
                       v_trav_reversement.debut
                      ) <= g_dateche
           AND v_trav_reversement.numgar BETWEEN NVL
                                                    (g_numgar_deb,
                                                     v_trav_reversement.numgar
                                                    )
                                             AND NVL
                                                   (g_numgar_fin,
                                                    NVL
                                                       (g_numgar_deb,
                                                        v_trav_reversement.numgar
                                                       )
                                                   )
--
-- AND   v_trav_reversement.numorg = pers_organisme.numorg
-- AND   pers_organisme.revers_cotis = 1
--
      ORDER BY v_trav_reversement.numsoc, v_trav_reversement.numorg;

--

   ------------------------------------------------------------------
--
-- Le corps des diff¿rentes procedures
--
------------------------------------------------------------------
--
--
   PROCEDURE p_dev_qg08b (
      i_deb_numsoc     IN       v_trav_reversement.numsoc%TYPE DEFAULT NULL,
      i_fin_numsoc     IN       v_trav_reversement.numsoc%TYPE DEFAULT NULL,
      i_deb_numorg     IN       v_trav_reversement.numorg%TYPE DEFAULT NULL,
      i_fin_numorg     IN       v_trav_reversement.numorg%TYPE DEFAULT NULL,
      i_deb_ref_chap   IN       v_trav_reversement.refcie_chapeau%TYPE
            DEFAULT NULL,
      i_fin_ref_chap   IN       v_trav_reversement.refcie_chapeau%TYPE
            DEFAULT NULL,
      i_deb_numgar     IN       v_trav_reversement.numgar%TYPE DEFAULT NULL,
      i_fin_numgar     IN       v_trav_reversement.numgar%TYPE DEFAULT NULL,
      i_dataffec       IN       VARCHAR2 DEFAULT NULL,
      i_dateche        IN       VARCHAR2 DEFAULT NULL,
      i_session        IN       NUMBER DEFAULT 1,
      i_niv_msg        IN       NUMBER DEFAULT 1,
      i_pause          IN       NUMBER DEFAULT 0,
      o_found          OUT      NUMBER,
      o_erreur         OUT      VARCHAR2
   )
   IS
      r_select_idaffec   c_select_idaffec%ROWTYPE;
   BEGIN
      --
      o_found := 1;
      g_erreur := NULL;
      --
      g_numsoc_deb := i_deb_numsoc;
      g_numsoc_fin := i_fin_numsoc;
      g_numorg_deb := i_deb_numorg;
      g_numorg_fin := i_fin_numorg;
      g_numgar_deb := i_deb_numgar;
      g_numgar_fin := i_fin_numgar;
      g_ref_chap_deb := i_deb_ref_chap;
      g_ref_chap_fin := i_fin_ref_chap;
      g_dataffec := NVL (e2d (i_dataffec), SYSDATE);
      g_dateche := NVL (e2d (i_dateche), SYSDATE);
      --
      --G_max_msg       := I_niv_msg;
      g_session := i_session;
      --G_idligne     := F_max_idligne(I_session => G_session);
      g_trait_entete := NULL;
      --
      -- OUVERTURE du Curseur
      --
      p_debut_traitement;

      --
      LOOP
         FETCH c_select_idaffec
          INTO r_select_idaffec;

         --
         EXIT WHEN c_select_idaffec%NOTFOUND;
         --
         -- LECTURE D'1 Ligne dans la table principale
         --
         --*debut debogage
         g_niv_msg := 3;
         g_msg_adm := 'Jalon lecture curseur ';
         p_ins_journal;
         --*fin debogage
         --
         o_found := 0;
         g_numsoc := r_select_idaffec.numsoc;
         g_numorg := r_select_idaffec.numorg;
         g_numquit := r_select_idaffec.numquit;
         g_numfor := r_select_idaffec.numfor;
         g_idaffec := r_select_idaffec.idaffec;
         g_montant := r_select_idaffec.montant;
         g_monnaie := r_select_idaffec.monnaie;
         g_montant_d := r_select_idaffec.montant_d;
         g_monnaie_d := r_select_idaffec.monnaie_d;
         --
         p_traitement_principal;
      --
      END LOOP;

      p_fin_traitement;
      --
      o_erreur := g_erreur;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := 'PK_QG08B -
' ||                  SUBSTR (SQLERRM (SQLCODE), 1, 128);
         o_erreur := SUBSTR (SQLERRM (SQLCODE), 1, 128);
         p_ins_journal;

         CLOSE c_select_idaffec;
   END;

--
-- -----------------------------
   PROCEDURE p_traitement_principal
   IS
   BEGIN
      IF g_trait_entete IS NULL
      THEN
         --
         p_entete_idaffec;
         --
         g_trait_entete := '1';
      --
      END IF;

      p_corps_idaffec;
   END;

--
-- -----------------------
   PROCEDURE p_entete_idaffec
   IS
   BEGIN
      g_montant_total := 0;
      g_montant_total_d := 0;
      g_pre_numsoc := g_numsoc;
      g_pre_numorg := g_numorg;
      p_select_idrevers;
   END;

--
-- ----------------------
   PROCEDURE p_corps_idaffec
   IS
   BEGIN
      IF g_numsoc = g_pre_numsoc
      THEN
         IF g_numorg != g_pre_numorg
         THEN
            p_pied_idaffec;
            p_select_idrevers;
         END IF;
      ELSE
         p_pied_idaffec;
         p_select_idrevers;
      END IF;

      g_montant_total := g_montant_total + g_montant;
      g_montant_total_d := g_montant_total_d + g_montant_d;
      p_maj_qttc_affec;
      p_maj_qttc_affec_tfc;
   END;

--
-- ---------------------
   PROCEDURE p_pied_idaffec
   IS
   BEGIN
--*debut debogage
      g_niv_msg := 3;
      g_msg_adm := 'Jalon insertion revers ';
      p_ins_journal;
--*fin debogage
      p_ins_revers;
      g_montant_total := 0;
      g_montant_total_d := 0;
      g_pre_numsoc := g_numsoc;
      g_pre_numorg := g_numorg;
   END;

--
-- ---------------------
   PROCEDURE p_maj_qttc_affec
   IS
   BEGIN
--
      g_proc := 'P_maj_qttc_affec';
--
--*debut debogage
      g_niv_msg := 3;
      g_msg_adm := 'Jalon maj qttc_affec ';
      p_ins_journal;

--*fin debogage
      UPDATE qttc_affec
         SET idrevers = g_idrevers
       WHERE qttc_affec.numquit = g_numquit
         AND qttc_affec.numfor = g_numfor
         AND qttc_affec.idaffec = g_idaffec
         AND qttc_affec.idrevers = 0;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END;

--
-- -------------------------
   PROCEDURE p_maj_qttc_affec_tfc
   IS
   BEGIN
--
      g_proc := 'P_maj_qttc_affec_tfc';
--
--*debut debogage
      g_niv_msg := 3;
      g_msg_adm := 'Jalon maj qttc_affec_tfc ';
      p_ins_journal;


--*fin debogage
-- PHA Ajout AND qttc_affec_tfc.tfc = 2 (reversement de cotisations), sinon, maj de tous les types ! 21/03/2011
      UPDATE qttc_affec_tfc
         SET idrevers = g_idrevers
       WHERE qttc_affec_tfc.numquit = g_numquit
         AND qttc_affec_tfc.numfor =
                DECODE (qttc_affec_tfc.tfc,
                        4, qttc_affec_tfc.numfor,
                        g_numfor
                       )
         AND qttc_affec_tfc.idaffec = g_idaffec
         AND qttc_affec_tfc.idrevers = 0
         AND qttc_affec_tfc.tfc = 2;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END;

--
-- ------------------------
   PROCEDURE p_select_idrevers
   IS
   BEGIN
--
      g_proc := 'P_select_idrevers';

/*
-- Mis en commentaire suite uniformisation des idrevers de reversements PHA 21/03/2011
      SELECT NVL (MAX (idrevers), 0) + 1
        INTO g_idrevers
        FROM reversement;
*/

  select IDREVERS.nextval INTO G_idrevers from dual;

--*debut debogage
      g_niv_msg := 3;
      g_msg_adm := 'Jalon idrevers + 1 = ' || TO_CHAR (g_idrevers);
      p_ins_journal;
--*fin debogage
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END;

--
-- -------------------
   PROCEDURE p_ins_revers
   IS
   BEGIN
--
      g_proc := 'P_ins_revers';

--
      INSERT INTO reversement
                  (idrevers, numsoc, numorg,
                   datrevers, debut, fin, montant,
                   monnaie, montant_d, monnaie_d, valide
                  )
           VALUES (NVL (g_idrevers, 1), g_pre_numsoc, g_pre_numorg,
                   TRUNC (SYSDATE), g_dataffec, g_dateche, g_montant_total,
                   g_monnaie, g_montant_total_d, g_monnaie_d, 'N'
                  );
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END;

-- ----------------------------------------------------------------------------------------
--
-- DEBUT ET FIN DU TRAITEMENT
--
-- ----------------------------------------------------------------------------------------
   PROCEDURE p_debut_traitement
   IS
   BEGIN
      g_niv_msg := 1;
      g_msg_adm :=
         'Debut de traitement le ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
      p_ins_journal;

      -- Fin ecriture dans le Journal
      OPEN c_select_idaffec;

      g_trait_entete := NULL;
   END;

--
-- -----------------------
   PROCEDURE p_fin_traitement
   IS
   BEGIN
--
      g_proc := 'P_fin_traitement';

--
      IF g_trait_entete IS NOT NULL
      THEN
         p_pied_idaffec;
      END IF;

      --
      -- FERMETURE du Curseur
      --
      CLOSE c_select_idaffec;

      --
      INSERT INTO lib_edition
                  (numedit,
                   editlib
                  )
           VALUES (g_session,
                   'Constitution Bordereaux de reversement de primes'
                  );

      --
      g_niv_msg := 1;
      g_msg_adm :=
            'Fin Normale du traitement le '
         || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
      p_ins_journal;
   -- Fin ecriture dans le Journal
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END;

--
----------------------- Fin des procedures publiques ------------------

   -- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
   PROCEDURE p_ins_journal
   IS
      l_idligne   NUMBER;
   BEGIN
      IF (g_niv_msg <= g_max_msg)
      THEN
         g_idligne := g_idligne + 1;

         IF (g_niv_msg = 0)
         THEN
            l_idligne := -1 * g_idligne;
         ELSE
            l_idligne := g_idligne;
         END IF;

         pk_trace.p_ins_journal_adm (i_nom_traitement      => g_nom_traitement,
                                     i_session             => g_session,
                                     i_niv_msg             => g_niv_msg,
                                     i_msg_adm             => g_msg_adm,
                                     i_date                => SYSDATE,
                                     i_idligne             => l_idligne
                                    );
      END IF;
   END p_ins_journal;
---------------- Fin des corps des procedures privees --
END;
/
