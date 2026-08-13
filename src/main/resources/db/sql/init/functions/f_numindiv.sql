CREATE function ARTHUS.f_numindiv
Return Number
as
loc_retour	number;
loc_sequence	number;
annee_mois	number;
BEGIN
Begin
annee_mois := to_number( to_char(sysdate, 'yymm') );
Select	nvl(max(to_number(substr(to_char(numindiv), 5, 3))), 0) + 1
Into	loc_sequence
From	individu
Where	numindiv like to_char(annee_mois)||'%';
End;
-- Return ( annee_mois );
loc_retour := to_number( to_char(annee_mois)||substr(to_char(loc_sequence, '0000'), 2, 4) );
Return ( loc_retour );
END	f_numindiv;
