CREATE procedure ARTHUS.charge_prest(I_numsin IN  number,
					 I_numgar IN number default null,
					 I_codfrais IN varchar2 default null,
					 I_debut IN date default null,
					 I_fin IN date default null,
					O_donnee OUT pk_texte.donnee)
is
CURSOR C_prest is
	Select 	sntr.codfrais,
		sntr.numgar,
		sntr.numindiv,
	        sntr.datsin,
		sntr.mtfrais,
		sntr.mtremb,
		sntr.autrb,
		sntr.mtreel,
	        sntr.datsai,
		sntr.nbacte,
		sntr.numdec,
		sntr.numassu,
		sntr.numbene,
		sntr.numsin,
		sntr.username,
		sntr.numfor,
		sntr.num_fact,
		sntr.idadhesion
	From	sntr
	Where 	numsin=I_numsin;
rec_C_prest C_prest%rowtype;
CURSOR C_sntr is
	Select 	nbacte,
		mtfrais,
		mtremb,
		autrb,
		mtreel
	From	sntr
	Where	sntr.codfrais=I_codfrais
	And	sntr.numgar=nvl(I_numgar,sntr.numgar)
	And	sntr.datsin between I_debut and I_fin
	Group By
		sntr.codfrais,
		sntr.numgar;
rec_C_sntr C_sntr%rowtype;
BEGIN
        begin
	Open C_prest;
	Fetch C_prest Into rec_C_prest;
	Close C_prest;
	        O_donnee(1):=rec_C_prest.codfrais;
	        O_donnee(2):=rec_C_prest.numgar;
	        O_donnee(3):=rec_C_prest.numindiv;
	        O_donnee(4):=d2e(rec_C_prest.datsin);
	        O_donnee(5):=rec_C_prest.mtfrais;
	        O_donnee(6):=rec_C_prest.mtremb;
	        O_donnee(7):=rec_C_prest.autrb;
	        O_donnee(8):=rec_C_prest.mtreel;
	        O_donnee(9):=d2e(rec_C_prest.datsai);
	        O_donnee(10):=rec_C_prest.nbacte;
	        O_donnee(11):=rec_C_prest.numdec;
	        O_donnee(12):=rec_C_prest.numassu;
	        O_donnee(13):=rec_C_prest.numbene;
	        O_donnee(14):=rec_C_prest.numsin;
	        O_donnee(15):=rec_C_prest.username;
	        O_donnee(16):=rec_C_prest.numfor;
	        O_donnee(17):=rec_C_prest.num_fact;
	        O_donnee(18):=rec_C_prest.idadhesion;
	        O_donnee(19):=rec_C_prest.mtfrais/rec_C_prest.nbacte;
	        O_donnee(20):=rec_C_prest.mtremb/rec_C_prest.nbacte;
	        O_donnee(21):=rec_C_prest.autrb/rec_C_prest.nbacte;
	        O_donnee(22):=rec_C_prest.mtreel/rec_C_prest.nbacte;
		Exception
			when no_data_found then
		O_donnee(1):=I_codfrais;
	       	O_donnee(2):=I_numgar;
	end;
	begin
               Open C_sntr;
	       Fetch C_sntr Into rec_C_sntr;
	       Close C_sntr;
	       O_donnee(23):=rec_C_sntr.nbacte;
	       O_donnee(24):=rec_C_sntr.mtfrais;
	       O_donnee(25):=rec_C_sntr.mtremb;
	       O_donnee(26):=rec_C_sntr.autrb;
	       O_donnee(27):=rec_C_sntr.mtreel;
	exception
		when no_data_found then null;
	end;
End charge_prest;
/
