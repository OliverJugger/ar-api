CREATE function ARTHUS.f_numutil
Return number
as
loc_retour	number := 0;
BEGIN
Begin
Select	numutil
Into	loc_retour
From	Utilisateurs
Where	numuid = uid;
Exception
	When No_data_found then loc_retour := 0;
	When Too_many_rows then loc_retour := 0;
End;
Return ( loc_retour );
END	f_numutil;
