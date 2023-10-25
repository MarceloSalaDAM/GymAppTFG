import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardModel {
  final String title;
  final String description;

  CardModel(this.title, this.description);
}

class CardListView extends StatefulWidget {
  final Function(CardModel) onCardTap;
  final List<CardModel> cards; // Debes definir el parámetro 'cards' aquí

  CardListView({
    Key? key,
    required this.onCardTap,
    required this.cards, // Asegúrate de incluir 'cards' en el constructor
  }) : super(key: key);

  @override
  _CardListViewState createState() => _CardListViewState();
}

class _CardListViewState extends State<CardListView> {
  final List<CardModel> cards = [];

  @override
  void initState() {
    super.initState();
    _loadExercisesFromFirebase();
  }

  void _loadExercisesFromFirebase() async {
    await Firebase
        .initializeApp(); // Inicializa Firebase (debe hacerse una vez en la aplicación)

    final firestore = FirebaseFirestore.instance;
    final exerciseSnapshot = await firestore.collection('ejercicios').get();

    setState(() {
      cards.clear();
      for (var exercise in exerciseSnapshot.docs) {
        cards.add(CardModel(exercise['nombre'], exercise['descripcion']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: cards.map((card) {
        return CardItem(card, () {
          widget.onCardTap(card);
        });
      }).toList(),
    );
  }
}

class CardItem extends StatelessWidget {
  final CardModel card;
  final VoidCallback onPressed;

  CardItem(this.card, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(
          "RUTINA 1",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Rutina 1 de pruba app",
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        onTap: onPressed,
      ),
    );
  }
}

class CardDetail extends StatelessWidget {
  final CardModel card;

  CardDetail(this.card);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.title),
      ),
      body: Center(
        child: Text('Detalles de ${card.title}\n${card.description}'),
      ),
    );
  }
}
