import 'package:flutter/material.dart';

class ReservationData extends ChangeNotifier{
  Map<String, List<DateTime>> reservations =
  {
    'startDatetime' : List<DateTime>.empty(growable: true),
    'endDatetime' : List<DateTime>.empty(growable: true)
  };
}