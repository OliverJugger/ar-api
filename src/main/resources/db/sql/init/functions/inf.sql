CREATE function ARTHUS.inf(
			a_montant	IN NUMBER,
			a_niveau	IN NUMBER)
	RETURN NUMBER
	AS
		loc_inf number default 0;
BEGIN
   RETURN trunc(a_montant,-a_niveau);
END inf;
