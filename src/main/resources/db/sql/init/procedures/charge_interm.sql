CREATE procedure ARTHUS.charge_interm ( I_numindiv IN number,
					   O_donnee OUT pk_texte.donnee)
is
CURSOR C_interm is
Select indvs.numindiv,
       indvs.refcie,
       indvs.qualite,
       indvs.codcourrier1,
       indvs.nom,
       indvs.prenom,
       indvs.codpays,
       indvs.tel,
       indvs.fax,
       indvs.email,
       pers_morale.creation,
       pers_morale.siret,
       pers_morale.ape,
       pers_morale.code_naf,
       pers_morale.vip,
       pers_morale.convention,
       pers_morale.potentiel,
       pers_intermediaire.mode_retro
From    indvs,
	pers_intermediaire,
	pers_morale
Where   indvs.numindiv=I_numindiv
And     indvs.numindiv=pers_morale.numindiv
And     pers_intermediaire.numindiv=indvs.numindiv;
rec_C_interm  C_interm%rowtype;
BEGIN
          Open C_interm;
	  Fetch C_interm Into rec_C_interm;
	  Close C_interm;
	  O_donnee(1):=rec_C_interm.numindiv;
          O_donnee(2):=rec_C_interm.refcie;
	  O_donnee(3):=Substr(pk_libelle.f_lib('QLTE',rec_C_interm.qualite),1,25);
          O_donnee(4):=Substr(pk_libelle.f_lib('CODC1',rec_C_interm.codcourrier1),1,25);
	  O_donnee(5):=Substr(pk_personne.f_nom(rec_C_interm.numindiv,30,0),1,30);
	  O_donnee(6):=Substr(rec_C_interm.nom,1,30);
	  O_donnee(7):=Substr(rec_C_interm.prenom,1,20);
	  O_donnee(8):=pk_personne.f_adresse (
					pk_personne.f_idadresse (
								rec_C_interm.numindiv, 0, sysdate, 'O', 0 ),1,rec_C_interm.numindiv);
	  O_donnee(9):=pk_personne.f_adresse (
					pk_personne.f_idadresse (
							rec_C_interm.numindiv, 0, sysdate, 'O', 0 ),2,rec_C_interm.numindiv);
	  O_donnee(10):=pk_personne.f_adresse (
					pk_personne.f_idadresse (
							rec_C_interm.numindiv, 0, sysdate, 'O', 0 ),3,rec_C_interm.numindiv);
	  O_donnee(11):=pk_personne.f_adresse (
					pk_personne.f_idadresse (
								rec_C_interm.numindiv, 0, sysdate, 'O', 0 ),4,rec_C_interm.numindiv);
	  O_donnee(12):=Substr(f_pays(rec_C_interm.codpays),1,15);
	  O_donnee(13):=rec_C_interm.tel;
	  O_donnee(14):=rec_C_interm.fax;
	  O_donnee(15):=rec_C_interm.email;
	  O_donnee(16):=d2e(rec_C_interm.creation);
	  O_donnee(17):=rec_C_interm.siret;
	  O_donnee(18):=rec_C_interm.ape;
	  O_donnee(19):=rec_C_interm.code_naf;
	  O_donnee(20):=rec_C_interm.vip;
          O_donnee(21):=Substr(pk_libelle.f_lib('CONVENTION',rec_C_interm.convention),1,25);
          O_donnee(22):=Substr(pk_libelle.f_lib('POTENTIEL',rec_C_interm.potentiel),1,25);
          O_donnee(23):=Substr(pk_libelle.f_lib('MD_RETRO',
						rec_C_interm.mode_retro),
						1,25);
END charge_interm;
/
