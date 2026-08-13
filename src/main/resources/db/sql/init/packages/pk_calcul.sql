CREATE OR REPLACE package ARTHUS.pk_calcul as
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
-- Valorisation d'une formule
--
Function F_valorise (
	       I_idformule	IN Def_formule.idformule%Type,
	       I_chaine	      	IN Varchar2,
	       I_contexte     	IN Number,
	       I_calcul	      	IN BOOLEAN     DEFAULT TRUE,
	       I_session      	IN Number	     Default 1,
	       I_max_msg      	IN Number	     Default 1
	       )
Return Number;
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
END pk_calcul;
/

CREATE OR REPLACE package body ARTHUS.pk_calcul as
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
-- Decomposition et analyse d'une chaine de caractere
--
Procedure P_analyse (
		I_idformule	IN	Def_formule.idformule%Type,
		I_chaine	IN 	Varchar2
		);
--
-- Analyse des arguments d'une fonction
--
Procedure P_eval_fonction(
			I_fonction 	IN varchar2,
			I_chaine	IN Varchar2,
			I_nbarg 	IN Binary_integer,
			O_valeur	OUT Number
			);
--
-- Evaluation d'un operateur
--
Procedure P_eval_operateur (
			I_chaine	IN	Varchar2,
			O_valeur	OUT	Number
			);
--
-- Retourne le nombre d'arguments d'une fonction
--
Function is_a_fonction(
		I_chaine 	IN varchar2 ,
		I_type 		IN Binary_integer
		)
RETURN 	Binary_integer;
--
-- Recherche du type de donnee
--
Procedure P_SEL_rep_fonction (
		I_chaine	IN	Varchar2,
		O_type		OUT	Number,
		O_libelle	OUT	Varchar2,
		O_nbarg		OUT	Number,
		O_idfonction	OUT	Number,
		O_date		OUT	Boolean,
		O_found		OUT	Boolean
		);
--
-- Evaluation d'une chaine simple
--
Function F_evalue (
		I_chaine 	IN Varchar2
		)
Return Number;
--
--
Procedure P_CHRG_Type_fonc;
--
-- Stockage des idvariable dans frmlvar_detail
--
Procedure P_INS_frmlvar_detail (
		I_chaine	IN 	Varchar2,
		I_session	IN	Varchar2
		);
--
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
-- Valorisation d'une formule
--
Function F_valorise (
		I_idformule	IN   def_formule.idformule%Type,
		I_chaine      IN   Varchar2,
		I_contexte    IN   Number,
		I_calcul      IN   Boolean   Default TRUE,
		I_session     IN   Number    Default 1,
		I_max_msg     IN   Number    Default 1
		)
Return Number
IS
L_fonction	Varchar2(100);
BEGIN
G_proc := 'F_valorise';
--
G_contexte := I_contexte;
G_calcul  := I_calcul;
G_session := I_session;
G_max_msg := I_max_msg;
--
-- Chargement tableau type de variables
--
G_niv_msg := 1;
G_msg_adm := 'Formule à évaluer : '|| I_chaine;
P_INS_journal;
--
Begin
L_fonction := T_type_fonc(1);
Exception When No_Data_Found then
	P_CHRG_Type_fonc;
End;
--
Delete frmlvar_detail
Where	idformule = I_idformule;
--
P_analyse(
	I_idformule	=> 	I_idformule,
	I_chaine	=> 	I_chaine
	);
--
Return( G_valeur );
END F_valorise;
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
-- Decomposition et analyse d'une chaine de caractere
--
Procedure P_analyse (
		I_idformule	IN	Def_formule.idformule%Type,
		I_chaine	IN Varchar2
		)
IS
G_idformule	Def_formule.idformule%type 	:= I_idformule;
L_variable	varchar2(100);
L_fonction	varchar2(100);
L_argument	Varchar2(100);
L_gauche	varchar2(100);
L_droite	varchar2(100);
L_chaine	Varchar2(100);
L_char		varchar2(1);
L_separateur	varchar2(1);
i 		Binary_integer := 0;
nbarg		Binary_integer := 0;
par_ouverte 	Binary_integer := 0;
par_fermee 	Binary_integer := 0;
L_found		Boolean;
L_type_fonction	Number;
L_lib_variable	Varchar2(100);
L_valeur		Number;
BEGIN
G_proc := 'P_analyse';
--
If (G_resultat) then
	L_chaine := Replace(I_chaine, G_recherche, G_L_valeur);
	G_resultat := FALSE;
Else
	L_chaine := I_chaine;
End if;
--
G_niv_msg := 2;
G_idfonction := 0;
G_code_msg := 3;
G_liste_param := L_chaine;
P_trace;
--
-- Detection d'une fonction
If ( (substr(L_chaine, 1, 1) != '(') and (instr(L_chaine, '(') > 0) ) then
	L_fonction := substr(L_chaine, 1, instr(L_chaine,'(')-1);
	L_argument := substr(L_chaine, instr(L_chaine,'('), length(L_chaine));
	nbarg := is_a_fonction(L_fonction, 1);
	--
	G_niv_msg := 3;
	G_idfonction := 0;
	G_code_msg := 4;
	G_liste_param := L_fonction ||'|'||to_char(nbarg);
	P_trace;
	--
	P_eval_fonction(
		I_fonction	=> L_fonction,
		I_chaine	=> L_argument,
		I_nbarg		=> nbarg,
		O_valeur	=> L_valeur
		);
	If ( L_chaine = G_gauche ) then
		G_val_gauche := L_valeur;
	Elsif ( L_chaine = G_droite ) then
		G_val_droite := L_valeur;
	End if;
Else
	G_val_droite := 0;
	G_val_gauche := 0;
	P_eval_operateur (
		I_chaine	=> L_chaine,
		O_valeur	=> L_valeur
		);
End If;
--
If (par_ouverte = 0) then
		--
		G_niv_msg := 2;
		G_msg_adm := 'Chaine '||I_chaine
				||' Résultat : '||to_char(L_valeur);
		P_INS_journal;
		G_recherche := I_chaine;
		G_resultat := TRUE;
		G_L_valeur := L_valeur;
		--
End if;
--
G_valeur := G_valeur + L_valeur;
--
END P_analyse ;
--
-- Evaluation d'un operateur
--
Procedure P_eval_operateur (
			I_chaine	IN	Varchar2,
			O_valeur	OUT	Number
			)
IS
L_gauche	varchar2(100);
L_droite	varchar2(100);
L_char		varchar2(1);
L_operateur	Varchar2(1);
i 		Binary_integer := 0;
par_ouverte 	Binary_integer := 0;
par_fermee 	Binary_integer := 0;
L_val_gauche	Number;
L_val_droite	Number;
L_valeur	Number;
BEGIN
for i in 1 .. length(I_chaine)
Loop
	L_char := substr(I_chaine,i,1);
	--
	If ( L_char = '(' ) then
		par_ouverte := par_ouverte + 1;
	Elsif ( L_char = ')' ) then
		par_fermee := par_fermee + 1;
	Elsif ( instr('&|<>=*/#-+', L_char) > 0 ) then
		L_operateur := L_char;
		If ( (par_ouverte - par_fermee) = 1 ) then
			L_gauche := substr(I_chaine, 2, i-2);
			G_gauche := L_gauche;
			L_droite := substr(I_chaine, i+1, length(I_chaine)-i-1);
			G_droite := L_droite;
			--
			G_niv_msg := 2;
			G_msg_adm := 'Operande gauche = '||L_gauche;
			P_INS_journal;
			G_msg_adm := 'Operateur = '||L_operateur;
			P_INS_journal;
			G_msg_adm := 'Operande droite = '||L_droite;
			P_INS_journal;
			--
			L_val_gauche := F_evalue(L_gauche);
			L_val_droite := F_evalue(L_droite);
			If ( L_val_gauche Is Not Null ) then
				G_val_gauche := L_val_gauche;
			End If;
			If ( L_val_droite Is Not Null ) then
				G_val_droite := L_val_droite;
			End If;
			--
			If ( L_operateur = '/' ) then
				L_valeur := Nvl(L_val_gauche, G_val_gauche) / Nvl(L_val_droite, G_val_droite);
			ElsIf ( L_operateur = '*' ) then
				L_valeur := Nvl(L_val_gauche, G_val_gauche) * Nvl(L_val_droite, G_val_droite);
			End if;
			--
			G_niv_msg := 2;
			G_msg_adm := 'Résultat : '||Nvl(L_val_gauche, G_val_gauche)||' '||L_operateur
					||' '||Nvl(L_val_droite, G_val_droite) ||' : '||to_char(L_valeur);
			P_INS_journal;
			--
			Exit;
		End if;
	End if;
End loop;
--
O_valeur := L_valeur;
END P_eval_operateur;
--
-- Analyse des arguments d'une fonction
--
Procedure P_eval_fonction(
			I_fonction 	IN varchar2,
			I_chaine 	IN varchar2,
			I_nbarg 	IN Binary_integer,
			O_valeur	OUT Number
			)
IS
type t_argument is table of varchar2(100) index by Binary_integer;
L_chaine		varchar2(100);
L_char		varchar2(1);
i 		Binary_integer := 0;
par_ouverte 	Binary_integer := 0;
par_fermee 	Binary_integer := 0;
arg_courant 	Binary_integer := I_nbarg;
T_arg 		t_argument;
T_val_arg	pk_fonction.t_valeur;
T_date		pk_fonction.t_typ_date;
L_valeur	Number;
L_found		Boolean;
L_type_fonction	Number;
L_lib_variable	Varchar2(100);
L_nbarg		Number;
BEGIN
--
G_niv_msg := 2;
G_msg_adm := 'Evaluation de la fonction '||I_fonction
	||' Argument '||I_chaine;
P_INS_journal;
--
P_SEL_rep_fonction (
	I_chaine	=> I_fonction,
	O_type		=> L_type_fonction,
	O_libelle	=> L_lib_variable,
	O_nbarg		=> L_nbarg,
	O_idfonction	=> G_idfonction,
	O_date		=> G_date,
	O_found		=> L_found
	);
--
G_niv_msg := 2;
G_msg_adm := T_type_fonc(L_type_fonction)
		|| ' : ' || L_lib_variable;
P_INS_journal;
--
L_chaine := substr(I_chaine, 2, length(I_chaine)-2);
for i in reverse 1 .. length(I_chaine)
loop
L_char := substr(I_chaine,i,1);
if ( L_char = '(' ) then
	par_ouverte := par_ouverte + 1;
elsif ( L_char = ')' ) then
	par_fermee := par_fermee + 1;
elsif ( L_char = ',' ) then
	if ( ((par_fermee - par_ouverte) = 1) and arg_courant > 1 ) then
		T_arg(arg_courant) := substr(L_chaine, i, length(L_chaine)-1);
		--
		G_niv_msg := 3;
		G_msg_adm := 'Argument No '||to_char(arg_courant)||' : '
				||T_arg(arg_courant);
		P_INS_journal;
		--
	arg_courant := arg_courant - 1;
	L_chaine := substr(L_chaine, 1, i-2);
	end if;
end if;
end loop;
T_arg(arg_courant) := L_chaine;
--
For i in 1 .. I_nbarg loop
	--
	G_niv_msg := 2;
	G_msg_adm := 'Argument No '||to_char(i)||' / ' || to_char(I_nbarg)|| ' : '
			||T_arg(i);
	P_INS_journal;
	--
	G_niv_msg := 3;
	G_msg_adm := 'Evaluation de '||T_arg(i);
	P_INS_journal;
	--
	If ( I_fonction IN ('TAB', 'TAB2') and i = 1 ) then
		G_tableau := TRUE;
	Else
		G_tableau := FALSE;
	End if;
	--
	L_valeur := F_evalue (T_arg(i));
	If ( G_date ) then
		T_val_arg(i) := d2e( j2d((L_valeur)) );
	Else
		T_val_arg(i) := to_char(L_valeur);
	End if;
	T_date(i) := G_date;
	--
	G_niv_msg := 2;
	If ( G_date ) then
		G_msg_adm := 'Valeur argument No '||to_char(i)||' : '
				||d2e( j2d(L_valeur) );
	Else
		G_msg_adm := 'Valeur argument No '||to_char(i)||' : '
				||to_char(L_valeur);
	End If;
	P_INS_journal;
	--
End loop;
--
--
G_niv_msg := 3;
G_msg_adm := 'Appel a P_SEL_fonction '||I_fonction||'('
		||T_val_arg(1)||','
		||T_val_arg(2)||','
		||T_val_arg(3)||')';
P_INS_journal;
--
pk_fonction.P_SEL_fonction (
		I_fonction	=>	I_fonction,
		I_nbarg		=>	I_nbarg,
		T_val_arg	=>	T_val_arg,
		T_date		=>	T_date,
		I_typ_date	=>	G_date,
		I_session	=>	G_session,
		I_max_msg	=>	G_max_msg,
		I_idligne	=>	G_idligne,
		O_idligne	=>	G_idligne,
		O_valeur	=>	L_valeur
		);
--
O_valeur := L_valeur;
END P_eval_fonction;
--
-- Retourne le nombre d'arguments d'une fonction
--
Function is_a_fonction(
		I_chaine 	IN varchar2 ,
		I_type 		IN Binary_integer
		)
RETURN 	Binary_integer
IS
L_nbarg		Binary_integer := -1;
BEGIN
Select	min(nbarg)
Into	L_nbarg
From	v_rep_fonction
Where	nom_fonction = I_chaine
and	type = I_type
;
If ( L_nbarg is null ) then
	Return( -1 );
Else
	Return( L_nbarg );
End if;
END;
--
-- Evaluation d'une chaine simple
--
Function F_evalue (
		I_chaine 	IN Varchar2
		)
Return Number
IS
L_idformule	Def_variable.idformule%Type := G_idformule;
L_found		Boolean;
L_type_fonction	Number;
L_lib_variable	Varchar2(100);
L_retour 	Number;
L_date		Date;
L_nbarg		Number;
L_type_date	Varchar2(20);
BEGIN
G_niv_msg := 3;
G_msg_adm := 'Longueur Chaine en entree : '||to_char(length(I_chaine))
		|| ' Longueur du translate '||to_char(length(Translate(I_chaine, '&|<>=*/#-+()', ' ')));
P_INS_journal;
--
If ( Translate(I_chaine, '&|<>=*/#-+()', ' ') = I_chaine ) then
	--
	G_niv_msg := 3;
	G_msg_adm := 'Evaluation chaine ' || I_chaine;
	P_INS_journal;
	--
	If ( NOT G_tableau ) then
		Begin
		L_retour := to_number(I_chaine);
		--
		G_niv_msg := 2;
		G_msg_adm := 'Chaine '||I_chaine||' - Numérique valeur : '||to_char(L_retour);
		P_INS_journal;
		--
		Return( L_retour );
		Exception When Value_error then
			Null;
		End;
	End if;
	--
	P_SEL_rep_fonction (
		I_chaine	=> I_chaine,
		O_type		=> L_type_fonction,
		O_libelle	=> L_lib_variable,
		O_nbarg		=> L_nbarg,
		O_idfonction	=> G_idfonction,
		O_date		=> G_date,
		O_found		=> L_found
		);
	If ( L_found ) then
		--
		If ( G_date ) then
			L_type_date := 'Date';
		Else
			L_type_date := 'Numérique';
		End if;
		--
		G_niv_msg := 2;
		G_idfonction := 0;
		G_code_msg := 5;
		G_liste_param := I_chaine||'|'||T_type_fonc(L_type_fonction)
			||'|'||L_lib_variable;
		P_trace;
		--
		If ( L_type_fonction = 4 ) then
			P_INS_frmlvar_detail (
				I_chaine	=>	I_chaine,
				I_session	=>	G_session
				);
		ElsIf ( G_tableau ) then
			Begin
			L_retour := to_number(I_chaine);
			--
			G_msg_adm := G_msg_adm||' - Valeur : '||to_char(L_retour);
			P_INS_journal;
			--
			Exception When Value_error then
				--
				G_niv_msg := 0;
				G_msg_adm := 'Variable inconnue dans ce contexte';
				P_INS_journal;
				--
			End;
		Elsif ( L_type_fonction = 2 ) then
			G_liste_param := I_chaine;
			If ( G_date ) then
				pk_contexte.P_SEL_contexte (
					I_variable	=>	I_chaine,
					O_Date	        =>	L_date,
					O_found		=>	L_found
					);
				--
				G_liste_param := G_liste_param || d2e(L_date);
				L_retour := d2j(L_date);
			Else
				pk_contexte.P_SEL_contexte (
					I_variable	=>	I_chaine,
					O_valeur	=>	L_retour,
					O_found		=>	L_found
					);
				G_liste_param := G_liste_param || to_char(L_retour);
			End If;
			--
			G_niv_msg := 2;
			G_idfonction := 0;
			If (L_found) then
				G_code_msg := 6;
			Else
				G_code_msg := 7;
			End if;
			P_trace;
			--
		End if;
	End if;
Else
	P_analyse(
		I_idformule 	=>	L_idformule,
		I_chaine	=>	I_chaine
		);
	If (G_resultat) then
		G_resultat := FALSE;
		L_retour := G_L_valeur;
		G_date := FALSE;
	End if;
End if;
--
G_niv_msg := 3;
G_msg_adm := 'Retour de F_evalue : '||to_char(L_retour);
P_INS_journal;
--
Return ( L_retour );
END F_Evalue;
--
-- Recherche du type de donnee
--
Procedure P_SEL_rep_fonction (
		I_chaine	IN	Varchar2,
		O_type		OUT	Number,
		O_libelle	OUT	Varchar2,
		O_nbarg		OUT	Number,
		O_idfonction	OUT	Number,
		O_date		OUT	Boolean,
		O_found		OUT	Boolean
		)
IS
Cursor C_rep_fonction_tous IS
	Select	type,
		lib_variable,
		contexte,
		nbarg,
		seq,
		d_date
	From	v_rep_fonction_ext
	Where	nom_fonction = I_chaine;
Rec_C_rep_fonction_tous	C_rep_fonction_tous%RowType;
--
Cursor C_rep_fonction IS
	Select	type,
		lib_variable,
		contexte,
		nbarg,
		seq,
		d_date
	From	v_rep_fonction_ext
	Where	nom_fonction = I_chaine
	and	contexte = G_contexte
	and	type not in(5, 7);
Rec_C_rep_fonction	C_rep_fonction%RowType;
--
Cursor C_rep_tableau IS
	Select	type,
		lib_variable,
		contexte,
		nbarg,
		seq,
		d_date
	From	v_rep_fonction_ext
	Where	nom_fonction = I_chaine
	and	contexte = G_contexte
	and	type in(5, 7);
Rec_C_rep_tableau	C_rep_tableau%RowType;
L_contexte		Number := G_contexte;
L_liste_param		Varchar2(128);
L_idligne		Number;
BEGIN
If ( G_tableau ) then
	Open C_rep_tableau;
	Fetch C_rep_tableau Into Rec_C_rep_tableau;
	If ( C_rep_tableau%NotFound ) then
		O_found := FALSE;
	Else
		O_found := TRUE;
		O_type := Rec_C_rep_tableau.type;
		O_libelle := Rec_C_rep_tableau.lib_variable;
		O_nbarg := Rec_C_rep_tableau.nbarg;
		O_idfonction := Rec_C_rep_tableau.seq;
		If (Rec_C_rep_tableau.d_date Is Null ) then
			O_date := FALSE;
		Else
			O_date := TRUE;
		End if;
	End if;
	Close C_rep_tableau;
Else
	Open C_rep_fonction;
	Fetch C_rep_fonction Into Rec_C_rep_fonction;
	If ( C_rep_fonction%NotFound ) then
		O_found := FALSE;
		Close C_rep_fonction;
		--
		Open C_rep_fonction_tous;
		Fetch C_rep_fonction_tous Into Rec_C_rep_fonction_tous;
		If ( C_rep_fonction_tous%NotFound ) then
			P_GEST_err_calc (
				I_idfonction	=> 0,
				I_code_msg	=> 2,
				O_idligne	=> L_idligne
				);
		Else
			L_liste_param :=
				t_type_fonc(Rec_C_rep_fonction_tous.type)
				||' |: ' ||' | '||
				I_chaine||' |('
				||Rec_C_rep_fonction_tous.lib_variable||') ';
			--
			G_niv_msg := 2;
			G_msg_adm := L_liste_param;
			P_INS_journal;
			--
			P_GEST_err_calc (
				I_idfonction	=> 0,
				I_code_msg	=> 1,
				I_liste_param	=> L_liste_param,
				O_idligne	=> L_idligne
				);
		End If;
		Close C_rep_fonction_tous;
	Else
		O_found := TRUE;
		O_type := Rec_C_rep_fonction.type;
		O_libelle := Rec_C_rep_fonction.lib_variable;
		O_nbarg := Rec_C_rep_fonction.nbarg;
		O_idfonction := Rec_C_rep_fonction.seq;
		If (Rec_C_rep_fonction.d_date Is Null ) then
			O_date := FALSE;
		Else
			O_date := TRUE;
		End if;
	End if;
End if;
END P_SEL_rep_fonction;
--
-- Chargement libelles types de données
--
Procedure P_CHRG_Type_fonc
IS
Cursor C_type IS
	Select	code,
		libelle
	From	Libelle
	Where	mnemo = 'TYPE_FONC'
	and	code > 0;
Rec_C_type 	C_type%RowType;
BEGIN
Open C_type;
Loop
	Fetch C_type Into Rec_C_type;
	Exit When C_type%NotFound;
	--
	T_type_fonc(Rec_C_type.code) := Rec_C_type.libelle;
End Loop;
Close C_type;
End P_CHRG_Type_fonc;
--
-- Stockage des idvariable dans frmlvar_detail
--
Procedure P_INS_frmlvar_detail (
		I_chaine	IN 	Varchar2,
		I_session	IN	Varchar2
		)
IS
L_idvariable	Number;
L_etendue	Number;
L_formule	Boolean;
L_type_date	Boolean;
BEGIN
pk_val_variable.P_SEL_def_variable (
	       I_chaine	      	=> 	I_chaine,
	       O_idvariable    	=> 	L_idvariable,
	       O_etendue    	=> 	L_etendue,
	       O_formule	=>	L_formule,
	       O_type_date	=>	L_type_date,
	       I_session      	=> 	G_session
	       );
--
If ( Not L_formule ) then
	--
	G_niv_msg := 2;
	G_idfonction := 0;
	G_code_msg := 8;
	G_liste_param := I_chaine||'|'||to_char(L_idvariable);
	P_trace;
	--
	Begin
	Insert Into frmlvar_detail (
		idvariable,
		idformule)
	Select	L_idvariable,
		G_idformule
	From	Dual
	Where Not Exists (
		Select	1
		From	frmlvar_detail	b
		Where	b.idvariable  = L_idvariable
		and	b.idformule = G_idformule
		);
	End;
End if;
END P_INS_frmlvar_detail;
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
END pk_calcul;
/
