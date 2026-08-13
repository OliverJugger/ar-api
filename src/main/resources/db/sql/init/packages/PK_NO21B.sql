CREATE OR REPLACE PACKAGE ARTHUS."PK_NO21B"
AS
--
   PROCEDURE p_no21b (
      i_numremise_deb   IN       porte_remise.numremise%TYPE DEFAULT NULL,
      i_numremise_fin   IN       porte_remise.numremise%TYPE DEFAULT NULL,
      i_session         IN       NUMBER DEFAULT 1,
      i_niv_msg         IN       NUMBER DEFAULT 1,
      i_pause           IN       NUMBER DEFAULT 0,
      o_found           OUT      NUMBER,
      o_erreur          OUT      VARCHAR2
   );
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

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_NO21B"
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
   PROCEDURE p_corps;

--
   PROCEDURE p_sel_flag_decompte;

--
   PROCEDURE p_del_remise;

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
-- Declaration des variables
--
   g_numremise                 porte_remise.numremise%TYPE;
   g_flag_decompte             VARCHAR2 (1);
--
   g_numremise_deb             porte_remise.numremise%TYPE;
   g_numremise_fin             porte_remise.numremise%TYPE;
--
-- Flag de commit ou rollback a retourner a Forms
   g_commit                    BOOLEAN                           := FALSE;
   g_rollback                  BOOLEAN                           := FALSE;
   g_auto_valide               BOOLEAN                           := FALSE;
--
   g_flag_test                 NUMBER;
   g_proc                      VARCHAR2 (80);
-- Variables de P_INS_journal
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE
                                                           DEFAULT 'pk_no21b';
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE       DEFAULT 1;
   g_niv_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_max_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_idligne                   journal_adm.idligne%TYPE          := 0;
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
   CURSOR c_sel_numremise
   IS
      SELECT numremise
        FROM porte_remise
       WHERE numremise BETWEEN g_numremise_deb
                           AND NVL (g_numremise_fin, g_numremise_deb);

--
------------------------------------------------------------------
--
-- Le corps des différentes procedures
--
------------------------------------------------------------------
--
--
   PROCEDURE p_no21b (
      i_numremise_deb   IN       porte_remise.numremise%TYPE DEFAULT NULL,
      i_numremise_fin   IN       porte_remise.numremise%TYPE DEFAULT NULL,
      i_session         IN       NUMBER DEFAULT 1,
      i_niv_msg         IN       NUMBER DEFAULT 1,
      i_pause           IN       NUMBER DEFAULT 0,
      o_found           OUT      NUMBER,
      o_erreur          OUT      VARCHAR2
   )
   IS
      r_sel_numremise   c_sel_numremise%ROWTYPE;
   BEGIN
      --
      o_found := 1;
      g_erreur := NULL;
      --
      g_max_msg := i_niv_msg;
      g_session := i_session;
      --
      g_numremise_deb := i_numremise_deb;
      g_numremise_fin := i_numremise_fin;
      --
      g_flag_decompte := NULL;
      --
      g_niv_msg := 3;
      g_msg_adm := 'Acces p_no21b';
      p_ins_journal;

--
   -- OUVERTURE du Curseur
   --
      IF NOT c_sel_numremise%ISOPEN
      THEN
---------
         g_niv_msg := 3;
         g_msg_adm := 'P_deb_trt_1';
         p_ins_journal;
---------
         p_debut_traitement;
---------
         g_niv_msg := 3;
         g_msg_adm := 'P_deb_trt_2';
         p_ins_journal;
---------
      END IF;

      --
      -- LECTURE D'1 Ligne dans la table principale
      --
      g_niv_msg := 3;
      g_msg_adm := 'Avant fetch';
      p_ins_journal;

---------
      LOOP
         FETCH c_sel_numremise
          INTO r_sel_numremise;

         EXIT WHEN c_sel_numremise%NOTFOUND;
         --
         g_numremise := r_sel_numremise.numremise;
         --
         p_corps;
      --
      END LOOP;

      --
      IF (c_sel_numremise%ROWCOUNT > 0)
      THEN
         -- Donnée trouvée
         g_niv_msg := 3;
         g_msg_adm := 'Jalon 1 - remise trouvée dans PORTE_REMISE';
         p_ins_journal;
         --
         o_found := 1;
      --
      ELSE
         --
         g_niv_msg := 3;
         g_msg_adm := 'Jalon 0 - aucune remise trouvée dans PORTE_REMISE';
         p_ins_journal;
         --
         o_found := 0;
         -- Aucune remise trouvée dans PORTE REMISE - Affichage à l'écran
         g_niv_msg := 1;
         g_msg_adm := 'Aucune remise trouvée dans PORTE REMISE';
         p_ins_journal;
      --
      END IF;

      --
      p_fin_traitement;
      --
      o_erreur := g_erreur;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := 'PK_NO21B - ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         o_erreur := SUBSTR (SQLERRM (SQLCODE), 1, 128);
         p_ins_journal;

         -- FERMETURE du Curseur
         IF c_sel_numremise%ISOPEN
         THEN
            CLOSE c_sel_numremise;
         END IF;
   END;

--
-- -----------------------------
   PROCEDURE p_corps
   IS
   BEGIN
--
      g_proc := 'P_corps';
--
      g_niv_msg := 3;
      g_msg_adm := 'P_corps';
      p_ins_journal;
--
      p_sel_flag_decompte;

--
      IF (g_flag_decompte IS NOT NULL)
      THEN
         -- Ecriture à l'écran
         g_niv_msg := 1;
         g_msg_adm :=
               'Annulation impossible de la remise de prestations N° '
            || g_numremise;
         p_ins_journal;
         --
         g_niv_msg := 1;
         g_msg_adm := 'Remise partiellement décomptée';
         p_ins_journal;
         --
         -- Ecriture dans le Journal
         g_niv_msg := 3;
         g_msg_adm :=
               'Annulation impossible de la remise de prestations N° '
            || g_numremise;
         p_ins_journal;
         --
         g_niv_msg := 3;
         g_msg_adm := 'Remise partiellement décomptée';
         p_ins_journal;
      -- Fin ecriture dans le Journal
      ELSE
         --
         p_del_remise;
         --
         -- Ecriture à l'écran
         g_niv_msg := 1;
         g_msg_adm :=
               'La remise de prestation N° '
            || g_numremise
            || ' a été totalement annulée.';
         p_ins_journal;
         --
         -- Ecriture dans le Journal
         g_niv_msg := 3;
         g_msg_adm :=
               'La remise de prestation N° '
            || g_numremise
            || ' a été totalement annulée.';
         p_ins_journal;
      -- Fin ecriture dans le Journal
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
   END p_corps;

--
-- ----------------------
   PROCEDURE p_sel_flag_decompte
   IS
   BEGIN
--
      g_proc := 'P_sel_flag_decompte';
--
      g_niv_msg := 3;
      g_msg_adm := 'P_sel_flag_decompte';
      p_ins_journal;

--
      SELECT '1'
        INTO g_flag_decompte
        FROM DUAL
       WHERE EXISTS (
                SELECT 1
                  FROM sinistre
                 WHERE numsin IN (SELECT numsin
                                    FROM sntr_ref
                                   WHERE numremise = g_numremise)
                   AND numdec + 0 != 0);
--
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         g_flag_decompte := NULL;
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
   END p_sel_flag_decompte;

--
-- ---------------------
--
   PROCEDURE p_del_remise
   IS
   BEGIN
--
      g_proc := 'P_del_remise';
--
      g_niv_msg := 3;
      g_msg_adm := 'P_del_remise';
      p_ins_journal;

--
      -- Delete dans sinistre
      DELETE      sinistre
            WHERE flagam = 'p' AND numsin IN (SELECT numsin
                                                FROM sntr_ref
                                               WHERE numremise = g_numremise);

--
      -- Delete dans porte_remise
      DELETE      porte_remise
            WHERE numremise = g_numremise
            and numporte = 1 ; -- MUR M0005845
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
   END p_del_remise;

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
      g_niv_msg := 1;
      g_msg_adm :=
         'Debut de traitement le ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
      p_ins_journal;

      -- Fin ecriture dans le Journal
      OPEN c_sel_numremise;
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

--
   -- FERMETURE du Curseur
      CLOSE c_sel_numremise;

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
