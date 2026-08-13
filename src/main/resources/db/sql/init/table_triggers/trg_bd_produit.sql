CREATE TRIGGER ARTHUS.trg_bd_produit
	before delete
	on produit
	for each row







Declare
	C_gar	v_gar%rowtype;
	begin
	Delete cond_souscription
	Where	numprod = :old.numprod;
	Delete 	cond_adhesion
	Where	etendue = 7
	and	cle = :old.numprod;
	For C_gar IN (
		Select	numfor,
			typfor
		From	v_gar
		Where	etendue = 7
		and	clef = :old.numprod)
	Loop
		Del_garanties( C_gar.numfor, C_gar.typfor );
	End Loop;
	end;