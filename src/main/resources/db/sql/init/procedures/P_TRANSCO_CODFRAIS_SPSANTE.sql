CREATE PROCEDURE ARTHUS.P_TRANSCO_CODFRAIS_SPSANTE(
        P_numfor              IN gar_cntrt.numfor%TYPE,
        P_nature_ntfrs_detail IN NUMBER,
        P_ntfrs_optique       IN NTFRS_OPTIQUE_T,
        P_type_monture        IN TYPE_MONTURE_T,
        P_ntfrs_vision        IN NTFRS_VISION_T,
        P_ntfrs_typ_vision    IN NTFRS_TYP_VISION_T,
        P_ntfrs_matiere       IN NTFRS_MATIERE_T,
        P_renew_lentille      IN RENEW_LENTILLE_T,
        P_MtRO                IN NUMBER,
        O_codfrais           OUT VARCHAR2,
        O_acte_err_code      OUT VARCHAR2)
IS




  CURSOR c_famille_acte
      IS
  SELECT d.codfrais
    FROM DEFRUB d
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor;

  rec_famille c_famille_acte%ROWTYPE;

  CURSOR c_acte
      IS
  SELECT DISTINCT c.codfrais
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
      -- , NTFRS a
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND c.numfor=d.numfor
     --AND a.codfrais = c.codfrais
     --AND d.codfrais =a.rubrique
     AND d.codfrais = c.rubrique
     AND n.codfrais=c.codfrais
 ORDER BY c.codfrais ;

  rec_acte c_acte%ROWTYPE;

  CURSOR c_optique_actev
      IS
  SELECT n.codfrais
       , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       --, NTFRS a
       , NTFRS_OPTIQUE o
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     --AND a.codfrais = c.codfrais
     --AND d.codfrais =a.rubrique
     AND d.codfrais = c.rubrique -- a.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND n.verre=1
     AND o.codfrais (+) =c.codfrais
     AND ((NVL(p_ntfrs_optique.sphere_deb  ,o.spheren_deb)  BETWEEN NVL(o.spheren_deb ,p_ntfrs_optique.sphere_deb)   AND NVL(o.spheren_fin ,p_ntfrs_optique.sphere_deb)   OR (o.spheren_deb  IS NULL AND o.spheren_fin  IS NULL))
       OR (NVL(p_ntfrs_optique.sphere_deb  ,o.spherep_deb)  BETWEEN NVL(o.spherep_deb ,p_ntfrs_optique.sphere_deb)   AND NVL(o.spherep_fin ,p_ntfrs_optique.sphere_deb)   OR (o.spherep_deb  IS NULL AND o.spherep_fin  IS NULL)))
     AND  (NVL(P_ntfrs_optique.cylindre_deb,o.cylindre_deb) BETWEEN NVL(o.cylindre_deb,P_ntfrs_optique.cylindre_deb) AND NVL(o.cylindre_fin,P_ntfrs_optique.cylindre_deb) OR (o.cylindre_deb IS NULL AND o.cylindre_fin IS NULL))
     AND  (NVL(P_ntfrs_optique.addition_deb,o.addition_deb) BETWEEN NVL(o.addition_deb,P_ntfrs_optique.addition_deb) AND NVL(o.addition_fin,P_ntfrs_optique.addition_deb) OR (o.addition_deb IS NULL AND o.addition_fin IS NULL))
     AND  (NVL(P_ntfrs_optique.aminci_deb  ,o.aminci_deb)   BETWEEN NVL(o.aminci_deb  ,P_ntfrs_optique.aminci_deb)   AND NVL(o.aminci_fin  ,P_ntfrs_optique.aminci_deb)   OR (o.aminci_deb   IS NULL AND o.aminci_fin   IS NULL))
     AND (NVL(o.teinte,-1) = NVL(P_ntfrs_optique.teinte,-1) OR o.teinte IS NULL)
     AND (NVL(o.famille,0)= NVL(P_ntfrs_optique.famille,0)  OR o.famille IS NULL)
  ORDER BY d.codfrais ;

  rec_optique_actev c_optique_actev%ROWTYPE;

  CURSOR c_optique_detailv
      IS
  SELECT n.codfrais
       , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
       --, NTFRS a
       , NTFRS_OPTIQUE o
       , NTFRS_VISION v
       , NTFRS_TYP_VISION t
       , NTFRS_MATIERE m
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     --AND a.codfrais = c.codfrais
     --AND d.codfrais =a.rubrique
     AND d.codfrais = c.rubrique -- a.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND n.verre=1
     AND o.codfrais (+) =c.codfrais
     AND ((NVL(p_ntfrs_optique.sphere_deb  ,o.spheren_deb)  BETWEEN NVL(o.spheren_deb ,p_ntfrs_optique.sphere_deb)   AND NVL(o.spheren_fin ,p_ntfrs_optique.sphere_deb)   OR (o.spheren_deb  IS NULL AND o.spheren_fin  IS NULL))
       OR (NVL(p_ntfrs_optique.sphere_deb  ,o.spherep_deb)  BETWEEN NVL(o.spherep_deb ,p_ntfrs_optique.sphere_deb)   AND NVL(o.spherep_fin ,p_ntfrs_optique.sphere_deb)   OR (o.spherep_deb  IS NULL AND o.spherep_fin  IS NULL)))
     AND  (NVL(P_ntfrs_optique.cylindre_deb,o.cylindre_deb) BETWEEN NVL(o.cylindre_deb,P_ntfrs_optique.cylindre_deb) AND NVL(o.cylindre_fin,P_ntfrs_optique.cylindre_deb) OR (o.cylindre_deb IS NULL AND o.cylindre_fin IS NULL))
     AND  (NVL(P_ntfrs_optique.addition_deb,o.addition_deb) BETWEEN NVL(o.addition_deb,P_ntfrs_optique.addition_deb) AND NVL(o.addition_fin,P_ntfrs_optique.addition_deb) OR (o.addition_deb IS NULL AND o.addition_fin IS NULL))
     AND  (NVL(P_ntfrs_optique.aminci_deb  ,o.aminci_deb)   BETWEEN NVL(o.aminci_deb  ,P_ntfrs_optique.aminci_deb)   AND NVL(o.aminci_fin  ,P_ntfrs_optique.aminci_deb)   OR (o.aminci_deb   IS NULL AND o.aminci_fin   IS NULL))
     AND (NVL(o.teinte,-1) = NVL(P_ntfrs_optique.teinte,-1) OR o.teinte IS NULL)
     AND (NVL(o.famille,-1)= NVL(p_ntfrs_optique.famille,-1)OR o.famille IS NULL)
     AND o.codfrais = v.codfrais (+)
     AND o.nature = v.nature (+)
     AND NVL(v.vision,p_ntfrs_vision.vision) = p_ntfrs_vision.vision
     AND o.codfrais = t.codfrais (+)
     AND NVL(t.type_vision,p_ntfrs_typ_vision.type_vision) = p_ntfrs_typ_vision.type_vision
     AND NVL(m.matiere,p_ntfrs_matiere.matiere) = p_ntfrs_matiere.matiere
     AND o.nature = t.nature (+)
     AND o.codfrais = m.codfrais (+)
     AND o.nature = m.nature (+)
  ORDER BY o.codfrais, n.secu;

  rec_optique_detailv c_optique_detailv%ROWTYPE;

  CURSOR c_optique_actel
      IS
  SELECT n.codfrais
       , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
      -- , NTFRS a
       , NTFRS_OPTIQUE o
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     --AND a.codfrais = c.codfrais
     --AND d.codfrais =a.rubrique
     AND d.codfrais = c.rubrique -- a.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND n.lentille=1
     AND o.codfrais (+) =c.codfrais
     AND ((NVL(p_ntfrs_optique.sphere_deb  ,o.spheren_deb)  BETWEEN NVL(o.spheren_deb ,p_ntfrs_optique.sphere_deb)   AND NVL(o.spheren_fin ,p_ntfrs_optique.sphere_deb)   OR (o.spheren_deb  IS NULL AND o.spheren_fin  IS NULL))
       OR (NVL(p_ntfrs_optique.sphere_deb  ,o.spherep_deb)  BETWEEN NVL(o.spherep_deb ,p_ntfrs_optique.sphere_deb)   AND NVL(o.spherep_fin ,p_ntfrs_optique.sphere_deb)   OR (o.spherep_deb  IS NULL AND o.spherep_fin  IS NULL)))
     AND  (NVL(P_ntfrs_optique.cylindre_deb,o.cylindre_deb) BETWEEN NVL(o.cylindre_deb,P_ntfrs_optique.cylindre_deb) AND NVL(o.cylindre_fin,P_ntfrs_optique.cylindre_deb) OR (o.cylindre_deb IS NULL AND o.cylindre_fin IS NULL))
     AND  (NVL(P_ntfrs_optique.addition_deb,o.addition_deb) BETWEEN NVL(o.addition_deb,P_ntfrs_optique.addition_deb) AND NVL(o.addition_fin,P_ntfrs_optique.addition_deb) OR (o.addition_deb IS NULL AND o.addition_fin IS NULL))
     AND  (NVL(P_ntfrs_optique.aminci_deb  ,o.aminci_deb)   BETWEEN NVL(o.aminci_deb  ,P_ntfrs_optique.aminci_deb)   AND NVL(o.aminci_fin  ,P_ntfrs_optique.aminci_deb)   OR (o.aminci_deb   IS NULL AND o.aminci_fin   IS NULL))
     AND (NVL(o.teinte,-1) = NVL(P_ntfrs_optique.teinte,-1) OR o.teinte IS NULL)
     AND (NVL(o.famille,P_ntfrs_optique.famille)= P_ntfrs_optique.famille OR o.famille IS NULL)
  ORDER BY d.codfrais ;

  rec_optique_actel c_optique_actel%ROWTYPE;

  CURSOR c_optique_detaill
      IS
  SELECT n.codfrais
       , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
     --, NTFRS a
       , NTFRS_OPTIQUE o
       , NTFRS_VISION v
       , NTFRS_TYP_VISION t
       , NTFRS_MATIERE m
       , RENEW_LENTILLE r
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     --AND a.codfrais = c.codfrais
     --AND d.codfrais =a.rubrique
     AND d.codfrais = c.rubrique -- a.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND n.codfrais=c.codfrais
     AND n.lentille=1
     AND o.codfrais (+) =c.codfrais
     AND ((NVL(p_ntfrs_optique.sphere_deb  ,o.spheren_deb)  BETWEEN NVL(o.spheren_deb ,p_ntfrs_optique.sphere_deb)   AND NVL(o.spheren_fin ,p_ntfrs_optique.sphere_deb)   OR (o.spheren_deb  IS NULL AND o.spheren_fin  IS NULL))
       OR (NVL(p_ntfrs_optique.sphere_deb  ,o.spherep_deb)  BETWEEN NVL(o.spherep_deb ,p_ntfrs_optique.sphere_deb)   AND NVL(o.spherep_fin ,p_ntfrs_optique.sphere_deb)   OR (o.spherep_deb  IS NULL AND o.spherep_fin  IS NULL)))
     AND  (NVL(P_ntfrs_optique.cylindre_deb,o.cylindre_deb) BETWEEN NVL(o.cylindre_deb,P_ntfrs_optique.cylindre_deb) AND NVL(o.cylindre_fin,P_ntfrs_optique.cylindre_deb) OR (o.cylindre_deb IS NULL AND o.cylindre_fin IS NULL))
     AND  (NVL(P_ntfrs_optique.addition_deb,o.addition_deb) BETWEEN NVL(o.addition_deb,P_ntfrs_optique.addition_deb) AND NVL(o.addition_fin,P_ntfrs_optique.addition_deb) OR (o.addition_deb IS NULL AND o.addition_fin IS NULL))
     AND  (NVL(P_ntfrs_optique.aminci_deb  ,o.aminci_deb)   BETWEEN NVL(o.aminci_deb  ,P_ntfrs_optique.aminci_deb)   AND NVL(o.aminci_fin  ,P_ntfrs_optique.aminci_deb)   OR (o.aminci_deb   IS NULL AND o.aminci_fin   IS NULL))
     AND (NVL(o.teinte,-1) = NVL(P_ntfrs_optique.teinte,-1) OR o.teinte IS NULL)
     AND (NVL(NVL(o.famille,p_ntfrs_optique.famille),-1) = NVL(p_ntfrs_optique.famille,-1) OR o.famille IS NULL)
     AND o.codfrais = v.codfrais (+)
     AND o.nature = v.nature (+)
     AND NVL(p_ntfrs_vision.vision,-1) = NVL(v.vision,NVL(p_ntfrs_vision.vision,-1))
     AND o.codfrais = t.codfrais (+)
     AND NVL(p_ntfrs_typ_vision.type_vision,-1) = NVL(t.type_vision,NVL(p_ntfrs_typ_vision.type_vision,-1))
     AND NVL(p_ntfrs_matiere.matiere,-1) = NVL(m.matiere,NVL(p_ntfrs_matiere.matiere,-1))
     AND o.nature = t.nature (+)
     AND o.codfrais = m.codfrais (+)
     AND o.nature = m.nature (+)
     AND n.codfrais = r.codfrais (+)
     AND NVL(P_renew_lentille.code,-1) = NVL(r.code,NVL(P_renew_lentille.code,-1))
  ORDER BY o.codfrais, n.secu;

  rec_optique_detaill c_optique_detaill%ROWTYPE;

  CURSOR c_monture_acte
      IS
  SELECT n.codfrais
       , n.secu
    FROM DEFRUB d
       , CALCUL c
       , NTFRS_DETAIL n
      -- , NTFRS a
       , TYPE_MONTURE t
       , NTFRS_MATIERE m
   WHERE d.codfrais like 'H%'  -- On traite uniquement de l optique pour SPSanté
     AND d.numfor=P_numfor
     AND c.numfor=d.numfor
     --AND a.codfrais = c.codfrais
     --AND d.codfrais =a.rubrique
     AND d.codfrais = c.rubrique -- a.rubrique
     AND SYSDATE BETWEEN c.datapli AND NVL(c.datper, SYSDATE)
     AND n.monture=1
     AND n.codfrais=c.codfrais
     AND t.codfrais (+)=c.codfrais
     AND NVL(p_type_monture.type_monture,-1) = NVL(t.type_monture,NVL(p_type_monture.type_monture,-1))
     AND m.codfrais (+)=c.codfrais
     AND NVL(p_ntfrs_matiere.matiere,-1) = NVL(m.matiere,NVL(p_ntfrs_matiere.matiere,-1))
  ORDER BY d.codfrais ;

  rec_monture_acte c_monture_acte%ROWTYPE;

BEGIN
  
  dbms_Output.Put_Line(' F_TRANSCO_CODFRAIS_SPSANTE:'||to_char(P_MtRO));
  dbms_Output.Put_Line(' P_MtRO°:'||P_MtRO);
  dbms_Output.Put_Line(' p_ntfrs_optique.sphere_deb°:'||p_ntfrs_optique.sphere_deb);
  dbms_Output.Put_Line(' p_ntfrs_optique.cylindre_deb°:'||p_ntfrs_optique.cylindre_deb);
  dbms_Output.Put_Line(' p_ntfrs_optique.addition_deb°:'||p_ntfrs_optique.addition_deb);
  dbms_Output.Put_Line(' p_ntfrs_optique.aminci_deb°:'||p_ntfrs_optique.aminci_deb);
  dbms_Output.Put_Line(' p_ntfrs_optique.teinte°:'||p_ntfrs_optique.teinte);
  dbms_Output.Put_Line(' p_ntfrs_optique.famille°:'||p_ntfrs_optique.famille);
  dbms_Output.Put_Line(' p_ntfrs_vision.vision°:'||p_ntfrs_vision.vision);
  dbms_Output.Put_Line(' p_ntfrs_typ_vision.type_vision°:'||p_ntfrs_typ_vision.type_vision);
  dbms_Output.Put_Line(' p_ntfrs_matiere.matiere°:'||p_ntfrs_matiere.matiere);
  dbms_Output.Put_Line(' P_renew_lentille.code°:'||P_renew_lentille.code);
  dbms_Output.Put_Line(' p_ntfrs_matiere.matiere°:'||p_ntfrs_matiere.matiere);
  dbms_Output.Put_Line(' p_type_monture.type_monture°:'||p_type_monture.type_monture);
  
  O_acte_err_code:='00';
  -- Verification de la validité de la famille d acte optique sur la garantie
  FOR rec_famille IN c_famille_acte LOOP
    -- Recherche de la totalité des actes de la famille optique de la garantie dont il existe une possible trancodification
    FOR rec_acte IN c_acte LOOP
   --   dbms_Output.Put_Line('codfrais :' || rec_acte.codfrais ); 
   --   dbms_Output.Put_Line('P_nature_ntfrs_detail :' || P_nature_ntfrs_detail );   
      -- On traite la prestation optique VERRE
      IF P_nature_ntfrs_detail =1 THEN
        -- Recherche de l'acte ARTHUS transcodé
        FOR rec_optique_actev IN c_optique_actev LOOP
        --  dbms_Output.Put_Line('MUR1') ; 
          -- Recherche du détails de la trancodification de l acte optique
          FOR rec_optique_detailv IN c_optique_detailv LOOP
         --   dbms_Output.Put_Line('MUR2') ;         
         --   dbms_Output.Put_Line('rec_optique_detailv.secu :' || rec_optique_detailv.secu );
         --   dbms_Output.Put_Line('P_MtRO :' || P_MtRO );
        --    dbms_Output.Put_Line('rec_optique_detailv.codfrais :' || rec_optique_detailv.codfrais );
            IF (rec_optique_detailv.secu ='O' AND P_MtRO>0) OR (rec_optique_detailv.secu ='N' AND P_MtRO=0) OR (rec_optique_detailv.secu IS NULL) THEN
              --PK_SPSANTE.P_INS_journal(2,' dans if secu rec_optique_detailv°:'||rec_optique_detailv.codfrais);
              --loc_codfrais:=rec_optique_detailv.codfrais;
              O_codfrais:=rec_optique_detailv.codfrais;
            --  O_codfrais(rec_optique_detailv.codfrais):=O_codfrais.COUNT;
                  END IF;
            END LOOP;
         END LOOP;
      -- On traite la prestation optique LENTILLE
      ELSIF P_nature_ntfrs_detail =3 THEN
        -- Recherche de l'acte ARTHUS transcodé
        FOR rec_optique_actel IN c_optique_actel LOOP
          -- Recherche du détails de la trancodification de l acte optique
          FOR rec_optique_detaill IN c_optique_detaill LOOP
            IF (rec_optique_detaill.secu ='O' AND P_MtRO>0) OR (rec_optique_detaill.secu ='N' AND P_MtRO=0) OR (rec_optique_detaill.secu IS NULL) THEN
              --PK_SPSANTE.P_INS_journal(2,' dans if°:'||rec_optique_detaill.codfrais);
              --loc_codfrais:=rec_optique_detaill.codfrais;
              o_acte_err_code:='00';
           --   O_codfrais(rec_optique_detaill.codfrais):=O_codfrais.COUNT;
               O_codfrais:=rec_optique_detaill.codfrais;
            END IF;
          END LOOP;
        END LOOP;
      -- On traite la prestation optique MONTURE
      ELSIF P_nature_ntfrs_detail = 2 THEN
        FOR rec_monture_acte IN c_monture_acte LOOP
          IF (rec_monture_acte.secu ='O' AND P_MtRO>0) OR (rec_monture_acte.secu ='N' AND P_MtRO=0) OR (rec_monture_acte.secu IS NULL) THEN
         --   O_codfrais(rec_monture_acte.codfrais):=O_codfrais.COUNT;
                       O_codfrais:=rec_monture_acte.codfrais;
            --PK_SPSANTE.P_INS_journal(2,' rec_monture_acte.codfrais°:'||rec_monture_acte.codfrais);
            --PK_SPSANTE.P_INS_journal(2,' O_codfrais.COUNT°:'||O_codfrais.COUNT);
          END IF;
        END LOOP;
      END IF;
    END LOOP;
  END LOOP;

EXCEPTION

  WHEN OTHERS THEN
    o_acte_err_code:='99'; -- Erreur indeterminée
END P_TRANSCO_CODFRAIS_SPSANTE;
/
