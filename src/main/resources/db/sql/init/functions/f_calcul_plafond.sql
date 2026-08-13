CREATE function ARTHUS.f_calcul_plafond(a_type in number,
					a_montant in number,
					a_indice in number,
					a_taux in number,
					a_nbindice in number,
					a_datsin in date,
					a_nbacte in number default 0)
Return number as
loc_retour number;
loc_valeur number;
Begin
If (a_type=1)
Then
	If (a_montant!=0)
	Then
		loc_retour:=a_montant;
	Elsif (a_indice!=0)
	Then
	  SELECT indcs.valeur
	  INTO loc_valeur
	  FROM indcs
	  WHERE indcs.indice=a_indice
	  AND indcs.datapli!=
		nvl(indcs.datper,indcs.datapli+1)
	  AND a_datsin between indcs.datapli and
	    nvl(indcs.datper,a_datsin);
	SELECT
	  decode(a_taux,0,a_nbindice,a_taux/100)*(loc_valeur)
	INTO loc_retour
	FROM dual;
	End if;
Elsif (a_type=2)
Then
	If (a_nbacte!=0)
	Then
		loc_retour:=a_nbacte;
	End if;
End if;
Return(loc_retour);
End;
