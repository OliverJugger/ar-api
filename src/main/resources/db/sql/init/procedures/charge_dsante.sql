CREATE procedure ARTHUS.charge_dsante(I_num_dossier IN  number,
					  t_donnee OUT pk_texte.donnee)
is
CURSOR C_dsante is
	Select 	dossier_sante.num_dossier,
		dossier_sante.ref_dossier,
		dossier_sante.numindiv,
	        dossier_sante.typbene,
		dossier_sante.numbene,
		dossier_sante.devise,
                dossier_sante.devise_out,
		dossier_sante.creation,
	        dossier_sante.dateouv,
		dossier_sante.dateferm,
		dossier_sante.maj,
		dossier_sante.numutil,
		dossier_sante.numassu,
		dossier_sante.nat_doss,
		dossier_sante.type_doss,
		dossier_sante.numprescrip,
		dossier_sante.numtiers,
		dossier_sante.pec,
                dossier_sante.num_dossier_pec,
                dossier_sante.num_fact_pec,
                dossier_sante.num_entree_pec,
                dossier_sante.reseau,
                histo_dossier.debut,
                histo_dossier.etat,
                histo_dossier.motif,
                histo_dossier.datsai,
                courr_dest.numindiv dest_courrier

	From	dossier_sante,histo_dossier,courr_dest
	Where 	dossier_sante.num_dossier=I_num_dossier
        And     dossier_sante.num_dossier=histo_dossier.num_dossier
        ANd     dossier_sante.num_dossier=courr_dest.id
        ANd     courr_dest.valide=1;

rec_C_dsante C_dsante%rowtype;

BEGIN
     Open C_dsante;
     Fetch C_dsante Into rec_C_dsante;
     Close C_dsante;
     t_donnee(1):=rec_C_dsante.num_dossier;
     t_donnee(2):=rec_C_dsante.ref_dossier;
     t_donnee(3):=rec_C_dsante.numindiv;
     t_donnee(4):=rec_C_dsante.typbene;
     t_donnee(5):=rec_C_dsante.numbene;
     t_donnee(6):=rec_C_dsante.devise;
     t_donnee(7):=rec_C_dsante.devise_out;
     t_donnee(8):=rec_C_dsante.creation;
     t_donnee(9):=rec_C_dsante.dateouv;
     t_donnee(10):=rec_C_dsante.dateferm;
     t_donnee(11):=rec_C_dsante.maj;
     t_donnee(12):=rec_C_dsante.numutil;
     t_donnee(13):=rec_C_dsante.numassu;
     t_donnee(14):=rec_C_dsante.nat_doss;
     t_donnee(15):=rec_C_dsante.type_doss;
     t_donnee(16):=rec_C_dsante.numprescrip;
     t_donnee(17):=rec_C_dsante.numtiers;
     t_donnee(18):=rec_C_dsante.pec;
     t_donnee(19):=rec_C_dsante.num_dossier_pec;
     t_donnee(20):=rec_C_dsante.num_fact_pec;
     t_donnee(21):=rec_C_dsante.num_entree_pec;
     t_donnee(22):=rec_C_dsante.reseau;
     t_donnee(23):=rec_C_dsante.debut;
     t_donnee(24):=rec_C_dsante.etat;
     t_donnee(25):=rec_C_dsante.motif;
     t_donnee(26):=rec_C_dsante.datsai;
     t_donnee(27):=rec_C_dsante.dest_courrier;

     Exception
	when no_data_found then
           null;

END charge_dsante;
/
