CREATE function ARTHUS.f_etat_adhe_sin(
			a_idadhesion	IN NUMBER,
			a_date		IN DATE,
			a_type in number default 1)
	RETURN NUMBER
	AS

/*===========================================================================*/
/* Fonction     : F_ETAT_ADHE_SIN.sql                                        */
/* Domaine      : ADHESION individuelle                                      */
/* Version      : V1.0                                                       */
/* Auteur       : ARTHUS                                                     */
/* Création     : DD/MM/AAAA                                                 */
/* Description  : Recherche de l'état adhésion pour validation calcul santé  */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : PHA/ 12/04/2017 / correction du tri dans curseur M0005297: */
/*     Changement etat adhesion multiple meme journee bloque le calcul sante */
/*                Remplacer :  order by debut desc , datsai desc             */
/*                Par       :  order by datsai desc, idhistoadhe desc        */
/*===========================================================================*/


		loc_etat	 number default 0;
	cursor fetch_adhe is
		select	histo_adhesion.etat,histo_adhesion.debut
		from	histo_adhesion
		where	idadhesion = a_idadhesion
		and	debut <= a_date
		order by TRUNC(datsai) desc, idhistoadhe desc
		;
loc_debut date;
BEGIN
   loc_etat := 0 ;
   begin
	Open fetch_adhe;
	Fetch fetch_adhe into loc_etat,loc_debut;
	if (fetch_adhe%NOTFOUND) then
	loc_etat:=0;
	end if;
		If (loc_etat=3)
		Then
			if (a_date>loc_debut)
			then
				loc_etat:=3;
			else
				loc_etat:=1;
			end if;
		end if;
	Close fetch_adhe;
   end;
   return loc_etat;
END f_etat_adhe_sin;
