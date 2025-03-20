package com.patriot.fourlipsclover.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

	@Bean
	public OpenAPI openAPI() {
		return new OpenAPI()
				.info(new Info()
						.title("FourLipsClover REST API")
						.description("FourLipsClover 어플리케이션의 API 문서")
						.version("v1.0.0"));
	}
}