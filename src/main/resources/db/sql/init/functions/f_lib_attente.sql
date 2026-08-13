CREATE function ARTHUS.f_lib_attente (
				a_idaffec 	in Number
				)
Return Varchar2
Is
loc_retour	Varchar2(60);
cpt		compte_client%Rowtype;
Loc_datpay	Date;
Cursor C_rejet ( P_numencaismt IN compte_client.numencaismt%Type ) IS
	Select 1
	From   annul_cptcli
	Where  numencaismt = P_numencaismt
	and    idaffec = a_idaffec;
Rec_C_rejet C_rejet%Rowtype;
BEGIN
For cpt in (
	Select	numencaismt,
		numfact
	From	compte_client
	Where	idaffec = a_idaffec
	and	codope =8)
Loop
Open C_rejet( cpt.numencaismt );
Fetch C_rejet Into Rec_C_rejet;
If ( C_rejet%Found ) then
	loc_retour := 'Annulation suite à rejet';
ElsIf ( cpt.numfact is Null ) then
	Begin
	Select	pk_libelle.f_lib('MREGL', modpmt)
		||' du '|| d2e(datpay)
		|| ' non affecté'
	Into	loc_retour
	From	encaismt
	Where	numencaismt = cpt.numencaismt;
	End;
Else
	Begin
	Select	'Solde régul° échéance ' || numfact
	Into	loc_retour
	From	facture_regul
	Where	facture_regul.numfact_regul = cpt.numfact;
	Exception When No_data_found then
		Begin
		Select	'Désaffectation pièce ' || numfact
		Into	loc_retour
		From	compte_client
		Where	compte_client.numfact = cpt.numfact
		and	compte_client.codope != 8
		and	compte_client.idaffec = a_idaffec;
		End;
	End;
End if;
Close C_rejet;
End Loop;
Return ( loc_retour );
END	f_lib_attente;
