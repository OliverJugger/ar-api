CREATE function ARTHUS.f_totaffec_d(	I_numfact IN NUMBER,
					I_codope IN NUMBER,
					I_datope IN Date Default Null)
RETURN NUMBER
IS
mt_affec_d number;
BEGIN
	select	sum(montant_d)
	into	mt_affec_d
	from 	compte_client
	where	codope		= I_codope
	and	numfact		= I_numfact
	and	datope		<= nvl(I_datope, datope)
	and	numencaismt + 0	!= 0;
	RETURN mt_affec_d;
END f_totaffec_d;
