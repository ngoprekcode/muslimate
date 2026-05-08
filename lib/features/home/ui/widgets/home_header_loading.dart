import 'package:flutter/material.dart';
import 'package:muslimate/shared/widgets/app_shimmer.dart';

class HomeHeaderLoading extends StatelessWidget {
  const HomeHeaderLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: AppShimmer(
        width: double.infinity,
        height: 180,
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    );
  }
}
