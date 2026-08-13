CREATE function ARTHUS.depend(
		a_role		IN NUMBER,
		a_numde		IN NUMBER,
		a_numenvers	IN NUMBER,
		a_date		IN DATE)
	RETURN NUMBER
	AS
		loc_depend number;
BEGIN
   loc_depend := 0;
   begin
	if (a_numde > 0)
	then
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
		AND	a_date
				BETWEEN	dependance.datapli
		  		AND	nvl(dependance.datper,
				    	a_date);
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
		AND	a_date
				BETWEEN	dependance.datapli
		  		AND	nvl(dependance.datper,
				    	a_date);
	end if;
	EXCEPTION
	when NO_DATA_FOUND then loc_depend := 0;
   end;
   if (loc_depend > 0)	then
	loc_depend := 1;
   else
	loc_depend := 0;
   end if;
   RETURN loc_depend;
END depend;
