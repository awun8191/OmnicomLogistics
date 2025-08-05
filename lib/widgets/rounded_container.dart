import 'package:flutter/material.dart';


Widget KRoundedContaier(BuildContext context, Widget? child, {double margin = 0.0, double height = 5, double padding = 10, double width = double.infinity}) {
  return Container(
    height: height,
    width: width,
    padding: EdgeInsets.all(padding),
    margin: EdgeInsets.all(margin),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondary
    ),
    child: child ?? Center(child: Text("data"),),
  );
}