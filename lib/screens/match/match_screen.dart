import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/match_provider.dart';
import '../../providers/auth_provider.dart';
import 'swipe_card.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQueue();
    });
  }

  Future<void> _loadQueue() async {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await matchProvider.fetchMatchQueue(mode: authProvider.user?.mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: Consumer<MatchProvider>(
        builder: (context, matchProvider, child) {
          if (matchProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (matchProvider.matchQueue.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No more profiles',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new matches',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadQueue,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: List.generate(
              matchProvider.matchQueue.length > 3 
                  ? 3 
                  : matchProvider.matchQueue.length,
              (index) {
                final profile = matchProvider.matchQueue[index];
                return SwipeCard(
                  profile: profile,
                  index: index,
                  onSwipe: (direction) async {
                    await matchProvider.swipe(
                      profile['user_id'],
                      direction,
                    );
                    matchProvider.removeFromQueue(index);
                  },
                );
              },
            ).reversed.toList(),
          );
        },
      ),
    );
  }
}
