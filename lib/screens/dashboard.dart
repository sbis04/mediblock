import 'package:flutter/material.dart';
import 'package:mediblock/res/custom_colors.dart';
import 'package:mediblock/widgets/logo_widget.dart';

class DashboardPage extends StatefulWidget {
  final String userName;

  const DashboardPage({@required this.userName});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.dark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomColors.dark,
        title: LogoWidget(textSize: 26),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Container(),
        ),
      ),
    );
  }
}
