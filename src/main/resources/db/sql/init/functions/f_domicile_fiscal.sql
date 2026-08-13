CREATE function ARTHUS.f_domicile_fiscal(
				a_idrepartition in number,
				a_numbene in number,
				a_debut in date
				)
Return number
Is
Cursor Fetch_bene_fisc Is
	Select	type_fisc
	From	bene_fisc
	Where	numbene = a_numbene
	and	idrepartition = a_idrepartition
	and	debut <= nvl(a_debut, debut)
	and	valide='O'
	Order by debut desc;
c_bene_fisc	Fetch_bene_fisc%Rowtype;
loc_type_fisc 	number;
Begin
<<Recommence>>
For c_bene_fisc In Fetch_bene_fisc Loop
	loc_type_fisc := c_bene_fisc.type_fisc;
	Exit when Fetch_bene_fisc%Found;
End Loop;
Return(loc_type_fisc);
End;
