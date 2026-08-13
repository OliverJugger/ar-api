CREATE TRIGGER ARTHUS."TRG_AF_INS_ADHE_CNTRT2"
AFTER INSERT ON adhe_cntrt
FOR EACH ROW
BEGIN
  /* SEPA  : gestion du querable et des mandats */
  IF pk_sepa.f_contrat_b2b(:new.numgar) = 0 THEN -- MUR M0006633
	if :new.mregl = 2 and pk_SEPA.f_ctrl_querable(:new.numquerable) = 1 THEN
		pk_sepa.p_creation_mandat(:new.idadhesion,:new.numgar,:new.numquerable,:new.mregl,:new.fract) ;
	else
		pk_sepa.p_creation_querable(:new.idadhesion,:new.numgar,:new.numquerable,:new.mregl,:new.fract) ;
	end if ;
  END IF ;
END;