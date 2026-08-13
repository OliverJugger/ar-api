CREATE function ARTHUS.f_totaffec(	I_numfact IN NUMBER,
					I_codope IN NUMBER,
					I_datope IN Date Default Null)
RETURN NUMBER
IS
mt_affec number;
BEGIN
	select	sum(montant)
	into	mt_affec
	from 	compte_client
	where	codope		= I_codope
	and	numfact		= I_numfact
	and	datope		<= nvl(I_datope, datope)
	and	numencaismt + 0	!= 0;
	RETURN mt_affec;
END f_totaffec;
