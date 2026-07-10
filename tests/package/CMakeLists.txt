cmake_minimum_required(VERSION 3.15)

project(serial_package_consumer LANGUAGES CXX)

find_package(serial REQUIRED)

add_executable(serial-package-consumer main.cc)
target_link_libraries(serial-package-consumer PRIVATE serial::serial)
