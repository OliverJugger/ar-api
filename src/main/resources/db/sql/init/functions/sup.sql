CREATE function ARTHUS.sup(
			a_montant	IN NUMBER,
			a_niveau	IN NUMBER)
	RETURN NUMBER
	AS
		loc_sup number default 0;
BEGIN
	loc_sup := ceil( a_montant / power(10,a_niveau) )*power(10,a_niveau);
	RETURN loc_sup;
END sup;
