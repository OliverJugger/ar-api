CREATE TRIGGER ARTHUS.trg_af_diu_noemie
  AFTER DELETE OR INSERT OR UPDATE ON noemie
  REFERENCING OLD AS old NEW AS new
  FOR EACH ROW
DECLARE
      l_action       VARCHAR2(1);
BEGIN
-- DELETE OR UPDATE (old values)
IF DELETING OR UPDATING THEN
   IF DELETING THEN
      l_action := 'D';
   END IF;
   IF UPDATING THEN
      l_action := 'U';
   END IF;
   INSERT INTO histo_noemie (
                IDPORTE        
              , NUMPORTE       
              , NUMINDIV       
              , NUMASSU        
              , IDADHESION     
              , NUMREMISE      
              , NUMSOC         
              , NUMORG         
              , ORGBASE        
              , CAISSE         
              , MATORG         
              , NATUR          
              , DEBUT          
              , MOUVEMENT      
              , FIN            
              , DATNAIS        
              , RANG           
              , CLESS          
              , NOM            
              , PRENOM         
              , NOMJF          
              , TYPE_CONTRAT   
              , CREATION       
              , MAJ            
              , DATNAIS_REGIME 
              , CENTRE         
              , ACTION_HISTO   
              , NUMUTIL_HISTO  
              , DATE_HISTO     
    )
   VALUES (
                :old.IDPORTE        
              , :old.NUMPORTE       
              , :old.NUMINDIV       
              , :old.NUMASSU        
              , :old.IDADHESION     
              , :old.NUMREMISE      
              , :old.NUMSOC         
              , :old.NUMORG         
              , :old.ORGBASE        
              , :old.CAISSE         
              , :old.MATORG         
              , :old.NATUR          
              , :old.DEBUT          
              , :old.MOUVEMENT      
              , :old.FIN            
              , :old.DATNAIS        
              , :old.RANG           
              , :old.CLESS          
              , :old.NOM            
              , :old.PRENOM         
              , :old.NOMJF          
              , :old.TYPE_CONTRAT   
              , :old.CREATION       
              , :old.MAJ            
              , :old.DATNAIS_REGIME 
              , :old.CENTRE 
            	, l_action
            	, f_numutil
            	,  SYSDATE
                );
END IF;

-- INSERT (new vlaues)
IF INSERTING THEN
   INSERT INTO histo_noemie (
                IDPORTE        
              , NUMPORTE       
              , NUMINDIV       
              , NUMASSU        
              , IDADHESION     
              , NUMREMISE      
              , NUMSOC         
              , NUMORG         
              , ORGBASE        
              , CAISSE         
              , MATORG         
              , NATUR          
              , DEBUT          
              , MOUVEMENT      
              , FIN            
              , DATNAIS        
              , RANG           
              , CLESS          
              , NOM            
              , PRENOM         
              , NOMJF          
              , TYPE_CONTRAT   
              , CREATION       
              , MAJ            
              , DATNAIS_REGIME 
              , CENTRE         
              , ACTION_HISTO   
              , NUMUTIL_HISTO  
              , DATE_HISTO   
                    )
   VALUES (
                :new.IDPORTE        
              , :new.NUMPORTE       
              , :new.NUMINDIV       
              , :new.NUMASSU        
              , :new.IDADHESION     
              , :new.NUMREMISE      
              , :new.NUMSOC         
              , :new.NUMORG         
              , :new.ORGBASE        
              , :new.CAISSE         
              , :new.MATORG         
              , :new.NATUR          
              , :new.DEBUT          
              , :new.MOUVEMENT      
              , :new.FIN            
              , :new.DATNAIS        
              , :new.RANG           
              , :new.CLESS          
              , :new.NOM            
              , :new.PRENOM         
              , :new.NOMJF          
              , :new.TYPE_CONTRAT   
              , :new.CREATION       
              , :new.MAJ            
              , :new.DATNAIS_REGIME 
              , :new.CENTRE 
            	, 'I'
            	, f_numutil
            	, SYSDATE
                );
END IF;

EXCEPTION
    WHEN OTHERS THEN NULL;
END;