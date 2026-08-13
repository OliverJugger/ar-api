CREATE TRIGGER ARTHUS.trg_ad_texte
after delete
on param_texte
for each row






begin
	delete texte
	where idtexte=:old.idtexte;
end;