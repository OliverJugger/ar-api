CREATE TRIGGER ARTHUS.TRG_B_DELETE_RECOURS_FACTURE
	before delete
	on recours_facture
	for each row








begin
		delete recours_sinistre where numrecours = :old.numrecours
					and   numfact    = :old.numordre;
	end;