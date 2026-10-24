extension DemoSeedData {
    static let milestones: [SeedMilestone] = [
        SeedMilestone(project: "p1", name: "Wireframes signed off", day: 2),
        SeedMilestone(project: "p1", name: "Dev handoff", day: 14),
        SeedMilestone(project: "p1", name: "Public launch", day: 24),
        SeedMilestone(project: "p2", name: "Beta build", day: 9),
        SeedMilestone(project: "p2", name: "App Store submission", day: 45),
        SeedMilestone(project: "p3", name: "Creative lock", day: 12),
        SeedMilestone(project: "p3", name: "Campaign live", day: 21),
        SeedMilestone(project: "p4", name: "Go / no-go", day: 11),
        SeedMilestone(project: "p4", name: "Launch day", day: 12),
        SeedMilestone(project: "p5", name: "v2 tokens", day: 3),
    ]

    static let events: [SeedEvent] = [
        SeedEvent(title: "Design review", day: 1, time: "10:00", project: "p1"),
        SeedEvent(title: "Sprint planning", day: 5, time: "09:30", project: "p2"),
        SeedEvent(title: "Launch sync", day: 0, time: "15:00", project: "p4"),
        SeedEvent(title: "Stakeholder demo", day: 9, time: "14:00", project: "p1"),
        SeedEvent(title: "Campaign kickoff", day: -3, time: "11:00", project: "p3"),
        SeedEvent(title: "Retro", day: 12, time: "16:00", project: "p2"),
    ]

    static let files: [SeedFile] = [
        SeedFile(
            project: "p1", name: "homepage-wireframes-v3.fig", bytes: 4_404_019, by: "m2", minutesAgo: 300, task: 3),
        SeedFile(project: "p1", name: "nav-audit-findings.pdf", bytes: 880_640, by: "m2", minutesAgo: 8000, task: 3),
        SeedFile(project: "p1", name: "brand-photography-set.zip", bytes: 134_217_728, by: "m4", minutesAgo: 3000),
        SeedFile(project: "p1", name: "hero-exploration.png", bytes: 2_202_010, by: "m4", minutesAgo: 1400),
        SeedFile(project: "p1", name: "content-inventory.xlsx", bytes: 317_440, by: "m5", minutesAgo: 9000),
        SeedFile(project: "p1", name: "sitemap-v2.pdf", bytes: 552_960, by: "m1", minutesAgo: 12000),
        SeedFile(project: "p1", name: "interview-notes.docx", bytes: 98_304, by: "m1", minutesAgo: 20000),
        SeedFile(project: "p1", name: "analytics-events.json", bytes: 12_288, by: "m6", minutesAgo: 700),
        SeedFile(project: "p2", name: "onboarding-flow.fig", bytes: 7_130_317, by: "m4", minutesAgo: 500),
        SeedFile(project: "p2", name: "beta-feedback.xlsx", bytes: 225_280, by: "m1", minutesAgo: 900),
        SeedFile(project: "p3", name: "campaign-brief.pdf", bytes: 1_153_434, by: "m5", minutesAgo: 4000),
        SeedFile(project: "p4", name: "launch-plan.docx", bytes: 184_320, by: "m1", minutesAgo: 6000),
    ]
}
