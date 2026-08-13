CREATE function ARTHUS.f_numorg(a_numindiv in number,a_type in number default 1)
Return number
Is
loc_numorg number(6);
Begin
If (a_type=1) then
	Begin
	Select 	numorg
	Into 	loc_numorg
	From 	pers_organisme
	Where 	numindiv=a_numindiv;
	Return(loc_numorg);
	Exception
	When no_data_found then
		loc_numorg:=a_numindiv;
		Return(loc_numorg);
	End;
Elsif (a_type=2) then
	Begin
	Select 	numindiv
	Into 	loc_numorg
	From 	pers_organisme
	Where 	numorg=a_numindiv;
	Return(loc_numorg);
	Exception
	When no_data_found then
		loc_numorg:=a_numindiv;
		Return(loc_numorg);
	End;
End if;
End;
