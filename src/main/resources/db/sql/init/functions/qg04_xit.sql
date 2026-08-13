CREATE function ARTHUS.qg04_xit(
	parametre1	VARCHAR2,
	numquit		BINARY_INTEGER)
    RETURN VARCHAR2 AS
        EXTERNAL LIBRARY extProcQG04_XIT
        NAME "qg04_xit"
        language C
    PARAMETERS (
	parametre1		STRING,
	numquit			int,
	RETURN STRING);
