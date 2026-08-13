CREATE function ARTHUS.F_CPTA_LIB_ANNUL_ENCAIS
                (
                I_codope       In Number,
                I_numencaismt    In Number,
                I_type           In Number   default 1,
                I_longueur       In Number   default 20
                )
Return     VARCHAR2
Is
loc_bdx        Number;
--loc_op_numvir   remise_op_detail.NUMVIREMENT%TYPE;
loc_refpmt      TRAV_COMPTA.VAR01%TYPE;
loc_nom         TRAV_COMPTA.VAR01%TYPE;
loc_encaismt    encaismt%ROWTYPE;
loc_typ_val     compta_lib_reglt.valeur%TYPE;


BEGIN

BEGIN
  select   *
  into     loc_encaismt
  from     encaismt
  where    numencaismt= I_numencaismt;

  Exception When No_data_found then Return 'ENCAISMT_INC';
END;

BEGIN
  Select  f_cpta_en(I_numencaismt)
  Into  loc_bdx
  From  dual;

  Exception When No_data_found then loc_bdx := 1;
END;

BEGIN
  select   COMPTA_LIB_REGLT.valeur
  into     loc_typ_val
  from     COMPTA_LIB_REGLT,
           COMPTE
  where    COMPTE.NUMCPTE            = loc_encaismt.NUMCPTE
  and      COMPTA_LIB_REGLT.NUMSOC   = COMPTE.NUMSOC
  and      COMPTA_LIB_REGLT.CODOPE   = I_codope
  and      COMPTA_LIB_REGLT.TYPE_PMT = 0
  and      COMPTA_LIB_REGLT.MODE_PMT = loc_encaismt.modpmt
  and      COMPTA_LIB_REGLT.TYPE_DEV = f_cpta_type_pmt(2,I_numencaismt);

  Exception When No_data_found then loc_typ_val := 'INC';
END;

if loc_bdx= 1 then

      loc_refpmt   := substr('0000000' || to_char(nvl(loc_encaismt.refpmt,loc_encaismt.numencaismt)),-7,7);
      loc_nom := pk_personne.f_nom(loc_encaismt.numcli,I_longueur,2);

else
  BEGIN
    select substr('0000000' || to_char(numremise),-7,7)
          ,pk_personne.f_nom(loc_encaismt.numcli,I_longueur,2)
    into   loc_refpmt, loc_nom
    from   remise_banque, encaismt, compte
    where  remise_banque.numencaismt=I_numencaismt
    and    encaismt.numencaismt=remise_banque.numencaismt
    and    compte.numcpte=encaismt.numcpte
    union
    select substr('0000000' || to_char(prelevement.numremise),-7,7)
          ,to_char(remise_prelev.date_prelev, 'DD/MM/YY')||' '||pk_personne.f_nom(loc_encaismt.numcli,I_longueur,2)
    from   prelevement,remise_prelev
    where  prelevement.numencaismt=I_numencaismt
    and    prelevement.numremise=remise_prelev.numremise;

    Exception
      When No_data_found then
        Return 'REF_EN_INCONNU';
      When too_many_rows then
        Return 'MULTI_REF';
  END;


end if;


if   I_type = 1 then

  RETURN ( SUBSTR(loc_refpmt,1,I_longueur) );

elsif I_type = 2 then

  RETURN ( SUBSTR(loc_typ_val,1,I_longueur) );

elsif I_type = 3 then

  RETURN ( SUBSTR(loc_nom,1,I_longueur) );

end if;


END  F_CPTA_LIB_ANNUL_ENCAIS;
