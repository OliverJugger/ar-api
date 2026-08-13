CREATE function ARTHUS.gs19_proc(
		batch_numedit	BINARY_INTEGER,
		test		  	VARCHAR2,
		sid				BINARY_INTEGER
   )
    RETURN VARCHAR2 AS
        EXTERNAL LIBRARY extProcGS19_PROC
        NAME "gs19_proc"
        language C
    PARAMETERS (
		batch_numedit	int,
        test            STRING,
		sid				int,
        RETURN          STRING);
