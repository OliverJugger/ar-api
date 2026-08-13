CREATE FUNCTION ARTHUS.ALGO_SIRET( SIRET varchar2 ) RETURN INT IS
    /***********************************************************************

	     Auteur   : Jérémy RUELLE (ARES)
    	 Date     : 01/06/2004
    	 Objet    : Fonction permettant de dire si un SIREN ou SIRET est valide

		 Paramètres :
		 ------------
		   SIRET            --Obligatoire

		 Retour de type numérique :
		 ------------------------
		 	1 si SIREN ou SIRET est valide
			-1 si non numérique
            0 sinon

	************************************************************************/

	var_siren varchar2(9);
	var_siret varchar2(14);
	result    int := 1;
	somme	  int := 0;
	pair      int;
	impair    int;
	nombre    number(14);

BEGIN

  /* Si paramètre est null, on retourne 0 */
  if SIRET is null then
    result := 0;
    goto FIN;
  end if;

  /* Si la longueur du paramètre est supèrieur à 14, retour 0*/
  if length ( SIRET ) > 14 then
    result := 0;
    goto FIN;
  end if;

  /* Si ce n'est pas une chaine numérique, on retourne -1 */
  begin

	nombre := to_number ( SIRET );

  exception
    when others then
	result := -1;
	goto FIN;

  end;

  /* Si il y a une virgule, on retourne zéro */
  if mod ( to_number( SIRET ),1 ) <> 0 then
    result := -1;
	goto FIN;
  end if;

  /* On ajoute des zéros devant la chaîne de caractères suivant la longueur du paramètre */
  if length ( SIRET ) > 9 then

	var_siret := LPAD(SIRET,14,'0');
	var_siren := substr(var_siret,1,9);

	/* Si le NIC = '00000', alors on met le NIC à null */
	if substr(var_siret,10,5) = '00000' then
	  var_siret := null;
	end if;

  else

	var_siret := null;
	var_siren := LPAD(SIRET,9,'0');

  end if;

  /* Vérification de la validité du SIREN */
  somme := to_number(substr(var_siren,1,1)) + to_number(substr(var_siren,3,1)) + to_number(substr(var_siren,5,1)) + to_number(substr(var_siren,7,1));
  for i in 1..4
  loop

    pair := 2*to_number(substr(var_siren,i*2,1));

    if ( pair >= 10 ) then
      pair := ( pair - 9 );
	end if;

    somme := somme + pair;

  end loop;

  if to_number(substr(var_siren,9,1)) <> ( 10 - ( mod ( somme,10 ) ) ) then
    result := 0;
  end if;

  if to_number(substr(var_siren,9,1)) = 0 and mod ( somme,10 ) = 0 then
    result := 1;
  end if;

  if result = 0 then
    goto fin;
  end if;

  /* Vérification de la validité du SIRET */
  if var_siret is not null then

    somme := 0;

    somme := to_number(substr(var_siret,2,1)) + to_number(substr(var_siret,4,1)) + to_number(substr(var_siret,6,1)) + to_number(substr(var_siret,8,1)) + to_number(substr(var_siret,10,1)) + to_number(substr(var_siret,12,1));

    for i in 1..7
    loop

      impair := 2*to_number(substr(var_siret,i*2-1,1));

      if ( impair >= 10 ) then
        impair := ( impair - 9 );
	  end if;

      somme := somme + impair;

    end loop;

    if to_number(substr(var_siret,14,1)) <> ( 10 - ( mod ( somme,10 ) ) ) then
      result := 0;
    end if;

    if to_number(substr(var_siret,14,1)) = 0 and mod ( somme,10 ) = 0 then
      result := 1;
    end if;

  end if;

  <<FIN>>
  null;

  return(result);


END;
