CREATE function ARTHUS.no10_687_proc(
		batch_nom_traitement	VARCHAR2,
		batch_numedit		BINARY_INTEGER,
		batch_nbre_lignes	BINARY_INTEGER,
		test		  		VARCHAR2,
		batch_numporte		BINARY_INTEGER,
		batch_nom_fichier	VARCHAR2,
		batch_nat_fic_imp	BINARY_INTEGER
   )
    RETURN VARCHAR2 AS
        EXTERNAL LIBRARY extProcNO10_687_PROC
        NAME "no10_687_proc"
        language C
    PARAMETERS (
		batch_nom_traitement	STRING,
		batch_numedit		int,
		batch_nbre_lignes	int,
        test            	STRING,
		batch_numporte		int,
		batch_nom_fichier	STRING,
		batch_nat_fic_imp	int,
        RETURN          	STRING);
