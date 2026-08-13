CREATE function ARTHUS.f_totcomm(f_numquit IN NUMBER,f_numfor IN NUMBER,
					f_numindiv in number)
	RETURN NUMBER
	AS
		montant number;
	BEGIN
		begin
		select	sum(montant)
		into	montant
		from 	qttc_comm
		where	numquit		= f_numquit
		and	numfor		= f_numfor
		and	numindiv	= f_numindiv
		group by numquit,numfor;
	EXCEPTION
		WHEN NO_DATA_FOUND then montant := 0;
		end;
		RETURN montant;
END f_totcomm;
