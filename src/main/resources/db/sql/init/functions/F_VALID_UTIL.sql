CREATE FUNCTION ARTHUS.F_VALID_UTIL
( p_nom_util  IN VARCHAR2 ) RETURN BOOLEAN
AS
  v_date_fin  utilisateurs.date_fin%TYPE;
BEGIN
  SELECT date_fin
    INTO v_date_fin
    FROM utilisateurs
   WHERE UPPER(nom) = UPPER(p_nom_util);

  IF ( v_date_fin IS NOT NULL
    AND v_date_fin < TRUNC(sysdate)  ) THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN TRUE;
END F_VALID_UTIL;
