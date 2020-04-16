import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gojek_flutter/gojek_flutter.dart';

class ProfileFragment extends StatefulWidget {
	@override
	_ProfileFragmentState createState() => new _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
	GojekFlutter gojek = new GojekFlutter();
	
	Future<String> getPreference(String index) async {
		SharedPreferences preferences = await SharedPreferences.getInstance();
		return preferences.getString(index);
	}
	
	@override
	void initState() {
		super.initState();
	}
	
	@override
	Widget build(BuildContext context) {
		return Center(
			child: new Text('Profile Fragment'),
		);
	}
}
