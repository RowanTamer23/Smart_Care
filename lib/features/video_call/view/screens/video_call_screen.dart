import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class VideoCallPage extends StatelessWidget {
  final String callId; // Unique ID for the call room
  final String userId; // Unique ID of the local user
  final String userName; // Display name of the local user

  const VideoCallPage({
    super.key,
    required this.callId,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: 1877438367, // Replace with your actual AppID (integer)
      appSign:
          '6207afd6ad857c26d4f340bc176659583a7e5802c61b47dc6fcc36b4637ff9f6', // Replace with your actual AppSign
      userID: userId,
      userName: userName,
      callID: callId,
      // Select the 1-on-1 video call template
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}
