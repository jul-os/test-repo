cmake_minimum_required(VERSION 3.24.2)
project(testproj CXX)

add_executable(${PROJECT_NAME} main.cpp
candle.cpp candle.h)


find_package(GTest REQUIRED)
include_directories(${GTEST_INCLUDE_DIRS})

add_executable(candle_tests
    candle.cpp
    candle.h
    tests.cpp
)

target_link_libraries(candle_tests GTest::gtest GTest::gtest_main)