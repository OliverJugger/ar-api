CREATE TRIGGER ARTHUS."TRG_BF_UPD_ADHE_CNTRT"
BEFORE UPDATE OF Date_fin_adhe, Mregl,Numquerable,fract
ON Adhe_cntrt
FOR EACH ROW
DECLARE
   --
   CST_SCCS     CONSTANT VARCHAR2(120) := '@(#)trg_bf_upd_adhe_cntrt.sql	1.1    00/12/06';
   loc_qttc qttc_global%ROWTYPE;
   ov_erreur varchar2(200);
   loc_retour_reactivation number default null ;
   loc_type_eche   NUMBER;
   loc_type_terme  NUMBER;
BEGIN
	/* Resiliation -> on ferme toutes les couvertures	*/
	if :new.date_fin_adhe is not null then
		update	adhesion
		set	datper 	= :new.date_fin_adhe,
			motif = 0
		where	idadhesion	= :new.idadhesion
		and	datper is null;
	else
		/* Remise en vigueur -> on rouvre les couvertures concernees */
		if :old.date_fin_adhe is not null then
			update	adhesion
			set	datper 	= :new.date_fin_adhe,
				motif = ''
			where	idadhesion	= :new.idadhesion
			and	datper 	= :old.date_fin_adhe;
		end if;
	end if;
	/* Mode reglement -> on reajuste les qttc previsionelles	*/
	if (:new.mregl != :old.mregl) then
		for loc_qttc in(select	numquit,
					debut, fin
				from	qttc_global
				where	idadhesion = :new.idadhesion
				and 	type_qttc = 3)
		loop
			update	qttc_global
			set	prelev = :new.mregl
			where	numquit	= loc_qttc.numquit
			;
			/*Update	facture
			Set 	mregl	= :new.mregl,
				echeance = f_eche_regl(
					:new.mregl, loc_qttc.debut, :new.delai)
			Where	codope = 4
			And	numfact = loc_qttc.numquit
			;      */
            BEGIN         --RKO SEPA B2B
              SELECT c.type_eche, c.type_terme
              INTO loc_type_eche, loc_type_terme
              FROM contrat c WHERE :new.numgar = c.numgar;

  			  Update	facture
  			  Set 	mregl	= :new.mregl
             ,echeance = F_ECHEANCE (
                                    :new.mregl,
                                    loc_qttc.debut,
                                    loc_qttc.fin,
                                    :new.delai,
                                    :new.eche_anniv,
                                    :new.fract,
                                    :new.date_fin_adhe,
                                    loc_type_eche,
                                    loc_type_terme
                                    )
  			  Where	codope = 4
  			  And	numfact = loc_qttc.numquit
  			 ;
            EXCEPTION
              WHEN OTHERS THEN NULL;
            END;
		end loop;
	end if;

	/* SEPA  : gestion du querable et des mandats */
	IF pk_sepa.f_contrat_b2b(:new.numgar) = 0 THEN -- MUR M0006633
    if (:new.numquerable != :old.numquerable) or (:new.mregl != :old.mregl) then
			pk_sepa.p_inactivation_mandat(:new.idadhesion,:new.numgar,:old.numquerable) ; -- inactivation ancien mandat

			IF :new.mregl <> 2 then
				pk_sepa.p_creation_querable(:new.idadhesion,:new.numgar,:new.numquerable,:new.mregl,:new.fract) ;
			end if;

			if :new.mregl = 2 and pk_SEPA.f_ctrl_querable(:new.numquerable) = 1 THEN -- vérifie que le quérable a bien des coordonnées bancaires sepa valides
				-- appel de la procedure reactivation mandat - si ko alors appel creation_mandat
				pk_sepa.p_reactivation_mandat ( :new.idadhesion,:new.numgar,:new.numquerable,:new.mregl,:new.fract,loc_retour_reactivation) ;   -- TLE AJOUT DU FRACTIONNEMENT
				IF loc_retour_reactivation != 0 then
					pk_sepa.p_creation_mandat(:new.idadhesion,:new.numgar,:new.numquerable,:new.mregl,:new.fract) ;
				end if ;
			end if;
	elsif :new.fract != :old.fract then
	-- En cas de changement de fractionnement, on désactive la ligne de histo_querable
	-- et on insère une nouvelle ligne avec le nouveau fractionnement
			pk_sepa.p_maj_histo_querable(:new.idadhesion,
                                   :new.numgar,
                                   :new.numquerable,
                                   :new.mregl,
                                   :new.fract
                                   ,ov_erreur);
	end if ;
    END IF ;
END;