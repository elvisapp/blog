import 'package:blog/src/homePage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class photoUpload extends StatefulWidget {
  @override
  _photoUploadState createState() => _photoUploadState();
}

class _photoUploadState extends State<photoUpload> {
  //guarda la imagen seleccionada

  File? _image; // imagen tomada de galeria
  String? url; // url de la imagem
  String? _myValue; //descripción
  final formKey = GlobalKey<FormState>();

  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image"),
        centerTitle: true,
      ),
      body: Center(
        child: _image == null ? const Text("Select and Image") : enableUpload(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImage();
        },
        tooltip: "Add Image",
        backgroundColor: Colors.green,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  ///////////////////pegar foto
  Future<void> getImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  ///////////////////subir a storage
  void uploadStatusImage() async {
    if (validateAndSave()) {
      //Subir imagen a firebase storage
      final Reference postImageRef =
          FirebaseStorage.instance.ref().child("Post Images");
      var timeKey = DateTime.now();

      UploadTask uploadTask =
          postImageRef.child(timeKey.toString() + ".jpg").putFile(_image!);

      var imageUrl = await (await uploadTask).ref.getDownloadURL();
      url = imageUrl.toString();
      print(url);
      // Guardar el post en la bbdd
      saveToDatabase(url!);
      //Regresar en Home
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      // Image.network(url!, fit: BoxFit.cover);
    }
  }

  bool? saveToDatabase(String url) {
    var dbTimeKey = DateTime.now();
    var formatDate = DateFormat('MMM d, yyyy');
    var formatTime = DateFormat('EEEE, hh:mm aaa');
    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);
    DatabaseReference ref = FirebaseDatabase.instance.reference();
    var data = {
      "image": url,
      "description": _myValue,
      "date": date,
      "time": time,
    };
    ref.child("Posts").push().set(data);
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  //////////////mostrar imagen
  Widget enableUpload() {
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _image != null
                    ? Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        height: 400.0,
                        width: 600.0,
                      )
                    : const Text('Please select an image'),
                SizedBox(
                  height: 15.0,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Descripcion"),
                  validator: (value) {
                    return value!.isEmpty ? "es obligatorio" : null;
                  },
                  onSaved: (value) {
                    //return  _myValue = value;
                  },
                ),
                SizedBox(
                  height: 15.0,
                ),
                RaisedButton(
                  elevation: 10.0,
                  child: Text("add a new"),
                  textColor: Colors.white,
                  color: Colors.pink,
                  onPressed: uploadStatusImage,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget pruebaUrl() {
    return Container(
      child: Image.network(url!, fit: BoxFit.cover),
    );
  }
}
