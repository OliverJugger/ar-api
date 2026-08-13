CREATE FUNCTION ARTHUS.F_CAISSE (a_numindiv IN NUMBER)
   RETURN NUMBER
AS
   i_Result   NUMBER DEFAULT 0;
BEGIN

  SELECT t.NumIndiv
    INTO i_Result
    FROM TrPnt t, Indvs i
   WHERE t.Caisse = i.Caisse
     AND TO_CHAR(t.Regime,'00') = TO_CHAR(i.Regime,'00')
   AND i.NumIndiv= a_numindiv
     AND t.Type_Tiers = 1;

  RETURN i_Result;

EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN 0;
END F_CAISSE;
