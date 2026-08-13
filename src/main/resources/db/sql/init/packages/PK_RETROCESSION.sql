CREATE OR REPLACE PACKAGE ARTHUS.PK_RETROCESSION AS
-- Chaine de reconnaissance SCCS
-- %W% Bordereau de Reversement commission %E%

   -- -- CONSTANTES PUBLIQUE -----------------------------------------------------
   cst_codope   NUMBER := 16;

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
--@pub
   FUNCTION f_sel_taux_remun (
      i_etendue      IN   apporteur.etendue%TYPE,
      i_cle          IN   apporteur.cle%TYPE,
      i_type         IN   apporteur.TYPE%TYPE,
      i_debut        IN   apporteur.debut%TYPE,
      i_mode_retro   IN   apporteur.mode_retro%TYPE,
      i_numindiv     IN   apporteur.numindiv%TYPE
   )
      RETURN NUMBER;

--Pragma Restrict_References(F_SEL_taux_remun, WNDS,WNPS);
--
   PROCEDURE p_sel_retrocession (
      i_deb_numsoc     IN       contrat.numinterm%TYPE,
      i_fin_numsoc     IN       contrat.numinterm%TYPE DEFAULT NULL,
      i_deb_numindiv   IN       apporteur.numindiv%TYPE DEFAULT NULL,
      i_fin_numindiv   IN       apporteur.numindiv%TYPE DEFAULT NULL,
      i_deb_regroup    IN       contrat.refcie_chapeau%TYPE DEFAULT NULL,
      i_fin_regroup    IN       contrat.refcie_chapeau%TYPE DEFAULT NULL,
      i_deb_numgar     IN       contrat.numgar%TYPE DEFAULT NULL,
      i_fin_numgar     IN       contrat.numgar%TYPE DEFAULT NULL,
      i_dataffec       IN       compte_client.datope%TYPE DEFAULT NULL,
      i_echeance       IN       qttc_global.debut%TYPE DEFAULT NULL,
      i_deb_type_tfc   IN       qttc_affec_tfc.type_tfc%TYPE DEFAULT NULL,
      i_fin_type_tfc   IN       qttc_affec_tfc.type_tfc%TYPE DEFAULT NULL,
      i_session        IN       NUMBER DEFAULT 1,
      i_niv_msg        IN       NUMBER DEFAULT 1,
      o_found          OUT      NUMBER,
      o_erreur         OUT      VARCHAR2
   );
-- -------------------------------------------- Fin des procedures publiques --

   FUNCTION F_MntGlobalCom (i_NumQuit  IN Qttc_Affec_TFC.NUMQUIT%TYPE,
                            i_IdRevers IN Qttc_Affec_TFC.IDREVERS%TYPE,
                            i_TFC      IN Qttc_Affec_TFC.TFC%TYPE,
                            i_TypeTFC  IN Qttc_Affec_TFC.Type_TFC%TYPE) RETURN NUMBER;

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_RETROCESSION AS
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
--@global
--
-- Parametres de P_SEL_retrocession
--
   g_deb_numsoc                contrat.numinterm%TYPE;
   g_fin_numsoc                contrat.numinterm%TYPE;
   g_deb_numindiv              apporteur.numindiv%TYPE;
   g_fin_numindiv              apporteur.numindiv%TYPE;
   g_deb_regroup               contrat.refcie_chapeau%TYPE;
   g_fin_regroup               contrat.refcie_chapeau%TYPE;
   g_deb_numgar                contrat.numgar%TYPE;
   g_fin_numgar                contrat.numgar%TYPE;
   g_dataffec                  compte_client.datope%TYPE;
   g_echeance                  qttc_global.debut%TYPE;
   g_deb_type_tfc              qttc_affec_tfc.type_tfc%TYPE;
   g_fin_type_tfc              qttc_affec_tfc.type_tfc%TYPE;
--
-- Variables de travail de P_SEL_retocession
--
   g_idrevers                  retrocession.idrevers%TYPE;
   g_last_numsoc               contrat.numinterm%TYPE            := -1;
   g_last_numindiv             apporteur.numindiv%TYPE           := -1;
   g_last_idaffec              qttc_affec_tfc.idaffec%TYPE       := -1;
   g_last_type_tfc             qttc_affec_tfc.type_tfc%TYPE      := -1;
   g_last_monnaie_d            qttc_affec_tfc.monnaie_d%TYPE     := -1;
   g_last_typgar               retrocession.typgar%TYPE          := -1;
   g_sum_montant               NUMBER                            := 0;
   g_sum_montant_d             NUMBER                            := 0;
   g_erreur                    journal_adm.msg_adm%TYPE;
-- Mode de reglement de l'intermediaire
   g_bene_modpmt               NUMBER                            := 1;
   g_devise                    NUMBER;
   g_devise_d                  NUMBER;
-- Indique si le montant mini ou le delai de reglement est atteint
   g_seuil_montant             NUMBER                            := 0;
   g_seuil_montant_d           NUMBER                            := 0;
   g_min_dataffec              DATE;
-- Flag de commit ou rollback a retourner a Forms
   g_commit                    BOOLEAN                           := FALSE;
   g_rollback                  BOOLEAN                           := FALSE;
   g_auto_valide               BOOLEAN                           := FALSE;
--
-- Variables de P_INS_journal
--
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE
                                                    DEFAULT 'pk_retrocession';
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE       DEFAULT 1;
   g_flag_test                 NUMBER;
   g_niv_msg                   journal_adm.niv_msg%TYPE          := 3;
   g_max_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_idligne                   journal_adm.idligne%TYPE          := 0;
   g_proc                      VARCHAR2 (80);

--
-- G_niv_msg prend les Valeurs :
-- 0 --> Message d'erreurs (Erreur ORACLE)
-- 1 --> Message informatif(tout se passe bien)
-- 2 et + Niveau de detail
-- -------------------------------------- Fin des variables globales privees --

   -- -- DEFINITION DES CURSEURS PRIVES ------------------------------------------
--@curs
   CURSOR c_retrocession
   IS
      SELECT   numsoc, numindiv, type_tfc, idaffec, dataffec, prelev_revers,
               montant, montant_d, monnaie, monnaie_d, typgar
          FROM v_trav_retrocession
         WHERE idrevers = 0
           AND prelev_revers = 2
           AND numsoc BETWEEN g_deb_numsoc AND NVL (g_fin_numsoc,
                                                    g_deb_numsoc)
           AND numindiv BETWEEN NVL (g_deb_numindiv, numindiv)
                            AND NVL (g_fin_numindiv,
                                     NVL (g_deb_numindiv, numindiv)
                                    )
           AND numgar BETWEEN NVL (g_deb_numgar, numgar)
                          AND NVL (g_fin_numgar, NVL (g_deb_numgar, numgar))
           AND type_tfc BETWEEN NVL (g_deb_type_tfc, type_tfc)
                            AND NVL (g_fin_type_tfc,
                                     NVL (g_deb_type_tfc, type_tfc)
                                    )
           AND DECODE (g_deb_regroup, NULL, -1, regroupement)
                  BETWEEN NVL (g_deb_regroup, -1)
                      AND DECODE (g_deb_regroup,
                                  NULL, -1,
                                  NVL (g_fin_regroup, g_deb_regroup)
                                 )
           AND TRUNC (dataffec) <= NVL (g_dataffec, SYSDATE)
           AND TRUNC (echeance) <= NVL (g_echeance, SYSDATE)
      ORDER BY numsoc, numindiv, idaffec, type_tfc, typgar, monnaie_d;

-- -------------------------------------- Fin des curseurs prives -------------
-- -- DEFINITION DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@priv
--
-- Controle des modalites de reglement
--
   PROCEDURE p_ctrl_montant;

--
-- Insertion dans retrocession
--
   PROCEDURE p_ins_retrocession;

--
-- Procedure de decaissement automatique
--
   PROCEDURE p_rglt_auto;

--
-- Flag de qttc_affec_tfc avec l'idrevers
--
   PROCEDURE p_upd_qttc_affec (
      i_idrevers        IN   qttc_affec_tfc.idrevers%TYPE,
      i_idaffec         IN   qttc_affec_tfc.idaffec%TYPE,
      i_tfc             IN   qttc_affec_tfc.tfc%TYPE,
      i_numbene         IN   qttc_affec_tfc.numbene%TYPE,
      i_type_tfc        IN   qttc_affec_tfc.type_tfc%TYPE,
      i_prelev_revers   IN   qttc_affec_tfc.prelev_revers%TYPE DEFAULT NULL
   );

--
-- Remise a zero de l'idrevers si Bx non construit
--
   PROCEDURE p_raz_qttc_affec (i_idrevers IN qttc_affec_tfc.idrevers%TYPE);

--
-- Insertion dans journal_adm
--
   PROCEDURE p_ins_journal;

--
-- Retourne le prochain idligne
--
   FUNCTION f_max_idligne (i_session IN journal_adm.id_session%TYPE)
      RETURN NUMBER;

--
-- Retourne le prochain idrevers
--
   FUNCTION f_max_idrevers
      RETURN retrocession.idrevers%TYPE;

--
-- ----------------------------- Fin des definitions des procedures privees ---

   -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--@corpub
   FUNCTION f_sel_taux_remun (
      i_etendue      IN   apporteur.etendue%TYPE,
      i_cle          IN   apporteur.cle%TYPE,
      i_type         IN   apporteur.TYPE%TYPE,
      i_debut        IN   apporteur.debut%TYPE,
      i_mode_retro   IN   apporteur.mode_retro%TYPE,
      i_numindiv     IN   apporteur.numindiv%TYPE
   )
      RETURN NUMBER
   IS
      CURSOR c_apporteur
      IS
         SELECT taux_remun, numindiv
           FROM apporteur
          WHERE etendue = i_etendue
            AND cle = i_cle
            AND TYPE = i_type
            AND mode_retro = i_mode_retro
            AND i_debut BETWEEN debut AND NVL (fin, i_debut);

--
      rec_c_apporteur    c_apporteur%ROWTYPE;
--
      l_sum_taux_indiv   NUMBER                := 0;
                                              -- Somme des Taux de l'apporteur
      l_sum_taux_total   NUMBER                := 0;
                                -- Somme des Taux de l'ensemble des apporteurs
      l_taux             NUMBER;
--
   BEGIN
      OPEN c_apporteur;

      LOOP
         FETCH c_apporteur
          INTO rec_c_apporteur;

         EXIT WHEN c_apporteur%NOTFOUND
               OR rec_c_apporteur.taux_remun IS NULL;

         --
         IF rec_c_apporteur.numindiv = i_numindiv
         THEN
            l_sum_taux_indiv := l_sum_taux_indiv + rec_c_apporteur.taux_remun;
         END IF;

         --
         l_sum_taux_total := l_sum_taux_total + rec_c_apporteur.taux_remun;
      END LOOP;

      --
      CLOSE c_apporteur;

      --
      IF l_sum_taux_indiv = 0
      THEN
         -- Taux global de l'apporteur
         l_taux := 1;
      ELSE
         -- Taux specifique de l'apporeur
         l_taux := l_sum_taux_indiv / l_sum_taux_total;
      END IF;

      --
      RETURN l_taux;
   END;

--@trav
-- Construction des bordereaux de retrocession
--
   PROCEDURE p_sel_retrocession (
      i_deb_numsoc     IN       contrat.numinterm%TYPE,
      i_fin_numsoc     IN       contrat.numinterm%TYPE DEFAULT NULL,
      i_deb_numindiv   IN       apporteur.numindiv%TYPE DEFAULT NULL,
      i_fin_numindiv   IN       apporteur.numindiv%TYPE DEFAULT NULL,
      i_deb_regroup    IN       contrat.refcie_chapeau%TYPE DEFAULT NULL,
      i_fin_regroup    IN       contrat.refcie_chapeau%TYPE DEFAULT NULL,
      i_deb_numgar     IN       contrat.numgar%TYPE DEFAULT NULL,
      i_fin_numgar     IN       contrat.numgar%TYPE DEFAULT NULL,
      i_dataffec       IN       compte_client.datope%TYPE DEFAULT NULL,
      i_echeance       IN       qttc_global.debut%TYPE DEFAULT NULL,
      i_deb_type_tfc   IN       qttc_affec_tfc.type_tfc%TYPE DEFAULT NULL,
      i_fin_type_tfc   IN       qttc_affec_tfc.type_tfc%TYPE DEFAULT NULL,
      i_session        IN       NUMBER DEFAULT 1,
      i_niv_msg        IN       NUMBER DEFAULT 1,
      o_found          OUT      NUMBER,
      o_erreur         OUT      VARCHAR2
   )
   IS
--
      rec_c_retrocession   c_retrocession%ROWTYPE;
--
-- Flag de commit ou rollback a retrourner a Forms
      g_commit             BOOLEAN                   := FALSE;
      g_rollback           BOOLEAN                   := FALSE;
--
      l_cst_tfc   CONSTANT qttc_affec_tfc.tfc%TYPE   DEFAULT 5;
--
   BEGIN
--
      o_found := 1;
      g_erreur := NULL;
--
      g_deb_numsoc := i_deb_numsoc;
      g_fin_numsoc := i_fin_numsoc;
      g_deb_numindiv := i_deb_numindiv;
      g_fin_numindiv := i_fin_numindiv;
      g_deb_regroup := i_deb_regroup;
      g_fin_regroup := i_fin_regroup;
      g_deb_numgar := i_deb_numgar;
      g_fin_numgar := i_fin_numgar;
      g_dataffec := i_dataffec;
      g_echeance := i_echeance;
      g_deb_type_tfc := i_deb_type_tfc;
      g_fin_type_tfc := i_fin_type_tfc;
--
--
      g_max_msg := i_niv_msg;
      g_session := i_session;
      g_idligne := f_max_idligne (i_session => g_session);

      IF NOT c_retrocession%ISOPEN
      THEN
         --
         g_niv_msg := 1;
         g_msg_adm :=
               'Début du traitement le '
            || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi');
         p_ins_journal;
         --
         g_last_numsoc := -1;
         g_last_numindiv := -1;
         g_last_idaffec := -1;
         g_last_type_tfc := -1;
         g_last_monnaie_d := -1;
         g_last_typgar := -1;
         g_sum_montant := 0;
         g_sum_montant_d := 0;
         g_min_dataffec := NULL;

         OPEN c_retrocession;

	       -- PHA 21/03/2011 gestion idrevers
	       G_idrevers := F_max_idrevers;

      END IF;

--   PHA 21/03/2011 ajout du LOOP
      LOOP
      FETCH c_retrocession
       INTO rec_c_retrocession;

--
      IF (c_retrocession%NOTFOUND)
      THEN
         --
         IF g_last_numsoc <> -1
         THEN
            -- Insertion dans retrocession
            p_ctrl_montant;
         END IF;

         --
         g_niv_msg := 1;
         g_msg_adm :=
               'Fin Normale du traitement le '
            || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi');
         p_ins_journal;

         --
         CLOSE c_retrocession;

         o_found := 0;
         RETURN;
      ELSE
         o_found := 1;
      END IF;

--
-- Recherche de la plus ancienne date d'affectation
--
      IF (rec_c_retrocession.dataffec <=
                             NVL (g_min_dataffec, rec_c_retrocession.dataffec)
         )
      THEN
         g_min_dataffec := rec_c_retrocession.dataffec;
      END IF;

--
-- Sur rupture d'une des 2 colonnes  on Insere dans retrocession
--
      IF (   g_last_numsoc <> rec_c_retrocession.numsoc
          OR g_last_numindiv <> rec_c_retrocession.numindiv
          OR g_last_typgar <> rec_c_retrocession.typgar
          OR g_last_monnaie_d <> rec_c_retrocession.monnaie_d
         )
      THEN
         --
         g_niv_msg := 2;
         g_msg_adm :=
               'Traitement société N° '
            || TO_CHAR (rec_c_retrocession.numsoc)
            || ' Intermédiaire : '
            || TO_CHAR (rec_c_retrocession.numindiv);
         p_ins_journal;
         --
         g_niv_msg := 3;
         g_msg_adm :=
               'Numsoc '
            || TO_CHAR (rec_c_retrocession.numsoc)
            || ' Last Numsoc '
            || TO_CHAR (g_last_numsoc)
            || ' Numindiv '
            || TO_CHAR (rec_c_retrocession.numindiv)
            || ' Last Numindiv '
            || TO_CHAR (g_last_numindiv);
         p_ins_journal;

         --
         IF g_last_numsoc <> -1
         THEN
            -- Insertion dans retrocession
            p_ctrl_montant;
            --
            -- Initialisation du montant a chaque rupture
            g_sum_montant := 0;
            g_sum_montant_d := 0;
            --
           	-- PHA 21/03/2011 gestion idrevers
  	        G_idrevers := F_max_idrevers;
         END IF;
      --
      END IF;

      IF (   g_last_idaffec <> rec_c_retrocession.idaffec
          OR g_last_type_tfc <> rec_c_retrocession.type_tfc
         )
      THEN
         --
         g_niv_msg := 3;
         g_msg_adm :=
               'Idaffec '
            || TO_CHAR (rec_c_retrocession.idaffec)
            || ' Last Idaffec '
            || TO_CHAR (g_last_idaffec)
            || ' Type_tfc '
            || TO_CHAR (rec_c_retrocession.type_tfc)
            || ' Last Type_tfc '
            || TO_CHAR (g_last_type_tfc);
         p_ins_journal;
         --
--         g_idrevers := f_max_idrevers;
         --
               -- Mise a jour de qttc_affec_tfc.idrevers
         p_upd_qttc_affec (i_idrevers           => g_idrevers,
                           i_idaffec            => rec_c_retrocession.idaffec,
                           i_tfc                => l_cst_tfc,
                           i_numbene            => rec_c_retrocession.numindiv,
                           i_type_tfc           => rec_c_retrocession.type_tfc,
                           i_prelev_revers      => rec_c_retrocession.prelev_revers
                          );
      END IF;

--
-- Cumul des montants pour l'apporteur
      g_sum_montant := g_sum_montant + rec_c_retrocession.montant;
      g_sum_montant_d := g_sum_montant_d + rec_c_retrocession.montant_d;
      g_devise := rec_c_retrocession.monnaie;
      g_devise_d := rec_c_retrocession.monnaie_d;
--
      g_niv_msg := 3;
      g_msg_adm :=
            'Société '
         || TO_CHAR (rec_c_retrocession.numsoc)
         || ' Intermédiaire '
         || TO_CHAR (rec_c_retrocession.numindiv)
         || ' : '
         || TO_CHAR (rec_c_retrocession.montant, '999999990.90')
         || ' Cumul : '
         || TO_CHAR (g_sum_montant, '999999990.90');
      p_ins_journal;
--
-- Affectation des anciennes valeurs pour controler la rupture
      g_last_numsoc := rec_c_retrocession.numsoc;
      g_last_numindiv := rec_c_retrocession.numindiv;
      g_last_idaffec := rec_c_retrocession.idaffec;
      g_last_type_tfc := rec_c_retrocession.type_tfc;
      g_last_monnaie_d := rec_c_retrocession.monnaie_d;
      g_last_typgar := rec_c_retrocession.typgar;
      o_erreur := g_erreur;
      -- PHA 21/03/2011 gestion boucle ici et plus dans ba21
      EXIT WHEN C_retrocession%NOTFOUND;
      END LOOP;
      -- / PHA 21/03/2011
--
   EXCEPTION
      WHEN OTHERS
      THEN
         --
         -- Insertion dans journal_adm du message d'erreur
         --
         g_msg_adm := SUBSTR (SQLERRM (SQLCODE), 1, 128);
         o_erreur := SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_niv_msg := 0;
         p_ins_journal;
   --
   END p_sel_retrocession;

--
-- ----------------------------- Fin des procedures publiques ------------------

   -- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
--
-- Controle des modalites de reglement
--
   PROCEDURE p_ctrl_montant
   IS
      l_seuil       NUMBER;
      l_delai       NUMBER;
      l_frequence   NUMBER;
      l_found       BOOLEAN;
      l_valide      BOOLEAN := FALSE;
   BEGIN
--
      g_proc := 'P_CTRL_montant';
      -- PHA 21/03/2011 gestion idrevers unifiée
      -- g_idrevers := f_max_idrevers;
--
-- Recherche du mode de reglement de l'intermediaire
--
      g_bene_modpmt :=
         pk_treso.f_bene_modpmt (i_numindiv      => g_last_numindiv,
                                 i_type          => 1,
                                 i_codope        => 10
                                );
--
      g_niv_msg := 2;
      g_msg_adm :=
            'Bénéficiaire '
         || TO_CHAR (g_last_numindiv)
         || ' '
         || pk_personne.f_nom (g_last_numindiv, 20)
         || ' Règlement '
         || TO_CHAR (g_bene_modpmt)
         || ' - '
         || pk_libelle.f_lib ('MOPM', g_bene_modpmt)
         || ' Montant '
         || TO_CHAR (g_sum_montant, '999999990.90');
      p_ins_journal;
--
-- Controle du seuil de reglement
      pk_treso.p_sel_param_ope (i_numsoc         => g_last_numsoc,
                                i_numorg         => 0,
                                i_numgar         => NULL,
                                i_codope         => cst_codope,
                                i_modpmt         => g_bene_modpmt,
                                o_montant        => l_seuil,
                                o_delai          => l_delai,
                                o_frequence      => l_frequence,
                                o_found          => l_found
                               );

      IF (l_found)
      THEN
         g_niv_msg := 2;
         g_msg_adm :=
               'Montant du bordereau '
            || TO_CHAR (g_sum_montant)
            || ' Montant minimum '
            || TO_CHAR (l_seuil);
         p_ins_journal;
         g_msg_adm :=
               'Date de reference '
            || d2e (g_min_dataffec)
            || ' Délai de rétention '
            || TO_CHAR (l_delai);
         p_ins_journal;
      ELSE
         g_niv_msg := 2;
         g_msg_adm := 'Aucun paramétrage de modalité de règlement défini';
         p_ins_journal;
         l_seuil := 0;
      END IF;

--
      IF (g_sum_montant < l_seuil)
      THEN
         g_niv_msg := 2;

         --
         IF (g_min_dataffec + l_delai <= TRUNC (SYSDATE))
         THEN
            g_msg_adm := 'Délai de rétention atteint';
            l_valide := TRUE;
         ELSE
            g_msg_adm :=
                  'Montant minimum de règlement ('
               || TO_CHAR (l_seuil)
               || ' '
               || pk_devise.symbole (g_devise)
               || ') non atteint.';
            l_valide := FALSE;
         END IF;
      ELSE
         l_valide := TRUE;
         g_msg_adm := 'Montant atteint';
         --
         p_ins_journal;
      END IF;

--
      IF (l_valide)
      THEN
         -- Insertion dans retrocession
         --
         g_rollback := FALSE;
         g_commit := TRUE;
         p_ins_retrocession;
      ELSE
         g_rollback := TRUE;
         p_raz_qttc_affec (i_idrevers => g_idrevers);
      END IF;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procédure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
   END p_ctrl_montant;

--
-- Remise a zero de l'idrevers si Bx non construit
--
   PROCEDURE p_raz_qttc_affec (i_idrevers IN qttc_affec_tfc.idrevers%TYPE)
   IS
   BEGIN
      UPDATE qttc_affec_tfc
         SET idrevers = 0
       WHERE idrevers = i_idrevers AND tfc = 5;
   END p_raz_qttc_affec;

--
-- Insertion dans retrocession
--
   PROCEDURE p_ins_retrocession
   IS
      l_valide      VARCHAR2 (1);
      l_datvalide   DATE;
      l_numutil     NUMBER;
      l_mini        NUMBER;
      l_maxi        NUMBER;
      l_found       BOOLEAN      := FALSE;
      l_montant     NUMBER       := 0;
      l_montant_d   NUMBER       := 0;
   BEGIN
      g_proc := 'P_INS_retrocession';
--
-- Recherche si le bordereau doit donner lieu a validation
--
      g_niv_msg := 2;
      g_msg_adm := 'Recherche parametres de validation';
      p_ins_journal;
      g_msg_adm :=
            'Codope '
         || TO_CHAR (cst_codope)
         || ' Numsoc '
         || TO_CHAR (g_last_numsoc)
         || ' Montant '
         || TO_CHAR (g_sum_montant);
      p_ins_journal;
--
      pk_treso.p_sel_validateur_auto (i_codope       => cst_codope,
                                      i_numsoc       => g_last_numsoc,
                                      i_montant      => g_sum_montant_d,
                                      o_found        => l_found
                                     );
--
      g_niv_msg := 2;

      IF (l_found)
      THEN
         g_msg_adm := 'Validation automatique';
         l_valide := 'O';
         l_datvalide := TRUNC (SYSDATE);
         g_auto_valide := TRUE;
         l_numutil := 0;
      ELSE
         l_valide := 'N';
         l_datvalide := NULL;
         g_auto_valide := FALSE;
         l_numutil := NULL;
         g_msg_adm :=
               'Le bordereau n°'
            || g_idrevers
            || ' ne peut pas être validé automatiquement';
      END IF;

      p_ins_journal;
--
      g_msg_adm := 'Insertion dans retrocession';
      p_ins_journal;

--

      SELECT SUM(NVL(MONTANT,0)), SUM(NVL(MONTANT_D,0))
          INTO l_montant, l_montant_d
          FROM qttc_affec_tfc WHERE idrevers = g_idrevers;

      IF NVL(l_montant,0) != NVL(g_sum_montant,0) OR NVL(g_sum_montant_d,0) != NVL(l_montant_d,0) THEN
        g_niv_msg := 1;
        g_msg_adm := 'ATTENTION, le bordereau n°' || g_idrevers || ' est en anomalie : Ecart entre montant total et somme du détail';
        p_ins_journal;
      END IF;
--
      INSERT INTO retrocession
                  (idrevers, numsoc, numindiv, datrevers,
                   dataffec, echeance, montant, montant_d,
                   valide, numutil, datvalide, monnaie,
                   monnaie_d, typgar
                  )
           VALUES (g_idrevers, g_last_numsoc, g_last_numindiv, SYSDATE,
                   g_dataffec, g_echeance, g_sum_montant, g_sum_montant_d,
                   l_valide, l_numutil, l_datvalide, g_devise,
                   g_last_monnaie_d, g_last_typgar
                  );

--
      IF (g_auto_valide)
      THEN
         p_rglt_auto;
      END IF;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procédure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm := SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
   END p_ins_retrocession;

--
-- Procedure de decaissement automatique
--
   PROCEDURE p_rglt_auto
   IS
      l_idmvt              compte_tiers.idmvt%TYPE;
      l_idcomp             compensation.idcomp%TYPE;
      l_numaffec           affectation.numaffec%TYPE;
      l_numdecaismt        decaismt.numdecaismt%TYPE;
      l_numcpte            compte.numcpte%TYPE;
      l_libcompte          compte.libcompte%TYPE;
      l_papid              papier_ope.papid%TYPE;
      l_found              BOOLEAN;
      l_found_compte_def   NUMBER;
      l_numutil            NUMBER;
      l_mini               NUMBER;
      l_maxi               NUMBER;
      l_rglt_auto          NUMBER;
   BEGIN
--
      g_proc := 'P_RGLT_auto';
--
-- Recherche du compte de paiement par défaut
      pk_treso.p_sel_def_compte (i_numsoc         => g_last_numsoc,
                                 i_codope         => 10,
                                 i_modpmt         => g_bene_modpmt,
                                 o_numcpte        => l_numcpte,
                                 o_libcompte      => l_libcompte,
                                 o_papid          => l_papid,
                                 o_found          => l_found
                                );
--
-- L_found_compte_def = 1 ==> compte par défaut trouvé
      l_found_compte_def := 0;

--
      IF (l_found)
      THEN
         --
         g_niv_msg := 2;
         g_msg_adm :=
             'Compte par défaut ' || TO_CHAR (l_numcpte) || ' '
             || l_libcompte;
         p_ins_journal;
         --
         l_found_compte_def := 1;
      --
      END IF;

      --
      pk_treso.p_sel_validateur_auto (i_codope       => 10,
                                      i_numsoc       => g_last_numsoc,
                                      i_montant      => g_sum_montant,
                                      o_found        => l_found
                                     );

      IF (l_found)
      THEN
         l_numutil := 0;
      ELSE
         l_numutil := -1;
      END IF;

	-- VCR 10/03/2009 - Fiche Humanis 2110
	-- Ajout de la condition sur sur le montant du bordereau < 0
	-- Insertion dans compte_tiers - Bdx négatif => sens = -1
	-- Montants en valeur absolue
	--
	IF (  g_sum_montant_d < 0) THEN
		BEGIN
			 --
			 g_msg_adm := 'Insertion dans compte_tiers - Bdx négatif';
			 p_ins_journal;
			 --
			 -- Insertion dans compte_tiers
			 pk_treso.p_ins_compte_tiers (i_numcli         => g_last_numindiv,
										  i_codope         => cst_codope,
										  i_cle            => g_idrevers,
										  i_datope         => TRUNC (SYSDATE),
										  i_sens           => -1,
										  i_montant        => ABS(g_sum_montant),
										  i_montant_d      => ABS(g_sum_montant_d),
										  i_monnaie        => g_devise,
										  i_monnaie_d      => g_last_monnaie_d,
										  o_idmvt          => l_idmvt
										 );
		EXCEPTION
			WHEN OTHERS
			THEN
				RAISE;
		END;

	ELSE

		BEGIN
			 --
			 g_msg_adm := 'Insertion dans compte_tiers - Bdx positif';
			 p_ins_journal;
			 --
			 -- Insertion dans compte_tiers
			 pk_treso.p_ins_compte_tiers (i_numcli         => g_last_numindiv,
										  i_codope         => cst_codope,
										  i_cle            => g_idrevers,
										  i_datope         => TRUNC (SYSDATE),
										  i_sens           => 1,
										  i_montant        => g_sum_montant,
										  i_montant_d      => g_sum_montant_d,
										  i_monnaie        => g_devise,
										  i_monnaie_d      => g_last_monnaie_d,
										  o_idmvt          => l_idmvt
										 );
		EXCEPTION
			 WHEN OTHERS
			 THEN
				RAISE;
		END;

		  --
		  -- Reglement automatique
		  -- f_rglt_auto retourne 1 si auto (0 dans les autres cas)
		  --
		  l_rglt_auto := f_rglt_auto (g_bene_modpmt);

		  --
		  -- Insertion dans decaismt seulement pour les modes de paiement auto
		  -- et si compte par defaut trouve
		  -- Si L_rglt_auto = 1 ==> Insertion dans affectation et decaismt (rglt auto)
		  -- Sinon Insertion dans affectation avec un decaismt à NULL
		  IF (l_rglt_auto = 1 AND l_found_compte_def = 1)
		  THEN
			 --
			 g_msg_adm := 'Insertion dans decaismt';
			 p_ins_journal;

			 --
			 -- Insertion du decaissement
			 BEGIN
				pk_treso.p_ins_decaismt (i_codope           => 10,
										 i_numcpte          => l_numcpte,
										 i_modpmt           => g_bene_modpmt,
										 i_montant          => g_sum_montant,
										 i_montant_d        => g_sum_montant_d,
										 i_typbene          => NULL,
										 i_numbene          => g_last_numindiv,
										 i_numdest          => g_last_numindiv,
										 i_numutil          => l_numutil,
										 i_monnaie          => g_devise,
										 i_monnaie_d        => g_last_monnaie_d,
										 i_montant_ct       => g_sum_montant_d,
										 i_devise_ct        => g_last_monnaie_d,
										 o_numdecaismt      => l_numdecaismt
										);
			 EXCEPTION
				WHEN OTHERS
				THEN
				   RAISE;
			 END;

			 --
			 g_msg_adm := 'Insertion dans affectation';
			 p_ins_journal;

			 --
			 -- Insertion d'une ligne dans affectation
			 --
			 BEGIN
				pk_treso.p_ins_affectation (i_codope           => 10,
											i_numdecaismt      => l_numdecaismt,
											i_montant          => g_sum_montant,
											i_montant_d        => g_sum_montant_d,
											i_monnaie          => g_devise,
											i_monnaie_d        => g_last_monnaie_d,
											i_numcli           => g_last_numindiv,
											i_numaffec         => G_idrevers, -- NULL, 21/03/2011 PHA passage de idrevers
											i_montant_ct       => g_sum_montant_d,
											i_devise_ct        => g_last_monnaie_d,
											o_numaffec         => l_numaffec
										   );
			 EXCEPTION
				WHEN OTHERS
				THEN
				   RAISE;
			 END;
		  --
		  ELSE
			 --
			 g_msg_adm := 'Insertion dans affectation';
			 p_ins_journal;

			 --
			 -- Insertion d'une ligne dans affectation
			 --
			 BEGIN
				pk_treso.p_ins_affectation (i_codope           => 10,
											i_numdecaismt      => NULL,
											i_montant          => g_sum_montant,
											i_montant_d        => g_sum_montant_d,
											i_monnaie          => g_devise,
											i_monnaie_d        => g_last_monnaie_d,
											i_numcli           => g_last_numindiv,
											i_numaffec         => G_idrevers, -- NULL, 21/03/2011 PHA passage de idrevers
											i_montant_ct       => g_sum_montant_d,
											i_devise_ct        => g_last_monnaie_d,
											o_numaffec         => l_numaffec
										   );
			 EXCEPTION
				WHEN OTHERS
				THEN
				   RAISE;
			 END;

			 --
			 g_msg_adm :=
				   'Le décaissement n''a pas été créé pour le bordereau n°'
				|| g_idrevers;
			 p_ins_journal;
		  --
		  END IF;

		  --
		  g_msg_adm := 'Insertion dans compte_tiers (compensation)';
		  p_ins_journal;

		  --
		  -- Insertion dans compensation d'un mouvement correspondant au debit
		  BEGIN
			 pk_treso.p_ins_compte_tiers (i_numcli         => g_last_numindiv,
										  i_codope         => 10,
										  i_cle            => l_numaffec,
										  i_datope         => TRUNC (SYSDATE),
										  i_sens           => -1,
										  i_montant        => g_sum_montant,
										  i_montant_d      => g_sum_montant_d,
										  i_monnaie        => g_devise,
										  i_monnaie_d      => g_last_monnaie_d,
										  o_idmvt          => l_idcomp
										 );
		  EXCEPTION
			 WHEN OTHERS
			 THEN
				RAISE;
		  END;

		  --
		  g_msg_adm := 'Insertion dans compensation';
		  p_ins_journal;

		  --
		  --
		  BEGIN
			 pk_treso.p_ins_compensation (i_idmvt       => l_idmvt,
										  i_idcomp      => l_idcomp
										 );
		  EXCEPTION
			 WHEN OTHERS
			 THEN
				RAISE;
		  END;
	--
	END IF;
   --
   END p_rglt_auto;

--
-- Flag de qttc_affec_tfc avec l'idrevers
--
   PROCEDURE p_upd_qttc_affec (
      i_idrevers        IN   qttc_affec_tfc.idrevers%TYPE,
      i_idaffec         IN   qttc_affec_tfc.idaffec%TYPE,
      i_tfc             IN   qttc_affec_tfc.tfc%TYPE,
      i_numbene         IN   qttc_affec_tfc.numbene%TYPE,
      i_type_tfc        IN   qttc_affec_tfc.type_tfc%TYPE,
      i_prelev_revers   IN   qttc_affec_tfc.prelev_revers%TYPE DEFAULT NULL
   )
   IS
   BEGIN
      UPDATE qttc_affec_tfc
         SET idrevers = i_idrevers
       WHERE idaffec = i_idaffec
         AND tfc = i_tfc
         AND numbene = i_numbene
         AND type_tfc = i_type_tfc
         AND NVL (prelev_revers, -1) = NVL (i_prelev_revers, -1);
   END;

--
-- Retourne le prochain idrevers
--
   FUNCTION f_max_idrevers
      RETURN retrocession.idrevers%TYPE
   IS
--      CURSOR c_retrocession
--      IS
--         SELECT NVL (MAX (idrevers), 0) + 1
--           FROM retrocession;

--
      l_idrevers   retrocession.idrevers%TYPE;
--
   BEGIN

-- Mis en commentaire du curseur suite uniformisation des idrevers de reversements PHA 21/03/2011
--      OPEN c_retrocession;
--      FETCH c_retrocession
--       INTO l_idrevers;

      select IDREVERS.nextval INTO L_idrevers from dual;

      RETURN l_idrevers;
   END f_max_idrevers;

--
-- Retourne le prochain idligne
--
   FUNCTION f_max_idligne (i_session IN journal_adm.id_session%TYPE)
      RETURN NUMBER
   IS
      l_idligne   NUMBER;
   BEGIN
      SELECT NVL (MAX (idligne), 0)
        INTO l_idligne
        FROM journal_adm
       WHERE id_session = i_session;

--
      RETURN (l_idligne);
--
   END f_max_idligne;

--
-- Insertion dans journal_adm
--
   PROCEDURE p_ins_journal
   IS
      l_idligne   NUMBER;
   BEGIN
--
      IF (g_niv_msg <= g_max_msg)
      THEN
         --
         g_idligne := g_idligne + 1;

         IF (g_niv_msg = 0)
         THEN
            l_idligne := -1 * g_idligne;
         ELSE
            l_idligne := g_idligne;
         END IF;

         --
         pk_trace.p_ins_journal_adm (i_nom_traitement      => g_nom_traitement,
                                     i_session             => g_session,
                                     i_niv_msg             => g_niv_msg,
                                     i_msg_adm             => g_msg_adm,
                                     i_idligne             => l_idligne
                                    );
      --
      END IF;
   END p_ins_journal;
--                            ------------------------------------ Fin des corps des procedures privees --

   -- Fonction renvoi un montant global des commissions, permettant de retro-calculer un montant de cotisation par rapport à une commission.
   FUNCTION F_MntGlobalCom (i_NumQuit  IN Qttc_Affec_TFC.NUMQUIT%TYPE,
                            i_IdRevers IN Qttc_Affec_TFC.IDREVERS%TYPE,
                            i_TFC      IN Qttc_Affec_TFC.TFC%TYPE,
                            i_TypeTFC  IN Qttc_Affec_TFC.Type_TFC%TYPE)
   RETURN NUMBER
   IS
     i_Montant    Qttc_Affec.Montant_D%TYPE;
     i_IdAffec    Qttc_Affec.IdAffec%TYPE;
   BEGIN
     -- NumQuit est obligatoire
     IF i_NumQuit IS NULL THEN
       RAISE NO_DATA_FOUND;
     END IF;

     SELECT SUM(Montant_D)
       INTO i_Montant
       FROM Qttc_Affec
      WHERE IdAffec IN (SELECT IdAffec
                          FROM qttc_affec_tfc
                         WHERE NumQuit=i_NumQuit
                           AND IdRevers = NVL(i_IdRevers,IdRevers)
                           AND TFC = NVL(i_TFC,TFC)
                           AND Type_TFC =NVL(i_TypeTFC,Type_TFC)
                       )
        AND NumFor = 0;

     RETURN (i_Montant);
   EXCEPTION
     WHEN OTHERS THEN RETURN NULL;
   END F_MntGlobalCom;

END;
/
