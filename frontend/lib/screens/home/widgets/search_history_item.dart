import 'package:flutter/material.dart';
import '../../../../models/search_history.dart';

class SearchHistoryItem extends StatelessWidget {
  final SearchHistory searchHistory;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const SearchHistoryItem({
    Key? key,
    required this.searchHistory,
    required this.onTap,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.search, color: Colors.grey),
      title: Text(searchHistory.query),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            searchHistory.date,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey),
            onPressed: onRemove,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}