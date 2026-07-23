package com.bdl.epbs_fund_api.utils;

import java.util.HashSet;
import java.util.Set;

/**
 * Similarité de Jaccard
 * 
 * Application avec bi-grammes (N =2)
 * 
 * Pas ultra précis mais plus rapide (car prend les caractères 2 par 2 pour la comparaison)
 *
 */
public class JaccardSimilarityUtil {
	
	private JaccardSimilarityUtil() {}
	
	private static final int GRANULARITY = 2;
	
    private static double calculateJaccardSimilarity(Set<String> set1, Set<String> set2) {
        Set<String> intersection = new HashSet<>(set1);
        intersection.retainAll(set2);
        
        Set<String> union = new HashSet<>(set1);
        union.addAll(set2);
        
        return (double) intersection.size() / union.size();
    }

    private static Set<String> getNgrams(String input, int n) {
        Set<String> ngrams = new HashSet<>();
        for (int i = 0; i < input.length() - n + 1; i++) {
            ngrams.add(input.substring(i, i + n).toUpperCase());
        }
        return ngrams;
    }
    
    public static double calculateJaccardSimilarity(String s1, String s2) {
    	return calculateJaccardSimilarity(getNgrams(s1, GRANULARITY), getNgrams(s2, GRANULARITY));
    }
}
