CREATE function ARTHUS.f_Calcul_Sinistre_dev (
				a_numdoss	In VARCHAR2
				)
Return Number
Is

-- Lance le calcul en devise de toutes les ligne sinistre du dossier

--
 CURSOR SNTR_DOSSIER IS
        SELECT  NUM_DOSSIER, NUMLIGNE, NUMSIN_SNTR
        FROM    SNTR_DOSSIER
        WHERE   NUM_DOSSIER = a_numdoss;

--
  REC_SNTRDossier SNTR_DOSSIER%ROWTYPE;

	s_devise_ct sinistre.monnaie%TYPE;
	s_datsin date;

	ld_devise_in NUMBER(3);
	ld_devise_out NUMBER(3);
	dev_ref number(3);

	loc_mtfrais sinistre.mtfrais%TYPE;
	loc_mtfrais_IN sinistre_sante.mtfrais_IN%TYPE;
	loc_mtprest sinistre.mtprest%TYPE;
	loc_mtremb  sinistre.mtremb%TYPE;
	loc_mtreel  sinistre.mtreel%TYPE;
  loc_autrb   sinistre.autrb%TYPE;


BEGIN



  OPEN  SNTR_DOSSIER;

  LOOP

  FETCH SNTR_DOSSIER INTO REC_SNTRDossier;
      IF SNTR_DOSSIER%FOUND THEN

  	  select pk_devise.devise_ct(numgar)
			into s_devise_ct
			from sinistre
			where numsin= REC_SNTRDossier.NUMSIN_SNTR;

			select mtfrais,mtprest,mtremb,mtreel,autrb,monnaie, datsin
			into loc_mtfrais,loc_mtprest,loc_mtremb,loc_mtreel,loc_autrb,dev_ref, s_datsin
			from sinistre
			where numsin= REC_SNTRDossier.NUMSIN_SNTR;

			select devise_in,devise_out,mtfrais_IN
			into ld_devise_in,ld_devise_out,loc_mtfrais_IN
			from sinistre_sante
			where num_dossier=REC_SNTRDossier.NUM_DOSSIER and numligne=REC_SNTRDossier.NUMLIGNE;

			  	 		UPDATE sinistre_dev SET   DEV_CT=s_devise_ct,
			  	 															DEV_IN=ld_devise_in,
			  	 															DEV_OUT=ld_devise_out,
			  	 															MTFRAIS_CT =pk_devise.f_conv_mt(dev_ref,s_devise_ct,  loc_mtfrais,s_datsin),
			  	 															MTFRAIS_IN =loc_mtfrais_IN,
			  	 															MTFRAIS_OUT=decode(ld_devise_out,ld_devise_in,loc_mtfrais_IN,pk_devise.f_conv_mt(dev_ref,ld_devise_out,loc_mtfrais,s_datsin)),
			  																MTPREST_CT =pk_devise.f_conv_mt(dev_ref,s_devise_ct,  loc_mtprest,s_datsin),
			  																MTPREST_IN =pk_devise.f_conv_mt(dev_ref,ld_devise_in, loc_mtprest,s_datsin),
			  																MTPREST_OUT=pk_devise.f_conv_mt(dev_ref,ld_devise_out,loc_mtprest,s_datsin),
			  																MTREMB_CT  =pk_devise.f_conv_mt(dev_ref,s_devise_ct,  loc_mtremb ,s_datsin),
			  																MTREMB_IN  =pk_devise.f_conv_mt(dev_ref,ld_devise_in, loc_mtremb ,s_datsin),
			  																MTREMB_OUT =pk_devise.f_conv_mt(dev_ref,ld_devise_out,loc_mtremb ,s_datsin),
			  																MTREEL_CT  =pk_devise.f_conv_mt(dev_ref,s_devise_ct,  loc_mtreel ,s_datsin),
			  																MTREEL_IN  =pk_devise.f_conv_mt(dev_ref,ld_devise_in, loc_mtreel ,s_datsin),
			  																MTREEL_OUT =pk_devise.f_conv_mt(dev_ref,ld_devise_out,loc_mtreel ,s_datsin),
			  																AUTRB_CT   =pk_devise.f_conv_mt(dev_ref,s_devise_ct,  loc_autrb  ,s_datsin),
			  																AUTRB_IN   =pk_devise.f_conv_mt(dev_ref,ld_devise_in, loc_autrb  ,s_datsin),
			  																AUTRB_OUT  =pk_devise.f_conv_mt(dev_ref,ld_devise_out,loc_autrb  ,s_datsin)
			  		WHERE NUMSIN = REC_SNTRDossier.numsin_sntr;



      ELSE

           CLOSE SNTR_DOSSIER;
           exit;

      END IF;

  END LOOP;

  return 1;

exception when others then  return 0;


END	f_Calcul_Sinistre_dev;
