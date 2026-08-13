CREATE function ARTHUS.rs01_proc(
		batch_numedit		BINARY_INTEGER,
		test		  		VARCHAR2
   )
    RETURN VARCHAR2 AS
        EXTERNAL LIBRARY extProcRS01_PROC
        NAME "rs01_proc"
        language C
    PARAMETERS (
		batch_numedit		int,
        test            	STRING,
        RETURN          	STRING);
