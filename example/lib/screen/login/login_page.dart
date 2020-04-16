import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gojek_flutter/gojek_flutter.dart';

import '../home/dashboard_page.dart';

class LoginPage extends StatefulWidget {
	LoginPage({ this.appTitle });
	
	String appTitle;
	
	@override
	_LoginPageState createState() => new _LoginPageState(appTitle: appTitle);
}

class _LoginPageState extends State<LoginPage> {
	_LoginPageState({ this.appTitle });
	
	GojekFlutter gojek = new GojekFlutter();
	
	final mobileController = TextEditingController();
	final OTPController = TextEditingController();
	
	String appTitle;
	bool _obscureText = true;
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar( title: Center(child: Text(appTitle)), ),
			body: Container(
				color: Colors.white,
				child: ListView(
					shrinkWrap: true,
					padding: EdgeInsets.only(left: 24.0, right: 24.0),
					children: <Widget>[
						SizedBox(height: 40.0),
						Hero(
							tag: 'hero',
							child: CircleAvatar(
								backgroundColor: Colors.transparent,
								radius: 80.0,
								child: Image.asset('assets/images/bat.png'),
							),
						),
						SizedBox(height: 10.0),
						TextFormField(
							keyboardType: TextInputType.number,
							autofocus: true,
							controller: mobileController,
							decoration: InputDecoration(
								hintText: 'Masukan nomor handphone',
								labelText: 'Phone Number',
								contentPadding: EdgeInsets.all(10.0),
								border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))
							),
						),
						SizedBox(height: 15.0),
						Padding(
							padding: EdgeInsets.symmetric(vertical: 20.0),
							child: Material(
								borderRadius: BorderRadius.circular(30.0),
								shadowColor: Colors.lightBlueAccent.shade100,
								elevation: 0.0,
								child: MaterialButton(
									minWidth: 200.0,
									height: 42.0,
									onPressed: () { loginPhone(context); },
									color: Colors.lightBlueAccent,
									child: Text('Masuk', style: TextStyle(color: Colors.white)),
								),
							),
						),
					],
				),
			)
		);
	}
	
	Future<void> alert(BuildContext context, String info) {
		return showDialog<void>(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: Text('Warning !'),
					content: Text(info),
					actions: <Widget>[
						FlatButton(
							child: Text('Ok'),
							onPressed: () {
							  Navigator.of(context).pop();
							},
						),
					],
				);
			},
		);
	}
	
	Future<String> setPreference(String index, String value) async {
		SharedPreferences preferences = await SharedPreferences.getInstance();
		setState(() { preferences.setString('${index}', '${value}'); });
	}
	
	Future<String> getPreference(String index) async {
		SharedPreferences preferences = await SharedPreferences.getInstance();
		return preferences.getString(index);
	}
	
	// STEP loginPhone GOJEK FLUTTER
	
	Future<String> loginPhone(BuildContext context) async {
		
		
		final response = await gojek.loginPhone(mobileController.text);
		
		if (["", null, false, 0].contains(response['loginToken'])) {
			if (!["", null, false, 0].contains(response['code'])) {
				alert(context, response['message']);
			} else {
				alert(context, 'Response loginPhone take data loginToken not found !');
			}
		} else {
			setState(() { setPreference('loginToken', response['loginToken']); });
			dialogOTP(context);
		}
	}
	
	Future<String> dialogOTP(BuildContext context) async {
		return showDialog<String>(
			context: context,
			barrierDismissible: false, // dialog is dismissible with a tap on the barrier
			builder: (BuildContext context) {
				return AlertDialog(
					title: Text('Masukan kode OTP'),
					content: new Row(
						children: <Widget>[
							Expanded(
								child: new TextField(
									keyboardType: TextInputType.number,
									obscureText: true,
									autofocus: true,
									controller: OTPController,
									decoration: InputDecoration(labelText: 'Kode OTP', hintText: 'XXXX'),
								)
							)
						],
					),
					actions: <Widget>[
						FlatButton(
							child: Text('Proses'),
							onPressed: () { loginGojek(context); },
						),
					],
				);
			},
		);
	}
	
	// STEP loginGojek GOJEK FLUTTER
	
	Future<String> loginGojek(BuildContext context) async {
		final loginToken = await getPreference('loginToken');
		final response = await gojek.loginGojek(loginToken, OTPController.text);
		print(response);
		if (["", null, false, 0].contains(response['authToken'])) {
			if (!["", null, false, 0].contains(response['code'])) {
				alert(context, response['message']);
			} else {
				alert(context, 'Response loginGojek take data authToken not found !');
			}
		} else {
			setState(() { setPreference('fullName', response['fullName']); });
			setState(() { setPreference('email', response['email']); });
			setState(() { setPreference('phoneNumber', response['phoneNumber']); });
			setState(() { setPreference('authToken', response['authToken']); });
			
			Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardPage(appTitle: appTitle)));
		}
	}
}
