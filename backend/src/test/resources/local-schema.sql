DROP TABLE IF EXISTS review_like;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS restaurant;
DROP TABLE IF EXISTS local_certification;
DROP TABLE IF EXISTS local_region;
DROP TABLE IF EXISTS member;

CREATE TABLE member
(
    member_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    email         VARCHAR(255),
    nickname      VARCHAR(255),
    profile_url   VARCHAR(255),
    created_at    TIMESTAMP,
    updated_at    TIMESTAMP,
    is_withdrawal BOOLEAN DEFAULT FALSE,
    withdrawal_at TIMESTAMP,
    trust_score   DOUBLE  DEFAULT 0.0
);

CREATE TABLE local_region
(
    local_region_id VARCHAR(255) PRIMARY KEY,
    region_name     VARCHAR(255)
);

CREATE TABLE local_certification
(
    local_certification_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_id              BIGINT,
    local_region_id        VARCHAR(255),
    certificated           BOOLEAN DEFAULT FALSE,
    certificated_at        TIMESTAMP,
    expiry_at              TIMESTAMP,
    local_grade            VARCHAR(50) NOT NULL,
    FOREIGN KEY (member_id) REFERENCES member (member_id),
    FOREIGN KEY (local_region_id) REFERENCES local_region (local_region_id)
);