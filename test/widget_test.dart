// Basic smoke test for the score persistence manager.
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_stack_tower/managers/score_manager.dart';

void main() {
  test('ScoreManager starts at zero before loading', () {
    final sm = ScoreManager();
    expect(sm.best, 0);
  });
}
