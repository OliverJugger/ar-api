CREATE FUNCTION ARTHUS.F_IS_DEROG( p_numdossier IN DOSSIER_SANTE.NUM_DOSSIER%TYPE
                  , p_numIndiv     IN NUMBER
                  , p_datSin       IN DATE
                  , p_sid          IN NUMBER
                  ,P_NUMREMISE     IN NUMBER
                  ,P_NUMPORTE      IN NUMBER)  RETURN NUMBER IS
  l_verre_droit   SINISTRE_VERRE%ROWTYPE;
  l_verre_gauche  SINISTRE_VERRE%ROWTYPE;

  loc_dero PK_FUNCT.DerogOptique_T;
  --2 cas possibles devis ou PEC - les info détaillées des équipements peuvent être dans les 2
  --donc impact sur trav_saisie ou sinistre_verre
 CURSOR C_verre IS
  --verre dans la contexte devis dossier sante
  SELECT v1.OEIL ,v1.SPHERE ,v1.CYLINDRE , v1.ADDITION ,v1.AXE
  from trav_saisie v1 --,travsn s1
  WHERE 1=1--s1.username = v1.username
  --AND s1.sid = v1.sid
 -- AND s1.numlig = v1.numlig
  AND v1.sid = p_sid
  AND v1.username = f_numutil
  --AND s1.numindiv = p_numIndiv
  --AND s1.datsin =  p_datSin
  AND v1.oeil IS NOT NULL
  UNION
  --verre dans la contexte PEC dossier sante
  SELECT v1.OEIL ,v1.SPHERE ,v1.CYLINDRE , v1.ADDITION ,v1.AXE
  FROM SINISTRE_VERRE v1 ,  SINISTRE_SANTE ss , SNTR_DOSSIER sd
  WHERE sd.num_dossier =  p_numdossier
  and sd.num_dossier=ss.num_dossier
  AND sd.numligne=ss.numligne
  AND ss.numindiv = p_numIndiv
  AND ss.datsin =  p_datSin
  AND v1.numsin = sd.numsin_sntr
  --autre filtres TODO
  /*UNION
  SELECT v1.OEIL OEILD,v1.SPHERE SPHERED,v1.CYLINDRE CYLINDRED, v1.ADDITION ADDITIOND,v1.AXE AXED
         v2.OEIL OEILG,v2.SPHERE SPHEREG,v2.CYLINDRE CYLINDREG, v2.ADDITION ADDITIONG,v2.AXE AXEG
  FROM SINISTRE_PORTE v1 , SINISTRE_PORTE v2
  AND v1.OEIL ='D'
  AND v2.OEIL='G'
  AND v1.numremise = v2.numremise
  AND v.numporte = v2.numporte
  AND v1.numindiv = v2.numindiv
  AND v1.numindiv = p_numIndiv
  AND v1.numremise =p_numremise
  AND v.numporte = p_numporte
  AND v1.datsin = v2.datsin
  AND v1.datsin =  p_datSin */;

  CURSOR c_SNTR IS
  SELECT codfrais, numligne
  from sinistre_sante
  WHERE num_dossier = p_numdossier
  AND SITUATION = 2;

BEGIN

  --création des objets sinistre_verre
  FOR r_verre IN c_verre LOOP
    IF R_verre.OEIL ='D' THEN
      l_verre_droit.OEIL := R_verre.OEIL;
      l_verre_droit.SPHERE := R_verre.SPHERE;
      l_verre_droit.CYLINDRE := R_verre.CYLINDRE;
      l_verre_droit.ADDITION := R_verre.ADDITION;
      l_verre_droit.axe := r_verre.axe;

    ELSIF R_verre.OEIL ='G' THEN
      l_verre_gauche.OEIL := R_verre.OEIL;
      l_verre_gauche.SPHERE := R_verre.SPHERE;
      l_verre_gauche.CYLINDRE := R_verre.CYLINDRE;
      l_verre_gauche.ADDITION := R_verre.ADDITION;
      l_verre_gauche.axe := r_verre.axe;
    END IF;
  END LOOP;
  --si on a les 2 verres
  --les contrôles sur le domaine optique du dossier est réalisé en amont - idem pour les montants
  --IF  l_verre_gauche.OEIL IS NOT NULL AND  l_verre_droit.OEIL IS NOT NULL THEN
    --on récupère les déro pour les 3 actes
    FOR R_SNTR IN c_SNTR LOOP

      loc_dero:= PK_FUNCT.F_DerogOptique(   p_numIndiv     => p_numIndiv
                      , p_datSin       =>  p_datSin
                      , p_codFrais     => R_SNTR.codfrais
                      , p_verre_droit  => l_verre_droit
                      , p_verre_gauche =>l_verre_gauche
                    );
  --dbms_output.put_line(R_SNTR.codfrais||loc_dero.derogoptique);
      IF  TRIM(loc_dero.derogoptique)='OUI' THEN
        RETURN 1;
      END IF;

    END LOOP;
 -- END IF;


  RETURN 0;


EXCEPTION
  WHEN OTHERS THEN
  --DBMS_OUTPUT.PUT_LINE('KO '||SQLERRM);
  RETURN 0;
END F_IS_DEROG;
