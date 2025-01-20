import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shop_pos_system_app/constants/app_colors.dart';

class FullScreenLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Black opaque background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
          ),
          // Centered loader
          Center(
            child: LoadingAnimationWidget.inkDrop(
              size: 50,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
