import 'package:flutter/material.dart';

class PinchZoomImage extends StatefulWidget {
  Image img;
  PinchZoomImage({required this.img, super.key});

  @override
  State<PinchZoomImage> createState() => _PinchZoomImageState();
}

class _PinchZoomImageState extends State<PinchZoomImage> with SingleTickerProviderStateMixin {
  late TransformationController controller;
  late AnimationController animationController;
  Animation<Matrix4>? animation;

  final double maxScale = 4;
  double scale = 1;

  OverlayEntry? entry;

  @override
  void initState() {
    super.initState();
    controller = TransformationController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200)
      )..addListener(() => controller.value = animation!.value)
      ..addStatusListener((status) {
        if(status==AnimationStatus.completed) {
          removeOverlay();
        }
      });
  }

  @override
  void dispose() {
    controller.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: buildImage(),
  );

  Widget buildImage() {
    return InteractiveViewer(
      transformationController: controller,
      clipBehavior: Clip.none,
      minScale: 1,
      maxScale: maxScale,
      onInteractionStart: ((details) {
        if(details.pointerCount < 2) return;
        showOverlay(context);
      }),
      onInteractionUpdate: ((details) {
        if (entry==null) return;
        scale = details.scale;
        entry!.markNeedsBuild();
      }),
      onInteractionEnd: (details) {
          debugPrint("Interaction End!!!");
          resetAnimation();
      },
      panEnabled: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(borderRadius: BorderRadius.circular(20),
          child: widget.img
          )
        )
    );
  }
  
  void resetAnimation() {
    animation = Matrix4Tween(
      begin: controller.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInExpo));
      animationController.forward(from:0);
  }
  
  void showOverlay(BuildContext context) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = MediaQuery.of(context).size;
    entry = OverlayEntry(
      builder: (context){
        final double opacity = ((scale - 1)/ (maxScale -1 )).clamp(0,1);
        return Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: opacity,
                child: Container(color: Colors.black)),
              
              ),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              width: size.width,
              child:buildImage(),
          )
          ],
        );
    });

    final overlay = Overlay.of(context);
    overlay.insert(entry!);
  }
  
  void removeOverlay() {
    entry?.remove();
    entry = null;
  }
  }