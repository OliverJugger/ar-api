CREATE function ARTHUS.f_statut_noemie (
				a_numindiv in number,
				a_idporte in number	default 0
				)
Return varchar2
is
loc_date_trans	date	default sysdate;
Cursor fetch_objet is
	Select	Decode(rejet_noemie.mouvement,
			'R', 'Rejet le ',
			'S', 'Signal° le ',
			'C', 'Certif° le '
			)||
		to_char(to_date(rejet_noemie.date_rejet,'ddmmyy'), 'dd/mm/yy')
		||' : '||
		rejet_noemie.libelle	statut
	From	rejet_noemie
	Where	rejet_noemie.numindiv = a_numindiv
	and	to_date(date_rejet, 'ddmmyy') >= loc_date_trans
	Order by
		rejet_noemie.numremise desc;
loc_objet	fetch_objet%Rowtype;
loc_retour	varchar2(200) := 'Non encore acquité ...';
loc_numremise	binary_integer := 0;
loc_transmis	binary_integer := 2;
BEGIN
If ( a_idporte != 0 ) then
	Begin
	Select	numremise,
		transmis
	Into	loc_numremise,
		loc_transmis
	From	porte_adhesion
	Where	idporte = a_idporte;
	Exception when No_data_found then Null;
	End;
	if ( loc_numremise = 0 or loc_transmis = 2 ) then
		Return ('Non encore transmis ...');
	else
	Begin
	Select	date_trans
	Into	loc_date_trans
	From	remise_externe
	Where	numremise = loc_numremise;
	Exception when No_data_found then Null;
	End;
	end if;
End if;
For loc_objet in fetch_objet
loop
	If fetch_objet%Found then
		loc_retour := loc_objet.statut;
		exit;
	End if;
end loop;
Return loc_retour;
END;
