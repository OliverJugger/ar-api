CREATE OR REPLACE PACKAGE ARTHUS."PK_TRESO"
AS
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
   g_montant_ligne2   VARCHAR2 (200);
   g_montant_ligne3   VARCHAR2 (200);

-- --------------------------------------------- Fin des variables publiques --

   -- -- PROCEDURES PUBLIQUES ----------------------------------------------------
--@pub
--
-- Recherche de l'utilisateur hablilite a valider la piece
--
   PROCEDURE p_sel_validateur (
      i_codope    IN       valid_ope.codope%TYPE,
      i_numsoc    IN       valid_ope.numsoc%TYPE,
      i_montant   IN       NUMBER,
      i_numindiv  IN       valid_ope.numindiv%TYPE,
      o_found     OUT      BOOLEAN
   );

--
-- Recherche de l'utilisateur auto hablilite a valider automatiquement la piece
--
   PROCEDURE p_sel_validateur_auto (
      i_codope    IN       valid_ope.codope%TYPE,
      i_numsoc    IN       valid_ope.numsoc%TYPE,
      i_montant   IN       NUMBER,
      o_found     OUT      BOOLEAN
   );

--
-- Insertion d'une ligne compte tiers
--
   PROCEDURE p_ins_compte_tiers (
      i_numcli      IN       compte_tiers.numcli%TYPE,
      i_codope      IN       compte_tiers.codope%TYPE,
      i_cle         IN       compte_tiers.cle%TYPE,
      i_datope      IN       compte_tiers.datope%TYPE,
      i_sens        IN       compte_tiers.sens%TYPE,
      i_montant     IN       compte_tiers.montant%TYPE,
      i_montant_d   IN       compte_tiers.montant_d%TYPE,
      i_monnaie     IN       compte_tiers.monnaie%TYPE,
      i_monnaie_d   IN       compte_tiers.monnaie_d%TYPE,
      o_idmvt       OUT      compte_tiers.idmvt%TYPE
   );

--
-- Insertion d'une ligne dans compensation
--
   PROCEDURE p_ins_compensation (
      i_idmvt    IN   compensation.idmvt%TYPE,
      i_idcomp   IN   compensation.idcomp%TYPE,
      i_typmvt   IN   compensation.typmvt%TYPE DEFAULT 0
   );

--
-- Insertion d'une ligne dans affectation
--
   PROCEDURE p_ins_affectation (
      i_codope        IN       affectation.codope%TYPE,
      i_numdecaismt   IN       affectation.numdecaismt%TYPE,
      i_montant       IN       affectation.montant%TYPE,
      i_montant_d     IN       affectation.montant_d%TYPE,
      i_numcli        IN       affectation.numcli%TYPE,
      o_numaffec      OUT      affectation.numaffec%TYPE,
      i_numaffec      IN       affectation.numaffec%TYPE DEFAULT NULL,
      i_dataffec      IN       affectation.dataffec%TYPE
            DEFAULT TRUNC (SYSDATE),
      i_monnaie       IN       affectation.monnaie%TYPE
            DEFAULT pk_devise.devise_ref,
      i_monnaie_d     IN       affectation.monnaie_d%TYPE,
      i_nbfeuille     IN       affectation.nbfeuille%TYPE DEFAULT NULL,
      i_montant_ct    IN       affectation.montant_ct%TYPE,
      i_devise_ct     IN       affectation.devise_ct%TYPE
   );

--
-- Insertion d'une ligne dans decaismt
--
   PROCEDURE p_ins_decaismt (
      i_codope        IN       decaismt.codope%TYPE,
      i_numcpte       IN       decaismt.numcpte%TYPE,
      i_modpmt        IN       decaismt.modpmt%TYPE,
      i_montant       IN       decaismt.montant%TYPE,
      i_montant_d     IN       decaismt.montant_d%TYPE,
      i_typbene       IN       decaismt.typbene%TYPE,
      i_numbene       IN       decaismt.numbene%TYPE,
      i_numdest       IN       decaismt.numdest%TYPE,
      i_numutil       IN       decaismt.numutil%TYPE,
      i_monnaie       IN       decaismt.monnaie%TYPE
            DEFAULT pk_devise.devise_ref,
      i_monnaie_d     IN       decaismt.monnaie_d%TYPE,
      i_montant_ct    IN       decaismt.montant_ct%TYPE,
      i_devise_ct     IN       decaismt.devise_ct%TYPE,
      o_numdecaismt   OUT      decaismt.numdecaismt%TYPE
   );

--
-- Compte par défaut a utiliser pou une operation et un mode de reglement donne
--
   PROCEDURE p_sel_def_compte (
      i_numsoc      IN       compte.numsoc%TYPE,
      i_codope      IN       papier_ope.codope%TYPE,
      i_modpmt      IN       papier_ope.modpmt%TYPE,
      o_numcpte     OUT      papier_ope.numcpte%TYPE,
      o_libcompte   OUT      compte.libcompte%TYPE,
      o_papid       OUT      papier_ope.papid%TYPE,
      o_found       OUT      BOOLEAN
   );

--
-- Parametrage des modalites de reglement (Fonction)
--
   FUNCTION f_param_ope_valide (
      i_numsoc    IN   NUMBER,
      i_numorg    IN   NUMBER,
      i_numgar    IN   NUMBER,
      i_codope    IN   NUMBER,
      i_modpmt    IN   NUMBER,
      i_mode      IN   NUMBER,
      i_montant   IN   NUMBER,
      i_date      IN   DATE DEFAULT NULL
   )
      RETURN NUMBER;

--Pragma Restrict_References(F_param_ope_valide, WNDS, WNPS);
--
-- Parametrage des modalites de reglement (Procedure)
--
   PROCEDURE p_sel_param_ope (
      i_numsoc      IN       NUMBER,
      i_numorg      IN       NUMBER,
      i_numgar      IN       NUMBER,
      i_codope      IN       NUMBER,
      i_modpmt      IN       NUMBER,
      o_montant     OUT      param_ope.montant%TYPE,
      o_delai       OUT      param_ope.delai%TYPE,
      o_frequence   OUT      param_ope.frequence%TYPE,
      o_found       OUT      BOOLEAN
   );

--
-- Recherche de la date de reference de l'encaissement
--
   PROCEDURE p_sel_datencaismt (
      i_numencaismt   IN       encaismt.numencaismt%TYPE,
      i_datpay        IN       encaismt.datpay%TYPE,
      o_datencaismt   OUT      encaismt.datpay%TYPE,
      o_remise        OUT      NUMBER
   );

--
-- Recherche des parametres de cloture
--
   PROCEDURE p_sel_param_cloture (
      i_numsoc    IN       param_cloture.numsoc%TYPE,
      o_debut     OUT      param_cloture.debut%TYPE,
      o_fin       OUT      param_cloture.fin%TYPE,
      o_cloture   OUT      param_cloture.cloture%TYPE,
      o_found     OUT      BOOLEAN,
      i_cloture   IN       VARCHAR2 DEFAULT 'O',
      i_datref    IN       DATE DEFAULT TRUNC (SYSDATE)
   );

--
-- Affectation d'un encaissement a une piece ( Ex procedure Affecte )
--
   PROCEDURE p_affecte (
      i_idaffec       IN   compte_client.idaffec%TYPE,
      i_codope        IN   compte_client.codope%TYPE,
      i_numfact       IN   compte_client.numfact%TYPE,
      i_numcli        IN   compte_client.numcli%TYPE,
      i_numencaismt   IN   compte_client.numencaismt%TYPE,
      i_montant       IN   compte_client.montant%TYPE,
      i_monnaie       IN   compte_client.monnaie%TYPE,
      i_montant_d     IN   compte_client.montant_d%TYPE,
      i_monnaie_d     IN   compte_client.monnaie_d%TYPE,
      i_datope        IN   compte_client.datope%TYPE DEFAULT TRUNC (SYSDATE)
   );

--
-- Retourne le mode de reglement d'une personne
--
--jbn 24/03/11 évolution RIB ajout devise
   FUNCTION f_bene_modpmt (
      i_numindiv     IN   rib.numindiv%TYPE,
      i_type         IN   rib.TYPE%TYPE,
      i_codope       IN   rib.codope%TYPE DEFAULT NULL,
      i_numgar       IN   rib.numgar%TYPE DEFAULT NULL,
      i_debut        IN   rib.debut%TYPE DEFAULT SYSDATE,
      i_idadhesion   IN   rib_adhe.idadhesion%TYPE DEFAULT NULL,
      i_devise  IN rib.devise_compte%Type Default Null
   )
      RETURN NUMBER;

--Pragma Restrict_References(F_bene_modpmt, WNDS, WNPS);
--
-- Nouvelle recherche du rib en tenant compte de rib_adhe
--
--jbn 24/03/11 évolution RIB ajout devise
   FUNCTION f_idrib (
      i_numindiv     IN   rib.numindiv%TYPE,
      i_type         IN   rib.TYPE%TYPE,
      i_codope       IN   rib.codope%TYPE DEFAULT NULL,
      i_numgar       IN   rib.numgar%TYPE DEFAULT NULL,
      i_debut        IN   rib.debut%TYPE DEFAULT SYSDATE,
      i_idadhesion   IN   rib_adhe.idadhesion%TYPE DEFAULT NULL,
      i_devise  IN rib.devise_compte%Type Default Null
   )
      RETURN NUMBER;

--Pragma Restrict_References(F_idrib, WNDS, WNPS);
--
-- Transformation d'un montant en lettres
--
   FUNCTION f_montant_lettre (
      i_montant    IN   NUMBER,
      i_longueur   IN   NUMBER,
      i_codmon     IN   NUMBER,
      i_ligne      IN   NUMBER
   )
      RETURN VARCHAR2;

--Pragma Restrict_References(F_montant_lettre, WNDS);
--
-- Repetition du nom du beneficiaire sur le cheque
--
   FUNCTION f_beneficiaire_cheque (i_nom IN VARCHAR, i_longueur IN NUMBER)
      RETURN VARCHAR2;

--Pragma Restrict_References(F_beneficiaire_cheque, WNDS);
--
-- Contrepartie d'un mouvement compte_tiers a une date donnee
--
   FUNCTION f_contrepartie (
      i_idmvt   IN   compte_tiers.idmvt%TYPE,
      i_date    IN   DATE
   )
      RETURN NUMBER;

--Pragma Restrict_References(F_contrepartie, WNDS, WNPS);
--
-- Contrepartie d'un mouvement compte_tiers a une date donnee
--
   FUNCTION f_contrepartie_d (
      i_idmvt   IN   compte_tiers.idmvt%TYPE,
      i_date    IN   DATE
   )
      RETURN NUMBER;

--
-- Retourne la societe rattachee au compte
--
   FUNCTION f_numsoc (i_numcpte IN compte.numcpte%TYPE)
      RETURN NUMBER;

--Pragma Restrict_References(F_numsoc, WNDS, WNPS);
--
-- Annulation de decaissement
--
   PROCEDURE p_annul_decaismt (
      i_numdecaismt   IN   decaismt.numdecaismt%TYPE,
      i_datannul      IN   DATE
   );
--
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_TRESO"
AS
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
-- Aucune
-- -------------------------------------- Fin des variables globales privees --

   -- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--@priv
   FUNCTION f_param_ope (
      i_codope   IN   NUMBER,
      i_modpmt   IN   NUMBER,
      i_numsoc   IN   NUMBER,
      i_numorg   IN   NUMBER,
      i_numgar   IN   NUMBER DEFAULT NULL
   )
      RETURN ROWID;

--
-- Insertion dans affectation_annul
--
   PROCEDURE p_ins_affectation_annul (
      i_numdecaismt   IN   affectation_annul.numdecaismt%TYPE,
      i_datannul      IN   DATE
   );

--
-- Recherche de l'origine des reglements fournisseur
--
   PROCEDURE p_sel_compte_tiers (
      i_idpiece    IN   affectation_annul.idpiece%TYPE,
      i_numaffec   IN   affectation_annul.numaffec%TYPE,
      i_exercice   IN   NUMBER
   );

--
-- Recherche des infos prestations sante
--
   PROCEDURE p_sel_sante (
      i_idpiece    IN   affectation_annul.idpiece%TYPE,
      i_numaffec   IN   affectation_annul.numaffec%TYPE,
      i_codope     IN   affectation_annul.codope%TYPE
   );

--
-- Recherche des infos prestations prevoyance
--
   PROCEDURE p_sel_prev (
      i_idpiece    IN   affectation_annul.idpiece%TYPE,
      i_numaffec   IN   affectation_annul.numaffec%TYPE
   );

--
-- Recherche des infos deductions URSSAF
--
   PROCEDURE p_sel_dedu (
      i_idpiece    IN   affectation_annul.idpiece%TYPE,
      i_numaffec   IN   affectation_annul.numaffec%TYPE
   );

--
-- Recherche des infos retrocession
--
   PROCEDURE p_sel_retro (
      i_idpiece   IN   affectation_annul.idpiece%TYPE,
      i_cle       IN   detail_annul.cle%TYPE
   );

--
-- Recherche des infos reversement
--
   PROCEDURE p_sel_revers (
      i_idpiece    IN   affectation_annul.idpiece%TYPE,
      i_numaffec   IN   affectation_annul.numaffec%TYPE
   );

--
-- Recherche des infos remboursement / compensation
--
   PROCEDURE p_sel_rbtcptcli (
      i_idpiece    IN   affectation_annul.idpiece%TYPE,
      i_numaffec   IN   affectation_annul.numaffec%TYPE,
      i_exercice   IN   NUMBER
   );

--
-- Insertion dans detail_annul
--
   PROCEDURE p_ins_detail_annul (
      i_idpiece     IN       detail_annul.idpiece%TYPE,
      i_codope      IN       detail_annul.codope%TYPE,
      i_cle         IN       detail_annul.cle%TYPE,
      i_numfor      IN       detail_annul.numfor%TYPE,
      i_exercice    IN       detail_annul.exercice%TYPE,
      i_montant     IN       detail_annul.montant%TYPE,
      i_montant_d   IN       detail_annul.montant_d%TYPE,
      i_monnaie     IN       detail_annul.monnaie%TYPE,
      i_monnaie_d   IN       detail_annul.monnaie_d%TYPE,
      o_iddetail    OUT      detail_annul.iddetail%TYPE
   );

--
-- ----------------------------- Fin des declarations des procedures privees --

   -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--@corpub
--
--
-- Recherche de l'utilisateur hablilite a valider la piece
--
    PROCEDURE p_sel_validateur (
      i_codope    IN       valid_ope.codope%TYPE,
      i_numsoc    IN       valid_ope.numsoc%TYPE,
      i_montant   IN       NUMBER,
      i_numindiv  IN       valid_ope.numindiv%TYPE,
      o_found     OUT      BOOLEAN
   )
   IS


      CURSOR c_valid
      IS
         SELECT numutil
           FROM valid_ope
          WHERE valid_ope.codope = i_codope
            AND valid_ope.numsoc = i_numsoc
            AND i_montant BETWEEN mini AND NVL (maxi, i_montant)
             AND nvl(numindiv,0) = 0
            AND numutil = f_numutil;

      CURSOR c_exclusivite
      IS
          SELECT numindiv, mini, maxi
            FROM valid_ope
          WHERE valid_ope.codope = i_codope
            AND valid_ope.numsoc = i_numsoc
            AND numindiv = i_numindiv
            and numutil = f_numutil;


      CURSOR c_no_exclusivite
      IS
          SELECT numindiv
            FROM valid_ope
          WHERE valid_ope.codope = i_codope
            AND valid_ope.numsoc = i_numsoc
            AND numindiv = i_numindiv
            and numutil != f_numutil;
    --
      l_numutil   NUMBER;
      rec_c_exclu  c_exclusivite%ROWTYPE;
      rec_c_no_exclu  c_no_exclusivite%ROWTYPE;

--
   BEGIN

        OPEN c_exclusivite;

          FETCH c_exclusivite INTO rec_c_exclu;
                IF c_exclusivite%FOUND THEN
                  IF i_montant between rec_c_exclu.mini and rec_c_exclu.maxi then
                       o_found:= TRUE;
                  ELSE
                       o_found :=FALSE;
                  END IF;
                 ELSE
                   OPEN  c_no_exclusivite;
                     FETCH c_no_exclusivite INTO rec_c_no_exclu;
                        IF c_no_exclusivite%FOUND THEN
                           o_found := FALSE;
                        ELSE
                          OPEN c_valid;
                              FETCH c_valid INTO l_numutil;
                                IF (c_valid%FOUND) THEN
                                  o_found := TRUE;
                                ELSE
                                  o_found := FALSE;
                                END IF;
                          CLOSE c_valid;
                        END IF;
                   CLOSE c_no_exclusivite;

                END IF;
          CLOSE c_exclusivite;

   END p_sel_validateur;


--
-- Recherche de l'utilisateur auto habililite a valider automatiquement la piece
--
   PROCEDURE p_sel_validateur_auto (
      i_codope    IN       valid_ope.codope%TYPE,
      i_numsoc    IN       valid_ope.numsoc%TYPE,
      i_montant   IN       NUMBER,
      o_found     OUT      BOOLEAN
   )
   IS
      CURSOR c_valid_auto
      IS
         SELECT numutil
           FROM valid_ope
          WHERE valid_ope.codope = i_codope
            AND valid_ope.numsoc = i_numsoc
            AND i_montant BETWEEN mini AND NVL (maxi, i_montant)
            AND numutil = 0;

--
      l_numutil   NUMBER;
--
   BEGIN
      OPEN c_valid_auto;

      FETCH c_valid_auto
       INTO l_numutil;

      IF (c_valid_auto%FOUND)
      THEN
         o_found := TRUE;
      ELSE
         o_found := FALSE;
      END IF;

      CLOSE c_valid_auto;
   END p_sel_validateur_auto;

--
-- Insertion d'une ligne compte tiers
--
   PROCEDURE p_ins_compte_tiers (
      i_numcli      IN       compte_tiers.numcli%TYPE,
      i_codope      IN       compte_tiers.codope%TYPE,
      i_cle         IN       compte_tiers.cle%TYPE,
      i_datope      IN       compte_tiers.datope%TYPE,
      i_sens        IN       compte_tiers.sens%TYPE,
      i_montant     IN       compte_tiers.montant%TYPE,
      i_montant_d   IN       compte_tiers.montant_d%TYPE,
      i_monnaie     IN       compte_tiers.monnaie%TYPE,
      i_monnaie_d   IN       compte_tiers.monnaie_d%TYPE,
      o_idmvt       OUT      compte_tiers.idmvt%TYPE
   )
   IS
   BEGIN
--
      SELECT idmvt.NEXTVAL
        INTO o_idmvt
        FROM DUAL;

--
      INSERT INTO compte_tiers
                  (idmvt, numcli, codope, cle, datope, sens,
                   montant, montant_d, monnaie, monnaie_d
                  )
           VALUES (o_idmvt, i_numcli, i_codope, i_cle, i_datope, i_sens,
                   i_montant, i_montant_d, i_monnaie, i_monnaie_d
                  );
--
   END p_ins_compte_tiers;

--
-- Insertion d'une ligne dans compensation
--
   PROCEDURE p_ins_compensation (
      i_idmvt    IN   compensation.idmvt%TYPE,
      i_idcomp   IN   compensation.idcomp%TYPE,
      i_typmvt   IN   compensation.typmvt%TYPE DEFAULT 0
   )
   IS
   BEGIN
--
      INSERT INTO compensation
                  (idmvt, idcomp, typmvt
                  )
           VALUES (i_idmvt, i_idcomp, i_typmvt
                  );
--
   END p_ins_compensation;

--
-- Insertion d'une ligne dans affectation
--
   PROCEDURE p_ins_affectation (
      i_codope        IN       affectation.codope%TYPE,
      i_numdecaismt   IN       affectation.numdecaismt%TYPE,
      i_montant       IN       affectation.montant%TYPE,
      i_montant_d     IN       affectation.montant_d%TYPE,
      i_numcli        IN       affectation.numcli%TYPE,
      o_numaffec      OUT      affectation.numaffec%TYPE,
      i_numaffec      IN       affectation.numaffec%TYPE DEFAULT NULL,
      i_dataffec      IN       affectation.dataffec%TYPE
            DEFAULT TRUNC (SYSDATE),
      i_monnaie       IN       affectation.monnaie%TYPE
            DEFAULT pk_devise.devise_ref,
      i_monnaie_d     IN       affectation.monnaie_d%TYPE,
      i_nbfeuille     IN       affectation.nbfeuille%TYPE DEFAULT NULL,
      i_montant_ct    IN       affectation.montant_ct%TYPE,
      i_devise_ct     IN       affectation.devise_ct%TYPE
   )
   IS
   BEGIN
--
      IF (i_numaffec IS NULL)
      THEN
         SELECT NVL (MAX (numaffec), 0) + 1
           INTO o_numaffec
           FROM affectation
          WHERE codope = i_codope;
      ELSE
         o_numaffec := i_numaffec;
      END IF;

--
      INSERT INTO affectation
                  (codope, numaffec, numdecaismt, montant,
                   montant_d, numcli, dataffec, monnaie, monnaie_d,
                   nbfeuille, montant_ct, devise_ct
                  )
           VALUES (i_codope, o_numaffec, i_numdecaismt, i_montant,
                   i_montant_d, i_numcli, i_dataffec, i_monnaie, i_monnaie_d,
                   i_nbfeuille, i_montant_ct, i_devise_ct
                  );
--
   END p_ins_affectation;

--
-- Insertion d'une ligne dans decaismt
--
   PROCEDURE p_ins_decaismt (
      i_codope        IN       decaismt.codope%TYPE,
      i_numcpte       IN       decaismt.numcpte%TYPE,
      i_modpmt        IN       decaismt.modpmt%TYPE,
      i_montant       IN       decaismt.montant%TYPE,
      i_montant_d     IN       decaismt.montant_d%TYPE,
      i_typbene       IN       decaismt.typbene%TYPE,
      i_numbene       IN       decaismt.numbene%TYPE,
      i_numdest       IN       decaismt.numdest%TYPE,
      i_numutil       IN       decaismt.numutil%TYPE,
      i_monnaie       IN       decaismt.monnaie%TYPE
            DEFAULT pk_devise.devise_ref,
      i_monnaie_d     IN       decaismt.monnaie_d%TYPE,
      i_montant_ct    IN       decaismt.montant_ct%TYPE,
      i_devise_ct     IN       decaismt.devise_ct%TYPE,
      o_numdecaismt   OUT      decaismt.numdecaismt%TYPE
   )
   IS
   BEGIN
--
      SELECT numdecaismt.NEXTVAL
        INTO o_numdecaismt
        FROM DUAL;

--
      INSERT INTO decaismt
                  (codope, numdecaismt, numcpte, modpmt, montant,
                   montant_d, typbene, numbene, numdest, numutil,
                   monnaie, monnaie_d, montant_ct, devise_ct, numedit
                  )
           VALUES (i_codope, o_numdecaismt, i_numcpte, i_modpmt, i_montant,
                   i_montant_d, i_typbene, i_numbene, i_numdest, i_numutil,
                   i_monnaie, i_monnaie_d, i_montant_ct, i_devise_ct, 0
                  );
--
   END p_ins_decaismt;

--
-- Compte par défaut a utiliser pou une operation et un mode de reglement donne
--
   PROCEDURE p_sel_def_compte (
      i_numsoc      IN       compte.numsoc%TYPE,
      i_codope      IN       papier_ope.codope%TYPE,
      i_modpmt      IN       papier_ope.modpmt%TYPE,
      o_numcpte     OUT      papier_ope.numcpte%TYPE,
      o_libcompte   OUT      compte.libcompte%TYPE,
      o_papid       OUT      papier_ope.papid%TYPE,
      o_found       OUT      BOOLEAN
   )
   IS
      CURSOR c_def_compte
      IS
         SELECT papier_ope.numcpte, compte.libcompte, papier_ope.papid
           FROM papier_ope, compte, vs_type_ope
          WHERE compte.numsoc = i_numsoc
            AND compte.numcpte = papier_ope.numcpte
            AND compte.numcpte = vs_type_ope.numcpte
            AND papier_ope.codope = vs_type_ope.numope
            AND papier_ope.codope = i_codope
            AND papier_ope.modpmt = i_modpmt
            AND papier_ope.defaut = '*'
            AND vs_type_ope.defaut = 'O';
   BEGIN
--
      OPEN c_def_compte;

      FETCH c_def_compte
       INTO o_numcpte, o_libcompte, o_papid;

      IF (c_def_compte%FOUND)
      THEN
         o_found := TRUE;
      ELSE
         o_found := FALSE;
      END IF;

      CLOSE c_def_compte;
--
   END p_sel_def_compte;

--
-- Parametrage des modalites de reglement (Procedure)
--
   PROCEDURE p_sel_param_ope (
      i_numsoc      IN       NUMBER,
      i_numorg      IN       NUMBER,
      i_numgar      IN       NUMBER,
      i_codope      IN       NUMBER,
      i_modpmt      IN       NUMBER,
      o_montant     OUT      param_ope.montant%TYPE,
      o_delai       OUT      param_ope.delai%TYPE,
      o_frequence   OUT      param_ope.frequence%TYPE,
      o_found       OUT      BOOLEAN
   )
   IS
      CURSOR c_param_ope (p_rowid IN ROWID)
      IS
         SELECT montant, delai, frequence
           FROM param_ope
          WHERE ROWID = p_rowid;

--
      rec_c_param_ope   c_param_ope%ROWTYPE;
      l_rowid           ROWID;
   BEGIN
--
      l_rowid :=
         f_param_ope (i_codope      => i_codope,
                      i_modpmt      => i_modpmt,
                      i_numsoc      => i_numsoc,
                      i_numorg      => i_numorg,
                      i_numgar      => i_numgar
                     );

--
      OPEN c_param_ope (l_rowid);

      FETCH c_param_ope
       INTO rec_c_param_ope;

      IF (c_param_ope%FOUND)
      THEN
         o_montant := rec_c_param_ope.montant;
         o_delai := rec_c_param_ope.delai;
         o_frequence := rec_c_param_ope.frequence;
         o_found := TRUE;
      ELSE
         o_found := FALSE;
      END IF;
--
   END p_sel_param_ope;

--
-- Parametrage des modalites de reglement (Fonction)
-- a_mode = 1 -> Renvoie 1 si le montant ou le delai de retention est atteint
-- a_mode = 2 -> Renvoie 1 si la frequence d'edition est atteinte
--
   FUNCTION f_param_ope_valide (
      i_numsoc    IN   NUMBER,
      i_numorg    IN   NUMBER,
      i_numgar    IN   NUMBER,
      i_codope    IN   NUMBER,
      i_modpmt    IN   NUMBER,
      i_mode      IN   NUMBER,
      i_montant   IN   NUMBER,
      i_date      IN   DATE DEFAULT NULL
   )
      RETURN NUMBER
   IS
      l_rowid     ROWID;
      l_retour    NUMBER;
      l_numbene   NUMBER;
      l_deredit   DATE;
   BEGIN
      l_retour := 0;
--
      l_rowid :=
         f_param_ope (i_codope      => i_codope,
                      i_modpmt      => i_modpmt,
                      i_numsoc      => i_numsoc,
                      i_numorg      => i_numorg,
                      i_numgar      => i_numgar
                     );

      IF (l_rowid IS NULL)
      THEN
         RETURN (1);
      END IF;

--
      IF (i_mode = 1)
      THEN
         BEGIN
            SELECT 1
              INTO l_retour
              FROM param_ope
             WHERE ROWID = l_rowid
               AND (   i_montant > param_ope.montant
                    OR i_date + param_ope.delai <= TRUNC (SYSDATE)
                   );
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_retour := 0;
         END;
      ELSE
         -- Frequence d'edition
         l_numbene := i_montant;

         IF (i_date IS NULL)
         THEN
            l_deredit := f_dernier_avis (i_codope, l_numbene, i_numgar);
         ELSE
            l_deredit := i_date;
         END IF;

         BEGIN
            SELECT 1
              INTO l_retour
              FROM param_ope
             WHERE ROWID = l_rowid
               AND (   l_deredit <= TRUNC (SYSDATE) - param_ope.frequence
                    OR param_ope.frequence = 0
                   );
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_retour := 0;
         END;
      END IF;

--
      RETURN (l_retour);
--
   END f_param_ope_valide;

--
-- Recherche de la date de reference de l'encaissement
--
   PROCEDURE p_sel_datencaismt (
      i_numencaismt   IN       encaismt.numencaismt%TYPE,
      i_datpay        IN       encaismt.datpay%TYPE,
      o_datencaismt   OUT      encaismt.datpay%TYPE,
      o_remise        OUT      NUMBER
   )
   IS
      CURSOR c_remise_banque
      IS
         SELECT numremise
           FROM remise_banque
          WHERE numencaismt = i_numencaismt;

      CURSOR c_remise_globale (p_numremise IN remise_banque.numremise%TYPE)
      IS
         SELECT daterem
           FROM remise_globale
          WHERE numremise = p_numremise AND valide = 'O' AND TYPE = 1;

      l_numremise   remise_banque.numremise%TYPE;
      l_daterem     DATE;
   BEGIN
      o_remise := -1;

--
      OPEN c_remise_banque;

      FETCH c_remise_banque
       INTO l_numremise;

      IF (c_remise_banque%FOUND)
      THEN
         --
         OPEN c_remise_globale (l_numremise);

         FETCH c_remise_globale
          INTO l_daterem;

         IF (c_remise_globale%FOUND)
         THEN
            o_datencaismt := l_daterem;
            o_remise := l_numremise;
         ELSE
            o_remise := 0;
         END IF;

         CLOSE c_remise_globale;
      --
      ELSE
         o_datencaismt := i_datpay;
      END IF;

      CLOSE c_remise_banque;
   END p_sel_datencaismt;

--
-- Recherche des parametres de cloture
--
   PROCEDURE p_sel_param_cloture (
      i_numsoc    IN       param_cloture.numsoc%TYPE,
      o_debut     OUT      param_cloture.debut%TYPE,
      o_fin       OUT      param_cloture.fin%TYPE,
      o_cloture   OUT      param_cloture.cloture%TYPE,
      o_found     OUT      BOOLEAN,
      i_cloture   IN       VARCHAR2 DEFAULT 'O',
      i_datref    IN       DATE DEFAULT TRUNC (SYSDATE)
   )
   IS
      CURSOR c_cloture
      IS
         SELECT   debut, fin, cloture
             FROM param_cloture
            WHERE numsoc = i_numsoc
              AND i_datref <= cloture
              AND fin <= TRUNC (SYSDATE)
              AND i_cloture = 'O'
         UNION
         SELECT   debut, fin, cloture
             FROM param_cloture
            WHERE numsoc = i_numsoc AND i_datref <= cloture
                  AND i_cloture = 'N'
         ORDER BY 1 DESC;

      rec_c_cloture   c_cloture%ROWTYPE;
      l_found         BOOLEAN             := FALSE;
   BEGIN
      OPEN c_cloture;

      FETCH c_cloture
       INTO rec_c_cloture;

      IF (c_cloture%FOUND)
      THEN
         l_found := TRUE;
         o_found := l_found;
         o_debut := rec_c_cloture.debut;
         o_fin := rec_c_cloture.fin;
         o_cloture := rec_c_cloture.cloture;
      END IF;

      CLOSE c_cloture;
   END p_sel_param_cloture;

--
-- Affectation d'un encaissement a une piece ( Ex procedure Affecte )
--
   PROCEDURE p_affecte (
      i_idaffec       IN   compte_client.idaffec%TYPE,
      i_codope        IN   compte_client.codope%TYPE,
      i_numfact       IN   compte_client.numfact%TYPE,
      i_numcli        IN   compte_client.numcli%TYPE,
      i_numencaismt   IN   compte_client.numencaismt%TYPE,
      i_montant       IN   compte_client.montant%TYPE,
      i_monnaie       IN   compte_client.monnaie%TYPE,
      i_montant_d     IN   compte_client.montant_d%TYPE,
      i_monnaie_d     IN   compte_client.monnaie_d%TYPE,
      i_datope        IN   compte_client.datope%TYPE DEFAULT TRUNC (SYSDATE)
   )
   IS
   BEGIN
-- Insertion dans compte client
      INSERT INTO compte_client
                  (idaffec, codope, numcli, numfact, numencaismt,
                   montant, monnaie, montant_d, monnaie_d, idcompta,
                   datope
                  )
           VALUES (i_idaffec, i_codope, i_numcli, i_numfact, i_numencaismt,
                   i_montant, i_monnaie, i_montant_d, i_monnaie_d, -1,
                   i_datope
                  );

--
-- Si affectation a une cotisation
--
      IF (i_codope = 4)
      THEN
         -- On prepare la ventilation dans qttc_affec
         INSERT INTO qttc_affec
                     (idaffec, idgar, numquit, numfor, numindiv, montant,
                      monnaie, montant_d, monnaie_d, idrevers
                     )
              VALUES (i_idaffec, 0, i_numfact, -1, 0, i_montant,
                      i_monnaie, i_montant_d, i_monnaie_d, 0
                     );

         --
         -- On update le montant affecte de qttc_global
         --
         UPDATE qttc_global
            SET mt_affec = NVL (qttc_global.mt_affec, 0) + i_montant,
                mt_affec_d = NVL (qttc_global.mt_affec_d, 0) + i_montant_d
          WHERE numquit = i_numfact;
/*
        Update qttc_global
   Set   mt_affec_d = nvl(qttc_global.mt_affec_d,0) + I_montant_d
   Where numquit = I_numfact;
*/
      END IF;
   END p_affecte;

--
-- Retourne le mode de reglement d'une personne
--
   FUNCTION f_bene_modpmt (
      i_numindiv     IN   rib.numindiv%TYPE,
      i_type         IN   rib.TYPE%TYPE,
      i_codope       IN   rib.codope%TYPE DEFAULT NULL,
      i_numgar       IN   rib.numgar%TYPE DEFAULT NULL,
      i_debut        IN   rib.debut%TYPE DEFAULT SYSDATE,
      i_idadhesion   IN   rib_adhe.idadhesion%TYPE DEFAULT NULL,
      i_devise       IN rib.devise_compte%Type Default Null
   )
      RETURN NUMBER
   IS
      l_modpmt   rib.modpmt%TYPE   DEFAULT 1;
      l_idrib    rib.idrib%TYPE;
   BEGIN
--
      l_idrib :=
         f_idrib (i_numindiv        => i_numindiv,
                  i_type            => i_type,
                  i_codope          => i_codope,
                  i_numgar          => i_numgar,
                  i_debut           => i_debut,
                  i_idadhesion      => i_idadhesion,
                  i_devise	        => i_devise
                 );

--
      IF (l_idrib IS NOT NULL)
      THEN
         BEGIN
            SELECT modpmt
              INTO l_modpmt
              FROM rib
             WHERE rib.idrib = l_idrib;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               l_modpmt := 1;
         END;
      END IF;

--
      RETURN (l_modpmt);
--
   END f_bene_modpmt;

--
-- Nouvelle recherche du rib en tenant compte de rib_adhe
--
   FUNCTION f_idrib (
      i_numindiv     IN   rib.numindiv%TYPE,
      i_type         IN   rib.TYPE%TYPE,
      i_codope       IN   rib.codope%TYPE DEFAULT NULL,
      i_numgar       IN   rib.numgar%TYPE DEFAULT NULL,
      i_debut        IN   rib.debut%TYPE DEFAULT SYSDATE,
      i_idadhesion   IN   rib_adhe.idadhesion%TYPE DEFAULT NULL,
      i_devise       IN   rib.devise_compte%Type Default Null
   )
      RETURN NUMBER
   IS
      CURSOR c_rib_adhe
      IS
         SELECT idrib
           FROM rib_adhe
          WHERE idadhesion = i_idadhesion AND TYPE = i_type;

      /*CURSOR c_rib_contrat -- jbn début
      IS
         SELECT   idrib
             FROM rib
            WHERE numindiv = i_numindiv
              AND TYPE = i_type
              AND debut <= i_debut
              AND codope = i_codope
              AND numgar = i_numgar
         ORDER BY debut DESC;

      CURSOR c_rib_codope
      IS
         SELECT   idrib
             FROM rib
            WHERE numindiv = i_numindiv
              AND TYPE = i_type
              AND debut <= i_debut
              AND codope = i_codope
         ORDER BY debut DESC, numgar ASC;

      CURSOR c_rib_debut
      IS
         SELECT   idrib
             FROM rib
            WHERE numindiv = i_numindiv AND TYPE = i_type AND debut <= i_debut
         ORDER BY debut DESC, codope ASC, numgar ASC;

      CURSOR c_rib_gene
      IS
         SELECT   idrib
             FROM rib
            WHERE numindiv = i_numindiv AND TYPE = i_type
         ORDER BY debut DESC, codope ASC, numgar ASC;*/ -- jbn fin

      l_idrib   rib.idrib%TYPE;
   BEGIN
      OPEN c_rib_adhe;

      FETCH c_rib_adhe
       INTO l_idrib;

      IF c_rib_adhe%NOTFOUND
      THEN
         /* OPEN c_rib_contrat; -- jbn début

         FETCH c_rib_contrat
          INTO l_idrib;

         IF c_rib_contrat%NOTFOUND
         THEN
            OPEN c_rib_codope;

            FETCH c_rib_codope
             INTO l_idrib;

            IF c_rib_codope%NOTFOUND
            THEN
               OPEN c_rib_debut;

               FETCH c_rib_debut
                INTO l_idrib;

               IF c_rib_debut%NOTFOUND
               THEN
                  OPEN c_rib_gene;

                  FETCH c_rib_gene
                   INTO l_idrib;

                  CLOSE c_rib_gene;
               END IF;

               CLOSE c_rib_debut;
            END IF;

            CLOSE c_rib_codope;
         END IF;

         CLOSE c_rib_contrat;*/
      SELECT f_bene_rib(
    		I_numindiv,
    		I_codope,
    		I_numgar,
    		I_type,
        I_devise,
        I_debut)
      INTO L_idrib
      FROM dual;
      END IF;

      CLOSE c_rib_adhe;

      RETURN (l_idrib);
   END f_idrib;

--
-- Transformation d'un montant en lettres
--
   FUNCTION f_montant_lettre (
      i_montant    IN   NUMBER,
      i_longueur   IN   NUMBER,
      i_codmon     IN   NUMBER,
      i_ligne      IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      l_chaine    VARCHAR2 (200);
      l_retour    VARCHAR2 (200);
      l_montant   VARCHAR2 (15)
                       := SUBSTR (TO_CHAR (i_montant, '099999999.00'), 2, 12);
      i           BINARY_INTEGER;
   BEGIN
-- Les Millions
      SELECT    DECODE (SUBSTR (l_montant, 1, 1),
                        '1', 'CENT ',
                        '2', 'DEUX CENT ',
                        '3', 'TROIS CENT ',
                        '4', 'QUATRE CENT ',
                        '5', 'CINQ CENT ',
                        '6', 'SIX CENT ',
                        '7', 'SEPT CENT ',
                        '8', 'HUIT CENT ',
                        '9', 'NEUF CENT ',
                        NULL
                       )
             || DECODE (SUBSTR (l_montant, 2, 1),
                        '1', DECODE (SUBSTR (l_montant, 3, 1),
                                     '0', 'DIX ',
                                     '1', 'ONZE ',
                                     '2', 'DOUZE ',
                                     '3', 'TREIZE ',
                                     '4', 'QUATORZE ',
                                     '5', 'QUINZE ',
                                     '6', 'SEIZE ',
                                     '7', 'DIX SEPT ',
                                     '8', 'DIX HUIT ',
                                     'DIX NEUF '
                                    ),
                        '2', 'VINGT ',
                        '3', 'TRENTE ',
                        '4', 'QUARANTE ',
                        '5', 'CINQUANTE ',
                        '6', 'SOIXANTE ',
                        '7', 'SOIXANTE ',
                        '8', 'QUATRE VINGT ',
                        '9', 'QUATRE VINGT ',
                        NULL
                       )
             || DECODE (SUBSTR (l_montant, 2, 1),
                        '0', DECODE (SUBSTR (l_montant, 3, 1),
                                     '1', 'UN ',
                                     '2', 'DEUX ',
                                     '3', 'TROIS ',
                                     '4', 'QUATRE ',
                                     '5', 'CINQ ',
                                     '6', 'SIX ',
                                     '7', 'SEPT ',
                                     '8', 'HUIT ',
                                     '9', 'NEUF ',
                                     NULL
                                    ),
                        '1', '',
                        DECODE (SUBSTR (l_montant, 3, 1),
                                '0', DECODE (SUBSTR (l_montant, 2, 1),
                                             '7', 'DIX ',
                                             '9', 'DIX ',
                                             NULL
                                            ),
                                '1', DECODE (SUBSTR (l_montant, 2, 1),
                                             '0', 'UN ',
                                             '7', 'ET ONZE ',
                                             '8', 'UN ',
                                             '9', 'ONZE ',
                                             'ET UN '
                                            ),
                                '2', DECODE (SUBSTR (l_montant, 2, 1),
                                             '7', 'DOUZE ',
                                             '9', 'DOUZE ',
                                             'DEUX '
                                            ),
                                '3', DECODE (SUBSTR (l_montant, 2, 1),
                                             '7', 'TREIZE ',
                                             '9', 'TREIZE ',
                                             'TROIS '
                                            ),
                                '4', DECODE (SUBSTR (l_montant, 2, 1),
                                             '7', 'QUATORZE ',
                                             '9', 'QUATORZE ',
                                             'QUATRE '
                                            ),
                                '5', DECODE (SUBSTR (l_montant, 2, 1),
                                             '7', 'QUINZE ',
                                             '9', 'QUINZE ',
                                             'CINQ '
                                            ),
                                '6', DECODE (SUBSTR (l_montant, 2, 1),
                                             '7', 'SEIZE ',
                                             '9', 'SEIZE ',
                                             'SIX '
                                            ),
                                '7', DECODE (SUBSTR (l_montant, 2, 1),
                                             '7', 'DIX SEPT ',
                                             '9', 'DIX SEPT ',
                                             'SEPT '
                                            ),
                                '8', DECODE (SUBSTR (l_montant, 2, 1),
                                             '7', 'DIX HUIT ',
                                             '9', 'DIX HUIT ',
                                             'HUIT '
                                            ),
                                DECODE (SUBSTR (l_montant, 2, 1),
                                        '7', 'DIX NEUF ',
                                        '9', 'DIX NEUF ',
                                        'NEUF '
                                       )
                               )
                       )
             || DECODE (SUBSTR (l_montant, 1, 3),
                        '000', NULL,
                        '001', 'MILLION ',
                        'MILLIONS '
                       )
             -- Les Milliers
             || DECODE (SUBSTR (l_montant, 4, 1),
                        '1', 'CENT ',
                        '2', 'DEUX CENT ',
                        '3', 'TROIS CENT ',
                        '4', 'QUATRE CENT ',
                        '5', 'CINQ CENT ',
                        '6', 'SIX CENT ',
                        '7', 'SEPT CENT ',
                        '8', 'HUIT CENT ',
                        '9', 'NEUF CENT ',
                        NULL
                       )
             || DECODE (SUBSTR (l_montant, 5, 1),
                        '1', DECODE (SUBSTR (l_montant, 6, 1),
                                     '0', 'DIX ',
                                     '1', 'ONZE ',
                                     '2', 'DOUZE ',
                                     '3', 'TREIZE ',
                                     '4', 'QUATORZE ',
                                     '5', 'QUINZE ',
                                     '6', 'SEIZE ',
                                     '7', 'DIX SEPT ',
                                     '8', 'DIX HUIT ',
                                     'DIX NEUF '
                                    ),
                        '2', 'VINGT ',
                        '3', 'TRENTE ',
                        '4', 'QUARANTE ',
                        '5', 'CINQUANTE ',
                        '6', 'SOIXANTE ',
                        '7', 'SOIXANTE ',
                        '8', 'QUATRE VINGT ',
                        '9', 'QUATRE VINGT ',
                        NULL
                       )
             || DECODE (SUBSTR (l_montant, 5, 1),
                        '0', DECODE (SUBSTR (l_montant, 6, 1),
                                     '1', 'UN ',
                                     '2', 'DEUX ',
                                     '3', 'TROIS ',
                                     '4', 'QUATRE ',
                                     '5', 'CINQ ',
                                     '6', 'SIX ',
                                     '7', 'SEPT ',
                                     '8', 'HUIT ',
                                     '9', 'NEUF ',
                                     NULL
                                    ),
                        '1', '',
                        DECODE (SUBSTR (l_montant, 6, 1),
                                '0', DECODE (SUBSTR (l_montant, 5, 1),
                                             '7', 'DIX ',
                                             '9', 'DIX ',
                                             NULL
                                            ),
                                '1', DECODE (SUBSTR (l_montant, 5, 1),
                                             '0', 'UN ',
                                             '7', 'ET ONZE ',
                                             '8', 'UN ',
                                             '9', 'ONZE ',
                                             'ET UN '
                                            ),
                                '2', DECODE (SUBSTR (l_montant, 5, 1),
                                             '7', 'DOUZE ',
                                             '9', 'DOUZE ',
                                             'DEUX '
                                            ),
                                '3', DECODE (SUBSTR (l_montant, 5, 1),
                                             '7', 'TREIZE ',
                                             '9', 'TREIZE ',
                                             'TROIS '
                                            ),
                                '4', DECODE (SUBSTR (l_montant, 5, 1),
                                             '7', 'QUATORZE ',
                                             '9', 'QUATORZE ',
                                             'QUATRE '
                                            ),
                                '5', DECODE (SUBSTR (l_montant, 5, 1),
                                             '7', 'QUINZE ',
                                             '9', 'QUINZE ',
                                             'CINQ '
                                            ),
                                '6', DECODE (SUBSTR (l_montant, 5, 1),
                                             '7', 'SEIZE ',
                                             '9', 'SEIZE ',
                                             'SIX '
                                            ),
                                '7', DECODE (SUBSTR (l_montant, 5, 1),
                                             '7', 'DIX SEPT ',
                                             '9', 'DIX SEPT ',
                                             'SEPT '
                                            ),
                                '8', DECODE (SUBSTR (l_montant, 5, 1),
                                             '7', 'DIX HUIT ',
                                             '9', 'DIX HUIT ',
                                             'HUIT '
                                            ),
                                DECODE (SUBSTR (l_montant, 5, 1),
                                        '7', 'DIX NEUF ',
                                        '9', 'DIX NEUF ',
                                        'NEUF '
                                       )
                               )
                       )
             || DECODE (SUBSTR (l_montant, 4, 3), '000', NULL, 'MILLE ')
             -- Les Centaines
             || DECODE (SUBSTR (l_montant, 7, 1),
                        '1', 'CENT ',
                        '2', 'DEUX ',
                        '3', 'TROIS ',
                        '4', 'QUATRE ',
                        '5', 'CINQ ',
                        '6', 'SIX ',
                        '7', 'SEPT ',
                        '8', 'HUIT ',
                        '9', 'NEUF ',
                        NULL
                       )
             || DECODE (SUBSTR (l_montant, 7, 1),
                        '0', NULL,
                        '1', NULL,
                        DECODE (SUBSTR (l_montant, 8, 2),
                                '00', 'CENTS ',
                                'CENT '
                               )
                       )
             || DECODE (SUBSTR (l_montant, 8, 1),
                        '1', DECODE (SUBSTR (l_montant, 9, 1),
                                     '0', 'DIX ',
                                     '1', 'ONZE ',
                                     '2', 'DOUZE ',
                                     '3', 'TREIZE ',
                                     '4', 'QUATORZE ',
                                     '5', 'QUINZE ',
                                     '6', 'SEIZE ',
                                     '7', 'DIX SEPT ',
                                     '8', 'DIX HUIT ',
                                     'DIX NEUF '
                                    ),
                        '2', 'VINGT ',
                        '3', 'TRENTE ',
                        '4', 'QUARANTE ',
                        '5', 'CINQUANTE ',
                        '6', 'SOIXANTE ',
                        '7', 'SOIXANTE ',
                        '8', 'QUATRE VINGT ',
                        '9', 'QUATRE VINGT ',
                        NULL
                       )
             || DECODE (SUBSTR (l_montant, 8, 1),
                        '0', DECODE (SUBSTR (l_montant, 9, 1),
                                     '1', 'UN ',
                                     '2', 'DEUX ',
                                     '3', 'TROIS ',
                                     '4', 'QUATRE ',
                                     '5', 'CINQ ',
                                     '6', 'SIX ',
                                     '7', 'SEPT ',
                                     '8', 'HUIT ',
                                     '9', 'NEUF ',
                                     NULL
                                    ),
                        '1', NULL,
                        DECODE (SUBSTR (l_montant, 9, 1),
                                '0', DECODE (SUBSTR (l_montant, 8, 1),
                                             '7', 'DIX ',
                                             '9', 'DIX ',
                                             NULL
                                            ),
                                '1', DECODE (SUBSTR (l_montant, 8, 1),
                                             '0', 'UN ',
                                             '7', 'ET ONZE ',
                                             '8', 'UN ',
                                             '9', 'ONZE ',
                                             'ET UN '
                                            ),
                                '2', DECODE (SUBSTR (l_montant, 8, 1),
                                             '7', 'DOUZE ',
                                             '9', 'DOUZE ',
                                             'DEUX '
                                            ),
                                '3', DECODE (SUBSTR (l_montant, 8, 1),
                                             '7', 'TREIZE ',
                                             '9', 'TREIZE ',
                                             'TROIS '
                                            ),
                                '4', DECODE (SUBSTR (l_montant, 8, 1),
                                             '7', 'QUATORZE ',
                                             '9', 'QUATORZE ',
                                             'QUATRE '
                                            ),
                                '5', DECODE (SUBSTR (l_montant, 8, 1),
                                             '7', 'QUINZE ',
                                             '9', 'QUINZE ',
                                             'CINQ '
                                            ),
                                '6', DECODE (SUBSTR (l_montant, 8, 1),
                                             '7', 'SEIZE ',
                                             '9', 'SEIZE ',
                                             'SIX '
                                            ),
                                '7', DECODE (SUBSTR (l_montant, 8, 1),
                                             '7', 'DIX SEPT ',
                                             '9', 'DIX SEPT ',
                                             'SEPT '
                                            ),
                                '8', DECODE (SUBSTR (l_montant, 8, 1),
                                             '7', 'DIX HUIT ',
                                             '9', 'DIX HUIT ',
                                             'HUIT '
                                            ),
                                DECODE (SUBSTR (l_montant, 8, 1),
                                        '7', 'DIX NEUF ',
                                        '9', 'DIX NEUF ',
                                        'NEUF '
                                       )
                               )
                       )
             || DECODE (SUBSTR (l_montant, 1, 6), '000000', '', NULL)
             || libelle
             || ' '
             || DECODE (SUBSTR (l_montant, 11, 2), '00', NULL, 'ET ')
             || DECODE (SUBSTR (l_montant, 11, 2),
                        '00', NULL,
                           SUBSTR (l_montant, 11, 2)
                        || DECODE (SUBSTR (l_montant, 11, 2),
                                   '00', NULL,
                                   ' ' || sousunit
                                  )
                       )
        INTO l_chaine
        FROM monnaie
       WHERE codmon = i_codmon;

--
      IF (i_ligne = 1)
      THEN
         IF (SUBSTR (l_chaine, 1, 8) = 'UN MILLE')
         THEN
            -- NSD 04-10-2007  L_chaine := Replace(L_chaine, 'UN ', NULL);
            l_chaine := REPLACE (l_chaine, 'UN MILLE', 'MILLE');
         END IF;

         g_montant_ligne2 := NULL;
         g_montant_ligne3 := NULL;
         g_montant_ligne2 :=
                  LTRIM (SUBSTR (l_chaine, i_longueur + 1, LENGTH (l_chaine)));
         g_montant_ligne3 :=
             LTRIM (SUBSTR (l_chaine, (2 * i_longueur) + 1, LENGTH (l_chaine)));
         l_retour := SUBSTR (l_chaine, 1, i_longueur);
         l_retour := RPAD (l_retour, i_longueur, '*');
         RETURN (l_retour);
      ELSIF (i_ligne = 2)
      THEN
         g_montant_ligne2 :=
                          RPAD (NVL (g_montant_ligne2, '*'), i_longueur, '*');
         RETURN (g_montant_ligne2);
      ELSE
         g_montant_ligne3 :=
                          RPAD (NVL (g_montant_ligne3, '*'), i_longueur, '*');
         RETURN (g_montant_ligne3);
      END IF;
   END f_montant_lettre;

--
-- Repetition du nom du beneficiaire sur le cheque
--
   FUNCTION f_beneficiaire_cheque (i_nom IN VARCHAR, i_longueur IN NUMBER)
      RETURN VARCHAR2
   IS
      l_retour   VARCHAR2 (200);
   BEGIN
      l_retour :=
         SUBSTR (REPLACE ('                              ', ' ', i_nom || '*'),
                 1,
                 i_longueur
                );
      RETURN (l_retour);
   END f_beneficiaire_cheque;

--
-- Contrepartie d'un mouvement compte_tiers a une date donnee
--
   FUNCTION f_contrepartie (
      i_idmvt   IN   compte_tiers.idmvt%TYPE,
      i_date    IN   DATE
   )
      RETURN NUMBER
   IS
      l_contrepartie   NUMBER;
   BEGIN
      SELECT NVL (SUM (montant * sens), 0)
        INTO l_contrepartie
        FROM compte_tiers
       WHERE idmvt IN (SELECT idcomp
                         FROM compensation
                        WHERE idmvt = i_idmvt) AND datope <= i_date;

      RETURN (l_contrepartie);
   END f_contrepartie;

--
-- Contrepartie d'un mouvement compte_tiers a une date donnee
--
   FUNCTION f_contrepartie_d (
      i_idmvt   IN   compte_tiers.idmvt%TYPE,
      i_date    IN   DATE
   )
      RETURN NUMBER
   IS
      l_contrepartie   NUMBER;
   BEGIN
      SELECT NVL (SUM (montant_d * sens), 0)
        INTO l_contrepartie
        FROM compte_tiers
       WHERE idmvt IN (SELECT idcomp
                         FROM compensation
                        WHERE idmvt = i_idmvt) AND datope <= i_date;

      RETURN (l_contrepartie);
   END f_contrepartie_d;

--
-- Retourne la societe rattachee au compte
--
   FUNCTION f_numsoc (i_numcpte IN compte.numcpte%TYPE)
      RETURN NUMBER
   IS
      CURSOR c_soc
      IS
         SELECT numsoc
           FROM compte
          WHERE numcpte = i_numcpte;

      CURSOR c_def_soc
      IS
         SELECT numsoc
           FROM vd_societe;

      rec_c_soc       c_soc%ROWTYPE;
      rec_c_def_soc   c_def_soc%ROWTYPE;
      l_numsoc        compte.numsoc%TYPE;
   BEGIN
      OPEN c_soc;

      FETCH c_soc
       INTO rec_c_soc;

      IF (c_soc%NOTFOUND)
      THEN
         OPEN c_def_soc;

         FETCH c_def_soc
          INTO rec_c_def_soc;

         CLOSE c_def_soc;

         l_numsoc := rec_c_def_soc.numsoc;
      ELSE
         l_numsoc := rec_c_soc.numsoc;
      END IF;

      CLOSE c_soc;

--
      RETURN (l_numsoc);
--
   END f_numsoc;

--
-- Annulation de decaissement
--
   PROCEDURE p_annul_decaismt (
      i_numdecaismt   IN   decaismt.numdecaismt%TYPE,
      i_datannul      IN   DATE
   )
   IS
   BEGIN
      p_ins_affectation_annul (i_numdecaismt      => i_numdecaismt,
                               i_datannul         => i_datannul
                              );
   END p_annul_decaismt;

--
-- ---------------------------------- Fin des corps des procedures publiques --

   -- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--@corpriv
--
-- Retourne l'enregistrement de parametrage des modalites de reglement
--
   FUNCTION f_param_ope (
      i_codope   IN   NUMBER,
      i_modpmt   IN   NUMBER,
      i_numsoc   IN   NUMBER,
      i_numorg   IN   NUMBER,
      i_numgar   IN   NUMBER DEFAULT NULL
   )
      RETURN ROWID
   IS
      l_rowid    ROWID  DEFAULT NULL;
      l_numsoc   NUMBER := i_numsoc;
      l_numorg   NUMBER := i_numorg;
   BEGIN
      IF (i_numgar IS NOT NULL)
      THEN
         BEGIN
            SELECT numinterm, numorg
              INTO l_numsoc, l_numorg
              FROM contrat
             WHERE numgar = i_numgar;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               RETURN (l_rowid);
         END;
      END IF;

-- Parametrage global societe
      BEGIN
         SELECT ROWID
           INTO l_rowid
           FROM param_ope
          WHERE param_ope.numsoc = l_numsoc
            AND param_ope.numorg = 0
            AND param_ope.numgar = 0
            AND param_ope.codope = i_codope
            AND param_ope.modpmt = i_modpmt;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

-- Parametrage specifique compagnie
      BEGIN
         SELECT ROWID
           INTO l_rowid
           FROM param_ope
          WHERE param_ope.numsoc = l_numsoc
            AND param_ope.numorg = l_numorg
            AND param_ope.numgar = 0
            AND param_ope.codope = i_codope
            AND param_ope.modpmt = i_modpmt;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

-- Parametrage specifique contrat
      BEGIN
         SELECT ROWID
           INTO l_rowid
           FROM param_ope
          WHERE param_ope.numsoc = l_numsoc
            AND param_ope.numorg = l_numorg
            AND param_ope.numgar = i_numgar
            AND param_ope.codope = i_codope
            AND param_ope.modpmt = i_modpmt;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

--
      RETURN (l_rowid);
   END f_param_ope;

--
-- Insertion dans affectation_annul
--
   PROCEDURE p_ins_affectation_annul (
      i_numdecaismt   IN   affectation_annul.numdecaismt%TYPE,
      i_datannul      IN   DATE
   )
   IS
      CURSOR c_affec
      IS
         SELECT codope, numaffec, montant, montant_d, monnaie, monnaie_d,
                dataffec, numcli,
                nbfeuille,
                montant_ec,
                type_ec,
                sens_ec,
                devise_ec,
                montant_ct,
                devise_ct,
                idcompta
           FROM affectation
          WHERE affectation.numdecaismt = i_numdecaismt;

--
      rec_c_affec   c_affec%ROWTYPE;
      l_idpiece     affectation_annul.idpiece%TYPE;
   BEGIN
      OPEN c_affec;

      LOOP
         FETCH c_affec
          INTO rec_c_affec;

         EXIT WHEN c_affec%NOTFOUND;

         --
         SELECT idpiece.NEXTVAL
           INTO l_idpiece
           FROM DUAL;

         --
         INSERT INTO affectation_annul
                     (idpiece, codope, numaffec,
                      numdecaismt, montant,
                      montant_d, monnaie,
                      monnaie_d, dataffec,
                      numcli, datannul,
                      Nbfeuille,
                      Montant_ec,
                      Type_ec,
                      Sens_ec,
                      Devise_ec,
                      Montant_ct,
                      Devise_ct,
                      Idcompta_init
                     )
              VALUES (l_idpiece, rec_c_affec.codope, rec_c_affec.numaffec,
                      i_numdecaismt, rec_c_affec.montant,
                      rec_c_affec.montant_d, rec_c_affec.monnaie,
                      rec_c_affec.monnaie_d, rec_c_affec.dataffec,
                      rec_c_affec.numcli, i_datannul,
                      rec_c_affec.nbfeuille,
                      rec_c_affec.montant_ec,
                      rec_c_affec.type_ec,
                      rec_c_affec.sens_ec,
                      rec_c_affec.devise_ec,
                      rec_c_affec.montant_ct,
                      rec_c_affec.devise_ct,
                      rec_c_affec.idcompta
                     );

         --
         IF (rec_c_affec.codope = 1)
         THEN
            p_sel_sante (i_idpiece       => l_idpiece,
                         i_numaffec      => rec_c_affec.numaffec,
                         i_codope        => rec_c_affec.codope
                        );
         ELSIF (rec_c_affec.codope = 2)
         THEN
            p_sel_prev (i_idpiece       => l_idpiece,
                        i_numaffec      => rec_c_affec.numaffec
                       );
         ELSIF (rec_c_affec.codope = 5)
         THEN
            p_sel_revers (i_idpiece       => l_idpiece,
                          i_numaffec      => rec_c_affec.numaffec
                         );
         ELSIF (rec_c_affec.codope = 8)
         THEN
            p_sel_rbtcptcli (i_idpiece       => l_idpiece,
                             i_numaffec      => rec_c_affec.numaffec,
                             i_exercice      => TO_CHAR (i_datannul, 'yyyy')
                            );
         ELSIF (rec_c_affec.codope = 10)
         THEN
            p_sel_compte_tiers (i_idpiece       => l_idpiece,
                                i_numaffec      => rec_c_affec.numaffec,
                                i_exercice      => TO_CHAR (i_datannul,
                                                            'yyyy')
                               );
         ELSIF (rec_c_affec.codope = 11)
         THEN
            p_sel_dedu (i_idpiece       => l_idpiece,
                        i_numaffec      => rec_c_affec.numaffec
                       );
         END IF;
      END LOOP;

      CLOSE c_affec;
   END p_ins_affectation_annul;

--
-- Recherche de l'origine des reglements fournisseur
--@trav
   PROCEDURE p_sel_compte_tiers (
      i_idpiece    IN   affectation_annul.idpiece%TYPE,
      i_numaffec   IN   affectation_annul.numaffec%TYPE,
      i_exercice   IN   NUMBER
   )
   IS
      CURSOR c_tiers
      IS
         SELECT compte_tiers.codope, compte_tiers.cle,
                compte_tiers.sens * compte_tiers.montant montant,
                compte_tiers.sens * compte_tiers.montant_d montant_d,
                compte_tiers.monnaie, compte_tiers.monnaie_d
           FROM compte_tiers
          WHERE compte_tiers.idmvt IN (
                   SELECT compensation.idmvt
                     FROM compensation, compte_tiers affec
                    WHERE affec.codope = 10
                      AND affec.cle = i_numaffec
                      AND affec.sens = -1
                      AND compensation.idcomp = affec.idmvt);

      rec_c_tiers   c_tiers%ROWTYPE;
      l_iddetail    detail_annul.iddetail%TYPE;
   BEGIN
      OPEN c_tiers;

      LOOP
         FETCH c_tiers
          INTO rec_c_tiers;

         EXIT WHEN c_tiers%NOTFOUND;

         --
         IF (rec_c_tiers.codope = 2)
         THEN
            p_sel_prev (i_idpiece       => i_idpiece,
                        i_numaffec      => rec_c_tiers.cle);
         ELSIF (rec_c_tiers.codope = 14)
         THEN
            p_sel_sante (i_idpiece       => i_idpiece,
                         i_numaffec      => rec_c_tiers.cle,
                         i_codope        => rec_c_tiers.codope
                        );
         ELSIF (rec_c_tiers.codope = 16)
         THEN
            p_sel_retro (i_idpiece => i_idpiece, i_cle => rec_c_tiers.cle);
         ELSIF (rec_c_tiers.codope IN (10, 15))
         THEN
            p_ins_detail_annul (i_idpiece        => i_idpiece,
                                i_codope         => rec_c_tiers.codope,
                                i_cle            => rec_c_tiers.cle,
                                i_numfor         => 0,
                                i_exercice       => i_exercice,
                                i_montant        => rec_c_tiers.montant,
                                i_montant_d      => rec_c_tiers.montant_d,
                                i_monnaie        => rec_c_tiers.monnaie,
                                i_monnaie_d      => rec_c_tiers.monnaie_d,
                                o_iddetail       => l_iddetail
                               );
         END IF;
      END LOOP;

      CLOSE c_tiers;
   END p_sel_compte_tiers;

--
-- Recherche des infos prestations sante
--
   PROCEDURE p_sel_sante (
      i_idpiece    IN   affectation_annul.idpiece%TYPE,
      i_numaffec   IN   affectation_annul.numaffec%TYPE,
      i_codope     IN   affectation_annul.codope%TYPE
   )
   IS
      CURSOR c_sante
      IS
         SELECT   SUM (sinistre.mtreel) montant,
                  SUM (sinistre_dev.mtreel_out) montant_d,
                  sinistre.monnaie monnaie, sinistre_dev.dev_out monnaie_d,
                  sinistre.numfor, TO_CHAR (sinistre.datsin, 'yyyy')
                                                                    exercice
             FROM sinistre, sinistre_dev
            WHERE sinistre.numdec = i_numaffec
              AND sinistre.numsin = sinistre_dev.numsin
         GROUP BY sinistre.monnaie,
                  sinistre_dev.dev_out,
                  sinistre.numfor,
                  TO_CHAR (sinistre.datsin, 'yyyy');

--
      rec_c_sante   c_sante%ROWTYPE;
      l_iddetail    detail_annul.iddetail%TYPE;
   BEGIN
      OPEN c_sante;

      LOOP
         FETCH c_sante
          INTO rec_c_sante;

         EXIT WHEN c_sante%NOTFOUND;
         --
         p_ins_detail_annul (i_idpiece        => i_idpiece,
                             i_codope         => i_codope,
                             i_cle            => i_numaffec,
                             i_numfor         => rec_c_sante.numfor,
                             i_exercice       => rec_c_sante.exercice,
                             i_montant        => rec_c_sante.montant,
                             i_montant_d      => rec_c_sante.montant_d,
                             i_monnaie        => rec_c_sante.monnaie,
                             i_monnaie_d      => rec_c_sante.monnaie_d,
                             o_iddetail       => l_iddetail
                            );
      END LOOP;

      CLOSE c_sante;
   END p_sel_sante;

--
-- Recherche des infos prestations prevoyance
--
   PROCEDURE p_sel_prev (
      i_idpiece    IN   affectation_annul.idpiece%TYPE,
      i_numaffec   IN   affectation_annul.numaffec%TYPE
   )
   IS
      CURSOR c_prev
      IS
         SELECT   SUM (f_total_histo (histo_jours.idhisto, -2)) montant,
                  SUM (f_total_histo_d (histo_jours.idhisto, -2)) montant_d,
                  repartition.numfor,
                  TO_CHAR (sntr_prev.survenance, 'yyyy') exercice,
                  histo_jours.monnaie, histo_jours.monnaie_d
             FROM sntr_prev, repartition, histo_jours, histo_calcul
            WHERE sntr_prev.nosin = repartition.nosin
              AND repartition.idrepartition = histo_calcul.idrepartition
              AND histo_jours.idcalcul = histo_calcul.idcalcul
              AND histo_calcul.numdec = i_numaffec
         GROUP BY repartition.numfor,
                  TO_CHAR (sntr_prev.survenance, 'yyyy'),
                  histo_jours.monnaie,
                  histo_jours.monnaie_d;

--
      rec_c_prev   c_prev%ROWTYPE;
      l_iddetail   detail_annul.iddetail%TYPE;
   BEGIN
      OPEN c_prev;

      LOOP
         FETCH c_prev
          INTO rec_c_prev;

         EXIT WHEN c_prev%NOTFOUND;

         --
         IF (rec_c_prev.numfor IS NOT NULL)
         THEN
            p_ins_detail_annul (i_idpiece        => i_idpiece,
                                i_codope         => 2,
                                i_cle            => i_numaffec,
                                i_numfor         => rec_c_prev.numfor,
                                i_exercice       => rec_c_prev.exercice,
                                i_montant        => rec_c_prev.montant,
                                i_montant_d      => rec_c_prev.montant_d,
                                i_monnaie        => rec_c_prev.monnaie,
                                i_monnaie_d      => rec_c_prev.monnaie_d,
                                o_iddetail       => l_iddetail
                               );
         END IF;
      END LOOP;

      CLOSE c_prev;
   END p_sel_prev;

--
-- Recherche des infos deductions URSSAF
--
   PROCEDURE p_sel_dedu (
      i_idpiece    IN   affectation_annul.idpiece%TYPE,
      i_numaffec   IN   affectation_annul.numaffec%TYPE
   )
   IS
      CURSOR c_dedu
      IS
         SELECT   SUM (ROUND ((  ((histo_jours.fin - histo_jours.debut) + 1)
                               * histo_dedu.montant
                              ),
                              2
                             )
                      ) montant,
                  SUM (ROUND ((  ((histo_jours.fin - histo_jours.debut) + 1)
                               * histo_dedu.montant_d
                              ),
                              2
                             )
                      ) montant_d,
                  histo_dedu.typdedu, repartition.numfor,
                  TO_CHAR (sntr_prev.survenance, 'yyyy') exercice,
                  histo_jours.monnaie, histo_jours.monnaie_d
             FROM sntr_prev,
                  repartition,
                  histo_jours,
                  histo_dedu,
                  histo_calcul
            WHERE sntr_prev.nosin = repartition.nosin
              AND repartition.idrepartition = histo_calcul.idrepartition
              AND histo_dedu.idhisto = histo_jours.idhisto
              AND histo_jours.idcalcul = histo_calcul.idcalcul
              AND histo_calcul.numdec = i_numaffec
         GROUP BY histo_dedu.typdedu,
                  repartition.numfor,
                  TO_CHAR (sntr_prev.survenance, 'yyyy'),
                  histo_jours.monnaie,
                  histo_jours.monnaie_d;

--
      rec_c_dedu   c_dedu%ROWTYPE;
      l_iddetail   detail_annul.iddetail%TYPE;
   BEGIN
      OPEN c_dedu;

      LOOP
         FETCH c_dedu
          INTO rec_c_dedu;

         EXIT WHEN c_dedu%NOTFOUND;
         --
         p_ins_detail_annul (i_idpiece        => i_idpiece,
                             i_codope         => 11,
                             i_cle            => i_numaffec,
                             i_numfor         => rec_c_dedu.numfor,
                             i_exercice       => rec_c_dedu.exercice,
                             i_montant        => rec_c_dedu.montant,
                             i_montant_d      => rec_c_dedu.montant_d,
                             i_monnaie        => rec_c_dedu.monnaie,
                             i_monnaie_d      => rec_c_dedu.monnaie_d,
                             o_iddetail       => l_iddetail
                            );

         --
         INSERT INTO dedu_annul
                     (iddetail, typdedu
                     )
              VALUES (l_iddetail, rec_c_dedu.typdedu
                     );
      --
      END LOOP;

      CLOSE c_dedu;
   END p_sel_dedu;

--
-- Recherche des infos remboursement / compensation
--
   PROCEDURE p_sel_rbtcptcli (
      i_idpiece    IN   affectation_annul.idpiece%TYPE,
      i_numaffec   IN   affectation_annul.numaffec%TYPE,
      i_exercice   IN   NUMBER
   )
   IS
      CURSOR c_rbt
      IS
         SELECT compte_client.montant, compte_client.montant_d,
                compte_client.monnaie, compte_client.monnaie_d
           FROM compte_client, rbtcptcli
          WHERE compte_client.idaffec = rbtcptcli.idaffec
            AND rbtcptcli.numaffec = i_numaffec;

--
      rec_c_rbt    c_rbt%ROWTYPE;
      l_iddetail   detail_annul.iddetail%TYPE;
   BEGIN
      OPEN c_rbt;

      LOOP
         FETCH c_rbt
          INTO rec_c_rbt;

         EXIT WHEN c_rbt%NOTFOUND;
         --
         p_ins_detail_annul (i_idpiece        => i_idpiece,
                             i_codope         => 8,
                             i_cle            => i_numaffec,
                             i_numfor         => 0,
                             i_exercice       => i_exercice,
                             i_montant        => rec_c_rbt.montant,
                             i_montant_d      => rec_c_rbt.montant_d,
                             i_monnaie        => rec_c_rbt.monnaie,
                             i_monnaie_d      => rec_c_rbt.monnaie_d,
                             o_iddetail       => l_iddetail
                            );
      --
      END LOOP;

      CLOSE c_rbt;
   END p_sel_rbtcptcli;

--
-- Recherche des infos reversement
--
   PROCEDURE p_sel_revers (
      i_idpiece    IN   affectation_annul.idpiece%TYPE,
      i_numaffec   IN   affectation_annul.numaffec%TYPE
   )
   IS
      CURSOR c_revers
      IS
         SELECT   SUM (qttc_affec.montant) montant,
                  SUM (qttc_affec.montant_d) montant_d, qttc_affec.monnaie,
                  qttc_affec.monnaie_d, qttc_affec.numfor,
                  TO_CHAR (qttc_global.debut, 'yyyy') exercice
             FROM qttc_global, qttc_affec
            WHERE qttc_global.numquit = qttc_affec.numquit
              AND qttc_affec.idrevers = i_numaffec
         GROUP BY qttc_affec.monnaie,
                  qttc_affec.monnaie_d,
                  qttc_affec.numfor,
                  TO_CHAR (qttc_global.debut, 'yyyy');

--
      rec_c_revers   c_revers%ROWTYPE;
      l_iddetail     detail_annul.iddetail%TYPE;
   BEGIN
      OPEN c_revers;

      LOOP
         FETCH c_revers
          INTO rec_c_revers;

         EXIT WHEN c_revers%NOTFOUND;
         --
         p_ins_detail_annul (i_idpiece        => i_idpiece,
                             i_codope         => 5,
                             i_cle            => i_numaffec,
                             i_numfor         => rec_c_revers.numfor,
                             i_exercice       => rec_c_revers.exercice,
                             i_montant        => rec_c_revers.montant,
                             i_montant_d      => rec_c_revers.montant_d,
                             i_monnaie        => rec_c_revers.monnaie,
                             i_monnaie_d      => rec_c_revers.monnaie_d,
                             o_iddetail       => l_iddetail
                            );
      --
      END LOOP;

      CLOSE c_revers;
   END p_sel_revers;

--
-- Recherche des infos retrocession
--@trav
   PROCEDURE p_sel_retro (
      i_idpiece   IN   affectation_annul.idpiece%TYPE,
      i_cle       IN   detail_annul.cle%TYPE
   )
   IS
      CURSOR c_retro
      IS
         SELECT   SUM (qttc_affec_tfc.montant) montant,
                  SUM (qttc_affec_tfc.montant_d) montant_d,
                  qttc_affec_tfc.monnaie, qttc_affec_tfc.monnaie_d,
                  qttc_affec_tfc.type_tfc, qttc_affec_tfc.numfor,
                  TO_CHAR (qttc_global.debut, 'yyyy') exercice
             FROM qttc_global, qttc_affec_tfc
            WHERE qttc_global.numquit = qttc_affec_tfc.numquit
              AND qttc_affec_tfc.tfc = 5
              AND qttc_affec_tfc.idrevers = i_cle
         GROUP BY qttc_affec_tfc.monnaie,
                  qttc_affec_tfc.monnaie_d,
                  qttc_affec_tfc.type_tfc,
                  qttc_affec_tfc.numfor,
                  TO_CHAR (qttc_global.debut, 'yyyy');

--
      rec_c_retro   c_retro%ROWTYPE;
      l_iddetail    detail_annul.iddetail%TYPE;
   BEGIN
      OPEN c_retro;

      LOOP
         FETCH c_retro
          INTO rec_c_retro;

         EXIT WHEN c_retro%NOTFOUND;
         --
         p_ins_detail_annul (i_idpiece        => i_idpiece,
                             i_codope         => 16,
                             i_cle            => i_cle,
                             i_numfor         => rec_c_retro.numfor,
                             i_exercice       => rec_c_retro.exercice,
                             i_montant        => rec_c_retro.montant,
                             i_montant_d      => rec_c_retro.montant_d,
                             i_monnaie        => rec_c_retro.monnaie,
                             i_monnaie_d      => rec_c_retro.monnaie_d,
                             o_iddetail       => l_iddetail
                            );

         --
         INSERT INTO retro_annul
                     (iddetail, type_retro
                     )
              VALUES (l_iddetail, rec_c_retro.type_tfc
                     );
      --
      END LOOP;

      CLOSE c_retro;
   END p_sel_retro;

--
-- Insertion dans detail_annul
--
   PROCEDURE p_ins_detail_annul (
      i_idpiece     IN       detail_annul.idpiece%TYPE,
      i_codope      IN       detail_annul.codope%TYPE,
      i_cle         IN       detail_annul.cle%TYPE,
      i_numfor      IN       detail_annul.numfor%TYPE,
      i_exercice    IN       detail_annul.exercice%TYPE,
      i_montant     IN       detail_annul.montant%TYPE,
      i_montant_d   IN       detail_annul.montant_d%TYPE,
      i_monnaie     IN       detail_annul.monnaie%TYPE,
      i_monnaie_d   IN       detail_annul.monnaie_d%TYPE,
      o_iddetail    OUT      detail_annul.iddetail%TYPE
   )
   IS
   BEGIN
--
      SELECT iddetail.NEXTVAL
        INTO o_iddetail
        FROM DUAL;

--
      INSERT INTO detail_annul
                  (iddetail, idpiece, codope, cle, numfor,
                   exercice, montant, montant_d, monnaie, monnaie_d
                  )
           VALUES (o_iddetail, i_idpiece, i_codope, i_cle, i_numfor,
                   i_exercice, i_montant, i_montant_d, i_monnaie, i_monnaie_d
                  );
--
   END p_ins_detail_annul;
--
-- ------------------------------------ Fin des corps des procedures privees --
END pk_treso;
/
