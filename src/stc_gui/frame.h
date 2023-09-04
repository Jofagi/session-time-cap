#include <wx/wx.h>

namespace stc
{

enum class command_id { hello = 1 };

class frame : public wxFrame
{
public:
  frame();

private:
  void on_exit(wxCommandEvent &event);
};

}// namespace stc