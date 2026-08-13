CREATE function ARTHUS.f_conso_reste (f_numfor IN NUMBER,
					f_numindiv IN NUMBER,
					f_codfrais IN CHAR,f_date IN DATE)
RETURN number
IS
	loc_retour_nbacte	NUMBER;
	loc_plafond	maxact.nbactes%TYPE;
	loc_etendue	maxact.etendue%TYPE;
	loc_conso	sntr.nbacte%TYPE;
	loc_numgar	adhesion.numgar%TYPE;
	loc_datapli	DATE;
BEGIN
	begin
		select 	maxact.nbactes,
			maxact.etendue,
			adhesion.numgar,
			adhesion.datapli
		into 	loc_plafond,
			loc_etendue,
			loc_numgar,
			loc_datapli
		from 	maxact,
			adhesion
		where	maxact.numfor=adhesion.numfor
		and 	maxact.numfor=f_numfor
		and	adhesion.numindiv=f_numindiv
		and	maxact.codfrais=f_codfrais
		and	nvl(adhesion.datper,adhesion.datapli+1)!=
				adhesion.datapli
		and	nvl(maxact.datper,maxact.datapli+1)!=
				maxact.datapli
		and	f_date between adhesion.datapli and
			nvl(adhesion.datper,f_date)
		and	f_date between maxact.datapli and
			nvl(maxact.datper,f_date);
		EXCEPTION
		when no_data_found then return 0;
	end;
if (loc_etendue=1)
	then
	begin
		SELECT SUM(sntr.nbacte)
		INTO   loc_conso
		FROM   sntr
		WHERE  sntr.numindiv = f_numindiv
		AND    sntr.codfrais = f_codfrais
		AND    sntr.numgar +0   = loc_numgar
		AND    sntr.numfor +0   = f_numfor
		AND    sntr.numdec +0 > 0
		AND    sntr.numannul is null
		AND    sntr.datsin BETWEEN
			'01-jan-'||to_char(f_date,'yyyy') and
			'31-dec-'||to_char(f_date,'yyyy');
		EXCEPTION
		when no_data_found then loc_conso :=0;
	end;
	else
	begin
		SELECT SUM(sntr.nbacte)
		INTO   loc_conso
		FROM   sntr
		WHERE  sntr.numassu = f_numindiv
		AND    sntr.codfrais = f_codfrais
		AND    sntr.numgar +0   = loc_numgar
		AND    sntr.numfor +0   = f_numfor
		AND    sntr.numdec +0 > 0
		AND    sntr.numannul is null
		AND    sntr.datsin BETWEEN
			'01-jan-'||to_char(f_date,'yyyy') and
			'31-dec-'||to_char(f_date,'yyyy');
		EXCEPTION
		when no_data_found then loc_conso :=0;
	end;
	end if;
	loc_retour_nbacte:=nvl(loc_plafond,0)-nvl(loc_conso,0);
if (loc_retour_nbacte<0)
then loc_retour_nbacte:=0;
end if;
RETURN(loc_retour_nbacte);
END f_conso_reste;
