import 'package:blog/src/photoUpload.dart';
import 'package:blog/src/posts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  // imagen tomada de galeria
  String? url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _loadImages(),
              builder: (context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> image = snapshot.data![index];
///////////////////////////////////////////////////////////////////////imagenes
                      return Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              top: 30.0,
                              left: 20.0,
                            ),
                            height: 220.0,
                            width: 330.0,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(
                                    255, 4, 241, 4), //PARA PROBAR CONTAINER
                                borderRadius: new BorderRadius.circular(30.0),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    image['url'],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  new BoxShadow(
                                    //SOMBRA
                                    color: Color(0xffA4A4A4),
                                    offset: Offset(1.0, 5.0),
                                    blurRadius: 3.0,
                                  ),
                                ]),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  color: Colors.amber,
                                  child: Text(image['uploaded_by']),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          const Divider(
                            color: Colors.black,
                            //color: Theme.of(context).primaryColor,
                            height: 2.5,
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Link"),
                            validator: (value) {
                              return value!.isEmpty
                                  ? "Des vamos que vamos"
                                  : null;
                            },
                            onSaved: (value) {
                              // _myValue = value;
                            },
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                        ],
                      );
                    },
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.amber,
                  ),
                );
              },
            ),
          ),
          botonFlotante(),
        ],
      ),

      // aqui se van a mostrar
    );
  }

  Widget botonFlotante() {
    return BottomAppBar(
      color: Colors.pink,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add_a_photo),
              iconSize: 40,
              color: Colors.white,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return photoUpload();
                }));
              },
            )
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadImages() async {
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref().list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String imageUrl = await file.getDownloadURL();
      final FullMetadata fileMeta = await file.getMetadata();

      final data = files.add({
        "url": imageUrl,
        "path": file.fullPath,
        "uploaded_by": fileMeta.customMetadata?[
                'uploaded_by'] ?? ///////metadato carga desde el servidor
            'Home Free', ///////titulo
        "description": fileMeta.customMetadata?['description'] ??
            'Descripcion por servidor Servi',
      });
    });

    return files;
  }
}
