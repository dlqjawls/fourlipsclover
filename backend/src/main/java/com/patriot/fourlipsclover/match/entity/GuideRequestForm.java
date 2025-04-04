package com.patriot.fourlipsclover.match.entity;

import com.patriot.fourlipsclover.group.entity.Group;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "guide_request_form")
public class GuideRequestForm {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "guide_request_form_id", nullable = false)
    private Integer guideRequestFormId;

    // 현지인 컨설팅이 끝나면 선택한 group에 plan으로 추가될 수 있도록 옵션 제공
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "group_id")
    private Group group; // 그룹 정보

    // 도보, 버스, 자동차, 기타
    @Column(name = "transportation", nullable = false)
    private String transportation;

    // 선호 음식 종류(한, 중, 일, 양식)
    @Column(name = "food_preference", nullable = false)
    private String foodPreference;
    // 선호하는 맛(맵,달게, 짭잘, 담백, 기타)
    @Column(name = "taste_preference", nullable = false)
    private String tastePreference;

    // 요청사항
    @Column(name = "requirements", nullable = false)
    private String requirements;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDate endDate;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @UpdateTimestamp
    private LocalDateTime updatedAt;

}
