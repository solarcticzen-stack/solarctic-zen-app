import 'package:material_ui/material_ui.dart';

import '../../app_services.dart';
import '../../core/design_system/app_theme.dart';
import '../../core/design_system/tokens.dart';
import '../../core/format/formatters.dart';
import '../../domain/common/local_date.dart';
import '../../domain/community/community.dart';
import 'community_widgets.dart';
import 'publish_forms.dart';

// ---------------------------------------------------------------- Termine

class EventsView extends StatelessWidget {
  const EventsView({required this.me, super.key});

  final CommunityProfile me;

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    final t = Theme.of(context).textTheme;
    final p = context.sz;
    return StreamBuilder<List<CommunityEvent>>(
      stream: s.community.watchEvents(),
      builder: (context, snap) {
        final now = s.now();
        final events = [
          for (final e in snap.data ?? const <CommunityEvent>[])
            if (e.startsAt.isAfter(now) && !me.blocked.contains(e.organizerId))
              e,
        ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
        final offset = s.utcOffsetMinutes();
        return ListView(
          key: const Key('events-list'),
          children: [
            Row(
              children: [
                Expanded(child: Text('Kommende Termine', style: t.titleMedium)),
                PublishButton(
                  key: const Key('add-event'),
                  label: 'Termin',
                  onPublish: () => AddEventScreen.open(context),
                ),
              ],
            ),
            const SizedBox(height: SzSpacing.m),
            if (events.isEmpty)
              Text('Noch keine Termine.', style: t.bodyMedium)
            else
              for (final e in events)
                Card(
                  key: Key('event-${e.id}'),
                  margin: const EdgeInsets.only(bottom: SzSpacing.s),
                  child: Padding(
                    padding: const EdgeInsets.all(SzSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.event_rounded,
                              size: 18,
                              color: p.accentSolar,
                            ),
                            const SizedBox(width: SzSpacing.s),
                            Expanded(
                              child: Text(
                                '${formatDay(LocalDate.fromInstant(e.startsAt, offset))} · '
                                '${formatTime(e.startsAt, offset)} Uhr',
                                style: t.labelSmall?.copyWith(
                                  color: p.textSecondary,
                                ),
                              ),
                            ),
                            if (e.isDemo) const DemoTag(),
                            ContentActionsButton(
                              target: ReportTarget.event,
                              targetId: e.id,
                              authorId: e.organizerId,
                              authorHandle: e.organizerHandle,
                            ),
                          ],
                        ),
                        Text(e.title, style: t.titleMedium),
                        const SizedBox(height: SzSpacing.xs),
                        Text(
                          e.location,
                          style: t.bodyMedium?.copyWith(color: p.textPrimary),
                        ),
                        if (e.description.isNotEmpty) ...[
                          const SizedBox(height: SzSpacing.s),
                          Text(e.description, style: t.bodyMedium),
                        ],
                        const SizedBox(height: SzSpacing.s),
                        Text(
                          'Organisiert von ${e.organizerHandle}',
                          style: TextStyle(color: p.textTertiary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Angebote

class OffersView extends StatelessWidget {
  const OffersView({required this.me, super.key});

  final CommunityProfile me;

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    final t = Theme.of(context).textTheme;
    final p = context.sz;
    return StreamBuilder<List<Offer>>(
      stream: s.community.watchOffers(),
      builder: (context, snap) {
        final offers = [
          for (final o in snap.data ?? const <Offer>[])
            if (!me.blocked.contains(o.providerId)) o,
        ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return ListView(
          key: const Key('offers-list'),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Angebote von Mitgliedern', style: t.titleMedium),
                ),
                PublishButton(
                  key: const Key('add-offer'),
                  label: 'Angebot',
                  onPublish: () => AddOfferScreen.open(context),
                ),
              ],
            ),
            const SizedBox(height: SzSpacing.xs),
            Text(
              'Angebote stammen von Premium-Mitgliedern und werden von Solarctic-Zen nicht geprüft.',
              style: TextStyle(color: p.textTertiary, fontSize: 12),
            ),
            const SizedBox(height: SzSpacing.m),
            if (offers.isEmpty)
              Text('Noch keine Angebote.', style: t.bodyMedium)
            else
              for (final o in offers)
                Card(
                  key: Key('offer-${o.id}'),
                  margin: const EdgeInsets.only(bottom: SzSpacing.s),
                  child: Padding(
                    padding: const EdgeInsets.all(SzSpacing.l),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                o.category.label.toUpperCase(),
                                style: t.labelSmall?.copyWith(
                                  color: p.accentIce,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            if (o.isDemo) const DemoTag(),
                            ContentActionsButton(
                              target: ReportTarget.offer,
                              targetId: o.id,
                              authorId: o.providerId,
                              authorHandle: o.providerHandle,
                            ),
                          ],
                        ),
                        Text(o.title, style: t.titleMedium),
                        const SizedBox(height: SzSpacing.s),
                        Text(
                          o.description,
                          style: t.bodyMedium?.copyWith(color: p.textPrimary),
                        ),
                        const SizedBox(height: SzSpacing.s),
                        if (o.location != null)
                          Text('Ort: ${o.location}', style: t.bodyMedium),
                        if (o.contact != null)
                          Text('Kontakt: ${o.contact}', style: t.bodyMedium),
                        const SizedBox(height: SzSpacing.s),
                        Text(
                          'Anbieter: ${o.providerHandle}',
                          style: TextStyle(color: p.textTertiary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Chat

class ChatView extends StatefulWidget {
  const ChatView({required this.me, super.key});

  final CommunityProfile me;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _input = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final s = AppServices.of(context);
    final me = s.communityProfile.profile!;
    final err = ChatLimits.validate(_input.text);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    await s.community.sendMessage(
      ChatMessage(
        id: s.idGenerator(now: s.now()),
        authorId: me.id,
        authorHandle: me.handle,
        authorSymbol: me.symbol,
        authorColor: me.colorIndex,
        text: _input.text.trim(),
        sentAt: s.now(),
      ),
    );
    _input.clear();
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppServices.of(context);
    final me = widget.me;
    final p = context.sz;
    final t = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, box) => Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: s.community.watchChat(),
              builder: (context, snap) {
                final msgs = [
                  for (final m in snap.data ?? const <ChatMessage>[])
                    if (!me.blocked.contains(m.authorId)) m,
                ]..sort((a, b) => b.sentAt.compareTo(a.sentAt));
                if (msgs.isEmpty) {
                  return Center(
                    child: Text(
                      'Noch keine Nachrichten. Sag Hallo!',
                      style: t.bodyMedium,
                    ),
                  );
                }
                final offset = s.utcOffsetMinutes();
                return ListView.builder(
                  key: const Key('chat-list'),
                  reverse: true,
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final m = msgs[i];
                    final mine = m.authorId == me.id;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: SzSpacing.xs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: mine
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        children: [
                          SzAvatar(
                            symbol: m.authorSymbol,
                            colorIndex: m.authorColor,
                            size: 32,
                          ),
                          const SizedBox(width: SzSpacing.s),
                          Flexible(
                            child: Container(
                              key: Key('msg-${m.id}'),
                              padding: const EdgeInsets.all(SzSpacing.m),
                              decoration: BoxDecoration(
                                color: mine ? p.bgElevated : p.bgSurface,
                                borderRadius: BorderRadius.circular(SzRadius.m),
                                border: Border.all(color: p.borderSubtle),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          mine ? 'Du' : m.authorHandle,
                                          overflow: TextOverflow.ellipsis,
                                          style: t.labelSmall?.copyWith(
                                            color: p.textSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: SzSpacing.s),
                                      Text(
                                        formatTime(m.sentAt, offset),
                                        style: TextStyle(
                                          color: p.textTertiary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(m.text, style: t.bodyLarge),
                                ],
                              ),
                            ),
                          ),
                          if (!mine)
                            ContentActionsButton(
                              target: ReportTarget.message,
                              targetId: m.id,
                              authorId: m.authorId,
                              authorHandle: m.authorHandle,
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: SzSpacing.xs),
              child: Text(
                _error!,
                key: const Key('chat-error'),
                style: TextStyle(color: p.stateDanger, fontSize: 13),
              ),
            ),
          const SizedBox(height: SzSpacing.s),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('chat-input'),
                  controller: _input,
                  minLines: 1,
                  // Bei wenig Höhe (kleines Gerät, grosse Schrift) kompakter.
                  maxLines: box.maxHeight < 320 ? 2 : 4,
                  maxLength: ChatLimits.maxLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Nachricht an die Community',
                    hintMaxLines: 1,
                    isDense: true,
                    counterText: '',
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: SzSpacing.s),
              IconButton.filled(
                key: const Key('chat-send'),
                tooltip: 'Senden',
                onPressed: _send,
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
