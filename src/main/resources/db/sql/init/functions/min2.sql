CREATE function ARTHUS.min2(a_un number,a_deux number)
	RETURN NUMBER
	AS
BEGIN
	RETURN least(a_un,a_deux);
END min2;
