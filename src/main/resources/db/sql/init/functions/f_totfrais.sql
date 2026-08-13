CREATE function ARTHUS.f_totfrais(f_numquit IN NUMBER)
	RETURN NUMBER
	AS
		montant number;
	BEGIN
		begin
		select	sum(montant)
		into	montant
		from 	qttc_frais
		where	numquit		= f_numquit;
	EXCEPTION
		WHEN NO_DATA_FOUND then montant := 0;
		end;
		RETURN montant;
END f_totfrais;
