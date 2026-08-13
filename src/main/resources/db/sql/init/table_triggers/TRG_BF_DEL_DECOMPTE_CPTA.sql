CREATE TRIGGER ARTHUS.TRG_BF_DEL_DECOMPTE_CPTA
   BEFORE DELETE ON Decompte
   FOR EACH ROW
-- M0003438 : mur ajout le 26/08/2014
-- Contrat Responsable ABO 22/07/2015 ajout de la base, y ,cas et taux
 Declare
--
      L_decompte_annul NUMBER;
      L_sinistre_annul NUMBER;
      L_sinistre_dev_annul NUMBER;
--
   Begin
--      If (:old.Idcompta != -1 ) Then
         -- Ajout ou update dans decompte_annul pour permettre l'annulation de la compta
         SELECT count(*)
         INTO L_decompte_annul
         FROM Decompte_annul
         WHERE Numdec = :old.Numdec;

         IF (L_decompte_annul > 0) Then
            UPDATE Decompte_annul
            SET Idcompta_init = :old.Idcompta, datannul = sysdate
            WHERE Numdec = :old.Numdec;
         ELSE
            INSERT INTO Decompte_annul (
                    numdec,numindiv,montant,datpay,modpmt,
                    typbene,numbene,monnaie,numgar,numdcptcie,
                    mtfrais,debit,mtremb,autrb,mtreel,
                    monnaie_d,montant_d,
                    mtfrais_d,debit_d,mtremb_d,autrb_d,mtreel_d,
                    devise_ec, devise_ct, montant_ec, montant_ct, sens_ec, type_ec,
                    numdest, roledest, idcompta, idcompta_init,
                    refpmt,cptcomp,nbfeuille,numpmt,numbque,
                    flagedit, datannul)
            VALUES(:old.numdec,:old.numindiv,:old.montant,:old.datpay,:old.modpmt,
                   :old.typbene,:old.numbene,:old.monnaie,:old.numgar,decode(:old.numdcptcie,0,-1,0),
                   :old.mtfrais,:old.debit,:old.mtremb,:old.autrb,:old.mtreel,
                   :old.monnaie_d,:old.montant_d,
                   :old.mtfrais_d,:old.debit_d,:old.mtremb_d,:old.autrb_d,:old.mtreel_d,
                   :old.devise_ec, :old.devise_ct, :old.montant_ec, :old.montant_ct, :old.sens_ec,
                   :old.type_ec, :old.numdest, :old.roledest, -1, :old.idcompta,
                   :old.refpmt,:old.cptcomp,:old.nbfeuille,:old.numpmt,:old.numbque,
                   :old.flagedit,sysdate);
         END IF;

         -- Ajout dans sinistre_annul et sinistre_dev_annul s'ils n'existent pas
         -- Important pour faire le lien dans la vue 121 de la compta
         SELECT count(*)
         INTO L_sinistre_annul
         FROM Sinistre_annul
         WHERE Numdec = :old.Numdec;

         IF (L_sinistre_annul = 0) Then
            INSERT INTO Sinistre_annul(
                    codfrais, numgar, numindiv, datsin, mtprest, mtremb, mtfrais,
                    datsai, nbacte, autrb, mtfran, sens, mtmax, mtreel,
                    numdec, numassu, numbene, numsin, numannul, username, flagam,
                    typbene, numpopu, numfor, num_fact, nummath, numpc, X,
                    idadhesion, PDSQLS, SPE_EXE, FRA_DEP,RACMON,DATEDIT_RC,EDTDCPT,
      							MONNAIE, NUMASSU_RC,NUMDCPTCIE, NUMDEC_RC, FLAG_REGIME, NUMDCPTCIE_INIT
                    , CODPAYS , NUM_DOSSIER_SIN , NUMLIGNE_SIN,BASEREMB,Y,TAUX,CAS )
            SELECT  codfrais, numgar, numindiv, datsin, mtprest, mtremb, mtfrais,
                    datsai, nbacte, autrb, mtfran, sens, mtmax, mtreel,
                    :old.Numdec, numassu, numbene, numsin, numannul, username, flagam,
                    typbene, numpopu, numfor, num_fact, nummath, numpc, X,
                    idadhesion,PDSQLS, SPE_EXE, FRA_DEP,RACMON,DATEDIT_RC,EDTDCPT,
      							MONNAIE, NUMASSU_RC,decode(numdcptcie,0,-1,0), NUMDEC_RC, FLAG_REGIME, numdcptcie
                    , CODPAYS , NUM_DOSSIER_SIN , NUMLIGNE_SIN  ,BASEREMB,Y,TAUX,CAS
            FROM    Sinistre
            WHERE   Numdec = :old.Numdec;
         END IF;
--
         SELECT count(*)
         INTO L_sinistre_dev_annul
         FROM Sinistre_dev_annul
         WHERE Numdec = :old.Numdec;

         IF (L_sinistre_dev_annul = 0) Then
            INSERT INTO Sinistre_dev_annul(
                    NUMSIN,DEV_CT,DEV_IN,DEV_OUT,MTFRAIS_CT,MTFRAIS_IN,MTFRAIS_OUT,MTPREST_CT,
                    MTPREST_IN,MTPREST_OUT,MTREMB_CT,MTREMB_IN,MTREMB_OUT,MTREEL_CT,MTREEL_IN,
                    MTREEL_OUT,AUTRB_CT,AUTRB_IN,AUTRB_OUT,NUMDEC,NUMINDIV
                    , CODPAYS , NUM_DOSSIER_SIN , NUMLIGNE_SIN )
            SELECT  NUMSIN,DEV_CT,DEV_IN,DEV_OUT,MTFRAIS_CT,MTFRAIS_IN,MTFRAIS_OUT,MTPREST_CT,
                    MTPREST_IN,MTPREST_OUT,MTREMB_CT,MTREMB_IN,MTREMB_OUT,MTREEL_CT,MTREEL_IN,
                    MTREEL_OUT,AUTRB_CT,AUTRB_IN,AUTRB_OUT,:old.Numdec,NUMINDIV
                    , CODPAYS , NUM_DOSSIER_SIN , NUMLIGNE_SIN
            FROM    Sinistre_dev
            WHERE   Numdec = :old.Numdec;
         END IF;

         --ABO 09/03/2012 M0003734 Consitution de bordereau de dde de rbt de prestation, pb de réinitialisation du numdcptcie de sinistre
         -- MAJ à réaliser après la création des sinistres annulés
         UPDATE sinistre
         SET numdcptcie = 0
         WHERE numdcptcie >0
         AND numdec = :old.Numdec;

--      End if;
   End;