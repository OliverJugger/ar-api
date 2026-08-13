CREATE OR REPLACE PACKAGE ARTHUS."PK_NO04B"
AS
--
   PROCEDURE p_no04b (
      i_deb_numporte   IN   porte_adhesion.numporte%TYPE DEFAULT NULL,
      i_fin_numporte   IN   porte_adhesion.numporte%TYPE DEFAULT NULL,
      i_param1         IN   param_batch.param1%TYPE DEFAULT NULL,
      i_param2         IN   param_batch.param2%TYPE DEFAULT NULL,
      i_session        IN   NUMBER DEFAULT 1,
      i_niv_msg        IN   NUMBER DEFAULT 1
   );
--


END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_NO04B"
AS

--
   PROCEDURE p_traitement_principal;

--
   PROCEDURE p_corps;

--
   PROCEDURE p_test_rupture;

--
   PROCEDURE p_maj_porte_adhesion;

--
   PROCEDURE p_maj_porte_adhesion_tiers;

--
   PROCEDURE p_maj_noemie;

--
   PROCEDURE p_maj_demande_tiers_payant;

--
   PROCEDURE p_ins_remise_externe;

--
   PROCEDURE p_maj_remise_externe;

--
   PROCEDURE p_sel_new_numremise;

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
--
   g_trait_entete              VARCHAR2 (1);
   g_numporte_deb              porte_adhesion.numporte%TYPE      DEFAULT NULL;
   g_numporte_fin              porte_adhesion.numporte%TYPE      DEFAULT NULL;
   g_numporte_deb_trouve       porte_adhesion.numporte%TYPE      DEFAULT NULL;
   g_param1                    param_batch.param1%TYPE           DEFAULT NULL;
   g_param2                    param_batch.param2%TYPE           DEFAULT NULL;
   g_type_carte                param_tiers_payant.type_carte%TYPE
                                                                 DEFAULT NULL;
   g_idporte                   porte_adhesion.idporte%TYPE;
   g_numporte                  porte_adhesion.numporte%TYPE;
   g_nb_enrg                   NUMBER (6);
   g_new_numremise             NUMBER (6);
   g_numremise                 NUMBER (6)                           DEFAULT 0;
   g_date_remise               DATE;
   g_lnumporte                 porte_adhesion.numporte%TYPE;
   g_ltype_carte               param_tiers_payant.type_carte%TYPE;
-- Flag de commit ou rollback a retourner a Forms
   g_commit                    BOOLEAN                              := FALSE;
   g_rollback                  BOOLEAN                              := FALSE;
   g_auto_valide               BOOLEAN                              := FALSE;
--
   g_flag_test                 NUMBER;
   g_proc                      VARCHAR2 (80);
-- Variables de P_INS_journal
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE
                                                           DEFAULT 'pk_no04b';
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE          DEFAULT 1;
   g_niv_msg                   journal_adm.niv_msg%TYPE             := 1;
   g_max_msg                   journal_adm.niv_msg%TYPE             := 1;
   g_idligne                   journal_adm.idligne%TYPE             := 0;
   g_erreur                    journal_adm.msg_adm%TYPE;

-- G_niv_msg prend les Valeurs :
-- 0 --> Message d'erreurs (Erreur ORACLE)
-- 1 --> Message informatif(tout se passe bien)
-- 2 et + Niveau de detail
--  -------------------- Fin des variables globales privees --
--  --------------------------------------------------------------------------
--
-- DEFINITION DES CURSEURS PRIVES ------------------------------------------
-- @curs
--
--  --------------------------------------------------------------------------
--
-- On recupere les infos Noemie. ------------------------------------------
--
   CURSOR c_select_info
   IS
      SELECT   porte_adhesion.numremise, porte_adhesion.idporte,
               noemie.numporte, NULL type_carte
          FROM noemie, porte_adhesion
         WHERE noemie.numassu > 0
           AND porte_adhesion.idporte = noemie.idporte
           AND porte_adhesion.numremise = 0
           AND porte_adhesion.transmis = 2
           AND porte_adhesion.numporte BETWEEN NVL (g_numporte_deb,
                                                    porte_adhesion.numporte
                                                   )
                                           AND NVL
                                                 (g_numporte_fin,
                                                  NVL (g_numporte_deb,
                                                       porte_adhesion.numporte
                                                      )
                                                 )
      ORDER BY porte_adhesion.numremise, noemie.numporte;

--
-- On recupere les infos tiers_payant.
--
   CURSOR c_select_info_tiers
   IS
      SELECT   porte_adhesion.numremise, porte_adhesion.idporte,
               porte_adhesion.numporte, param_tiers_payant.type_carte
          FROM porte_adhesion, demande_tp, param_tiers_payant
         WHERE porte_adhesion.numremise = 0
           AND porte_adhesion.numporte BETWEEN NVL (g_numporte_deb,
                                                    porte_adhesion.numporte
                                                   )
                                           AND NVL
                                                 (g_numporte_fin,
                                                  NVL (g_numporte_deb,
                                                       porte_adhesion.numporte
                                                      )
                                                 )
           AND porte_adhesion.transmis = 2
           AND demande_tp.idporte = porte_adhesion.idporte
           AND param_tiers_payant.idparam_tp = demande_tp.idparam_tp
      ORDER BY porte_adhesion.numremise,
               porte_adhesion.numporte,
               param_tiers_payant.type_carte;

--
------------------------------------------------------------------
--
-- Le corps des différentes procedures
--
------------------------------------------------------------------
--
--
   PROCEDURE p_no04b (
      i_deb_numporte   IN   porte_adhesion.numporte%TYPE DEFAULT NULL,
      i_fin_numporte   IN   porte_adhesion.numporte%TYPE DEFAULT NULL,
      i_param1         IN   param_batch.param1%TYPE DEFAULT NULL,
      i_param2         IN   param_batch.param2%TYPE DEFAULT NULL,
      i_session        IN   NUMBER DEFAULT 1,
      i_niv_msg        IN   NUMBER DEFAULT 1
   )
   IS
      r_select_info         c_select_info%ROWTYPE;
      r_select_info_tiers   c_select_info_tiers%ROWTYPE;
      iderr                 VARCHAR2 (2);
   BEGIN
      --
      g_erreur := NULL;
      --
      g_lnumporte := 0;
      g_numporte_deb := i_deb_numporte;
      g_numporte_fin := i_fin_numporte;
      g_param1 := i_param1;
      g_param2 := i_param2;
      --
      g_max_msg := i_niv_msg;
      g_session := i_session;
      --G_idligne     := F_max_idligne(I_session => G_session);

      ---------
--
-- NSD (=) 11-06-2007 Fiche humanis G1115
--
   -- NSD (=) Suppression du message Porte de ... par modif du niveau
   --G_niv_msg := 1;
      g_niv_msg := 3;
      g_msg_adm :=
            'Porte de ['
         || i_deb_numporte
         || '] à ['
         || i_fin_numporte
         || '] Nature ['
         || i_param1
         || '] Flag type carte ['
         || i_param2
         || ']';
      p_ins_journal;
      -- NSD (+) Ce message garde le niveau 1
      g_niv_msg := 1;
      g_msg_adm :=
          'Debut de traitement le ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
      p_ins_journal;

   -- Fin ecriture dans le Journal
--
-- Sélection du Curseur à utiliser avec la variable G_numporte_deb
---
      BEGIN
         --
         g_numporte_deb_trouve := NULL;

         --
         SELECT numporte
           INTO g_numporte_deb_trouve
           FROM porte_param
          WHERE numbene IS NOT NULL AND numporte = g_numporte_deb;
      ---
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            g_numporte_deb_trouve := NULL;
      END;

---
      IF (g_numporte_deb_trouve IS NOT NULL)
      THEN
         -- OUVERTURE du Curseur C_select_info_tiers
         --
         IF NOT c_select_info_tiers%ISOPEN
         THEN
            g_niv_msg := 3;
            g_msg_adm := 'Curseur "Tiers payant"';
            p_ins_journal;
---------
            p_debut_traitement;
---------
            g_niv_msg := 3;
            g_msg_adm := 'Début Boucle "Tiers payant"';
            p_ins_journal;
         END IF;

         --
         -- Boucle de traitement du curseur Tiers payant
         --
         LOOP
            FETCH c_select_info_tiers
             INTO r_select_info_tiers;

            EXIT WHEN c_select_info_tiers%NOTFOUND;
            iderr := '00';
            g_idporte := r_select_info_tiers.idporte;
            iderr := '01';
            g_numporte := r_select_info_tiers.numporte;
            iderr := '02';
            g_type_carte := r_select_info_tiers.type_carte;
--
            p_traitement_principal;
--
         END LOOP;

         -- Info affichée à l'écran si pas de données à traiter
         IF (c_select_info_tiers%ROWCOUNT = 0)
         THEN
            g_niv_msg := 1;
            g_msg_adm := 'Aucune donnée à traiter';
            p_ins_journal;
         END IF;

         p_fin_traitement;
---------
      ELSE
         -- OUVERTURE du Curseur C_select_info
         --
         IF NOT c_select_info%ISOPEN
         THEN
            g_niv_msg := 3;
            g_msg_adm := 'Curseur "Noemie"';
            p_ins_journal;
---------
            p_debut_traitement;
---------
            g_niv_msg := 3;
            g_msg_adm := 'Début Boucle "Noemie"';
            p_ins_journal;
         END IF;

         --
         -- Boucle de traitement du curseur Noemie
         --
         LOOP
            FETCH c_select_info
             INTO r_select_info;

            EXIT WHEN c_select_info%NOTFOUND;
            iderr := '00';
            g_idporte := r_select_info.idporte;
            iderr := '01';
            g_numporte := r_select_info.numporte;
            iderr := '02';
            g_type_carte := r_select_info.type_carte;
--
            p_traitement_principal;
--
         END LOOP;

         -- Info affichée à l'écran si pas de données à traiter
         IF (c_select_info%ROWCOUNT = 0)
         THEN
            g_niv_msg := 1;
            g_msg_adm := 'Aucune donnée à traiter';
            p_ins_journal;
         END IF;

         p_fin_traitement;
--
      END IF;
   --
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm :=
                 'PK_NO04B - ' || iderr || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         p_ins_journal;

         -- FERMETURE du Curseur jpf 06/11/2004
         IF c_select_info_tiers%ISOPEN
         THEN
            CLOSE c_select_info_tiers;
         ELSIF c_select_info%ISOPEN
         THEN
            CLOSE c_select_info;
         END IF;
--
   END;

--
-- -----------------------------
   PROCEDURE p_traitement_principal
   IS
   BEGIN
      g_proc := 'P_traitement_principal';

---------
      IF g_trait_entete IS NULL
      THEN
         --
         g_trait_entete := '1';
         --
         g_nb_enrg := '0';
      --
      END IF;

      --
      p_test_rupture;
      p_corps;
   --
---------
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
   END p_traitement_principal;

--
-- ------------------------
   PROCEDURE p_corps
   IS
   BEGIN
      --
      g_proc := 'P_corps';
      g_niv_msg := 3;
      g_msg_adm := 'Traitement ligne - NUMPORTE =' || g_numporte;
      --    P_INS_journal;
      --
      g_nb_enrg := g_nb_enrg + 1;

      --
      IF (g_numporte_deb_trouve IS NOT NULL)
      THEN
         p_maj_porte_adhesion;
      ELSE
         p_maj_porte_adhesion;
         p_maj_noemie;
      END IF;
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
   END p_corps;

--
-- ----------------------
   PROCEDURE p_test_rupture
   IS
   BEGIN
--
      g_proc := 'P_Test_Rupture';

      IF (g_numporte != g_lnumporte)
      THEN
         --
         -- NSD (=) Suppression du message Porte de ... par modif du niveau
         -- G_niv_msg := 1;
         g_niv_msg := 3;
         g_msg_adm := 'Rupture/porte ' || g_numporte || '/' || g_lnumporte;
         p_ins_journal;
         p_sel_new_numremise;
         p_ins_remise_externe;
         --
         g_nb_enrg := 0;
         g_lnumporte := g_numporte;
         g_ltype_carte := g_type_carte;
      --
      ELSIF (    g_param2 IS NOT NULL
             AND g_param2 = '1'
             AND g_type_carte != g_ltype_carte
            )
      THEN
         g_niv_msg := 1;
         g_msg_adm :=
                'Rupture/type carte ' || g_type_carte || '/' || g_ltype_carte;
         p_sel_new_numremise;
         p_ins_remise_externe;
         --
         g_nb_enrg := 0;
         g_ltype_carte := g_type_carte;
      END IF;
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
   END p_test_rupture;

--
-- ----------------------
   PROCEDURE p_maj_porte_adhesion
   IS
   BEGIN
--
      g_proc := 'P_maj_porte_adhesion';
--
      g_niv_msg := 3;
      g_msg_adm := 'P_maj_porte_adhesion';
      p_ins_journal;

--
      UPDATE porte_adhesion
         SET numremise = g_new_numremise
       WHERE idporte = g_idporte;
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
   END p_maj_porte_adhesion;

--
-- ----------------------
   PROCEDURE p_maj_porte_adhesion_tiers
   IS
   BEGIN
--
      g_proc := 'P_maj_porte_adhesion_tiers';
--
      g_niv_msg := 3;
      g_msg_adm := 'P_maj_porte_adhesion_tiers';
      p_ins_journal;

--
      UPDATE porte_adhesion
         SET numremise = g_new_numremise
       WHERE idporte = g_idporte AND numremise = 0;
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
   END p_maj_porte_adhesion_tiers;

--
-- ----------------------
   PROCEDURE p_maj_noemie
   IS
   BEGIN
--
      g_proc := 'P_maj_noemie';
--
      g_niv_msg := 3;
      g_msg_adm := 'P_maj_noemie';
      p_ins_journal;

--
      UPDATE noemie
         SET numremise = g_new_numremise
       WHERE idporte = g_idporte;
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
   END p_maj_noemie;

--
-- ----------------------
   PROCEDURE p_maj_demande_tiers_payant
   IS
   BEGIN
--
      g_proc := 'P_maj_demande_tiers_payant';
--
      g_niv_msg := 3;
      g_msg_adm := 'P_maj_demande_tiers_payant';
      p_ins_journal;

--
      UPDATE demande_tiers_payant
         SET numremise = g_new_numremise
       WHERE idporte = g_idporte AND transmis = 2;
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
   END p_maj_demande_tiers_payant;

--
-- ----------------------
   PROCEDURE p_ins_remise_externe
   IS
   BEGIN
--
      g_proc := 'P_ins_remise_externe';
--
      g_niv_msg := 3;
      g_msg_adm := 'P_ins_remise_externe';
      p_ins_journal;

--
      IF (g_numremise > 0)
      THEN
         p_maj_remise_externe;
      END IF;

      --
      g_numremise := g_new_numremise;

--    --
      INSERT INTO remise_externe
                  (numremise, date_remise, numporte, nombre, batch, valide,
                   numutil, datedit, datvalide, date_trans, nature)
         SELECT g_new_numremise, TRUNC (SYSDATE), g_numporte,
                NVL (g_nb_enrg, 0), '', 'N', '', '', '', '',
                TO_NUMBER (g_param1)
           FROM DUAL;
--    Where nvl(G_nb_enrg, 0) > 0;
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
   END p_ins_remise_externe;

--
   PROCEDURE p_maj_remise_externe
   IS
   BEGIN
      g_proc := 'P_maj_remise_externe';

---------
      UPDATE remise_externe
         SET nombre = NVL (g_nb_enrg, 0)
       WHERE numremise = g_numremise AND numporte = g_numporte;
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
   END p_maj_remise_externe;

--
-- ----------------------
   PROCEDURE p_sel_new_numremise
   IS
   BEGIN
--
      g_proc := 'P_sel_new_numremise';
--
      g_niv_msg := 3;
      g_msg_adm := 'P_sel_new_numremise';
      p_ins_journal;

--
      --SDA 3988
      /*SELECT NVL (MAX (numremise), 0) + 1
        INTO g_new_numremise
        FROM remise_externe;*/

      select seq_numremise.nextval into g_new_numremise from dual;
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
   END p_sel_new_numremise;

--
-- ----------------------------------------------------------------------------------------
--
-- DEBUT ET FIN DU TRAITEMENT
--
-- ----------------------------------------------------------------------------------------
   PROCEDURE p_debut_traitement
   IS
   BEGIN
      --
      g_proc := 'P_debut_traitement';

      --
      IF (g_numporte_deb_trouve IS NOT NULL)
      THEN
         -- OUVERTURE du Curseur C_select_info_tiers
         g_msg_adm := 'Ouverture "Tiers payant"';
         p_ins_journal;

         OPEN c_select_info_tiers;
      ELSE
         -- OUVERTURE du Curseur C_select_info
         g_msg_adm := 'Ouverture "Noemie"';
         p_ins_journal;

         OPEN c_select_info;
      END IF;

      --
      g_trait_entete := NULL;
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
   END p_debut_traitement;

--
-- -----------------------
   PROCEDURE p_fin_traitement
   IS
   BEGIN
      --
      g_proc := 'P_fin_traitement';
      -- maj du nombre d'attestations
      p_maj_remise_externe;

      --
      -- FERMETURE du Curseur C_select_info_tiers ou du Curseur C_select_info
      --
      IF (g_numporte_deb_trouve IS NOT NULL)
      THEN
         -- FERMETURE du Curseur C_select_info_tiers
         CLOSE c_select_info_tiers;
      ELSE
         -- FERMETURE du Curseur C_select_info
         CLOSE c_select_info;
      END IF;

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

         -- FERMETURE du Curseur
         IF c_select_info_tiers%ISOPEN
         THEN
            CLOSE c_select_info_tiers;
         ELSIF c_select_info%ISOPEN
         THEN
            CLOSE c_select_info;
         END IF;
--
   END p_fin_traitement;

--
----------------------- Fin des procedures publiques ------------------

   -- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
   PROCEDURE p_ins_journal
   IS
      l_idligne   NUMBER;
   BEGIN
--
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
                                     i_idligne             => l_idligne
                                    );
      END IF;
--
   END p_ins_journal;
---------------- Fin des corps des procedures privees --
END;
/
