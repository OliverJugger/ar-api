CREATE procedure ARTHUS.charge_garantie (I_numfor IN number,
					   O_donnee out pk_texte.donnee
					    )
is
CURSOR C_garantie is
select garanties.nomgar,
       garanties.libelle,
       garanties.debut,
       garanties.fin
From    garanties
	Where   numfor=I_numfor
        Union
	Select  frmls.nomgar,
		frmls.libelle,
	        frmls.debut,
		frmls.fin
	From    frmls
	Where   numfor=I_numfor;
rec_C_garantie   C_garantie%rowtype;
BEGIN
		Open C_garantie;
	        Fetch C_garantie Into rec_C_garantie;
	        Close C_garantie;
		O_donnee(1):=rec_C_garantie.nomgar;
		O_donnee(2):=rec_C_garantie.libelle;
		O_donnee(3):=d2e(rec_C_garantie.debut);
		O_donnee(4):=d2e(rec_C_garantie.fin);
END charge_garantie;
/
