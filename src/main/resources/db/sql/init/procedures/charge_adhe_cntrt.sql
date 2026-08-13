CREATE procedure ARTHUS.charge_adhe_cntrt ( a_idadhesion in number,
						t_donnee out pk_texte.donnee)
is
loc_tableau pk_texte.donnee;
BEGIN
loc_tableau :=f_qttc_comptant(a_idadhesion);
	Begin
	Select 	adhe_cntrt.idadhesion,
		adhe_cntrt.numadhe,
		adhe_cntrt.numquerable,
		adhe_cntrt.ref_ext,
		d2e(adhe_cntrt.dsous),
		d2e(adhe_cntrt.date_fin_adhe),
		substr(pk_libelle.f_lib('FRAC',adhe_cntrt.fract),1,15),
		substr(pk_libelle.f_lib('MREGL',adhe_cntrt.mregl),1,15),
		pk_libelle.f_lib('USER',adhe_cntrt.numutil),
		d2e(adhe_cntrt.date_adhe),
		substr(pk_libelle.f_lib('ET_ADHE',f_etat_adhe(a_idadhesion,sysdate)),1,15),
		substr(pk_libelle.f_lib('HISTO_ADHE',
					f_etat_adhe(a_idadhesion,sysdate,2)),1,15),
		to_char(round(f_qttc_annuelle(a_idadhesion,sysdate,2),1),
					'999999999.90'),
		loc_tableau(1),
		loc_tableau(2),
		loc_tableau(3),
		d2e(j2d(f_etat_adhe(a_idadhesion,greatest(date_adhe,sysdate),
									3))),
		f_convert_montant(
		to_char(round(f_qttc_annuelle(a_idadhesion,sysdate,2),1),
					'999999999.90'),
		prmt.dfdev,prmt.dfsoc,sysdate),
		f_convert_montant(loc_tableau(1),prmt.dfdev,prmt.dfsoc,sysdate)
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
		t_donnee(18),
		t_donnee(20),
		t_donnee(21)
	From	adhe_cntrt,prmt
	Where	adhe_cntrt.idadhesion=a_idadhesion;
	End;
END;
/
