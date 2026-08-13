CREATE function ARTHUS.qg05_xit(
	pva01_numquit	BINARY_INTEGER,
	param1	VARCHAR2,
	param2	VARCHAR2,
	param3	VARCHAR2)
    RETURN VARCHAR2 AS
        EXTERNAL LIBRARY extProcQG05_XIT
        NAME "qg05_xit"
        language C
    PARAMETERS (
	pva01_numquit	int,
	param1		STRING,
	param2		STRING,
	param3		STRING,
	RETURN STRING);
