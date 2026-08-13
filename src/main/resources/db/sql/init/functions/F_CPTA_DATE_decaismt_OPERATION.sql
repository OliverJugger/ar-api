CREATE function ARTHUS.F_CPTA_DATE_decaismt_OPERATION (I_numdecaismt    In Number)
Return     DATE
As    loc_date       DATE;
      loc_bdx        NUMBER;
      loc_decaismt   decaismt%ROWTYPE;
BEGIN

BEGIN
  select  *
    into  loc_decaismt
    from  decaismt
   where  numdecaismt  =   I_numdecaismt;
END;

BEGIN
  Select  f_cpta_de(I_numdecaismt)
    Into  loc_bdx
    From  dual;
  Exception When No_data_found then loc_bdx := 1;
END;

if loc_bdx= 1 then
-- 21/05/10 : ATTENTION - il a ete constate que la date de creation dans la table DECAISMT est ecrasee et identique pour
--            tous les decaissements. Elle ne peut donc pas etre utilisee pour le moment. D'ou l'usage de DATPAY en attente.
-- 15/09/10 : Ajout de la date d'affectation pour régler le probleme. Màj de la date de creation du décaissement.
--  loc_date   := loc_decaismt.creation;
--  loc_date 	:= loc_decaismt.datpay;
-- 20/07/2011 : dans le cas des pertes et profits (compte 8) et des regulations hors arthus (compte 11)la date d'affectation n'est pas renseignée, c'est donc la DATPAY qui est utilisée
  if loc_decaismt.numcpte in (8,11) then
    loc_date := loc_decaismt.datpay;
  else
    loc_date 	:= loc_decaismt.dataffec;
  end if;
else
  BEGIN
    Select  datdisk
      Into  loc_date
      From  remise_op_detail,
            remise_op
     Where  remise_op_detail.numdecaismt= I_numdecaismt
    AND     remise_op_detail.numremise=remise_op.numremise
    UNION
    Select  datdisk
      From  remise_vire_detail,
            remise_vire
     Where  remise_vire_detail.numdecaismt= I_numdecaismt
       AND  remise_vire_detail.numremise=remise_vire.numremise ;
  END;
end if;

if  loc_date is null then
  loc_date  := (sysdate + 365);
end if;

RETURN loc_date;

END  F_CPTA_DATE_decaismt_OPERATION;
