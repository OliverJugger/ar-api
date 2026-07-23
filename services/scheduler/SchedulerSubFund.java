package com.bdl.epbs_fund_api.services.scheduler;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.authentication.UserContext;
import com.bdl.epbs_fund_api.services.impl.v2.SubFundServiceV2;

import lombok.extern.log4j.Log4j2;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;

@Log4j2
@Component
public class SchedulerSubFund {

	// Default value will be false
	@Value("${epbs.scheduler.audit.enable:false}")
	private boolean isEnabledScheduler;
	
	@Value("${epbs.scheduler.audit.execution.date}")
	@DateTimeFormat(pattern = "dd-MM-yyyy")
	private LocalDate executionDate;

	@Value("${epbs.scheduler.audit.user}")
	private String tecUser;

	@Autowired
	private SubFundServiceV2 subFundServiceV2;

	@Scheduled(cron = "${epbs.scheduler.audit.cron}")
    @SchedulerLock(name = "RoutineSynchroAudit", lockAtLeastFor = "10m", lockAtMostFor = "10m")
	public void executeSynchroAuditJob() {
		log.info("Scheduler.executeSynchroAuditJob start");
		if (isEnabledScheduler && LocalDateTime.now().toLocalDate().equals(executionDate)) {
			log.info("Scheduler.scheduledJob is enabled, processing...");

			UserContext.setCurrentUser(Map.of("sub", tecUser));
			
			subFundServiceV2.synchronizeWithLastRevision();
		}
	}
	
}
