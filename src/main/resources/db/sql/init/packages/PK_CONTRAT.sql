CREATE OR REPLACE PACKAGE ARTHUS."PK_CONTRAT"
AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_contrat.sql   1.2  01/02/05
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
-- Procedure permettant de mettre a jour les differentes tables en relation
-- avec la table contrat. Cette Procedure est appelee a partir du Trigger
-- sur la table Contrat suite  a la mise a jour de "dateffet".
--
   PROCEDURE p_upd_relation_contrat (
      i_numgar       IN   contrat.numgar%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2 DEFAULT NULL
   );

--
-- Procedure permettant de mettre a jour les differentes tables en relation
-- avec la table Gar_cntrt. Cette Procedure est appelee a partir du Trigger
-- sur la table Gar_cntrt suite  a la mise a jour de "datapli".
--
   PROCEDURE p_upd_relation_gar_cntrt (
      i_numgar        IN   gar_cntrt.numgar%TYPE,
      i_numfor        IN   gar_cntrt.numfor%TYPE,
      i_type          IN   gar_cntrt.TYPE%TYPE,
      i_old_datapli   IN   gar_cntrt.datapli%TYPE,
      i_new_datapli   IN   gar_cntrt.datapli%TYPE,
      i_flag          IN   VARCHAR2 DEFAULT NULL
   );

--
-- Procedure permettant de rechercher une information complementaire
-- sur un  contrat donne.
-- il y a 5 informations complementaires possibles, il faut passer
-- le numero d'information voulu
--
   FUNCTION f_contrat_info_compl (
      i_numgar        IN   contrat_compl.numgar%TYPE,
      i_numgar_ref    IN   contrat_compl.numgar_ref%TYPE,
      i_num_col       IN   NUMBER
  ) RETURN VARCHAR2;

-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_CONTRAT"
AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_contrat.sql   1.2  01/02/05
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
   PROCEDURE p_upd_apporteur (
      i_cle          IN   apporteur.cle%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   );

--
   PROCEDURE p_upd_cond_adhesion (
      i_cle          IN   cond_adhesion.cle%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   );

--
   PROCEDURE p_upd_cond_proposition (
      i_cle          IN   cond_proposition.cle%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   );

--
   PROCEDURE p_upd_grp_gar (
      i_clef         IN   grp_gar.clef%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   );

--
   PROCEDURE p_upd_val_variable (
      i_clef         IN   val_variable.clef%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   );

--
   PROCEDURE p_upd_param_devise (
      i_numgar       IN   param_devise.numgar%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   );

--
   PROCEDURE p_upd_gar_cntrt (
      i_numgar       IN   gar_cntrt.numgar%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   );

--
--
   PROCEDURE p_upd_garanties (
      i_cle         IN   garanties.cle%TYPE,
      i_numfor      IN   garanties.numfor%TYPE,
      i_old_debut   IN   garanties.debut%TYPE,
      i_new_debut   IN   garanties.debut%TYPE,
      i_flag        IN   VARCHAR2
   );

--
   PROCEDURE p_upd_frml_dedu (
      i_numfor      IN   frml_dedu.numfor%TYPE,
      i_old_debut   IN   frml_dedu.debut%TYPE,
      i_new_debut   IN   frml_dedu.debut%TYPE,
      i_flag        IN   VARCHAR2
   );

--
   PROCEDURE p_upd_frml_prest (
      i_numfor      IN   frml_prest.numfor%TYPE,
      i_old_debut   IN   frml_prest.debut%TYPE,
      i_new_debut   IN   frml_prest.debut%TYPE,
      i_flag        IN   VARCHAR2
   );

--
   PROCEDURE p_upd_frml_reval (
      i_numfor      IN   frml_reval.numfor%TYPE,
      i_old_debut   IN   frml_reval.debut%TYPE,
      i_new_debut   IN   frml_reval.debut%TYPE,
      i_flag        IN   VARCHAR2
   );

--
   PROCEDURE p_upd_formule (
      i_numfor      IN   formule.numfor%TYPE,
      i_old_debut   IN   formule.debut%TYPE,
      i_new_debut   IN   formule.debut%TYPE,
      i_flag        IN   VARCHAR2
   );

--
   PROCEDURE p_upd_calcul (
      i_numfor        IN   calcul.numfor%TYPE,
      i_old_datapli   IN   calcul.datapli%TYPE,
      i_new_datapli   IN   calcul.datapli%TYPE,
      i_flag          IN   VARCHAR2
   );

--
   PROCEDURE p_upd_carence (
      i_numfor        IN   carence.numfor%TYPE,
      i_old_datapli   IN   carence.datapli%TYPE,
      i_new_datapli   IN   carence.datapli%TYPE,
      i_flag          IN   VARCHAR2
   );

--
   PROCEDURE p_upd_cond_adhesion_gar (
      i_numfor      IN   cond_adhesion_gar.numfor%TYPE,
      i_old_debut   IN   cond_adhesion_gar.debut%TYPE,
      i_new_debut   IN   cond_adhesion_gar.debut%TYPE,
      i_flag        IN   VARCHAR2
   );

--
   PROCEDURE p_upd_franact (
      i_numfor        IN   franact.numfor%TYPE,
      i_old_datapli   IN   franact.datapli%TYPE,
      i_new_datapli   IN   franact.datapli%TYPE,
      i_flag          IN   VARCHAR2
   );

--
   PROCEDURE p_upd_franfor (
      i_numfor        IN   franfor.numfor%TYPE,
      i_old_datapli   IN   franfor.datapli%TYPE,
      i_new_datapli   IN   franfor.datapli%TYPE,
      i_flag          IN   VARCHAR2
   );

--
   PROCEDURE p_upd_maxact (
      i_numfor        IN   maxact.numfor%TYPE,
      i_old_datapli   IN   maxact.datapli%TYPE,
      i_new_datapli   IN   maxact.datapli%TYPE,
      i_flag          IN   VARCHAR2
   );

--
   PROCEDURE p_upd_maxfor (
      i_numfor        IN   maxfor.numfor%TYPE,
      i_old_datapli   IN   maxfor.datapli%TYPE,
      i_new_datapli   IN   maxfor.datapli%TYPE,
      i_flag          IN   VARCHAR2
   );

--
   PROCEDURE p_upd_defrub (
      i_numfor        IN   defrub.numfor%TYPE,
      i_old_datapli   IN   defrub.datapli%TYPE,
      i_new_datapli   IN   defrub.datapli%TYPE,
      i_flag          IN   VARCHAR2
   );

--
   PROCEDURE p_upd_frml_prime_simple (
      i_numfor      IN   frml_prime_simple.numfor%TYPE,
      i_old_debut   IN   frml_prime_simple.debut%TYPE,
      i_new_debut   IN   frml_prime_simple.debut%TYPE,
      i_flag        IN   VARCHAR2
   );

--
   PROCEDURE p_upd_frml_tfc (
      i_numfor      IN   frml_tfc.numfor%TYPE,
      i_old_debut   IN   frml_tfc.debut%TYPE,
      i_new_debut   IN   frml_tfc.debut%TYPE,
      i_flag        IN   VARCHAR2
   );

--
-- ----------------------------- Fin des declarations des procedures privees --
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--
   PROCEDURE p_upd_relation_contrat (
      i_numgar       IN   contrat.numgar%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2 DEFAULT NULL
   )
   IS
   BEGIN
      p_upd_apporteur (i_cle             => i_numgar,
                       i_old_dateff      => i_old_dateff,
                       i_new_dateff      => i_new_dateff,
                       i_flag            => i_flag
                      );
      --
      p_upd_cond_adhesion (i_cle             => i_numgar,
                           i_old_dateff      => i_old_dateff,
                           i_new_dateff      => i_new_dateff,
                           i_flag            => i_flag
                          );
      --
      p_upd_cond_proposition (i_cle             => i_numgar,
                              i_old_dateff      => i_old_dateff,
                              i_new_dateff      => i_new_dateff,
                              i_flag            => i_flag
                             );
      --
      p_upd_grp_gar (i_clef            => i_numgar,
                     i_old_dateff      => i_old_dateff,
                     i_new_dateff      => i_new_dateff,
                     i_flag            => i_flag
                    );
      --
      p_upd_val_variable (i_clef            => i_numgar,
                          i_old_dateff      => i_old_dateff,
                          i_new_dateff      => i_new_dateff,
                          i_flag            => i_flag
                         );
      --
      p_upd_param_devise (i_numgar          => i_numgar,
                          i_old_dateff      => i_old_dateff,
                          i_new_dateff      => i_new_dateff,
                          i_flag            => i_flag
                         );
      --
      p_upd_gar_cntrt (i_numgar          => i_numgar,
                       i_old_dateff      => i_old_dateff,
                       i_new_dateff      => i_new_dateff,
                       i_flag            => i_flag
                      );
   END;

--
--
   PROCEDURE p_upd_relation_gar_cntrt (
      i_numgar        IN   gar_cntrt.numgar%TYPE,
      i_numfor        IN   gar_cntrt.numfor%TYPE,
      i_type          IN   gar_cntrt.TYPE%TYPE,
      i_old_datapli   IN   gar_cntrt.datapli%TYPE,
      i_new_datapli   IN   gar_cntrt.datapli%TYPE,
      i_flag          IN   VARCHAR2 DEFAULT NULL
   )
   IS
   BEGIN
--
      IF i_type = 2
      THEN                                          -- Concerne la Prevoyance
         --
         p_upd_garanties (i_cle            => i_numgar,
                          i_numfor         => i_numfor,
                          i_old_debut      => i_old_datapli,
                          i_new_debut      => i_new_datapli,
                          i_flag           => i_flag
                         );
         --
         p_upd_frml_dedu (i_numfor         => i_numfor,
                          i_old_debut      => i_old_datapli,
                          i_new_debut      => i_new_datapli,
                          i_flag           => i_flag
                         );
         --
         p_upd_frml_prest (i_numfor         => i_numfor,
                           i_old_debut      => i_old_datapli,
                           i_new_debut      => i_new_datapli,
                           i_flag           => i_flag
                          );
         --
         p_upd_frml_reval (i_numfor         => i_numfor,
                           i_old_debut      => i_old_datapli,
                           i_new_debut      => i_new_datapli,
                           i_flag           => i_flag
                          );
      --
      ELSIF i_type = 1
      THEN                                                -- Concerne la Sante
         --
         p_upd_formule (i_numfor         => i_numfor,
                        i_old_debut      => i_old_datapli,
                        i_new_debut      => i_new_datapli,
                        i_flag           => i_flag
                       );
         --
         p_upd_calcul (i_numfor           => i_numfor,
                       i_old_datapli      => i_old_datapli,
                       i_new_datapli      => i_new_datapli,
                       i_flag             => i_flag
                      );
         --
         p_upd_carence (i_numfor           => i_numfor,
                        i_old_datapli      => i_old_datapli,
                        i_new_datapli      => i_new_datapli,
                        i_flag             => i_flag
                       );
         --
         p_upd_cond_adhesion_gar (i_numfor         => i_numfor,
                                  i_old_debut      => i_old_datapli,
                                  i_new_debut      => i_new_datapli,
                                  i_flag           => i_flag
                                 );
         --
         p_upd_franact (i_numfor           => i_numfor,
                        i_old_datapli      => i_old_datapli,
                        i_new_datapli      => i_new_datapli,
                        i_flag             => i_flag
                       );
         --
         p_upd_franfor (i_numfor           => i_numfor,
                        i_old_datapli      => i_old_datapli,
                        i_new_datapli      => i_new_datapli,
                        i_flag             => i_flag
                       );
         --
         p_upd_maxact (i_numfor           => i_numfor,
                       i_old_datapli      => i_old_datapli,
                       i_new_datapli      => i_new_datapli,
                       i_flag             => i_flag
                      );
         --
         p_upd_maxfor (i_numfor           => i_numfor,
                       i_old_datapli      => i_old_datapli,
                       i_new_datapli      => i_new_datapli,
                       i_flag             => i_flag
                      );
         --
         p_upd_defrub (i_numfor           => i_numfor,
                       i_old_datapli      => i_old_datapli,
                       i_new_datapli      => i_new_datapli,
                       i_flag             => i_flag
                      );
      --
      END IF;

--
      p_upd_frml_prime_simple (i_numfor         => i_numfor,
                               i_old_debut      => i_old_datapli,
                               i_new_debut      => i_new_datapli,
                               i_flag           => i_flag
                              );
--
      p_upd_frml_tfc (i_numfor         => i_numfor,
                      i_old_debut      => i_old_datapli,
                      i_new_debut      => i_new_datapli,
                      i_flag           => i_flag
                     );
--
   END;

--

/* SCR : 20100210, recherche des informations complémentaires d'un contrat */
--
  FUNCTION f_contrat_info_compl (
      i_numgar        IN   contrat_compl.numgar%TYPE,
      i_numgar_ref    IN   contrat_compl.numgar_ref%TYPE,
      i_num_col       IN   NUMBER
  ) RETURN VARCHAR2
  IS

   vINFO  VARCHAR2(30) := NULL;

   vINFO1 VARCHAR2(30) := NULL;
   vINFO2 VARCHAR2(30) := NULL;
   vINFO3 VARCHAR2(30) := NULL;
   vINFO4 VARCHAR2(30) := NULL;
   vINFO5 VARCHAR2(30) := NULL;

   BEGIN

      SELECT cc.INFO1, cc.INFO2, cc.INFO3, cc.INFO4, cc.INFO5
        INTO vINFO1,vINFO2,vINFO3,vINFO4,vINFO5
        FROM CONTRAT_COMPL cc
       WHERE cc.numgar_ref = i_numgar_ref
         AND cc.numgar     = i_numgar;

      CASE i_num_col
         WHEN 1 THEN vINFO :=vINFO1;
         WHEN 2 THEN vINFO :=vINFO2;
         WHEN 3 THEN vINFO :=vINFO3;
         WHEN 4 THEN vINFO :=vINFO4;
         WHEN 5 THEN vINFO :=vINFO5;
      ELSE
         vINFO := NULL;
      END CASE;

      RETURN vINFO;

   EXCEPTION
      WHEN OTHERS THEN
         vINFO := NULL;
         RETURN vINFO;
   END f_contrat_info_compl;

-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--
   PROCEDURE p_upd_apporteur (
      i_cle          IN   apporteur.cle%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE apporteur
         SET debut = i_new_dateff
       WHERE etendue = 2
         AND cle = i_cle
         AND (   (TRUNC (debut) = i_old_dateff AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_cond_adhesion (
      i_cle          IN   cond_adhesion.cle%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE cond_adhesion
         SET debut = i_new_dateff
       WHERE etendue = 2
         AND cle = i_cle
         AND (   (TRUNC (debut) = i_old_dateff AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_cond_proposition (
      i_cle          IN   cond_proposition.cle%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE cond_proposition
         SET debut = i_new_dateff
       WHERE etendue = 2
         AND cle = i_cle
         AND (   (TRUNC (debut) = i_old_dateff AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_grp_gar (
      i_clef         IN   grp_gar.clef%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE grp_gar
         SET datapli = i_new_dateff
       WHERE etendue = 2
         AND clef = i_clef
         AND (   (TRUNC (datapli) = i_old_dateff AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_val_variable (
      i_clef         IN   val_variable.clef%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE val_variable
         SET debut = i_new_dateff
       WHERE etendue = 2
         AND clef = i_clef
         AND statique = 'O'
         AND (   (TRUNC (debut) = i_old_dateff AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_param_devise (
      i_numgar       IN   param_devise.numgar%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE param_devise
         SET debut = i_new_dateff
       WHERE numgar = i_numgar
         AND (   (TRUNC (debut) = i_old_dateff AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_gar_cntrt (
      i_numgar       IN   gar_cntrt.numgar%TYPE,
      i_old_dateff   IN   contrat.dateff%TYPE,
      i_new_dateff   IN   contrat.dateff%TYPE,
      i_flag         IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE gar_cntrt
         SET datapli = i_new_dateff
       WHERE numgar = i_numgar
         AND (   (TRUNC (datapli) = i_old_dateff AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
--
   PROCEDURE p_upd_garanties (
      i_cle         IN   garanties.cle%TYPE,
      i_numfor      IN   garanties.numfor%TYPE,
      i_old_debut   IN   garanties.debut%TYPE,
      i_new_debut   IN   garanties.debut%TYPE,
      i_flag        IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE garanties
         SET debut = i_new_debut
       WHERE cle = i_cle
         AND numfor = i_numfor
         AND etendue = 2
         AND (   (TRUNC (debut) = i_old_debut AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_frml_dedu (
      i_numfor      IN   frml_dedu.numfor%TYPE,
      i_old_debut   IN   frml_dedu.debut%TYPE,
      i_new_debut   IN   frml_dedu.debut%TYPE,
      i_flag        IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE frml_dedu
         SET debut = i_new_debut
       WHERE numfor = i_numfor
         AND (   (TRUNC (debut) = i_old_debut AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_frml_prest (
      i_numfor      IN   frml_prest.numfor%TYPE,
      i_old_debut   IN   frml_prest.debut%TYPE,
      i_new_debut   IN   frml_prest.debut%TYPE,
      i_flag        IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE frml_prest
         SET debut = i_new_debut
       WHERE numfor = i_numfor
         AND (   (TRUNC (debut) = i_old_debut AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_frml_reval (
      i_numfor      IN   frml_reval.numfor%TYPE,
      i_old_debut   IN   frml_reval.debut%TYPE,
      i_new_debut   IN   frml_reval.debut%TYPE,
      i_flag        IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE frml_reval
         SET debut = i_new_debut
       WHERE numfor = i_numfor
         AND (   (TRUNC (debut) = i_old_debut AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_formule (
      i_numfor      IN   formule.numfor%TYPE,
      i_old_debut   IN   formule.debut%TYPE,
      i_new_debut   IN   formule.debut%TYPE,
      i_flag        IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE formule
         SET debut = i_new_debut
       WHERE numfor = i_numfor
         AND (   (TRUNC (debut) = i_old_debut AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_calcul (
      i_numfor        IN   calcul.numfor%TYPE,
      i_old_datapli   IN   calcul.datapli%TYPE,
      i_new_datapli   IN   calcul.datapli%TYPE,
      i_flag          IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE calcul
         SET datapli = i_new_datapli
       WHERE numfor = i_numfor
         AND (   (TRUNC (datapli) = i_old_datapli AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_carence (
      i_numfor        IN   carence.numfor%TYPE,
      i_old_datapli   IN   carence.datapli%TYPE,
      i_new_datapli   IN   carence.datapli%TYPE,
      i_flag          IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE carence
         SET datapli = i_new_datapli
       WHERE numfor = i_numfor
         AND (   (TRUNC (datapli) = i_old_datapli AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_cond_adhesion_gar (
      i_numfor      IN   cond_adhesion_gar.numfor%TYPE,
      i_old_debut   IN   cond_adhesion_gar.debut%TYPE,
      i_new_debut   IN   cond_adhesion_gar.debut%TYPE,
      i_flag        IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE cond_adhesion_gar
         SET debut = i_new_debut
       WHERE numfor = i_numfor
         AND (   (TRUNC (debut) = i_old_debut AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_franact (
      i_numfor        IN   franact.numfor%TYPE,
      i_old_datapli   IN   franact.datapli%TYPE,
      i_new_datapli   IN   franact.datapli%TYPE,
      i_flag          IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE franact
         SET datapli = i_new_datapli
       WHERE numfor = i_numfor
         AND (   (TRUNC (datapli) = i_old_datapli AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_franfor (
      i_numfor        IN   franfor.numfor%TYPE,
      i_old_datapli   IN   franfor.datapli%TYPE,
      i_new_datapli   IN   franfor.datapli%TYPE,
      i_flag          IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE franfor
         SET datapli = i_new_datapli
       WHERE numfor = i_numfor
         AND (   (TRUNC (datapli) = i_old_datapli AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_maxact (
      i_numfor        IN   maxact.numfor%TYPE,
      i_old_datapli   IN   maxact.datapli%TYPE,
      i_new_datapli   IN   maxact.datapli%TYPE,
      i_flag          IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE maxact
         SET datapli = i_new_datapli
       WHERE numfor = i_numfor
         AND (   (TRUNC (datapli) = i_old_datapli AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_maxfor (
      i_numfor        IN   maxfor.numfor%TYPE,
      i_old_datapli   IN   maxfor.datapli%TYPE,
      i_new_datapli   IN   maxfor.datapli%TYPE,
      i_flag          IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE maxfor
         SET datapli = i_new_datapli
       WHERE numfor = i_numfor
         AND (   (TRUNC (datapli) = i_old_datapli AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_defrub (
      i_numfor        IN   defrub.numfor%TYPE,
      i_old_datapli   IN   defrub.datapli%TYPE,
      i_new_datapli   IN   defrub.datapli%TYPE,
      i_flag          IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE defrub
         SET datapli = i_new_datapli
       WHERE numfor = i_numfor
         AND (   (TRUNC (datapli) = i_old_datapli AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_frml_prime_simple (
      i_numfor      IN   frml_prime_simple.numfor%TYPE,
      i_old_debut   IN   frml_prime_simple.debut%TYPE,
      i_new_debut   IN   frml_prime_simple.debut%TYPE,
      i_flag        IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE frml_prime_simple
         SET debut = i_new_debut
       WHERE numfor = i_numfor
         AND (   (TRUNC (debut) = i_old_debut AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;

--
   PROCEDURE p_upd_frml_tfc (
      i_numfor      IN   frml_tfc.numfor%TYPE,
      i_old_debut   IN   frml_tfc.debut%TYPE,
      i_new_debut   IN   frml_tfc.debut%TYPE,
      i_flag        IN   VARCHAR2
   )
   IS
   BEGIN
      UPDATE frml_tfc
         SET debut = i_new_debut
       WHERE numfor = i_numfor
         AND (   (TRUNC (debut) = i_old_debut AND i_flag IS NULL)
              OR (i_flag IS NOT NULL)
             );
   END;
--
-- ------------------------------------ Fin des corps des procedures privees --
END;
/
