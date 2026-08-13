CREATE TRIGGER ARTHUS."TRG_PORTE_REMISE" 
after delete
on porte_remise
for each row
declare
  loc_TYPE_CIRCUIT porte_param.TYPE_CIRCUIT%type ;
begin
	DELETE	rejet_noemie
	WHERE	numremise = :old.numremise
	AND	numporte = :old.numporte;

	DELETE	sinistre_porte
	WHERE	numremise = :old.numremise
	AND	numporte = :old.numporte;

  --M0005621 : pas supprimer sntr_ref lorsque l'on est sur une remise DSN
  -- DELETE	sntr_ref
  -- WHERE	numremise = :old.numremise;
  begin
    select TYPE_CIRCUIT into loc_TYPE_CIRCUIT
    from porte_param
    where numporte = :old.numporte
    ;
    if loc_TYPE_CIRCUIT != 5 then
      DELETE	sntr_ref WHERE	numremise = :old.numremise;
    end if;
  exception
    when others  then null ;
  end;

	--DELETE	sntrprt_cetip
	--WHERE	numremise = :old.numremise;

	DELETE	sinistre_ano
	WHERE	numremise = :old.numremise
	AND	numporte = :old.numporte;

	DELETE	sinistre_porte_forcage
	WHERE	numremise = :old.numremise;

end;