CREATE function ARTHUS.f_lib_propal (
				a_numpropo	In Number
				)
Return Varchar2
Is
loc_retour	Varchar2(78);
loc_objet	Binary_integer;
loc_lib		Varchar2(45);
c_fabric	proposition%Rowtype;
BEGIN
For c_fabric in (
	Select	objet,
		idobjet
	From	proposition
	Where	idpropo = a_numpropo)
Loop
	If ( c_fabric.objet = 1 ) then
		Begin
		Select	libelle
		Into	loc_lib
		From	produit
		Where	numprod = c_fabric.idobjet;
		Exception When No_data_found then loc_lib := 'Prod inexistant ...';
		End;
		loc_retour := 'Un contrat '|| loc_lib;
	Else
		Begin
		Select	refcie
		Into	loc_lib
		From	contrat
		Where	numgar = c_fabric.idobjet;
		Exception When No_data_found then loc_lib := 'Cont. inexistant ...';
		End;
		loc_retour := 'Une adhésion '|| loc_lib;
	End if;
Exit;
End Loop;
Return ( loc_retour );
END	f_lib_propal;
