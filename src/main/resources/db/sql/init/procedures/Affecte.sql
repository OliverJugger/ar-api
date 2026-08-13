CREATE procedure ARTHUS.Affecte (
				a_idaffec 	in Number,
				a_codope 	in Number,
				a_numfact 	in Number,
				a_numcli 	in Number,
				a_numencaismt 	in Number,
				a_montant 	in Number,
				a_montant_d in Number,
				a_monnaie	in Number,
				a_monnaie_d in Number
				)
Is
BEGIN
/* Insertion dans compte client */

Insert Into
compte_client(	idaffec,
		codope,
		numcli,
		numfact,
		numencaismt,
		montant,
		montant_d,
		monnaie,
		monnaie_d,
		idcompta,
		datope)
Values    	(a_idaffec,
       		a_codope,
		a_numcli,
       		a_numfact,
		a_numencaismt,
		a_montant,
		a_montant_d,
		a_monnaie,
		a_monnaie_d,
		-1,
		trunc(sysdate));

/*  Si affectation d'une quittance  */
If ( a_codope = 4 ) then
   	 Insert Into qttc_affec
		(idaffec, idgar, numquit, numfor, numindiv, montant, idrevers, montant_d,monnaie, monnaie_d)
		Values	(a_idaffec,
			0,
			a_numfact,
			-1,
			0,
			a_montant,
			0,
			a_montant_d,
			a_monnaie,
			a_monnaie_d
			);

   	 Update	qttc_global
		 SET	qttc_global.mt_affec = nvl(qttc_global.mt_affec,0)+ a_montant,
				qttc_global.mt_affec_d = nvl(qttc_global.mt_affec_d,0)+ a_montant_d
		 WHERE	qttc_global.numquit = a_numfact;
End if;
END;
/
