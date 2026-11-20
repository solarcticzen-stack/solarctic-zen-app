import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/charts.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/formatters.dart';
import '../../domain/common/local_date.dart';
import '../../domain/profile/user_profile.dart';
import '../../domain/questionnaire/questionnaire.dart';

/// Welche Fragebögen zu den Zielen gehören (FEATURES.md §L, P5).
Set<QuestionnaireKind> questionnairesFor(UserProfile p) => {
  if (p.has(BathGoal.mental) || p.has(BathGoal.stress)) QuestionnaireKind.who5,
  if (p.has(BathGoal.sleep)) QuestionnaireKind.sleep,
};

/// Eine Frage pro Bildschirm, danach das Ergebnis.
class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({required this.kind, super.key});

  final QuestionnaireKind kind;

  static Future<void> open(BuildContext context, QuestionnaireKind kind) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => QuestionnaireScreen(kind: kind),
        ),
      );

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  late final AppServices _s = AppServices.of(context);
  late final QuestionnaireDefinition _def = Questionnaires.of(widget.kind);
  final List<int> _answers = [];
  QuestionnaireResult? _result;

  Future<void> _answer(int value) async {
    setState(() => _answers.add(value));
    if (_answers.length < _def.items.length) return;
    final now = _s.now();
    final result = QuestionnaireResult(
      id: _s.idGenerator(now: now),
      kind: widget.kind,
      answeredAt: now,
      answers: List.unmodifiable(_answers),
      score: _def.score(_answers),
    );
    await _s.questionnaires.save(result);
    if (mounted) setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.bgBase,
        title: Text(_def.title),
        leading: IconButton(
          tooltip: 'Schliessen',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: _result == null
            ? _question(context)
            : _resultView(context, _result!),
      ),
    );
  }

  Widget _question(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final i = _answers.length;
    return ListView(
      padding: const EdgeInsets.all(SzSpacing.pageMargin),
      children: [
        if (i == 0) ...[
          Text(_def.intro, style: t.bodyMedium),
          const SizedBox(height: SzSpacing.l),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                'FRAGE ${i + 1} VON ${_def.items.length}',
                style: t.labelSmall?.copyWith(
                  color: p.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            if (i > 0)
              TextButton(
                key: const Key('q-back'),
                onPressed: () => setState(_answers.removeLast),
                child: const Text('Zurück'),
              ),
          ],
        ),
        const SizedBox(height: SzSpacing.s),
        ClipRRect(
          borderRadius: BorderRadius.circular(SzRadius.full),
          child: LinearProgressIndicator(
            value: i / _def.items.length,
            minHeight: 4,
            color: p.accentPrimary,
            backgroundColor: p.bgElevated,
          ),
        ),
        const SizedBox(height: SzSpacing.xl),
        Text(
          _def.items[i],
          key: const Key('q-item'),
          style: t.headlineMedium?.copyWith(fontSize: 22),
        ),
        const SizedBox(height: SzSpacing.xl),
        for (final (value, label) in _def.options)
          Padding(
            padding: const EdgeInsets.only(bottom: SzSpacing.s),
            child: OutlinedButton(
              key: Key('q-opt-$value'),
              onPressed: () => _answer(value),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(SzTouch.min + 4),
                alignment: Alignment.centerLeft,
                side: BorderSide(color: p.borderSubtle),
                foregroundColor: p.textPrimary,
              ),
              child: Text(label),
            ),
          ),
      ],
    );
  }

  Widget _resultView(BuildContext context, QuestionnaireResult r) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    final isWho5 = r.kind == QuestionnaireKind.who5;
    return ListView(
      padding: const EdgeInsets.all(SzSpacing.pageMargin),
      children: [
        Text(
          'DEIN WERT',
          style: t.labelSmall?.copyWith(
            color: p.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          '${r.score.round()} / 100',
          key: const Key('q-score'),
          style: t.displayMedium,
        ),
        const SizedBox(height: SzSpacing.m),
        Text(
          'Danke! Alle 14 Tage fragt die App erneut. So siehst du in der Statistik, '
          'wie sich dein ${isWho5 ? 'Wohlbefinden' : 'Schlaf'} entwickelt.',
          style: t.bodyLarge,
        ),
        if (!_def.validated) ...[
          const SizedBox(height: SzSpacing.s),
          Text(
            'Diese Kurzfragen sind nicht klinisch geprüft.',
            style: t.bodyMedium,
          ),
        ],
        if (isWho5 && r.score <= Questionnaires.who5SupportThreshold)
          const _SupportCard()
        else if (isWho5 && r.score <= Questionnaires.who5LowThreshold) ...[
          const SizedBox(height: SzSpacing.l),
          Text(
            'Dein Wert zeigt, dass es dir in den letzten zwei Wochen eher nicht so gut ging. '
            'Wenn das anhält, kann ein Gespräch mit deiner Hausärztin oder deinem Hausarzt helfen.',
            key: const Key('q-low'),
            style: t.bodyLarge,
          ),
        ],
        const SizedBox(height: SzSpacing.xl),
        SizedBox(
          height: SzTouch.session,
          child: FilledButton(
            key: const Key('q-done'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fertig'),
          ),
        ),
      ],
    );
  }
}

/// Unterstützender Hinweis bei sehr niedrigem WHO-5-Wert – keine Diagnose.
class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: SzSpacing.l),
      child: Container(
        key: const Key('q-support'),
        padding: const EdgeInsets.all(SzSpacing.l),
        decoration: BoxDecoration(
          color: p.bgSurface,
          borderRadius: BorderRadius.circular(SzRadius.m),
          border: Border.all(color: p.stateCaution),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Es scheint dir gerade nicht gut zu gehen',
              style: t.titleMedium,
            ),
            const SizedBox(height: SzSpacing.s),
            Text(
              'Das ist keine Diagnose. Aber du musst damit nicht allein bleiben. '
              'Sprich mit einer Person deines Vertrauens oder mit deiner Hausärztin bzw. deinem Hausarzt.',
              style: t.bodyLarge,
            ),
            const SizedBox(height: SzSpacing.m),
            Text('Die Dargebotene Hand: Telefon 143', style: t.titleMedium),
            Text(
              'rund um die Uhr, anonym und kostenlos (Schweiz)',
              style: t.bodyMedium,
            ),
            const SizedBox(height: SzSpacing.s),
            Text('Im Notfall: Telefon 144', style: t.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// Karte «Fragebogen fällig» auf dem Dashboard.
class DueQuestionnairesCard extends StatelessWidget {
  const DueQuestionnairesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    return ListenableBuilder(
      listenable: ProfileListenable(s.profile),
      builder: (context, _) {
        final kinds = questionnairesFor(s.profile.profile);
        if (kinds.isEmpty) return const SizedBox.shrink();
        return StreamBuilder<List<QuestionnaireResult>>(
          stream: s.questionnaires.watchAll(),
          builder: (context, snap) {
            final results = snap.data ?? const [];
            final due = [
              for (final k in kinds)
                if (isQuestionnaireDue(k, results, now: s.now())) k,
            ];
            if (due.isEmpty) return const SizedBox.shrink();
            final p = context.sz;
            final t = Theme.of(context).textTheme;
            return Padding(
              padding: const EdgeInsets.only(top: SzSpacing.m),
              child: Column(
                children: [
                  for (final k in due)
                    Card(
                      child: ListTile(
                        key: Key('q-due-${k.name}'),
                        leading: Icon(
                          Icons.assignment_outlined,
                          color: p.accentPrimary,
                        ),
                        title: Text(Questionnaires.of(k).title),
                        subtitle: Text(
                          results.any((r) => r.kind == k)
                              ? 'Wieder fällig – dauert etwa eine Minute'
                              : 'Ausgangswert erfassen – dauert etwa eine Minute',
                          style: t.bodyMedium,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => QuestionnaireScreen.open(context, k),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Verlaufsdiagramme der Fragebögen in der Statistik.
class QuestionnaireCharts extends StatelessWidget {
  const QuestionnaireCharts({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    return StreamBuilder<List<QuestionnaireResult>>(
      stream: s.questionnaires.watchAll(),
      builder: (context, snap) {
        final results = snap.data ?? const [];
        return Column(
          children: [
            for (final kind in QuestionnaireKind.values)
              if (results.any((r) => r.kind == kind))
                _chart(context, kind, results),
          ],
        );
      },
    );
  }

  Widget _chart(
    BuildContext context,
    QuestionnaireKind kind,
    List<QuestionnaireResult> all,
  ) {
    final s = AppServices.of(context);
    final t = Theme.of(context).textTheme;
    final def = Questionnaires.of(kind);
    final list = [
      for (final r in all)
        if (r.kind == kind) r,
    ];
    final offset = s.utcOffsetMinutes();
    return Padding(
      padding: const EdgeInsets.only(top: SzSpacing.m),
      child: Card(
        key: Key('chart-q-${kind.name}'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SzSpacing.l,
            SzSpacing.l,
            SzSpacing.l,
            SzSpacing.m,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(def.title, style: t.titleMedium),
              Text(
                '${list.length} ${list.length == 1 ? 'Befragung' : 'Befragungen'} · 0–100${def.validated ? '' : ' · nicht klinisch geprüft'}',
                style: t.bodyMedium,
              ),
              const SizedBox(height: SzSpacing.xl),
              SzLineChart(
                minY: 0,
                data: [
                  for (final r in list)
                    ChartDatum(
                      value: r.score,
                      axisLabel: formatShortDate(
                        LocalDate.fromInstant(r.answeredAt, offset),
                      ),
                      tooltip:
                          '${formatDay(LocalDate.fromInstant(r.answeredAt, offset))}\n${r.score.round()} / 100',
                    ),
                ],
                semanticsLabel:
                    '${def.title}: zuletzt ${list.last.score.round()} von 100, ${list.length} Befragungen.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
