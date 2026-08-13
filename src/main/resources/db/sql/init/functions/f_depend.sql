CREATE function ARTHUS.f_depend(
		a_role		IN NUMBER,
		a_numde		IN NUMBER,
		a_numenvers	IN NUMBER,
		a_date		IN NUMBER)
	RETURN NUMBER
	AS
		loc_depend number;
BEGIN
   loc_depend := 0;
if (a_numde > 0) then
	SELECT	COUNT(*)
	INTO	loc_depend
	FROM	dependance
	WHERE	dependance.role = decode(a_role,
			0,dependance.role,
			a_role)
	AND	dependance.numde = a_numde
	AND	dependance.numenvers = decode(a_numenvers,
			0,dependance.numenvers,
			a_numenvers)
	AND	to_date(a_date,'j')
			BETWEEN	dependance.datapli
		  	AND	nvl(dependance.datper,
				    to_date(a_date,'j'));
else
	SELECT	COUNT(*)
	INTO	loc_depend
	FROM	dependance
	WHERE	dependance.role = decode(a_role,
			0,dependance.role,
			a_role)
	AND	dependance.numde = decode(a_numde,
			0,dependance.numde,
			a_numde)
	AND	dependance.numenvers = a_numenvers
	AND	to_date(a_date,'j')
			BETWEEN	dependance.datapli
		  	AND	nvl(dependance.datper,
				    to_date(a_date,'j'));
end if;
	if (loc_depend > 0)	then
		loc_depend := 1;
	else
		loc_depend := 0;
	end if;
	RETURN loc_depend;
END f_depend;
