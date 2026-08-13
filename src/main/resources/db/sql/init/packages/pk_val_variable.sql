CREATE OR REPLACE package ARTHUS.pk_val_variable as
-- -- CONSTANTES PUBLIQUE -----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des constantes publiques --
-- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des exceptions publiques --
-- -- TYPES PUBLIQUES ---------------------------------------------------------
type t_libelle is table of varchar2(45) index by binary_integer;
Type t_valeur Is Table of Number Index by Binary_integer;
Type t_typ_date Is Table of Boolean Index by Binary_integer;
-- ------------------------------------------------- Fin des types publiques --
-- -- VARIABLES PUBLIQUES -----------------------------------------------------
T_Type_fonc		t_libelle;
-- --------------------------------------------- Fin des variables publiques --
-- -- PROCEDURES PUBLIQUES ----------------------------------------------------
--@pub
--
-- Recuperation des infos val_variable
--
Procedure P_SEL_def_variable (
	       I_chaine	      	IN 	Varchar2,
	       O_idvariable    	OUT 	Number,
	       O_etendue    	OUT 	Number,
	       O_formule	OUT	BOOLEAN,
	       O_type_date	OUT	Boolean,
	       I_session      	IN 	Number
	       );
--
-- Gestion des messages d'erreur de calcul
--
Procedure P_GEST_err_calc (
		I_idfonction	IN mess_err_calc.idfonction%Type,
		I_code_msg	IN mess_err_calc.code_msg%Type,
		I_liste_param	IN Varchar2	Default Null,
		I_code_pays	IN mess_err_calc.code_pays%Type Default Null,
		I_proc	IN	Varchar2 	Default Null,
		I_idligne	IN	Number	Default Null,
		O_idligne	OUT	Number
		);
--
-- -------------------------------------------- Fin des procedures publiques --
END pk_val_variable;
/

CREATE OR REPLACE package body ARTHUS.pk_val_variable as
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
G_idformule  	Def_formule.idformule%Type;
G_idvariable  	Def_variable.idvariable%Type	Default Null;
G_contexte  	Number	 	default 1;
G_calcul       	Boolean		Default FALSE;
G_tableau      	Boolean	 	Default FALSE;
G_valeur	Number := 0;
G_val_droite	Number := 0;
G_val_gauche	Number := 0;
G_date		Boolean 	Default FALSE;
G_gauche	Varchar2(100);
G_droite	Varchar2(100);
G_recherche	Varchar2(100);
G_L_valeur	Varchar2(100);
G_resultat	boolean := FALSE;
--
-- Variables de P_INS_journal
--
G_nom_traitement    Constant journal_adm.nom_traitement%Type default 'pk_calcul';
G_msg_adm	Varchar2(250);
G_session	journal_adm.id_session%Type default 1;
G_flag_test	Number;
G_code_msg	mess_erreur.code_msg%TYPE := 1;
G_niv_msg	journal_adm.niv_msg%TYPE := 1;
G_max_msg	journal_adm.niv_msg%TYPE := 1;
G_idligne	journal_adm.idligne%TYPE := 0;
G_liste_param	Varchar2(250) := Null;
G_idfonction	mess_err_calc.idfonction%Type;
G_proc		Varchar2(80);
G_pays		Number Default pk_devise.pays_ref;
G_type_msg	Number;
--
-- G_niv_msg prend les Valeurs :
--	0 --> Message d'erreurs (Erreur ORACLE)
--	1 --> Message informatif(tout se passe bien)
--	2 et + Niveau de detail
-- -------------------------------------- Fin des variables globales privees --
-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--@priv
-- Recuperation des infos val_variable
--
Procedure P_SEL_idvariable (
		I_chaine	IN 	Varchar2,
		O_idvariable	OUT	Number,
		O_etendue    	OUT 	Number,
	       	O_formule	OUT	BOOLEAN,
	       	O_type_date	OUT	Boolean,
		I_session	IN	Number
		);
-- Insertion dans journal_adm
--
Procedure P_INS_journal;
--
-- Gestion du log
--
Procedure P_trace;
--
-- ----------------------------- Fin des declarations des procedures privees --
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--@corpub
--
-- Recuperation des infos def_variable
--
Procedure P_SEL_def_variable (
	       I_chaine	      	IN 	Varchar2,
	       O_idvariable    	OUT 	Number,
	       O_etendue    	OUT 	Number,
	       O_formule	OUT	BOOLEAN,
	       O_type_date	OUT	Boolean,
	       I_session	IN	Number
	       )
IS
L_idvariable    Number;
L_etendue	Number;
L_formule	BOOLEAN     	DEFAULT FALSE;
L_type_date	Boolean		Default FALSE;
BEGIN
P_SEL_idvariable (
	I_chaine	=>	I_chaine,
	O_idvariable    => 	L_idvariable,
	O_etendue    	=> 	L_etendue,
	O_formule	=>	L_formule,
	O_type_date	=>	L_type_date,
	I_session	=>	I_session
       );
END P_SEL_def_variable;
--
-- Gestion des messages d'erreur de calcul
--
Procedure P_GEST_err_calc (
	I_idfonction	IN 	mess_err_calc.idfonction%Type,
	I_code_msg	IN 	mess_err_calc.code_msg%Type,
	I_liste_param	IN 	Varchar2	Default Null,
	I_code_pays	IN 	mess_err_calc.code_pays%Type Default Null,
	I_proc		IN	Varchar2 	Default Null,
	I_idligne	IN	Number	Default Null,
	O_idligne	OUT 	Number
	)
IS
L_proc		Varchar2(45) := I_proc;
L_code_pays	mess_err_calc.code_pays%Type := I_code_pays;
L_liste_param	varchar2(128) := I_liste_param;
L_type_msg	mess_err_calc.type_msg%Type;
BEGIN
--
If ( L_code_pays Is Null ) then
	L_code_pays := G_pays;
End if;
--
pk_trace.P_SEL_mess_err_calc (
	I_idfonction	=> I_idfonction,
	I_code_msg	=> I_code_msg,
	I_code_pays	=> L_code_pays,
	I_liste_param	=> L_liste_param,
	O_type_msg	=> L_type_msg,
	O_lib_msg	=> G_msg_adm
	);
--
G_niv_msg := L_type_msg;
--
If ( L_proc Is Not Null ) then
	G_msg_adm := I_proc||' : '||G_msg_adm;
End if;
--
If ( I_idligne Is Not Null ) then
	G_idligne := I_idligne;
End If;
--
P_INS_journal;
O_idligne := G_idligne;
--
END P_GEST_err_calc;
--
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--@corpriv
-- Recuperation des infos def_variable
--
Procedure P_SEL_idvariable (
		I_chaine	IN 	Varchar2,
		O_idvariable	OUT	Number,
		O_etendue    	OUT 	Number,
	       	O_formule	OUT	BOOLEAN,
	       	O_type_date	OUT	Boolean,
		I_session	IN	Number
		)
IS
Cursor C_variable IS
	Select	idvariable,
		etendue,
		type
	From	def_variable
	Where	nom_variable = I_chaine;
Cursor C_histo	(P_idvariable IN def_variable.idvariable%Type) IS
	Select	idformule
	From	Histo_frmlvar
	Where 	idvariable = P_idvariable
	and	valide = 'O'
	and	Sysdate between debut and nvl(fin, debut);
Rec_C_variable C_variable%Rowtype;
Rec_C_histo C_histo%Rowtype;
BEGIN
Open C_variable;
Fetch C_variable into Rec_C_variable;
--
O_idvariable := Rec_C_variable.idvariable;
O_etendue := Rec_C_variable.etendue;
If (Rec_c_variable.type = 'N') then
	O_type_date :=  FALSE;
Else
	O_type_date := TRUE;
End if;
O_idvariable := Rec_C_variable.idvariable;
--
Close C_variable;
--
Open C_histo( O_idvariable );
Fetch C_histo Into Rec_C_histo;
If C_histo%Found then
	O_formule:= TRUE;
Else
	O_formule:= FALSE;
End if;
Null;
END P_SEL_idvariable;
--
--
-- Insertion dans journal_adm
--
Procedure P_INS_journal
IS
L_idligne 	Number;
BEGIN
--
If ( G_niv_msg <= G_max_msg ) then
	--
	G_idligne := G_idligne + 1;
	If ( G_niv_msg = 0 ) then
		L_idligne := -1 * G_idligne;
	Else
		L_idligne := G_idligne;
	End If;
	--
	PK_trace.P_INS_journal_adm (
		I_nom_traitement => G_nom_traitement,
		I_session        => G_session,
		I_niv_msg        => G_niv_msg,
		I_msg_adm        => Substr(G_msg_adm, 1, 132),
		I_idligne        => L_idligne);
	--
End If;
Commit;
END P_INS_journal;
--
-- Gestion du log
--
Procedure P_trace
IS
BEGIN
P_GEST_err_calc (
	I_idfonction	=> G_idfonction,
	I_code_msg	=> G_code_msg,
	I_liste_param	=> G_liste_param,
	O_idligne	=> G_idligne
	);
END P_trace;
--
-- ------------------------------------ Fin des corps des procedures privees --
END pk_val_variable;
/
