CREATE procedure ARTHUS.P_MAJ_datope (
	I_numencaismt 	IN encaismt.numencaismt%Type,
	I_datope	IN Varchar2
	)
AS
Cursor C_encais IS
	Select	encaismt.codope
	From	encaismt
	Where	encaismt.numencaismt = I_numencaismt;
--
Cursor C_tiers IS
	Select	compensation.idcomp
	From	compensation,
		compte_tiers
	Where	compensation.idmvt = compte_tiers.idmvt
	and	compte_tiers.codope = 10
	and	compte_tiers.cle = I_numencaismt
	and	compte_tiers.sens = 1;
--
L_codope	encaismt.codope%Type;
L_idmvt		compte_tiers.idmvt%Type;
L_datope	Date;
Nb_tiers	Number := 0;
Nb_cli		Number := 0;
BEGIN
L_datope := To_date(I_datope, 'dd/mm/yyyy');
Open C_encais;
Fetch C_encais into L_codope;
If ( L_codope = 10 ) then
	--
	Begin
	Update	compte_tiers
	Set	datope = L_datope
	Where	codope = 10
	and	cle = I_numencaismt
	and	sens = 1;
	Nb_tiers := Nb_tiers + Sql%Rowcount;
	End;
	--
	Open C_tiers;
	Loop
		Fetch C_tiers Into L_idmvt;
		Exit When C_tiers%NotFound;
		Begin
		Update	compte_tiers
		Set	datope = L_datope
		Where	idmvt = L_idmvt;
		Nb_tiers := Nb_tiers + Sql%Rowcount;
		End;
	End Loop;
	Close C_tiers;
End if;
--
Begin
Update	compte_client
Set     datope = L_datope
Where	numencaismt = I_numencaismt;
Nb_cli := Nb_cli + Sql%Rowcount;
End;
--
Close C_encais;
Dbms_output.put_line( '------------------------------------------------------' );
Dbms_output.put_line( Nb_tiers || ' lignes compte tiers MAJ, '
			|| Nb_cli || ' lignes compte client MAJ.');
END;
/
