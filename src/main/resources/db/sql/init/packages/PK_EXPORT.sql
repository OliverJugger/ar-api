CREATE OR REPLACE PACKAGE ARTHUS.PK_EXPORT AS

--
-- Chaine de reconnaissance SCCS
-- %W%	%E%

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
enr_param_dmnde param_dmnde%ROWTYPE;
Procedure P_RECUP (p_numedit Varchar2);
-- -------------------------------------------- Fin des procedures publiques --

End PK_EXPORT;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_EXPORT AS

-- Chaine de reconnaissance SCCS
-- %W%	%E%

-- -- CONSTANTES PRIVEES ------------------------------------------------------
--

-- ---------------------------------------------- Fin des constantes privees --

-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
--
-- ---------------------------------------------- Fin des exceptions privees --

-- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --

-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
--

Procedure P_RECUP (p_numedit Varchar2) IS
Cursor c_param_dmnde (p_numdmnde Varchar2) Is
	select	*
	from	param_dmnde
	where	param_dmnde.numdmnde = p_numdmnde
;
Cursor c_param_batch (p_numbatch Varchar2) Is
	select	*
	from	param_batch
	where	param_batch.numbatch = p_numbatch
;
enr_param_batch param_batch%ROWTYPE;
Cursor c_file_edition (p_numedit Varchar2) Is
	SELECT	file_edition.impid	impid,
		file_edition.papid	papid,
		file_edition.numdmnde	numdmnde,
		file_batch.batchid	numbatch,
		file_edition.editid	ent_editid,
		file_edition.condense	flag_condense,
		typ_edition.nb_char	ent_nb_char,
		decode(typ_edition.nb_pdg, 0, '', typ_edition.nb_pdg)	ent_nb_pdg,
		to_char(file_edition.date_demande,'DD/MM/YYYY')		ent_date_dmnde,
		nvl(lib_edition.editlib,typ_edition.editlib)		edit_lib,
		file_edition.userid	file_userid,
		file_edition.numedit	numedit
	FROM	file_edition,
		typ_edition,
		lib_edition,
		file_batch
	WHERE	file_edition.numedit = p_numedit
	AND	file_batch.numbatch  = file_edition.numbatch
	AND	lib_edition.numedit (+) = file_edition.numedit
	AND	typ_edition.batchid = file_batch.batchid
;
enr_file_edition c_file_edition%ROWTYPE;
Begin
   enr_param_dmnde := null;

   OPEN c_file_edition(p_numedit);
   FETCH c_file_edition INTO enr_file_edition;
   CLOSE c_file_edition;
   OPEN c_param_batch(enr_file_edition.numbatch);
   FETCH c_param_batch INTO enr_param_batch;
   CLOSE c_param_batch;
   If enr_file_edition.numdmnde is not null then
	OPEN c_param_dmnde(enr_file_edition.numdmnde);
	FETCH c_param_dmnde INTO enr_param_dmnde;
	CLOSE c_param_dmnde;
   End if;
End;
End PK_EXPORT;
/
