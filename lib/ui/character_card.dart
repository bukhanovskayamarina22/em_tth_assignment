import 'package:em_tth_assignment/data/models.dart';
import 'package:em_tth_assignment/ui/favorite_button.dart';
import 'package:flutter/material.dart';

class CharacterCard extends StatefulWidget {
  final Character character;
  final void Function(bool value) onFavoritePressed;

  const CharacterCard({required this.character, required this.onFavoritePressed, super.key});

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard> {
  bool isFavorite = false;

  @override
  void initState() {
    isFavorite = widget.character.isFavorite;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // adaptivity logic
    final screenWidth = MediaQuery.of(context).size.width;
    // displaying 2 cards per row
    final cardWidth = (screenWidth - 32) / 2;
    // the base size of a card is 180 px
    final scaleFactor = cardWidth / 180;
    final nameFontSize = (16 * scaleFactor).clamp(12.0, 20.0);
    final detailsFontSize = (12 * scaleFactor).clamp(10.0, 16.0);
    final iconSize = (20 * scaleFactor).clamp(16.0, 28.0);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(4 * scaleFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox.expand(
                      child: Image.network(
                        widget.character.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.person, size: iconSize * 2, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: RotatingFavoriteButton(
                      isFavorite: isFavorite,
                      onFavoritePressed: () {
                        setState(() {
                          isFavorite = !widget.character.isFavorite;
                        });
                        widget.onFavoritePressed(!widget.character.isFavorite);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Text content
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(top: 4 * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Character name
                    Text(
                      widget.character.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: nameFontSize),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Status
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(fontSize: detailsFontSize),
                        children: [
                          const TextSpan(text: 'Status: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: widget.character.status),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Type
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(fontSize: detailsFontSize),
                        children: [
                          const TextSpan(text: 'Type: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: widget.character.type.isEmpty ? 'Unknown' : widget.character.type),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}
