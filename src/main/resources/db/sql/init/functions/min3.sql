CREATE function ARTHUS.min3(a_un number,a_deux number,a_trois number)
	RETURN NUMBER
	AS
BEGIN
	RETURN least(a_un,a_deux,a_trois);
END min3;
