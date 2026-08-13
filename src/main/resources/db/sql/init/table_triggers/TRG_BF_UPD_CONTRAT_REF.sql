CREATE TRIGGER ARTHUS."TRG_BF_UPD_CONTRAT_REF"
BEFORE UPDATE OF Mregl,Numquerable,Fract
ON CONTRAT_REF
FOR EACH ROW
DECLARE
	loc_retour_reactivation number default null ;
	ov_erreur varchar2(200);
BEGIN
	/* SEPA  : gestion du querable et des mandats */
	if (:new.numquerable != :old.numquerable) or (:new.mregl != :old.mregl)  then
		pk_sepa.p_inactivation_mandat(0,:new.numgar,:old.numquerable) ; -- inactivation ancien mandat
		IF :new.mregl <> 2 then
			pk_sepa.p_creation_querable(0,:new.numgar,:new.numquerable,:new.mregl,:new.fract) ;
		end if;
		if :new.mregl = 2 and pk_SEPA.f_ctrl_querable(:new.numquerable) = 1  and :new.typequit = 1 THEN -- vérifie que le quérable a bien des coordonnées bancaires sepa valides
			-- appel de la procedure reactivation mandat - si ko alors appel creation_mandat
			pk_sepa.p_reactivation_mandat ( 0,:new.numgar,:new.numquerable,:new.mregl,:new.fract,loc_retour_reactivation) ;   -- TLE AJOUT DU FRACTIONNEMENT
			IF loc_retour_reactivation != 0 then
					pk_sepa.p_creation_mandat(0,:new.numgar,:new.numquerable,:new.mregl,:new.fract) ;
			end if ;
		end if;
	elsif :new.fract != :old.fract then
	-- En cas de changement de fractionnement, on désactive la ligne de histo_querable
	-- et on insère une nouvelle ligne avec le nouveau fractionnement
	 	pk_sepa.p_maj_histo_querable(0,
                                   :new.numgar,
                                   :old.numquerable,
                                   :old.mregl,
                                   :new.fract,
								   ov_erreur);
	end if ;

END;