import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import 'models/picture.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Picture> _photos = <Picture>[];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchTerm = 'audi';
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _getImages(page: _page);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final double height = MediaQuery.of(context).size.height;
    final double offset = _scrollController.position.pixels;
    final double scrollExtent = _scrollController.position.maxScrollExtent;

    if (_hasMore && !_isLoading && scrollExtent - offset < 3 * height) {
      _page++;
      _getImages(page: _page);
    }
  }

  Future<void> _getImages({String? search, required int page}) async {
    setState(() {
      _isLoading = true;
    });
    final Client client = Client();
    final String accessKey = dotenv.env['UNSPLASH_API_KEY']!;
    final String query = search ?? _searchTerm;
    const String count = '28';

    final Response response = await client.get(Uri.parse(
        'https://api.unsplash.com/search/photos?'
            'query=$query&client_id=$accessKey'
            '&per_page=$count&page=$page'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> results = data['results'] as List<dynamic>;
      _hasMore = data['total_pages'] as int < _page;

      setState(() {
        if (page == 1) {
          _photos.clear();
        }
        _photos
            .addAll(results.cast<Map<dynamic, dynamic>>().map((Map<dynamic, dynamic> json) => Picture.fromJson(json)));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo recommendations'),
        actions: <Widget>[
          if (_isLoading && _page > 1)
          const Center(
            child: FittedBox(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: const CircularProgressIndicator(),
              ),
            ),
          )
        ],
      ),
      body: _isLoading && _page == 1 ?
        const Center(
          child: CircularProgressIndicator(),
        ) : Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  label: Text('Image theme...'),
                  prefixIcon: Icon(Icons.search),
                  prefixIconColor: Colors.lightBlue
                ),
              )),
              TextButton(
                  onPressed: () {
                    _searchTerm = _searchController.text;
                    _page = 1;
                    if (_searchTerm.isEmpty) {
                      _searchTerm = 'audi';
                    }
                    _getImages(search: _searchTerm, page: _page);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white
                  ),
                  child: const Text('Search')
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(child: _photos.isNotEmpty ? GridView.builder(
              controller: _scrollController,
              itemCount: _photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemBuilder: (BuildContext context, int index) {
                final Picture picture = _photos[index];
                return Stack(fit: StackFit.expand, children: <Widget>[
                  GridTile(child: Image.network(picture.urls.regular, fit: BoxFit.cover)),
                  Align(
                      alignment: AlignmentDirectional.bottomEnd,
                      child: Container(
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: AlignmentDirectional.bottomCenter,
                                end: AlignmentDirectional.topCenter,
                                colors: <Color>[Colors.black, Colors.transparent])),
                        child: ListTile(
                          title: Text(picture.user.name),
                          trailing: CircleAvatar(
                            backgroundImage: NetworkImage(picture.user.profileImages.medium),
                          ),
                        ),
                      ))
                ]);
              })
              : const Center(
            child: CircularProgressIndicator(semanticsLabel: 'Loading photos...'),
          ),)
        ],
      )
    );
  }
}
