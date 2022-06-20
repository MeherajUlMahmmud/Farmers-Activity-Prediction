import 'dart:io';
import 'package:farmers_activity_prediction/services/api_service.dart';
import 'package:farmers_activity_prediction/utils/utility_func.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farmers_activity_prediction/utils/constants.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  AnimationController _controller;

  File _selectedFile;
  bool _isLoading = false;
  String imageUrl;
  String posture;
  String status;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: new Duration(seconds: 5));
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  void _selectImage(ImageSource source) async {
    PickedFile image = await ImagePicker().getImage(source: source);

    if (image != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          // maxWidth: 700,
          // maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.deepOrange,
            toolbarTitle: "Crop Image",
            statusBarColor: Colors.deepOrange.shade900,
            backgroundColor: Colors.white,
          ));

      this.setState(() {
        _selectedFile = cropped;
      });
    }
  }

  void _uploadImage() {
    if (_selectedFile != null) {
      setState(() {
        _isLoading = true;
        posture = "";
      });
      final Future<String> response = APIService.uploadPicture(_selectedFile);
      response.then(
        (value) {
          if (value != "Error") {
            setState(() {
              _isLoading = false;
            });
            print(value);
            setState(() {
              posture = value;
            });
            // UtilityFunction.showSnackbar(
            //     context, "Image uploaded successfully", true);
          } else {
            setState(() {
              _isLoading = false;
            });
            UtilityFunction.showSnackbar(
                context, "Error in predicting pose", false);
          }
        },
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      UtilityFunction.showSnackbar(context, "Please select an image", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 3.0,
        title: Text(APP_NAME),
      ),
      body: Container(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/93019-loading-18.json',
                    // animate: true,
                    // repeat: true,
                    controller: _controller,
                    onLoaded: (composition) {
                      _controller..duration = composition.duration;
                      _isLoading ? _controller.repeat() : _controller.reset();
                      // ..forward();
                    },
                  ),
                  Text(
                    "Predicting...",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : ListView(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: _selectedFile != null
                        ? Image.file(_selectedFile)
                        : imageUrl == null
                            ? Image.asset(
                                "assets/placeholder.jpg",
                                fit: BoxFit.cover,
                                width: 100.0,
                                height: 100.0,
                              )
                            : Image.network(
                                IMAGE_API + imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // show dialog to select image
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Select Image'),
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _selectImage(ImageSource.camera);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                        Text(' Camera'),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _selectImage(ImageSource.gallery);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.photo_library,
                                          color: Colors.white,
                                        ),
                                        Text(' Gallery'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text('Pick an Image'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        primary: Colors.white,
                        onPrimary: Colors.blue,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _uploadImage();

                        // setState(() {
                        //   _isLoading = true;
                        // });
                        // Future.delayed(Duration(seconds: 5), () {
                        //   setState(() {
                        //     _isLoading = false;
                        //   });
                        // });
                      },
                      child: Text('Upload and Predict Posture'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = false;
                          imageUrl = null;
                          _selectedFile = null;
                          posture = "";
                        });
                      },
                      child: Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        primary: Colors.grey,
                        textStyle: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  posture != null
                      ? Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  posture,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
      ),
    );
  }
}
