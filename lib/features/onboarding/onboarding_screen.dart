import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/profile_provider.dart';
import '../../widgets/ui.dart';
import 'step_basics.dart';
import 'step_conditions.dart';
import 'step_goals.dart';
import 'step_diet.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentStep = 0;
  bool _isSaving = false;

  String? _ageRange;
  String? _biologicalSex;
  List<String> _conditions = [];
  List<String> _goals = [];
  String? _dietaryPreference;
  List<String> _allergies = [];
  List<String> _medications = [];

  static const _steps = [
    ('Baseline', 'The basics', 'Two data points that change how every scan is scored.'),
    ('Conditions', 'What we should know', 'Anything here reweights risks specifically for you.'),
    ('Goals', 'What you\'re after', 'We\'ll grade every scan against these.'),
    ('Intake', 'Diet, allergies, meds', 'So we can flag conflicts before they reach your plate.'),
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  void _loadExistingProfile() {
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile == null) return;
    setState(() {
      _ageRange = profile.ageRange;
      _biologicalSex = profile.biologicalSex;
      _conditions = List.from(profile.conditions);
      _goals = List.from(profile.goals);
      _dietaryPreference = profile.dietaryPreference;
      _allergies = List.from(profile.allergies);
      _medications = List.from(profile.medications);
    });
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _controller.nextPage(duration: kMotionSlow, curve: kCurveEmphasized);
      setState(() => _currentStep++);
    } else {
      _saveProfile();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _controller.previousPage(duration: kMotionSlow, curve: kCurveEmphasized);
      setState(() => _currentStep--);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(profileProvider.notifier).updateProfile({
        'ageRange': _ageRange,
        'biologicalSex': _biologicalSex,
        'conditions': _conditions,
        'goals': _goals,
        'dietaryPreference': _dietaryPreference,
        'allergies': _allergies,
        'medications': _medications,
      });
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) debugPrint('Failed to save profile: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Scaffold(
      child: Container(
        color: kBackground,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      IconSquare(icon: Icons.arrow_back_rounded, size: 38, onTap: _prevStep)
                    else
                      const SizedBox(width: 38, height: 38),
                    const Gap(16),
                    Expanded(
                      child: Row(
                        children: List.generate(4, (i) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
                              child: AnimatedContainer(
                                duration: kMotionSlow,
                                curve: kCurveEmphasized,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: i <= _currentStep ? kSignal : kSurfaceHighest,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const Gap(16),
                    Pressable(
                      onTap: () => context.go('/home'),
                      child: Text('SKIP', style: kLabel.copyWith(color: kOnSurfaceFaint)),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: kMotionBase,
                      switchInCurve: kCurveEmphasized,
                      child: Column(
                        key: ValueKey(_currentStep),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow('Calibration ${_currentStep + 1} / 4 — ${step.$1}'),
                          const Gap(12),
                          Text(step.$2, style: kHeadline.copyWith(fontSize: 28)),
                          const Gap(8),
                          Text(step.$3, style: kBody.copyWith(color: kOnSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),

              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StepBasics(
                      ageRange: _ageRange,
                      biologicalSex: _biologicalSex,
                      onAgeChanged: (v) => setState(() => _ageRange = v),
                      onSexChanged: (v) => setState(() => _biologicalSex = v),
                    ),
                    StepConditions(
                      selected: _conditions,
                      onChanged: (v) => setState(() => _conditions = v),
                    ),
                    StepGoals(
                      selected: _goals,
                      onChanged: (v) => setState(() => _goals = v),
                    ),
                    StepDiet(
                      dietaryPreference: _dietaryPreference,
                      allergies: _allergies,
                      medications: _medications,
                      onDietChanged: (v) => setState(() => _dietaryPreference = v),
                      onAllergiesChanged: (v) => setState(() => _allergies = v),
                      onMedicationsChanged: (v) => setState(() => _medications = v),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: AppButton(
                  label: _currentStep == 3 ? 'Finish calibration' : 'Continue',
                  icon: _currentStep == 3 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  loading: _isSaving,
                  onTap: _nextStep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
