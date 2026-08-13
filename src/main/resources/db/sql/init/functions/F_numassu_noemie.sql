CREATE function ARTHUS.F_numassu_noemie (p_numindiv individu.numindiv%TYPE) RETURN NUMBER IS
 loc_numassu individu.numindiv%TYPE;
BEGIN
 BEGIN
    SELECT DISTINCT i2.numindiv
      INTO loc_numassu
      FROM individu i1, individu i2
     WHERE i1.matorg=i2.matorg
       AND i2.natur = 1
       AND i2.numindiv <> i1.numindiv
       AND i1.numindiv=p_numindiv;
    
  EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        loc_numassu := NULL;
     WHEN TOO_MANY_ROWS
     THEN
        loc_numassu := NULL;
  END;
  RETURN NVL( loc_numassu,f_numassu(p_numindiv));


END F_numassu_noemie;
