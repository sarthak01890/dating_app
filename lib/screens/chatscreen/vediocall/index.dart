// index.dart

import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:dating_app/screens/chatscreen/vediocall/video_call.dart';
import 'package:flutter/material.dart';
import 'package:dating_app/screens/chatscreen/vediocall/index.dart';
import 'package:dating_app/screens/chatscreen/vediocall/settings.dart';
import 'package:permission_handler/permission_handler.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  final _channelController = TextEditingController(text: channgeId); // Default value set
  bool _validateError = false;

  ClientRoleType? _role = ClientRoleType.clientRoleBroadcaster;

  // **नया: लोकल UID को ट्रैक करने के लिए**
  int _uid = uidBroadcaster;

  @override
  void initState() {
    super.initState();
    _setUidBasedOnRole(_role); // Role के आधार पर UID सेट करें
  }

  void _setUidBasedOnRole(ClientRoleType? role) {
    if (role == ClientRoleType.clientRoleBroadcaster) {
      _uid = uidBroadcaster; // 1
    } else if (role == ClientRoleType.clientRoleAudience) {
      _uid = uidAudience; // 2
    }
  }

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agora Calling'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 400,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _channelController,
                      decoration: InputDecoration(
                        errorText:
                        _validateError ? 'Channel name is mandatory' : null,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(width: 1),
                        ),
                        hintText: 'Channel name',
                      ),
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  ListTile(
                    title: Text('Broadcaster (UID: $uidBroadcaster)'),
                    leading: Radio(
                      value: ClientRoleType.clientRoleBroadcaster,
                      groupValue: _role,
                      onChanged: (ClientRoleType? value) {
                        setState(() {
                          _role = value;
                          _setUidBasedOnRole(value);
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Audience (UID: $uidAudience)'),
                    leading: Radio(
                      value: ClientRoleType.clientRoleAudience,
                      groupValue: _role,
                      onChanged: (ClientRoleType? value) {
                        setState(() {
                          _role = value;
                          _setUidBasedOnRole(value);
                        });
                      },
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onJoin,
                        child: const Text('Video Call'),
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.blueAccent),
                            foregroundColor:
                            MaterialStateProperty.all(Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);

      // **UID को VideoCall पेज पर पास करें**
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCall(
            channelName: _channelController.text,
            role: _role,
            localUid: _uid, // <--- यूनीक UID यहाँ पास किया गया है
          ),
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}