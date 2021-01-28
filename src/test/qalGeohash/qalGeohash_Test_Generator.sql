--NOTE: Uncomment out the next two lines when needing to initialize the schema (when loading the very first time)
--CREATE SCHEMA qalGeohash_Test_Generator
--GO

DROP FUNCTION IF EXISTS [qalGeohash_Test_Generator].[fromBigint]
GO

CREATE FUNCTION [qalGeohash_Test_Generator].[fromBigint] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE (
        biGeohash                  BIGINT,
        vcTest_Name_Main           VARCHAR(500),
        vcGeohash                  VARCHAR(12),
        dcCenterLongitude          DECIMAL(15, 12),
        dcCenterLatitude           DECIMAL(15, 12),
        vcTest_Name_Auxiliary      VARCHAR(500),
        dcLeftLongitude            DECIMAL(15, 12),
        dcRightLongitude           DECIMAL(15, 12),
        dcLowerLatitude            DECIMAL(15, 12),
        dcUpperLatitude            DECIMAL(15, 12),
        biGeohashParent            BIGINT,
        vcGeohashParent            VARCHAR(12),
        biNorth                    BIGINT,
        biNorthEast                BIGINT,
        biEast                     BIGINT,
        biSouthEast                BIGINT,
        biSouth                    BIGINT,
        biSouthWest                BIGINT,
        biWest                     BIGINT,
        biNorthWest                BIGINT,
        vcTest_Name_Dms            VARCHAR(500),
        tiDegreesAbsoluteLongitude TINYINT,
        tiMinutesLongitude         TINYINT,
        dcSecondsLongitude         DECIMAL(8, 6),
        bIsNegativeLongitude       BIT,
        tiDegreesAbsoluteLatitude  TINYINT,
        tiMinutesLatitude          TINYINT,
        dcSecondsLatitude          DECIMAL(8, 6),
        bIsNegativeLatitude        BIT
      )
  AS
    BEGIN
    DECLARE @vcGeohash VARCHAR(12) = qalGeohash_Main.convertBigintToVarchar(@_biGeohash)
    DECLARE @dcCenterLongitude DECIMAL(15, 12) = NULL
    DECLARE @dcCenterLatitude  DECIMAL(15, 12) = NULL
    DECLARE @dcLeftLongitude   DECIMAL(15, 12) = NULL
    DECLARE @dcRightLongitude  DECIMAL(15, 12) = NULL
    DECLARE @dcLowerLatitude   DECIMAL(15, 12) = NULL
    DECLARE @dcUpperLatitude   DECIMAL(15, 12) = NULL
    SELECT  @dcCenterLongitude = tuple.dcCenterLongitude,
            @dcCenterLatitude  = tuple.dcCenterLatitude,
            @dcLeftLongitude   = tuple.dcLeftLongitude,
            @dcRightLongitude  = tuple.dcRightLongitude,
            @dcLowerLatitude   = tuple.dcLowerLatitude,
            @dcUpperLatitude   = tuple.dcUpperLatitude
      FROM qalGeohash_Main.expandBigintIntoLongLats(@_biGeohash) AS tuple
    DECLARE @biNorth     BIGINT = NULL
    DECLARE @biNorthEast BIGINT = NULL
    DECLARE @biEast      BIGINT = NULL
    DECLARE @biSouthEast BIGINT = NULL
    DECLARE @biSouth     BIGINT = NULL
    DECLARE @biSouthWest BIGINT = NULL
    DECLARE @biWest      BIGINT = NULL
    DECLARE @biNorthWest BIGINT = NULL
    SELECT  @biNorth     = tuple.biNorth,
            @biNorthEast = tuple.biNorthEast,
            @biEast      = tuple.biEast,
            @biSouthEast = tuple.biSouthEast,
            @biSouth     = tuple.biSouth,
            @biSouthWest = tuple.biSouthWest,
            @biWest      = tuple.biWest,
            @biNorthWest = tuple.biNorthWest
      FROM qalGeohash_Auxiliary.neighborsOfBigintAsRow(@_biGeohash) AS tuple
    DECLARE @tiDegreesAbsoluteLongitude TINYINT       = NULL
    DECLARE @tiMinutesLongitude         TINYINT       = NULL
    DECLARE @dcSecondsLongitude         DECIMAL(8, 6) = NULL
    DECLARE @bIsNegativeLongitude       BIT           = NULL
    DECLARE @tiDegreesAbsoluteLatitude  TINYINT       = NULL
    DECLARE @tiMinutesLatitude          TINYINT       = NULL
    DECLARE @dcSecondsLatitude          DECIMAL(8, 6) = NULL
    DECLARE @bIsNegativeLatitude        BIT           = NULL
    SELECT  @tiDegreesAbsoluteLongitude = tuple.tiDegreesAbsoluteLongitude,
            @tiMinutesLongitude         = tuple.tiMinutesLongitude,
            @dcSecondsLongitude         = tuple.dcSecondsLongitude,
            @bIsNegativeLongitude       = tuple.bIsNegativeLongitude,
            @tiDegreesAbsoluteLatitude  = tuple.tiDegreesAbsoluteLatitude,
            @tiMinutesLatitude          = tuple.tiMinutesLatitude,
            @dcSecondsLatitude          = tuple.dcSecondsLatitude,
            @bIsNegativeLatitude        = tuple.bIsNegativeLatitude
      FROM qalGeohash_Dms.expandBigintIntoDmsCheck(@_biGeohash) AS tuple

      --Return the results
      INSERT INTO @table_
        VALUES (
          @_biGeohash,
          'main.positive.' + @vcGeohash,
          @vcGeohash,
          @dcCenterLongitude,
          @dcCenterLatitude,
          'auxiliary.positive.' + @vcGeohash,
          @dcLeftLongitude,
          @dcRightLongitude,
          @dcLowerLatitude,
          @dcUpperLatitude,
          qalGeohash_Auxiliary.parentOfBigint(@_biGeohash),
          qalGeohash_Auxiliary.parentOfVarchar(@vcGeohash),
          @biNorth,
          @biNorthEast,
          @biEast,
          @biSouthEast,
          @biSouth,
          @biSouthWest,
          @biWest,
          @biNorthWest,
          'dms.positive.' + @vcGeohash,
          @tiDegreesAbsoluteLongitude,
          @tiMinutesLongitude,
          @dcSecondsLongitude,
          @bIsNegativeLongitude,
          @tiDegreesAbsoluteLatitude,
          @tiMinutesLatitude,
          @dcSecondsLatitude,
          @bIsNegativeLatitude
        )
      RETURN
    END --qalGeohash_Test_Generator.fromBigint
GO
