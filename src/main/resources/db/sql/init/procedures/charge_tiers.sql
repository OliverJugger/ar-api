CREATE procedure ARTHUS.charge_tiers ( a_numindiv in number,
					   t_donnee out pk_texte.donnee)
is
BEGIN
	Select
		indvs.numindiv,
		indvs.refcie,
		substr(pk_libelle.f_lib('QLTE',indvs.qualite),1,25),
		substr(pk_libelle.f_lib('CODC1',indvs.codcourrier1),1,25),
		substr(pk_personne.f_nom(indvs.numindiv,30,0),1,30),
		substr(indvs.nom,1,30),
		substr(indvs.prenom,1,20),
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
		substr(f_pays(indvs.codpays),1,15),
		f_contact(indvs.numindiv, 1),
		f_contact(indvs.numindiv, 3),
		f_contact(indvs.numindiv, 4),
		pers_morale.abrege,
		substr(pk_libelle.f_lib('TT',pers_tiers.type_tiers),1,15),
		substr(pers_tiers.nomp,1,20),
		    pk_personne.f_adresse (
		        pk_personne.f_idadresse (
		            indvs.numindiv, 0, sysdate, 'O', 11 ),
		                            1, indvs.numindiv),
		    pk_personne.f_adresse (
		        pk_personne.f_idadresse (
		            indvs.numindiv, 0, sysdate, 'O', 11 ),
		                            2, indvs.numindiv),
		   	pk_personne.f_adresse (
		        pk_personne.f_idadresse (
		            indvs.numindiv, 0, sysdate, 'O', 11 ),
		                            3, indvs.numindiv),
		   	pk_personne.f_adresse (
		        pk_personne.f_idadresse (
		            indvs.numindiv, 0, sysdate, 'O', 11 ),
		                            4, indvs.numindiv),
		pers_tiers.numdpt||' '||pers_tiers.numactv||' '||
			pers_tiers.numinser||' '||pers_tiers.numcle
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
		t_donnee(23)
	From	pers_morale,
	 	indvs,
		pers_tiers
	Where	pers_morale.numindiv	= indvs.numindiv
	And	indvs.numindiv		= pers_tiers.numindiv
	And	pers_tiers.numtiers 	= a_numindiv;
END;
/
