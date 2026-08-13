CREATE procedure ARTHUS.pec_sp_except is
   
   
   CURSOR C_pec is
   select distinct f.refcie,sp.numremise,sp.Idfactpe,sp.numsin, tpe.numfact,tpe.datfact,ds.num_dossier,sp.codfrais_porte,sp.mtprest
  from sinistre_porte sp , suivi_fact_tpe tpe  , sinistre_porte f
  left outer join dossier_sante ds on (ds.ref_dossier = f.refcie and Ds.Type_Doss=4)
  where sp.numremise =20964 and sp.etat not in (1,4)
  and Sp.Idfactpe = tpe.Idfactpe
  and Tpe.Codevefac=40
  and tpe.numremise_import = f.numremise
  and f.numporte = 2
  and F.Idfactpe = tpe.Idfactpe
  and f.refcie is not null
  ;
   
 
 CURSOR C_sinistre_sante(p_num_dossier varchar2,
                        p_montant number,
                        p_nature varchar2,
                        p_codfrais Varchar2) IS

  SELECT s.numligne,s.numsin_sntrprt,s.mtprest_reel,s.codfrais
  FROM  sinistre_sante  s LEFT OUTER JOIN ntfrs_detail d ON ( s.codfrais = d.codfrais)
  WHERE num_dossier = p_num_dossier
  AND (s.codfrais = d.codfrais
  AND ((d.lentille = 1 AND p_nature='001')
    OR (d.monture = 1 AND p_nature='010')
    OR (d.verre = 1 AND p_nature='100'))
   OR (s.codfrais = p_codfrais AND p_nature='000'))
  AND NVL(s.mtprest_reel,0)=NVL(p_montant,0)
  AND s.numsin_sntrprt IS NULL
 
  order by numligne;


CURSOR C_dossier_sante (p_refcie VARCHAR2) IS
  SELECT num_dossier, num_dossier_pec, ref_dossier,numindiv,numbene,numassu,numporte,nat_doss,num_dossier_porte,numremise_sntrprt
  FROM dossier_sante
  WHERE ref_dossier = trim(p_refcie)
  AND type_doss = 4;
  
CURSOR C_sntr_dossier (p_dossier NUMBER,p_numligne NUMBER) IS
  SELECT numsin_sntr
  FROM sntr_dossier
  WHERE num_dossier = p_dossier
  AND numligne = p_numligne;
  
  loc_dossier_resil dossier_sante.num_dossier%TYPE:=NULL;
loc_ano_resil     NUMBER:=0;
w_numano   number(6);

loc_dossier NUMBER(15);
loc_dossier_PEC     DOSSIER_SANTE.NUM_DOSSIER%TYPE:=NULL;
loc_dossier_creat   DOSSIER_SANTE.CREATION%TYPE:=NULL;
loc_nature varchar2(3);
loc_codfrais porte_natfrais.codfrais%TYPE;
  loc_numfact suivi_fact_tpe.numfact%TYPE;
loc_datfact suivi_fact_tpe.datfact%TYPE;
exc_dossier_inconnu EXCEPTION;
exc_dossier_liquide EXCEPTION;
exc_dossier_ferme   EXCEPTION;
exc_dossier_perime  EXCEPTION;
exc_montant_diff    EXCEPTION;
exc_acte_inconnu    EXCEPTION;
exc_rej_technique   EXCEPTION;
Rec_C_sinistre_sante C_sinistre_sante%ROWTYPE;
REc_C_dossier_sante C_dossier_sante%ROWTYPE;
Rec_C_sntr_dossier   C_sntr_dossier%ROWTYPE;
R_pec C_pec%ROWTYPE;
 
 begin
  for R_pec IN C_pec LOOP
    BEGIN   
    w_numano :=0;
    dbms_output.put_line(':new.refcie :'||R_pec.refcie);
    --contrôle de l'existence du dossier de liq
    BEGIN
        SELECT num_dossier
        INTO loc_dossier
        FROM dossier_sante
        WHERE type_doss=1
        AND num_dossier_pec = R_pec.num_dossier;
      EXCEPTION
        WHEN no_data_found THEN loc_dossier:=0;
      END;
    
    IF R_pec.num_dossier is NULL THEN
     RAISE exc_dossier_inconnu;
    END IF;
    IF loc_dossier = 0 THEN
      loc_dossier:= PK_CALCUL_DOSSIER.F_LIQ_DOSSIER(R_pec.refcie,R_pec.numremise,R_pec.numfact,R_pec.datfact);
      
      IF loc_dossier = 0 THEN
       RAISE exc_dossier_inconnu;
      ELSIF loc_dossier =-1 THEN
        RAISE exc_rej_technique;
      END IF;
    END IF;

      --transcodification porte 2 pour lier les sinistres au sinistre_porte
    
    dbms_output.put_line(':new.codfrais_porte :'||R_pec.codfrais_porte);

      BEGIN
        SELECT NVL(d.verre,0) || NVL(d.monture,0) || NVL(d.lentille,0),p.codfrais
        INTO loc_nature, loc_codfrais
        FROM  porte_natfrais p  left outer join  ntfrs_detail d ON (d.codfrais = p.codfrais )
        WHERE p.numporte = 2
        AND p.regime = 1
        AND p.codfrais_porte = R_pec.codfrais_porte;
        dbms_output.put_line('loc_nature :'||loc_nature);
        dbms_output.put_line('loc_codfrais :'||loc_codfrais);

      EXCEPTION
        WHEN no_data_found THEN
          RAISE exc_acte_inconnu;
        WHEN too_many_rows THEN
          RAISE exc_acte_inconnu;
      END;
    --  :NEW.codfrais:=loc_codfrais; --acte transco TPE
      
      OPEN C_sinistre_sante(loc_dossier,R_pec.mtprest,loc_nature,loc_codfrais) ;
      FETCH C_sinistre_sante INTO Rec_C_sinistre_sante;

      IF C_sinistre_sante%NOTFOUND THEN

        IF C_sinistre_sante%ISOPEN THEN CLOSE  C_sinistre_sante;
        END IF;

        RAISE exc_montant_diff;--montant du sinistre différent
      END IF;

      --on a trouvé au moins 1 acte de mˆme nature et montant dans le dossier de PEC
      update sinistre_porte 
      set etat  =1,  mtprestarmedi= Rec_C_sinistre_sante.mtprest_reel, codfrais=Rec_C_sinistre_sante.codfrais
      where numremise = R_pec.numremise and numsin =R_pec.numsin;
      
      
      dbms_output.put_line('update :new.numsin :'||R_pec.numsin);
      dbms_output.put_line('Rec_C_sinistre_sante.numligne :'||Rec_C_sinistre_sante.numligne);
      dbms_output.put_line('loc_dossier:'||loc_dossier);
      --mise à jour de la référence porte
      UPDATE sinistre_sante
      SET numsin_sntrprt =  R_pec.numsin
      WHERE numligne = Rec_C_sinistre_sante.numligne
      AND num_dossier = loc_dossier;


       --ABO pansement pour la création de la référence pour décompte
       
      FOR REC_sntr_dossier IN C_sntr_dossier(loc_dossier,Rec_C_sinistre_sante.numligne)   LOOP
        INSERT INTO sntr_ref (numsin,numsin_porte,numremise,ref)
        VALUES (REC_sntr_dossier.numsin_sntr,R_pec.numsin,R_pec.numremise,R_pec.numremise);
        --pour prise en compte par la constitution des décomptes
        UPDATE SINISTRE SET flagam ='p'
        WHERE numsin =REC_sntr_dossier.numsin_sntr;
      END LOOP;
  

        CLOSE  C_sinistre_sante;
       
    
   EXCEPTION
      WHEN exc_dossier_inconnu THEN w_numano :=96; --705 pec inconnue
      WHEN exc_dossier_liquide THEN w_numano :=67; --697 facture déja règlée au PS
      WHEN exc_dossier_ferme THEN w_numano :=99; --706
      WHEN exc_dossier_perime THEN w_numano :=97; --706 validité expirée
      WHEN exc_montant_diff THEN w_numano :=98; --707
      WHEN exc_acte_inconnu THEN w_numano:=85; --125
      WHEN exc_rej_technique THEN w_numano:=63;--900
      WHEN OTHERS THEN w_numano:=63;

   END;
   
  IF C_sinistre_sante%ISOPEN THEN CLOSE  C_sinistre_sante;
  END IF;
  IF C_Dossier_sante%ISOPEN THEN CLOSE  C_dossier_sante;
  END IF;

   
  IF w_numano>0 THEN
    dbms_output.put_line(':new.w_numano :'||w_numano);
    --il faut rejetter tous les sinistre de la pec.
    --créer donc des sinistre ano pour tout ceux qui ont déjà été enregistré => NON car les ano concerne que ce sinistre !
    --sinistre en cours
    pk_noemie.P_INS_sinistre_ano(
      I_numporte  => 2,
      I_numano  => w_numano,
      I_numsin  => R_pec.numsin,
      I_datano  => Trunc(sysdate),
      I_etatano  => 1,
      I_numremise  => R_pec.numremise);
    END IF;
  
    END LOOP;
    end;
/
