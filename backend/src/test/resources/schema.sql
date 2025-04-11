DROP TABLE IF EXISTS review_image;
DROP TABLE IF EXISTS review_like;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS restaurant;

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

CREATE TABLE restaurant
(
    restaurant_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    address_name      VARCHAR(255),
    category          VARCHAR(255),
    category_name     VARCHAR(255),
    kakao_place_id    VARCHAR(255),
    phone             VARCHAR(255),
    place_name        VARCHAR(255),
    place_url         VARCHAR(255),
    road_address_name VARCHAR(255),
    x                 DOUBLE,
    y                 DOUBLE
);

CREATE TABLE reviews
(
    review_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    content       TEXT,
    created_at    TIMESTAMP,
    updated_at    TIMESTAMP,
    deleted_at    TIMESTAMP,
    is_delete     BOOLEAN DEFAULT FALSE,
    member_id     BIGINT,
    restaurant_id VARCHAR(255),
    visited_at    TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES member (member_id)
);

CREATE TABLE review_like
(
    review_id   INT         NOT NULL,
    member_id   INT         NOT NULL,
    like_status VARCHAR(10) NOT NULL,
    PRIMARY KEY (review_id, member_id),
    FOREIGN KEY (review_id) REFERENCES reviews (review_id),
    FOREIGN KEY (member_id) REFERENCES member (member_id)
);

CREATE TABLE review_image
(
    review_image_id INT AUTO_INCREMENT PRIMARY KEY,
    review_id       INT NOT NULL,
    image_url       VARCHAR(255),
    created_at      TIMESTAMP,
    FOREIGN KEY (review_id) REFERENCES reviews (review_id)
);