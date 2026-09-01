import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:hris_v2/models/karyawan.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/masuk%20absen/absen_upload.dart';
import 'package:hris_v2/screens/home/dashboard/sub_dashboard/absen_online/utils/facedetection/google_ml_kit.dart';
import 'package:hris_v2/theme/colors/light_colors.dart';
import 'package:location/location.dart';

class FaceDetectionAbsen extends StatefulWidget {
  final Karyawan currUser;
  const FaceDetectionAbsen({super.key, required this.currUser});

  @override
  State<FaceDetectionAbsen> createState() => _State();
}

class _State extends State<FaceDetectionAbsen> with TickerProviderStateMixin {
  //set face detection
  double _exposureOffset = 0.0;
  FaceDetector faceDetector =
      GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
    enableContours: true,
    enableClassification: true,
    enableTracking: true,
    enableLandmarks: true,
  ));

  List<CameraDescription>? cameras;
  CameraController? controller;
  XFile? image;
  bool isBusy = false;

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  //set open front camera device
  //if 1 front, if 0 rear
  loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![1], ResolutionPreset.max);
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.camera_enhance_outlined,
                  color: Colors.white,
                ),
                SizedBox(width: 10.w),
                const Text("Ups, kamera tidak ditemukan!",
                    style: TextStyle(color: Colors.white))
              ],
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        shape: const StadiumBorder(),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _setExposureOffset(double value) async {
    if (controller != null) {
      await controller!.setExposureOffset(value);
      setState(() {
        _exposureOffset = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    //set loading
    showLoaderDialog(BuildContext context) {
      AlertDialog alert = AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(LightColors.kFagettiBlue)),
            Container(
                margin: const EdgeInsets.only(left: 20).r,
                child: const Text("Sedang memeriksa data...")),
          ],
        ),
      );
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            if (Platform.isIOS) ...[
              Container(
                width: double.infinity.w,
                height: 580.w,
                child: SizedBox(
                  height: 500.h,
                  width: 500.w,
                  child: controller == null
                      ? const Center(
                          child: Text("Ups, kamera bermasalah!",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))
                      : !controller!.value.isInitialized
                          ? const Center(child: CircularProgressIndicator())
                          : ClipPath(
                              child: Transform(
                                alignment: Alignment.center,
                                transform:
                                    Matrix4.translationValues(-0.0, 0.0, 0.0),
                                child: CameraPreview(controller!),
                              ),
                            ),
                ),
              ),
            ],
            if (Platform.isAndroid) ...[
              Container(
                width: double.infinity.w,
                height: 580.w,
                child: SizedBox(
                  height: 500.h,
                  width: 500.w,
                  child: controller == null
                      ? const Center(
                          child: Text("Ups, kamera bermasalah!",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))
                      : !controller!.value.isInitialized
                          ? const Center(child: CircularProgressIndicator())
                          : ClipPath(
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(math.pi),
                                child: CameraPreview(controller!),
                              ),
                            ),
                ),
              ),
            ],
            Container(
              height: 100.w,
              color: Colors.white,
              child: Column(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 50.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Posisikan wajahmu dalam bingkai",
                            style: GoogleFonts.epilogue(
                                fontSize: 18.sp, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 500.w,
                height: 225.h,
                padding: const EdgeInsets.symmetric(horizontal: 30).r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Slider(
                        thumbColor: LightColors.kFagettiBlue,
                        activeColor: LightColors.kFagettiBlue,
                        value: _exposureOffset,
                        min: -2.0,
                        max: 2.0,
                        divisions: 10,
                        label: _exposureOffset.toStringAsFixed(1),
                        onChanged: _setExposureOffset,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20).r,
                      child: ClipOval(
                        child: Material(
                          color: LightColors.kFagettiBlue, // Button color
                          child: InkWell(
                            splashColor:
                                LightColors.kFagettiBlue, // Splash color
                            onTap: () async {
                              final hasPermission =
                                  await handleLocationPermission();
                              try {
                                if (controller != null) {
                                  if (controller!.value.isInitialized) {
                                    controller!.setFlashMode(FlashMode.off);
                                    image = await controller!.takePicture();
                                    setState(() {
                                      if (hasPermission) {
                                        showLoaderDialog(context);
                                        final inputImage =
                                            InputImage.fromFilePath(
                                                image!.path);
                                        Platform.isAndroid
                                            ? processImage(inputImage)
                                            : Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AbsenPage(
                                                          currUser:
                                                              widget.currUser,
                                                          image: image,
                                                        )));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_outlined,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 10.w),
                                              const Text(
                                                "Nyalakan perizinan lokasi terlebih dahulu!",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                          backgroundColor:
                                              LightColors.kFagettiBlue,
                                          shape: const StadiumBorder(),
                                          behavior: SnackBarBehavior.floating,
                                        ));
                                      }
                                    });
                                  }
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10.w),
                                      const Text(
                                        "Ups, pastikan sesuai wajah",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                  backgroundColor: LightColors.kFagettiBlue,
                                  shape: const StadiumBorder(),
                                  behavior: SnackBarBehavior.floating,
                                ));
                              }
                            },
                            child: SizedBox(
                              width: 56.w,
                              height: 56.h,
                              child: const Icon(
                                Icons.camera_enhance_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //permission location
  Future<bool> handleLocationPermission() async {
    final Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.location_off,
                color: Colors.white,
              ),
              SizedBox(width: 10.w),
              const Text(
                "Location services are disabled. Please enable the services.",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
          backgroundColor: LightColors.kFagettiBlue,
          shape: const StadiumBorder(),
          behavior: SnackBarBehavior.floating,
        ));
        return false;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.location_off,
                color: Colors.white,
              ),
              SizedBox(width: 10.w),
              const Text(
                "Location permission denied.",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
          backgroundColor: LightColors.kFagettiBlue,
          shape: const StadiumBorder(),
          behavior: SnackBarBehavior.floating,
        ));
        return false;
      }
    }

    if (permissionGranted == PermissionStatus.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.location_off,
              color: Colors.white,
            ),
            SizedBox(width: 10.w),
            const Text(
              "Location permission denied forever, we cannot access.",
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        backgroundColor: LightColors.kFagettiBlue,
        shape: const StadiumBorder(),
        behavior: SnackBarBehavior.floating,
      ));
      return false;
    }
    return true;
  }

  //face detection
  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    isBusy = false;

    if (mounted) {
      setState(() {
        Navigator.of(context).pop(true);
        if (faces.isNotEmpty) {
          bool isWearingMask = false;

          for (final face in faces) {
            final bottomMouth = face.landmarks[FaceLandmarkType.bottomMouth];

            if (bottomMouth != null) {
              final mouthBottomY =
                  bottomMouth.position.y; // Posisi vertikal bawah mulut
              final faceBottomY = face.boundingBox.bottom; // Batas bawah wajah

              // Debugging: menunjukkan nilai landmark
              print(
                  "Mouth Bottom Y: $mouthBottomY, Face Bottom Y: $faceBottomY");

              // Logika keputusan: jika mulut lebih tinggi dari batas bawah wajah, kemungkinan memakai masker
              if (mouthBottomY > faceBottomY) {
                isWearingMask = true; // Menganggap bahwa mulut tertutup
                break;
              }
            } else {
              print(
                  "Bottom mouth landmark tidak tersedia untuk wajah ini."); // Log jika landmark tidak tersedia
            }
          }

          if (isWearingMask) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.warning,
                    color: Colors.yellow,
                  ),
                  SizedBox(width: 10.w),
                  const Expanded(
                    child: Text(
                      "Ups, pastikan Anda tidak memakai masker untuk mendeteksi wajah dengan benar!",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
              backgroundColor: Colors.red,
              shape: const StadiumBorder(),
              behavior: SnackBarBehavior.floating,
            ));
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AbsenPage(
                  currUser: widget.currUser,
                  image: image,
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.face_retouching_natural_outlined,
                  color: Colors.white,
                ),
                SizedBox(width: 10.w),
                const Expanded(
                  child: Text(
                    "Ups, pastikan wajah Anda terlihat jelas dengan cahaya yang cukup!",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
            backgroundColor: LightColors.kFagettiBlue,
            shape: const StadiumBorder(),
            behavior: SnackBarBehavior.floating,
          ));
        }
      });
    }
  }
}
