package com.bdl.epbs_fund_api.specification.rule.rel_related_individual;

import java.util.Objects;
import java.util.Optional;

import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.relations.RelRelatedIndividual;
import com.bdl.epbs_fund_api.specification.criteria.RelRelatedIndividualSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class RelRelatedIndividualActiveRule implements RelRelatedIndividualRule {
	  private static final long serialVersionUID = 1L;
	
	  private static final String VALID_TO_FIELDNAME = "validTo";
	  private static final String TASKUID_FIELDNAME = "taskUid";

	@Override
    public boolean matches(RelRelatedIndividualSearchCriteria criteria) {
    	return Optional.ofNullable(criteria)
    			.map(RelRelatedIndividualSearchCriteria::getActiveDate)
    			.map(Objects::nonNull)
    			.orElse(false);
    }

    @Override
    public Predicate apply(Root<RelRelatedIndividual> root, CriteriaBuilder builder, RelRelatedIndividualSearchCriteria criteria) {
        return builder.or(
                builder.isNull(root.get(VALID_TO_FIELDNAME)),
                builder.greaterThan(root.get(VALID_TO_FIELDNAME), criteria.getActiveDate()),
                builder.and(
                		builder.equal(root.get(VALID_TO_FIELDNAME), criteria.getActiveDate()),
                        builder.isNotNull(root.get(TASKUID_FIELDNAME)))
        );
    }
}
