// vedio_call.dart

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dating_app/screens/chatscreen/vediocall/index.dart';
import 'package:dating_app/screens/chatscreen/vediocall/settings.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'call_controller.dart';

class VideoCall extends StatefulWidget {
  // **नया: IndexPage से data प्राप्त करने के लिए**
  final String channelName;
  final ClientRoleType? role;
  final int localUid;

  const VideoCall({
    Key? key,
    required this.channelName,
    required this.role,
    required this.localUid, // <--- UID प्राप्त करें
  }) : super(key: key);

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  // CallController को Get.lazyPut या Get.put से मैनेज करें
  final callCon = Get.put(CallController());

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // Turn on wakelock feature till call is running

    // **CallController को UID के साथ initialize करें**
    callCon.initilize(userUid: widget.localUid);
  }

  @override
  void dispose() {
    // Agora engine cleanup callCon.clear() में किया जाता है, 
    // जो onCallEnd() के माध्यम से होता है।
    WakelockPlus.disable(); // Turn off wakelock feature after call end
    super.dispose();
  }

  // स्थानीय वीडियो के लिए एक सहायक फ़ंक्शन
  Widget _localVideoView() {
    if (callCon.localUserJoined.value) {
      // सुनिश्चित करें कि यह आपके लोकल UID (जो IndexPage से पास हुआ है) के लिए है।
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: callCon.engine,
          canvas: const VideoCanvas(uid: 0), // uid: 0 लोकल यूज़र के लिए Agora का डिफ़ॉल्ट है जब आपने joinChannel में एक निश्चित UID पास किया हो।
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  // रिमोट वीडियो के लिए एक सहायक फ़ंक्शन
  Widget _remoteVideoView() {
    if (callCon.myremoteUid.value != 0) {
      if (callCon.videoPaused.value) {
        return Container(
          color: Theme.of(context).primaryColor,
          child: Center(
              child: Text(
                "Remote Video Paused",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.white70),
              )),
        );
      } else {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: callCon.engine,
            canvas: VideoCanvas(
                uid: callCon.myremoteUid.value), // <--- रिमोट UID
            connection: RtcConnection(
              channelId: widget.channelName, // <--- Channel Name
              localUid: widget.localUid,
            ),
          ),
        );
      }
    } else {
      return const Center(
        child: Text(
          'Waiting for Remote User...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.black,
          body: Obx(() => Padding(
            padding: EdgeInsets.all(10),
            child: Stack(
              children: [
                // **मुख्य (रिमोट) दृश्य**
                Center(
                  child: _remoteVideoView(),
                ),
                // **छोटा (लोकल) दृश्य**
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 100,
                    height: 150,
                    child: Center(
                      child: _localVideoView(),
                    ),
                  ),
                ),
                // **कंट्रोल बटन**
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    child: Row(
                      children: [
                        // Mute Audio
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              callCon.onToggleMute();
                            },
                            child: Icon(
                              callCon.muted.value
                                  ? Icons.mic_off // Mic Off है (म्यूट है)
                                  : Icons.mic, // Mic On है (अनम्यूट है)
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Call End
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              callCon.onCallEnd();
                            },
                            child: const Icon(
                              Icons.call_end, // कॉल एंड के लिए बदल दिया
                              size: 35,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        // Video On/Off (Mute Video)
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              callCon.onVideoOff();
                            },
                            child: Icon(
                              callCon.mutedVideo.value
                                  ? Icons.videocam_off // Video Off है (म्यूट है)
                                  : Icons.videocam, // Video On है (अनम्यूट है)
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Switch Camera
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              callCon.onSwitchCamera();
                            },
                            child: const Icon(
                              Icons.switch_camera,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ))),
    );
  }
}