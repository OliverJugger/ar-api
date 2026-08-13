CREATE function ARTHUS.f_etat_adhe_b(
			a_idadhesion	IN NUMBER,
			a_date		IN DATE,
			a_type in number default 1)
RETURN NUMBER
AS
loc_etat	number default 0;
L_date		Date;
cursor C_histo is
	Select	histo_adhesion.etat,
		histo_adhesion.motif,
		d2j(histo_adhesion.debut)	debut
	From	histo_adhesion
	Where	idadhesion = a_idadhesion
	and	debut <= L_date
	and	etat != 0
	order by
		trunc(debut) desc ,
		datsai desc
	;
Cursor C_instance IS
	Select	histo_adhesion.etat,
		histo_adhesion.motif,
		d2j(histo_adhesion.debut)	debut
	From	histo_adhesion
	Where	idadhesion = a_idadhesion
	and	debut <= L_date
	and	Not Exists (
		select	1
		from	histo_adhesion	instance
		where	instance.idadhesion = a_idadhesion
		and	instance.etat != 0
		)
	order by
		trunc(debut) desc ,
		datsai desc
	;
Rec_C_histo	C_histo%Rowtype;
Rec_C_instance	C_instance%Rowtype;
BEGIN
loc_etat := 0;
--
Begin
Select	Greatest( date_adhe, a_date )
Into	L_date
From	adhe_cntrt
Where	idadhesion = a_idadhesion;
Exception When No_data_found then L_date := a_date;
End;
--
Open C_instance;
fetch C_instance into Rec_C_instance;
If (C_instance%Found) then
	If (a_type=1) Then
		loc_etat := nvl( Rec_C_instance.etat, 0 );
	Elsif (a_type=2) Then
		loc_etat := nvl( Rec_C_instance.motif, 0 );
	Elsif (a_type=3) Then
		loc_etat := nvl( Rec_C_instance.debut, 1 );
	End if;
Else
	Open C_histo;
	Fetch C_histo into Rec_C_histo;
	Close C_histo;
	--
	If (a_type=1) Then
		loc_etat := nvl( Rec_C_histo.etat, 0 );
	Elsif (a_type=2) Then
		loc_etat := nvl( Rec_C_histo.motif, 0 );
	Elsif (a_type=3) Then
		loc_etat := nvl( Rec_C_histo.debut, 1 );
	End if;
End if;
Close C_instance;
--
Return loc_etat;
--
END f_etat_adhe_b;
