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


INSERT INTO reviews (review_id, member_id,
                     restaurant_id,
                     content,
                     visited_at,
                     created_at,
                     updated_at,
                     deleted_at,
                     is_delete)
VALUES (1, 1, -- member_id (예시 값)
        1, -- restaurant_id (예시 값)
        '테스트컨텐츠',
        '2023-05-15 18:30:00', -- visited_at
        '2023-05-16 10:20:00', -- created_at
        NULL, -- updated_at (아직 업데이트되지 않음)
        NULL, -- deleted_at (아직 삭제되지 않음)
        FALSE -- is_delete
       );