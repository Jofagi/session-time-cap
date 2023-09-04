#include "app.h"
#include "frame.h"

#include <memory>

namespace stc
{

bool app::OnInit()
{
  auto main_frame{ std::make_unique<frame>() };
  main_frame->Show();

  [[maybe_unused]] auto* managed_by_framework{ main_frame.release() };

  return true;
}

}// namespace stc

wxIMPLEMENT_APP(stc::app);