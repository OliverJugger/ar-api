CREATE TRIGGER ARTHUS."TRG_BF_INS_UPD_DECAISMT"
BEFORE INSERT OR UPDATE ON DECAISMT
FOR EACH ROW

BEGIN
IF :new.devise_ct IS NULL THEN
	:new.devise_ct := :new.monnaie;
END IF;

IF :new.montant_ct IS NULL THEN
	:new.montant_ct := :new.montant;
END IF;

END;