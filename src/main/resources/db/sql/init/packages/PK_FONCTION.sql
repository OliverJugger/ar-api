CREATE OR REPLACE PACKAGE ARTHUS."PK_FONCTION"
AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_fonction.sql  1.1  03/08/25

   -- -- CONSTANTES PUBLIQUE -----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des constantes publiques --

   -- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des exceptions publiques --

   -- -- TYPES PUBLIQUES ---------------------------------------------------------
   TYPE t_valeur IS TABLE OF VARCHAR2 (45)
      INDEX BY BINARY_INTEGER;

   TYPE t_typ_date IS TABLE OF BOOLEAN
      INDEX BY BINARY_INTEGER;

-- ------------------------------------------------- Fin des types publiques --

   -- -- VARIABLES PUBLIQUES -----------------------------------------------------
   t_val_arg   t_valeur;
   t_date      t_typ_date;

-- --------------------------------------------- Fin des variables publiques --

   -- -- PROCEDURES PUBLIQUES ----------------------------------------------------
--
-- Retourne la valeur d'une fonction
--
   PROCEDURE p_sel_fonction (
      i_fonction   IN       VARCHAR2,
      i_nbarg      IN       NUMBER,
      t_val_arg    IN       t_valeur,
      t_date       IN       t_typ_date,
      i_typ_date   IN       BOOLEAN,
      i_session    IN       journal_adm.id_session%TYPE DEFAULT 1,
      i_max_msg    IN       journal_adm.niv_msg%TYPE := 1,
      i_idligne    IN       journal_adm.idligne%TYPE,
      o_idligne    OUT      journal_adm.idligne%TYPE,
      o_valeur     OUT      NUMBER
   );
   --,
   --O_found      OUT   Boolean
   --);
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_FONCTION"
AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_fonction.sql  1.1  03/08/25

   -- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --

   -- -- EXCEPTIONS PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions privees --

   -- -- TYPES PRIVEES -----------------------------------------------------------

   -- --------------------------------------------------- Fin des types privees --

   -- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
--@global
   g_fonction                  VARCHAR2 (100);
   g_nbarg                     NUMBER;
   g_t_val_arg                 t_valeur;
   g_t_date                    t_typ_date;
   g_typ_date                  BOOLEAN;
--
-- Variables de P_INS_journal
--
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE
                                                          DEFAULT 'pk_calcul';
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE       DEFAULT 1;
   g_niv_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_max_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_idligne                   journal_adm.idligne%TYPE          := 0;
   g_proc                      VARCHAR2 (80);
   g_pays                      NUMBER              DEFAULT pk_devise.pays_ref;
   g_type_msg                  NUMBER;
   g_liste_param               VARCHAR2 (128);

--
-- G_niv_msg prend les Valeurs :
-- 0 --> Message d'erreurs (Erreur ORACLE)
-- 1 --> Message informatif(tout se passe bien)
-- 2 et + Niveau de detail

   -- -------------------------------------- Fin des variables globales privees --

   -- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--
-- Procedure IND -> Valeur d'un indice a une date
--
   PROCEDURE p_sel_indice (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure TAB -> Valeur d'un tableau a une date
--
   PROCEDURE p_sel_tableau (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Insertion dans journal_adm
--
   PROCEDURE p_ins_journal;

--
-- Procedure AN -> Calcul de l'année civile de la date
--
   PROCEDURE p_sel_annee_civile (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure SAN -> Calcul de l'année civile suivant la date
--
   PROCEDURE p_sel_annee_suivante (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure MENS -> Calcul du mois civil de la date
--
   PROCEDURE p_sel_mois_civil (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure SMENS -> Calcul du mois civil suivant la date
--
   PROCEDURE p_sel_mois_suivant (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure TRIM -> Retourne la date du premier jour du trimestre pour la date donnee
--
   PROCEDURE p_sel_trimestre (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure STRIM -> Retourne la date du premier jour du trimestre suivant la date donnee
--
   PROCEDURE p_sel_trimestre_suivant (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure AGE_P -> CALCUL DE L'AGE D'UNE PERSONNE
--
   PROCEDURE p_sel_age (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure AGE_MP -> CALCUL DE L'AGE MILLESIME D'UNE PERSONNE
--
   PROCEDURE p_sel_age_millesime (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure NB_ADR ou NBI_ADR -> Calcule le nombre d'ayant droit dependant d'un assure pour un type donne
--
   PROCEDURE p_sel_nb_ayant_droit (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure TRF -> CALCUL DU TARIF
--
   PROCEDURE p_sel_tarif (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure TM -> CALCUL DU TICKET MODERATEUR
--
   PROCEDURE p_sel_ticket_moderateur (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure TMRL -> CALCUL DU TICKET MODERATEUR RECONSTITUE LIMITE
--
   PROCEDURE p_sel_tmrl (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure TML -> CALCUL DU TICKET MODERATEUR LIMITE
--
   PROCEDURE p_sel_tml (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure RBR -> CALCUL DU REMBOURSEMENT RECONSTITUE
--
   PROCEDURE p_sel_rbt_reconstitue (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure SEMI -> CALCUL DU SEMESTRE CIVIL DE LA DATE
--
   PROCEDURE p_sel_semestre_civil (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure SSEMI -> CALCUL DU SEMESTRE CIVIL SUIVANT LA DATE
--
   PROCEDURE p_sel_semestre_suivant (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure REG -> Recherche du regime de base de la personne
--
   PROCEDURE p_sel_reg_base (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure T_AYDR -> Recherche du type d'ayant droit de l'assure
--
   PROCEDURE p_sel_type_ad (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure R_AYDR ou RI_AYDR-> Recherche du rang d'un ayant droit
--
   PROCEDURE p_sel_rang_ad (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure DEPEND -> Teste l'existence d'une dependance entre deux personnes
--
   PROCEDURE p_sel_dependance (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure NB_DEPEND -> Calcule le nombre de dependances entre deux personnes
--
   PROCEDURE p_sel_nb_depend (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure TAB2 -> Retourne la valeur correspondant a la cle2 pour la cle1 dans le tableau
--
   PROCEDURE p_sel_tab2 (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure AM -> Ajoute un nombre de mois à une date
--
   PROCEDURE p_sel_ajoute_mois (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure RATIO -> CALCUL DE RATIO
--
   PROCEDURE p_sel_ratio (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure TR -> CALCUL DU TARIF RECONSTITUE
--
   PROCEDURE p_sel_tarif_reconstitue (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure ROUND -> Retourne la valeur arrondie
--
   PROCEDURE p_sel_round (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure SUP -> Retourne l'arrondi supérieur d'une valeur
--
   PROCEDURE p_sel_sup (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure INF -> Retourne l'arrondi à la valeur inférieure
--
   PROCEDURE p_sel_inf (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure J_CONSO -> Recherche du nombre de jours consommes en arrets et rentes
--
   PROCEDURE p_sel_j_conso (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure NAYDR -> Recherche d'un ayant droit d'un type donne
--
   PROCEDURE p_sel_ayant_droit (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure MT_COT_REG -> Ramene le montant des cotisations reglees pour une periode
--
   PROCEDURE p_sel_mt_cot_reg (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure DADC -> Recherche de la date de debut du 1er arret continu en fonction d'un type
--
   PROCEDURE p_sel_dadc (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure REJET -> Recherche des frais de rejets pour un appel
--
   PROCEDURE p_sel_rejet (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure NGROUPE -> Recherche le n° d'1 ayant-droit de type donne pour 1 assure principal
--
   PROCEDURE p_sel_n_groupe (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure PERS_SEXE -> Recherche du sexe d'une personne
--
   PROCEDURE p_sel_sexe (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure ACTE_CONSO -> Consommation acte soins de sante
--
   PROCEDURE p_sel_acte_conso (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure NB_MOIS (PRORA) -> Retourne un nombre de mois écoulé entre 2 dates
--
   PROCEDURE p_sel_prora (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure MIN2 -> Retourne le minimum entre 2 valeurs
--
   PROCEDURE p_sel_min2 (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure MIN3 -> Retourne le minimum entre 3 valeurs
--
   PROCEDURE p_sel_min3 (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure MAX2 -> Retourne le maximum entre 2 valeurs
--
   PROCEDURE p_sel_max2 (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure MAX3 -> Retourne le maximum entre 3 valeurs
--
   PROCEDURE p_sel_max3 (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure TEST -> Retourne une valeur conditionnée
--
   PROCEDURE p_sel_test (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure NOT -> Procedure logique de négation
--
   PROCEDURE p_sel_not (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure NAT -> Retourne le code pays relatif à la nationalité
--
   PROCEDURE p_sel_codpays (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure DEF ->  Recherche de la valeur de la variable idvariable
--
   PROCEDURE p_sel_valeur_variable (o_valeur OUT NUMBER, o_found OUT BOOLEAN);

--
-- Procedure REMPLACE_POINT ->  Remplace un point par une virgule dans un chaine de caractères numériques
--
   PROCEDURE remplace_point (i_chaine IN VARCHAR2, o_chaine OUT VARCHAR2);

-- ----------------------------- Fin des declarations des procedures privees --

   -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--
-- Retourne la valeur d'une fonction
--
   PROCEDURE p_sel_fonction (
      i_fonction   IN       VARCHAR2,
      i_nbarg      IN       NUMBER,
      t_val_arg    IN       t_valeur,
      t_date       IN       t_typ_date,
      i_typ_date   IN       BOOLEAN,
      i_session    IN       journal_adm.id_session%TYPE DEFAULT 1,
      i_max_msg    IN       journal_adm.niv_msg%TYPE := 1,
      i_idligne    IN       journal_adm.idligne%TYPE,
      o_idligne    OUT      journal_adm.idligne%TYPE,
      o_valeur     OUT      NUMBER
   )
   -- ,
   --O_found      OUT   Boolean
   --)
   IS
      i          BINARY_INTEGER;
      l_valeur   NUMBER;
      l_found    BOOLEAN;
   BEGIN
      g_fonction := i_fonction;
      g_nbarg := i_nbarg;
      g_t_val_arg := t_val_arg;
      g_t_date := t_date;
      g_typ_date := i_typ_date;
      g_session := i_session;
      g_max_msg := i_max_msg;
      g_idligne := i_idligne;
--
      g_niv_msg := 3;
      g_msg_adm := 'Recherche valeur de ' || g_fonction;

      FOR i IN 1 .. g_nbarg
      LOOP
         IF (g_t_date (i))
         THEN
            g_msg_adm :=
               g_msg_adm || ' Arg # ' || TO_CHAR (i) || ' : '
               || g_t_val_arg (i);
         ELSE
            g_msg_adm :=
               g_msg_adm || ' Arg # ' || TO_CHAR (i) || ' : '
               || g_t_val_arg (i);
         END IF;
      END LOOP;

      p_ins_journal;

--
      IF (g_fonction = 'IND')
      THEN
         p_sel_indice (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'TAB')
      THEN
         p_sel_tableau (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'AN')
      THEN
         p_sel_annee_civile (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'SAN')
      THEN
         p_sel_annee_suivante (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'MENS')
      THEN
         p_sel_mois_civil (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'SMENS')
      THEN
         p_sel_mois_suivant (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'TRIM')
      THEN
         p_sel_trimestre (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'STRIM')
      THEN
         p_sel_trimestre_suivant (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'AGE_P')
      THEN
         p_sel_age (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'AGE_MP')
      THEN
         p_sel_age_millesime (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'NB_ADR')
      THEN
         g_t_val_arg (4) := g_t_val_arg (3);
         g_t_val_arg (3) := g_t_val_arg (2);
         g_t_date (4) := g_t_date (3);
         g_t_date (3) := g_t_date (2);
         p_sel_nb_ayant_droit (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'NBI_ADR')
      THEN
         p_sel_nb_ayant_droit (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'TRF')
      THEN
         p_sel_tarif (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'TM')
      THEN
         p_sel_ticket_moderateur (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'TMRL')
      THEN
         p_sel_tmrl (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'TML')
      THEN
         p_sel_tml (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'RBR')
      THEN
         p_sel_rbt_reconstitue (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'SEMI')
      THEN
         p_sel_semestre_civil (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'SSEMI')
      THEN
         p_sel_semestre_suivant (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'REG')
      THEN
         p_sel_reg_base (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'T_AYDR')
      THEN
         p_sel_type_ad (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'R_AYDR')
      THEN
         g_t_val_arg (4) := g_t_val_arg (3);
         g_t_val_arg (3) := g_t_val_arg (2);
         g_t_date (4) := g_t_date (3);
         g_t_date (3) := g_t_date (2);
         p_sel_rang_ad (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'RI_AYDR')
      THEN
         p_sel_rang_ad (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'DEPEND')
      THEN
         p_sel_dependance (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'NB_DEPEND')
      THEN
         p_sel_nb_depend (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'TAB2')
      THEN
         p_sel_tab2 (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'AM')
      THEN
         p_sel_ajoute_mois (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'RATIO')
      THEN
         p_sel_ratio (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'TR')
      THEN
         p_sel_tarif_reconstitue (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'ROUND')
      THEN
         p_sel_round (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'SUP')
      THEN
         p_sel_sup (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'INF')
      THEN
         p_sel_inf (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'J_CONSO')
      THEN
         p_sel_j_conso (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'NAYDR')
      THEN
         p_sel_ayant_droit (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'MT_COT_REG')
      THEN
         p_sel_mt_cot_reg (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'DADC')
      THEN
         p_sel_dadc (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'REJET')
      THEN
         p_sel_rejet (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'NGROUPE')
      THEN
         p_sel_n_groupe (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'PERS_SEXE')
      THEN
         p_sel_sexe (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'ACTE_CONSO')
      THEN
         p_sel_acte_conso (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'NB_MOIS')
      THEN
         p_sel_prora (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'MIN2')
      THEN
         p_sel_min2 (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'MIN3')
      THEN
         p_sel_min3 (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'MAX2')
      THEN
         p_sel_max2 (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'MAX3')
      THEN
         p_sel_max3 (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'TEST')
      THEN
         p_sel_test (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'NOT')
      THEN
         p_sel_not (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'NAT')
      THEN
         p_sel_codpays (o_valeur => l_valeur, o_found => l_found);
      ELSIF (g_fonction = 'DEF')
      THEN
         p_sel_valeur_variable (o_valeur => l_valeur, o_found => l_found);
      END IF;

      o_idligne := g_idligne;
      o_valeur := l_valeur;
-- O_found := L_found;
   END p_sel_fonction;

-- ---------------------------------- Fin des corps des procedures publiques --

   -- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--
-- Procedure IND -> Valeur d'un indice a une date
--
   PROCEDURE p_sel_indice (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_valeur       NUMBER;
      l_lib_indice   VARCHAR2 (45);

      CURSOR c_lib_indice
      IS
         SELECT libelle.libelle
           FROM libelle
          WHERE libelle.mnemo = 'INDC'
            AND libelle.code = TO_NUMBER (g_t_val_arg (1));

--
      CURSOR c_indice
      IS
         SELECT indice.valeur
           FROM indice
          WHERE indice = TO_NUMBER (g_t_val_arg (1))
            AND e2d (g_t_val_arg (2)) BETWEEN datapli
                                          AND NVL (datper,
                                                   e2d (g_t_val_arg (2))
                                                  );
   BEGIN
--
      g_proc := 'P_SEL_indice';
      g_liste_param := NULL;

--
      OPEN c_lib_indice;

      FETCH c_lib_indice
       INTO l_lib_indice;

      IF (c_lib_indice%FOUND)
      THEN
         --
         g_niv_msg := 2;
         g_msg_adm :=
                    'Valeur de ' || l_lib_indice || ' au ' || g_t_val_arg (2);

         --
         OPEN c_indice;

         FETCH c_indice
          INTO l_valeur;

         IF (c_indice%FOUND)
         THEN
            o_valeur := l_valeur;
            o_found := TRUE;
            g_msg_adm := g_msg_adm || ' : ' || TO_CHAR (o_valeur);
            p_ins_journal;
         ELSE
            o_valeur := NULL;
            o_found := FALSE;
            g_liste_param := l_lib_indice || ' | ' || g_t_val_arg (2);
            pk_calcul.p_gest_err_calc (i_idfonction       => 12,
                                       i_code_msg         => 2,
                                       i_liste_param      => g_liste_param,
                                       i_proc             => g_proc,
                                       i_idligne          => g_idligne,
                                       o_idligne          => g_idligne
                                      );
         --
         END IF;

         CLOSE c_indice;
      ELSE
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := g_t_val_arg (1);
         pk_calcul.p_gest_err_calc (i_idfonction       => 12,
                                    i_code_msg         => 1,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_lib_indice;
   END p_sel_indice;

--
-- Procedure TAB -> Valeur d'un tableau a une date
--
   PROCEDURE p_sel_tableau (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_tableau       lib_tableau.tableau%TYPE;
      l_clef          tableau.clef%TYPE;
      l_debut         VARCHAR2 (10);
      l_idtableau     BINARY_INTEGER;
      l_type          BINARY_INTEGER;
      l_valeur        tableau.valeur%TYPE;
      l_lib_tableau   VARCHAR2 (45);

--
      CURSOR c_lib_tableau
      IS
         SELECT idtableau, nom_tableau, TYPE
           FROM lib_tableau
          WHERE tableau = g_t_val_arg (1)
            AND e2d (g_t_val_arg (3)) BETWEEN debut
                                          AND NVL (fin, e2d (g_t_val_arg (3)));

--
      CURSOR c_val_exacte (p_idtableau IN BINARY_INTEGER)
      IS
         SELECT valeur
           FROM tableau
          WHERE idtableau = p_idtableau AND clef = TO_NUMBER (g_t_val_arg (2));

--
      CURSOR c_val_sup (p_idtableau IN BINARY_INTEGER)
      IS
         SELECT valeur
           FROM tableau
          WHERE idtableau = p_idtableau
                AND clef >= TO_NUMBER (g_t_val_arg (2));

--
      CURSOR c_val_inf (p_idtableau IN BINARY_INTEGER)
      IS
         SELECT valeur
           FROM tableau
          WHERE idtableau = p_idtableau AND clef < TO_NUMBER (g_t_val_arg (2));
--
   BEGIN
--
      g_proc := 'P_SEL_tableau';
      g_liste_param := NULL;
--
      l_tableau := g_t_val_arg (1);
      l_clef := TO_NUMBER (g_t_val_arg (2));
      l_debut := g_t_val_arg (3);

      OPEN c_lib_tableau;

      FETCH c_lib_tableau
       INTO l_idtableau, l_lib_tableau, l_type;

--
      g_liste_param := l_tableau || ' | ' || l_debut;
      pk_calcul.p_gest_err_calc (i_idfonction       => 37,
                                 i_code_msg         => 4,
                                 i_liste_param      => g_liste_param,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      IF (c_lib_tableau%FOUND)
      THEN
         --
         g_liste_param :=
               l_clef
            || ' | '
            || l_tableau
            || ' | '
            || TO_CHAR (l_idtableau)
            || ' | '
            || pk_libelle.f_lib ('TYPTAB', l_type);
         pk_calcul.p_gest_err_calc (i_idfonction       => 37,
                                    i_code_msg         => 5,
                                    i_liste_param      => g_liste_param,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );

         --
         IF (l_type = 1)
         THEN
            OPEN c_val_exacte (l_idtableau);

            FETCH c_val_exacte
             INTO l_valeur;

            IF (c_val_exacte%FOUND)
            THEN
               BEGIN
                  remplace_point (i_chaine      => l_valeur,
                                  o_chaine      => l_valeur);
                  o_valeur := TO_NUMBER (l_valeur);
                  o_found := TRUE;
               EXCEPTION
                  WHEN VALUE_ERROR
                  THEN
                     o_valeur := NULL;
                     o_found := FALSE;
                     pk_calcul.p_gest_err_calc (i_idfonction      => 37,
                                                i_code_msg        => 2,
                                                i_proc            => g_proc,
                                                i_idligne         => g_idligne,
                                                o_idligne         => g_idligne
                                               );
               END;
            ELSE
               o_valeur := NULL;
               o_found := FALSE;
               g_liste_param :=
                     l_tableau
                  || ' | '
                  || pk_libelle.f_lib ('TYPTAB', l_type)
                  || ' | '
                  || l_clef;
               pk_calcul.p_gest_err_calc (i_idfonction       => 37,
                                          i_code_msg         => 3,
                                          i_liste_param      => g_liste_param,
                                          i_proc             => g_proc,
                                          i_idligne          => g_idligne,
                                          o_idligne          => g_idligne
                                         );
            --
            END IF;

            CLOSE c_val_exacte;
         ELSIF (l_type = 2)
         THEN
            OPEN c_val_inf (l_idtableau);

            FETCH c_val_inf
             INTO l_valeur;

            IF (c_val_inf%FOUND)
            THEN
               BEGIN
                  remplace_point (i_chaine      => l_valeur,
                                  o_chaine      => l_valeur);
                  o_valeur := TO_NUMBER (l_valeur);
                  o_found := TRUE;
               EXCEPTION
                  WHEN VALUE_ERROR
                  THEN
                     o_valeur := NULL;
                     o_found := FALSE;
                     pk_calcul.p_gest_err_calc (i_idfonction      => 37,
                                                i_code_msg        => 2,
                                                i_proc            => g_proc,
                                                i_idligne         => g_idligne,
                                                o_idligne         => g_idligne
                                               );
               END;
            ELSE
               o_valeur := NULL;
               o_found := FALSE;
               g_liste_param :=
                     l_tableau
                  || ' | '
                  || pk_libelle.f_lib ('TYPTAB', l_type)
                  || ' | '
                  || l_clef;
               pk_calcul.p_gest_err_calc (i_idfonction       => 37,
                                          i_code_msg         => 3,
                                          i_liste_param      => g_liste_param,
                                          i_proc             => g_proc,
                                          i_idligne          => g_idligne,
                                          o_idligne          => g_idligne
                                         );
            --
            END IF;

            CLOSE c_val_inf;
         ELSIF (l_type = 3)
         THEN
            OPEN c_val_sup (l_idtableau);

            FETCH c_val_sup
             INTO l_valeur;

            IF (c_val_sup%FOUND)
            THEN
               BEGIN
                  remplace_point (i_chaine      => l_valeur,
                                  o_chaine      => l_valeur);
                  o_valeur := TO_NUMBER (l_valeur);
                  o_found := TRUE;
               EXCEPTION
                  WHEN VALUE_ERROR
                  THEN
                     o_valeur := NULL;
                     o_found := FALSE;
                     pk_calcul.p_gest_err_calc (i_idfonction      => 37,
                                                i_code_msg        => 2,
                                                i_proc            => g_proc,
                                                i_idligne         => g_idligne,
                                                o_idligne         => g_idligne
                                               );
               END;
            ELSE
               o_valeur := NULL;
               o_found := FALSE;
               g_liste_param :=
                     l_tableau
                  || ' | '
                  || pk_libelle.f_lib ('TYPTAB', l_type)
                  || ' | '
                  || l_clef;
               pk_calcul.p_gest_err_calc (i_idfonction       => 37,
                                          i_code_msg         => 3,
                                          i_liste_param      => g_liste_param,
                                          i_proc             => g_proc,
                                          i_idligne          => g_idligne,
                                          o_idligne          => g_idligne
                                         );
            --
            END IF;

            CLOSE c_val_sup;
         END IF;
      ELSE
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := l_tableau || ' | ' || l_debut;
         pk_calcul.p_gest_err_calc (i_idfonction       => 37,
                                    i_code_msg         => 1,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      --
      END IF;

      CLOSE c_lib_tableau;
   END p_sel_tableau;

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
                                     i_msg_adm             => SUBSTR
                                                                   (g_msg_adm,
                                                                    1,
                                                                    132
                                                                   ),
                                     i_idligne             => l_idligne
                                    );
      --
      END IF;

      COMMIT;
   END p_ins_journal;

--
-- Procedure AN -> Calcul de l'année civile de la date
--
   PROCEDURE p_sel_annee_civile (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_date           DATE;
      l_annee_civile   DATE;

      CURSOR c_annee_civile
      IS
         SELECT TRUNC (l_date, 'YYYY')
           FROM DUAL;
   BEGIN
      g_proc := 'P_SEL_annee_civile';
      g_liste_param := NULL;
--
      l_date := e2d (g_t_val_arg (1));
--
      g_liste_param := d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 7,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      OPEN c_annee_civile;

      FETCH c_annee_civile
       INTO l_annee_civile;

      IF (c_annee_civile%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 7,
                                    i_code_msg         => 1,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := d2j (l_annee_civile);
         o_found := TRUE;
         g_liste_param := d2e (l_date) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 7,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_annee_civile;
   END p_sel_annee_civile;

--
-- Procedure SAN -> Calcul de l'année civile suivant la date
--
   PROCEDURE p_sel_annee_suivante (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_date             DATE;
      l_annee_suivante   DATE;

      CURSOR c_annee_suivante
      IS
         SELECT TRUNC (ADD_MONTHS (l_date, 12), 'YYYY')
           FROM DUAL;
   BEGIN
      g_proc := 'P_SEL_annee_suivante';
      g_liste_param := NULL;
--
      l_date := e2d (g_t_val_arg (1));
--
      g_liste_param := d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 31,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      OPEN c_annee_suivante;

      FETCH c_annee_suivante
       INTO l_annee_suivante;

      IF (c_annee_suivante%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 31,
                                    i_code_msg         => 1,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := d2j (l_annee_suivante);
         o_found := TRUE;
         g_liste_param := d2e (l_date) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 31,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_annee_suivante;
   END p_sel_annee_suivante;

--
-- Procedure MENS -> Calcul du mois civil de la date
--
   PROCEDURE p_sel_mois_civil (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_date         DATE;
      l_mois_civil   DATE;

      CURSOR c_mois_civil
      IS
         SELECT TRUNC (l_date, 'MM')
           FROM DUAL;
   BEGIN
      g_proc := 'P_SEL_mois_civil';
      g_liste_param := NULL;
--
      l_date := e2d (g_t_val_arg (1));
--
      g_liste_param := d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 16,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      OPEN c_mois_civil;

      FETCH c_mois_civil
       INTO l_mois_civil;

      IF (c_mois_civil%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 16,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := d2j (l_mois_civil);
         o_found := TRUE;
         g_liste_param := d2e (l_date) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 16,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_mois_civil;
   END p_sel_mois_civil;

--
-- Procedure SMENS -> Calcul du mois civil suivant la date
--
   PROCEDURE p_sel_mois_suivant (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_date           DATE;
      l_mois_suivant   DATE;

      CURSOR c_mois_suivant
      IS
         SELECT TRUNC (ADD_MONTHS (l_date, 1), 'MM')
           FROM DUAL;
   BEGIN
      g_proc := 'P_SEL_mois_suivant';
      g_liste_param := NULL;
--
      l_date := e2d (g_t_val_arg (1));
--
      g_liste_param := d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 33,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      OPEN c_mois_suivant;

      FETCH c_mois_suivant
       INTO l_mois_suivant;

      IF (c_mois_suivant%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 33,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := d2j (l_mois_suivant);
         o_found := TRUE;
         g_liste_param := d2e (l_date) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 33,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_mois_suivant;
   END p_sel_mois_suivant;

--
-- Procedure TRIM -> Retourne la date du premier jour du trimestre pour la date donnee
--
   PROCEDURE p_sel_trimestre (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_trimestre   DATE;
      l_date        DATE;

      CURSOR c_trimestre
      IS
         SELECT TRUNC (l_date, 'Q')
           FROM DUAL;
   BEGIN
      g_proc := 'P_SEL_trimestre';
      g_liste_param := NULL;
--
      l_date := e2d (g_t_val_arg (1));
--
      g_liste_param := d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 44,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      OPEN c_trimestre;

      FETCH c_trimestre
       INTO l_trimestre;

      IF (c_trimestre%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 44,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := d2j (l_trimestre);
         o_found := TRUE;
         g_liste_param := d2e (l_date) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 44,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_trimestre;
   END p_sel_trimestre;

--
-- Procedure STRIM -> Retourne la date du premier jour du trimestre suivant la date donnee
--
   PROCEDURE p_sel_trimestre_suivant (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_trimestre_suiv   DATE;
      l_date             DATE;

      CURSOR c_trimestre_suiv
      IS
         SELECT ADD_MONTHS (TRUNC (l_date, 'Q'), 3)
           FROM DUAL;
   BEGIN
      g_proc := 'P_SEL_trimestre_suivant';
      g_liste_param := NULL;
--
      l_date := e2d (g_t_val_arg (1));
--
      g_liste_param := d2e (l_date) || ' | ' || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 35,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      OPEN c_trimestre_suiv;

      FETCH c_trimestre_suiv
       INTO l_trimestre_suiv;

      IF (c_trimestre_suiv%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 35,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := d2j (l_trimestre_suiv);
         o_found := TRUE;
         g_liste_param := d2e (l_date) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 35,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_trimestre_suiv;
   END p_sel_trimestre_suivant;

--
-- Procedure AGE_P -> CALCUL DE L'AGE D'UNE PERSONNE
--
   PROCEDURE p_sel_age (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_age_pers   NUMBER;
      l_date       DATE;
      l_indiv      NUMBER;

      CURSOR c_age_pers
      IS
         SELECT   TO_NUMBER (TO_CHAR (l_date, 'YYYY'))
                - TO_NUMBER (TO_CHAR (datnais, 'YYYY'))
           FROM indvs
          WHERE numindiv = l_indiv;
--
   BEGIN
      g_proc := 'P_SEL_age';
      g_liste_param := NULL;
--
      l_indiv := TO_NUMBER (g_t_val_arg (1));
      l_date := e2d (g_t_val_arg (2));
--
      g_liste_param := d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 5,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      OPEN c_age_pers;

      FETCH c_age_pers
       INTO l_age_pers;

      IF (c_age_pers%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_indiv) || ' | ' || d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 5,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         IF (l_age_pers < 0)
         THEN
            o_valeur := NULL;
            o_found := FALSE;
            g_liste_param := d2e (l_date);
            pk_calcul.p_gest_err_calc (i_idfonction       => 5,
                                       i_code_msg         => 3,
                                       i_liste_param      => g_liste_param,
                                       i_proc             => g_proc,
                                       i_idligne          => g_idligne,
                                       o_idligne          => g_idligne
                                      );
         ELSE
            o_valeur := l_age_pers;
            o_found := TRUE;
            g_liste_param := d2e (l_date) || ' | ' || TO_CHAR (o_valeur);
            pk_calcul.p_gest_err_calc (i_idfonction       => 35,
                                       i_code_msg         => 4,
                                       i_liste_param      => g_liste_param,
                                       i_proc             => g_proc,
                                       i_idligne          => g_idligne,
                                       o_idligne          => g_idligne
                                      );
         END IF;
      END IF;

      CLOSE c_age_pers;
   END p_sel_age;

--
-- Procedure AGE_MP -> CALCUL DE L'AGE MILLESIME D'UNE PERSONNE
--
   PROCEDURE p_sel_age_millesime (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_age_mill   NUMBER;
      l_date       DATE;
      l_indiv      NUMBER;

      CURSOR c_age_mill
      IS
         SELECT FLOOR (MONTHS_BETWEEN (l_date, datnais) / 12)
           FROM indvs
          WHERE numindiv = l_indiv;
--
   BEGIN
      g_proc := 'P_SEL_age_millesime';
      g_liste_param := NULL;
--
      l_indiv := TO_NUMBER (g_t_val_arg (1));
      l_date := e2d (g_t_val_arg (2));
--
      g_liste_param := TO_CHAR (l_indiv) || ' | ' || d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 2,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      OPEN c_age_mill;

      FETCH c_age_mill
       INTO l_age_mill;

      IF (c_age_mill%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_indiv) || ' | ' || d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 2,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         IF (l_age_mill < 0)
         THEN
            o_valeur := NULL;
            o_found := FALSE;
            g_liste_param := TO_CHAR (l_indiv) || ' | ' || d2e (l_date);
            pk_calcul.p_gest_err_calc (i_idfonction       => 2,
                                       i_code_msg         => 3,
                                       i_liste_param      => g_liste_param,
                                       i_proc             => g_proc,
                                       i_idligne          => g_idligne,
                                       o_idligne          => g_idligne
                                      );
         ELSE
            o_valeur := l_age_mill;
            o_found := TRUE;
            g_liste_param :=
                  TO_CHAR (l_indiv)
               || ' | '
               || d2e (l_date)
               || ' | '
               || TO_CHAR (o_valeur);
            pk_calcul.p_gest_err_calc (i_idfonction       => 2,
                                       i_code_msg         => 4,
                                       i_liste_param      => g_liste_param,
                                       i_proc             => g_proc,
                                       i_idligne          => g_idligne,
                                       o_idligne          => g_idligne
                                      );
         END IF;
      END IF;

      CLOSE c_age_mill;
   END p_sel_age_millesime;

--
-- Procedure NB_ADR ou NBI_ADR-> Calcule le nombre d'ayant droit dependant d'un assure pour un type donne
--
   PROCEDURE p_sel_nb_ayant_droit (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numindiv         NUMBER;
      l_type1            NUMBER;
      l_type2            NUMBER;
      l_date             DATE;
      l_nb_ayant_droit   NUMBER;
      a_numfor           NUMBER;
      comm_idadhesion    NUMBER;
   BEGIN
      g_proc := 'P_SEL_nb_ayant_droit';
      g_liste_param := NULL;
--
      l_numindiv := TO_NUMBER (g_t_val_arg (1));
      l_type1 := TO_NUMBER (g_t_val_arg (2));
      l_type2 := TO_NUMBER (g_t_val_arg (3));
      l_date := e2d (g_t_val_arg (4));
      a_numfor := 0;
      comm_idadhesion := 0;
--
      g_liste_param := TO_CHAR (l_numindiv);
      pk_calcul.p_gest_err_calc (i_idfonction       => 21,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      IF (comm_idadhesion = 0)
      THEN
         /* Recherche sur la fiche assure */
         BEGIN
            SELECT NVL (COUNT (*), 0)
              INTO l_nb_ayant_droit
              FROM indvs
             WHERE indvs.numassu = l_numindiv
               AND indvs.typadr BETWEEN l_type1 AND l_type2
               AND EXISTS (
                      SELECT 1
                        FROM couverture
                       WHERE couverture.numindiv = indvs.numindiv
                         AND l_date BETWEEN couverture.datapli
                                        AND NVL (couverture.datper, l_date));

            o_valeur := l_nb_ayant_droit;
            o_found := TRUE;
            g_liste_param :=
                            TO_CHAR (l_numindiv) || ' | '
                            || TO_CHAR (o_valeur);
            pk_calcul.p_gest_err_calc (i_idfonction       => 21,
                                       i_code_msg         => 4,
                                       i_liste_param      => g_liste_param,
                                       i_proc             => g_proc,
                                       i_idligne          => g_idligne,
                                       o_idligne          => g_idligne
                                      );
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               o_valeur := NULL;
               o_found := FALSE;
               g_liste_param := TO_CHAR (l_numindiv);
               pk_calcul.p_gest_err_calc (i_idfonction       => 21,
                                          i_code_msg         => 2,
                                          i_liste_param      => g_liste_param,
                                          i_proc             => g_proc,
                                          i_idligne          => g_idligne,
                                          o_idligne          => g_idligne
                                         );
         END;
      ELSE
         /* Recherche sur l' adhesion  */
         BEGIN
            SELECT NVL (COUNT (*), 0)
              INTO l_nb_ayant_droit
              FROM adhe_cntrt_membre affilie
             WHERE affilie.idadhesion = comm_idadhesion
               AND affilie.typadr BETWEEN l_type1 AND l_type2
               AND EXISTS (
                      SELECT 1
                        FROM couverture
                       WHERE l_date BETWEEN couverture.datapli
                                        AND NVL (couverture.datper, l_date)
                         AND couverture.numfor =
                                DECODE (a_numfor,
                                        0, couverture.numfor,
                                        a_numfor
                                       )
                         AND couverture.numindiv = affilie.numindiv
                         AND couverture.idadhesion = comm_idadhesion);

            o_valeur := l_nb_ayant_droit;
            o_found := TRUE;
            g_liste_param :=
                            TO_CHAR (l_numindiv) || ' | '
                            || TO_CHAR (o_valeur);
            pk_calcul.p_gest_err_calc (i_idfonction       => 21,
                                       i_code_msg         => 4,
                                       i_liste_param      => g_liste_param,
                                       i_proc             => g_proc,
                                       i_idligne          => g_idligne,
                                       o_idligne          => g_idligne
                                      );
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               o_valeur := NULL;
               o_found := FALSE;
               g_liste_param := TO_CHAR (l_numindiv);
               pk_calcul.p_gest_err_calc (i_idfonction       => 21,
                                          i_code_msg         => 3,
                                          i_liste_param      => g_liste_param,
                                          i_proc             => g_proc,
                                          i_idligne          => g_idligne,
                                          o_idligne          => g_idligne
                                         );
         END;
      END IF;
   END p_sel_nb_ayant_droit;

--
-- Procedure TRF -> CALCUL DU TARIF
--
   PROCEDURE p_sel_tarif (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numorg        tarif.numorg%TYPE;
      l_type          tarif.typtar%TYPE;
      l_date          DATE;
      l_codmon        tarif.codmon%TYPE;
      l_tarif         NUMBER;
      comm_codfrais   tarif.codfrais%TYPE;

      CURSOR c_tarif
      IS
         SELECT valeur
           FROM tarif
          WHERE tarif.numorg = l_numorg
            AND tarif.typtar = l_type
            AND tarif.codmon = l_codmon
            AND tarif.codfrais = comm_codfrais
            AND tarif.datapli != NVL (tarif.datper, tarif.datapli + 1)
            AND l_date BETWEEN tarif.datapli AND NVL (tarif.datper, l_date);
   BEGIN
      g_proc := 'P_SEL_tarif';
      g_liste_param := NULL;
--
      comm_codfrais := 'OPT';
      l_numorg := TO_NUMBER (g_t_val_arg (1));
      l_type := TO_NUMBER (g_t_val_arg (2));
      l_date := e2d (g_t_val_arg (3));
      l_codmon := TO_NUMBER (g_t_val_arg (4));
--
      g_liste_param := d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 43,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      OPEN c_tarif;

      FETCH c_tarif
       INTO l_tarif;

      IF (c_tarif%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := e2d (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 43,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := l_tarif;
         o_found := TRUE;
         g_liste_param := d2e (l_date) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 43,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_tarif;
   END p_sel_tarif;

--
-- Procedure TM -> CALCUL DU TICKET MODERATEUR
--
   PROCEDURE p_sel_ticket_moderateur (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numorg              tarif.numorg%TYPE;
      l_type                tarif.typtar%TYPE;
      l_date                DATE;
      l_codmon              tarif.codmon%TYPE;
      l_ticket_moderateur   NUMBER;
      comm_taux             tarif.taux%TYPE;
      comm_codfrais         tarif.codfrais%TYPE;

      CURSOR c_ticket_moderateur
      IS
         SELECT valeur * (1 - (NVL (comm_taux, 100) / 100))
           FROM tarif
          WHERE tarif.numorg = l_numorg
            AND tarif.typtar = l_type
            AND tarif.codmon = l_codmon
            AND tarif.codfrais = comm_codfrais
            AND tarif.datapli != NVL (tarif.datper, tarif.datapli + 1)
            AND l_date BETWEEN tarif.datapli AND NVL (tarif.datper, l_date);
   BEGIN
      g_proc := 'P_SEL_Ticket_Moderateur';
      g_liste_param := NULL;
--
      comm_taux := 0;
      comm_codfrais := 'OPT';
      l_numorg := TO_NUMBER (g_t_val_arg (1));
      l_type := TO_NUMBER (g_t_val_arg (2));
      l_date := e2d (g_t_val_arg (3));
      l_codmon := TO_NUMBER (g_t_val_arg (4));
--
      g_liste_param := TO_CHAR (l_numorg) || ' | ' || d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 39,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      OPEN c_ticket_moderateur;

      FETCH c_ticket_moderateur
       INTO l_ticket_moderateur;

      IF (c_ticket_moderateur%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_numorg) || ' | ' || d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 39,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := l_ticket_moderateur;
         o_found := TRUE;
         g_liste_param :=
               TO_CHAR (l_numorg)
            || ' | '
            || d2e (l_date)
            || ' | '
            || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 39,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_ticket_moderateur;
   END p_sel_ticket_moderateur;

--
-- Procedure TMRL -> CALCUL DU TICKET MODERATEUR RECONSTITUE LIMITE
--
   PROCEDURE p_sel_tmrl (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numorg        tarif.numorg%TYPE;
      l_numorgbase    tarif.numorg%TYPE;
      l_type          tarif.typtar%TYPE;
      l_date          DATE;
      l_codmon        tarif.codmon%TYPE;
      l_tmrl          NUMBER;
      comm_mtremb     NUMBER;
      comm_taux       tarif.taux%TYPE;
      comm_codfrais   tarif.codfrais%TYPE;

      CURSOR c_tmrl
      IS
         SELECT LEAST (  comm_mtremb
                       * (trf_base.taux / 100)
                       / (comm_taux / 100)
                       * ((1 / (trf_base.taux / 100)) - 1),
                       comm_mtremb * ((1 / (comm_taux / 100)) - 1)
                      )
           FROM tarif trf_org, tarif trf_base
          WHERE trf_org.numorg = l_numorg
            AND trf_base.numorg = l_numorgbase
            AND trf_org.typtar = l_type
            AND trf_base.typtar = l_type
            AND trf_org.codmon = l_codmon
            AND trf_base.codmon = l_codmon
            AND trf_org.codfrais = comm_codfrais
            AND trf_base.codfrais = comm_codfrais
            AND trf_org.datapli != NVL (trf_org.datper, trf_org.datapli + 1)
            AND trf_base.datapli != NVL (trf_org.datper, trf_org.datapli + 1)
            AND l_date BETWEEN trf_org.datapli AND NVL (trf_org.datper,
                                                        l_date)
            AND l_date BETWEEN trf_base.datapli AND NVL (trf_base.datper,
                                                         l_date
                                                        );
   BEGIN
      g_proc := 'P_SEL_TMRL';
      g_liste_param := NULL;
--
      comm_mtremb := 50;
      comm_taux := 65;
      comm_codfrais := 'OPT';
      l_numorg := TO_NUMBER (g_t_val_arg (1));
      l_numorgbase := TO_NUMBER (g_t_val_arg (2));
      l_type := TO_NUMBER (g_t_val_arg (3));
      l_date := e2d (g_t_val_arg (4));
      l_codmon := TO_NUMBER (g_t_val_arg (5));
--
      g_liste_param := d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 41,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      OPEN c_tmrl;

      FETCH c_tmrl
       INTO l_tmrl;

      IF (c_tmrl%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 41,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := l_tmrl;
         o_found := TRUE;
         g_liste_param := d2e (l_date) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 41,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_tmrl;
   END p_sel_tmrl;

--
-- Procedure TML -> CALCUL DU TICKET MODERATEUR LIMITE
--
   PROCEDURE p_sel_tml (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numorg        tarif.numorg%TYPE;
      l_numorgbase    tarif.numorg%TYPE;
      l_type          tarif.typtar%TYPE;
      l_date          DATE;
      l_codmon        tarif.codmon%TYPE;
      l_tml           NUMBER;
      comm_codfrais   tarif.codfrais%TYPE;
      comm_taux       tarif.taux%TYPE;

      CURSOR c_tml
      IS
         SELECT LEAST (trf_base.valeur * (1 - (trf_base.taux / 100)),
                       trf_org.valeur * (1 - (comm_taux / 100))
                      )
           FROM tarif trf_org, tarif trf_base
          WHERE trf_org.numorg = l_numorg
            AND trf_base.numorg = l_numorgbase
            AND trf_org.typtar = l_type
            AND trf_base.typtar = l_type
            AND trf_org.codmon = l_codmon
            AND trf_base.codmon = l_codmon
            AND trf_org.codfrais = comm_codfrais
            AND trf_base.codfrais = comm_codfrais
            AND trf_org.datapli != NVL (trf_org.datper, trf_org.datapli + 1)
            AND trf_base.datapli != NVL (trf_org.datper, trf_org.datapli + 1)
            AND l_date BETWEEN trf_org.datapli AND NVL (trf_org.datper,
                                                        l_date)
            AND l_date BETWEEN trf_base.datapli AND NVL (trf_base.datper,
                                                         l_date
                                                        );
   BEGIN
      g_proc := 'P_SEL_TML';
      g_liste_param := NULL;
--
      comm_taux := 60;
      comm_codfrais := 'OPT';
      l_numorg := TO_NUMBER (g_t_val_arg (1));
      l_numorgbase := TO_NUMBER (g_t_val_arg (2));
      l_type := TO_NUMBER (g_t_val_arg (3));
      l_date := e2d (g_t_val_arg (4));
      l_codmon := TO_NUMBER (g_t_val_arg (5));
--
      g_liste_param := d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 40,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      OPEN c_tml;

      FETCH c_tml
       INTO l_tml;

      IF (c_tml%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 40,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := l_tml;
         o_found := TRUE;
         g_liste_param := d2e (l_date) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 40,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_tml;
   END p_sel_tml;

--
-- Procedure RBR -> CALCUL DU REMBOURSEMENT RECONSTITUE
--
   PROCEDURE p_sel_rbt_reconstitue (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numorg            tarif.numorg%TYPE;
      l_type              tarif.typtar%TYPE;
      l_date              DATE;
      l_codmon            tarif.codmon%TYPE;
      l_rbt_reconstitue   NUMBER;
      comm_mtfrais        NUMBER;
      comm_codfrais       tarif.codfrais%TYPE;

      CURSOR c_rbt_reconstitue
      IS
         SELECT DECODE (valeur, 0, comm_mtfrais, valeur) * taux / 100
           FROM tarif
          WHERE tarif.numorg = l_numorg
            AND tarif.typtar = l_type
            AND tarif.codmon = l_codmon
            AND tarif.codfrais = comm_codfrais
            AND tarif.datapli != NVL (tarif.datper, tarif.datapli + 1)
            AND l_date BETWEEN tarif.datapli AND NVL (tarif.datper, l_date);
   BEGIN
      g_proc := 'P_SEL_rbt_reconstitue';
      g_liste_param := NULL;
--
      comm_mtfrais := 250;
      comm_codfrais := 'OPT';
      l_numorg := TO_NUMBER (g_t_val_arg (1));
      l_type := TO_NUMBER (g_t_val_arg (2));
      l_date := e2d (g_t_val_arg (3));
      l_codmon := TO_NUMBER (g_t_val_arg (4));
--
      g_liste_param := TO_CHAR (l_numorg) || ' | ' || d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 26,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      OPEN c_rbt_reconstitue;

      FETCH c_rbt_reconstitue
       INTO l_rbt_reconstitue;

      IF (c_rbt_reconstitue%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_numorg) || ' | ' || d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 26,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := l_rbt_reconstitue;
         o_found := TRUE;
         g_liste_param :=
               TO_CHAR (l_numorg)
            || ' | '
            || d2e (l_date)
            || ' | '
            || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 26,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_rbt_reconstitue;
   END p_sel_rbt_reconstitue;

--
-- Procedure SEMI -> CALCUL DU SEMESTRE CIVIL DE LA DATE
--
   PROCEDURE p_sel_semestre_civil (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_date             DATE;
      l_semestre_civil   DATE;

      CURSOR c_semestre_civil
      IS
         SELECT ADD_MONTHS (TRUNC (l_date, 'Y'),
                            DECODE (SIGN (  6
                                          - TO_NUMBER (TO_CHAR (l_date, 'MM'))
                                         ),
                                    -1, 6,
                                    0, 0,
                                    1, 0
                                   )
                           )
           FROM DUAL;
   BEGIN
      g_proc := 'P_SEL_semestre_civil';
      g_liste_param := NULL;
--
      l_date := e2d (g_t_val_arg (1));
--
      g_liste_param := d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 32,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      OPEN c_semestre_civil;

      FETCH c_semestre_civil
       INTO l_semestre_civil;

      IF (c_semestre_civil%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 32,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := d2j (l_semestre_civil);
         o_found := TRUE;
         g_liste_param := d2e (l_date) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 32,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_semestre_civil;
   END p_sel_semestre_civil;

--
-- Procedure SSEMI -> CALCUL DU SEMESTRE CIVIL SUIVANT LA DATE
--
   PROCEDURE p_sel_semestre_suivant (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_date               DATE;
      l_semestre_suivant   DATE;

      CURSOR c_semestre_suivant
      IS
         SELECT ADD_MONTHS (TRUNC (l_date, 'Y'),
                            DECODE (SIGN (  6
                                          - TO_NUMBER (TO_CHAR (l_date, 'MM'))
                                         ),
                                    -1, 12,
                                    0, 6,
                                    1, 6
                                   )
                           )
           FROM DUAL;
   BEGIN
      g_proc := 'P_SEL_semestre_suivant';
      g_liste_param := NULL;
--
      l_date := e2d (g_t_val_arg (1));
--
      g_liste_param := d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 34,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      OPEN c_semestre_suivant;

      FETCH c_semestre_suivant
       INTO l_semestre_suivant;

      IF (c_semestre_suivant%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 34,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := d2j (l_semestre_suivant);
         o_found := TRUE;
         g_liste_param := d2e (l_date) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 34,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_semestre_suivant;
   END p_sel_semestre_suivant;

--
-- Procedure REG -> Recherche du regime de base de la personne
--
   PROCEDURE p_sel_reg_base (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numindiv        NUMBER;
      l_numfor          NUMBER;
      l_date            DATE;
      l_reg_base        NUMBER;
      comm_idadhesion   NUMBER;
   BEGIN
      g_proc := 'P_SEL_reg_base';
      g_liste_param := NULL;
--
      comm_idadhesion := 0;
      l_numindiv := TO_NUMBER (g_t_val_arg (1));
      l_numfor := TO_NUMBER (g_t_val_arg (2));
      l_date := e2d (g_t_val_arg (3));
--
      g_liste_param := TO_CHAR (l_numindiv) || ' | ' || d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 27,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      IF (l_numfor = 0 OR comm_idadhesion = 0)
      THEN
         /* Recherche sur la fiche assure */
         SELECT indvs.orgbase
           INTO l_reg_base
           FROM indvs
          WHERE indvs.numindiv = l_numindiv;
      ELSE
         /* Recherche sur la couverture   */
         SELECT NVL (MIN (cvrt.numorg), 0)
           INTO l_reg_base
           FROM cvrt
          WHERE cvrt.numindiv = l_numindiv
            AND cvrt.numfor = l_numfor
            AND cvrt.idadhesion = comm_idadhesion
            AND l_date BETWEEN cvrt.datapli AND NVL (cvrt.datper, l_date);
      END IF;

      o_valeur := l_reg_base;
      o_found := TRUE;
      g_liste_param :=
            TO_CHAR (l_numindiv)
         || ' | '
         || d2e (l_date)
         || ' | '
         || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 27,
                                 i_code_msg         => 3,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_numindiv) || ' | ' || d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 27,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_reg_base;

--
-- Procedure T_AYDR -> Recherche du type d'ayant droit de l'assure
--
   PROCEDURE p_sel_type_ad (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numindiv        NUMBER;
      l_date            DATE;
      l_type_ad         NUMBER;
      comm_idadhesion   NUMBER;
   BEGIN
      comm_idadhesion := 0;
      g_proc := 'P_SEL_type_ad';
      g_liste_param := NULL;
--
      l_numindiv := TO_NUMBER (g_t_val_arg (1));
      l_date := e2d (g_t_val_arg (2));
--
      g_liste_param := TO_CHAR (l_numindiv);
      pk_calcul.p_gest_err_calc (i_idfonction       => 45,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      IF (comm_idadhesion = 0)
      THEN
         /* Recherche sur la fiche assure */
         SELECT NVL (indvs.typadr, 0)
           INTO l_type_ad
           FROM indvs
          WHERE indvs.numindiv = l_numindiv;
      ELSE
         /* Recherche sur l' adhesion  */
         SELECT NVL (affilie.typadr, 0)
           INTO l_type_ad
           FROM adhe_cntrt_membre affilie
          WHERE affilie.numindiv = l_numindiv
            AND affilie.idadhesion = comm_idadhesion;
      END IF;

      o_valeur := l_type_ad;
      o_found := TRUE;
      g_liste_param := TO_CHAR (l_numindiv) || ' | ' || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 45,
                                 i_code_msg         => 3,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_numindiv);
         pk_calcul.p_gest_err_calc (i_idfonction       => 45,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_type_ad;

--
-- Procedure R_AYDR ou RI_AYDR -> Recherche du rang d'un ayant droit
--
   PROCEDURE p_sel_rang_ad (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numindiv        NUMBER;
      l_type1           NUMBER;
      l_type2           NUMBER;
      l_date            DATE;
      l_rang_ad         NUMBER;
      a_numfor          NUMBER;
      comm_idadhesion   NUMBER;
--
   BEGIN
      g_proc := 'P_SEL_rang_ad';
      g_liste_param := NULL;
--
      comm_idadhesion := 0;
      l_numindiv := TO_NUMBER (g_t_val_arg (1));
      l_type1 := TO_NUMBER (g_t_val_arg (2));
      l_type2 := TO_NUMBER (g_t_val_arg (3));
      l_date := e2d (g_t_val_arg (4));
      a_numfor := 0;
--
      g_liste_param := TO_CHAR (l_numindiv);
      pk_calcul.p_gest_err_calc (i_idfonction       => 30,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      IF (comm_idadhesion = 0)
      THEN
         /* Recherche sur la fiche assure */
         SELECT NVL (COUNT (numindiv), 0)
           INTO l_rang_ad
           FROM indvs ayd
          WHERE ayd.numassu =
                   (SELECT numassu
                      FROM indvs princ
                     WHERE princ.numindiv = l_numindiv
                       AND princ.typadr BETWEEN l_type1 AND l_type2)
            AND ayd.typadr BETWEEN l_type1 AND l_type2
            AND (ayd.datnais + (ayd.rang / 4)) <=
                                                (SELECT datnais + (rang / 4)
                                                   FROM indvs
                                                  WHERE numindiv = l_numindiv);
      ELSE
         /* Recherche sur l' adhesion  */
         SELECT NVL (COUNT (affilie.numindiv), 0)
           INTO l_rang_ad
           FROM indvs ayd, adhe_cntrt_membre affilie
          WHERE (ayd.datnais + (ayd.rang / 4)) <=
                                          (SELECT datnais + (rang / 4)
                                             FROM indvs
                                            WHERE indvs.numindiv = l_numindiv)
            AND ayd.numindiv = affilie.numindiv
            AND affilie.typadr BETWEEN l_type1 AND l_type2
            AND affilie.idadhesion = comm_idadhesion
            AND EXISTS (
                   SELECT 1
                     FROM couverture
                    WHERE l_date BETWEEN couverture.datapli
                                     AND NVL (couverture.datper, l_date)
                      AND couverture.numfor =
                             DECODE (a_numfor,
                                     0, couverture.numfor,
                                     a_numfor
                                    )
                      AND couverture.numindiv = affilie.numindiv
                      AND couverture.idadhesion = comm_idadhesion);
      END IF;

      o_valeur := l_rang_ad;
      o_found := TRUE;
      g_liste_param := TO_CHAR (l_numindiv) || ' | ' || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 30,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_numindiv);
         pk_calcul.p_gest_err_calc (i_idfonction       => 30,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_rang_ad;

--
-- Procedure DEPEND -> Teste l'existence d'une dependance entre deux personnes
--
   PROCEDURE p_sel_dependance (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_role         dependance.ROLE%TYPE;
      l_numde        dependance.numde%TYPE;
      l_numenvers    dependance.numenvers%TYPE;
      l_date         DATE;
      l_dependance   NUMBER;
   BEGIN
      g_proc := 'P_SEL_dependance';
      g_liste_param := NULL;
--
      l_role := TO_NUMBER (g_t_val_arg (1));
      l_numde := TO_NUMBER (g_t_val_arg (2));
      l_numenvers := TO_NUMBER (g_t_val_arg (3));
      l_date := e2d (g_t_val_arg (4));
--
      g_liste_param := TO_CHAR (l_numde) || ' | ' || TO_CHAR (l_numenvers);
      pk_calcul.p_gest_err_calc (i_idfonction       => 10,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      IF (l_numde <> 0)
      THEN
         SELECT COUNT (*)
           INTO l_dependance
           FROM dependance
          WHERE dependance.ROLE = DECODE (l_role, 0, dependance.ROLE, l_role)
            AND dependance.numde = l_numde
            AND dependance.numenvers =
                    DECODE (l_numenvers,
                            0, dependance.numenvers,
                            l_numenvers
                           )
            AND l_date BETWEEN dependance.datapli
                           AND NVL (dependance.datper, l_date);
      ELSE
         SELECT COUNT (*)
           INTO l_dependance
           FROM dependance
          WHERE dependance.ROLE = DECODE (l_role, 0, dependance.ROLE, l_role)
            AND dependance.numde =
                                DECODE (l_numde,
                                        0, dependance.numde,
                                        l_numde
                                       )
            AND dependance.numenvers = l_numenvers
            AND l_date BETWEEN dependance.datapli
                           AND NVL (dependance.datper, l_date);
      END IF;

      IF (l_dependance = 0)
      THEN
         o_valeur := 0;
         o_found := TRUE;
         g_liste_param := TO_CHAR (l_numde) || ' | ' || TO_CHAR (l_numenvers);
         pk_calcul.p_gest_err_calc (i_idfonction       => 10,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := 1;
         o_found := TRUE;
         g_liste_param := TO_CHAR (l_numde) || ' | ' || TO_CHAR (l_numenvers);
         pk_calcul.p_gest_err_calc (i_idfonction       => 10,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_numde) || ' | ' || TO_CHAR (l_numenvers);
         pk_calcul.p_gest_err_calc (i_idfonction       => 10,
                                    i_code_msg         => 4,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_dependance;

--
-- Procedure NB_DEPEND -> Calcule le nombre de dependances entre deux personnes
--
   PROCEDURE p_sel_nb_depend (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_role         dependance.ROLE%TYPE;
      l_numde        dependance.numde%TYPE;
      l_numenvers    dependance.numenvers%TYPE;
      l_date         DATE;
      l_dependance   NUMBER;
   BEGIN
      g_proc := 'P_SEL_nb_depend';
      g_liste_param := NULL;
      l_role := TO_NUMBER (g_t_val_arg (1));
      l_numde := TO_NUMBER (g_t_val_arg (2));
      l_numenvers := TO_NUMBER (g_t_val_arg (3));
      l_date := e2d (g_t_val_arg (4));
--
      g_liste_param := TO_CHAR (l_numde) || ' | ' || TO_CHAR (l_numenvers);
      pk_calcul.p_gest_err_calc (i_idfonction       => 22,
                                 i_code_msg         => 3,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      IF (l_numde <> 0)
      THEN
         SELECT COUNT (*)
           INTO l_dependance
           FROM dependance
          WHERE dependance.ROLE = DECODE (l_role, 0, dependance.ROLE, l_role)
            AND dependance.numde = l_numde
            AND dependance.numenvers =
                    DECODE (l_numenvers,
                            0, dependance.numenvers,
                            l_numenvers
                           )
            AND l_date BETWEEN dependance.datapli
                           AND NVL (dependance.datper, l_date);
      ELSE
         SELECT COUNT (*)
           INTO l_dependance
           FROM dependance
          WHERE dependance.ROLE = DECODE (l_role, 0, dependance.ROLE, l_role)
            AND dependance.numde =
                                DECODE (l_numde,
                                        0, dependance.numde,
                                        l_numde
                                       )
            AND dependance.numenvers = l_numenvers
            AND l_date BETWEEN dependance.datapli
                           AND NVL (dependance.datper, l_date);
      END IF;

      o_valeur := l_dependance;
      o_found := TRUE;
      g_liste_param :=
            TO_CHAR (o_valeur)
         || ' | '
         || TO_CHAR (l_numde)
         || ' | '
         || TO_CHAR (l_numenvers);
      pk_calcul.p_gest_err_calc (i_idfonction       => 22,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_numde) || ' | ' || TO_CHAR (l_numenvers);
         pk_calcul.p_gest_err_calc (i_idfonction       => 22,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_nb_depend;

--
-- Procedure TAB2 -> Retourne la valeur correspondant a la cle2 pour la cle1 dans le tableau
--
   PROCEDURE p_sel_tab2 (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_tab        lib_tableau.tableau%TYPE;
      l_val1       tableau.clef%TYPE;
      l_val2       tableau.clef%TYPE;
      l_date       DATE;
      loc_valeur   VARCHAR2 (15);
   BEGIN
      g_proc := 'P_SEL_tab2';
      g_liste_param := NULL;
      l_tab := g_t_val_arg (1);
      l_val1 := g_t_val_arg (2);
      l_val2 := g_t_val_arg (3);
      l_date := e2d (g_t_val_arg (4));
--
      g_liste_param :=
         l_val2 || ' | ' || l_val1 || ' | ' || l_tab || ' | ' || d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 127,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      BEGIN
/* Valeurs par cles exactes */
         SELECT valeur
           INTO loc_valeur
           FROM tableau_double, lib_tableau
          WHERE tableau_double.idtableau = lib_tableau.idtableau
            AND TO_NUMBER (tableau_double.clef1) = ROUND (l_val1, 2)
            AND TO_NUMBER (tableau_double.clef2) = ROUND (l_val2, 2)
            AND lib_tableau.tableau = l_tab
            AND l_date BETWEEN NVL (lib_tableau.debut, l_date)
                           AND NVL (lib_tableau.fin, l_date)
            AND lib_tableau.type_tableau = 2
            AND lib_tableau.TYPE = 1;

         remplace_point (i_chaine => loc_valeur, o_chaine => loc_valeur);
         o_valeur := TO_NUMBER (loc_valeur);
         o_found := TRUE;
         g_liste_param :=
               l_val2
            || ' | '
            || l_val1
            || ' | '
            || l_tab
            || ' | '
            || d2e (l_date)
            || ' | '
            || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 127,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
/* Valeurs par intervalles inferieurs --> cle1 */
               SELECT a.valeur
                 INTO loc_valeur
                 FROM tableau_double a, lib_tableau
                WHERE a.clef1 =
                         (SELECT MAX (TO_NUMBER (b.clef1))
                            FROM tableau_double b, lib_tableau
                           WHERE b.idtableau = lib_tableau.idtableau
                             AND TO_NUMBER (b.clef1) <= ROUND (l_val1, 2)
                             AND TO_NUMBER (b.clef2) = ROUND (l_val2, 2)
                             AND lib_tableau.tableau = l_tab
                             AND l_date BETWEEN NVL (lib_tableau.debut,
                                                     l_date)
                                            AND NVL (lib_tableau.fin, l_date)
                             AND lib_tableau.type_tableau = 2
                             AND lib_tableau.TYPE = 2)
                  AND a.clef2 = ROUND (l_val2, 2)
                  AND lib_tableau.tableau = l_tab
                  AND a.idtableau = lib_tableau.idtableau
                  AND l_date BETWEEN NVL (lib_tableau.debut, l_date)
                                 AND NVL (lib_tableau.fin, l_date)
                  AND lib_tableau.type_tableau = 2
                  AND lib_tableau.TYPE = 2;

               remplace_point (i_chaine      => loc_valeur,
                               o_chaine      => loc_valeur);
               o_valeur := TO_NUMBER (loc_valeur);
               o_found := TRUE;
               g_liste_param :=
                     l_val2
                  || ' | '
                  || l_val1
                  || ' | '
                  || l_tab
                  || ' | '
                  || d2e (l_date)
                  || ' | '
                  || TO_CHAR (o_valeur);
               pk_calcul.p_gest_err_calc (i_idfonction       => 127,
                                          i_code_msg         => 3,
                                          i_liste_param      => g_liste_param,
                                          i_proc             => g_proc,
                                          i_idligne          => g_idligne,
                                          o_idligne          => g_idligne
                                         );
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  BEGIN
/* Valeurs par intervalles inferieurs --> cle2 */
                     SELECT a.valeur
                       INTO loc_valeur
                       FROM tableau_double a, lib_tableau
                      WHERE a.clef2 =
                               (SELECT MAX (TO_NUMBER (b.clef2))
                                  FROM tableau_double b, lib_tableau
                                 WHERE b.idtableau = lib_tableau.idtableau
                                   AND TO_NUMBER (b.clef2) <=
                                                             ROUND (l_val2, 2)
                                   AND TO_NUMBER (b.clef1) = ROUND (l_val1, 2)
                                   AND lib_tableau.tableau = l_tab
                                   AND l_date BETWEEN NVL (lib_tableau.debut,
                                                           l_date
                                                          )
                                                  AND NVL (lib_tableau.fin,
                                                           l_date
                                                          )
                                   AND lib_tableau.type_tableau = 2
                                   AND lib_tableau.TYPE = 4)
                        AND a.clef1 = ROUND (l_val1, 2)
                        AND lib_tableau.tableau = l_tab
                        AND a.idtableau = lib_tableau.idtableau
                        AND l_date BETWEEN NVL (lib_tableau.debut, l_date)
                                       AND NVL (lib_tableau.fin, l_date)
                        AND lib_tableau.type_tableau = 2
                        AND lib_tableau.TYPE = 4;

                     remplace_point (i_chaine      => loc_valeur,
                                     o_chaine      => loc_valeur
                                    );
                     o_valeur := TO_NUMBER (loc_valeur);
                     o_found := TRUE;
                     g_liste_param :=
                           l_val2
                        || ' | '
                        || l_val1
                        || ' | '
                        || l_tab
                        || ' | '
                        || d2e (l_date)
                        || ' | '
                        || TO_CHAR (o_valeur);
                     pk_calcul.p_gest_err_calc
                                              (i_idfonction       => 127,
                                               i_code_msg         => 3,
                                               i_liste_param      => g_liste_param,
                                               i_proc             => g_proc,
                                               i_idligne          => g_idligne,
                                               o_idligne          => g_idligne
                                              );
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        BEGIN
/* Valeurs par intervalles superieurs --> cle1 */
                           SELECT a.valeur
                             INTO loc_valeur
                             FROM tableau_double a, lib_tableau
                            WHERE a.clef1 =
                                     (SELECT MIN (TO_NUMBER (b.clef1))
                                        FROM tableau_double b, lib_tableau
                                       WHERE b.idtableau =
                                                         lib_tableau.idtableau
                                         AND TO_NUMBER (b.clef1) >=
                                                             ROUND (l_val1, 2)
                                         AND TO_NUMBER (b.clef2) =
                                                             ROUND (l_val2, 2)
                                         AND lib_tableau.tableau = l_tab
                                         AND l_date
                                                BETWEEN NVL
                                                           (lib_tableau.debut,
                                                            l_date
                                                           )
                                                    AND NVL (lib_tableau.fin,
                                                             l_date
                                                            )
                                         AND lib_tableau.type_tableau = 2
                                         AND lib_tableau.TYPE = 3)
                              AND a.clef2 = ROUND (l_val2, 2)
                              AND lib_tableau.tableau = l_tab
                              AND a.idtableau = lib_tableau.idtableau
                              AND l_date BETWEEN NVL (lib_tableau.debut,
                                                      l_date
                                                     )
                                             AND NVL (lib_tableau.fin, l_date)
                              AND lib_tableau.type_tableau = 2
                              AND lib_tableau.TYPE = 3;

                           remplace_point (i_chaine      => loc_valeur,
                                           o_chaine      => loc_valeur
                                          );
                           o_valeur := TO_NUMBER (loc_valeur);
                           o_found := TRUE;
                           g_liste_param :=
                                 l_val2
                              || ' | '
                              || l_val1
                              || ' | '
                              || l_tab
                              || ' | '
                              || d2e (l_date)
                              || ' | '
                              || TO_CHAR (o_valeur);
                           pk_calcul.p_gest_err_calc
                                              (i_idfonction       => 127,
                                               i_code_msg         => 3,
                                               i_liste_param      => g_liste_param,
                                               i_proc             => g_proc,
                                               i_idligne          => g_idligne,
                                               o_idligne          => g_idligne
                                              );
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              BEGIN
/* Valeurs par intervalles superieurs --> cle2 */
                                 SELECT a.valeur
                                   INTO loc_valeur
                                   FROM tableau_double a, lib_tableau
                                  WHERE a.clef2 =
                                           (SELECT MIN (TO_NUMBER (b.clef2))
                                              FROM tableau_double b,
                                                   lib_tableau
                                             WHERE b.idtableau =
                                                         lib_tableau.idtableau
                                               AND TO_NUMBER (b.clef2) >=
                                                             ROUND (l_val2, 2)
                                               AND TO_NUMBER (b.clef1) =
                                                             ROUND (l_val1, 2)
                                               AND lib_tableau.tableau = l_tab
                                               AND l_date
                                                      BETWEEN NVL
                                                                (lib_tableau.debut,
                                                                 l_date
                                                                )
                                                          AND NVL
                                                                (lib_tableau.fin,
                                                                 l_date
                                                                )
                                               AND lib_tableau.type_tableau =
                                                                             2
                                               AND lib_tableau.TYPE = 5)
                                    AND a.clef1 = ROUND (l_val1, 2)
                                    AND lib_tableau.tableau = l_tab
                                    AND a.idtableau = lib_tableau.idtableau
                                    AND l_date BETWEEN NVL (lib_tableau.debut,
                                                            l_date
                                                           )
                                                   AND NVL (lib_tableau.fin,
                                                            l_date
                                                           )
                                    AND lib_tableau.type_tableau = 2
                                    AND lib_tableau.TYPE = 5;

                                 remplace_point (i_chaine      => loc_valeur,
                                                 o_chaine      => loc_valeur
                                                );
                                 o_valeur := TO_NUMBER (loc_valeur);
                                 o_found := TRUE;
                                 g_liste_param :=
                                       l_val2
                                    || ' | '
                                    || l_val1
                                    || ' | '
                                    || l_tab
                                    || ' | '
                                    || d2e (l_date)
                                    || ' | '
                                    || TO_CHAR (o_valeur);
                                 pk_calcul.p_gest_err_calc
                                              (i_idfonction       => 127,
                                               i_code_msg         => 3,
                                               i_liste_param      => g_liste_param,
                                               i_proc             => g_proc,
                                               i_idligne          => g_idligne,
                                               o_idligne          => g_idligne
                                              );
                              EXCEPTION
                                 WHEN NO_DATA_FOUND
                                 THEN
                                    o_valeur := NULL;
                                    o_found := FALSE;
                                    g_liste_param :=
                                          l_val2
                                       || ' | '
                                       || l_val1
                                       || ' | '
                                       || l_tab
                                       || ' | '
                                       || d2e (l_date);
                                    pk_calcul.p_gest_err_calc
                                              (i_idfonction       => 127,
                                               i_code_msg         => 2,
                                               i_liste_param      => g_liste_param,
                                               i_proc             => g_proc,
                                               i_idligne          => g_idligne,
                                               o_idligne          => g_idligne
                                              );
                              END;
                        END;
                  END;
            END;
      END;
   END p_sel_tab2;

--
-- Procedure AM -> Ajoute un nombre de mois à une date
--
   PROCEDURE p_sel_ajoute_mois (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_date1         DATE;
      l_nbmois        NUMBER;
      l_ajoute_mois   DATE;

      CURSOR c_ajoute_mois
      IS
         SELECT ADD_MONTHS (l_date1, l_nbmois)
           FROM DUAL;
   BEGIN
      g_proc := 'P_SEL_ajoute_mois';
      g_liste_param := NULL;
      l_date1 := e2d (g_t_val_arg (1));
      l_nbmois := TO_NUMBER (g_t_val_arg (2));
--
      g_liste_param := TO_CHAR (l_nbmois) || ' | ' || d2e (l_date1);
      pk_calcul.p_gest_err_calc (i_idfonction       => 6,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      OPEN c_ajoute_mois;

      FETCH c_ajoute_mois
       INTO l_ajoute_mois;

      IF (c_ajoute_mois%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_nbmois) || ' | ' || d2e (l_date1);
         pk_calcul.p_gest_err_calc (i_idfonction       => 6,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := d2j (l_ajoute_mois);
         o_found := TRUE;
         g_liste_param :=
               TO_CHAR (l_nbmois)
            || ' | '
            || d2e (l_date1)
            || ' | '
            || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 6,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_ajoute_mois;
   END p_sel_ajoute_mois;

--
-- Procedure RATIO -> CALCUL DE RATIO
--
   PROCEDURE p_sel_ratio (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_type    indice.indice%TYPE;
      l_date1   DATE;
      l_date2   DATE;
      l_ratio   NUMBER;

      CURSOR c_ratio
      IS
         SELECT (a.valeur / b.valeur) - 1
           FROM indice a, indice b
          WHERE a.indice = l_type
            AND b.indice = l_type
            AND a.datapli != NVL (a.datper, a.datapli + 1)
            AND b.datapli != NVL (b.datper, b.datapli + 1)
            AND l_date1 BETWEEN a.datapli AND NVL (a.datper, l_date1)
            AND l_date2 BETWEEN b.datapli AND NVL (b.datper, l_date2);
   BEGIN
      g_proc := 'P_SEL_ratio';
      g_liste_param := NULL;
      l_type := TO_NUMBER (g_t_val_arg (1));
      l_date1 := e2d (g_t_val_arg (2));
      l_date2 := e2d (g_t_val_arg (3));
--
      g_liste_param := d2e (l_date1) || ' | ' || d2e (l_date2);
      pk_calcul.p_gest_err_calc (i_idfonction       => 25,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      OPEN c_ratio;

      FETCH c_ratio
       INTO l_ratio;

      IF (c_ratio%NOTFOUND)
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := d2e (l_date1) || ' | ' || d2e (l_date2);
         pk_calcul.p_gest_err_calc (i_idfonction       => 25,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := l_ratio;
         o_found := TRUE;
         g_liste_param :=
               d2e (l_date1)
            || ' | '
            || d2e (l_date2)
            || ' | '
            || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 25,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;

      CLOSE c_ratio;
   END p_sel_ratio;

--
-- Procedure TR -> CALCUL DU TARIF RECONSTITUE
--
   PROCEDURE p_sel_tarif_reconstitue (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numorg              tarif.numorg%TYPE;
      l_type                tarif.typtar%TYPE;
      l_date_trf            DATE;
      l_codmon              tarif.codmon%TYPE;
      l_tarif_reconstitue   NUMBER;
      comm_orgbase          NUMBER;
      comm_mtremb           NUMBER;
      comm_taux             NUMBER;
   BEGIN
      comm_orgbase := 3;
      comm_mtremb := 250;
      comm_taux := 65;
      g_proc := 'P_SEL_tarif_reconstitue';
      g_liste_param := NULL;
      l_type := TO_NUMBER (g_t_val_arg (2));
      l_date_trf := e2d (g_t_val_arg (3));
      l_codmon := TO_NUMBER (g_t_val_arg (4));

      IF (g_t_val_arg (1) = 0)
      THEN
         l_numorg := comm_orgbase;
      ELSE
         l_numorg := TO_NUMBER (g_t_val_arg (1));
      END IF;

--
      o_valeur := l_tarif_reconstitue;
      g_liste_param := TO_CHAR (l_numorg) || ' | ' || d2e (l_date_trf);
      pk_calcul.p_gest_err_calc (i_idfonction       => 42,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      SELECT comm_mtremb / comm_taux * 100
        INTO l_tarif_reconstitue
        FROM DUAL;

      o_valeur := l_tarif_reconstitue;
      o_found := TRUE;
      g_liste_param :=
            TO_CHAR (l_numorg)
         || ' | '
         || d2e (l_date_trf)
         || ' | '
         || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 42,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_numorg) || ' | ' || d2e (l_date_trf);
         pk_calcul.p_gest_err_calc (i_idfonction       => 42,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_tarif_reconstitue;

--
-- Procedure ROUND -> Retourne la valeur arrondie
--
   PROCEDURE p_sel_round (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_montant   NUMBER;
      l_niveau    NUMBER;
      l_round     NUMBER;
   BEGIN
      g_proc := 'P_SEL_round';
      g_liste_param := NULL;
      l_montant := TO_NUMBER (g_t_val_arg (1));
      l_niveau := TO_NUMBER (g_t_val_arg (2));
--
      g_liste_param := TO_CHAR (l_montant) || ' | ' || TO_CHAR (l_niveau);
      pk_calcul.p_gest_err_calc (i_idfonction       => 29,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      SELECT ROUND (l_montant, l_niveau)
        INTO l_round
        FROM DUAL;

      o_valeur := l_round;
      o_found := TRUE;
      g_liste_param :=
            TO_CHAR (l_montant)
         || ' | '
         || TO_CHAR (l_niveau)
         || ' | '
         || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 29,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_montant) || ' | ' || TO_CHAR (l_niveau);
         pk_calcul.p_gest_err_calc (i_idfonction       => 29,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_round;

--
-- Procedure SUP -> Retourne l'arrondi supérieur d'une valeur
--
   PROCEDURE p_sel_sup (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_montant   NUMBER;
      l_niveau    NUMBER;
      l_sup       NUMBER;
   BEGIN
      g_proc := 'P_SEL_sup';
      g_liste_param := NULL;
      l_montant := TO_NUMBER (g_t_val_arg (1));
      l_niveau := TO_NUMBER (g_t_val_arg (2));
--
      g_liste_param := TO_CHAR (l_montant);
      pk_calcul.p_gest_err_calc (i_idfonction       => 36,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      SELECT l_montant * POWER (10, l_niveau)
        INTO l_sup
        FROM DUAL;

      IF (SIGN (l_sup) = -1)
      THEN
         SELECT FLOOR (l_sup)
           INTO l_sup
           FROM DUAL;
      ELSE
         SELECT CEIL (l_sup)
           INTO l_sup
           FROM DUAL;
      END IF;

      SELECT l_sup / POWER (10, l_niveau)
        INTO l_sup
        FROM DUAL;

      o_valeur := l_sup;
      o_found := TRUE;
      g_liste_param := TO_CHAR (l_montant) || ' | ' || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 36,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_montant);
         pk_calcul.p_gest_err_calc (i_idfonction       => 36,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_sup;

--
-- Procedure INF -> Retourne l'arrondi à la valeur inférieure
--
   PROCEDURE p_sel_inf (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_montant   NUMBER;
      l_niveau    NUMBER;
      l_inf       NUMBER;
   BEGIN
      g_proc := 'P_SEL_inf';
      g_liste_param := NULL;
      l_montant := TO_NUMBER (g_t_val_arg (1));
      l_niveau := TO_NUMBER (g_t_val_arg (2));
--
      g_liste_param := TO_CHAR (l_montant);
      pk_calcul.p_gest_err_calc (i_idfonction       => 13,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      SELECT l_montant * POWER (10, l_niveau)
        INTO l_inf
        FROM DUAL;

      IF (SIGN (l_inf) = -1)
      THEN
         SELECT CEIL (l_inf)
           INTO l_inf
           FROM DUAL;
      ELSE
         SELECT FLOOR (l_inf)
           INTO l_inf
           FROM DUAL;
      END IF;

      SELECT l_inf / POWER (10, l_niveau)
        INTO l_inf
        FROM DUAL;

      o_valeur := l_inf;
      o_found := TRUE;
      g_liste_param := TO_CHAR (l_montant) || ' | ' || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 13,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_montant);
         pk_calcul.p_gest_err_calc (i_idfonction       => 13,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_inf;

--
-- Procedure J_CONSO -> Recherche du nombre de jours consommes en arrets et rentes
--
   PROCEDURE p_sel_j_conso (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_debut         DATE;
      l_fin           DATE;
      l_flag_sin      NUMBER;
      l_flag_bene     NUMBER;
      l_j_conso       NUMBER                := 0;
      loc_debut       DATE;
      loc_fin         DATE;
      comm_numbene    NUMBER;
      comm_numfor     NUMBER;
      comm_numindiv   NUMBER;
      comm_nosin      NUMBER;

      CURSOR fetch_histo
      IS
         SELECT histo_calcul.idrepartition, histo_calcul.numbene,
                histo_jours.debut, histo_jours.fin, sin_prev.nosin
           FROM histo_calcul, histo_jours, repartition, sin_prev
          WHERE histo_calcul.idrepartition = repartition.idrepartition
            AND histo_calcul.numbene =
                   DECODE (l_flag_bene,
                           0, histo_calcul.numbene,
                           comm_numbene
                          )
            AND histo_jours.idcalcul = histo_calcul.idcalcul
            AND repartition.numfor = comm_numfor
            AND repartition.nosin = sin_prev.nosin
            AND sin_prev.numindiv = comm_numindiv
            AND NOT EXISTS (
                            SELECT 1
                              FROM histo_annul
                             WHERE histo_annul.idcalcul =
                                                         histo_calcul.idcalcul)
            AND NOT EXISTS (SELECT 1
                              FROM histo_annul
                             WHERE histo_annul.idannul = histo_calcul.idcalcul);

      histo           fetch_histo%ROWTYPE;
   BEGIN
      comm_numbene := 73;
      comm_numfor := 201931;
      comm_numindiv := 82;
      comm_nosin := 030003501;
      g_proc := 'P_SEL_j_conso';
      g_liste_param := NULL;
      l_debut := e2d (g_t_val_arg (1));
      l_fin := e2d (g_t_val_arg (2));
      l_flag_sin := TO_NUMBER (g_t_val_arg (3));
      l_flag_bene := TO_NUMBER (g_t_val_arg (4));
--
      g_liste_param := d2e (l_debut) || ' | ' || d2e (l_fin);
      pk_calcul.p_gest_err_calc (i_idfonction       => 3,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      FOR histo IN fetch_histo
      LOOP
         IF ((l_flag_sin != 0) AND (histo.nosin != comm_nosin))
         THEN
            EXIT;
         END IF;

         IF (   (histo.debut BETWEEN l_debut AND l_fin)
             OR (histo.fin BETWEEN l_debut AND l_fin)
            )
         THEN
            loc_debut := GREATEST (l_debut, histo.debut);
            loc_fin := LEAST (l_fin, histo.fin);
            l_j_conso := l_j_conso + (loc_fin - loc_debut) + 1;
         END IF;
      END LOOP;

      o_valeur := l_j_conso;
      o_found := TRUE;
      g_liste_param :=
            d2e (l_debut) || ' | ' || d2e (l_fin) || ' | '
            || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 3,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := d2e (l_debut) || ' | ' || d2e (l_fin);
         pk_calcul.p_gest_err_calc (i_idfonction       => 3,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_j_conso;

--
-- Procedure NAYDR -> Recherche d'un ayant droit d'un type donne
--
   PROCEDURE p_sel_ayant_droit (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numindiv        NUMBER;
      l_type1           NUMBER;
      l_type2           NUMBER;
      l_date            DATE;
      l_rang            NUMBER;
      l_numfor          NUMBER;
      l_naydr           NUMBER;
      comm_idadhesion   NUMBER;
   BEGIN
      g_proc := 'P_SEL_ayant_droit';
      g_liste_param := NULL;
      comm_idadhesion := 0;
      l_numindiv := TO_NUMBER (g_t_val_arg (1));
      l_type1 := TO_NUMBER (g_t_val_arg (2));
      l_type2 := TO_NUMBER (g_t_val_arg (3));
      l_date := e2d (g_t_val_arg (4));
      l_rang := TO_NUMBER (g_t_val_arg (5));
      l_numfor := TO_NUMBER (g_t_val_arg (6));
--
      g_liste_param := TO_CHAR (l_numindiv) || ' | ' || d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 19,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      IF (comm_idadhesion = 0)
      THEN
         /* Recherche sur la fiche assure */
         SELECT NVL (MIN (ayd.numindiv), 0)
           INTO l_naydr
           FROM indvs ayd
          WHERE ayd.numassu =
                   (SELECT numassu
                      FROM indvs princ
                     WHERE princ.numindiv = l_numindiv
                       AND princ.typadr BETWEEN l_type1 AND l_type2)
            AND ayd.typadr BETWEEN l_type1 AND l_type2
            AND (   f_r_aydr (0, ayd.numindiv, l_type1, l_type2, l_date) =
                                                                        l_rang
                 OR l_rang = 0
                );
      ELSE
         /* Recherche sur l' adhesion  */
         SELECT NVL (MIN (affilie.numindiv), 0)
           INTO l_naydr
           FROM indvs ayd, adhe_cntrt_membre affilie
          WHERE (   f_r_aydr (comm_idadhesion,
                              ayd.numindiv,
                              l_type1,
                              l_type2,
                              l_date,
                              l_numfor
                             ) = l_rang
                 OR l_rang = 0
                )
            AND ayd.numindiv = affilie.numindiv
            AND affilie.typadr BETWEEN l_type1 AND l_type2
            AND affilie.idadhesion = comm_idadhesion
            AND EXISTS (
                   SELECT 1
                     FROM couverture
                    WHERE l_date BETWEEN couverture.datapli
                                     AND NVL (couverture.datper, l_date)
                      AND couverture.numfor =
                             DECODE (l_numfor,
                                     0, couverture.numfor,
                                     l_numfor
                                    )
                      AND couverture.numindiv = affilie.numindiv
                      AND couverture.idadhesion = comm_idadhesion);
      END IF;

      o_valeur := l_naydr;
      o_found := TRUE;
      g_liste_param :=
            TO_CHAR (l_numindiv)
         || ' | '
         || d2e (l_date)
         || ' | '
         || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 19,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_numindiv) || ' | ' || d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 19,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_ayant_droit;

--
-- Procedure MT_COT_REG -> Ramene le montant des cotisations reglees pour une periode
--
   PROCEDURE p_sel_mt_cot_reg (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_ngar            NUMBER;
      l_debut           DATE;
      l_fin             DATE;
      l_mt_cot_reg      NUMBER;
      comm_idadhesion   NUMBER;
   BEGIN
      comm_idadhesion := 0;
      g_proc := 'P_SEL_mt_cot_reg';
      g_liste_param := NULL;
      l_ngar := TO_NUMBER (g_t_val_arg (1));
      l_debut := e2d (g_t_val_arg (2));
      l_fin := e2d (g_t_val_arg (3));

      IF (g_t_val_arg (3) = NULL OR g_t_val_arg (3) = '0')
      THEN
         l_fin := l_debut;
      END IF;

--
      g_liste_param := d2e (l_debut) || ' | ' || d2e (l_fin);
      pk_calcul.p_gest_err_calc (i_idfonction       => 1,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      SELECT SUM (NVL (mt_affec, 0))
        INTO l_mt_cot_reg
        FROM qttc_gar
       WHERE numquit IN (
                SELECT numquit
                  FROM qttc_global
                 WHERE qttc_global.idadhesion = comm_idadhesion
                   AND qttc_global.debut BETWEEN l_debut AND l_fin)
         AND (qttc_gar.numfor = l_ngar OR l_ngar = 0);

      o_valeur := l_mt_cot_reg;
      o_found := TRUE;
      g_liste_param :=
            d2e (l_debut) || ' | ' || d2e (l_fin) || ' | '
            || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 1,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := d2e (l_debut) || ' | ' || d2e (l_fin);
         pk_calcul.p_gest_err_calc (i_idfonction       => 1,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_mt_cot_reg;

--
-- Procedure DADC -> Recherche de la date de debut du 1er arret continu en fonction d'un type
--
   PROCEDURE p_sel_dadc (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      comm_debut    NUMBER;
      comm_nosin    NUMBER;
      l_type        NUMBER;
      loc_nbjour    INTEGER         := 0;
      loc_debut     DATE            := j2d (comm_debut);
      loc_continu   VARCHAR2 (1)    := 'O';
      loc_arret     arret%ROWTYPE;
   BEGIN
      comm_debut := 2452655;
      comm_nosin := 030004404;
      g_proc := 'P_SEL_DADC';
      g_liste_param := NULL;
      l_type := TO_NUMBER (g_t_val_arg (1));
--
      g_liste_param := TO_CHAR (l_type);
      pk_calcul.p_gest_err_calc (i_idfonction       => 4,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      FOR loc_arret IN (SELECT   debut, fin, continu
                            FROM arret
                           WHERE fin < j2d (comm_debut)
                             AND nosin = comm_nosin
                             AND TYPE = l_type
                        ORDER BY debut DESC)
      LOOP
         IF ((loc_continu = 'O'))
         THEN
            loc_nbjour :=
                         loc_nbjour
                         + ((loc_arret.fin - loc_arret.debut) + 1);
            loc_debut := loc_arret.debut;
            loc_continu := loc_arret.continu;
         END IF;
      END LOOP;

      o_valeur := d2j (loc_debut);
      o_found := TRUE;
      g_liste_param := TO_CHAR (l_type) || ' | ' || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 4,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_type) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 4,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_dadc;

--
-- Procedure REJET -> Recherche des frais de rejets pour un appel
--
   PROCEDURE p_sel_rejet (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numquit   NUMBER;
      l_rejet     NUMBER;
   BEGIN
      g_proc := 'P_SEL_rejet';
      g_liste_param := NULL;
      l_numquit := TO_NUMBER (g_t_val_arg (1));
--
      g_liste_param := TO_CHAR (l_numquit);
      pk_calcul.p_gest_err_calc (i_idfonction       => 91,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      SELECT NVL (SUM (annul_encais.montant_frais), 0)
        INTO l_rejet
        FROM annul_encais
       WHERE EXISTS (
                SELECT 1
                  FROM compte_client
                 WHERE annul_encais.numencaismt = compte_client.numencaismt
                   AND compte_client.codope = 4
                   AND compte_client.numfact = l_numquit);

      o_valeur := l_rejet;
      o_found := TRUE;
      g_liste_param := TO_CHAR (l_numquit) || ' | ' || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 91,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_numquit);
         pk_calcul.p_gest_err_calc (i_idfonction       => 91,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_rejet;

--
-- Procedure NGROUPE -> Recherche le n° d'1 ayant-droit de type donne pour 1 assure principal
--
   PROCEDURE p_sel_n_groupe (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numindiv   NUMBER;
      l_type       NUMBER;
      loc_retour   NUMBER;
   BEGIN
      g_proc := 'P_SEL_n_groupe';
      g_liste_param := NULL;
      l_numindiv := TO_NUMBER (g_t_val_arg (1));
      l_type := TO_NUMBER (g_t_val_arg (2));
--
      g_liste_param := TO_CHAR (l_numindiv) || ' | ' || TO_CHAR (l_type);
      pk_calcul.p_gest_err_calc (i_idfonction       => 117,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      SELECT indvs.numindiv
        INTO loc_retour
        FROM indvs
       WHERE numassu = l_numindiv AND typadr = l_type;

      o_valeur := loc_retour;
      o_found := TRUE;
      g_liste_param := TO_CHAR (l_numindiv) || ' | ' || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 117,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_numindiv) || ' | ' || TO_CHAR (l_type);
         pk_calcul.p_gest_err_calc (i_idfonction       => 117,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      WHEN TOO_MANY_ROWS
      THEN
         o_valeur := 0;
         g_liste_param := TO_CHAR (l_numindiv) || ' | ' || TO_CHAR (l_type);
         pk_calcul.p_gest_err_calc (i_idfonction       => 117,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_n_groupe;

--
-- Procedure PERS_SEXE -> Recherche du sexe d'une personne
--
   PROCEDURE p_sel_sexe (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_numindiv   indvs.numindiv%TYPE;
      loc_retour   NUMBER;
   BEGIN
      g_proc := 'P_SEL_sexe';
      g_liste_param := NULL;
      l_numindiv := TO_NUMBER (g_t_val_arg (1));
--
      g_liste_param := TO_CHAR (l_numindiv);
      pk_calcul.p_gest_err_calc (i_idfonction       => 123,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

--
      SELECT sexe
        INTO loc_retour
        FROM indvs
       WHERE numindiv = l_numindiv;

      o_valeur := loc_retour;
      o_found := TRUE;
      g_liste_param := TO_CHAR (l_numindiv) || ' | ' || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 123,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_numindiv);
         pk_calcul.p_gest_err_calc (i_idfonction       => 123,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_sexe;

--
-- Procedure ACTE_CONSO -> Consommation acte soins de sante
--
   PROCEDURE p_sel_acte_conso (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_codfrais        VARCHAR2 (5);
      l_debut           DATE;
      l_fin             DATE;
      l_etendue         NUMBER;
      l_type            NUMBER;
      comm_numindiv     NUMBER;
      comm_idadhesion   NUMBER;

      CURSOR c_conso
      IS
         SELECT NVL (SUM (nbacte), 0) nbacte, NVL (SUM (mtreel), 0) mtreel,
                NVL (SUM (mtfrais), 0) mtfrais
           FROM sinistre
          WHERE numindiv = comm_numindiv
            AND codfrais = l_codfrais
            AND datsin BETWEEN l_debut AND l_fin
            AND l_etendue = 0
         UNION
         SELECT NVL (SUM (nbacte), 0) nbacte, NVL (SUM (mtreel), 0) mtreel,
                NVL (SUM (mtfrais), 0) mtfrais
           FROM sinistre
          WHERE numindiv IN (
                    SELECT numindiv
                      FROM indvs
                     WHERE numassu =
                                    f_numassu (comm_numindiv, comm_idadhesion))
            AND codfrais = l_codfrais
            AND datsin BETWEEN l_debut AND l_fin
            AND l_etendue = 1
         UNION
         SELECT NVL (SUM (nbacte), 0) nbacte, NVL (SUM (mtreel), 0) mtreel,
                NVL (SUM (mtfrais), 0) mtfrais
           FROM travsn
          WHERE numindiv = comm_numindiv
            AND codfrais = l_codfrais
            AND datsin BETWEEN l_debut AND l_fin
            AND l_etendue = 0
         UNION
         SELECT NVL (SUM (nbacte), 0) nbacte, NVL (SUM (mtreel), 0) mtreel,
                NVL (SUM (mtfrais), 0) mtfrais
           FROM travsn
          WHERE numindiv IN (
                    SELECT numindiv
                      FROM indvs
                     WHERE numassu =
                                    f_numassu (comm_numindiv, comm_idadhesion))
            AND codfrais = l_codfrais
            AND datsin BETWEEN l_debut AND l_fin
            AND l_etendue = 1;

      rec_c_conso       c_conso%ROWTYPE;
      l_conso           NUMBER            := 0;
   BEGIN
      comm_numindiv := 82;
      comm_idadhesion := 0;
      g_proc := 'P_SEL_acte_conso';
      g_liste_param := NULL;
--
      l_codfrais := g_t_val_arg (1);
      l_debut := e2d (g_t_val_arg (2));
      l_fin := e2d (g_t_val_arg (3));
      l_etendue := TO_NUMBER (g_t_val_arg (4));
      l_type := TO_NUMBER (g_t_val_arg (5));
--
      g_liste_param := d2e (l_debut) || ' | ' || d2e (l_fin);
      pk_calcul.p_gest_err_calc (i_idfonction       => 129,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      OPEN c_conso;

      LOOP
         FETCH c_conso
          INTO rec_c_conso;

         EXIT WHEN c_conso%NOTFOUND;

         IF (l_type = 1)
         THEN
            IF (rec_c_conso.nbacte != 0)
            THEN
               l_conso := rec_c_conso.nbacte;
               EXIT;
            END IF;
         ELSIF (l_type = 2)
         THEN
            IF (rec_c_conso.mtreel != 0)
            THEN
               l_conso := rec_c_conso.mtreel;
               EXIT;
            END IF;
         ELSIF (l_type = 3)
         THEN
            IF (rec_c_conso.mtfrais != 0)
            THEN
               l_conso := rec_c_conso.mtfrais;
               EXIT;
            END IF;
         END IF;
      END LOOP;

      CLOSE c_conso;

      o_valeur := l_conso;
      o_found := TRUE;
      g_liste_param :=
             d2e (l_debut) || ' | ' || d2e (l_fin) || ' | '
             || TO_CHAR (l_conso);
      pk_calcul.p_gest_err_calc (i_idfonction       => 129,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param :=
            d2e (l_debut) || ' | ' || d2e (l_fin) || ' | '
            || TO_CHAR (l_conso);
         pk_calcul.p_gest_err_calc (i_idfonction       => 129,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_acte_conso;

--
-- Procedure PRORA -> Retourne un nombre de mois écoulé entre 2 dates
--
   PROCEDURE p_sel_prora (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_debut     DATE;
      l_fin       DATE;
      l_nb_mois   NUMBER;
   BEGIN
      g_proc := 'P_SEL_prora';
      g_liste_param := NULL;
--
      l_debut := e2d (g_t_val_arg (1));
      l_fin := e2d (g_t_val_arg (2));
      g_liste_param := d2e (l_debut) || ' | ' || d2e (l_fin);
      pk_calcul.p_gest_err_calc (i_idfonction       => 23,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      SELECT   MONTHS_BETWEEN (LAST_DAY (l_fin) + 1, TRUNC (l_debut, 'MM'))
             - (  (TO_NUMBER (TO_CHAR (l_debut, 'DD')) - 1)
                / TO_NUMBER (TO_CHAR (LAST_DAY (l_debut), 'DD'))
               )
             - (  (  TO_NUMBER (TO_CHAR (LAST_DAY (l_fin), 'DD'))
                   - TO_NUMBER (TO_CHAR (l_fin, 'DD'))
                  )
                / TO_NUMBER (TO_CHAR (LAST_DAY (l_fin), 'DD'))
               )
        INTO l_nb_mois
        FROM DUAL;

      o_valeur := l_nb_mois;
      o_found := TRUE;
      g_liste_param :=
            d2e (l_debut) || ' | ' || d2e (l_fin) || ' | '
            || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 23,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := l_debut || ' | ' || l_fin;
         pk_calcul.p_gest_err_calc (i_idfonction       => 23,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_prora;

--
-- Procedure MIN2 -> Retourne le minimum entre 2 valeurs
--
   PROCEDURE p_sel_min2 (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_val1   NUMBER;
      l_val2   NUMBER;
      l_min    NUMBER;
   BEGIN
      g_proc := 'P_SEL_min2';
      g_liste_param := NULL;
      l_val1 := TO_NUMBER (g_t_val_arg (1));
      l_val2 := TO_NUMBER (g_t_val_arg (2));
      g_liste_param := TO_CHAR (l_val1) || ' | ' || TO_CHAR (l_val2);
      pk_calcul.p_gest_err_calc (i_idfonction       => 17,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      SELECT LEAST (l_val1, l_val2)
        INTO l_min
        FROM DUAL;

      o_valeur := l_min;
      o_found := TRUE;
      g_liste_param :=
            TO_CHAR (l_val1)
         || ' | '
         || TO_CHAR (l_val2)
         || ' | '
         || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 17,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_val1) || ' | ' || TO_CHAR (l_val2);
         pk_calcul.p_gest_err_calc (i_idfonction       => 17,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_min2;

--
-- Procedure MIN3 -> Retourne le minimum entre 3 valeurs
--
   PROCEDURE p_sel_min3 (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_val1   NUMBER;
      l_val2   NUMBER;
      l_val3   NUMBER;
      l_min    NUMBER;
   BEGIN
      g_proc := 'P_SEL_min3';
      g_liste_param := NULL;
      l_val1 := TO_NUMBER (g_t_val_arg (1));
      l_val2 := TO_NUMBER (g_t_val_arg (2));
      l_val3 := TO_NUMBER (g_t_val_arg (3));
      g_liste_param :=
            TO_CHAR (l_val1)
         || ' | '
         || TO_CHAR (l_val2)
         || ' | '
         || TO_CHAR (l_val3);
      pk_calcul.p_gest_err_calc (i_idfonction       => 18,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      SELECT LEAST (l_val1, l_val2, l_val3)
        INTO l_min
        FROM DUAL;

      o_valeur := l_min;
      o_found := TRUE;
      g_liste_param :=
            TO_CHAR (l_val1)
         || ' | '
         || TO_CHAR (l_val2)
         || ' | '
         || TO_CHAR (l_val3)
         || ' | '
         || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 18,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param :=
               TO_CHAR (l_val1)
            || ' | '
            || TO_CHAR (l_val2)
            || ' | '
            || TO_CHAR (l_val3);
         pk_calcul.p_gest_err_calc (i_idfonction       => 18,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_min3;

--
-- Procedure MAX2 -> Retourne le maximum entre 2 valeurs
--
   PROCEDURE p_sel_max2 (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_val1   NUMBER;
      l_val2   NUMBER;
      l_max    NUMBER;
   BEGIN
      g_proc := 'P_SEL_max2';
      g_liste_param := NULL;
      l_val1 := TO_NUMBER (g_t_val_arg (1));
      l_val2 := TO_NUMBER (g_t_val_arg (2));
      g_liste_param := TO_CHAR (l_val1) || ' | ' || TO_CHAR (l_val2);
      pk_calcul.p_gest_err_calc (i_idfonction       => 14,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      SELECT GREATEST (l_val1, l_val2)
        INTO l_max
        FROM DUAL;

      o_valeur := l_max;
      o_found := TRUE;
      g_liste_param :=
            TO_CHAR (l_val1)
         || ' | '
         || TO_CHAR (l_val2)
         || ' | '
         || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 14,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_val1) || ' | ' || TO_CHAR (l_val2);
         pk_calcul.p_gest_err_calc (i_idfonction       => 14,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_max2;

--
-- Procedure MAX3 -> Retourne le maximum entre 3 valeurs
--
   PROCEDURE p_sel_max3 (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_val1   NUMBER;
      l_val2   NUMBER;
      l_val3   NUMBER;
      l_max    NUMBER;
   BEGIN
      g_proc := 'P_SEL_max3';
      g_liste_param := NULL;
      l_val1 := TO_NUMBER (g_t_val_arg (1));
      l_val2 := TO_NUMBER (g_t_val_arg (2));
      l_val3 := TO_NUMBER (g_t_val_arg (3));
      g_liste_param :=
            TO_CHAR (l_val1)
         || ' | '
         || TO_CHAR (l_val2)
         || ' | '
         || TO_CHAR (l_val3);
      pk_calcul.p_gest_err_calc (i_idfonction       => 15,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      SELECT GREATEST (l_val1, l_val2, l_val3)
        INTO l_max
        FROM DUAL;

      o_valeur := l_max;
      o_found := TRUE;
      g_liste_param :=
            TO_CHAR (l_val1)
         || ' | '
         || TO_CHAR (l_val2)
         || ' | '
         || TO_CHAR (l_val3)
         || ' | '
         || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 15,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param :=
               TO_CHAR (l_val1)
            || ' | '
            || TO_CHAR (l_val2)
            || ' | '
            || TO_CHAR (l_val3);
         pk_calcul.p_gest_err_calc (i_idfonction       => 15,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_max3;

--
-- Procedure TEST -> Retourne une valeur conditionnée
--
   PROCEDURE p_sel_test (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_val1   NUMBER;
      l_val2   NUMBER;
      l_val3   NUMBER;
   BEGIN
      g_proc := 'P_SEL_test';
      g_liste_param := NULL;
      l_val1 := TO_NUMBER (g_t_val_arg (1));
      l_val2 := TO_NUMBER (g_t_val_arg (2));
      l_val3 := TO_NUMBER (g_t_val_arg (3));
      g_liste_param := TO_CHAR (l_val1);
      pk_calcul.p_gest_err_calc (i_idfonction       => 38,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      IF (l_val1 <> 0)
      THEN                                         -- cas où L_val1 est à TRUE
         o_valeur := l_val2;
         o_found := TRUE;
         g_liste_param := TO_CHAR (l_val1) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 38,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE                                        -- cas où L_val1 est à FALSE
         o_valeur := l_val3;
         o_found := TRUE;
         g_liste_param := TO_CHAR (l_val1) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 38,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_val1);
         pk_calcul.p_gest_err_calc (i_idfonction       => 38,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_test;

--
-- Procedure NOT -> Procedure logique de négation
--
   PROCEDURE p_sel_not (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_val1   NUMBER;
   BEGIN
      g_proc := 'P_SEL_not';
      g_liste_param := NULL;
      l_val1 := TO_NUMBER (g_t_val_arg (1));
      g_liste_param := TO_CHAR (l_val1);
      pk_calcul.p_gest_err_calc (i_idfonction       => 24,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      IF (l_val1 <> 0)
      THEN
         o_valeur := 0;
         o_found := TRUE;
         g_liste_param := TO_CHAR (l_val1) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 24,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      ELSE
         o_valeur := 1;
         o_found := TRUE;
         g_liste_param := TO_CHAR (l_val1) || ' | ' || TO_CHAR (o_valeur);
         pk_calcul.p_gest_err_calc (i_idfonction       => 24,
                                    i_code_msg         => 2,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_val1);
         pk_calcul.p_gest_err_calc (i_idfonction       => 24,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_not;

--
-- Procedure NAT -> Retourne le code pays relatif à la nationalité
--
   PROCEDURE p_sel_codpays (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_codpays    individu.codpays%TYPE;
      l_numindiv   individu.numindiv%TYPE;
   BEGIN
      g_proc := 'P_SEL_codpays';
      g_liste_param := NULL;
--
      l_numindiv := TO_NUMBER (g_t_val_arg (1));
      g_liste_param := TO_CHAR (l_numindiv);
      pk_calcul.p_gest_err_calc (i_idfonction       => 140,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

      SELECT codpays
        INTO l_codpays
        FROM individu
       WHERE numindiv = l_numindiv;

      o_valeur := l_codpays;
      o_found := TRUE;
      g_liste_param := TO_CHAR (l_numindiv) || ' | ' || TO_CHAR (o_valeur);
      pk_calcul.p_gest_err_calc (i_idfonction       => 140,
                                 i_code_msg         => 2,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := TO_CHAR (l_numindiv);
         pk_calcul.p_gest_err_calc (i_idfonction       => 140,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );
   END p_sel_codpays;

--
-- Procedure DEF ->  Recherche de la valeur de la variable idvariable
--
   PROCEDURE p_sel_valeur_variable (o_valeur OUT NUMBER, o_found OUT BOOLEAN)
   IS
      l_loc_val         NUMBER;
      l_chaine          VARCHAR2 (10);
      l_date            DATE;
      l_idvariable      def_variable.idvariable%TYPE;
      l_etendue         def_variable.etendue%TYPE;
      l_statique        def_variable.statique%TYPE;
      l_type            def_variable.TYPE%TYPE;
      l_clef            NUMBER;
      l_val_var         VARCHAR2 (15);
      l_dval_var        NUMBER;
      l_numgar          NUMBER;
      comm_numindiv     NUMBER                         := 248;
      comm_numgar       NUMBER                         := 176;
      comm_numcli       NUMBER                         := 73;
      comm_numassu      NUMBER                         := 73;
      comm_numorg       NUMBER                         := 3;
      comm_numprod      NUMBER                         := 500;
      comm_numinterm    NUMBER                         := 1;
      comm_idadhesion   NUMBER                         := 862;
      comm_nosin        NUMBER                         := 030003801;
      comm_numbene      NUMBER                         := 73;
      loc_comm_numgar   NUMBER                         := 0;

      CURSOR c_var
      IS
         SELECT idvariable, etendue, DECODE (statique, 'O', 1, 'N', 0), TYPE
           FROM def_variable
          WHERE def_variable.nom_variable = l_chaine;

      CURSOR c_clef (p_etendue IN BINARY_INTEGER)
      IS
         SELECT DECODE (p_etendue,
                        0, comm_numindiv,
                        2, comm_numgar,
                        3, comm_numcli,
                        4, comm_numassu,
                        5, comm_numorg,
                        7, comm_numprod,
                        9, comm_numinterm,
                        12, comm_numindiv,
                        13, comm_idadhesion,
                        15, comm_nosin,
                        16, comm_numbene
                       )
           FROM DUAL;

      CURSOR c_type1 (
         p_clef         IN   BINARY_INTEGER,
         p_type         IN   VARCHAR2,
         p_idvariable   IN   BINARY_INTEGER
      )
      IS
         SELECT DECODE (p_type,
                        'D', TO_CHAR (TO_DATE (valeur, 'DD/MM/YY'), 'j'),
                        'E', TO_CHAR (TO_DATE (valeur, 'DDMMYYYY'), 'j'),
                        valeur
                       ),
                d2j (val_variable.debut)
           FROM val_variable
          WHERE val_variable.idvariable = p_idvariable
            AND val_variable.numgar = comm_numgar
            AND val_variable.valeur IS NOT NULL
            AND val_variable.clef = p_clef
            AND val_variable.valide = 'O'
            AND l_date BETWEEN val_variable.debut
                           AND NVL (val_variable.fin, l_date);

      CURSOR c_type2 (
         p_clef         IN   BINARY_INTEGER,
         p_type         IN   VARCHAR2,
         p_idvariable   IN   BINARY_INTEGER
      )
      IS
         SELECT DECODE (p_type,
                        'D', TO_CHAR (TO_DATE (valeur, 'DD/MM/YY'), 'j'),
                        'E', TO_CHAR (TO_DATE (valeur, 'DDMMYYYY'), 'j'),
                        valeur
                       ),
                d2j (val_variable.debut), val_variable.numgar
           FROM val_variable
          WHERE val_variable.idvariable = p_idvariable
            AND val_variable.numgar IS NULL
            AND val_variable.valeur IS NOT NULL
            AND val_variable.clef = p_clef
            AND val_variable.valide = 'O'
            AND l_date BETWEEN val_variable.debut
                           AND NVL (val_variable.fin, l_date);
   BEGIN
      g_proc := 'P_SEL_valeur_variable';
      g_liste_param := NULL;
--
      l_loc_val := TO_NUMBER (g_t_val_arg (1));
      l_chaine := g_t_val_arg (2);
      l_date := e2d (g_t_val_arg (3));
      g_liste_param := l_chaine || ' | ' || d2e (l_date);
      pk_calcul.p_gest_err_calc (i_idfonction       => 9,
                                 i_code_msg         => 1,
                                 i_liste_param      => g_liste_param,
                                 i_proc             => g_proc,
                                 i_idligne          => g_idligne,
                                 o_idligne          => g_idligne
                                );

/*----------------------------------------------------------------------------
        Recherche de l'idvariable correspondant a la chaine
----------------------------------------------------------------------------*/
      OPEN c_var;

      FETCH c_var
       INTO l_idvariable, l_etendue, l_statique, l_type;

      IF (c_var%FOUND)
      THEN
         OPEN c_clef (l_etendue);

         FETCH c_clef
          INTO l_clef;

         IF (c_clef%FOUND)
         THEN
/*----------------------------------------------------------------------------
  Recherche explicite dans val_variable
----------------------------------------------------------------------------*/
            OPEN c_type1 (l_clef, l_type, l_idvariable);

            FETCH c_type1
             INTO l_val_var, l_dval_var;

            IF (c_type1%FOUND)
            THEN
               IF (loc_comm_numgar = 0)
               THEN
                  loc_comm_numgar := comm_numgar;
               ELSIF (loc_comm_numgar <> comm_numgar)
               THEN
                  loc_comm_numgar := 0;
               END IF;

               IF (l_loc_val = 1)
               THEN
                  remplace_point (i_chaine      => l_val_var,
                                  o_chaine      => l_val_var
                                 );
                  o_valeur := TO_NUMBER (l_val_var);
                  o_found := TRUE;
               ELSIF (l_loc_val = 2)
               THEN
                  o_valeur := l_dval_var;
                  o_found := TRUE;
               ELSE
                  o_valeur := 1;
                  o_found := TRUE;
               END IF;

               g_liste_param :=
                  l_chaine || ' | ' || d2e (l_date) || ' | '
                  || TO_CHAR (o_valeur);
               pk_calcul.p_gest_err_calc (i_idfonction       => 9,
                                          i_code_msg         => 2,
                                          i_liste_param      => g_liste_param,
                                          i_proc             => g_proc,
                                          i_idligne          => g_idligne,
                                          o_idligne          => g_idligne
                                         );
            ELSE
/*----------------------------------------------------------------------------
  Recherche non explicite dans val_variable
----------------------------------------------------------------------------*/
               CLOSE c_type1;

               OPEN c_type2 (l_clef, l_type, l_idvariable);

               FETCH c_type2
                INTO l_val_var, l_dval_var, l_numgar;

               IF (c_type2%FOUND)
               THEN
                  IF (loc_comm_numgar = 0)
                  THEN
                     loc_comm_numgar := l_numgar;
                  ELSIF (loc_comm_numgar <> l_numgar)
                  THEN
                     loc_comm_numgar := 0;
                  END IF;

                  IF (l_loc_val = 1)
                  THEN
                     remplace_point (i_chaine      => l_val_var,
                                     o_chaine      => l_val_var
                                    );
                     o_valeur := TO_NUMBER (l_val_var);
                     o_found := TRUE;
                  ELSIF (l_loc_val = 2)
                  THEN
                     o_valeur := l_dval_var;
                     o_found := TRUE;
                  ELSE
                     o_valeur := 1;
                     o_found := TRUE;
                  END IF;
               ELSE
                  o_valeur := 0;
                  o_found := FALSE;
                  g_liste_param := l_chaine || ' | ' || d2e (l_date);
                  pk_calcul.p_gest_err_calc (i_idfonction       => 9,
                                             i_code_msg         => 3,
                                             i_liste_param      => g_liste_param,
                                             i_proc             => g_proc,
                                             i_idligne          => g_idligne,
                                             o_idligne          => g_idligne
                                            );

                  CLOSE c_type2;
               END IF;

               g_liste_param :=
                  l_chaine || ' | ' || d2e (l_date) || ' | '
                  || TO_CHAR (o_valeur);
               pk_calcul.p_gest_err_calc (i_idfonction       => 9,
                                          i_code_msg         => 2,
                                          i_liste_param      => g_liste_param,
                                          i_proc             => g_proc,
                                          i_idligne          => g_idligne,
                                          o_idligne          => g_idligne
                                         );
            END IF;
         ELSE
            o_valeur := 0;
            o_found := FALSE;
            g_liste_param := l_chaine || ' | ' || d2e (l_date);
            pk_calcul.p_gest_err_calc (i_idfonction       => 9,
                                       i_code_msg         => 3,
                                       i_liste_param      => g_liste_param,
                                       i_proc             => g_proc,
                                       i_idligne          => g_idligne,
                                       o_idligne          => g_idligne
                                      );

            CLOSE c_clef;
         END IF;
      ELSE
         o_valeur := NULL;
         o_found := FALSE;
         g_liste_param := l_chaine || ' | ' || d2e (l_date);
         pk_calcul.p_gest_err_calc (i_idfonction       => 9,
                                    i_code_msg         => 3,
                                    i_liste_param      => g_liste_param,
                                    i_proc             => g_proc,
                                    i_idligne          => g_idligne,
                                    o_idligne          => g_idligne
                                   );

         CLOSE c_var;
      END IF;
   END p_sel_valeur_variable;

--
-- Procedure REMPLACE_POINT ->  Remplace un point par une virgule dans un chaine de caractères numériques
--
   PROCEDURE remplace_point (i_chaine IN VARCHAR2, o_chaine OUT VARCHAR2)
   IS
      l_point   NUMBER;
   BEGIN
      l_point := INSTR (i_chaine, '.');

      IF (l_point <> 0)
      THEN
         o_chaine :=
               SUBSTR (i_chaine, 1, l_point - 1)
            || ','
            || SUBSTR (i_chaine, l_point + 1, LENGTH (i_chaine));
      ELSE
         o_chaine := i_chaine;
      END IF;
   END remplace_point;
-- ------------------------------------ Fin des corps des procedures privees --
END;
/
