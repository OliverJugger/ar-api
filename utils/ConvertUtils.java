package com.bdl.epbs_fund_api.utils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

public class ConvertUtils {

	public static LocalDateTime asLocalDateTime(LocalDate date) {
		return LocalDateTime.of(date, LocalTime.MIN);
	}
	
	private ConvertUtils() {}
	
}
