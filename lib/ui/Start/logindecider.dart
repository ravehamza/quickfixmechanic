import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:quickfixmechanic/Resources/Internet/check_network_connection.dart';
import 'package:quickfixmechanic/ui/Mycolors.dart';
import 'package:quickfixmechanic/ui/Pages/home.dart';
import 'package:quickfixmechanic/ui/Pages/puncturehome.dart';
import 'package:quickfixmechanic/ui/Pages/waiting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'Login/Login.dart';


class LoginDecider extends StatefulWidget {
  @override
  _LoginDeciderState createState() => _LoginDeciderState();
}

class _LoginDeciderState extends State<LoginDecider> {
  static const platform = const MethodChannel('samples.flutter.dev/battery');

  bool _inter=false;

  @override
  void initState() {
    _checklogin();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body:Container(
              color: background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("forveel partner",style: GoogleFonts.lato(color: textc,fontSize: 40),),
                    SizedBox(height: 10,),
                    (_inter)?
                    _nointernet()
                        :SpinKitWave(color: textc,)
                  ],
                ),
              ),
            )
    );
  }

  _checklogin()
  async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('userlogin'))
    {
      if(prefs.getString('userlogin')!="0")
      {
        _startActivity(prefs.getString('userlogin'));
      }
      else if(prefs.getString('userlogin')=="0")
        {
          Navigator.push(context, PageTransition(
              child: Login(),
              type: PageTransitionType.fade,
              duration: Duration(milliseconds: 50)
          ));
        }
    }
    else{
      prefs.setString('userlogin', "0");
      Navigator.push(context, PageTransition(
          child: Login(),
          type: PageTransitionType.fade,
          duration: Duration(milliseconds: 50)
      ));
    }
  }


  _getuser(id)async{
    if(await IsConnectedtoInternet()){
      setState(() {
        _inter=true;
      });
      return;
    }
    Firestore.instance.collection("mechanic").document(id).get().then((value){
      if(!value.exists) {
        Navigator.push(context, PageTransition(
            child: Login(),
            type: PageTransitionType.fade,
            duration: Duration(milliseconds: 50)
        ));
      }
      else{
        if(value['verified']){
          if(value["onlypuncture"]){
            Navigator.push(context, PageTransition(
                child: PunctureHome(value),
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 50)
            ));
          }else{
            Navigator.push(context, PageTransition(
                child: Home(value),
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 50)
            ));
          }

        }
        else{
          Navigator.push(context, PageTransition(
              child: waiting(value),
              type: PageTransitionType.fade,
              duration: Duration(milliseconds: 50)
          ));
        }

      }
    });


  }



  Future<void> _startActivity(uid) async {
    try {
      String result = await platform.invokeMethod('StartSecondActivity');
      if(result=="success")
      {
        _getuser(uid);
      }
      else{
        Toast.show("Please allow location permission", context);
        SystemNavigator.pop();
      }
    } on PlatformException catch (e) {
      debugPrint("Error: '${e.message}'.");
      Toast.show("Please allow location permission", context);
      SystemNavigator.pop();
    }
  }


  Widget _nointernet(){
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.error,color: Colors.red,size: 70,),
          SizedBox(height: 7,),
          Text("No Internet"),
          SizedBox(height: 7,),
          OutlineButton(
            borderSide: BorderSide(color: Colors.blue.shade700),
            child: Text("Retry"),
            onPressed: (){
              setState(() {
                _inter=false;
              });
              _checklogin();
            },
          )
        ],
      ),
    );
  }

}





