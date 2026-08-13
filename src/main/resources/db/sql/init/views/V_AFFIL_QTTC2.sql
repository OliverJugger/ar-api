CREATE FORCE VIEW ARTHUS.V_AFFIL_QTTC2 AS
SELECT  
         aq.NUMQUIT                                                             --   N° quittance Arthus
       , af.NUMCLI                                                              --   Société
       , f_nom(af.numcli) NOM_CLI
       , adh.NUMGAR                                                              --   n° contrat
       , adh.code_pop
       , cntrt.REFCIE                                                              --   Référence       
       ,NULL DEBUT-- q.DEBUT 
       , NULL FIN --q.FIN
       , af.datefic
       , SUM(ind.mt_base) MT_BASE
       , NULL RESERVE1
       , NULL ETAT_QUITTANCE /*, DECODE (f_datemis (4, aq.numquit, 1, 0),
                         'Non émis', DECODE (f_datemis (4, aq.numquit,1,99),
                         'Non annulé', f_datemis       (4, aq.numquit,1,0),
                                       f_datemis       (4, aq.numquit,1,99)
                                            ),
                                       f_datemis       (4, aq.numquit, 1, 0)
                )                                    ETAT_QUITTANCE            --   Etat échéance calculée*/
       , NULl MT_ARTHUS--q.montant_d                                 MT_ARTHUS                 --   Mt Arthus
       , NULL ECART--(F_TOTQTTC_IND(aq.NUMQUIT)-q.montant_d  )    ECART                     --   Ecart Arthus DSN
     , af.numporte
    FROM 
    AFFIL_FICHIER af
    INNER JOIN AFFIL_PORTE_CNTRT ac ON (ac.numremise = af.numremise
                                    AND ac.numporte = af.numporte
                                    AND ac.ENTREPRISE = af.ENTREPRISE
                                    AND ac.etabli = af.etabli
                                    AND ac.num_ordre = af.num_ordre)   
    INNER JOIN  AFFIL_PORTE ap  ON (  ac.numremise = ap.numremise
                                  AND ac.numporte = ap.numporte
                                  AND ac.ENTREPRISE = ap.ENTREPRISE
                                  AND ac.etabli = ap.etabli
                                  AND ac.num_ordre = ap.num_ordre )  
    INNER JOIN AFFIL_PORTE_ADH adh ON( adh.REF_EXT_CNTRT = ac.REF_EXT_CNTRT
                                   AND adh.numremise = ap.numremise
                                   AND adh.numporte = ap.numporte
                                   AND adh.numligne = ap.numligne
                                    and adh.numgar =7479
                                   )
    INNER JOIN contrat cntrt ON ( adh.numgar = cntrt.numgar)    
    INNER JOIN AFFIL_PORTE_QTTC aq ON (adh.numremise = aq.numremise
                                    AND adh.numporte = aq.numporte
                                   AND adh.REF_EXT_CNTRT = aq.REF_EXT_CNTRT
                                   AND adh.REF_EXT_ADH = aq.REF_EXT_ADH
                                   AND adh.numligne = aq.numligne)                               
    INNER JOIN AFFIL_PORTE_QTTC_INDIV ind ON ( aq.num_qttc = ind.num_qttc
                                        AND   aq.numligne = ind.numligne
                                        AND   aq.numporte = ind.numporte
                                        AND   aq.numremise = ind.numremise)
    --LEFT OUTER JOIN V_QTTC_GLOBAL q   ON q.NUMQUIT = aq.NUMQUIT
    WHERE af.numporte =20
    AND ap.etat <>4
    AND af.num_annulante IS NULL
    AND adh.numgar is not null
    and af.numporte =20


   /* AND ((aq.NUMQUIT IS NULL AND NOT EXISTS ( 
        SELECT  1 FROM AFFIL_PORTE_QTTC apq 
        WHERE ac.numremise = apq.numremise AND ac.numporte = apq.numporte
        AND adh.REF_EXT_CNTRT = apq.REF_EXT_CNTRT
        AND apq.numquit IS NOT NULL) ) OR aq.NUMQUIT IS NOT NULL) -- pose problème si ref_ext_cntrt identique pour des collèges diff */
    group by aq.NUMQUIT,af.NUMCLI, adh.NUMGAR ,adh.code_pop, cntrt.REFCIE --,q.DEBUT , q.FIN ,q.montant_d 
    , af.datefic,af.numporte
