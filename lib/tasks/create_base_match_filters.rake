task create_base_match_filters: :environment do
  # ## antenne relation client OCAPIAT : - de 11 salariés
  # Antenne.where(id: []).each do |antenne|
  #   antenne.match_filters << MatchFilter.create(effectif_max: 11)
  # end
  # ## antennes régionales OCAPIAT : 11 salariés et +
  # Antenne.where(id: []).each do |antenne|
  #   antenne.match_filters << MatchFilter.create(effectif_min: 10)
  # end
  # ## antennes départementales DEETS : - de 20 salariés => sur le **sujet problème de trésorerie** (sur autre sujets : tous les effectifs)
  # Antenne.where(id: []).each do |antenne|
  #   # http://localhost:3000/admin/subjects/42
  #   antenne.match_filters << MatchFilter.create(effectif_max: 20, subject: Subject.find(42))
  # end
  # ## institution CRP DREETS : + de 20 salariés
  # Antenne.where(id: []).each do |antenne|
  #   antenne.match_filters << MatchFilter.create(effectif_min: 19)
  # end
  ## antenne DREETS Commissaire au redressement productif : + de 20 salariés ET code NAF industrie
  Antenne.where(id: [710, 746, 707]).each do |antenne|
    accepted_naf_codes = ['1011Z', '1012Z', '1013A', '1013B', '1020Z', '1031Z', '1032Z', '1039A', '1039B', '1041A', '1041B', '1042Z', '1051A', '1051B', '1051C', '1051D', '1052Z', '1061A', '1061B', '1062Z', '1071A', '1071B', '1071C', '1071D', '1072Z', '1073Z', '1081Z', '1082Z', '1083Z', '1084Z', '1085Z', '1086Z', '1089Z', '1091Z', '1092Z', '1101Z', '1102A', '1102B', '1103Z', '1104Z', '1105Z', '1106Z', '1107A', '1107B', '1200Z', '1310Z', '1320Z', '1330Z', '1391Z', '1392Z', '1393Z', '1394Z', '1395Z', '1396Z', '1399Z', '1411Z', '1412Z', '1413Z', '1414Z', '1419Z', '1420Z', '1431Z', '1439Z', '1511Z', '1512Z', '1520Z', '1610A', '1610B', '1621Z', '1622Z', '1623Z', '1624Z', '1629Z', '1711Z', '1712Z', '1721A', '1721B', '1721C', '1722Z', '1723Z', '1724Z', '1729Z', '1811Z', '1812Z', '1813Z', '1814Z', '1820Z', '2011Z', '2012Z', '2013A', '2013B', '2014Z', '2015Z', '2016Z', '2017Z', '2020Z', '2030Z', '2041Z', '2042Z', '2051Z', '2052Z', '2053Z', '2059Z', '2060Z', '2110Z', '2120Z', '2211Z', '2219Z', '2221Z', '2222Z', '2223Z', '2229A', '2229B', '2311Z', '2312Z', '2313Z', '2314Z', '2319Z', '2320Z', '2331Z', '2332Z', '2341Z', '2342Z', '2343Z', '2344Z', '2349Z', '2351Z', '2352Z', '2361Z', '2362Z', '2363Z', '2364Z', '2365Z', '2369Z', '2370Z', '2391Z', '2399Z', '2410Z', '2420Z', '2431Z', '2432Z', '2433Z', '2434Z', '2441Z', '2442Z', '2443Z', '2444Z', '2445Z', '2446Z', '2451Z', '2452Z', '2453Z', '2454Z', '2511Z', '2512Z', '2521Z', '2529Z', '2530Z', '2540Z', '2550A', '2550B', '2561Z', '2562A', '2562B', '2571Z', '2572Z', '2573A', '2573B', '2591Z', '2592Z', '2593Z', '2594Z', '2599A', '2599B', '2611Z', '2612Z', '2620Z', '2630Z', '2640Z', '2651A', '2651B', '2652Z', '2660Z', '2670Z', '2680Z', '2711Z', '2712Z', '2720Z', '2731Z', '2732Z', '2733Z', '2740Z', '2751Z', '2752Z', '2790Z', '2811Z', '2812Z', '2813Z', '2814Z', '2815Z', '2821Z', '2822Z', '2823Z', '2824Z', '2825Z', '2829A', '2829B', '2830Z', '2841Z', '2849Z', '2891Z', '2892Z', '2893Z', '2894Z', '2895Z', '2896Z', '2899A', '2899B', '2910Z', '2920Z', '2931Z', '2932Z', '3011Z', '3012Z', '3020Z', '3030Z', '3040Z', '3091Z', '3092Z', '3099Z', '3101Z', '3102Z', '3103Z', '3109A', '3109B', '3211Z', '3212Z', '3213Z', '3220Z', '3230Z', '3240Z', '3250A', '3250B', '3291Z', '3299Z']
    antenne.match_filters << MatchFilter.create(effectif_min: 19, accepted_naf_codes: accepted_naf_codes, subject: Subject.find(42))
  end
  # ## institution DREETS : liste de codes NAF industries et autre => sur le **sujet difficulté** (sur autres sujets : tous les codes NAF)
  # Antenne.where(id: []).each do |antenne|
  #   accepted_naf_codes = []
  #   antenne.match_filters << MatchFilter.create(effectif_min: 19, accepted_naf_codes: accepted_naf_codes)
  # end
  ## institution BPI : + de 10 salariés
  ## institution BPI : entreprise de plus de 3 ans
  Antenne.where(id: 288).each do |antenne|
    antenne.match_filters << MatchFilter.create(effectif_min: 10)
    antenne.match_filters << MatchFilter.create(min_years_of_existence: 3)
  end
  # ## quelques antennes Pôle emploi en PACA : codes NAF industrie / commerces, tous sujets
  # Antenne.where(id: []).each do |antenne|
  #   accepted_naf_codes = []
  #   antenne.match_filters << MatchFilter.create(effectif_min: 19, accepted_naf_codes: accepted_naf_codes)
  # end
  # ## institution ou antenne Asso de professions libérales : liste de codes NAF
  # Antenne.where(id: []).each do |antenne|
  #   accepted_naf_codes = []
  #   antenne.match_filters << MatchFilter.create(effectif_min: 19, accepted_naf_codes: accepted_naf_codes)
  # end
end
