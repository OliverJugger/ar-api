CREATE TRIGGER ARTHUS.trg_bf_ins_upd_individu
before insert or update
on individu
for each row
DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
Begin
if ( :new.creation is null ) then
	:new.creation := trunc(sysdate);
	:new.maj := sysdate;
	:new.numutil := f_numutil;
	:new.modificateur := f_numutil;
else
	:new.maj := sysdate;
	:new.modificateur := f_numutil;
end if;
IF UPDATING THEN
insert into individu_audit ( NUMINDIV
                            ,TYPE
                            ,NOM
                            ,QUALITE
                            ,PRENOM
                            ,DATNAIS
                            ,REFCIE
                            ,CODCOURRIER1
                            ,CODCOURRIER2
                            ,CODTITRE
                            ,SEXE
                            ,POTENTIEL
                            ,NOMJF
                            ,CREATION
                            ,MAJ
                            ,NUMUTIL
                            ,NUMASSU
                            ,TYPASSU
                            ,TYPADR
                            ,REGIME
                            ,ORGBASE
                            ,MATORG
                            ,CLESS
                            ,RANG
                            ,NATUR
                            ,CAISSE
                            ,TEL
                            ,FAX
                            ,ADR1
                            ,ADR2
                            ,CODPOS
                            ,VILLE
                            ,CODPAYS
                            ,GUICHETORG
                            ,CLE
                            ,GUICHETPMT
                            ,EMAIL
                            ,DECES
                            ,N_INSEE
                            ,MODIFICATEUR
                            ,DATNAIS_REGIME
                            ,REGIME2
                            ,CAISSE2
                            ,GUICHETORG2
                            ,MATORG2
                            ,CLESS2
                            ,LIEUNAIS)
values (   :old.NUMINDIV
          ,:old.TYPE
          ,:old.NOM
          ,:old.QUALITE
          ,:old.PRENOM
          ,:old.DATNAIS
          ,:old.REFCIE
          ,:old.CODCOURRIER1
          ,:old.CODCOURRIER2
          ,:old.CODTITRE
          ,:old.SEXE
          ,:old.POTENTIEL
          ,:old.NOMJF
          ,:old.CREATION
          ,:new.MAJ
          ,:old.NUMUTIL
          ,:old.NUMASSU
          ,:old.TYPASSU
          ,:old.TYPADR
          ,:old.REGIME
          ,:old.ORGBASE
          ,:old.MATORG
          ,:old.CLESS
          ,:old.RANG
          ,:old.NATUR
          ,:old.CAISSE
          ,:old.TEL
          ,:old.FAX
          ,:old.ADR1
          ,:old.ADR2
          ,:old.CODPOS
          ,:old.VILLE
          ,:old.CODPAYS
          ,:old.GUICHETORG
          ,:old.CLE
          ,:old.GUICHETPMT
          ,:old.EMAIL
          ,:old.DECES
          ,:old.N_INSEE
          ,f_numutil
          ,:old.DATNAIS_REGIME
          ,:old.REGIME2
          ,:old.CAISSE2
          ,:old.GUICHETORG2
          ,:old.MATORG2
          ,:old.CLESS2
          ,:old.LIEUNAIS);
END IF;
PK_INS_HISTO_EXPORT.INS_HISTO_EXPORT(1, :new.numindiv, :new.numindiv);

End;