CREATE FUNCTION ARTHUS.f_eche_anniv
               (	a_numgar         IN NUMBER,
			a_idadhesion     IN NUMBER,
			a_date_deb_Cotis IN DATE,
			a_ramener        IN NUMBER default 1)
  RETURN NUMBER
	IS
  Loc_Anniversaire	 number default 0;
  Loc_Julien   Number default 0;
  Loc_Temp     varchar2 (17);
/**/
  CURSOR C_ADHE IS
     SELECT ALL ADHE_CNTRT.ECHE_ANNIV, FRACT
           FROM ADHE_CNTRT
      WHERE ADHE_CNTRT.IDADHESION = a_idadhesion;

  R_ADHE C_ADHE%ROWTYPE;
/**/
  CURSOR C_CNTRT IS
     SELECT ALL CONTRAT.ECHE_ANNIV, FRACT
       FROM CONTRAT
      WHERE CONTRAT.NUMGAR = a_numgar;
  R_CNTRT C_CNTRT%ROWTYPE;
/**/
BEGIN
/* Recherche dans la Vue CONTRAT, CONTRAT ou ADHESION COLLECTIVE) */
IF (a_idadhesion) = 0 or (a_idadhesion IS NULL)
   THEN
   OPEN C_CNTRT;
   FETCH C_CNTRT INTO R_CNTRT;
   IF C_CNTRT%NOTFOUND
      THEN
      Loc_Anniversaire := 0;
   ELSE
      IF To_Char (R_CNTRT.ECHE_ANNIV, 'DD-MM') =
         To_Char (a_date_deb_Cotis, 'DD-MM')
        THEN
        Loc_Anniversaire := 1;
      ELSE
        Loc_Anniversaire := 0;
      END IF;
      /* Calcul de la date JULIEN de la date échéance anniversaire de l'exercice */
      Loc_Temp := (To_Char (R_CNTRT.ECHE_ANNIV, 'DD-MM') ||  '-' ||
                   To_Char (a_date_deb_Cotis, 'YYYY'));
      LOC_Julien := D2J(To_Date(Loc_Temp, 'DD-MM-YYYY'));

	  /* ajustement de loc_anniversaire si sur découpage glissant 31/12 */
	  if To_Char (a_date_deb_Cotis, 'DD-MM') = '01-01' then

			if add_months(j2d(LOC_Julien),-12+R_CNTRT.FRACT) > a_date_deb_Cotis then
				Loc_Anniversaire := 1;
			end if;

	  end if;

   END IF;
   CLOSE C_CNTRT;
ELSE
/* Recherche dans la table  ADHESION) */
   OPEN C_ADHE;
   FETCH C_ADHE INTO R_ADHE;
   IF C_ADHE%NOTFOUND
      THEN
      Loc_Anniversaire := 0;
   ELSE
      IF To_Char (R_ADHE.ECHE_ANNIV, 'DD-MM') =
         To_Char (a_date_deb_Cotis, 'DD-MM')
        THEN
        Loc_Anniversaire := 1;
      ELSE
        Loc_Anniversaire := 0;
      END IF;
   END IF;
   CLOSE C_ADHE;
   /* Calcul de la date JULIEN de la date échéance anniversaire de l'exercice */
      Loc_Temp := (To_Char (R_ADHE.ECHE_ANNIV, 'DD-MM') || '-' ||
                   To_Char (a_date_deb_Cotis, 'YYYY'));
      LOC_Julien := D2J(To_Date(Loc_Temp, 'DD-MM-YYYY'));

	  /* ajustement de loc_anniversaire si sur découpage glissant 31/12 */
	  if To_Char (a_date_deb_Cotis, 'DD-MM') = '01-01' then

			if add_months(j2d(LOC_Julien),-12+R_ADHE.FRACT) > a_date_deb_Cotis then
				Loc_Anniversaire := 1;
			end if;

	  end if;

END IF;
/*--*/
IF a_ramener = 1 THEN
   RETURN (Loc_Anniversaire);
ELSE
   RETURN (Loc_Julien);
END IF;
/*--*/
END;
