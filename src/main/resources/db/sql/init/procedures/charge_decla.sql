CREATE procedure ARTHUS.charge_decla ( a_cle in number,
						a_numgar in number,
						a_debut in date,
						a_fin in date,
					   t_donnee out pk_texte.donnee)
is
loc_libelle varchar2(45);
BEGIN
	Select 	mone.libelle
	Into 	loc_libelle
	From 	mone,
		prmt
	Where	mone.codmon=prmt.dfdev;
	Begin
	select 	sum(qttc_global.mt_affec)||' '||mone.libelle,
		to_char(qttc_global.debut,'yyyy')
	Into
		t_donnee(1),
		t_donnee(6)
	From	qttc_global,
		mone,
		prmt
	Where	qttc_global.numquerable=a_cle
	And	qttc_global.mt_affec!=0
	And	qttc_global.debut between a_debut and a_fin
	And	qttc_global.numgar=a_numgar
	And	mone.codmon=prmt.dfdev
	Group by
		to_char(qttc_global.debut,'yyyy'),
		mone.libelle;
	Exception
		When no_data_found then
				t_donnee(1):=0||' '||loc_libelle;
	End;
	Begin
	select 	sum(decaismt.montant)||' '||mone.libelle,
		to_char(decaismt.datpay,'yyyy')
	Into
		t_donnee(4),
		t_donnee(5)
	From	decaismt,
		affectation,
		decompte_prev,
		adhe_cntrt,
		mone,
		prmt
	Where	decaismt.numdest=a_cle
	And	decaismt.numdecaismt=affectation.numdecaismt
	And	decaismt.refpmt is not null
	And	affectation.numaffec=decompte_prev.numdec
	And	affectation.codope=2
	And	decompte_prev.idadhesion=adhe_cntrt.idadhesion
	And	adhe_cntrt.numgar=a_numgar
	And	adhe_cntrt.numquerable=a_cle
	And	decaismt.datpay between a_debut and a_fin
	And	mone.codmon=prmt.dfdev
	Group by
		to_char(decaismt.datpay,'yyyy'),
		mone.libelle;
	Exception
		When no_data_found then t_donnee(4):=0||' '||loc_libelle;
		t_donnee(5):=to_char(a_fin,'yyyy');
	End;
	Select 	to_char(a_debut,'dd/mm/yyyy'),
		to_char(a_fin,'dd/mm/yyyy')
	Into	t_donnee(2),
		t_donnee(3)
	From	dual;
END;
/
