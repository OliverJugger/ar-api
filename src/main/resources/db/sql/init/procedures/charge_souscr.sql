CREATE Procedure ARTHUS.charge_souscr ( a_numindiv in number,
					   a_idrib in number default 0,
					   t_donnee out pk_texte.donnee)
is
t_donnee_rib pk_texte.donnee;
BEGIN

/*
If (a_idrib!=0)
Then
charge_rib(a_idrib,t_donnee_rib);

t_donnee(29):=t_donnee_rib(1);
t_donnee(30):=t_donnee_rib(2);
t_donnee(31):=t_donnee_rib(3);
t_donnee(32):=t_donnee_rib(4);
t_donnee(33):=t_donnee_rib(5);
t_donnee(34):=t_donnee_rib(6);
t_donnee(35):=t_donnee_rib(7);
t_donnee(36):=t_donnee_rib(8);

 End if;
*/

Begin

	Select
		numindiv,
		refcie,
		substr(pk_libelle.f_lib('QLTE',qualite),1,15),
		substr(pk_libelle.f_lib('CODC1',codcourrier1),1,15),
		substr(pk_libelle.f_lib('CODC2',codcourrier2),1,15),
		substr(pk_libelle.f_lib('TITRE',codtitre),1,15),
		substr(pk_personne.f_nom(numindiv,30,0),1,30),
		substr(nom,1,30),
		substr(prenom,1,20),
          	pk_personne.f_adresse (
                              pk_personne.f_idadresse (
                              numindiv, 0, sysdate, 'O', 0 ),
                              1, numindiv),
          	pk_personne.f_adresse (
                              pk_personne.f_idadresse (
                              numindiv, 0, sysdate, 'O', 0 ),
                              2, numindiv),

          	pk_personne.f_adresse (
                              pk_personne.f_idadresse (
                              numindiv, 0, sysdate, 'O', 0 ),
                              3, numindiv),
          	pk_personne.f_adresse (
                              pk_personne.f_idadresse (
                              numindiv, 0, sysdate, 'O', 0 ),
                              4, numindiv),
		substr(f_pays(codpays),1,15),
		tel,
		fax,
		email,
		d2e(datnais),
		matorg,
		cless,
		'',
		'',
		'',
		'',
		'',
		'',
		''
	Into	t_donnee(1),
		t_donnee(2),
		t_donnee(3),
		t_donnee(4),
		t_donnee(5),
		t_donnee(6),
		t_donnee(7),
		t_donnee(8),
		t_donnee(9),
		t_donnee(10),
		t_donnee(11),
		t_donnee(12),
		t_donnee(13),
		t_donnee(14),
		t_donnee(15),
		t_donnee(16),
		t_donnee(17),
		t_donnee(18),
		t_donnee(19),
		t_donnee(20),
		t_donnee(21),
		t_donnee(22),
		t_donnee(23),
		t_donnee(24),
		t_donnee(25),
		t_donnee(26),
		t_donnee(27)
	From 	indvs
	Where	numindiv=a_numindiv
	And	type=1
	;

	Exception
	When no_data_found then

	Begin

	Select
		indvs.numindiv,
		refcie,
		substr(pk_libelle.f_lib('QLTE',qualite),1,15),
		substr(pk_libelle.f_lib('CODC1',codcourrier1),1,15),
		substr(pk_libelle.f_lib('CODC2',codcourrier2),1,15),
		substr(pk_libelle.f_lib('TITRE',codtitre),1,15),
		substr(pk_personne.f_nom(indvs.numindiv,30,0),1,30),
		substr(nom,1,30),
		substr(prenom,1,20),
          	pk_personne.f_adresse (
                              pk_personne.f_idadresse (
                              indvs.numindiv, 0, sysdate, 'O', 0 ),
                              1, indvs.numindiv),
          	pk_personne.f_adresse (
                              pk_personne.f_idadresse (
                              indvs.numindiv, 0, sysdate, 'O', 0 ),
                              2, indvs.numindiv),

          	pk_personne.f_adresse (
                              pk_personne.f_idadresse (
                              indvs.numindiv, 0, sysdate, 'O', 0 ),
                              3, indvs.numindiv),
          	pk_personne.f_adresse (
                              pk_personne.f_idadresse (
                              indvs.numindiv, 0, sysdate, 'O', 0 ),
                              4, indvs.numindiv),
		substr(f_pays(codpays),1,15),
		tel,
		fax,
		email,
		'',
		'',
		to_number(''),
		d2e(pers_morale.creation),
		pers_morale.siret,
		pers_morale.ape,
		pers_morale.code_naf,
		pers_morale.vip,
		substr(pk_libelle.f_lib('CONVENTION',pers_morale.convention),
									1,25),
		substr(pk_libelle.f_lib('POTENTIEL',pers_morale.potentiel),
									1,25)
	Into	t_donnee(1),
		t_donnee(2),
		t_donnee(3),
		t_donnee(4),
		t_donnee(5),
		t_donnee(6),
		t_donnee(7),
		t_donnee(8),
		t_donnee(9),
		t_donnee(10),
		t_donnee(11),
		t_donnee(12),
		t_donnee(13),
		t_donnee(14),
		t_donnee(15),
		t_donnee(16),
		t_donnee(17),
		t_donnee(18),
		t_donnee(19),
		t_donnee(20),
		t_donnee(21),
		t_donnee(22),
		t_donnee(23),
		t_donnee(24),
		t_donnee(25),
		t_donnee(26),
		t_donnee(27)
	From	indvs,
		pers_morale
	Where	indvs.numindiv=a_numindiv
	And	indvs.numindiv=pers_morale.numindiv
	And	indvs.type=2
	;

	End;
end;
END charge_souscr;
/
