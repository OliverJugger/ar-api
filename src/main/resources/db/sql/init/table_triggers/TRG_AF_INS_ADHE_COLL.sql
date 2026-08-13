CREATE TRIGGER ARTHUS."TRG_AF_INS_ADHE_COLL"
AFTER INSERT ON adhe_collective
FOR EACH ROW
BEGIN
	IF :new.mregl <> 2 then
		pk_sepa.p_creation_querable(0,:new.numgar,:new.numquerable,:new.mregl,:new.fract) ;
	end if;
	if :new.mregl = 2 and pk_SEPA.f_ctrl_querable(:new.numquerable) = 1 THEN -- verifie que le querable a bien des coordonnees bancaires sepa valides
		pk_sepa.p_creation_mandat(0,:new.numgar,:new.numquerable,:new.mregl,:new.fract) ;
	end if;
END;