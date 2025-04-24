// lib/search_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movieom_app/Entity/api_movie.dart';
import 'package:movieom_app/Entity/movie_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> suggestions = [];
  List<ApiMovie> movies = [];
  List<Map<String, dynamic>> searchHistory = [];
  bool _isLoadingSuggestions = false;
  bool _isLoadingMovies = false;
  bool _isLoadingHistory = false;
  String _errorMessage = '';

  bool _isTyping = false;
  DateTime _lastTyped = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user!.uid;

      final searchHistoryRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('searchHistory')
          .orderBy('timestamp', descending: true)
          .limit(10);

      final querySnapshot = await searchHistoryRef.get();
      final history = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'keyword': data['keyword'] ?? '',
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate().toString() ?? '',
        };
      }).toList();

      setState(() {
        searchHistory = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải lịch sử tìm kiếm: $e';
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _saveSearchHistory(String keyword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user!.uid;
      print('Saving search history for User ID: $userId');

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await userDocRef.get();
      if (!userDoc.exists) {
        await userDocRef.set({
          'email': user.email ?? '',
          'first_name': user.displayName?.split(' ').first ?? '',
          'last_name': user.displayName?.split(' ').last ?? '',
          'age': 0,
        });
      }

      final searchHistoryRef = userDocRef.collection('searchHistory');
      await searchHistoryRef.add({
        'keyword': keyword,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _loadSearchHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu lịch sử tìm kiếm: $e')),
      );
    }
  }

  Future<void> fetchSuggestions(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
      _errorMessage = '';
    });

    final url = Uri.parse(
      'https://phimapi.com/v1/api/tim-kiem?keyword=$keyword&page=1&sort_field=_id&sort_type=asc&limit=5',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final searchResponse = ApiSearchResponse.fromJson(data);
        setState(() {
          suggestions = searchResponse.movies.map((movie) => movie.title).toList();
          _isLoadingSuggestions = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Không thể tải gợi ý. Mã lỗi: ${response.statusCode}';
          suggestions = [];
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải gợi ý: $e';
        suggestions = [];
        _isLoadingSuggestions = false;
      });
    }
  }

  Future<void> fetchMovies(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        movies = [];
        suggestions = [];
        _isLoadingMovies = false;
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isLoadingMovies = true;
      _errorMessage = '';
      movies = [];
      suggestions = [];
    });

    final url = Uri.parse(
      'https://phimapi.com/v1/api/tim-kiem?keyword=$keyword&page=1&sort_field=_id&sort_type=asc&limit=10',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final searchResponse = ApiSearchResponse.fromJson(data);
        setState(() {
          movies = searchResponse.movies;
          _isLoadingMovies = false;
        });

        await _saveSearchHistory(keyword);
      } else {
        setState(() {
          _errorMessage = 'Không thể tải dữ liệu. Mã lỗi: ${response.statusCode}';
          _isLoadingMovies = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã có lỗi xảy ra: $e';
        _isLoadingMovies = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _isTyping = true;
      _lastTyped = DateTime.now();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (DateTime.now().difference(_lastTyped).inMilliseconds >= 500) {
        setState(() {
          _isTyping = false;
        });
        fetchMovies(value);
        fetchSuggestions(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: "Tìm kiếm phim...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        if (_isLoadingHistory)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        if (searchHistory.isNotEmpty && !_isTyping && movies.isEmpty)
          Container(
            height: 100,
            child: ListView.builder(
              itemCount: searchHistory.length,
              itemBuilder: (context, index) {
                final history = searchHistory[index];
                return ListTile(
                  title: Text(history['keyword']),
                  subtitle: Text('Tìm kiếm lúc: ${history['timestamp']}'),
                  onTap: () {
                    _controller.text = history['keyword'];
                    _onSearchChanged(history['keyword']);
                  },
                );
              },
            ),
          ),
        if (_isLoadingSuggestions && _isTyping)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        if (suggestions.isNotEmpty && _isTyping)
          Container(
            height: 150,
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(suggestions[index]),
                  onTap: () {
                    _controller.text = suggestions[index];
                    _onSearchChanged(suggestions[index]);
                  },
                );
              },
            ),
          ),
        Expanded(
          child: _isLoadingMovies
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : movies.isEmpty
              ? const Center(child: Text('Không tìm thấy phim nào!'))
              : ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    vertical: 5, horizontal: 10),
                child: ListTile(
                  leading: movie.poster.isNotEmpty
                      ? Image.network(
                    movie.poster,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                    const Icon(Icons.movie),
                  )
                      : const Icon(Icons.movie),
                  title: Text(
                    movie.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Năm: ${movie.year.isNotEmpty ? movie.year : 'N/A'} - Thể loại: ${movie.title}', // Dùng title làm thể loại
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    final movieModel = movie.toMovieModel();
                    Navigator.pushNamed(
                      context,
                      '/movie_detail',
                      arguments: movieModel,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}