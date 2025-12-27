import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class TopicSelectionDialog extends StatelessWidget {
  const TopicSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: AlertDialog(
          title: const Text('More Topics'),
          content: SizedBox(
            width: double.maxFinite,
            child: Consumer<GameProvider>(
              builder: (context, provider, child) {
                final allTopics = provider.allTopics;
                
                if (allTopics.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No topics available'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: allTopics.length,
                  itemBuilder: (context, index) {
                    final topic = allTopics[index];
                    final isEnabled = provider.isTopicEnabled(topic.id);

                    return SwitchListTile(
                      title: Text(
                        topic.displayName,
                        style: theme.textTheme.bodyLarge,
                      ),
                      value: isEnabled,
                      onChanged: (value) {
                        provider.toggleTopicEnabled(topic.id);
                      },
                      activeColor: colorScheme.primary,
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            Consumer<GameProvider>(
              builder: (context, provider, child) {
                final enabledCount = provider.availableTopics.length;
                final canClose = enabledCount > 1;

                return TextButton(
                  onPressed: canClose
                      ? () {
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: canClose
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

