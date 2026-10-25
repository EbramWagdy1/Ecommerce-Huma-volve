import 'package:ecommerce_app_huma_volve/features/home/pressention/view_model/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/dummy_data.dart';
import '../../../../../core/theme.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (currentScroll >= maxScroll - 200) {
        context.read<HomeCubit>().getProducts(isLoadMore: true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final cubit = context.read<HomeCubit>();
            await Future.wait([
              cubit.getCategories(),
              cubit.getProducts(categoryId: cubit.currentCategoryId),
            ]);
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.menu,
                              color: AppTheme.primary,
                            ),
                          ),
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                              dummyUser.profilePictureUrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Explore',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(fontSize: 36),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Best trendy collection!',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search clothes...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.tune,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<HomeCubit, HomeState>(
                        buildWhen: (previous, current) =>
                            current is CategoryLoading ||
                            current is CategorySuccess ||
                            current is CategoryError,
                        builder: (context, state) {
                          final cubit = context.read<HomeCubit>();
                          if (state is CategoryLoading && cubit.categories.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (state is CategoryError && cubit.categories.isEmpty) {
                            return Center(
                              child: Text(state.message),
                            );
                          }
                          final categories = cubit.categories;
                          if (categories.isNotEmpty) {
                            final totalItems = categories.length + 1;
                            return SizedBox(
                              height: 44,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: totalItems,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final isAll = index == 0;
                                  final label = isAll
                                      ? 'All'
                                      : (categories[index - 1].name ?? '');
                                  return CategoryChip(
                                    label: label,
                                    isSelected: _selectedCategoryIndex == index,
                                    onTap: () {
                                      if (_selectedCategoryIndex == index) return;
                                      setState(() {
                                        _selectedCategoryIndex = index;
                                      });
                                      context.read<HomeCubit>().getProducts(
                                            categoryId: isAll
                                                ? null
                                                : categories[index - 1].id,
                                          );
                                    },
                                  );
                                },
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<HomeCubit, HomeState>(
                buildWhen: (previous, current) =>
                    current is ProductsLoading ||
                    current is ProductsSuccess ||
                    current is ProductsError,
                builder: (context, state) {
                  final cubit = context.read<HomeCubit>();
                  if (state is ProductsLoading && cubit.products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                  if (state is ProductsError && cubit.products.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Text(state.message),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => cubit.getProducts(
                                  categoryId: cubit.currentCategoryId,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  if (cubit.products.isNotEmpty) {
                    final products = cubit.products;
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return ProductCard(product: products[index]);
                          },
                          childCount: products.length,
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No products found'),
                      ),
                    ),
                  );
                },
              ),
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  final cubit = context.read<HomeCubit>();
                  if (state is ProductsPaginationLoading || cubit.isLoadingMore) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                  if (state is ProductsPaginationError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                state.message,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  cubit.getProducts(isLoadMore: true);
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Failed to load more. Tap to retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  if (!cubit.hasMore && cubit.products.isNotEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Text(
                            'No more products',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox(height: 24));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
