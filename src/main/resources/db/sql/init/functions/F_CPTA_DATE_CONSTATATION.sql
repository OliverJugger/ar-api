CREATE function ARTHUS.F_CPTA_DATE_CONSTATATION (I_codope In Number, I_cle In Number)
Return     DATE
As    loc_date       DATE;
BEGIN

BEGIN
  -- Si prestation sante, on renvoie la date du decompte
  If I_codope = 1 Then
    Select  datpay
      Into  loc_date
      From  v_decompte_cpta
     Where  numdec = I_cle;
  End If;

  -- Si cotisation, on renvoie la date de premiere emission de la facture
  If I_codope = 4 Then
    Select  datemis
      Into  loc_date
      From  emission
     Where  numfact    = I_cle
     And    codope     = I_codope
     And    numrelance = 0;
  End If;

  -- Si commission a percevoir, on renvoie la date de creation du bordereau de reversement de prime associe
  If I_codope = 7 Then
    Select  datvalide
      Into  loc_date
      From  reversement
     Where  idrevers   = I_cle;
  End If;

END;

IF  loc_date IS NULL THEN
  loc_date  := (sysdate + 365);
END IF;

RETURN loc_date;

END  F_CPTA_DATE_CONSTATATION;
