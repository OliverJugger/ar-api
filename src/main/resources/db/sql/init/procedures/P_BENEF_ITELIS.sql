CREATE PROCEDURE ARTHUS.P_BENEF_ITELIS 
IS
 loc_requete varchar2(5000);
 o_erreur varchar2(100);
 numlig   number :=0;
begin  
numlig :=numlig+1;
 PK_TRACE.P_INS_journal_adm
              ( I_nom_traitement =>'P_BENEF_ITELIS',
                I_session    =>SID,
                I_niv_msg    =>1, 
                I_msg_adm    =>'debut de traitement ', 
                I_date       =>sysdate,
		        I_idligne	 =>numlig );
 loc_requete := '
              SELECT ''GEREP'' AS NOM_COURTIER, ''GEREP'' AS NOM_GESTIONNAIRE, PK_LIBELLE.F_LIB(''ORGN'',cr.numorg) AS NOM_ASSUREUR, pk_personne.f_nom(cr.numcli) AS NOM_CLIENT_PAYEUR
                          , cr.refcie AS DESIGNATION_PORTEFEUILLE, cr.refcie AS CODE_CONTRAT, COUNT(DISTINCT adh.numindiv) AS NOMBRE_BENEFICIAIRES, ''OPT_DEN_AUD'' AS PERIMETRE_SERVICE_DEPLOYE
                          , DECODE(F_VAL_VAR_ALL(adh.numfor,F_FIND_VAR(''LOGO_OPTI''), SYSDATE),NULL,''NON'',''OUI'') AS SELECTION_OPTI
                          , DECODE(MAX(F_VAL_VAR_ALL(adh.numfor,F_FIND_VAR(''LOGO_OPTI''), SYSDATE)),NULL,NULL,1,''OPTI_1'',2,''OPTI_2'',3,''OPTI_3'',4,''OPTI_4'',5,''OPTI_5'') AS SELECTION_OPTI_DETAIL 
                          , '' '' ||D2E(Greatest(PK_HISTO_CONTRAT.f_sel_date_debut (cr.numgar, SYSDATE), E2D(''01/01/''||TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, ''Q''), -3),''YYYY'')))) AS DATE_PRISE_EFFET_SERVICE
                          , '' '' ||D2E(Least(PK_HISTO_CONTRAT.f_sel_date_resil (cr.numgar, SYSDATE), E2D(''31/12/''||TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, ''Q''), -3),''YYYY'')))) AS DATE_FIN_EFFET_SERVICE
                         FROM porte_contrat pc,
                          contrat_ref cr,
                         adhesion adh,
                          (SELECT adh.numindiv, MIN(TO_CHAR(adh.DATAPLI, ''YYYYDDMM'') || adh.numgar || adh.numfor ) Top
                                FROM porte_contrat pc, contrat_ref cr,
                                  adhesion adh
                                WHERE  1 = 1
                                  AND  pc.numporte =  22
                                  AND  pc.numgar   =  cr.numgar
                                  AND  adh.numgar  =  cr.numgar
                                  AND  adh.rang    <> 2
                                  AND  adh.etat    <>  2
                                  AND  adh.datapli - 1 <  TRUNC(SYSDATE, ''Q'') - 1
                                  AND adh.datapli <> nvl(adh.datper,adh.datapli+1)
                                  AND  COALESCE(adh.datper, SYSDATE+1000) - 1 > ADD_MONTHS(TRUNC(SYSDATE, ''Q''), -3)
                                  GROUP BY adh.numindiv) IndivTop
                         WHERE  1 = 1
                          AND  pc.numporte =  22
                          AND  pc.numgar   =  cr.numgar
                          AND  adh.numgar  =  cr.numgar
                          AND  adh.rang    <> 2
                          AND  adh.datapli - 1 < TRUNC(SYSDATE, ''Q'') - 1 
                          AND adh.datapli <> nvl(adh.datper,adh.datapli+1)
                          AND  COALESCE(adh.datper, SYSDATE+1000) - 1 > ADD_MONTHS(TRUNC(SYSDATE, ''Q''), -3)
                          AND  IndivTop.numindiv = adh.numindiv
                          AND  IndivTop.Top = TO_CHAR(adh.DATAPLI, ''YYYYDDMM'') || adh.numgar || adh.numfor
                         GROUP BY ''GEREP'', ''GEREP'', PK_LIBELLE.F_LIB(''ORGN'',cr.numorg), pk_personne.f_nom(cr.numcli), cr.refcie, 
cr.refcie, ''OPT_DEN_AUD'', 
DECODE(F_VAL_VAR_ALL(adh.numfor,F_FIND_VAR(''LOGO_OPTI''), SYSDATE),NULL,''NON'',''OUI''), 
'' '' ||D2E(Greatest(PK_HISTO_CONTRAT.f_sel_date_debut (cr.numgar, SYSDATE), E2D(''01/01/''||TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, ''Q''), -3),''YYYY'')))), 
'' '' ||D2E(Least(PK_HISTO_CONTRAT.f_sel_date_resil (cr.numgar, SYSDATE), E2D(''31/12/''||TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE, ''Q''), -3),''YYYY''))))

                    '
                    ;

           PK_CONVERT_TO_XLSX.CONVERT_TO_XLSX(p_requete =>loc_requete
                                         ,p_directory=>'EXPORT'
                                          ,p_nom_fich=>'Fichier_des_declaratifs_des_effectifs_beneficiaires.xlsx',
                                          o_erreur =>o_erreur
                                         );
 numlig :=numlig+1;
 PK_TRACE.P_INS_journal_adm
              ( I_nom_traitement =>'P_BENEF_ITELIS',
                I_session    =>SID,
                I_niv_msg    =>1, 
                I_msg_adm    =>'fin de traitement ', 
                I_date       =>sysdate,
		        I_idligne	 =>numlig );
EXCEPTION

 WHEN OTHERS THEN
    numlig :=numlig+1;
    PK_TRACE.P_INS_journal_adm
              ( I_nom_traitement =>'P_BENEF_ITELIS',
                I_session    =>SID,
                I_niv_msg    =>1, 
                I_msg_adm    =>'Echec de l''extraction des beneficiares itelis '||sqlerrm , 
                I_date       =>sysdate,
		        I_idligne	 => numlig);

END P_BENEF_ITELIS;
/
