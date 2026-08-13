CREATE function ARTHUS.f_sntr_remb (
				a_numsin in number
				)
Return integer
as
	loc_retour	integer := 0;
BEGIN
Begin
Select	1
Into	loc_retour
From	sntr_remb
Where	numsin = a_numsin;
Exception When No_data_found then loc_retour := 0;
End;
Return ( loc_retour );
END;
