import 'package:flutter/material.dart';

/// Generic pagination controller for infinite scrolling
class PaginationController<T> extends ChangeNotifier {
  List<T> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 0;
  final int _pageSize;

  List<T> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int get currentPage => _currentPage;

  final Future<List<T>> Function(int page, int pageSize) fetchItems;
  final ScrollController scrollController;

  PaginationController({
    required this.fetchItems,
    required this.scrollController,
    int pageSize = 20,
  }) : _pageSize = pageSize {
    scrollController.addListener(_scrollListener);
    loadMore();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      loadMore();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newItems = await fetchItems(_currentPage, _pageSize);

      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _items.addAll(newItems);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _items.clear();
    _currentPage = 0;
    _hasMore = true;
    _error = null;
    notifyListeners();
    await loadMore();
  }

  void clear() {
    _items.clear();
    _currentPage = 0;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }
}

/// Paginated list view widget
class PaginatedListView<T> extends StatefulWidget {
  final PaginationController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget? loadingWidget;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PaginatedListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingWidget,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    // Show error
    if (controller.error != null && controller.items.isEmpty) {
      return widget.errorBuilder?.call(context, controller.error!) ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${controller.error}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
    }

    // Show empty state
    if (controller.items.isEmpty && !controller.isLoading) {
      return widget.emptyBuilder?.call(context) ??
          const Center(
            child: Text('No items found'),
          );
    }

    // Show list with pagination
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.builder(
        controller: widget.controller.scrollController,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        itemCount: controller.items.length + (controller.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < controller.items.length) {
            return widget.itemBuilder(
              context,
              controller.items[index],
              index,
            );
          } else {
            // Loading indicator at the bottom
            return Padding(
              padding: const EdgeInsets.all(16),
              child: widget.loadingWidget ??
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
            );
          }
        },
      ),
    );
  }
}

/// Paginated grid view widget
class PaginatedGridView<T> extends StatefulWidget {
  final PaginationController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final SliverGridDelegate gridDelegate;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget? loadingWidget;
  final EdgeInsetsGeometry? padding;

  const PaginatedGridView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.gridDelegate,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingWidget,
    this.padding,
  });

  @override
  State<PaginatedGridView<T>> createState() => _PaginatedGridViewState<T>();
}

class _PaginatedGridViewState<T> extends State<PaginatedGridView<T>> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    // Show error
    if (controller.error != null && controller.items.isEmpty) {
      return widget.errorBuilder?.call(context, controller.error!) ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${controller.error}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
    }

    // Show empty state
    if (controller.items.isEmpty && !controller.isLoading) {
      return widget.emptyBuilder?.call(context) ??
          const Center(
            child: Text('No items found'),
          );
    }

    // Show grid with pagination
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: CustomScrollView(
        controller: widget.controller.scrollController,
        slivers: [
          SliverPadding(
            padding: widget.padding ?? EdgeInsets.zero,
            sliver: SliverGrid(
              gridDelegate: widget.gridDelegate,
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return widget.itemBuilder(
                    context,
                    controller.items[index],
                    index,
                  );
                },
                childCount: controller.items.length,
              ),
            ),
          ),
          if (controller.hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: widget.loadingWidget ??
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
