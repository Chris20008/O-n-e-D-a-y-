# Behalte Jackson JSON-Bibliothek
-keep class com.fasterxml.** { *; }

# Behalte Spotify SDK Klassen
-keep class com.spotify.** { *; }

# Behalte Android Support Annotations
-keep class android.support.annotation.** { *; }
-keep class androidx.annotation.** { *; }

# Verhindere, dass NotNull-Annotation entfernt wird
-keepattributes *Annotation*

# Falls es weiterhin Probleme gibt, R8 deaktivieren
-dontwarn com.fasterxml.**
-dontwarn com.spotify.**
