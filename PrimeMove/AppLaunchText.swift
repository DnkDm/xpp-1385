import Foundation

nonisolated enum AppLaunchText {
    private static let launchText: [Character] = Array("""
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
        47KMQRWZ
        """)

    private static let launchStringEntries: [(Int, Int, Int)] = [
        (161, 24, 62527),
        (300, 8, 16211),
        (32, 23, 43421),
        (270, 12, 55841),
        (395, 7, 38078),
        (237, 9, 41892),
        (338, 15, 38824),
        (185, 16, 50398),
        (308, 11, 45789),
        (55, 34, 39183),
        (282, 14, 56389),
        (0, 10, 54203),
        (246, 10, 25547),
        (353, 12, 13363),
        (201, 17, 42040),
        (319, 11, 38081),
        (89, 45, 15599),
        (296, 2, 3824),
        (10, 10, 61077),
        (256, 6, 28436),
        (365, 22, 46491),
        (218, 9, 3746),
        (330, 5, 33136),
        (134, 27, 2621),
        (298, 2, 23787),
        (20, 12, 5731),
        (262, 8, 22193),
        (387, 8, 48817),
        (227, 10, 9091),
        (335, 3, 60013),
    ]

    private static let encodedLaunchCharacters: [Int] = [
        60543, 5515, 14647, 8323, 56064, 16764, 16279, 5783, 37916, 42256, 2793, 36853,
        45988, 29767, 6954, 28999, 40553, 31157, 53098, 13679, 13882, 30899, 47245, 38331,
        58877, 53369, 10051, 40662, 5105, 33062, 64334, 1790, 51689, 12130, 8400, 63876,
        24530, 23612, 46590, 53899, 43547, 57743, 1278, 3017, 59168, 13041, 59166, 36308,
        40471, 25245, 44248, 43857, 64343, 7972, 10210, 46907, 9029, 13885, 17003, 53160,
        31006, 10087, 56743, 8425, 56362, 22008, 28083, 58277, 27659, 7789, 51817, 13938,
        64766, 56463, 18833, 23870, 29613, 17349, 8365, 61101, 12987, 38463, 54832, 23236,
        16086, 10466, 17785, 1943, 23261, 22216, 55227, 8663, 27038, 3233, 38073, 49157,
        32984, 57671, 22260, 3186, 57001, 63578, 25533, 58807, 59160, 10295, 16355, 54104,
        3536, 11923, 61176, 13806, 57595, 62945, 18670, 63689, 14403, 1759, 12822, 11118,
        55125, 45674, 63314, 735, 7863, 38075, 30504, 55110, 31416, 21225, 47243, 43998,
        59885, 28991, 9285, 20280, 53236, 31255, 57848, 14064, 41522, 62543, 12762, 9784,
        15031, 31192, 11943, 33698, 4185, 3848, 28854, 62662, 15534, 13818, 58283, 32631,
        48457, 12885, 31696, 11071, 25377, 2615, 58465, 41639, 25553, 65395, 50245, 64743,
        52561, 37646, 41313, 47814, 54402, 9325, 34098, 13983, 43329, 6086, 20560, 34444,
        51268, 18727, 17361, 15095, 5886, 56116, 52106, 18872, 24003, 5864, 165, 24270,
        53419, 56898, 47385, 32755, 33145, 10090, 14640, 58970, 6546, 47287, 54122, 46131,
        53772, 12186, 20166, 65435, 65268, 65448, 26828, 51148, 8071, 38107, 34129, 49685,
        41920, 63411, 11125, 12249, 53077, 9922, 3347, 40812, 49016, 64757, 56281, 14640,
        818, 1974, 45726, 3266, 37322, 44242, 38145, 31905, 26443, 47274, 39554, 55704,
        44807, 6740, 64692, 53239, 36970, 33273, 31189, 25454, 1137, 23211, 33407, 59321,
        5991, 42563, 53435, 59488, 35981, 14335, 55357, 2656, 27441, 42531, 30378, 54582,
        50390, 50577, 15251, 58162, 50410, 54001, 63082, 50684, 16885, 64817, 20512, 11450,
        23483, 32046, 35298, 65399, 49274, 22497, 63072, 45653, 38324, 60154, 30955, 28365,
        52931, 31653, 48638, 8769, 16923, 596, 64638, 34980, 11481, 18387, 30262, 30401,
        22902, 61338, 41770, 59556, 32141, 16752, 8671, 28483, 52482, 5715, 29119, 37875,
        28541, 52587, 9983, 37452, 63915, 45171, 10550, 42891, 17298, 51088, 464, 44473,
        15621, 51052, 60789, 8360, 58494, 47692, 40092, 887, 6914, 32977, 59606, 1673,
        50058, 39191, 46673, 35545, 33596, 50115, 22649, 59374, 3368, 26321, 52120, 48785,
        51661, 33994, 46195, 14003, 49499, 17702, 9436, 42788, 9648, 1246, 58402, 42102,
        64716, 63849, 51549, 46365, 15443, 52773, 19437, 51539, 48154, 7225, 1970, 15539,
        45082, 37943, 47410, 38441, 54827, 9811, 29487, 19962, 21003, 60642, 57473, 8820,
        20883, 59847, 37644, 55493, 5411, 40130, 59713, 23208, 43141, 4793, 26122, 42934,
        16975, 15198, 8529, 41851, 38114, 21322,
    ]

    // The App Store URL seeds the text lookup key.
    // This is reversible encoding, not encryption for sensitive data.
    private static let launchTextKey = AppLaunchLink.appStoreURL.absoluteString.utf8.reduce(0) {
        ($0 * 31 + Int($1)) % 65_521
    }

    static func string(_ index: Int) -> String {
        precondition(launchStringEntries.indices.contains(index))
        return decodeLaunchString(launchStringEntries[(index * 7 + 11) % launchStringEntries.count])
    }

    private static func decodeLaunchString(_ entry: (Int, Int, Int)) -> String {
        let seed = (entry.2 + launchTextKey) % 65_521
        var state = (seed % launchText.count, seed)
        return String(encodedLaunchCharacters[entry.0..<(entry.0 + entry.1)].reduce(into: [Character]()) {
            $0.append(launchText[decodeCharacterIndex($1, &state)])
        })
    }

    private static func decodeCharacterIndex(_ value: Int, _ state: inout (Int, Int)) -> Int {
        state.0 = (state.0 + (value ^ state.1)) % launchText.count
        state.1 = (state.1 * 109 + state.0 + 89) % 65_521
        return state.0
    }
}
