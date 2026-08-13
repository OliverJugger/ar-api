CREATE function ARTHUS.max2(a_un number,a_deux number)
	RETURN NUMBER
	AS
BEGIN
	RETURN greatest(a_un,a_deux);
END max2;
