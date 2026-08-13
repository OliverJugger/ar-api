CREATE function ARTHUS.no06_proc(
		batch_numedit		BINARY_INTEGER,
		test		  		VARCHAR2,
		batch_numporte		BINARY_INTEGER,
		batch_nom_fichier	VARCHAR2,
		batch_nat_fic_imp	BINARY_INTEGER
   )
    RETURN VARCHAR2 AS
        EXTERNAL LIBRARY extProcNO06_PROC
        NAME "no06_proc"
        language C
    PARAMETERS (
		batch_numedit		int,
        test            	STRING,
		batch_numporte		int,
		batch_nom_fichier	STRING,
		batch_nat_fic_imp	int,
        RETURN          	STRING);
