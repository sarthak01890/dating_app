// call_controller.dart

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:dating_app/screens/chatscreen/vediocall/index.dart';
import 'package:dating_app/screens/chatscreen/vediocall/settings.dart';
import 'package:wakelock_plus/wakelock_plus.dart';


class CallController extends GetxController {
  RxInt myremoteUid = 0.obs;
  RxBool localUserJoined = false.obs;
  RxBool muted = false.obs;
  RxBool videoPaused = false.obs;
  RxBool switchMainView = false.obs;
  RxBool mutedVideo = false.obs;
  RxBool reConnectingRemoteView = false.obs;
  RxBool isFront = false.obs;
  late RtcEngine engine;

  // local user ID को स्टोर करने के लिए एक नई RxInt
  RxInt myLocalUid = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // initilize() को अब यहाँ से नहीं, बल्कि VideoCall से UID के साथ कॉल किया जाएगा।
  }

  @override
  void onClose() {
    super.onClose();
    clear();
  }

  clear() {
    engine.leaveChannel();
    isFront.value = false;
    reConnectingRemoteView.value = false;
    videoPaused.value = false;
    muted.value = false;
    mutedVideo.value = false;
    switchMainView.value = false;
    localUserJoined.value = false;
    myLocalUid.value = 0; // Local UID भी क्लियर करें
    update();
  }

  // **UID को एक पैरामीटर के रूप में स्वीकार करने के लिए अपडेट किया गया**
  Future<void> initilize({required int userUid}) async {
    myLocalUid.value = userUid; // Local UID को स्टोर करें

    Future.delayed(Duration.zero, () async {
      await _initAgoraRtcEngine();
      _addAgoraEventHandlers();
      await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      // Video Encoder Configuration ठीक है
      VideoEncoderConfiguration configuration = const VideoEncoderConfiguration();
      await engine.setVideoEncoderConfiguration(configuration);

      await engine.leaveChannel(); // सुनिश्चित करें कि पहले कोई चैनल जॉइन न हो

      // **यूनीक UID के साथ चैनल जॉइन करें**
      await engine.joinChannel(
        token: token,
        channelId: channgeId,
        uid: myLocalUid.value, // <--- यहाँ यूनीक UID का उपयोग किया गया है
        options: const ChannelMediaOptions(),
      );
      update();
    });
  }

  Future<void> _initAgoraRtcEngine() async {
    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    await engine.enableVideo();
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
  }

  void _addAgoraEventHandlers() {
    engine.registerEventHandler(
      RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print("****** LOCAL USER JOINED CHANNEL: UID ${myLocalUid.value} ******"); // <-- Log 1: अपना सफल कनेक्शन देखें
            localUserJoined.value = true;
            update();
          },
          // **onUserJoined को केवल रिमोट UID के लिए अपडेट किया गया**
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            // **Log 2: जब रिमोट यूजर जुड़ता है तो यह संदेश दिखेगा**
            print("****** REMOTE USER JOINED: UID $remoteUid ******");

            myremoteUid.value = remoteUid;
            update();
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            WakelockPlus.disable();
            myremoteUid.value = 0;
            onCallEnd(); // Disconnect पर कॉल एंड
            update();
          },
          onRemoteVideoStats:
              (RtcConnection connection, RemoteVideoStats remoteVideoStats) {
            if (remoteVideoStats.receivedBitrate == 0) {
              videoPaused.value = true;
              update();
            } else {
              videoPaused.value = false;
              update();
            }
          },
          onTokenPrivilegeWillExpire:
              (RtcConnection connection, String token) {},
          onLeaveChannel: (RtcConnection connection, stats) {
            // clear(); // clear() onCallEnd में कॉल हो रहा है
            // onCallEnd(); // onCallEnd() में clear() है और Get.offAll() है।
            update();
          }),
    );
  }

  void onVideoOff() {
    mutedVideo.value = !mutedVideo.value;
    engine.muteLocalVideoStream(mutedVideo.value);
    update();
  }

  void onCallEnd() {
    // WakelockPlus.disable() को onUserOffline या dispose() में कॉल करना बेहतर है
    clear();
    update();
    Get.offAll(() => IndexPage());
  }

  void onToggleMute() {
    muted.value = !muted.value;
    engine.muteLocalAudioStream(muted.value);
    update();
  }

  void onToggleMuteVideo() {
    mutedVideo.value = !mutedVideo.value;
    engine.muteLocalVideoStream(mutedVideo.value);
    update();
  }

  void onSwitchCamera() {
    engine.switchCamera().then((value) => {}).catchError((err) {});
  }
}