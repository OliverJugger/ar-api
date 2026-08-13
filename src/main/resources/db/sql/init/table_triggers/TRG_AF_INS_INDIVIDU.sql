CREATE TRIGGER ARTHUS."TRG_AF_INS_INDIVIDU"
after insert
on individu
for each row
DECLARE
   CST_SCCS   CONSTANT VARCHAR2(120) := '%W%    %E%';
BEGIN
Begin
Ins_rib( :new.numindiv, :new.nom, :new.prenom, :new.codcourrier1 );
--décompte santé
Insert into COURRIER_INFO (NUMINDIV,TYPE_CRRR,MOYEN_INFO) SELECT :new.numindiv,28,1 from dual
where not exists (select numindiv from courrier_info where numindiv = :new.numindiv and type_crrr=28)
-- MUR M0005551
and :new.type = 1
;

--décompte prévoyance
Insert into COURRIER_INFO (NUMINDIV,TYPE_CRRR,MOYEN_INFO) SELECT :new.numindiv,17,1 from dual
where not exists (select numindiv from courrier_info where numindiv = :new.numindiv and type_crrr=17);
Insert into COURRIER_INFO (NUMINDIV,TYPE_CRRR,MOYEN_INFO) SELECT :new.numindiv,18,1 from dual
where not exists (select numindiv from courrier_info where numindiv = :new.numindiv and type_crrr=18);
Insert into COURRIER_INFO (NUMINDIV,TYPE_CRRR,MOYEN_INFO) SELECT :new.numindiv,19,1 from dual
where not exists (select numindiv from courrier_info where numindiv = :new.numindiv and type_crrr=19);
Insert into COURRIER_INFO (NUMINDIV,TYPE_CRRR,MOYEN_INFO) SELECT :new.numindiv,20,1 from dual
where not exists (select numindiv from courrier_info where numindiv = :new.numindiv and type_crrr=20);

End;
END;