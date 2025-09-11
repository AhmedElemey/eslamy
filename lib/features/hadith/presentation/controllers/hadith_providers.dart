import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/hadith.dart';
import '../../service/hadith_service.dart';

class HadithListState {
  final List<HadithItem> items;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final String? error;

  const HadithListState({
    this.items = const <HadithItem>[],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.error,
  });

  HadithListState copyWith({
    List<HadithItem>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    String? error,
  }) {
    return HadithListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HadithListNotifier extends StateNotifier<HadithListState> {
  HadithListNotifier(this._service) : super(const HadithListState());

  final HadithService _service;

  Future<void> refresh() async {
    state = state.copyWith(items: [], page: 1, hasMore: true, error: null);
    await loadMore();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final page = await _service.fetchHadiths(page: state.page);
      state = state.copyWith(
        items: [...state.items, ...page.items],
        page: state.page + 1,
        hasMore: page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final hadithListProvider = StateNotifierProvider<HadithListNotifier, HadithListState>((ref) {
  final service = ref.watch(hadithServiceProvider);
  return HadithListNotifier(service);
});


