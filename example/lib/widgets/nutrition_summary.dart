import 'package:flutter/material.dart';

class NutritionSummary extends StatelessWidget {
  const NutritionSummary({super.key, required this.values});

  final List<String> values;

  static const _height = 80.0;
  static const _gap = 3.0;
  static const _radius = Radius.circular(10);

  @override
  Widget build(BuildContext context) {
    final color = Colors.blueGrey[100];
    return Row(
      children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
            child: Container(
              height: _height,
              margin: EdgeInsetsDirectional.only(end: i == values.length - 1 ? 0 : _gap),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadiusDirectional.horizontal(
                  start: i == 0 ? _radius : Radius.zero,
                  end: i == values.length - 1 ? _radius : Radius.zero,
                ),
              ),
              child: Text(values[i]),
            ),
          ),
      ],
    );
  }
}
