CREATE function ARTHUS.f_fra_dep
(	p_PDSQLF in number,
	p_SPEC_EXE in number,
	p_codfrais in varchar2,
	p_datsin in date,
	p_mtfrais in number,
	p_baseremb in number,
	p_nbacte in number)
	return number
as
/*
** Calcul de la franchise de d¿passement pour une prestation qualifi¿e Hors parcours
*/

	v_montant param_actes_pds.montant%type;
	v_franchise NUMBER(11,2) := 0;
	v_code libelle_bis.code%type;
	v_code2 libelle_bis.code%type;

	cursor c_lib is
	select code from libelle_bis
	where mnemo = 'SPEC' and code = p_SPEC_EXE;

	cursor c_lib_exclu is
	select code from libelle_bis
	where mnemo = 'SPEC_EXCLU' and code = p_SPEC_EXE;

	cursor c_actes_pds is
	select pa1.MONTANT
	from param_actes_pds pa1
	where pa1.TYPE = 2
	and pa1.DATAPPLI = (select max(pa2.DATAPPLI)
						from param_actes_pds pa2
						where pa2.codfrais = p_codfrais
						and pa2.TYPE=2
						and pa2.DATAPPLI <= p_datsin)
	and pa1.CODFRAIS = p_codfrais;


Begin
/* R¿gle de calcul : PDSQLF =2 */
	If p_PDSQLF != 2 then return(0);
	End if;

/* R¿gle de calcul : SPEC_EXE doit ¿tre pr¿sent dans les mnemo SPEC de la table LIBELLE_BIS */
	open c_lib;
		fetch c_lib into v_code;
	If c_lib%NOTFOUND then return(0);
	End if;
	close c_lib;

/* R¿gle de calcul : SPEC_EXE ne doit pas ¿tre pr¿sent dans les mnemo SPEC_EXCLU de la table LIBELLE_BIS */
	open c_lib_exclu;
		fetch c_lib_exclu into v_code2;
	If c_lib_exclu%FOUND then return(0);
	End if;
	close c_lib_exclu;

/* D¿termination du montant dans la table PARAM_ACTES_PDS */
	open c_actes_pds;
		fetch c_actes_pds into v_montant;
		IF c_actes_pds%NOTFOUND then return(0);
		End if;
	close c_actes_pds;

/* Calcul de FRA_DEP */

	v_franchise := ((p_mtfrais * p_nbacte) - (p_baseremb * p_nbacte));

	IF v_franchise > v_montant then
		v_franchise := v_montant;
	End if;
	If  v_franchise < 0 then
		return(0);
	else
		return (v_franchise);
	End if;

	Exception
	when no_data_found then
			return(0);
	when too_many_rows then
			return(0);
	when others then
			return(0);

End f_fra_dep;
