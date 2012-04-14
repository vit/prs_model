# coding: UTF-8

module Coms
	class User
		class Country
			def self.list
				List
			end
			def self.get_name code, lang=:en
				code = code.to_sym
				lang = lang.to_sym
				lang = :en unless [:en, :ru].include? lang
				@names ||= {}
				unless @names[lang]
					@names[lang] = {}
					list.each do |e|
						c = e[:code].to_sym
						n = e[lang]
						@names[lang][c] = n
					end
				end
				@names[lang][code]
			end
			List = [
				#{:code=>"ac", :en=>nil, :ru=>nil},
				#{:code=>"ac", :en=>"Ascension Island", :ru=>"Остров Вознесения"},
				{:code=>"ad", :en=>"Andorra", :ru=>"Андорра"},
				{:code=>"ae", :en=>"United Arab Emirates", :ru=>"Объединенные Арабские Эмираты"},
				{:code=>"af", :en=>"Afghanistan", :ru=>"Афганистан"},
				{:code=>"ag", :en=>"Antigua and Barbuda", :ru=>"Антигуа и Барбуда"},
				{:code=>"ai", :en=>"Anguilla", :ru=>"Ангилья"},
				{:code=>"al", :en=>"Albania", :ru=>"Албания"},
				{:code=>"am", :en=>"Armenia", :ru=>"Армения"},
				{:code=>"an", :en=>"Netherlands Antilles", :ru=>"Антильские острова (Нид.)"},
				{:code=>"ao", :en=>"Angola", :ru=>"Ангола"},
				{:code=>"aq", :en=>"Antarctica", :ru=>"Антарктика"},
				{:code=>"ar", :en=>"Argentina", :ru=>"Аргентина"},
				{:code=>"as", :en=>"American Samoa", :ru=>"Восточное Самоа"},
				{:code=>"at", :en=>"Austria", :ru=>"Австрия"},
				{:code=>"au", :en=>"Australia", :ru=>"Австралия"},
				{:code=>"aw", :en=>"Aruba", :ru=>"Аруба (Антильские острова Нид.)"},
				{:code=>"ax", :en=>"AX", :ru=>"AX"},
				{:code=>"az", :en=>"Azerbaijan", :ru=>"Азербайджан"},
				{:code=>"ba", :en=>"Bosnia and Herzegovina", :ru=>"Босния и Герцеговина"},
				{:code=>"bb", :en=>"Barbados", :ru=>"Барбадос"},
				{:code=>"bd", :en=>"Bangladesh", :ru=>"Бангладеш"},
				{:code=>"be", :en=>"Belgium", :ru=>"Бельгия"},
				{:code=>"bf", :en=>"Burkina Faso", :ru=>"Буркина-Фасо"},
				{:code=>"bg", :en=>"Bulgaria", :ru=>"Болгария"},
				{:code=>"bh", :en=>"Bahrain", :ru=>"Бахрейн"},
				{:code=>"bi", :en=>"Burundi", :ru=>"Бурунди"},
				{:code=>"bj", :en=>"Benin", :ru=>"Бенин"},
				{:code=>"bm", :en=>"Bermuda", :ru=>"Бермудские Острова"},
				{:code=>"bn", :en=>"Brunei", :ru=>"Бруней"},
				{:code=>"bo", :en=>"Bolivia", :ru=>"Боливия"},
				{:code=>"br", :en=>"Brazil", :ru=>"Бразилия"},
				{:code=>"bs", :en=>"Bahamas", :ru=>"Багамские Острова"},
				{:code=>"bt", :en=>"Bhutan", :ru=>"Бутан"},
				{:code=>"bv", :en=>"Bouvet Island", :ru=>"Буве остров"},
				{:code=>"bw", :en=>"Botswana", :ru=>"Ботсвана"},
				{:code=>"by", :en=>"Belarus", :ru=>"Белоруссия"},
				{:code=>"bz", :en=>"Belize", :ru=>"Белиз"},
				{:code=>"ca", :en=>"Canada", :ru=>"Канада"},
				{:code=>"cc", :en=>"Cocos Islands (Keeling)", :ru=>"Кокосовые(Килинг) острова"},
				{:code=>"cd", :en=>"Congo, the Democratic Republic of the", :ru=>"Конго, Демократическая Республика"},
				{:code=>"cf", :en=>"Central African Republic", :ru=>"Центральноафриканская республика"},
				{:code=>"cg", :en=>"Congo", :ru=>"Конго"},
				{:code=>"ch", :en=>"Switzerland", :ru=>"Швейцария"},
				{:code=>"ci", :en=>"Côte d'Ivoire", :ru=>"Кот-д'Ивуар"},
				{:code=>"ck", :en=>"Cook Islands", :ru=>"Кука Острова"},
				{:code=>"cl", :en=>"Chile", :ru=>"Чили"},
				{:code=>"cm", :en=>"Cameroon", :ru=>"Камерун"},
				{:code=>"cn", :en=>"China", :ru=>"Китай"},
				{:code=>"co", :en=>"Colombia", :ru=>"Колумбия"},
				{:code=>"cr", :en=>"Costa Rica", :ru=>"Коста-Рика"},
				{:code=>"cs", :en=>"Serbia and Montenegro", :ru=>"Сербия и Черногория"},
				{:code=>"cu", :en=>"Cuba", :ru=>"Куба"},
				{:code=>"cv", :en=>"Cape Verde", :ru=>"Кабо-Верде"},
				{:code=>"cx", :en=>"Christmas Island", :ru=>"Рождества остров"},
				{:code=>"cy", :en=>"Cyprus", :ru=>"Кипр"},
				{:code=>"cz", :en=>"Czechia", :ru=>"Чехия"},
				{:code=>"de", :en=>"Germany", :ru=>"Германия"},
				{:code=>"dj", :en=>"Djibouti", :ru=>"Джибути"},
				{:code=>"dk", :en=>"Denmark", :ru=>"Дания"},
				{:code=>"dm", :en=>"Dominica", :ru=>"Доминика"},
				{:code=>"do", :en=>"Dominican Republic", :ru=>"Доминиканская Республика"},
				{:code=>"dz", :en=>"Algeria", :ru=>"Алжир"},
				{:code=>"ec", :en=>"Ecuador", :ru=>"Эквадор"},
				{:code=>"ee", :en=>"Estonia", :ru=>"Эстония"},
				{:code=>"eg", :en=>"Egypt", :ru=>"Египет"},
				{:code=>"eh", :en=>"Western Sahara", :ru=>"Западная Сахара"},
				{:code=>"er", :en=>"Eritrea", :ru=>"Эритрея"},
				{:code=>"es", :en=>"Spain", :ru=>"Испания"},
				{:code=>"et", :en=>"Ethiopia", :ru=>"Эфиопия"},
				{:code=>"eu", :en=>nil, :ru=>nil},
				{:code=>"fi", :en=>"Finland", :ru=>"Финляндия"},
				{:code=>"fj", :en=>"Fiji", :ru=>"Фиджи"},
				{:code=>"fk", :en=>"Falkland Islands", :ru=>"Фолклендские (Мальвинские) Острова"},
				{:code=>"fm", :en=>"Micronesia, Federated States of", :ru=>"Микронезия, Федеративные Штаты"},
				{:code=>"fo", :en=>"Faroe Islands", :ru=>"Фарерские Острова"},
				{:code=>"fr", :en=>"France", :ru=>"Франция"},
				{:code=>"fx", :en=>"FX", :ru=>"Франция, Метрополия"},
				{:code=>"ga", :en=>"Gabon", :ru=>"Габон"},
				{:code=>"gb", :en=>"Great Britain", :ru=>"Великобритания"},
				{:code=>"gd", :en=>"Grenada", :ru=>"Гренада"},
				{:code=>"ge", :en=>"Georgia", :ru=>"Грузия"},
				{:code=>"gf", :en=>"French Guiana", :ru=>"Гвиана (Фр.)"},
				{:code=>"gg", :en=>"Guernsey", :ru=>"Гернси"},
				{:code=>"gh", :en=>"Ghana", :ru=>"Гана"},
				{:code=>"gi", :en=>"Gibraltar", :ru=>"Гибралтар"},
				{:code=>"gl", :en=>"Greenland", :ru=>"Гренландия"},
				{:code=>"gm", :en=>"Gambia", :ru=>"Гамбия"},
				{:code=>"gn", :en=>"Guinea", :ru=>"Гвинея"},
				{:code=>"gp", :en=>"Guadeloupe", :ru=>"Гваделупа"},
				{:code=>"gq", :en=>"Equatorial Guinea", :ru=>"Экваториальная Гвинея"},
				{:code=>"gr", :en=>"Greece", :ru=>"Греция"},
				{:code=>"gs", :en=>"South Georgia and the South Sandwich Islands", :ru=>"Южная Георгия и Южные Сандвичевы Острова"},
				{:code=>"gt", :en=>"Guatemala", :ru=>"Гватемала"},
				{:code=>"gu", :en=>"Guam", :ru=>"Гуам"},
				{:code=>"gw", :en=>"Guinea-Bissau", :ru=>"Гвинея-Бисау"},
				{:code=>"gy", :en=>"Guyana", :ru=>"Гайана"},
				{:code=>"hk", :en=>"Hong Kong", :ru=>"Сянган (Гонконг)"},
				{:code=>"hm", :en=>"Heard Island and McDonald Islands", :ru=>"Херд и Макдональд, острова"},
				{:code=>"hn", :en=>"Honduras", :ru=>"Гондурас"},
				{:code=>"hr", :en=>"Croatia", :ru=>"Хорватия"},
				{:code=>"ht", :en=>"Haiti", :ru=>"Гаити"},
				{:code=>"hu", :en=>"Hungary", :ru=>"Венгрия"},
				{:code=>"id", :en=>"Indonesia", :ru=>"Индонезия"},
				{:code=>"ie", :en=>"Ireland", :ru=>"Ирландия"},
				{:code=>"il", :en=>"Israel", :ru=>"Израиль"},
				{:code=>"im", :en=>"Isle of Man", :ru=>"Остров Мэн"},
				{:code=>"in", :en=>"India", :ru=>"Индия"},
				{:code=>"io", :en=>"British Indian Ocean Territory", :ru=>"Британские территории в Индийском океане"},
				{:code=>"iq", :en=>"Iraq", :ru=>"Ирак"},
				{:code=>"ir", :en=>"Iran", :ru=>"Иран"},
				{:code=>"is", :en=>"Iceland", :ru=>"Исландия"},
				{:code=>"it", :en=>"Italy", :ru=>"Италия"},
				{:code=>"je", :en=>"Jersey", :ru=>"Джерси"},
				{:code=>"jm", :en=>"Jamaica", :ru=>"Ямайка"},
				{:code=>"jo", :en=>"Jordan", :ru=>"Иордания"},
				{:code=>"jp", :en=>"Japan", :ru=>"Япония"},
				{:code=>"ke", :en=>"Kenya", :ru=>"Кения"},
				{:code=>"kg", :en=>"Kyrgyzstan", :ru=>"Киргизия"},
				{:code=>"kh", :en=>"Cambodia", :ru=>"Камбоджа"},
				{:code=>"ki", :en=>"Kiribati", :ru=>"Кирибати"},
				{:code=>"km", :en=>"Comoros", :ru=>"Коморские Острова"},
				{:code=>"kn", :en=>"Saint Kitts and Nevis", :ru=>"Сент-Китс и Невис"},
				{:code=>"kp", :en=>"North Korea", :ru=>"Северная Корея"},
				{:code=>"kr", :en=>"South Korea", :ru=>"Южная Корея"},
				{:code=>"kw", :en=>"Kuwait", :ru=>"Кувейт"},
				{:code=>"ky", :en=>"Cayman Islands", :ru=>"Кайман острова"},
				{:code=>"kz", :en=>"Kazakhstan", :ru=>"Казахстан"},
				{:code=>"la", :en=>"Laos", :ru=>"Лаос"},
				{:code=>"lb", :en=>"Lebanon", :ru=>"Ливан"},
				{:code=>"lc", :en=>"Saint Lucia", :ru=>"Сент-Люсия"},
				{:code=>"li", :en=>"Liechtenstein", :ru=>"Лихтенштейн"},
				{:code=>"lk", :en=>"Sri Lanka", :ru=>"Шри-Ланка"},
				{:code=>"lr", :en=>"Liberia", :ru=>"Либерия"},
				{:code=>"ls", :en=>"Lesotho", :ru=>"Лесото"},
				{:code=>"lt", :en=>"Lithuania", :ru=>"Литва"},
				{:code=>"lu", :en=>"Luxembourg", :ru=>"Люксембург"},
				{:code=>"lv", :en=>"Latvia", :ru=>"Латвия"},
				{:code=>"ly", :en=>"Libya", :ru=>"Ливия"},
				{:code=>"ma", :en=>"Morocco", :ru=>"Марокко"},
				{:code=>"mc", :en=>"Monaco", :ru=>"Монако"},
				{:code=>"md", :en=>"Moldova", :ru=>"Молдавия"},
				{:code=>"mg", :en=>"Madagascar", :ru=>"Мадагаскар"},
				{:code=>"mh", :en=>"Marshall Islands", :ru=>"Маршалловы Острова"},
				{:code=>"mk", :en=>"Macedonia", :ru=>"Македония"},
				{:code=>"ml", :en=>"Mali", :ru=>"Мали"},
				{:code=>"mm", :en=>"Myanmar", :ru=>"Мьянма"},
				{:code=>"mn", :en=>"Mongolia", :ru=>"Монголия"},
				{:code=>"mo", :en=>"Macau", :ru=>"Аомынь (Макао)"},
				{:code=>"mp", :en=>"Northern Mariana Islands", :ru=>"Северные Марианские острова"},
				{:code=>"mq", :en=>"Martinique", :ru=>"Мартиника"},
				{:code=>"mr", :en=>"Mauritania", :ru=>"Мавритания"},
				{:code=>"ms", :en=>"Montserrat", :ru=>"Монтсеррат"},
				{:code=>"mt", :en=>"Malta", :ru=>"Мальта"},
				{:code=>"mu", :en=>"Mauritius", :ru=>"Маврикий"},
				{:code=>"mv", :en=>"Maldives", :ru=>"Мальдивы"},
				{:code=>"mw", :en=>"Malawi", :ru=>"Малави"},
				{:code=>"mx", :en=>"Mexico", :ru=>"Мексика"},
				{:code=>"my", :en=>"Malaysia", :ru=>"Малайзия"},
				{:code=>"mz", :en=>"Mozambique", :ru=>"Мозамбик"},
				{:code=>"na", :en=>"Namibia", :ru=>"Намибия"},
				{:code=>"nc", :en=>"New Caledonia", :ru=>"Новая Каледония"},
				{:code=>"ne", :en=>"Niger", :ru=>"Нигер"},
				{:code=>"nf", :en=>"Norfolk Island", :ru=>"Норфолк"},
				{:code=>"ng", :en=>"Nigeria", :ru=>"Нигерия"},
				{:code=>"ni", :en=>"Nicaragua", :ru=>"Никарагуа"},
				{:code=>"nl", :en=>"Netherlands", :ru=>"Нидерланды"},
				{:code=>"no", :en=>"Norway", :ru=>"Норвегия"},
				{:code=>"np", :en=>"Nepal", :ru=>"Непал"},
				{:code=>"nr", :en=>"Nauru", :ru=>"Науру"},
				{:code=>"nu", :en=>"Niue", :ru=>"Ниуэ"},
				{:code=>"nz", :en=>"New Zealand", :ru=>"Новая Зеландия"},
				{:code=>"om", :en=>"Oman", :ru=>"Оман"},
				{:code=>"pa", :en=>"Panama", :ru=>"Панама"},
				{:code=>"pe", :en=>"Peru", :ru=>"Перу"},
				{:code=>"pf", :en=>"French Polynesia", :ru=>"Французская Полинезия"},
				{:code=>"pg", :en=>"Papua New Guinea", :ru=>"Папуа-Новая Гвинея"},
				{:code=>"ph", :en=>"Philippines", :ru=>"Филиппины"},
				{:code=>"pk", :en=>"Pakistan", :ru=>"Пакистан"},
				{:code=>"pl", :en=>"Poland", :ru=>"Польша"},
				{:code=>"pm", :en=>"Saint Pierre and Miquelon", :ru=>"Сен-Пьер и Микелон"},
				{:code=>"pn", :en=>"Pitcairn", :ru=>"Питкэрн"},
				{:code=>"pr", :en=>"Puerto Rico", :ru=>"Пуэрто-Рико"},
				{:code=>"ps", :en=>"Palestine", :ru=>"Палестина"},
				{:code=>"pt", :en=>"Portugal", :ru=>"Португалия"},
				{:code=>"pw", :en=>"Palau", :ru=>"Палау"},
				{:code=>"py", :en=>"Paraguay", :ru=>"Парагвай"},
				{:code=>"qa", :en=>"Qatar", :ru=>"Катар"},
				{:code=>"re", :en=>"Reunion", :ru=>"Реюньон"},
				{:code=>"ro", :en=>"Romania", :ru=>"Румыния"},
				{:code=>"ru", :en=>"Russia", :ru=>"Россия"},
				{:code=>"rw", :en=>"Rwanda", :ru=>"Руанда"},
				{:code=>"sa", :en=>"Saudi Arabia", :ru=>"Саудовская Аравия"},
				{:code=>"sb", :en=>"Solomon Islands", :ru=>"Соломоновы Острова"},
				{:code=>"sc", :en=>"Seychelles", :ru=>"Сейшельские острова"},
				{:code=>"sd", :en=>"Sudan", :ru=>"Судан"},
				{:code=>"se", :en=>"Sweden", :ru=>"Швеция"},
				{:code=>"sg", :en=>"Singapore", :ru=>"Сингапур"},
				{:code=>"sh", :en=>"Saint Helena", :ru=>"Святой Елены остров"},
				{:code=>"si", :en=>"Slovenia", :ru=>"Словения"},
				{:code=>"sj", :en=>"Svalbard and Jan Mayen", :ru=>"Шпицберген и Ян-Майен"},
				{:code=>"sk", :en=>"Slovakia", :ru=>"Словакия"},
				{:code=>"sl", :en=>"Sierra Leone", :ru=>"Сьерра-Леоне"},
				{:code=>"sm", :en=>"San Marino", :ru=>"Сан-Марино"},
				{:code=>"sn", :en=>"Senegal", :ru=>"Сенегал"},
				{:code=>"so", :en=>"Somalia", :ru=>"Сомали"},
				{:code=>"sr", :en=>"Suriname", :ru=>"Суринам"},
				{:code=>"st", :en=>"Sao Tome and Principe", :ru=>"Сан-Томе и Принсипи"},
				{:code=>"sv", :en=>"El Salvador", :ru=>"Сальвадор"},
				{:code=>"sy", :en=>"Syria", :ru=>"Сирия"},
				{:code=>"sz", :en=>"Swaziland", :ru=>"Свазиленд"},
				{:code=>"tc", :en=>"Turks and Caicos Islands", :ru=>"Теркс и Кайкос острова"},
				{:code=>"td", :en=>"Chad", :ru=>"Чад"},
				{:code=>"tf", :en=>"French Southern Territories", :ru=>"Французские Южные Территории"},
				{:code=>"tg", :en=>"Togo", :ru=>"Того"},
				{:code=>"th", :en=>"Thailand", :ru=>"Таиланд"},
				{:code=>"tj", :en=>"Tajikistan", :ru=>"Таджикистан"},
				{:code=>"tk", :en=>"Tokelau", :ru=>"Токелау"},
				{:code=>"tl", :en=>"Timor-Leste (East Timor)", :ru=>"Восточный Тимор"},
				{:code=>"tm", :en=>"Turkmenistan", :ru=>"Туркмения"},
				{:code=>"tn", :en=>"Tunisia", :ru=>"Тунис"},
				{:code=>"to", :en=>"Tonga", :ru=>"Тонга"},
				{:code=>"tr", :en=>"Turkey", :ru=>"Турция"},
				{:code=>"tt", :en=>"Trinidad and Tobago", :ru=>"Тринидад и Тобаго"},
				{:code=>"tv", :en=>"Tuvalu", :ru=>"Тувалу"},
				{:code=>"tw", :en=>"Taiwan", :ru=>"Тайвань"},
				{:code=>"tz", :en=>"Tanzania", :ru=>"Танзания"},
				{:code=>"ua", :en=>"Ukraine", :ru=>"Украина"},
				{:code=>"ug", :en=>"Uganda", :ru=>"Уганда"},
				{:code=>"uk", :en=>"United Kingdom", :ru=>"Соединённое Королевство"},
				{:code=>"um", :en=>"United States Minor Outlying Islands", :ru=>"Мелкие отдаленные острова США"},
				{:code=>"us", :en=>"United States", :ru=>"Соединенные Штаты Америки"},
				{:code=>"uy", :en=>"Uruguay", :ru=>"Уругвая"},
				{:code=>"uz", :en=>"Uzbekistan", :ru=>"Узбекистан"},
				{:code=>"va", :en=>"Vatican (or Holy See)", :ru=>"Ватикан"},
				{:code=>"vc", :en=>"Saint Vincent and the Grenadines", :ru=>"Сент Винсент и Гренадины"},
				{:code=>"ve", :en=>"Venezuela", :ru=>"Венесуэла"},
				{:code=>"vg", :en=>"Virgin Islands, British", :ru=>"Виргинские острова (Брит.)"},
				{:code=>"vi", :en=>"Virgin Islands, U.S.", :ru=>"Виргинские острова (США)"},
				{:code=>"vn", :en=>"Vietnam", :ru=>"Вьетнам"},
				{:code=>"vu", :en=>"Vanuatu", :ru=>"Вануату"},
				{:code=>"wf", :en=>"Wallis and Futuna", :ru=>"Уолис и Футуна острова"},
				{:code=>"ws", :en=>"Samoa", :ru=>"Западное Самоа"},
				{:code=>"ye", :en=>"Yemen", :ru=>"Йемен"},
				{:code=>"yt", :en=>"Mayotte", :ru=>"Майотта"},
				{:code=>"za", :en=>"South Africa", :ru=>"Южная Африка"},
				{:code=>"zm", :en=>"Zambia", :ru=>"Замбия"},
				{:code=>"zw", :en=>"Zimbabwe", :ru=>"Зимбабве"}
			]
		end
	end
end
