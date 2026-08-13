CREATE function ARTHUS.f_porte_emetteur (
				a_regime in number,
				a_numsoc in number,
				a_numorg in number,
				a_numcaisse in number,
				a_numporte in number	default 1
				)
Return varchar2
as
loc_emetteur	varchar2(25);
loc_caisse	binary_integer := a_numcaisse;
Cursor	fetch_parporte
Is
Select	parporte.numemetteur
From	parporte
Where	parporte.numreg = a_regime
and	parporte.numsoc = a_numsoc
and	parporte.numorg = a_numorg
and	parporte.numporte = a_numporte
and	parporte.numcaisse = loc_caisse;
loc_porte	fetch_parporte%Rowtype;
BEGIN
<<Reboucle>>
Begin
For loc_porte in fetch_parporte
Loop
	If (loc_porte.numemetteur is not null) then
		loc_emetteur := loc_porte.numemetteur;
		Exit;
	End if;
End loop;
End;
If ( (loc_caisse != 0) and (loc_emetteur is Null) ) then
	loc_caisse := 0;
	Goto Reboucle;
End if;
Return ( loc_emetteur );
END	f_porte_emetteur;
