add_executable(stc_gui app.cpp frame.cpp)

target_link_libraries(stc_gui PRIVATE session_time_cap::session_time_cap_options
                                      session_time_cap::session_time_cap_warnings)

target_link_system_libraries(
  stc_gui
  PRIVATE
  CLI11::CLI11
  fmt::fmt
  spdlog::spdlog
  lefticus::tools
  wxcore)

target_include_directories(stc_gui PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")
