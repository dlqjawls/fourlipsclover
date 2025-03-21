INSERT INTO member (member_id, email, nickname, profile_url, created_at, updated_at, is_withdrawal,
                    trust_score)
VALUES (1, 'test1@example.com', '사용자1', 'http://example.com/profile1.jpg', CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP, false, 0.0);

INSERT INTO member (member_id, email, nickname, profile_url, created_at, updated_at, is_withdrawal,
                    trust_score)
VALUES (2, 'test2@example.com', '사용자2', 'http://example.com/profile1.jpg', CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP, false, 0.0);

INSERT INTO local_region (local_region_id, region_name)
VALUES ('2920000000', '광산구');
INSERT INTO local_region (local_region_id, region_name)
VALUES ('1165000000', '서초구');
INSERT INTO local_region (local_region_id, region_name)
VALUES ('1168000000', '강남구');