CREATE Function ARTHUS.f_pays_def (a_numindiv 	in Number )
Return Number
Is
 Cursor C_pays_defaut Is
    Select pers_adresse.codpays
    From   pers_adresse,
	   indvs
    Where   pers_adresse.numindiv=a_numindiv
    And     indvs.numindiv = pers_adresse.numindiv
    And     pers_adresse.defaut='O';

  a_pays  pers_adresse.codpays%type;

BEGIN
    OPEN   C_pays_defaut;
    FETCH  C_pays_defaut INTO a_pays;
    If C_pays_defaut%Notfound Then
       a_pays:=0;
    End If;
    CLOSE  C_pays_defaut;
    RETURN a_pays;
END;
