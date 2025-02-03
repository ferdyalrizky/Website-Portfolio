import 'package:flutter/material.dart';
import 'package:aplikasi_gudang/models/rak.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataList extends StatefulWidget {
  final String keyword; // Parameter for the search keyword

  const DataList(
      {super.key, required this.keyword, required List searchResults});

  @override
  State<DataList> createState() => _DataListState();
}

class _DataListState extends State<DataList> {
  bool loadingResults = true; // Loading status
  List<Room> searchResults = []; // List of Room objects

  @override
  void initState() {
    super.initState();
    fetchSearchResults(
        widget.keyword); // Fetch results when the widget initializes
  }

  Future<void> fetchSearchResults(String keyword) async {
    // Fetch all results (modify this URL if necessary)
    final response = await http.get(Uri.parse(
        'http://162.5.10.165/erp_project/api/barang/warehouse/layout/B'));

    print('Fetching data for keyword: $keyword');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('JSON Data: $jsonData'); // Print the JSON data

      // Check if 'data' is present and is a list
      if (jsonData['data'] is List) {
        setState(() {
          // Flatten the nested arrays into a single list
          List<Room> allRooms = (jsonData['data'] as List)
              .expand((innerList) => (innerList as List)
                  .map((roomJson) => Room.fromJson(roomJson)))
              .toList();

          // Filter results based on the keyword
          searchResults =
              allRooms.where((room) => room.code.contains(keyword)).toList();

          // Debugging: Print the number of results found
          print('Number of rooms found: ${searchResults.length}');

          loadingResults = false; // Set loading to false
        });
      } else {
        print('Data is not a list or is missing');
        setState(() {
          loadingResults = false; // Set loading to false
        });
      }
    } else {
      setState(() {
        loadingResults = false; // Set loading to false
      });
      print('Failed to load search results: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "${widget.keyword}"'),
      ),
      body: loadingResults
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : searchResults.isNotEmpty
              ? ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final room = searchResults[index];
                    return ListTile(
                      title: Text(room.code), // Use the Room object's code
                      subtitle: Text(room.isActive
                          ? 'Active'
                          : 'Inactive'), // Use the Room object's isActive
                      onTap: () {
                        // Action when a search result is tapped
                        print("Selected: ${room.code}");
                      },
                    );
                  },
                )
              : Center(
                  child:
                      Text("No results found")), // Show message if no results
    );
  }
}
