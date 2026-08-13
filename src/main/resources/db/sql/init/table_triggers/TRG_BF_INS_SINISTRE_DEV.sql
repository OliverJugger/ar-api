CREATE TRIGGER ARTHUS.TRG_BF_INS_SINISTRE_DEV
before insert
on SINISTRE_DEV
for each row
BEGIN
  --pk_trace.P_INS_journal_adm('M0003438',1,1,'TRG_BF_INS_SINISTRE_DEV avant select : new.numsin = ' || :new.numsin,sysdate,0);
  -- maj des colonnes CODPAYS et NUM_DOSSIER_SIN à partir de SINISTRE_SANTE
  select SAN.codpays , SAN.num_dossier
  into :new.codpays , :new.num_dossier_sin
  from sntr_dossier SNTR
  inner join sinistre_sante SAN on (SNTR.num_dossier = SAN.num_dossier
                                and SNTR.numligne = SAN.numligne )
  where  SNTR.numsin_sntr = :new.numsin ;
  --pk_trace.P_INS_journal_adm('M0003438',1,1,'TRG_BF_INS_SINISTRE_DEV apres select : new.numsin = ' || :new.numsin,sysdate,0);
EXCEPTION when no_data_found then null ;
END;