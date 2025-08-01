import SwiftUI

struct BirthdayPopupView: View {
    let birthday: Date
    let contactName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text("🎂")
                            .font(.system(size: 60))
                        
                        Text("\(contactName)'s Birthday")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(formatBirthday())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Historic Events
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Historic Events on This Day")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(getHistoricEvents(), id: \.self) { event in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                    
                                    Text(event)
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Famous Birthdays
                    if let famousBirthdays = getFamousBirthdays() {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Famous People Born on This Day")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(famousBirthdays, id: \.self) { person in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.purple)
                                            .font(.caption)
                                        
                                        Text(person)
                                            .font(.body)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Fun Facts
                    if let funFacts = getFunFacts() {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Fun Facts")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(funFacts, id: \.self) { fact in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                        
                                        Text(fact)
                                            .font(.body)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Zodiac Info
                    HStack(spacing: 40) {
                        VStack(spacing: 8) {
                            Text("Western Zodiac")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(getWesternZodiac())
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Lunar Zodiac")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(getChineseZodiac())
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 40)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Birthday Facts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func formatBirthday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: birthday)
    }
    
    private func getMonthDay() -> (month: Int, day: Int) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: birthday)
        let day = calendar.component(.day, from: birthday)
        return (month, day)
    }
    
    private func getHistoricEvents() -> [String] {
        let (month, day) = getMonthDay()
        
        switch (month, day) {
        case (1, 1): return [
            "1801: The United Kingdom of Great Britain and Ireland is established",
            "1863: The Emancipation Proclamation takes effect, freeing slaves in Confederate states",
            "1901: Australia becomes a federation of six states",
            "1999: The Euro currency is introduced in 11 European countries"
        ]
        case (1, 2): return [
            "1492: The Reconquista ends with the fall of Granada",
            "1788: Georgia becomes the 4th state to ratify the U.S. Constitution",
            "1905: The Russian Revolution of 1905 begins",
            "1959: Luna 1 becomes the first spacecraft to reach the Moon"
        ]
        case (1, 3): return [
            "1521: Martin Luther is excommunicated by Pope Leo X",
            "1777: American forces win the Battle of Princeton",
            "1959: Alaska becomes the 49th state of the United States",
            "2004: NASA's Spirit rover lands on Mars"
        ]
        case (1, 4): return [
            "1642: Isaac Newton is born in Woolsthorpe, England",
            "1790: President George Washington delivers the first State of the Union address",
            "1948: Burma gains independence from the United Kingdom",
            "2007: Nancy Pelosi becomes the first female Speaker of the House"
        ]
        case (1, 5): return [
            "1066: Edward the Confessor dies, leading to the Norman Conquest",
            "1781: The British fleet is destroyed at the Battle of Jersey",
            "1925: Nellie Tayloe Ross becomes the first female governor in the U.S.",
            "2005: Eris, the largest known dwarf planet, is discovered"
        ]
        case (1, 6): return [
            "1066: Harold Godwinson is crowned King of England",
            "1838: Samuel Morse demonstrates the telegraph for the first time",
            "1912: New Mexico becomes the 47th state of the United States",
            "1994: Nancy Kerrigan is attacked by Tonya Harding's associates"
        ]
        case (1, 7): return [
            "1610: Galileo Galilei discovers the four largest moons of Jupiter",
            "1789: The first U.S. presidential election is held",
            "1927: The first transatlantic telephone call is made",
            "1959: The United States recognizes Fidel Castro's government in Cuba"
        ]
        case (1, 8): return [
            "1815: The Battle of New Orleans is fought",
            "1935: Elvis Presley is born in Tupelo, Mississippi",
            "1964: President Lyndon B. Johnson declares 'War on Poverty'",
            "2011: U.S. Representative Gabrielle Giffords is shot in Tucson"
        ]
        case (1, 9): return [
            "1793: The first successful hot air balloon flight in America",
            "1861: Mississippi becomes the second state to secede from the Union",
            "1913: Richard Nixon is born in Yorba Linda, California",
            "2007: Apple CEO Steve Jobs introduces the iPhone"
        ]
        case (1, 10): return [
            "49 BCE: Julius Caesar crosses the Rubicon River",
            "1776: Thomas Paine publishes 'Common Sense'",
            "1863: The London Underground opens",
            "1946: The first General Assembly of the United Nations opens"
        ]
        case (1, 11): return [
            "1569: The first recorded lottery in England is drawn",
            "1759: The first American life insurance company is founded",
            "1922: Insulin is first used to treat diabetes",
            "1964: The Surgeon General's report on smoking is published"
        ]
        case (1, 12): return [
            "1773: The first public museum in America opens in Charleston",
            "1932: Hattie Caraway becomes the first woman elected to the U.S. Senate",
            "1966: President Lyndon B. Johnson says the U.S. should stay in Vietnam",
            "2010: A 7.0 magnitude earthquake devastates Haiti"
        ]
        case (1, 13): return [
            "1128: The Knights Templar are officially recognized by the Catholic Church",
            "1794: President George Washington approves the first U.S. flag",
            "1930: Mickey Mouse comic strip first appears",
            "1982: Air Florida Flight 90 crashes into the Potomac River"
        ]
        case (1, 14): return [
            "1506: The Laocoon sculpture is discovered in Rome",
            "1784: The Continental Congress ratifies the Treaty of Paris",
            "1954: Marilyn Monroe marries Joe DiMaggio",
            "2005: The Huygens probe lands on Saturn's moon Titan"
        ]
        case (1, 15): return [
            "1559: Elizabeth I is crowned Queen of England",
            "1929: Martin Luther King Jr. is born in Atlanta, Georgia",
            "1967: The first Super Bowl is played between Green Bay Packers and Kansas City Chiefs",
            "2001: Wikipedia is launched by Jimmy Wales and Larry Sanger"
        ]
        case (1, 16): return [
            "27 BCE: Augustus becomes the first Roman Emperor",
            "1920: Prohibition begins in the United States",
            "1969: The Soviet Union launches Soyuz 4",
            "2003: The Space Shuttle Columbia disaster occurs"
        ]
        case (1, 17): return [
            "1377: Pope Gregory XI moves the Papacy back to Rome",
            "1893: The Hawaiian monarchy is overthrown",
            "1994: A 6.7 magnitude earthquake strikes Los Angeles",
            "2007: The Doomsday Clock is moved to 5 minutes to midnight"
        ]
        case (1, 18): return [
            "1778: Captain James Cook discovers the Hawaiian Islands",
            "1912: Robert Scott reaches the South Pole",
            "1943: The Warsaw Ghetto Uprising begins",
            "1993: Martin Luther King Jr. Day is observed for the first time"
        ]
        case (1, 19): return [
            "1419: The Hundred Years' War resumes",
            "1861: Georgia becomes the fifth state to secede from the Union",
            "1937: Howard Hughes sets a new air record by flying from Los Angeles to New York",
            "1983: Apple introduces the Lisa computer"
        ]
        case (1, 20): return [
            "1265: The first English parliament meets",
            "1936: King Edward VIII becomes King of the United Kingdom",
            "1981: Iran releases 52 American hostages",
            "2009: Barack Obama is inaugurated as the 44th President of the United States"
        ]
        case (1, 21): return [
            "1793: King Louis XVI of France is executed by guillotine",
            "1911: The first Monte Carlo Rally takes place",
            "1976: The first commercial Concorde flight takes off",
            "2003: The last known Pyrenean ibex dies, making the species extinct"
        ]
        case (1, 22): return [
            "1506: The first contingent of 150 Swiss Guards arrives at the Vatican",
            "1901: Queen Victoria dies after 63 years on the throne",
            "1973: The Supreme Court decides Roe v. Wade",
            "2006: Evo Morales becomes the first indigenous President of Bolivia"
        ]
        case (1, 23): return [
            "1556: The deadliest earthquake in history strikes Shaanxi, China",
            "1849: Elizabeth Blackwell becomes the first woman to receive a medical degree in the U.S.",
            "1937: The Moscow Trials begin in the Soviet Union",
            "1997: Madeleine Albright becomes the first female U.S. Secretary of State"
        ]
        case (1, 24): return [
            "41: The Roman Emperor Caligula is assassinated",
            "1848: Gold is discovered at Sutter's Mill, starting the California Gold Rush",
            "1935: The first canned beer is sold by Krueger Brewing Company",
            "1986: The Voyager 2 space probe makes its closest approach to Uranus"
        ]
        case (1, 25): return [
            "1327: Edward III becomes King of England",
            "1890: The United Mine Workers of America is founded",
            "1924: The first Winter Olympics opens in Chamonix, France",
            "1995: The Norwegian rocket incident occurs, almost triggering nuclear war"
        ]
        case (1, 26): return [
            "1500: Vicente Yáñez Pinzón becomes the first European to set foot in Brazil",
            "1788: The First Fleet arrives in Australia",
            "1926: The first public demonstration of television",
            "2001: An earthquake in Gujarat, India kills over 20,000 people"
        ]
        case (1, 27): return [
            "98: Trajan becomes Roman Emperor",
            "1888: The National Geographic Society is founded",
            "1967: The Apollo 1 fire kills three astronauts",
            "2010: Apple announces the iPad"
        ]
        case (1, 28): return [
            "1547: Henry VIII dies and is succeeded by his son Edward VI",
            "1871: France surrenders to Prussia, ending the Franco-Prussian War",
            "1986: The Space Shuttle Challenger disaster occurs",
            "2002: The first Wikipedia article is published"
        ]
        case (1, 29): return [
            "904: Sergius III becomes Pope",
            "1936: The first players are elected to the Baseball Hall of Fame",
            "1996: The first successful cloning of a mammal, Dolly the sheep",
            "2002: President George W. Bush delivers the 'Axis of Evil' speech"
        ]
        case (1, 30): return [
            "1649: King Charles I of England is executed",
            "1933: Adolf Hitler becomes Chancellor of Germany",
            "1969: The Beatles perform their last public concert",
            "2003: The Space Shuttle Columbia disaster occurs"
        ]
        case (1, 31): return [
            "1606: Guy Fawkes is executed for plotting to blow up the English Parliament",
            "1865: The Thirteenth Amendment to the U.S. Constitution is passed",
            "1958: The first American satellite, Explorer 1, is launched",
            "1990: The first McDonald's opens in Moscow"
        ]
        case (2, 1): return [
            "1327: Edward III becomes King of England",
            "1790: The Supreme Court of the United States convenes for the first time",
            "1960: Four black students stage the first sit-in at a Woolworth's lunch counter",
            "2003: The Space Shuttle Columbia disaster occurs"
        ]
        case (2, 2): return [
            "506: Alaric II, King of the Visigoths, promulgates the Breviary of Alaric",
            "1653: New Amsterdam is incorporated as a city",
            "1887: The first Groundhog Day is observed in Punxsutawney, Pennsylvania",
            "1990: South African President F.W. de Klerk lifts the ban on the African National Congress"
        ]
        case (2, 3): return [
            "1488: Bartolomeu Dias of Portugal lands in Mossel Bay after rounding the Cape of Good Hope",
            "1783: Spain recognizes the independence of the United States",
            "1959: Buddy Holly, Ritchie Valens, and J.P. Richardson die in a plane crash",
            "1995: The Space Shuttle Discovery launches on mission STS-63"
        ]
        case (2, 4): return [
            "211: Roman Emperor Septimius Severus dies",
            "1789: George Washington is unanimously elected as the first President of the United States",
            "1945: The Yalta Conference begins",
            "2004: Facebook is launched by Mark Zuckerberg"
        ]
        case (2, 5): return [
            "62: An earthquake destroys Pompeii and Herculaneum",
            "1778: South Carolina becomes the first state to ratify the Articles of Confederation",
            "1917: The United States Congress passes the Immigration Act of 1917",
            "1971: Apollo 14 lands on the Moon"
        ]
        case (2, 6): return [
            "1685: James II becomes King of England",
            "1778: France recognizes the independence of the United States",
            "1952: Elizabeth II becomes Queen of the United Kingdom",
            "1971: Alan Shepard becomes the first person to play golf on the Moon"
        ]
        case (2, 7): return [
            "457: Leo I becomes Byzantine Emperor",
            "1795: The 11th Amendment to the U.S. Constitution is ratified",
            "1964: The Beatles arrive in the United States for the first time",
            "1984: Bruce McCandless becomes the first person to perform an untethered spacewalk"
        ]
        case (2, 8): return [
            "421: Constantius III becomes co-Emperor of the Western Roman Empire",
            "1587: Mary, Queen of Scots is executed",
            "1915: D.W. Griffith's controversial film 'The Birth of a Nation' premieres",
            "1960: The first star is placed on the Hollywood Walk of Fame"
        ]
        case (2, 9): return [
            "474: Zeno is crowned as co-emperor of the Byzantine Empire",
            "1773: William Henry Harrison is born",
            "1943: The Battle of Guadalcanal ends",
            "1964: The Beatles make their first appearance on The Ed Sullivan Show"
        ]
        case (2, 10): return [
            "1258: Baghdad falls to the Mongols",
            "1763: The Treaty of Paris ends the French and Indian War",
            "1933: The New York City-based Postal Telegraph Company introduces the first singing telegram",
            "1996: IBM's Deep Blue defeats world chess champion Garry Kasparov"
        ]
        case (2, 11): return [
            "660 BCE: Traditional founding date of Japan by Emperor Jimmu",
            "1858: The Virgin Mary appears to Bernadette Soubirous in Lourdes, France",
            "1929: The Lateran Treaty is signed, creating the Vatican City",
            "1990: Nelson Mandela is released from prison after 27 years"
        ]
        case (2, 12): return [
            "881: Pope John VIII crowns Charles the Fat Holy Roman Emperor",
            "1809: Charles Darwin is born",
            "1912: The last Qing Emperor of China abdicates",
            "2001: The NEAR Shoemaker spacecraft lands on asteroid 433 Eros"
        ]
        case (2, 13): return [
            "1542: Catherine Howard, the fifth wife of Henry VIII, is executed",
            "1635: The Boston Latin School, the first public school in America, is founded",
            "1945: The bombing of Dresden begins",
            "2000: The last original Peanuts comic strip is published"
        ]
        case (2, 14): return [
            "1929: The St. Valentine's Day Massacre occurs in Chicago",
            "1876: Alexander Graham Bell patents the telephone",
            "1912: Arizona becomes the 48th state of the United States",
            "1989: The first GPS satellite is launched"
        ]
        case (2, 15): return [
            "399 BCE: Socrates is sentenced to death",
            "1764: The city of St. Louis is established",
            "1898: The USS Maine explodes in Havana Harbor",
            "2003: Protests against the Iraq War take place in over 600 cities worldwide"
        ]
        case (2, 16): return [
            "1270: The Grand Duchy of Lithuania is established",
            "1804: Stephen Decatur leads a raid to burn the captured USS Philadelphia",
            "1923: Howard Carter unseals the burial chamber of Pharaoh Tutankhamun",
            "1968: The first 911 emergency telephone system goes into service"
        ]
        case (2, 17): return [
            "1370: The Battle of Rudau takes place",
            "1801: Thomas Jefferson is elected President of the United States",
            "1904: Giacomo Puccini's opera 'Madama Butterfly' premieres",
            "1996: Garry Kasparov defeats Deep Blue in the first game of their chess match"
        ]
        case (2, 18): return [
            "1229: The Sixth Crusade ends with a peace treaty",
            "1861: Jefferson Davis is inaugurated as President of the Confederate States",
            "1930: Pluto is discovered by Clyde Tombaugh",
            "2001: NASCAR driver Dale Earnhardt dies in a crash at the Daytona 500"
        ]
        case (2, 19): return [
            "197: Emperor Septimius Severus defeats usurper Clodius Albinus",
            "1807: Former Vice President Aaron Burr is arrested for treason",
            "1945: The Battle of Iwo Jima begins",
            "1986: The Soviet Union launches the Mir space station"
        ]
        case (2, 20): return [
            "1472: Orkney and Shetland are pawned by Norway to Scotland",
            "1792: The Postal Service Act establishes the United States Post Office",
            "1962: John Glenn becomes the first American to orbit the Earth",
            "1986: The Soviet Union launches the Mir space station"
        ]
        case (2, 21): return [
            "362: Athanasius returns to Alexandria",
            "1848: Karl Marx and Friedrich Engels publish 'The Communist Manifesto'",
            "1965: Malcolm X is assassinated in New York City",
            "1995: Steve Fossett becomes the first person to make a solo flight across the Pacific Ocean"
        ]
        case (2, 22): return [
            "705: Empress Wu Zetian abdicates the throne",
            "1819: Spain cedes Florida to the United States",
            "1980: The United States ice hockey team defeats the Soviet Union in the 'Miracle on Ice'",
            "1997: Scientists announce the birth of Dolly the sheep, the first cloned mammal"
        ]
        case (2, 23): return [
            "1455: The Gutenberg Bible becomes the first printed book",
            "1836: The Battle of the Alamo begins",
            "1945: The American flag is raised on Iwo Jima",
            "1997: A fire at the Uphaar Cinema in New Delhi kills 59 people"
        ]
        case (2, 24): return [
            "303: Galerius publishes his edict that begins the persecution of Christians",
            "1582: Pope Gregory XIII announces the Gregorian calendar",
            "1803: The Supreme Court decides Marbury v. Madison",
            "2008: Fidel Castro resigns as President of Cuba"
        ]
        case (2, 25): return [
            "138: Roman Emperor Hadrian adopts Antoninus Pius",
            "1570: Pope Pius V excommunicates Queen Elizabeth I",
            "1836: Samuel Colt receives a patent for the Colt revolver",
            "1986: People Power Revolution begins in the Philippines"
        ]
        case (2, 26): return [
            "747 BCE: Epoch of the Nabonassar Era begins",
            "1815: Napoleon Bonaparte escapes from Elba",
            "1919: Grand Canyon National Park is established",
            "1993: The World Trade Center bombing occurs"
        ]
        case (2, 27): return [
            "380: The Edict of Thessalonica makes Christianity the state religion of the Roman Empire",
            "1827: The first Mardi Gras celebration is held in New Orleans",
            "1933: The Reichstag fire occurs in Berlin",
            "1991: President George H.W. Bush announces the end of the Gulf War"
        ]
        case (2, 28): return [
            "202: The Battle of Baideng ends with a treaty between the Han and Xiongnu",
            "1638: The Scottish National Covenant is signed",
            "1953: James Watson and Francis Crick discover the structure of DNA",
            "1993: The Bureau of Alcohol, Tobacco and Firearms raids the Branch Davidian compound"
        ]
        case (2, 29): return [
            "1504: Christopher Columbus uses a lunar eclipse to frighten Jamaican natives",
            "1704: Queen Anne's War begins",
            "1940: Hattie McDaniel becomes the first African American to win an Academy Award",
            "2004: Jean-Bertrand Aristide is removed as President of Haiti"
        ]
        case (3, 1): return [
            "752 BCE: Romulus, the first king of Rome, celebrates the first Roman triumph",
            "1565: The city of Rio de Janeiro is founded",
            "1872: Yellowstone National Park is established as the world's first national park",
            "1961: President John F. Kennedy establishes the Peace Corps"
        ]
        case (3, 2): return [
            "537: The Siege of Rome ends",
            "1836: The Republic of Texas declares independence from Mexico",
            "1949: The B-50 Superfortress 'Lucky Lady II' completes the first non-stop around-the-world flight",
            "1962: Wilt Chamberlain scores 100 points in a single NBA game"
        ]
        case (3, 3): return [
            "1284: The Statute of Rhuddlan incorporates the Principality of Wales into England",
            "1845: Florida becomes the 27th state of the United States",
            "1918: Germany, Austria and Russia sign the Treaty of Brest-Litovsk",
            "1991: Rodney King is beaten by Los Angeles police officers"
        ]
        case (3, 4): return [
            "51: Nero is given the title 'princeps iuventutis'",
            "1681: Charles II grants a land charter to William Penn",
            "1933: Franklin D. Roosevelt is inaugurated as President of the United States",
            "1977: The first Cray-1 supercomputer is shipped to Los Alamos National Laboratory"
        ]
        case (3, 5): return [
            "363: Roman Emperor Julian moves from Antioch with an army of 90,000",
            "1770: The Boston Massacre occurs",
            "1946: Winston Churchill delivers his 'Iron Curtain' speech",
            "1982: The Soviet Union's Venera 14 lands on Venus"
        ]
        case (3, 6): return [
            "1521: Ferdinand Magellan arrives at Guam",
            "1836: The Battle of the Alamo ends",
            "1857: The Supreme Court decides Dred Scott v. Sandford",
            "1987: The MS Herald of Free Enterprise capsizes, killing 193 people"
        ]
        case (3, 7): return [
            "321: Emperor Constantine I decrees that the dies Solis Invicti is the day of rest",
            "1876: Alexander Graham Bell is granted a patent for the telephone",
            "1965: Civil rights marchers are beaten by state troopers on 'Bloody Sunday'",
            "2009: NASA's Kepler space telescope is launched"
        ]
        case (3, 8): return [
            "1010: Ferdowsi completes his epic poem 'Shahnameh'",
            "1702: Queen Anne becomes Queen of England",
            "1917: The February Revolution begins in Russia",
            "1983: President Ronald Reagan calls the Soviet Union an 'evil empire'"
        ]
        case (3, 9): return [
            "141: Emperor Antoninus Pius dies",
            "1841: The Supreme Court decides United States v. The Amistad",
            "1933: The Emergency Banking Act is passed",
            "1959: The Barbie doll makes its debut at the American International Toy Fair"
        ]
        case (3, 10): return [
            "241 BCE: The First Punic War ends with the Battle of the Aegates Islands",
            "1848: The Treaty of Guadalupe Hidalgo is ratified",
            "1876: Alexander Graham Bell makes the first successful telephone call",
            "1969: James Earl Ray pleads guilty to assassinating Martin Luther King Jr."
        ]
        case (3, 11): return [
            "222: Emperor Elagabalus is assassinated",
            "1810: Napoleon marries Marie-Louise of Austria",
            "1941: President Franklin D. Roosevelt signs the Lend-Lease Act",
            "1990: Lithuania declares independence from the Soviet Union"
        ]
        case (3, 12): return [
            "538: Vitiges, king of the Ostrogoths, ends his siege of Rome",
            "1888: The Great Blizzard of 1888 begins",
            "1933: President Franklin D. Roosevelt delivers the first of his 'Fireside Chats'",
            "2003: Elizabeth Smart is found alive after being kidnapped nine months earlier"
        ]
        case (3, 13): return [
            "624: The Battle of Badr takes place",
            "1639: Harvard College is named for clergyman John Harvard",
            "1881: Alexander II of Russia is assassinated",
            "1997: The Phoenix Lights are observed over Phoenix, Arizona"
        ]
        case (3, 14): return [
            "44 BCE: Julius Caesar is assassinated by Roman senators",
            "1794: Eli Whitney is granted a patent for the cotton gin",
            "1879: Albert Einstein is born in Ulm, Germany",
            "1995: Norman Thagard becomes the first American to ride to space on a Russian rocket"
        ]
        case (3, 15): return [
            "44 BCE: Julius Caesar is assassinated by Roman senators",
            "1493: Christopher Columbus returns to Spain after his first voyage to the Americas",
            "1917: Tsar Nicholas II of Russia abdicates the throne",
            "1985: The first domain name (symbolics.com) is registered"
        ]
        case (3, 16): return [
            "597 BCE: Babylonians capture Jerusalem",
            "1521: Ferdinand Magellan reaches the Philippines",
            "1802: The United States Military Academy is established at West Point",
            "1968: The My Lai Massacre occurs during the Vietnam War"
        ]
        case (3, 17): return [
            "45 BCE: Julius Caesar defeats the Pompeian forces of Titus Labienus and Pompey the Younger",
            "1776: British forces evacuate Boston",
            "1958: The United States launches the Vanguard 1 satellite",
            "2000: The dot-com bubble peaks with the NASDAQ reaching 5,048.62"
        ]
        case (3, 18): return [
            "37: Roman Emperor Caligula accepts the titles of the Principate",
            "1766: The Stamp Act is repealed",
            "1925: The Tri-State Tornado kills 695 people",
            "1965: Cosmonaut Alexei Leonov becomes the first person to walk in space"
        ]
        case (3, 19): return [
            "1279: A Mongolian victory in the Battle of Yamen ends the Song dynasty",
            "1915: Pluto is photographed for the first time",
            "1945: Adolf Hitler orders the destruction of German industry",
            "2003: The United States begins Operation Iraqi Freedom"
        ]
        case (3, 20): return [
            "235: Maximinus Thrax is proclaimed Emperor",
            "1602: The Dutch East India Company is established",
            "1852: Harriet Beecher Stowe's 'Uncle Tom's Cabin' is published",
            "2003: The United States begins Operation Iraqi Freedom"
        ]
        case (3, 21): return [
            "630: Emperor Heraclius restores the True Cross to Jerusalem",
            "1804: The French civil code is adopted",
            "1965: Martin Luther King Jr. leads 3,200 people on a civil rights march",
            "2006: Twitter is founded"
        ]
        case (3, 22): return [
            "238: Gordian I and his son Gordian II are proclaimed Roman Emperors",
            "1622: The Jamestown massacre occurs",
            "1945: The Arab League is founded",
            "1995: Cosmonaut Valeri Polyakov returns to Earth after 437 days in space"
        ]
        case (3, 23): return [
            "1400: The Trần dynasty of Vietnam ends",
            "1775: Patrick Henry delivers his 'Give me liberty or give me death' speech",
            "1919: Benito Mussolini founds the Fascist movement in Italy",
            "1983: President Ronald Reagan proposes the Strategic Defense Initiative"
        ]
        case (3, 24): return [
            "1401: Mongol emperor Timur sacks Damascus",
            "1882: Robert Koch announces the discovery of the tuberculosis bacterium",
            "1934: The Tydings-McDuffie Act is passed",
            "1989: The Exxon Valdez oil spill occurs in Prince William Sound"
        ]
        case (3, 25): return [
            "421: Venice is founded",
            "1306: Robert the Bruce becomes King of Scotland",
            "1911: The Triangle Shirtwaist Factory fire kills 146 people",
            "1975: King Faisal of Saudi Arabia is assassinated"
        ]
        case (3, 26): return [
            "1027: Pope John XIX crowns Conrad II as Holy Roman Emperor",
            "1827: Ludwig van Beethoven dies",
            "1953: Jonas Salk announces the polio vaccine",
            "1979: The Camp David Accords are signed"
        ]
        case (3, 27): return [
            "1309: Pope Clement V imposes excommunication and interdiction on Venice",
            "1794: The United States Navy is established",
            "1964: The Good Friday earthquake strikes Alaska",
            "1998: The FDA approves Viagra"
        ]
        case (3, 28): return [
            "37: Roman Emperor Caligula accepts the titles of the Principate",
            "1776: Juan Bautista de Anza finds the site for the Presidio of San Francisco",
            "1979: The Three Mile Island nuclear accident occurs",
            "2005: The 2005 Sumatra earthquake occurs"
        ]
        case (3, 29): return [
            "1461: The Battle of Towton takes place",
            "1849: The United Kingdom annexes the Punjab",
            "1973: The last United States combat troops leave South Vietnam",
            "2004: Bulgaria, Estonia, Latvia, Lithuania, Romania, Slovakia, and Slovenia join NATO"
        ]
        case (3, 30): return [
            "240 BCE: The first recorded perihelion passage of Halley's Comet",
            "1856: The Treaty of Paris ends the Crimean War",
            "1981: President Ronald Reagan is shot by John Hinckley Jr.",
            "2009: Twelve gunmen attack various locations in Mumbai"
        ]
                 case (3, 31): return [
             "307: After divorcing his wife Minervina, Constantine marries Fausta",
             "1492: Queen Isabella of Castile issues the Alhambra Decree",
             "1889: The Eiffel Tower is officially opened",
             "1991: The Warsaw Pact is dissolved"
         ]
         case (4, 1): return [
             "286: Emperor Diocletian elevates his general Maximian to co-emperor",
             "1572: The Sea Beggars capture Brielle from the Spanish",
             "1918: The Royal Air Force is formed",
             "1976: Apple Computer Company is formed by Steve Jobs and Steve Wozniak"
         ]
         case (4, 2): return [
             "1513: Juan Ponce de León lands in Florida",
             "1792: The Coinage Act is passed, establishing the United States Mint",
             "1917: President Woodrow Wilson asks Congress to declare war on Germany",
             "1982: Argentina invades the Falkland Islands"
         ]
         case (4, 3): return [
             "1043: Edward the Confessor is crowned King of England",
             "1860: The Pony Express begins its first run",
             "1948: President Harry S. Truman signs the Marshall Plan",
             "1973: The first handheld mobile phone call is made"
         ]
         case (4, 4): return [
             "1581: Francis Drake completes his circumnavigation of the world",
             "1818: Congress adopts the flag of the United States",
             "1949: The North Atlantic Treaty Organization (NATO) is established",
             "1968: Martin Luther King Jr. is assassinated in Memphis, Tennessee"
         ]
         case (4, 5): return [
             "823: Lothair I is crowned King of Italy",
             "1614: Pocahontas marries John Rolfe",
             "1792: President George Washington uses his first veto",
             "1951: Julius and Ethel Rosenberg are sentenced to death"
         ]
         case (4, 6): return [
             "648: King Oswine of Deira is murdered",
             "1199: King Richard I of England dies from an infection",
             "1909: Robert Peary and Matthew Henson reach the North Pole",
             "1994: The Rwandan genocide begins"
         ]
         case (4, 7): return [
             "451: Attila the Hun sacks the city of Metz",
             "1141: Empress Matilda becomes the first female ruler of England",
             "1927: The first long-distance public television broadcast",
             "2001: NASA's Mars Odyssey spacecraft is launched"
         ]
         case (4, 8): return [
             "217: Roman Emperor Caracalla is assassinated",
             "1904: The Entente Cordiale is signed between Britain and France",
             "1946: The League of Nations dissolves",
             "1994: Kurt Cobain is found dead in his Seattle home"
         ]
         case (4, 9): return [
             "1241: The Battle of Legnica takes place",
             "1865: Confederate General Robert E. Lee surrenders to Union General Ulysses S. Grant",
             "1940: Germany invades Denmark and Norway",
             "2003: Baghdad falls to American forces"
         ]
         case (4, 10): return [
             "428: Nestorius becomes Patriarch of Constantinople",
             "1606: The Virginia Company of London is established",
             "1815: The Mount Tambora volcano begins a three-month-long eruption",
             "1972: The Apollo 16 mission is launched"
         ]
         case (4, 11): return [
             "491: Flavius Anastasius becomes Byzantine Emperor",
             "1689: William III and Mary II are crowned as joint sovereigns",
             "1945: American forces liberate the Buchenwald concentration camp",
             "1970: Apollo 13 is launched"
         ]
         case (4, 12): return [
             "467: Anthemius is proclaimed Western Roman Emperor",
             "1606: The Union Flag is adopted as the flag of Great Britain",
             "1861: The American Civil War begins with the attack on Fort Sumter",
             "1961: Yuri Gagarin becomes the first human to travel into space"
         ]
         case (4, 13): return [
             "1111: Henry V is crowned Holy Roman Emperor",
             "1742: George Frideric Handel's 'Messiah' premieres in Dublin",
             "1943: The Katyn massacre is discovered",
             "1970: Apollo 13's oxygen tank explodes"
         ]
         case (4, 14): return [
             "69: Vitellius becomes Roman Emperor",
             "1865: President Abraham Lincoln is shot by John Wilkes Booth",
             "1912: The RMS Titanic hits an iceberg",
             "1981: The first Space Shuttle, Columbia, returns to Earth"
         ]
         case (4, 15): return [
             "1912: The RMS Titanic sinks in the North Atlantic Ocean",
             "1865: President Abraham Lincoln dies after being shot the previous night",
             "1947: Jackie Robinson becomes the first African American to play in Major League Baseball",
             "1989: The Hillsborough disaster occurs during a football match in Sheffield, England"
         ]
         case (4, 16): return [
             "73: Masada falls to the Romans",
             "1746: The Battle of Culloden takes place",
             "1947: Bernard Baruch coins the term 'Cold War'",
             "2007: The Virginia Tech massacre occurs"
         ]
         case (4, 17): return [
             "69: After the First Battle of Bedriacum, Vitellius becomes Roman Emperor",
             "1492: Spain and Christopher Columbus sign the Capitulations of Santa Fe",
             "1961: The Bay of Pigs Invasion begins",
             "1989: The Tiananmen Square protests begin"
         ]
         case (4, 18): return [
             "796: King Æthelred I of Northumbria is murdered",
             "1775: Paul Revere makes his famous midnight ride",
             "1906: The San Francisco earthquake occurs",
             "1983: The U.S. Embassy in Beirut is bombed"
         ]
         case (4, 19): return [
             "1012: Martyrdom of Ælfheah in Greenwich, London",
             "1775: The American Revolutionary War begins",
             "1943: The Warsaw Ghetto Uprising begins",
             "1995: The Oklahoma City bombing occurs"
         ]
         case (4, 20): return [
             "1303: The University of Rome La Sapienza is established",
             "1653: Oliver Cromwell dissolves the Rump Parliament",
             "1889: Adolf Hitler is born in Braunau am Inn, Austria",
             "1999: The Columbine High School massacre occurs"
         ]
         case (4, 21): return [
             "753 BCE: Romulus and Remus found Rome",
             "1509: Henry VIII becomes King of England",
             "1918: Manfred von Richthofen, the 'Red Baron', is shot down",
             "1989: Tiananmen Square protests are violently suppressed"
         ]
         case (4, 22): return [
             "1500: Portuguese explorer Pedro Álvares Cabral discovers Brazil",
             "1864: The U.S. Congress passes the Coinage Act",
             "1915: The Second Battle of Ypres begins",
             "1970: The first Earth Day is celebrated"
         ]
         case (4, 23): return [
             "1014: The Battle of Clontarf takes place",
             "1564: William Shakespeare is born",
             "1945: Hermann Göring is captured by the United States Army",
             "1985: Coca-Cola introduces 'New Coke'"
         ]
         case (4, 24): return [
             "1184 BCE: The Greeks enter Troy using the Trojan Horse",
             "1800: The Library of Congress is established",
             "1915: The Armenian Genocide begins",
             "1990: The Hubble Space Telescope is launched"
         ]
         case (4, 25): return [
             "404 BCE: Peloponnesian War ends",
             "1607: The first permanent English settlement in America is established at Jamestown",
             "1945: American and Soviet forces meet at the Elbe River",
             "1983: Pioneer 10 crosses the orbit of Pluto"
         ]
         case (4, 26): return [
             "1336: Francesco Petrarca ascends Mont Ventoux",
             "1607: English colonists make landfall at Cape Henry, Virginia",
             "1937: The German Condor Legion bombs Guernica",
             "1986: The Chernobyl disaster occurs"
         ]
         case (4, 27): return [
             "33: The crucifixion of Jesus Christ",
             "1521: Ferdinand Magellan is killed in the Philippines",
             "1865: The steamboat Sultana explodes, killing 1,700 people",
             "2006: Construction begins on the Freedom Tower"
         ]
         case (4, 28): return [
             "224: The Battle of Hormozdgan takes place",
             "1789: The mutiny on the Bounty occurs",
             "1945: Benito Mussolini is executed",
             "2001: Dennis Tito becomes the first space tourist"
         ]
         case (4, 29): return [
             "1429: Joan of Arc arrives to relieve the Siege of Orléans",
             "1862: New Orleans falls to Union forces",
             "1945: American forces liberate the Dachau concentration camp",
             "1992: The Los Angeles riots begin"
         ]
         case (4, 30): return [
             "311: The Edict of Toleration is issued by Galerius",
             "1789: George Washington is inaugurated as the first President of the United States",
             "1945: Adolf Hitler and Eva Braun commit suicide",
             "1993: The World Wide Web is made available to the public"
         ]
         case (5, 1): return [
             "1886: The Haymarket affair occurs in Chicago, leading to the establishment of International Workers' Day",
             "1931: The Empire State Building opens in New York City",
             "1960: A U-2 spy plane piloted by Francis Gary Powers is shot down over the Soviet Union",
             "2004: Ten new countries join the European Union"
         ]
         case (5, 2): return [
             "1194: King Richard I of England gives Portsmouth its first Royal Charter",
             "1670: King Charles II of England grants a permanent charter to the Hudson's Bay Company",
             "1945: The Soviet Union announces the fall of Berlin",
             "2011: Osama bin Laden is killed by U.S. Navy SEALs"
         ]
         case (5, 3): return [
             "1481: The largest of three earthquakes strikes the island of Rhodes",
             "1791: The Polish Constitution of 1791 is proclaimed",
             "1937: Gone with the Wind wins the Pulitzer Prize",
             "1999: A tornado outbreak kills 46 people in Oklahoma"
         ]
         case (5, 4): return [
             "1256: The Augustinian monastic order is constituted",
             "1493: Pope Alexander VI divides the New World between Spain and Portugal",
             "1970: The Kent State shootings occur",
             "1989: The Tiananmen Square protests begin"
         ]
         case (5, 5): return [
             "553: The Second Council of Constantinople begins",
             "1821: Napoleon Bonaparte dies in exile on Saint Helena",
             "1945: World War II ends in Europe",
             "1961: Alan Shepard becomes the first American in space"
         ]
         case (5, 6): return [
             "1527: The Sack of Rome begins",
             "1882: The Chinese Exclusion Act is signed into law",
             "1937: The Hindenburg disaster occurs",
             "1994: The Channel Tunnel opens"
         ]
         case (5, 7): return [
             "558: The dome of the Hagia Sophia collapses",
             "1824: Beethoven's Ninth Symphony premieres",
             "1945: Germany surrenders to the Allies",
             "1992: The Space Shuttle Endeavour is launched on its first mission"
         ]
         case (5, 8): return [
             "589: Reccared summons the Third Council of Toledo",
             "1886: Coca-Cola is first sold to the public",
             "1945: Victory in Europe Day is celebrated",
             "1980: The World Health Organization declares smallpox eradicated"
         ]
         case (5, 9): return [
             "328: Athanasius is elected Patriarch of Alexandria",
             "1671: Thomas Blood attempts to steal the Crown Jewels",
             "1950: Robert Schuman presents his proposal for a European Coal and Steel Community",
             "2001: Ghana's former President Jerry Rawlings visits the White House"
         ]
         case (5, 10): return [
             "28 BCE: A solar eclipse occurs",
             "1775: The Second Continental Congress meets",
             "1869: The First Transcontinental Railroad is completed",
             "1994: Nelson Mandela is inaugurated as President of South Africa"
         ]
         case (5, 11): return [
             "330: Constantinople is consecrated",
             "1812: Prime Minister Spencer Perceval is assassinated",
             "1949: Siam officially changes its name to Thailand",
             "1997: Deep Blue defeats Garry Kasparov in chess"
         ]
         case (5, 12): return [
             "254: Pope Stephen I succeeds Pope Lucius I",
             "1780: Charleston, South Carolina falls to British forces",
             "1949: The Soviet Union lifts its blockade of Berlin",
             "2008: A 7.9 magnitude earthquake strikes Sichuan, China"
         ]
         case (5, 13): return [
             "609: Pope Boniface IV dedicates the Pantheon in Rome",
             "1607: Jamestown, Virginia is settled",
             "1940: Winston Churchill delivers his 'Blood, toil, tears, and sweat' speech",
             "1981: Pope John Paul II is shot in St. Peter's Square"
         ]
         case (5, 14): return [
             "1264: The Battle of Lewes takes place",
             "1796: Edward Jenner administers the first smallpox vaccination",
             "1948: The State of Israel is established",
             "1973: Skylab, the United States' first space station, is launched"
         ]
         case (5, 15): return [
             "495: Pope Gelasius I succeeds Pope Felix III",
             "1602: Bartholomew Gosnold becomes the first European to see Cape Cod",
             "1948: The Arab-Israeli War begins",
             "1991: Edith Cresson becomes France's first female Prime Minister"
         ]
         case (5, 16): return [
             "218: Julia Maesa, aunt of the assassinated Caracalla, is banished to her home in Syria",
             "1770: Marie Antoinette marries Louis-Auguste",
             "1929: The first Academy Awards ceremony is held",
             "1975: Junko Tabei becomes the first woman to reach the summit of Mount Everest"
         ]
         case (5, 17): return [
             "352: Liberius becomes Pope",
             "1792: The New York Stock Exchange is founded",
             "1954: The Supreme Court decides Brown v. Board of Education",
             "2004: Massachusetts becomes the first U.S. state to legalize same-sex marriage"
         ]
         case (5, 18): return [
             "332: Emperor Constantine the Great announces free distributions of food to the citizens in Constantinople",
             "1803: The United Kingdom declares war on France",
             "1980: Mount St. Helens erupts",
             "1991: Northern Somalia declares independence"
         ]
         case (5, 19): return [
             "715: Pope Gregory II is elected",
             "1536: Anne Boleyn is executed",
             "1962: Marilyn Monroe sings 'Happy Birthday' to President John F. Kennedy",
             "1991: Croatia votes for independence"
         ]
         case (5, 20): return [
             "325: The First Council of Nicaea begins",
             "1506: Christopher Columbus dies",
             "1927: Charles Lindbergh begins the first solo nonstop transatlantic flight",
             "1989: The Chinese government declares martial law in Beijing"
         ]
         case (5, 21): return [
             "293: Roman Emperors Diocletian and Maximian appoint Galerius as Caesar",
             "1502: Portuguese explorer João da Nova discovers the island of Saint Helena",
             "1881: The American Red Cross is established",
             "1927: Charles Lindbergh completes the first solo transatlantic flight"
         ]
         case (5, 22): return [
             "337: Constantine the Great dies",
             "1807: The Embargo Act of 1807 is passed",
             "1960: The Great Chilean earthquake occurs",
             "1990: North and South Yemen merge to form the Republic of Yemen"
         ]
         case (5, 23): return [
             "1430: Joan of Arc is captured by the Burgundians",
             "1701: Captain William Kidd is hanged for piracy",
             "1934: Bonnie and Clyde are ambushed and killed",
             "1995: The first version of the Java programming language is released"
         ]
         case (5, 24): return [
             "1218: The Fifth Crusade leaves Acre for Egypt",
             "1844: Samuel Morse sends the first telegraph message",
             "1930: Amy Johnson lands in Darwin, Australia, becoming the first woman to fly solo from England to Australia",
             "2000: Israel withdraws from southern Lebanon"
         ]
         case (5, 25): return [
             "1085: Alfonso VI of Castile takes Toledo, Spain from the Moors",
             "1787: The Constitutional Convention opens in Philadelphia",
             "1961: President John F. Kennedy announces the goal of landing a man on the Moon",
             "1977: Star Wars is released in theaters"
         ]
         case (5, 26): return [
             "451: The Battle of Avarayr takes place",
             "1637: The Pequot War ends",
             "1940: The Dunkirk evacuation begins",
             "2004: The United States Army veteran Memorial is dedicated"
         ]
         case (5, 27): return [
             "1703: Saint Petersburg is founded by Peter the Great",
             "1937: The Golden Gate Bridge opens",
             "1969: Construction of the Walt Disney World Resort begins",
             "1999: The International Criminal Tribunal for the former Yugoslavia indicts Slobodan Milošević"
         ]
         case (5, 28): return [
             "585 BCE: A solar eclipse occurs, as predicted by Thales",
             "1588: The Spanish Armada sets sail from Lisbon",
             "1937: The Golden Gate Bridge opens to pedestrian traffic",
             "1998: Pakistan conducts its first nuclear tests"
         ]
         case (5, 29): return [
             "363: Roman Emperor Julian defeats the Sassanid army",
             "1453: Constantinople falls to the Ottoman Empire",
             "1953: Edmund Hillary and Tenzing Norgay reach the summit of Mount Everest",
             "1999: Olusegun Obasanjo becomes Nigeria's first elected president"
         ]
         case (5, 30): return [
             "1431: Joan of Arc is burned at the stake",
             "1806: Andrew Jackson kills Charles Dickinson in a duel",
             "1922: The Lincoln Memorial is dedicated",
             "1989: The Tiananmen Square protests are violently suppressed"
         ]
         case (5, 31): return [
             "1279 BCE: Ramesses II becomes Pharaoh of Egypt",
             "1859: Big Ben begins keeping time",
             "1916: The Battle of Jutland begins",
             "2005: Vanity Fair reveals that Mark Felt was 'Deep Throat'"
         ]
         case (6, 1): return [
             "193: Roman Emperor Didius Julianus is assassinated",
             "1495: Friar John Cor records the first known batch of Scotch whisky",
             "1813: James Lawrence, mortally wounded, gives his final order: 'Don't give up the ship!'",
             "1980: CNN begins broadcasting"
         ]
         case (6, 2): return [
             "455: The Vandals enter Rome and plunder the city for two weeks",
             "1774: The Quartering Act is enacted",
             "1953: Queen Elizabeth II is crowned",
             "1995: The United States Air Force Academy graduates its first female cadets"
         ]
         case (6, 3): return [
             "350: Roman usurper Nepotianus is defeated and killed",
             "1539: Hernando de Soto claims Florida for Spain",
             "1940: The Dunkirk evacuation ends",
             "1989: The Chinese government violently suppresses the Tiananmen Square protests"
         ]
         case (6, 4): return [
             "781 BCE: A solar eclipse is recorded in China",
             "1039: Conrad II, Holy Roman Emperor, dies",
             "1940: The Dunkirk evacuation ends",
             "1989: The Tiananmen Square massacre occurs"
         ]
         case (6, 5): return [
             "70: Titus and his Roman legions breach the middle wall of Jerusalem",
             "1257: Kraków, Poland receives city rights",
             "1967: The Six-Day War begins",
             "2004: Ronald Reagan dies"
         ]
         case (6, 6): return [
             "1944: D-Day - Allied forces invade Normandy during World War II",
             "1844: The Young Men's Christian Association (YMCA) is founded in London",
             "1984: Tetris is released by Russian game designer Alexey Pajitnov",
             "2012: The transit of Venus occurs, a rare astronomical event"
         ]
         case (6, 7): return [
             "421: Emperor Theodosius II marries Aelia Eudocia",
             "1494: Spain and Portugal sign the Treaty of Tordesillas",
             "1942: The Battle of Midway ends",
             "2006: The United Nations Security Council votes to end the sanctions against Iraq"
         ]
         case (6, 8): return [
             "218: Battle of Antioch",
             "1783: The volcano Laki begins an eight-month eruption",
             "1949: George Orwell's Nineteen Eighty-Four is published",
             "2004: The first transit of Venus since 1882 occurs"
         ]
         case (6, 9): return [
             "68: Roman Emperor Nero commits suicide",
             "1534: Jacques Cartier becomes the first European to discover the Saint Lawrence River",
             "1944: The Soviet Union begins the Vyborg–Petrozavodsk Offensive",
             "2008: The 2008 Canadian Grand Prix takes place"
         ]
         case (6, 10): return [
             "1190: Frederick I Barbarossa drowns in the Saleph River",
             "1692: Bridget Bishop is hanged at Gallows Hill near Salem, Massachusetts",
             "1940: Norway surrenders to German forces",
             "2003: The Spirit rover is launched"
         ]
         case (6, 11): return [
             "1184 BCE: Troy is sacked and burned",
             "1509: Henry VIII of England marries Catherine of Aragon",
             "1942: The United States agrees to send Lend-Lease aid to the Soviet Union",
             "2001: Timothy McVeigh is executed"
         ]
         case (6, 12): return [
             "910: The Hungarians defeat the East Frankish army",
             "1665: England installs a municipal government in New York City",
             "1942: Anne Frank receives a diary for her thirteenth birthday",
             "1987: President Ronald Reagan challenges Mikhail Gorbachev to tear down the Berlin Wall"
         ]
         case (6, 13): return [
             "313: The Edict of Milan is posted in Nicomedia",
             "1381: The Peasants' Revolt begins",
             "1966: The Supreme Court rules in Miranda v. Arizona",
             "1983: Pioneer 10 becomes the first man-made object to leave the Solar System"
         ]
         case (6, 14): return [
             "1158: Munich is founded by Henry the Lion",
             "1777: The Stars and Stripes is adopted by Congress as the Flag of the United States",
             "1940: Paris falls under German occupation",
             "1982: The Falklands War ends"
         ]
         case (6, 15): return [
             "763 BCE: Assyrians record a solar eclipse",
             "1215: King John of England puts his seal on the Magna Carta",
             "1944: The Battle of Saipan begins",
             "1996: The Manchester bombing occurs"
         ]
         case (6, 16): return [
             "1487: The Battle of Stoke Field takes place",
             "1903: The Ford Motor Company is incorporated",
             "1963: Valentina Tereshkova becomes the first woman in space",
             "2000: The United States and North Korea sign the Agreed Framework"
         ]
         case (6, 17): return [
             "1462: Vlad III the Impaler attempts to assassinate Mehmed II",
             "1775: The Battle of Bunker Hill takes place",
             "1944: Iceland declares independence from Denmark",
             "1994: O.J. Simpson leads police on a low-speed chase"
         ]
         case (6, 18): return [
             "618: Li Yuan becomes Emperor Gaozu of Tang",
             "1812: The War of 1812 begins",
             "1940: Charles de Gaulle delivers his Appeal of 18 June",
             "1983: Sally Ride becomes the first American woman in space"
         ]
         case (6, 19): return [
             "325: The original Nicene Creed is adopted",
             "1865: Juneteenth is celebrated for the first time",
             "1944: The Battle of the Philippine Sea begins",
             "1987: The Supreme Court rules that the death penalty is constitutional"
         ]
         case (6, 20): return [
             "451: The Battle of Chalons takes place",
             "1782: The U.S. Congress adopts the Great Seal of the United States",
             "1944: The Battle of the Philippine Sea ends",
             "1990: Asteroid Eureka is discovered"
         ]
         case (6, 21): return [
             "217 BCE: The Battle of Raphia takes place",
             "1582: Sengoku period: Oda Nobunaga is forced to commit suicide",
             "1945: The Battle of Okinawa ends",
             "2004: SpaceShipOne becomes the first privately funded spaceplane to achieve spaceflight"
         ]
         case (6, 22): return [
             "168 BCE: Battle of Pydna",
             "1633: Galileo Galilei is forced to recant his heliocentric view",
             "1941: Germany invades the Soviet Union",
             "1990: Checkpoint Charlie is dismantled"
         ]
         case (6, 23): return [
             "229: Sun Quan proclaims himself emperor of Eastern Wu",
             "1314: The Battle of Bannockburn begins",
             "1940: Adolf Hitler takes a tour of Paris",
             "1996: Nintendo releases the Nintendo 64 in Japan"
         ]
         case (6, 24): return [
             "109: Roman Emperor Trajan inaugurates the Aqua Traiana",
             "1314: The Battle of Bannockburn ends",
             "1947: Kenneth Arnold makes the first widely reported UFO sighting",
             "1995: The Rugby World Cup begins"
         ]
         case (6, 25): return [
             "841: The Battle of Fontenay-en-Puisaye takes place",
             "1876: The Battle of the Little Bighorn occurs",
             "1950: The Korean War begins",
             "1997: The Russian Progress M-34 spacecraft collides with the Mir space station"
         ]
         case (6, 26): return [
             "363: Roman Emperor Julian is killed during the retreat from the Sassanid Empire",
             "1409: The Council of Pisa opens",
             "1945: The United Nations Charter is signed",
             "1997: The first Harry Potter book is published"
         ]
         case (6, 27): return [
             "678: Saint Agatho begins his reign as Catholic Pope",
             "1844: Joseph Smith, founder of the Latter Day Saint movement, is killed",
             "1950: The United States decides to send troops to fight in the Korean War",
             "1991: Slovenia declares independence from Yugoslavia"
         ]
         case (6, 28): return [
             "1098: The Crusaders defeat Kerbogha of Mosul",
             "1776: The Battle of Sullivan's Island takes place",
             "1914: Archduke Franz Ferdinand is assassinated",
             "1997: Mike Tyson bites Evander Holyfield's ear"
         ]
         case (6, 29): return [
             "226: Cao Pi dies after an illness",
             "1613: The Globe Theatre burns down",
             "1956: The Federal-Aid Highway Act is signed",
             "2007: Apple Inc. releases the first iPhone"
         ]
         case (6, 30): return [
             "296: Pope Marcellinus begins his papacy",
             "1520: Spanish conquistadors are expelled from Tenochtitlan",
             "1934: The Night of the Long Knives occurs",
             "1997: The United Kingdom transfers sovereignty over Hong Kong to China"
         ]
         case (7, 1): return [
             "69: The Batavian rebellion begins",
             "1867: The Dominion of Canada is established",
             "1963: The ZIP code is introduced in the United States",
             "1997: The United Kingdom transfers sovereignty over Hong Kong to China"
         ]
         case (7, 2): return [
             "437: Emperor Valentinian III begins his reign over the Western Roman Empire",
             "1776: The Continental Congress votes for independence from Great Britain",
             "1964: President Lyndon B. Johnson signs the Civil Rights Act",
             "2000: Vicente Fox becomes the first opposition candidate to win the Mexican presidency"
         ]
         case (7, 3): return [
             "324: The Battle of Adrianople takes place",
             "1775: George Washington takes command of the Continental Army",
             "1863: The Battle of Gettysburg ends",
             "1988: The USS Vincennes shoots down Iran Air Flight 655"
         ]
         case (7, 4): return [
             "1776: The United States Declaration of Independence is adopted by the Continental Congress",
             "1802: The United States Military Academy opens at West Point",
             "1863: The Siege of Vicksburg ends during the American Civil War",
             "1939: Lou Gehrig delivers his 'Luckiest Man' speech at Yankee Stadium"
         ]
         case (7, 5): return [
             "328: The official opening of Constantine's Bridge",
             "1687: Isaac Newton publishes Philosophiæ Naturalis Principia Mathematica",
             "1946: The bikini is introduced in Paris",
             "1996: Dolly the sheep becomes the first mammal cloned from an adult cell"
         ]
         case (7, 6): return [
             "371 BCE: The Battle of Leuctra takes place",
             "1415: Jan Hus is burned at the stake",
             "1885: Louis Pasteur successfully tests his rabies vaccine",
             "1947: The AK-47 goes into production in the Soviet Union"
         ]
         case (7, 7): return [
             "1124: Tyre falls to the Crusaders",
             "1456: Joan of Arc is acquitted of heresy",
             "1898: The United States annexes Hawaii",
             "2005: A series of bombings in London kills 52 people"
         ]
         case (7, 8): return [
             "1099: The First Crusade reaches Jerusalem",
             "1497: Vasco da Gama sets sail on the first direct European voyage to India",
             "1889: The Wall Street Journal is first published",
             "2011: The Space Shuttle Atlantis launches on the final mission of the Space Shuttle program"
         ]
         case (7, 9): return [
             "455: Avitus is proclaimed Western Roman Emperor",
             "1755: The French and Indian War begins",
             "1944: The Battle of Saipan ends",
             "2011: South Sudan declares independence"
         ]
         case (7, 10): return [
             "48 BCE: The Battle of Dyrrhachium takes place",
             "1584: William I of Orange is assassinated",
             "1925: The Scopes Trial begins",
             "1962: Telstar, the world's first communications satellite, is launched"
         ]
         case (7, 11): return [
             "472: After being besieged in Rome by his own generals, Western Roman Emperor Anthemius is captured",
             "1798: The United States Marine Corps is established",
             "1960: To Kill a Mockingbird is published",
             "1995: The Srebrenica massacre begins"
         ]
         case (7, 12): return [
             "1191: The Third Crusade: Saladin's garrison surrenders to Philip Augustus",
             "1690: The Battle of the Boyne takes place",
             "1943: The Battle of Kursk begins",
             "2006: Hezbollah initiates the 2006 Lebanon War"
         ]
         case (7, 13): return [
             "1174: William I of Scotland is captured by the English",
             "1793: Charlotte Corday assassinates Jean-Paul Marat",
             "1863: The New York City draft riots begin",
             "1985: Live Aid concerts are held in London and Philadelphia"
         ]
         case (7, 14): return [
             "1223: Louis VIII becomes King of France",
             "1789: The Storming of the Bastille occurs",
             "1881: Billy the Kid is shot and killed",
             "2015: NASA's New Horizons spacecraft performs the first flyby of Pluto"
         ]
         case (7, 15): return [
             "1099: The First Crusade captures Jerusalem",
             "1799: The Rosetta Stone is found",
             "1918: The Second Battle of the Marne begins",
             "2006: Twitter is launched"
         ]
         case (7, 16): return [
             "622: The beginning of the Islamic calendar",
             "1790: The District of Columbia is established",
             "1945: The Trinity test, the first detonation of a nuclear weapon",
             "1969: Apollo 11 launches"
         ]
         case (7, 17): return [
             "1203: The Fourth Crusade captures Constantinople",
             "1762: Catherine II becomes Empress of Russia",
             "1955: Disneyland opens in Anaheim, California",
             "1996: TWA Flight 800 crashes off the coast of Long Island"
         ]
         case (7, 18): return [
             "64: The Great Fire of Rome begins",
             "1290: King Edward I of England issues the Edict of Expulsion",
             "1925: Adolf Hitler publishes Mein Kampf",
             "1976: Nadia Comăneci becomes the first person to score a perfect 10 in Olympic gymnastics"
         ]
         case (7, 19): return [
             "711: The Battle of Guadalete takes place",
             "1799: The Rosetta Stone is found",
             "1943: Rome is bombed by the Allies",
             "1989: United Airlines Flight 232 crashes in Sioux City, Iowa"
         ]
         case (7, 20): return [
             "356 BCE: Alexander the Great is born",
             "1810: Colombia declares independence from Spain",
             "1969: Apollo 11 lands on the Moon",
             "2012: A mass shooting occurs at a movie theater in Aurora, Colorado"
         ]
         case (7, 21): return [
             "356 BCE: The Temple of Artemis in Ephesus is destroyed by arson",
             "1861: The First Battle of Bull Run takes place",
             "1969: Neil Armstrong becomes the first human to walk on the Moon",
             "2011: The final Space Shuttle mission ends"
         ]
         case (7, 22): return [
             "838: The Battle of Anzen takes place",
             "1587: Roanoke Colony is established",
             "1933: Wiley Post becomes the first person to fly solo around the world",
             "2011: Anders Behring Breivik kills 77 people in Norway"
         ]
         case (7, 23): return [
             "1632: Three hundred colonists bound for New France depart from Dieppe, France",
             "1829: William Austin Burt patents the typographer",
             "1952: The European Coal and Steel Community is established",
             "1995: Comet Hale-Bopp is discovered"
         ]
         case (7, 24): return [
             "1132: The Battle of Nocera takes place",
             "1567: Mary, Queen of Scots is forced to abdicate",
             "1911: Hiram Bingham III re-discovers Machu Picchu",
             "1969: Apollo 11 returns to Earth"
         ]
         case (7, 25): return [
             "306: Constantine I is proclaimed Roman Emperor",
             "1593: Henry IV of France publicly converts from Protestantism to Roman Catholicism",
             "1946: The United States detonates an atomic bomb at Bikini Atoll",
             "2000: Air France Flight 4590 crashes, killing 113 people"
         ]
         case (7, 26): return [
             "657: The Battle of Siffin takes place",
             "1775: Benjamin Franklin becomes the first Postmaster General of the United States",
             "1945: The Potsdam Declaration is issued",
             "1956: The Italian ocean liner SS Andrea Doria sinks"
         ]
         case (7, 27): return [
             "1214: The Battle of Bouvines takes place",
             "1694: The Bank of England is established",
             "1940: Bugs Bunny makes his debut in 'A Wild Hare'",
             "1996: The Centennial Olympic Park bombing occurs"
         ]
         case (7, 28): return [
             "1364: The Battle of Cascina takes place",
             "1794: Maximilien Robespierre is executed",
             "1914: World War I begins",
             "1976: The Tangshan earthquake kills 242,000 people"
         ]
         case (7, 29): return [
             "587: The Siege of Jerusalem ends",
             "1588: The Spanish Armada is defeated",
             "1958: NASA is established",
             "1981: Prince Charles marries Lady Diana Spencer"
         ]
         case (7, 30): return [
             "762: The city of Baghdad is founded",
             "1619: The first representative assembly in the Americas meets",
             "1945: The USS Indianapolis is torpedoed",
             "2003: The last Volkswagen Beetle rolls off the assembly line"
         ]
         case (7, 31): return [
             "781: The oldest recorded eruption of Mount Fuji",
             "1498: Christopher Columbus becomes the first European to visit the island of Trinidad",
             "1941: The Holocaust: Under instructions from Adolf Hitler, Nazi official Hermann Göring orders SS General Reinhard Heydrich to 'submit to me as soon as possible a general plan of the administrative material and financial measures necessary for carrying out the desired Final Solution of the Jewish question'",
             "1991: The Strategic Arms Reduction Treaty is signed"
         ]
         case (8, 1): return [
             "30 BCE: Octavian enters Alexandria, Egypt",
             "1774: Joseph Priestley discovers oxygen",
             "1944: Anne Frank makes the last entry in her diary",
             "1981: MTV begins broadcasting"
         ]
         case (8, 2): return [
             "338 BCE: The Battle of Chaeronea takes place",
             "1776: The signing of the United States Declaration of Independence begins",
             "1934: Adolf Hitler becomes Führer of Germany",
             "1990: Iraq invades Kuwait"
         ]
         case (8, 3): return [
             "8: Roman Emperor Augustus is proclaimed Pater Patriae",
             "1492: Christopher Columbus sets sail from Palos de la Frontera",
             "1914: Germany declares war on France",
             "2005: President Maumoon Abdul Gayoom survives an assassination attempt"
         ]
         case (8, 4): return [
             "70: The destruction of the Second Temple in Jerusalem",
             "1693: Dom Pérignon invents champagne",
             "1914: The United Kingdom declares war on Germany",
             "2007: NASA launches the Phoenix spacecraft"
         ]
         case (8, 5): return [
             "25: Guangwu claims the throne as Emperor of China",
             "1583: Sir Humphrey Gilbert establishes the first English colony in North America",
             "1962: Marilyn Monroe is found dead",
             "2010: The Copiapó mining accident occurs"
         ]
         case (8, 6): return [
             "1284: The Republic of Pisa is defeated in the Battle of Meloria",
             "1890: At Auburn Prison in New York, murderer William Kemmler becomes the first person to be executed by electric chair",
             "1945: The atomic bombing of Hiroshima",
             "1991: Tim Berners-Lee releases files describing his idea for the World Wide Web"
         ]
         case (8, 7): return [
             "322 BCE: The Battle of Crannon takes place",
             "1782: George Washington orders the creation of the Badge of Military Merit",
             "1947: Thor Heyerdahl's balsa wood raft, the Kon-Tiki, smashes into the reef at Raroia",
             "1998: The United States embassy bombings occur"
         ]
         case (8, 8): return [
             "1220: Sweden is defeated by Estonian tribes in the Battle of Lihula",
             "1588: The Spanish Armada is defeated",
             "1945: The Soviet Union declares war on Japan",
             "2008: The 2008 Summer Olympics open in Beijing"
         ]
         case (8, 9): return [
             "48 BCE: The Battle of Pharsalus takes place",
             "1173: Construction of the Leaning Tower of Pisa begins",
             "1945: The atomic bombing of Nagasaki",
             "1974: Richard Nixon resigns as President of the United States"
         ]
         case (8, 10): return [
             "955: The Battle of Lechfeld takes place",
             "1628: The Swedish warship Vasa sinks",
             "1945: Japan offers to surrender",
             "2003: The highest temperature ever recorded in the United Kingdom"
         ]
         case (8, 11): return [
             "3114 BCE: The Mesoamerican Long Count calendar begins",
             "1492: Pope Alexander VI succeeds Pope Innocent VIII",
             "1952: Hussein bin Talal is proclaimed King of Jordan",
             "2003: NATO takes over command of the peacekeeping force in Afghanistan"
         ]
         case (8, 12): return [
             "1099: The First Crusade ends",
             "1851: Isaac Singer is granted a patent for his sewing machine",
             "1944: The Waffen-SS massacres 560 people in Sant'Anna di Stazzema",
             "2000: The Russian submarine Kursk sinks"
         ]
         case (8, 13): return [
             "1521: Tenochtitlan falls to Hernán Cortés",
             "1704: The Battle of Blenheim takes place",
             "1961: The Berlin Wall is built",
             "2004: The 2004 Summer Olympics open in Athens"
         ]
         case (8, 14): return [
             "1040: King Duncan I is killed in battle",
             "1385: The Battle of Aljubarrota takes place",
             "1945: Japan surrenders, ending World War II",
             "2003: The Northeast blackout of 2003 occurs"
         ]
         case (8, 15): return [
             "778: The Battle of Roncevaux Pass takes place",
             "1914: The Panama Canal opens",
             "1945: Japan surrenders, ending World War II",
             "1969: The Woodstock Music & Art Fair begins"
         ]
         case (8, 16): return [
             "1328: The House of Stuart begins to rule Scotland",
             "1812: Detroit surrenders without a fight to the British Army",
             "1960: Joseph Kittinger parachutes from a balloon at 102,800 feet",
             "1987: Northwest Airlines Flight 255 crashes"
         ]
         case (8, 17): return [
             "1308: Pope Clement V pardons Jacques de Molay",
             "1807: Robert Fulton's North River Steamboat leaves New York City",
             "1943: The Allies liberate Messina, Sicily",
             "1999: A 7.4 magnitude earthquake strikes İzmit, Turkey"
         ]
         case (8, 18): return [
             "293 BCE: The oldest known Roman temple to Venus is founded",
             "1587: Virginia Dare becomes the first English child born in the Americas",
             "1920: The Nineteenth Amendment to the United States Constitution is ratified",
             "1991: The Soviet coup attempt of 1991 begins"
         ]
         case (8, 19): return [
             "43 BCE: Octavian is later considered the first Roman Emperor",
             "1692: Five people are hanged for witchcraft in Salem, Massachusetts",
             "1960: Sputnik 5 is launched",
             "1991: The Soviet coup attempt of 1991 ends"
         ]
         case (8, 20): return [
             "636: The Battle of Yarmouk begins",
             "1794: The Battle of Fallen Timbers takes place",
             "1940: Leon Trotsky is assassinated",
             "1988: The Iran-Iraq War ends"
         ]
         case (8, 21): return [
             "1192: Minamoto no Yoritomo becomes Seii Tai Shōgun",
             "1858: The Lincoln-Douglas debates begin",
             "1959: Hawaii becomes the 50th state of the United States",
             "1991: Latvia declares independence from the Soviet Union"
         ]
         case (8, 22): return [
             "1485: The Battle of Bosworth Field takes place",
             "1770: James Cook claims the eastern coast of Australia",
             "1902: Theodore Roosevelt becomes the first U.S. President to ride in an automobile",
             "1989: Nolan Ryan strikes out his 5,000th batter"
         ]
         case (8, 23): return [
             "79: Mount Vesuvius begins stirring, on the feast day of Vulcan",
             "1305: William Wallace is executed",
             "1939: The Molotov-Ribbentrop Pact is signed",
             "1990: Armenia declares independence from the Soviet Union"
         ]
         case (8, 24): return [
             "79: Mount Vesuvius erupts, destroying Pompeii",
             "410: The Visigoths sack Rome",
             "1814: British troops invade Washington, D.C.",
             "1991: Ukraine declares independence from the Soviet Union"
         ]
         case (8, 25): return [
             "357: The Battle of Strasbourg takes place",
             "1609: Galileo Galilei demonstrates his first telescope",
             "1944: Paris is liberated from German occupation",
             "1989: Voyager 2 makes its closest approach to Neptune"
         ]
         case (8, 26): return [
             "1071: The Battle of Manzikert takes place",
             "1789: The Declaration of the Rights of Man and of the Citizen is approved",
             "1920: The 19th amendment to the United States Constitution takes effect",
             "1978: Pope John Paul I becomes Pope"
         ]
         case (8, 27): return [
             "479 BCE: The Battle of Plataea takes place",
             "1776: The Battle of Long Island takes place",
             "1883: The eruption of Krakatoa begins",
             "2003: Mars makes its closest approach to Earth in nearly 60,000 years"
         ]
         case (8, 28): return [
             "475: The Roman general Orestes forces western Roman Emperor Julius Nepos to flee his capital city, Ravenna",
             "1565: The Spanish establish the first permanent European settlement in the Philippines",
             "1963: Martin Luther King Jr. delivers his 'I Have a Dream' speech",
             "2005: Hurricane Katrina makes landfall in Louisiana"
         ]
         case (8, 29): return [
             "708: Copper coins are minted in Japan for the first time",
             "1526: The Battle of Mohács takes place",
             "1949: The Soviet Union tests its first atomic bomb",
             "2005: Hurricane Katrina devastates much of the U.S. Gulf Coast"
         ]
         case (8, 30): return [
             "1363: The Battle of Lake Poyang begins",
             "1791: The HMS Pandora sinks after having run aground",
             "1963: The Hotline between the U.S. and Soviet Union goes into operation",
             "1995: NATO launches Operation Deliberate Force"
         ]
         case (8, 31): return [
             "1056: Empress Theodora becomes ill",
             "1888: Mary Ann Nichols is murdered, the first victim of Jack the Ripper",
             "1957: The Federation of Malaya gains independence",
             "1997: Princess Diana dies in a car crash"
         ]
         case (9, 1): return [
             "462: Possible start of first Byzantine indiction cycle",
             "1715: King Louis XIV of France dies",
             "1939: Germany invades Poland, starting World War II",
             "1983: Korean Air Lines Flight 007 is shot down"
         ]
         case (9, 2): return [
             "44 BCE: Cicero launches the first of his Philippicae",
             "1666: The Great Fire of London begins",
             "1945: World War II ends with the surrender of Japan",
             "1998: Swissair Flight 111 crashes"
         ]
         case (9, 3): return [
             "36 BCE: The Battle of Naulochus takes place",
             "1783: The Treaty of Paris ends the American Revolutionary War",
             "1939: The United Kingdom and France declare war on Germany",
             "1976: Viking 2 lands on Mars"
         ]
         case (9, 4): return [
             "476: Romulus Augustulus is deposed when Odoacer proclaims himself 'King of Italy'",
             "1781: Los Angeles is founded",
             "1888: George Eastman registers the trademark Kodak",
             "1998: Google is founded"
         ]
         case (9, 5): return [
             "917: The Battle of Achelous takes place",
             "1774: The First Continental Congress assembles",
             "1972: The Munich massacre occurs",
             "1997: Mother Teresa dies"
         ]
         case (9, 6): return [
             "394: The Battle of the Frigidus takes place",
             "1522: The Victoria returns to Sanlúcar de Barrameda",
             "1901: President William McKinley is shot",
             "1995: Cal Ripken Jr. breaks Lou Gehrig's record"
         ]
         case (9, 7): return [
             "70: The Roman army under Titus occupies and plunders Jerusalem",
             "1822: Brazil declares independence from Portugal",
             "1940: The Blitz begins",
             "1996: Tupac Shakur is shot"
         ]
         case (9, 8): return [
             "617: The Battle of Huoyi takes place",
             "1504: Michelangelo's David is unveiled",
             "1943: Italy surrenders to the Allies",
             "1974: Watergate scandal: President Gerald Ford pardons Richard Nixon"
         ]
         case (9, 9): return [
             "337: Constantine II, Constantius II, and Constans succeed their father Constantine I",
             "1776: The Continental Congress officially names the United States",
             "1948: The Democratic People's Republic of Korea is established",
             "2001: Ahmad Shah Massoud is assassinated"
         ]
         case (9, 10): return [
             "506: The bishops of Visigothic Gaul meet in the Council of Agde",
             "1813: The Battle of Lake Erie takes place",
             "1945: Vidkun Quisling is sentenced to death",
             "2001: The September 11 attacks occur"
         ]
         case (9, 11): return [
             "2001: Terrorist attacks occur in the United States, destroying the World Trade Center",
             "1941: Construction begins on the Pentagon",
             "1973: Chilean President Salvador Allende is overthrown in a military coup",
             "1997: NASA's Mars Global Surveyor reaches Mars"
         ]
         case (9, 12): return [
             "490: The Battle of Marathon takes place",
             "1683: The Battle of Vienna takes place",
             "1940: The Lascaux cave paintings are discovered",
             "1992: Mae Jemison becomes the first African-American woman in space"
         ]
         case (9, 13): return [
             "509 BCE: The Temple of Jupiter Optimus Maximus is dedicated",
             "1814: The Battle of Baltimore takes place",
             "1940: The Battle of Britain reaches its climax",
             "1993: The Oslo Accords are signed"
         ]
         case (9, 14): return [
             "81: Domitian becomes Emperor of the Roman Empire",
             "1752: The British Empire adopts the Gregorian calendar",
             "1901: President William McKinley dies from gunshot wounds",
             "1959: The Soviet probe Luna 2 crashes onto the Moon"
         ]
         case (9, 15): return [
             "994: Major Fatimid victory over the Byzantine Empire",
             "1616: The first non-aristocratic, free public school in Europe is opened",
             "1940: The Battle of Britain reaches its climax",
             "2008: Lehman Brothers files for bankruptcy"
         ]
         case (9, 16): return [
             "1400: Owain Glyndŵr is declared Prince of Wales",
             "1620: The Mayflower departs from Plymouth, England",
             "1940: The Selective Training and Service Act is passed",
             "1987: The Montreal Protocol is signed"
         ]
         case (9, 17): return [
             "1176: The Battle of Myriokephalon takes place",
             "1787: The United States Constitution is signed",
             "1944: Operation Market Garden begins",
             "1978: The Camp David Accords are signed"
         ]
         case (9, 18): return [
             "96: Nerva is proclaimed Roman Emperor",
             "1793: George Washington lays the cornerstone of the United States Capitol",
             "1947: The United States Air Force is established",
             "1977: Voyager 1 takes the first photograph of the Earth and Moon together"
         ]
         case (9, 19): return [
             "1356: The Battle of Poitiers takes place",
             "1777: The Battle of Saratoga begins",
             "1944: The Battle of Hürtgen Forest begins",
             "1985: A strong earthquake kills thousands in Mexico City"
         ]
         case (9, 20): return [
             "451: The Battle of the Catalaunian Plains takes place",
             "1519: Ferdinand Magellan sets sail from Sanlúcar de Barrameda",
             "1873: The Panic of 1873 begins",
             "2001: George W. Bush delivers his 'Axis of Evil' speech"
         ]
         case (9, 21): return [
             "37: Tiberius dies",
             "1792: The French Republic is proclaimed",
             "1937: J.R.R. Tolkien's 'The Hobbit' is published",
             "1981: Belize gains independence from the United Kingdom"
         ]
         case (9, 22): return [
             "66: Emperor Nero creates the Legion I Italica",
             "1692: The last people convicted of witchcraft in the Salem witch trials are hanged",
             "1862: President Abraham Lincoln issues the Emancipation Proclamation",
             "1980: The Iran-Iraq War begins"
         ]
         case (9, 23): return [
             "1122: The Concordat of Worms is signed",
             "1779: The Battle of Flamborough Head takes place",
             "1846: Neptune is discovered",
             "1999: NASA announces that it has lost contact with the Mars Climate Orbiter"
         ]
         case (9, 24): return [
             "622: Muhammad completes his hegira from Mecca to Medina",
             "1789: The Judiciary Act of 1789 is passed",
             "1948: The Honda Motor Company is founded",
             "1996: The Comprehensive Nuclear-Test-Ban Treaty is signed"
         ]
         case (9, 25): return [
             "275: Marcus Claudius Tacitus becomes Roman Emperor",
             "1493: Christopher Columbus sets sail on his second voyage",
             "1789: The United States Congress passes the Bill of Rights",
             "1983: The Soviet Union issues a statement admitting that Korean Air Lines Flight 007 was shot down"
         ]
         case (9, 26): return [
             "46 BCE: Julius Caesar dedicates a temple to his mythical ancestor Venus Genetrix",
             "1580: Sir Francis Drake finishes his circumnavigation of the Earth",
             "1789: Thomas Jefferson is appointed the first United States Secretary of State",
             "1983: Soviet military officer Stanislav Petrov averts a nuclear war"
         ]
         case (9, 27): return [
             "489: Theodoric the Great defeats Odoacer at the Battle of Verona",
             "1540: The Society of Jesus is approved by Pope Paul III",
             "1940: The Tripartite Pact is signed",
             "1996: The Taliban capture Kabul"
         ]
         case (9, 28): return [
             "48 BCE: Pompey is assassinated",
             "1066: William the Conqueror invades England",
             "1928: Alexander Fleming discovers penicillin",
             "1995: Bob Denard and a group of mercenaries take the islands of the Comoros"
         ]
         case (9, 29): return [
             "61: Boudica is defeated at the Battle of Watling Street",
             "1364: The Battle of Auray takes place",
             "1789: The United States Department of War is established",
             "2004: The asteroid 4179 Toutatis passes within four lunar distances of Earth"
         ]
         case (9, 30): return [
             "1399: Henry IV is proclaimed King of England",
             "1791: Wolfgang Amadeus Mozart's opera 'The Magic Flute' premieres",
             "1938: The Munich Agreement is signed",
             "2009: The 2009 Sumatra earthquakes occur"
         ]
         case (10, 1): return [
             "331 BCE: Alexander the Great defeats Darius III of Persia",
             "1908: The Ford Model T is introduced",
             "1949: The People's Republic of China is established",
             "1971: Walt Disney World opens in Florida"
         ]
         case (10, 2): return [
             "1187: Saladin captures Jerusalem",
             "1835: The Texas Revolution begins",
             "1950: The comic strip Peanuts is first published",
             "1996: The Electronic Freedom of Information Act is signed"
         ]
         case (10, 3): return [
             "52 BCE: Vercingetorix surrenders to Julius Caesar",
             "1789: George Washington proclaims the first Thanksgiving Day",
             "1952: The United Kingdom successfully tests a nuclear weapon",
             "1990: East and West Germany reunify"
         ]
         case (10, 4): return [
             "1582: Pope Gregory XIII implements the Gregorian calendar",
             "1777: The Battle of Germantown takes place",
             "1957: The Soviet Union launches Sputnik 1",
             "2004: SpaceShipOne wins the Ansari X Prize"
         ]
         case (10, 5): return [
             "610: Heraclius arrives at Constantinople",
             "1582: The Gregorian calendar is introduced",
             "1947: President Harry S. Truman delivers the first televised White House address",
             "1988: The Brazilian Constitution is promulgated"
         ]
         case (10, 6): return [
             "105 BCE: The Cimbri inflict a major defeat on the Roman army",
             "1683: William Penn arrives in Pennsylvania",
             "1927: The Jazz Singer, the first talking picture, premieres",
             "1973: The Yom Kippur War begins"
         ]
         case (10, 7): return [
             "3761 BCE: The epoch of the Hebrew calendar",
             "1571: The Battle of Lepanto takes place",
             "1949: The German Democratic Republic is established",
             "2001: The United States begins military operations in Afghanistan"
         ]
         case (10, 8): return [
             "451: The Council of Chalcedon begins",
             "1871: The Great Chicago Fire begins",
             "1918: Sergeant Alvin C. York kills 28 German soldiers",
             "1967: Che Guevara is captured in Bolivia"
         ]
         case (10, 9): return [
             "768: Charlemagne and his brother Carloman I are crowned Kings of The Franks",
             "1446: The Hangul alphabet is published in Korea",
             "1940: John Lennon is born",
             "1989: An official news agency in the Soviet Union reports the landing of a UFO in Voronezh"
         ]
         case (10, 10): return [
             "680: The Battle of Karbala takes place",
             "1845: The United States Naval Academy opens",
             "1911: The Wuchang Uprising begins the Xinhai Revolution",
             "1967: The Outer Space Treaty is signed"
         ]
         case (10, 11): return [
             "1138: A massive earthquake strikes Aleppo, Syria",
             "1492: Christopher Columbus's expedition makes landfall in the Caribbean",
             "1899: The Second Boer War begins",
             "1968: Apollo 7 launches"
         ]
         case (10, 12): return [
             "539 BCE: The army of Cyrus the Great of Persia takes Babylon",
             "1492: Christopher Columbus reaches the New World",
             "1810: The first Oktoberfest is held",
             "1964: The Soviet Union launches Voskhod 1"
         ]
         case (10, 13): return [
             "54: Nero succeeds Claudius as Roman Emperor",
             "1792: The cornerstone of the White House is laid",
             "1943: Italy declares war on Germany",
             "2010: The Chilean miners are rescued"
         ]
         case (10, 14): return [
             "1066: The Battle of Hastings takes place",
             "1933: Germany withdraws from the League of Nations",
             "1947: Chuck Yeager breaks the sound barrier",
             "1962: The Cuban Missile Crisis begins"
         ]
         case (10, 15): return [
             "533: Byzantine general Belisarius makes his formal entry into Carthage",
             "1582: Pope Gregory XIII implements the Gregorian calendar",
             "1917: Mata Hari is executed",
             "2003: China launches Shenzhou 5"
         ]
         case (10, 16): return [
             "456: Magister militum Ricimer defeats the Emperor Avitus at Piacenza",
             "1793: Marie Antoinette is executed",
             "1859: John Brown leads a raid on Harpers Ferry",
             "1964: China detonates its first nuclear weapon"
         ]
         case (10, 17): return [
             "1346: The Battle of Neville's Cross takes place",
             "1777: The British surrender at Saratoga",
             "1931: Al Capone is convicted of tax evasion",
             "1989: The Loma Prieta earthquake strikes San Francisco"
         ]
         case (10, 18): return [
             "1016: The Danes defeat the Saxons in the Battle of Assandun",
             "1867: The United States takes possession of Alaska",
             "1922: The British Broadcasting Company is founded",
             "1989: The Galileo spacecraft is launched"
         ]
         case (10, 19): return [
             "202 BCE: The Battle of Zama takes place",
             "1781: The British surrender at Yorktown",
             "1935: The League of Nations places economic sanctions on Italy",
             "1987: Black Monday occurs on Wall Street"
         ]
         case (10, 20): return [
             "1564: The Battle of Kawanakajima takes place",
             "1803: The United States Senate ratifies the Louisiana Purchase",
             "1944: The Battle of Leyte Gulf begins",
             "1973: The Sydney Opera House opens"
         ]
         case (10, 21): return [
             "1096: The People's Crusade is massacred",
             "1797: The USS Constitution is launched",
             "1879: Thomas Edison invents the light bulb",
             "1967: The March on the Pentagon takes place"
         ]
         case (10, 22): return [
             "362: The temple of Apollo at Daphne is destroyed by fire",
             "1797: André-Jacques Garnerin makes the first recorded parachute jump",
             "1962: President Kennedy announces the Cuban Missile Crisis",
             "2008: India launches its first lunar mission"
         ]
         case (10, 23): return [
             "42 BCE: The Battle of Philippi takes place",
             "1707: The first Parliament of Great Britain meets",
             "1942: The Second Battle of El Alamein begins",
             "2001: Apple releases the iPod"
         ]
         case (10, 24): return [
             "69: The Second Battle of Bedriacum takes place",
             "1648: The Peace of Westphalia is signed",
             "1945: The United Nations is founded",
             "2003: Concorde makes its last commercial flight"
         ]
         case (10, 25): return [
             "1415: The Battle of Agincourt takes place",
             "1854: The Charge of the Light Brigade occurs",
             "1944: The Battle of Leyte Gulf ends",
             "2001: Microsoft releases Windows XP"
         ]
         case (10, 26): return [
             "740: An earthquake strikes Constantinople",
             "1774: The First Continental Congress adjourns",
             "1881: The Gunfight at the O.K. Corral takes place",
             "1994: Jordan and Israel sign a peace treaty"
         ]
         case (10, 27): return [
             "312: Constantine the Great is said to have received his famous Vision of the Cross",
             "1904: The first New York City subway line opens",
             "1962: The Cuban Missile Crisis ends",
             "1997: The Dow Jones Industrial Average gains 337.17 points"
         ]
         case (10, 28): return [
             "312: Constantine the Great defeats Maxentius at the Battle of the Milvian Bridge",
             "1636: Harvard University is founded",
             "1886: The Statue of Liberty is dedicated",
             "1962: The Cuban Missile Crisis ends"
         ]
         case (10, 29): return [
             "312: Constantine the Great enters Rome",
             "1618: Sir Walter Raleigh is executed",
             "1929: The Wall Street Crash of 1929 occurs",
             "1998: John Glenn returns to space at age 77"
         ]
         case (10, 30): return [
             "637: Antioch surrenders to the Muslim forces",
             "1485: Henry VII is crowned King of England",
             "1938: Orson Welles broadcasts 'The War of the Worlds'",
             "1995: The Quebec sovereignty referendum is held"
         ]
         case (10, 31): return [
             "1517: Martin Luther posts his 95 Theses, sparking the Protestant Reformation",
             "1926: Harry Houdini dies from complications of appendicitis",
             "1956: The Suez Crisis begins when Israel invades the Sinai Peninsula",
             "2011: The world population reaches 7 billion people"
         ]
         case (11, 1): return [
             "996: Emperor Otto III issues a deed to Gottschalk, Bishop of Freising",
             "1512: The ceiling of the Sistine Chapel is exhibited to the public",
             "1952: The United States successfully detonates the first hydrogen bomb",
             "1993: The Maastricht Treaty takes effect"
         ]
         case (11, 2): return [
             "619: A qaghan of the Western Turkic Khaganate is assassinated",
             "1783: George Washington delivers his Farewell Address",
             "1947: Howard Hughes' Spruce Goose makes its first and only flight",
             "2000: The International Space Station receives its first resident crew"
         ]
         case (11, 3): return [
             "644: Umar is assassinated",
             "1493: Christopher Columbus first sights the island of Dominica",
             "1903: Panama declares independence from Colombia",
             "1957: The Soviet Union launches Sputnik 2 with Laika"
         ]
         case (11, 4): return [
             "1429: Joan of Arc liberates Saint-Pierre-le-Moûtier",
             "1922: Howard Carter discovers the entrance to Tutankhamun's tomb",
             "1956: Soviet troops enter Hungary",
             "2008: Barack Obama is elected President of the United States"
         ]
         case (11, 5): return [
             "1138: Lý Anh Tông is enthroned as emperor of Vietnam",
             "1605: The Gunpowder Plot is foiled",
             "1913: The United States recognizes the Republic of China",
             "1995: André Dallaire attempts to assassinate Prime Minister Jean Chrétien"
         ]
         case (11, 6): return [
             "355: Roman Emperor Constantius II promotes his cousin Julian to the rank of Caesar",
             "1860: Abraham Lincoln is elected President of the United States",
             "1935: Edwin Armstrong presents his paper 'A Method of Reducing Disturbances in Radio Signaling by a System of Frequency Modulation'",
             "1962: The United Nations General Assembly passes a resolution condemning South Africa's apartheid policies"
         ]
         case (11, 7): return [
             "680: The Sixth Ecumenical Council commences in Constantinople",
             "1917: The October Revolution begins",
             "1944: Franklin D. Roosevelt is elected to a fourth term as President",
             "2000: The 2000 United States presidential election takes place"
         ]
         case (11, 8): return [
             "960: The Song dynasty is established",
             "1519: Hernán Cortés enters Tenochtitlan",
             "1923: Adolf Hitler leads the Beer Hall Putsch",
             "2016: Donald Trump is elected President of the United States"
         ]
         case (11, 9): return [
             "694: Egica, a king of the Visigoths of Hispania, accuses Jews of aiding Muslims",
             "1799: Napoleon Bonaparte leads the Coup of 18 Brumaire",
             "1938: Kristallnacht occurs",
             "1989: The Berlin Wall falls"
         ]
         case (11, 10): return [
             "1444: The Battle of Varna takes place",
             "1775: The United States Marine Corps is established",
             "1954: The U.S. Marine Corps Memorial is dedicated",
             "1989: German reunification is officially completed"
         ]
         case (11, 11): return [
             "308: At Carnuntum, Emperor emeritus Diocletian confers with Galerius, Augustus of the East",
             "1620: The Mayflower Compact is signed",
             "1918: World War I ends",
             "1975: Angola gains independence from Portugal"
         ]
         case (11, 12): return [
             "1035: Canute the Great dies",
             "1793: Jean Sylvain Bailly is guillotined",
             "1927: Leon Trotsky is expelled from the Soviet Communist Party",
             "1990: Tim Berners-Lee publishes a formal proposal for the World Wide Web"
         ]
         case (11, 13): return [
             "1002: English king Æthelred orders the killing of all Danes in England",
             "1775: American Revolutionary War: Patriot revolutionary forces under Gen. Richard Montgomery occupy Montreal",
             "1942: The Battle of Guadalcanal begins",
             "1985: The Nevado del Ruiz volcano erupts"
         ]
         case (11, 14): return [
             "1680: German astronomer Gottfried Kirch discovers the Great Comet of 1680",
             "1851: Herman Melville's novel Moby-Dick is published",
             "1940: Coventry is heavily bombed by German Luftwaffe",
             "1991: American and British authorities announce indictments against two Libyan intelligence officials"
         ]
         case (11, 15): return [
             "655: The Battle of the Winwaed takes place",
             "1777: The Continental Congress approves the Articles of Confederation",
             "1920: The first assembly of the League of Nations is held",
             "1988: The Soviet Union launches the Buran spacecraft"
         ]
         case (11, 16): return [
             "534: A second and final revision of the Codex Justinianus is published",
             "1776: British and Hessian units capture Fort Washington",
             "1940: The Holocaust: In occupied Poland, the Nazis close off the Warsaw Ghetto",
             "1989: The Velvet Revolution begins"
         ]
         case (11, 17): return [
             "1183: The Battle of Mizushima takes place",
             "1558: Elizabeth I becomes Queen of England",
             "1869: The Suez Canal opens",
             "1970: The Soviet Union lands Lunokhod 1 on Mare Imbrium"
         ]
         case (11, 18): return [
             "326: The old St. Peter's Basilica is consecrated",
             "1626: St. Peter's Basilica is consecrated",
             "1883: American and Canadian railroads institute five standard continental time zones",
             "1978: The Jonestown massacre occurs"
         ]
         case (11, 19): return [
             "461: Libius Severus is declared emperor of the Western Roman Empire",
             "1493: Christopher Columbus goes ashore on an island he first saw the day before",
             "1863: President Abraham Lincoln delivers the Gettysburg Address",
             "1969: Apollo 12 lands on the Moon"
         ]
         case (11, 20): return [
             "284: Diocletian is chosen as Roman Emperor",
             "1789: New Jersey becomes the first U.S. state to ratify the Bill of Rights",
             "1945: The Nuremberg trials begin",
             "1998: The first module of the International Space Station is launched"
         ]
         case (11, 21): return [
             "164 BCE: Judas Maccabaeus, son of Mattathias of the Hasmonean family, restores the Temple in Jerusalem",
             "1620: The Mayflower arrives at what is now Provincetown, Massachusetts",
             "1877: Thomas Edison announces his invention of the phonograph",
             "1995: The Dayton Agreement is signed"
         ]
         case (11, 22): return [
             "1963: President John F. Kennedy is assassinated in Dallas, Texas",
             "1718: Blackbeard the pirate is killed in battle off the coast of North Carolina",
             "1943: Lebanon gains independence from France",
             "1995: The first feature-length computer-animated film, Toy Story, is released"
         ]
         case (11, 23): return [
             "534 BCE: Thespis of Icaria becomes the first recorded actor to portray a character onstage",
             "1499: Perkin Warbeck, a pretender to the English crown, is executed",
             "1936: Life magazine is reborn as a photo magazine",
             "1996: Ethiopian Airlines Flight 961 is hijacked"
         ]
         case (11, 24): return [
             "380: Theodosius I makes his adventus, or formal entry, into Constantinople",
             "1642: Abel Janszoon Tasman becomes the first European to discover the island Van Diemen's Land",
             "1859: Charles Darwin publishes On the Origin of Species",
             "1963: Lee Harvey Oswald is shot by Jack Ruby"
         ]
         case (11, 25): return [
             "571: The Prophet Muhammad is born",
             "1783: The British evacuate New York City",
             "1947: The Hollywood Ten are blacklisted",
             "1999: The United Nations establishes the International Day for the Elimination of Violence against Women"
         ]
         case (11, 26): return [
             "783: The Asturian queen Adosinda is held at a monastery to prevent her from supporting the rebellion of her son Mauregatus",
             "1778: Captain James Cook becomes the first European to visit Maui",
             "1942: Casablanca premieres in New York City",
             "2008: Terrorist attacks occur in Mumbai"
         ]
         case (11, 27): return [
             "25: Luoyang is declared capital of the Han dynasty by Emperor Guangwu of Han",
             "1095: Pope Urban II declares the First Crusade",
             "1895: Alfred Nobel signs his last will and testament",
             "1978: Harvey Milk and George Moscone are assassinated"
         ]
         case (11, 28): return [
             "587: The Treaty of Andelot is signed",
             "1520: Ferdinand Magellan begins crossing the Pacific Ocean",
             "1943: The Tehran Conference begins",
             "1979: Air New Zealand Flight 901 crashes into Mount Erebus"
         ]
         case (11, 29): return [
             "561: King Chlothar I dies at Compiègne",
             "1777: San Jose, California, is founded",
             "1947: The United Nations General Assembly votes to partition Palestine",
             "1987: Korean Air Flight 858 is bombed"
         ]
         case (11, 30): return [
             "977: Emperor Otto II lifts the siege at Paris",
             "1782: The United States and Great Britain sign preliminary peace articles",
             "1939: The Winter War begins",
             "1995: The official end of Operation Desert Storm"
         ]
         case (12, 1): return [
             "800: Charlemagne judges the accusations against Pope Leo III in the Vatican",
             "1824: The 1824 United States presidential election is held",
             "1955: Rosa Parks refuses to give up her bus seat",
             "1990: The Channel Tunnel workers from the United Kingdom and France meet"
         ]
         case (12, 2): return [
             "1409: The University of Leipzig opens",
             "1804: Napoleon Bonaparte is crowned Emperor of the French",
             "1942: The first controlled nuclear chain reaction is achieved",
             "1982: The first permanent artificial heart is implanted"
         ]
         case (12, 3): return [
             "741: Pope Zachary succeeds Pope Gregory III",
             "1818: Illinois becomes the 21st U.S. state",
             "1967: The first human heart transplant is performed",
             "1984: The Bhopal disaster occurs"
         ]
         case (12, 4): return [
             "771: Charlemagne becomes the sole King of the Franks",
             "1676: The Battle of Lund takes place",
             "1945: The United States Senate approves the United States' participation in the United Nations",
             "1991: Pan American World Airways ceases operations"
         ]
         case (12, 5): return [
             "63 BCE: Cicero reads the last of his Catiline Orations",
             "1492: Christopher Columbus becomes the first European to set foot on the island of Hispaniola",
             "1933: Prohibition in the United States ends",
             "2013: Nelson Mandela dies"
         ]
         case (12, 6): return [
             "1060: Béla I is crowned king of Hungary",
             "1865: The Thirteenth Amendment to the United States Constitution is ratified",
             "1917: Finland declares independence from Russia",
             "1992: The Babri Masjid is demolished"
         ]
         case (12, 7): return [
             "43 BCE: Cicero is assassinated",
             "1941: The attack on Pearl Harbor occurs",
             "1972: Apollo 17 launches",
             "1988: The Spitak earthquake devastates Armenia"
         ]
         case (12, 8): return [
             "65: Horace writes his 'Ode to Maecenas'",
             "1941: The United States declares war on Japan",
             "1980: John Lennon is shot and killed",
             "1991: The Soviet Union is dissolved"
         ]
         case (12, 9): return [
             "536: Byzantine general Belisarius enters Rome",
             "1793: New York City's first daily newspaper, the American Minerva, is established",
             "1946: The 'Subsequent Nuremberg Trials' begin",
             "1992: American troops land in Somalia"
         ]
         case (12, 10): return [
             "741: Pope Zachary is elected",
             "1520: Martin Luther burns his copy of the papal bull Exsurge Domine",
             "1901: The first Nobel Prize ceremony is held",
             "1948: The Universal Declaration of Human Rights is adopted"
         ]
         case (12, 11): return [
             "359: Honoratus, the first known Prefect of the City of Constantinople, takes office",
             "1816: Indiana becomes the 19th U.S. state",
             "1941: Germany and Italy declare war on the United States",
             "1997: The Kyoto Protocol is adopted"
         ]
         case (12, 12): return [
             "627: The Battle of Nineveh takes place",
             "1787: Pennsylvania becomes the second state to ratify the U.S. Constitution",
             "1901: Guglielmo Marconi receives the first transatlantic radio signal",
             "2000: The United States Supreme Court releases its decision in Bush v. Gore"
         ]
         case (12, 13): return [
             "1294: Pope Celestine V resigns the papacy",
             "1577: Sir Francis Drake sets sail from Plymouth, England",
             "1937: The Nanking Massacre begins",
             "2003: Saddam Hussein is captured"
         ]
         case (12, 14): return [
             "557: Constantinople is severely damaged by an earthquake",
             "1799: George Washington dies at Mount Vernon",
             "1911: Roald Amundsen becomes the first person to reach the South Pole",
             "2012: The Sandy Hook Elementary School shooting occurs"
         ]
         case (12, 15): return [
             "533: The Vandalic War begins",
             "1791: The United States Bill of Rights becomes law",
             "1939: Gone with the Wind premieres",
             "1973: The American Psychiatric Association removes homosexuality from its list of mental disorders"
         ]
         case (12, 16): return [
             "714: Pepin of Herstal, mayor of the Merovingian palace, dies at Jupille",
             "1773: The Boston Tea Party occurs",
             "1944: The Battle of the Bulge begins",
             "1991: Kazakhstan declares independence from the Soviet Union"
         ]
         case (12, 17): return [
             "546: The Ostrogoths under King Totila conquer Rome",
             "1903: The Wright brothers make their first powered flight",
             "1944: The Malmedy massacre occurs",
             "1989: The Simpsons premieres on television"
         ]
         case (12, 18): return [
             "218 BCE: The Battle of the Trebia takes place",
             "1620: The Mayflower lands at Plymouth Rock",
             "1944: The Supreme Court of the United States decides Korematsu v. United States",
             "1994: The North American Free Trade Agreement goes into effect"
         ]
         case (12, 19): return [
             "324: Licinius abdicates his position as Roman Emperor",
             "1776: Thomas Paine publishes the first 'American Crisis' essay",
             "1946: The First Indochina War begins",
             "1998: The United States House of Representatives impeaches Bill Clinton"
         ]
         case (12, 20): return [
             "69: Vespasian becomes Roman Emperor",
             "1803: The Louisiana Purchase is completed",
             "1951: The first experimental nuclear power plant begins operation",
             "1989: The United States invades Panama"
         ]
         case (12, 21): return [
             "69: The Roman Senate declares Vespasian emperor",
             "1620: The Mayflower Pilgrims come ashore in Plymouth",
             "1937: Snow White and the Seven Dwarfs premieres",
             "1988: Pan Am Flight 103 is bombed over Lockerbie, Scotland"
         ]
         case (12, 22): return [
             "401: Pope Innocent I is elected",
             "1808: Ludwig van Beethoven conducts and performs in concert",
             "1944: The Battle of the Bulge begins",
             "1989: The Brandenburg Gate reopens"
         ]
         case (12, 23): return [
             "484: Huneric dies and is succeeded by his nephew Gunthamund",
             "1783: George Washington resigns as commander-in-chief",
             "1947: The transistor is first demonstrated",
             "1986: The experimental aircraft Voyager completes the first non-stop flight around the world"
         ]
         case (12, 24): return [
             "640: Pope John IV is elected",
             "1814: The Treaty of Ghent is signed",
             "1865: The Ku Klux Klan is formed",
             "1968: Apollo 8 enters orbit around the Moon"
         ]
         case (12, 25): return [
             "800: Charlemagne is crowned Holy Roman Emperor by Pope Leo III",
             "1066: William the Conqueror is crowned King of England",
             "1776: George Washington crosses the Delaware River during the American Revolution",
             "1991: Mikhail Gorbachev resigns as President of the Soviet Union"
         ]
         case (12, 26): return [
             "268: Pope Dionysius is elected",
             "1776: The Battle of Trenton takes place",
             "1941: Winston Churchill addresses a joint session of the U.S. Congress",
             "2004: A 9.3 magnitude earthquake creates a tsunami causing devastation in Sri Lanka, India, Indonesia, Thailand, Malaysia, the Maldives and many other areas around the rim of the Indian Ocean"
         ]
         case (12, 27): return [
             "537: The Hagia Sophia is completed",
             "1831: Charles Darwin embarks on his journey aboard the HMS Beagle",
             "1945: The International Monetary Fund is created",
             "2007: Benazir Bhutto is assassinated"
         ]
         case (12, 28): return [
             "457: Majorian is acclaimed emperor of the Western Roman Empire",
             "1832: John C. Calhoun becomes the first Vice President of the United States to resign",
             "1945: The United States Congress officially recognizes the Pledge of Allegiance",
             "1973: The Endangered Species Act is passed"
         ]
         case (12, 29): return [
             "1170: Thomas Becket is assassinated",
             "1845: Texas is admitted as the 28th U.S. state",
             "1937: The Irish Free State is replaced by a new state called Ireland",
             "1989: Václav Havel is elected President of Czechoslovakia"
         ]
         case (12, 30): return [
             "1460: The Battle of Wakefield takes place",
             "1853: The Gadsden Purchase is completed",
             "1922: The Union of Soviet Socialist Republics is formed",
             "2006: Saddam Hussein is executed"
         ]
         case (12, 31): return [
             "406: The Vandals cross the Rhine",
             "1600: The British East India Company is chartered",
             "1907: The first New Year's Eve celebration is held in Times Square",
             "1999: The world prepares for the Y2K bug"
         ]
        default:
            // For dates not specifically covered, provide some interesting historical context
            let monthNames = ["January", "February", "March", "April", "May", "June", 
                             "July", "August", "September", "October", "November", "December"]
            return [
                "\(monthNames[month-1]) \(day) has witnessed countless moments that shaped our world",
                "On this day throughout history, ordinary people have done extraordinary things",
                "This date connects you to a rich tapestry of human achievement and discovery",
                "Every day is a new chapter in the ongoing story of humanity's journey"
            ]
        }
    }
    
    private func getFamousBirthdays() -> [String]? {
        let (month, day) = getMonthDay()
        
        switch (month, day) {
        case (1, 1): return [
            "Paul Revere (1735) - American patriot and silversmith",
            "J. Edgar Hoover (1895) - First director of the FBI",
            "J.D. Salinger (1919) - Author of 'The Catcher in the Rye'",
            "Grandmaster Flash (1958) - Hip-hop pioneer and DJ"
        ]
        case (1, 15): return [
            "Martin Luther King Jr. (1929) - Civil rights leader",
            "Aristotle Onassis (1906) - Greek shipping magnate",
            "Mario Van Peebles (1957) - Actor and director",
            "Pitbull (1981) - Rapper and singer"
        ]
        case (2, 14): return [
            "Frederick Douglass (1818) - Abolitionist and writer",
            "Jack Benny (1894) - Comedian and actor",
            "Hugh Downs (1921) - Television host",
            "Rob Thomas (1972) - Singer-songwriter"
        ]
        case (3, 15): return [
            "Andrew Jackson (1767) - 7th President of the United States",
            "Ruth Bader Ginsburg (1933) - Supreme Court Justice",
            "Eva Longoria (1975) - Actress and producer",
            "Will.i.am (1975) - Rapper and producer"
        ]
        case (4, 15): return [
            "Leonardo da Vinci (1452) - Italian Renaissance artist and inventor",
            "Bessie Smith (1894) - Blues singer",
            "Emma Watson (1990) - Actress and activist",
            "Seth Rogen (1982) - Actor and comedian"
        ]
        case (5, 1): return [
            "Kate Smith (1907) - Singer",
            "Judy Collins (1939) - Folk singer",
            "Rita Coolidge (1945) - Singer-songwriter",
            "Tim McGraw (1967) - Country singer"
        ]
        case (6, 6): return [
            "Nathan Hale (1755) - American Revolutionary War spy",
            "Robert F. Kennedy (1925) - U.S. Attorney General and Senator",
            "Björn Borg (1956) - Tennis champion",
            "Sandra Bernhard (1955) - Comedian and actress"
        ]
        case (7, 4): return [
            "Calvin Coolidge (1872) - 30th President of the United States",
            "Gloria Stuart (1910) - Actress",
            "Gina Lollobrigida (1927) - Italian actress",
            "Malala Yousafzai (1997) - Nobel Peace Prize winner"
        ]
        case (8, 15): return [
            "Napoleon Bonaparte (1769) - French military leader and emperor",
            "Julia Child (1912) - Chef and television personality",
            "Ben Affleck (1972) - Actor and director",
            "Jennifer Lawrence (1990) - Actress"
        ]
        case (9, 11): return [
            "O. Henry (1862) - American short story writer",
            "D.H. Lawrence (1885) - English novelist",
            "Harry Connick Jr. (1967) - Singer and actor",
            "Ludacris (1977) - Rapper and actor"
        ]
        case (10, 31): return [
            "John Keats (1795) - English Romantic poet",
            "Katherine Hepburn (1907) - Actress",
            "Dan Rather (1931) - Journalist",
            "Vanilla Ice (1967) - Rapper"
        ]
        case (11, 22): return [
            "Charles de Gaulle (1890) - French military leader and president",
            "Rodney Dangerfield (1921) - Comedian",
            "Jamie Lee Curtis (1958) - Actress",
            "Scarlett Johansson (1984) - Actress"
        ]
        case (12, 25): return [
            "Isaac Newton (1642) - English physicist and mathematician",
            "Humphrey Bogart (1899) - Actor",
            "Annie Lennox (1954) - Singer-songwriter",
            "Justin Trudeau (1971) - Prime Minister of Canada"
        ]
        default:
            return nil
        }
    }
    
    private func getFunFacts() -> [String]? {
        let (month, day) = getMonthDay()
        
        switch (month, day) {
        case (1, 1): return [
            "January 1st is the most common birthday in the United States",
            "The first day of the year is celebrated as New Year's Day worldwide",
            "Many people make resolutions on this day to improve their lives",
            "In many cultures, this day symbolizes new beginnings and fresh starts"
        ]
        case (2, 14): return [
            "Valentine's Day is celebrated in many countries around the world",
            "Approximately 150 million Valentine's Day cards are exchanged annually",
            "The heart shape as a symbol of love became popular in the 15th century",
            "Chocolate became associated with Valentine's Day in the 19th century"
        ]
        case (3, 15): return [
            "The Ides of March was a day of religious observance in ancient Rome",
            "Shakespeare's famous line 'Beware the Ides of March' comes from Julius Caesar",
            "This date marks the middle of March in the Roman calendar",
            "Many consider this day unlucky due to Caesar's assassination"
        ]
        case (4, 15): return [
            "Tax Day in the United States (when not extended)",
            "The Titanic disaster occurred on this date in 1912",
            "This day is also known as Jackie Robinson Day in baseball",
            "Many countries observe this as a day of remembrance"
        ]
        case (5, 1): return [
            "May Day is celebrated as International Workers' Day in many countries",
            "In ancient times, May 1st was associated with spring fertility festivals",
            "Many countries celebrate this as a public holiday",
            "The tradition of dancing around the maypole originated in medieval Europe"
        ]
        case (6, 6): return [
            "D-Day, one of the most significant military operations in history",
            "The number 666 is considered unlucky in many cultures",
            "This date is also known as National Yo-Yo Day",
            "Many consider this a day of great historical importance"
        ]
        case (7, 4): return [
            "Independence Day in the United States",
            "The Declaration of Independence was actually signed on July 2nd",
            "Fireworks displays are a traditional part of celebrations",
            "This day is celebrated with parades, barbecues, and family gatherings"
        ]
        case (8, 15): return [
            "Assumption Day is celebrated in many Catholic countries",
            "India celebrates Independence Day on this date",
            "This day marks the end of summer in many cultures",
            "Many festivals and celebrations occur around this time"
        ]
        case (9, 11): return [
            "A day of remembrance for the 2001 terrorist attacks",
            "Many memorial services are held on this date",
            "This day changed the course of modern history",
            "Acts of kindness and service are encouraged on this day"
        ]
        case (10, 31): return [
            "Halloween is celebrated in many countries",
            "The tradition of trick-or-treating began in the 1930s",
            "Pumpkins are carved into jack-o'-lanterns for decoration",
            "This day is associated with costumes, candy, and spooky fun"
        ]
        case (11, 22): return [
            "The anniversary of JFK's assassination in 1963",
            "Many memorial services are held on this date",
            "This day is remembered for its historical significance",
            "A day of reflection on leadership and public service"
        ]
        case (12, 25): return [
            "Christmas Day is celebrated by billions of people worldwide",
            "The date of Jesus' birth is not actually known",
            "Many cultures have winter solstice celebrations around this time",
            "This day is associated with gift-giving and family gatherings"
        ]
        default:
            return nil
        }
    }
    
    private func getWesternZodiac() -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: birthday)
        let day = calendar.component(.day, from: birthday)
        
        switch (month, day) {
        case (1, 1...19), (12, 22...31): return "Capricorn ♑"
        case (1, 20...31), (2, 1...18): return "Aquarius ♒"
        case (2, 19...29), (3, 1...20): return "Pisces ♓"
        case (3, 21...31), (4, 1...19): return "Aries ♈"
        case (4, 20...30), (5, 1...20): return "Taurus ♉"
        case (5, 21...31), (6, 1...20): return "Gemini ♊"
        case (6, 21...30), (7, 1...22): return "Cancer ♋"
        case (7, 23...31), (8, 1...22): return "Leo ♌"
        case (8, 23...31), (9, 1...22): return "Virgo ♍"
        case (9, 23...30), (10, 1...22): return "Libra ♎"
        case (10, 23...31), (11, 1...21): return "Scorpio ♏"
        case (11, 22...30), (12, 1...21): return "Sagittarius ♐"
        default: return "Unknown"
        }
    }
    
    private func getChineseZodiac() -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: birthday)
        let month = calendar.component(.month, from: birthday)
        let day = calendar.component(.day, from: birthday)
        
        // Simplified Lunar Zodiac calculation
        let zodiacYear = (year - 1900) % 12
        
        let animal: String
        switch zodiacYear {
        case 0: animal = "Rat 🐀"
        case 1: animal = "Ox 🐂"
        case 2: animal = "Tiger 🐅"
        case 3: animal = "Rabbit 🐇"
        case 4: animal = "Dragon 🐉"
        case 5: animal = "Snake 🐍"
        case 6: animal = "Horse 🐎"
        case 7: animal = "Goat 🐐"
        case 8: animal = "Monkey 🐒"
        case 9: animal = "Rooster 🐓"
        case 10: animal = "Dog 🐕"
        case 11: animal = "Pig 🐖"
        default: animal = "Unknown"
        }
        
        return animal
    }
}

#Preview {
    BirthdayPopupView(birthday: Date(), contactName: "John Doe")
} 
