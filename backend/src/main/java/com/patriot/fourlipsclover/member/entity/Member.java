package com.patriot.fourlipsclover.member.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "member")
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int memberId;

    @Column(nullable = false)
    private String email;

    @Column(nullable = false)
    private String nickname;

    private String profileUrl;

    @Column(name = "created_at", insertable = false, updatable = false,
            columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
    private LocalDateTime createdAt;

    @Column(name = "updated_at", insertable = false,
            columnDefinition = "TIMESTAMP NULL DEFAULT NULL")
    private LocalDateTime updatedAt;

    @Column(name = "withdrawal_at", insertable = false,
            columnDefinition = "TIMESTAMP NULL DEFAULT NULL")
    private LocalDateTime withdrawalAt;

    @Column(name = "is_withdrawal", insertable = false,
            columnDefinition = "BOOLEAN DEFAULT FALSE")
    private Boolean isWithdrawal;

    @Column(name = "trust_score", insertable = false,
            columnDefinition = "FLOAT DEFAULT 0")
    private float trustScore;
}
