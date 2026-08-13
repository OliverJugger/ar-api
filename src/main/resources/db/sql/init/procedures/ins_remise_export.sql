CREATE procedure ARTHUS.ins_remise_export (
				a_idporte	In Number
				)
Is
loc_numremise		Number;
BEGIN
Select	nvl( max(numremise), 0 ) +1
Into	loc_numremise
From	remise_export;
Insert Into remise_export (
	numremise,
	idporte,
	nombre,
	date_remise)
Select	loc_numremise,
	a_idporte,
	count(*),
	trunc(sysdate)
From	histo_export
Where	numremise = 0
and	idporte = a_idporte;
Update	histo_export
Set	numremise = loc_numremise
Where	numremise = 0
and	idporte = a_idporte;
END;
/
