CREATE function ARTHUS.f_lib_affec (
				a_idaffec 	in Number
				)
Return Varchar2
Is
loc_retour	Varchar2(60);
cpt		compte_client%Rowtype;
regul		idaffec_regul%Rowtype;
attente		idaffec_attente%Rowtype;
Loc_datpay	Date;
BEGIN
For cpt in (
	Select	numencaismt,
		numfact,
		codope,
		numcli,
		datope,
		montant
	From	compte_client
	Where	idaffec = a_idaffec
	and	codope != 8)
Loop
If ( cpt.montant < 0 ) then
	Begin
	Select	'Rejet le '||d2e( annul_encais.date_annul )||' : '
		|| pk_libelle.f_lib( 'PREVANN', annul_encais.motif )
	Into	loc_retour
	From	annul_encais,
		prelevement
	Where	prelevement.numencaismt = cpt.numencaismt
	and	prelevement.numencaismt=annul_encais.numencaismt;
	Exception When No_data_found then
		Begin
		Select	'Reporté le '||
			d2e(facture_regul.datope)||
			' sur l'' appel n° '||facture_regul.numfact
		Into	loc_retour
		from 	facture_regul,
			idaffec_regul
		where	facture_regul.codope = cpt.codope
		and	facture_regul.numfact_regul = cpt.numfact
		and	idaffec_regul.idaffec = a_idaffec;
		Exception When No_data_found then
			loc_retour := 'Annulé le '||
				d2e(cpt.datope)||
				' report sur compte client n° '||cpt.numcli;
		End;
	End;
Else
	Begin
	Select	'Par régularisation le '||
		d2e(facture_regul.datope)||
		' de l'' appel n° '||facture_regul.numfact_regul
	Into	loc_retour
	from 	facture_regul
	where	facture_regul.codope = cpt.codope
	and	facture_regul.numfact = cpt.numfact;
	Exception When No_data_found then
		Begin
		Select	'Par ' || pk_libelle.f_lib('MREGL', modpmt)
			||' du '|| d2e(datpay)
		Into	loc_retour
		From	encaismt
		Where	numencaismt = cpt.numencaismt;
		Exception When No_data_found then loc_retour := Null;
		End;
	End;
End if;
Exit;
End Loop;
Return ( loc_retour );
END	f_lib_affec;
