CREATE TRIGGER ARTHUS."TRG_AF_INS_UPD_EMISSION" 
after insert or update
on emission
for each row
     WHEN ( new.codope = 4 and new.numrelance = 99 )
Begin
	Insert into facture_annul (
			Codope,
			Numfact,
			Datope)
	Select	:new.codope,
		:new.numfact,
		:new.datemis
	From	Dual
	Where Not Exists (
		Select 	1
		From	facture_annul
		Where	facture_annul.codope = :new.codope
		and	facture_annul.numfact = :new.numfact);
End;