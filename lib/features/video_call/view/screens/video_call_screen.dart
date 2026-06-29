import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:smart_care/core/routes/routes.dart';

class VideoCallPage extends StatelessWidget {
  final String callId; // Unique ID for the call room
  final String userId; // Unique ID of the local user
  final String userName; // Display name of the local user
  final String? patientId;
  final String? patientName;

  const VideoCallPage({
    super.key,
    required this.callId,
    required this.userId,
    required this.userName,
    this.patientId,
    this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ZegoUIKitPrebuiltCall(
            appID: 1877438367, // Replace with your actual AppID (integer)
            appSign:
                '6207afd6ad857c26d4f340bc176659583a7e5802c61b47dc6fcc36b4637ff9f6', // Replace with your actual AppSign
            userID: userId,
            userName: userName,
            callID: callId,
            // Select the 1-on-1 video call template
            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
          ),
          if (patientId != null && patientName != null)
            Positioned(
              top: 50,
              right: 16,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.videoCall,
                          arguments: {
                            'callId': callId,
                            'userId': patientId!,
                            'userName': patientName!,
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5C518),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_add_rounded,
                                color: Color(0xFF0D3B38),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Launch Patient App Call',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Simulate: $patientName',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
