CREATE OR REPLACE PACKAGE ARTHUS.pk_contexte AS
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
--@pub
--
-- Chargement des donnees contextuelles
--
Procedure P_CHRG_contexte (
			I_variable	IN 	Varchar2,
			I_valeur	IN	Number
			);
Procedure P_CHRG_contexte (
			I_variable	IN 	Varchar2,
			I_date	IN	Date
			);
--
-- Restitution des variables systeme
--
Procedure P_SEL_contexte (
			I_variable	IN	Varchar2,
			O_valeur	OUT	Number,
			O_found		OUT	Boolean
			);
Procedure P_SEL_contexte (
			I_variable	IN	Varchar2,
			O_date		OUT	Date,
			O_FOUND		OUT	Boolean
			);
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_contexte AS
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
G_datesurv	Date;
G_debut		Date;
G_echeance	Date;
G_fract		Number;
G_found		Boolean;
-- -------------------------------------- Fin des variables globales privees --
-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
-- Aucune
-- ----------------------------- Fin des declarations des procedures privees --
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--@corpub
--
-- Chargement des donnees contextuelles (numeriques)
--
Procedure P_CHRG_contexte (
			I_variable	IN 	Varchar2,
			I_valeur	IN	Number
			)
IS
BEGIN
If ( I_variable = 'FRACT' ) then
	G_fract := I_valeur;
End if;
Null;
END P_CHRG_contexte;
--
-- Chargement des donnees contextuelles (Date)
--
Procedure P_CHRG_contexte (
			I_variable	IN 	Varchar2,
			I_date	IN	Date
			)
IS
BEGIN
If ( I_variable = 'DS' ) then
	G_datesurv := I_Date;
ElsIf ( I_variable = 'DEC' ) then
	G_echeance := I_Date;
End if;
END P_CHRG_contexte;
--
-- Restitution des variables systeme (numeriques)
--
Procedure P_SEL_contexte (
			I_variable	IN	Varchar2,
			O_valeur	OUT	Number,
			O_found		OUT	Boolean
			)
IS
BEGIN
O_found := FALSE;
If ( I_variable = 'FRACT' ) then
	O_valeur := G_fract;
End if;
--
If ( O_valeur Is Not Null ) then
	O_found := TRUE;
End if;
--
END P_SEL_contexte;
--
-- Restitution des variables systeme (Date)
--
Procedure P_SEL_contexte (
			I_variable	IN	Varchar2,
			O_Date		OUT	Date,
			O_found		OUT	Boolean
			)
IS
BEGIN
O_found := FALSE;
--
If ( I_variable = 'DS' ) then
	O_Date := G_datesurv;
ElsIf ( I_variable = 'DEC' ) then
	O_Date := G_echeance;
End if;
--
If ( O_date Is Not Null ) then
	O_found := TRUE;
End if;
--
END P_SEL_contexte;
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --
END;
/
