CREATE TRIGGER ARTHUS.trg_bf_adhe_collective
BEFORE DELETE ON adhe_collective
FOR EACH ROW






DECLARE
  --
   CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
  --
BEGIN
		Delete  Histo_contrat
		Where   numgar   = :old.numgar;
END;