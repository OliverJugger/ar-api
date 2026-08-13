CREATE procedure ARTHUS.qttc_revers (
				a_idrevers in number
				)
is
BEGIN
	/* Insertion dans affectation  */
	Insert Into
		affectation(
			codope,
			numaffec,
			dataffec,
			monnaie,
			montant,
			numcli)
	Select 	5,
		reversement.idrevers,
		reversement.datrevers,
		f_param_devise(reversement.numsoc, 0, 0, sysdate),
		reversement.montant,
		f_numorg(reversement.numorg,2)
	From	reversement
	Where	reversement.idrevers = a_idrevers
	;
	Begin
	/* Insertion des comm dans facture  */
	Insert Into
		facture(
			codope,
			numfact,
			numcli,
			datfact,
			monnaie,
			mregl,
			echeance,
			montant)
	Select 	7,
		reversement.idrevers,
		f_numorg(reversement.numorg,2),
		reversement.datrevers,
		f_param_devise(reversement.numsoc, 0, 0, sysdate),
		prmt.dfdev,
		trunc(sysdate),
		sum(qttc_affec_tfc.montant)
	From	prmt,
		reversement,
		qttc_affec_tfc
	Where	reversement.idrevers = a_idrevers
	and	qttc_affec_tfc.tfc = 2
	and	qttc_affec_tfc.prelev_revers = 2
	and	qttc_affec_tfc.idrevers = reversement.idrevers
	Group By
		reversement.idrevers,
		reversement.numorg,
		reversement.datrevers,
		reversement.numsoc,
		prmt.dfdev
	;
	Exception When No_data_found then null;
	End;
	Begin
	/* Insertion des frais dans affectation  */
	Insert Into
		affectation(
			codope,
			numaffec,
			dataffec,
			monnaie,
			numcli,
			montant)
	Select 	6,
		reversement.idrevers,
		reversement.datrevers,
		f_param_devise(reversement.numsoc, 0, 0, sysdate),
		societe.numindiv,
		sum(qttc_affec_tfc.montant)
	From	societe,
		reversement,
		qttc_affec_tfc
	Where	societe.numsoc=reversement.numsoc
	and	reversement.idrevers = a_idrevers
	and	qttc_affec_tfc.tfc in (3, 4)
	and	qttc_affec_tfc.idrevers = reversement.idrevers
	Group By
		6,
		reversement.idrevers,
		reversement.datrevers,
		reversement.numsoc,
		societe.numindiv
	;
	Exception When No_data_found then null;
	End;
END;
/
