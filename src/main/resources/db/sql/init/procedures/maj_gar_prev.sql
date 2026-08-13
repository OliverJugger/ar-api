CREATE procedure ARTHUS.maj_gar_prev (a_numfor in number)
is
	Cursor fetch_gar is
	Select
		gar.numfor,
		gar.nat_risq,
		gar_prev.type_calc
	From	gar,gar_prev
	Where	gar.numfor=gar_prev.numfor
	And	gar.numfor=nvl(a_numfor,gar.numfor)
	;
loc_gar fetch_gar%Rowtype;
Begin
	For loc_gar in fetch_gar
	Loop
		Update gar_prev
		Set gar_fisc=decode(loc_gar.nat_risq,3,
						decode(loc_gar.type_calc,3,0,
						2,2),
						     5,
						decode(loc_gar.type_calc,3,0),
						     4,
						decode(loc_gar.type_calc,1,1),
						     2,
						decode(loc_gar.type_calc,2,3)
				)
		Where numfor=loc_gar.numfor
		;
	End loop;
End;
/
