CREATE TRIGGER ARTHUS.trg_bd_gar_cntrt
  before delete
  on gar_cntrt_ref
  for each row







begin
  Del_garanties( :old.numfor, :old.type );
 end;