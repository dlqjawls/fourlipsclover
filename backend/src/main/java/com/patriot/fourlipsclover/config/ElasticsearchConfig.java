package com.patriot.fourlipsclover.config;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import co.elastic.clients.transport.ElasticsearchTransport;
import co.elastic.clients.transport.rest_client.RestClientTransport;
import javax.net.ssl.SSLContext;
import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.conn.ssl.NoopHostnameVerifier;
import org.apache.http.conn.ssl.TrustAllStrategy;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.ssl.SSLContexts;
import org.elasticsearch.client.RestClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ElasticsearchConfig {

	@Value("${elasticsearch.host:localhost}")
	private String host;

	@Value("${elasticsearch.port:9200}")
	private String port;

	@Value("${elasticsearch.scheme:https}")
	private String scheme;

	@Value("${elasticsearch.username:}")
	private String username;

	@Value("${elasticsearch.password:}")
	private String password;

	@Bean
	public ElasticsearchClient elasticsearchClient() {
		// 기본 인증 정보 설정
		final CredentialsProvider credentialsProvider = new BasicCredentialsProvider();
		credentialsProvider.setCredentials(
				AuthScope.ANY,
				new UsernamePasswordCredentials(username, password)
		);

		// SSL 설정 (자체 서명 인증서 허용)
		SSLContext sslContext;
		try {
			sslContext = SSLContexts.custom()
					.loadTrustMaterial(null, TrustAllStrategy.INSTANCE)
					.build();
		} catch (Exception e) {
			throw new RuntimeException("SSL 컨텍스트 생성 실패", e);
		}
		// RestClient 설정
		RestClient restClient = RestClient.builder(
						new HttpHost(host, Integer.parseInt(port), scheme))
				.setHttpClientConfigCallback(httpClientBuilder -> httpClientBuilder
						.setDefaultCredentialsProvider(credentialsProvider)
						.setSSLContext(sslContext)
						.setSSLHostnameVerifier(NoopHostnameVerifier.INSTANCE))
				.build();

		// ElasticsearchTransport 설정
		ElasticsearchTransport transport = new RestClientTransport(
				restClient,
				new JacksonJsonpMapper());

		return new ElasticsearchClient(transport);
	}
}
