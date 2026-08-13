CREATE function ARTHUS.ga02_xit(
	parametre1	VARCHAR2,
	parametre2	VARCHAR2,
	numindiv	BINARY_INTEGER,
	numgar	BINARY_INTEGER,
	adhesion_numfor	BINARY_INTEGER,
	datapli	VARCHAR2,
	idadhesion	BINARY_INTEGER)
    RETURN VARCHAR2 AS
        EXTERNAL LIBRARY extProcGA02_XIT
        NAME "ga02_xit"
        language C
    PARAMETERS (
	parametre1		STRING,
	parametre2		STRING,
	numindiv		int,
	numindiv		INDICATOR,
	numgar			int,
	numgar			INDICATOR,
	adhesion_numfor		int,
	adhesion_numfor		INDICATOR,
	datapli			STRING,
	datapli			INDICATOR,
	idadhesion		int,
	idadhesion		INDICATOR,
	RETURN STRING);
