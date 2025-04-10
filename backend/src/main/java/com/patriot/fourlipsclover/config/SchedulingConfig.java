package com.patriot.fourlipsclover.config;

import com.patriot.fourlipsclover.locals.service.LocalCertificationService;
import com.patriot.fourlipsclover.member.service.MemberService;
import com.patriot.fourlipsclover.tag.service.TagService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

@Slf4j
@Configuration
@EnableScheduling
@RequiredArgsConstructor
public class SchedulingConfig {

	private final LocalCertificationService localCertificationService;
	private final TagService tagService;
	private final MemberService memberService;

	/**
	 * 3개월마다 현지인 등급을 업데이트합니다. cron 표현식: 초 분 시 일 월 요일 "0 0 0 1 1,4,7,10 *": 1월, 4월, 7월, 10월 1일 자정에
	 * 실행
	 */
	@Scheduled(cron = "0 0 0 1 1,4,7,10 *")
	public void updateLocalGrades() {
		log.info("현지인 등급 업데이트 작업 시작");
		localCertificationService.updateLocalGrades();
		tagService.uploadAllLocalCertificationsToElasticsearch();

		log.info("현지인 등급 업데이트 작업 완료");
	}

	@Scheduled(cron = "0 0 0 1 1,4,7,10 *")
	public void uploadRestaurantDocument() {
		tagService.uploadRestaurantDocument();
		memberService.updateTrustScore();
		
	}
}
