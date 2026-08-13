CREATE Procedure ARTHUS.P_Calc_Sinistre_dev (
				a_numdoss	In SINISTRE_SANTE.NUM_DOSSIER%TYPE
				)
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

  -- Ajustement des montants OUT

 CURSOR AJ_SNTR_DOSSIER IS
        Select	num_dossier,numligne,max(numsin) mxnumsin,sum(mtreel) mtreeltot,sum(decode(F_type_couv(sntr_dossier.NUMSIN_SNTR, sntr_dossier.NUM_dossier,sntr_dossier.NUMligne), 3,0,4,0,sinistre.mtfrais)) mtfraisTot
				From	sinistre, sntr_dossier
				where  sinistre.numsin=sntr_dossier.NUMSIN_SNTR
				and num_dossier=a_numdoss
				and numdec=0
				group by  num_dossier,numligne;

--
	REC_AJ_SNTRDossier AJ_SNTR_DOSSIER%ROWTYPE;

	--s_devise_ct sinistre.monnaie%TYPE;
	--s_datsin date;

	AJ_devise_in  NUMBER(3);
	AJ_devise_out NUMBER(3);
	AJ_type_couv  NUMBER(1);
	--dev_ref number(3);

	--loc_mtfrais sinistre.mtfrais%TYPE;
	AJ_mtfrais_IN sinistre_sante.mtfrais_IN%TYPE;
	--loc_mtprest sinistre.mtprest%TYPE;
	--loc_mtremb  sinistre.mtremb%TYPE;
	AJ_Remb_Total  sinistre.mtreel%TYPE;
    --loc_autrb   sinistre.autrb%TYPE;

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

  OPEN  AJ_SNTR_DOSSIER;

  LOOP

  FETCH AJ_SNTR_DOSSIER INTO REC_AJ_SNTRDossier;

      IF AJ_SNTR_DOSSIER%FOUND THEN

					if REC_AJ_SNTRDossier.mtreeltot=REC_AJ_SNTRDossier.mtfraistot then

							select devise_in,devise_out,mtfrais_IN
							into AJ_devise_in,AJ_devise_out,AJ_mtfrais_IN
							from sinistre_sante
							where num_dossier=REC_AJ_SNTRDossier.NUM_DOSSIER and numligne=REC_AJ_SNTRDossier.NUMLIGNE;

							if AJ_devise_in=AJ_devise_out then

								select F_dcpt_RembTotal(REC_AJ_SNTRDossier.NUM_DOSSIER,REC_AJ_SNTRDossier.NUMLIGNE),
											 f_type_couv(REC_AJ_SNTRDossier.mxnumsin,REC_AJ_SNTRDossier.NUM_DOSSIER,REC_AJ_SNTRDossier.NUMLIGNE)
								into AJ_Remb_Total, AJ_type_couv
								from dual;


								UPDATE sinistre_dev SET
									MTREEL_OUT =MTREEL_OUT +(mtfrais_IN  - AJ_Remb_Total),
									MTREEL_IN  =MTREEL_OUT +(mtfrais_IN  - AJ_Remb_Total),
									MTPREST_OUT =decode(AJ_type_couv,1,mtfrais_IN ,2, mtfrais_IN ,MTPREST_OUT),
									MTPREST_IN  =decode(AJ_type_couv,1,mtfrais_IN ,2, mtfrais_IN ,MTPREST_IN),
									MTREMB_OUT  =decode(AJ_type_couv,1,mtfrais_IN,MTREMB_OUT),
									MTREMB_IN   =decode(AJ_type_couv,1,mtfrais_IN,MTREMB_IN)
								WHERE NUMSIN = REC_AJ_SNTRDossier.mxnumsin;

							end if;

					end if;
      ELSE

           CLOSE AJ_SNTR_DOSSIER;
           exit;

      END IF;

  END LOOP;



END	P_Calc_Sinistre_dev;
/
