CREATE Function ARTHUS.f_codpos (
			a_numindiv 	in Number,
			a_codope 	in Number 	Default 0,
			a_debut 	in Date		Default sysdate,
			a_defaut 	in varchar2	Default 'O',
			a_numgar 	in Number	Default 0
			)
Return varchar2
Is
loc_codpos	Varchar2(5) :=0;
loc_numindiv	Binary_integer := a_numindiv;
loc_codope	Binary_integer := a_codope;
loc_numgar	Binary_integer := a_numgar;
loc_defaut	Varchar2(1) := a_defaut;
loc_debut	Date := a_debut;
Cursor Fetch_codpos Is
	Select	codpos
	From	pers_adresse
	Where	numindiv = loc_numindiv
	and	codope = loc_codope
	and	numgar = loc_numgar
	and	defaut = nvl(loc_defaut, defaut)
	and	debut <= nvl(loc_debut, debut)
	Order by debut desc;
c_codpos	Fetch_codpos%Rowtype;
Begin
<<Recommence>>
For c_codpos In Fetch_codpos Loop
	loc_codpos := c_codpos.codpos;
	Exit when Fetch_codpos%Found;
End Loop;
If ( loc_codpos = 0 ) then
	If ( loc_numgar != 0 ) then
		loc_numgar := 0;
		Goto Recommence;
	Elsif ( loc_codope != 0 ) then
		loc_codope := 0;
		Goto Recommence;
	Elsif ( loc_debut Is Not Null ) then
		loc_debut := Null;
		Goto Recommence;
	Elsif ( loc_defaut = 'O' ) then
		loc_defaut := 'N';
		Goto Recommence;
	Elsif ( loc_defaut = 'N' ) then
		loc_defaut := Null;
		Goto Recommence;
	End if;
	If ( loc_numindiv != f_numassu(a_numindiv) ) then
		loc_numindiv := f_numassu(a_numindiv);
		loc_codope	:= a_codope;
		loc_numgar	:= a_numgar;
		loc_defaut	:= a_defaut;
		loc_debut	:= a_debut;
		Goto Recommence;
 	End if;
End if;
Return( loc_codpos );
End f_codpos;
