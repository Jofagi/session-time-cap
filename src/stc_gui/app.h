#pragma once
#include <wx/wx.h>

namespace stc
{
    
class app : public wxApp
{
public:
  bool OnInit() override;
  void OnInitCmdLine(wxCmdLineParser& parser) override;
  bool OnCmdLineParsed(wxCmdLineParser& parser) override;
};

}// namespace stc

