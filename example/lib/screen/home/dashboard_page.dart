import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gojek_flutter/gojek_flutter.dart';

import '../login/login_page.dart';

import 'fragment/profile_fragment.dart';

class DashboardPage extends StatefulWidget {
	DashboardPage({ this.appTitle });
	
	String appTitle;
	
	final drawerItem = [
		new DrawerItem("Profil", Icons.person)
	];
	
	@override
	_DashboardPageState createState() => new _DashboardPageState(appTitle: appTitle);
}

class _DashboardPageState extends State<DashboardPage> {
	_DashboardPageState({ this.appTitle });
	
	String appTitle;
	
	GojekFlutter gojek = new GojekFlutter();
	
	String fullName;
	String email;
	double balance;
	
	int _selectedDrawerIndex = 0;
	
	_getDrawerItemWidget(int pos) {
		switch (pos) {
			case 0: return new ProfileFragment();
			default: return new Text("Error");
		}
	}

	_onSelectItem(int index) {
		setState(() => _selectedDrawerIndex = index);
		Navigator.of(context).pop(); // close the drawer
	}
	
	Future<String> setPreference(String index, String value) async {
		SharedPreferences preferences = await SharedPreferences.getInstance();
		setState(() => preferences.setString('${index}', '${value}') );
	}
	
	Future<String> getPreference(String index) async {
		SharedPreferences preferences = await SharedPreferences.getInstance();
		return preferences.getString(index);
	}
	
	Future checkBalance() async {
		gojek.authToken = await getPreference('authToken');
		
		final response = await gojek.checkBalance();
		print(response);
		return response['balance'].toDouble();
	}
	
	initPreference() async {
		fullName = await getPreference('fullName');
		email = await getPreference('email');
		
		balance = await checkBalance();
		
		setState(() => fullName = !["", null, false, 0].contains(fullName) ? fullName : " ");
		setState(() => email = !["", null, false, 0].contains(email) ? email : " ");
		setState(() => balance = !["", null, false, 0].contains(balance) ? balance : 0);
	}
	
	@override
	void initState() {
		super.initState();
		initPreference();
	}
	
	@override
	Widget build(BuildContext context) {
		var drawerOptions = <Widget>[];
		for (var i = 0; i < widget.drawerItem.length; i++) {
			var d = widget.drawerItem[i];
			drawerOptions.add(
				ListTile(
					leading: new Icon(d.icon),
					title: Text(d.title),
					trailing: new Icon(Icons.arrow_right),
					selected: i == _selectedDrawerIndex,
					onTap: () => _onSelectItem(i),
				)
			);
		}
		
		return Scaffold(
			appBar: AppBar(
				title: new Text(widget.drawerItem[_selectedDrawerIndex].title),
			),
			drawer: Drawer(
				child: Column(
					children: <Widget>[
						UserAccountsDrawerHeader(
							accountName: Container( padding: EdgeInsets.only(right: 20.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[ Text(fullName), Text('${balance}') ]) ),
							accountEmail: Text(email),
							currentAccountPicture: CircleAvatar(
								backgroundColor: Theme.of(context).platform == TargetPlatform.iOS ? Colors.blue : Colors.white,
								child: Text("${getInitials(fullName)}",style: TextStyle(fontSize: 40.0), ),
							),
						),
						Column(children: drawerOptions)
					]
				),
			),
			body: _getDrawerItemWidget(_selectedDrawerIndex),
		);
	}
	
	String getInitials(String nameString) {
		if (nameString.isEmpty) return " ";
		
		List<String> arrayValue = nameString.replaceAll(RegExp(r"\s+\b|\b\s"), " ").split(" ");
		List<String> nameArray = (arrayValue.length > 1) ? [ arrayValue[0], arrayValue[1] ] : [ arrayValue[0] ];
		
		String initials = ((nameArray[0])[0] != null ? (nameArray[0])[0] : " ") + (nameArray.length == 1 ? " " : (nameArray[nameArray.length - 1])[0]);
		
		return initials.toUpperCase();
	}
}

class DrawerItem {
	String title;
	IconData icon;
	
	DrawerItem(this.title, this.icon);
}
