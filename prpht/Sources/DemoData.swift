//
//  DemoData.swift
//  prpht
//
//  Generated from prpht/index.html - do not edit by hand.
//  All demo content: fixtures/markets, friends' bets, chat threads and
//  group-bet sweepstakes, plus the shared model structs.
//

import Foundation

struct Sel {
    let name: String
    let odds: Double
    let line: String
}

struct Fixture {
    let id: String
    let sport: String
    let colorHex: String
    let league: String
    let time: String
    let match: String
    let market: String
    let selections: [Sel]
    let target: Int
    var likes: Int = 0
}

struct FriendBet {
    let who: String
    let ago: String
    let matchId: String
    let selection: String
    let match: String
    let odds: Double
    let line: String
    let note: String
}

struct ChatMsg {
    let fromMe: Bool
    let kindBet: Bool
    let matchId: String
    let selection: String
    let match: String
    let odds: Double
    let line: String
    let text: String
    let t: String
}

struct Conversation {
    let id: String
    let who: String
    let colorHex: String
    let msgs: [ChatMsg]
}

struct SweepEntrant { let who: String }

struct Sweepstake {
    let id: String
    let name: String
    let host: String
    let event: String
    let runners: [String]
    var entrants: [SweepEntrant]
    let status: String
}

let sportsList = ["For You", "Politics", "Gaming", "Energy", "Tech", "Crypto",
                  "Football", "Racing", "Tennis", "Cricket", "Basketball", "Love Island"]
let marketSports = ["Politics", "Gaming", "Energy", "Tech", "Crypto"]
let fyIcon: [String: String] = ["y1": "Football", "y2": "Football", "y3": "Football", "y4": "Racing", "y5": "Tennis", "y6": "Football", "y7": "Basketball", "y8": "Football"]

let demoFixtures: [Fixture] = [
    Fixture(id: "y1", sport: "For You", colorHex: "#C8563B", league: "Premier League", time: "12:30 - Sat 26 Jul",
              match: "Arsenal v Chelsea", market: "Bet Builder", selections: [Sel(name: "Saka & Odegaard", odds: 29, line: "Saka to assist Odegaard and Odegaard to assist Saka")], target: 0),
    Fixture(id: "y2", sport: "For You", colorHex: "#6CABDD", league: "Premier League", time: "17:30 - Sat 26 Jul",
              match: "Man City v Liverpool", market: "Long Shot", selections: [Sel(name: "Haaland hat-trick", odds: 41, line: "Haaland to score a hat-trick and Manchester City to win 4-0")], target: 0),
    Fixture(id: "y3", sport: "For You", colorHex: "#004D98", league: "La Liga", time: "16:00 - Sun 27 Jul",
              match: "Barcelona v Real Madrid", market: "Bet Builder", selections: [Sel(name: "Goals in both halves", odds: 12, line: "Both teams to score in both halves of El Clasico")], target: 0),
    Fixture(id: "y4", sport: "For You", colorHex: "#A6BE47", league: "Aintree", time: "16:00 - Tomorrow",
              match: "Grand National", market: "Double", selections: [Sel(name: "Rambler & Maximus", odds: 34, line: "Corach Rambler to win the Grand National and I Am Maximus to place")], target: 0),
    Fixture(id: "y5", sport: "For You", colorHex: "#61AD34", league: "Wimbledon", time: "13:00 - Wed 30 Jul",
              match: "Djokovic v Alcaraz", market: "Bet Builder", selections: [Sel(name: "Straight sets", odds: 8.5, line: "Djokovic to win in straight sets and drop fewer than six games")], target: 0),
    Fixture(id: "y6", sport: "For You", colorHex: "#B84A5A", league: "Bundesliga", time: "14:30 - Sun 27 Jul",
              match: "Bayern Munich v Dortmund", market: "Bet Builder", selections: [Sel(name: "Corners & cards", odds: 16, line: "Over 12 corners and 5 or more cards in Der Klassiker")], target: 0),
    Fixture(id: "y7", sport: "For You", colorHex: "#FDB927", league: "NBA", time: "01:30 - Wed 30 Jul",
              match: "Lakers v Warriors", market: "Long Shot", selections: [Sel(name: "Curry 8 threes", odds: 23, line: "Steph Curry to sink 8 threes and the Warriors to win by 20")], target: 0),
    Fixture(id: "y8", sport: "For You", colorHex: "#004170", league: "Ligue 1", time: "20:00 - Tue 29 Jul",
              match: "PSG v Marseille", market: "Wildcard", selections: [Sel(name: "Keeper to score", odds: 66, line: "Any goalkeeper to score and the match to finish level")], target: 0),
    Fixture(id: "y9", sport: "For You", colorHex: "#FF2E7E", league: "Love Island", time: "21:00 - Tonight",
              match: "Villa Specials", market: "Long Shot", selections: [Sel(name: "Aidan dumped & double dumping", odds: 34, line: "Aidan to be dumped tonight and the villa to lose two couples by Sunday")], target: 0),
    Fixture(id: "f1", sport: "Football", colorHex: "#C8563B", league: "Premier League", time: "12:30 - Sat 26 Jul",
              match: "Arsenal v Chelsea", market: "Match Result", selections: [Sel(name: "Arsenal", odds: 2.1, line: "Arsenal to beat Chelsea within 90 minutes"), Sel(name: "Draw", odds: 3.4, line: "Arsenal and Chelsea to share the points"), Sel(name: "Chelsea", odds: 3.8, line: "Chelsea to win away at the Emirates")], target: 0),
    Fixture(id: "f2", sport: "Football", colorHex: "#6CABDD", league: "Premier League", time: "17:30 - Sat 26 Jul",
              match: "Man City v Liverpool", market: "Match Result", selections: [Sel(name: "Man City", odds: 1.9, line: "Manchester City to beat Liverpool within 90 minutes"), Sel(name: "Draw", odds: 3.6, line: "Manchester City and Liverpool to share the points"), Sel(name: "Liverpool", odds: 4.2, line: "Liverpool to win away at the Etihad")], target: 1),
    Fixture(id: "f3", sport: "Football", colorHex: "#004D98", league: "La Liga", time: "16:00 - Sun 27 Jul",
              match: "Barcelona v Real Madrid", market: "Match Result", selections: [Sel(name: "Barcelona", odds: 2.5, line: "Barcelona to win El Clasico within 90 minutes"), Sel(name: "Draw", odds: 3.3, line: "El Clasico to finish all square"), Sel(name: "Real Madrid", odds: 2.9, line: "Real Madrid to win away at the Nou Camp")], target: 0),
    Fixture(id: "f4", sport: "Football", colorHex: "#B84A5A", league: "Bundesliga", time: "14:30 - Sun 27 Jul",
              match: "Bayern Munich v Dortmund", market: "Match Result", selections: [Sel(name: "Bayern Munich", odds: 1.75, line: "Bayern Munich to beat Dortmund within 90 minutes"), Sel(name: "Draw", odds: 3.8, line: "Bayern Munich and Dortmund to share the points"), Sel(name: "Dortmund", odds: 5, line: "Dortmund to win Der Klassiker in Munich")], target: 2),
    Fixture(id: "f5", sport: "Football", colorHex: "#9ca3af", league: "Serie A", time: "19:45 - Mon 28 Jul",
              match: "Juventus v AC Milan", market: "Match Result", selections: [Sel(name: "Juventus", odds: 2.4, line: "Juventus to beat AC Milan within 90 minutes"), Sel(name: "Draw", odds: 3.1, line: "Juventus and AC Milan to share the points"), Sel(name: "AC Milan", odds: 2.8, line: "AC Milan to win away in Turin")], target: 1),
    Fixture(id: "f6", sport: "Football", colorHex: "#004170", league: "Ligue 1", time: "20:00 - Tue 29 Jul",
              match: "PSG v Marseille", market: "Match Result", selections: [Sel(name: "PSG", odds: 1.45, line: "PSG to beat Marseille within 90 minutes"), Sel(name: "Draw", odds: 4.5, line: "Le Classique to finish all square"), Sel(name: "Marseille", odds: 6.5, line: "Marseille to win away in Paris")], target: 0),
    Fixture(id: "r1", sport: "Racing", colorHex: "#A6BE47", league: "Ascot", time: "13:15 - Today",
              match: "King George VI Stakes", market: "To Win", selections: [Sel(name: "Auguste Rodin", odds: 2.5, line: "Auguste Rodin to win the King George VI Stakes"), Sel(name: "Rebel Romance", odds: 4, line: "Rebel Romance to win the King George VI Stakes"), Sel(name: "Luxembourg", odds: 6.5, line: "Luxembourg to win the King George VI Stakes")], target: 0),
    Fixture(id: "r2", sport: "Racing", colorHex: "#A6BE47", league: "Cheltenham", time: "14:30 - Today",
              match: "Gold Cup", market: "To Win", selections: [Sel(name: "Galopin Des Champs", odds: 1.8, line: "Galopin Des Champs to win the Cheltenham Gold Cup"), Sel(name: "Fastorslow", odds: 5, line: "Fastorslow to win the Cheltenham Gold Cup"), Sel(name: "Gerri Colombe", odds: 7, line: "Gerri Colombe to win the Cheltenham Gold Cup")], target: 1),
    Fixture(id: "r3", sport: "Racing", colorHex: "#A6BE47", league: "Newmarket", time: "15:45 - Today",
              match: "Guineas Stakes", market: "To Win", selections: [Sel(name: "City Of Troy", odds: 2.1, line: "City Of Troy to win the Guineas Stakes"), Sel(name: "Rosallion", odds: 3.5, line: "Rosallion to win the Guineas Stakes"), Sel(name: "Ghostwriter", odds: 8, line: "Ghostwriter to win the Guineas Stakes")], target: 0),
    Fixture(id: "r4", sport: "Racing", colorHex: "#A6BE47", league: "Aintree", time: "16:00 - Tomorrow",
              match: "Grand National", market: "To Win", selections: [Sel(name: "Corach Rambler", odds: 6, line: "Corach Rambler to win the Grand National"), Sel(name: "I Am Maximus", odds: 8, line: "I Am Maximus to win the Grand National"), Sel(name: "Meetingofthewaters", odds: 10, line: "Meetingofthewaters to win the Grand National")], target: 2),
    Fixture(id: "r5", sport: "Racing", colorHex: "#A6BE47", league: "Goodwood", time: "17:15 - Tomorrow",
              match: "Sussex Stakes", market: "To Win", selections: [Sel(name: "Paddington", odds: 1.5, line: "Paddington to win the Sussex Stakes"), Sel(name: "Inspiral", odds: 4.5, line: "Inspiral to win the Sussex Stakes"), Sel(name: "Chaldean", odds: 9, line: "Chaldean to win the Sussex Stakes")], target: 0),
    Fixture(id: "r6", sport: "Racing", colorHex: "#A6BE47", league: "York", time: "18:30 - Tomorrow",
              match: "Juddmonte International", market: "To Win", selections: [Sel(name: "Mostahdaf", odds: 3, line: "Mostahdaf to win the Juddmonte International"), Sel(name: "Nashwa", odds: 5, line: "Nashwa to win the Juddmonte International"), Sel(name: "King Of Steel", odds: 5.5, line: "King Of Steel to win the Juddmonte International")], target: 1),
    Fixture(id: "t1", sport: "Tennis", colorHex: "#61AD34", league: "Wimbledon", time: "13:00 - Wed 30 Jul",
              match: "Djokovic v Alcaraz", market: "Match Winner", selections: [Sel(name: "Djokovic", odds: 1.65, line: "Novak Djokovic to beat Carlos Alcaraz at Wimbledon"), Sel(name: "Alcaraz", odds: 2.2, line: "Carlos Alcaraz to beat Novak Djokovic at Wimbledon")], target: 0),
    Fixture(id: "t2", sport: "Tennis", colorHex: "#00549A", league: "US Open", time: "18:00 - Wed 30 Jul",
              match: "Sinner v Medvedev", market: "Match Winner", selections: [Sel(name: "Sinner", odds: 1.8, line: "Jannik Sinner to beat Daniil Medvedev at the US Open"), Sel(name: "Medvedev", odds: 2, line: "Daniil Medvedev to beat Jannik Sinner at the US Open")], target: 1),
    Fixture(id: "t3", sport: "Tennis", colorHex: "#A9C23F", league: "Roland Garros", time: "11:00 - Thu 31 Jul",
              match: "Swiatek v Sabalenka", market: "Match Winner", selections: [Sel(name: "Swiatek", odds: 1.4, line: "Iga Swiatek to beat Aryna Sabalenka at Roland Garros"), Sel(name: "Sabalenka", odds: 2.9, line: "Aryna Sabalenka to beat Iga Swiatek at Roland Garros")], target: 0),
    Fixture(id: "t4", sport: "Tennis", colorHex: "#0078D7", league: "Australian Open", time: "09:00 - Thu 31 Jul",
              match: "Gauff v Rybakina", market: "Match Winner", selections: [Sel(name: "Gauff", odds: 2.1, line: "Coco Gauff to beat Elena Rybakina in Melbourne"), Sel(name: "Rybakina", odds: 1.7, line: "Elena Rybakina to beat Coco Gauff in Melbourne")], target: 1),
    Fixture(id: "t5", sport: "Tennis", colorHex: "#A6BE47", league: "Miami Open", time: "14:00 - Fri 01 Aug",
              match: "Zverev v Tsitsipas", market: "Match Winner", selections: [Sel(name: "Zverev", odds: 1.9, line: "Alexander Zverev to beat Stefanos Tsitsipas in Miami"), Sel(name: "Tsitsipas", odds: 1.9, line: "Stefanos Tsitsipas to beat Alexander Zverev in Miami")], target: 0),
    Fixture(id: "t6", sport: "Tennis", colorHex: "#A6BE47", league: "Indian Wells", time: "16:30 - Fri 01 Aug",
              match: "Jabeur v Pegula", market: "Match Winner", selections: [Sel(name: "Jabeur", odds: 2.3, line: "Ons Jabeur to beat Jessica Pegula at Indian Wells"), Sel(name: "Pegula", odds: 1.6, line: "Jessica Pegula to beat Ons Jabeur at Indian Wells")], target: 1),
    Fixture(id: "c1", sport: "Cricket", colorHex: "#A6BE47", league: "The Ashes", time: "11:00 - Wed 30 Jul",
              match: "England v Australia", market: "Match Result", selections: [Sel(name: "England", odds: 2.8, line: "England to beat Australia in the Ashes test"), Sel(name: "Draw", odds: 3.2, line: "The Ashes test to end in a draw"), Sel(name: "Australia", odds: 2.2, line: "Australia to beat England in the Ashes test")], target: 1),
    Fixture(id: "c2", sport: "Cricket", colorHex: "#A6BE47", league: "T20 World Cup", time: "14:00 - Wed 30 Jul",
              match: "India v Pakistan", market: "Match Winner", selections: [Sel(name: "India", odds: 1.6, line: "India to beat Pakistan at the T20 World Cup"), Sel(name: "Pakistan", odds: 2.3, line: "Pakistan to beat India at the T20 World Cup")], target: 0),
    Fixture(id: "c3", sport: "Cricket", colorHex: "#A6BE47", league: "IPL", time: "16:00 - Thu 31 Jul",
              match: "Chennai v Mumbai", market: "Match Winner", selections: [Sel(name: "Chennai", odds: 1.9, line: "Chennai Super Kings to beat the Mumbai Indians"), Sel(name: "Mumbai", odds: 1.9, line: "Mumbai Indians to beat the Chennai Super Kings")], target: 1),
    Fixture(id: "c4", sport: "Cricket", colorHex: "#A6BE47", league: "Test Series", time: "09:00 - Fri 01 Aug",
              match: "South Africa v New Zealand", market: "Match Result", selections: [Sel(name: "South Africa", odds: 2.1, line: "South Africa to beat New Zealand in the test"), Sel(name: "Draw", odds: 4.5, line: "The test match to end in a draw"), Sel(name: "New Zealand", odds: 2.6, line: "New Zealand to beat South Africa in the test")], target: 0),
    Fixture(id: "c5", sport: "Cricket", colorHex: "#A6BE47", league: "Big Bash", time: "08:30 - Sat 02 Aug",
              match: "Perth Scorchers v Sydney Sixers", market: "Match Winner", selections: [Sel(name: "Perth Scorchers", odds: 1.75, line: "Perth Scorchers to beat the Sydney Sixers"), Sel(name: "Sydney Sixers", odds: 2.1, line: "Sydney Sixers to beat the Perth Scorchers")], target: 1),
    Fixture(id: "c6", sport: "Cricket", colorHex: "#A6BE47", league: "The Hundred", time: "18:00 - Sun 03 Aug",
              match: "Oval Invincibles v London Spirit", market: "Match Winner", selections: [Sel(name: "Oval Invincibles", odds: 1.85, line: "Oval Invincibles to beat London Spirit"), Sel(name: "London Spirit", odds: 1.95, line: "London Spirit to beat Oval Invincibles")], target: 0),
    Fixture(id: "b1", sport: "Basketball", colorHex: "#FDB927", league: "NBA", time: "01:30 - Wed 30 Jul",
              match: "Lakers v Warriors", market: "Moneyline", selections: [Sel(name: "Lakers", odds: 2.1, line: "The Lakers to beat the Warriors"), Sel(name: "Warriors", odds: 1.75, line: "The Warriors to beat the Lakers")], target: 1),
    Fixture(id: "b2", sport: "Basketball", colorHex: "#007A33", league: "NBA", time: "02:00 - Wed 30 Jul",
              match: "Celtics v Heat", market: "Moneyline", selections: [Sel(name: "Celtics", odds: 1.5, line: "The Celtics to beat the Heat"), Sel(name: "Heat", odds: 2.6, line: "The Heat to beat the Celtics")], target: 0),
    Fixture(id: "b3", sport: "Basketball", colorHex: "#A6BE47", league: "EuroLeague", time: "19:30 - Thu 31 Jul",
              match: "Real Madrid v Olympiacos", market: "Moneyline", selections: [Sel(name: "Real Madrid", odds: 1.65, line: "Real Madrid to beat Olympiacos in the EuroLeague"), Sel(name: "Olympiacos", odds: 2.25, line: "Olympiacos to beat Real Madrid in the EuroLeague")], target: 0),
    Fixture(id: "b4", sport: "Basketball", colorHex: "#1D1160", league: "NBA", time: "03:00 - Fri 01 Aug",
              match: "Nuggets v Suns", market: "Moneyline", selections: [Sel(name: "Nuggets", odds: 1.85, line: "The Nuggets to beat the Suns"), Sel(name: "Suns", odds: 1.95, line: "The Suns to beat the Nuggets")], target: 1),
    Fixture(id: "b5", sport: "Basketball", colorHex: "#00471B", league: "NBA", time: "04:30 - Sat 02 Aug",
              match: "Bucks v 76ers", market: "Moneyline", selections: [Sel(name: "Bucks", odds: 1.7, line: "The Bucks to beat the 76ers"), Sel(name: "76ers", odds: 2.15, line: "The 76ers to beat the Bucks")], target: 0),
    Fixture(id: "b6", sport: "Basketball", colorHex: "#A6BE47", league: "EuroLeague", time: "20:00 - Sun 03 Aug",
              match: "Panathinaikos v Monaco", market: "Moneyline", selections: [Sel(name: "Panathinaikos", odds: 1.9, line: "Panathinaikos to beat Monaco in the EuroLeague"), Sel(name: "Monaco", odds: 1.9, line: "Monaco to beat Panathinaikos in the EuroLeague")], target: 1),
    Fixture(id: "li1", sport: "Love Island", colorHex: "#FF2E7E", league: "Love Island", time: "21:00 - Tonight",
              match: "Next Boy Dumped", market: "Dumping", selections: [Sel(name: "Aidan", odds: 6, line: "Aidan to be the next boy dumped from the island"), Sel(name: "Marco", odds: 4, line: "Marco to be the next boy dumped from the island"), Sel(name: "Reece", odds: 3, line: "Reece to be the next boy dumped from the island")], target: 0),
    Fixture(id: "li2", sport: "Love Island", colorHex: "#F43F5E", league: "Love Island", time: "21:00 - Tonight",
              match: "Next Girl Dumped", market: "Dumping", selections: [Sel(name: "Mimi", odds: 4.5, line: "Mimi to be the next girl dumped from the island"), Sel(name: "Cassie", odds: 3, line: "Cassie to be the next girl dumped from the island"), Sel(name: "Nadia", odds: 7, line: "Nadia to be the next girl dumped from the island")], target: 0),
    Fixture(id: "li3", sport: "Love Island", colorHex: "#EC4899", league: "Villa Special", time: "21:00 - Wed 05 Aug",
              match: "Recoupling", market: "Couple Up", selections: [Sel(name: "Aidan & Ella", odds: 3.5, line: "Aidan and Ella to couple up at the next recoupling"), Sel(name: "Marco & Cassie", odds: 5, line: "Marco and Cassie to couple up at the next recoupling"), Sel(name: "Reece & Mimi", odds: 9, line: "Reece and Mimi to couple up at the next recoupling")], target: 1),
    Fixture(id: "li4", sport: "Love Island", colorHex: "#FB7185", league: "Casa Amor", time: "21:00 - Thu 06 Aug",
              match: "Aidan at Casa Amor", market: "Loyalty", selections: [Sel(name: "Head turned", odds: 2.75, line: "Aidan to walk back in coupled up with a Casa Amor girl"), Sel(name: "Stays loyal", odds: 1.4, line: "Aidan to stay loyal and walk back in on his own")], target: 0),
    Fixture(id: "li5", sport: "Love Island", colorHex: "#E11D48", league: "Villa Special", time: "21:00 - Fri 07 Aug",
              match: "First to Say I Love You", market: "Specials", selections: [Sel(name: "Ella", odds: 3, line: "Ella to be the first islander to say I love you"), Sel(name: "Aidan", odds: 5, line: "Aidan to be the first islander to say I love you"), Sel(name: "Marco", odds: 8, line: "Marco to be the first islander to say I love you")], target: 1),
    Fixture(id: "li6", sport: "Love Island", colorHex: "#D946EF", league: "Movie Night", time: "21:00 - Sat 08 Aug",
              match: "Tears at Movie Night", market: "Specials", selections: [Sel(name: "Over 3.5 tears", odds: 1.8, line: "Four or more islanders to cry at Movie Night"), Sel(name: "Under 3.5 tears", odds: 2, line: "Fewer than four islanders to cry at Movie Night")], target: 0),
    Fixture(id: "li7", sport: "Love Island", colorHex: "#FF4D6D", league: "Love Island", time: "21:00 - Sun 09 Aug",
              match: "Series Winner", market: "Outright", selections: [Sel(name: "Ella", odds: 4, line: "Ella to be crowned the winner of Love Island"), Sel(name: "Cassie", odds: 5, line: "Cassie to be crowned the winner of Love Island"), Sel(name: "Aidan", odds: 11, line: "Aidan to be crowned the winner of Love Island")], target: 0),
    Fixture(id: "li8", sport: "Love Island", colorHex: "#FF7A9C", league: "Villa Special", time: "21:00 - Tonight",
              match: "Tonight in the Villa", market: "Bet Builder", selections: [Sel(name: "Dumping & bombshell", odds: 21, line: "Aidan to be dumped and a bombshell to walk in on the same episode")], target: 0),
    Fixture(id: "pm1", sport: "Politics", colorHex: "#55828B", league: "Polymarket", time: "Resolves Dec 31, 2026",
              match: "Which party wins the Senate in 2026?", market: "Politics", selections: [Sel(name: "Democratic Party", odds: 2, line: "Democratic Party to win the Senate in 2026"), Sel(name: "Republican Party", odds: 1.9, line: "Republican Party to win the Senate in 2026")], target: 0),
    Fixture(id: "pm2", sport: "Politics", colorHex: "#7D84B2", league: "Polymarket", time: "Resolves Nov 3, 2026",
              match: "Clarity Act (H.R.3633) signed into law in 2026?", market: "Politics", selections: [Sel(name: "Yes", odds: 4.5, line: "The Clarity Act (H.R.3633) to be signed into law in 2026"), Sel(name: "No", odds: 1.22, line: "The Clarity Act (H.R.3633) not to be signed into law in 2026")], target: 1),
    Fixture(id: "pm3", sport: "Politics", colorHex: "#506C64", league: "Polymarket", time: "Resolves Sep 17, 2026",
              match: "Who will Trump pick as the next Press Secretary?", market: "Politics", selections: [Sel(name: "Scott Jennings", odds: 3.3, line: "Trump to name Scott Jennings as the next Press Secretary"), Sel(name: "Anna Kelly", odds: 6.5, line: "Trump to name Anna Kelly as the next Press Secretary")], target: 0),
    Fixture(id: "pm4", sport: "Politics", colorHex: "#8FA6CB", league: "Polymarket", time: "Resolves Dec 31, 2026",
              match: "US announces end of Iranian blockade by...?", market: "Politics", selections: [Sel(name: "By October 31", odds: 2.04, line: "The US to announce the end of the Iranian blockade by October 31"), Sel(name: "By December 31", odds: 1.38, line: "The US to announce the end of the Iranian blockade by December 31")], target: 1),
    Fixture(id: "pm5", sport: "Gaming", colorHex: "#D946EF", league: "Polymarket", time: "Resolves Dec 31, 2026",
              match: "Will GTA VI be released before 2027?", market: "Gaming", selections: [Sel(name: "Yes", odds: 3, line: "GTA VI to be released before 2027"), Sel(name: "No", odds: 1.4, line: "GTA VI to slip beyond 2027")], target: 1),
    Fixture(id: "pm6", sport: "Gaming", colorHex: "#EC4899", league: "Polymarket", time: "Resolves Mar 31, 2027",
              match: "Will GTA VI hit 100M copies sold in year one?", market: "Gaming", selections: [Sel(name: "Yes", odds: 2.6, line: "GTA VI to sell 100 million copies in its first year"), Sel(name: "No", odds: 1.53, line: "GTA VI not to reach 100 million copies in its first year")], target: 0),
    Fixture(id: "pm7", sport: "Energy", colorHex: "#F9A03F", league: "Polymarket", time: "Resolves Sep 30, 2026",
              match: "Will Brent crude close above $80 in September?", market: "Energy", selections: [Sel(name: "Yes", odds: 3.75, line: "Brent crude to close above $80 a barrel in September"), Sel(name: "No", odds: 1.3, line: "Brent crude not to close above $80 a barrel in September")], target: 1),
    Fixture(id: "pm8", sport: "Energy", colorHex: "#D45113", league: "Polymarket", time: "Resolves Sep 30, 2026",
              match: "Strait of Hormuz traffic normal by September 30?", market: "Energy", selections: [Sel(name: "Yes", odds: 15, line: "Strait of Hormuz shipping traffic to return to normal by September 30"), Sel(name: "No", odds: 1.02, line: "Strait of Hormuz shipping traffic not to return to normal by September 30")], target: 1),
    Fixture(id: "pm9", sport: "Tech", colorHex: "#8FA6CB", league: "Polymarket", time: "Resolves Dec 31, 2026",
              match: "Anthropic IPO by...?", market: "Tech", selections: [Sel(name: "By Dec 31 2026", odds: 1.14, line: "Anthropic to complete its IPO by December 31 2026"), Sel(name: "Later or never", odds: 5.5, line: "Anthropic not to complete its IPO by December 31 2026")], target: 0),
    Fixture(id: "pm10", sport: "Tech", colorHex: "#55828B", league: "Polymarket", time: "Resolves Dec 31, 2026",
              match: "Will a frontier lab ship GPT-6 level models in 2026?", market: "Tech", selections: [Sel(name: "Yes", odds: 2.2, line: "A frontier lab to ship a GPT-6 level model in 2026"), Sel(name: "No", odds: 1.69, line: "No frontier lab to ship a GPT-6 level model in 2026")], target: 0),
    Fixture(id: "pm11", sport: "Tech", colorHex: "#7D84B2", league: "Polymarket", time: "Resolves Jun 30, 2027",
              match: "FDA approves a skin cancer vaccine by...?", market: "Tech", selections: [Sel(name: "By Jun 30 2027", odds: 1.45, line: "The FDA to approve a skin cancer vaccine by June 30 2027"), Sel(name: "Not by then", odds: 2.75, line: "The FDA not to approve a skin cancer vaccine by June 30 2027")], target: 0),
    Fixture(id: "pm12", sport: "Crypto", colorHex: "#F7931A", league: "Polymarket", time: "Resolves Aug 31, 2026",
              match: "What price will Bitcoin hit in August?", market: "Crypto", selections: [Sel(name: "$80,000 or higher", odds: 1.59, line: "Bitcoin to hit $80,000 or higher in August"), Sel(name: "$75,000 or lower", odds: 1.64, line: "Bitcoin to hit $75,000 or lower in August")], target: 0),
    Fixture(id: "pm13", sport: "Crypto", colorHex: "#FDB927", league: "Polymarket", time: "Resolves Dec 31, 2026",
              match: "Fed decision in September?", market: "Crypto", selections: [Sel(name: "No change", odds: 1.45, line: "The Fed to hold rates in September"), Sel(name: "25 bps increase", odds: 2.9, line: "The Fed to raise rates 25 bps in September")], target: 0),
    Fixture(id: "pm14", sport: "Crypto", colorHex: "#F9A03F", league: "Polymarket", time: "Resolves Dec 31, 2027",
              match: "Will Bitcoin close 2027 above $150k?", market: "Crypto", selections: [Sel(name: "Yes", odds: 2.5, line: "Bitcoin to close 2027 above $150,000"), Sel(name: "No", odds: 1.57, line: "Bitcoin to close 2027 at or below $150,000")], target: 0),
]

let friendsFeedData: [FriendBet] = [
    FriendBet(who: "Simon", ago: "2m", matchId: "f1", selection: "Arsenal",
              match: "Arsenal v Chelsea", odds: 2.1, line: "Arsenal to beat Chelsea within 90 minutes", note: "they are unreal at home right now"),
    FriendBet(who: "Priya", ago: "11m", matchId: "y2", selection: "Haaland hat-trick",
              match: "Man City v Liverpool", odds: 41, line: "Haaland to score a hat-trick and Manchester City to win 4-0", note: "one pound to change my life"),
    FriendBet(who: "Dee", ago: "24m", matchId: "r4", selection: "Corach Rambler",
              match: "Grand National", odds: 6, line: "Corach Rambler to win the Grand National", note: "dad had a dream about this horse"),
    FriendBet(who: "Marcus", ago: "38m", matchId: "t1", selection: "Djokovic",
              match: "Djokovic v Alcaraz", odds: 1.65, line: "Novak Djokovic to beat Carlos Alcaraz at Wimbledon", note: "never bet against the man"),
    FriendBet(who: "Aoife", ago: "1h", matchId: "y8", selection: "Keeper to score",
              match: "PSG v Marseille", odds: 66, line: "Any goalkeeper to score and the match to finish level", note: "absolutely no notes. just vibes"),
    FriendBet(who: "Tom", ago: "2h", matchId: "f4", selection: "Dortmund",
              match: "Bayern Munich v Dortmund", odds: 5, line: "Dortmund to win Der Klassiker in Munich", note: "value is value"),
    FriendBet(who: "Dee", ago: "3m", matchId: "f1", selection: "Chelsea",
              match: "Arsenal v Chelsea", odds: 3.8, line: "Chelsea to win away at the Emirates", note: "someone has to say it"),
    FriendBet(who: "Aoife", ago: "9m", matchId: "f1", selection: "Draw",
              match: "Arsenal v Chelsea", odds: 3.4, line: "Arsenal and Chelsea to share the points", note: "the sensible money"),
    FriendBet(who: "Marcus", ago: "15m", matchId: "f1", selection: "Arsenal",
              match: "Arsenal v Chelsea", odds: 2.1, line: "Arsenal to beat Chelsea within 90 minutes", note: "with Simon on this one"),
    FriendBet(who: "Tom", ago: "20m", matchId: "y1", selection: "Saka & Odegaard",
              match: "Arsenal v Chelsea", odds: 29, line: "Saka to assist Odegaard and Odegaard to assist Saka", note: "the dream ticket"),
    FriendBet(who: "Simon", ago: "31m", matchId: "f2", selection: "Liverpool",
              match: "Man City v Liverpool", odds: 4.2, line: "Liverpool to win away at the Etihad", note: "they owe us one"),
    FriendBet(who: "Dee", ago: "44m", matchId: "f2", selection: "Man City",
              match: "Man City v Liverpool", odds: 1.9, line: "Manchester City to beat Liverpool within 90 minutes", note: "boring but right"),
    FriendBet(who: "Priya", ago: "52m", matchId: "f4", selection: "Bayern Munich",
              match: "Bayern Munich v Dortmund", odds: 1.75, line: "Bayern Munich to beat Dortmund within 90 minutes", note: "sorry Tom"),
    FriendBet(who: "Simon", ago: "1h", matchId: "t1", selection: "Alcaraz",
              match: "Djokovic v Alcaraz", odds: 2.2, line: "Carlos Alcaraz to beat Novak Djokovic at Wimbledon", note: "new era, Marcus"),
    FriendBet(who: "Aoife", ago: "1h", matchId: "r4", selection: "I Am Maximus",
              match: "Grand National", odds: 8, line: "I Am Maximus to win the Grand National", note: "best name in the race"),
    FriendBet(who: "Marcus", ago: "2h", matchId: "r4", selection: "Corach Rambler",
              match: "Grand National", odds: 6, line: "Corach Rambler to win the Grand National", note: "following Dee blindly"),
]

let conversationsData: [Conversation] = [
    Conversation(id: "m1", who: "Simon", colorHex: "#C8563B", msgs: [ChatMsg(fromMe: false, kindBet: false, matchId: "", selection: "", match: "", odds: 0, line: "", text: "you seeing this Arsenal price?", t: "09:12"),
                       ChatMsg(fromMe: false, kindBet: true, matchId: "f1", selection: "Arsenal", match: "Arsenal v Chelsea", odds: 2.1, line: "Arsenal to beat Chelsea within 90 minutes", text: "", t: "09:12"),
                       ChatMsg(fromMe: true, kindBet: false, matchId: "", selection: "", match: "", odds: 0, line: "", text: "go on then", t: "09:15")]),
    Conversation(id: "m2", who: "Priya", colorHex: "#6CABDD", msgs: [ChatMsg(fromMe: false, kindBet: false, matchId: "", selection: "", match: "", odds: 0, line: "", text: "put a quid on this and retire", t: "08:40"),
                       ChatMsg(fromMe: false, kindBet: true, matchId: "y2", selection: "Haaland hat-trick", match: "Man City v Liverpool", odds: 41, line: "Haaland to score a hat-trick and Manchester City to win 4-0", text: "", t: "08:40")]),
    Conversation(id: "m3", who: "Dee", colorHex: "#A6BE47", msgs: [ChatMsg(fromMe: true, kindBet: false, matchId: "", selection: "", match: "", odds: 0, line: "", text: "grand national shout?", t: "Yesterday"),
                       ChatMsg(fromMe: false, kindBet: false, matchId: "", selection: "", match: "", odds: 0, line: "", text: "corach rambler. trust me", t: "Yesterday")]),
    Conversation(id: "m4", who: "Marcus", colorHex: "#61AD34", msgs: [ChatMsg(fromMe: false, kindBet: false, matchId: "", selection: "", match: "", odds: 0, line: "", text: "wimbledon final is free money", t: "Yesterday")]),
]

let sweepstakesSeed: [Sweepstake] = [
    Sweepstake(id: "s1", name: "Office Grand National Sweep", host: "Priya", event: "Grand National",
               runners: ["Corach Rambler", "I Am Maximus", "Meetingofthewaters", "Galopin Des Champs", "Fastorslow", "Gerri Colombe"], entrants: [SweepEntrant(who: "Priya"), SweepEntrant(who: "Simon"), SweepEntrant(who: "Dee"), SweepEntrant(who: "Marcus")], status: "open"),
    Sweepstake(id: "s2", name: "Five-a-side lads: Wimbledon", host: "Marcus", event: "Wimbledon",
               runners: ["Djokovic", "Alcaraz", "Sinner", "Medvedev", "Zverev", "Tsitsipas"], entrants: [SweepEntrant(who: "Marcus"), SweepEntrant(who: "Tom"), SweepEntrant(who: "Aoife")], status: "open"),
    Sweepstake(id: "s3", name: "Sunday league sweep", host: "Dee", event: "Bayern Munich v Dortmund",
               runners: ["Bayern Munich", "Draw", "Dortmund"], entrants: [SweepEntrant(who: "Dee"), SweepEntrant(who: "Aoife"), SweepEntrant(who: "Tom")], status: "drawn"),
]

let sweepEvents: [(event: String, runners: [String])] = [
    ("Arsenal v Chelsea", ["Arsenal", "Draw", "Chelsea"]),
    ("Man City v Liverpool", ["Man City", "Draw", "Liverpool"]),
    ("Grand National", ["Corach Rambler", "I Am Maximus", "Meetingofthewaters",
                        "Paddington", "Galopin Des Champs", "Fastorslow"]),
    ("Bayern Munich v Dortmund", ["Bayern Munich", "Draw", "Dortmund"]),
    ("Wimbledon final", ["Djokovic", "Alcaraz", "Sinner", "Medvedev"]),
]

let allFriends = ["Simon", "Priya", "Dee", "Marcus", "Aoife", "Tom"]
