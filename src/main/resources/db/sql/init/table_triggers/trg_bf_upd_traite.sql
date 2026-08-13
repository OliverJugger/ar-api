CREATE TRIGGER ARTHUS.trg_bf_upd_traite
Before Update of datfintr
ON traite
For each row






BEGIN
Update	avenant
Set	datfinav = :new.datfintr
Where	numtr = :new.numtr
and	nvl(datfinav, :new.datfintr) >= :new.datfintr;
END;