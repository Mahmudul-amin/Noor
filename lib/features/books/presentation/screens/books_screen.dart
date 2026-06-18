import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> books = [
    {
      'title': "Prophet Muhammad's Manner of Performing Prayers",
      'image': 'assets/images/book thumb/Book_Thumb_1.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single/en_Prophet_Muhammads_Manner_of_performing_prayers.pdf',
    },
    {
      'title': "Simple Summary of the Pillars of Islam and Eemaan",
      'image': 'assets/images/book thumb/Book_Thumb_2.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single2/en_Simple_Summary_of_the_Pillars_Islam_and_Eemaan.pdf',
    },
    {
      'title': "Explanation of the Last Tenth of the Quran",
      'image': 'assets/images/book thumb/Book_Thumb_3.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single/en_Explanation_of_the_Last_Tenth_of_the_Quran.pdf',
    },
    {
      'title': "Translation of the Meaning of the Pure Qur'an",
      'image': 'assets/images/book thumb/Book_Thumb_4.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single2/en-translation-the-meaning-of-quran-pure.pdf',
    },
    {
      'title': "Muhammad (pbuh)",
      'image': 'assets/images/book thumb/Book_Thumb_5.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single/en-muhammed-pbuh.pdf',
    },
    {
      'title': "Explanation of the Important Lessons",
      'image': 'assets/images/book thumb/Book_Thumb_6.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single3/en-explanation-of-the-important-lessons.pdf',
    },
    {
      'title': "Who Created the Universe?",
      'image': 'assets/images/book thumb/Book_Thumb_7.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single/risala_en-man_kholaqo_alkaun.pdf',
    },
    {
      'title': "Useful Ways of Leading a Happy Life",
      'image': 'assets/images/book thumb/Book_Thumb_8.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single2/en_useful_way_of_leading_happy_life.pdf',
    },
    {
      'title': "Surah Al-Fatiha and Al-Baqarah",
      'image': 'assets/images/book thumb/Book_Thumb_9.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single/en-surah-al-fatiha-and-al-baqarah.pdf',
    },
    {
      'title': "The Responsible Guide",
      'image': 'assets/images/book thumb/Book_Thumb_10.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single3/en-the-responsible-guide.pdf',
    },
    {
      'title': "Objectives and Lessons of Quranic Surah",
      'image': 'assets/images/book thumb/Book_Thumb_11.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single/en-objectives-and-lessons-of-quranic-surah.pdf',
    },
    {
      'title': "Fundamental Beliefs of Ahl as-Sunnah",
      'image': 'assets/images/book thumb/Book_Thumb_12.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single/en-the-fundeamental-beliefs-of-ahl-as-sunnah-book.pdf',
    },
    {
      'title': "Natural Blood of Women",
      'image': 'assets/images/book thumb/Book_Thumb_13.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single/risala_en_risalah-fiidimaa-attobiiyyah-linnisaa.pdf',
    },
    {
      'title': "The Messenger of Islam",
      'image': 'assets/images/book thumb/Book_Thumb_14.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single/risala_en_rasulislam-v1.0.pdf',
    },
    {
      'title': "Concise Biography of the Prophet",
      'image': 'assets/images/book thumb/Book_Thumb_15.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single3/en-concise-biography.pdf',
    },
    {
      'title': "The Evil Consequences of Adultery",
      'image': 'assets/images/book thumb/Book_Thumb_16.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single/en_The_Evil_Consequences_of_Adultery.pdf',
    },
    {
      'title': "Clarification of Many Issues about Hajj, Umrah, and Visiting",
      'image': 'assets/images/book thumb/Book_Thumb_17.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single/risala_en-attahqiq_walidoh_2.pdf',
    },
    {
      'title':
          "Summarised Etiquettes and Rulings of Visiting the Prophet's Mosque",
      'image': 'assets/images/book thumb/Book_Thumb_19.png',
      'url':
          'https://d1.islamhouse.com/data/en/ih_books/single/risala_en_mukhtasarfiadabziarah.pdf',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 56) / 3;
    final cardHeight = cardWidth / 0.60;

    // Filter books based on search query
    final filteredBooks = books.where((book) {
      final title = book['title'] ?? '';
      return title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Select specific featured books
    final featuredBooks = books
        .where((book) =>
            book['title'] == "Translation of the Meaning of the Pure Qur'an" ||
            book['title'] ==
                "Prophet Muhammad's Manner of Performing Prayers" ||
            book['title'] == "Muhammad (pbuh)" ||
            book['title'] == "Useful Ways of Leading a Happy Life" ||
            book['title'] ==
                "Summarised Etiquettes and Rulings of Visiting the Prophet's Mosque")
        .toList();

    final isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Library',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: books.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.library_books_outlined,
                      size: 60, color: AppColors.textLight),
                  SizedBox(height: 16),
                  Text(
                    'No books added yet.',
                    style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Decorative Welcome Banner ---
                  _buildWelcomeBanner(isDark),

                  // --- Search Bar Section ---
                  _buildSearchBar(isDark),
                  const SizedBox(height: 8),

                  // --- Featured Side Scroller Section (Hidden during active search) ---
                  if (!isSearching && featuredBooks.isNotEmpty) ...[
                    _buildFeaturedSection(
                        context, isDark, featuredBooks, cardWidth, cardHeight),
                    const SizedBox(height: 16),
                  ],

                  // --- Explore Grid Title ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      isSearching
                          ? 'Search Results (${filteredBooks.length})'
                          : 'Explore Library',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- All Books Grid or Empty State ---
                  filteredBooks.isEmpty
                      ? _buildNoResultsState(isDark)
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          clipBehavior: Clip.none,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.60,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];
                            return GestureDetector(
                              onTap: () {
                                if (book['url'] != null &&
                                    book['url']!.isNotEmpty) {
                                  context.push('/pdf', extra: {
                                    'title': book['title'] ?? 'Document',
                                    'url': book['url'],
                                    'image': book['image'],
                                  });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 15,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: book['image'] != null &&
                                              book['image']!.isNotEmpty
                                          ? Image.asset(
                                              book['image']!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  _buildPlaceholder(),
                                            )
                                          : _buildPlaceholder(),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      color: isDark
                                          ? AppColors.surfaceDark
                                          : Colors.white,
                                      child: Text(
                                        book['title'] ?? 'Unknown Book',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.surfaceDark
                ]
              : [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gain Sacred Knowledge",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "\"Read in the name of your Lord who created.\" (96:1)\nExplore our curated collection of Islamic literature.",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: isDark
                        ? Colors.white70
                        : Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 76,
            height: 76,
            child: Center(
              child: OverflowBox(
                maxWidth: 92,
                maxHeight: 92,
                child: Image.asset(
                  'assets/images/Books_Page_Header_Logo.png',
                  width: 92,
                  height: 92,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1F2937),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: "Search library books by title...",
          hintStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.primary : Colors.black45,
            size: 22,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(
    BuildContext context,
    bool isDark,
    List<Map<String, String>> featuredBooks,
    double cardWidth,
    double cardHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Featured Readings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
        ),
        SizedBox(
          height: cardHeight + 16,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: featuredBooks.length,
            itemBuilder: (context, index) {
              final book = featuredBooks[index];
              final isLast = index == featuredBooks.length - 1;
              return GestureDetector(
                onTap: () {
                  if (book['url'] != null && book['url']!.isNotEmpty) {
                    context.push('/pdf', extra: {
                      'title': book['title'] ?? 'Document',
                      'url': book['url'],
                      'image': book['image'],
                    });
                  }
                },
                child: Container(
                  width: cardWidth,
                  margin: EdgeInsets.only(
                    right: isLast ? 0 : 12,
                    top: 8,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: book['image'] != null &&
                                book['image']!.isNotEmpty
                            ? Image.asset(
                                book['image']!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        child: Text(
                          book['title'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color:
                                isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsState(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          const SizedBox(height: 16),
          Text(
            "No Books Found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We couldn't find any books matching \"$_searchQuery\". Try checking the spelling or search for another title.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black45,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: AppColors.primary,
          size: 40,
        ),
      ),
    );
  }
}
