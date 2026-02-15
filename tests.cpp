#include "candle.h"
#include <gtest/gtest.h>

const double EPS = 1e-9;

// тестЫ для метода body_contains

TEST(CandleTest, BodyContains_GreenCandle_IncludesBoundaries)
{
    Candle c{10.0, 15.0, 5.0, 12.0}; // green: open=10, close=12
    EXPECT_TRUE(c.body_contains(10.0));
    EXPECT_TRUE(c.body_contains(12.0));
    EXPECT_TRUE(c.body_contains(11.0));
    EXPECT_FALSE(c.body_contains(9.9));
    EXPECT_FALSE(c.body_contains(12.1));
}

TEST(CandleTest, BodyContains_RedCandle_IncludesBoundaries)
{
    Candle c{12.0, 15.0, 5.0, 10.0}; // red: open=12, close=10
    EXPECT_TRUE(c.body_contains(10.0));
    EXPECT_TRUE(c.body_contains(12.0));
    EXPECT_TRUE(c.body_contains(11.0));
    EXPECT_FALSE(c.body_contains(9.9));
    EXPECT_FALSE(c.body_contains(12.1));
}

TEST(CandleTest, BodyContains_DojiCandle_OnlyExactPrice)
{
    Candle c{10.0, 15.0, 5.0, 10.0}; // open == close
    EXPECT_TRUE(c.body_contains(10.0));
    EXPECT_FALSE(c.body_contains(10.0001));
    EXPECT_FALSE(c.body_contains(9.9999));
}