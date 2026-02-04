import 'package:flutter/material.dart';

import 'package:dot_cast/dot_cast.dart';
import 'package:provider/provider.dart';

import 'package:elastic_dashboard/widgets/nt_widgets/nt_widget.dart';

class ShooterStateModel extends SingleTopicNTWidgetModel {
  @override
  String type = ShooterStateWidget.widgetType;

  ShooterStateModel({
    required super.ntConnection,
    required super.preferences,
    required super.topic,
    super.ntStructMeta,
    super.dataType,
    super.period,
  }) : super();

  ShooterStateModel.fromJson({
    required super.ntConnection,
    required super.preferences,
    required super.jsonData,
  }) : super.fromJson();
}

class ShooterStateWidget extends NTWidget {
  static const String widgetType = 'Shooter State';

  const ShooterStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ShooterStateModel model = cast(context.watch<NTWidgetModel>());

    return ValueListenableBuilder(
      valueListenable: model.subscription!,
      builder: (context, data, child) {
        String currentState = tryCast<String>(data) ?? 'SHOOTER';

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(_getImageForState(currentState)),
            const SizedBox(height: 8),
            Text(
              currentState,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }

  String _getImageForState(String state) {
    switch (state) {
      case 'MOVING':
        return 'assets/logos/SHOOTER_MOVING.png';
      case 'RAMPING_UP':
        return 'assets/logos/SHOOTER_RAMPING_UP.png';
      case 'STOP':
        return 'assets/logos/SHOOTER_STOP.png';
      default:
        return 'assets/logos/SHOOTER_STOP.png';
    }
  }
}
