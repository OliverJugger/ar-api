CREATE FUNCTION ARTHUS."F_ETAT_ADHE" (
         a_idadhesion   IN NUMBER,
         a_date      IN DATE,
         a_type in number default 1)
/*===========================================================================*/
/* Fonction     : F_ETAT_ADHE.sql                                            */
/* Domaine      : Personne                                                   */
/* Version      : V1.0                                                       */
/* Auteur       :                                                            */
/* Création     :   Retourne l'état, le type ou la date de l'adhesion en     */
/* Description  :   fonction du type en entrée de la fonction                */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : KLA / 21/02/2011 / Ajout du curseur C_futur pour gérer les */
/*                adhésions en instance postèrieure à la date du jour        */
/*                PHA 17/12/2014 anomalie sur le tri lorsque plusieurs états */
/*                sont saisis le même jour                                   */
/*===========================================================================*/

/* ==========================================================================*/
-- PROCEDURES ET FONCTIONS PUBLIQUES
/* ========================== Fin des Procedures publiques ==================*/
RETURN NUMBER
AS
loc_etat   number default 0;
L_date      Date;
cursor C_histo is
   Select   histo_adhesion.etat,
      histo_adhesion.motif,
      d2j(histo_adhesion.debut)   debut,
      d2j(histo_adhesion.datsai)   datsai,
      idhistoadhe
   From   histo_adhesion
   Where   idadhesion = a_idadhesion
   and   debut <= L_date
   and   etat != 0
   order by
      datsai desc ,
      idhistoadhe desc
   ;
Cursor C_instance IS
   Select   histo_adhesion.etat,
      histo_adhesion.motif,
      d2j(histo_adhesion.debut)   debut,
      d2j(histo_adhesion.datsai)   datsai,
      idhistoadhe
   From   histo_adhesion
   Where   idadhesion = a_idadhesion
   and   debut <= L_date
   and   Not Exists (
      select   1
      from   histo_adhesion   instance
      where   instance.idadhesion = a_idadhesion
      and   instance.etat != 0
      )
   order by
      datsai desc ,
      idhistoadhe desc
   ;

Cursor C_futur IS
  Select  histo_adhesion.etat,
        histo_adhesion.motif,
        d2j(histo_adhesion.debut) debut,
        d2j(histo_adhesion.datsai)   datsai,
        idhistoadhe
    From    histo_adhesion
    Where   idhistoadhe = (select min(idhistoadhe) from histo_adhesion Where idadhesion = a_idadhesion)
  ;
Rec_C_histo   C_histo%Rowtype;
Rec_C_instance   C_instance%Rowtype;
Rec_C_futur C_futur%Rowtype;
BEGIN
loc_etat := 0;
--
Begin
L_date :=a_date;
End;
--
Open C_instance;
fetch C_instance into Rec_C_instance;
If (C_instance%Found) then
   If (a_type=1) Then
      loc_etat := nvl( Rec_C_instance.etat, 0 );
   Elsif (a_type=2) Then
      loc_etat := nvl( Rec_C_instance.motif, 0 );
   Elsif (a_type=3) Then
      loc_etat := nvl( Rec_C_instance.debut, 1 );
   Elsif (a_type=4) Then
      loc_etat := nvl( Rec_C_instance.datsai, 1 );
    Elsif (a_type=5) Then
      loc_etat := Rec_C_instance.idhistoadhe;
   End if;
Else
   Open C_histo;
   Fetch C_histo into Rec_C_histo;
  If (C_histo%Found) then
     --
     If (a_type=1) Then
        loc_etat := nvl( Rec_C_histo.etat, 0 );
     Elsif (a_type=2) Then
        loc_etat := nvl( Rec_C_histo.motif, 0 );
     Elsif (a_type=3) Then
        loc_etat := nvl( Rec_C_histo.debut, 1 );
     Elsif (a_type=4) Then
        loc_etat := nvl( Rec_C_histo.datsai, 1 );
      Elsif (a_type=5) Then
        loc_etat := Rec_C_histo.idhistoadhe;
     End if;
   Else
     Open C_futur;
     Fetch C_futur into Rec_C_futur;
     Close C_futur;
     --
     If (a_type=1) Then
        loc_etat := nvl( Rec_C_futur.etat, 0 );
     Elsif (a_type=2) Then
        loc_etat := nvl( Rec_C_futur.motif, 0 );
     Elsif (a_type=3) Then
        loc_etat := nvl( Rec_C_futur.debut, 1 );
     Elsif (a_type=4) Then
        loc_etat := nvl( Rec_C_futur.datsai, 1 );
      Elsif (a_type=5) Then
        loc_etat := Rec_C_futur.idhistoadhe;
     End if;
   End if;
   Close C_histo;
End if;
Close C_instance;
--
Return loc_etat;
--
END f_etat_adhe;
