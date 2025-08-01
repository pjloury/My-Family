import SwiftUI

struct ChineseZodiacPopupView: View {
    let chineseZodiacAnimal: String
    let contactName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text(chineseZodiacAnimal)
                            .font(.system(size: 60))
                        
                        Text(getAnimalName())
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("\(contactName)'s Lunar Sign")
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
                    
                    // Element & Lucky Info
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
                            Text("Lucky Numbers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(getLuckyNumbers())
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 40)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Compatibility
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Best Matches")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(getCompatibility())
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Lunar Zodiac Profile")
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
    
    private func getAnimalName() -> String {
        switch chineseZodiacAnimal {
        case "🐀": return "Rat"
        case "🐂": return "Ox"
        case "🐅": return "Tiger"
        case "🐇": return "Rabbit"
        case "🐉": return "Dragon"
        case "🐍": return "Snake"
        case "🐎": return "Horse"
        case "🐐": return "Goat"
        case "🐒": return "Monkey"
        case "🐓": return "Rooster"
        case "🐕": return "Dog"
        case "🐖": return "Pig"
        default: return "Unknown"
        }
    }
    
    private func getPersonalityTraits() -> [String] {
        switch chineseZodiacAnimal {
        case "🐀": return [
            "Quick-witted and resourceful, you're excellent at finding opportunities others miss",
            "Your sharp mind and adaptability help you thrive in any situation",
            "You're incredibly ambitious and always have big plans for the future",
            "Your charm and social skills make you popular with everyone you meet"
        ]
        case "🐂": return [
            "Patient and reliable, you're the steady foundation that others can always count on",
            "Your determination and strong work ethic help you achieve your goals",
            "You're incredibly loyal and value deep, lasting relationships",
            "Your practical nature and attention to detail make you highly capable"
        ]
        case "🐅": return [
            "Brave and confident, you have a natural leadership quality that draws people to you",
            "Your adventurous spirit and love of challenges make life exciting",
            "You're incredibly competitive and always strive to be the best",
            "Your generosity and warm heart make you a beloved friend and family member"
        ]
        case "🐇": return [
            "Gentle and kind, you have a peaceful nature that brings calm to any situation",
            "Your artistic talents and appreciation for beauty enrich your life and others'",
            "You're incredibly diplomatic and always know the right thing to say",
            "Your intuition and sensitivity help you understand others deeply"
        ]
        case "🐉": return [
            "Powerful and charismatic, you have a magnetic presence that commands attention",
            "Your creativity and imagination know no bounds",
            "You're incredibly lucky and often find success through unexpected opportunities",
            "Your generosity and desire to help others make you a natural leader"
        ]
        case "🐍": return [
            "Wise and mysterious, you have an intuitive understanding of life's deeper meanings",
            "Your analytical mind and attention to detail help you solve complex problems",
            "You're incredibly determined and never give up on what you want",
            "Your elegance and sophistication make you stand out in any crowd"
        ]
        case "🐎": return [
            "Energetic and enthusiastic, you bring excitement and joy wherever you go",
            "Your love of freedom and adventure drives you to explore new horizons",
            "You're incredibly optimistic and always see the bright side of life",
            "Your natural charm and social skills make you popular with everyone"
        ]
        case "🐐": return [
            "Creative and artistic, you have a unique perspective that brings beauty to the world",
            "Your gentle nature and empathy make you a wonderful friend and partner",
            "You're incredibly patient and understanding with others",
            "Your imagination and dreamy nature inspire those around you"
        ]
        case "🐒": return [
            "Clever and witty, you have a sharp mind that can solve any puzzle",
            "Your adaptability and quick thinking help you succeed in any situation",
            "You're incredibly curious and love learning new things",
            "Your sense of humor and playful nature make you fun to be around"
        ]
        case "🐓": return [
            "Confident and talented, you have a natural flair for performance and leadership",
            "Your attention to detail and perfectionism help you excel in everything you do",
            "You're incredibly honest and always speak your mind",
            "Your courage and determination inspire others to follow their dreams"
        ]
        case "🐕": return [
            "Loyal and honest, you're the most trustworthy friend anyone could ask for",
            "Your sense of justice and fairness drives you to protect those you care about",
            "You're incredibly kind and always willing to help others",
            "Your intelligence and intuition help you understand people's true intentions"
        ]
        case "🐖": return [
            "Compassionate and generous, you have a heart of gold that touches everyone you meet",
            "Your optimistic nature and positive outlook on life are contagious",
            "You're incredibly honest and always keep your promises",
            "Your love of comfort and good food brings joy to those around you"
        ]
        default: return ["Personality traits not available"]
        }
    }
    
    private func getStrengths() -> [String] {
        switch chineseZodiacAnimal {
        case "🐀": return ["Quick-witted", "Resourceful", "Ambitious", "Charming", "Adaptable"]
        case "🐂": return ["Patient", "Reliable", "Determined", "Loyal", "Hardworking"]
        case "🐅": return ["Brave", "Confident", "Competitive", "Generous", "Adventurous"]
        case "🐇": return ["Gentle", "Artistic", "Diplomatic", "Intuitive", "Peaceful"]
        case "🐉": return ["Powerful", "Charismatic", "Creative", "Lucky", "Generous"]
        case "🐍": return ["Wise", "Mysterious", "Analytical", "Determined", "Elegant"]
        case "🐎": return ["Energetic", "Enthusiastic", "Optimistic", "Charming", "Free-spirited"]
        case "🐐": return ["Creative", "Artistic", "Gentle", "Patient", "Imaginative"]
        case "🐒": return ["Clever", "Witty", "Adaptable", "Curious", "Playful"]
        case "🐓": return ["Confident", "Talented", "Detail-oriented", "Honest", "Courageous"]
        case "🐕": return ["Loyal", "Honest", "Just", "Kind", "Intelligent"]
        case "🐖": return ["Compassionate", "Generous", "Optimistic", "Honest", "Loving"]
        default: return ["Strengths not available"]
        }
    }
    
    private func getChallenges() -> [String] {
        switch chineseZodiacAnimal {
        case "🐀": return ["Impatience", "Greed", "Over-ambition", "Restlessness"]
        case "🐂": return ["Stubbornness", "Rigidity", "Slow to change", "Overly serious"]
        case "🐅": return ["Impulsiveness", "Arrogance", "Recklessness", "Impatience"]
        case "🐇": return ["Indecisiveness", "Over-sensitivity", "Timidity", "Escapism"]
        case "🐉": return ["Arrogance", "Impatience", "Overconfidence", "Temper"]
        case "🐍": return ["Jealousy", "Suspicion", "Vengefulness", "Secretiveness"]
        case "🐎": return ["Impatience", "Restlessness", "Inconsistency", "Overconfidence"]
        case "🐐": return ["Indecisiveness", "Pessimism", "Over-sensitivity", "Laziness"]
        case "🐒": return ["Restlessness", "Impatience", "Sarcasm", "Inconsistency"]
        case "🐓": return ["Arrogance", "Impatience", "Over-critical", "Stubbornness"]
        case "🐕": return ["Cynicism", "Suspicion", "Over-protectiveness", "Stubbornness"]
        case "🐖": return ["Naivety", "Over-trusting", "Laziness", "Materialistic"]
        default: return ["Challenges not available"]
        }
    }
    
    private func getElement() -> String {
        switch chineseZodiacAnimal {
        case "🐀", "🐅", "🐉", "🐎", "🐒": return "Yang"
        case "🐂", "🐇", "🐍", "🐐", "🐓", "🐕", "🐖": return "Yin"
        default: return "Unknown"
        }
    }
    
    private func getLuckyNumbers() -> String {
        switch chineseZodiacAnimal {
        case "🐀": return "2, 3"
        case "🐂": return "1, 4"
        case "🐅": return "1, 3, 4"
        case "🐇": return "3, 4, 6"
        case "🐉": return "1, 6, 7"
        case "🐍": return "2, 8, 9"
        case "🐎": return "2, 3, 7"
        case "🐐": return "2, 7"
        case "🐒": return "4, 9"
        case "🐓": return "5, 7, 8"
        case "🐕": return "3, 4, 9"
        case "🐖": return "2, 5, 8"
        default: return "Unknown"
        }
    }
    
    private func getCompatibility() -> String {
        switch chineseZodiacAnimal {
        case "🐀": return "Best matches: Dragon, Monkey, Ox. Your quick wit and ambition pair perfectly with these signs who appreciate your resourcefulness and drive."
        case "🐂": return "Best matches: Rat, Snake, Rooster. Your steady nature and loyalty create strong bonds with these signs who value reliability and commitment."
        case "🐅": return "Best matches: Horse, Dog, Pig. Your bravery and confidence attract these signs who admire your leadership and adventurous spirit."
        case "🐇": return "Best matches: Goat, Pig, Dog. Your gentle nature and artistic soul connect deeply with these peaceful and creative signs."
        case "🐉": return "Best matches: Rat, Monkey, Rooster. Your charisma and power draw these ambitious signs who share your drive for success."
        case "🐍": return "Best matches: Ox, Rooster, Dragon. Your wisdom and mystery intrigue these signs who appreciate depth and intelligence."
        case "🐎": return "Best matches: Tiger, Goat, Dog. Your energy and enthusiasm inspire these signs who love adventure and positive energy."
        case "🐐": return "Best matches: Rabbit, Horse, Pig. Your creativity and gentleness harmonize beautifully with these artistic and peaceful signs."
        case "🐒": return "Best matches: Rat, Dragon, Snake. Your cleverness and adaptability complement these intelligent and strategic signs."
        case "🐓": return "Best matches: Ox, Snake, Dragon. Your confidence and talent impress these signs who value excellence and determination."
        case "🐕": return "Best matches: Tiger, Horse, Rabbit. Your loyalty and honesty create strong bonds with these trustworthy and kind signs."
        case "🐖": return "Best matches: Rabbit, Goat, Tiger. Your compassion and generosity warm the hearts of these gentle and caring signs."
        default: return "Compatibility information not available"
        }
    }
}

#Preview {
    ChineseZodiacPopupView(chineseZodiacAnimal: "🐉", contactName: "John Doe")
} 