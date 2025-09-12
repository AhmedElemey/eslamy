import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textSize = ref.watch(textSizeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Text size', style: theme.textTheme.titleMedium),
              Text(
                'Adjust the text size across the app. 0 is default.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              textSize.when(
                data: (current) {
                  const options = [0, 4, 8, 10];
                  final currentIndex =
                      options.indexOf(current).clamp(0, options.length - 1);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        value: currentIndex.toDouble(),
                        min: 0,
                        max: (options.length - 1).toDouble(),
                        divisions: options.length - 1,
                        label: options[currentIndex].toString(),
                        onChanged: (v) {
                          final idx = v.round().clamp(0, options.length - 1);
                          final delta = options[idx];
                          ref
                              .read(textSizeProvider.notifier)
                              .setTextSize(delta);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                            options.map((e) => Text(e.toString())).toList(),
                      ),
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
