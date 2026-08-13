CREATE OR REPLACE PACKAGE ARTHUS.pk_compte_tiers AS
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
--
-- Retourne le mouvement d'origine compte_tiers d'une ligne compte_client
--
Function F_origine (
		I_codope	IN	compte_client.codope%Type,
		I_idaffec	IN	compte_client.idaffec%Type
		)
Return Number;
Pragma Restrict_References(F_origine, WNDS, WNPS);
--
-- Retourne le type d'operation d'une ligne compte_tiers
--
Function F_codope (
		I_idmvt		IN	compte_tiers.idmvt%Type,
    I_numcli  IN  compte_tiers.numcli%Type
		)
Return Number;
Pragma Restrict_References(F_codope, WNDS, WNPS);
--
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_compte_tiers AS
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
--
-- ----------------------------- Fin des declarations des procedures privees --
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--
-- Retourne le type d'operation d'une ligne compte_tiers
--
Function F_codope (
		I_idmvt		IN	compte_tiers.idmvt%Type,
    I_numcli  IN  compte_tiers.numcli%Type
		)
Return Number
IS
Cursor C_compte_tiers IS
	Select	codope
	From	compte_tiers
	Where	idmvt = I_idmvt
    And numcli = I_numcli;
L_codope	compte_tiers.codope%Type;
BEGIN
Open C_compte_tiers;
Fetch C_compte_tiers Into L_codope;
Close C_compte_tiers;
--
Return ( L_codope );
--
END F_codope;
--
-- Retourne le mouvement d'origine compte_tiers d'une ligne compte_client
--
Function F_origine (
		I_codope	IN	compte_client.codope%Type,
		I_idaffec	IN	compte_client.idaffec%Type
		)
Return Number
IS
Cursor C_compte_tiers IS
	Select	idmvt
	From	compte_tiers
	Where	codope = I_codope
	and	cle = I_idaffec;
Cursor C_origine ( P_idmvt IN compte_tiers.idmvt%Type ) IS
	Select	idmvt
	From	compensation
	Where	idcomp = P_idmvt;
L_idmvt		compte_tiers.idmvt%Type;
BEGIN
Open C_compte_tiers;
Fetch C_compte_tiers Into L_idmvt;
If ( C_compte_tiers%Found ) then
	Open C_origine ( L_idmvt );
	Fetch C_origine Into L_idmvt;
	If ( C_origine%NotFound ) then
		L_idmvt := 0;
	End if;
	Close C_origine;
Else
	L_idmvt := 0;
End if;
Close C_compte_tiers;
--
Return( L_idmvt );
--
End F_origine;
--
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --
END;
/
