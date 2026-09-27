# flutter_local_notifications saves scheduled reminders with Gson so it can
# re-register them after a reboot. Gson reads them back by reflection, so its
# model classes and generic type information must survive shrinking, or
# reminders silently vanish on restart. The plugin ships no rules of its own.
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
