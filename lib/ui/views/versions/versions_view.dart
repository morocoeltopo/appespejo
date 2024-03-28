import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:glass_down_v2/models/app_info.dart';
import 'package:glass_down_v2/ui/views/versions/items/version_card/version_card.dart';
import 'package:glass_down_v2/ui/widgets/common/placeholder.dart';
import 'package:stacked/stacked.dart';

import 'versions_viewmodel.dart';

class VersionsView extends StackedView<VersionsViewModel> {
  const VersionsView({super.key, required this.app});

  final AppInfo app;

  @override
  Widget builder(
    BuildContext context,
    VersionsViewModel viewModel,
    Widget? child,
  ) {
    return PopScope(
      canPop: true,
      onPopInvoked: (_) => viewModel.cancel(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => viewModel.showChangeFiltersModal(),
          icon: const Icon(Icons.settings_applications),
          label: const Text('Quick settings'),
        ),
        body: RefreshIndicator(
          onRefresh: () => viewModel.fetchVersions(app),
          backgroundColor: Theme.of(context).colorScheme.primary,
          color: Theme.of(context).colorScheme.onPrimary,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 90,
                automaticallyImplyLeading: false,
                bottom: viewModel.isBusy
                    ? const PreferredSize(
                        preferredSize: Size.fromHeight(6),
                        child: LinearProgressIndicator(),
                      )
                    : const PreferredSize(
                        preferredSize: Size.fromHeight(6),
                        child: SizedBox(),
                      ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(bottom: 16, left: 20),
                  title: Text(
                    app.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              if (viewModel.hasError && viewModel.modelError is! DioException)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          title: Text(
                            viewModel.modelError is DioException
                                ? viewModel.modelError.message
                                : viewModel.modelError.toString(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (viewModel.appWithLinks != null)
                SliverList(
                  delegate: SliverChildListDelegate([
                    ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (final appLinks in viewModel.appWithLinks!.links)
                          VersionCard(
                            app: app,
                            versionLink: appLinks,
                          )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 48),
                      child: FilledButton.tonal(
                        onPressed: () => viewModel.loadMore(app),
                        child: const Text('Load more'),
                      ),
                    )
                  ]),
                ),
              if (!viewModel.isBusy &&
                  viewModel.appWithLinks != null &&
                  viewModel.appWithLinks!.links.isEmpty)
                const PlaceholderText(
                  text: [
                    'No versions found',
                    'Try changing filters below',
                    'and pull to refresh results'
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  @override
  VersionsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      VersionsViewModel();

  @override
  void onViewModelReady(VersionsViewModel viewModel) {
    super.onViewModelReady(viewModel);
    viewModel.fetchVersions(app);
  }
}
