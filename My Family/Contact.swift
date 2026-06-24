import Foundation
import SwiftUI
import UIKit

struct SpecialDate: Identifiable, Codable, Equatable {
    var id = UUID()
    var date: Date
    var label: String = ""

    var daysUntilNext: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let thisYear = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        var next = calendar.date(from: DateComponents(year: thisYear, month: month, day: day)) ?? date
        if next < today {
            next = calendar.date(from: DateComponents(year: thisYear + 1, month: month, day: day)) ?? date
        }
        return calendar.dateComponents([.day], from: today, to: next).day ?? 0
    }

    var monthsUntilNext: String {
        let days = daysUntilNext
        if days == 0 { return "Today" }
        let months = days / 30
        if months < 1 {
            return days == 1 ? "1 day" : "\(days) days"
        }
        return months == 1 ? "1 month" : "\(months) months"
    }

    var displayLabel: String {
        label.isEmpty ? "Special Date" : label
    }
}

struct Contact: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var firstName: String
    let nickname: String?
    var birthday: Date
    var photoFileName: String?
    var phoneNumber: String?
    var notificationsEnabled: Bool = true
    var calendarReminderEnabled: Bool = true
    var deceasedDate: Date?
    var specialDates: [SpecialDate] = []
    var relation: String?

    static let suggestedRelations: [String] = [
        "Mother", "Father", "Sister", "Brother",
        "Grandmother", "Grandfather", "Great-Grandmother", "Great-Grandfather",
        "Aunt", "Uncle", "Cousin", "Niece", "Nephew",
        "Daughter", "Son",
        "Wife", "Husband", "Girlfriend", "Boyfriend", "Partner",
        "Friend", "Best Friend",
        "Mother-in-Law", "Father-in-Law", "Sister-in-Law", "Brother-in-Law",
        "Stepmom", "Stepdad", "Stepsibling",
    ]

    enum CodingKeys: String, CodingKey {
        case id, name, firstName, nickname, birthday, photoFileName, phoneNumber
        case notificationsEnabled, calendarReminderEnabled, deceasedDate, specialDates, relation
    }

    init(name: String, firstName: String, nickname: String?, birthday: Date, photoFileName: String?, phoneNumber: String? = nil, notificationsEnabled: Bool = true, calendarReminderEnabled: Bool = true, deceasedDate: Date? = nil, specialDates: [SpecialDate] = [], relation: String? = nil) {
        self.name = name
        self.firstName = firstName
        self.nickname = nickname
        self.birthday = birthday
        self.photoFileName = photoFileName
        self.phoneNumber = phoneNumber
        self.notificationsEnabled = notificationsEnabled
        self.calendarReminderEnabled = calendarReminderEnabled
        self.deceasedDate = deceasedDate
        self.specialDates = specialDates
        self.relation = relation
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decode(String.self, forKey: .name)
        firstName = try c.decode(String.self, forKey: .firstName)
        nickname = try c.decodeIfPresent(String.self, forKey: .nickname)
        birthday = try c.decode(Date.self, forKey: .birthday)
        photoFileName = try c.decodeIfPresent(String.self, forKey: .photoFileName)
        phoneNumber = try c.decodeIfPresent(String.self, forKey: .phoneNumber)
        notificationsEnabled = try c.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? true
        calendarReminderEnabled = try c.decodeIfPresent(Bool.self, forKey: .calendarReminderEnabled) ?? true
        deceasedDate = try c.decodeIfPresent(Date.self, forKey: .deceasedDate)
        specialDates = try c.decodeIfPresent([SpecialDate].self, forKey: .specialDates) ?? []
        relation = try c.decodeIfPresent(String.self, forKey: .relation)
    }

    var displayName: String {
        return nickname ?? name
    }

    var isDeceased: Bool {
        return deceasedDate != nil
    }

    // Age they lived to (nil if still living)
    var ageAtDeath: Int? {
        guard let deceasedDate = deceasedDate else { return nil }
        return Calendar.current.dateComponents([.year], from: birthday, to: deceasedDate).year
    }

    // Age they would be if still alive
    var wouldBeAge: Int {
        return Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0
    }

    var age: Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        return ageComponents.year ?? 0
    }
    
    var daysUntilNextBirthday: Int {
        let calendar = Calendar.current
        let now = Date()
        
        // Get today's date components (year, month, day only)
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        let today = calendar.date(from: todayComponents) ?? now
        
        // Get this year's birthday
        let thisYear = calendar.component(.year, from: now)
        var nextBirthday = calendar.date(from: DateComponents(year: thisYear, month: calendar.component(.month, from: birthday), day: calendar.component(.day, from: birthday))) ?? birthday
        
        // If this year's birthday has passed, get next year's birthday
        if nextBirthday < today {
            nextBirthday = calendar.date(from: DateComponents(year: thisYear + 1, month: calendar.component(.month, from: birthday), day: calendar.component(.day, from: birthday))) ?? birthday
        }
        
        let days = calendar.dateComponents([.day], from: today, to: nextBirthday).day ?? 0
        return days
    }
    
    var birthdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: birthday)
    }
    
    var birthdayMonthDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: birthday)
    }
    
    var birthdayYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: birthday)
    }
    
    var monthsAndDaysUntilBirthday: String {
        let calendar = Calendar.current
        let now = Date()
        
        // Get this year's birthday
        let thisYear = calendar.component(.year, from: now)
        var nextBirthday = calendar.date(from: DateComponents(year: thisYear, month: calendar.component(.month, from: birthday), day: calendar.component(.day, from: birthday))) ?? birthday
        
        // If this year's birthday has passed, get next year's birthday
        if nextBirthday < now {
            nextBirthday = calendar.date(from: DateComponents(year: thisYear + 1, month: calendar.component(.month, from: birthday), day: calendar.component(.day, from: birthday))) ?? birthday
        }
        
        let components = calendar.dateComponents([.month, .day], from: now, to: nextBirthday)
        let months = components.month ?? 0
        let days = components.day ?? 0
        
        if months > 0 {
            if days > 0 {
                let monthText = months == 1 ? "month" : "months"
                let dayText = days == 1 ? "day" : "days"
                return "\(months) \(monthText), \(days) \(dayText)"
            } else {
                let monthText = months == 1 ? "month" : "months"
                return "\(months) \(monthText)"
            }
        } else {
            let dayText = days == 1 ? "day" : "days"
            return "\(days) \(dayText)"
        }
    }
    
    var monthsUntilBirthday: String {
        let calendar = Calendar.current
        let now = Date()
        
        // Get this year's birthday
        let thisYear = calendar.component(.year, from: now)
        var nextBirthday = calendar.date(from: DateComponents(year: thisYear, month: calendar.component(.month, from: birthday), day: calendar.component(.day, from: birthday))) ?? birthday
        
        // If this year's birthday has passed, get next year's birthday
        if nextBirthday < now {
            nextBirthday = calendar.date(from: DateComponents(year: thisYear + 1, month: calendar.component(.month, from: birthday), day: calendar.component(.day, from: birthday))) ?? birthday
        }
        
        let components = calendar.dateComponents([.month, .day], from: now, to: nextBirthday)
        let months = components.month ?? 0
        let days = components.day ?? 0
        
        // Round days into months (30 days = 1 month)
        let totalDays = (months * 30) + days
        let roundedMonths = totalDays / 30
        
        if roundedMonths < 1 {
            // If less than 1 month, show days
            let dayText = totalDays == 1 ? "day" : "days"
            return "\(totalDays) \(dayText)"
        } else {
            let monthText = roundedMonths == 1 ? "month" : "months"
            return "\(roundedMonths) \(monthText)"
        }
    }
    
    var photo: UIImage? {
        guard let photoFileName = photoFileName else { return nil }
        let fileManager = FileManager.default
        // Try App Group first (current save location)
        if let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.pjloury.My-Family") {
            let groupPath = groupURL.appendingPathComponent("ContactPhotos").appendingPathComponent(photoFileName)
            if let data = try? Data(contentsOf: groupPath) {
                return UIImage(data: data)
            }
        }
        // Fall back to Documents (legacy location for pre-migration photos)
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let legacyPath = documentsDirectory.appendingPathComponent("ContactPhotos").appendingPathComponent(photoFileName)
        if let data = try? Data(contentsOf: legacyPath) {
            return UIImage(data: data)
        }
        return nil
    }
    
    var zodiacSign: String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: birthday)
        let day = calendar.component(.day, from: birthday)
        
        switch (month, day) {
        case (1, 1...19), (12, 22...31):
            return "♑" // Capricorn
        case (1, 20...31), (2, 1...18):
            return "♒" // Aquarius
        case (2, 19...29), (3, 1...20):
            return "♓" // Pisces
        case (3, 21...31), (4, 1...19):
            return "♈" // Aries
        case (4, 20...30), (5, 1...20):
            return "♉" // Taurus
        case (5, 21...31), (6, 1...20):
            return "♊" // Gemini
        case (6, 21...30), (7, 1...22):
            return "♋" // Cancer
        case (7, 23...31), (8, 1...22):
            return "♌" // Leo
        case (8, 23...31), (9, 1...22):
            return "♍" // Virgo
        case (9, 23...30), (10, 1...22):
            return "♎" // Libra
        case (10, 23...31), (11, 1...21):
            return "♏" // Scorpio
        case (11, 22...30), (12, 1...21):
            return "♐" // Sagittarius
        default:
            return "♑" // Capricorn (fallback)
        }
    }
    
    var chineseZodiacAnimal: String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: birthday)
        let month = calendar.component(.month, from: birthday)
        let day = calendar.component(.day, from: birthday)
        
        // Lunar New Year dates (approximate, may vary by 1-2 days)
        // These are the dates when the new year started for each year
        let lunarNewYearDates: [Int: (month: Int, day: Int)] = [
            1900: (1, 30), 1901: (2, 19), 1902: (2, 8), 1903: (1, 29), 1904: (2, 16), 1905: (2, 4),
            1906: (1, 25), 1907: (2, 13), 1908: (2, 2), 1909: (1, 22), 1910: (2, 10), 1911: (1, 30),
            1912: (2, 18), 1913: (2, 6), 1914: (1, 26), 1915: (2, 14), 1916: (2, 3), 1917: (1, 23),
            1918: (2, 11), 1919: (2, 1), 1920: (2, 20), 1921: (2, 8), 1922: (1, 28), 1923: (2, 16),
            1924: (2, 5), 1925: (1, 25), 1926: (2, 13), 1927: (2, 2), 1928: (1, 23), 1929: (2, 10),
            1930: (1, 30), 1931: (2, 17), 1932: (2, 6), 1933: (1, 26), 1934: (2, 14), 1935: (2, 4),
            1936: (1, 24), 1937: (2, 11), 1938: (1, 31), 1939: (2, 19), 1940: (2, 8), 1941: (1, 27),
            1942: (2, 15), 1943: (2, 5), 1944: (1, 25), 1945: (2, 13), 1946: (2, 2), 1947: (1, 22),
            1948: (2, 10), 1949: (1, 29), 1950: (2, 17), 1951: (2, 6), 1952: (1, 27), 1953: (2, 14),
            1954: (2, 3), 1955: (1, 24), 1956: (2, 12), 1957: (1, 31), 1958: (2, 18), 1959: (2, 8),
            1960: (1, 28), 1961: (2, 15), 1962: (2, 5), 1963: (1, 25), 1964: (2, 13), 1965: (2, 2),
            1966: (1, 21), 1967: (2, 9), 1968: (1, 30), 1969: (2, 17), 1970: (2, 6), 1971: (1, 27),
            1972: (2, 15), 1973: (2, 3), 1974: (1, 23), 1975: (2, 11), 1976: (1, 31), 1977: (2, 18),
            1978: (2, 7), 1979: (1, 28), 1980: (2, 16), 1981: (2, 5), 1982: (1, 25), 1983: (2, 13),
            1984: (2, 2), 1985: (1, 21), 1986: (2, 9), 1987: (1, 29), 1988: (2, 17), 1989: (2, 6),
            1990: (1, 27), 1991: (2, 15), 1992: (2, 4), 1993: (1, 23), 1994: (2, 10), 1995: (1, 31),
            1996: (2, 19), 1997: (2, 7), 1998: (1, 28), 1999: (2, 16), 2000: (2, 5), 2001: (1, 24),
            2002: (2, 12), 2003: (2, 1), 2004: (1, 22), 2005: (2, 9), 2006: (1, 29), 2007: (2, 18),
            2008: (2, 7), 2009: (1, 26), 2010: (2, 14), 2011: (2, 3), 2012: (1, 23), 2013: (2, 10),
            2014: (1, 31), 2015: (2, 19), 2016: (2, 8), 2017: (1, 28), 2018: (2, 16), 2019: (2, 5),
            2020: (1, 25), 2021: (2, 12), 2022: (2, 1), 2023: (1, 22), 2024: (2, 10), 2025: (1, 29),
            2026: (2, 17), 2027: (2, 6), 2028: (1, 26), 2029: (2, 13), 2030: (2, 3), 2031: (1, 23),
            2032: (2, 11), 2033: (1, 31), 2034: (2, 19), 2035: (2, 8), 2036: (1, 28), 2037: (2, 15),
            2038: (2, 4), 2039: (1, 24), 2040: (2, 12), 2041: (2, 1), 2042: (1, 22), 2043: (2, 10)
        ]
        
        // Determine the effective year for zodiac calculation
        var effectiveYear = year
        
        // Check if birth date is before lunar new year
        if let lunarNewYear = lunarNewYearDates[year] {
            let birthDate = (month, day)
            let lunarDate = lunarNewYear
            
            // If born before lunar new year, use previous year's zodiac
            if birthDate < lunarDate {
                effectiveYear = year - 1
            }
        }
        
        // Calculate zodiac based on effective year
        let zodiacYear = (effectiveYear - 1900) % 12
        
        switch zodiacYear {
        case 0:
            return "🐀" // Rat
        case 1:
            return "🐂" // Ox
        case 2:
            return "🐅" // Tiger
        case 3:
            return "🐇" // Rabbit
        case 4:
            return "🐉" // Dragon
        case 5:
            return "🐍" // Snake
        case 6:
            return "🐎" // Horse
        case 7:
            return "🐐" // Goat
        case 8:
            return "🐒" // Monkey
        case 9:
            return "🐓" // Rooster
        case 10:
            return "🐕" // Dog
        case 11:
            return "🐖" // Pig
        default:
            return "🐀" // Rat (fallback)
        }
    }
    
    var gradeLevelEmoji: String? {
        // Only show for K-12 age children (typically 5-18 years old)
        if age < 5 || age > 18 {
            return nil
        }
        
        let calendar = Calendar.current
        
        // Typical school year starts in August/September
        // Students born before September 1st are in the grade for their age
        // Students born after September 1st are in the grade below their age
        
        let birthMonth = calendar.component(.month, from: birthday)
        let birthDay = calendar.component(.day, from: birthday)
        
        // Calculate grade based on age and birthday cutoff
        var grade = age - 5 // Start with basic grade calculation
        
        // Adjust for birthday cutoff (September 1st)
        if birthMonth > 9 || (birthMonth == 9 && birthDay > 1) {
            grade -= 1
        }
        
        // Ensure grade is within K-12 range
        if grade < 0 {
            grade = 0 // Kindergarten
        } else if grade > 12 {
            grade = 12 // 12th grade
        }
        
        // Return appropriate emoji
        switch grade {
        case 0:
            return "🎒" // Kindergarten
        case 1:
            return "1️⃣"
        case 2:
            return "2️⃣"
        case 3:
            return "3️⃣"
        case 4:
            return "4️⃣"
        case 5:
            return "5️⃣"
        case 6:
            return "6️⃣"
        case 7:
            return "7️⃣"
        case 8:
            return "8️⃣"
        case 9:
            return "9️⃣"
        case 10:
            return "🔟"
        case 11:
            return "1️⃣1️⃣"
        case 12:
            return "1️⃣2️⃣"
        default:
            return nil
        }
    }
}

enum SortOption: String, CaseIterable {
    case name = "Name"
    case age = "Age"
    case birthday = "Birthday"
    case daysUntilBirthday = "Upcoming Birthday"
    
    var displayName: String {
        return self.rawValue
    }
}

enum SortDirection: String {
    case ascending = "ascending"
    case descending = "descending"
    
    var arrow: String {
        switch self {
        case .ascending:
            return "⬆️"
        case .descending:
            return "⬇️"
        }
    }
    
    var next: SortDirection {
        switch self {
        case .ascending:
            return .descending
        case .descending:
            return .ascending
        }
    }
} 