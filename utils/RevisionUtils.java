package com.bdl.epbs_fund_api.utils;

import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.function.BiConsumer;
import java.util.function.Function;
import java.util.stream.IntStream;

import com.bdl.epbs_fund_api.mappings.v2.AuditedMapperV2;

public class RevisionUtils {
	
	private RevisionUtils() {}
	
	public static Integer incrementAuditVersion(Integer forceAuditVersion) {
		return Objects.isNull(forceAuditVersion) ? 0 : forceAuditVersion + 1;
	}
	
	public static <T, U> List<T> sortRevisionsAndOrganise(
			List<T> revisions,
			Comparator<T> compareSortFunction,
			Function<T, U> getRevisionElementAfterFunction,
			Function<T, U> getRevisionElementBeforeFunction,
			BiConsumer<T, U> setRevisionElementBeforeFunction,
			AuditedMapperV2<U> auditedEqualsMapper) {
		
		List<T> sortedRevisions = revisions
			.stream()
			.sorted(compareSortFunction)
			.toList();
		
		IntStream.range(0, sortedRevisions.size())
			.forEach(index -> {
				U revisionBefore =
						index == (sortedRevisions.size() - 1) 
						? null
						: getRevisionElementAfterFunction.apply(sortedRevisions.get(index + 1));
				
				setRevisionElementBeforeFunction.accept(sortedRevisions.get(index), revisionBefore);
			});
		
		return sortedRevisions
				.stream()
				.filter(rev -> !auditedEqualsMapper.toAuditedEquals(getRevisionElementAfterFunction.apply(rev))
						.equals(auditedEqualsMapper.toAuditedEquals(getRevisionElementBeforeFunction.apply(rev))))
				.toList();
	}
}
