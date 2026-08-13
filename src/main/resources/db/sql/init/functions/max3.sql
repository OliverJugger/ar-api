CREATE function ARTHUS.max3(a_un number,a_deux number,a_trois number)
	RETURN NUMBER
	AS
BEGIN
	RETURN greatest(a_un,a_deux,a_trois);
END max3;
