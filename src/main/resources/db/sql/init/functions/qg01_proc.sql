CREATE function ARTHUS.qg01_proc(
		batch_numedit		BINARY_INTEGER,
		test		  		VARCHAR2)
    RETURN VARCHAR2 AS
        EXTERNAL LIBRARY extProcQG01_PROC
        NAME "qg01_proc"
        language C
    PARAMETERS (
		batch_numedit		int,
        test            	STRING,
	RETURN STRING);
