CREATE TRIGGER ARTHUS."TRG_AF_INS_CONTRAT_REF"
AFTER INSERT ON CONTRAT_REF
FOR EACH ROW
BEGIN
IF  :new.TYPEQUIT = 1 then
       IF :new.mregl <> 2 then
          pk_sepa.p_creation_querable(0,:new.numgar,:new.numquerable,:new.mregl,:new.fract) ;
       end if;
       if :new.mregl = 2 and pk_SEPA.f_ctrl_querable(:new.numquerable) = 1 THEN -- vérifie que le quérable a bien des coordonnées bancaires sepa valides
          pk_sepa.p_creation_mandat(0,:new.numgar,:new.numquerable,:new.mregl,:new.fract) ;
       end if;
    end if;
END;