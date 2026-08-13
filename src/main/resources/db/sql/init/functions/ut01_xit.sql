CREATE FUNCTION ARTHUS.ut01_xit(
   type_action    VARCHAR2,
   util_nom       VARCHAR2,
   util_password  VARCHAR2,
   util_profil    VARCHAR2,
   trace_level    VARCHAR2)
    RETURN VARCHAR2 AS
        EXTERNAL LIBRARY extProcUT01_XIT
        NAME "ut01_xit"
        LANGUAGE C
    PARAMETERS (
   type_action    STRING,
   util_nom       STRING,
   util_password  STRING,
   util_password  INDICATOR SHORT,
   util_profil    STRING,
   util_profil    INDICATOR SHORT,
   trace_level    STRING,
   RETURN         STRING);
