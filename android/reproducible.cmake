# Read into every plugin's native (CMake) build; see build.gradle.kts.
#
# The linker's build ID is a hash over inputs that include where the build
# ran, so the same code built on two machines gives different bytes, and
# F-Droid can't match its rebuild to the published APK. Nothing in Nexpill reads
# the ID: it exists for crash-report symbolication, and Nexpill has no crash
# reporting.
add_link_options("LINKER:--build-id=none")
