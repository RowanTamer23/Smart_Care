import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCallPage extends StatelessWidget {
  final String callId; // Unique ID for the call room
  final String userId; // Unique ID of the local user
  final String userName; // Display name of the local user

  const VideoCallPage({
    Key? key,
    required this.callId,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: 123456789, // Replace with your actual AppID (integer)
      appSign: 'your_app_sign_string', // Replace with your actual AppSign
      userID: userId,
      userName: userName,
      callID: callId,
      // Select the 1-on-1 video call template
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}
