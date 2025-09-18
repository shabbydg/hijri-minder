import 'package:flutter/material.dart';
import '../models/islamic_event.dart';
import '../services/events_service.dart';
import '../services/service_locator.dart';

/// Screen for displaying Islamic events and holidays
/// Provides event browsing, search, filtering, and detail views
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with TickerProviderStateMixin {
  final EventsService _eventsService = ServiceLocator.eventsService;
  final TextEditingController _searchController = TextEditingController();
  
  List<IslamicEvent> _displayedEvents = [];
  List<IslamicEvent> _allEvents = [];
  String _selectedCategory = 'All';
  bool _showImportantOnly = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadEvents() {
    setState(() {
      _allEvents = _eventsService.getAllEvents();
      _displayedEvents = List.from(_allEvents);
    });
  }

  void _filterEvents() {
    List<IslamicEvent> filteredEvents = List.from(_allEvents);

    // Apply category filter
    if (_selectedCategory != 'All') {
      filteredEvents = filteredEvents.where((event) {
        return event.getCategoryDisplayName() == _selectedCategory;
      }).toList();
    }

    // Apply importance filter
    if (_showImportantOnly) {
      filteredEvents = filteredEvents.where((event) => event.isImportant).toList();
    }

    // Apply search filter
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isNotEmpty) {
      filteredEvents = _eventsService.searchEvents(searchQuery);
      
      // Apply other filters to search results
      if (_selectedCategory != 'All') {
        filteredEvents = filteredEvents.where((event) {
          return event.getCategoryDisplayName() == _selectedCategory;
        }).toList();
      }
      
      if (_showImportantOnly) {
        filteredEvents = filteredEvents.where((event) => event.isImportant).toList();
      }
    }

    setState(() {
      _displayedEvents = filteredEvents;
    });
  }

  void _showEventDetails(IslamicEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EventDetailSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Events'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Events', icon: Icon(Icons.event)),
            Tab(text: 'Important', icon: Icon(Icons.star)),
            Tab(text: 'Search', icon: Icon(Icons.search)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllEventsTab(),
          _buildImportantEventsTab(),
          _buildSearchTab(),
        ],
      ),
    );
  }

  Widget _buildAllEventsTab() {
    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: _buildEventsList(_allEvents),
        ),
      ],
    );
  }

  Widget _buildImportantEventsTab() {
    final importantEvents = _eventsService.getImportantEvents();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Important Islamic Events',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<IslamicEvent>>(
            future: importantEvents,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _buildEventsList(snapshot.data!);
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterEvents();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => _filterEvents(),
          ),
        ),
        _buildCategoryFilter(),
        Expanded(
          child: _buildEventsList(_displayedEvents),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', ..._eventsService.getEventCategories()];
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
                _filterEvents();
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsList(List<IslamicEvent> events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Sort events by importance and date
    final sortedEvents = List<IslamicEvent>.from(events);
    sortedEvents.sort((a, b) {
      // First sort by importance
      final importanceComparison = b.getImportanceLevel().compareTo(a.getImportanceLevel());
      if (importanceComparison != 0) return importanceComparison;
      
      // Then sort by month and day
      final monthComparison = a.hijriMonth.compareTo(b.hijriMonth);
      if (monthComparison != 0) return monthComparison;
      
      return a.hijriDay.compareTo(b.hijriDay);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(IslamicEvent event) {
    final categoryColor = _getCategoryColor(event.category);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Category indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              
              // Event content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (event.isImportant)
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.hijriDay} ${_getMonthName(event.hijriMonth)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event.getCategoryDisplayName(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: categoryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (event.location != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            event.location!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow indicator
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.eid:
        return Colors.green;
      case EventCategory.shahadat:
        return Colors.red;
      case EventCategory.ramadan:
        return Colors.purple;
      case EventCategory.hajj:
        return Colors.orange;
      case EventCategory.milad:
        return Colors.blue;
      case EventCategory.other:
        return Colors.grey;
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      '', 'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
      'Ramadan', 'Shawwal', 'Dhul Qi\'dah', 'Dhul Hijjah'
    ];
    return month > 0 && month < monthNames.length ? monthNames[month] : 'Unknown';
  }
}

/// Bottom sheet for displaying event details
class EventDetailSheet extends StatelessWidget {
  final IslamicEvent event;

  const EventDetailSheet({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(event.category);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 40,
                            decoration: BoxDecoration(
                              color: categoryColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${event.hijriDay} ${_getMonthName(event.hijriMonth)}${event.hijriYear != null ? ' ${event.hijriYear}' : ' (Annual)'}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (event.isImportant)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Category
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              event.getCategoryDisplayName(),
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: categoryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Location (if available)
                      if (event.location != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              event.location!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Significance section
                      Text(
                        'Significance',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getEventSignificance(event),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Add to calendar functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Add to calendar feature coming soon'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Add to Calendar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Share functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Share feature coming soon'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.eid:
        return Colors.green;
      case EventCategory.shahadat:
        return Colors.red;
      case EventCategory.ramadan:
        return Colors.purple;
      case EventCategory.hajj:
        return Colors.orange;
      case EventCategory.milad:
        return Colors.blue;
      case EventCategory.other:
        return Colors.grey;
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      '', 'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
      'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
      'Ramadan', 'Shawwal', 'Dhul Qi\'dah', 'Dhul Hijjah'
    ];
    return month > 0 && month < monthNames.length ? monthNames[month] : 'Unknown';
  }

  String _getEventSignificance(IslamicEvent event) {
    // Provide detailed significance based on event category and title
    switch (event.category) {
      case EventCategory.eid:
        if (event.title.contains('Fitr')) {
          return 'Eid al-Fitr marks the end of Ramadan, the holy month of fasting. It is a time of celebration, gratitude, and community gathering. Muslims perform special prayers, give charity (Zakat al-Fitr), and share meals with family and friends.';
        } else if (event.title.contains('Adha')) {
          return 'Eid al-Adha commemorates Prophet Ibrahim\'s willingness to sacrifice his son as an act of obedience to Allah. It coincides with the Hajj pilgrimage and involves the ritual sacrifice of animals, with the meat shared among family, friends, and the needy.';
        }
        break;
      case EventCategory.ramadan:
        if (event.title.contains('Ramadan')) {
          return 'Ramadan is the ninth month of the Islamic calendar and the holy month of fasting. Muslims fast from dawn to sunset, engage in increased prayer and Quran recitation, and focus on spiritual purification and self-discipline.';
        } else if (event.title.contains('Qadr')) {
          return 'Laylat al-Qadr (Night of Power) is believed to be the night when the first verses of the Quran were revealed to Prophet Muhammad. It is considered more blessed than a thousand months, and Muslims spend this night in prayer and remembrance.';
        }
        break;
      case EventCategory.shahadat:
        return 'This day commemorates the martyrdom of important figures in Islamic history. It is observed with reflection, prayer, and remembrance of their sacrifices and contributions to the faith.';
      case EventCategory.milad:
        return 'This day celebrates the birth or significant life events of Prophet Muhammad or other important Islamic figures. It is marked with prayers, recitation of religious poetry, and community gatherings.';
      case EventCategory.hajj:
        return 'This event is related to the Hajj pilgrimage, one of the Five Pillars of Islam. It represents the spiritual journey that every able Muslim should undertake at least once in their lifetime.';
      case EventCategory.other:
        return 'This is an important date in the Islamic calendar that holds special significance for the Muslim community.';
    }
    
    return 'This event holds special significance in Islamic tradition and is observed by Muslims worldwide with prayer, reflection, and community participation.';
  }
}