CREATE function ARTHUS.f_prorata2(f_debut IN NUMBER,f_fin IN NUMBER, I_numgar IN NUMBER, I_numfor IN NUMBER, I_idadhesion IN NUMBER default 0, I_numindiv IN NUMBER default 0 )
	RETURN NUMBER
	AS
		loc_prorata     number;
		f_nbunitcalc    number;
		f_unitcalc      number;
		f_typeunitcalc  number;
		loc_nbjours     number;
		f_couv_debut    number;
		f_couv_fin      number;
		loc_Mod_nbjours number;
		jours_gratuits  number:=0;

	CURSOR C_Couv IS
		select d2j(datapli), nvl(d2j(datper),0)
		from adhesion
		where idadhesion=I_idadhesion and numindiv=I_numindiv
		and numgar= I_numgar and numfor=I_numfor
		and j2d(f_debut) between  datapli and nvl(datper,j2d(f_debut))
		UNION
		select d2j(datapli), nvl(d2j(datper),0)
		from adhesion, grp_gar_def
		where adhesion.idadhesion=I_idadhesion and adhesion.numindiv=I_numindiv
		and adhesion.numgar= I_numgar
		and grp_gar_def.numfor=I_numfor and adhesion.numfor= grp_gar_def.numgrpgar
		and j2d(f_debut) between  adhesion.datapli and nvl(adhesion.datper,j2d(f_debut));

	BEGIN

		 Select nbunitcalc, unitcalc, typeunitcalc, nvl(j_gratuit,0)
		 Into f_nbunitcalc,f_unitcalc, f_typeunitcalc, jours_gratuits
		 From frmls
		 Where numfor=pk_qttc.F_SEL_numfor(I_numgar,I_numfor)
		 Union
		 Select nbunitcalc, unitcalc, typeunitcalc, nvl(j_gratuit,0)
		 from garanties
		 Where numfor=pk_qttc.F_SEL_numfor(I_numgar,I_numfor);

	IF f_unitcalc = 1 then -- Base mensuelle
			SELECT
			months_between(
				last_day( to_date(f_fin,'j') ) + 1 ,
				trunc( to_date(f_debut,'j') ,'MM')
					)
			-
			(
				(
					to_number(to_char(to_date(f_debut,'j'),'DD')) - 1
				) /
				to_number(to_char(last_day(to_date(f_debut,'j')),'DD'))
			)
			-
			(
				(
					to_number(to_char(last_day(to_date(f_fin,'j')),'DD')) -
					to_number(to_char(to_date(f_fin,'j'),'DD'))
				) /
				to_number(to_char(last_day(to_date(f_fin,'j')),'DD'))
			)
			INTO	loc_prorata
			FROM	dual;

			loc_prorata:=loc_prorata;

	ELSIF f_unitcalc = 2 then -- Base hebdomadaire;

		select to_date(f_fin, 'j') - to_date(f_debut, 'j') +1
		into   loc_nbjours
		from dual;

		loc_prorata:=(loc_nbjours/7);

	ELSIF f_unitcalc = 3 then -- Base journalière;
		select to_date(f_fin, 'j') - to_date(f_debut, 'j') +1
		into   loc_nbjours
		from dual;

		loc_prorata:=loc_nbjours;

	END IF;

	if (f_typeunitcalc=1) then -- pas d'arrondi à l'entier supérieur
		RETURN loc_prorata;             -- /f_nbunitcalc;  JPF 10/06/2006
	else
		if f_unitcalc = 3 then
			-- 08/08/2005 Gestion des non fractionnements UC sur plusieurs echéances
			if (I_idadhesion =0 or I_numindiv=0 )then
					select ceil(loc_prorata/f_nbunitcalc)*f_nbunitcalc
					into   loc_prorata
					from   dual;
			else

				Open C_Couv;
				Fetch C_Couv Into f_couv_debut, f_couv_fin;
				If ( C_Couv%NotFound or f_couv_fin=0) then
					-- Si pas de date de fin de couverture, Pas d'arrondi, comme si f_typeunitcalc=1

					Close C_Couv;
				else
				    Close C_Couv;

					if f_debut = f_couv_debut and f_fin= f_couv_fin then --Période unique
						-- Pas d'arrondi à l'entier supp pour chaque cotis période complète
						select ceil((loc_prorata- jours_gratuits)/f_nbunitcalc)*f_nbunitcalc
						into   loc_prorata
						from   dual;

					elsif  f_debut = f_couv_debut then -- Première période avec suite
						-- Pas d'arrondi, comme si f_typeunitcalc=1
						null;


					elsif f_fin= f_couv_fin then   -- Dernière période
						select mod(to_date(f_debut, 'j') - to_date(f_couv_debut, 'j'),f_nbunitcalc)
						into   loc_Mod_nbjours
						from dual;

						select ceil((loc_prorata-(f_nbunitcalc-loc_Mod_nbjours)- jours_gratuits)/f_nbunitcalc)*f_nbunitcalc +(f_nbunitcalc-loc_Mod_nbjours)
						into   loc_prorata
						from   dual;

					else -- Milieu de période
						-- Pas d'arrondi, comme si f_typeunitcalc=1
						null;

					end if;

				end if;

			end if;

		else
			select ceil(loc_prorata)
			into   loc_prorata
			from   dual;
		end if;

		RETURN loc_prorata;             -- /f_nbunitcalc;  JPF 10/06/2006
	end if;

END f_prorata2;
