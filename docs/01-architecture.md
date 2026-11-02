# Arquitetura

## Módulos

A app é um target fino (`Tycho/`) sobre o package local `Packages/TychoKit`, com três módulos:

- `TychoCore`: modelos SwiftData, vocabulários, ações de domínio, lógica derivada e seed. Depende só de Foundation e SwiftData.
- `TychoDesign`: tokens, tema e componentes base. Depende só de SwiftUI e das frameworks da plataforma (CoreGraphics, AppKit, UIKit), nunca de `TychoCore`.
- `TychoFeatures`: ecrãs, navegação e estado de vista. Depende dos dois anteriores.

```
Tycho (app) → TychoFeatures → TychoDesign
                            → TychoCore

TychoDesign e TychoCore não dependem um do outro
```

A dependência vai num só sentido. O app target importa `TychoFeatures` (e SwiftUI), e `TychoCore` nunca importa SwiftUI. Sem dependências externas.

## Modelo de dados

Modelos: `Workspace`, `Member`, `Team`, `Project`, `TaskItem`, `Subtask`, `Milestone`, `CalendarEvent`, `FileRecord` e `SavedView`. O nome `TaskItem` evita a colisão com `Task` da concorrência do Swift; a key mostrada (por exemplo `WEB-103`) deriva de `project.key` e `number`.

Regras do schema, para manter a compatibilidade com CloudKit:

- todos os atributos têm valor por omissão ou são opcionais;
- todas as relações são opcionais, com o inverso declarado num dos lados;
- nunca se usa `@Attribute(.unique)`: a unicidade é validada nas ações;
- os enums são guardados como `String` raw (`statusRaw`), com um accessor tipado, e os predicates usam o campo raw;
- cada modelo tem `id: UUID = UUID()` como identidade estável.

Vocabulários iguais ao original: `TaskStatus`, `TaskPriority`, `TaskLabel`, `ProjectStatus`, `ProjectColor` e `MemberRole`.

Na Fase 2 entraram as dependências entre tarefas (`TaskItem.blockedBy`, muitos-para-muitos consigo próprio), os milestones, os eventos e os ficheiros. O `FileRecord` guarda o conteúdo real em `data` com `@Attribute(.externalStorage)`, que no CloudKit passa a CKAsset, e `hasData` diz se há conteúdo sem carregar o blob. Na Fase 3 entrou o `SavedView`: uma vista guardada de um projeto, com nome, layout (`layoutRaw`: List, Board ou Table), filtros codificados em JSON (`filtersData`) e `sortOrder`, ordenada por `Rank`. Ficam para as fases seguintes os comentários, a atividade, as notificações e a recorrência.

## Fluxo das ações

As mutações passam pelas ações do `TychoCore` (`ProjectActions`, `TaskActions`, `SubtaskActions`, `DependencyActions`, `FileActions`, `SavedViewActions`), que recebem um `ModelContext` e um relógio injetado. Cada ação valida, muta e atualiza `updatedAt`. A ordenação da tabela vive em `TableSort`, também no `TychoCore`. As vistas leem com `@Query` e nunca escrevem diretamente, exceto bindings simples do inspector, que também passam por `TaskActions.update`.

- A ordem usa `Rank` (`Rank.swift`): `Rank.between` devolve o ponto médio entre dois vizinhos, `Rank.insert` posiciona um item entre irmãos e `Rank.appendOrder` calcula a ordem do fim do grupo. Quando o intervalo fica abaixo de `Rank.epsilon`, `Rank.insert` renormaliza o grupo em múltiplos de `Rank.step`.
- A lógica derivada é feita de funções puras: `Project.progress`, `TaskItem.progress`, `TaskItem.isOverdue(now:)` e `HomeSummary(now:)`.
- `DependencyActions` liga e desliga dependências dentro do mesmo projeto e rejeita a própria tarefa e o ciclo direto. `TaskActions.reschedule` (drop no Calendar) e `TaskActions.shift` (drag na Timeline) mexem nas datas em dias inteiros e mantêm a duração. `FileActions` acrescenta (até 250 MB), renomeia, duplica e apaga ficheiros.
- A lógica das vistas é pura e testada no Core: `CalendarGrid` e `CalendarDay` (grelha e itens do dia), `TimelineLayout`, `TimelineRows`, `DependencyPath` e `MilestoneLane` (geometria em `Double`, sem SwiftUI), `TaskComparator` e `TableColumnID` (ordenação e colunas), e `DateText` (o formatador partilhado).
- O motor das vistas vive em `Filters/`: `TaskFilter` (campo, operador `is` ou `is not` e valores, para Status, Assignee, Priority, Due date, Project, Labels, Created date e Updated date), `DueBucket`, `TaskViewGrouping`, `TaskViewQuery` (pesquisa, filtros e ordenação aplicados de uma vez) e `TaskViewState`, o estado persistido de cada vista, que guarda também o agrupamento; os grupos saem do `TaskViewModel`.
- `SearchIndex` (em `Search/`) pesquisa tarefas, projetos e ficheiros de uma vez; o `SearchScope` (All, Tasks, Projects, Files) filtra os resultados depois, na palette e na página Search. A página limita as tarefas a 30, como o original.
- `DemoSeed` porta o seed do original (workspace Gr8r Studio, 7 projetos, 49 tarefas); `EmptySeed` cria só o workspace e o membro "me".

## Navegação e ecrãs

- `NavigationSplitView` em todas as plataformas, que no iPhone colapsa em stack.
- A rota é um `enum AppRoute` num `@Observable Router` por janela.
- Rotas do workspace: Home, My Tasks, Tasks, Calendar, Timeline, Projects e Search, mais a de cada projeto. A tab de um projeto é uma das embutidas ou uma saved view (`ProjectTab.savedView`).
- Ecrãs: primeiro arranque, Home, My Tasks, Tasks (List, Board e Table), Calendar (mês e semana), Timeline (setas de dependência e milestones), Projects, Project (Board, List, Table, Calendar, Timeline e Files), inspector de tarefa (com "Blocked by" e "Attachments"), sheets de criação e Settings.
- O `Router` guarda também o estado partilhado do Calendar (data e modo) e da Timeline (zoom e agrupamento).
- Na vista Files os ficheiros chegam por picker ou drop e a pré-visualização usa Quick Look sobre uma cópia temporária, apagada ao fechar. A app é sandboxed e só pede o entitlement de ficheiros escolhidos pelo utilizador em leitura.
- O detalhe da tarefa usa `.inspector(...)` com `inspectorColumnWidth` e passa a sheet em largura compacta (iPhone) ou, no macOS, quando a janela fica abaixo de `InspectorLayout.minimumWindowWidth`. No macOS o `Router` é a fonte desse estado (`inspectsInSheet`), atualizado pela largura da janela. No iOS a vista escolhe entre coluna e sheet pela size class com que está a desenhar, e o `Router` acompanha-a para os comandos (nova tarefa, novo projeto) e para o flush das edições. O `Router` mantém também um registo de flush: o título, a estimativa e a descrição do inspector registam-se nele, e as edições por gravar são guardadas antes de o inspector fechar, trocar de tarefa, mudar entre coluna e sheet, abrir uma sheet de criação com o inspector em sheet, ou a janela fechar.
- As vistas de tarefas (Tasks, My Tasks e as tabs de projeto) partilham o `TaskViewModel` de `ViewEngine/`: toolbar com pesquisa, filtros, agrupamento e ordenação, chips dos filtros ativos (`FilterChips`), construtor de filtros (`FilterBuilder`, com a lista de valores aberta por baixo da linha) e estado vazio filtrado. Os atalhos da Home (Open, Done, Overdue) abrem Tasks com um `TasksPreset`.
- Saved views (`SavedViews/`): cada projeto mostra as suas vistas guardadas como tabs a seguir às embutidas. Guarda-se pelo botão "+" a seguir às tabs (`SaveViewSheet`); renomear e apagar passam pelo menu da vista (`RenameViewSheet`).
- Command palette (`Palette/`): ⌘K ou o botão da toolbar (com o rótulo "Search or jump to…" em janelas a partir de 1400 pt) abre um overlay com dois modos, comandos e pesquisa (Tab alterna). Mostra sugestões, tarefas recentes, pesquisas recentes e resultados por secção; ↑ e ↓ movem a seleção e ↵ corre. "View all" abre a página Search com as contagens por scope.
- Atalhos de teclado (`Shortcuts/`): teclas simples pelo `ShortcutReceiver` (`/` pesquisa, `?` lista de atalhos, `[` sidebar, `N` nova tarefa, `P` novo projeto) e chords `G` seguido de H, T, P, C ou S para navegar. Ficam inativos enquanto se edita texto (`TextEditingMarker`) ou há uma sheet aberta. A lista vem do `ShortcutCatalog` e aparece no `ShortcutsSheet` e nas Settings.
- Comandos: ⌘N nova tarefa, ⌘⇧N novo projeto, ⌘⇧L alterna light e dark, ⌘K abre a palette, ⌘, abre as Settings. A sidebar alterna pelo `SidebarCommands()` do sistema (⌃⌘S).

## Design system

- Cores dinâmicas (light e dark) com os mesmos nomes dos tokens do original, mais cinco cores de status e o accent do sistema (`Color.accentColor`), sem preferência própria.
- Espaçamento, raio, métricas dependentes da density, tipografia SF Pro com Dynamic Type, sombras e motion que respeita `accessibilityReduceMotion`.
- Componentes: `StatusIcon`, `PriorityIcon`, `LabelPill`, `Avatar`, `AvatarStack`, `ProgressRing`, `StatCard`, `ProjectGlyph`, `EmptyState`, `TychoButtonStyle` (primary, secondary e danger) e `TychoToggleStyle`. Os ícones Lucide do original mapeiam para SF Symbols.
- Sidebar, toolbar e inspector usam o Liquid Glass nativo do OS 27.

## Estado e preferências

As preferências (`theme`, `density`, `motion`, `weekStart` e `dateFormat`) ficam em `@AppStorage`, por dispositivo e sem sincronização; nas Settings aparecem como "Start week on" e "Date format", e chegam às vistas pelo `Environment` (`\.weekStart` e `\.dateText`). O estado de cada vista de tarefas (ordenação, colunas escondidas e larguras, pesquisa, filtros, agrupamento e modo) fica em `task.views`, por chave (`p:<id>`, `sv:<id>`, `tasks`, `mytasks`, `cal` e `tl`); o antigo `table.views` é migrado no arranque. As pesquisas recentes ficam em `search.recent`. A rota, a seleção e os grupos colapsados vivem no `Router` e em `@State`.

---
Anterior: [Índice](00-index.md) · Próximo: [Desenvolvimento](02-development.md)
