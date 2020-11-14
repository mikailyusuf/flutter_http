import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'data/Post.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Http ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> _posts = [];

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();

  bool _isLoading = false;

  @override
  initState() {
    super.initState();
    fetchPosts();
  }

  Widget _buildPostList() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      key: _refreshIndicatorKey,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Padding(
                child: new ListTile(
                  title: Text(_posts[index].title),
                  subtitle: Text(_posts[index].body),
                ),
                padding: EdgeInsets.all(10.0),
              ),
              Divider(
                height: 5.0,
              )
            ],
          );
        },
        itemCount: _posts.length,
      ),
    );
  }



  Future<dynamic> fetchPosts() {
    _isLoading = true;

    return http.get('https://jsonplaceholder.typicode.com/posts')
        .then((http.Response response) {
      final List<Post> fetchedPosts = [];

      final List<dynamic> postsData = json.decode(response.body);
      if (postsData == null) {
        setState(() {
          _isLoading = false;
        });
      }

      for (var i = 0; i < postsData.length; i++) {
        final Post post = Post(
            userId: postsData[i]['userId'],
            id: postsData[i]['id'],
            title: postsData[i]['title'],
            body: postsData[i]['body']);
        fetchedPosts.add(post);
      }
      setState(() {
        _posts = fetchedPosts;
        _isLoading = false;
      });
    }).catchError((Object error) {
      setState(() {
        _isLoading = false;
      });
    });

  }

  Future<dynamic> _onRefresh() {
    return fetchPosts();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : _buildPostList(),
    );
  }


}


