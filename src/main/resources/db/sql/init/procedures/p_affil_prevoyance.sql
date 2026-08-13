CREATE procedure ARTHUS.p_affil_prevoyance (
          i_numindiv IN individu.numindiv%TYPE,
          i_numgar contrat.numgar%TYPE, 
          i_numfor adhesion.numfor%TYPE ,
          i_debut varchar2,
          i_fin varchar2) is

  loc_AFFIL_PORTE     AFFIL_PORTE%ROWTYPE;
  loc_AFFIL_PORTE_ADH AFFIL_PORTE_ADH%ROWTYPE;
  loc_ano NUMBER;
  
  loc_HISTO_ADHESION    HISTO_ADHESION%ROWTYPE;
  loc_ADHE_CNTRT        ADHE_CNTRT%ROWTYPE;
  loc_ADHE_CNTRT_MEMBRE ADHE_CNTRT_MEMBRE%ROWTYPE;
  
  exc_histo_adhesion EXCEPTION;
  exc_adhe_membre    EXCEPTION;
  exc_adhecntrt      EXCEPTION;
BEGIN
  loc_AFFIL_PORTE.numindiv := i_numindiv;
  loc_AFFIL_PORTE.type_mvt := 1;
  loc_AFFIL_PORTE_ADH.numindiv := i_numindiv;
  loc_AFFIL_PORTE_ADH.numgar := i_numgar;
  loc_AFFIL_PORTE.numgar := i_numgar;
  loc_AFFIL_PORTE_ADH.refgarantie := i_numfor;
  loc_AFFIL_PORTE_ADH.numayd :=0;
  loc_AFFIL_PORTE.debutc := i_debut;
  loc_AFFIL_PORTE.fincon := i_fin;
  loc_AFFIL_PORTE.USERNAME_FORCAGE:=f_numutil;
  loc_AFFIL_PORTE.DATRAIT:=sysdate;

  BEGIN
  
    PK_CTRL_AFFIL.P_INIT_ADHE_CNTRT( loc_AFFIL_PORTE
                                   , loc_AFFIL_PORTE_ADH.numgar
                                   , e2d(loc_AFFIL_PORTE.DEBUTC) -- P_dateff
                                   , loc_ADHE_CNTRT
                                   , loc_ano);
    --dbms_Output.Put_Line('ici'||loc_ADHE_CNTRT.IDADHESION);
    loc_AFFIL_PORTE_ADH.IDADHESION:=loc_ADHE_CNTRT.IDADHESION;
    loc_AFFIL_PORTE.IDADHESION:=loc_ADHE_CNTRT.IDADHESION;
    
    IF loc_ano<>0 THEN
      RAISE exc_adhecntrt;
    END IF;
   
    IF PK_CTRL_AFFIL.F_INSERT_ADHE_CNTRT(loc_ADHE_CNTRT) THEN
     loc_ano:=0;
    ELSE
      RAISE exc_adhecntrt;
    END IF;
    --dbms_Output.Put_Line('la');
    PK_CTRL_AFFIL.P_INIT_HISTO_ADHESION( loc_AFFIL_PORTE
                                        ,loc_AFFIL_PORTE_ADH
                                       , e2d(loc_AFFIL_PORTE.DEBUTC) -- P_dateff
                                       , loc_HISTO_ADHESION
                                       , loc_ano);
                                       
                                       
    IF loc_ano<> 0 THEN
      RAISE exc_histo_adhesion;
    END IF;
    dbms_Output.Put_Line('re'||loc_HISTO_ADHESION.IDHISTOADHE);
    IF PK_CTRL_AFFIL.F_INSERT_HISTO_ADHESION(loc_HISTO_ADHESION) THEN
      loc_ano:=0;
    ELSE
      RAISE exc_histo_adhesion;
    END IF;
    --dbms_Output.Put_Line('pouet'||loc_HISTO_ADHESION.etat);
    PK_CTRL_AFFIL.P_INIT_ADHE_CNTRT_MEMBRE( loc_AFFIL_PORTE_ADH
                                          , loc_ADHE_CNTRT_MEMBRE
                                          , loc_ano);
   -- P_INS_journal(3,' P_GestionAffiliation, P_INIT_ADHE_CNTRT_MEMBRE: '||P_AFFIL_PORTE_ADH.IDADHESION);
    IF loc_ano<>0 THEN
      RAISE exc_adhe_membre;
    END IF;
  -- dbms_Output.Put_Line('ouic');
    IF PK_CTRL_AFFIL.F_INSERT_ADHE_CNTRT_MEMBRE(loc_ADHE_CNTRT_MEMBRE) THEN
      loc_ano:=0;
    ELSE
      RAISE exc_adhe_membre;
    END IF;
    dbms_Output.Put_Line(loc_ADHE_CNTRT_MEMBRE.numindiv ||'-'||loc_ADHE_CNTRT_MEMBRE.idadhesion);
    --PK_CTRL_AFFIL.P_INS_COUVERTURES( loc_AFFIL_PORTE_ADH,  loc_AFFIL_PORTE.USERNAME_FORCAGE,e2d(i_debut),e2d(i_fin),loc_ano);
    
     INSERT INTO ADHESION( NUMINDIV,NUMGAR,NUMFOR,DATAPLI,DATPER,RANG,ETAT,UC,FLAG_REGIME,
                          REGIME,TYPFOR,NUMORG,DIS_CARENCE,DIS_FRANCHISE,IDADHESION,
                          NUMFOR_CARENCE,NUMUTIL,CREATION,MAJ,MOTIF,IDCOUVERTURE
                          )
    SELECT   loc_AFFIL_PORTE_ADH.numindiv ,loc_AFFIL_PORTE_ADH.NUMGAR,loc_AFFIL_PORTE_ADH.REFGARANTIE,NVL(e2d(i_debut),sysdate),e2d(i_fin),1,1,NULL,'C',
           1,g.type,1,'O','O',loc_AFFIL_PORTE_ADH.IDADHESION,
           NULL,loc_AFFIL_PORTE.USERNAME_FORCAGE,SYSDATE, NULL, NULL, IDCOUVERTURE.NEXTVAL
     FROM  gar_cntrt g
    WHERE g.numfor  = loc_AFFIL_PORTE_ADH.refgarantie
      AND NOT EXISTS(SELECT idadhesion
                       FROM adhesion
                      WHERE NUMINDIV =   loc_AFFIL_PORTE_ADH.NUMINDIV
                        and idadhesion = loc_AFFIL_PORTE_ADH.IDADHESION
                        and numfor = loc_AFFIL_PORTE_ADH.REFGARANTIE);
    
  
    EXCEPTION
    WHEN exc_adhecntrt THEN
      loc_ano:=-4;
    
    WHEN exc_histo_adhesion THEN
      loc_ano:=-6;
      
    WHEN exc_adhe_membre THEN
      loc_ano:=-9;
     
  /*  WHEN exc_adhesion THEN
      loc_ano:=-12;*/
    WHEN OTHERS THEN
  dbms_Output.Put_Line(' Erreur : '||SUBSTR(SQLERRM,1,132));
    loc_ano:=-14;
   END;
   
  IF loc_ano<>0 THEN
    dbms_Output.Put_Line(' loc_ano : '||loc_ano);
   ROLLBACK;
  ELSE
    COMMIT;
  END IF;

END ;
/
