import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inifinite_scroll/infinite_scroll_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> items = [];

  Future getData({int page = 1}) async {
    int limit = 25;
    final url = Uri.parse(
        "https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List newItems = jsonDecode(response.body);
      setState(() {
        items.addAll(newItems.map<String>((item) {
          final number = item['id'];
          return "item $number";
        }).toList());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${items.length}"),
            InfiniteScrollView(
              totalData: null,
              itemCount: items.length,
              enableRefresh: true,
              onLoadMore: (page) {
                getData(page: page);
              },
              onRefresh: () async {
                setState(() => items.clear());
                getData();
              },
              itemBuilder: (ctx, idx) {
                return ListTile(
                  title: Text("data $idx"),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
