CREATE TRIGGER ARTHUS.trg_porte_contrat
after delete
on porte_contrat
for each row







Begin
	Delete param_tiers_payant
	Where numporte=:old.numporte
	And numgar=:old.numgar
	;
End;