CREATE TRIGGER ARTHUS.trg_bd_histo_annul
before delete
on histo_annul
for each row







BEGIN
Update	arret
Set 	traite = 'O'
Where	idarret = :old.idannul;
END;