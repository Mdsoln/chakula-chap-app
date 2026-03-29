// lib/core/mock/mock_data.dart
//
// Central seed data for the investor demo.
// All prices in TZS. Dar es Salaam context.
// ─────────────────────────────────────────────────────────────────────────────

import '../../features/menu/data/models/menu_models.dart';
import '../../features/order_tracking/data/models/order_models.dart';
import '../../features/order_tracking/domain/entities/order_entity.dart';

abstract class MockData {
  // ── Categories ─────────────────────────────────────────────────────────────

  static final List<CategoryModel> categories = [
    const CategoryModel(id: 'cat-01', name: 'Rice Dishes',   emoji: '🍚', itemCount: 6),
    const CategoryModel(id: 'cat-02', name: 'Grills',        emoji: '🔥', itemCount: 5),
    const CategoryModel(id: 'cat-03', name: 'Street Food',   emoji: '🌯', itemCount: 7),
    const CategoryModel(id: 'cat-04', name: 'Soups & Stews', emoji: '🍲', itemCount: 4),
    const CategoryModel(id: 'cat-05', name: 'Seafood',       emoji: '🦐', itemCount: 5),
    const CategoryModel(id: 'cat-06', name: 'Drinks',        emoji: '🥤', itemCount: 6),
    const CategoryModel(id: 'cat-07', name: 'Desserts',      emoji: '🍮', itemCount: 4),
    const CategoryModel(id: 'cat-08', name: 'Breakfast',     emoji: '🍳', itemCount: 5),
  ];

  // ── Menu Items ─────────────────────────────────────────────────────────────

  static final List<MenuItemModel> menuItems = [
    // ── Rice Dishes ──────────────────────────────────────────
    const MenuItemModel(
      id: 'item-01', categoryId: 'cat-01',
      name: 'Wali wa Nazi na Kuku',
      description: 'Aromatic coconut rice slow-cooked with tender chicken, served with kachumbari and tamarind chutney.',
      price: 12000, emoji: '🍚', rating: 4.8, reviewCount: 312,
      prepTimeMinutes: 25, calories: 620, isAvailable: true, isFeatured: true, tag: '🔥 Best Seller',
      variants: [
        MenuItemVariantModel(id: 'v-01a', label: 'Half portion', priceModifier: -3000),
        MenuItemVariantModel(id: 'v-01b', label: 'Extra Chicken', priceModifier: 4000),
      ],
      extras: [
        MenuItemExtraModel(id: 'e-01', name: 'Extra Kachumbari', price: 1000),
        MenuItemExtraModel(id: 'e-02', name: 'Avocado', price: 2000),
      ],
    ),
    const MenuItemModel(
      id: 'item-02', categoryId: 'cat-01',
      name: 'Pilau ya Nyama',
      description: 'Zanzibar-style spiced pilau with slow-braised beef, garnished with fried onions and raita.',
      price: 14000, emoji: '🫕', rating: 4.9, reviewCount: 540,
      prepTimeMinutes: 30, calories: 710, isAvailable: true, isFeatured: true, tag: '⭐ Top Rated',
      variants: [
        MenuItemVariantModel(id: 'v-02a', label: 'Chicken instead', priceModifier: -2000),
      ],
      extras: [
        MenuItemExtraModel(id: 'e-03', name: 'Raita extra', price: 1500),
        MenuItemExtraModel(id: 'e-02', name: 'Avocado', price: 2000),
      ],
    ),
    const MenuItemModel(
      id: 'item-03', categoryId: 'cat-01',
      name: 'Wali Mboga na Samaki',
      description: 'White rice paired with coconut fish curry and seasonal greens. Light and flavourful.',
      price: 11000, emoji: '🐟', rating: 4.5, reviewCount: 187,
      prepTimeMinutes: 20, calories: 490, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-04', categoryId: 'cat-01',
      name: 'Biryani ya Kuku',
      description: 'Fragrant basmati rice layered with spiced chicken, saffron and rose water. A festive classic.',
      price: 16000, emoji: '🍗', rating: 4.7, reviewCount: 228,
      prepTimeMinutes: 35, calories: 780, isAvailable: true, isFeatured: true, tag: '🆕 New',
      variants: [
        MenuItemVariantModel(id: 'v-04a', label: 'Vegetarian', priceModifier: -3000),
        MenuItemVariantModel(id: 'v-04b', label: 'Prawn', priceModifier: 5000),
      ],
      extras: [
        MenuItemExtraModel(id: 'e-04', name: 'Boiled Egg', price: 1000),
        MenuItemExtraModel(id: 'e-05', name: 'Extra Sauce', price: 1500),
      ],
    ),
    const MenuItemModel(
      id: 'item-05', categoryId: 'cat-01',
      name: 'Ugali na Maharage',
      description: 'Classic stiff ugali served with rich red kidney bean stew. Comfort food at its best.',
      price: 6000, emoji: '🫘', rating: 4.3, reviewCount: 95,
      prepTimeMinutes: 15, calories: 520, isAvailable: true, isFeatured: false, tag: '💚 Vegan',
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-06', categoryId: 'cat-01',
      name: 'Wali Nyeupe na Mchuzi wa Nyama',
      description: 'Simple white rice with a slow-simmered beef curry. The people\'s favourite.',
      price: 9000, emoji: '🥘', rating: 4.4, reviewCount: 143,
      prepTimeMinutes: 20, calories: 560, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),

    // ── Grills ────────────────────────────────────────────────
    const MenuItemModel(
      id: 'item-07', categoryId: 'cat-02',
      name: 'Nyama Choma Platter',
      description: 'Mixed charcoal-grilled beef, goat, and chicken with kachumbari, ugali, and green chilli sauce.',
      price: 28000, emoji: '🍖', rating: 4.9, reviewCount: 671,
      prepTimeMinutes: 40, calories: 920, isAvailable: true, isFeatured: true, tag: '🔥 Best Seller',
      variants: [
        MenuItemVariantModel(id: 'v-07a', label: 'Beef only', priceModifier: -5000),
        MenuItemVariantModel(id: 'v-07b', label: 'Goat only', priceModifier: -4000),
      ],
      extras: [
        MenuItemExtraModel(id: 'e-06', name: 'Extra Ugali', price: 2000),
        MenuItemExtraModel(id: 'e-07', name: 'Chilli Sauce', price: 500),
      ],
    ),
    const MenuItemModel(
      id: 'item-08', categoryId: 'cat-02',
      name: 'Grilled Tilapia',
      description: 'Whole tilapia marinated in lemon, garlic, and Swahili spices, grilled to perfection.',
      price: 18000, emoji: '🐠', rating: 4.7, reviewCount: 289,
      prepTimeMinutes: 30, calories: 480, isAvailable: true, isFeatured: true, tag: '⭐ Top Rated',
      variants: [], extras: [
      MenuItemExtraModel(id: 'e-08', name: 'Chips', price: 3000),
      MenuItemExtraModel(id: 'e-09', name: 'Coleslaw', price: 1500),
    ],
    ),
    const MenuItemModel(
      id: 'item-09', categoryId: 'cat-02',
      name: 'Mishkaki ya Kuku',
      description: 'Juicy chicken skewers marinated overnight in coconut milk, ginger, and paprika.',
      price: 10000, emoji: '🍢', rating: 4.6, reviewCount: 215,
      prepTimeMinutes: 20, calories: 390, isAvailable: true, isFeatured: false, tag: null,
      variants: [
        MenuItemVariantModel(id: 'v-09a', label: '6 skewers', priceModifier: 0),
        MenuItemVariantModel(id: 'v-09b', label: '12 skewers', priceModifier: 8000),
      ],
      extras: [],
    ),
    const MenuItemModel(
      id: 'item-10', categoryId: 'cat-02',
      name: 'Grilled Prawns',
      description: 'Tiger prawns grilled with garlic butter, lime, and fresh coriander. Coastal delicacy.',
      price: 24000, emoji: '🦐', rating: 4.8, reviewCount: 198,
      prepTimeMinutes: 25, calories: 340, isAvailable: true, isFeatured: true, tag: '🌟 Premium',
      variants: [], extras: [
      MenuItemExtraModel(id: 'e-08', name: 'Chips', price: 3000),
    ],
    ),
    const MenuItemModel(
      id: 'item-11', categoryId: 'cat-02',
      name: 'BBQ Chicken Half',
      description: 'Half chicken marinated in smoky BBQ sauce, slow-grilled for 45 minutes.',
      price: 15000, emoji: '🍗', rating: 4.5, reviewCount: 176,
      prepTimeMinutes: 45, calories: 680, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [
      MenuItemExtraModel(id: 'e-08', name: 'Chips', price: 3000),
      MenuItemExtraModel(id: 'e-10', name: 'Garlic Bread', price: 2000),
    ],
    ),

    // ── Street Food ───────────────────────────────────────────
    const MenuItemModel(
      id: 'item-12', categoryId: 'cat-03',
      name: 'Zanzibar Pizza',
      description: 'Street-style crepe filled with minced meat, egg, onion, and cheese. Crispy and golden.',
      price: 7000, emoji: '🥙', rating: 4.8, reviewCount: 489,
      prepTimeMinutes: 12, calories: 420, isAvailable: true, isFeatured: true, tag: '🔥 Best Seller',
      variants: [
        MenuItemVariantModel(id: 'v-12a', label: 'Vegetarian', priceModifier: -1000),
        MenuItemVariantModel(id: 'v-12b', label: 'Extra Cheese', priceModifier: 1500),
        MenuItemVariantModel(id: 'v-12c', label: 'Sweet (Nutella + Banana)', priceModifier: 2000),
      ],
      extras: [],
    ),
    const MenuItemModel(
      id: 'item-13', categoryId: 'cat-03',
      name: 'Viazi Karai',
      description: 'Potatoes in a spiced chickpea batter, deep-fried until crisp. Topped with tamarind chutney.',
      price: 4000, emoji: '🥔', rating: 4.6, reviewCount: 322,
      prepTimeMinutes: 10, calories: 310, isAvailable: true, isFeatured: false, tag: '💚 Vegan',
      variants: [], extras: [
      MenuItemExtraModel(id: 'e-11', name: 'Extra Chutney', price: 500),
    ],
    ),
    const MenuItemModel(
      id: 'item-14', categoryId: 'cat-03',
      name: 'Samosa za Nyama (6 pcs)',
      description: 'Crispy triangular pastries filled with spiced minced beef and green peas.',
      price: 5000, emoji: '🥟', rating: 4.5, reviewCount: 267,
      prepTimeMinutes: 8, calories: 380, isAvailable: true, isFeatured: true, tag: null,
      variants: [
        MenuItemVariantModel(id: 'v-14a', label: 'Vegetable filling', priceModifier: -1000),
      ],
      extras: [],
    ),
    const MenuItemModel(
      id: 'item-15', categoryId: 'cat-03',
      name: 'Mkate wa Mofa',
      description: 'Traditional Swahili flatbread baked in a clay oven. Perfect with any stew or curry.',
      price: 2000, emoji: '🫓', rating: 4.4, reviewCount: 115,
      prepTimeMinutes: 15, calories: 250, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-16', categoryId: 'cat-03',
      name: 'Chips Mayai',
      description: 'A Tanzanian street staple — thick chips bound together with egg and fried as a hearty omelette.',
      price: 6000, emoji: '🍳', rating: 4.7, reviewCount: 403,
      prepTimeMinutes: 15, calories: 510, isAvailable: true, isFeatured: true, tag: '⭐ Top Rated',
      variants: [
        MenuItemVariantModel(id: 'v-16a', label: 'With kachumbari', priceModifier: 500),
      ],
      extras: [
        MenuItemExtraModel(id: 'e-12', name: 'Chilli Sauce', price: 500),
      ],
    ),
    const MenuItemModel(
      id: 'item-17', categoryId: 'cat-03',
      name: 'Mandazi (4 pcs)',
      description: 'Lightly sweetened East African doughnuts flavoured with cardamom and coconut milk.',
      price: 3000, emoji: '🍩', rating: 4.3, reviewCount: 88,
      prepTimeMinutes: 10, calories: 280, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-18', categoryId: 'cat-03',
      name: 'Urojo (Zanzibar Mix)',
      description: 'Tangy mango soup loaded with bhajias, viazi karai, samosa pieces, and chilli. Iconic street dish.',
      price: 5500, emoji: '🍜', rating: 4.9, reviewCount: 612,
      prepTimeMinutes: 10, calories: 350, isAvailable: true, isFeatured: true, tag: '🏆 Iconic',
      variants: [], extras: [],
    ),

    // ── Soups & Stews ──────────────────────────────────────────
    const MenuItemModel(
      id: 'item-19', categoryId: 'cat-04',
      name: 'Mchuzi wa Samaki',
      description: 'Coastal fish curry in a rich coconut and tomato gravy, simmered with Zanzibar spices.',
      price: 13000, emoji: '🍛', rating: 4.6, reviewCount: 201,
      prepTimeMinutes: 25, calories: 420, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [
      MenuItemExtraModel(id: 'e-06', name: 'Extra Ugali', price: 2000),
    ],
    ),
    const MenuItemModel(
      id: 'item-20', categoryId: 'cat-04',
      name: 'Supu ya Ndizi',
      description: 'Hearty green banana soup with goat meat, spiced with fresh ginger and coriander.',
      price: 9000, emoji: '🍌', rating: 4.4, reviewCount: 134,
      prepTimeMinutes: 35, calories: 480, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-21', categoryId: 'cat-04',
      name: 'Bone Broth Soup',
      description: 'Rich slow-simmered beef bone soup with vegetables. Great for cold mornings.',
      price: 8000, emoji: '🦴', rating: 4.5, reviewCount: 109,
      prepTimeMinutes: 20, calories: 280, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-22', categoryId: 'cat-04',
      name: 'Lentil Soup (Supu ya Dengu)',
      description: 'Creamy red lentil soup cooked with cumin, turmeric, and lemon. Vegan and filling.',
      price: 7000, emoji: '🫘', rating: 4.3, reviewCount: 87,
      prepTimeMinutes: 20, calories: 310, isAvailable: true, isFeatured: false, tag: '💚 Vegan',
      variants: [], extras: [],
    ),

    // ── Seafood ────────────────────────────────────────────────
    const MenuItemModel(
      id: 'item-23', categoryId: 'cat-05',
      name: 'Coconut Prawn Curry',
      description: 'Jumbo prawns in a velvety coconut milk curry with lemongrass and kaffir lime.',
      price: 22000, emoji: '🦞', rating: 4.8, reviewCount: 256,
      prepTimeMinutes: 25, calories: 520, isAvailable: true, isFeatured: true, tag: '🌟 Premium',
      variants: [], extras: [
      MenuItemExtraModel(id: 'e-06', name: 'Extra Ugali', price: 2000),
    ],
    ),
    const MenuItemModel(
      id: 'item-24', categoryId: 'cat-05',
      name: 'Calamari Rings',
      description: 'Crispy golden calamari with a light batter, served with garlic aioli.',
      price: 14000, emoji: '🦑', rating: 4.5, reviewCount: 143,
      prepTimeMinutes: 15, calories: 380, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-25', categoryId: 'cat-05',
      name: 'Octopus Salad',
      description: 'Tender octopus tossed with cucumber, tomato, red onion, lime juice and olive oil.',
      price: 18000, emoji: '🐙', rating: 4.7, reviewCount: 178,
      prepTimeMinutes: 20, calories: 290, isAvailable: true, isFeatured: true, tag: '⭐ Top Rated',
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-26', categoryId: 'cat-05',
      name: 'Crab in Garlic Butter',
      description: 'Fresh local crab halves sautéed in garlic, butter, and white wine. Market-fresh.',
      price: 26000, emoji: '🦀', rating: 4.9, reviewCount: 89,
      prepTimeMinutes: 30, calories: 440, isAvailable: true, isFeatured: true, tag: '🌟 Premium',
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-27', categoryId: 'cat-05',
      name: 'Fish & Chips',
      description: 'Beer-battered local white fish with crispy chips, tartar sauce, and a lemon wedge.',
      price: 13000, emoji: '🐟', rating: 4.4, reviewCount: 202,
      prepTimeMinutes: 20, calories: 620, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),

    // ── Drinks ─────────────────────────────────────────────────
    const MenuItemModel(
      id: 'item-28', categoryId: 'cat-06',
      name: 'Fresh Passion Juice',
      description: 'Pressed fresh passionfruit chilled with ice. No added sugar.',
      price: 4000, emoji: '🧃', rating: 4.7, reviewCount: 344,
      prepTimeMinutes: 3, calories: 90, isAvailable: true, isFeatured: true, tag: null,
      variants: [
        MenuItemVariantModel(id: 'v-28a', label: 'Large (750ml)', priceModifier: 2000),
      ],
      extras: [],
    ),
    const MenuItemModel(
      id: 'item-29', categoryId: 'cat-06',
      name: 'Avocado Smoothie',
      description: 'Thick blended avocado with milk, honey, and vanilla. Rich and nutritious.',
      price: 6000, emoji: '🥑', rating: 4.8, reviewCount: 298,
      prepTimeMinutes: 5, calories: 310, isAvailable: true, isFeatured: true, tag: '🔥 Trending',
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-30', categoryId: 'cat-06',
      name: 'Tangawizi Lemonade',
      description: 'Fresh ginger and lemon juice with honey, sparkling water, and mint. Refreshing kick.',
      price: 5000, emoji: '🍋', rating: 4.6, reviewCount: 187,
      prepTimeMinutes: 3, calories: 70, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-31', categoryId: 'cat-06',
      name: 'Madafu (Fresh Coconut)',
      description: 'Young green coconut served ice-cold. Nature\'s own sports drink.',
      price: 3500, emoji: '🥥', rating: 4.9, reviewCount: 512,
      prepTimeMinutes: 2, calories: 60, isAvailable: true, isFeatured: true, tag: '💚 Natural',
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-32', categoryId: 'cat-06',
      name: 'Chai ya Tangawizi',
      description: 'Swahili spiced ginger milk tea. Warm, comforting, and perfectly spiced.',
      price: 2500, emoji: '🍵', rating: 4.5, reviewCount: 156,
      prepTimeMinutes: 5, calories: 120, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-33', categoryId: 'cat-06',
      name: 'Tamarind Juice',
      description: 'Tangy-sweet tamarind drink with a touch of chilli and rock salt. A Zanzibar classic.',
      price: 3000, emoji: '🫙', rating: 4.4, reviewCount: 134,
      prepTimeMinutes: 2, calories: 80, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),

    // ── Desserts ───────────────────────────────────────────────
    const MenuItemModel(
      id: 'item-34', categoryId: 'cat-07',
      name: 'Kashata ya Nazi',
      description: 'Crunchy coconut candy sweetened with jaggery and cardamom. Bite-sized squares.',
      price: 3000, emoji: '🍬', rating: 4.5, reviewCount: 98,
      prepTimeMinutes: 5, calories: 200, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-35', categoryId: 'cat-07',
      name: 'Halwa ya Zanzibar',
      description: 'Rich gelatinous halwa flavoured with rose water, cardamom, and saffron. Melt-in-mouth.',
      price: 5000, emoji: '🍮', rating: 4.8, reviewCount: 167,
      prepTimeMinutes: 5, calories: 280, isAvailable: true, isFeatured: true, tag: '⭐ Top Rated',
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-36', categoryId: 'cat-07',
      name: 'Maandazi na Chai',
      description: 'Warm cardamom doughnuts served with a pot of masala tea. Classic afternoon treat.',
      price: 4500, emoji: '☕', rating: 4.6, reviewCount: 211,
      prepTimeMinutes: 10, calories: 350, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-37', categoryId: 'cat-07',
      name: 'Mango Sorbet',
      description: 'Homemade mango sorbet with Alphonso mango pulp. No dairy, naturally vegan.',
      price: 4000, emoji: '🥭', rating: 4.7, reviewCount: 143,
      prepTimeMinutes: 2, calories: 150, isAvailable: true, isFeatured: true, tag: '💚 Vegan',
      variants: [], extras: [],
    ),

    // ── Breakfast ──────────────────────────────────────────────
    const MenuItemModel(
      id: 'item-38', categoryId: 'cat-08',
      name: 'Full Swahili Breakfast',
      description: 'Vitumbua, mandazi, boiled egg, uji wa mtama, and freshly brewed chai. The full spread.',
      price: 8000, emoji: '🍽️', rating: 4.7, reviewCount: 234,
      prepTimeMinutes: 15, calories: 580, isAvailable: true, isFeatured: true, tag: '🌅 Breakfast',
      variants: [], extras: [
      MenuItemExtraModel(id: 'e-04', name: 'Extra Egg', price: 1000),
    ],
    ),
    const MenuItemModel(
      id: 'item-39', categoryId: 'cat-08',
      name: 'Vitumbua (6 pcs)',
      description: 'Soft coconut rice pancakes pan-fried in a special mould. Slightly sweet and fluffy.',
      price: 4000, emoji: '🥞', rating: 4.6, reviewCount: 178,
      prepTimeMinutes: 12, calories: 320, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-40', categoryId: 'cat-08',
      name: 'Uji wa Mtama',
      description: 'Warm sorghum porridge sweetened with coconut milk. Nutrient-rich morning fuel.',
      price: 3000, emoji: '🥣', rating: 4.4, reviewCount: 89,
      prepTimeMinutes: 8, calories: 210, isAvailable: true, isFeatured: false, tag: '💚 Vegan',
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-41', categoryId: 'cat-08',
      name: 'Eggs Benedict Swahili Style',
      description: 'Poached eggs on mkate wa mofa, topped with spiced hollandaise and fresh coriander.',
      price: 11000, emoji: '🍳', rating: 4.5, reviewCount: 112,
      prepTimeMinutes: 18, calories: 490, isAvailable: true, isFeatured: true, tag: '🆕 New',
      variants: [], extras: [],
    ),
    const MenuItemModel(
      id: 'item-42', categoryId: 'cat-08',
      name: 'Avocado Toast',
      description: 'Thick toast smeared with smashed avocado, chilli flakes, lime, and poached egg.',
      price: 9000, emoji: '🥑', rating: 4.6, reviewCount: 156,
      prepTimeMinutes: 10, calories: 380, isAvailable: true, isFeatured: false, tag: null,
      variants: [], extras: [],
    ),
  ];

  // ── Mock Rider ─────────────────────────────────────────────────────────────

  static const RiderModel mockRider = RiderModel(
    id: 'rider-01',
    name: 'Juma Bakari',
    phone: '+255 745 123 456',
    rating: 4.9,
    totalDeliveries: 1247,
    avatarUrl: null,
  );

  // ── Mock past Orders (pre-seeded history) ─────────────────────────────────

  static List<OrderModel> pastOrders = [
    OrderModel(
      id: 'order-history-01',
      orderNumber: 'ZTU-20240001',
      items: [
        const OrderItemModel(
          menuItemId: 'item-02', menuItemName: 'Pilau ya Nyama',
          menuItemEmoji: '🫕', unitPrice: 14000, quantity: 2, lineTotal: 28000,
        ),
        const OrderItemModel(
          menuItemId: 'item-29', menuItemName: 'Avocado Smoothie',
          menuItemEmoji: '🥑', unitPrice: 6000, quantity: 2, lineTotal: 12000,
        ),
      ],
      deliveryAddress: const DeliveryAddressModel(
        label: 'Home', street: '14 Msasani Road', area: 'Msasani', city: 'Dar es Salaam',
        latitude: -6.7652, longitude: 39.2848,
      ),
      paymentMethod: 'mpesa',
      status: 'delivered',
      subtotal: 40000, deliveryFee: 3000, discount: 0, total: 43000,
      paymentReference: 'MPE202401-XK99',
      placedAt: DateTime.now().subtract(const Duration(days: 3)),
      estimatedDeliveryAt: DateTime.now().subtract(const Duration(days: 3, hours: -1)),
      rider: MockData.mockRider,
    ),
    OrderModel(
      id: 'order-history-02',
      orderNumber: 'ZTU-20240002',
      items: [
        const OrderItemModel(
          menuItemId: 'item-07', menuItemName: 'Nyama Choma Platter',
          menuItemEmoji: '🍖', unitPrice: 28000, quantity: 1, lineTotal: 28000,
        ),
        const OrderItemModel(
          menuItemId: 'item-31', menuItemName: 'Madafu',
          menuItemEmoji: '🥥', unitPrice: 3500, quantity: 3, lineTotal: 10500,
        ),
      ],
      deliveryAddress: const DeliveryAddressModel(
        label: 'Office', street: 'PSPF Towers, Ohio Street', area: 'CBD', city: 'Dar es Salaam',
        latitude: -6.8163, longitude: 39.2894,
      ),
      paymentMethod: 'cashOnDelivery',
      status: 'delivered',
      subtotal: 38500, deliveryFee: 5000, discount: 2000, total: 41500,
      placedAt: DateTime.now().subtract(const Duration(days: 7)),
      estimatedDeliveryAt: DateTime.now().subtract(const Duration(days: 7, hours: -1)),
      rider: MockData.mockRider,
    ),
    OrderModel(
      id: 'order-history-03',
      orderNumber: 'ZTU-20240003',
      items: [
        const OrderItemModel(
          menuItemId: 'item-12', menuItemName: 'Zanzibar Pizza',
          menuItemEmoji: '🥙', unitPrice: 7000, quantity: 3, lineTotal: 21000,
        ),
        const OrderItemModel(
          menuItemId: 'item-28', menuItemName: 'Fresh Passion Juice',
          menuItemEmoji: '🧃', unitPrice: 4000, quantity: 3, lineTotal: 12000,
        ),
      ],
      deliveryAddress: const DeliveryAddressModel(
        label: 'Home', street: '8 Kigamboni Ferry Rd', area: 'Kigamboni', city: 'Dar es Salaam',
        latitude: -6.8327, longitude: 39.3117,
      ),
      paymentMethod: 'tigoPesa',
      status: 'delivered',
      subtotal: 33000, deliveryFee: 4000, discount: 0, total: 37000,
      paymentReference: 'TIGO202401-ZZ12',
      placedAt: DateTime.now().subtract(const Duration(days: 14)),
      estimatedDeliveryAt: DateTime.now().subtract(const Duration(days: 14, hours: -1)),
      rider: MockData.mockRider,
    ),
  ];

  // ── Order Status Progression Timeline ─────────────────────────────────────
  // Simulates real-world timing after order placement.
  // Each entry: (status, delay from placement, rider lat/lng for map)

  static const List<_StatusStep> orderProgressionTimeline = [
    _StatusStep(OrderStatus.pending,    Duration(seconds: 0),    null, null),
    _StatusStep(OrderStatus.confirmed,  Duration(seconds: 15),   null, null, '✅ Restaurant confirmed your order!'),
    _StatusStep(OrderStatus.preparing,  Duration(seconds: 30),   null, null, '👨‍🍳 Kitchen is preparing your food'),
    _StatusStep(OrderStatus.ready,      Duration(minutes: 2),    -6.7740, 39.2501, '📦 Order packed and rider assigned!'),
    _StatusStep(OrderStatus.pickedUp,   Duration(minutes: 2, seconds: 30), -6.7820, 39.2620, '🛵 Rider picked up your order!'),
    _StatusStep(OrderStatus.delivered,  Duration(minutes: 4),    -6.8000, 39.2780, '🏠 Order delivered! Enjoy your meal 🎉'),
  ];
}

// ── Internal helper ────────────────────────────────────────────────────────────

class _StatusStep {
  final OrderStatus status;
  final Duration delay;
  final double? riderLat;
  final double? riderLng;
  final String? message;

  const _StatusStep(this.status, this.delay, this.riderLat, this.riderLng, [this.message]);
}