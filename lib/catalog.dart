import 'package:flutter/material.dart';
import 'models.dart';

/// Products carry a real BigBasket photograph only when the photo genuinely
/// matches that brand and pack. Everything else falls back to a brand-styled
/// packaging card, so the shelf never shows a mismatched product.
///
/// Mutable (not const) so admin-added products fetched from Supabase can be
/// appended at runtime — see [catalogStore].
final List<Product> kProducts = [
  // ── Grains, Rice & Staples ──
  Product(id: 1, name: 'Aashirvaad Atta', brand: 'Aashirvaad', category: 'grains', emoji: '🌾', unit: '5 kg', packLabel: 'Whole Wheat Atta', price: 275, image: '126906_10-aashirvaad-atta-whole-wheat.jpg', flag: Flag.bestseller),
  Product(id: 2, name: 'India Gate Basmati', brand: 'India Gate', category: 'grains', emoji: '🍚', unit: '5 kg', packLabel: 'Feast Rozzana Basmati', price: 499, image: '30000590_5-india-gate-basmati-rice-feast-rozzana.jpg'),
  Product(id: 3, name: 'MahaRaja Ponni Rice', brand: 'MahaRaja Choice', category: 'grains', emoji: '🌾', unit: '5 kg', packLabel: 'Ponni Boiled Rice', price: 365, flag: Flag.bestseller),
  Product(id: 4, name: 'Fortune Chakki Fresh Atta', brand: 'Fortune', category: 'grains', emoji: '🌾', unit: '5 kg', packLabel: 'Chakki Fresh Atta', price: 260, image: '40120174_7-fortune-chakki-fresh-atta-100-atta-0-maida.jpg'),
  Product(id: 5, name: 'Toor Dal Premium', brand: 'MahaRaja Choice', category: 'grains', emoji: '🫘', unit: '1 kg', packLabel: 'Toor Dal', price: 145),
  Product(id: 6, name: 'MTR Rava Idli Mix', brand: 'MTR', category: 'grains', emoji: '🟡', unit: '500 g', packLabel: 'Breakfast Rava Idli Mix', price: 95, image: '265966_6-mtr-breakfast-mix-rava-idli.jpg'),
  Product(id: 7, name: 'Daawat Rozana Super', brand: 'Daawat', category: 'grains', emoji: '🍚', unit: '5 kg', packLabel: 'Rozana Super Basmati', price: 380, image: '40075197_8-daawat-basmati-rice-rozana-super-90.jpg'),
  Product(id: 8, name: 'Fortune Maida', brand: 'Fortune', category: 'grains', emoji: '🤍', unit: '500 g', packLabel: 'Refined Wheat Flour', price: 42, image: '40194163_7-fortune-maida.jpg'),
  Product(id: 9, name: 'Urad Dal White', brand: 'MahaRaja Choice', category: 'grains', emoji: '⚪', unit: '1 kg', packLabel: 'Urad Dal Whole', price: 120),
  Product(id: 10, name: 'Rajma Chitra', brand: 'Naga', category: 'grains', emoji: '🫘', unit: '1 kg', packLabel: 'Rajma Chitra', price: 130),

  // ── Edible Oils & Ghee ──
  Product(id: 11, name: 'Fortune Kachi Ghani Mustard Oil', brand: 'Fortune', category: 'oils', emoji: '🌻', unit: '1 L', packLabel: 'Kachi Ghani Mustard Oil', price: 145, image: '276756_14-fortune-fortune-premium-kachi-ghani-pure-mustard-oil.jpg', flag: Flag.bestseller),
  Product(id: 12, name: 'Gold Winner Sunflower Oil', brand: 'Gold Winner', category: 'oils', emoji: '🌻', unit: '1 L', packLabel: 'Refined Sunflower Oil', price: 140, image: '274141_11-gold-winner-refined-sunflower-oil.jpg'),
  Product(id: 13, name: 'Idhayam Gingelly Oil', brand: 'Idhayam', category: 'oils', emoji: '🫙', unit: '500 ml', packLabel: 'Gingelly Oil', price: 165, image: '148682_1-idhayam-oil-gingelly.jpg'),
  Product(id: 14, name: 'Amul Pure Ghee', brand: 'Amul', category: 'oils', emoji: '✨', unit: '500 ml', packLabel: 'Pure Ghee', price: 330, image: '40050541_5-amul-amul-ghee-500-ml.jpg', flag: Flag.bestseller),
  Product(id: 15, name: 'GRB Cow Ghee', brand: 'GRB', category: 'oils', emoji: '✨', unit: '500 ml', packLabel: 'Cow Ghee', price: 380, image: '255834_6-grb-ghee.jpg'),
  Product(id: 16, name: 'Sundrop Superlite Advanced', brand: 'Sundrop', category: 'oils', emoji: '💛', unit: '850 g', packLabel: 'Refined Sunflower Oil', price: 160, image: '255499_4-sundrop-super-lite-advanced-sunflower-oil.jpg'),

  // ── Spices & Masalas ──
  Product(id: 17, name: 'Aachi Chicken Masala', brand: 'Aachi', category: 'spices', emoji: '🌶️', unit: '200 g', packLabel: 'Chicken Masala', price: 95, image: '40214400_1-aachi-chicken-masala.jpg', flag: Flag.bestseller),
  Product(id: 18, name: 'Sakthi Sambar Powder', brand: 'Sakthi', category: 'spices', emoji: '🟤', unit: '100 g', packLabel: 'Sambar Powder', price: 55, image: '100286338_2-sakthi-powder-sambar.jpg'),
  Product(id: 19, name: 'Everest Chaat Masala', brand: 'Everest', category: 'spices', emoji: '🟡', unit: '100 g', packLabel: 'Chaat Masala', price: 38, image: '268937_3-everest-chaat-masala.jpg', flag: Flag.bestseller),
  Product(id: 20, name: 'MDH Garam Masala', brand: 'MDH', category: 'spices', emoji: '🌶️', unit: '100 g', packLabel: 'Garam Masala', price: 65, image: '100004473_4-mdh-masala-garam.jpg'),
  Product(id: 21, name: 'Eastern Sambar Powder', brand: 'Eastern', category: 'spices', emoji: '🟠', unit: '100 g', packLabel: 'Sambar Powder', price: 45, image: '40298714_1-eastern-sambar-powder-100-natural-spice-blend-no-preservatives.jpg'),
  Product(id: 22, name: 'Tata Salt', brand: 'Tata', category: 'spices', emoji: '⚪', unit: '1 kg', packLabel: 'Iodised Salt', price: 28, image: '241600_9-tata-salt-iodized.jpg'),
  Product(id: 23, name: 'Catch Chilli Flakes', brand: 'Catch', category: 'spices', emoji: '🌶️', unit: '30 g', packLabel: 'Red Chilli Flakes', price: 52, image: '40285105_1-catch-red-chilli-flakes-adds-flavour.jpg'),
  Product(id: 24, name: "Parry's Sugar", brand: "Parry's", category: 'spices', emoji: '🤍', unit: '1 kg', packLabel: 'White Label Sugar', price: 48, image: '40004538_2-parrys-sugar-white-label.jpg'),

  // ── Dairy & Frozen ──
  Product(id: 25, name: 'Aavin Full Cream Milk', brand: 'Aavin', category: 'dairy', emoji: '🥛', unit: '500 ml', packLabel: 'Pasteurised Full Cream', price: 27, image: '40151384_1-aavin-pasteurised-full-cream-milk.jpg', flag: Flag.bestseller),
  Product(id: 26, name: 'Amul Butter', brand: 'Amul', category: 'dairy', emoji: '🧈', unit: '100 g', packLabel: 'Pasteurised Butter', price: 58, image: '104860_8-amul-butter-pasteurised.jpg', flag: Flag.bestseller),
  Product(id: 27, name: 'Milky Mist Paneer', brand: 'Milky Mist', category: 'dairy', emoji: '🧀', unit: '200 g', packLabel: 'Premium Fresh Paneer', price: 95, image: '264679_6-milky-mist-paneer-premium-fresh.jpg'),
  Product(id: 28, name: 'Heritage Total Curd', brand: 'Heritage', category: 'dairy', emoji: '🥣', unit: '400 g', packLabel: 'Total Curd', price: 35, image: '225759_15-heritage-curd-premium.jpg'),
  Product(id: 29, name: 'Arun Vanilla Cone', brand: 'Arun', category: 'dairy', emoji: '🍨', unit: '100 ml', packLabel: 'Vanilla Ice Cream Cone', price: 60, mrp: 75, image: '40339211_1-arun-icecreams-vanilla-icone.jpg', flag: Flag.sale),
  Product(id: 30, name: 'McCain French Fries', brand: 'McCain', category: 'dairy', emoji: '🍟', unit: '1 kg', packLabel: 'French Fries', price: 265, image: '40355765_6-mccain-french-fries.jpg'),
  Product(id: 31, name: 'Amul Cheese Slices', brand: 'Amul', category: 'dairy', emoji: '🧀', unit: '200 g', packLabel: 'Pure Milk Cheese Slices', price: 135, image: '104808_9-amul-cheese-slices.jpg'),
  Product(id: 32, name: 'Hatsun Curd', brand: 'Hatsun', category: 'dairy', emoji: '🥣', unit: '500 g', packLabel: 'Fresh Curd', price: 32, image: '40339220_1-hatsun-hatsun-curd.jpg'),
  Product(id: 33, name: "Kwality Wall's Cone", brand: "Kwality Wall's", category: 'dairy', emoji: '🍦', unit: '105 ml', packLabel: 'Frozen Dessert Cone', price: 45, image: '40062731_7-kwality-walls-cornetto-double-chocolate-frozen-dessert.jpg'),
  Product(id: 34, name: 'Amul Taaza Milk', brand: 'Amul', category: 'dairy', emoji: '🥛', unit: '500 ml', packLabel: 'Homogenised Toned Milk', price: 32, image: '40041431_1-amul-taaza-fresh-toned-milk.jpg'),

  // ── Bakery ──
  Product(id: 35, name: 'Britannia Whole Wheat Bread', brand: 'Britannia', category: 'bakery', emoji: '🍞', unit: '1 pack', packLabel: '100% Whole Wheat', price: 40, image: '40162924_7-britannia-100-whole-wheat-bread.jpg', flag: Flag.bestseller),
  Product(id: 36, name: 'English Oven Brown Bread', brand: 'English Oven', category: 'bakery', emoji: '🍞', unit: '400 g', packLabel: 'Brown Bread', price: 55, image: '70001169_14-english-oven-bread-brown.jpg'),
  Product(id: 37, name: 'MahaRaja Fresh Cake', brand: 'MahaRaja Bakery', category: 'bakery', emoji: '🍰', unit: '250 g', packLabel: 'Fresh Cake', price: 85, flag: Flag.isNew),
  Product(id: 38, name: 'Britannia Toastea Rusk', brand: 'Britannia', category: 'bakery', emoji: '🥖', unit: '182 g', packLabel: 'Milk Atta Rusk', price: 45, image: '407839_13-britannia-toastea-milk-rusk-with-goodness-of-milk-wheat.jpg'),
  Product(id: 39, name: 'Modern Choco Fill Bun', brand: 'Modern', category: 'bakery', emoji: '🧁', unit: '50 g', packLabel: 'Choco Sweet Fill Bun', price: 20, image: '40005981_6-modern-choco-fill.jpg'),

  // ── Snacks & Packaged Foods ──
  Product(id: 40, name: "Lay's Cream & Onion", brand: "Lay's", category: 'snacks', emoji: '🥔', unit: '95 g', packLabel: 'American Style', price: 40, image: '1212514_12-lays-potato-chips-american-style-cream-onion-flavour.jpg', flag: Flag.bestseller),
  Product(id: 41, name: "Haldiram's Bhujia Sev", brand: "Haldiram's", category: 'snacks', emoji: '🍿', unit: '200 g', packLabel: 'Namkeen Bhujia Sev', price: 65, image: '100022552_5-haldirams-namkeen-bhujia-sev.jpg'),
  Product(id: 42, name: 'Maggi 2-Min Noodles', brand: 'Maggi', category: 'snacks', emoji: '🍜', unit: '4 pack', packLabel: 'Masala Noodles', price: 56, image: '266112_27-maggi-2-minute-instant-noodles-masala.jpg', flag: Flag.bestseller),
  Product(id: 43, name: 'Parle-G Biscuits', brand: 'Parle', category: 'snacks', emoji: '🍪', unit: '250 g', packLabel: 'Glucose Biscuits', price: 30, image: '102102_4-parle-gluco-biscuits-parle-g.jpg'),
  Product(id: 44, name: 'Cadbury Dairy Milk', brand: 'Cadbury', category: 'snacks', emoji: '🍫', unit: '150 g', packLabel: 'Dairy Milk Chocolate', price: 85, image: '1200590_16-cadbury-dairy-milk-chocolate.jpg', flag: Flag.bestseller),
  Product(id: 45, name: 'Bingo Mad Angles', brand: 'Bingo!', category: 'snacks', emoji: '🔺', unit: '60 g', packLabel: 'Tomato Madness', price: 20, image: '238342_23-bingo-mad-angles-tomato-madness.jpg'),
  Product(id: 46, name: 'Sunfeast Dark Fantasy', brand: 'Sunfeast', category: 'snacks', emoji: '🍪', unit: '75 g', packLabel: 'Bourbon Choco Cream', price: 40, image: '40077089_19-sunfeast-dark-fantasy-bourbon-chocolate-cream-biscuits.jpg'),
  Product(id: 47, name: "Kellogg's Corn Flakes", brand: "Kellogg's", category: 'snacks', emoji: '🥣', unit: '275 g', packLabel: 'Original Corn Flakes', price: 145, image: '40235172_11-kellogs-corn-flakes-rich-in-protein-vitamins-essential-minerals-original.jpg'),
  Product(id: 48, name: 'Oreo Vanilla Cream', brand: 'Oreo', category: 'snacks', emoji: '🍪', unit: '120 g', packLabel: 'Sandwich Biscuit', price: 30, image: '40260443_24-cadbury-oreo-chocolatey-sandwich-biscuit-crunchy-vanilla-flavour-mega-family-pack.jpg'),
  Product(id: 49, name: 'Kurkure Masala Munch', brand: 'Kurkure', category: 'snacks', emoji: '🟠', unit: '90 g', packLabel: 'Masala Munch', price: 20, image: '1205616_6-kurkure-namkeen-masala-munch.jpg'),

  // ── Sauces, Jams & Spreads ──
  Product(id: 50, name: 'Kissan Tomato Ketchup', brand: 'Kissan', category: 'sauces', emoji: '🍅', unit: '500 g', packLabel: 'Fresh Tomato Ketchup', price: 115, image: '40226027_11-kissan-fresh-tomato-ketchup-tasty-yummy-healthy.jpg', flag: Flag.bestseller),
  Product(id: 51, name: 'Nutella Spread', brand: 'Nutella', category: 'sauces', emoji: '🟤', unit: '750 g', packLabel: 'Hazelnut & Cocoa Spread', price: 799, image: '40102776_10-nutella-hazelnut-spread-with-cocoa.jpg'),
  Product(id: 52, name: 'Maggi Hot & Sweet', brand: 'Maggi', category: 'sauces', emoji: '🌶️', unit: '1 kg', packLabel: 'Tomato Chilli Sauce', price: 225, image: '119705_14-maggi-hot-sweet-tomato-chilli-sauce.jpg'),
  Product(id: 53, name: 'Dabur Honey', brand: 'Dabur', category: 'sauces', emoji: '🍯', unit: '500 g', packLabel: '100% Pure Honey', price: 225, image: '202277_11-dabur-100-pure-honey-worlds-no1-honey-brand-with-no-sugar-adulteration.jpg'),
  Product(id: 54, name: 'Del Monte Pasta Sauce', brand: 'Del Monte', category: 'sauces', emoji: '🍝', unit: '400 g', packLabel: 'Pizza & Pasta Sauce', price: 110, image: '40122969_3-del-monte-sauce-pizza-pasta-spout.jpg'),

  // ── Beverages ──
  Product(id: 55, name: 'Tata Tea Gold', brand: 'Tata Tea', category: 'beverages', emoji: '🍵', unit: '500 g', packLabel: 'Gold Leaf Tea', price: 275, image: '40200082_6-tata-tea-gold-tea.jpg', flag: Flag.bestseller),
  Product(id: 56, name: 'Nescafe Gold Blend', brand: 'Nescafe', category: 'beverages', emoji: '☕', unit: '100 g', packLabel: 'Instant Coffee Powder', price: 320, image: '40154923_14-nescafe-gold-blend-instant-coffee-powder-rich-smooth.jpg'),
  Product(id: 57, name: 'Bru Instant Coffee', brand: 'Bru', category: 'beverages', emoji: '☕', unit: '50 g', packLabel: 'Instant Coffee', price: 125, image: '266579_29-bru-instant-coffee.jpg', flag: Flag.bestseller),
  Product(id: 58, name: 'Tropicana Orange Delight', brand: 'Tropicana', category: 'beverages', emoji: '🍊', unit: '1 L', packLabel: 'Orange Fruit Juice', price: 120, image: '229792_20-tropicana-fruit-juice-delight-orange.jpg'),
  Product(id: 59, name: 'Coca-Cola Diet Coke', brand: 'Coca-Cola', category: 'beverages', emoji: '🥤', unit: '330 ml', packLabel: 'Diet Coke', price: 40, image: '40371247_1-coca-cola-diet-coke.jpg'),
  Product(id: 60, name: 'Horlicks Classic Malt', brand: 'Horlicks', category: 'beverages', emoji: '🥛', unit: '500 g', packLabel: 'Nutrition Drink', price: 285, image: '40359128_1-horlicks-classic-malt-nutrition-drink.jpg'),
  Product(id: 61, name: 'Red Bull Energy', brand: 'Red Bull', category: 'beverages', emoji: '🥫', unit: '250 ml', packLabel: 'Energy Drink', price: 125, image: '13377_3-red-bull-energy-drink.jpg'),
  Product(id: 62, name: 'Bournvita Health Drink', brand: 'Bournvita', category: 'beverages', emoji: '🟤', unit: '500 g', packLabel: 'Chocolate Health Drink', price: 240, image: '40133416_31-cadbury-chocolate-health-drink-bournvita.jpg'),

  // ── Personal Care ──
  Product(id: 63, name: 'Dove Beauty Bar', brand: 'Dove', category: 'personal', emoji: '🧼', unit: '100 g', packLabel: 'Cream Beauty Bar', price: 55, image: '40016743_15-dove-cream-beauty-bathing-bar.jpg', flag: Flag.bestseller),
  Product(id: 64, name: 'Head & Shoulders Lemon Fresh', brand: 'H&S', category: 'personal', emoji: '🧴', unit: '180 ml', packLabel: 'Anti-Dandruff Shampoo', price: 165, image: '20004730_11-head-shoulders-anti-dandruff-shampoo-lemon-fresh.jpg'),
  Product(id: 65, name: 'Colgate Strong Teeth', brand: 'Colgate', category: 'personal', emoji: '🪥', unit: '150 g', packLabel: 'Anticavity Toothpaste', price: 115, image: '40186855_18-colgate-strong-teeth-anticavity-toothpaste-with-amino-shakti-formula-provides-fresher-breath.jpg', flag: Flag.bestseller),
  Product(id: 66, name: 'Nivea Body Lotion', brand: 'Nivea', category: 'personal', emoji: '🧴', unit: '400 ml', packLabel: 'Almond Oil Lotion', price: 350, image: '40178947_15-nivea-body-lotion-for-very-dry-skin-with-2x-almond-oil-for-men-women.jpg'),
  Product(id: 67, name: 'Pantene Hairfall Control', brand: 'Pantene', category: 'personal', emoji: '🧴', unit: '1 L', packLabel: 'Pro-V Shampoo', price: 749, image: '40117659_3-pantene-pro-v-shampoo-for-hair-fall-control-strengthens-from-root-to-tip.jpg'),
  Product(id: 68, name: 'Dettol Handwash', brand: 'Dettol', category: 'personal', emoji: '🧴', unit: '200 ml', packLabel: 'Liquid Handwash', price: 62, image: '40160740_22-dettol-liquid-handwash-skincare-everyday-protection-ph-balanced-moisturising.jpg'),
  Product(id: 69, name: 'Himalaya Neem Soap', brand: 'Himalaya', category: 'personal', emoji: '🧴', unit: '125 g', packLabel: 'Neem & Turmeric Soap', price: 160, image: '40000424_4-himalaya-neem-turmeric-soap.jpg'),
  Product(id: 70, name: 'Mysore Sandal Gold Soap', brand: 'Mysore Sandal', category: 'personal', emoji: '🧼', unit: '125 g', packLabel: 'Sandalwood Bathing Soap', price: 85, image: '30005530_2-mysore-sandal-bathing-soap-gold.jpg', flag: Flag.bestseller),

  // ── Hygiene & Baby Care ──
  Product(id: 71, name: 'Whisper Bindazzz Nights', brand: 'Whisper', category: 'hygiene', emoji: '📦', unit: '30 pads', packLabel: 'XXXL Sanitary Pads', price: 315, image: '40186837_5-whisper-bindazzz-nights-sanitary-pads-double-huge-wings-wider-back-xxxl.jpg'),
  Product(id: 72, name: 'Pampers Premium Care XL', brand: 'Pampers', category: 'hygiene', emoji: '👶', unit: '76 pcs', packLabel: 'Extra Large Diapers', price: 1199, image: '40131173_17-pampers-premium-care-diapers-extra-large.jpg', flag: Flag.bestseller),
  Product(id: 73, name: "Johnson's Baby Oil", brand: "Johnson's", category: 'hygiene', emoji: '🍼', unit: '500 ml', packLabel: 'Baby Oil with Vitamin E', price: 445, image: '230067_8-johnsons-baby-baby-oil-with-vitamin-e.jpg'),
  Product(id: 74, name: 'Huggies Wonder Pants M', brand: 'Huggies', category: 'hygiene', emoji: '👶', unit: '76 pcs', packLabel: 'Complete Comfort Pants', price: 999, image: '40257804_1-huggies-complete-comfort-wonder-pants-with-aloe-vera-medium-m-size-baby-diaper-pants-76-count.jpg'),

  // ── Laundry & Household ──
  Product(id: 75, name: 'Surf Excel Matic', brand: 'Surf Excel', category: 'household', emoji: '🧺', unit: '2 kg', packLabel: 'Top Load Liquid', price: 445, image: '40334083_7-surf-excel-matic-top-load-liquid-detergent.jpg', flag: Flag.bestseller),
  Product(id: 76, name: 'Vim Dishwash Gel', brand: 'Vim', category: 'household', emoji: '🍋', unit: '750 ml', packLabel: 'Dishwash Liquid Gel', price: 135, image: '900459772_6-vim-dishwash-liquid-gel.jpg'),
  Product(id: 77, name: 'Lizol Floor Cleaner', brand: 'Lizol', category: 'household', emoji: '🧹', unit: '975 ml', packLabel: 'Citrus Disinfectant', price: 185, image: '40129070_10-lizol-disinfectant-surface-floor-cleaner-liquid-citrus-kills-999-germs.jpg'),
  Product(id: 78, name: 'Harpic Original', brand: 'Harpic', category: 'household', emoji: '🚽', unit: '500 ml', packLabel: 'Toilet Cleaner', price: 105, image: '1207190_16-harpic-original-disinfectant-toilet-cleaner-liquid.jpg'),
  Product(id: 79, name: 'Comfort Conditioner', brand: 'Comfort', category: 'household', emoji: '🌸', unit: '860 ml', packLabel: 'Morning Fresh', price: 225, image: '230745_19-comfort-after-wash-morning-fresh-fabric-conditioner.jpg'),
  Product(id: 80, name: 'Ariel Matic Front Load', brand: 'Ariel', category: 'household', emoji: '🧺', unit: '2 kg', packLabel: 'Matic Liquid Detergent', price: 480, image: '40326742_13-ariel-matic-front-load-liquid-detergent.jpg'),

  // ── Home, Pooja & Pet Care ──
  Product(id: 81, name: 'Cycle Three In One', brand: 'Cycle', category: 'pooja', emoji: '🪔', unit: '250 g', packLabel: 'Agarbatti · 3 Fragrances', price: 199, image: '40050945_7-cycle-three-in-one-agarbathis.jpg'),
  Product(id: 82, name: 'Goodknight Power Activ+', brand: 'Goodknight', category: 'pooja', emoji: '🦟', unit: '45 ml', packLabel: 'Mosquito Repellent Refill', price: 78, image: '40162407_3-good-knight-power-activ-mosquito-repellent-refill.jpg'),
  Product(id: 83, name: 'Pedigree Adult', brand: 'Pedigree', category: 'pooja', emoji: '🐕', unit: '3 kg', packLabel: 'Chicken & Vegetables', price: 630, image: '40252412_11-pedigree-adult-dry-dog-food-chicken-vegetables-balanced-nutrition-for-dogs-overall-health.jpg', flag: Flag.bestseller),
  Product(id: 84, name: 'Mangaldeep Camphor', brand: 'Mangaldeep', category: 'pooja', emoji: '🔥', unit: '50 g', packLabel: 'Sankalph Pooja Camphor', price: 55, image: '40341707_3-mangaldeep-sankalph-pooja-camphor-infused-with-bhimseni.jpg'),

  // ── Detergents & Laundry ──
  Product(id: 85, name: 'Vim Dishwash Liquid', brand: 'Vim', category: 'detergents', emoji: '🧼', unit: '3 L', packLabel: 'Removes Odours & Grease', price: 392, mrp: 545, images: ['900459772_6-product.jpg', '900459772-2_6-product.jpg', '900459772-3_6-product.jpg'], variants: [Variant('3 L', 392, mrp: 545), Variant('500 ml', 99, mrp: 140), Variant('250 ml', 59, mrp: 85)]),
  Product(id: 86, name: 'Vim Lemon Dishwash Bar', brand: 'Vim', category: 'detergents', emoji: '🧼', unit: '480 g', packLabel: 'Lemon Fresh', price: 149, mrp: 210, images: ['317229_6-product.jpg', '317229-2_6-product.jpg', '317229-3_6-product.jpg'], variants: [Variant('480 g', 149, mrp: 210), Variant('240 g', 89, mrp: 125)]),
  Product(id: 87, name: 'Surf Excel Matic Top Load', brand: 'Surf Excel', category: 'detergents', emoji: '🧺', unit: '5 kg', packLabel: 'Liquid Detergent', price: 449, mrp: 650, images: ['40334083_6-product.jpg', '40334083-2_6-product.jpg', '40334083-3_6-product.jpg'], variants: [Variant('5 kg', 449, mrp: 650), Variant('2 kg', 199, mrp: 280), Variant('1 L', 149, mrp: 210)]),
  Product(id: 88, name: 'Surf Excel Matic Front Load', brand: 'Surf Excel', category: 'detergents', emoji: '🧺', unit: '4 kg', packLabel: 'Refill Pouch', price: 369, mrp: 520, images: ['40320190_6-product.jpg', '40320190-2_6-product.jpg', '40320190-3_6-product.jpg'], variants: [Variant('4 kg', 369, mrp: 520), Variant('2 kg', 189, mrp: 270), Variant('1 L', 129, mrp: 185)]),
  Product(id: 89, name: 'Comfort Morning Fresh', brand: 'Comfort', category: 'detergents', emoji: '🌸', unit: '860 ml', packLabel: 'Fabric Conditioner', price: 189, mrp: 270, images: ['230745_6-product.jpg', '230745-2_6-product.jpg', '230745-3_6-product.jpg'], variants: [Variant('860 ml', 189, mrp: 270), Variant('430 ml', 119, mrp: 170)]),
  Product(id: 90, name: 'Surf Excel Easy Wash', brand: 'Surf Excel', category: 'detergents', emoji: '🧺', unit: '5 kg', packLabel: 'Detergent Powder', price: 399, mrp: 580, images: ['215595_6-product.jpg', '215595-2_6-product.jpg', '215595-3_6-product.jpg'], variants: [Variant('5 kg', 399, mrp: 580), Variant('2 kg', 169, mrp: 250), Variant('500 g', 79, mrp: 120)]),
  Product(id: 91, name: 'Ariel Power Gel Front Load', brand: 'Ariel', category: 'detergents', emoji: '✨', unit: '6 kg', packLabel: 'Liquid Detergent', price: 549, mrp: 780, images: ['40326742_6-product.jpg', '40326742-2_6-product.jpg', '40326742-3_6-product.jpg'], variants: [Variant('6 kg', 549, mrp: 780), Variant('3 kg', 299, mrp: 425)]),
  Product(id: 92, name: 'bb home Lemon Dishwash', brand: 'bb home', category: 'detergents', emoji: '🧼', unit: '2 L', packLabel: 'Aloe Vera', price: 149, mrp: 210, images: ['40206009_6-product.jpg', '40206009-2_6-product.jpg', '40206009-3_6-product.jpg'], variants: [Variant('2 L', 149, mrp: 210), Variant('500 ml', 59, mrp: 85)]),
  Product(id: 93, name: 'Ariel Power Gel Top Load', brand: 'Ariel', category: 'detergents', emoji: '✨', unit: '6 kg', packLabel: 'Liquid Detergent', price: 549, mrp: 780, images: ['40326741_6-product.jpg', '40326741-2_6-product.jpg', '40326741-3_6-product.jpg'], variants: [Variant('6 kg', 549, mrp: 780), Variant('3 kg', 299, mrp: 425)]),
  Product(id: 94, name: 'Vim Lemon Dishwash Liquid', brand: 'Vim', category: 'detergents', emoji: '🧼', unit: '750 ml', packLabel: 'Lemon Gel', price: 99, mrp: 140, images: ['307195_6-product.jpg', '307195-2_6-product.jpg', '307195-3_6-product.jpg'], variants: [Variant('750 ml', 99, mrp: 140), Variant('200 ml', 39, mrp: 55)]),
];

const List<Category> kCategories = [
  Category('all', 'All', '🛍️', [Color(0xFFC8390A), Color(0xFFE04A18)]),
  Category('grains', 'Grains', '🌾', [Color(0xFF8A5A20), Color(0xFFB07830)], heroId: 1),
  Category('oils', 'Oils', '🫙', [Color(0xFFB89010), Color(0xFFD8B030)], heroId: 12),
  Category('spices', 'Spices', '🌶️', [Color(0xFFB82020), Color(0xFFD84040)], heroId: 17),
  Category('dairy', 'Dairy', '🥛', [Color(0xFF1858A0), Color(0xFF3878C8)], heroId: 25),
  Category('bakery', 'Bakery', '🍞', [Color(0xFF8A4818), Color(0xFFB06830)], heroId: 35),
  Category('snacks', 'Snacks', '🍿', [Color(0xFFC83020), Color(0xFFE04840)], heroId: 40),
  Category('sauces', 'Sauces', '🍅', [Color(0xFFC84020), Color(0xFFE06040)], heroId: 50),
  Category('beverages', 'Drinks', '☕', [Color(0xFF5A2010), Color(0xFF8A3828)], heroId: 55),
  Category('personal', 'Care', '🧴', [Color(0xFF2050A0), Color(0xFF4070C8)], heroId: 63),
  Category('hygiene', 'Baby', '👶', [Color(0xFFA03060), Color(0xFFC85080)], heroId: 72),
  Category('household', 'Clean', '🧹', [Color(0xFF2868A0), Color(0xFF4888C8)], heroId: 75),
  Category('pooja', 'Pooja', '🪔', [Color(0xFFA04818), Color(0xFFC86830)], heroId: 81),
  Category('detergents', 'Laundry', '🧼', [Color(0xFF0A6818), Color(0xFF1EB040)], heroId: 85),
];

const List<Section> kSections = [
  Section('grains', 'Grains, Rice & Staples'),
  Section('oils', 'Edible Oils & Ghee'),
  Section('spices', 'Spices & Masalas'),
  Section('dairy', 'Dairy & Frozen'),
  Section('bakery', 'Bakery'),
  Section('snacks', 'Snacks & Packaged Foods'),
  Section('sauces', 'Sauces, Jams & Spreads'),
  Section('beverages', 'Beverages'),
  Section('personal', 'Personal Care'),
  Section('hygiene', 'Hygiene & Baby Care'),
  Section('household', 'Laundry & Household'),
  Section('pooja', 'Home, Pooja & Pet Care'),
];

const List<String> kBrands = [
  'Aashirvaad', 'Amul', 'Fortune', 'Maggi', 'Cadbury', 'Tata Tea', 'Nescafe',
  'Britannia', "Haldiram's", "Lay's", 'Dove', 'Colgate', 'Surf Excel',
  'Aachi', 'Sakthi', 'MahaRaja Choice',
];

const _w = Color(0xFFFFFFFF);
Color _o(int v) => Color(v);

/// Brand-accurate packaging treatments for the fallback cards.
final Map<String, BrandStyle> kBrandStyles = {
  'Aashirvaad': BrandStyle([_o(0xFF102850), _o(0xFF1A3A70)], _o(0xFFF0D040), _w.withValues(alpha: .85)),
  'India Gate': BrandStyle([_o(0xFF5A0A18), _o(0xFFA01828)], _o(0xFFE8D068), _w.withValues(alpha: .85)),
  'MahaRaja Choice': BrandStyle([_o(0xFF0A1626), _o(0xFF1D3A5F)], _o(0xFFD9B45B), _o(0xFFF7F4EC).withValues(alpha: .80)),
  'MahaRaja Bakery': BrandStyle([_o(0xFF12304F), _o(0xFF2E5C8A)], _o(0xFFD9B45B), _o(0xFFF7F4EC).withValues(alpha: .84)),
  'Fortune': BrandStyle([_o(0xFFC89010), _o(0xFFF0C040)], _o(0xFF7A1010), _o(0xFF641400).withValues(alpha: .75)),
  'Naga': BrandStyle([_o(0xFF5A1818), _o(0xFFB03838)], _o(0xFFFFE848), _w.withValues(alpha: .8)),
  'Daawat': BrandStyle([_o(0xFF0A4020), _o(0xFF1E8040)], _o(0xFFE8D068), _w.withValues(alpha: .8)),
  'MTR': BrandStyle([_o(0xFFA01818), _o(0xFFE04040)], _o(0xFFFFE040), _w.withValues(alpha: .85)),
  'Pillsbury': BrandStyle([_o(0xFF102870), _o(0xFF2858C8)], _w, _w.withValues(alpha: .85)),
  'Gold Winner': BrandStyle([_o(0xFFB87810), _o(0xFFE8A020)], _w, _w.withValues(alpha: .85)),
  'Idhayam': BrandStyle([_o(0xFF6A2810), _o(0xFFA84818)], _o(0xFFE8D068), _w.withValues(alpha: .85)),
  'Amul': BrandStyle([_o(0xFFA01010), _o(0xFFE02828)], _w, _w.withValues(alpha: .85)),
  'GRB': BrandStyle([_o(0xFF8A1818), _o(0xFFC83030)], _o(0xFFE8D048), _w.withValues(alpha: .85)),
  'Sundrop': BrandStyle([_o(0xFFC89808), _o(0xFFF0C830)], _o(0xFFC81818), _o(0xFF96140A).withValues(alpha: .7)),
  'Aachi': BrandStyle([_o(0xFF981010), _o(0xFFE02828)], _o(0xFFFFE040), _w.withValues(alpha: .85)),
  'Sakthi': BrandStyle([_o(0xFF882010), _o(0xFFD04020)], _o(0xFFFFE040), _w.withValues(alpha: .8)),
  'Everest': BrandStyle([_o(0xFFB83020), _o(0xFFE05040)], _w, _w.withValues(alpha: .85)),
  'MDH': BrandStyle([_o(0xFFA82020), _o(0xFFD84040)], _o(0xFFFFE040), _w.withValues(alpha: .85)),
  'Eastern': BrandStyle([_o(0xFFC86818), _o(0xFFF09838)], _w, _w.withValues(alpha: .85)),
  'Tata': BrandStyle([_o(0xFF102870), _o(0xFF2858C8)], _w, _w.withValues(alpha: .8)),
  'Catch': BrandStyle([_o(0xFF981010), _o(0xFFE02828)], _w, _w.withValues(alpha: .85)),
  "Parry's": BrandStyle([_o(0xFFC06818), _o(0xFFF09838)], _w, _w.withValues(alpha: .85)),
  'Aavin': BrandStyle([_o(0xFF0E3870), _o(0xFF2868C0)], _w, _w.withValues(alpha: .85)),
  'Milky Mist': BrandStyle([_o(0xFF1048A0), _o(0xFF3878D8)], _w, _w.withValues(alpha: .85)),
  'Heritage': BrandStyle([_o(0xFF0A4020), _o(0xFF1E8040)], _w, _w.withValues(alpha: .8)),
  'Arun': BrandStyle([_o(0xFFC81838), _o(0xFFF04868)], _o(0xFFFFE040), _w.withValues(alpha: .85)),
  'McCain': BrandStyle([_o(0xFF0A4020), _o(0xFF1E8040)], _w, _w.withValues(alpha: .8)),
  'Hatsun': BrandStyle([_o(0xFF1840A0), _o(0xFF3870D8)], _w, _w.withValues(alpha: .8)),
  "Kwality Wall's": BrandStyle([_o(0xFF481090), _o(0xFF7830D0)], _w, _w.withValues(alpha: .85)),
  'Britannia': BrandStyle([_o(0xFF1848A0), _o(0xFF3870D0)], _w, _w.withValues(alpha: .85)),
  'English Oven': BrandStyle([_o(0xFF4A2810), _o(0xFF8A4828)], _o(0xFFE8D068), _w.withValues(alpha: .8)),
  'Modern': BrandStyle([_o(0xFFC89808), _o(0xFFF0C830)], _o(0xFFC81010), _o(0xFF96140A).withValues(alpha: .7)),
  "Lay's": BrandStyle([_o(0xFFC8A810), _o(0xFFF0D030)], _o(0xFF0A5028), _o(0xFF003C14).withValues(alpha: .7)),
  "Haldiram's": BrandStyle([_o(0xFFA01010), _o(0xFFD82828)], _o(0xFFFFE040), _w.withValues(alpha: .85)),
  'Maggi': BrandStyle([_o(0xFFC89010), _o(0xFFF0C040)], _o(0xFFC81010), _o(0xFF96140A).withValues(alpha: .7)),
  'Parle': BrandStyle([_o(0xFFC89020), _o(0xFFF0B840)], _o(0xFFB02020), _o(0xFF8C140A).withValues(alpha: .7)),
  'Cadbury': BrandStyle([_o(0xFF2A1050), _o(0xFF4828A0)], _o(0xFFE8D040), _w.withValues(alpha: .85)),
  'Bingo!': BrandStyle([_o(0xFFC82010), _o(0xFFF04830)], _o(0xFFFFE040), _w.withValues(alpha: .85)),
  'Sunfeast': BrandStyle([_o(0xFF1A3880), _o(0xFF3060C0)], _w, _w.withValues(alpha: .85)),
  "Kellogg's": BrandStyle([_o(0xFF0A5020), _o(0xFF1E9040)], _w, _w.withValues(alpha: .85)),
  'Oreo': BrandStyle([_o(0xFF0E1830), _o(0xFF1A2848)], _w, _w.withValues(alpha: .85)),
  'Kurkure': BrandStyle([_o(0xFF0A6028), _o(0xFF1EA048)], _o(0xFFFFE040), _w.withValues(alpha: .85)),
  'Kissan': BrandStyle([_o(0xFFC83020), _o(0xFFE85040)], _w, _w.withValues(alpha: .85)),
  'Nutella': BrandStyle([_o(0xFF2A0808), _o(0xFF5A1818)], _o(0xFFE8D040), _w.withValues(alpha: .85)),
  'Dabur': BrandStyle([_o(0xFF0A5020), _o(0xFF1E8040)], _w, _w.withValues(alpha: .85)),
  'Del Monte': BrandStyle([_o(0xFF104828), _o(0xFF208848)], _w, _w.withValues(alpha: .85)),
  'Tata Tea': BrandStyle([_o(0xFF6A1818), _o(0xFFA82828)], _o(0xFFE8D048), _w.withValues(alpha: .85)),
  'Nescafe': BrandStyle([_o(0xFF3A1010), _o(0xFF6A2020)], _o(0xFFD04040), _w.withValues(alpha: .85)),
  'Bru': BrandStyle([_o(0xFF4A2010), _o(0xFF8A3818)], _o(0xFFE8D040), _w.withValues(alpha: .85)),
  'Tropicana': BrandStyle([_o(0xFFE87818), _o(0xFFF8A040)], _w, _w.withValues(alpha: .85)),
  'Coca-Cola': BrandStyle([_o(0xFF8A0808), _o(0xFFC81818)], _w, _w.withValues(alpha: .85)),
  'Horlicks': BrandStyle([_o(0xFFC87818), _o(0xFFF0A030)], _w, _w.withValues(alpha: .85)),
  'Red Bull': BrandStyle([_o(0xFF102858), _o(0xFF1838A0)], _o(0xFFC83030), _w.withValues(alpha: .85)),
  'Bournvita': BrandStyle([_o(0xFF3A1818), _o(0xFF7A2828)], _o(0xFFC86818), _w.withValues(alpha: .85)),
  'Dove': BrandStyle([_o(0xFF1858A0), _o(0xFF3888D0)], _w, _w.withValues(alpha: .85)),
  'H&S': BrandStyle([_o(0xFF0A5860), _o(0xFF18A0B0)], _w, _w.withValues(alpha: .85)),
  'Colgate': BrandStyle([_o(0xFFA01018), _o(0xFFD83038)], _w, _w.withValues(alpha: .85)),
  'Nivea': BrandStyle([_o(0xFF0A2870), _o(0xFF1840B0)], _w, _w.withValues(alpha: .85)),
  'Pantene': BrandStyle([_o(0xFFB89010), _o(0xFFE8C028)], _w, _w.withValues(alpha: .85)),
  'Dettol': BrandStyle([_o(0xFF0A5028), _o(0xFF1E9048)], _w, _w.withValues(alpha: .85)),
  'Himalaya': BrandStyle([_o(0xFF1858A0), _o(0xFF3890D0)], _w, _w.withValues(alpha: .85)),
  'Mysore Sandal': BrandStyle([_o(0xFF9A6818), _o(0xFFD09838)], _o(0xFF4A1808), _o(0xFF3C1400).withValues(alpha: .7)),
  'Whisper': BrandStyle([_o(0xFF1848A0), _o(0xFF3880D8)], _w, _w.withValues(alpha: .85)),
  'Pampers': BrandStyle([_o(0xFF0A6838), _o(0xFF20B858)], _w, _w.withValues(alpha: .85)),
  "Johnson's": BrandStyle([_o(0xFFC848A0), _o(0xFFE878C0)], _w, _w.withValues(alpha: .85)),
  'Huggies': BrandStyle([_o(0xFFA01010), _o(0xFFE02020)], _w, _w.withValues(alpha: .85)),
  'Surf Excel': BrandStyle([_o(0xFF1830A0), _o(0xFF3050D0)], _w, _w.withValues(alpha: .85)),
  'Vim': BrandStyle([_o(0xFF0A6818), _o(0xFF1EB040)], _o(0xFFFFE040), _w.withValues(alpha: .85)),
  'Lizol': BrandStyle([_o(0xFF3818A0), _o(0xFF5830D0)], _w, _w.withValues(alpha: .85)),
  'Harpic': BrandStyle([_o(0xFF0A3870), _o(0xFF1860B8)], _w, _w.withValues(alpha: .85)),
  'Comfort': BrandStyle([_o(0xFF1848A0), _o(0xFF3878D0)], _w, _w.withValues(alpha: .85)),
  'Ariel': BrandStyle([_o(0xFF0A4838), _o(0xFF189070)], _w, _w.withValues(alpha: .85)),
  'Cycle': BrandStyle([_o(0xFF5A2810), _o(0xFF9A4820)], _o(0xFFE8D068), _w.withValues(alpha: .8)),
  'Goodknight': BrandStyle([_o(0xFF0A5028), _o(0xFF1E9048)], _w, _w.withValues(alpha: .85)),
  'Pedigree': BrandStyle([_o(0xFFC89010), _o(0xFFF0C040)], _o(0xFF2A1808), _o(0xFF281400).withValues(alpha: .7)),
  'Mangaldeep': BrandStyle([_o(0xFF882818), _o(0xFFC84838)], _o(0xFFE8D048), _w.withValues(alpha: .8)),
  'Vim': BrandStyle([_o(0xFF0A6818), _o(0xFF1EB040)], _o(0xFFFFE040), _w.withValues(alpha: .85)),
  'Surf Excel': BrandStyle([_o(0xFF1830A0), _o(0xFF3050D0)], _w, _w.withValues(alpha: .85)),
  'Comfort': BrandStyle([_o(0xFF1848A0), _o(0xFF3878D0)], _w, _w.withValues(alpha: .85)),
  'Ariel': BrandStyle([_o(0xFF0A4838), _o(0xFF189070)], _w, _w.withValues(alpha: .85)),
  'bb home': BrandStyle([_o(0xFF6BA030), _o(0xFF9BC858)], _w, _w.withValues(alpha: .85)),
};

BrandStyle styleFor(String brand) =>
    kBrandStyles[brand] ??
    BrandStyle([_o(0xFF555555), _o(0xFF777777)], _w, _w.withValues(alpha: .8));

Product productById(int id) => kProducts.firstWhere((p) => p.id == id);

List<Product> productsIn(String category) =>
    category == 'all' ? kProducts : kProducts.where((p) => p.category == category).toList();
