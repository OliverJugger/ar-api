CREATE function ARTHUS.f_idarchive (
				a_numindiv in number
				)
Return varchar2
as
loc_retour	Varchar2(10);
loc_sequence	number;
annee_mois	Varchar2(4);
emp		adhe_pret%rowtype;
BEGIN
For emp in (
	Select	idarchive
	From	adhe_pret
	Where	numindiv = a_numindiv)
Loop
	loc_retour := emp.idarchive;
	Exit;
End loop;
If ( loc_retour is Null ) then
Begin
annee_mois := to_char(sysdate, 'yymm');
Select	nvl(max(to_number(substr(idarchive, 5, 3))), 0) + 1
Into	loc_sequence
From	adhe_pret
Where	idarchive like annee_mois||'%';
End;
-- Return ( annee_mois );
loc_retour := annee_mois||substr(to_char(loc_sequence, '000'), 2, 3);
End if;
Return ( loc_retour );
END	f_idarchive;
