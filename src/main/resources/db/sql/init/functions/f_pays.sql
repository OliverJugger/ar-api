CREATE function ARTHUS.f_pays   (a_pays in binary_integer)
		RETURN	varchar2
as
		loc_pays varchar2(45) := 'Pays indéterminé';
BEGIN
	Begin
	Select nom
	Into loc_pays
	From pays
	Where codpays=a_pays;
	Exception
		When no_data_found then null;
	End;
return(loc_pays);
END;
