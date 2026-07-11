// Conditional export: native platforms get the real isolate/dart:ffi-based
// processor; web gets a stub that returns a clear "not available" error
// instead of failing to compile.
export 'sd_isolate_processor_stub.dart'
    if (dart.library.io) 'sd_isolate_processor_io.dart';
