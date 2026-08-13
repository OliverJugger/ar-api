CREATE TRIGGER ARTHUS.trg_ai_qttc_global
after Insert
on qttc_global
for each row






begin
Ins_histo_export( 37, :new.idadhesion );
end;