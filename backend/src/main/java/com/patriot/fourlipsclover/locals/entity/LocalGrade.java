package com.patriot.fourlipsclover.locals.entity;

import lombok.Getter;

@Getter
public enum LocalGrade {
	ONE("ONE"), TWO("TWO"), THREE("THREE"), FOUR("FOUR");
	private final String value;

	LocalGrade(String value) {
		this.value = value;
	}
}
