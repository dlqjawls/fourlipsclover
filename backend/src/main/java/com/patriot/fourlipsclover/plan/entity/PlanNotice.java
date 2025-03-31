package com.patriot.fourlipsclover.plan.entity;

import com.patriot.fourlipsclover.member.entity.Member;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "plan_notice")
public class PlanNotice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "plan_notice_id", nullable = false)
    private Integer planNoticeId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "plan_id", nullable = false)
    private Plan plan;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "creator_id", nullable = false)
    private Member creator;

    @Column(name = "is_important", nullable = false)
    private boolean isImportant;

    @Enumerated(EnumType.STRING)
    @Column(name = "color", nullable = false)
    private PlanNoticeColor color;

    @Column(name = "content", length = 30, nullable = false)
    private String content;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

}
