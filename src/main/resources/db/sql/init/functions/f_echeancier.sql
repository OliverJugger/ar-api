CREATE function ARTHUS.f_echeancier(a_numgar in number,a_numindiv in number,
					a_debut in date,a_numquit in number,
					a_codprel in number)
Return number
as
loc_echeancier number default 0;
Begin
	select	1
	into	loc_echeancier
	from	qttc_global
	where	numquit = a_numquit
	and	(numeche = 1
		 or
		 comptant = 'C'
		 or
		 prelev != 2)
	UNION
	select	1
	from	facture_regul
	where	facture_regul.codope = 4
	and	facture_regul.numfact = a_numquit
	UNION
	select	1
	from	qttc_global
	where	numgar = a_numgar
	and	numindiv = a_numindiv
	and	debut < a_debut
	and	comptant != 'R'
	and	prelev != 2
	and	a_codprel = 2
	and  	debut = (select	max(debut)
			 from	qttc_global
			 where	numgar = a_numgar
			 and	numindiv = a_numindiv
			 and	debut < a_debut
			 and	comptant != 'R')
	;
	Return(loc_echeancier);
	Exception
		When no_data_found then
				loc_echeancier:=0;
				return(loc_echeancier);
End;
