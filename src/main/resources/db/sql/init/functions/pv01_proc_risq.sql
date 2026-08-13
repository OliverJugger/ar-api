CREATE FUNCTION ARTHUS.pv01_proc_risq (
        batch_numedit		BINARY_INTEGER,
		test		  		VARCHAR2,
		batch_etendue		BINARY_INTEGER,
		numsindeb			VARCHAR2,
		numsinfin			VARCHAR2,
		numrisqdeb			VARCHAR2,
		numrisqfin			VARCHAR2,
		param1				VARCHAR2,
		param2				VARCHAR2
)
   RETURN VARCHAR2
AS
EXTERNAL
   LIBRARY extprocpv01_proc
   NAME "pv01_proc"
   LANGUAGE c
   PARAMETERS (
        batch_numedit		int,
        test            	STRING,
		batch_etendue		int,
		numsindeb			STRING,
	    numsindeb		   	INDICATOR,
		numsinfin			STRING,
	    numsinfin		   	INDICATOR,
		numrisqdeb			STRING,
	    numrisqdeb		   	INDICATOR,
		numrisqfin			STRING,
	    numrisqfin		   	INDICATOR,
		param1				STRING,
		param1				INDICATOR,
		param2				STRING,
		param2				INDICATOR,
      RETURN STRING
   );
