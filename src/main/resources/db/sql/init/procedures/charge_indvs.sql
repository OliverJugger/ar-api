CREATE procedure ARTHUS.charge_indvs ( I_numindiv IN number,
					   I_idrib IN number default 0,
					   O_donnee OUT pk_texte.donnee)
is
O_donnee_rib pk_texte.donnee;
CURSOR C_indvs is
	Select
		numindiv,
		refcie,
	        qualite,
		codcourrier1,
		codcourrier2,
		codtitre,
		nom,
		prenom,
		codpays,
		tel,
		fax,
		datnais,
		typassu,
		natur,
		typadr,
		matorg,
		cless,
		regime,
		orgbase,
		caisse,
		guichetorg,
		cle,
		rang,
		numassu
	From 	indvs
	Where	numindiv=I_numindiv;
rec_C_indvs C_indvs%rowtype;
BEGIN
/*
If (a_idrib!=0)
Then
*/
charge_rib(I_idrib,O_donnee_rib);
O_donnee(31):=O_donnee_rib(1);
O_donnee(32):=O_donnee_rib(2);
O_donnee(33):=O_donnee_rib(3);
O_donnee(34):=O_donnee_rib(4);
O_donnee(35):=O_donnee_rib(5);
O_donnee(36):=O_donnee_rib(6);
O_donnee(37):=O_donnee_rib(7);
O_donnee(38):=O_donnee_rib(8);
/*
 End if;
*/
	Open C_indvs;
	Fetch C_indvs Into rec_C_indvs;
	Close C_indvs;
	O_donnee(1):=rec_C_indvs.numindiv;
        O_donnee(2):=rec_C_indvs.refcie;
        O_donnee(3):=Substr(pk_libelle.f_lib('QLTE',rec_C_indvs.qualite),1,15);
        O_donnee(4):=Substr(pk_libelle.f_lib('CODC1',rec_C_indvs.codcourrier1),1,15);
        O_donnee(5):=Substr(pk_libelle.f_lib('CODC2',rec_C_indvs.codcourrier2),1,15);
        O_donnee(6):=Substr(pk_libelle.f_lib('TITRE',rec_C_indvs.codtitre),1,15);
        O_donnee(7):=Substr(pk_personne.f_nom(rec_C_indvs.numindiv,30,0),1,30);
        O_donnee(8):=Substr(rec_C_indvs.nom,1,30);
        O_donnee(9):=Substr(rec_C_indvs.prenom,1,20);
        O_donnee(10):=pk_personne.f_adresse (
                              pk_personne.f_idadresse (
                            rec_C_indvs.numindiv, 0, sysdate, 'O', 0 ),
                              1,rec_C_indvs.numindiv);
        O_donnee(11):=pk_personne.f_adresse (
                              pk_personne.f_idadresse (
                             rec_C_indvs.numindiv, 0, sysdate, 'O', 0 ),
                              2,rec_C_indvs.numindiv);
        O_donnee(12):=pk_personne.f_adresse (
                              pk_personne.f_idadresse (
                      rec_C_indvs.numindiv, 0, sysdate, 'O', 0 ),
                              3, rec_C_indvs.numindiv);
        O_donnee(13):=pk_personne.f_adresse (
                              pk_personne.f_idadresse (
                             rec_C_indvs.numindiv, 0, sysdate, 'O', 0 ),
                              4,rec_C_indvs.numindiv);
        O_donnee(14):=Substr(f_pays(rec_C_indvs.codpays),1,15);
        O_donnee(15):=rec_C_indvs.tel;
        O_donnee(16):=rec_C_indvs.fax;
        O_donnee(17):=d2e(rec_C_indvs.datnais);
        O_donnee(18):=Substr(pk_libelle.f_lib('TPAS',rec_C_indvs.typassu),1,15);
        O_donnee(19):=rec_C_indvs.natur;
	--,1,'Ouvreur de droit',2,'Ayant-Droit';
        O_donnee(20):=Substr(pk_libelle.f_lib('TYAD',rec_C_indvs.typadr),1,15);
        O_donnee(21):=rec_C_indvs.matorg;
        O_donnee(22):=rec_C_indvs.cless;
        O_donnee(23):=Substr(pk_libelle.f_lib('REGIME',rec_C_indvs.regime),1,15);
        O_donnee(24):=Substr(pk_libelle.f_lib('ORGNS',rec_C_indvs.orgbase),1,15);
        O_donnee(25):=rec_C_indvs.caisse;
        O_donnee(26):=rec_C_indvs.guichetorg;
        O_donnee(27):=rec_C_indvs.cle;
        O_donnee(28):=rec_C_indvs.rang;
        O_donnee(29):=rec_C_indvs.numassu;
END charge_indvs;
/
