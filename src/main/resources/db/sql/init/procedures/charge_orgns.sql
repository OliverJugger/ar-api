CREATE procedure ARTHUS.charge_orgns ( a_numindiv in number,
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
		indvs.tel,
		indvs.fax,
		indvs.email,
		pers_morale.abrege,
		pers_organisme.prescr,
		pers_organisme.entete1,
		pers_organisme.entete2,
		pers_organisme.entete3
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
		t_donnee(20)
	From 	indvs,
		pers_organisme,
		pers_morale
	Where	pers_organisme.numorg=a_numindiv
	And	pers_morale.numindiv=indvs.numindiv
	And	pers_organisme.numindiv=indvs.numindiv;
END;
/
