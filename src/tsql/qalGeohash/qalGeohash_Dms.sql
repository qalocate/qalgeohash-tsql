-- /* ---------.---------.---------.---------.---------.---------.--------.---------.---------.---------.---------.--------- *\
-- ** Part Of:     QA Locate Geohash API                                                                                     **
-- ** URL:         http://www.qalocate.com                                                                                   **
-- ** File:                                                                                                                  **
-- **   Name:      qalGeohash_Dms.sql                                                                                        **
-- **   Version:   v2021.02.14                                                                                               **
-- **                                                                                                                        **
-- ** Description:                                                                                                           **
-- **  SQL Server TSQL Implementation of Geohash types and conversion functions                                              **
-- **                                                                                                                        **
-- ** License:   AGPLv3 license (see end of file for details)                                                                **
-- ** Ownership: Copyright (C) 2021 by Precision Location Intelligence, Inc.                                                 **
-- **                                                                                                                        **
-- ** To obtain a custom/different/commercial license for this, please send an email with your request to:                   **
-- **     <mailto:jim.oflaherty.jr@qalocate.com>                                                                             **
-- **                                                                                                                        **
-- \* ---------.---------.---------.---------.---------.---------.--------.---------.---------.---------.---------.--------- */

--NOTE: Uncomment out the next two lines when needing to initialize the schema (when loading the very first time)
--CREATE SCHEMA qalGeohash_Dms
--GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[convertDmsDirectionalToBitCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[convertDmsDirectionalToBit]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[convertDmsToL_itudeCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[convertDmsToL_itude]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[convertL_itudeToDmsCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[convertL_itudeToDms]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[convertDmsToLongLatCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[convertDmsToLongLat]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[convertLongLatToDmsCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[convertLongLatToDms]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[expandBigintIntoDmsCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[expandBigintIntoDms]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[expandBigintIntoDmssCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[expandBigintIntoDmss]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[expandVarcharIntoDmsCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[expandVarcharIntoDms]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[expandVarcharIntoDmssCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[expandVarcharIntoDmss]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[reduceDmsIntoBigintCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[reduceDmsIntoBigint]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[reduceDmsIntoVarcharCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Dms].[reduceDmsIntoVarchar]
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[convertDmsDirectionalToBitCheck] (
  @_chDirectional CHAR
) RETURNS
    BIT
  AS
    BEGIN
      IF (qalGeohash_Preconditions.checkDmsDirectional(@_chDirectional) IS NOT NULL)
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Dms.convertDmsDirectionalToBit(@_chDirectional)
    END --qalGeohash_Dms.convertDmsDirectionalToBitCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[convertDmsDirectionalToBit] (
  @_chDirectional CHAR
) RETURNS
    BIT
  AS
    BEGIN
      IF ((@_chDirectional = 'W') OR (@_chDirectional = 'S'))
        RETURN 1
      RETURN 0
    END --qalGeohash_Dms.convertDmsDirectionalToBit
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[convertDmsToL_itudeCheck] (
  @_bIsLatitude       BIT,
  @_tiDegreesAbsolute TINYINT,       -- 0..180    inclusive
  @_tiMinutes         TINYINT,       -- 0..60     exclusive
  @_dcSeconds         DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegative       BIT            -- If directional, is either S or W?
) RETURNS
    DECIMAL(15, 12)
  AS
    BEGIN
      IF (
        qalGeohash_Preconditions.checkDms(@_bIsLatitude, @_tiDegreesAbsolute, @_tiMinutes, @_dcSeconds, @_bIsNegative) IS NOT NULL
      )
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Dms.convertDmsToL_itude(@_tiDegreesAbsolute, @_tiMinutes, @_dcSeconds, @_bIsNegative)
    END --qalGeohash_Dms.convertDmsToL_itudeCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[convertDmsToL_itude] (
  @_tiDegreesAbsolute TINYINT,       -- 0..180    inclusive
  @_tiMinutes         TINYINT,       -- 0..60     exclusive
  @_dcSeconds         DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegative       BIT            -- If directional, is either S or W?
) RETURNS
    DECIMAL(15, 12)
  AS
    BEGIN
      --Return the results
      RETURN
        (
          CAST(@_tiDegreesAbsolute AS FLOAT) +
          (CAST(@_tiMinutes AS FLOAT) / 60.0) + 
          (CAST(@_dcSeconds AS FLOAT) / 3600.0)
        ) * (CASE WHEN (@_bIsNegative = 0) THEN 1.0 ELSE -1.0 END)
    END --qalGeohash_Dms.convertDmsToL_itude
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[convertL_itudeToDmsCheck] (
  @_bIsLatitude BIT,          -- 0..1 inclusive
  @_dcL_itude   DECIMAL(15, 12)
) RETURNS
    @table_
      TABLE (
        tiDegreesAbsolute TINYINT,
        tiMinutes         TINYINT,
        dcSeconds         DECIMAL(8, 6),
        bIsNegative       BIT
      )
  AS
    BEGIN
      IF (qalGeohash_Preconditions.checkL_itude(@_bIsLatitude, @_dcL_itude) IS NOT NULL)
        RETURN

      --Return the results
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Dms.convertL_itudeToDms(@_bIsLatitude, @_dcL_itude)
      RETURN
    END --qalGeohash_Dms.convertL_itudeToDmsCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[convertL_itudeToDms] (
  @_bIsLatitude BIT,            -- 0..1 inclusive
  @_dcL_itude   DECIMAL(15, 12)
) RETURNS
    @table_
      TABLE (
        tiDegreesAbsolute TINYINT,
        tiMinutes         TINYINT,
        dcSeconds         DECIMAL(8, 6),
        bIsNegative       BIT
      )
  AS
    BEGIN
      DECLARE @dcAbsL_itude      DECIMAL(15, 12) = ABS(@_dcL_itude)
      DECLARE @tiDegreesAbsolute TINYINT         = FLOOR(@dcAbsL_itude)
      DECLARE @tiMinutes         TINYINT         = FLOOR((@dcAbsL_itude - @tiDegreesAbsolute) * 60.0)
    
      --Return the results
      INSERT INTO @table_
        VALUES (
          @tiDegreesAbsolute,
          @tiMinutes,
          (CAST(@dcAbsL_itude - @tiDegreesAbsolute AS FLOAT) - (CAST(@tiMinutes AS FLOAT) / 60.0)) * 3600.0,
          CASE WHEN (@_dcL_itude < 0.0) THEN 1 ELSE 0 END
        )
      RETURN
    END --qalGeohash_Dms.convertL_itudeToDms
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[convertDmsToLongLatCheck] (
  @_tiDegreesAbsoluteLongitude TINYINT,       -- 0..180 inclusive
  @_tiMinutesLongitude         TINYINT,       -- 0..60  exclusive
  @_dcSecondsLongitude         DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegativeLongitude       BIT,           -- If directional, is either S or W?
  @_tiDegreesAbsoluteLatitude  TINYINT,       -- 0..90 inclusive
  @_tiMinutesLatitude          TINYINT,       -- 0..60  exclusive
  @_dcSecondsLatitude          DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegativeLatitude        BIT            -- If directional, is either S or W?
) RETURNS
    @table_
      TABLE (
        dcLongitude DECIMAL(15, 12),
        dcLatitude  DECIMAL(15, 12)
      )
  AS
    BEGIN
      --validate preconditions
      IF (
        (
          qalGeohash_Preconditions.checkDms(
            0, @_tiDegreesAbsoluteLongitude, @_tiMinutesLongitude, @_dcSecondsLongitude, @_bIsNegativeLongitude
          ) IS NOT NULL
        ) OR
        (
          qalGeohash_Preconditions.checkDms(
            1, @_tiDegreesAbsoluteLatitude, @_tiMinutesLatitude, @_dcSecondsLatitude, @_bIsNegativeLatitude
          ) IS NOT NULL
        )
      )
        RETURN

      --Return the results
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Dms.convertDmsToLongLat(
                 @_tiDegreesAbsoluteLongitude,
                 @_tiMinutesLongitude,
                 @_dcSecondsLongitude,
                 @_bIsNegativeLongitude,
                 @_tiDegreesAbsoluteLatitude,
                 @_tiMinutesLatitude,
                 @_dcSecondsLatitude,
                 @_bIsNegativeLatitude
               )
      RETURN
    END --qalGeohash_Dms.convertDmsToLongLatCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[convertDmsToLongLat] (
  @_tiDegreesAbsoluteLongitude TINYINT,       -- 0..180 inclusive
  @_tiMinutesLongitude         TINYINT,       -- 0..60  exclusive
  @_dcSecondsLongitude         DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegativeLongitude       BIT,           -- If directional, is either S or W?
  @_tiDegreesAbsoluteLatitude  TINYINT,       -- 0..90 inclusive
  @_tiMinutesLatitude          TINYINT,       -- 0..60  exclusive
  @_dcSecondsLatitude          DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegativeLatitude        BIT            -- If directional, is either S or W?
) RETURNS
    @table_
      TABLE (
        dcLongitude DECIMAL(15, 12),
        dcLatitude  DECIMAL(15, 12)
      )
  AS
    BEGIN
      --Return the results
      INSERT INTO @table_
        VALUES (
          qalGeohash_Dms.convertDmsToL_itude(
            @_tiDegreesAbsoluteLongitude, @_tiMinutesLongitude, @_dcSecondsLongitude, @_bIsNegativeLongitude
          ),
          qalGeohash_Dms.convertDmsToL_itude(
            @_tiDegreesAbsoluteLatitude, @_tiMinutesLatitude, @_dcSecondsLatitude, @_bIsNegativeLatitude
          )
        )
      RETURN
    END --qalGeohash_Dms.convertDmsToLongLat
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[convertLongLatToDmsCheck] (
  @_dcLongitude DECIMAL(15, 12),
  @_dcLatitude  DECIMAL(15, 12)
) RETURNS
    @table_
      TABLE (
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
      --validate preconditions
      IF (
        (qalGeohash_Preconditions.checkL_itude(0, @_dcLongitude) IS NOT NULL) OR
        (qalGeohash_Preconditions.checkL_itude(1, @_dcLatitude) IS NOT NULL)
      )
        RETURN
      
      --Return the results
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Dms.convertLongLatToDms(@_dcLongitude, @_dcLatitude)
      RETURN
    END --qalGeohash_Dms.convertLongLatToDmsCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[convertLongLatToDms] (
  @_dcLongitude DECIMAL(15, 12),
  @_dcLatitude  DECIMAL(15, 12)
) RETURNS
    @table_
      TABLE (
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
      --Allocate working variables
      DECLARE @tiDegreesAbsoluteLongitude TINYINT       = NULL
      DECLARE @tiMinutesLongitude         TINYINT       = NULL
      DECLARE @dcSecondsLongitude         DECIMAL(8, 6) = NULL
      DECLARE @bIsNegativeLongitude       BIT           = NULL
      DECLARE @tiDegreesAbsoluteLatitude  TINYINT       = NULL
      DECLARE @tiMinutesLatitude          TINYINT       = NULL
      DECLARE @dcSecondsLatitude          DECIMAL(8, 6) = NULL
      DECLARE @bIsNegativeLatitude        BIT           = NULL
      
      --Execute the operation
      SELECT @tiDegreesAbsoluteLongitude = tuple.tiDegreesAbsolute,
             @tiMinutesLongitude         = tuple.tiMinutes,
             @dcSecondsLongitude         = tuple.dcSeconds,
             @bIsNegativeLongitude       = tuple.bIsNegative
        FROM qalGeohash_Dms.convertL_itudeToDms(0, @_dcLongitude) AS tuple
      SELECT @tiDegreesAbsoluteLatitude  = tuple.tiDegreesAbsolute,
             @tiMinutesLatitude          = tuple.tiMinutes,
             @dcSecondsLatitude          = tuple.dcSeconds,
             @bIsNegativeLatitude        = tuple.bIsNegative
        FROM qalGeohash_Dms.convertL_itudeToDms(1, @_dcLatitude) AS tuple

      --Return the results
      INSERT INTO @table_
        VALUES (
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
    END --qalGeohash_Dms.convertLongLatToDms
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[expandBigintIntoDmsCheck] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE (
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
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN
    
      --Return the results
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Dms.expandBigintIntoDms(@_biGeohash)
      RETURN
    END --qalGeohash_Dms.expandBigintIntoDmsCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[expandBigintIntoDms] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE (
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
      --Allocate working variables
      DECLARE @dcLongitude DECIMAL(15, 12) = NULL
      DECLARE @dcLatitude  DECIMAL(15, 12) = NULL

      --Execute the operation
      SELECT @dcLongitude = tuple.dcLongitude,
             @dcLatitude  = tuple.dcLatitude
        FROM qalGeohash_Main.expandBigintIntoLongLat(@_biGeohash) AS tuple

      --Return the results
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Dms.convertLongLatToDms(@dcLongitude, @dcLatitude)
      RETURN
    END --qalGeohash_Dms.expandBigintIntoDms
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[expandBigintIntoDmssCheck] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE (
        tiDegreesAbsoluteCenterLongitude TINYINT,
        tiMinutesCenterLongitude         TINYINT,
        dcSecondsCenterLongitude         DECIMAL(8, 6),
        bIsNegativeCenterLongitude       BIT,
        tiDegreesAbsoluteCenterLatitude  TINYINT,
        tiMinutesCenterLatitude          TINYINT,
        dcSecondsCenterLatitude          DECIMAL(8, 6),
        bIsNegativeCenterLatitude        BIT,
        tiDegreesAbsoluteLeftLongitude   TINYINT,
        tiMinutesLeftLongitude           TINYINT,
        dcSecondsLeftLongitude           DECIMAL(8, 6),
        bIsNegativeLeftLongitude         BIT,
        tiDegreesAbsoluteRightLongitude  TINYINT,
        tiMinutesRightLongitude          TINYINT,
        dcSecondsRightLongitude          DECIMAL(8, 6),
        bIsNegativeRightLongitude        BIT,
        tiDegreesAbsoluteLowerLatitude   TINYINT,
        tiMinutesLowerLatitude           TINYINT,
        dcSecondsLowerLatitude           DECIMAL(8, 6),
        bIsNegativeLowerLatitude         BIT,
        tiDegreesAbsoluteUpperLatitude   TINYINT,
        tiMinutesUpperLatitude           TINYINT,
        dcSecondsUpperLatitude           DECIMAL(8, 6),
        bIsNegativeUpperLatitude         BIT
      )
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN
    
      --Return the results
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Dms.expandBigintIntoDmss(@_biGeohash)
      RETURN
    END --qalGeohash_Dms.expandBigintIntoDmssCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[expandBigintIntoDmss] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE (
        tiDegreesAbsoluteCenterLongitude TINYINT,
        tiMinutesCenterLongitude         TINYINT,
        dcSecondsCenterLongitude         DECIMAL(8, 6),
        bIsNegativeCenterLongitude       BIT,
        tiDegreesAbsoluteCenterLatitude  TINYINT,
        tiMinutesCenterLatitude          TINYINT,
        dcSecondsCenterLatitude          DECIMAL(8, 6),
        bIsNegativeCenterLatitude        BIT,
        tiDegreesAbsoluteLeftLongitude   TINYINT,
        tiMinutesLeftLongitude           TINYINT,
        dcSecondsLeftLongitude           DECIMAL(8, 6),
        bIsNegativeLeftLongitude         BIT,
        tiDegreesAbsoluteRightLongitude  TINYINT,
        tiMinutesRightLongitude          TINYINT,
        dcSecondsRightLongitude          DECIMAL(8, 6),
        bIsNegativeRightLongitude        BIT,
        tiDegreesAbsoluteLowerLatitude   TINYINT,
        tiMinutesLowerLatitude           TINYINT,
        dcSecondsLowerLatitude           DECIMAL(8, 6),
        bIsNegativeLowerLatitude         BIT,
        tiDegreesAbsoluteUpperLatitude   TINYINT,
        tiMinutesUpperLatitude           TINYINT,
        dcSecondsUpperLatitude           DECIMAL(8, 6),
        bIsNegativeUpperLatitude         BIT
      )
  AS
    BEGIN
      --Allocate working variables
      DECLARE @dcCenterLongitude DECIMAL(15, 12) = NULL
      DECLARE @dcCenterLatitude  DECIMAL(15, 12) = NULL
      DECLARE @dcLeftLongitude   DECIMAL(15, 12) = NULL
      DECLARE @dcRightLongitude  DECIMAL(15, 12) = NULL
      DECLARE @dcLowerLatitude   DECIMAL(15, 12) = NULL
      DECLARE @dcUpperLatitude   DECIMAL(15, 12) = NULL

      --Execute the operation
      SELECT @dcCenterLongitude = tuple.dcCenterLongitude,
             @dcCenterLatitude  = tuple.dcCenterLatitude,
             @dcLeftLongitude   = tuple.dcLeftLongitude,
             @dcRightLongitude  = tuple.dcRightLongitude,
             @dcLowerLatitude   = tuple.dcLowerLatitude,
             @dcUpperLatitude   = tuple.dcUpperLatitude
        FROM qalGeohash_Main.expandBigintIntoLongLats(@_biGeohash) AS tuple

      --Return the results
      INSERT INTO @table_
        SELECT  tupleCenter.tiDegreesAbsoluteLongitude    AS tiDegreesAbsoluteCenterLongitude,
                tupleCenter.tiMinutesLongitude            AS tiMinutesCenterLongitude,
                tupleCenter.dcSecondsLongitude            AS dcSecondsCenterLongitude,
                tupleCenter.bIsNegativeLongitude         AS bIsNegativeCenterLongitude,
                tupleCenter.tiDegreesAbsoluteLatitude     AS tiDegreesAbsoluteCenterLatitude,
                tupleCenter.tiMinutesLatitude             AS tiMinutesCenterLatitude,
                tupleCenter.dcSecondsLatitude             AS dcSecondsCenterLatitude,
                tupleCenter.bIsNegativeLatitude          AS bIsNegativeCenterLatitude,
                tupleLeftLower.tiDegreesAbsoluteLongitude AS tiDegreesAbsoluteLeftLongitude,
                tupleLeftLower.tiMinutesLongitude         AS tiMinutesLeftLongitude,
                tupleLeftLower.dcSecondsLongitude         AS dcSecondsLeftLongitude,
                tupleLeftLower.bIsNegativeLongitude      AS bIsNegativeLeftLongitude,
                tupleRightUpper.tiDegreesAbsoluteLatitude AS tiDegreesAbsoluteRightLongitude,
                tupleRightUpper.tiMinutesLatitude         AS tiMinutesRightLongitude,
                tupleRightUpper.dcSecondsLatitude         AS dcSecondsRightLongitude,
                tupleRightUpper.bIsNegativeLatitude      AS bIsNegativeRightLongitude,
                tupleLeftLower.tiDegreesAbsoluteLongitude AS tiDegreesAbsoluteLowerLatitude,
                tupleLeftLower.tiMinutesLongitude         AS tiMinutesLowerLatitude,
                tupleLeftLower.dcSecondsLongitude         AS dcSecondsLowerLatitude,
                tupleLeftLower.bIsNegativeLongitude      AS bIsNegativeLowerLatitude,
                tupleRightUpper.tiDegreesAbsoluteLatitude AS tiDegreesAbsoluteUpperLatitude,
                tupleRightUpper.tiMinutesLatitude         AS tiMinutesUpperLatitude,
                tupleRightUpper.dcSecondsLatitude         AS dcSecondsUpperLatitude,
                tupleRightUpper.bIsNegativeLatitude      AS bIsNegativeUpperLatitude
          FROM qalGeohash_Dms.convertLongLatToDms(@dcCenterLongitude, @dcCenterLatitude) AS tupleCenter
         CROSS APPLY qalGeohash_Dms.convertLongLatToDms(@dcLeftLongitude, @dcLowerLatitude) AS tupleLeftLower
         CROSS APPLY qalGeohash_Dms.convertLongLatToDms(@dcRightLongitude, @dcUpperLatitude) AS tupleRightUpper
      RETURN
    END --qalGeohash_Dms.expandBigintIntoDmss
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[expandVarcharIntoDmsCheck] (
  @_vcGeohash VARCHAR(12)
) RETURNS
    @table_
      TABLE (
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
      --validate preconditions
      IF (qalGeohash_Preconditions.checkVarchar(@_vcGeohash) IS NOT NULL)
        RETURN
    
      --Return the results
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Dms.expandVarcharIntoDms(@_vcGeohash)
      RETURN
    END --qalGeohash_Dms.expandVarcharIntoDmsCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[expandVarcharIntoDms] (
  @_vcGeohash VARCHAR(12)
) RETURNS
    @table_
      TABLE (
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
      --Allocate working variables
      DECLARE @dcLongitude DECIMAL(15, 12) = NULL
      DECLARE @dcLatitude  DECIMAL(15, 12) = NULL

      --Execute the operation
      SELECT @dcLongitude = tuple.dcLongitude,
             @dcLatitude  = tuple.dcLatitude
        FROM qalGeohash_Main.expandVarcharIntoLongLat(@_vcGeohash) AS tuple

      --Return the results
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Dms.convertLongLatToDms(@dcLongitude, @dcLatitude)
      RETURN
    END --qalGeohash_Dms.expandVarcharIntoDms
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[expandVarcharIntoDmssCheck] (
  @_vcGeohash VARCHAR(12)
) RETURNS
    @table_
      TABLE (
        tiDegreesAbsoluteCenterLongitude TINYINT,
        tiMinutesCenterLongitude         TINYINT,
        dcSecondsCenterLongitude         DECIMAL(8, 6),
        bIsNegativeCenterLongitude       BIT,
        tiDegreesAbsoluteCenterLatitude  TINYINT,
        tiMinutesCenterLatitude          TINYINT,
        dcSecondsCenterLatitude          DECIMAL(8, 6),
        bIsNegativeCenterLatitude        BIT,
        tiDegreesAbsoluteLeftLongitude   TINYINT,
        tiMinutesLeftLongitude           TINYINT,
        dcSecondsLeftLongitude           DECIMAL(8, 6),
        bIsNegativeLeftLongitude         BIT,
        tiDegreesAbsoluteRightLongitude  TINYINT,
        tiMinutesRightLongitude          TINYINT,
        dcSecondsRightLongitude          DECIMAL(8, 6),
        bIsNegativeRightLongitude        BIT,
        tiDegreesAbsoluteLowerLatitude   TINYINT,
        tiMinutesLowerLatitude           TINYINT,
        dcSecondsLowerLatitude           DECIMAL(8, 6),
        bIsNegativeLowerLatitude         BIT,
        tiDegreesAbsoluteUpperLatitude   TINYINT,
        tiMinutesUpperLatitude           TINYINT,
        dcSecondsUpperLatitude           DECIMAL(8, 6),
        bIsNegativeUpperLatitude         BIT
      )
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkVarchar(@_vcGeohash) IS NOT NULL)
        RETURN
    
      --Return the results
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Dms.expandVarcharIntoDmss(@_vcGeohash)
      RETURN
    END --qalGeohash_Dms.expandVarcharIntoDmssCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[expandVarcharIntoDmss] (
  @_vcGeohash VARCHAR(12)
) RETURNS
    @table_
      TABLE (
        tiDegreesAbsoluteCenterLongitude TINYINT,
        tiMinutesCenterLongitude         TINYINT,
        dcSecondsCenterLongitude         DECIMAL(8, 6),
        bIsNegativeCenterLongitude       BIT,
        tiDegreesAbsoluteCenterLatitude  TINYINT,
        tiMinutesCenterLatitude          TINYINT,
        dcSecondsCenterLatitude          DECIMAL(8, 6),
        bIsNegativeCenterLatitude        BIT,
        tiDegreesAbsoluteLeftLongitude   TINYINT,
        tiMinutesLeftLongitude           TINYINT,
        dcSecondsLeftLongitude           DECIMAL(8, 6),
        bIsNegativeLeftLongitude         BIT,
        tiDegreesAbsoluteRightLongitude  TINYINT,
        tiMinutesRightLongitude          TINYINT,
        dcSecondsRightLongitude          DECIMAL(8, 6),
        bIsNegativeRightLongitude        BIT,
        tiDegreesAbsoluteLowerLatitude   TINYINT,
        tiMinutesLowerLatitude           TINYINT,
        dcSecondsLowerLatitude           DECIMAL(8, 6),
        bIsNegativeLowerLatitude         BIT,
        tiDegreesAbsoluteUpperLatitude   TINYINT,
        tiMinutesUpperLatitude           TINYINT,
        dcSecondsUpperLatitude           DECIMAL(8, 6),
        bIsNegativeUpperLatitude         BIT
      )
  AS
    BEGIN
      --Allocate working variables
      DECLARE @dcCenterLongitude DECIMAL(15, 12) = NULL
      DECLARE @dcCenterLatitude  DECIMAL(15, 12) = NULL
      DECLARE @dcLeftLongitude   DECIMAL(15, 12) = NULL
      DECLARE @dcRightLongitude  DECIMAL(15, 12) = NULL
      DECLARE @dcLowerLatitude   DECIMAL(15, 12) = NULL
      DECLARE @dcUpperLatitude   DECIMAL(15, 12) = NULL

      --Execute the operation
      SELECT @dcCenterLongitude = tuple.dcCenterLongitude,
             @dcCenterLatitude  = tuple.dcCenterLatitude,
             @dcLeftLongitude   = tuple.dcLeftLongitude,
             @dcRightLongitude  = tuple.dcRightLongitude,
             @dcLowerLatitude   = tuple.dcLowerLatitude,
             @dcUpperLatitude   = tuple.dcUpperLatitude
        FROM qalGeohash_Main.expandVarcharIntoLongLats(@_vcGeohash) AS tuple

      --Return the results
      INSERT INTO @table_
        SELECT  tupleCenter.tiDegreesAbsoluteLongitude    AS tiDegreesAbsoluteCenterLongitude,
                tupleCenter.tiMinutesLongitude            AS tiMinutesCenterLongitude,
                tupleCenter.dcSecondsLongitude            AS dcSecondsCenterLongitude,
                tupleCenter.bIsNegativeLongitude          AS bIsNegativeCenterLongitude,
                tupleCenter.tiDegreesAbsoluteLatitude     AS tiDegreesAbsoluteCenterLatitude,
                tupleCenter.tiMinutesLatitude             AS tiMinutesCenterLatitude,
                tupleCenter.dcSecondsLatitude             AS dcSecondsCenterLatitude,
                tupleCenter.bIsNegativeLatitude           AS bIsNegativeCenterLatitude,
                tupleLeftLower.tiDegreesAbsoluteLongitude AS tiDegreesAbsoluteLeftLongitude,
                tupleLeftLower.tiMinutesLongitude         AS tiMinutesLeftLongitude,
                tupleLeftLower.dcSecondsLongitude         AS dcSecondsLeftLongitude,
                tupleLeftLower.bIsNegativeLongitude       AS bIsNegativeLeftLongitude,
                tupleRightUpper.tiDegreesAbsoluteLatitude AS tiDegreesAbsoluteRightLongitude,
                tupleRightUpper.tiMinutesLatitude         AS tiMinutesRightLongitude,
                tupleRightUpper.dcSecondsLatitude         AS dcSecondsRightLongitude,
                tupleRightUpper.bIsNegativeLatitude       AS bIsNegativeRightLongitude,
                tupleLeftLower.tiDegreesAbsoluteLongitude AS tiDegreesAbsoluteLowerLatitude,
                tupleLeftLower.tiMinutesLongitude         AS tiMinutesLowerLatitude,
                tupleLeftLower.dcSecondsLongitude         AS dcSecondsLowerLatitude,
                tupleLeftLower.bIsNegativeLongitude       AS bIsNegativeLowerLatitude,
                tupleRightUpper.tiDegreesAbsoluteLatitude AS tiDegreesAbsoluteUpperLatitude,
                tupleRightUpper.tiMinutesLatitude         AS tiMinutesUpperLatitude,
                tupleRightUpper.dcSecondsLatitude         AS dcSecondsUpperLatitude,
                tupleRightUpper.bIsNegativeLatitude       AS bIsNegativeUpperLatitude
          FROM qalGeohash_Dms.convertLongLatToDms(@dcCenterLongitude, @dcCenterLatitude) AS tupleCenter
         CROSS APPLY qalGeohash_Dms.convertLongLatToDms(@dcLeftLongitude, @dcLowerLatitude) AS tupleLeftLower
         CROSS APPLY qalGeohash_Dms.convertLongLatToDms(@dcRightLongitude, @dcUpperLatitude) AS tupleRightUpper
      RETURN
    END --qalGeohash_Dms.expandVarcharIntoDmss
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[reduceDmsIntoBigintCheck] (
  @_tiDegreesAbsoluteLongitude TINYINT,       -- 0..180 inclusive
  @_tiMinutesLongitude         TINYINT,       -- 0..60  exclusive
  @_dcSecondsLongitude         DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegativeLongitude       BIT,           -- If directional, is either S or W?
  @_tiDegreesAbsoluteLatitude  TINYINT,       -- 0..90 inclusive
  @_tiMinutesLatitude          TINYINT,       -- 0..60  exclusive
  @_dcSecondsLatitude          DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegativeLatitude        BIT,           -- If directional, is either S or W?
  @_tiBitsWide                 TINYINT = 55   -- Largest value producing a square-like tile and still storable in a C# and Java
                                              --   type of Double
) RETURNS
    BIGINT
  AS
    BEGIN
      IF (
        (
          qalGeohash_Preconditions.checkDms(
            0, @_tiDegreesAbsoluteLongitude, @_tiMinutesLongitude, @_dcSecondsLongitude, @_bIsNegativeLongitude
          ) IS NOT NULL
        ) OR
        (
          qalGeohash_Preconditions.checkDms(
            1, @_tiDegreesAbsoluteLatitude, @_tiMinutesLatitude, @_dcSecondsLatitude, @_bIsNegativeLatitude
          ) IS NOT NULL
        ) OR
        (qalGeohash_Preconditions.checkBitsWide(@_tiBitsWide) IS NOT NULL)
      )
        RETURN NULL
      
      --Return the results
      RETURN
        qalGeohash_Dms.reduceDmsIntoBigint(
          @_tiDegreesAbsoluteLongitude,
          @_tiMinutesLongitude,
          @_dcSecondsLongitude,
          @_bIsNegativeLongitude,
          @_tiDegreesAbsoluteLatitude,
          @_tiMinutesLatitude,
          @_dcSecondsLatitude,
          @_bIsNegativeLatitude,
          @_tiBitsWide
        )
    END --qalGeohash_Dms.reduceDmsIntoBigintCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[reduceDmsIntoBigint] (
  @_tiDegreesAbsoluteLongitude TINYINT,       -- 0..180 inclusive
  @_tiMinutesLongitude         TINYINT,       -- 0..60  exclusive
  @_dcSecondsLongitude         DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegativeLongitude       BIT,           -- If directional, is either S or W?
  @_tiDegreesAbsoluteLatitude  TINYINT,       -- 0..90 inclusive
  @_tiMinutesLatitude          TINYINT,       -- 0..60  exclusive
  @_dcSecondsLatitude          DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegativeLatitude        BIT,           -- If directional, is either S or W?
  @_tiBitsWide                 TINYINT = 55   -- Largest value producing a square-like tile and still storable in a C# and Java
                                              --   type of Double
) RETURNS
    BIGINT
  AS
    BEGIN
      --Return the results
      RETURN
        qalGeohash_Main.reduceLongLatIntoBigint(
          qalGeohash_Dms.convertDmsToL_itude(
            @_tiDegreesAbsoluteLongitude, @_tiMinutesLongitude, @_dcSecondsLongitude, @_bIsNegativeLongitude
          ),
          qalGeohash_Dms.convertDmsToL_itude(
            @_tiDegreesAbsoluteLatitude, @_tiMinutesLatitude, @_dcSecondsLatitude, @_bIsNegativeLatitude
          ),
          @_tiBitsWide
        )
    END --qalGeohash_Dms.reduceDmsIntoBigint
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[reduceDmsIntoVarcharCheck] (
  @_tiDegreesAbsoluteLongitude TINYINT,       -- 0..180 inclusive
  @_tiMinutesLongitude         TINYINT,       -- 0..60  exclusive
  @_dcSecondsLongitude         DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegativeLongitude       BIT,           -- If directional, is either S or W?
  @_tiDegreesAbsoluteLatitude  TINYINT,       -- 0..90 inclusive
  @_tiMinutesLatitude          TINYINT,       -- 0..60  exclusive
  @_dcSecondsLatitude          DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegativeLatitude        BIT,           -- If directional, is either S or W?
  @_tiCharsWide                TINYINT = 11   -- Largest value producing a square-like tile and storable in a C# and Java type of
                                              --   Double
) RETURNS
    VARCHAR(12)
  AS
    BEGIN
      IF (
        (
          qalGeohash_Preconditions.checkDms(
            0, @_tiDegreesAbsoluteLongitude, @_tiMinutesLongitude, @_dcSecondsLongitude, @_bIsNegativeLongitude
          ) IS NOT NULL
        ) OR
        (
          qalGeohash_Preconditions.checkDms(
            1, @_tiDegreesAbsoluteLatitude, @_tiMinutesLatitude, @_dcSecondsLatitude, @_bIsNegativeLatitude
          ) IS NOT NULL
        ) OR
        (qalGeohash_Preconditions.checkCharsWide(@_tiCharsWide) IS NOT NULL)
      )
        RETURN NULL
      
      --Return the results
      RETURN
        qalGeohash_Dms.reduceDmsIntoVarchar(
          @_tiDegreesAbsoluteLongitude,
          @_tiMinutesLongitude,
          @_dcSecondsLongitude,
          @_bIsNegativeLongitude,
          @_tiDegreesAbsoluteLatitude,
          @_tiMinutesLatitude,
          @_dcSecondsLatitude,
          @_bIsNegativeLatitude,
          @_tiCharsWide
        )
    END --qalGeohash_Dms.reduceDmsIntoVarcharCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Dms].[reduceDmsIntoVarchar] (
  @_tiDegreesAbsoluteLongitude TINYINT,       -- 0..180 inclusive
  @_tiMinutesLongitude         TINYINT,       -- 0..60  exclusive
  @_dcSecondsLongitude         DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegativeLongitude       BIT,           -- If directional, is either S or W?
  @_tiDegreesAbsoluteLatitude  TINYINT,       -- 0..90 inclusive
  @_tiMinutesLatitude          TINYINT,       -- 0..60  exclusive
  @_dcSecondsLatitude          DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegativeLatitude        BIT,           -- If directional, is either S or W?
  @_tiCharsWide                TINYINT = 11   -- Largest value producing a square-like tile and storable in a C# and Java type of
                                              --   Double
) RETURNS
    VARCHAR(12)
  AS
    BEGIN
      --Return the results
      RETURN
        qalGeohash_Main.reduceLongLatIntoVarchar(
          qalGeohash_Dms.convertDmsToL_itude(
            @_tiDegreesAbsoluteLongitude, @_tiMinutesLongitude, @_dcSecondsLongitude, @_bIsNegativeLongitude
          ),
          qalGeohash_Dms.convertDmsToL_itude(
            @_tiDegreesAbsoluteLatitude, @_tiMinutesLatitude, @_dcSecondsLatitude, @_bIsNegativeLatitude
          ),
          @_tiCharsWide
        )
    END --qalGeohash_Dms.reduceDmsIntoVarchar
GO

-- The TSQL-plGeohash™ files are free software: you can redistribute it and/or modify it under the terms of the GNU Affero
-- General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option)
-- any later version.
-- 
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
-- of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
-- 
-- You should have received a copy of the [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.en.html)
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
-- 
-- To obtain a custom/different/commercial license for this, please send an email with your request to:
--   <mailto:jim.oflaherty.jr@qalocate.com>
