package com.patriot.fourlipsclover.restaurant.service;

import com.patriot.fourlipsclover.restaurant.dto.response.RestaurantRankingResponse;
import com.patriot.fourlipsclover.restaurant.repository.RestaurantJpaRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import weka.classifiers.trees.RandomForest;
import weka.core.*;

import java.io.*;
import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class RestaurantRankingService {
    private final RestaurantJpaRepository restaurantRepository;

    private RandomForest model;
    private boolean modelTrained = false;

    // 모델 파일 경로
    private final String MODEL_PATH = "model/random_forest_model.ser";

    @PostConstruct
    public void init() {
        // 서버 시작 시 모델 초기화 또는 학습
        try {
            loadOrTrainModel();
        } catch (Exception e) {
            log.error("모델 초기화 실패", e);
        }
    }

    private void loadOrTrainModel() {
        File modelFile = new File(MODEL_PATH);
        if (modelFile.exists()) {
            try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(modelFile))) {
                model = (RandomForest) ois.readObject();
                modelTrained = true;
                log.info("저장된 랜덤 포레스트 모델을 로드했습니다.");
            } catch (Exception e) {
                log.error("모델 로드 실패", e);
            }
        } else {
            // 데이터가 충분하면 모델 학습
            try {
                trainModel();
            } catch (Exception e) {
                log.error("모델 학습 실패", e);
            }
        }
    }

    @Transactional(readOnly = true)
    public void trainModel() throws Exception {
        log.info("랜덤 포레스트 모델 학습 시작...");
        List<RestaurantRankingResponse> data = getRestaurantRankingData();

        if (data.size() < 10) {
            log.warn("학습 데이터가 부족합니다 ({}개). 최소 10개의 데이터가 필요합니다.", data.size());
            return;
        }

        // 초기 점수 계산 (학습용)
        data.forEach(dto -> dto.setScore(calculateInitialScore(dto)));

        // Weka 인스턴스 생성
        Instances trainingData = createTrainingInstances(data);

        // 모델 설정 및 학습
        model = new RandomForest();
        model.setNumIterations(100);
        model.setMaxDepth(10);
        model.setSeed(42);
        model.buildClassifier(trainingData);

        // 모델 저장
        File directory = new File(new File(MODEL_PATH).getParent());
        if (!directory.exists()) {
            directory.mkdirs();
        }

        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(MODEL_PATH))) {
            oos.writeObject(model);
        }

        modelTrained = true;
        log.info("랜덤 포레스트 모델 학습 완료");
    }

    @Transactional(readOnly = true)
    public List<RestaurantRankingResponse> calculateRankings() {
        List<RestaurantRankingResponse> rankingData = getRestaurantRankingData();

        if (modelTrained && model != null) {
            try {
                // 학습된 모델로 점수 예측
                predictScores(rankingData);
            } catch (Exception e) {
                log.error("모델 예측 실패, 규칙 기반 점수 계산으로 전환", e);
                calculateScoresByRules(rankingData);
            }
        } else {
            // 규칙 기반 점수 계산
            calculateScoresByRules(rankingData);
        }

        // 점수에 따라 정렬
        rankingData.sort(Comparator.comparing(RestaurantRankingResponse::getScore).reversed());

        // 순위 할당
        for (int i = 0; i < rankingData.size(); i++) {
            rankingData.get(i).setRank(i + 1);
        }

        return rankingData;
    }

    @Transactional(readOnly = true)
    public List<RestaurantRankingResponse> calculateRankingsByCategory(String category) {
        List<RestaurantRankingResponse> rankingData = getRestaurantRankingDataByCategory(category);

        if (modelTrained && model != null) {
            try {
                predictScores(rankingData);
            } catch (Exception e) {
                log.error("모델 예측 실패, 규칙 기반 점수 계산으로 전환", e);
                calculateScoresByRules(rankingData);
            }
        } else {
            calculateScoresByRules(rankingData);
        }

        rankingData.sort(Comparator.comparing(RestaurantRankingResponse::getScore).reversed());

        for (int i = 0; i < rankingData.size(); i++) {
            rankingData.get(i).setRank(i + 1);
        }

        return rankingData;
    }

    @Transactional(readOnly = true)
    public List<RestaurantRankingResponse> calculateRankingsNearby(
            Double latitude, Double longitude, Integer radius) {
        List<RestaurantRankingResponse> rankingData = getRestaurantRankingDataNearby(
                latitude, longitude, radius);

        if (modelTrained && model != null) {
            try {
                predictScores(rankingData);
            } catch (Exception e) {
                log.error("모델 예측 실패, 규칙 기반 점수 계산으로 전환", e);
                calculateScoresByRules(rankingData);
            }
        } else {
            calculateScoresByRules(rankingData);
        }

        rankingData.sort(Comparator.comparing(RestaurantRankingResponse::getScore).reversed());

        for (int i = 0; i < rankingData.size(); i++) {
            rankingData.get(i).setRank(i + 1);
        }

        return rankingData;
    }

    @Transactional(readOnly = true)
    public RestaurantRankingResponse getRestaurantRanking(Integer restaurantId) {
        // 전체 랭킹 계산
        List<RestaurantRankingResponse> allRankings = calculateRankings();

        // 특정 식당 찾기
        return allRankings.stream()
                .filter(r -> r.getRestaurantId().equals(restaurantId))
                .findFirst()
                .orElse(null);
    }

    private void predictScores(List<RestaurantRankingResponse> data) throws Exception {
        if (data.isEmpty()) {
            return;
        }

        // Weka 인스턴스 생성
        Instances testInstances = createTestInstances(data);

        // 예측
        for (int i = 0; i < data.size(); i++) {
            double score = model.classifyInstance(testInstances.instance(i));
            data.get(i).setScore(score);
        }
    }

    @Transactional(readOnly = true)
    public List<RestaurantRankingResponse> calculateRankingsByMainCategory(Integer categoryId) {
        List<RestaurantRankingResponse> rankingData = getRestaurantRankingDataByMainCategory(categoryId);

        if (modelTrained && model != null) {
            try {
                predictScores(rankingData);
            } catch (Exception e) {
                log.error("모델 예측 실패, 규칙 기반 점수 계산으로 전환", e);
                calculateScoresByRules(rankingData);
            }
        } else {
            calculateScoresByRules(rankingData);
        }

        rankingData.sort(Comparator.comparing(RestaurantRankingResponse::getScore).reversed());

        for (int i = 0; i < rankingData.size(); i++) {
            rankingData.get(i).setRank(i + 1);
        }

        return rankingData;
    }

    private List<RestaurantRankingResponse> getRestaurantRankingDataByMainCategory(Integer categoryId) {
        List<Map<String, Object>> rawData = restaurantRepository.getRestaurantRankingDataByMainCategory(categoryId);
        return convertToRankingResponse(rawData);
    }

    private void calculateScoresByRules(List<RestaurantRankingResponse> data) {
        for (RestaurantRankingResponse dto : data) {
            dto.setScore(calculateInitialScore(dto));
        }
    }

    private double calculateInitialScore(RestaurantRankingResponse dto) {
        // 신뢰 점수 가중치
        double trustWeight = dto.getAvgUserTrustScore() != null ?
                dto.getAvgUserTrustScore() / 5.0 : 0.2;

        // 긍정/부정 리뷰 가중치
        double positiveWeight = dto.getWeightedPositive() != null ? dto.getWeightedPositive() * 1.0 : 0.0;
        double negativeWeight = dto.getWeightedNegative() != null ? dto.getWeightedNegative() * 0.8 : 0.0;

        // 방문 수 가중치 (로그 스케일)
        double visitWeight = dto.getVisitCount() != null ?
                Math.log1p(dto.getVisitCount()) * 0.5 : 0.0;

        // 리뷰 수 가중치 (많을수록 신뢰도 상승)
        double reviewCountFactor = dto.getReviewCount() != null ?
                Math.min(1.0, dto.getReviewCount() / 10.0) : 0.0;

        // 최종 점수 계산 (긍정-부정) * 리뷰 수 가중치 * 신뢰 점수 + 방문 가중치
        return (positiveWeight - negativeWeight) * reviewCountFactor *
                (trustWeight + 0.2) + visitWeight;
    }

    private Instances createTrainingInstances(List<RestaurantRankingResponse> data) throws Exception {
        // Weka 속성 정의
        ArrayList<Attribute> attributes = new ArrayList<>();
        attributes.add(new Attribute("visitCount"));
        attributes.add(new Attribute("weightedPositive"));
        attributes.add(new Attribute("weightedNegative"));
        attributes.add(new Attribute("avgUserTrustScore"));
        attributes.add(new Attribute("reviewCount"));
        attributes.add(new Attribute("avgPerPersonAmount"));
        attributes.add(new Attribute("score"));

        // 인스턴스 생성
        Instances instances = new Instances("RestaurantRanking", attributes, data.size());
        instances.setClassIndex(attributes.size() - 1);

        // 데이터 추가
        for (RestaurantRankingResponse dto : data) {
            Instance inst = new DenseInstance(attributes.size());
            inst.setValue(0, nullSafeDouble(dto.getVisitCount()));
            inst.setValue(1, nullSafeDouble(dto.getWeightedPositive()));
            inst.setValue(2, nullSafeDouble(dto.getWeightedNegative()));
            inst.setValue(3, nullSafeDouble(dto.getAvgUserTrustScore()));
            inst.setValue(4, nullSafeDouble(dto.getReviewCount()));
            inst.setValue(5, nullSafeDouble(dto.getAvgPerPersonAmount()));
            inst.setValue(6, nullSafeDouble(dto.getScore()));

            instances.add(inst);
        }

        return instances;
    }

    private Instances createTestInstances(List<RestaurantRankingResponse> data) throws Exception {
        // Weka 속성 정의 (학습 데이터와 동일한 구조)
        ArrayList<Attribute> attributes = new ArrayList<>();
        attributes.add(new Attribute("visitCount"));
        attributes.add(new Attribute("weightedPositive"));
        attributes.add(new Attribute("weightedNegative"));
        attributes.add(new Attribute("avgUserTrustScore"));
        attributes.add(new Attribute("reviewCount"));
        attributes.add(new Attribute("avgPerPersonAmount"));
        attributes.add(new Attribute("score"));

        // 인스턴스 생성
        Instances instances = new Instances("RestaurantRanking", attributes, data.size());
        instances.setClassIndex(attributes.size() - 1);

        // 데이터 추가
        for (RestaurantRankingResponse dto : data) {
            Instance inst = new DenseInstance(attributes.size());
            inst.setValue(0, nullSafeDouble(dto.getVisitCount()));
            inst.setValue(1, nullSafeDouble(dto.getWeightedPositive()));
            inst.setValue(2, nullSafeDouble(dto.getWeightedNegative()));
            inst.setValue(3, nullSafeDouble(dto.getAvgUserTrustScore()));
            inst.setValue(4, nullSafeDouble(dto.getReviewCount()));
            inst.setValue(5, nullSafeDouble(dto.getAvgPerPersonAmount()));

            // 테스트 데이터는 대상 변수 값을 임시로 설정 (예측시에는 무시됨)
            inst.setValue(6, 0);

            instances.add(inst);
        }

        return instances;
    }

    // null 값을 안전하게 처리하는 유틸리티 메서드
    private double nullSafeDouble(Number value) {
        return value != null ? value.doubleValue() : 0.0;
    }

    private List<RestaurantRankingResponse> getRestaurantRankingData() {
        List<Map<String, Object>> rawData = restaurantRepository.getRestaurantRankingData();
        return convertToRankingResponse(rawData);
    }

    private List<RestaurantRankingResponse> getRestaurantRankingDataByCategory(String category) {
        List<Map<String, Object>> rawData = restaurantRepository.getRestaurantRankingDataByCategory(category);
        return convertToRankingResponse(rawData);
    }

    private List<RestaurantRankingResponse> getRestaurantRankingDataNearby(
            Double latitude, Double longitude, Integer radius) {
        List<Map<String, Object>> rawData = restaurantRepository.getRestaurantRankingDataNearby(
                latitude, longitude, radius);
        return convertToRankingResponse(rawData);
    }

    private List<RestaurantRankingResponse> convertToRankingResponse(List<Map<String, Object>> rawData) {
        return rawData.stream()
                .map(row -> {
                    RestaurantRankingResponse response = new RestaurantRankingResponse();
                    response.setRestaurantId(convertToInteger(row.get("restaurantId")));
                    response.setPlaceName((String) row.get("placeName"));
                    response.setCategoryName((String) row.get("categoryName"));
                    response.setMainCategoryName((String) row.get("mainCategoryName"));
                    response.setVisitCount(convertToInteger(row.get("visitCount")));
                    response.setWeightedPositive(convertToDouble(row.get("weightedPositive")));
                    response.setWeightedNegative(convertToDouble(row.get("weightedNegative")));
                    response.setAvgUserTrustScore(convertToDouble(row.get("avgUserTrustScore")));
                    response.setReviewCount(convertToInteger(row.get("reviewCount")));
                    response.setAvgPerPersonAmount(convertToDouble(row.get("avgPerPersonAmount")));
                    return response;
                })
                .collect(Collectors.toList());
    }

    // 데이터 타입 변환 유틸리티 메서드들
    private Integer convertToInteger(Object value) {
        if (value == null) return 0;
        if (value instanceof Integer) return (Integer) value;
        if (value instanceof Long) return ((Long) value).intValue();
        if (value instanceof BigDecimal) return ((BigDecimal) value).intValue();
        return 0;
    }

    private Double convertToDouble(Object value) {
        if (value == null) return 0.0;
        if (value instanceof Double) return (Double) value;
        if (value instanceof BigDecimal) return ((BigDecimal) value).doubleValue();
        if (value instanceof Integer) return ((Integer) value).doubleValue();
        if (value instanceof Long) return ((Long) value).doubleValue();
        if (value instanceof Float) return ((Float) value).doubleValue();
        return 0.0;
    }
}