import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:elastic_dashboard/widgets/draggable_containers/models/widget_container_model.dart';
import 'package:elastic_dashboard/widgets/gesture/drag_listener.dart';

class WidgetDragTile extends StatefulWidget {
  final int gridIndex;
  final String title;
  final IconData icon;
  final WidgetContainerModel Function() widgetBuilder;
  final void Function(Offset globalPosition, WidgetContainerModel widget)
  onDragUpdate;
  final void Function(WidgetContainerModel widget) onDragEnd;
  final void Function() onRemoveWidget;

  const WidgetDragTile({
    super.key,
    required this.gridIndex,
    required this.title,
    required this.icon,
    required this.widgetBuilder,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onRemoveWidget,
  });

  @override
  State<WidgetDragTile> createState() => _WidgetDragTileState();
}

class _WidgetDragTileState extends State<WidgetDragTile> {
  WidgetContainerModel? draggingWidget;

  void cancelDrag() {
    if (draggingWidget != null) {
      draggingWidget?.dispose();
      widget.onRemoveWidget();
      draggingWidget = null;
    }
  }

  @override
  void didUpdateWidget(WidgetDragTile oldWidget) {
    if (widget.gridIndex != oldWidget.gridIndex) cancelDrag();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    cancelDrag();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () {},
    child: DragListener(
      onDragStart: (details) {
        if (draggingWidget != null) return;
        if (details.kind != null &&
            details.kind! == PointerDeviceKind.trackpad) {
          draggingWidget = null;
          return;
        }
        setState(() {
          draggingWidget = widget.widgetBuilder.call();
        });
      },
      onDragUpdate: (details) {
        if (draggingWidget == null) return;
        widget.onDragUpdate.call(details.globalPosition, draggingWidget!);
      },
      onDragEnd: (details) {
        if (draggingWidget == null) return;
        widget.onDragEnd.call(draggingWidget!);
        setState(() {
          draggingWidget = null;
        });
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 16.0),
        child: ListTile(
          style: ListTileStyle.drawer,
          contentPadding: const EdgeInsets.only(right: 20.0),
          leading: Icon(widget.icon),
          title: Text(widget.title),
        ),
      ),
    ),
  );
}
