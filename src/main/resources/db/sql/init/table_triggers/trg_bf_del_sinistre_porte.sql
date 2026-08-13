CREATE TRIGGER ARTHUS.trg_bf_del_sinistre_porte
before delete
on sinistre_porte
for each row




DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
begin
	delete 	sinistre_ano
	where 	sinistre_ano.numsin = :old.numsin
	and	sinistre_ano.numremise = :old.numremise;
	--
	/* VCR 22/11/2006 Table inexistante
	Delete	sntrprt_cetip
	Where	numremise = :old.numremise
	and	numsin = :old.numsin;
	*/
end;