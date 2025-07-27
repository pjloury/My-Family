import Foundation
import SwiftUI

struct Contact: Identifiable, Codable {
    let id = UUID()
    let name: String
    let firstName: String
    let nickname: String?
    let birthday: Date
    let photoData: Data?
    
    var displayName: String {
        return nickname ?? name
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
        
        // Get this year's birthday
        let thisYear = calendar.component(.year, from: now)
        var nextBirthday = calendar.date(from: DateComponents(year: thisYear, month: calendar.component(.month, from: birthday), day: calendar.component(.day, from: birthday))) ?? birthday
        
        // If this year's birthday has passed, get next year's birthday
        if nextBirthday < now {
            nextBirthday = calendar.date(from: DateComponents(year: thisYear + 1, month: calendar.component(.month, from: birthday), day: calendar.component(.day, from: birthday))) ?? birthday
        }
        
        let days = calendar.dateComponents([.day], from: now, to: nextBirthday).day ?? 0
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
                return "\(months) months, \(days) days"
            } else {
                return "\(months) months"
            }
        } else {
            return "\(days) days"
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
            return "\(totalDays) days"
        } else {
            return "\(roundedMonths) months"
        }
    }
    
    var photo: UIImage? {
        guard let photoData = photoData else { return nil }
        return UIImage(data: photoData)
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
}

enum SortOption: String, CaseIterable {
    case name = "Name"
    case age = "Age"
    case birthday = "Birthday"
    case daysUntilBirthday = "Days Until Birthday"
    
    var displayName: String {
        return self.rawValue
    }
} 