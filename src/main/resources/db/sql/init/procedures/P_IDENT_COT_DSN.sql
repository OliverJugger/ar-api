CREATE PROCEDURE ARTHUS.P_IDENT_COT_DSN
IS
  G_nbre_lignes         Number := 1;
  o_erreur              VARCHAR2(200):=NULL;
  loc_debut DATE;
  loc_fin   DATE;
  loc_start DATE;
  loc_end   DATE;
  loc_heure number;
  loc_min   number;

  CURSOR c_contrat (i_start DATE, i_end DATE) IS
  SELECT DISTINCT af.numremise,adh.NUMGAR,pr.numporte,c.numcli, af.datefic
    FROM AFFIL_PORTE_ADH adh
	   , AFFIL_FICHIER af
	   , AFFIL_PORTE ap
       , PORTE_REMISE pr
	   , contrat c
     , affil_porte_qttc qttc
   WHERE  pr.NUMREMISE = adh.NUMREMISE
	 AND ap.NUMREMISE = adh.NUMREMISE
	 AND ap.NUMREMISE = af.NUMREMISE
     AND pr.NUMPORTE = adh.NUMPORTE
	 AND af.NUMPORTE= adh.NUMPORTE
	 AND ap.NUMPORTE= adh.NUMPORTE
	 AND ap.NUMLIGNE = adh.NUMLIGNE
	 AND ap.ETABLI = af.ETABLI
	 AND ap.ENTREPRISE = af.ENTREPRISE
	 AND ap.NUM_ORDRE = af.NUM_ORDRE
   AND ap.etat<>4 --annulé
   AND af.datefic BETWEEN  i_start and i_end
   AND qttc.numremise = ap.numremise
   and qttc.numligne = ap.numligne
   and qttc.numporte = ap.numporte
   AND qttc.ref_ext_cntrt = adh.ref_ext_cntrt
   AND qttc.ref_ext_adh = adh.ref_ext_adh
   AND qttc.statut<>6 --exclu
   AND pr.numporte = 20
	 AND af.nature =1 --DSN mensuelle uniquement
	 AND c.numgar = adh.numgar
   AND adh.numgar is NOT NULL
   AND qttc.numquit is null;
  -- and adh.numgar =14352;
  -- and af.numremise >79000;
BEGIN

  --détermination des dates de fichiers à prendre en compte. On lance en fin de trimestre la totalité du trimestre
  -- à cheval avec le trimestre suivant (dout le -35 jours car en avril on doit traiter T1 uniquement)
  loc_start := trunc(SYSDATE-35 ,'Q');
  loc_end := add_months(loc_start,3);
  --
  -- Lancement de l identification des cotisations
  --

  FOR rec_contrat IN c_contrat(loc_start,loc_end) LOOP

    SELECT to_char(sysdate, 'hh24') into loc_heure FROM DUAL;
    SELECT to_char(sysdate, 'mi') into loc_min FROM DUAL;
    IF loc_heure >=2 AND loc_min>10 THEN
    EXIT;--dernier traitement à 06h30
    END IF;

    loc_debut:=rec_contrat.datefic;
    --loc_fin := add_months(loc_debut,3)-1;
    ARTHUS.PK_GEST_COTIS_AF06T.P_GestCotisations ( rec_contrat.numporte
                                                 , rec_contrat.numremise
                                                 , rec_contrat.numcli
                                                 , rec_contrat.numgar
                                                 , loc_debut
                                                 , loc_fin
                                                 , sid
                                                 , 'AF06T'
                                                 , G_nbre_lignes
                                                 , NULL
                                                 , 1
                                                 , o_erreur);

    COMMIT;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END P_IDENT_COT_DSN;
/
