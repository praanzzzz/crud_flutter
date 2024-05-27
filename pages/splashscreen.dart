import 'package:flutter/material.dart';
import 'package:crud_flutter/pages/home_page.dart';
import 'package:flutter/services.dart';


//stateful
class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _splashscreenState();
}


//state
class _splashscreenState extends State<splashscreen> 
  with SingleTickerProviderStateMixin{

  @override
  void initState(){
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(Duration(seconds: 4), (){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()));
    });
  }

  @override
  void dispose(){
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values
    );
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
         child: Image.asset(
        'assets/images/logos.png',
        width: 100, 
        fit: BoxFit.contain, 
      ),
      ),
    );
  }
}