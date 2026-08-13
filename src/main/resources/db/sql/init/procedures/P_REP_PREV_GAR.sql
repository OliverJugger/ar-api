CREATE PROCEDURE ARTHUS.P_REP_PREV_GAR(I_numfor_ref garanties.numfor%TYPE, I_numprod produit.numprod%TYPE, I_numgar contrat_ref.numgar%TYPE, I_debut DATE DEFAULT NULL) IS
  loc_numfor NUMBER(9);
  L_ins_journal BOOLEAN;
  L_code_msg VARCHAR(2000);
  loc_nomgar v_gar.nomgar%TYPE;
  loc_libgar v_gar.libgar%TYPE;
  loc_typfor v_gar.typfor%TYPE;
  loc_valide v_gar.valide%TYPE;
  loc_debut DATE;
  loc_count NUMBER;
BEGIN
  /*declare


begin

  P_REP_PREV_GAR(67675, 80, 4415,NULL) ;

end;

*/
  loc_count:=0;
  SELECT COUNT(*) INTO loc_count FROM garanties WHERE numfor_ref=I_numfor_ref AND cle = I_numgar AND etendue = 2;

  IF loc_count = 0 THEN

    --Procedure de création établie en fonction de gg05

    SELECT v_gar.nomgar,   v_gar.libgar, v_gar.typfor, v_gar.valide,NVL(I_debut,v_gar.datapli)
    INTO loc_nomgar,loc_libgar,loc_typfor,loc_valide, loc_debut
    From   v_gar
    Where  numfor=I_numfor_ref;

    Select numfor.nextval
    Into loc_numfor
    from dual;
     dbms_output.put_line('loc_numfor:'||loc_numfor);
    Insert into gar_cntrt_ref  (numgar,numfor,nomgar,datapli,datper,libelle, type,valide,numfor_ref)
    Values (I_numgar,
            loc_numfor,
            loc_nomgar,
            loc_debut,
            Null,
            loc_libgar,
            loc_typfor,
            loc_valide,
            I_numfor_ref);

    Pk_dupliq_gar.P_INS_Gar2
               (I_numfor      => loc_numfor,
                I_code_pays   => 1,
                I_session     => 1,
                I_date        => sysdate,
                I_ins_journal => L_ins_journal
               );
   --dbms_output.put_line('Pk_dupliq_gar.P_INS_Gar2' || L_ins_journal);

    PK_insert_var.P_INS_val_var(I_etendue     => 1,
                                I_numgar      => I_numgar,
                                I_numfor      => loc_numfor,
                                I_numindiv    => 0,
                                I_ins_journal => L_ins_journal,
                                I_valeur      => 0,
                                I_code_pays   => 1,
                                I_session     => 1,
                                I_date        => sysdate,
                                O_code_msg    => L_code_msg);
    dbms_output.put_line('PK_insert_var.P_INS_val_var'||L_code_msg);

  ELSE
    dbms_output.put_line('Garantie déjà existante I_numfor_ref:'||I_numfor_ref);
  END IF;

END P_REP_PREV_GAR;
/
