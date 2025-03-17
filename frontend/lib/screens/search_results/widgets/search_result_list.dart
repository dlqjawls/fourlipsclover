// search_result_list.dart
import 'package:flutter/material.dart';

class SearchResultList extends StatelessWidget {
  final String query;
  final String? filter;

  const SearchResultList({
    Key? key,
    required this.query,
    this.filter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 (실제로는 API에서 가져올 것)
    final restaurants = [
      {
        "id": 1,
        "name": "부억간 수완지구",
        "rating": 4.6,
        "reviewCount": 12,
        "isOpen": true,
        "distance": "1.8km",
        "categories": ["파스타", "테라스"],
        "image": "https://via.placeholder.com/100",
        "rank": 71,
      },
      {
        "id": 2,
        "name": "어니스트식스티 수완점",
        "rating": 4.5,
        "reviewCount": 5,
        "isOpen": true,
        "distance": "2.1km",
        "categories": ["스테이크", "와인"],
        "image": "https://via.placeholder.com/100",
        "rank": 64,
      },
    ];

    return ListView.separated(
      itemCount: restaurants.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              Text(
                "${index + 1}. ${restaurant["name"]}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "${restaurant["rank"]}점",
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 2),
                  Text(
                    "${restaurant["rating"]} (${restaurant["reviewCount"]}명)",
                    style: TextStyle(color: Colors.black87),
                  ),
                  SizedBox(width: 8),
                  Text(
                  restaurant["isOpen"] == true ? "영업 중" : "영업 종료",
                  style: TextStyle(
                    color: restaurant["isOpen"] == true ? Colors.black54 : Colors.red,
                  ),
                ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                "${restaurant["distance"]} • ${(restaurant["categories"] as List).join(", ")}",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          trailing: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Container(
                color: Colors.grey[300],
                child: Center(
                  child: Text('이미지'),
                ),
              ),
            ),
          ),
          onTap: () {
            // 음식점 상세 페이지로 이동
          },
        );
      },
    );
  }
}