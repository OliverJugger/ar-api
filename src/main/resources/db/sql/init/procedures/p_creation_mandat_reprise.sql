CREATE PROCEDURE ARTHUS.p_creation_mandat_reprise
              ( iv_idadhesion   IN NUMBER
              , iv_numgar       IN NUMBER
              , iv_numquerable  IN NUMBER
              , iv_mregl        IN NUMBER
              , iv_fract        IN NUMBER
              , iv_idhq         IN number
              )
  IS
    loc_idrib      rib.idrib%type ;
  loc_rum        VARCHAR2(35 BYTE) ;
  loc_date_adhe  date ;

  BEGIN

    -- recup du rib
    loc_idrib := 0 ;

    select date_adhe into loc_date_adhe
    from adhe_cntrt where idadhesion = iv_idadhesion ;

    select pk_treso.f_idrib (iv_NUMQUERABLE, 2, null, null, greatest(sysdate , loc_date_adhe), iv_IDADHESION, pk_devise.devise_ref) into loc_idrib from dual ;

    if loc_idrib != 0 then

      -- sequence RUM (voir pour utilisation parametre systeme)
      select F_LIB('MANDAT', '1') || lpad(RUM.NEXTVAL,(35-length(F_LIB('MANDAT', '1'))),'0') into loc_rum from dual ;

      update histo_querable  set mandat = loc_rum  where idhistoquerable = iv_idhq ;


      insert into histo_mandat(IDHISTOMANDAT,MANDAT,MAJ,STATUT,IDRIB,MVT,NUMREMISE,AMDT_ICS,AMDT_MNDT,AMDT_ACCT,AMDT_SMNDA,AMDT_CREANCIER,CREATION)
      values (IDHISTOMANDAT.NEXTVAL,
      loc_rum,
      null,
      1, --actif
      loc_idrib ,
      'FRST',
      null,
      null,null,null,null,null,
      sysdate) ;

    end if ;

  EXCEPTION -- a gerer
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN TOO_MANY_ROWS THEN NULL;
    WHEN OTHERS THEN NULL ;

END p_creation_mandat_reprise  ;
/
