CREATE function ARTHUS.f_numero      (a_mnemo in varchar2)
		RETURN	number
as
	numero 	number;
	i 	Binary_integer;
	loc_min 	Binary_integer;
	loc_max 	Binary_integer;
BEGIN
If ( a_mnemo = 'SOCIETE' ) then
	loc_min := 1; loc_max := 99;
Elsif ( a_mnemo = 'ORGANISME' ) then
	loc_min := 100; loc_max := 999;
Else
	Update num
	Set numero=nvl(numero,0)+1
	Where mnemo=a_mnemo;
	Select numero
	Into numero
	From num
	Where mnemo=a_mnemo;
	Return( numero );
End If;
For i in loc_min .. loc_max
Loop
	Begin
	Select	numindiv
	Into	numero
	From	indvs
	Where	numindiv = i;
	Exception When No_data_found then
		numero := i;
		Exit;
	End;
End loop;
Return( numero );
END f_numero;
