CREATE function ARTHUS.rb01_proc(
		test		  		VARCHAR2,
		batch_nom_fichier	VARCHAR2
   )
    RETURN VARCHAR2 AS
        EXTERNAL LIBRARY extProcRB01_PROC
        NAME "rb01_proc"
        language C
    PARAMETERS (
        test            	STRING,
		batch_nom_fichier	STRING,
        RETURN          	STRING);
