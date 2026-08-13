CREATE PROCEDURE ARTHUS.P_LIQ_DOSSIER( i_num_dossier IN dossier_sante.num_dossier%type,
                                          i_numfact    IN dossier_sante.num_fact_pec%TYPE default NULL,
                                          i_datfact    IN dossier_sante.date_fact_pec%TYPE  default sysdate,
                                          o_new_dossier OUT dossier_sante.num_dossier%type)
as

/********PROCEDURE PERMETTANT DE LIQUIDER UN DOSSIER SANTE********/
-- renvoi le numéro de dossier liquidé dans o_new_dossier
-- -1 si erreur technique
--  0 si le dossier n'est pas trouvé
  loc_dossier dossier_sante%rowtype;
  loc_numfact         suivi_fact_tpe.numfact%TYPE;
  loc_datfact         suivi_fact_tpe.datfact%TYPE;
  loc_num_dossier_liq dossier_sante.num_dossier%TYPE;
  loc_sens_porte      libelle.sens%TYPE;
  loc_numano          NUMBER;
  loc_libelle         VARCHAR2(300);

  exc_dossier_inconnu EXCEPTION;
  exc_rej_technique   EXCEPTION;

BEGIN

  BEGIN  -- récuperation du dossier a liquider
    SELECT * INTO  loc_dossier
    FROM dossier_sante
    WHERE num_dossier = i_num_dossier
    AND type_doss = 4;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      o_new_dossier:= 0;
      return;
  END;

  PK_CTRL_TP.P_INS_DOSSIER_SANTE(P_ref     => loc_dossier.ref_dossier,
                                P_numindiv => loc_dossier.numindiv,
                                P_PS       => loc_dossier.numprescrip,
                                P_numassu  => loc_dossier.numassu,
                                P_numporte => loc_dossier.numporte,
                                P_natdoss  => loc_dossier.nat_doss,
                                P_typedoss => 1,
                                P_num_dossier_porte =>'',--à vérifier si bon
                                O_num_dossier => loc_num_dossier_liq);

  IF loc_num_dossier_liq=0 THEN
    loc_libelle :='Impossible de créer le dossier de liquidation';
    RAISE exc_rej_technique;
  END IF;
  PK_CTRL_TP.P_INS_HISTO_DOSSIER(loc_num_dossier_liq,0,0,sysdate);


   --déplacement des sinistres et création du lien entre les 2 dossiers
  PK_CALCUL_DOSSIER.P_CPYL_PEC( P_num_dossier_Pec => loc_dossier.num_dossier,
                                P_num_dossier     => loc_num_dossier_liq,
                                P_num_porte       => loc_dossier.numporte,
                                O_sens_porte      => loc_sens_porte,
                                O_erreur          => loc_numano);
                                 --TO DO vérifié que le numsin_sntrprt est bien alimenté lors de la copie
  IF loc_numano = 1373 THEN loc_numano:=NULL;
  ELSE
    --copie des sinistres plantées
    loc_libelle :='Impossible de copier les sinistres dans le dossier';
    RAISE exc_rej_technique; --rejet technique-> plantage à identifier
  END IF;

    --mise à jour du dossier de liquidation
  UPDATE dossier_sante
  SET
      pec = 1,
      num_fact_pec = nvl(i_numfact,loc_dossier.num_fact_pec),
      date_fact_pec = nvl(i_datfact,sysdate)
  WHERE num_dossier = loc_num_dossier_liq;
  commit;
  dbms_output.put_line('nouveau dossie = '||loc_num_dossier_liq);
  o_new_dossier:= loc_num_dossier_liq;

  EXCEPTION
    WHEN exc_rej_technique THEN
      o_new_dossier:=1;
      RETURN ;


END P_LIQ_DOSSIER;
/
