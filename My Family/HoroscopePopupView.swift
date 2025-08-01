import SwiftUI

struct HoroscopePopupView: View {
    let zodiacSign: String
    let contactName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text(zodiacSign)
                            .font(.system(size: 60))
                        
                        Text(getZodiacName())
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("\(contactName)'s Sign")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Personality Traits
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Personality")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(getPersonalityTraits(), id: \.self) { trait in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    
                                    Text(trait)
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Strengths
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Strengths")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(getStrengths(), id: \.self) { strength in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    
                                    Text(strength)
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Challenges
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Growth Areas")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(getChallenges(), id: \.self) { challenge in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    
                                    Text(challenge)
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Element & Quality
                    HStack(spacing: 40) {
                        VStack(spacing: 8) {
                            Text("Element")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(getElement())
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Quality")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(getQuality())
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
            .navigationTitle("Zodiac Profile")
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
    
    private func getZodiacName() -> String {
        switch zodiacSign {
        case "♈": return "Aries"
        case "♉": return "Taurus"
        case "♊": return "Gemini"
        case "♋": return "Cancer"
        case "♌": return "Leo"
        case "♍": return "Virgo"
        case "♎": return "Libra"
        case "♏": return "Scorpio"
        case "♐": return "Sagittarius"
        case "♑": return "Capricorn"
        case "♒": return "Aquarius"
        case "♓": return "Pisces"
        default: return "Unknown"
        }
    }
    
    private func getPersonalityTraits() -> [String] {
        switch zodiacSign {
        case "♈": return [
            "Bold and ambitious, you're a natural leader who charges ahead with confidence",
            "Your fiery energy and enthusiasm are contagious to everyone around you",
            "You have an adventurous spirit and love taking on new challenges",
            "Direct and honest, you say what you mean and appreciate the same from others"
        ]
        case "♉": return [
            "Patient and reliable, you're the rock that others can always depend on",
            "You have a deep appreciation for beauty, comfort, and the finer things in life",
            "Your determination and persistence help you achieve your goals",
            "You're incredibly loyal and value long-lasting relationships"
        ]
        case "♊": return [
            "Versatile and expressive, you have a natural gift for communication",
            "Your curious mind loves learning and exploring new ideas",
            "You're adaptable and can easily connect with different types of people",
            "Your wit and charm make you a delightful conversationalist"
        ]
        case "♋": return [
            "Nurturing and protective, you have a strong maternal instinct",
            "Your emotional intelligence helps you understand others deeply",
            "You're incredibly intuitive and often sense things before they happen",
            "Home and family are your top priorities in life"
        ]
        case "♌": return [
            "Dramatic and creative, you have a natural flair for the spotlight",
            "Your generous heart and warm personality draw people to you",
            "You're confident and have a strong sense of self-worth",
            "Your leadership comes from inspiring others with your passion"
        ]
        case "♍": return [
            "Analytical and practical, you have a keen eye for detail",
            "Your perfectionist nature drives you to do things right",
            "You're incredibly helpful and love being of service to others",
            "Your intelligence and work ethic make you highly capable"
        ]
        case "♎": return [
            "Diplomatic and fair-minded, you naturally seek balance and harmony",
            "Your charm and social grace make you popular with others",
            "You have a strong sense of justice and fairness",
            "Your indecisiveness comes from wanting to consider all perspectives"
        ]
        case "♏": return [
            "Passionate and mysterious, you have an intense and magnetic presence",
            "Your determination and resourcefulness help you overcome any obstacle",
            "You're incredibly loyal and expect the same from those close to you",
            "Your intuition and ability to read people are almost psychic"
        ]
        case "♐": return [
            "Optimistic and adventurous, you have an infectious enthusiasm for life",
            "Your philosophical mind loves exploring big questions and ideas",
            "You're honest and straightforward, sometimes to a fault",
            "Your love of freedom and exploration drives you to seek new experiences"
        ]
        case "♑": return [
            "Ambitious and disciplined, you have the patience to achieve your goals",
            "Your practical nature and strong work ethic make you highly successful",
            "You're responsible and reliable, always following through on commitments",
            "Your wisdom and maturity often make you wise beyond your years"
        ]
        case "♒": return [
            "Progressive and original, you think outside the box and embrace uniqueness",
            "Your humanitarian nature drives you to make the world a better place",
            "You're independent and value your freedom and individuality",
            "Your innovative ideas and forward-thinking approach inspire others"
        ]
        case "♓": return [
            "Compassionate and artistic, you have a deep connection to your emotions",
            "Your intuition and empathy help you understand others on a profound level",
            "You're creative and imaginative, often lost in your own dreamy world",
            "Your gentle nature and caring heart make you a natural healer"
        ]
        default: return ["Personality traits not available"]
        }
    }
    
    private func getStrengths() -> [String] {
        switch zodiacSign {
        case "♈": return ["Courageous", "Energetic", "Willful", "Pioneering", "Independent"]
        case "♉": return ["Patient", "Reliable", "Devoted", "Persistent", "Determined"]
        case "♊": return ["Adaptable", "Versatile", "Communicative", "Witty", "Intellectual"]
        case "♋": return ["Tenacious", "Highly imaginative", "Loyal", "Emotional", "Sympathetic"]
        case "♌": return ["Creative", "Passionate", "Generous", "Warm-hearted", "Cheerful"]
        case "♍": return ["Analytical", "Kind", "Hardworking", "Practical", "Diligent"]
        case "♎": return ["Diplomatic", "Gracious", "Fair-minded", "Social", "Peaceful"]
        case "♏": return ["Determined", "Passionate", "Strategic", "Magnetic", "Intuitive"]
        case "♐": return ["Optimistic", "Adventurous", "Honest", "Philosophical", "Enthusiastic"]
        case "♑": return ["Responsible", "Disciplined", "Self-controlled", "Ambitious", "Patient"]
        case "♒": return ["Progressive", "Original", "Independent", "Humanitarian", "Intellectual"]
        case "♓": return ["Compassionate", "Artistic", "Intuitive", "Gentle", "Musical"]
        default: return ["Strengths not available"]
        }
    }
    
    private func getChallenges() -> [String] {
        switch zodiacSign {
        case "♈": return ["Impatience", "Impulsiveness", "Aggressiveness", "Self-centeredness"]
        case "♉": return ["Stubbornness", "Possessiveness", "Uncompromising", "Materialistic"]
        case "♊": return ["Indecisiveness", "Inconsistency", "Nervousness", "Superficiality"]
        case "♋": return ["Moodiness", "Pessimism", "Suspiciousness", "Over-emotional"]
        case "♌": return ["Arrogance", "Stubbornness", "Self-centeredness", "Laziness"]
        case "♍": return ["Worry", "Overly critical", "Perfectionism", "Harshness"]
        case "♎": return ["Indecisiveness", "Non-confrontational", "Self-pity", "Easily influenced"]
        case "♏": return ["Jealousy", "Secretiveness", "Obsessiveness", "Vengeful"]
        case "♐": return ["Impatience", "Tactlessness", "Restlessness", "Overconfidence"]
        case "♑": return ["Pessimism", "Rigidity", "Coldness", "Overly serious"]
        case "♒": return ["Rebelliousness", "Detachment", "Unpredictability", "Aloofness"]
        case "♓": return ["Escapism", "Oversensitivity", "Self-pity", "Lack of boundaries"]
        default: return ["Challenges not available"]
        }
    }
    
    private func getElement() -> String {
        switch zodiacSign {
        case "♈", "♌", "♐": return "Fire"
        case "♉", "♍", "♑": return "Earth"
        case "♊", "♎", "♒": return "Air"
        case "♋", "♏", "♓": return "Water"
        default: return "Unknown"
        }
    }
    
    private func getQuality() -> String {
        switch zodiacSign {
        case "♈", "♋", "♎", "♑": return "Cardinal"
        case "♉", "♌", "♏", "♒": return "Fixed"
        case "♊", "♍", "♐", "♓": return "Mutable"
        default: return "Unknown"
        }
    }
}

#Preview {
    HoroscopePopupView(zodiacSign: "♌", contactName: "John Doe")
} 