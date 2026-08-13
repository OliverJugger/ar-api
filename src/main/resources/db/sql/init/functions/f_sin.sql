CREATE function ARTHUS.f_sin (
				a_numdec in number
				)
Return Varchar2
as
loc_nosin	Varchar2(10);
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
	Select 	repartition.nosin
	Into 	loc_nosin
	From 	repartition
	Where	repartition.idrepartition = loc_idrepartition
	;
	Exception
	When no_data_found then loc_nosin := '0';
	End;
else
	loc_nosin := '0';
end if;
return(loc_nosin);
END;
