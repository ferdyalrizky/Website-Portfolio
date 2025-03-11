import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hris_v2/models/absen_online.dart';
import 'package:hris_v2/models/area_kerja.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/masuk%20absen/face_detection.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/masuk%20absen/status_absen.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/components/custom_text_field_and_header.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:hris_v2/utils/constant.dart';
import 'package:hris_v2/widgets/dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as map_toolkit;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../../../../../widgets/custom_snackbar_content.dart';

class AbsenPage extends StatefulWidget {
  final Karyawan currUser;
  final XFile? image;

  const AbsenPage({super.key, required this.currUser, this.image});

  @override
  State<AbsenPage> createState() => _AbsenPageState(image);
}

class _AbsenPageState extends State<AbsenPage> {
  _AbsenPageState(this.image);
  XFile? image;
  LocationData? userCurrLoc;
  bool isInSelectedArea = true;
  Uint8List? selfieBytes;
  AbsenOnline? _absenOnline;
  String _visitsTime = "";
  late bool isLoadingAbsenOnline;
  String _displayText = '';
  String _radiusText = '';
  // bool isUsingFakeLocation = false;

  GoogleMapController? _mapController;

  List<AreaKerja> _areaKerja = [];

  // void resetFakeLocationStatus() {
  //   setState(() {
  //     isUsingFakeLocation = false;
  //   });
  // }

  // Future<void> checkDeviceSafety() async {
  //   try {
  //     // Caching the result to avoid repeated checks
  //     if (isUsingFakeLocation) return;

  //     bool isSafe = await SafeDevice.isSafeDevice;
  //     setState(() {
  //       isUsingFakeLocation = !isSafe;
  //     });

  //     if (!isSafe) {
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(""),
  //           ),
  //         );
  //       }
  //       return; // Prevent further actions
  //     }
  //   } catch (e) {
  //     print("Error checking device safety: $e");
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("Error checking device safety. Please try again."),
  //         ),
  //       );
  //     }
  //   }
  // }

  bool _isLoadingAreaKerja = true;
  _getAreaKerja() async {
    setState(() {
      _isLoadingAreaKerja = true;
    });
    var header = {
      'ContentType': 'application/json',
      'Authorization': 'Bearer ${widget.currUser.apiToken}',
    };
    try {
      var response = await http.get(
        Uri.parse('$API_URL/v2/getAreaKerja'),
        headers: header,
      );
      final output = jsonDecode(response.body);
      print("Jumlah Area Kerja: ${_areaKerja.length}");
      _areaKerja = (output as List)
          .map((areaKerja) => AreaKerja.fromJson(areaKerja))
          .toList();
      print("Area Kerja: $_areaKerja");
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

  // check radius area kantor
  bool checkIsInRadius(AreaKerja areaKerja) {
    List<String> lokasi = areaKerja.lokasi.split(',');
    final distance = map_toolkit.SphericalUtil.computeDistanceBetween(
      map_toolkit.LatLng(userCurrLoc!.latitude!, userCurrLoc!.longitude!),
      map_toolkit.LatLng(double.parse(lokasi[0]), double.parse(lokasi[1])),
    );
    return distance <= 100;
  }

  //To get current user location
  Future<void> getCurrentLocation() async {
    requestPermissionLocation(); // Memeriksa izin lokasi

    Location loc = Location();
    try {
      // Memastikan layanan lokasi diaktifkan
      bool serviceEnabled = await loc.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await loc.requestService();
        if (!serviceEnabled) {
          print("Layanan lokasi tidak diaktifkan.");
          return; // Kembali jika layanan lokasi tidak diaktifkan
        }
      }

      // Mendapatkan lokasi pengguna
      userCurrLoc = await loc.getLocation();
      print(
          "User  Location: ${userCurrLoc!.latitude}, ${userCurrLoc!.longitude}");

      // Memeriksa apakah lokasi pengguna berada dalam area kerja
      isInSelectedArea =
          _areaKerja.any((areaKerja) => checkIsInRadius(areaKerja));

      // Jika Anda ingin memeriksa lokasi palsu, tambahkan logika di sini
      // if (isUsingFakeLocation) {
      //   // Tampilkan pesan atau lakukan tindakan lain jika lokasi palsu terdeteksi
      //   print("Lokasi palsu terdeteksi.");
      // }

      await loc.getLocation().then((location) {
        setState(() {
          userCurrLoc = location;
          print(
              "User  Location: ${userCurrLoc!.latitude}, ${userCurrLoc!.longitude}"); // Tambahkan log ini
          isInSelectedArea =
              _areaKerja.any((areaKerja) => checkIsInRadius(areaKerja));
        });
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  //To get if user has in the area
  void checkUpdatedLocation(LatLng pointLatLng) {}

  //Set Custom Marker Icon for user Position
  setCustomMarkerIcon() async {
    markerIcon = await getBytesFromAsset('assets/images/avatar.png', 100);
    var icon = BitmapDescriptor.fromBytes(markerIcon);
    userIcon = icon;

    // Get the user's current location
    final location = await getLocation();
    print("id karyawan/${widget.currUser.id}");

    // Make API call to retrieve location data
    final response = await http.get(
      Uri.parse(
          '$API_URL/v2/absen_online/cek_alamat_lokasi_user/${widget.currUser.id}/${location.latitude},${location.longitude}'),
      headers: {
        'ContentType': 'application/json; charset=UTF8',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      },
    );
    print(response.body);
    if (response.statusCode == 201) {
      // Parse the response data
      final jsonData = jsonDecode(response.body);
      // Update the display text
      setState(() {
        _displayText = jsonData['datas'].toString();
        _radiusText = jsonData['radius'].toString();
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<LocationData> getLocation() async {
    final locationService = Location();
    return await locationService.getLocation();
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
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  _onAbsenOnlineBtnPress(String absenType) async {
    final validationSuccess = _formKey.currentState?.validate() ?? false;

    if (!validationSuccess) {
      return; // Exit early if validation fails
    }

    final GlobalKey<State> keyLoader = GlobalKey<State>();
    Dialogs.loading(context, keyLoader, "Proses...");

    try {
      String userCurrLatLong =
          '${userCurrLoc?.latitude?.toStringAsFixed(6)},${userCurrLoc?.longitude?.toStringAsFixed(6)}';

      var header = {
        'ContentType': 'multipart/formdata',
        'Authorization': 'Bearer ${widget.currUser.apiToken}',
      };

      Map<String, String> body = {
        'id': widget.currUser.id.toString(),
        'absensi': absenType,
        'location': userCurrLatLong,
        'keterangan': _formKey.currentState?.fields['keterangan']?.value ?? '',
        // 'is_fake_gps':
        //     isUsingFakeLocation ? " (User  menggunakan lokasi palsu)" : "",
      };

      var request =
          http.MultipartRequest('POST', Uri.parse('$API_URL/v2/absenOnline'))
            ..fields.addAll(body)
            ..headers.addAll(header);

      if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('foto', image!.path));
      }

      var response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      final responseData = jsonDecode(responseBody.body);

      // Logging untuk debugging
      print("Response Body: ${responseBody.body}");
      print("Response Status Code: ${response.statusCode}");

      // Tutup loading indicator
      Navigator.of(keyLoader.currentContext!, rootNavigator: false).pop();

      // Cek status kode respons
      if (response.statusCode == 201) {
        // Kasus sukses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Success",
              msg: "Absen berhasil",
              contentType: ContentType.success,
            ),
          ),
        );

        // Reset form dan variabel
        _formKey.currentState?.reset();
        image = null;
        selfieBytes = null;
        setState(() {});

        // Navigasi ke halaman StatusAbsen
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StatusAbsen(
                    currUser: widget.currUser,
                  )),
        );
      } else {
        // Kasus gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            content: CustomSnackbarContent(
              title: "Failed",
              msg: responseData['messages'] ?? "Terjadi kesalahan",
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } catch (e) {
      // Menangani kesalahan
      print('Error: $e');
      Navigator.of(keyLoader.currentContext!, rootNavigator: false)
          .pop(); // Tutup loading

      // Tampilkan pesan kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: CustomSnackbarContent(
            title: "Error",
            msg: "Terjadi kesalahan saat mengirim data absen.",
            contentType: ContentType.failure,
          ),
        ),
      );
    }

    _getOnlineAbsenData();
  }

  //TODO bikin ambil data absen online
  _getOnlineAbsenData() async {
    setState(() {
      isLoadingAbsenOnline = true;
    });
    var header = {
      'ContentType': 'multipart/formdata',
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
        _visitsTime = "";
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
    // await checkDeviceSafety();
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
                  padding: const EdgeInsets.symmetric(horizontal: 10).r,
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 67,
                            left: 64.5,
                            right: 64,
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
                                        BoxConstraints(maxWidth: 280.w),
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      widget.currUser.namaKaryawan!,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w800,
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
                                  Text(
                                    widget.currUser.nip!,
                                    style: TextStyle(
                                        color: const Color(0xFF585858),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    height: 33.h,
                                  ),
                                  Container(
                                    width: 200.w,
                                    height: 200.h,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                            color:
                                                Colors.black.withOpacity(0.1),
                                          ),
                                        ],
                                        color: Colors.white),
                                    child: image != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.file(
                                              File(image!.path),
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                print(
                                                    'Error loading image: $error');
                                                return const Text(
                                                    'Error loading image');
                                              },
                                            ),
                                          )
                                        : const Icon(
                                            Icons.camera_enhance_outlined,
                                            color: Colors.white,
                                          ),
                                  ),
                                  SizedBox(
                                    height: 38.h,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Card(
                          shadowColor:
                              const ui.Color.fromARGB(255, 197, 192, 192),
                          elevation: 3,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            //height: isOpen ? 200 : 100,
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            padding: const EdgeInsets.all(16).w,
                            child: Column(children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 0,
                                    child: CircleAvatar(
                                      backgroundColor: const Color(0xFF0277B7),
                                      radius: 20.r,
                                      child: Icon(
                                        Icons.location_pin,
                                        color: Colors.white,
                                        size: 20.w,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 0, child: SizedBox(width: 18.w)),
                                  Expanded(
                                    flex: 7,
                                    child: Column(
                                      children: [
                                        Text(
                                          _displayText,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        SizedBox(
                                          height: 12.h,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              isInSelectedArea
                                  ? Container()
                                  : Card(
                                      shadowColor: const ui.Color.fromARGB(
                                          255, 197, 192, 192),
                                      elevation: 3,
                                      clipBehavior: Clip.antiAlias,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        //height: isOpen ? 200 : 100,
                                        decoration: const BoxDecoration(
                                            color: Color(0xFFFFF3D9)),
                                        padding: const EdgeInsets.all(16).w,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 0,
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    color:
                                                        const Color(0xFFE6B627),
                                                    Icons.warning_amber,
                                                    size: 30.r,
                                                  )
                                                ],
                                              ),
                                            ),
                                            const Expanded(
                                                flex: 0,
                                                child: SizedBox(width: 0)),
                                            Expanded(
                                              flex: 5,
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 8.h,
                                                  ),
                                                  Text(
                                                    "Anda berada di luar area kantor",
                                                    style: TextStyle(
                                                        color: const Color(
                                                            0xFFE6B627),
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                            ]),
                          ),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        const CustomTextFieldAndHeader(
                          header: "Keterangan *",
                          txtFieldName: "keterangan",
                          keyboardType: TextInputType.text,
                          isRequired: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
      bottomNavigationBar: Container(
        height: 180.w,
        child: BottomAppBar(
          color: Colors.white24,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.black)),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FaceDetectionAbsen(
                          currUser: widget.currUser,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Unggah ulang',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    backgroundColor: LightColors.kFagettiBlue,
                  ),
                  onPressed: () async {
                    await _onAbsenOnlineBtnPress('check_in');
                  },
                  child: Text(
                    'Kirim',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
