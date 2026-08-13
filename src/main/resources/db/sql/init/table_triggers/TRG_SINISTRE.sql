CREATE TRIGGER ARTHUS."TRG_SINISTRE"
	before delete
	on sinistre
	for each row
begin
		delete sntr_ref		where numsin = :old.numsin;
		delete courrier		where numsin = :old.numsin;
		delete forcage		where numsin = :old.numsin;
		delete histo_plafond where numsin = :old.numsin;
		delete SINISTRE_DEV where numsin = :old.numsin;
		delete SINISTRE_DENT where numsin = :old.numsin;
    delete SINISTRE_VERRE where numsin = :old.numsin;
    delete sntr_dossier where numsin_sntr = :old.numsin; -- MUR M0005677
	end;