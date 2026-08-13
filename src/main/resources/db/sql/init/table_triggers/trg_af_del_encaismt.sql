CREATE TRIGGER ARTHUS.trg_af_del_encaismt
AFTER DELETE ON encaismt
FOR EACH ROW





BEGIN

	delete 	remise_banque
	where	numencaismt = :old.numencaismt;

END;