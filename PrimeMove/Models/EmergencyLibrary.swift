import SwiftUI

/// First-aid protocols for common training incidents.
///
/// IMPORTANT: this is general educational first-aid information, not medical advice.
/// Every protocol defers to professional emergency services and a clinician.
enum EmergencyLibrary {

    static let globalDisclaimer =
    "PrimeMove is not a medical service. This information is general first-aid education only and cannot replace a professional assessment. In a real emergency, call your local emergency number immediately and follow the dispatcher's instructions — act under their guidance. When in doubt, always seek a doctor."

    static let universalRedFlags = [
        "Loss of consciousness, confusion, or seizure",
        "Trouble breathing, chest pain, or blue lips",
        "Severe or uncontrolled bleeding",
        "A limb that is deformed, or bone visible through skin",
        "Sudden severe weakness, slurred speech, or facial droop"
    ]

    private static func url(_ s: String) -> URL { URL(string: s)! }

    static let protocols: [EmergencyProtocol] = [

        EmergencyProtocol(
            id: "e_cramp",
            title: "Muscle Cramp",
            tagline: "Sudden involuntary muscle spasm (e.g. calf “charley horse”).",
            icon: "bolt.heart.fill",
            severity: "Common",
            severityColor: Theme.volt,
            overview: "A cramp is an abrupt, painful, involuntary contraction. Most are harmless and ease within minutes, but the muscle can stay tender afterward.",
            doNow: [
                CarePhase(title: "Stop and gently lengthen", detail: "Stop the activity and slowly stretch the cramping muscle. For a calf cramp, straighten the leg and pull the toes up toward the shin."),
                CarePhase(title: "Massage the area", detail: "Gently rub the muscle to help it relax. Light, steady pressure is enough."),
                CarePhase(title: "Apply heat, then cold", detail: "Warmth helps a tight muscle relax; ice can ease residual soreness afterward."),
                CarePhase(title: "Rehydrate", detail: "Sip water or a drink with electrolytes, as dehydration and salt loss can contribute.")
            ],
            avoid: ["Forcefully contracting the cramped muscle", "Pushing back into hard activity while it's still seizing"],
            callEmergencyIf: [
                "The cramp doesn't ease and the muscle becomes hard, very swollen, or the skin changes color",
                "Cramps are frequent, severe, or come with weakness — see a doctor",
                "You suspect significant dehydration or heat illness alongside it"
            ],
            sources: [
                ArticleSource(publisher: "Mayo Clinic", title: "Muscle cramp — symptoms & causes",
                    url: url("https://www.mayoclinic.org/diseases-conditions/muscle-cramp/symptoms-causes/syc-20350820")),
                ArticleSource(publisher: "NHS", title: "Leg cramps",
                    url: url("https://www.nhs.uk/conditions/leg-cramps/"))
            ]),

        EmergencyProtocol(
            id: "e_strain",
            title: "Muscle Strain / Pull",
            tagline: "An overstretched or torn muscle or tendon.",
            icon: "figure.strengthtraining.functional",
            severity: "Urgent care",
            severityColor: Theme.signal,
            overview: "A strain (“pulled muscle”) ranges from mild overstretch to a partial or full tear, often felt as a sudden sharp pain, with later swelling, bruising and weakness.",
            doNow: [
                CarePhase(title: "Stop immediately", detail: "Stop the activity. Continuing on a strain can worsen the tear."),
                CarePhase(title: "Rest & protect", detail: "Rest the muscle and avoid movements that reproduce the pain for the first 48–72 hours."),
                CarePhase(title: "Ice it", detail: "Apply an ice pack wrapped in a cloth for 15–20 minutes every 2–3 hours to limit swelling. Never put ice directly on skin."),
                CarePhase(title: "Compress & elevate", detail: "Use an elastic bandage for support and, where possible, raise the area to reduce swelling.")
            ],
            avoid: ["Heat, alcohol, or vigorous massage in the first 48–72 hours (can increase swelling)", "“Running it off” or stretching aggressively through sharp pain"],
            callEmergencyIf: [
                "You heard a “pop” and cannot use the limb or bear weight",
                "There is severe pain, rapid heavy swelling, or numbness",
                "The area looks deformed — treat as a possible serious tear or fracture and get medical care"
            ],
            sources: [
                ArticleSource(publisher: "OrthoInfo (AAOS)", title: "Sprains, strains and other soft-tissue injuries",
                    url: url("https://orthoinfo.aaos.org/en/diseases--conditions/sprains-strains-and-other-soft-tissue-injuries/")),
                ArticleSource(publisher: "NHS", title: "Sprains and strains",
                    url: url("https://www.nhs.uk/conditions/sprains-and-strains/"))
            ]),

        EmergencyProtocol(
            id: "e_sprain",
            title: "Sprained Ankle / Joint",
            tagline: "An overstretched or torn ligament around a joint.",
            icon: "figure.fall",
            severity: "Urgent care",
            severityColor: Theme.signal,
            overview: "A sprain damages the ligaments that stabilize a joint, most often the ankle. Expect pain, swelling, bruising and reduced movement. Early care follows the R.I.C.E. principle.",
            doNow: [
                CarePhase(title: "Rest", detail: "Stop and protect the joint. Avoid weight-bearing if it's painful."),
                CarePhase(title: "Ice", detail: "Apply a wrapped ice pack for 15–20 minutes every 2–3 hours for the first 1–2 days."),
                CarePhase(title: "Compression", detail: "Wrap with an elastic bandage — firm but not so tight it causes numbness or tingling."),
                CarePhase(title: "Elevation", detail: "Raise the joint above heart level when resting to limit swelling.")
            ],
            avoid: ["Heat and massage in the first 48–72 hours", "Putting full weight on a joint that can't bear it"],
            callEmergencyIf: [
                "You can't put any weight on it or it looks out of shape",
                "There's severe swelling, numbness, or the joint feels unstable",
                "Pain and swelling don't start improving after a few days — get it assessed"
            ],
            sources: [
                ArticleSource(publisher: "NHS", title: "Sprains and strains — care advice",
                    url: url("https://www.nhs.uk/conditions/sprains-and-strains/")),
                ArticleSource(publisher: "Mayo Clinic", title: "Sprained ankle — diagnosis & treatment",
                    url: url("https://www.mayoclinic.org/diseases-conditions/sprained-ankle/symptoms-causes/syc-20353225"))
            ]),

        EmergencyProtocol(
            id: "e_fracture",
            title: "Suspected Fracture",
            tagline: "A possible broken bone after a fall or impact.",
            icon: "bandage.fill",
            severity: "Call emergency",
            severityColor: Theme.danger,
            overview: "Suspect a fracture with severe pain, deformity, swelling, an inability to use the limb, or a grinding sensation. A broken bone needs professional treatment — this is stabilization only while help comes.",
            doNow: [
                CarePhase(title: "Call for emergency help", detail: "For an obvious or suspected fracture, call your local emergency number, especially if the leg, hip, or spine is involved."),
                CarePhase(title: "Keep it still", detail: "Don't move the injured part. Support it in the position found; immobilize the joints above and below if trained to."),
                CarePhase(title: "Control any bleeding", detail: "Apply gentle pressure around (not on) a protruding bone with a clean cloth."),
                CarePhase(title: "Treat for shock & cool the area", detail: "Keep the person warm and calm. An ice pack wrapped in cloth can ease pain and swelling while you wait.")
            ],
            avoid: ["Trying to straighten or “pop back” the limb", "Moving the person if a head, neck, or back injury is possible", "Giving food or drink in case surgery is needed"],
            callEmergencyIf: [
                "Bone is poking through the skin, or the limb is clearly deformed",
                "The injury is to the head, neck, back, hip, or thigh",
                "There's heavy bleeding, numbness, or the skin past the injury turns pale or blue"
            ],
            sources: [
                ArticleSource(publisher: "Mayo Clinic", title: "Fractures (broken bones) — first aid",
                    url: url("https://www.mayoclinic.org/first-aid/first-aid-fractures/basics/art-20056641")),
                ArticleSource(publisher: "NHS", title: "Broken arm or wrist / broken bones",
                    url: url("https://www.nhs.uk/conditions/broken-arm-or-wrist/"))
            ]),

        EmergencyProtocol(
            id: "e_heat",
            title: "Heat Exhaustion",
            tagline: "Overheating during or after exertion.",
            icon: "thermometer.sun.fill",
            severity: "Urgent — can escalate",
            severityColor: Theme.signal,
            overview: "Heat exhaustion brings heavy sweating, weakness, dizziness, nausea, headache and a fast, weak pulse. Untreated it can progress to life-threatening heatstroke.",
            doNow: [
                CarePhase(title: "Get out of the heat", detail: "Move to a cool, shaded or air-conditioned place and stop all activity."),
                CarePhase(title: "Cool the body", detail: "Loosen clothing, apply cool wet cloths or a cool shower, and fan the skin."),
                CarePhase(title: "Lie down and elevate the legs", detail: "Rest lying down with the legs slightly raised."),
                CarePhase(title: "Sip cool fluids", detail: "Drink cool water or an electrolyte drink slowly if fully alert and not nauseated.")
            ],
            avoid: ["Returning to exercise too soon", "Drinks with a lot of caffeine or alcohol", "Giving fluids to anyone confused or not fully alert"],
            callEmergencyIf: [
                "Symptoms don't improve within ~30 minutes of cooling and rest",
                "Body temperature is very high, skin is hot and dry, or there's confusion, fainting, or seizures — treat as heatstroke and call emergency services now",
                "The person stops sweating despite the heat, or starts vomiting repeatedly"
            ],
            sources: [
                ArticleSource(publisher: "Mayo Clinic", title: "Heat exhaustion — symptoms & causes",
                    url: url("https://www.mayoclinic.org/diseases-conditions/heat-exhaustion/symptoms-causes/syc-20373250")),
                ArticleSource(publisher: "NHS", title: "Heat exhaustion and heatstroke",
                    url: url("https://www.nhs.uk/conditions/heat-exhaustion-heatstroke/"))
            ]),

        EmergencyProtocol(
            id: "e_faint",
            title: "Fainting / Collapse",
            tagline: "A brief loss of consciousness.",
            icon: "figure.fall.circle.fill",
            severity: "Assess carefully",
            severityColor: Theme.cyan,
            overview: "Fainting is a short loss of consciousness from a temporary drop in blood flow to the brain. Most people recover quickly, but a collapse can also signal something serious.",
            doNow: [
                CarePhase(title: "Lay them down, raise the legs", detail: "Help the person lie flat and raise their legs about 30 cm to restore blood flow to the brain."),
                CarePhase(title: "Check breathing", detail: "Make sure the airway is clear and they are breathing normally."),
                CarePhase(title: "Loosen tight clothing & give air", detail: "Loosen collars or belts and ensure fresh air and space around them."),
                CarePhase(title: "Recover gradually", detail: "Once awake, let them rest before slowly sitting up. Offer water when fully alert.")
            ],
            avoid: ["Sitting or standing them up too quickly", "Crowding them or giving food/drink while groggy", "Slapping or shaking to “wake” them"],
            callEmergencyIf: [
                "They don't regain consciousness within about a minute or aren't breathing normally — call emergency services and start CPR if trained",
                "There was chest pain, palpitations, or fainting during exertion",
                "The person is injured from the fall, pregnant, diabetic, or has repeated episodes"
            ],
            sources: [
                ArticleSource(publisher: "NHS", title: "Fainting",
                    url: url("https://www.nhs.uk/conditions/fainting/")),
                ArticleSource(publisher: "American Red Cross", title: "First aid steps & training",
                    url: url("https://www.redcross.org/take-a-class/first-aid"))
            ]),
    ]
}
