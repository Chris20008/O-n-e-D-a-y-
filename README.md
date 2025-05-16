# O-n-e-D-a-y-

O-n-e-D-a-y-

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Documentation

# 📁 `lib/screens/` – Tiefgehende, semantische Dokumentation

Diese Dokumentation beschreibt im Detail jede Komponente im `lib/screens/`-Ordner, erklärt Aufbau, Klassen, Funktionen und die Datenflüsse zwischen den einzelnen Screens. Sie ist nach Funktionsbereichen gegliedert:

1. [Main Screens](#1-main-screens)  
   1.1 [Workout-Screen](#11-screen_workouts)  
   1.2 [Statistics-Screen](#12-screen_statistics)  
   1.3 [History-Screen](#13-screen_workout_history)  
2. [Other Screens](#2-other-screens)  
   2.1 [Running-Workout-Screen](#21-screen_running_workout)  
   2.2 [Settings-Screen](#22-screen_settings)  
   2.3 [Backup-Datei-Picker](#23-local_file_picker)  
   2.4 [Welcome-Screen](#24-welcome_screen)  
3. [Zusammenhänge & Datenfluss](#3-zusammenhänge--datenfluss)

---

## 1. Main Screens

### 1.1 Workout-Screen (`screen_workouts`)

#### 1.1.1 `screen_workouts.dart`
- **Klassen:**
  - `ScreenWorkout` (StatefulWidget): Einstiegspunkt des Screens.
  - `_ScreenWorkoutState` (State<ScreenWorkout>): verwaltet lokale UI-Logik.
  - `CnWorkouts` (ChangeNotifier): Provider für Workout-Daten (Liste, CRUD-Operationen).
- **Member-Variablen:**
  - `late CnNewWorkOutPanel cnNewWorkout`: steuert das „Neues Workout“-Panel.
  - `late CnBottomMenu cnBottomMenu`: steuert das untere Navigationsmenü.
  - `late CnRunningWorkout cnRunningWorkout`: hält Status für aktives Training.
  - `late CnSpotifyBar cnSpotifyBar`: steuert die Spotify-Leiste.
  - `late CnHomepage cnHomepage`: Status für die Startseite.
  - `late CnConfig cnConfig`: App-Konfigurationen (Theme, Sprache).
  - `late CnWorkouts cnWorkouts`: Zugriff auf gespeicherte Workouts.
  - `bool isVisible`: steuert Sichtbarkeit von Banners und Overlay-Komponenten.
- **Methoden:**
  - `@override Widget build(BuildContext context)`:  
    - Liest Provider-Instanzen, baut Scaffold mit AppBar, `BannerRunningWorkout`, `ListView` der Workouts mittels `WorkoutExpansionTile`.
    - Öffnet via FloatingActionButton das `NewWorkoutPanel`.
    - Beteiligt an State-Änderungen, wenn Workouts hinzugefügt/gelöscht werden.
- **Semantik & Flow:**
  - Der Screen verknüpft UI und Business-Logik über Provider.  
  - Workouts werden in einem ExpandableTile angezeigt; das Panel erlaubt Inline-Erstellung neuer Workouts.

#### 1.1.2 Panels

##### A) New Workout Panel (`panels/new_workout_panel`)
- **`new_workout_panel.dart`**  
  - **Klasse:** `NewWorkoutPanel` (StatefulWidget)  
  - **Beschreibung:** Slide-Up-Panel auf `ScreenWorkout`, um komplette Trainingspläne anzulegen.  
  - Bindet `CnNewWorkOutPanel` zur Verwaltung temporärer Eingaben.
- **Funktionen (`functions/*.dart`):**  
  - `add_exercise.dart`: fügt der internen Liste eine neue Übung hinzu.  
  - `delete_workout.dart`: löscht den gesamten Workout-Entwurf.  
  - `move_tile.dart`: Handhabt Drag-&-Drop-Neuordnung von Übungen.
- **Widgets (`widgets/exercise_and_link_list_view`):**  
  - `exercise_and_link_list_view.dart` (Klasse `ExerciseAndLinkListView`):  
    - `ReorderableListView` für Übungen und verknüpfte Blöcke.  
    - Mischt einzelne `ExerciseWithSlideAction`-Widgets.  
  - `add_exercise_button.dart`: Knopf zum Hinzufügen weiterer Übungen.  
  - `exercise_with_slide_action/`:  
    - **`slidable`-Widget** mit Aktionsebenen (`start_action_pane.dart`, `end_action_pane.dart`), z. B. „Verschieben“ oder „Löschen“.

##### B) New Exercise Panel (`panels/new_exercise_panel`)
- **`new_exercise_panel.dart`**  
  - **Klasse:** `NewExercisePanel` (StatefulWidget)  
  - **Beschreibung:** Detailliertes Panel zur Bearbeitung einer einzelnen Übung (Name, Sätze, Wiederholungen, Gewicht).
- **Funktionen:**  
  - `on_tap_field.dart`: steuert FocusNodes, wenn Nutzer Felder antippt.
- **Widgets:**
  - **Header (`widgets/header`):**  
    - `header.dart`: Titel + `Cancel/Save`-Buttons.  
    - `cancel_save_row.dart`: Row mit den Buttons.
  - **Exercise Name Field (`widgets/header/widgets/exercise_name_field`):**  
    - `exercise_name_field.dart` (Klasse `ExerciseNameField`): `TextFormField` mit  
      - Validatoren (`exercise_name_field_validator.dart`)  
      - Submit-Handler (`on_exercise_name_field_submitted.dart`)
  - **Set List View (`widgets/set_list_view`):**  
    - `set_list_view.dart` (Klasse `SetListView`):  
      - `ReorderableListView` aller Sets.  
      - Bindet an List<SetModel> im Provider `CnNewExercisePanel`.
    - **Funktionen:**  
      - `on_reorder.dart`: aktualisiert die Reihenfolge im Model.
    - **Sub-Widgets:**  
      - `exercise_options_selectors.dart`: Dropdown für Einheiten (kg, lbs).  
      - `footer.dart`: „Satz hinzufügen“-Button.  
      - **Slidable Single Set (`widgets/slidable_single_set`):**  
        - `slidable_single_set.dart`:  
          - `LeftTextField` / `RightTextField` (Gewicht, Wiederholungen).  
          - Slide-Aktionen (`end_action_pane.dart`) zum Löschen/Ändern.

---

### 1.2 Statistics-Screen (`screen_statistics`)

#### 1.2.1 `screen_statistics.dart`
- **Klassen:**
  - `ScreenStatistics` (StatefulWidget)  
  - `_ScreenStatisticsState` (State<ScreenStatistics>)  
  - `CnScreenStatistics` (ChangeNotifier): verwaltet Filter- und Chart-Zustand  
  - `HealthDataPointWrapper`: Hilfsklasse zur Umwandlung von Raw-Datenpunkten  
- **Member-Variablen:**
  - `late CnScreenStatistics cnScreenStatistics`  
  - `late CnStandardPopUp cnStandardPopUp` (genutztes Popup für Fehlermeldungen)  
  - `List<String> allWorkoutNames`, `allExerciseNames`: Listen für Filter-Dropdowns  
  - `late final double heightExerciseLineChartMin/Max`: Bounds für Chart-Höhe  
  - `final Map<String, dynamic> json`: geladene JSON-Daten aus Assets  
- **Methoden:**
  - `@override Widget build(BuildContext)`:  
    - Lädt Filterdaten, baut `FilterStatistics`-Button & `ExerciseLineChart` über `SzWrapper`.  
    - Platziert `HeaderScreenStatistics` und `StatisticsOverlay`.
- **Semantik:**
  - Trennung in drei Schichten: **Daten** (Provider), **Filter-UI** (`FilterStatistics`), **Darstellung** (`ExerciseLineChart` + Overlay).

#### 1.2.2 Filter-Funktionalität
- **`functions/open_filter_pop_up.dart`**  
  - `openFilterPopUp(context)`: zeigt modales Dialog-Widget `FilterStatistics`.
- **`widgets/filter_statistics`**  
  - `filter_statistics.dart` (Haupt-Widget) mit  
    - `FilterStatisticsHeader` (Titel + Apply/Reset)  
    - Widgets zur Auswahl von Zeitraum, Workout-Namen, Übungen.

#### 1.2.3 Chart-Widgets
- **`widgets/charts/sz_controller.dart`**  
  - **Klasse:** `SzController` (ChangeNotifier)  
  - **Beschreibung:** verwaltet `minX`, `maxX`, `scale`, benachrichtigt bei Änderungen.
- **`sz_state_manager.dart`**  
  - Speichert persistent Zoom-/Scroll-Zustand (z. B. für Hot Reload).
- **`spot_manager.dart`**  
  - Filtert Datenpunkte: verringert Anzahl gerenderter Punkte bei Weit-Zoom für Performance.
- **`sz_wrapper.dart`**  
  - Widget, das `SzController` an `LineChart` (fl_chart) bindet, setzt Domain & Range.
- **`exercise_line_chart.dart`**  
  - Implementiert den `LineChart` selbst, definiert Achsen, Styling, Datenquelle.
- **`statistics_overlay.dart`**  
  - Zeichnet interaktive Tooltips und vertikale Linien bei Touch-Events.

---

### 1.3 History-Screen (`screen_workout_history`)

#### `screen_workout_history.dart`
- **Klassen:**
  - `ScreenWorkoutHistory` (StatefulWidget)  
  - `_ScreenWorkoutHistoryState` (State<ScreenWorkoutHistory>)  
  - `CnWorkoutHistory` (ChangeNotifier): liefert vergangene Workout-Daten  
- **Methoden:**
  - `build()`: holt Monatsdaten, zeigt `MonthSummaryChart` und Detailliste.
- **Semantik:**
  - Gruppiert Workouts nach Datum, zeigt pro Tag Farbmarker.

#### `month_summary_chart.dart`
- **Klasse:** `MonthSummaryChart` (StatelessWidget)  
- **Beschreibung:** rendert Balkendiagramm der Workouts pro Tag/Monat via fl_chart.

---

## 2. Other Screens

### 2.1 Running-Workout-Screen (`screen_running_workout`)

#### `screen_running_workout.dart` & `wrapper_screen_running_workout.dart`
- **Klassen:**
  - `ScreenRunningWorkout` (StatefulWidget)  
  - `WrapperScreenRunningWorkout` (StatefulWidget): kapselt Layout-Logik  
  - `CnRunningWorkout` (ChangeNotifier): steuert Timer, aktuelle Übung, Status  
- **Flow:**  
  1. Laden aktiver Workout-Daten aus Provider  
  2. Anzeigen von `RunningWorkoutContent` + `Stopwatch`  
  3. Fußleiste (`RunningWorkoutFooter`) mit „Beenden“/„Abbrechen“-Buttons.

#### Widgets im Running-Workout
- **`animated_column.dart`**: Animiert Layout-Wechsel beim Fortschritt.  
- **`stopwatch.dart`**: Steuert Zeitmessung via `Timer.periodic`.  
- **`selector_exercises_to_update.dart`**: Dropdown/Modal zur Auswahl nächster Übung.  
- **`running_workout_content/`:**  
  - `running_workout_content.dart`: ListView der Sets im Live-Modus.  
  - `exercise_header.dart`: Zeigt Übungsname, Satznummer, Resttimer.  
- **`running_workout_footer.dart`**: Anzeigen von Aktionen nach Session (Save, Discard).

---

### 2.2 Settings-Screen (`screen_settings`)

#### `screen_settings.dart`
- **Klasse:** `ScreenSettings` (StatelessWidget)  
- **Beschreibung:** Listet drei Hauptabschnitte als ListTiles.

#### Funktionen
- `load_backup_from_file_picker.dart`: importiert Backup-JSON via FilePicker.

#### Unterabschnitte
1. **`1_general_settings.dart`**:  
   - Sprache, Theme (Light/Dark), Notification-Toggles.
2. **`2_backup_options.dart`**:  
   - „Backup erstellen“ (JSON exportieren), „Backup laden“.  
3. **`3_about_section.dart`**:  
   - App-Version via `package_info`, rechtliche Links, Entwicklerkontakt.

---

### 2.3 Backup-Datei-Picker (`local_file_picker`)

#### `local_file_picker.dart`
- **Klasse:** `LocalFilePicker` (StatelessWidget)  
- **Beschreibung:** Wrapper um das native FilePicker-Plugin.

#### `widgets/local_backups_list_view`
- **`local_backups_list_view.dart`**:  
  - `ListView.builder` zeigt gefundene JSON-Backups.  
- **`get_file_size_text.dart`**:  
  - `formatFileSize(int bytes)`: wandelt Bytes in KB/MB um.

---

### 2.4 Welcome-Screen (`welcome_screen.dart`)
- **Klassen:**
  - `WelcomeScreen` (StatefulWidget)  
  - `_WelcomeScreenState`: steuert PageView oder einfache Column-Layout.  
- **Beschreibung:** erster Einstieg für neue Nutzer, zeigt Logos, Kurzbeschreibung, „Loslegen“-Button.

---

## 3. Zusammenhänge & Datenfluss

### 3.1 Workout-Erstellung
1. Nutzer tippt „+“ → `ScreenWorkout` baut `NewWorkoutPanel` auf.  
2. `NewWorkoutPanel` nutzt `CnNewWorkOutPanel`, um Eingaben temporär zu speichern.  
3. Hinzugefügte Übungen über `ExerciseAndLinkListView`.  
4. Speichern publisht an `CnWorkouts` → persistiert via ObjectBox.

### 3.2 Statistik-Ansicht
1. `ScreenStatistics` lädt alle Workouts/Übungen in Provider `CnScreenStatistics`.  
2. Filter-Pop-up (`openFilterPopUp`) setzt Kriterien in `CnScreenStatistics`.  
3. `SzController` und `SpotManager` berechnen darzustellende Datenpunkte.  
4. `ExerciseLineChart` rendert via fl_chart, `StatisticsOverlay` ergänzt Interaktivität.

### 3.3 Live-Tracking
1. Start in `ScreenRunningWorkout` → `CnRunningWorkout` startet Timer.  
2. `RunningWorkoutContent` zeigt aktuelle Übung & Sätze.  
3. Widget-Kommunikation über Provider: Pausen- und Satzwechsel per `SelectorExercisesToUpdate`.  
4. Beenden speichert Resultate über `CnRunningWorkout` und navigiert zurück zur History.

---

> **Hinweis:** Jeder Screen ist **feature-first** aufgebaut: UI-Widgets, Business-Logik (ChangeNotifier) und Hilfsfunktionen sind pro Feature in getrennten Ordnern organisiert. Dieser modulare Aufbau erleichtert Wartung, Testbarkeit und spätere Erweiterungen.



[Imprint](https://github.com/Chris20008/O-n-e-D-a-y-/blob/master/IMPRINT.md#imprint)
