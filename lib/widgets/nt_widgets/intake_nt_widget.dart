import 'package:flutter/material.dart';

import 'package:dot_cast/dot_cast.dart';
import 'package:provider/provider.dart';

import 'package:elastic_dashboard/widgets/nt_widgets/nt_widget.dart';

class IntakeStateModel extends SingleTopicNTWidgetModel {
  @override
  String type = IntakeStateWidget.widgetType;

  IntakeStateModel({
    required super.ntConnection,
    required super.preferences,
    required super.topic,
    super.ntStructMeta,
    super.dataType,
    super.period,
  }) : super();

  IntakeStateModel.fromJson({
    required super.ntConnection,
    required super.preferences,
    required super.jsonData,
  }) : super.fromJson();
}

class IntakeStateWidget extends NTWidget {
  static const String widgetType = 'Intake State';

  const IntakeStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    IntakeStateModel model = cast(context.watch<NTWidgetModel>());

    return ValueListenableBuilder(
      valueListenable: model.subscription!,
      builder: (context, data, child) {
        String currentState = tryCast<String>(data) ?? 'INTAKE';

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
      case 'RETRACTED':
        return 'assets/logos/INTAKE_STOWED.png';
      case 'EXTENDED':
        return 'assets/logos/INTAKE_EXTENDED.png';
      case 'RUNNING':
        return 'assets/logos/INTAKE_MOVING.png';
      default:
        return 'assets/logos/INTAKE_STOWED.png';
    }
  }
}
