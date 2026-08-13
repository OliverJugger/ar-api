CREATE procedure ARTHUS.charge_rib ( a_idrib in number,
					   t_donnee out pk_texte.donnee
					    )
is
BEGIN


	Select	rib.numgar,
		substr(pk_libelle.f_lib('OPE',rib.codope),1,15),
		decode(rib.type,1,
			substr(pk_libelle.f_lib('MOPM',rib.modpmt),1,15),
			2,substr(pk_libelle.f_lib('MREGL',rib.modpmt),1,15)),
		codbque||' '||guichet||' '||compte||' '||clerib,
		substr(rib.intitule,1,25),
		d2e(rib.debut),
		substr(pk_libelle.f_lib('DEVISE',rib.devise_compte),1,15),
		substr(pk_libelle.f_lib('DEVISE',rib.devise_ope),1,15)
	Into
		t_donnee(1),
		t_donnee(2),
		t_donnee(3),
		t_donnee(4),
		t_donnee(5),
		t_donnee(6),
		t_donnee(7),
		t_donnee(8)
	From
		rib
	Where
		idrib=a_idrib;
END;
/
