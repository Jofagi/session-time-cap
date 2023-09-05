#include "app.h"
#include "frame.h"

#include <wx/cmdline.h>

#include <array>
#include <iostream>
#include <memory>

namespace stc
{

bool app::OnInit()
{
  if (!wxApp::OnInit()) { return false; }

  auto main_frame{ std::make_unique<frame>() };
  main_frame->Show();

  [[maybe_unused]] auto *managed_by_framework{ main_frame.release() };

  return true;
}

void app::OnInitCmdLine(wxCmdLineParser &parser)
{
  static constexpr std::array cmd_line_desc = {
    wxCmdLineEntryDesc{ wxCMD_LINE_SWITCH, "h", "help", "displays help on the command line parameters", wxCMD_LINE_VAL_NONE, wxCMD_LINE_OPTION_HELP },
    wxCmdLineEntryDesc{ wxCMD_LINE_SWITCH, "v", "version", "displays the application version", wxCMD_LINE_VAL_NONE, wxCMD_LINE_PARAM_OPTIONAL },
    wxCmdLineEntryDesc{ wxCMD_LINE_NONE, nullptr, nullptr, nullptr, wxCMD_LINE_VAL_NONE, 0 }
  };

  parser.SetDesc(cmd_line_desc.data());
  parser.SetSwitchChars('-');
}

bool app::OnCmdLineParsed(wxCmdLineParser &parser)
{
  if (parser.FoundSwitch('v') == wxCMD_SWITCH_ON) {

    // Print version and exit
    std::cout << "stc_gui v" << STC_GUI_VERSION << '\n';
    return false;
  }

  return true;
}

}// namespace stc

wxIMPLEMENT_APP(stc::app);