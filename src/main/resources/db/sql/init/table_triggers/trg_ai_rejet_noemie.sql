CREATE TRIGGER ARTHUS.trg_ai_rejet_noemie
After 	Insert
On 	rejet_noemie
For each row
      WHEN ( 	new.mouvement = 'R' or new.mouvement = 'S' ) Declare
	loc_last_idporte 	binary_integer;
	loc_transmis 		binary_integer;
	porte 		porte_adhesion%Rowtype;
BEGIN
/* On recherche le dernier enregistrement transmis pour l'assure */
For porte in (
	Select	idporte,
		transmis,
		mouvement
	From	porte_adhesion
	Where	porte_adhesion.numporte = :new.numporte
	and	porte_adhesion.numindiv = :new.numindiv
	Order by
		idporte Desc)
Loop
	If ( porte.transmis = 1 ) then
		Begin
		/* On le marque (Rejet ou signalement) */
		Update	porte_adhesion
		Set	transmis = decode(:new.mouvement, 'R', 7, 8)
		Where	idporte = porte.idporte;
		/* Et on genere un nouveau mouvement */
		Update	individu
		Set	guichetpmt = decode( :new.mouvement,
					'R', decode(porte.mouvement,
						'C', '-2',
						'M', '-3',
						Null),
					'S', '-3')
		Where	numindiv = :new.numindiv;
		maj_ouv_de_droit(:new.numindiv);
		Update	individu
		Set	guichetpmt = ''
		Where	numindiv = :new.numindiv;
		End;
		Exit;
	Elsif ( porte.transmis = 2 ) then
		/* S'il y a eu une demande entre temps, on la supprime */
		Begin
		Delete	porte_adhesion
		Where	idporte = porte.idporte
		and	type Not In(30, 31);
		End;
		Exit;
	End if;
End loop;
END;