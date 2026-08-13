CREATE procedure ARTHUS.verif_adresse
As
loc_adressse pers_adresse%rowtype;
nom	Varchar2(32);
adr1	Varchar2(32);
adr2	Varchar2(32);
adr3	Varchar2(32);
adr4	Varchar2(32);
adr5	Varchar2(32);
Begin
For loc_adresse in (
	Select	idadresse,
		numindiv
	From	pers_adresse)
Loop
	Begin
	Select	pk_personne.f_adresse ( loc_adresse.idadresse, 1, loc_adresse.numindiv,0),
		pk_personne.f_adresse ( loc_adresse.idadresse, 2, loc_adresse.numindiv, 0 ),
		pk_personne.f_adresse ( loc_adresse.idadresse, 3, loc_adresse.numindiv, 0 ),
		pk_personne.f_adresse ( loc_adresse.idadresse, 4, loc_adresse.numindiv, 0 ),
		pk_personne.f_adresse ( loc_adresse.idadresse, 5, loc_adresse.numindiv, 0 ),
         	pk_personne.f_nom ( loc_adresse.numindiv, 32, 0 )
	Into	adr1,
		adr2,
		adr3,
		adr4,
		adr5,
		nom
	From	Dual;
	Exception when others then
	Dbms_output.put_line('Numindiv = ' || loc_adresse.numindiv
			|| 'idadresse : '|| loc_adresse.idadresse
			|| 'Erreur : '|| sqlerrm);
	End;
End loop;
End;
/
