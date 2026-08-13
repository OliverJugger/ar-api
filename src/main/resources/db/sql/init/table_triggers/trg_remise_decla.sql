CREATE TRIGGER ARTHUS.trg_remise_decla
before delete on remise_decla
for each row







Begin
	Delete decla_detail2
	Where iddecla in(select iddecla from decla_detail1
			where idsynthese in
				(select idsynthese from decla_synthese
				where numremise=:old.numremise
				)
			)
	;
	Delete decla_detail1
	where idsynthese in
			(select idsynthese from decla_synthese
			where numremise=:old.numremise
			)
	;
	Delete decla_synthese
	where numremise=:old.numremise
	;
End;