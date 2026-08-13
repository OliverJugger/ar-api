CREATE procedure ARTHUS.charge_prch ( a_numpc in number,
					   t_donnee out pk_texte.donnee)
is
BEGIN
	Select 	prch.numpc,
		prch.numindiv,
		prch.numassu,
		prch.numtiers,
		d2e(prch.datehospi),
		substr(pk_libelle.f_lib('DESTI',prch.typedest),1,15),
		prch.numentree,
		prch.numfact,
		ind(calcul_cp.x,prch.datehospi),
		f_conso_reste(prch.numfor,prch.numindiv,
			porte_natfrais_cp.codfrais,prch.datehospi),
		ind(calcul_fj.x,prch.datehospi),
		f_conso_reste(prch.numfor,prch.numindiv,
			porte_natfrais_fj.codfrais,prch.datehospi),
		to_char(prch.datehospi,'yyyy')
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
		t_donnee(14)
	From	prch,
		calcul calcul_cp,
		calcul calcul_fj,
		porte_natfrais porte_natfrais_cp,
		porte_natfrais porte_natfrais_fj
	Where	prch.numpc=a_numpc
	And 	porte_natfrais_cp.numporte= 0
	And	calcul_cp.codfrais= porte_natfrais_cp.codfrais
	And	porte_natfrais_cp.codfrais_porte= 'SHO'
	And	calcul_cp.numfor=prch.numfor
	And	prch.datehospi between calcul_cp.datapli
		and nvl(calcul_cp.datper,prch.datehospi)
	And 	porte_natfrais_fj.numporte= 0
	And	calcul_fj.codfrais= porte_natfrais_fj.codfrais
	And	porte_natfrais_fj.codfrais_porte= 'FJ'
	And	prch.datehospi between calcul_fj.datapli
		and nvl(calcul_fj.datper,prch.datehospi)
	And	calcul_fj.numfor=prch.numfor
	Union
	Select 	prch.numpc,
		prch.numindiv,
		prch.numassu,
		prch.numtiers,
		d2e(prch.datehospi),
		substr(pk_libelle.f_lib('DESTI',prch.typedest),1,15),
		prch.numentree,
		prch.numfact,
		0,
		0,
		0,
		0,
		to_char(prch.datehospi,'yyyy')
	From	prch
	Where	prch.numpc=a_numpc
	And not exists
		(Select 1 from
		calcul calcul_cp,
		calcul calcul_fj,
		porte_natfrais porte_natfrais_cp,
		porte_natfrais porte_natfrais_fj
			Where	prch.numpc=a_numpc
			And 	porte_natfrais_cp.numporte= 0
			And	calcul_cp.codfrais= porte_natfrais_cp.codfrais
			And	porte_natfrais_cp.codfrais_porte= 'SHO'
			And	calcul_cp.numfor=prch.numfor
			And	prch.datehospi between calcul_cp.datapli
				and nvl(calcul_cp.datper,prch.datehospi)
			And 	porte_natfrais_fj.numporte= 0
			And	calcul_fj.codfrais= porte_natfrais_fj.codfrais
			And	porte_natfrais_fj.codfrais_porte= 'FJ'
			And	prch.datehospi between calcul_fj.datapli
				and nvl(calcul_fj.datper,prch.datehospi)
			And	calcul_fj.numfor=prch.numfor
		);
END charge_prch;
/
