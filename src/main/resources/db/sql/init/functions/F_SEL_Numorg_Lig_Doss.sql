CREATE FUNCTION ARTHUS.F_SEL_Numorg_Lig_Doss (CODE_FRAIS IN VARCHAR2,
																NUMERO_INDIVIDU IN NUMBER,
																DATE_SINISTRE IN DATE DEFAULT SYSDATE)
RETURN  NUMBER
IS


  loc_numfor_numorg      number default 0;
  Cursor fetch_cvrt_numorg is
          Select  v_cvrt.idadhesion,
                  v_cvrt.numgar,
                  v_cvrt.numfor,
                  v_cvrt.datper,
                  v_cvrt.numorg,
                  v_cvrt.etat,
                  v_cvrt.motif,
                  v_cvrt.rang
          From    v_cvrt
          Where   v_cvrt.numindiv = NUMERO_INDIVIDU
          and     v_cvrt.typfor = 1
          and     v_cvrt.flag_regime='O'
          and     DATE_SINISTRE between v_cvrt.datapli
                           and     nvl(v_cvrt.datper, DATE_SINISTRE)
          -- Order by  rang
          Order By datapli Desc
          ;
  loc_cvrt_numorg    fetch_cvrt_numorg%ROWTYPE;

	loc_ass_numfor number;

	CURSOR C_ASS (LOC_ASS_NUMFOR NUMBER) IS
		SELECT  NUMASS
	    FROM 	FRMLS
		 WHERE (NUMFOR = loc_ass_numfor);

	R_ASS C_ASS%ROWTYPE;


BEGIN

	for loc_cvrt_numorg in fetch_cvrt_numorg
	loop

  	Begin
  		Select  numfor
  		Into    loc_numfor_numorg
  		From    calcul
  		Where   calcul.numfor = pk_qttc.F_sel_Numfor(loc_cvrt_numorg.numgar,loc_cvrt_numorg.numfor)
  			and     calcul.codfrais = CODE_FRAIS
  			and     DATE_SINISTRE between calcul.datapli
                   and     nvl(calcul.datper, DATE_SINISTRE)
  			and     calcul.datapli != nvl(calcul.datper, calcul.datapli + 1)
  		;
  		Exception When No_data_found then loc_numfor_numorg := 0;
  		End;

    if loc_numfor_numorg != 0 then

		  		OPEN C_ASS (pk_qttc.F_sel_Numfor(loc_cvrt_numorg.numgar, loc_cvrt_numorg.numfor));
				  FETCH C_ASS INTO R_ASS;
				  /*
				  IF C_ASS%FOUND THEN
				  			if R_ASS.NUMASS is not null then
									:SINISTRE_SANTE.NUMORG := R_ASS.NUMASS;
								else
									message('Assureur inconnu sur la garantie obligatoire');
								end if;
				  ELSE
				  	 message('Assureur inconnu sur la garantie obligatoire');
				  	 CLOSE C_ASS;
				  	 CLOSE fetch_cvrt_numorg;
				  	 Raise form_trigger_failure;
					END IF;
				  */
				  -- Modif NS du 04-02-2005
				   IF C_ASS%FOUND
				  		AND R_ASS.NUMASS is not null then
									return (R_ASS.NUMASS);
				   ELSE
                        return(-1);
				   END IF;
			CLOSE C_ASS;
			exit;

    end if;
end loop;
CLOSE fetch_cvrt_numorg;
EXCEPTION
		WHEN OTHERS THEN return(NULL);
END;
