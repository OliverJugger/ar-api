CREATE TRIGGER ARTHUS.trg_bd_dcptdedu
before delete
on dcptdedu
for each row







Begin
Update	histo_dedu
Set	numdec = 0
Where	numdec = :old.numdec;
End;