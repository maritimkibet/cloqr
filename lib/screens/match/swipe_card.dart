import 'package:flutter/material.dart';

class SwipeCard extends StatefulWidget {
  final Map<String, dynamic> profile;
  final int index;
  final Function(String direction) onSwipe;

  const SwipeCard({
    super.key,
    required this.profile,
    required this.index,
    required this.onSwipe,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragOffset.dx.abs() > 100) {
      final direction = _dragOffset.dx > 0 ? 'right' : 'left';
      _animateCardOff(direction);
    } else {
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  void _animateCardOff(String direction) {
    final targetOffset = Offset(
      direction == 'right' ? 500 : -500,
      0,
    );

    _animation = Tween<Offset>(
      begin: _dragOffset,
      end: targetOffset,
    ).animate(_controller);

    _controller.forward().then((_) {
      widget.onSwipe(direction);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final interests = widget.profile['interests'] as List?;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = _controller.isAnimating
            ? _animation.value
            : _dragOffset;

        return Positioned(
          top: 20 + (widget.index * 10.0),
          left: 20,
          right: 20,
          child: Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: offset.dx / 1000,
              child: GestureDetector(
                onPanUpdate: widget.index == 0 ? _onPanUpdate : null,
                onPanEnd: widget.index == 0 ? _onPanEnd : null,
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    height: screenSize.height * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.profile['avatar_url'] ?? '',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.person,
                                  size: 100,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.profile['username'] ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${widget.profile['course'] ?? 'Student'} • Year ${widget.profile['year'] ?? '?'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                if (widget.profile['bio'] != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.profile['bio'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (interests != null && interests.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    children: interests.take(3).map((interest) {
                                      return Chip(
                                        label: Text(interest),
                                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                                        labelStyle: const TextStyle(color: Colors.white),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
