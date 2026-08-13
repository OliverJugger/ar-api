CREATE function ARTHUS.f_porte_identifiant (
				a_numgar in number,
				a_numporte in number	default 3,
				a_type in number default 1
				)
Return varchar2
as
loc_identifiant	varchar2(25);
loc_numgar	binary_integer := a_numgar;
Cursor	fetch_param
Is
Select	calcul||famille||'.'||organisme||'.'||centre ident,
	calcul||famille||organisme||centre||1 ident1,
	famille,
	organisme,
	centre,
	1 test
From	param_tiers_payant
Where	numporte=a_numporte
And	numgar=a_numgar
;
loc_param	fetch_param%Rowtype;
BEGIN
<<Reboucle>>
Begin
For loc_param in fetch_param
Loop
	If (loc_param.test is not null) then
		If (a_type=1) then
		loc_identifiant:=loc_param.ident;
		Exit;
		Elsif (a_type=2) then
		loc_identifiant:=loc_param.ident1;
		Exit;
		Elsif (a_type=3) then
		loc_identifiant:=loc_param.famille;
		Exit;
		Elsif (a_type=4) then
		loc_identifiant:=loc_param.organisme;
		Exit;
		Elsif (a_type=5) then
		loc_identifiant:=loc_param.centre;
		Exit;
		End if;
	End if;
End loop;
End;

If ( (loc_numgar != 0) and (loc_param.test is Null) ) then
	loc_numgar := 0;
	Goto Reboucle;
End if;

Return ( loc_identifiant );

END	f_porte_identifiant;
