if(NOT UNIX)
  return()
endif()

find_package(GTest QUIET)
if(NOT GTest_FOUND)
  message(STATUS "GTest not found; serial tests will not be built.")
  return()
endif()

function(serial_add_gtest target)
  add_executable(${target} ${ARGN})
  target_link_libraries(${target} PRIVATE serial::serial GTest::GTest)
  add_test(NAME ${target} COMMAND ${target})
endfunction()

serial_add_gtest(serial-test unix_serial_tests.cc)
if(NOT APPLE)
  target_link_libraries(serial-test PRIVATE util)
endif()

if(NOT APPLE)
  serial_add_gtest(serial-test-timer unit/unix_timer_tests.cc)
endif()
