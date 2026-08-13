CREATE OR REPLACE Package ARTHUS.pk_donnee
As
-- -- CONSTANTES PUBLIQUE -----------------------------------------------------
-- Chaine de reconnaissance SCCS
-- %W%  %E%
-- Aucune
-- -------------------------------------------- Fin des constantes publiques --

-- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des exceptions publiques --

-- -- TYPES PUBLIQUES ---------------------------------------------------------

type donnee is table of varchar2(50) index by binary_integer;

-- ------------------------------------------------- Fin des types publiques --

-- -- VARIABLES PUBLIQUES -----------------------------------------------------

t_donnee	donnee;
t_nul		donnee;

-- --------------------------------------------- Fin des variables publiques --

-- -- PROCEDURES PUBLIQUES ----------------------------------------------------

Procedure Charge_donnee	(
			a_entite 	In Number,
			a_cle 		In Number,
			t_out	Out donnee
			);

Procedure Charge_individu	(
			a_cle 		In Number
			);
Procedure Charge_adresse (
			a_cle 		In Number
			);
Procedure Charge_rib (
			a_cle 		In Number
			);
Procedure Charge_situ_pers (
			a_cle 		In Number
			);
Procedure Charge_adhesion (
			a_cle 		In Number
			);
Procedure Charge_situ_adhe (
			a_cle 		In Number
			);
Procedure Charge_var_adhe (
			a_cle 		In Number
			);
Procedure Charge_cotis_adhe (
			a_cle 		In Number
			);
Function Valeur_variable (
		a_idvariable 	in Binary_integer,
		a_cle 		in Binary_integer,
		a_debut 	in Date Default Sysdate
		)
Return Varchar2;
--Pragma restrict_references (Valeur_variable, WNDS);

Function f_qttc_annuelle (
			a_idadhesion 	In Number,
			a_date 		In Date Default Sysdate
			)
Return Number;
--Pragma restrict_references (f_qttc_annuelle, WNDS, WNPS);

Function f_qttc_regl (
			a_idadhesion 	In Number,
			a_date 		In Date Default Sysdate
			)
Return Number;
--Pragma restrict_references (f_qttc_regl, WNDS, WNPS);

-- -------------------------------------------- Fin des procedures publiques --
END pk_donnee;
/

CREATE OR REPLACE Package Body ARTHUS.pk_donnee
As
-- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Chaine de reconnaissance SCCS
-- %W%  %E%
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
Procedure P_SEL_lib_garantie (
		I_numfor	IN	gar_cntrt.numfor%Type,
		I_type		IN	gar_cntrt.type%Type,
		O_nomgar	OUT	gar_cntrt.nomgar%Type,
		O_libelle	OUT	gar_cntrt.libelle%Type)
IS
Cursor C_groupe IS
	Select	nomgrpgar,
		libelle
	From	grp_gar
	Where	numgrpgar = I_numfor;
Cursor C_gar IS
	Select	nomgar,
		libelle
	From	gar_cntrt
	Where	numfor = I_numfor;
Rec_C_groupe C_groupe%Rowtype;
Rec_C_gar C_gar%Rowtype;
BEGIN
If ( I_type = 3 ) then
	Open C_groupe;
	Fetch C_groupe Into Rec_C_groupe;
	O_nomgar := Rec_C_groupe.nomgrpgar;
	O_libelle := Rec_C_groupe.libelle;
	Close C_groupe;
Else
	Open C_gar;
	Fetch C_gar Into Rec_C_gar;
	O_nomgar := Rec_C_gar.nomgar;
	O_libelle := Rec_C_gar.libelle;
	Close C_gar;
End if;
END P_SEL_lib_garantie;

Procedure Charge_couverture (
		I_cle	IN	adhesion.idadhesion%Type,
		I_date	IN	Date Default Sysdate)
IS
Cursor C_couverture IS
	Select	Idadhesion,
		Numindiv,
		Numgar,
		Numfor,
		Datapli,
		Etat,
		Typfor,
		Numorg,
		Flag_Regime,
		Dis_Carence,
		Dis_Franchise,
		Rang,
		Datper,
		Motif,
		Numutil,
		Creation,
		Maj
	From	adhesion
	Where	idadhesion 	= I_cle
	and	I_date between adhesion.datapli
			and nvl(adhesion.datper, I_date)
	and	adhesion.etat = 1
	and	adhesion.datapli != nvl(adhesion.datper, adhesion.datapli + 1);
Rec_C_couverture	C_couverture%Rowtype;
BEGIN
Open C_couverture;
Fetch C_couverture Into Rec_C_couverture;
P_SEL_lib_garantie (
		I_numfor        => Rec_C_couverture.numfor,
		I_type          => Rec_C_couverture.typfor,
		O_nomgar        => T_donnee( 5 ),
		O_libelle       => T_donnee( 6 ) );
T_donnee( 1 ) := Rec_C_couverture.idadhesion;
T_donnee( 2 ) := Rec_C_couverture.numindiv;
T_donnee( 3 ) := Rec_C_couverture.numgar;
T_donnee( 4 ) := Rec_C_couverture.numfor;
T_donnee( 7 ) := d2e( Rec_C_couverture.datapli );
T_donnee( 8 ) := Rec_C_couverture.etat;
T_donnee( 9 ) := Rec_C_couverture.typfor;
T_donnee( 10 ) := Rec_C_couverture.numorg;
T_donnee( 11 ) := Rec_C_couverture.flag_regime;
T_donnee( 12 ) := Rec_C_couverture.dis_carence;
T_donnee( 13 ) := Rec_C_couverture.dis_franchise;
T_donnee( 14 ) := Rec_C_couverture.rang;
T_donnee( 15 ) := d2e( Rec_C_couverture.datper );
T_donnee( 16 ) := Rec_C_couverture.motif;
T_donnee( 17 ) := Rec_C_couverture.numutil;
T_donnee( 18 ) := d2e( Rec_C_couverture.creation );
T_donnee( 19 ) := d2e( Rec_C_couverture.maj );
Close C_couverture;
END Charge_couverture;
-- ----------------------------- Fin des declarations des procedures privees --

-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------

Procedure Charge_donnee (
			a_entite 	In Number,
			a_cle 		In Number,
			t_out		Out donnee
			)
Is
BEGIN

t_donnee := t_nul;

If ( a_entite = 1 ) then
	Charge_individu( a_cle );
ElsIf ( a_entite = 2 ) then
	Charge_adresse( pk_personne.f_idadresse(a_cle) );
ElsIf ( a_entite = 3 ) then
	Charge_situ_pers( a_cle );
ElsIf ( a_entite = 4 ) then
	Charge_rib( pk_personne.f_idrib(a_cle, 2) );
ElsIf ( a_entite = 31 ) then
	Charge_adhesion( a_cle );
ElsIf ( a_entite = 32 ) then
	Charge_situ_adhe( a_cle );
ElsIf ( a_entite = 34 ) then
	Charge_couverture(
		I_cle	=> a_cle );
ElsIf ( a_entite = 35 ) then
	Charge_var_adhe( a_cle );
ElsIf ( a_entite = 37 ) then
	Charge_cotis_adhe( a_cle );
End if;

t_out := t_donnee;

END	Charge_donnee;

Procedure Charge_individu (
			a_cle 		In Number
			)
Is
Indiv	Individu%Rowtype;
BEGIN
Dbms_output.put_line( 'Cle = '|| a_cle );
For Indiv in (
	Select	*
	From	individu
	Where	numindiv = a_cle)
Loop
Dbms_output.put_line( 'numindiv = '|| indiv.numindiv );
	t_donnee(1) := Indiv.numindiv;
Dbms_output.put_line( 'Donne 1 = '|| t_donnee(1) );
	t_donnee(2) := Indiv.type;
	t_donnee(3) := Indiv.nom;
	t_donnee(4) := Indiv.qualite;
	t_donnee(5) := Indiv.prenom;
	t_donnee(6) := d2e(Indiv.datnais);
	t_donnee(7) := Indiv.refcie;
	t_donnee(8) := Indiv.codcourrier1;
	t_donnee(9) := Indiv.codcourrier2;
	t_donnee(10) := Indiv.codtitre;
	t_donnee(11) := Indiv.sexe;
	t_donnee(12) := Indiv.potentiel;
	t_donnee(13) := Indiv.nomjf;
	t_donnee(14) := d2e(Indiv.creation);
	t_donnee(15) := d2e(Indiv.maj);
	t_donnee(16) := Indiv.numutil;
	t_donnee(17) := Indiv.numassu;
	t_donnee(18) := Indiv.typassu;
	t_donnee(19) := Indiv.typadr;
	t_donnee(20) := Indiv.regime;
	t_donnee(21) := Indiv.orgbase;
	t_donnee(22) := Indiv.matorg;
	t_donnee(23) := Indiv.cless;
	t_donnee(24) := Indiv.rang;
	t_donnee(25) := Indiv.natur;
	t_donnee(26) := Indiv.caisse;
	t_donnee(27) := Indiv.tel;
	t_donnee(28) := Indiv.fax;
End Loop;

END	Charge_individu;

Procedure Charge_adresse (
			a_cle 		In Number
			)
Is
Adr	Pers_adresse%Rowtype;
BEGIN
For Adr in (
	Select	*
	From	pers_adresse
	Where	idadresse = a_cle)
Loop
	t_donnee(1) := Adr.idadresse;
	t_donnee(2) := Adr.numindiv;
	t_donnee(3) := d2e(Adr.debut);
	t_donnee(4) := Adr.codope;
	t_donnee(5) := Adr.numgar;
	t_donnee(6) := Adr.defaut;
	t_donnee(7) := Adr.numutil;
	t_donnee(8) := d2e(Adr.maj);
	t_donnee(9) := Adr.no_voie;
	t_donnee(10) := Adr.bis;
	t_donnee(11) := Adr.type_voie;
	t_donnee(12) := Adr.nom_voie;
	t_donnee(13) := Adr.adresse_2;
	t_donnee(14) := Adr.comp_adresse;
	t_donnee(15) := Adr.codpos;
	t_donnee(16) := Adr.ville;
	t_donnee(17) := Adr.flag_cedex;
	t_donnee(18) := Adr.no_cedex;
	t_donnee(19) := Adr.codpays;
End Loop;

END	Charge_adresse;

Procedure Charge_rib (
			a_cle 		In Number
			)
Is
C_rib	rib%Rowtype;
BEGIN
For C_rib in (
	Select	*
	From	rib
	Where	idrib = a_cle)
Loop
	t_donnee(1) := C_rib.idrib;
	t_donnee(2) := C_rib.numindiv;
	t_donnee(3) := C_rib.type;
	t_donnee(4) := d2e(C_rib.debut);
	t_donnee(5) := C_rib.codope;
	t_donnee(6) := C_rib.numgar;
	t_donnee(7) := C_rib.modpmt;
	t_donnee(8) := C_rib.devise_compte;
	t_donnee(9) := C_rib.devise_ope;
	t_donnee(10) := d2e(C_rib.creation);
	t_donnee(11) := C_rib.numutil_creation;
	t_donnee(12) := C_rib.codbque;
	t_donnee(13) := C_rib.guichet;
	t_donnee(14) := C_rib.compte;
	t_donnee(15) := C_rib.clerib;
	t_donnee(16) := C_rib.intitule;
	t_donnee(17) := C_rib.domiciliation;
	t_donnee(18) := d2e(C_rib.maj);
	t_donnee(19) := C_rib.numutil_maj;
End Loop;

END	Charge_rib;

Procedure Charge_situ_pers (
			a_cle 		In Number
			)
Is
BEGIN
	t_donnee(1) := a_cle;
	t_donnee(2) := d2e( j2d( pk_personne.f_situ_pers(a_cle, 1) ) );
	t_donnee(3) := pk_personne.f_situ_pers( a_cle, 2 );
	t_donnee(4) := pk_personne.f_situ_pers( a_cle, 3 );
	t_donnee(5) := pk_personne.f_situ_pers( a_cle, 4 );
	t_donnee(6) := pk_personne.f_situ_pers( a_cle, 5 );
	t_donnee(7) := pk_personne.f_situ_pers( a_cle, 6 );
	t_donnee(8) := pk_personne.f_situ_pers( a_cle, 7 );

END	Charge_situ_pers;

Procedure Charge_adhesion (
			a_cle 		In Number
			)
Is
Adhe	Adhe_cntrt%Rowtype;
BEGIN
For Adhe in (
	Select	*
	From	Adhe_cntrt
	Where	idadhesion = a_cle)
Loop
	t_donnee(1) := Adhe.idadhesion;
	t_donnee(2) := Adhe.ref_ext;
	t_donnee(3) := Adhe.numgar;
	t_donnee(4) := Adhe.numadhe;
	t_donnee(5) := d2e(Adhe.date_adhe);
	t_donnee(6) := Adhe.meme_gar;
	t_donnee(7) := d2e(Adhe.date_fin_adhe);
	t_donnee(8) := Adhe.numquerable;
	t_donnee(9) := Adhe.fract;
	t_donnee(10) := d2e(Adhe.echesuiv);
	t_donnee(11) := d2e(Adhe.dereche);
	t_donnee(12) := Adhe.mregl;
	t_donnee(13) := Adhe.delai;
	t_donnee(14) := d2e(Adhe.dsous);
	t_donnee(15) := Adhe.numutil;
End Loop;

END	Charge_adhesion;

Procedure Charge_situ_adhe (
			a_cle 		In Number
			)
Is
Histo	histo_adhesion%Rowtype;
BEGIN
For Histo in (
	Select	*
	From	histo_adhesion
	Where	idadhesion = a_cle
	Order by Trunc(debut) Desc, datsai Desc )
Loop
	t_donnee(1) := Histo.idadhesion;
	t_donnee(2) := d2e(Histo.debut);
	t_donnee(3) := d2e(Histo.datsai);
	t_donnee(4) := Histo.etat;
	t_donnee(5) := Histo.motif;
	t_donnee(6) := Histo.numutil;
Exit;
End Loop;

END	Charge_situ_adhe;

Procedure Charge_var_adhe (
			a_cle 		In Number
			)
Is
Cursor Fetch_donnee Is
	Select	donnee
	From	def_var_porte
	Where	donnee > 1
	Group by donnee;
i		Binary_integer;
loc_donnee	Number;
loc_valeur	Varchar2(15);
C_donne Fetch_donnee%Rowtype;
Def_var	def_var_porte%Rowtype;
BEGIN
t_donnee( 1 ) := a_cle;
For C_donnee in Fetch_donnee
Loop
	i := C_donnee.donnee;
	For Def_var in (
		Select	idvariable
		From	def_var_porte
		Where	donnee = C_donnee.donnee)
	loop
		loc_valeur := Valeur_variable( Def_var.idvariable, a_cle );
		If ( loc_valeur is Not Null ) then
			Exit;
		End if;
	End loop;
	t_donnee( i ) := loc_valeur;
End Loop;

END	Charge_var_adhe;

Function Valeur_variable (
		a_idvariable 	in Binary_integer,
		a_cle 		in Binary_integer,
		a_debut 	in Date default Sysdate
		)
Return Varchar2
Is
loc_etendue	Binary_integer;
loc_cle		Binary_integer;
loc_numgar	Binary_integer;
loc_valeur	Varchar2(15);
Val_var		val_variable%rowtype;
BEGIN
Begin
Select	etendue
Into	loc_etendue
From	def_variable
Where	idvariable = a_idvariable;
End;
If (loc_etendue = 13 ) then
	loc_cle := a_cle;
Else
	loc_cle := f_numassu( 0, a_cle );
End if;
loc_numgar := f_numgar( a_cle );
Begin
For Val_var in (
	Select	valeur
	From	val_variable
	Where	valide = 'O'
	and	numgar = loc_numgar
	and	a_debut >= nvl( fin, a_debut )
	and	idvariable + 0 = a_idvariable
	and	clef = loc_cle
	and	etendue = loc_etendue
	Order by
		debut Desc)
Loop
	loc_valeur := Val_var.valeur;
	Exit;
End loop;
End;
Return ( loc_valeur );
Exception When No_Data_Found then Return Null;
End Valeur_variable;

Procedure Charge_cotis_adhe (
			a_cle 		In Number
			)
Is
qttc		qttc_global%Rowtype;
loc_date	Date;
BEGIN
For qttc in (
	Select	debut
	From 	qttc_global
	Where	idadhesion = a_cle
	and	type_qttc != 3
	Order by debut desc)
Loop
	loc_date := qttc.debut;
	Exit;
End Loop;
t_donnee( 1 ) := a_cle;
t_donnee( 2 ) := f_qttc_annuelle( a_cle, loc_date );
t_donnee( 3 ) := f_qttc_regl( a_cle, loc_date );
END	Charge_cotis_adhe;

Function f_qttc_annuelle (
			a_idadhesion 	In Number,
			a_date 		In Date Default Sysdate
			)
Return number
Is
loc_fin		date;
loc_debut	date;
loc_montant	number;
loc_retour	number;
L_numquit	qttc_global.numquit%Type;
BEGIN

Select	nvl( sum(pk_funct.f_arrondi(4, numquit, mt_ttc)), 0 ),
	min(numquit),
	min(debut),
	max(fin)
Into	loc_montant,
	L_numquit,
	loc_debut,
	loc_fin
From	qttc_global
Where	idadhesion = a_idadhesion
And	debut between trunc(a_date, 'Y')
		and   add_months( trunc(a_date, 'Y'), 12 )-1
and	comptant != 'R'
;
loc_retour := loc_montant / f_prorata( d2j(loc_debut), d2j(loc_fin) ) * 12;
loc_retour := pk_funct.f_arrondi(4, L_numquit, loc_retour);

Return ( loc_retour );

END	f_qttc_annuelle;

Function f_qttc_regl (
			a_idadhesion 	In Number,
			a_date 		In Date Default Sysdate
			)
Return number
Is
loc_montant	number;
loc_retour	number;
BEGIN

Select	nvl( sum(mt_affec), 0 )
Into	loc_montant
From	qttc_global
Where	idadhesion = a_idadhesion
And	debut between trunc(a_date, 'Y')
		and   add_months( trunc(a_date, 'Y'), 12 )-1
and	comptant != 'R'
;
loc_retour := loc_montant;

Return ( loc_retour );

END	f_qttc_regl;

-- ---------------------------------- Fin des corps des procedures publiques --

-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --
END pk_donnee;
/
