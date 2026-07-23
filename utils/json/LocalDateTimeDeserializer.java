package com.bdl.epbs_fund_api.utils.json;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;

import lombok.NoArgsConstructor;

@NoArgsConstructor
public class LocalDateTimeDeserializer extends JsonDeserializer<LocalDateTime>{

	@Override
	public LocalDateTime deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
		try {
			return LocalDateTime.parse(p.getValueAsString(), DateTimeFormatter.ISO_LOCAL_DATE_TIME);	
		} catch (IOException e) {
			return LocalDate.parse(p.getValueAsString(),DateTimeFormatter.ofPattern("yyyy-MM-dd")).atStartOfDay();
		}
	}
}
