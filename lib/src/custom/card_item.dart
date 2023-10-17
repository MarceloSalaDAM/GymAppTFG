import 'package:flutter/material.dart';

class CardModel {
  final String title;
  final String description;

  CardModel(this.title, this.description);
}

class CardListView extends StatelessWidget {
  final List<CardModel> cards;
  final Function(CardModel) onCardTap;

  const CardListView({super.key,
    required this.cards,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: cards.map((card) {
        return CardItem(card, () {
          onCardTap(card);
        });
      }).toList(),
    );
  }
}

class CardItem extends StatelessWidget {
  final CardModel card;
  final VoidCallback onPressed;

  const CardItem(this.card, this.onPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Añade sombra a la tarjeta
      margin: const EdgeInsets.all(10), // Margen alrededor de la tarjeta
      child: ListTile(
        title: Text(
          card.title,
          style: const TextStyle(
            fontSize: 18, // Tamaño de fuente del título
            fontWeight: FontWeight.bold, // Texto en negrita
          ),
        ),
        subtitle: Text(
          card.description,
          style: const TextStyle(
            fontSize: 14, // Tamaño de fuente de la descripción
          ),
        ),
        onTap: onPressed,
      ),
    );
  }
}

class CardDetail extends StatelessWidget {
  final CardModel card;

  const CardDetail(this.card, {super.key});

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
