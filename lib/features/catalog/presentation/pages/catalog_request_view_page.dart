import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/di.dart';
import '../bloc/catalog_requests_bloc.dart';

class CatalogRequestViewPage extends StatefulWidget {
  final String requestId;
  const CatalogRequestViewPage({super.key, required this.requestId});

  @override
  State<CatalogRequestViewPage> createState() => _CatalogRequestViewPageState();
}

class _CatalogRequestViewPageState extends State<CatalogRequestViewPage> {
  late final CatalogRequestsBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = getIt<CatalogRequestsBloc>();
    bloc.add(LoadCatalogRequestDetails(widget.requestId));
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Request Details')),
        body: BlocConsumer<CatalogRequestsBloc, CatalogRequestsState>(
          listener: (context, state) {
            if (state is CatalogRequestActionSuccess) {
              Navigator.of(context).pop(true);
            }
          },
          builder: (context, state) {
            if (state is CatalogRequestsLoading ||
                state is CatalogRequestsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CatalogRequestsError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is CatalogRequestDetailsLoaded) {
              final r = state.item;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(r.title,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(r.description),
                  const SizedBox(height: 12),
                  if (r.materials.isNotEmpty) ...[
                    const Text('Materials',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    for (final m in r.materials)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(m.description)),
                          if (m.quantity != null) Text('x${m.quantity}'),
                          if (m.price != null) Text('₦${m.price}'),
                        ],
                      ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context
                              .read<CatalogRequestsBloc>()
                              .add(ApproveRequestEvent(r.id)),
                          child: const Text('Approve'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final reasonCtr = TextEditingController();
                            final msgCtr = TextEditingController();
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Decline request'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                        controller: reasonCtr,
                                        decoration: const InputDecoration(
                                            labelText: 'Reason')),
                                    TextField(
                                        controller: msgCtr,
                                        decoration: const InputDecoration(
                                            labelText: 'Message (optional)')),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Decline')),
                                ],
                              ),
                            );
                            if (!context.mounted) return;
                            if (ok == true) {
                              context.read<CatalogRequestsBloc>().add(
                                  DeclineRequestEvent(r.id,
                                      reason: reasonCtr.text.trim().isEmpty
                                          ? null
                                          : reasonCtr.text.trim(),
                                      message: msgCtr.text.trim().isEmpty
                                          ? null
                                          : msgCtr.text.trim()));
                            }
                          },
                          child: const Text('Decline'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
