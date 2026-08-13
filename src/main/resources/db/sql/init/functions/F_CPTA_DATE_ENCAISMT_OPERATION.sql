CREATE function ARTHUS.F_CPTA_DATE_ENCAISMT_OPERATION (I_numencaismt    In Number)
Return     DATE
As    loc_date              DATE;
      loc_bdx               NUMBER;
      loc_encaismt encaismt%ROWTYPE;
BEGIN

  BEGIN
    SELECT  *
      INTO  loc_encaismt
      FROM  encaismt
     WHERE  numencaismt = I_numencaismt;
  END;

  BEGIN
    SELECT  f_cpta_en(I_numencaismt)
      INTO  loc_bdx
      FROM  dual;
  EXCEPTION WHEN NO_DATA_FOUND THEN loc_bdx := 1;
  END;

  IF loc_bdx= 1 THEN
    loc_date   := loc_encaismt.creation;
  ELSE
    BEGIN
      SELECT remise_globale.daterem
        INTO loc_date
        FROM remise_globale
             ,remise_banque
       WHERE remise_banque.numencaismt = I_numencaismt
         AND remise_globale.numremise  = remise_banque.numremise
    UNION
      SELECT remise_prelev.date_prelev
        FROM prelevement
             ,remise_prelev
       WHERE prelevement.numencaismt  = I_numencaismt
         AND prelevement.numremise    = remise_prelev.numremise;
    END;
  END IF;

  IF  loc_date IS NULL THEN
   loc_date  := (sysdate + 365);
  END IF;

  RETURN loc_date;

END  F_CPTA_DATE_ENCAISMT_OPERATION;
