CREATE function ARTHUS.ca01_xit(
		prchnumfor		BINARY_INTEGER,
		prchedatehospi	DOUBLE PRECISION,
		prchedatapli	DOUBLE PRECISION,
		assunumindiv    BINARY_INTEGER,
		prchidadhesion  BINARY_INTEGER,
		test		    VARCHAR2
		)
    RETURN VARCHAR2 AS
        EXTERNAL LIBRARY extProcCA01_XIT
        NAME "ca01_xit"
        language C
    PARAMETERS (
		prchnumfor      int,
		prchedatehospi	Double,
		prchedatehospi  INDICATOR,
		prchedatapli	Double,
		prchedatapli	INDICATOR,
		assunumindiv	int,
		prchidadhesion	int,
        test            STRING,
        RETURN          STRING);
