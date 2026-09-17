import Foundation

nonisolated enum AppReviewText {
    private static let reviewText: [Character] = Array("""
        At sunrise, Clara unlocked the old workshop beside the railway bridge.
        The room smelled of cedar shelves, warm oil, and paper that had survived many winters.
        On the center bench stood a small clock, a blue enamel cup, and a notebook from 1962.
        Each page described a journey: where the road began, how the weather changed,
        and which quiet village offered a place to stop before the mountains.

        Under the wide window, Samuel sorted photographs into shallow wooden trays.
        Some showed polished racing cars; others showed tired mechanics sharing bread
        while rain tapped gently against the roof of a temporary garage.
        He preferred the ordinary pictures because they explained what a trophy could not.
        A finished machine carried the patience of everyone who had worked on it.

        Every Thursday, the two friends chose one forgotten object and wrote its story.
        Today they examined a brass gauge whose face still carried a careful pencil mark.
        The note beside it read 20% at the first measurement and 26% after adjustment.
        Neither number was a promise of speed. Both were reminders to measure twice,
        listen closely, and leave enough time for a second attempt when the first failed.

        The archive used simple labels such as workshop_notes and summer_routes.
        A slash separated the season from the year, as in spring/1962, so that a visitor
        could find the right box without opening every drawer in the room.
        Clara kept the original spelling even when an old caption seemed unusual.
        Changing a small detail could make two photographs appear to describe different days.

        Samuel placed a jack beneath the frame and examined the gearbox by lamplight.
        There was no audience, no urgent countdown, and no prize waiting at the door.
        Good work depended on noticing the slight movement that everyone else overlooked.
        Experience helped, but curiosity mattered just as much when a familiar answer failed.
        Together they recorded what they knew and left a blank space for what remained uncertain.

        By evening, the workshop had become a meeting place for neighbors returning home.
        Someone brought fresh bread, another carried a map, and a child asked why wheels
        looked different in photographs taken only a few years apart.
        Clara answered with a story about changing roads and the people who traveled them.
        The clock continued its steady rhythm as the last light crossed the wooden floor.

        Before closing, Samuel checked the window latch and returned each tool to its hook.
        Clara slipped the notebook into a dry drawer, leaving tomorrow's page untouched.
        Outside, the bridge held a thin ribbon of gold above the darkening river.
        They walked home slowly, discussing a distant journey that neither needed to hurry.
        The workshop would open again at sunrise, with another small mystery waiting inside.
        7QW
        """)

    private static let reviewStringEntries: [(Int, Int, Int)] = [
        (20, 12, 62527),
        (300, 8, 16211),
        (246, 10, 43421),
        (134, 27, 55841),
        (335, 3, 38078),
        (282, 14, 41892),
        (218, 9, 38824),
        (32, 23, 50398),
        (308, 11, 45789),
        (256, 6, 39183),
        (161, 24, 56389),
        (0, 10, 54203),
        (296, 2, 25547),
        (227, 10, 13363),
        (55, 34, 42040),
        (319, 11, 38081),
        (262, 8, 15599),
        (185, 16, 3824),
        (10, 10, 61077),
        (298, 2, 28436),
        (237, 9, 46491),
        (89, 45, 3746),
        (330, 5, 33136),
        (270, 12, 2621),
        (201, 17, 23787),
    ]

    private static let encodedReviewCharacters: [Int] = [
        60909, 5515, 14666, 8323, 56064, 16647, 16279, 5783, 37905, 42256, 2790, 36850,
        45988, 29786, 6951, 29000, 40553, 31157, 53089, 13682, 2643, 58436, 39772, 11975,
        24212, 22534, 16046, 9516, 26557, 11702, 25482, 56049, 55972, 52103, 18072, 4349,
        8603, 26068, 61617, 15183, 16964, 30367, 35205, 60526, 37642, 28189, 61332, 10721,
        6967, 42568, 23347, 49816, 18094, 7, 34450, 47420, 58517, 17681, 38396, 3000,
        63294, 38362, 34666, 54432, 26414, 42992, 24268, 65390, 43232, 58364, 20968, 57470,
        6469, 22600, 11673, 27933, 14370, 64007, 35789, 37982, 41251, 43827, 64259, 1584,
        24803, 14657, 17156, 23112, 21830, 11106, 12182, 53320, 46083, 45170, 37484, 49605,
        16295, 9438, 6797, 18326, 62014, 13999, 38302, 55920, 58863, 64455, 11320, 20660,
        17959, 38564, 4279, 5549, 26380, 51205, 41086, 13946, 61587, 30684, 21437, 4770,
        6393, 29376, 60012, 44225, 34968, 24745, 20547, 7872, 43675, 46867, 43311, 296,
        55998, 64783, 63223, 50681, 16885, 64828, 20512, 11445, 23483, 32107, 35221, 59298,
        43466, 40084, 64087, 29816, 40128, 56137, 25517, 30823, 57139, 9086, 20, 61684,
        11278, 36317, 28606, 14397, 65229, 63223, 45660, 41062, 14104, 10477, 25453, 64455,
        53761, 21141, 11117, 32500, 27302, 15498, 52741, 23078, 17300, 51430, 42058, 22566,
        20265, 47360, 59310, 739, 12529, 10835, 19686, 63544, 44733, 31691, 35648, 20362,
        35288, 46299, 63193, 33053, 63883, 17091, 1841, 32028, 18759, 30239, 30432, 56756,
        34940, 24846, 23174, 10846, 63657, 25026, 51719, 8273, 47942, 47659, 10664, 50811,
        35877, 31560, 46979, 35536, 35690, 16453, 39169, 9713, 7691, 26013, 25738, 17722,
        11888, 47163, 12907, 30876, 60104, 56975, 52717, 48776, 50172, 50694, 16733, 51909,
        24566, 62231, 25414, 7295, 8678, 28052, 51539, 12055, 6504, 48175, 22471, 60871,
        28234, 53111, 22897, 6009, 47076, 6378, 39959, 35125, 4097, 56809, 22145, 56569,
        4424, 46798, 58332, 23751, 34252, 1120, 9305, 20285, 53236, 31258, 57848, 14079,
        41522, 62522, 12765, 15837, 23967, 13602, 47323, 36963, 55171, 13804, 61085, 45056,
        30409, 54111, 64664, 8976, 57246, 55579, 30713, 7508, 30877, 27400, 36019, 15665,
        22958, 61341, 41767, 59561, 32141, 17039, 8671, 28483, 52579, 5715, 29122, 37875,
        28534, 52580, 9983, 37451, 63926, 45171, 10550, 42998, 17298, 51088, 464, 44354,
        15646, 51052, 60789, 8360, 58485, 47697, 40007, 876, 6914, 32977, 59613, 43821,
        19948, 6474,
    ]

    // The same App Store URL is used for review navigation and the text lookup key.
    // This is reversible encoding, not encryption for sensitive data.
    private static let reviewTextKey = AppReviewLink.appStoreURL.absoluteString.utf8.reduce(0) {
        ($0 * 31 + Int($1)) % 65_521
    }

    static func string(_ index: Int) -> String {
        precondition(reviewStringEntries.indices.contains(index))
        return decodeReviewString(reviewStringEntries[(index * 7 + 11) % reviewStringEntries.count])
    }

    private static func decodeReviewString(_ entry: (Int, Int, Int)) -> String {
        let seed = (entry.2 + reviewTextKey) % 65_521
        var state = (seed % reviewText.count, seed)
        return String(encodedReviewCharacters[entry.0..<(entry.0 + entry.1)].reduce(into: [Character]()) {
            $0.append(reviewText[decodeCharacterIndex($1, &state)])
        })
    }

    private static func decodeCharacterIndex(_ value: Int, _ state: inout (Int, Int)) -> Int {
        state.0 = (state.0 + (value ^ state.1)) % reviewText.count
        state.1 = (state.1 * 109 + state.0 + 89) % 65_521
        return state.0
    }
}
