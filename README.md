# Mantra Counter

Offline mantra chanting counter with real-time voice detection using Porcupine wake-word engine.

## Architecture

```
lib/
  main.dart                    # App entry + Dashboard UI (Riverpod)
  data/local/database.dart     # Drift database schema & queries
```

### Database Schema (Drift)

| Table              | Purpose                                     |
|--------------------|---------------------------------------------|
| MantraConfigTable  | Mantra definitions (name, script, target)   |
| SessionsTable      | Chanting session tracking                   |
| DetectionsTable    | Individual detection events with confidence |

### Key Dependencies

| Package                    | Role                          |
|----------------------------|-------------------------------|
| drift + sqlite3_flutter_libs | Reactive local database      |
| flutter_riverpod           | State management              |
| pvporcupine_flutter        | Offline wake-word detection    |
| permission_handler         | Microphone permissions         |
| flutter_background_service | Background audio processing    |

## Setup

```bash
# 1. Install dependencies & generate drift code
flutter pub get
dart run build_runner build

# 2. Get Porcupine access key from https://console.picovoice.ai
#    Train keywords -> download .ppn files -> place in assets/models/

# 3. Add your access key to android/app/build.gradle.kts
#    manifestPlaceholders["PICOVOICE_ACCESS_KEY"] = "your_key_here"

# 4. Run
flutter run
```

## Next Steps

1. **Porcupine Integration** - Implement `PorcupineManager` using `pvporcupine_flutter`
2. **Session Screen** - Real-time counter with audio visualization
3. **Background Service** - Keep counting when app is backgrounded
4. **Statistics** - Session history, streaks, and progress charts
