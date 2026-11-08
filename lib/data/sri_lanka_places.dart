import 'package:latlong2/latlong.dart';

class SriLankaPlace {
  final String id;
  final String name;
  final String emoji;
  final String category;
  final LatLng location;
  final String shortDescription;
  final String history;
  final List<String> highlights;
  final String imageUrl;
  final String bestTimeToVisit;
  final String entryFee;
  final double rating;
  final int reviewCount;

  const SriLankaPlace({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.location,
    required this.shortDescription,
    required this.history,
    required this.highlights,
    required this.imageUrl,
    required this.bestTimeToVisit,
    required this.entryFee,
    required this.rating,
    required this.reviewCount,
  });
}

final List<SriLankaPlace> sriLankaPlaces = [
  // UNESCO World Heritage Sites
  SriLankaPlace(
    id: 'sigiriya',
    name: 'Sigiriya Rock Fortress',
    emoji: '🏛️',
    category: 'UNESCO Heritage',
    location: const LatLng(7.9570, 80.7603),
    shortDescription: 'Ancient rock fortress and palace ruins',
    history:
        '''Sigiriya, also known as Lion Rock, is a 5th-century rock fortress located in the northern Matale District. It was built by King Kashyapa I (477-495 CE) who chose this site as his new capital after seizing the throne from his father, King Dhatusena.

The king transformed the massive 200-meter-high rock into a fortified palace complex, complete with gardens, pools, and stunning frescoes. The most remarkable feature is the Lion Gate, where visitors once entered through the jaws of an enormous lion sculpture, of which only the paws remain today.

After Kashyapa's death, the site became a Buddhist monastery until the 14th century. The famous Sigiriya frescoes, depicting celestial maidens, are among the finest examples of ancient Sri Lankan art. In 1982, UNESCO designated Sigiriya as a World Heritage Site.''',
    highlights: [
      'Mirror Wall with ancient graffiti',
      'Sigiriya Frescoes (Cloud Maidens)',
      'Lion Paw Entrance',
      'Royal Gardens and Water Gardens',
      'Summit Palace Ruins',
      'Boulder Gardens',
    ],
    imageUrl: 'assets/images/sigiriya.jpg',
    bestTimeToVisit: 'January to April',
    entryFee: '\$30 USD (Foreigners)',
    rating: 4.8,
    reviewCount: 15420,
  ),

  SriLankaPlace(
    id: 'kandy',
    name: 'Temple of the Sacred Tooth',
    emoji: '🛕',
    category: 'UNESCO Heritage',
    location: const LatLng(7.2936, 80.6413),
    shortDescription: 'Buddhist temple housing Buddha\'s tooth relic',
    history:
        '''The Sri Dalada Maligawa, or Temple of the Sacred Tooth Relic, is a Buddhist temple in Kandy that houses the relic of the tooth of the Buddha. The temple is located in the royal palace complex of the former Kingdom of Kandy.

The tooth relic was brought to Sri Lanka from India in 4th century CE, hidden in the hair of Princess Hemamali. Since ancient times, the relic has played an important role in local politics because it is believed that whoever holds the relic holds the governance of the country.

The present temple structure was built during the reign of the Kandyan kings between 1687-1707 and 1747-1782. The temple has survived Portuguese attacks, British colonial looting attempts, and a 1998 terrorist bombing. It remains the most sacred place of worship for Buddhists in Sri Lanka.''',
    highlights: [
      'Sacred Tooth Relic Chamber',
      'Alut Maligawa (New Palace)',
      'Daily Puja Ceremonies',
      'Royal Palace Museum',
      'Kandy Lake Views',
      'Esala Perahera Festival',
    ],
    imageUrl: 'assets/central province/temple of tooth.jpg',
    bestTimeToVisit: 'July-August (Esala Perahera)',
    entryFee: '\$15 USD',
    rating: 4.7,
    reviewCount: 12350,
  ),

  SriLankaPlace(
    id: 'galle',
    name: 'Galle Fort',
    emoji: '🏰',
    category: 'UNESCO Heritage',
    location: const LatLng(6.0269, 80.2170),
    shortDescription: 'Historic fort built by Portuguese colonists',
    history:
        '''Galle Fort, in the Bay of Galle on the southwest coast of Sri Lanka, was first fortified by the Portuguese in 1588. However, the present structure was built by the Dutch beginning in 1649.

The fort is the best example of a fortified city built by Europeans in South and Southeast Asia, showing the interaction between Portuguese, Dutch, and British colonial architectural styles with South Asian traditions. The Dutch added extensive fortifications, creating a town within the walls.

Today, Galle Fort is a living heritage site with residents, boutique hotels, restaurants, shops, and museums operating within its walls. The fort survived the 2004 tsunami with minimal damage, testament to the strength of its construction. It was designated a UNESCO World Heritage Site in 1988.''',
    highlights: [
      'Dutch Reformed Church (1755)',
      'Lighthouse on the ramparts',
      'Maritime Archaeology Museum',
      'Old Dutch Hospital',
      'Flag Rock sunset views',
      'Boutique shopping streets',
    ],
    imageUrl: 'assets/images/galle_fort.jpg',
    bestTimeToVisit: 'December to March',
    entryFee: 'Free',
    rating: 4.6,
    reviewCount: 9870,
  ),

  SriLankaPlace(
    id: 'anuradhapura',
    name: 'Anuradhapura Sacred City',
    emoji: '🏯',
    category: 'UNESCO Heritage',
    location: const LatLng(8.3500, 80.3833),
    shortDescription: 'Ancient capital with Buddhist monasteries',
    history:
        '''Anuradhapura was the first capital of Sri Lanka, founded in the 4th century BCE. For over 1,300 years, it served as the political and religious capital, becoming one of the most durable centers of political power in the ancient world.

The city is home to the Sri Maha Bodhi, the oldest historically documented tree in the world, grown from a cutting of the original Bodhi tree under which the Buddha attained enlightenment. Emperor Ashoka's daughter, Princess Sanghamitta, brought it to Sri Lanka in 288 BCE.

Among its ruins are giant stupas (dagobas), some reaching heights of over 100 meters, monastic complexes, and the Abhayagiri and Jetavanarama monasteries, which were among the largest structures in the ancient world after the Egyptian pyramids.''',
    highlights: [
      'Sri Maha Bodhi (Sacred Bo Tree)',
      'Ruwanwelisaya Stupa',
      'Jetavanaramaya - 3rd tallest stupa ever built',
      'Abhayagiri Monastery',
      'Twin Ponds (Kuttam Pokuna)',
      'Isurumuniya Rock Temple',
    ],
    imageUrl:
        'https://images.pexels.com/photos/2161467/pexels-photo-2161467.jpeg?auto=compress&cs=tinysrgb&w=800',
    bestTimeToVisit: 'June to September',
    entryFee: '\$25 USD',
    rating: 4.7,
    reviewCount: 8920,
  ),

  SriLankaPlace(
    id: 'polonnaruwa',
    name: 'Polonnaruwa Ancient City',
    emoji: '🗿',
    category: 'UNESCO Heritage',
    location: const LatLng(7.9403, 81.0188),
    shortDescription: 'Medieval capital with stunning ruins',
    history:
        '''Polonnaruwa was the second capital of Sri Lanka after the destruction of Anuradhapura in 993 CE. It contains the Brahmanic monuments commissioned by the Chola dynasty and the impressive remains of the 11th-12th century Sinhalese kingdom.

King Vijayabahu I (1055-1110) first made Polonnaruwa his capital after expelling the Chola invaders. His successor, King Parakramabahu I (1153-1186), transformed the city into a marvel of urban planning with palaces, temples, and the massive Parakrama Samudra reservoir.

The Gal Vihara, featuring four magnificent Buddha statues carved from a single granite rock, represents the pinnacle of Sinhalese rock sculpture. The city was abandoned in the 13th century and reclaimed by the jungle until its rediscovery in the 19th century.''',
    highlights: [
      'Gal Vihara rock sculptures',
      'Royal Palace of King Parakramabahu',
      'Vatadage circular relic house',
      'Parakrama Samudra reservoir',
      'Lankatilaka temple',
      'Quadrangle sacred precinct',
    ],
    imageUrl: 'assets/north central province/encient city of plonnaruwa.jpg',
    bestTimeToVisit: 'January to September',
    entryFee: '\$25 USD',
    rating: 4.6,
    reviewCount: 7650,
  ),

  SriLankaPlace(
    id: 'dambulla',
    name: 'Dambulla Cave Temple',
    emoji: '🕌',
    category: 'UNESCO Heritage',
    location: const LatLng(7.8675, 80.6492),
    shortDescription: 'Ancient cave temple with Buddha statues',
    history:
        '''The Dambulla Cave Temple, also known as the Golden Temple of Dambulla, is a World Heritage Site dating back to the 1st century BCE. King Valagamba took refuge here during his 14-year exile and after reclaiming his throne, converted the caves into a magnificent temple complex.

The complex consists of five caves containing 153 Buddha statues and is the largest and best-preserved cave temple complex in Sri Lanka. The ceilings are covered with elaborate paintings depicting the life of Buddha and important events in Sri Lankan history.

Over the centuries, successive kings added to the temple, with King Nissanka Malla gilding the complex and earning it the name "Golden Rock Temple." The paintings and statues span over 2,000 years of Buddhist art, making it an invaluable artistic and religious treasure.''',
    highlights: [
      'Cave of the Divine King',
      '153 Buddha statues',
      'Ancient ceiling murals',
      'Cave of the Great Kings',
      'Golden Buddha Museum',
      'Panoramic views from hilltop',
    ],
    imageUrl:
        'https://images.pexels.com/photos/2474689/pexels-photo-2474689.jpeg?auto=compress&cs=tinysrgb&w=800',
    bestTimeToVisit: 'January to April',
    entryFee: '\$15 USD',
    rating: 4.5,
    reviewCount: 6890,
  ),

  // Nature & Wildlife
  SriLankaPlace(
    id: 'yala',
    name: 'Yala National Park',
    emoji: '🐆',
    category: 'Wildlife',
    location: const LatLng(6.3728, 81.5209),
    shortDescription: 'Famous for highest leopard density',
    history:
        '''Yala National Park is Sri Lanka's most visited and second-largest national park. Designated in 1938, it has a history dating back to ancient times when it was part of the Ruhuna Kingdom.

The park has the highest leopard density in the world, making it one of the best places on Earth to observe these elusive cats in the wild. Besides leopards, Yala is home to elephants, sloth bears, crocodiles, and over 200 bird species.

The park also contains significant cultural sites, including the ancient pilgrimage site of Sithulpahuwa, a 2nd-century BCE Buddhist monastery, and Magul Maha Viharaya, where King Kavantissa married Viharamahadevi.''',
    highlights: [
      'Leopard safari',
      'Asian elephants',
      'Sloth bears',
      'Bird watching (215 species)',
      'Ancient Buddhist ruins',
      'Scenic lagoons and beaches',
    ],
    imageUrl: 'assets/images/yala_leopard.jpg',
    bestTimeToVisit: 'February to July',
    entryFee: '\$35 USD + jeep hire',
    rating: 4.7,
    reviewCount: 11200,
  ),

  SriLankaPlace(
    id: 'ella',
    name: 'Ella',
    emoji: '🌄',
    category: 'Hill Country',
    location: const LatLng(6.8667, 81.0466),
    shortDescription: 'Scenic hill town with stunning views',
    history:
        '''Ella is a small town nestled in the Sri Lankan highlands at 1,041 meters above sea level. Once a quiet village, it has transformed into a backpacker haven due to its stunning natural beauty and cool climate.

The area has been inhabited for centuries, with local legend telling of the giant Ravana from the Indian epic Ramayana, who is said to have hidden Princess Sita in the caves around Ella. The Ravana Falls nearby are named after this legend.

The famous Nine Arch Bridge, built during the British colonial era without steel, is an engineering marvel. The train journey from Kandy to Ella is considered one of the most scenic railway routes in the world.''',
    highlights: [
      'Nine Arch Bridge',
      'Little Adam\'s Peak',
      'Ella Rock hike',
      'Ravana Falls',
      'Scenic train journey',
      'Tea plantations',
    ],
    imageUrl: 'assets/images/nine_arch_bridge.jpg',
    bestTimeToVisit: 'January to March',
    entryFee: 'Free (town)',
    rating: 4.8,
    reviewCount: 14560,
  ),

  SriLankaPlace(
    id: 'mirissa',
    name: 'Mirissa Beach',
    emoji: '🏖️',
    category: 'Beaches',
    location: const LatLng(5.9485, 80.4528),
    shortDescription: 'Popular beach for whale watching',
    history:
        '''Mirissa is a small town on the south coast of Sri Lanka, located in the Matara District. It was once a humble fishing village, with local fishermen using the now-famous stilt fishing technique.

The area gained international recognition as one of the best whale watching destinations in the world. Between November and April, blue whales, the largest animals on Earth, pass through these waters during their annual migration.

Mirissa has also become famous for its palm-fringed crescent-shaped beach, perfect for swimming and surfing. The iconic Coconut Tree Hill has become one of Sri Lanka's most photographed spots.''',
    highlights: [
      'Blue whale watching',
      'Coconut Tree Hill',
      'Parrot Rock',
      'Sunset views',
      'Stilt fishermen',
      'Surfing and swimming',
    ],
    imageUrl: 'assets/southern province/mirissa beach.jpg',
    bestTimeToVisit: 'November to April',
    entryFee: 'Free (whale watching \$40-60)',
    rating: 4.5,
    reviewCount: 8970,
  ),

  SriLankaPlace(
    id: 'nuwara_eliya',
    name: 'Nuwara Eliya',
    emoji: '🍃',
    category: 'Hill Country',
    location: const LatLng(6.9497, 80.7891),
    shortDescription: 'Little England in the hills',
    history:
        '''Nuwara Eliya, meaning "City of Light," was founded by the British in the 19th century as a retreat from the tropical heat. The cool climate reminded them of home, leading to the nickname "Little England."

British planters established the first tea estates here in 1867, transforming the landscape and Sri Lanka's economy. The rolling hills covered with emerald tea bushes became iconic. Today, Ceylon tea from this region is world-renowned.

The town retains much of its colonial character with Tudor-style hotels, English gardens, a racecourse, and a golf course. Gregory Lake, created as a reservoir in 1873, is named after British Governor Sir William Gregory.''',
    highlights: [
      'Tea plantation tours',
      'Horton Plains National Park',
      'Gregory Lake',
      'Victoria Park',
      'Hakgala Botanical Garden',
      'Colonial architecture',
    ],
    imageUrl: 'assets/central province/nuwara eliya tea country.jpg',
    bestTimeToVisit: 'February to April',
    entryFee: 'Free (town)',
    rating: 4.4,
    reviewCount: 7890,
  ),

  SriLankaPlace(
    id: 'adams_peak',
    name: 'Adam\'s Peak (Sri Pada)',
    emoji: '⛰️',
    category: 'Pilgrimage',
    location: const LatLng(6.8094, 80.4994),
    shortDescription: 'Sacred mountain with footprint relic',
    history:
        '''Adam's Peak, known locally as Sri Pada ("Sacred Footprint"), is a 2,243-meter conical mountain revered by multiple faiths. At the summit is a rock formation believed to be a footprint.

Buddhists believe it is the footprint of Buddha, Hindus attribute it to Lord Shiva, Christians and Muslims believe it was made by Adam when he first set foot on Earth after being cast out of Eden.

The pilgrimage season runs from December to May, when thousands climb the 5,500+ steps through the night to witness the spectacular sunrise and the perfect triangular shadow cast by the peak. This sacred tradition has continued for over 1,000 years.''',
    highlights: [
      'Sacred footprint at summit',
      'Sunrise pilgrimage',
      'Shadow of the peak',
      'Ancient pilgrim trails',
      'Endemic biodiversity',
      'Multi-faith significance',
    ],
    imageUrl:
        'https://images.pexels.com/photos/2387873/pexels-photo-2387873.jpeg?auto=compress&cs=tinysrgb&w=800',
    bestTimeToVisit: 'December to May',
    entryFee: 'Free',
    rating: 4.8,
    reviewCount: 6540,
  ),

  SriLankaPlace(
    id: 'trincomalee',
    name: 'Trincomalee',
    emoji: '🌊',
    category: 'Beaches',
    location: const LatLng(8.5874, 81.2152),
    shortDescription: 'Natural harbor with pristine beaches',
    history:
        '''Trincomalee has one of the finest natural harbors in the world, which has attracted traders and colonizers for millennia. The Koneswaram Temple atop Swami Rock dates back over 2,000 years and was once one of the most important Hindu temples.

The Portuguese destroyed the original temple in 1622, throwing the sacred idol into the sea. British divers rediscovered some artifacts in 1956, and the temple has been rebuilt.

The beach at Nilaveli, just north of Trincomalee, is considered one of the most beautiful in Sri Lanka. Pigeon Island nearby offers excellent snorkeling with coral reefs and diverse marine life.''',
    highlights: [
      'Koneswaram Temple',
      'Fort Frederick',
      'Nilaveli Beach',
      'Pigeon Island snorkeling',
      'Whale watching (March-August)',
      'Hot springs at Kanniya',
    ],
    imageUrl:
        'https://images.pexels.com/photos/1450372/pexels-photo-1450372.jpeg?auto=compress&cs=tinysrgb&w=800',
    bestTimeToVisit: 'May to September',
    entryFee: 'Free (Pigeon Island \$10)',
    rating: 4.5,
    reviewCount: 5670,
  ),

  SriLankaPlace(
    id: 'horton_plains',
    name: 'Horton Plains & World\'s End',
    emoji: '🌫️',
    category: 'Nature',
    location: const LatLng(6.8019, 80.7994),
    shortDescription: 'Scenic plateau with dramatic cliff',
    history:
        '''Horton Plains is a protected area in the central highlands, named after the British Governor Sir Robert Wilmot-Horton. This unique ecosystem sits at an elevation of 2,100-2,300 meters.

The area is home to many endemic species found nowhere else on Earth. The cloud forest and grasslands support sambar deer, purple-faced langurs, and the elusive leopard.

World's End is a stunning escarpment that drops 880 meters (2,880 ft) straight down. On clear mornings, you can see the southern coastline 80 km away. Baker's Falls, a 20-meter waterfall, is another highlight of this UNESCO World Heritage Site.''',
    highlights: [
      'World\'s End viewpoint',
      'Baker\'s Falls',
      'Mini World\'s End',
      'Cloud forest trails',
      'Endemic wildlife',
      'Misty grasslands',
    ],
    imageUrl:
        'https://images.pexels.com/photos/2559484/pexels-photo-2559484.jpeg?auto=compress&cs=tinysrgb&w=800',
    bestTimeToVisit: 'January to March (early morning)',
    entryFee: '\$25 USD',
    rating: 4.7,
    reviewCount: 5980,
  ),

  SriLankaPlace(
    id: 'arugam_bay',
    name: 'Arugam Bay',
    emoji: '🏄',
    category: 'Beaches',
    location: const LatLng(6.8403, 81.8336),
    shortDescription: 'World-class surfing destination',
    history:
        '''Arugam Bay is a bay situated on the Indian Ocean in the dry zone of Sri Lanka's southeast coast. It was transformed from a fishing village into a surfing mecca starting in the 1970s.

The bay is consistently ranked among the top 10 surfing destinations in the world, with the main point break offering rides of up to 400 meters during the season. The area also has significant archaeological sites, including ancient Magul Maha Viharaya.

Despite its remoteness, Arugam Bay attracts surfers, backpackers, and wildlife enthusiasts. Nearby Kumana National Park is excellent for bird watching, and elephants can be spotted in the surrounding wilderness.''',
    highlights: [
      'World-class surfing',
      'Main Point break',
      'Elephant sightings',
      'Kumana National Park',
      'Whiskey Point',
      'Laid-back beach vibe',
    ],
    imageUrl: 'assets/eastern province/arugam bay.jpg',
    bestTimeToVisit: 'April to October',
    entryFee: 'Free',
    rating: 4.6,
    reviewCount: 6230,
  ),

  SriLankaPlace(
    id: 'sinharaja',
    name: 'Sinharaja Forest Reserve',
    emoji: '🌳',
    category: 'UNESCO Heritage',
    location: const LatLng(6.4167, 80.4667),
    shortDescription: 'Pristine tropical rainforest',
    history:
        '''Sinharaja Forest Reserve is Sri Lanka's last viable area of primary tropical rainforest. The name means "Kingdom of the Lion," reflecting ancient legends about lions that once roamed here.

This UNESCO World Heritage Site contains an extraordinary level of endemic species - over 60% of trees and nearly 50% of mammals and butterflies are found nowhere else on Earth. It's a living laboratory of evolution.

The forest has been protected since the colonial era, though it faced threats from logging until 1977. Today, it encompasses 18,900 hectares of virgin forest, serving as a vital watershed for several major rivers.''',
    highlights: [
      'Endemic bird watching',
      'Giant trees and vines',
      'Purple-faced langur',
      'Mixed species bird flocks',
      'Waterfalls and streams',
      'Medicinal plants',
    ],
    imageUrl: 'assets/sabaragamuwa province/sinharaja.jpg',
    bestTimeToVisit: 'August to September, January to April',
    entryFee: '\$20 USD + guide',
    rating: 4.6,
    reviewCount: 3450,
  ),

  SriLankaPlace(
    id: 'udawalawe',
    name: 'Udawalawe National Park',
    emoji: '🐘',
    category: 'Wildlife',
    location: const LatLng(6.4384, 80.8830),
    shortDescription: 'Best place to see wild elephants',
    history:
        '''Udawalawe National Park was created in 1972 to protect the catchment area of the Udawalawe Reservoir, which was built on the Walawe River. The park covers 30,821 hectares of land.

Unlike other parks where elephants can be elusive, Udawalawe offers almost guaranteed sightings of Sri Lankan elephants year-round. The park is home to over 600 wild elephants, including many family groups.

The Elephant Transit Home on the park boundary rehabilitates orphaned baby elephants, raising them with minimal human contact before releasing them into the wild. This provides an ethical alternative to elephant orphanages.''',
    highlights: [
      'Wild elephant herds',
      'Elephant Transit Home',
      'Water buffalo',
      'Crocodiles',
      'Bird watching (190 species)',
      'All-year wildlife viewing',
    ],
    imageUrl:
        'https://images.pexels.com/photos/66898/elephant-cub-tsavo-kenya-66898.jpeg?auto=compress&cs=tinysrgb&w=800',
    bestTimeToVisit: 'May to September',
    entryFee: '\$20 USD + jeep hire',
    rating: 4.5,
    reviewCount: 7890,
  ),

  SriLankaPlace(
    id: 'jaffna',
    name: 'Jaffna',
    emoji: '🕍',
    category: 'Cultural',
    location: const LatLng(9.6615, 79.9997),
    shortDescription: 'Tamil cultural capital of the north',
    history:
        '''Jaffna is the cultural capital of the Sri Lankan Tamils, with a history stretching back over 2,000 years. The Jaffna Kingdom flourished here from the 13th to 17th centuries.

The Portuguese built Jaffna Fort in 1619, which was later modified by the Dutch. It remains one of the best-preserved Dutch forts in Asia. The city suffered greatly during the civil war but has been rebuilding since 2009.

The region is famous for its unique cuisine, ancient Hindu temples (especially the Nallur Kandaswamy Temple), and distinctive architecture. The library, rebuilt after its destruction in 1981, symbolizes cultural resilience.''',
    highlights: [
      'Jaffna Fort',
      'Nallur Kandaswamy Kovil',
      'Nagadeepa Purana Viharaya',
      'Jaffna Public Library',
      'Casuarina Beach',
      'Unique Tamil cuisine',
    ],
    imageUrl: 'assets/nothern province/jaffna fort.avif',
    bestTimeToVisit: 'January to September',
    entryFee: 'Free',
    rating: 4.4,
    reviewCount: 4560,
  ),

  SriLankaPlace(
    id: 'unawatuna',
    name: 'Unawatuna Beach',
    emoji: '🐠',
    category: 'Beaches',
    location: const LatLng(6.0096, 80.2489),
    shortDescription: 'Crescent bay with coral reefs',
    history:
        '''Unawatuna is a coastal town and popular tourist destination. According to legend, the name comes from the epic Ramayana - a portion of the Himalayan mountain (Una-watuna means "which fell") dropped here when Hanuman was carrying it to Lanka.

The bay is protected by a natural reef, creating calm, clear waters perfect for swimming and snorkeling. The Japanese Peace Pagoda on Rumassala Hill offers panoramic views.

Despite damage from the 2004 tsunami, Unawatuna has rebuilt into a vibrant beach destination. The underwater life includes coral reefs, sea turtles, and colorful tropical fish. Nearby Jungle Beach offers a more secluded experience.''',
    highlights: [
      'Protected bay swimming',
      'Snorkeling with sea turtles',
      'Japanese Peace Pagoda',
      'Jungle Beach',
      'Rumassala Hill (Ramayana site)',
      'Beach bars and restaurants',
    ],
    imageUrl:
        'https://images.pexels.com/photos/1450340/pexels-photo-1450340.jpeg?auto=compress&cs=tinysrgb&w=800',
    bestTimeToVisit: 'November to April',
    entryFee: 'Free',
    rating: 4.4,
    reviewCount: 8760,
  ),

  SriLankaPlace(
    id: 'bentota',
    name: 'Bentota',
    emoji: '🌴',
    category: 'Beaches',
    location: const LatLng(6.4214, 79.9975),
    shortDescription: 'Water sports paradise',
    history:
        '''Bentota is a coastal town in the Galle District, known for its pristine beaches and water sports. The name derives from a mythical demon called Bem who once ruled the area.

The Bentota River provides calm waters perfect for jet skiing, water skiing, and river safaris to spot crocodiles and monitor lizards. The river estuary is lined with mangroves and home to diverse birdlife.

Geoffrey Bawa, Sri Lanka's most famous architect, created his masterpiece estate, Lunuganga, near Bentota. His designs influenced tropical modernist architecture worldwide. Bentota also has one of Sri Lanka's oldest and most sacred temples, the Galapatha Raja Maha Viharaya.''',
    highlights: [
      'Water sports center',
      'Bentota River safari',
      'Brief Garden (Bevis Bawa)',
      'Lunuganga estate',
      'Turtle hatchery',
      'Galapatha Temple',
    ],
    imageUrl:
        'https://images.pexels.com/photos/1174732/pexels-photo-1174732.jpeg?auto=compress&cs=tinysrgb&w=800',
    bestTimeToVisit: 'November to April',
    entryFee: 'Free (activities vary)',
    rating: 4.3,
    reviewCount: 6540,
  ),

  SriLankaPlace(
    id: 'mihintale',
    name: 'Mihintale',
    emoji: '☸️',
    category: 'Pilgrimage',
    location: const LatLng(8.3500, 80.5000),
    shortDescription: 'Cradle of Buddhism in Sri Lanka',
    history:
        '''Mihintale is venerated as the site where Buddhism was introduced to Sri Lanka. In 247 BCE, King Devanampiyatissa met the Indian monk Mahinda, son of Emperor Ashoka, on this mountain.

After their famous conversation testing the king's wisdom, Devanampiyatissa embraced Buddhism, forever changing Sri Lanka's religious and cultural landscape. The annual Poson festival in June celebrates this event with thousands of pilgrims.

The site contains numerous ruins including the Ambasthala Dagaba marking the meeting spot, the Mahaseya Dagaba on the summit, ancient hospitals with stone medicine troughs, and the Aradhana Gala (Meditation Rock) where Mahinda is said to have meditated.''',
    highlights: [
      'Ambasthala Dagaba',
      'Mahaseya summit stupa',
      'Ancient hospital ruins',
      'Meditation Rock',
      '1,840 steps pilgrimage',
      'Poson Full Moon celebrations',
    ],
    imageUrl:
        'https://images.pexels.com/photos/2161454/pexels-photo-2161454.jpeg?auto=compress&cs=tinysrgb&w=800',
    bestTimeToVisit: 'June (Poson) or year-round',
    entryFee: '\$5 USD',
    rating: 4.5,
    reviewCount: 3890,
  ),

  SriLankaPlace(
    id: 'pinnawala',
    name: 'Pinnawala Elephant Orphanage',
    emoji: '🐘',
    category: 'Wildlife',
    location: const LatLng(7.3005, 80.3882),
    shortDescription: 'Rescued elephant sanctuary',
    history:
        '''The Pinnawala Elephant Orphanage was established in 1975 to care for orphaned elephant calves found in the wild. Located near Kegalle, it began with seven orphans.

Today, the orphanage cares for the largest herd of captive elephants in the world. Twice daily, the elephants walk through town to the Ma Oya River for bathing - a popular spectacle for visitors.

While the orphanage has faced criticism for its practices, it has successfully bred elephants in captivity and raised awareness about elephant conservation. Many Sri Lankans love visiting to see the baby elephants being bottle-fed.''',
    highlights: [
      'Elephant bathing time',
      'Baby elephant feeding',
      'Walk through town',
      'Elephant dung paper factory',
      'Close encounters',
      'Photography opportunities',
    ],
    imageUrl:
        'https://images.pexels.com/photos/1054655/pexels-photo-1054655.jpeg?auto=compress&cs=tinysrgb&w=800',
    bestTimeToVisit: 'Year-round',
    entryFee: '\$25 USD',
    rating: 3.9,
    reviewCount: 9870,
  ),

  SriLankaPlace(
    id: 'negombo',
    name: 'Negombo',
    emoji: '⛵',
    category: 'Beaches',
    location: const LatLng(7.2094, 79.8358),
    shortDescription: 'Gateway beach town near Colombo',
    history:
        '''Negombo is a city on Sri Lanka's west coast, just 7 km north of the international airport. It has been a trading port since at least the 8th century, known for cinnamon and later fishing.

The Portuguese arrived in 1505, followed by the Dutch who built a massive fort here. Today, only parts of the main gate survive. The town earned the nickname "Little Rome" due to its numerous Catholic churches, a legacy of Portuguese missionaries.

The Dutch Canal, connecting Negombo to Colombo, dates from the colonial era and is still used. The lagoon is famous for its crab catches, and the beach, while not the prettiest, offers convenient resort stays before or after flights.''',
    highlights: [
      'Fish market at dawn',
      'Dutch Canal boat trips',
      'Historic St. Mary\'s Church',
      'Negombo Lagoon',
      'Brown\'s Beach',
      'Convenient airport access',
    ],
    imageUrl: 'assets/western province/mount lavinia beach.jpg',
    bestTimeToVisit: 'November to April',
    entryFee: 'Free',
    rating: 4.0,
    reviewCount: 5670,
  ),

  SriLankaPlace(
    id: 'minneriya',
    name: 'Minneriya National Park',
    emoji: '🦏',
    category: 'Wildlife',
    location: const LatLng(8.0330, 80.8830),
    shortDescription: 'The Gathering - largest elephant meetup',
    history:
        '''Minneriya National Park was declared in 1997 and is centered around the ancient Minneriya Tank, a reservoir built by King Mahasen in the 3rd century CE.

The park is famous for "The Gathering," considered the largest congregation of Asian elephants in the world. Between July and October, as surrounding areas dry up, up to 300 elephants gather near the tank - a spectacular wildlife phenomenon.

Beyond elephants, the park hosts sambar deer, spotted deer, monkeys, and rich birdlife including rare species like the grey slender loris. The reservoir continues to serve its original purpose of irrigation.''',
    highlights: [
      'The Gathering (July-Oct)',
      'Up to 300 elephants',
      'Ancient tank/reservoir',
      'Bird watching',
      'Scenic landscapes',
      'Quiet alternative to Yala',
    ],
    imageUrl: 'assets/north central province/minneriya national park.jpg',
    bestTimeToVisit: 'July to October',
    entryFee: '\$25 USD + jeep hire',
    rating: 4.6,
    reviewCount: 7230,
  ),

  SriLankaPlace(
    id: 'colombo',
    name: 'Colombo',
    emoji: '🏙️',
    category: 'City',
    location: const LatLng(6.9271, 79.8612),
    shortDescription: 'Vibrant capital city with colonial charm',
    history:
        '''Colombo has been Sri Lanka's commercial capital for over 2,000 years, thanks to its natural harbor. Arab traders established settlements here by the 8th century, followed by the Portuguese (1505), Dutch (1656), and British (1796).

The city blends colonial architecture with modern skyscrapers, ancient temples with contemporary galleries. The Galle Face Green has been a promenade since 1859, while the Pettah bazaar buzzes with trade as it has for centuries.

Since the end of the civil war in 2009, Colombo has transformed with new infrastructure, restaurants, and cultural spaces. The Dutch Hospital, Arcade Independence Square, and numerous rooftop bars showcase this renaissance.''',
    highlights: [
      'Galle Face Green',
      'Gangaramaya Temple',
      'Independence Square',
      'Dutch Hospital shopping',
      'Pettah Market',
      'Mount Lavinia Beach',
    ],
    imageUrl: 'assets/western province/galle-face.jpg',
    bestTimeToVisit: 'November to February',
    entryFee: 'Free',
    rating: 4.2,
    reviewCount: 14560,
  ),
];

// Helper to get place by ID
SriLankaPlace? getPlaceById(String id) {
  try {
    return sriLankaPlaces.firstWhere((p) => p.id == id);
  } catch (e) {
    return null;
  }
}
