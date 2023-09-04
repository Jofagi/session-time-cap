#include "frame.h"

#include <memory>
namespace stc
{
frame::frame() : wxFrame(nullptr, wxID_ANY, "Session Time Cap")
{
  auto file_menu{ std::make_unique<wxMenu>() };
  file_menu->Append(static_cast<int>(command_id::hello), "&Hello...\tCtrl+H", "Says Hello");
  file_menu->AppendSeparator();
  file_menu->Append(wxID_EXIT);

  auto help_menu{ std::make_unique<wxMenu>() };
  help_menu->Append(wxID_ABOUT);

  auto menu_bar{ std::make_unique<wxMenuBar>() };
  menu_bar->Append(file_menu.release(), "&File");
  menu_bar->Append(help_menu.release(), "&Help");
  SetMenuBar(menu_bar.release());

  CreateStatusBar();
  SetStatusText("Ready");

  Bind(wxEVT_MENU, &frame::on_exit, this, wxID_EXIT);

  Bind(
    wxEVT_MENU, [](wxCommandEvent &) { wxLogMessage("Hello World!"); }, static_cast<int>(command_id::hello));

  Bind(
    wxEVT_MENU,
    [](wxCommandEvent &) {
      wxMessageBox("This is the Session Time Cap tool.", "About Session Time Cap", wxOK | wxICON_INFORMATION);
    },
    wxID_ABOUT);
}

void frame::on_exit([[maybe_unused]] wxCommandEvent &event) { Close(true); }

}// namespace stc