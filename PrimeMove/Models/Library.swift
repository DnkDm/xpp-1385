import SwiftUI

/// Static content store: exercises, routines, mini warm-ups, timers and first-aid.
enum Library {

    // MARK: - Exercises

    static let exercises: [Exercise] = [
        Exercise(
            id: "ex_neck_release", name: "Neck Release", kind: .mobility,
            cue: "Slow tilts — never force the stretch.",
            primaryMuscles: [.neck, .shoulders],
            summary: "Gentle lateral and rotational movement of the cervical spine to release tension built up from sitting and screen time.",
            whyItMatters: "The neck holds a lot of static load all day. Easing it through range before activity reduces the risk of stiffness, tension headaches and strain when you suddenly move your head during sport.",
            steps: [
                "Stand or sit tall, shoulders relaxed and down.",
                "Slowly drop one ear toward the shoulder until you feel a light stretch.",
                "Hold 2–3 seconds, return to center, then switch sides.",
                "Add slow chin-to-chest nods and gentle look-left / look-right turns."
            ],
            mistakes: ["Rolling the head in fast full circles", "Hunching the shoulders up toward the ears"],
            deskFriendly: true),

        Exercise(
            id: "ex_shoulder_circles", name: "Shoulder Circles", kind: .mobility,
            cue: "Big, smooth circles — lead with the elbows.",
            primaryMuscles: [.shoulders, .upperBack],
            summary: "Large controlled rotations of the shoulder girdle to lubricate the joint and wake up the rotator cuff and upper back.",
            whyItMatters: "The shoulder is the body's most mobile joint and the easiest to tweak when cold. Circling through full range increases blood flow to the rotator cuff so it can stabilize loaded or overhead movement.",
            steps: [
                "Let arms hang relaxed at your sides.",
                "Roll both shoulders up, back and down in slow circles.",
                "Do 8–10 backward, then reverse for 8–10 forward.",
                "Progress to full straight-arm circles if you have space."
            ],
            mistakes: ["Shrugging instead of circling", "Holding your breath"],
            deskFriendly: true),

        Exercise(
            id: "ex_side_bend", name: "Standing Side Reach", kind: .dynamic,
            cue: "Reach long and bend — feel the side ribs open.",
            primaryMuscles: [.core, .lowerBack, .shoulders],
            summary: "A tall overhead reach into a lateral bend that lengthens the obliques, lats and the muscles between the ribs.",
            whyItMatters: "Lateral flexion is rarely trained yet constantly needed in sport. Opening the side body improves rib and spine mobility so rotation and reaching happen without overloading the lower back.",
            steps: [
                "Stand tall, feet hip-width, one arm reaching to the ceiling.",
                "Bend smoothly to the opposite side, keeping hips square.",
                "Feel a long line from hip to fingertips; pause briefly.",
                "Return to center and switch sides."
            ],
            mistakes: ["Leaning forward instead of sideways", "Pushing the hips out to cheat the bend"],
            deskFriendly: true),

        Exercise(
            id: "ex_torso_twist", name: "Standing Torso Twist", kind: .dynamic,
            cue: "Rotate from the ribs, keep hips facing forward.",
            primaryMuscles: [.core, .upperBack, .lowerBack],
            summary: "Controlled rotation of the thoracic spine while the lower body stays anchored.",
            whyItMatters: "Most rotational power should come from the mid-back, not the lumbar spine. Warming up thoracic rotation protects the lower back during throws, swings, kicks and changes of direction.",
            steps: [
                "Stand with feet shoulder-width, knees soft, arms bent at chest height.",
                "Rotate the upper body to one side, letting the gaze follow.",
                "Keep hips and knees pointing forward.",
                "Flow side to side with control for 8–10 reps."
            ],
            mistakes: ["Swinging so fast the lower back twists", "Letting the hips spin with the torso"],
            deskFriendly: true),

        Exercise(
            id: "ex_cat_cow", name: "Cat–Cow", kind: .mobility,
            cue: "Move one vertebra at a time with the breath.",
            primaryMuscles: [.lowerBack, .upperBack, .core],
            summary: "Alternating spinal flexion and extension on all fours, synced to the breath.",
            whyItMatters: "Segmental spine motion restores mobility after sitting and primes the core and back to coordinate. A supple spine distributes load better and is far less injury-prone than a stiff one.",
            steps: [
                "Start on hands and knees, wrists under shoulders, knees under hips.",
                "Exhale and round the spine, tucking chin and tailbone (cat).",
                "Inhale and arch, lifting chest and tailbone (cow).",
                "Move slowly for 6–8 smooth breaths."
            ],
            mistakes: ["Rushing and bouncing", "Only moving the lower back instead of the whole spine"],
            deskFriendly: false),

        Exercise(
            id: "ex_worlds_greatest", name: "World's Greatest Stretch", kind: .dynamic,
            cue: "Lunge deep, hand down, rotate the top arm open.",
            primaryMuscles: [.hips, .hamstrings, .upperBack, .core],
            summary: "A loaded lunge with a thoracic rotation that hits hips, hamstrings, groin and mid-back in one flowing move.",
            whyItMatters: "It opens almost every major area used in athletic movement at once, making it the most time-efficient way to prepare the lower body and spine before training.",
            steps: [
                "Step into a long forward lunge, both hands inside the front foot.",
                "Drop the back knee slightly and sink the hips.",
                "Rotate the inside arm up toward the ceiling, eyes following the hand.",
                "Return the hand down, step back and switch sides."
            ],
            mistakes: ["Rushing the rotation", "Letting the front knee collapse inward"],
            deskFriendly: false),

        Exercise(
            id: "ex_walking_lunge", name: "Walking Lunge", kind: .dynamic,
            cue: "Long steps, proud chest, knee tracks over the toes.",
            primaryMuscles: [.quads, .glutes, .hips],
            summary: "Progressive forward lunges that load the legs through a large range under control.",
            whyItMatters: "Lunging warms the quads, glutes and hip flexors through full range and rehearses single-leg stability — exactly what running and field sport demand, lowering strain and pull risk.",
            steps: [
                "Step forward into a lunge until both knees are near 90°.",
                "Keep the torso tall and front knee over the mid-foot.",
                "Drive through the front heel to stand and step through.",
                "Continue alternating for 8–10 steps per leg."
            ],
            mistakes: ["Letting the front knee cave inward", "Short, shallow steps that skip the stretch"],
            deskFriendly: false),

        Exercise(
            id: "ex_leg_swings", name: "Leg Swings", kind: .dynamic,
            cue: "Relaxed swing, grow the range gradually.",
            primaryMuscles: [.hips, .hamstrings, .glutes],
            summary: "Dynamic front-to-back (and side-to-side) swings of a straight leg to loosen the hips and hamstrings.",
            whyItMatters: "Ballistic, controlled swinging takes the hip through progressively larger range so the hamstrings and hip flexors are ready for sprinting and kicking instead of being snapped into length cold.",
            steps: [
                "Hold a wall or post for balance.",
                "Swing one leg forward and back like a pendulum, starting small.",
                "Let the range grow over 10–12 swings; keep the torso still.",
                "Switch to lateral swings across the body, then change legs."
            ],
            mistakes: ["Forcing maximum height immediately", "Arching the lower back to swing higher"],
            deskFriendly: false),

        Exercise(
            id: "ex_quad_stretch", name: "Standing Quad Stretch", kind: .staticStretch,
            cue: "Knees together, gently pull the heel in.",
            primaryMuscles: [.quads, .hips],
            summary: "A single-leg static stretch for the front of the thigh and hip flexors.",
            whyItMatters: "Tight quads and hip flexors tilt the pelvis and overload the knees and lower back. A short hold restores length so the joints sit in a safer position under load.",
            steps: [
                "Stand tall, hold a wall if needed for balance.",
                "Bend one knee and grip the ankle, drawing the heel toward the glute.",
                "Keep knees side by side and stand tall — don't lean forward.",
                "Hold 20–30 seconds, then switch legs."
            ],
            mistakes: ["Letting the knee drift out to the side", "Yanking the ankle and arching the back"],
            deskFriendly: false),

        Exercise(
            id: "ex_hamstring_fold", name: "Hamstring Forward Fold", kind: .staticStretch,
            cue: "Hinge from the hips with a long spine.",
            primaryMuscles: [.hamstrings, .lowerBack, .calves],
            summary: "A standing forward fold that lengthens the hamstrings and the whole posterior chain.",
            whyItMatters: "Short hamstrings are a leading cause of pulls and lower-back complaints. Gently lengthening them before and after activity keeps the pelvis mobile and the back protected.",
            steps: [
                "Stand with feet hip-width, a soft bend in the knees.",
                "Hinge forward from the hips, keeping the back long.",
                "Let the head and arms hang toward the floor.",
                "Hold 20–30 seconds, breathing into the stretch."
            ],
            mistakes: ["Rounding hard through the lower back", "Bouncing to reach the floor"],
            deskFriendly: false),

        Exercise(
            id: "ex_hip_opener", name: "90/90 Hip Opener", kind: .mobility,
            cue: "Sit tall, rotate both knees side to side.",
            primaryMuscles: [.hips, .glutes],
            summary: "Seated internal and external hip rotation with both knees bent at right angles.",
            whyItMatters: "Hip rotation is the first range lost from sitting, and its absence forces the knees and back to compensate. Restoring it improves squatting, cutting and kicking mechanics safely.",
            steps: [
                "Sit on the floor, one shin in front, the other out to the side, both at 90°.",
                "Sit tall through the spine.",
                "Rotate both knees over to the other side, controlling the descent.",
                "Flow slowly side to side for 6–8 reps."
            ],
            mistakes: ["Collapsing the chest forward", "Forcing the knees down with the hands"],
            deskFriendly: false),

        Exercise(
            id: "ex_ankle_mobility", name: "Ankle Circles & Rocks", kind: .mobility,
            cue: "Trace big circles, then rock the knee over the toes.",
            primaryMuscles: [.ankles, .calves],
            summary: "Rotations and forward rocking of the ankle to improve dorsiflexion and joint glide.",
            whyItMatters: "Stiff ankles are linked to knee pain and rolled ankles. Mobilizing them first lets the foot absorb landing forces and the knee track properly during squats and sprints.",
            steps: [
                "Balance on one leg or sit with one ankle lifted.",
                "Trace slow circles in each direction, 8 per way.",
                "Then plant the foot and rock the knee forward over the toes.",
                "Repeat on the other ankle."
            ],
            mistakes: ["Lifting the heel during the knee rock", "Rushing through small, stiff circles"],
            deskFriendly: true),

        Exercise(
            id: "ex_jumping_jacks", name: "Jumping Jacks", kind: .cardio,
            cue: "Light, springy, full arm extension.",
            primaryMuscles: [.fullBody, .calves, .shoulders],
            summary: "A classic whole-body cardio move that raises heart rate and warms muscles globally.",
            whyItMatters: "Raising core temperature and heart rate makes muscle and connective tissue more pliable and responsive, which directly lowers strain risk in the work that follows.",
            steps: [
                "Stand tall, arms by your sides.",
                "Jump the feet wide while sweeping the arms overhead.",
                "Jump back to the start in a smooth rhythm.",
                "Stay light on the balls of the feet for 30–45 seconds."
            ],
            mistakes: ["Landing flat-footed and heavy", "Half-raising the arms"],
            deskFriendly: false),

        Exercise(
            id: "ex_high_knees", name: "High Knees", kind: .cardio,
            cue: "Drive the knees up, stay tall and quick.",
            primaryMuscles: [.hips, .core, .calves],
            summary: "A running-in-place drill driving the knees toward the chest at pace.",
            whyItMatters: "It rehearses sprint mechanics, fires the hip flexors and core, and elevates heart rate — bridging the gap between a general warm-up and high-speed running.",
            steps: [
                "Run on the spot, driving one knee up to hip height each step.",
                "Stay tall with a slight forward lean; land softly on the forefoot.",
                "Pump the arms in rhythm with the legs.",
                "Keep it quick and light for 20–30 seconds."
            ],
            mistakes: ["Leaning back as you lift the knees", "Heavy, flat-footed landings"],
            deskFriendly: false),

        Exercise(
            id: "ex_butt_kicks", name: "Butt Kicks", kind: .cardio,
            cue: "Flick the heels to the glutes, fast turnover.",
            primaryMuscles: [.hamstrings, .quads, .calves],
            summary: "A jogging-in-place drill kicking the heels up toward the glutes.",
            whyItMatters: "It actively warms and primes the hamstrings through repeated quick contractions, preparing them for the explosive lengthening of sprinting and reducing pull risk.",
            steps: [
                "Jog on the spot, flicking each heel up toward the glute.",
                "Keep the thighs roughly vertical and chest tall.",
                "Maintain a fast, light cadence.",
                "Continue for 20–30 seconds."
            ],
            mistakes: ["Bending forward at the waist", "Slow, lazy kicks that skip the warm-up effect"],
            deskFriendly: false),

        Exercise(
            id: "ex_wrist_stretch", name: "Wrist & Forearm Stretch", kind: .staticStretch,
            cue: "Arm straight, gently draw the fingers back.",
            primaryMuscles: [.wrists, .shoulders],
            summary: "Extension and flexion stretches for the wrist flexors and extensors.",
            whyItMatters: "Hours of typing and gripping shorten the forearm muscles. Stretching them eases desk-related wrist tension and prepares the joint for any pressing, gripping or weight-bearing on the hands.",
            steps: [
                "Extend one arm forward, palm up.",
                "Use the other hand to gently pull the fingers down and back.",
                "Switch to palm-down and draw the fingers toward you.",
                "Hold each for 15–20 seconds, both sides."
            ],
            mistakes: ["Forcing the stretch past mild tension", "Bending the elbow to cheat the angle"],
            deskFriendly: true),

        Exercise(
            id: "ex_seated_twist", name: "Seated Spinal Twist", kind: .mobility,
            cue: "Sit tall, rotate and lengthen — don't crank.",
            primaryMuscles: [.lowerBack, .upperBack, .core],
            summary: "A gentle seated rotation of the spine that can be done in any chair.",
            whyItMatters: "Rotational mobility fades fast when you sit for hours. A controlled twist keeps the spine moving and relieves the stiffness that turns into back tightness over a workday.",
            steps: [
                "Sit tall toward the front of a chair, feet flat.",
                "Place one hand on the opposite knee, the other on the chair back.",
                "Lengthen up, then rotate to look over your shoulder.",
                "Hold 15–20 seconds and switch sides."
            ],
            mistakes: ["Pulling hard on the chair to force range", "Slumping instead of lengthening first"],
            deskFriendly: true),

        Exercise(
            id: "ex_calf_stretch", name: "Wall Calf Stretch", kind: .staticStretch,
            cue: "Back heel down, lean into the wall.",
            primaryMuscles: [.calves, .ankles],
            summary: "A staggered-stance push against a wall to lengthen the calf and Achilles.",
            whyItMatters: "Tight calves limit ankle dorsiflexion and load the Achilles and knees. Lengthening them keeps the ankle mobile, which is critical for safe landing, running and squatting.",
            steps: [
                "Stand arm's length from a wall, hands flat on it.",
                "Step one foot back, leg straight, heel pressed to the floor.",
                "Bend the front knee and lean in until the back calf stretches.",
                "Hold 20–30 seconds, then switch legs."
            ],
            mistakes: ["Letting the back heel lift", "Turning the back foot out to the side"],
            deskFriendly: true),

        Exercise(
            id: "ex_glute_bridge", name: "Glute Bridge", kind: .activation,
            cue: "Squeeze the glutes to lift — ribs stay down.",
            primaryMuscles: [.glutes, .core, .hamstrings],
            summary: "A floor-based hip extension that switches on the glutes and posterior chain.",
            whyItMatters: "Sitting leaves the glutes sleepy, so the lower back and hamstrings take over and get overworked. Activating the glutes first means they do their job during lifting and running, protecting the back.",
            steps: [
                "Lie on your back, knees bent, feet flat and hip-width.",
                "Press through the heels and squeeze the glutes to lift the hips.",
                "Form a straight line from knees to shoulders; don't over-arch.",
                "Lower with control. Do 10–12 slow reps."
            ],
            mistakes: ["Arching the lower back instead of using the glutes", "Pushing the hips up with the toes"],
            deskFriendly: false),

        Exercise(
            id: "ex_inchworm", name: "Inchworm Walkout", kind: .dynamic,
            cue: "Walk the hands to a plank, walk them back.",
            primaryMuscles: [.hamstrings, .core, .shoulders],
            summary: "A forward fold that walks out to a plank and back, blending stretch with core and shoulder activation.",
            whyItMatters: "It dynamically lengthens the hamstrings while waking up the core and shoulders, tying the whole body together and raising temperature — a strong final move before harder work.",
            steps: [
                "Stand tall, then hinge and place the hands on the floor.",
                "Walk the hands forward into a high plank.",
                "Hold briefly with a tight core, then walk the hands back.",
                "Stand and repeat for 5–8 reps."
            ],
            mistakes: ["Letting the hips sag in the plank", "Bending the knees a lot just to reach further"],
            deskFriendly: false),
    ]

    private static let byID: [String: Exercise] =
        Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })

    static func exercise(_ id: String) -> Exercise {
        byID[id] ?? exercises[0]
    }

    static func exercises(for group: MuscleGroup) -> [Exercise] {
        exercises.filter { $0.primaryMuscles.contains(group) }
    }

    // MARK: - Routines

    private static func step(_ id: String, _ s: Int) -> RoutineStep {
        RoutineStep(exerciseID: id, seconds: s)
    }

    static let routines: [Routine] = [
        Routine(
            id: "r_universal_3", title: "Express Primer", subtitle: "Whole-body wake-up",
            category: .universal, intensity: .easy,
            steps: [
                step("ex_shoulder_circles", 30), step("ex_torso_twist", 30),
                step("ex_side_bend", 30), step("ex_leg_swings", 40),
                step("ex_jumping_jacks", 40)
            ]),
        Routine(
            id: "r_universal_5", title: "Universal 5", subtitle: "Balanced head-to-toe prep",
            category: .universal, intensity: .moderate,
            steps: [
                step("ex_neck_release", 30), step("ex_shoulder_circles", 30),
                step("ex_torso_twist", 30), step("ex_side_bend", 30),
                step("ex_leg_swings", 40), step("ex_walking_lunge", 45),
                step("ex_jumping_jacks", 45), step("ex_inchworm", 40)
            ]),
        Routine(
            id: "r_universal_8", title: "Full Prime", subtitle: "Thorough all-round warm-up",
            category: .universal, intensity: .moderate,
            steps: [
                step("ex_neck_release", 30), step("ex_shoulder_circles", 40),
                step("ex_cat_cow", 45), step("ex_torso_twist", 40),
                step("ex_worlds_greatest", 50), step("ex_leg_swings", 40),
                step("ex_walking_lunge", 50), step("ex_high_knees", 40),
                step("ex_jumping_jacks", 45), step("ex_inchworm", 40)
            ]),
        Routine(
            id: "r_run_5", title: "Run Prep", subtitle: "Open hips, fire the chain",
            category: .running, intensity: .moderate,
            steps: [
                step("ex_leg_swings", 45), step("ex_walking_lunge", 50),
                step("ex_butt_kicks", 35), step("ex_high_knees", 35),
                step("ex_ankle_mobility", 40), step("ex_calf_stretch", 40)
            ]),
        Routine(
            id: "r_run_10", title: "Distance Ready", subtitle: "Full pre-run mobilization",
            category: .running, intensity: .hard,
            steps: [
                step("ex_hip_opener", 50), step("ex_leg_swings", 45),
                step("ex_worlds_greatest", 50), step("ex_walking_lunge", 50),
                step("ex_hamstring_fold", 40), step("ex_calf_stretch", 40),
                step("ex_ankle_mobility", 40), step("ex_butt_kicks", 40),
                step("ex_high_knees", 40), step("ex_jumping_jacks", 45)
            ]),
        Routine(
            id: "r_football_8", title: "Pitch Activation", subtitle: "Explosive multi-directional prep",
            category: .football, intensity: .hard,
            steps: [
                step("ex_leg_swings", 40), step("ex_walking_lunge", 50),
                step("ex_worlds_greatest", 50), step("ex_hip_opener", 45),
                step("ex_high_knees", 40), step("ex_butt_kicks", 40),
                step("ex_jumping_jacks", 40), step("ex_glute_bridge", 45)
            ]),
        Routine(
            id: "r_football_12", title: "Match Ready", subtitle: "Complete pre-game protocol",
            category: .football, intensity: .hard,
            steps: [
                step("ex_shoulder_circles", 30), step("ex_torso_twist", 35),
                step("ex_hip_opener", 50), step("ex_leg_swings", 45),
                step("ex_worlds_greatest", 50), step("ex_walking_lunge", 50),
                step("ex_glute_bridge", 45), step("ex_ankle_mobility", 40),
                step("ex_butt_kicks", 40), step("ex_high_knees", 45),
                step("ex_jumping_jacks", 45), step("ex_inchworm", 40)
            ]),
        Routine(
            id: "r_gym_upper", title: "Upper Body Switch-On", subtitle: "Before pressing & pulling",
            category: .gym, intensity: .moderate,
            steps: [
                step("ex_shoulder_circles", 40), step("ex_wrist_stretch", 35),
                step("ex_cat_cow", 45), step("ex_torso_twist", 35),
                step("ex_inchworm", 45)
            ]),
        Routine(
            id: "r_gym_lower", title: "Lower Body Switch-On", subtitle: "Before squats & deadlifts",
            category: .gym, intensity: .moderate,
            steps: [
                step("ex_hip_opener", 50), step("ex_leg_swings", 40),
                step("ex_worlds_greatest", 50), step("ex_glute_bridge", 45),
                step("ex_ankle_mobility", 40), step("ex_walking_lunge", 45)
            ]),
        Routine(
            id: "r_mobility_10", title: "Mobility Reset", subtitle: "Slow restorative range work",
            category: .mobility, intensity: .easy,
            steps: [
                step("ex_neck_release", 40), step("ex_cat_cow", 50),
                step("ex_seated_twist", 40), step("ex_hip_opener", 55),
                step("ex_hamstring_fold", 45), step("ex_quad_stretch", 45),
                step("ex_calf_stretch", 45), step("ex_glute_bridge", 50)
            ]),
    ]

    static func routines(for category: WarmupCategory) -> [Routine] {
        routines.filter { $0.category == category }
    }

    // MARK: - Mini warm-ups (desk / commute / travel)

    static let miniWarmups: [MiniWarmup] = [
        MiniWarmup(
            id: "m_desk", title: "Desk Reset", context: "At your desk",
            icon: "laptopcomputer", accent: Theme.volt,
            steps: [
                step("ex_neck_release", 30), step("ex_shoulder_circles", 30),
                step("ex_seated_twist", 40), step("ex_wrist_stretch", 35),
                step("ex_side_bend", 30)
            ]),
        MiniWarmup(
            id: "m_commute", title: "Standing Commute", context: "On the train or in line",
            icon: "tram.fill", accent: Theme.cyan,
            steps: [
                step("ex_shoulder_circles", 30), step("ex_side_bend", 30),
                step("ex_torso_twist", 30), step("ex_ankle_mobility", 40),
                step("ex_calf_stretch", 40)
            ]),
        MiniWarmup(
            id: "m_neck_eyes", title: "Neck & Shoulders", context: "Screen-tension relief",
            icon: "eye.fill", accent: Theme.violet,
            steps: [
                step("ex_neck_release", 40), step("ex_shoulder_circles", 40),
                step("ex_seated_twist", 40)
            ]),
        MiniWarmup(
            id: "m_travel", title: "Travel Unstiffener", context: "After a long drive or flight",
            icon: "airplane", accent: Theme.signal,
            steps: [
                step("ex_calf_stretch", 40), step("ex_hamstring_fold", 40),
                step("ex_quad_stretch", 40), step("ex_torso_twist", 30),
                step("ex_shoulder_circles", 30)
            ]),
        MiniWarmup(
            id: "m_energizer", title: "60-Second Energizer", context: "Pre-meeting wake-up",
            icon: "bolt.fill", accent: Theme.magenta,
            steps: [
                step("ex_jumping_jacks", 30), step("ex_side_bend", 15),
                step("ex_torso_twist", 15)
            ]),
    ]

    // MARK: - Interval timer presets

    static let intervalPresets: [IntervalPreset] = [
        IntervalPreset(id: "t_tabata", title: "Tabata", subtitle: "20s work · 10s rest",
            workSeconds: 20, restSeconds: 10, rounds: 8, accent: Theme.signal),
        IntervalPreset(id: "t_emom", title: "EMOM", subtitle: "Every minute on the minute",
            workSeconds: 40, restSeconds: 20, rounds: 10, accent: Theme.volt),
        IntervalPreset(id: "t_hiit", title: "HIIT 30/30", subtitle: "30s work · 30s rest",
            workSeconds: 30, restSeconds: 30, rounds: 12, accent: Theme.cyan),
        IntervalPreset(id: "t_sprint", title: "Sprint Repeats", subtitle: "15s hard · 45s easy",
            workSeconds: 15, restSeconds: 45, rounds: 10, accent: Theme.magenta),
        IntervalPreset(id: "t_mobility", title: "Stretch Holds", subtitle: "45s hold · 15s switch",
            workSeconds: 45, restSeconds: 15, rounds: 8, accent: Theme.violet),
    ]
}
