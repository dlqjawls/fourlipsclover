package com.patriot.fourlipsclover.loadtest;

import static org.junit.jupiter.api.Assertions.assertNotNull;

import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantResponse;
import com.patriot.fourlipsclover.restaurant.entity.Restaurant;
import java.awt.Color;
import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.LongSummaryStatistics;
import java.util.Random;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtils;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYBarRenderer;
import org.jfree.data.category.DefaultCategoryDataset;
import org.jfree.data.statistics.HistogramDataset;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class LocationSearchPerformanceTest {

	private static final double TEST_LAT = 37.498095;
	private static final double TEST_LON = 127.027610;
	private static final int TEST_RADIUS = 1000; // 1km

	private static final String CHART_OUTPUT_DIR = "performance-test-results";
	@Autowired
	private SearchPerformanceTestService testService;

	@Test
	public void compareSearchPerformance() {
		// 단일 검색 비교
		List<Restaurant> jpaResult = testService.searchByJpa(TEST_LAT, TEST_LON,
				TEST_RADIUS);
		List<RestaurantResponse> esResult = testService.searchByElasticsearch(TEST_LAT, TEST_LON,
				TEST_RADIUS);

		assertNotNull(jpaResult);
		assertNotNull(esResult);
	}

	@Test
	@DisplayName("동시 사용자 시뮬레이션")
	public void loadTest() throws Exception {
		int threadCount = 50; // 동시 사용자 수
		int requestsPerThread = 10; // 각 사용자당 요청 수

		// 성능 측정 결과 저장
		List<Long> jpaTimes = Collections.synchronizedList(new ArrayList<>());
		List<Long> esTimes = Collections.synchronizedList(new ArrayList<>());

		// 테스트 좌표값 배열 (다양한 위치 테스트)
		double[][] testLocations = {
				{35.159720, 126.793116}, // 광주 광산구 송정동
				{35.138548, 126.807302}, // 광주 광산구 우산동
				{35.190104, 126.822879}, // 광주 광산구 신가동
				{35.179129, 126.834743}, // 광주 광산구 산월동
				{35.164664, 126.848798}  // 광주 광산구 첨단동
		};

		ExecutorService executor = Executors.newFixedThreadPool(threadCount);
		CountDownLatch latch = new CountDownLatch(threadCount * requestsPerThread * 2); // JPA + ES

		// 시작 시간 측정
		long startTime = System.currentTimeMillis();

		// 부하 테스트 실행
		for (int i = 0; i < threadCount; i++) {
			final int threadIndex = i;

			executor.submit(() -> {
				Random random = new Random();

				for (int j = 0; j < requestsPerThread; j++) {
					// 랜덤 위치 선택
					int locationIndex = random.nextInt(testLocations.length);
					double lat = testLocations[locationIndex][0];
					double lon = testLocations[locationIndex][1];
					int radius = 500 + random.nextInt(1500); // 500m~2000m

					// JPA 테스트
					try {
						long start = System.currentTimeMillis();
						testService.searchByJpa(lat, lon, radius);
						long time = System.currentTimeMillis() - start;
						jpaTimes.add(time);
					} finally {
						latch.countDown();
					}

					// Elasticsearch 테스트
					try {
						long start = System.currentTimeMillis();
						testService.searchByElasticsearch(lat, lon, radius);
						long time = System.currentTimeMillis() - start;
						esTimes.add(time);
					} finally {
						latch.countDown();
					}
				}
			});
		}

		// 모든 테스트 완료 대기
		latch.await(5, TimeUnit.MINUTES);
		long totalTime = System.currentTimeMillis() - startTime;

		// 결과 분석
		printResults(jpaTimes, esTimes, totalTime, threadCount * requestsPerThread);
	}

	private void createAndSaveCharts(List<Long> jpaTimes, List<Long> esTimes,
			LongSummaryStatistics jpaStats, LongSummaryStatistics esStats, int totalRequests) {
		try {
			// 디렉토리 생성
			File outputDir = new File(CHART_OUTPUT_DIR);
			if (!outputDir.exists()) {
				outputDir.mkdirs();
			}

			// 타임스탬프 생성
			String timestamp = LocalDateTime.now()
					.format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss"));

			// 1. 응답 시간 비교 막대 그래프
			createResponseTimeBarChart(jpaStats, esStats, timestamp);

			// 2. TPS 비교 막대 그래프
			createTpsBarChart(jpaStats, esStats, totalRequests, timestamp);

			// 3. 응답 시간 분포 히스토그램
			createResponseTimeHistogram(jpaTimes, esTimes, timestamp);

			System.out.println("\n차트가 " + CHART_OUTPUT_DIR + " 디렉토리에 저장되었습니다.");
		} catch (Exception e) {
			System.err.println("차트 생성 중 오류 발생: " + e.getMessage());
			e.printStackTrace();
		}
	}

	private void printResults(List<Long> jpaTimes, List<Long> esTimes, long totalTime,
			int totalRequests) {
		// JPA 통계
		LongSummaryStatistics jpaStats = jpaTimes.stream().mapToLong(Long::valueOf)
				.summaryStatistics();

		// Elasticsearch 통계
		LongSummaryStatistics esStats = esTimes.stream().mapToLong(Long::valueOf)
				.summaryStatistics();

		System.out.println("\n===== 성능 테스트 결과 =====");
		System.out.println("총 테스트 시간: " + totalTime + "ms");
		System.out.println("총 요청 수: " + totalRequests + "개 (각 방식당)");

		System.out.println("\n----- JPA 검색 성능 -----");
		System.out.println("평균 응답시간: " + jpaStats.getAverage() + "ms");
		System.out.println("최소 응답시간: " + jpaStats.getMin() + "ms");
		System.out.println("최대 응답시간: " + jpaStats.getMax() + "ms");
		System.out.println("TPS: " + (totalRequests * 1000.0 / jpaStats.getSum()));

		System.out.println("\n----- Elasticsearch 검색 성능 -----");
		System.out.println("평균 응답시간: " + esStats.getAverage() + "ms");
		System.out.println("최소 응답시간: " + esStats.getMin() + "ms");
		System.out.println("최대 응답시간: " + esStats.getMax() + "ms");
		System.out.println("TPS: " + (totalRequests * 1000.0 / esStats.getSum()));

		System.out.println("\n----- 성능 비교 -----");
		System.out.println(
				"평균 응답시간 차이: " + (jpaStats.getAverage() / esStats.getAverage()) + "배 (JPA/ES)");
		System.out.println("최대 응답시간 차이: " + (jpaStats.getMax() / esStats.getMax()) + "배 (JPA/ES)");
		System.out.println("TPS 차이: " + (esStats.getSum() / jpaStats.getSum()) + "배 (ES/JPA)");

		// 결과 시각화
		createAndSaveCharts(jpaTimes, esTimes, jpaStats, esStats, totalRequests);
	}

	private void createResponseTimeBarChart(LongSummaryStatistics jpaStats,
			LongSummaryStatistics esStats,
			String timestamp) throws IOException {
		DefaultCategoryDataset dataset = new DefaultCategoryDataset();

		dataset.addValue(jpaStats.getAverage(), "JPA", "Average Response Time");
		dataset.addValue(esStats.getAverage(), "Elasticsearch", "Average Response Time");

		dataset.addValue(jpaStats.getMin(), "JPA", "Minimum Response Time");
		dataset.addValue(esStats.getMin(), "Elasticsearch", "Minimum Response Time");

		dataset.addValue(jpaStats.getMax(), "JPA", "Maximum Response Time");
		dataset.addValue(esStats.getMax(), "Elasticsearch", "Maximum Response Time");

		JFreeChart chart = ChartFactory.createBarChart(
				"JPA vs Elasticsearch Response Time Comparison",
				"Metrics",
				"Response Time (ms)",
				dataset,
				PlotOrientation.VERTICAL,
				true,
				true,
				false
		);

		CategoryPlot plot = chart.getCategoryPlot();

		// 차트 배경 및 그리드 스타일 개선
		plot.setBackgroundPaint(new Color(250, 250, 250));
		plot.setDomainGridlinePaint(new Color(220, 220, 220));
		plot.setRangeGridlinePaint(new Color(220, 220, 220));
		plot.setOutlinePaint(new Color(100, 100, 100));

		// 바 색상 설정 (반투명 효과 적용)
		plot.getRenderer().setSeriesPaint(0, new Color(65, 105, 225, 220)); // JPA(로열 블루)
		plot.getRenderer().setSeriesPaint(1, new Color(50, 205, 50, 220));  // ES(라임 그린)

		// 범례 스타일 개선
		chart.getLegend().setFrame(org.jfree.chart.block.BlockBorder.NONE);
		chart.getLegend().setBackgroundPaint(new Color(250, 250, 250));

		// 제목 폰트 설정
		chart.getTitle().setFont(new java.awt.Font("SansSerif", java.awt.Font.BOLD, 18));

		ChartUtils.saveChartAsPNG(
				new File(CHART_OUTPUT_DIR + "/response-time-comparison-" + timestamp + ".png"),
				chart,
				800,
				600,
				null,
				true,  // 고품질 렌더링 활성화
				9      // 압축 레벨 (0-9)
		);
	}

	private void createTpsBarChart(LongSummaryStatistics jpaStats, LongSummaryStatistics esStats,
			int totalRequests, String timestamp) throws IOException {
		DefaultCategoryDataset dataset = new DefaultCategoryDataset();

		double jpaTps = totalRequests * 1000.0 / jpaStats.getSum();
		double esTps = totalRequests * 1000.0 / esStats.getSum();

		dataset.addValue(jpaTps, "TPS", "JPA");
		dataset.addValue(esTps, "TPS", "Elasticsearch");

		JFreeChart chart = ChartFactory.createBarChart(
				"JPA vs Elasticsearch TPS Comparison",
				"Search Method",
				"TPS (Transactions Per Second)",
				dataset,
				PlotOrientation.VERTICAL,
				true,
				true,
				false
		);

		CategoryPlot plot = chart.getCategoryPlot();

		// 차트 배경 및 그리드 스타일 개선
		plot.setBackgroundPaint(new Color(250, 250, 250));
		plot.setDomainGridlinePaint(new Color(220, 220, 220));
		plot.setRangeGridlinePaint(new Color(220, 220, 220));
		plot.setOutlinePaint(new Color(100, 100, 100));

		// 바 색상 설정
		plot.getRenderer().setSeriesPaint(0, new Color(65, 105, 225, 220)); // JPA(로열 블루)
		plot.getRenderer().setSeriesPaint(1, new Color(50, 205, 50, 220));  // ES(라임 그린)

		// 범례 스타일 개선
		chart.getLegend().setFrame(org.jfree.chart.block.BlockBorder.NONE);
		chart.getLegend().setBackgroundPaint(new Color(250, 250, 250));

		// 제목 폰트 설정
		chart.getTitle().setFont(new java.awt.Font("SansSerif", java.awt.Font.BOLD, 18));

		ChartUtils.saveChartAsPNG(
				new File(CHART_OUTPUT_DIR + "/tps-comparison-" + timestamp + ".png"),
				chart,
				800,
				600,
				null,
				true,  // 고품질 렌더링 활성화
				9      // 압축 레벨 (0-9)
		);
	}

	private void createResponseTimeHistogram(List<Long> jpaTimes, List<Long> esTimes,
			String timestamp)
			throws IOException {
		HistogramDataset dataset = new HistogramDataset();

		// 배열로 변환
		double[] jpaData = jpaTimes.stream().mapToDouble(Long::doubleValue).toArray();
		double[] esData = esTimes.stream().mapToDouble(Long::doubleValue).toArray();

		// 더 많은 구간으로 나누어 상세한 분포 표현
		dataset.addSeries("JPA", jpaData, 30);
		dataset.addSeries("Elasticsearch", esData, 30);

		JFreeChart chart = ChartFactory.createHistogram(
				"Response Time Distribution Comparison",
				"Response Time (ms)",
				"Frequency",
				dataset,
				PlotOrientation.VERTICAL,
				true,
				true,
				false
		);

		XYPlot plot = chart.getXYPlot();

		// 차트 배경 및 그리드 스타일 개선
		plot.setBackgroundPaint(new Color(250, 250, 250));
		plot.setDomainGridlinePaint(new Color(220, 220, 220));
		plot.setRangeGridlinePaint(new Color(220, 220, 220));
		plot.setOutlinePaint(new Color(100, 100, 100));

		// 렌더러 스타일 개선
		XYBarRenderer renderer = (XYBarRenderer) plot.getRenderer();
		renderer.setSeriesPaint(0, new Color(65, 105, 225, 200)); // 로열 블루 (투명도 적용)
		renderer.setSeriesPaint(1, new Color(50, 205, 50, 200));  // 라임 그린 (투명도 적용)
		renderer.setBarPainter(new org.jfree.chart.renderer.xy.StandardXYBarPainter());
		renderer.setShadowVisible(false);
		renderer.setDrawBarOutline(true);
		renderer.setSeriesOutlinePaint(0, new Color(25, 25, 112));
		renderer.setSeriesOutlinePaint(1, new Color(0, 100, 0));
		renderer.setSeriesOutlineStroke(0, new java.awt.BasicStroke(1.0f));
		renderer.setSeriesOutlineStroke(1, new java.awt.BasicStroke(1.0f));

		// 범례 스타일 개선
		chart.getLegend().setFrame(org.jfree.chart.block.BlockBorder.NONE);
		chart.getLegend().setBackgroundPaint(new Color(250, 250, 250));

		// 제목 폰트 설정
		chart.getTitle().setFont(new java.awt.Font("SansSerif", java.awt.Font.BOLD, 18));

		ChartUtils.saveChartAsPNG(
				new File(CHART_OUTPUT_DIR + "/response-time-histogram-" + timestamp + ".png"),
				chart,
				800,
				600,
				null,
				true,  // 고품질 렌더링 활성화
				9      // 압축 레벨 (0-9)
		);
	}
}