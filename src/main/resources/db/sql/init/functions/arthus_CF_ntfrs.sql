CREATE function ARTHUS.arthus_CF_ntfrs (i_numsin in number )  
return Char is
 	 Cursor C_text Is 	 
    SELECT	Replace(crrr.text,'-',' ') 
    FROM   crrr
    WHERE  crrr.text is not null
    AND    crrr.numsin = i_numsin --:sntr_numsin    
    --and crrr.numindiv = 5962 and crrr.codfrais = 'PDIM' and crrr.datsin = e2d('08/03/2019')
    ORDER BY crrr.type,crrr.seq;
    
  L_crrr_acte  varchar2(250):=NULL;
  L_comm  varchar2(250):= NULL;
  L_ligne varchar2(500):= NULL;
begin
  open C_text;
  Loop
    Fetch C_text Into L_crrr_acte;    
    L_comm:= L_crrr_acte;   
  	L_ligne:=L_ligne||' '||L_comm;  
  	If C_text%notfound then
  		exit;
  	End If;  	
  End Loop;
  L_ligne:=substr(SUBSTR(L_ligne,2,LENGTH(L_ligne)-(LENGTH(L_crrr_acte)+ 2 )) , 1 , 75 ) ;
  Close C_text;
  --
  IF L_Ligne IS NULL THEN
  	L_Ligne := 'NSD';
  END IF;
  --	
  Return(L_ligne);
  --
  EXCEPTION
  	WHEN OTHERS THEN return('NSD');
end;
