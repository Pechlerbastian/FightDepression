import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Widget drawer;
  final Function onDrawerChanged;
  final Widget body;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.drawer,
    required this.onDrawerChanged,
    required this.body,
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          child: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
        title: Text(widget.title, style: Theme.of(context).textTheme.headline1)
      ),
      drawer: widget.drawer,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0) {
            _isDrawerOpen = true;
            _scaffoldKey.currentState!.openDrawer();
            widget.onDrawerChanged(_isDrawerOpen);
          } else {
            _isDrawerOpen = false;
            _scaffoldKey.currentState!.openEndDrawer();
            widget.onDrawerChanged(_isDrawerOpen);
          }
        },
        child: widget.body,
      ),
    );
  }
}