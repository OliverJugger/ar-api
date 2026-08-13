CREATE TRIGGER ARTHUS.trg_ai_beneficiaire
After Insert or Update
On beneficiaire
For each row








Begin
Ins_histo_export( 36, :new.idadhesion );
End;