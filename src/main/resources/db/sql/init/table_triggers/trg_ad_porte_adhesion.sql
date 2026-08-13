CREATE TRIGGER ARTHUS.trg_ad_porte_adhesion
Before delete on porte_adhesion
for each row




BEGIN
Begin
delete 	noemie
where	idporte=:old.idporte;

delete demande_tp
where idporte=:old.idporte;

delete demande_tp_ad
where idporte=:old.idporte;

End;
END;