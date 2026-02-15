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

TEST(CandleTest, BodyContains_Candle_OnlyExactPrice)
{
    Candle c{10.0, 15.0, 5.0, 10.0}; // open == close
    EXPECT_TRUE(c.body_contains(10.0));
    EXPECT_FALSE(c.body_contains(10.0001));
    EXPECT_FALSE(c.body_contains(9.9999));
}

// 3 теста для метода contains

TEST(CandleTest, Contains_NormalCandle_IncludesShadows)
{
    Candle c{10.0, 15.0, 5.0, 12.0};
    EXPECT_TRUE(c.contains(5.0));
    EXPECT_TRUE(c.contains(15.0));
    EXPECT_TRUE(c.contains(10.0));
    EXPECT_FALSE(c.contains(4.999));
    EXPECT_FALSE(c.contains(15.001));
}

TEST(CandleTest, Contains_PriceOutsideRange)
{
    Candle c{10.0, 15.0, 5.0, 12.0};
    EXPECT_FALSE(c.contains(4.0));
    EXPECT_FALSE(c.contains(16.0));
}

TEST(CandleTest, Contains_DegenerateCandle_HighEqualsLow)
{
    Candle c{10.0, 10.0, 10.0, 10.0};
    EXPECT_TRUE(c.contains(10.0));
    EXPECT_FALSE(c.contains(10.0001));
    EXPECT_FALSE(c.contains(9.9999));
}

// 3 теста для метода full_size

TEST(CandleTest, FullSize_NormalCandle)
{
    Candle c{10.0, 15.0, 5.0, 12.0};
    EXPECT_NEAR(c.full_size(), 10.0, EPS);
}

TEST(CandleTest, FullSize_ZeroSize)
{
    Candle c{10.0, 10.0, 10.0, 10.0};
    EXPECT_NEAR(c.full_size(), 0.0, EPS);
}

TEST(CandleTest, FullSize_Negative)
{
    // high is lower than low, not possible but...
    Candle c{10.0, 5.0, 15.0, 12.0};
    EXPECT_NEAR(c.full_size(), 10.0, EPS);
}