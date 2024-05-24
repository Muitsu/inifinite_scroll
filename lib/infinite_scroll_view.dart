import 'package:flutter/material.dart';

class InfiniteScrollView extends StatefulWidget {
  final bool enableRefresh;
  final int? totalData;
  final int itemCount;
  final void Function(int page)? onLoadMore;
  final Future<void> Function()? onRefresh;
  final Widget Function(BuildContext ctx, int idx) itemBuilder;
  final Widget? loadingWidget;
  final Widget? emptyPlaceholder;
  const InfiniteScrollView({
    super.key,
    this.enableRefresh = false,
    this.totalData,
    required this.itemBuilder,
    required this.itemCount,
    this.emptyPlaceholder,
    this.loadingWidget,
    this.onLoadMore,
    this.onRefresh,
  });

  @override
  State<InfiniteScrollView> createState() => _InfiniteScrollViewState();
}

class _InfiniteScrollViewState extends State<InfiniteScrollView> {
  final controller = ScrollController();
  int itemLength = 0;
  int currentCount = 1;
  bool isHasData = false;
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        isHasData = !(widget.itemCount == 0 ||
            widget.itemCount >= (widget.totalData ?? widget.itemCount));
        if (!isHasData) return;
        currentCount++;
        if (widget.onLoadMore != null) {
          widget.onLoadMore!(currentCount);
        }
        setState(() {});
      }
    });
  }

  int _setData() {
    return itemLength = ((widget.itemCount == 0 ||
            widget.itemCount >= (widget.totalData ?? widget.itemCount))
        ? widget.itemCount
        : widget.itemCount + 1);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalData == 0) {
      return widget.emptyPlaceholder ?? const Text('No Record Found');
    }
    return Expanded(
        child: widget.enableRefresh
            ? _withRefreshIndicator()
            : _withoutRefreshIndicator());
  }

  Widget _withRefreshIndicator() {
    int cnt = _setData();
    return RefreshIndicator(
      onRefresh: () async {
        if (widget.onRefresh == null) return;
        setState(() => currentCount = 1);
        widget.onRefresh!();
      },
      child: SingleChildScrollView(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: List.generate(cnt, (index) {
            return _widgetShow(index: index);
          }),
        ),
      ),
    );
  }

  Widget _withoutRefreshIndicator() {
    int cnt = _setData();
    return SingleChildScrollView(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: List.generate(cnt, (index) {
          return _widgetShow(index: index);
        }),
      ),
    );
  }

  Widget _widgetShow({required int index}) {
    if (index < widget.itemCount) {
      return widget.itemBuilder(context, index);
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: widget.loadingWidget ?? const CircularProgressIndicator(),
        ),
      );
    }
  }
}
