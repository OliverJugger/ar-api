CREATE PROCEDURE ARTHUS.P_INS_SINISTRE_VERRE 
IS

CURSOR c_santeclair
IS 
SELECT flux.id_flux,statut,id_type,TO_CHAR(dat_maj, 'DD/MM/YYYY HH24:MI:SS'),flux_aller
, PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),212,5),3,2) sphere_OD

, PK_WS_BACK_SANTECLAIR.F_FORMAT_NUMBER(PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),217,5),3,2) cylindre_OD--8 , 4
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
--AND flux.dat_maj > ADD_MONTHS (sysdate, -12)-- -24
AND TRUNC(flux.dat_maj) BETWEEN e2d('01/01/2019') and  e2d('31/12/2019')
AND PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),343,5)='VER'
--AND PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),175,16 ) = 'P201904183018SIA'
AND  PK_WS_BACK_SANTECLAIR.F_DECOUPE(SUBSTR(flux_aller,0,400),165,1 )='P'--PEC
ORDER BY id_flux desc;

CURSOR c_spsante IS
SELECT 
EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:referenceDossierOperateur','xmlns:mod="http://modele.ws.tpo.cga.com"') ref_doss 
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[1]/mod:ametropie/mod:oeil','xmlns:mod="http://modele.ws.tpo.cga.com"') oeilD
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[1]/mod:ametropie/mod:sphere','xmlns:mod="http://modele.ws.tpo.cga.com"') sphereD
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[1]/mod:ametropie/mod:cylindre','xmlns:mod="http://modele.ws.tpo.cga.com"') cylindreD
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[1]/mod:ametropie/mod:axeDuCylindre','xmlns:mod="http://modele.ws.tpo.cga.com"') axeDuCylindreD
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[1]/mod:ametropie/mod:addition_deb','xmlns:mod="http://modele.ws.tpo.cga.com"') additionD
--SELECT EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:verre/mod:indice','xmlns:mod="http://modele.ws.tpo.cga.com"') aminci 
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[1]/mod:equipementOptique/mod:verre/mod:teinte','xmlns:mod="http://modele.ws.tpo.cga.com"') teinteD
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[1]/mod:equipementOptique/mod:verre/mod:vISion','xmlns:mod="http://modele.ws.tpo.cga.com"') visionD
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[1]/mod:equipementOptique/mod:verre/mod:type','xmlns:mod="http://modele.ws.tpo.cga.com"') type_visionD
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[1]/mod:equipementOptique/mod:verre/mod:matiere','xmlns:mod="http://modele.ws.tpo.cga.com"') matiereD

, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[2]/mod:ametropie/mod:oeil','xmlns:mod="http://modele.ws.tpo.cga.com"') oeilG
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[2]/mod:ametropie/mod:sphere','xmlns:mod="http://modele.ws.tpo.cga.com"') sphereG
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[2]/mod:ametropie/mod:cylindre','xmlns:mod="http://modele.ws.tpo.cga.com"') cylindreG
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[2]/mod:ametropie/mod:axeDuCylindre','xmlns:mod="http://modele.ws.tpo.cga.com"') axeDuCylindreG
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[2]/mod:ametropie/mod:addition_deb','xmlns:mod="http://modele.ws.tpo.cga.com"') additionG
--SELECT EXTRACTVALUE(loc_xml,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique['||i||']/mod:equipementOptique/mod:verre/mod:indice','xmlns:mod="http://modele.ws.tpo.cga.com"') aminci 
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[2]/mod:equipementOptique/mod:verre/mod:teinte','xmlns:mod="http://modele.ws.tpo.cga.com"') teinteG
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[2]/mod:equipementOptique/mod:verre/mod:vISion','xmlns:mod="http://modele.ws.tpo.cga.com"') visionG
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[2]/mod:equipementOptique/mod:verre/mod:type','xmlns:mod="http://modele.ws.tpo.cga.com"') type_visionG
, EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[2]/mod:equipementOptique/mod:verre/mod:matiere','xmlns:mod="http://modele.ws.tpo.cga.com"') matiereG
FROM xml_04_06 x, flux f
WHERE 
--f.dat_maj > ADD_MONTHS (sysdate, -12)--SYSDATE - 200---- -24
TRUNC(f.dat_maj) BETWEEN e2d('01/01/2019') and  e2d('31/12/2019')
AND x.id_flux = f.id_flux
AND EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[1]/mod:identifiant','xmlns:mod="http://modele.ws.tpo.cga.com"') ='VERRE'
AND  EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:prestationOptique[2]/mod:identifiant','xmlns:mod="http://modele.ws.tpo.cga.com"') ='VERRE'
AND EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:type','xmlns:mod="http://modele.ws.tpo.cga.com"') ='2' --PEC 
--AND EXTRACTVALUE(doc_xml1,'mod:oiamCREQ/mod:partenariat/mod:propositionClient/mod:referenceDossierOperateur','xmlns:mod="http://modele.ws.tpo.cga.com"')='1484909'
;


CURSOR c_itelis IS 
SELECT 
EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/enTete/numeroDossierExperteo', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') ref_doss,
EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/dossier/domaine', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') domaine,
EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/detailActes/detailActe[1]/acteType', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') type_acte,
EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/detailActes/detailActe[1]/verre/correction/oeil', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') oeilD,
EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/detailActes/detailActe[1]/verre/correction/sphere', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') sphereD,
EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/detailActes/detailActe[1]/verre/correction/cylindre', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') cylindreD,
EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/detailActes/detailActe[1]/verre/correction/addition', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') additionD,
EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/detailActes/detailActe[1]/verre/correction/axe', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') axeD,
EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/detailActes/detailActe[2]/verre/correction/oeil', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') oeilG,
EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/detailActes/detailActe[2]/verre/correction/sphere', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') sphereG,
EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/detailActes/detailActe[2]/verre/correction/cylindre', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') cylindreG,
EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/detailActes/detailActe[2]/verre/correction/addition', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') additionG,
EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/detailActes/detailActe[2]/verre/correction/axe', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') axeG,
f.ID_FLUX
FROM xml_04_09_itelis x , FLUX f
WHERE x.id_flux = f.id_flux
--AND f.dat_maj > add_months(sysdate,-12)
AND TRUNC(f.dat_maj) BETWEEN e2d('01/01/2019') and  e2d('31/12/2019')
--AND  EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/enTete/numeroDossierExperteo', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') ='43117552'
AND EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/dossier/domaine', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') ='0' --optique
AND EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/detailActes/detailActe[1]/acteType', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') ='VERRE'
and EXTRACTVALUE(doc_xml1,'ns2:CalculRCRequest/dossier/type', 'xmlns:ns2="http://schemas.xmlsoap.org/wsdl/"  xmlns="http://ws.jalma.com/stdclient"') ='1'--PEC
;

loc_numdoss  dossier_sante.num_dossier%TYPE;
loc_heure number;
loc_min   number;


BEGIN

  --Récupération des données 
  FOR rec_santeclair IN c_santeclair 
    LOOP

       SELECT to_char(sysdate, 'hh24') into loc_heure FROM DUAL;
       SELECT to_char(sysdate, 'mi') into loc_min FROM DUAL;
       IF loc_heure >=17 AND loc_min>30 THEN 
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

   --Récupération des données SPSANTE

     FOR rec_spsante IN c_spsante
       LOOP
        SELECT to_char(sysdate, 'hh24') into loc_heure FROM DUAL;
        SELECT to_char(sysdate, 'mi') into loc_min FROM DUAL;
        IF loc_heure >=17 AND loc_min>30 THEN
        EXIT;--dernier traitement à 17h30
        END IF;

        BEGIN

          SELECT dIStinct ds.num_dossier 
          INTO loc_numdoss
          FROM dossier_sante ds, sntr_dossier sd
          WHERE ds.ref_dossier =  rec_spsante.ref_doss 
          AND sd.num_dossier = ds.num_dossier
          and ds.numporte = 15;

       EXCEPTION
          WHEN no_data_found THEN
             CONTINUE;
          WHEN too_many_rows THEN  
            CONTINUE;
        END;

        INSERT INTO sinistre_verre (numsin, numlig, username, oeil, sphere, cylindre, addition, axe)
                     (SELECT s.numsin,1,s.username,'D',rec_spsante.sphereD, rec_spsante.cylindreD , rec_spsante.additionD, rec_spsante.axeDuCylindreD
                               FROM sntr_dossier sd ,sinistre s 
                               WHERE sd.num_dossier =loc_numdoss
                               AND  sd.numsin_sntr = s.numsin
                               AND sd.numligne =1
                               AND NOT EXISTS (SELECT 1 
                                                FROM sinistre_verre WHERE numsin =  s.numsin AND oeil = 'D'
                                                )
                        );-- Oeil Droit


        INSERT INTO sinistre_verre (numsin, numlig, username, oeil, sphere, cylindre, addition, axe)
                     (SELECT s.numsin,2,s.username,'G', rec_spsante.sphereG, rec_spsante.cylindreG , rec_spsante.additionG, rec_spsante.axeDuCylindreG
                               FROM sntr_dossier sd ,sinistre s 
                               WHERE sd.num_dossier =loc_numdoss
                               AND  sd.numsin_sntr = s.numsin
                               AND sd.numligne =1 --2  ABO+RKO M0006992 enregistrement de l'oeil gauche sur la première prestat si présence de deux verres(s.nbacte=2) sur la prestation
                               AND s.nbacte = 2                         
                               AND NOT EXISTS (SELECT 1 
                                                FROM sinistre_verre WHERE numsin =  s.numsin AND oeil = 'G'
                                                )
                        );-- Oeil Gauche
        IF SQL%ROWCOUNT =0 THEN  -- ABO+RKO M0006992 pas de présence de deux verres sur la première prestation , alors enregistrement de l'oeil gauche sur la 2ième prestation                       
        INSERT INTO sinistre_verre (numsin, numlig, username, oeil, sphere, cylindre, addition, axe)
                     (SELECT s.numsin,2,s.username,'G', rec_spsante.sphereG, rec_spsante.cylindreG , rec_spsante.additionG, rec_spsante.axeDuCylindreG
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

    --Récuperation des données ITELIS  

     FOR rec_itelis IN c_itelis 
    LOOP
      SELECT to_char(sysdate, 'hh24') into loc_heure FROM DUAL;
      SELECT to_char(sysdate, 'mi') into loc_min FROM DUAL;
      IF loc_heure >=17 AND loc_min>30 THEN
       EXIT;--dernier traitement à 17h30
      END IF;

      BEGIN
        SELECT dIStinct ds.num_dossier 
        INTO loc_numdoss
        FROM dossier_sante ds, sntr_dossier sd
        WHERE ds.ref_dossier =  rec_itelis.ref_doss 
        AND sd.num_dossier = ds.num_dossier
        and ds.numporte = 22;

      EXCEPTION
        when no_data_found then 
            CONTINUE;
        when too_many_rows then  
            CONTINUE;
      END;

            INSERT INTO sinistre_verre (numsin, numlig, username, oeil, sphere, cylindre, addition, axe)
                     (SELECT s.numsin,1,s.username,'D',rec_itelis.sphereD, rec_itelis.cylindreD , rec_itelis.additionD, rec_itelis.axeD
                               FROM sntr_dossier sd ,sinistre s 
                               WHERE sd.num_dossier =loc_numdoss
                               AND  sd.numsin_sntr = s.numsin
                               AND sd.numligne =1
                               AND NOT EXISTS (SELECT 1 
                                                FROM sinIStre_verre WHERE numsin =  s.numsin AND oeil = 'D'
                                                )
                        );-- Oeil Droit

            INSERT INTO sinistre_verre (numsin, numlig, username, oeil, sphere, cylindre, addition, axe)
                     (SELECT s.numsin,2,s.username,'G',rec_itelis.sphereG , rec_itelis.cylindreG , rec_itelis.additionG, rec_itelis.axeG
                               FROM sntr_dossier sd ,sinistre s 
                               WHERE sd.num_dossier =loc_numdoss
                               AND  sd.numsin_sntr = s.numsin
                               AND sd.numligne =1 --2  ABO+RKO M0006992 enregistrement de l'oeil gauche sur la première prestat si présence de deux verres(s.nbacte=2) sur la prestation
                               AND s.nbacte=2  
                               AND NOT EXISTS (SELECT 1 
                                                FROM sinIStre_verre WHERE numsin =  s.numsin AND oeil = 'G'
                                                )
                        );-- Oeil Gauche
            IF SQL%ROWCOUNT =0 THEN  -- ABO+RKO M0006992 -- pas de présence de deux verres sur la première prestation , alors enregistrement de l'oeil gauche sur la 2ième prestation                     
                INSERT INTO sinistre_verre (numsin, numlig, username, oeil, sphere, cylindre, addition, axe)
                       (SELECT s.numsin,2,s.username,'G', rec_itelis.sphereG , rec_itelis.cylindreG , rec_itelis.additionG, rec_itelis.axeG
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
              ( I_nom_traitement =>'P_INS_SINISTRE_VERRE',
                I_session    =>SID,
                I_niv_msg    =>1, 
                I_msg_adm    =>'Echec de l''insertion dans sinistre_verre '||sqlerrm , 
                I_date       =>sysdate,
		        I_idligne	 =>1 );

END P_INS_SINISTRE_VERRE;
/
