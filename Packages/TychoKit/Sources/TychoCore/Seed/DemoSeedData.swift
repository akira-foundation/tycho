import Foundation

enum DemoSeedData {
    static let teams: [SeedTeam] = [
        SeedTeam(
            slug: "design", name: "Design", symbol: "paintpalette", color: 0x8662C9,
            summary: "Product design, brand, and research"),
        SeedTeam(
            slug: "eng", name: "Engineering", symbol: "chevron.left.forwardslash.chevron.right", color: 0x3B82C4,
            summary: "Web, mobile, and platform engineering"),
        SeedTeam(
            slug: "mkt", name: "Marketing", symbol: "megaphone", color: 0xC54B78,
            summary: "Campaigns, content, and growth"),
        SeedTeam(
            slug: "product", name: "Product", symbol: "target", color: 0xC48A1E, summary: "Roadmap, planning, and QA"),
    ]

    static let members: [SeedMember] = [
        SeedMember(
            ref: "m1", name: "Tanjim Islam", email: "hello@gr8rstudio.com", role: .owner, team: "product",
            title: "Head of Product", color: 0x5A67D8),
        SeedMember(
            ref: "m2", name: "Sarah Chen", email: "sarah@gr8rstudio.com", role: .admin, team: "design",
            title: "Design Lead", color: 0xC54B78),
        SeedMember(
            ref: "m3", name: "John Carter", email: "john@gr8rstudio.com", role: .member, team: "eng",
            title: "Frontend Engineer", color: 0x3B82C4),
        SeedMember(
            ref: "m4", name: "Emma Wilson", email: "emma@gr8rstudio.com", role: .member, team: "design",
            title: "Product Designer", color: 0x23918A),
        SeedMember(
            ref: "m5", name: "Priya Patel", email: "priya@gr8rstudio.com", role: .member, team: "mkt",
            title: "Content Strategist", color: 0xC48A1E),
        SeedMember(
            ref: "m6", name: "Marcus Lee", email: "marcus@gr8rstudio.com", role: .member, team: "eng",
            title: "Backend Engineer", color: 0x8662C9),
        SeedMember(
            ref: "m7", name: "Lena Fischer", email: "lena@gr8rstudio.com", role: .admin, team: "product",
            title: "QA Lead", color: 0x3D8E5F),
        SeedMember(
            ref: "m8", name: "Diego Alvarez", email: "diego@freelance.io", role: .guest, team: "mkt",
            title: "Freelance Copywriter", color: 0xC0612B),
    ]

    static let projects: [SeedProject] = [
        SeedProject(
            ref: "p1", key: "WEB", name: "Website Redesign", symbol: "globe", color: .indigo, status: .active,
            team: "design", lead: "m2", due: 24, start: -30, favorite: true,
            members: ["m1", "m2", "m3", "m4", "m5", "m6", "m7"],
            summary:
                "Rebuild gr8rstudio.com with a clearer information architecture, a responsive component library, and a faster CMS-driven blog.",
            lastMinutes: 12),
        SeedProject(
            ref: "p2", key: "MOB", name: "Mobile App", symbol: "iphone", color: .blue, status: .active, team: "eng",
            lead: "m3", due: 52, start: -45, favorite: true, members: ["m1", "m3", "m4", "m6", "m7"],
            summary:
                "Native iOS and Android client for field teams with offline sync, push notifications, and biometric sign-in.",
            lastMinutes: 48),
        SeedProject(
            ref: "p3", key: "MKT", name: "Marketing Campaign", symbol: "megaphone", color: .rose, status: .planning,
            team: "mkt", lead: "m5", due: 40, start: -10, favorite: false, members: ["m1", "m4", "m5", "m7", "m8"],
            summary:
                "Q4 awareness campaign across paid social, email, and a launch webinar targeting operations leads.",
            lastMinutes: 130),
        SeedProject(
            ref: "p4", key: "LCH", name: "Product Launch", symbol: "paperplane", color: .amber, status: .risk,
            team: "product", lead: "m1", due: 12, start: -21, favorite: false, members: ["m1", "m2", "m3", "m5", "m7"],
            summary: "Coordinate the Workflows 2.0 launch: pricing, docs, press, and sales enablement across teams.",
            lastMinutes: 35),
        SeedProject(
            ref: "p5", key: "DS", name: "Design System", symbol: "puzzlepiece", color: .violet, status: .active,
            team: "design", lead: "m2", due: 70, start: -60, favorite: false, members: ["m2", "m3", "m4"],
            summary: "Shared tokens, components, and documentation used by web and mobile teams.", lastMinutes: 300),
        SeedProject(
            ref: "p6", key: "CP", name: "Customer Portal", symbol: "building.2", color: .teal, status: .hold,
            team: "eng", lead: "m6", due: 90, start: -5, favorite: false, members: ["m6", "m7"],
            summary:
                "Self-serve billing and support portal for enterprise customers. Restricted during contract review.",
            lastMinutes: 2880),
        SeedProject(
            ref: "p7", key: "MW", name: "Marketing Website", symbol: "square.grid.2x2", color: .green,
            status: .complete, team: "mkt", lead: "m5", due: -18, start: -80, favorite: false,
            members: ["m1", "m3", "m5"],
            summary: "Launch site for the spring release. Shipped and handed to the web team for maintenance.",
            lastMinutes: 26000),
    ]

    static let wireframesNotes = """
        Low-fidelity wireframes for the new homepage covering **desktop, tablet, and mobile** breakpoints.

        - Hero with product value proposition
        - Customer logos and proof points
        - Feature overview linking to product pages

        Reference the navigation audit for IA decisions.
        """

    static let tasks: [SeedTask] = [
        SeedTask(
            project: "p1", title: "Audit existing navigation", status: .done, assignee: "m2", priority: .high, due: -12,
            labels: [.research], estimate: "2d", length: 5, ageDays: 28),
        SeedTask(
            project: "p1", title: "Summarize stakeholder interviews", status: .done, assignee: "m1", priority: .medium,
            due: -9, labels: [.research], estimate: "1d", ageDays: 26),
        SeedTask(
            project: "p1", title: "Create homepage wireframes", status: .review, assignee: "m2", priority: .high,
            due: 1, labels: [.design], estimate: "3d", length: 7, favorite: true, notes: wireframesNotes,
            subtasks: [
                ("Desktop layout", true), ("Tablet layout", true), ("Mobile layout", true),
                ("Annotate interactions", false),
            ]),
        SeedTask(
            project: "p1", title: "Finalize navigation", status: .progress, assignee: "m3", priority: .high, due: 0,
            labels: [.design, .frontend], estimate: "2d", length: 4,
            subtasks: [
                ("Primary nav structure", true), ("Mega-menu content", false), ("Mobile drawer behavior", false),
            ]),
        SeedTask(
            project: "p1", title: "Design responsive navigation", status: .progress, assignee: "m4", priority: .medium,
            due: 3, labels: [.design], estimate: "3d", length: 6,
            subtasks: [("Breakpoint rules", true), ("Sticky header states", false)]),
        SeedTask(
            project: "p1", title: "Prepare design system tokens", status: .todo, assignee: "m1", priority: .medium,
            due: 6, labels: [.design], estimate: "2d", length: 4),
        SeedTask(
            project: "p1", title: "Review responsive layouts", status: .todo, assignee: "m4", priority: .medium, due: 8,
            labels: [.qa, .design], estimate: "1d", length: 3),
        SeedTask(
            project: "p1", title: "Prepare developer handoff", status: .todo, assignee: "m2", priority: .high, due: 14,
            labels: [.frontend], estimate: "2d", length: 4),
        SeedTask(
            project: "p1", title: "Design mobile onboarding", status: .progress, assignee: "m4", priority: .urgent,
            due: -1, labels: [.design], estimate: "3d", length: 6,
            subtasks: [("Welcome screens", true), ("Permission prompts", false), ("Empty states", false)]),
        SeedTask(
            project: "p1", title: "Write homepage copy", status: .backlog, assignee: "m5", priority: .low, due: 18,
            labels: [.content], estimate: "2d"),
        SeedTask(
            project: "p1", title: "Set up analytics events", status: .backlog, assignee: "m6", priority: .medium,
            due: 20, labels: [.backend, .growth], estimate: "1d"),
        SeedTask(
            project: "p1", title: "Accessibility audit of templates", status: .backlog, assignee: "m7", priority: .high,
            due: 22, labels: [.qa], estimate: "2d"),
        SeedTask(
            project: "p1", title: "Build hero component", status: .todo, assignee: "m3", priority: .medium, due: 10,
            labels: [.frontend], estimate: "2d", length: 3),
        SeedTask(
            project: "p1", title: "Image optimization pipeline", status: .review, assignee: "m6", priority: .low,
            due: 2, labels: [.backend], estimate: "1d", length: 5),
        SeedTask(
            project: "p1", title: "Weekly design sync notes", status: .todo, assignee: "m1", priority: .low, due: 2,
            labels: [.content], estimate: "30m", length: 0),
        SeedTask(
            project: "p1", title: "Migrate blog to new CMS", status: .backlog, assignee: "m3", priority: .medium,
            due: 28, labels: [.backend], estimate: "5d", length: 8),
        SeedTask(
            project: "p1", title: "Footer and legal pages", status: .done, assignee: "m5", priority: .low, due: -5,
            labels: [.frontend], estimate: "1d"),
        SeedTask(
            project: "p1", title: "Fix broken anchor links on pricing", status: .done, assignee: "m3",
            priority: .medium, due: -3, labels: [.bug], estimate: "2h", length: 1),
        SeedTask(
            project: "p2", title: "Onboarding flow prototype", status: .progress, assignee: "m4", priority: .high,
            due: 4, labels: [.design], estimate: "3d", length: 6),
        SeedTask(
            project: "p2", title: "Push notification service", status: .progress, assignee: "m6", priority: .high,
            due: 6, labels: [.backend], estimate: "5d", length: 9),
        SeedTask(
            project: "p2", title: "Offline mode sync", status: .todo, assignee: "m3", priority: .urgent, due: 5,
            labels: [.frontend, .backend], estimate: "8d", length: 10),
        SeedTask(
            project: "p2", title: "App Store screenshots", status: .backlog, assignee: "m5", priority: .low, due: 40,
            labels: [.content], estimate: "1d"),
        SeedTask(
            project: "p2", title: "Crash reporting setup", status: .done, assignee: "m6", priority: .medium, due: -8,
            labels: [.backend], estimate: "1d"),
        SeedTask(
            project: "p2", title: "Biometric sign-in", status: .review, assignee: "m3", priority: .high, due: 2,
            labels: [.frontend], estimate: "3d", length: 6),
        SeedTask(
            project: "p2", title: "Settings screen redesign", status: .todo, assignee: "m4", priority: .medium, due: 9,
            labels: [.design], estimate: "2d"),
        SeedTask(
            project: "p2", title: "Triage beta tester feedback", status: .todo, assignee: "m1", priority: .medium,
            due: 0, labels: [.research], estimate: "4h", length: 1),
        SeedTask(
            project: "p2", title: "Crash on Android 12 when rotating", status: .todo, assignee: "m3", priority: .urgent,
            due: 1, labels: [.bug], estimate: "1d", length: 1),
        SeedTask(
            project: "p3", title: "Campaign brief", status: .done, assignee: "m5", priority: .medium, due: -6,
            labels: [.content], estimate: "1d"),
        SeedTask(
            project: "p3", title: "Landing page copy", status: .progress, assignee: "m5", priority: .medium, due: 4,
            labels: [.content], estimate: "2d"),
        SeedTask(
            project: "p3", title: "Paid social creatives", status: .todo, assignee: "m4", priority: .high, due: 7,
            labels: [.design, .growth], estimate: "3d", length: 5),
        SeedTask(
            project: "p3", title: "Email nurture sequence", status: .todo, assignee: "m8", priority: .medium, due: 9,
            labels: [.content], estimate: "2d"),
        SeedTask(
            project: "p3", title: "Influencer outreach list", status: .backlog, assignee: "m7", priority: .low,
            due: nil, labels: [.growth]),
        SeedTask(
            project: "p3", title: "Launch webinar deck", status: .todo, assignee: "m1", priority: .medium, due: 15,
            labels: [.content], estimate: "2d"),
        SeedTask(
            project: "p3", title: "Budget approval", status: .review, assignee: "m1", priority: .urgent, due: -2,
            estimate: "1h", length: 1),
        SeedTask(
            project: "p4", title: "Launch readiness checklist", status: .progress, assignee: "m1", priority: .urgent,
            due: 3, labels: [.qa], estimate: "1d", length: 10,
            subtasks: [
                ("Docs published", true), ("Pricing live", false), ("Support trained", false),
                ("Status page updated", true),
            ]),
        SeedTask(
            project: "p4", title: "Pricing page update", status: .todo, assignee: "m2", priority: .high, due: 6,
            labels: [.design, .frontend], estimate: "2d"),
        SeedTask(
            project: "p4", title: "Press release draft", status: .review, assignee: "m5", priority: .medium, due: 1,
            labels: [.content], estimate: "1d"),
        SeedTask(
            project: "p4", title: "Sales enablement docs", status: .todo, assignee: "m7", priority: .medium, due: 8,
            labels: [.content], estimate: "2d"),
        SeedTask(
            project: "p4", title: "Release notes", status: .backlog, assignee: "m3", priority: .low, due: 11,
            labels: [.content], estimate: "4h"),
        SeedTask(
            project: "p4", title: "Go / no-go meeting", status: .todo, assignee: "m1", priority: .high, due: 11,
            estimate: "1h", length: 0),
        SeedTask(
            project: "p5", title: "Color tokens v2", status: .done, assignee: "m2", priority: .high, due: -4,
            labels: [.design], estimate: "3d"),
        SeedTask(
            project: "p5", title: "Button component audit", status: .progress, assignee: "m2", priority: .medium,
            due: 5, labels: [.design, .frontend], estimate: "2d"),
        SeedTask(
            project: "p5", title: "Form field states", status: .todo, assignee: "m4", priority: .medium, due: 12,
            labels: [.design], estimate: "3d"),
        SeedTask(
            project: "p5", title: "Icon library cleanup", status: .backlog, assignee: "m4", priority: .low, due: nil,
            labels: [.design]),
        SeedTask(
            project: "p5", title: "Documentation site", status: .todo, assignee: "m3", priority: .medium, due: 20,
            labels: [.frontend], estimate: "5d", length: 8),
        SeedTask(
            project: "p5", title: "Dark mode palette", status: .review, assignee: "m2", priority: .high, due: 2,
            labels: [.design], estimate: "2d"),
        SeedTask(
            project: "p7", title: "Launch site QA", status: .done, assignee: "m3", priority: .high, due: -20,
            labels: [.qa]),
        SeedTask(
            project: "p7", title: "Spring release hero video", status: .done, assignee: "m5", priority: .medium,
            due: -24, labels: [.content]),
        SeedTask(
            project: "p6", title: "Billing API contract", status: .todo, assignee: "m6", priority: .high, due: 30,
            labels: [.backend]),
    ]
}
