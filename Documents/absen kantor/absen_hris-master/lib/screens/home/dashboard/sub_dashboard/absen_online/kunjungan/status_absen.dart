import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hris_v2/core.dart';
import 'package:hris_v2/models/absen_online.dart';
import 'package:hris_v2/models/area_kerja.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/home_navigation.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/custom_snackbar_content.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as map_toolkit;

import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../../../../../widgets/dialog.dart';

class StatusAbsenKunjungan extends StatefulWidget {
  final Karyawan currUser;
  final XFile? image;

  const StatusAbsenKunjungan({super.key, required this.currUser, this.image});

  @override
  State<StatusAbsenKunjungan> createState() =>
      _StatusAbsenKunjunganState(image);
}

class _StatusAbsenKunjunganState extends State<StatusAbsenKunjungan> {
  _StatusAbsenKunjunganState(this.image);
  XFile? image;
  LocationData? userCurrLoc;
  bool isInSelectedArea = true;
  File? fotoSelfie;
  Uint8List? selfieBytes;
  AbsenOnline? _absenOnline;
  String _visitsTime = "";
  String _alamat = "";
  late bool isLoadingAbsenOnline;

  GoogleMapController? _mapController;

  // Define the radius for the circle (in meters)
  final double radius = 100.0;

  List<AreaKerja> _areaKerja = [];
  bool _isLoadingAreaKerja = true;
  _getAreaKerja() async {
    setState(() {
      _isLoadingAreaKerja = true;
    });
    var header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.currUser.apiToken}',
    };
    try {
      var response = await http.get(
        Uri.parse('$API_URL/v2/getAreaKerja'),
        headers: header,
      );
      final output = jsonDecode(response.body);
      print("Jumlah Area Kerja: ${_areaKerja.length}"); // Tambahkan log ini
      _areaKerja = (output as List)
          .map((areaKerja) => AreaKerja.fromJson(areaKerja))
          .toList();
      print("Area Kerja: $_areaKerja"); // Tambahkan log ini
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoadingAreaKerja = false;
      });
    }
  }

  BitmapDescriptor userIcon = BitmapDescriptor.defaultMarker;
  late Uint8List markerIcon;

  bool checkInOutBtnLoading = false;

  final _formKey = GlobalKey<FormBuilderState>();

  //?[START Helper Method]

  //Open Camera
  Future getSelfie() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagePicked =
        await picker.pickImage(source: ImageSource.camera);
    if (imagePicked != null) {
      fotoSelfie = File(imagePicked.path);
    }

    setState(() {});
  }

  bool checkIsInRadius(AreaKerja areaKerja) {
    List<String> lokasi = areaKerja.lokasi.split(',');
    final distance = map_toolkit.SphericalUtil.computeDistanceBetween(
      map_toolkit.LatLng(userCurrLoc!.latitude!, userCurrLoc!.longitude!),
      map_toolkit.LatLng(double.parse(lokasi[0]), double.parse(lokasi[1])),
    );
    return distance <= 100;
  }

  //To get current user location
  getCurrentLocation() async {
    Location loc = Location();

    await loc.getLocation().then((location) {
      setState(() {
        userCurrLoc = location;
        print(
            "User  Location: ${userCurrLoc!.latitude}, ${userCurrLoc!.longitude}"); // Tambahkan log ini
        isInSelectedArea =
            _areaKerja.any((areaKerja) => checkIsInRadius(areaKerja));
      });
    });
  }

  LatLng getLatLng(AreaKerja areaKerja) {
    List<String> lokasi = areaKerja.lokasi.split(',');
    LatLng latLng = LatLng(double.parse(lokasi[0]), double.parse(lokasi[1]));
    print(
        "nama area kerja : ${areaKerja.areaKerja}: $latLng"); // Tambahkan log ini
    return latLng;
  }

  //To get if user has in the area
  void checkUpdatedLocation(LatLng pointLatLng) {}

  //Move camera to the coordinate
  void moveCameraMaps(LatLng coordinate) {
    setState(() {
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: coordinate, zoom: 18)));
    });
  }

  //Set Custom Marker Icon for user Position
  setCustomMarkerIcon() async {
    markerIcon = await getBytesFromAsset('assets/images/petunjukarah.png', 100);
    var icon = BitmapDescriptor.fromBytes(markerIcon);
    userIcon = icon;
    setState(() {});
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void requestPermissionLocation() async {
    final permission = await Permission.location.request();
    if (permission.isGranted) {
    } else if (permission.isDenied ||
        permission.isPermanentlyDenied ||
        permission.isRestricted) {
      await Permission.location.request();
    }
  }

  _onAbsenOnlineBtnPress(String absenType) async {
    final validationSuccess = _formKey.currentState!.validate();
    final GlobalKey<State> keyLoader = GlobalKey<State>();
    final String tipeAbsen = absenType == "check_in"
        ? "Check In"
        : absenType == "check_out"
            ? "Check Out"
            : "Visit";

    if (fotoSelfie == null) {
      int gacha = Random().nextInt(1000);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Failed",
            msg: gacha == 0
                ? "Selfie dulu dong ganteng/cantik"
                : "Harus lampirkan foto selfie",
            contentType: ContentType.failure,
          ),
        ),
      );

      return;
    }

    if (validationSuccess) {
      Dialogs.loading(context, keyLoader, "Proses...");
    } else {
      return;
    }

    String userCurrLatLong =
        '${userCurrLoc!.latitude!.toStringAsFixed(6)},${userCurrLoc!.longitude!.toStringAsFixed(6)}';

    var header = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${widget.currUser.apiToken}',
    };

    Map<String, String> body = {
      'id': widget.currUser.id.toString(),
      'absensi': absenType,
      'location': userCurrLatLong,
      'keterangan_visit':
          _formKey.currentState!.fields['keterangan_visit']?.value,
    };
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$API_URL/v2/absenOnline'))
            ..fields.addAll(body)
            ..headers.addAll(header);

      if (fotoSelfie != null) {
        request.files
            .add(await http.MultipartFile.fromPath('foto', fotoSelfie!.path));
      }

      var response = await request.send();
      print(response.statusCode);

      if (response.statusCode == 201) {
        Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "$tipeAbsen Berhasil",
              contentType: ContentType.success,
            ),
          ),
        );

        _formKey.currentState?.reset();
        fotoSelfie = null;
        selfieBytes = null;
        setState(() {});
      } else {
        Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Failed",
              msg: "$tipeAbsen Gagal",
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error $e');
    }
    _getOnlineAbsenData();
  }

  //TODO bikin ambil data absen online
  _getOnlineAbsenData() async {
    setState(() {
      isLoadingAbsenOnline = true;
    });
    var header = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${widget.currUser.apiToken}',
    };
    try {
      var response = await http.get(
        Uri.parse('$API_URL/v2/getRekapAbsenOnline/${widget.currUser.nip}'),
        headers: header,
      );
      final output = jsonDecode(response.body);
      print(output);
      _absenOnline = AbsenOnline.fromJson(output);
      if (_absenOnline!.visits[0] != "") {
        _visitsTime = "";
        for (var i = 0; i < _absenOnline!.visits.length; i++) {
          _visitsTime += "${_absenOnline!.visits[i]}\n";
        }
      } else {
        _visitsTime = "-";
      }
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoadingAbsenOnline = false;
    });
  }

  _lokasiAlamatVisit() async {
    setState(() {
      isLoadingAbsenOnline = true;
    });
    var header = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${widget.currUser.apiToken}',
    };
    try {
      var response = await http.get(
        Uri.parse('$API_URL/v2/getRekapAbsenOnline/${widget.currUser.nip}'),
        headers: header,
      );
      final output = jsonDecode(response.body);
      print(output);
      _absenOnline = AbsenOnline.fromJson(output);

      // Cek apakah ada alamat
      if (_absenOnline!.alamat.isNotEmpty) {
        // Ambil alamat terakhir
        _alamat = _absenOnline!.alamat.last; // Mengambil alamat terakhir
      } else {
        _alamat = "-"; // Jika tidak ada alamat
      }
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoadingAbsenOnline = false;
    });
  }

  //?[End Helper Method]

  //&[START Lifecycle]
  @override
  void initState() {
    initializing();
    super.initState();
  }
  //&[END Lifecycle]

  initializing() async {
    await _lokasiAlamatVisit();
    await _getAreaKerja();
    await _getOnlineAbsenData();
    await setCustomMarkerIcon();
    await getCurrentLocation();
  }

  //![START Screen Build]
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: userCurrLoc == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10).w,
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 87,
                          ).r,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Center vertically
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxWidth: 300.w),
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      "Anda berhasil Absen kunjungan",
                                      style: GoogleFonts.epilogue(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      softWrap: true,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.h,
                                  ),
                                  SizedBox(
                                    height: 33.h,
                                  ),
                                  isInSelectedArea
                                      ? Container(
                                          width: 160.w,
                                          height: 160.w,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                spreadRadius: 2,
                                                blurRadius: 10,
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: _absenOnline!.visits == ""
                                                ? Image.asset(
                                                    "assets/images/berhasil.png")
                                                : Image.asset(
                                                    "assets/images/berhasil.png"),
                                          ))
                                      : Container(
                                          width: 160.w,
                                          height: 160.w,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                spreadRadius: 2,
                                                blurRadius: 10,
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              child: Image.asset(
                                                  "assets/images/luarradius.png",
                                                  fit: BoxFit.cover))),
                                  SizedBox(
                                    height: 55.h,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Card(
                          shadowColor: Colors.white54,
                          elevation: 8,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            //height: isOpen ? 200 : 100,
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            padding: const EdgeInsets.all(16).w,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 0,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.blue,
                                            radius: 40.r,
                                            backgroundImage: _absenOnline!
                                                        .gambar ==
                                                    null
                                                ? const AssetImage(
                                                    'assets/images/avatar.png')
                                                : NetworkImage(
                                                    '$API_URL_PROFILE_PICT/${_absenOnline!.gambar}'),
                                          )),
                                      Expanded(
                                          flex: 0,
                                          child: SizedBox(width: 18.w)),
                                      Expanded(
                                        flex: 0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.currUser.namaKaryawan!,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                            Text(
                                              widget.currUser.nip!,
                                              style: TextStyle(
                                                  color:
                                                      const Color(0xFF717171),
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          Text(
                                            "Waktu",
                                            style: TextStyle(
                                                color: const Color(0xFF717171),
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                          Text(
                                            _visitsTime,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      isInSelectedArea
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                top: 6,
                                                bottom: 6,
                                                left: 8,
                                                right: 8,
                                              ).r,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6.r),
                                                color: _absenOnline!.visits ==
                                                        ""
                                                    ? const Color(0xFFFFF7E6)
                                                    : const Color(0xFFFFF7E6),
                                              ),
                                              child: Text(
                                                _absenOnline!.visits == ""
                                                    ? "Absen kunjungan"
                                                    : "Absen kunjungan",
                                                style: TextStyle(
                                                  color: _absenOnline!.visits ==
                                                          ""
                                                      ? const Color(0xFFFFB000)
                                                      : const Color(0xFFFFB000),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.only(
                                                top: 6,
                                                bottom: 6,
                                                left: 8,
                                                right: 8,
                                              ).r,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: const Color(0xFFFFF7E6),
                                              ),
                                              child: const Text(
                                                "Diluar radius",
                                                style: TextStyle(
                                                  color: Color(0xFFFFB000),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )
                                    ],
                                  ),
                                  Text(
                                    "Lokasi",
                                    style: TextStyle(
                                        color: const Color(0xFF717171),
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 8.h,
                                  ),
                                  Text(
                                    _alamat,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    "Keterangan",
                                    style: TextStyle(
                                        color: const Color(0xFF717171),
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 8.h,
                                  ),
                                  Text(
                                    _absenOnline!.keteranganVisit,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600),
                                  )
                                ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white24,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: LightColors.kFagettiBlue,
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeNavigation(),
              ),
              (Route<dynamic> route) => false,
            );
          },
          child: const Text(
            'Kembali',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
