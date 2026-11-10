import 'package:flutter/material.dart';

import '../../api/models.dart';
import '../theme/tokens.dart';

/// A card with a title row and optional trailing action.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(Space.xl),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.titleMedium),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: context.text.bodySmall),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: Space.lg),
          child,
        ],
      ),
    ),
  );
}

/// A big number with a caption and an icon.
class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? detail;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(Space.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: Space.md),
          Text(value, style: context.text.headlineMedium?.copyWith(height: 1.1)),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.text.labelLarge?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(
              detail!,
              style: context.text.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    ),
  );
}

/// A quoted question: number, text and what a "yes" gives.
class QuestionQuote extends StatelessWidget {
  const QuestionQuote({super.key, required this.question, this.caption = 'Deciding question'});

  final Question question;
  final String caption;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(Space.lg),
    decoration: BoxDecoration(
      color: context.colors.surfaceContainer,
      borderRadius: BorderRadius.circular(Radii.md),
      border: Border(left: BorderSide(color: context.colors.primary, width: 3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${caption.toUpperCase()} · Q${question.number}',
          style: context.text.labelSmall?.copyWith(color: context.colors.primary),
        ),
        const SizedBox(height: Space.sm),
        Text(question.text, style: context.text.bodyLarge),
        if (question.note != null) ...[
          const SizedBox(height: Space.sm),
          Text(
            question.note!,
            style: context.text.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ],
    ),
  );
}

/// The answers given, in flowchart order.
class AnswerTrail extends StatelessWidget {
  const AnswerTrail({super.key, required this.questions, required this.answers});

  final List<Question> questions;
  final List<bool> answers;

  @override
  Widget build(BuildContext context) {
    final trl = context.trlColors;
    return Column(
      children: [
        for (var i = 0; i < answers.length && i < questions.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    'Q${questions[i].number}',
                    style: context.text.labelMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(child: Text(questions[i].text, style: context.text.bodySmall)),
                const SizedBox(width: Space.md),
                Text(
                  answers[i] ? 'Yes' : 'No',
                  style: context.text.labelMedium?.copyWith(
                    color: answers[i] ? trl.meets : context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Icon, title and message, for empty and error states.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(Space.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(Space.lg),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primaryContainer.withValues(alpha: 0.5),
            ),
            child: Icon(icon, size: 32, color: context.colors.primary),
          ),
          const SizedBox(height: Space.lg),
          Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: Space.sm),
            Text(message!, style: context.text.bodyMedium, textAlign: TextAlign.center),
          ],
          if (action != null) ...[const SizedBox(height: Space.xl), action!],
        ],
      ),
    ),
  );
}
