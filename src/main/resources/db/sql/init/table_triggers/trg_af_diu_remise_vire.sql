CREATE TRIGGER ARTHUS.trg_af_diu_remise_vire
   AFTER DELETE OR INSERT OR UPDATE ON remise_vire
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
      INSERT INTO histo_remise_vire (
         numremise,
         numcpte,
         datrem,
         nombre,
         montant,
         valide,
         datvalide,
         datedit,
         numutil,
         datdisk,
         typdest,
         numdest,
         natrem,
         monnaie_d,
         montant_d,
         monnaie,
         date_valeur,
	     action_histo,
	     numutil_histo,
	     date_histo)
      VALUES (
         :old.numremise,
         :old.numcpte,
         :old.datrem,
         :old.nombre,
         :old.montant,
         :old.valide,
         :old.datvalide,
         :old.datedit,
         :old.numutil,
         :old.datdisk,
         :old.typdest,
         :old.numdest,
         :old.natrem,
         :old.monnaie_d,
         :old.montant_d,
         :old.monnaie,
         :old.date_valeur,
	     l_action,
	     f_numutil,
	     SYSDATE);
   END IF;

   -- INSERT (new vlaues)
   IF INSERTING THEN
      INSERT INTO histo_remise_vire (
         numremise,
         numcpte,
         datrem,
         nombre,
         montant,
         valide,
         datvalide,
         datedit,
         numutil,
         datdisk,
         typdest,
         numdest,
         natrem,
         monnaie_d,
         montant_d,
         monnaie,
         date_valeur,
	     action_histo,
	     numutil_histo,
	     date_histo)
      VALUES (
         :new.numremise,
         :new.numcpte,
         :new.datrem,
         :new.nombre,
         :new.montant,
         :new.valide,
         :new.datvalide,
         :new.datedit,
         :new.numutil,
         :new.datdisk,
         :new.typdest,
         :new.numdest,
         :new.natrem,
         :new.monnaie_d,
         :new.montant_d,
         :new.monnaie,
         :new.date_valeur,
	     'I',
	     f_numutil,
	     SYSDATE);
   END IF;

   EXCEPTION WHEN OTHERS THEN NULL;
END;