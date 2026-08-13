CREATE function ARTHUS.f_tottaxe(f_numquit IN NUMBER,f_numfor IN NUMBER)
	RETURN NUMBER
	AS
		montant number;
	BEGIN
		begin
		select	sum(montant)
		into	montant
		from 	qttc_taxe
		where	numquit		= f_numquit
		and	numfor		= f_numfor
		group by numquit,numfor;
	EXCEPTION
		WHEN NO_DATA_FOUND then montant := 0;
		end;
		RETURN montant;
END f_tottaxe;
