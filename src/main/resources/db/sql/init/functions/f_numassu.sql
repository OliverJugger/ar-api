CREATE function ARTHUS.f_numassu (
				comm_numindiv	in	Number,
				comm_idadhesion	in	Number Default 0
				)
Return Number
As
loc_numassu	Number(9);
Begin
If ( comm_idadhesion = 0 ) then
	Begin
	Select	indvs.numassu
	Into	loc_numassu
	From	indvs
	Where	indvs.numindiv = comm_numindiv;
	Exception When No_data_found then Raise No_data_found;
	End;
Else
	Begin
	Select	adhe_cntrt_membre.numindiv
	Into	loc_numassu
	From	adhe_cntrt_membre
	Where	adhe_cntrt_membre.idadhesion = comm_idadhesion
	and	adhe_cntrt_membre.typadr = 0;
	Exception When No_data_found then Raise No_data_found;
	 When Too_many_rows then loc_numassu:=comm_numindiv;
	End;
End if;
Return ( loc_numassu );
END	f_numassu;
