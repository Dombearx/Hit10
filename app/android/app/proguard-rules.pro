# R8 keep rules for release builds (code shrinking renames classes; these
# libraries look classes up by name at run time).

# WorkManager (pulled in by the Google Mobile Ads SDK) creates its Room
# database by reflection: without this the app crashes at launch with
# "Failed to create an instance of androidx.work.impl.WorkDatabase"
# (found by the emulator smoke test, playtest1).
-keep class * extends androidx.room.RoomDatabase { *; }
-keep class androidx.work.impl.** { *; }

# flutter_local_notifications stores scheduled notifications with Gson.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
