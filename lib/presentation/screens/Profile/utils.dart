import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async{
  final ImagePicker _imagePicker=ImagePicker();
  //this is class in photo manager dart package which contains information of image like path, size
  XFile? _file= await _imagePicker.pickImage(source: source);
  if(_file != null){
    return _file.readAsBytes();
  }
  //no image selected
  print("No image Selected");
}
