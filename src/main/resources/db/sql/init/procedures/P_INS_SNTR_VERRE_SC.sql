CREATE PROCEDURE ARTHUS.P_INS_SNTR_VERRE_SC 
IS

CURSOR c_santeclair
IS 
SELECT flux.id_flux,statut,id_type,TO_CHAR(dat_maj, 'DD/MM/YYYY HH24:MI:SS'),flux_aller
, PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),212,5),3,2) sphere_OD
, PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),217,5),3,2) cylindre_OD
, PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),222,3),3,0) axe_OD
, PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),225,4),2,2) addition_OD
, PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),229,5),3,2) sphere_OG
, PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),234,5),3,2) cylindre_OG
, PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),239,3),3,0) axe_OG
, PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),242,4),2,2) addition_OG
, PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),343,5)nature
, PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),175,16 )ref_doss
FROM flux, hISto_flux_ws_sc
WHERE id_type =21
AND id_flux_sc = flux.id_flux
--AND flux.dat_maj > sysdate-5--ADD_MONTHS (sysdate, -12)-- -24
AND TRUNC(flux.dat_maj) BETWEEN e2d('01/01/2020') and  trunc(sysdate-1)
--AND PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),175,16 ) = 'P202103202622SIA'
--and id_flux_sc=18810545 
AND (NVL(PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),212,5),3,2),0) <>0  
OR NVL(PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),217,5),3,2),0) <>0 
OR NVL(PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),222,3),3,0),0) <>0
OR NVL(PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),225,4),2,2),0) <>0
OR NVL(PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),229,5),3,2),0) <>0 
OR NVL(PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),234,5),3,2),0) <>0 
OR NVL(PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),239,3),3,0),0) <>0
OR NVL(PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),242,4),2,2),0) <>0
)
AND F_GET_TRANSCO('SC','DOMSC',PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),343,5),1)='*SCSO' --optique --determine la nature du dossier -- *SCSA pour auditif, *SCSD pour dentaire et *SCSOR pour orthodontie
AND PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),343,5) NOT IN ('LEN','LEJ','LER')--exclusion des lentilles
AND PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),165,1 )='P'--PEC
ORDER BY id_flux desc;

loc_numdoss  dossier_sante.num_dossier%TYPE;
loc_heure number;
loc_min   number;


BEGIN

  --Récupération des données 
  FOR rec_santeclair IN c_santeclair 
    LOOP

       SELECT to_char(sysdate, 'hh24') into loc_heure FROM DUAL;
       SELECT to_char(sysdate, 'mi') into loc_min FROM DUAL;
       IF loc_heure >=22 AND loc_min>30 THEN 
         EXIT;--dernier traitement à 17h30
       END IF;
       BEGIN


      SELECT dIStinct ds.num_dossier 
      INTO loc_numdoss
      FROM dossier_sante ds, sntr_dossier sd
      WHERE ds.ref_dossier =  rec_santeclair.ref_doss 
      AND sd.num_dossier = ds.num_dossier
      and ds.numporte = 16;

      EXCEPTION
        when no_data_found then 
            CONTINUE;
        when too_many_rows then 
            CONTINUE;
      END;


            INSERT INTO sinIStre_verre (numsin, numlig, username, oeil, sphere, cylindre, addition, axe)
                     (SELECT s.numsin,1,s.username,'D',rec_santeclair.sphere_OD, rec_santeclair.cylindre_OD , rec_santeclair.addition_OD, rec_santeclair.axe_OD
                               FROM sntr_dossier sd ,sinistre s 
                               WHERE sd.num_dossier =loc_numdoss
                               AND  sd.numsin_sntr = s.numsin
                               AND sd.numligne =1
                               AND NOT EXISTS (SELECT 1 
                                                FROM sinIStre_verre WHERE numsin =  s.numsin AND oeil = 'D'
                                                )
                        );-- Oeil Droit

            INSERT INTO sinIStre_verre (numsin, numlig, username, oeil, sphere, cylindre, addition, axe)
                  (SELECT s.numsin,2,s.username,'G', rec_santeclair.sphere_OG, rec_santeclair.cylindre_OG , rec_santeclair.addition_OG, rec_santeclair.axe_OG 
                  FROM sntr_dossier sd ,sinistre s 
                  WHERE sd.num_dossier =loc_numdoss
                  AND  sd.numsin_sntr = s.numsin
                  --AND numligne =2 
                  AND numligne=1   -- ABO+RKO M0006992 enregistrement de l'oeil gauche sur la première prestat si présence de deux verres(s.nbacte=2) sur la prestation
                  AND s.nbacte=2    
                  AND NOT EXISTS (SELECT 1 
                                  FROM sinIStre_verre WHERE numsin =  s.numsin AND oeil = 'G'
                                 )
                  );-- Oeil Gauche 
            IF SQL%ROWCOUNT =0 THEN  -- ABO+RKO M0006992 pas de présence de deux verres sur la première prestation , alors enregistrement de l'oeil gauche sur la 2ième prestation                       
                INSERT INTO sinistre_verre (numsin, numlig, username, oeil, sphere, cylindre, addition, axe)
                       (SELECT s.numsin,2,s.username,'G', rec_santeclair.sphere_OG, rec_santeclair.cylindre_OG , rec_santeclair.addition_OG, rec_santeclair.axe_OG
                                 FROM sntr_dossier sd ,sinistre s 
                                 WHERE sd.num_dossier =loc_numdoss
                                 AND  sd.numsin_sntr = s.numsin
                                 AND sd.numligne =2 
                                 AND NOT EXISTS (SELECT 1 
                                                  FROM sinistre_verre WHERE numsin =  s.numsin AND oeil = 'G'
                                                  )
                          );-- Oeil Gauche
            END IF;
        END LOOP;

EXCEPTION

 WHEN OTHERS THEN
    PK_TRACE.P_INS_journal_adm
              ( I_nom_traitement =>'P_INS_SNTR_VERRE_SC',
                I_session    =>SID,
                I_niv_msg    =>1, 
                I_msg_adm    =>'Echec de l''insertion dans sinistre_verre '||sqlerrm , 
                I_date       =>sysdate,
		        I_idligne	 =>1 );

END P_INS_SNTR_VERRE_SC;
/
