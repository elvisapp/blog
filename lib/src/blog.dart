import 'dart:io';

import 'package:flutter/material.dart';

class BlogHome extends StatefulWidget {
  @override
  _BlogHomeState createState() => _BlogHomeState();
}

class _BlogHomeState extends State<BlogHome> {
  File? _image;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Vamos que vamos'),
        _image != null
            ? Image.file(
                _image!,
                fit: BoxFit.cover,
                height: 400.0,
                width: 600.0,
              )
            : const Text('Please select an image'),
      ],
    );
  }
}
