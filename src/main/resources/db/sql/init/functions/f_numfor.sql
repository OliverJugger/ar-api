CREATE function ARTHUS.f_numfor (
				a_numdec in number
				)
Return Number
as
loc_numfor	Number;
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
	Select 	repartition.numfor
	Into 	loc_numfor
	From 	repartition
	Where	repartition.idrepartition = loc_idrepartition
	;
	Exception
	When no_data_found then loc_numfor := '0';
	End;
else
	loc_numfor := '0';
end if;
return(loc_numfor);
END;
