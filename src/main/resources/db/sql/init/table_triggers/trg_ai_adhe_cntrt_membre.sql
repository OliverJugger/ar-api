CREATE TRIGGER ARTHUS.trg_ai_adhe_cntrt_membre
After Insert or Update
On adhe_cntrt_membre
For each row








Begin
Ins_histo_export( 33, :new.idadhesion );
End;