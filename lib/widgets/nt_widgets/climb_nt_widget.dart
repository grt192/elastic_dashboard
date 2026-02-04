import 'package:flutter/material.dart';

import 'package:dot_cast/dot_cast.dart';
import 'package:provider/provider.dart';

import 'package:elastic_dashboard/widgets/nt_widgets/nt_widget.dart';

class ClimbStateModel extends SingleTopicNTWidgetModel {
  @override
  String type = ClimbStateWidget.widgetType;

  ClimbStateModel({
    required super.ntConnection,
    required super.preferences,
    required super.topic,
    super.ntStructMeta,
    super.dataType,
    super.period,
  }) : super();

  ClimbStateModel.fromJson({
    required super.ntConnection,
    required super.preferences,
    required super.jsonData,
  }) : super.fromJson();
}

class ClimbStateWidget extends NTWidget {
  static const String widgetType = 'Climb State';

  const ClimbStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ClimbStateModel model = cast(context.watch<NTWidgetModel>());

    return ValueListenableBuilder(
      valueListenable: model.subscription!,
      builder: (context, data, child) {
        String currentState = tryCast<String>(data) ?? 'CLIMB';

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
      case 'CLIMBED':
        return 'assets/logos/CLIMBED.png';
      case 'CLIMBING':
        return 'assets/logos/CLIMBING.png';
      case 'UNCLIMBED':
        return 'assets/logos/UNCLIMBED.png';
      default:
        return 'assets/logos/UNCLIMBED.png';
    }
  }
}
