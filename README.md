<a href="https://www.qalocate.com" target="_blank"><img src="./QALocate_300ppi.png" alt="QA Locate, a dba of Precision Location Intelligence, Inc." width="268"></a>

[a  dba of Precision Location Intelligence, Inc.](https://www.qalocate.com)

---

<a href="https://qalocate.com/qalgeohash-tsql" target="_blank"><span style="font-family:default; font-size:2.35em; color:#5FA845">qalGeohash-TSQL™</span></a>

  - [`v2021.01.12`](#v20210112)

---

# Table of Contents <!-- omit in toc -->

- [Welcome](#welcome)
  - [Installation](#installation)
  - [Quickstart Introduction - Example Conversions](#quickstart-introduction---example-conversions)
    - [From LongLat To Bigint](#from-longlat-to-bigint)
    - [From Bigint To LongLat](#from-bigint-to-longlat)
    - [From LongLat To Varchar](#from-longlat-to-varchar)
    - [From Varchar To LongLat](#from-varchar-to-longlat)
- [Philosophy](#philosophy)
  - [Why Use a Geohash Instead of Longitude(x)/Latitude(y)?](#why-use-a-geohash-instead-of-longitudexlatitudey)
  - [Why Use `BIGINT` for a Geohash Value?](#why-use-bigint-for-a-geohash-value)
  - [Why LongLat, instead of the opposite of LatLong?](#why-longlat-instead-of-the-opposite-of-latlong)
- [Database Types](#database-types)
  - [Discrete Representations](#discrete-representations)
    - [Integer Type](#integer-type)
    - [String Type](#string-type)
  - [Scalar Representations](#scalar-representations)
    - [LongLat Types](#longlat-types)
    - [Dms Types](#dms-types)
- [Miscellaneous](#miscellaneous)
  - [Preconditions Overhead as Optional](#preconditions-overhead-as-optional)
  - [Functions](#functions)
    - [Naming Prefixes](#naming-prefixes)
    - [Naming Variables](#naming-variables)
    - [Implementation Notes](#implementation-notes)
      - [Dms Functions `CAST`ing to `FLOAT`](#dms-functions-casting-to-float)
      - [Never Returning an Empty `VARCHAR`](#never-returning-an-empty-varchar)
  - [Useful Code Snippets](#useful-code-snippets)
- [Modules](#modules)
  - [Preconditions](#preconditions)
  - [Main](#main)
  - [Dms](#dms)
  - [Auxiliary](#auxiliary)
  - [Geography](#geography)
- [Support](#support)
- [Legal](#legal)
  - [License](#license)
    - [AGPLv3 License](#agplv3-license)
    - [REALLY HATE the AGPLv3? - No Worries, We'd Love to Work with You](#really-hate-the-agplv3---no-worries-wed-love-to-work-with-you)
- [Version History](#version-history)
  - [v2021.01.12](#v20210112)
- [Footnotes](#footnotes)

---

# Welcome

As a library for SQL Server, qalGeohash-TSQL™ is a set of functions for performance, flexibility and utilization of the Geohash

- [Geohash's Wikipedia Entry](https://en.wikipedia.org/wiki/Geohash)

- [7m Video Visually Explaining Geohash](https://www.youtube.com/watch?v=UaMzra18TD8)

Designed for maximum accuracy, performance, and strong conversion consistency guarantees, qalGeohash-TSQL™ enables an average IT data warehouse analyst or report writer to efficiently use, process, and leverage simple GIS spatial proximity models and queries. qalGeohash-TSQL™ accomplishes this without requiring said analyst or report writer to engage in the steep learning curve of finding and adopting a full GIS style solution.

## Installation

SQL Server Privileges

- To install any of these modules, TSQL `SCHEMA` creation and `FUNCTION` creation and execution privileges must be granted to the users intending to do the installation and utilization. This may require speaking with the admin of the SQL Server Database instance into which you intend to install these modules.

Levels

- Absolute Minimum

  - It is possible to start by installing only the [Main](#main) module
  - This requires none of the guarded (`*Check`) functions are called
    - The guarded (`*Check`) functions are dependent upon the [Preconditions](#preconditions) module
  
- Moderate Install
  
  - All basic functionality is covered in the first two modules; [Preconditions](#preconditions) and [Main](#main)

  
- Full Install

  - Requires the Moderate Install
  - Added functionality is covered in the remaining modules; [Dms](#dms), [Auxiliary](#auxiliary), and [Geography](#geography)

---

## Quickstart Introduction - Example Conversions

Below is a quick-start introduction to the most used functions. It is intended to cover just the tip of the iceberg. Please examine the [Modules](#modules) section to see the full range of functions. Please also see the [Useful Code Snippets](#useful-code-snippets) section for plenty of concrete SQL query examples.

### From LongLat To Bigint

The following obtains a `BIGINT` Geohash from a LongLat `DECIMAL` pair with a length of 45 bits (9 characters):

```sql
SELECT qalGeohash_Main.reduceLongLatIntoBigintCheck(
         -96.960422,
         32.892066,
         45
       ) AS biGeohash
```

Result:

|    | biGeohash       |
|----|----------------:|
| 1: | 173433487611976 |

---

### From Bigint To LongLat

The following obtains a LongLat `DECIMAL` pair from a `BIGINT`:

```sql
SELECT *
  FROM qalGeohash_Main.expandBigintIntoLongLatCheck(173433487611976) AS tuple
```

Result:

|    | dcLongitude      | dcLatitude      |
|----|-----------------:|----------------:|
| 1: | -96.960418224336 | 32.892057895662 |

---

### From LongLat To Varchar

The following obtains a `VARCHAR` Geohash from a LongLat `DECIMAL` pair with a length of 9 characters (45 bits):

```sql
SELECT qalGeohash_Main.reduceLongLatIntoVarcharCheck(
         -96.960422,
         32.892066,
         9
       ) AS vcGeohash
```

Result:

|    | vcGeohash |
|----|-----------|
| 1: | 9vg51egd4 |

---

### From Varchar To LongLat

The following obtains LongLat `DECIMAL` pair from a `VARCHAR`:

```sql
SELECT *
  FROM qalGeohash_Main.expandVarcharIntoLongLatCheck('9vg51egd4') AS tuple
```

Result:

|    | dcLongitude      | dcLatitude      |
|----|-----------------:|----------------:|
| 1: | -96.960418224336 | 32.892057895662 |

---

# Philosophy

## Why Use a Geohash Instead of Longitude(x)/Latitude(y)?

It's very important to understand the essential distinction FOR A COMPUTER between "equals" and "near". Or asked a different way: What's the fundamental computational difference between a discrete and a scalar value? Answer Hint: It's a.k.a. digital versus analog.

- The core value behind the Geohash itself is its value as a *discrete* data type (other examples are Boolean, Enumeration, Integer, etc.), as opposed to it being a *scalar* (common examples are Float, Decimal, etc.).

  - Because a discrete data type has an unambiguous bitwise encoding/decoding (i.e. a *lossless* value transformation), it enables the hyper-efficient processing of Boolean logic which is what underlies the support of the equals/not-equals operations.

    - Said another way when using scalars, any reliance on Boolean logic requires the use of a bounded variance (i.e. a *lossy* value transformation) to converge upon an equals/not-equals answer. A scalar requires the computationally expensive method of detecting if the numbers are **NEAR** each other, as opposed to **EQUAL** to each other. It's why it doesn't work to test for equals when dealing with two floating-point numbers. This near-vs-equals distinction has significant storage and performance implications at larger scales. Like processing petabytes of IoT location data.

- To convert a scalar value (ex: longitude and latitude represented by a pair of floating-point numbers) to a discrete value is, by definition, always a "lossy" operation.

  - As an analogy, it is the same thing as digitizing a 35mm photo original. Or converting live music into a digital track. The original is digital-ized. This process is entirely based upon taking an analog value (a floating-point value going out to many decimal places residing between 0.0 and 1.0 with an almost infinite number of possible values) and turning it into a discrete value (an integer value only having a small number of possible values). This reductive operation is also referred to as "pixelizing" analog data. Another old way of referring to this is analog to digital conversion.

- To convert a digital value to a scalar value, by definition, always results in a more "coarse-grained" result than the scalar value could actually hold. This is why when looking at a digital photo that is mostly dark, the different gray contrasts are able to be explicitly seen, even though they appeared as continuous and could not be seen in the original analog photo.

- **tl;dr** Much faster processing of spatial proximity data at petabyte levels is made possible because databases are the most optimized for processing discrete integer values of which the Geohash is perfectly designed. And upon which, qalGeohash-TSQL™ is optimally implemented.

## Why Use `BIGINT` for a Geohash Value?

Given the existence of the `VARCHAR` Geohash value, what's the benefit of using a `BIGINT` instead?

The short answer is much faster table lookup and join performance, substantially reduced storage costs, and low impact future technical flexibility. And all of these are essential if/when one is doing big data/data science/data analytics involving IoT location data event streams measuring in the hundreds of billions.

To explore this, please review the table below to understand some of the nuance behind the various forms of simple location encoding.

| Variable     | Data Type     | Bytes | O-Notation |
|--------------|---------------|:-----:|:---------:|
| biGeohash    | `BIGINT`      | 8     | O(1)      |
| vcGeohash    | `VARCHAR(12)` | 12    | O(n)      |
| LongLat      | Tuple[<br>&ensp;`DECIMAL(15, 12)`,<br>&ensp;`DECIMAL(15, 12)`<br>] | 18    | O(1.5n) |
| vcLongLat    | Tuple[<br>&ensp;`VARCHAR(12)`,<br>&ensp;`VARCHAR(12)`<br>] | 24    | O(2n) |
| LongLatAsDms | Tuple[<br>&ensp;Tuple[<br>&ensp;&ensp;`TINYINT`,<br>&ensp;&ensp;`TINYINT`,<br>&ensp;&ensp;`DECIMAL(10, 2)`,<br>&ensp;&ensp;`BIT`<br>&ensp;],<br>&ensp;Tuple[<br>&ensp;&ensp;`TINYINT`,<br>&ensp;&ensp;`TINYINT`,<br>&ensp;&ensp;`DECIMAL(10, 2)`,<br>&ensp;&ensp;`BIT`<br>&ensp;]<br>] | 23     | O(2n) |

Note: The DMS in "LongLatAs**Dms**" = "**D**egress, **M**inutes, & **S**econds"

- Performance, storage, and technical flexibility

  - Performance - The `equals` operation for a `BIGINT` is essentially CPU atomic.<sup id="cpu-atomic-id">[[1]](#cpu-atomic-footnote)</sup> So, while initially, it might appear at the SQL and source code level there is little difference between the various ways to represent a Geohash value represented as a  `VARCHAR(12)` or a `BIGINT`, deep down in the actual database query plan implementation it becomes vastly different.

   1. Using a `BIGINT` enables an order of magnitude faster `equals` operation than a `VARCHAR`. The `equals` operation for a `VARCHAR` must explicitly traverse every character to confirm the two strings are in fact completely equal.

   2. Because optimizing to minimize CPU cache misses and disk IO are both crucial to high-performance lookups and joins, increasing the number of bytes that must be read, moved around, and evaluated is undesirable. As can be seen from the table above, a VARCHAR is many times slower in equals and is far more likely to negatively impact crucial query performance optimizations.

   3. As to the other three ways LongLats might be encoded and utilized, all are significantly worse than `VARCHAR(12)` in all the same measures that `VARCHAR(12)` is substantially worse than `BIGINT`.

  - Storage - As was alluded to in the Performance section above, increasing the byte size of a location representation has an outsized high impact on space costs.

     1. Just the choice to use a `VARCHAR` instead of a `BIGINT` results in at least a doubling of the total space required.

     2. Using the other representations, which are quite normal across almost all corporate IT data warehouse systems, are much more space costly than even the `VARCHAR` choice, much less the `BIGINT` choice.

  - Technical Flexibility - The business environment can change rapidly causing Customers, partners, new IT systems, etc. to require changes to existing systems. Anticipating and providing flexibility to adapt in the face of these changes is important in keeping a company nimble and competitive in their market(s).

     1. Consider a requirement where one needed to increase the selected Geohash's length from 9 (5x5 meters) to 11 (15x15 centimeters) characters. If the earlier design had decided on `VARCHAR(12)`, it means the cost of working with the data just grew by at least +22%. And this impact is on both performance and storage. If `BIGINT` had been chosen instead, there is no impact in either performance or storage. Exactly the same bucket of bits would behave exactly the same way.
   
     2. Encoding locations via any of the LongLat type shapes is just woefully worse. First, there is no guarantee the extra decimal digits actually represent improved accuracy, and in fact, could be masking far less accurate data. Additionally, they are unable to use the hyper-efficient equals strategy and must resort to the much more expensive nearby tactic. This nearby tactical function must be fully performed at every single compare executed by a lookup or join in that query plan. Again, think of there being millions or even billions of rows in the data warehouse originating from IoT devices.

  **tl;dr** Even with all of the many performance breakthroughs over the years around floating-point numbers and strings, computer systems are STILL hyper-optimized around integer values. Because of this, it makes `BIGINT` the obvious goto for spatial problem spaces needing to plan for either high-performance data science and/or for the tidal wave of IoT data hitting data warehouses and lakes.

## Why LongLat, instead of the opposite of LatLong?

**tl;dr** *Because math*. Software engineering is far more about its relation to math than it is about location.

Location specification and naming is a legacy system now hundreds of years old. And it is only because of the way it has emerged over time that the y-axis (Latitude indicating how far North or South) was placed in front of the x-axis (Longitude indicating how far East or West). This is exactly the opposite of mathematics, and more specifically, geometry upon which spatial data and processing is based.

So, for a software engineer who is already dealing with math, arrays, matrices, and geometry, it creates a cognitive dissonance trying to remember by exception that a spatial coordinate pair is really (y, x); i.e. (Latitude, Longitude). And this dissonance is further amplified for those of us that have dyslexic tendencies. This is solved by having the spatial coordinate pair line up with all the rest of the math world.

How much a software engineer must end up holding within their head simultaneously turns out to be critically important to software authoring quality and productivity. Additionally, this becomes even more important since both coordinates are of the same basic underlying *type* (`DECIMAL`). This means as thousands of lines of code are being written, it is trivial to accidentally submit the spatial coordinate pair in reverse order. And there is no means to discover the error until runtime. Strongly typed languages (ex: Scala) solve this problem at compile-time. Unfortunately, that isn't an option with TSQL, even via User Defined Types.<sup id="same-types-id">[[2]](#same-types-footnote)</sup>

---

# Database Types

Technically a Geohash is a rectangular-like region and not a single point ([watch this short video to more easily visualize an animated Geohash](https://www.youtube.com/watch?v=UaMzra18TD8)). IOW, when asking a Geohash for its "point", what is actually being requested is the **center** of the rectangular-like region defined by the left and right bounds of its longitude and the lower and upper bounds of its latitude. The rectangular-like region, not its center, is what is actually encoded into either an integer or string Geohash value.

---

## Discrete Representations

### Integer Type

- A scalar LongLat value reduced into a discrete Geohash results in one integer value
  - Defined as the SQL type **`BIGINT`**

- Example Value of the 5x5 meters Geohash '[9vg51egd4](https://ui.qalocate.com/#/map/geohash/9vg51egd4)' for the [front door of Starbucks in Las Colinas, TX](https://www.google.com/maps/place/32%C2%B053'31.4%22N+96%C2%B057'37.5%22W/@32.892066,-96.9609715,19z/data=!3m1!4b1!4m6!3m5!1s0x0:0x0!7e2!8m2!3d32.8920657!4d-96.9604228):
  - `biGeohash: 173,433,487,611,976`

### String Type

- A scalar LongLat value reduced into a discrete Geohash results in one string value
  - Defined as the SQL type **`VARCHAR(12)`**

- Example Value of the 5x5 meters Geohash '[9vg51egd4](https://ui.qalocate.com/#/map/geohash/9vg51egd4)' for the [front door of Starbucks in Las Colinas, TX](https://www.google.com/maps/place/32%C2%B053'31.4%22N+96%C2%B057'37.5%22W/@32.892066,-96.9609715,19z/data=!3m1!4b1!4m6!3m5!1s0x0:0x0!7e2!8m2!3d32.8920657!4d-96.9604228):
  - `vcGeohash: '9vg51egd4'`

---

## Scalar Representations

### LongLat Types

- LongLat = (Longitude(x) + Latitude(y))

- A discrete Geohash value expanded into a scalar LongLat result in either a pair or 6 of the same floating-point type

- Compound Type
  - Center Point
    - Longitude - computed by the formula (Right Longitude - Left Longitude) / 2.0
    - Latitude - computed by the formula (Right Latitude - Left Latitude) / 2.0
  - Left and Right Longitude boundaries
  - Lower and Upper Latitude boundaries
  - Each of the above is defined as the SQL type, **`DECIMAL(15, 12)`**

- Example Values of the 5x5 meters Geohash '[9vg51egd4](https://ui.qalocate.com/#/map/geohash/9vg51egd4)' for the [front door of Starbucks in Las Colinas, TX](https://www.google.com/maps/place/32%C2%B053'31.4%22N+96%C2%B057'37.5%22W/@32.892066,-96.9609715,19z/data=!3m1!4b1!4m6!3m5!1s0x0:0x0!7e2!8m2!3d32.8920657!4d-96.9604228):

| columnName        | dcValue          |
|-------------------|-----------------:|
| dcCenterLongitude | -96.960418224336 |
| dcCenterLatitude  | 32.892057895662  |
| dcLeftLongitude   | -96.960439682008 |
| dcRightLongitude  | -96.960396766664 |
| dcLowerLatitude   | 32.892036437989  |
| dcUpperLatitude   | 32.892079353334  |

### Dms Types

- DMS = (**D**egress, **M**inutes, & **S**econds)
  - Decimal LongLat (-96.9604182, 32.8920578) as DMS values:
    - Longitude: -96° 57' 37.5048"
    - Latitude: 32° 53' 31.4082"

- A discrete Geohash value expanded into a scalar Dms result in either a pair or 6 of the same compound type (of the 4 components below)

- Compound type
  - Absolute Degrees - Defined as SQL type **`TINYINT`**
  - Minutes - Defined as SQL type **`TINYINT`**
  - Seconds -  - Defined as SQL type **`DECIMAL(10, 8)`**
  - Signed - Defined as SQL type **`BIT`**

- Example Values for the center of the 5x5 meters Geohash '[9vg51egd4](https://ui.qalocate.com/#/map/geohash/9vg51egd4)' for the [front door of Starbucks in Las Colinas, TX](https://www.google.com/maps/place/32%C2%B053'31.4%22N+96%C2%B057'37.5%22W/@32.892066,-96.9609715,19z/data=!3m1!4b1!4m6!3m5!1s0x0:0x0!7e2!8m2!3d32.8920657!4d-96.9604228):

| columnName        | value            |
|-------------------|-----------------:|
|tiDegreesAbsoluteCenterLongitude|96|
|tiMinutesCenterLongitude|57|
|dcSecondsCenterLongitude|37.505608|
|tiIsNegativeCenterLongitude|1|
|tiDegreesAbsoluteCenterLatitude|32|
|tiMinutesCenterLatitude|53|
|dcSecondsCenterLatitude|31.408424|
|tiIsNegativeCenterLatitude|0|

  - ...next 16 values are not shown which cover the Left/Right Longitude and Lower/Upper Latitude of the boundaries

---

# Miscellaneous

## Preconditions Overhead as Optional

Passing invalid input parameters to the unguarded functions (those without the `*Check` suffix) will *fail ungracefully*.

- To enable efficient processing of already validated qalGeohash-TSQL™ data, a tradeoff was made to provide all of the functions within the [Main](#main), [Dms](#dms), [Auxiliary](#auxiliary), and [Geography](#geography) modules as unguarded; specifically the function names that do not have the `*Check` suffix. These unguarded functions assume the input parameters provided have been pre-validated.

  - By avoiding the overhead of validating the input parameters, if/when an invalid input parameter is provided, the unguarded function's result(s) are **UNDEFINED** and therefore *must* be presumed to be ***SILENTLY ERRONEOUS***.

- Good Practices:
  - By default, call the guarded (`*Check`) version of each function so there is no need to worry about the validity of the data being sent through the functions. This is useful if one has no control over the data set being submitted. And each guarded function is designed to properly return a `NULL` or an empty table result in the event it is provided an invalid input parameter.

  - Proactively use the 'check*' prefixed functions available in the [Preconditions](#preconditions) module
    1. Find and fix any issues using the `check*` functions within a data set prior to sending it through the unguarded functions. The `check*` functions are exactly the same ones being used within the guard logic of the guarded (`*Check`) functions.
  
    2. Employ the `check*` functions within a table's and/or a column's trigger logic to prevent invalid qalGeohash-TSQL™ data from even being inserted (or updated) into a column in the first place.

---

## Functions

### Naming Prefixes

Within each of the modules, [Main](#main), [Dms](#dms), [Auxiliary](#auxiliary), and [Geography](#geography), there appear three different function name prefixes; `convert*`, `expand*`, & `reduce*`. These prefixes are used to distinguish between *lossless* and *lossy* transformations of the underlying data. Please see the [Philosophy](#philosophy) and [Data Types](#database-types) sections for the background on the Scalar-versus-Discrete value distinction for which this naming strategy was inspired.

- Prefixes

  - `convert*` - An essentially lossless conversion where the value is translated to another data type
    - If the function were to be round-tripped, the results should exactly match the original input values.

  - `expand*` - A lossy conversion where the lower grained discrete value is being expanded into a higher grained scalar value type

  - `reduce*` - A lossy conversion where the higher grained scalar value is being reduced into a lower grain discrete value type

---

### Naming Variables

In the event one would like to explore the actual function implementation code in the various modules, here's a description of the source code syntax and styles chosen to maximize the reading comprehension speed of the TSQL source code.

- Using an underscore (`_`) to indicate the intention of a particular variable
  - An underscore prefix indicates the function variable is a function input parameter
    - Ex: `@_biGeohash`

  - An underscore suffix indicates the function variable is the function's `RETURN` value or table
    - For a non-table `RETURN` value:
      - Ex: `@biGeohash_`
    - For a table `RETURN` value:
      - Ex: `@table_`

- Using a Type-Prefix-Abbreviation on variable names to reduce having to hold as many SQL types in one's head simultaneously

  - Prefix: SQL Type

    - `b*`: **`BIT`**
      - Ex: bIsLatitude contains 0 or 1

    - `ch*`: **`CHAR`**
      - Ex: chDirectional contains one of 'N', 'E', 'S', or 'W'

    - `ti*`: **`TINYINT`**
      - Ex: tiMinutes contains 0 to 59 inclusive

    - `bi*`: **`BIGINT`**
      - Ex: biGeohash contains the same range of discrete integer values as java.lang.Long

    - `vc*`: **`VARCHAR`**
      - Ex: vcGeohash contains between 1 and 12 (inclusive) characters that are each limited to the set of the 32 valid Geohash characters; i.e. all 10 digits and only 22 of the 26 letters of the alphabet where the four invalid characters are defined as: 'a', 'i', 'l', and 'o'

    - `dc*`: **`DECIMAL`**
      - Ex: dcLongitude contains the values between -180.0 (inclusive) and 180.0 (inclusive)

    - `gc*`: **`geography::Point`**
      - Ex: gcCenter contains the 'FLOAT' values used by the SQL Server Spatial library

---

### Implementation Notes

#### Dms Functions `CAST`ing to `FLOAT`

- In order to minimize the variance drift of the math operations on `DECIMAL`, all numbers involved in composing and decomposing Dms values were all first `CAST` to `FLOAT`, the math operations performed, and then were converted back into their appropriate type. This ensured the amount of unintended rounding noise typical of floating point values remained at essentially undetectable levels.

#### Never Returning an Empty `VARCHAR`

- In order to eliminate littering client code with empty `VARCHAR`s thereby requiring copious amounts of (`vcGeohash = ''`) tests, this design commits to always returning either a non-empty `VARCHAR` (`LEN(vcGeohash) > 0`) or returning `NULL`.

---

## Useful Code Snippets

***TODO: Insert useful SQL code snippets***

---

# Modules

qalGeohash defines five (5) modules:

1. [Preconditions](#preconditions)
2. [Main](#main)
3. [Dms](#dms)
4. [Auxiliary](#auxiliary)
5. [Geography](#geography)

## Preconditions

  - Schema Name: `qalGeohash_Preconditions`
    - [Source code](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Preconditions.sql#L1)

    - Dependencies:
      - [`qalGeohash_Main`](#main)

  - Each function validates one of the five fundamental "data types" (see ["Database Types"](#database-types) below)

    - If the input parameters are...

      - All Valid: The returned value is `NULL`

      - Any Invalid: The returned value is a `VARCHAR` containing a pipe-delimited detailed description of each of the invalid parameters and how they failed to validate

  - When calling any function with the suffix `*Check` within the four modules; [Main](#main), [Dms](#dms) (**D**egress, **M**inutes, & **S**econds), [Auxiliary](#auxiliary), and [Geography](#geography), some of these Precondition functions are automatically invoked which creates additional performance overhead on each call.

    - While this might sound trivial, it is not when the function is begin called against millions of rows.

    - When invoking a said `*Check` function in those other modules, passing invalid parameters will cause it to gracefully fail by returning a `NULL` value or an empty table

  - Functions:

    - `checkBigint` - [<sub><sup>Source</sup></sub>](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Preconditions.sql#L51)
      - Intention: Ensure is a valid Geohash value
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - failedPreconditions_: `VARCHAR(MAX)`
          - Success: `NULL`
          - Failure: Non-empty `VARCHAR(MAX)` describing which preconditions failed to be met
      - Implementation Notes:
        - Overview: Must not be `NULL`
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `checkSans` - [<sub><sup>Source</sup></sub>](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Preconditions.sql#L98)
      - Intention: Ensure is a valid value in the 60 bits of a Geohash value
      - Input parameters:
        - _biGeohashSans: `BIGINT` - Candidate Geohash Sans value
      - Output:
        - failedPreconditions_: `VARCHAR(MAX)`
          - Success: `NULL`
          - Failure: Non-empty `VARCHAR(MAX)` describing which preconditions failed to be met
      - Implementation Notes:
        - Overview: Must not be `NULL`
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `checkBitsWide` - [<sub><sup>Source</sup></sub>](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Preconditions.sql#L126)
      - Intention: Ensure is a valid quantity of bits for a Geohash value
      - Input parameters:
        - _biBitsWide: `TINYINT` - Candidate bit quantity value
      - Output:
        - failedPreconditions_: `VARCHAR(MAX)`
          - Success: `NULL`
          - Failure: Non-empty `VARCHAR(MAX)` describing which preconditions failed to be met
      - Implementation Notes:
        - Overview: Must not be `NULL`, must be greater than 0, must not be greater than 60, and must be a multiple of 5
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `checkL_itude` - [<sub><sup>Source</sup></sub>](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Preconditions.sql#L155)
      - Intention: Ensure is valid value for one of the LongLat coordinate components
      - Input parameters:
        - _bIsLatitude: `BIT` - 0 for Longitude, and 1 for Latitude
        - _dcL_itude: `DECIMAL(15, 12)`- Candidate LongLat component value
      - Output:
        - failedPreconditions_: `VARCHAR(MAX)`
          - Success: `NULL`
          - Failure: Non-empty `VARCHAR(MAX)` describing which preconditions failed to be met
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `checkVarchar` - [<sub><sup>Source</sup></sub>](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Preconditions.sql#L196)
      - Intention: Ensure is valid Geohash value
      - Input parameters:
        - _vcGeohash: `VARCHAR(12)` - Candidate Geohash value
      - Output:
        - failedPreconditions_: `VARCHAR(MAX)`
          - Success: `NULL`
          - Failure: Non-empty `VARCHAR(MAX)` describing which preconditions failed to be met
      - Implementation Notes:
        - Overview: Must not be `NULL`
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `checkDms` - [<sub><sup>Source</sup></sub>](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Preconditions.sql#L238)
      - Intention: Ensure is valid values for Dms coordinate components
      - Input parameters:
        - _bIsLatitude: `BIT` - 0 for Longitude, and 1 for Latitude
        - _tiDegreesAbsolute: `TINYINT` - Candidate value for ABS(degrees), 0 to (180 when _bIsLatitude = 0, else 90) inclusive
        - _tiMinutes: `TINYINT` - Candidate value for minutes, 0 to 60 exclusive
        - _dcSeconds: `DECIMAL(8, 6)` - Candidate value for seconds, 0.0 to 60.0 exclusive
        - _bIsNegative: `BIT` - 0 if Compass directional is either 'N' or 'E', and 0 for 'S' and 'W'?
      - Output:
        - failedPreconditions_: `VARCHAR(MAX)`
          - Success: `NULL`
          - Failure: Non-empty `VARCHAR(MAX)` describing which preconditions failed to be met
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `checkDmsDirectional` - [<sub><sup>Source</sup></sub>](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Preconditions.sql#L296)
      - Intention: Ensure is valid Dms directional value
      - Input parameters:
        - _chDirectional: `CHAR` - Candidate Compass Directional value
      - Output:
        - failedPreconditions_: `VARCHAR(MAX)`
          - Success: `NULL`
          - Failure: Non-empty `VARCHAR(MAX)` describing which preconditions failed to be met
      - Implementation Notes:
        - Overview: Must not be `NULL` and must upper case and exactly one of 'N', 'E', 'S', or 'W'
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `checkNeighborOrientationEnumId` - [<sub><sup>Source</sup></sub>](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Preconditions.sql#L391)
      - Intention: Ensure is a valid Neighbor Orientation Enum Id value
      - Input parameters:
        - _tiNeighborOrientationEnumId: `TINYINT` - Candidate Neighbor Orientation Enum Id value
      - Output:
        - failedPreconditions_: `VARCHAR(MAX)`
          - Success: `NULL`
          - Failure: Non-empty `VARCHAR(MAX)` describing which preconditions failed to be met
      - Implementation Notes:
        - Overview: Must not be `NULL` and must not be greater than 8
        - Valid _tiNeighborOrientationEnumId values are (ordered clockwise starting at Noon):
          - 0 = North
          - 1 = NorthEast
          - 2 = East
          - 3 = SouthEast
          - 4 = South
          - 5 = SouthWest
          - 6 = West
          - 7 = NorthWest
          - 8 = Center
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `checkNeighborOrientationEnumName` - [<sub><sup>Source</sup></sub>](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Preconditions.sql#L346)
      - Intention: Ensure is a valid Neighbor Orientation Enum Name value
      - Input parameters:
        - _chNeighborOrientationEnumName: `CHAR(2)` - Candidate Neighbor Orientation Enum Id value
      - Output:
        - failedPreconditions_: `VARCHAR(MAX)`
          - Success: `NULL`
          - Failure: Non-empty `VARCHAR(MAX)` describing which preconditions failed to be met
      - Implementation Notes:
        - Overview: Must not be `NULL` and must not be greater than 8
        - Valid _chNeighborOrientationEnumName values are (ordered clockwise starting at Noon):
          - 'N' = 0
          - 'NE' = 1
          - 'E' = 2
          - 'SE' = 3
          - 'S' = 4
          - 'SW' = 5
          - 'W' = 6
          - 'NW' = 7
          - 'C' = 8
        - Please directly examine the `FUNCTION` to see the full set of preconditions

Example usage of just one of the above functions:

```sql
SELECT qalGeohash_Preconditions.checkVarchar('ailogrrrrrailo') AS checkVarcharFailure
```

Results:

- checkVarcharFailure: `|_vcGeohash must not contain invalid character(s) [a,i,l,o,a,i]`<sup id="invalid-characters-id">[[3]](#invalid-characters-footnote)</sup>

---

## Main

  - Schema Name: `qalGeohash_Main`
    - [Source code](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L1)

    - Dependencies:
      - [`qalGeohash_Preconditions`](#preconditions)

  - Each function performs a transformation from one of the three core data types (Bigint, Varchar, or LongLat) to another of these three core data types

  - Functions (each is also available in a version with the suffix, `*Check`, as in `convertBigintToVarcharCheck`):

    - `extractCharsWide` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L114) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L130)</sup></sub>
      - Intention: From the supplied Geohash value as a `BIGINT`, its length in characters
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - tiCharsWide_: `TINYINT` - A value between 1 and 12, inclusive
      - Implementation Notes:
        - Not provided for `VARCHAR(12)`; use the SQL provided `LEN(@vcGeohash)` function
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `extractBitsWide` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L141) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L157)</sup></sub>
      - Intention: From the supplied Geohash value as a `BIGINT`, its length in bits
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - tiBitsWide_: `TINYINT` - A value between 5 and 60, inclusive
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `extractSans` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L168) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L184)</sup></sub>
      - Intention: From the supplied Geohash value as a `BIGINT`, its value in bits
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - biGeohashSans_: `BIGINT` - A value between 0 and (2^60) - 1, inclusive
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `encodeBigint` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L200) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L220)</sup></sub>
      - Intention: From the supplied GeohashSans and bitsWide values, the combined `BIGINT` Geohash value
      - Input parameters:
        - _biGeohashSans: `BIGINT` - Candidate value between 0 and (2^60) - 1, inclusive
        - _tiBitsWide: `BIGINT` - Candidate value between 5 and 60, inclusive
      - Output:
        - biGeohash_: `BIGINT` - A Geohash which is _tiBitsWide bits in length
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `decodeBigint` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L243) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L266)</sup></sub>
      - Intention: From the supplied Geohash value, its two values extracted
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - biGeohashSans_: `BIGINT` - A value between 0 and (2^60) - 1, inclusive
        - tiBitsWide_: `BIGINT` - A value between 5 and 60, inclusive
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `convertBigintToVarchar` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L286) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L302)</sup></sub>
      - Intention: Lossless conversion of a Geohash value from a `BIGINT` to a `VARCHAR` 
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - vcGeohash_: `VARCHAR(12)` - A Geohash which is `charsWide(@_biGeohash)` in length
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `convertVarcharToBigint` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L330) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L346)</sup></sub>
      - Intention: Lossless conversion of a Geohash value from a VARCHAR to a BIGINT 
      - Input parameters:
        - _vcGeohash: `VARCHAR(12)` - Candidate Geohash value
      - Output:
        - biGeohash_: `BIGINT` - A Geohash which is `LEN(@_vcGeohash) * 5` bits in length
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `expandBigintIntoLong` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L372) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L388)</sup></sub>
      - Intention: Lossy conversion of a Geohash value from a `BIGINT` into a single `DECIMAL(15, 12)` value of the Longitude component
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - dcLongitude_: `DECIMAL(15, 12)` - The Longitude part of the center of the biGeohash's rectangular-like region
      - Implementation Notes:
        - Forwards request to `expandBigintIntoLongLats` function
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `expandBigintIntoLat` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L407) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L423)</sup></sub>
      - Intention: Lossy conversion of a Geohash value from a `BIGINT` into a single `DECIMAL(15, 12)` value of the Latitude component
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - dcLatitude_: `DECIMAL(15, 12)` - The Latitude part of the center of the biGeohash's rectangular-like region
      - Implementation Notes:
        - Forwards request to `expandBigintIntoLongLats` function
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `expandBigintIntoLongLat` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L442) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L464)</sup></sub>
      - Intention: Lossy conversion of a Geohash value from a `BIGINT` into a single row table with a pair of `DECIMAL(15, 12)` values
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - table_: Tuple[<br>&emsp;dcLongitude: `DECIMAL(15, 12)`,<br>&emsp;dcLatitude: `DECIMAL(15, 12)`<br>] - The center of the biGeohash's rectangular-like region
      - Implementation Notes:
        - Forwards request to `expandBigintIntoLongLats` function
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `expandBigintIntoLongLats` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L484) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L509)</sup></sub>
      - Intention: Lossy conversion of a Geohash value from a `BIGINT` into a single row table with 6 `DECIMAL(15, 12)` values
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - table_: Tuple[<br>&emsp;dcCenterLongitude: `DECIMAL(15, 12)`,<br>&emsp;dcCenterLatitude: `DECIMAL(15, 12)`,<br>&emsp;dcLeftLongitude: `DECIMAL(15, 12)`,<br>&emsp;dcRightLongitude: `DECIMAL(15, 12)`,<br>&emsp;dcLowerLatitude: `DECIMAL(15, 12)`,<br>&emsp;dcUpperLatitude: `DECIMAL(15, 12)`<br>] - The center of and the boundaries forming biGeohash's rectangular-like region
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `expandVarcharIntoLongLat` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L579) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L601)</sup></sub>
      - Intention: Lossy conversion of a Geohash value from a `VARCHAR(12)` into a single row table with a pair of `DECIMAL(15, 12)` values
      - Input parameters:
        - _vcGeohash: `VARCHAR(12)` - Candidate Geohash value
      - Output:
        - table_: Tuple[<br>&emsp;dcLongitude: `DECIMAL(15, 12)`,<br>&emsp;dcLatitude: `DECIMAL(15, 12)`<br>] - The center of the biGeohash's rectangular-like region
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `expandVarcharIntoLongLats` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L623) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L649)</sup></sub>
      - Intention: Lossy conversion of a Geohash value from a `VARCHAR(12)` into a single row table with 6 `DECIMAL(15, 12)` values
      - Input parameters:
        - _vcGeohash: `VARCHAR(12)` - Candidate Geohash value
      - Output:
        - table_: Tuple[<br>&emsp;dcCenterLongitude: `DECIMAL(15, 12)`,<br>&emsp;dcCenterLatitude: `DECIMAL(15, 12)`,<br>&emsp;dcLeftLongitude: `DECIMAL(15, 12)`,<br>&emsp;dcRightLongitude: `DECIMAL(15, 12)`,<br>&emsp;dcLowerLatitude: `DECIMAL(15, 12)`,<br>&emsp;dcUpperLatitude: `DECIMAL(15, 12)`<br>] - The center of and the boundaries forming biGeohash's rectangular-like region
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `reduceLongLatIntoBigint` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L675) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L697)</sup></sub>
      - Intention: Lossy conversion of a LongLat spatial coordinate pair of `DECIMAL(15, 12)` into a `BIGINT` Geohash value
      - Input parameters:
        - _dcLongitude: `DECIMAL(15, 12)` - Candidate spatial coordinate pair component for th x-axis
        - _dcLatitude: `DECIMAL(15, 12)` - Candidate spatial coordinate pair component for the y-axis
        - _tiBitsWide: `TINYINT` - Candidate length quantity value
      - Output:
        - biGeohash_: `BIGINT` - A Geohash which is `_tiBitsWide` in length
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `reduceLongLatIntoVarchar` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L750) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Main.sql#L774)</sup></sub>
      - Intention: Lossy conversion of a LongLat spatial coordinate pair into a Geohash value string
      - Input parameters:
        - _dcLongitude: `DECIMAL(15, 12)` - Candidate spatial coordinate pair component for the x-axis
        - _dcLatitude: `DECIMAL(15, 12)` - Candidate spatial coordinate pair component for the y-axis
        - _tiCharsWide: `TINYINT` - Candidate length quantity value
      - Output:
        - vcGeohash_: `VARCHAR(12)` - A Geohash which is `_tiCharsWide` characters in length
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

Example Usage:

- Please see those listed in the [Quickstart Introduction](#quickstart-introduction---example-usages) above

---

## Dms

  - Schema Name: `qalGeohash_Dms`
    - [Source code](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L1)

    - Dependencies:
      - [`qalGeohash_Preconditions`](#preconditions)
      - [`qalGeohash_Main`](#main)

  - DMS = (**D**egress, **M**inutes, & **S**econds)
    - Decimal LongLat (-96.9604182, 32.8920578) as DMS values:
      - Longitude: -96° 57' 37.5048"
      - Latitude: 32° 53' 31.4082"

  - Each function performs a transformation to or from the Dms data type to the three core data types

  - Functions (each is also available in a version with the suffix, `*Check`, as in `convertDmsDirectionalToBitCheck`):

    - `convertDmsDirectionalToBit` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L90) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L105)</sup></sub>
      - Intention: Translates a direction encoded as a `CHAR` into a `BIT` 
      - Input parameters:
        - _chDirectional: `CHAR` - Candidate directional value
      - Output:
        - bIsNotNorE_: `BIT` - Is 0 if _chDirectional is either upper case 'N' or 'E', else 1
      - Implementation Notes:
        - If _chDirectional is `NULL or is any other character value than exactly an upper case 'N' or 'E', the returned value is 1
          - IOW, this function will never return NULL, and will return 1 unless the character is exactly an upper case 'N' or 'E'
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `convertDmsToL_itude` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L118) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L139)</sup></sub>
      - Intention: Lossless conversion of a specified Dms coordinate as Tuple[`TINYINT`, `TINYINT`, `DECIMAL(10, 8)`, `BIT`] into a `DECIMAL(15, 12)` representing one of the values of a spatial coordinate pair
      - Input parameters:
        - _tiDegreesAbsolute: `TINYINT` - Candidate degrees absolute (0 to 180 inclusive for Longitude and 0 to 90 inclusive for Latitude)
        - _tiMinutes: `TINYINT` - Candidate minutes absolute (0 to 60 exclusive)
        - _dcSeconds: `DECIMAL(8, 6)` - Candidate seconds absolute (0.0 to 60.0 exclusive)
        - _bIsNegative: `BIT` - If 0, treat degrees as positive (which is either N or E), else treat degrees as negative (which is either S or W)
      - Output:
        - dcL_itude: `DECIMAL(15, 12)` - Converted value
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `convertL_itudeToDms` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L159) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L184)</sup></sub>
      - Intention: Lossless conversion of one of the values of a spatial coordinate pair into the Dms coordinate equivalent as Tuple[`TINYINT`, `TINYINT`, `DECIMAL(10, 8)`, `BIT`]
      - Input parameters:
        - _bIsLatitude: `BIT` - 0 for Longitude, and 1 for Latitude
        - _dcL_itude: `DECIMAL(15, 12)` - Candidate value
      - Output:
        - table_: Tuple[<br>&emsp;tiDegreesAbsolute: `TINYINT`,<br>&emsp;tiMinutes: `TINYINT`,<br>&emsp;dcSeconds: `DECIMAL(10, 8)`,<br>&emsp;bIsNegative: `BIT`,<br>] - Converted value
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `convertDmsToLongLat` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L214) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L264)</sup></sub>
      - Intention: Lossless conversion of a specified Dms coordinate pair into a LongLat coordinate pair
      - Input parameters:
        - _tiDegreesAbsoluteLongitude: `TINYINT` - Candidate degrees absolute (0 to 180 inclusive)
        - _tiMinutesLongitude: `TINYINT` - Candidate minutes absolute (0 to 60 exclusive)
        - _dcSecondsLongitude: `DECIMAL(8, 6)` - Candidate seconds absolute (0.0 to 60.0 exclusive)
        - _bIsNegativeLongitude: `BIT` - If 0, treat degrees as positive (which is E), else treat degrees as negative (which is W)
        - _tiDegreesAbsoluteLatitude: `TINYINT` - Candidate degrees absolute (0 to 90 inclusive)
        - _tiMinutesLatitude: `TINYINT` - Candidate minutes absolute (0 to 60 exclusive)
        - _dcSecondsLatitude: `DECIMAL(8, 6)` - Candidate seconds absolute (0.0 to 60.0 exclusive)
        - _bIsNegativeLatitude: `BIT` - If 0, treat degrees as positive (which is N), else treat degrees as negative (which is S)
      - Output:
        - table_: Tuple[<br>&emsp;dcLongitude: `DECIMAL(15, 12)`,<br>&emsp;dcLatitude: `DECIMAL(15, 12)`<br>] - The center of the biGeohash's rectangular-like region
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `convertLongLatToDms` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L296) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L329)</sup></sub>
      - Intention: Lossless conversion of a LongLat spatial coordinate pair to Dms coordinate pair
      - Input parameters:
        - _dcLongitude: `DECIMAL(15, 12)` - Candidate spatial coordinate pair component for th x-axis
        - _dcLatitude: `DECIMAL(15, 12)` - Candidate spatial coordinate pair component for the y-axis
      - Output:
        - table: Tuple[<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteLongitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesLongitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsLongitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeLongitude: `BIT`,<br>&emsp;],<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteLatitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesLatitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsLatitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeLatitude: `BIT`,<br>&emsp;]<br>] - Converted values
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `expandBigintIntoDms` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L385) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L414)</sup></sub>
      - Intention: Lossy conversion of a Geohash value as `BIGINT` into Dms pair
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - table: Tuple[<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteLongitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesLongitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsLongitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeLongitude: `BIT`,<br>&emsp;],<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteLatitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesLatitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsLatitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeLatitude: `BIT`,<br>&emsp;]<br>] - Converted values
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `expandBigintIntoDmss` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L448) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L493)</sup></sub>
      - Intention: Lossy conversion of a Geohash value into Dms center and rectangular-like boundaries
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - table: Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteCenterLongitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesCenterLongitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsCenterLongitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeCenterLongitude: `BIT`,<br>&emsp;],<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteCenterLatitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesCenterLatitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsCenterLatitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeCenterLatitude: `BIT`,<br>&emsp;],<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteLeftLongitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesLeftLongitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsLeftLongitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeLeftLongitude: `BIT`,<br>&emsp;],<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteRightLongitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesRightLongitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsRightLongitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeRightLongitude: `BIT`,<br>&emsp;],<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteLowerLatitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesLowerLatitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsLowerLatitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeLowerLatitude: `BIT`,<br>&emsp;],<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteUpperLatitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesUpperLatitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsUpperLatitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeUpperLatitude: `BIT`,<br>&emsp;]<br>] - Converted values
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `expandVarcharIntoDms` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L576) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L605)</sup></sub>
      - Intention: Lossy conversion of a Geohash value as `VARCHAR(12)` into Dms coordinate pair
      - Input parameters:
        - _vcGeohash: `VARCHAR(12)` - Candidate Geohash value
      - Output:
        - table: Tuple[<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteLongitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesLongitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsLongitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeLongitude: `BIT`,<br>&emsp;],<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteLatitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesLatitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsLatitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeLatitude: `BIT`,<br>&emsp;]<br>] - Converted values
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `expandVarcharIntoDmss` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L639) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L684)</sup></sub>
      - Intention: Lossy conversion of a Geohash value into Dms center and rectangular-like boundaries
      - Input parameters:
        - _vcGeohash: `VARCHAR(12)` - Candidate Geohash value
      - Output:
        - table: Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteCenterLongitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesCenterLongitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsCenterLongitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeCenterLongitude: `BIT`,<br>&emsp;],<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteCenterLatitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesCenterLatitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsCenterLatitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeCenterLatitude: `BIT`,<br>&emsp;],<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteLeftLongitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesLeftLongitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsLeftLongitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeLeftLongitude: `BIT`,<br>&emsp;],<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteRightLongitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesRightLongitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsRightLongitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeRightLongitude: `BIT`,<br>&emsp;],<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteLowerLatitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesLowerLatitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsLowerLatitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeLowerLatitude: `BIT`,<br>&emsp;],<br>&emsp;Tuple[<br>&emsp;&emsp;tiDegreesAbsoluteUpperLatitude: `TINYINT`,<br>&emsp;&emsp;tiMinutesUpperLatitude: `TINYINT`,<br>&emsp;&emsp;dcSecondsUpperLatitude: `DECIMAL(10, 8)`,<br>&emsp;&emsp;bIsNegativeUpperLatitude: `BIT`,<br>&emsp;]<br>] - Converted values
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `reduceDmsIntoBigint` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L767) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L814)</sup></sub>
      - Intention: Lossy conversion of a specified Dms coordinate pair into a Geohash value as `BIGINT`
      - Input parameters:
        - _tiDegreesAbsoluteLongitude: `TINYINT` - Candidate degrees absolute (0 to 180 inclusive)
        - _tiMinutesLongitude: `TINYINT` - Candidate minutes absolute (0 to 60 exclusive)
        - _dcSecondsLongitude: `DECIMAL(8, 6)` - Candidate seconds absolute (0.0 to 60.0 exclusive)
        - _bIsNegativeLongitude: `BIT` - If 0, treat degrees as positive (which is E), else treat degrees as negative (which is W)
        - _tiDegreesAbsoluteLatitude: `TINYINT` - Candidate degrees absolute (0 to 90 inclusive)
        - _tiMinutesLatitude: `TINYINT` - Candidate minutes absolute (0 to 60 exclusive)
        - _dcSecondsLatitude: `DECIMAL(8, 6)` - Candidate seconds absolute (0.0 to 60.0 exclusive)
        - _bIsNegativeLatitude: `BIT` - If 0, treat degrees as positive (which is N), else treat degrees as negative (which is S)
        - _tiBitsWide: `TINYINT` - Candidate length quantity value
      - Output:
        - biGeohash_: `BIGINT` - A Geohash which is _tiBitsWide in length
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `reduceDmsIntoVarchar` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L844) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Dms.sql#L891)</sup></sub>
      - Intention: Lossy conversion of a specified Dms coordinate pair into a Geohash value as `VARCHAR(12)`
      - Input parameters:
        - _tiDegreesAbsoluteLongitude: `TINYINT` - Candidate degrees absolute (0 to 180 inclusive)
        - _tiMinutesLongitude: `TINYINT` - Candidate minutes (0 to 60 exclusive)
        - _dcSecondsLongitude: `DECIMAL(8, 6)` - Candidate seconds (0.0 to 60.0 exclusive)
        - _bIsNegativeLongitude: `BIT` - If 0, treat degrees as positive (which is E), else treat degrees as negative (which is W)
        - _tiDegreesAbsoluteLatitude: `TINYINT` - Candidate degrees absolute (0 to 90 inclusive)
        - _tiMinutesLatitude: `TINYINT` - Candidate minutes (0 to 60 exclusive)
        - _dcSecondsLatitude: `DECIMAL(8, 6)` - Candidate seconds  (0.0 to 60.0 exclusive)
        - _bIsNegativeLatitude: `BIT` - If 0, treat degrees as positive (which is N), else treat degrees as negative (which is S)
        - _tiCharsWide: `TINYINT` - Candidate length quantity value (multiplied by 5 to produce tiBitsWide)
      - Output:
        - vcGeohash_: `VARCHAR(12)` - A Geohash which is _tiCharsWide in length
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

Example Usage:

```sql
SELECT qalGeohash_Dms.reduceDmsIntoVarcharCheck(
         96, 57, 37.505608, qalGeohash_Dms.convertDmsDirectionalToBitCheck('W'),
         32, 53, 31.408424, qalGeohash_Dms.convertDmsDirectionalToBitCheck('N'),
         9
       ) AS vcGeohash
```

Results:

|    | vcGeohash |
|----|-----------|
| 1: | 9vg51egd4 |

---

## Auxiliary

  - Schema Name: `qalGeohash_Auxiliary`
    - [Source code](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L1)

    - Dependencies:
      - [`qalGeohash_Preconditions`](#preconditions)
      - [`qalGeohash_Main`](#main)

  - Additional functions augmenting use of the Geohash

  - Functions (each is also available in a version with the suffix, `*Check`, as in `neighborOfBigintCheck`):

    - `convertNeighborOrientationEnumFromIdToName` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L96) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L112)</sup></sub>
      - Intention: Translates a Neighbor Orientation Enum Id into a Name
      - Input parameters:
        - _tiNeighborOrientationEnumId: `TINYINT` - Candidate Neighbor Orientation Enum Id value
      - Output:
        - chNeighborOrientationEnumName_: `CHAR(2)` - A Neighbor Orientation Enum Name value
      - Implementation Notes:
        - Valid _tiNeighborOrientationEnumId values are (ordered clockwise starting at Noon):
          - 0 = 'N'
          - 1 = 'NE'
          - 2 = 'E'
          - 3 = 'SE'
          - 4 = 'S'
          - 5 = 'SW'
          - 6 = 'W'
          - 7 = 'NW'
          - 8 = 'C'
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `convertNeighborOrientationEnumFromNameToId` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L136) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L152)</sup></sub>
      - Intention: Translates a Neighbor Orientation Enum Name into an Id 
      - Input parameters:
        - chNeighborOrientationEnumName_: `CHAR(2)` - Candidate Neighbor Orientation Enum Name value
      - Output:
        - _tiNeighborOrientationEnumId: `TINYINT` - A Neighbor Orientation Enum Id value
      - Implementation Notes:
        - Valid _chNeighborOrientationEnumName values are (ordered clockwise starting at Noon):
          - 'N' = 0
          - 'NE' = 1
          - 'E' = 2
          - 'SE' = 3
          - 'S' = 4
          - 'SW' = 5
          - 'W' = 6
          - 'NW' = 7
          - 'C' = 8
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `neighborOfBigint` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L176) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L196)</sup></sub>
      - Intention: From the supplied Geohash value as a `BIGINT`, provide the specified neighbor Geohash values as `BIGINT` 
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
        - _tiNeighborOrientationEnumId: `TINYINT` - Specific Neighbor Orientation requested
      - Output:
        - biGeohash: `BIGINT` - A Geohash value from the specific Neighbor Orientation
      - Implementation Notes:
        - Valid _tiNeighborOrientationEnumId values, 0 to 8 inclusive, are defined in method `convertNeighborOrientationEnumFromIdToName` above
        - It is possible for this function to return `NULL` for a valid _tiNeighborOrientationEnumId value
          - This occurs when the _biGeohash value provided is abutted against either the top of the bottom of the global region
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `neighborsOfBigintAsRow` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L268) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L296)</sup></sub>
      - Intention: From the supplied Geohash, provide into a single row table all 8 neighboring Geohash values
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - table_: Tuple[<br>&emsp;biNorth: `BIGINT`,<br>&emsp;biNorthEast: `BIGINT`,<br>&emsp;biEast: `BIGINT`,<br>&emsp;biSouthEast: `BIGINT`,<br>&emsp;biSouth: `BIGINT`,<br>&emsp;biSouthWest: `BIGINT`,<br>&emsp;biWest: `BIGINT`,<br>&emsp;biNorthWest `BIGINT`<br>] - The surrouding biGeohash's, some of which can be `NULL`
      - Implementation Notes:
        - It is possible for this function to return `NULL` for some column values
          - This occurs when the _biGeohash value provided is abutted against either the top of the bottom of the global region
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `neighborsOfBigintWithSelfAsRow` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L350) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L379)</sup></sub>
      - Intention: From the supplied Geohash value, provide into a single row table with _biGeohash and all 8 neighboring Geohash values
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - table_: Tuple[<br>&emsp;biCenter `BIGINT`,<br>&emsp;biNorth: `BIGINT`,<br>&emsp;biNorthEast: `BIGINT`,<br>&emsp;biEast: `BIGINT`,<br>&emsp;biSouthEast: `BIGINT`,<br>&emsp;biSouth: `BIGINT`,<br>&emsp;biSouthWest: `BIGINT`,<br>&emsp;biWest: `BIGINT`,<br>&emsp;biNorthWest: `BIGINT`] - The surrouding biGeohash's, some of which can be `NULL`
      - Implementation Notes:
        - It is possible for this function to return `NULL` for some column values
          - This occurs when the _biGeohash value provided is abutted against either the top of the bottom of the global region
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `neighborsOfBigintAsTable` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L435) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L458)</sup></sub>
      - Intention: From the supplied Geohash value, provide into up to 8 rows (or 9, when _bIsSelfIncluded = 1) in a table representing all neighboring Geohash values where each row has a Neighbor Orientation Enum Id and a Geohash value
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
        - _bIsSelfIncluded: `BIT` - 0 for excluding _biGeohash, and 1 for including _biGeohash as the first insertion
      - Output:
        - table_: Tuple[<br>&emsp;tiNeighborOrientationEnumId: `TINYINT`,<br>&emsp;biGeohash: `BIGINT`<br>] - The surrouding biGeohash's each represented as a row
      - Implementation Notes:
        - Valid _tiNeighborOrientationEnumId values, 0 to 8 inclusive, are defined in method `convertNeighborOrientationEnumFromIdToName` above
        - It is possible for this function to return fewer than the maximum of 8 rows (or 9, when _bIsSelfIncluded = 1)
          - This occurs when the _biGeohash value provided is abutted against either the top of the bottom of the global region
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `parentOfBigint` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L504) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L520)</sup></sub>
      - Intention: Lossless conversion to the parent of a Geohash value 
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - biGeohash_: `BIGINT` - A Geohash which is the parent of _biGeohash
      - Implementation Notes:
        - This function returns `NULL` if passed a Geohash value that is only 5 bits wide (a single character)
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `parentsOfBigint` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L537) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L564)</sup></sub>
      - Intention: Lossless conversion to all the parents of the Geohash value 
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
        - _tiBitsWideMin: `TINYINT` - The number of bits wide at which to stop, inclusive
        - _bIsSelfIncluded: `BIT` - 0 for excluding _biGeohash, and 1 for including _biGeohash as the first insertion
      - Output:
        - table_: Tuple[<br>&emsp;biGeohash: `BIGINT`<br>] - The parent(s) of _biGeohash, each represented as a row, with _biGeohash inserted first if _bIsSelfIncluded = 1
      - Implementation Notes:
        - This function returns `NULL` if passed a Geohash value that is only 5 bits wide (a single character)
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `parentOfVarchar` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L603) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L619)</sup></sub>
      - Intention: Lossless conversion to the parent of a Geohash value
      - Input parameters:
        - _vcGeohash: `VARCHAR(12)` - Candidate Geohash value
      - Output:
        - vcGeohash_: `VARCHAR(12)` - A Geohash which is the parent of _vcGeohash
      - Implementation Notes:
        - This function returns `NULL` if passed a Geohash value that is only 1 character wide (5 bits wide)
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `parentsOfVarchar` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L637) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L664)</sup></sub>
      - Intention: Lossless conversion to all the parents of the Geohash value 
      - Input parameters:
        - _vcGeohash: `VARCHAR(12)` - Candidate Geohash value
        - _tiCharsWideMin: `TINYINT` - The number of chars wide at which to stop, inclusive
        - _bIsSelfIncluded: `BIT` - 0 for excluding _biGeohash, and 1 for including _biGeohash as the first insertion
      - Output:
        - table_: Tuple[<br>&emsp;vcGeohash: `BIGINT`<br>] - The parent(s) of _vcGeohash, each represented as a row, with _vcGeohash inserted first if _bIsSelfIncluded = 1
      - Implementation Notes:
        - This function returns `NULL` if passed a Geohash value that is only 1 character wide (5 bits wide)
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `changeBitsWide` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L700) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L720)</sup></sub>
      - Intention: Lossless conversion of a Geohash value to a different size in bits
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
        - _tiBitsWideNew: `TINYINT` - The number of bits wide at which to target the size
      - Output:
        - biGeohash_: `BIGINT` - Geohash at the new _tiBitsWideNew size
      - Implementation Notes:
        - When increasing size, injects the equivalent of "s000..." immediately following the shifted left original value
          - Ex: Using `VARCHAR` representation, the value "9vgb" (20 bits wide) becomes the value "9vgbs0000000" when passed 60 for _tiBitsWideNew
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `changeCharsWide` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L750) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Auxiliary.sql#L770)</sup></sub>
      - Intention: Lossless conversion of a Geohash value to a different size in characters
      - Input parameters:
        - _vcGeohash: `BIGINT` - Candidate Geohash value
        - _tiCharsWideNew: `TINYINT` - The number of characters wide at which to target the size
      - Output:
        - vcGeohash_: `VARCHAR(12)` - Geohash at the new _tiCharsWideNew size
      - Implementation Notes:
        - Injects the equivalent of "s000..." immediately following the shifted left  original value
          - Ex: The value "9vgb" (20 bits wide) becomes the value "9vgbs0000000" when passed 60 for _tiBitsWideNew
        - Please directly examine the `FUNCTION` to see the full set of preconditions

Example Usage:

```sql
SELECT *
  FROM qalGeohash_Auxiliary.neighborsOfBigintAsRowCheck(173433487611976)
```

Results:

|    | biNorth         | biNorthEast     | biEast          | biSouthEast     | biSouth         | biSouthWest     | biWest          | biNorthWest     |
|----|-----------------|-----------------|-----------------|-----------------|-----------------|-----------------|-----------------|-----------------|
| 1: | 173433487612008 | 173433487612024 | 173433487611992 | 173433487610616 | 173433487610600 | 173433487610552 | 173433487611928 | 173433487611960 |

---

## Geography

  - Schema Name: `qalGeohash_Geography`
    - [Source code](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Geography.sql#L1)

    - Dependencies:
      - [`qalGeohash_Preconditions`](#preconditions)
      - [`qalGeohash_Main`](#main)

  - Additional functions augmenting use of the Geohash

  - Functions (each is also available in a version with the suffix, `*Check`, as in `expandBigintIntoGeographyPointCheck`):

    - `expandBigintIntoGeographyPoint` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Geography.sql#L48) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Geography.sql#L64)</sup></sub>
      - Intention: Lossy conversion of a Geohash value from a `BIGINT` into a `geography::Point`
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value
      - Output:
        - gcPoint_: `geography::Point` - The center of the biGeohash's rectangular-like region
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `reduceGeographyPointIntoBigint` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Geography.sql#L85) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Geography.sql#L102)</sup></sub>
      - Intention: Lossy conversion of a `geography::Point` into a Geohash value as a `BIGINT`
      - Input parameters:
        - _gcPoint: `geograph::Point` - Candidate coordinate value
        - _tiBitsWide: `TINYINT` - Candidate length quantity value
      - Output:
        - biGeohash_: `BIGINT` - A Geohash which is _tiBitsWide in length
      - Implementation Notes:
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `distanceInMetersBetweenBigints` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Geography.sql#L120) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Geography.sql#L140)</sup></sub>
      - Intention: Calculate the distance in meters between the center point of each Geohash value
      - Input parameters:
        - _biGeohashA: `BIGINT` - Candidate Geohash value A
        - _biGeohashB: `BIGINT` - Candidate Geohash value B
      - Output:
        - fDistanceInMeters_: `FLOAT` - Distance in meters
      - Implementation Notes:
        - Distance function uses the geodesic/geodetic distance which is defined to be the shortest path using the great arc along the ellipsoid of the earth at sea level
          - For more information, see the details here: <http://vterrain.org/Misc/distance.html>
        - Please directly examine the `FUNCTION` to see the full set of preconditions

    - `distanceInMetersBetweenBigintAndGeographyPoint` - <sub><sup>Source: [Checked](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Geography.sql#L160) | [Raw](https://github.com/qalocate/qalgeohash-tsql/blob/main/src/tsql/qalGeohash/qalGeohash_Geography.sql#L177)</sup></sub>
      - Intention: Calculate the distance in meters between the center point of a Geohash and a `geography::Point`
      - Input parameters:
        - _biGeohash: `BIGINT` - Candidate Geohash value A
        - _gcPoint: `geograph::Point` - Candidate coordinate value A
      - Output:
        - fDistanceInMeters_: `FLOAT` - Distance in meters
      - Implementation Notes:
        - Distance function uses the geodesic/geodetic distance which is defined to be the shortest path using the great arc along the ellipsoid of the earth at sea level
          - For more information, see the details here: <http://vterrain.org/Misc/distance.html>
        - Please directly examine the `FUNCTION` to see the full set of preconditions

---

# Support

Learn More about qalGeohash-TSQL™: <https://qalocate.com/qalgeohash-tsql>

Website: <https://www.qalocate.com>

Email: <contact@qalocate.com>

---

# Legal

**Ownership:** qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.

**Brand:** QA Locate™ is a dba of Precision Location Intelligence, Inc.

---

## License

### AGPLv3 License

The qalGeohash-TSQL™ files are free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.

You should have received a copy of the [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.en.html) along with this program.  If not, see <https://www.gnu.org/licenses/>.

---

### REALLY HATE the AGPLv3? - No Worries, We'd Love to Work with You

If the AGPLv3 doesn't work for you, we would LOVE to work with you to generate a **custom/different/commercial/non-profit/government license** for qalGeohash-TSQL™. Please send an email  (to: <contact@qalocate.com>) letting us know what license you would prefer. We are happy to discuss this with you. 

---

# Version History

## v2021.01.12
 - Initial release

# Footnotes

1. <b id="cpu-atomic-footnote">CPU Atomic:</b> Because `BIGINT` is a 8-byte value, it is not guaranteed to be perfectly CPU operation atomic. However, there isn't enough value to dive down into this rabbit hole given `BIGINT` is STILL at least an order of magnitude faster than the fastest handwritten assembly comparing two strings (`VARCHAR`s) composed of the most efficient byte size ASCII characters. [[referenced]](#cpu-atomic-id)

2. <b id="same-types-footnote">Same Types:</b> One of the fascinating benefits of the Scala programming language is it's ability to create custom no-overhead primitive types. It solves this problem by allowing the software engineer to create a new type "Longitude" which is just a type-wrapper for Double. The same is done with "Latitude". Now we have TWO different types with the same underlying implementation as Double. The compiler then ensures a Latitude type cannot be passed where a Longitude type is expected. This simple concept is fantastic for eliminating an entire class of bugs emerging from copious amounts of copying/pasting over large code surface areas. [[referenced]](#same-types-id)

3. <b id="invalid-characters-footnote">Invalid Characters:</b> The reason the final 'l' and 'o' are not present in the `checkVarcharFailure` message is the `checkVarchar` function's input parameter is a `VARCHAR(12)`. This results in only the first 12 characters of the original input parameter being passed into the implementation of the function. [[referenced]](#invalid-characters-id)
