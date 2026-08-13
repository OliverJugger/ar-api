CREATE FUNCTION ARTHUS.QUALEA_F_FORMAT ( P_Chaine   IN   varchar2)
RETURN  varchar2 	deterministic
IS
BEGIN

  RETURN REPLACE(TRANSLATE(UPPER(P_Chaine),'·ŽÔÒÓ×Ø… ƒ„Š‚ˆ‰Œ‹“–êé€â-''','AAEEEEIIaaaaeeeeiiouuUUCO '),' ','');

EXCEPTION
  WHEN OTHERS THEN
    RETURN P_Chaine;
END QUALEA_F_FORMAT;
