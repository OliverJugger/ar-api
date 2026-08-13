CREATE procedure ARTHUS.Ins_beneficiaire	(
			a_idadhesion	in number,
			a_numfor 	in number,
			a_numindiv	in number,
			a_numbene	in number Default 0
			)
Is
Cursor Fetch_garantie Is
	Select	garanties.numfor,
		garanties.type_bene
	From	garanties,
		v_gar_cntrt
	Where	garanties.numfor = v_gar_cntrt.numfor
	and	v_gar_cntrt.idgarantie = a_numfor;
type_bene	Binary_integer := 0;
Bene		Bene_gar%Rowtype;
Indiv		Individu%Rowtype;
Gar		Fetch_garantie%Rowtype;
BEGIN
For Gar in Fetch_garantie Loop
type_bene := Gar.type_bene;
If ( type_bene = 0 ) then
	Ins_bene( a_idadhesion, Gar.numfor, a_numindiv, a_numindiv, 0 );
Else
	For Bene in (
		Select	type_bene
		From	bene_gar
		Where	numfor = Gar.numfor)
	Loop
		For Indiv in (
			Select	numindiv,
				typadr
			From	individu
			Where	numindiv != a_numindiv
			and	typadr = Bene.type_bene
			and	numassu in (
				select	famille.numassu
				from	individu famille
				where	famille.numindiv = a_numindiv)
			)
		Loop
			Ins_bene( a_idadhesion, Gar.numfor, a_numindiv,
				  Indiv.numindiv, Indiv.typadr );
		End loop;
	End loop;
End if;
End Loop;
END;
/
