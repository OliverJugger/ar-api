CREATE PROCEDURE ARTHUS.P_IDENT_COT_DSN_R (i_deb date, i_fin date,i_remise NUMBER)
IS
   G_nbre_lignes         Number := 1;
  o_erreur              VARCHAR2(200):=NULL;
  loc_debut DATE;
  loc_fin   DATE;

  loc_heure number;
  loc_min   number;

  CURSOR c_contrat
      IS
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
   AND af.datefic between i_deb and i_fin
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
   --AND qttc.numquit is null;
  -- and adh.numgar =14352;
   and af.numremise >=i_remise;
    --ORDER BY adh.NUMGAR ASC;
BEGIN
  --
  -- Lancement de l identification des cotisations
  --

  FOR rec_contrat IN c_contrat LOOP

    SELECT to_char(sysdate, 'hh24') into loc_heure FROM DUAL;
    SELECT to_char(sysdate, 'mi') into loc_min FROM DUAL;
    /*IF loc_heure >=6 AND loc_min>10 THEN
    EXIT;--dernier traitement à 06h30
    END IF;*/

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

END P_IDENT_COT_DSN_R;
/
