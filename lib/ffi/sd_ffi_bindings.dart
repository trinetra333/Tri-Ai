// Conditional export: native platforms (Android/iOS/desktop) get the real
// dart:ffi-based bindings; web gets a stub with matching enum types only.
// dart.library.io is true everywhere except web, which is exactly the
// split we need here (dart:ffi is unavailable precisely where dart:io is).
export 'sd_ffi_bindings_stub.dart'
    if (dart.library.io) 'sd_ffi_bindings_io.dart';
