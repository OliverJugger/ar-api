CREATE function ARTHUS.va05_xit(
   va05_parametre1   VARCHAR2,
   va05_parametre2   VARCHAR2,
   va05_parametre3   VARCHAR2,
   txtCond 	         VARCHAR2,
   txtForm           VARCHAR2
   )
    RETURN VARCHAR2 AS
        EXTERNAL LIBRARY extProcVA05_XIT
        NAME "va05_xit"
        language C
    PARAMETERS (
	va05_parametre1 STRING,
	va05_parametre2 STRING,
	va05_parametre3 STRING,
      txtCond 	    STRING,
      txtCond         INDICATOR,
      txtForm         STRING,
      RETURN          STRING);
