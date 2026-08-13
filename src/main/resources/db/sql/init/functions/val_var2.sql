CREATE Function ARTHUS.val_var2 (
		a_etendue	in Binary_integer,
		a_typinfo	in Binary_integer,
		a_cle		in Binary_integer,
		a_numindiv	in Binary_integer,
		a_debut 	in Date default Sysdate
		)
Return Varchar2
Is
loc_cle		Binary_integer;
loc_numgar	Binary_integer;
loc_valeur	Varchar2(15);
Val_var		val_variable%rowtype;
BEGIN
If (a_etendue = 13 ) then
loc_cle := a_cle;
Elsif (a_etendue = 4 ) then
loc_cle := a_numindiv;
Else
loc_cle := a_numindiv;
End if;
loc_numgar := f_numgar( a_cle );
Begin
For Val_var in (
	Select	valeur
	From	val_variable,type_info
	Where	valide = 'O'
	and	numgar = loc_numgar
  	and	a_debut between debut and nvl( fin, a_debut )
	and	clef = loc_cle
	and	etendue = a_etendue
	and	type_donnee=4
	and	cle=idvariable
	and	type_info=a_typinfo
	Order by
		debut Desc)
Loop
	loc_valeur := Val_var.valeur;
	Exit;
End loop;
End;
Return ( loc_valeur );
End val_var2;
