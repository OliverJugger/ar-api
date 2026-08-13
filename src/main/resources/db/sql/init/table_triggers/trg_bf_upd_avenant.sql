CREATE TRIGGER ARTHUS.trg_bf_upd_avenant
Before Update of datfinav
ON avenant
For each row






BEGIN
Update	cntrt_trait
Set	fin = :new.datfinav
Where	numav = :new.numav
and	fin is null;
END;