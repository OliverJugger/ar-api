CREATE TRIGGER ARTHUS.trg_ai_histo_adhesion
After Insert or Update
On histo_adhesion
For each row








Begin
Ins_histo_export( 32, :new.idadhesion );
End;