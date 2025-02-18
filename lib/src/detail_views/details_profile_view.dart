import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../custom/picker_button.dart';

class DetailsProfileView extends StatefulWidget {
  const DetailsProfileView({Key? key}) : super(key: key);

  @override
  _DetailsProfileViewState createState() => _DetailsProfileViewState();
}

class _DetailsProfileViewState extends State<DetailsProfileView> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String selectedEdad = '16';
  String selectedEstatura = '100';
  String selectedGenero = 'Hombre';
  String selectedPeso = '40';
  String? _imagePath;
  late TextEditingController nombreController;
  bool _isEditing = false;
  bool _isImageLoading = false;
  bool _isLoading = true;

  late String _initialNombre = '';
  late String _initialEdad = '';
  late String _initialGenero = '';
  late String _initialEstatura = '';
  late String _initialPeso = '';
  late String _ultimaModFija='';


  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController();
    Future.delayed(const Duration(seconds: 1), () {
      loadUserData();
    });
  }

  Future<void> loadUserData() async {
    String? idUser = FirebaseAuth.instance.currentUser?.uid;
    final docRef = db.collection("usuarios").doc(idUser);

    // Establecer _isLoading en true antes de cargar los datos
    setState(() {
      _isLoading = true;
    });

    DocumentSnapshot docsnap = await docRef.get();

    if (docsnap.exists) {
      Map<String, dynamic> userData = docsnap.data() as Map<String, dynamic>;
      setState(() {
        nombreController.text = userData['nombre'];
        selectedEdad = userData['edad'];
        selectedGenero = userData['genero'];
        selectedEstatura = userData['estatura'];
        selectedPeso = userData['peso'];
        _imagePath = userData['imageURL'];

        _initialNombre = nombreController.text;
        _initialEdad = selectedEdad;
        _initialGenero = selectedGenero;
        _initialEstatura = selectedEstatura;
        _initialPeso = selectedPeso;
        // Establecer la fecha y hora de la última modificación
        Timestamp? ultimaModTimestamp = userData['ultimaMod'];
        DateTime? ultimaModDateTime;

        if (ultimaModTimestamp != null) {
          ultimaModDateTime = ultimaModTimestamp.toDate();
          _ultimaModFija = DateFormat('dd/MM/yyyy HH:mm').format(ultimaModDateTime);
        } else {
          _ultimaModFija = ' ';
        }

        // Establecer _isLoading en false después de cargar los datos
        _isLoading = false;
      });
    }
  }

  void _revertChanges() {
    loadUserData();
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _cargarFoto() async {
    setState(() {
      _isImageLoading = true;
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var file = File(pickedFile.path);
      String filename = 'profile_image.jpg';
      Reference ref =
      FirebaseStorage.instance.ref().child("profileImages/$filename");
      UploadTask uploadTask = ref.putFile(file);

      await uploadTask.whenComplete(() async {
        String imageUrl = await ref.getDownloadURL();
        setState(() {
          _imagePath = imageUrl;
          _isImageLoading = false;
        });
      });
    } else {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  void acceptPressed(
      String nombre,
      String edad,
      String genero,
      String estatura,
      String peso,
      ) async {
    try {
      String? idUser = FirebaseAuth.instance.currentUser?.uid;
      final docRef = db.collection("usuarios").doc(idUser);

      // Obtener la fecha y hora actual
      DateTime now = DateTime.now();

      // Formatear la fecha y hora actual como "dd/MM/yyyy HH:mm"
      String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(now);

      await docRef.update({
        'nombre': nombre,
        'edad': edad,
        'genero': genero,
        'estatura': estatura,
        'peso': peso,
        'imageURL': _imagePath,
        'ultimaMod': now,
        // Actualizar la fecha y hora de la última modificación
      });

      // Actualizar el valor de ultimaMod en el estado local
      setState(() {
        _ultimaModFija = formattedDate;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados con éxito.'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar los datos: $error'),
        ),
      );
    }
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNonEditableField(String label, String value) {
    return _buildDataRow(label, value);
  }

  Widget _buildEditableField(String label, List<String> options,
      String selectedValue, void Function(String?)? onChanged) {
    return PickerButton<String>(
      titulo: label,
      opciones: options,
      valorSeleccionado: selectedValue,
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label, String value, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: isEditing
          ? TextFormField(
        controller: nombreController,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      )
          : _buildDataRow(label, value),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón adicional solo si _isEditing es true
          if (_isEditing)
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return WillPopScope(
                      // Evitar que se cierre el diálogo con el botón de retroceso del dispositivo
                      onWillPop: () async => false,
                      child: AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        title: const Text(
                          'SALIR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        content: const Text(
                            '¿Estás seguro de que deseas salir? Perderás los cambios'),
                        actions: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Cierra el cuadro de diálogo
                                  _revertChanges();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Aceptar',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.cancel, size: 30, color: Colors.white),
              label: const Text(
                "CANCELAR",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize:
                const Size(140, 50), // Ajusta el tamaño según sea necesario
              ),
            ),

          // Spacer para agregar espacio entre los dos botones
          const Spacer(),

          ElevatedButton.icon(
            onPressed: () {
              if (_isEditing) {
                acceptPressed(
                  nombreController.text,
                  selectedEdad,
                  selectedGenero,
                  selectedEstatura,
                  selectedPeso,
                );
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(_isEditing ? Icons.save_alt : Icons.edit,
                size: 30, color: Colors.white),
            label: Text(
              _isEditing ? 'GUARDAR' : 'EDITAR',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0XFF0f7991),
              minimumSize:
              const Size(140, 50), // Ajusta el tamaño según sea necesario
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: const BoxDecoration(
                  color: Color(0XFFDADADA),
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 2),
                    top: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                  width: 140.0,
                  height: 140.0,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: Center(
                    child: InkWell(
                      onTap: _isEditing ? _cargarFoto : null,
                      child: Container(
                        width: 140.0,
                        height: 140.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: _isImageLoading
                              ? const CircularProgressIndicator()
                              : _imagePath != null
                              ? Image.network(
                            _imagePath!,
                            fit: BoxFit.cover,
                          )
                              : const Center(
                            child: Icon(
                              Icons.add_a_photo,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Espacio entre la imagen y el texto de última modificación
              Text(
                'Última modificación: $_ultimaModFija',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildTextField(
                            'NOMBRE', nombreController.text, _isEditing),
                        const Divider(height: 25),
                        _isEditing
                            ? _buildEditableField(
                            'GÉNERO',
                            ['Hombre', 'Mujer', 'Otro'],
                            selectedGenero, (newValue) {
                          setState(() {
                            selectedGenero = newValue!;
                          });
                        })
                            : _buildNonEditableField('GÉNERO', selectedGenero),
                        const Divider(height: 25),
                        _isEditing
                            ? _buildEditableField(
                            'EDAD',
                            List.generate(
                                55, (index) => (16 + index).toString()),
                            selectedEdad, (newValue) {
                          setState(() {
                            selectedEdad = newValue!;
                          });
                        })
                            : _buildNonEditableField('EDAD', selectedEdad),
                        const Divider(height: 25),
                        _isEditing
                            ? _buildEditableField(
                            'ESTATURA (cm)',
                            List.generate(
                                221, (index) => (100 + index).toString()),
                            selectedEstatura, (newValue) {
                          setState(() {
                            selectedEstatura = newValue!;
                          });
                        })
                            : _buildNonEditableField(
                            'ESTATURA (cm)', selectedEstatura),
                        const Divider(height: 25),
                        _isEditing
                            ? _buildEditableField(
                            'PESO (kg)',
                            List.generate(
                                160, (index) => (40 + index).toString()),
                            selectedPeso, (newValue) {
                          setState(() {
                            selectedPeso = newValue!;
                          });
                        })
                            : _buildNonEditableField('PESO (kg)', selectedPeso),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !_isLoading,
                child: _buildBottomNavigationBar(),
              ),
            ],
          ),
          // Widget de carga
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
