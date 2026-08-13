CREATE procedure ARTHUS.qttc_reventil (
				a_numquit in number, a_2numquit in number
				)
is
-- Variable de reconnaissance SCCS
-- @(#)qttc_reventil.sql	1.    00/11/20
loc_ratio	number;
loc_delta	number;
loc_ratio_d	number;
loc_delta_d	number;
loc_mt_frais	number;
loc_mt_reel	number;
loc_mt_affec	number;
loc_mt_frais_d	number;
loc_mt_reel_d	number;
loc_mt_affec_d	number;
loc_monnaie	number;
loc_monnaie_d	number;

Cursor fetch_affec is
	Select	idaffec,
			montant,
            monnaie,
            montant_d,
            monnaie_d,
			numquit
	From	qttc_affec
	Where	numquit between a_numquit and a_2numquit
	And	idgar = 0;
loc_affec	fetch_affec%Rowtype;
BEGIN
For loc_affec in fetch_affec
loop
	/* On determine le ratio du reste a affecter 	*/

	Begin
   	Select	loc_affec.montant / decode( qttc_global.mt_ttc,0,1,
			pk_funct.f_arrondi(4,
			qttc_global.numquit,
			qttc_global.mt_ttc) ),
			loc_affec.montant_d / decode( qttc_global.mt_ttc_d,0,1,
			pk_funct.f_arrondi(4,
			qttc_global.numquit,
			qttc_global.mt_ttc_d) ),
			qttc_global.mt_ttc,
            qttc_global.monnaie,
            qttc_global.mt_ttc_d,
            qttc_global.monnaie_d
	Into	loc_ratio,
            loc_ratio_d,
			loc_mt_reel,
            loc_monnaie,
            loc_mt_reel_d,
            loc_monnaie_d
	From	qttc_global
	Where	qttc_global.numquit = loc_affec.numquit
	And	qttc_global.mt_ttc is not null
    And	qttc_global.mt_ttc_d is not null;
	Exception When No_data_found then Exit;
	End;

	/* On retablit le montant a affecter par rapport au montant calcule */

	 loc_mt_affec   := loc_mt_reel   * loc_ratio;
	 loc_mt_affec_d := loc_mt_reel_d * loc_ratio_d;

	/* On maj dans qttc_affec une ligne par garantie /assure */
	BEGIN
   	 Update qttc_affec
	 set    montant   = (select nvl(QTTC_GAR.MT_TTC*loc_ratio,0)
					     from QTTC_GAR
					     where QTTC_GAR.NUMQUIT = loc_affec.numquit
					     and   QTTC_GAR.idgar   = qttc_affec.idgar
						 and   QTTC_GAR.NUMFOR= qttc_affec.numfor ),
			montant_d = (select nvl(QTTC_GAR.MT_TTC_D*loc_ratio_d,0)
					     from QTTC_GAR
					     where QTTC_GAR.NUMQUIT = loc_affec.numquit
					     and   QTTC_GAR.idgar   = qttc_affec.idgar
						 and   QTTC_GAR.NUMFOR= qttc_affec.numfor)
	 WHERE NUMQUIT = loc_affec.numquit
	 AND   idaffec= loc_affec.idaffec
	 AND   idgar !=0;
	END;

	/* On maj les frais dans affec_tfc */

	Begin

   	    update qttc_affec_tfc
		set montant = (select SUM(nvl(QTTC_FRAIS.MONTANT,0))*loc_ratio
					   from QTTC_FRAIS
					   where QTTC_FRAIS.NUMQUIT = loc_affec.numquit
					   and   QTTC_FRAIS.NUMFOR = qttc_affec_tfc.numfor
					   and   DECODE(QTTC_FRAIS.NUMFOR, 0, 4, 3) = qttc_affec_tfc.TFC
					   and   QTTC_FRAIS.TYPE_FRAIS =qttc_affec_tfc.type_tfc
					   and   QTTC_FRAIS.NUMBENE = qttc_affec_tfc.numbene),
		    montant_d = (select SUM(nvl(QTTC_FRAIS.MONTANT_d,0))*loc_ratio_d
					   from QTTC_FRAIS
					   where QTTC_FRAIS.NUMQUIT = loc_affec.numquit
					   and   QTTC_FRAIS.NUMFOR = qttc_affec_tfc.numfor
					   and   DECODE(QTTC_FRAIS.NUMFOR, 0, 4, 3) = qttc_affec_tfc.TFC
					   and   QTTC_FRAIS.TYPE_FRAIS =qttc_affec_tfc.type_tfc
					   and   QTTC_FRAIS.NUMBENE = qttc_affec_tfc.numbene)
	    where qttc_affec_tfc.tfc in (4, 3)
		and   NUMQUIT = loc_affec.numquit
		AND   idaffec= loc_affec.idaffec;

	/* On re-calcule la somme des frais affectes */
		BEGIN
		 SELECT ALL NVL(SUM(QTTC_AFFEC_TFC.MONTANT), 0),
					QTTC_AFFEC_TFC.MONNAIE,
					NVL(SUM(QTTC_AFFEC_TFC.MONTANT_D), 0),
					QTTC_AFFEC_TFC.MONNAIE_D
			Into	loc_mt_frais,
					loc_monnaie,
					loc_mt_frais_d,
					loc_monnaie_d
			FROM QTTC_AFFEC_TFC
			WHERE (QTTC_AFFEC_TFC.IDAFFEC = loc_affec.idaffec
			AND QTTC_AFFEC_TFC.TFC IN (3, 4))
			GROUP BY QTTC_AFFEC_TFC.MONNAIE,
					 QTTC_AFFEC_TFC.MONNAIE_D ;
		EXCEPTION
			 WHEN No_Data_Found THEN
				loc_monnaie 	:= 1;
				loc_monnaie_d	:= 1;
                loc_mt_frais   := 0;
                loc_mt_frais_d := 0;
		END;
		----- Revu par NS 25-07-2005 --- ---
	End;

	/* On determine le delta eventuel (Total encaisse - total affecte) */
	----- Revu par NS 25-07-2005 --- -------
	BEGIN
	SELECT ALL loc_mt_affec - SUM(QTTC_AFFEC.MONTANT) - loc_mt_frais,
				QTTC_AFFEC.MONNAIE,
				loc_mt_affec_d - SUM(QTTC_AFFEC.MONTANT_D) - loc_mt_frais_d,
				QTTC_AFFEC.MONNAIE_D
		Into	loc_delta,
                loc_monnaie,
                loc_delta_d,
                loc_monnaie_d
		FROM QTTC_AFFEC
		WHERE (QTTC_AFFEC.IDAFFEC = loc_affec.idaffec
			AND QTTC_AFFEC.IDGAR<>0)
		GROUP BY QTTC_AFFEC.MONNAIE,
				 QTTC_AFFEC.MONNAIE_D;
	Exception When No_data_found then
			 loc_monnaie 	:= 1;
			 loc_monnaie_d	:= 1;
			 loc_mt_frais	:= 0;
			 loc_mt_frais_d	:= 0;
	END;
	----- Revu par NS 25-07-2005 --- -------

	/* Qu'on affecte sur la premiere garantie */

	If ( loc_delta != 0 or loc_delta_d != 0) Then

		Begin
		     Update	qttc_affec
		     Set	montant   = nvl(montant,0) + loc_delta,
                    monnaie   =loc_monnaie,
                    montant_d = montant_d + loc_delta_d,
                    monnaie_d =loc_monnaie_d
		     Where	qttc_affec.idaffec = loc_affec.idaffec
		     And	qttc_affec.idgar != 0
		     and	rownum = 1;
		     Exception When No_data_found then null;
		End;
	End if;

	/*  On met a jour le montant total affecte pour la garantie  */

   	Update	qttc_gar
	Set	qttc_gar.mt_affec   = (select	sum(nvl(qttc_affec.montant,0))
			               from 	qttc_affec
			               where	qttc_affec.numquit = loc_affec.numquit
			               and	qttc_affec.idgar = qttc_gar.idgar
			               ),
        qttc_gar.monnaie    = (select distinct(qttc_affec.monnaie)
			               from  qttc_affec
			               where qttc_affec.numquit = loc_affec.numquit
			               and   qttc_affec.idgar = qttc_gar.idgar
			               ),
        qttc_gar.mt_affec_d = (select sum(nvl(qttc_affec.montant_d,0))
			               from  qttc_affec
			               where qttc_affec.numquit = loc_affec.numquit
			               and   qttc_affec.idgar = qttc_gar.idgar
			               ),
        qttc_gar.monnaie_d  = (select distinct( qttc_affec.monnaie_d)
			               from  qttc_affec
			               where qttc_affec.numquit = loc_affec.numquit
			               and   qttc_affec.idgar = qttc_gar.idgar
			               )
	Where	qttc_gar.numquit = loc_affec.numquit
	and qttc_gar.mt_ttc<>0
	and qttc_gar.mt_ttc_d<>0;

	/* On affecte les comm et les taxes */

	Begin

		update qttc_affec_tfc
		set montant = ( select SUM(QTTC_COMM.MONTANT)*loc_ratio
						from QTTC_COMM
						WHERE QTTC_COMM.NUMQUIT = loc_affec.numquit
						and QTTC_COMM.NUMFOR    = qttc_affec_tfc.numfor
						and QTTC_COMM.TYPE_COMM = qttc_affec_tfc.type_tfc
						and QTTC_COMM.NUMBENE   = qttc_affec_tfc.numbene
						and QTTC_COMM.PRELEV_REVERS = qttc_affec_tfc.prelev_revers ),
			montant_d = ( select SUM(QTTC_COMM.MONTANT_d)*loc_ratio_d
						from QTTC_COMM
						WHERE QTTC_COMM.NUMQUIT = loc_affec.numquit
						and QTTC_COMM.NUMFOR    = qttc_affec_tfc.numfor
						and QTTC_COMM.TYPE_COMM = qttc_affec_tfc.type_tfc
						and QTTC_COMM.NUMBENE   = qttc_affec_tfc.numbene
						and QTTC_COMM.PRELEV_REVERS = qttc_affec_tfc.prelev_revers )
		 where qttc_affec_tfc.tfc = 2
		and   NUMQUIT = loc_affec.numquit
		AND   idaffec= loc_affec.idaffec;

	Exception When No_data_found then null;
	End;

	Begin

		update qttc_affec_tfc
		set montant = (select SUM(QTTC_RETRO.MONTANT)*loc_ratio
					   FROM QTTC_RETRO
					   WHERE QTTC_RETRO.NUMQUIT = loc_affec.numquit
					   and QTTC_RETRO.NUMFOR = qttc_affec_tfc.numfor
					   and QTTC_RETRO.TYPE_COMM = qttc_affec_tfc.type_tfc
					   and QTTC_RETRO.NUMBENE= qttc_affec_tfc.numbene
					   and QTTC_RETRO.PRELEV_REVERS = qttc_affec_tfc.prelev_revers
					   and DECODE(QTTC_RETRO.PRELEV_REVERS, 1, -1, 0) = qttc_affec_tfc.idrevers),
			montant_d = (select SUM(QTTC_RETRO.MONTANT_D)*loc_ratio_d
					   FROM QTTC_RETRO
					   WHERE QTTC_RETRO.NUMQUIT = loc_affec.numquit
					   and QTTC_RETRO.NUMFOR = qttc_affec_tfc.numfor
					   and QTTC_RETRO.TYPE_COMM = qttc_affec_tfc.type_tfc
					   and QTTC_RETRO.NUMBENE= qttc_affec_tfc.numbene
					   and QTTC_RETRO.PRELEV_REVERS = qttc_affec_tfc.prelev_revers
					   and DECODE(QTTC_RETRO.PRELEV_REVERS, 1, -1, 0) = qttc_affec_tfc.idrevers)
		where qttc_affec_tfc.tfc = 5
		and   NUMQUIT = loc_affec.numquit
		AND   idaffec= loc_affec.idaffec;

	Exception When No_data_found then null;

	End;

	Begin
		update qttc_affec_tfc
		set montant = (select SUM(QTTC_TAXE.MONTANT)* loc_ratio
					   FROM QTTC_TAXE
					   WHERE QTTC_TAXE.NUMQUIT = loc_affec.numquit
						and	 QTTC_TAXE.NUMFOR = qttc_affec_tfc.numfor
						and	 QTTC_TAXE.TYPE_TAXE = qttc_affec_tfc.type_tfc
						and	 QTTC_TAXE.NUMBENE= qttc_affec_tfc.numbene),
			montant_d = (select SUM(QTTC_TAXE.MONTANT_D)* loc_ratio_d
					   FROM QTTC_TAXE
					   WHERE QTTC_TAXE.NUMQUIT = loc_affec.numquit
						and	 QTTC_TAXE.NUMFOR = qttc_affec_tfc.numfor
						and	 QTTC_TAXE.TYPE_TAXE = qttc_affec_tfc.type_tfc
						and	 QTTC_TAXE.NUMBENE= qttc_affec_tfc.numbene)
		where qttc_affec_tfc.tfc = 1
		and   NUMQUIT = loc_affec.numquit
		AND   idaffec= loc_affec.idaffec;

	Exception When No_data_found then null;

	End;


end loop;

END;
/
