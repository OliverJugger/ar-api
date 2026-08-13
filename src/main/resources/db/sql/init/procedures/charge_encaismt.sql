CREATE procedure ARTHUS.charge_encaismt(I_numencaismt IN number,
						O_donnee OUT pk_texte.donnee)
is
L_modpmt encaismt.modpmt%type;
CURSOR C_encaismt1 is
	Select 	encaismt.numencaismt,
		encaismt.modpmt,
		encaismt.montant,
		encaismt.monnaie,
		mone_euro.libelle,
		encaismt.datpay,
		encaismt.numutil,
		encaismt.refpmt,
		annul_encais.motif,
		annul_encais.date_annul
	From	annul_encais,encaismt,mone mone,mone mone_euro,prmt
	Where	encaismt.numencaismt=I_numencaismt
	And 	encaismt.numencaismt=annul_encais.numencaismt(+)
	And	encaismt.monnaie=mone.codmon
	And	prmt.dfsoc=mone_euro.codmon
	And	encaismt.modpmt=1;
rec_C_encaismt1 C_encaismt1%rowtype;
CURSOR C_encaismt2 is
	Select 	encaismt.numencaismt,
		encaismt.modpmt,
		encaismt.montant,
		encaismt.monnaie,
	    mone_euro.libelle,
		remise_prelev.datdisk,
		encaismt.numutil,
		prelevement.numprelev,
		prelevement.codbque,
		prelevement.guichet,
		prelevement.compte,
		annul_encais.motif,
		annul_encais.date_annul
	From	remise_prelev,annul_encais,prelevement,encaismt,mone,
		mone mone_euro,prmt
	Where	remise_prelev.numremise=prelevement.numremise
	And	prelevement.numencaismt=encaismt.numencaismt
	And	prelevement.numencaismt=annul_encais.numencaismt(+)
	And	encaismt.numencaismt=I_numencaismt
	And	encaismt.monnaie=mone.codmon
	And	prmt.dfsoc=mone_euro.codmon
	And	encaismt.modpmt=2;
rec_C_encaismt2 C_encaismt2%rowtype;
Begin
       If L_modpmt=2 then
	Open C_encaismt2;
	Fetch C_encaismt2 Into rec_C_encaismt2;
	Close C_encaismt2;
	O_donnee(1):=rec_C_encaismt2.numencaismt;
        O_donnee(2):=Substr(pk_libelle.f_lib('MOPM',rec_C_encaismt2.modpmt),1,15);
        O_donnee(3):=to_char(rec_C_encaismt2.montant,'999999990.90');
	O_donnee(4):=rec_C_encaismt2.monnaie;
        O_donnee(5):=to_char(pk_devise.F_convert_euro(rec_C_encaismt2.montant),'999999990.90');
	O_donnee(6):=pk_devise.lib_symbole(rec_C_encaismt2.monnaie);
        O_donnee(7):=d2e(rec_C_encaismt2.datdisk);
        O_donnee(8):=pk_libelle.f_lib('USER',rec_C_encaismt2.numutil);
        O_donnee(9):=rec_C_encaismt2.numprelev;
        O_donnee(10):=pk_libelle.f_lib('MREGL',rec_C_encaismt2.modpmt)||' le  '||d2e(rec_C_encaismt2.datdisk)||'N°'||rec_C_encaismt2.codbque;
        O_donnee(11):=Substr(pk_libelle.f_lib('PREVANN',nvl(rec_C_encaismt2.motif,-2)),1,30);
        O_donnee(12):=d2e(rec_C_encaismt2.date_annul);
        O_donnee(13):=rec_C_encaismt2.codbque||' '||rec_C_encaismt2.guichet||' ' ||rec_C_encaismt2.compte;
Else
	Open C_encaismt1;
	Fetch C_encaismt1 Into rec_C_encaismt1;
	Close C_encaismt1;
	O_donnee(1):=rec_C_encaismt1.numencaismt;
        O_donnee(2):=Substr(pk_libelle.f_lib('MOPM',rec_C_encaismt1.modpmt),1,15);
	O_donnee(3):=to_char(rec_C_encaismt1.montant);
	O_donnee(4):=rec_C_encaismt1.monnaie;
        O_donnee(5):=pk_devise.F_convert_euro(rec_C_encaismt1.montant);
	O_donnee(6):=pk_devise.lib_symbole(rec_C_encaismt1.monnaie);
        O_donnee(7):=d2e(rec_C_encaismt1.datpay);
        O_donnee(8):=pk_libelle.f_lib('USER',rec_C_encaismt1.numutil);
        O_donnee(9):=rec_C_encaismt1.refpmt;
        O_donnee(10):=pk_libelle.f_lib('MREGL',rec_C_encaismt1.modpmt)||' le '||
		d2e(rec_C_encaismt1.datpay)||'N°'||rec_C_encaismt1.refpmt;
        O_donnee(11):=Substr(pk_libelle.f_lib('PREVANN',nvl(rec_C_encaismt1.motif,-2)),1,30);
        O_donnee(12):=d2e(rec_C_encaismt1.date_annul);
        O_donnee(13):='';
       End If;
End charge_encaismt;
/
