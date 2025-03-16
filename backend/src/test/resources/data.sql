INSERT INTO member (member_id, email, nickname, profile_url, created_at, updated_at, is_withdrawal,
                    trust_score)
VALUES (1, 'test1@example.com', '사용자1', 'http://example.com/profile1.jpg', CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP, false, 0.0);


INSERT INTO restaurant (restaurant_id, address_name, category, category_name, kakao_place_id, phone,
                        place_name, place_url, road_address_name, x, y)
VALUES (1, '광주 광산구 수완동 1386', '음식점 > 한식 > 육류,고기', null, '2114253032', '062-962-9296', '초돈',
        'http://place.map.kakao.com/2114253032', '광주 광산구 수완로74번길 30-6', 126.830452421678,
        35.1912340501076);
INSERT INTO restaurant (restaurant_id, address_name, category, category_name, kakao_place_id, phone,
                        place_name, place_url, road_address_name, x, y)
VALUES (2, '광주 광산구 장덕동 1457', '음식점 > 한식', null, '26792051', '062-943-9233', '황솔촌 수완점',
        'http://place.map.kakao.com/26792051', '광주 광산구 장신로19번안길 23', 126.813103709848,
        35.1914320553405);


