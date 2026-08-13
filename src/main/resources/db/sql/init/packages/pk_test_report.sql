CREATE OR REPLACE PACKAGE ARTHUS.pk_test_report AS
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
  PROCEDURE P_SEL_indvs
   ( I_numindiv       IN  indvs.numindiv%TYPE,
     O_nom            OUT indvs.nom%TYPE,
     O_prenom         OUT indvs.prenom%TYPE);
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_test_report AS
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
-- Aucune
-- ----------------------------- Fin des declarations des procedures privees --
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
  PROCEDURE P_SEL_indvs
   ( I_numindiv       IN  indvs.numindiv%TYPE,
     O_nom            OUT indvs.nom%TYPE,
     O_prenom         OUT indvs.prenom%TYPE)
IS
  CURSOR C_indvs IS
         select nom,
                prenom
         From   indvs
         Where  numindiv = I_numindiv;
--
Rec_c_indvs C_indvs%ROWTYPE;
--
BEGIN
  OPEN  C_indvs;
  FETCH C_indvs INTO Rec_c_indvs;
  CLOSE C_indvs;
  O_nom := Rec_c_indvs.nom;
  O_prenom := Rec_c_indvs.prenom;
END;
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --
END;
/
