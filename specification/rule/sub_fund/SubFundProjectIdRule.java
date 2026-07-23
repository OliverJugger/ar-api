package com.bdl.epbs_fund_api.specification.rule.sub_fund;

import java.util.Objects;
import java.util.Optional;

import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.model.entities.ProjectInitiator;
import com.bdl.epbs_fund_api.model.entities.SubFund;
import com.bdl.epbs_fund_api.specification.criteria.SubFundSearchCriteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

@Component
public class SubFundProjectIdRule implements SubFundRule {
	private static final long serialVersionUID = 1L;

	@Override
	public boolean matches(SubFundSearchCriteria criteria) {
		return Optional.ofNullable(criteria)
				.map(SubFundSearchCriteria::getProjectId)
				.map(Objects::nonNull)
				.orElse(false);
	}

	@Override
	public Predicate apply(Root<SubFund> root, CriteriaBuilder builder, SubFundSearchCriteria criteria) {
		Join<ProjectInitiator, SubFund> relSubFundProjectInitiator = root
				.join("relProjectSubFund", JoinType.LEFT)
				.join("project", JoinType.LEFT);
				
		return builder.equal(relSubFundProjectInitiator.get("id"), criteria.getProjectId());
	}

}
