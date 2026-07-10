cmake_minimum_required(VERSION 3.15)

project(serial
  VERSION 1.2.1
  DESCRIPTION "Cross-platform serial port library"
  LANGUAGES CXX
)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

option(SERIAL_BUILD_EXAMPLES "Build serial examples" ON)
option(SERIAL_BUILD_TESTS "Build serial tests" ON)

set(serial_SRCS
  src/serial.cc
  include/serial/serial.h
  include/serial/v8stdint.h
)

if(APPLE)
  list(APPEND serial_SRCS
    src/impl/unix.cc
    src/impl/list_ports/list_ports_osx.cc
  )
elseif(UNIX)
  list(APPEND serial_SRCS
    src/impl/unix.cc
    src/impl/list_ports/list_ports_linux.cc
  )
else()
  list(APPEND serial_SRCS
    src/impl/win.cc
    src/impl/list_ports/list_ports_win.cc
  )
endif()

add_library(serial ${serial_SRCS})
add_library(serial::serial ALIAS serial)

target_include_directories(serial
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_compile_features(serial PUBLIC cxx_std_98)

if(APPLE)
  find_library(IOKIT_LIBRARY IOKit REQUIRED)
  find_library(FOUNDATION_LIBRARY Foundation REQUIRED)
  target_link_libraries(serial PUBLIC ${FOUNDATION_LIBRARY} ${IOKIT_LIBRARY})
elseif(UNIX)
  find_package(Threads REQUIRED)
  target_link_libraries(serial PUBLIC Threads::Threads rt)
else()
  target_link_libraries(serial PUBLIC setupapi)
endif()

if(SERIAL_BUILD_EXAMPLES)
  add_executable(serial_example examples/serial_example.cc)
  target_link_libraries(serial_example PRIVATE serial::serial)
endif()

include(CTest)
if(BUILD_TESTING AND SERIAL_BUILD_TESTS)
  add_subdirectory(tests)
endif()

install(TARGETS serial
  EXPORT serialTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY include/serial
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT serialTargets
  FILE serialTargets.cmake
  NAMESPACE serial::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/serial
)

configure_package_config_file(
  cmake/serialConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/serialConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/serial
)

write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/serialConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/serialConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/serialConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/serial
)

if(BUILD_TESTING)
  set(SERIAL_PACKAGE_TEST_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/package-test-prefix")
  set(SERIAL_PACKAGE_TEST_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/package-test-build")

  add_test(
    NAME serial-install-package
    COMMAND ${CMAKE_COMMAND} --install ${CMAKE_BINARY_DIR}
      --prefix ${SERIAL_PACKAGE_TEST_PREFIX}
  )

  add_test(
    NAME serial-find-package
    COMMAND ${CMAKE_COMMAND}
      -S ${CMAKE_CURRENT_SOURCE_DIR}/tests/package
      -B ${SERIAL_PACKAGE_TEST_BUILD_DIR}
      -DCMAKE_PREFIX_PATH=${SERIAL_PACKAGE_TEST_PREFIX}
  )
  set_tests_properties(serial-find-package PROPERTIES DEPENDS serial-install-package)

  add_test(
    NAME serial-build-package-consumer
    COMMAND ${CMAKE_COMMAND} --build ${SERIAL_PACKAGE_TEST_BUILD_DIR}
  )
  set_tests_properties(serial-build-package-consumer PROPERTIES DEPENDS serial-find-package)
endif()
