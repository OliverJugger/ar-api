CREATE FUNCTION ARTHUS.F_SEL_date_effet( I_numgar IN histo_contrat.numgar%TYPE )
RETURN DATE
IS
 CURSOR C_histo_contrat IS
       Select debut
       From   histo_contrat
       Where  numgar = I_numgar
       And    etat IN (0, 1)
       and    annul = 'N' -- M0006541
       Order by
	etat desc,
	debut asc;
--
L_debut histo_contrat.debut%TYPE;
--
BEGIN
  OPEN  C_histo_contrat;
  FETCH C_histo_contrat INTO L_debut;
  CLOSE C_histo_contrat;
  RETURN L_debut;
END;
