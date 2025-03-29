package com.patriot.fourlipsclover.match.entity;

import com.patriot.fourlipsclover.member.entity.Member;
import com.patriot.fourlipsclover.restaurant.entity.Region;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "`match`")
public class Match {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "match_id", nullable = false)
    private Integer matchId;

    // 매칭 요청자
    @Column(name = "member_id", nullable = false)
    private Long memberId;

    // 최소 1개, 최대 3개의 태그를 받아와야함
    // 태그 관계 매핑
    @OneToMany(mappedBy = "match")
    @Column(name = "matchTags")
    private List<MatchTag> matchTags;

    // 광역시
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "region_id", nullable = false)
    private Region region;

    // 현지인 가이드 ID
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "guide_id", nullable = false)
    private Member guide;

    // 가이드 신청서
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "guide_request_form_id", nullable = false)
    private GuideRequestForm guideRequestForm;

    // 현지인 승인대기, 승인, 거절(Pending, Confirmed, Rejected)
    @Column(name = "status", nullable = false)
    private ApprovalStatus status;

    // 결제번호(PaymentApproveResponse 에서 가져옴)
    @Column(name = "partner_order_id")
    private String partnerOrderId;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

}
