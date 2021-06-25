#include "run_loop.h"

#include <windows.h>

#include <algorithm>

RunLoop::RunLoop() {}

RunLoop::~RunLoop() {}

void RunLoop::Run() 
{
  TimePoint next_flutter_event_time = TimePoint::clock::now();
    MSG message;
    // All pending Windows messages must be processed; MsgWaitForMultipleObjects
    // won't return again for items left in the queue after PeekMessage.
    while (::GetMessage(&message, nullptr, 0, 0)) 
    {
      ::TranslateMessage(&message);
      ::DispatchMessage(&message);
      // Allow Flutter to process messages each time a Windows message is
      // processed, to prevent starvation.
      next_flutter_event_time =
          std::min(next_flutter_event_time, ProcessFlutterMessages());
    }    // If the PeekMessage loop didn't run, process Flutter messages.
}

void RunLoop::RegisterFlutterInstance(
    flutter::FlutterEngine* flutter_instance) {
  flutter_instances_.insert(flutter_instance);
}

void RunLoop::UnregisterFlutterInstance(
    flutter::FlutterEngine* flutter_instance) {
  flutter_instances_.erase(flutter_instance);
}

RunLoop::TimePoint RunLoop::ProcessFlutterMessages() {
  TimePoint next_event_time = TimePoint::max();
  for (auto instance : flutter_instances_) {
    std::chrono::nanoseconds wait_duration = instance->ProcessMessages();
    if (wait_duration != std::chrono::nanoseconds::max()) {
      next_event_time =
          std::min(next_event_time, TimePoint::clock::now() + wait_duration);
    }
  }
  return next_event_time;
}
