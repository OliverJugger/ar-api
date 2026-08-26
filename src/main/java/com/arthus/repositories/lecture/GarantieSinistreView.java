package com.arthus.repositories.lecture;

import java.time.LocalDate;

/*
 * Projection du résultat de {@code findGarantiesAvecDates} : une garantie du
 * sinistre, son contrat porteur et les dates de couverture issues d'ADHESION.
 *
 * Correspondance avec les colonnes de l'ancienne requête Forms :
 * 
 *   g.libelle          -> getLibelle()
 *   g.nomgar           -> getNomgar()
 *   :repartition.valide-> getValide()
 *   c.numgar           -> getNumgar()
 *   c.refcie           -> getRefcie()
 *   max(a.datapli)     -> getDatesous()
 *   max(a.datper)      -> getDatper()
 * 
 * numfor est ajouté : c'est la clé de la garantie, elle manquait au SELECT
 * d'origine parce que Forms l'avait déjà dans le bloc courant.)
 *
 * Les alias de la requête native sont en minuscules ; Oracle les remonte en
 * majuscules et Spring Data fait la correspondance sur le nom de la propriété.
 * Si un alias ne se mappe pas, mets-le entre guillemets dans le SQL AS "datesous".
 * 
 */
public interface GarantieSinistreView {

    Long getNumfor();

    String getNomgar();

    String getLibelle();

    /* VALIDE de la répartition ('O'). */
    String getValide();

    Long getNumgar();

    String getRefcie();

    /* max(ADHESION.DATAPLI) — la « date de souscription » de l'écran legacy. */
    LocalDate getDatesous();

    /* max(ADHESION.DATPER). */
    LocalDate getDatper();
}
