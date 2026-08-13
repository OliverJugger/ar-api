CREATE Function ARTHUS.Val_var (
		a_idvariable 	in Binary_integer,
		a_cle 		in Binary_integer,
		a_debut 	in Date default Sysdate
		)
Return Varchar2
Is
loc_etendue	Binary_integer;
loc_cle		Binary_integer;
loc_numgar	Binary_integer;
loc_valeur	Varchar2(15);
Val_var		val_variable%rowtype;
BEGIN
Begin
Select	etendue
Into	loc_etendue
From	def_variable
Where	idvariable = a_idvariable;
End;
If (loc_etendue = 13 ) then
	loc_cle := a_cle;
Else
	loc_cle := f_numassu( 0, a_cle );
End if;
loc_numgar := f_numgar( a_cle );
Begin
For Val_var in (
	Select	valeur
	From	val_variable
	Where	valide = 'O'
	and	numgar = loc_numgar
	and	a_debut between debut and nvl( fin, a_debut )
	and	idvariable + 0 = a_idvariable
	and	clef = loc_cle
	and	etendue = loc_etendue
	Order by
		debut Desc)
Loop
	loc_valeur := Val_var.valeur;
	Exit;
End loop;
End;
Return ( loc_valeur );
Exception When No_Data_Found then Return Null;
End Val_var;
