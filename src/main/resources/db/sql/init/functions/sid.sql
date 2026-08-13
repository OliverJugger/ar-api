CREATE function ARTHUS.sid
	RETURN NUMBER
	AS
		loc_sid number;
BEGIN
	return userenv('SESSIONID');
END sid;
