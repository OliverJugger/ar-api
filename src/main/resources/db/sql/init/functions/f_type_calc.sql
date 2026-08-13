CREATE function ARTHUS.f_type_calc (
				a_numdec in number
				)
Return Number
as
loc_type_calc		Number;
loc_idrepartition	number;
BEGIN
Begin
Select	min(idrepartition)
Into	loc_idrepartition
From	histo_calcul
Where	histo_calcul.numdec = a_numdec;
End;
if ( loc_idrepartition is not null ) then
	Begin
	Select 	repartition.type_calc
	Into 	loc_type_calc
	From 	repartition
	Where	repartition.idrepartition = loc_idrepartition
	;
	Exception
	When no_data_found then loc_type_calc := '0';
	End;
else
	loc_type_calc := '0';
end if;
return(loc_type_calc);
END;
