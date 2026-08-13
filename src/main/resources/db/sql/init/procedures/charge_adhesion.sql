CREATE procedure ARTHUS.charge_adhesion ( I_cle IN pk_texte.clefs,
					   O_donnee OUT pk_texte.donnee)
is
CURSOR C_adhesion is
select adhesion.numindiv,
       adhesion.numfor,
       gar_cntrt.nomgar,
       gar_cntrt.libelle,
       adhesion.etat,
       adhesion.datapli,
       adhesion.datper,
       adhesion.rang,
       adhesion.dis_carence,
       adhesion.dis_franchise,
       adhesion.flag_regime,
       adhesion.motif
From   adhesion,gar_cntrt
where   adhesion.idadhesion=I_cle(0)
and     adhesion.numindiv=nvl(I_cle(1),adhesion.numindiv)
and     adhesion.numfor=nvl(I_cle(2),adhesion.numfor)
and     adhesion.numfor=gar_cntrt.numfor
order by adhesion.numindiv,
	 adhesion.numfor;
rec_C_adhesion C_adhesion%rowtype;
BEGIN
       Open C_adhesion;
       Fetch C_adhesion Into rec_C_adhesion;
       Close C_adhesion;
       O_donnee(1):=rec_C_adhesion.numindiv;
       O_donnee(2):=rec_C_adhesion.numfor;
       O_donnee(3):=rec_C_adhesion.nomgar;
       O_donnee(4):=Substr(rec_C_adhesion.libelle,1,25);
       O_donnee(5):=pk_libelle.f_lib('ETIN',rec_C_adhesion.etat);
       O_donnee(6):=d2e(rec_C_adhesion.datapli);
       O_donnee(7):=d2e(rec_C_adhesion.datper);
       O_donnee(8):=rec_C_adhesion.rang;
       O_donnee(9):=rec_C_adhesion.dis_carence;
       O_donnee(10):=rec_C_adhesion.dis_franchise;
       O_donnee(11):=rec_C_adhesion.flag_regime;
       O_donnee(12):=pk_libelle.f_lib('ET_CVRT',rec_C_adhesion.motif);
END charge_adhesion;
/
