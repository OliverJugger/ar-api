CREATE FUNCTION ARTHUS.F_IS_ALL_LIEN_GED_CHECKED(i_idrappel number, i_numporte number default 25) RETURN NUMBER IS
code_retour number :=0;
BEGIN

  SELECT DISTINCT 2216
  INTO code_retour
  FROM lien_ged
  WHERE ref_ext = i_idrappel
  AND src = i_numporte
  AND etat not in (2,3);

RETURN code_retour;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  return 0;
END F_IS_ALL_LIEN_GED_CHECKED;
