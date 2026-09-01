import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hris_v2/screens/home/owner_screens/data_karyawan/detail_karyawan.dart';
import 'package:hris_v2/theme/colors/custom_theme.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/loader.dart';
import 'package:http/http.dart' as http;

import '../../../../models/karyawan.dart';
import '../../../../size_config.dart';

class ListKaryawanScreen extends StatefulWidget {
  final Karyawan currUser;
  const ListKaryawanScreen({super.key, required this.currUser});

  @override
  State<ListKaryawanScreen> createState() => _ListKaryawanScreenState();
}

class _ListKaryawanScreenState extends State<ListKaryawanScreen> {
  _ListKaryawanScreenState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNamaKaryawans = namaKaryawans;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  final TextEditingController _filter = TextEditingController();
  String _searchText = "";
  List<Karyawan> namaKaryawans = [];
  List<Karyawan> filteredNamaKaryawans = [];
  Icon _searchIcon = const Icon(Icons.search);
  Widget _appBarTitle = const Text("List Karyawan");
  bool isLoading = true;

  void _getNamaKaryawans() async {
    final response = await http.get(
      Uri.parse('$API_URL/v2/getAllKaryawan'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      },
    );
    // print(response.body);
    // print(jsonDecode(response.body));
    List<Karyawan> tempList = [];
    for (int i = 0; i < jsonDecode(response.body).length; i++) {
      // tempList.add(response.body[i]);
      // print(jsonDecode(response.body)[i]["name"]);
      tempList.add(Karyawan.fromJson(jsonDecode(response.body)[i]));
    }
    setState(() {
      namaKaryawans = tempList;
      filteredNamaKaryawans = namaKaryawans;
      isLoading = false;
    });
  }

  void _searchPressed() {
    setState(() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = const Icon(Icons.close);
        _appBarTitle = TextField(
          controller: _filter,
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: "Search..."),
        );
      } else {
        _searchIcon = const Icon(Icons.search);
        _appBarTitle = const Text('List Karyawan');
        filteredNamaKaryawans = namaKaryawans;
        _filter.clear();
      }
    });
  }

  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List<Karyawan> tempList = [];
      for (int i = 0; i < filteredNamaKaryawans.length; i++) {
        if (filteredNamaKaryawans[i]
            .nama!
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredNamaKaryawans[i]);
        }
      }
      filteredNamaKaryawans = tempList;
    }
    return ListView.builder(
      itemCount: namaKaryawans == null ? 0 : filteredNamaKaryawans.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            width: getProportionateScreenWidth(75),
            height: getPropotionateScreenHeight(75),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    spreadRadius: 2,
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.1))
              ],
              color: Colors.blueAccent,
              shape: BoxShape.circle,
              image: filteredNamaKaryawans[index].profilePhotoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(
                          '$API_URL_PROFILE_PICT/${filteredNamaKaryawans[index].profilePhotoUrl}'),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage('assets/images/avatar.png'),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          title: Text(filteredNamaKaryawans[index].namaKaryawan ?? "none"),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return DetailKaryawanScreen(
                selectedKaryawan: filteredNamaKaryawans[index],
                currUser: widget.currUser,
              );
            }));
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: _appBarTitle,
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          icon: _searchIcon,
          onPressed: _searchPressed,
        ),
      ],
    );
  }

  @override
  void initState() {
    _getNamaKaryawans();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildBar(context),
      body: isLoading
          ? const Center(child: Loader())
          : Container(
              padding: const EdgeInsets.all(10.0),
              child: _buildList(),
            ),
      resizeToAvoidBottomInset: false,
    );
  }
}
