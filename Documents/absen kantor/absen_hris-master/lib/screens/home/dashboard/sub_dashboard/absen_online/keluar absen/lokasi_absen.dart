import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hris_v2/models/absen_online.dart';
import 'package:hris_v2/models/area_kerja.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/keluar%20absen/baca_petunjuk.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/custom_snackbar_content.dart';
import 'package:hris_v2/widgets/dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as map_toolkit;

import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class AbsenOnlineScreenKeluar extends StatefulWidget {
  //TODO: Nambah Data User untuk Absen Online push ke API
  final Karyawan currUser;

  const AbsenOnlineScreenKeluar({
    super.key,
    required this.currUser,
  });

  @override
  State<AbsenOnlineScreenKeluar> createState() =>
      _AbsenOnlineScreenKeluarState();
}

class _AbsenOnlineScreenKeluarState extends State<AbsenOnlineScreenKeluar> {
  final Completer<GoogleMapController> _gmapController = Completer();

  LocationData? userCurrLoc;
  bool isInSelectedArea = true;
  File? fotoSelfie;
  Uint8List? selfieBytes;
  AbsenOnline? _absenOnline;
  String _visitsTime = "";
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
      'keterangan': _formKey.currentState!.fields['keterangan']?.value,
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

  //?[End Helper Method]

  //&[START Lifecycle]
  @override
  void initState() {
    initializing();
    super.initState();
  }
  //&[END Lifecycle]

  initializing() async {
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
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            size: 24.w,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: userCurrLoc == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: RPadding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: SizedBox(
                        height: 300.h,
                        width: double.infinity.w,
                        child: GoogleMap(
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          initialCameraPosition: CameraPosition(
                            target: LatLng(userCurrLoc!.latitude!,
                                userCurrLoc!.longitude!),
                            zoom: 16.5,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId("user"),
                              icon: userIcon,
                              position: LatLng(userCurrLoc!.latitude!,
                                  userCurrLoc!.longitude!),
                              draggable: true,
                              onDragEnd: (updateLatLng) {
                                checkUpdatedLocation(updateLatLng);
                              },
                            ),
                            ..._areaKerja.map((areaKerja) {
                              LatLng latLng = getLatLng(areaKerja);
                              print(
                                  "Adding marker for area: ${areaKerja.areaKerja} at $latLng"); // Tambahkan log ini
                              return Marker(
                                markerId: MarkerId(areaKerja.id.toString()),
                                position: latLng,
                                infoWindow:
                                    InfoWindow(title: areaKerja.areaKerja),
                              );
                            }),
                          },
                          circles: {
                            ..._areaKerja.map((areaKerja) {
                              LatLng latLng = getLatLng(areaKerja);
                              print(
                                  "Adding circle for area: ${areaKerja.areaKerja} at $latLng with radius: $radius"); // Tambahkan log ini
                              return Circle(
                                circleId: CircleId(areaKerja.id.toString()),
                                center: latLng,
                                radius: radius,
                                fillColor: isInSelectedArea
                                    ? const Color(0xFFB1D5E9).withOpacity(0.6)
                                    : const Color(0xFFE6F1F8).withOpacity(0.6),
                                strokeColor:
                                    const Color(0xFF0277B7).withOpacity(0.3),
                                strokeWidth: 2,
                              );
                            }),
                          },
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            isInSelectedArea
                                ? SvgPicture.asset("assets/images/yesarea.svg")
                                : SvgPicture.asset("assets/images/noarea.svg"),
                            SizedBox(
                              width: 8.w,
                            ),
                            Text(
                              isInSelectedArea
                                  ? "Posisi kamu didalam radius kantor"
                                  : "Posisi kamu diluar radius kantor",
                              style: TextStyle(
                                  fontSize: 14.sp, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        height: 120.h,
        color: Colors.white24,
        child: Column(
          children: [
            Text(
              isInSelectedArea ? "Oke, bisa absen" : "Yakin mau tetap absen?",
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF717171)),
            ),
            SizedBox(
              height: 5.h,
            ),
            SizedBox(
              width: double.infinity.w,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: LightColors.kFagettiBlue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BacaAturanKeluar(
                              currUser: widget.currUser,
                            )),
                  );
                },
                child: const Text(
                  'Ambil foto',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  //![END Screen Build]
}
