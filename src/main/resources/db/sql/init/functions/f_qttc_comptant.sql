CREATE function ARTHUS.f_qttc_comptant (
				a_idadhesion in number
				)
Return pk_texte.donnee
as
loc_t_donnee pk_texte.donnee;
BEGIN
loc_t_donnee(1) :='';
loc_t_donnee(2) :='';
loc_t_donnee(3) :='';
	Begin
	Select	to_char(mt_ttc,'999999999.90'),
		to_char(qttc_global.debut,'dd/mm/yy'),
		to_char(qttc_global.fin,'dd/mm/yy')
	Into	loc_t_donnee(1),
		loc_t_donnee(2),
		loc_t_donnee(3)
	From	qttc_global
	Where	idadhesion = a_idadhesion
	And	comptant = 'C'
	;
	Exception When no_data_found then
		loc_t_donnee(1) :='';
		loc_t_donnee(2) :='';
		loc_t_donnee(3) :='';
	End;
Return ( loc_t_donnee );
END	f_qttc_comptant;
