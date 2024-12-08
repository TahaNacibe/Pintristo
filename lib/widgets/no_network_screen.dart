import 'package:flutter/material.dart';
import 'package:pintresto/services/network_services.dart';

class NoNetworkScreen extends StatefulWidget {
  final void Function(bool state) onCheck;
  const NoNetworkScreen({required this.onCheck, super.key});

  @override
  State<NoNetworkScreen> createState() => _NoNetworkScreenState();
}

class _NoNetworkScreenState extends State<NoNetworkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          ConnectivityServices().isConnected().then((value) {
            if (value) {
              widget.onCheck(value);
            }
          });
        },
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 35,
              ),
              Text(
                "No Internet Connection",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25),
              )
            ],
          ),
        ),
      ),
    );
  }
}
