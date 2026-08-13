CREATE OR REPLACE package ARTHUS.pk_maj_datope
AS
--
-- Variables globales
G_date_butoir	Constant Date := '31-dec-2001';
G_debut		Constant Date := '01-jan-2001';
G_fin		Constant Date := '31-dec-2001';
G_datencaismt	Date;
G_deb_encaismt	Number;
G_fin_encaismt	Number;
--
-- Declaration des Procedures publiques
--
Procedure P_MAJ_datope (
		I_deb_encaismt 	IN Number Default Null,
		I_fin_encaismt	IN Number Default Null
		);
--
END pk_maj_datope;
/

CREATE OR REPLACE package body ARTHUS.pk_maj_datope
AS
--@priv
-- Declaration des Procedures privees
-------------------------------------
--
-- Traitement du compte d'attente
--
Procedure P_MAJ_attente (
		I_numencaismt	IN encaismt.numencaismt%Type,
		I_codope	IN encaismt.numencaismt%Type
		);
--
-- Traitement des affectations
--
Procedure P_MAJ_affectation (
		I_numencaismt	IN encaismt.numencaismt%Type,
		I_codope	IN encaismt.numencaismt%Type
		);
--
-- Traitement des remises en banque
--
Procedure P_MAJ_remise;
--
-- Traitement hors remises en banque
--
Procedure P_MAJ_hors_remise;
--
-- Traitement affectations par compensation
--
Procedure P_MAJ_compensation;
--
--@corpriv --------------------
-- Corps des Procedures privees
-------------------------------
--
-- Traitement affectations par compensation
--
Procedure P_MAJ_compensation
IS
Cursor C_compens IS
	Select	idmvt,
		datope
	From	compte_tiers
	Where	codope != 10
	and	idmvt IN (
		select	pk_compte_tiers.f_origine ( codope, idaffec )
		from	compte_client
		);
Cursor C_affec ( P_idmvt IN compte_tiers.idmvt%Type ) IS
	Select	idmvt,
		datope,
		cle
	From	compte_tiers
	Where	idmvt IN (
		select	idcomp
		from	compensation
		where	idmvt = P_idmvt
		)
	and	codope + 0 != 10;
Rec_C_compens	C_compens%Rowtype;
Rec_C_affec	C_affec%Rowtype;
BEGIN
Open C_compens;
Loop
	Fetch C_compens Into Rec_C_compens;
	Exit When C_compens%NotFound;
	Open C_affec ( Rec_C_compens.idmvt );
	Loop
		Fetch C_affec Into Rec_C_affec;
		Exit When C_affec%NotFound;
		If ( Rec_C_affec.datope > G_date_butoir ) then
			--
			Update	compte_tiers
			Set	datope = G_date_butoir
			Where	idmvt = Rec_C_affec.idmvt;
			--
			Update	compte_client
			Set	datope = G_date_butoir
			Where	idaffec = Rec_C_affec.cle;
			--
		End if;
	End Loop;
	Close C_affec;
End Loop;
Close C_compens;
END P_MAJ_compensation;
--
-- Traitement des remises en banque
--
Procedure P_MAJ_hors_remise
IS
Cursor C_encais IS
	Select	encaismt.datpay,
		encaismt.numencaismt,
		encaismt.codope
	From	encaismt
	Where	encaismt.datpay between G_debut and G_fin
	and Not Exists (
		select	1
		from	remise_banque
		where	remise_banque.numencaismt = encaismt.numencaismt
		)
	Order By
		encaismt.numencaismt;
Rec_C_encais	C_encais%Rowtype;
BEGIN
Open C_encais;
Loop
	Fetch C_encais Into Rec_C_encais;
	Exit When C_encais%NotFound;
	--
	Dbms_output.put_line( 'Traitement encais N° '
		|| Rec_C_encais.numencaismt
		|| ' Date ' || Rec_C_encais.datpay );
	--
	G_datencaismt := Rec_C_encais.datpay;
	--
	P_MAJ_attente (
		I_numencaismt	=> Rec_C_encais.numencaismt,
		I_codope	=> Rec_C_encais.codope
		);
	--
	P_MAJ_affectation (
		I_numencaismt	=> Rec_C_encais.numencaismt,
		I_codope	=> Rec_C_encais.codope
		);
	--
End Loop;
Close C_encais;
END P_MAJ_hors_remise;
--
--
-- Traitement des remises en banque
--
Procedure P_MAJ_remise
IS
Cursor C_remise IS
	Select	remise_globale.numremise,
		remise_globale.daterem,
		encaismt.numencaismt,
		encaismt.codope
	From	remise_globale,
		remise_banque,
		encaismt
	Where	remise_globale.daterem between G_debut and G_fin
	and	remise_banque.numremise= remise_globale.numremise
	and	encaismt.numencaismt = remise_banque.numencaismt
	Order By
		remise_globale.numremise;
Rec_C_remise	C_remise%Rowtype;
BEGIN
Open C_remise;
Loop
	Fetch C_remise Into Rec_C_remise;
	Exit When C_remise%NotFound;
	--
	Dbms_output.put_line( 'Traitement remise N° '|| Rec_C_remise.numremise
		|| ' Date ' || Rec_C_remise.daterem );
	--
	G_datencaismt := Rec_C_remise.daterem;
	--
	P_MAJ_attente (
		I_numencaismt	=> Rec_C_remise.numencaismt,
		I_codope	=> Rec_C_remise.codope
		);
	--
	P_MAJ_affectation (
		I_numencaismt	=> Rec_C_remise.numencaismt,
		I_codope	=> Rec_C_remise.codope
		);
	--
End Loop;
Close C_remise;
END P_MAJ_remise;
--
/*
Procedure P_autre
IS
Cursor C_encais ( P_numremise IN remise_banque.numremise%Type ) IS
	Select	encaismt.numencaismt,
		encaismt.codope
	From	encaismt,
		remise_banque
	Where	encaismt.numencaismt = remise_banque.numencaismt
	and	remise_banque.numremise = P_numremise;
Rec_C_encais	C_encais%Rowtype;
--
*/
--
-- Traitement du compte d'attente
--
Procedure P_MAJ_attente (
		I_numencaismt	IN encaismt.numencaismt%Type,
		I_codope	IN encaismt.numencaismt%Type
		)
IS
Cursor C_tiers IS
	Select	idmvt,
		datope
	From	compte_tiers
	Where	codope = 10
	and	cle = I_numencaismt;
--
Cursor C_attente IS
	Select	idaffec,
		datope
	From	compte_client
	Where	codope + 0 = 8
	and	numfact IS Null
	and	numencaismt = I_numencaismt;
--
Rec_C_tiers	C_tiers%Rowtype;
Rec_C_attente	C_attente%Rowtype;
L_datope	Date;
L_update	Boolean := FALSE;
BEGIN
--
Dbms_output.put_line( 'Encaissement N° '
	|| I_numencaismt ||
	' Ope ' || I_codope );
--
If ( I_codope = 10 ) then
	L_update := FALSE;
	Open C_tiers;
	Fetch C_tiers Into Rec_C_tiers;
	Close C_tiers;
	--
	If ( Rec_C_tiers.datope > G_date_butoir ) then
		L_datope := G_date_butoir;
		L_update := TRUE;
	ElsIf ( Rec_C_tiers.datope > G_datencaismt ) then
		L_datope := G_datencaismt;
		L_update := TRUE;
	End if;
	--
	If ( L_update ) then
		Update	compte_tiers
		Set	datope = L_datope
		Where	idmvt = Rec_C_tiers.idmvt;
		--
		Dbms_output.put_line( 'Maj Idmvt ' || Rec_C_tiers.idmvt
			|| ' ancienne date ' || Rec_C_tiers.datope
			|| ' nouvelle : ' || L_datope);
		--
	End if;
Else	-- ( codope != 10 )
	L_update := FALSE;
	Open C_attente;
	Loop
		Fetch C_attente Into Rec_C_attente;
		Exit When C_attente%NotFound;
		--
		If ( Rec_C_attente.datope > G_date_butoir ) then
			L_datope := G_date_butoir;
			L_update := TRUE;
		ElsIf ( Rec_C_attente.datope > G_datencaismt ) then
			L_datope := G_datencaismt;
			L_update := TRUE;
		End if;
		--
		If ( L_update ) then
			Update	compte_client
			Set	datope = L_datope
			Where	idaffec = Rec_C_attente.idaffec
			and	codope + 0 = 8
			and	numfact IS Null;
			--
			Dbms_output.put_line( 'Maj Idaffec '
				|| Rec_C_attente.idaffec
				|| ' ancienne date ' || Rec_C_attente.datope
				|| ' nouvelle : ' || L_datope);
			--
		End if;
	End Loop;
	Close C_attente;
End if;
END P_MAJ_attente;
--
-- Traitement des affectations
--
Procedure P_MAJ_affectation (
		I_numencaismt	IN encaismt.numencaismt%Type,
		I_codope	IN encaismt.numencaismt%Type
		)
IS
Cursor C_affec IS
	Select	idaffec,
		codope,
		datope
	From	compte_client
	Where	numencaismt = I_numencaismt
	and	numfact is Not Null;
--
Rec_C_affec	C_affec%Rowtype;
L_datope	Date;
L_update	Boolean := FALSE;
BEGIN
L_update := FALSE;
Open C_affec;
Loop
	Fetch C_affec Into Rec_C_affec;
	Exit When C_affec%NotFound;
	--
	If ( Rec_C_affec.datope > G_date_butoir ) then
		L_datope := G_date_butoir;
		L_update := TRUE;
	End if;
	--
	If ( L_update ) then
		Update	compte_client
		Set	datope = L_datope
		Where	idaffec = Rec_C_affec.idaffec
		and	codope + 0 = Rec_C_affec.codope;
		--
		Update	compte_tiers
		Set	datope = L_datope
		Where	codope = Rec_C_affec.codope
		and	cle = Rec_C_affec.idaffec;
		--
		Dbms_output.put_line( 'Maj Idaffec '
			|| Rec_C_affec.idaffec
			|| ' ancienne date ' || Rec_C_affec.datope
			|| ' nouvelle : ' || L_datope);
		--
	End if;
End Loop;
Close C_affec;
END P_MAJ_affectation;
--
-- Declaration des Procedures publiques
--
Procedure P_MAJ_datope (
		I_deb_encaismt 	IN Number Default Null,
		I_fin_encaismt	IN Number Default Null
		)
IS
BEGIN
G_deb_encaismt := I_deb_encaismt;
G_fin_encaismt := I_fin_encaismt;
--
P_MAJ_remise;
--
P_MAJ_hors_remise;
--
P_MAJ_compensation;
--
END P_MAJ_datope;
--
END pk_maj_datope;
/
