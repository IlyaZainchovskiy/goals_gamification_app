import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goals_gamification_app/core/constants/app_colors.dart';

void main() {
  test('AppColors містить усі необхідні кольори', () {
    expect(AppColors.primary, isA<Color>());
    expect(AppColors.secondary, isA<Color>());
    expect(AppColors.error, isA<Color>());
    expect(AppColors.background, isA<Color>());
    
    expect(AppColors.highPriority, isA<Color>());
    expect(AppColors.mediumPriority, isA<Color>());
    expect(AppColors.lowPriority, isA<Color>());
  });
}