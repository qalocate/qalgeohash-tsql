-- /* ---------.---------.---------.---------.---------.---------.--------.---------.---------.---------.---------.--------- *\
-- ** Part Of:     QA Locate Geohash API                                                                                     **
-- ** URL:         http://www.qalocate.com                                                                                   **
-- ** File:                                                                                                                  **
-- **   Name:      qalGeohash_Auxiliary.sql                                                                                  **
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

CREATE SCHEMA qalGeohash_Auxiliary
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[convertNeighborOrientationEnumFromIdToNameCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[convertNeighborOrientationEnumFromIdToName]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[convertNeighborOrientationEnumFromNameToIdCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[convertNeighborOrientationEnumFromNameToId]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[neighborOfBigintCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[neighborOfBigint]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[neighborsOfBigintAsRowCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[neighborsOfBigintAsRow]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[neighborsOfBigintWithSelfAsRowCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[neighborsOfBigintWithSelfAsRow]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[neighborsOfBigintAsTableCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[neighborsOfBigintAsTable]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[parentOfBigintCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[parentOfBigint]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[parentsOfBigintCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[parentsOfBigint]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[parentOfVarcharCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[parentOfVarchar]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[parentsOfVarcharCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[parentsOfVarchar]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[changeBitsWideCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[changeBitsWide]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[changeCharsWideCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Auxiliary].[changeCharsWide]
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[convertNeighborOrientationEnumFromIdToNameCheck] (
  @_tiNeighborOrientationEnumId TINYINT -- All values greater than 8 return NULL
) RETURNS
    CHAR(2)
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumId(@_tiNeighborOrientationEnumId) IS NOT NULL)
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Auxiliary.convertNeighborOrientationEnumFromIdToName(@_tiNeighborOrientationEnumId)
    END --qalGeohash_Auxiliary.convertNeighborOrientationEnumFromIdToNameCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[convertNeighborOrientationEnumFromIdToName] (
  @_tiNeighborOrientationEnumId TINYINT -- All values greater than 8 return NULL
) RETURNS
    CHAR(2)
  AS
    BEGIN
      --Return the results
      RETURN
        CASE @_tiNeighborOrientationEnumId
          WHEN 0 THEN 'N'
          WHEN 1 THEN 'NE'
          WHEN 2 THEN 'E'
          WHEN 3 THEN 'SE'
          WHEN 4 THEN 'S'
          WHEN 5 THEN 'SW'
          WHEN 6 THEN 'W'
          WHEN 7 THEN 'NW'
          WHEN 8 THEN 'C'
          ELSE NULL
        END
    END --qalGeohash_Auxiliary.convertNeighborOrientationEnumFromIdToName
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[convertNeighborOrientationEnumFromNameToIdCheck] (
  @_chNeighborOrientationEnumName CHAR(2) -- All values other than ('N', 'NW', ..., 'C') return NULL
) RETURNS
    TINYINT
  AS
    BEGIN
      --validate preconditions
      IF (@_chNeighborOrientationEnumName IS NULL)
        RETURN NULL
        
      --Return the results
      RETURN qalGeohash_Auxiliary.convertNeighborOrientationEnumFromNameToId(@_chNeighborOrientationEnumName)
    END --qalGeohash_Auxiliary.convertNeighborOrientationEnumFromNameToIdCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[convertNeighborOrientationEnumFromNameToId] (
  @_chNeighborOrientationEnumName CHAR(2) -- All values other than ('N', 'NW', ..., 'C') return NULL
) RETURNS
    TINYINT
  AS
    BEGIN
      --Return the results
      RETURN
        CASE @_chNeighborOrientationEnumName
          WHEN 'N'  THEN 0
          WHEN 'NE' THEN 1
          WHEN 'E'  THEN 2
          WHEN 'SE' THEN 3
          WHEN 'S'  THEN 4
          WHEN 'SW' THEN 5
          WHEN 'W'  THEN 6
          WHEN 'NW' THEN 7
          WHEN 'C'  THEN 8
          ELSE NULL
        END
    END --qalGeohash_Auxiliary.convertNeighborOrientationEnumFromNameToId
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[neighborOfBigintCheck] (
  @_biGeohash                   BIGINT,
  @_tiNeighborOrientationEnumId TINYINT
) RETURNS
    BIGINT
  AS
    BEGIN
      --validate preconditions
      IF (
        (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL) OR
        (qalGeohash_Preconditions.checkNeighborOrientationEnumId(@_tiNeighborOrientationEnumId) IS NOT NULL)
      )
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, @_tiNeighborOrientationEnumId)
    END --qalGeohash_Auxiliary.neighborOfBigintCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[neighborOfBigint] (
  @_biGeohash                   BIGINT,
  @_tiNeighborOrientationEnumId TINYINT
) RETURNS
    BIGINT
  AS
    BEGIN
      DECLARE @biGeohash_ BIGINT = NULL
    
      IF (@_tiNeighborOrientationEnumId < 8)
        BEGIN
          --Allocate working variables
          DECLARE @dcLongitude DECIMAL(15, 12) = NULL
          DECLARE @dcLatitude  DECIMAL(15, 12) = NULL
          DECLARE @dcWidthLongitude  DECIMAL(15, 12) = NULL
          DECLARE @dcHeightLatitude  DECIMAL(15, 12) = NULL

          --Execute the operation
          SELECT @dcLongitude = tuple.dcCenterLongitude,
                 @dcLatitude  = tuple.dcCenterLatitude,
                 @dcWidthLongitude = (tuple.dcRightLongitude - tuple.dcLeftLongitude),
                 @dcHeightLatitude = (tuple.dcUpperLatitude - tuple.dcLowerLatitude)
            FROM qalGeohash_Main.expandBigintIntoLongLats(@_biGeohash) AS tuple
          IF (@_tiNeighborOrientationEnumId = 0)      --N
            SET @dcLatitude  = @dcLatitude + @dcHeightLatitude
          ELSE IF (@_tiNeighborOrientationEnumId = 1) --NE
            BEGIN
              SET @dcLongitude = @dcLongitude + @dcWidthLongitude
              SET @dcLatitude  = @dcLatitude + @dcHeightLatitude
            END
          ELSE IF (@_tiNeighborOrientationEnumId = 2) --E
            SET @dcLongitude = @dcLongitude + @dcWidthLongitude
          ELSE IF (@_tiNeighborOrientationEnumId = 3) --SE
            BEGIN
              SET @dcLongitude = @dcLongitude + @dcWidthLongitude
              SET @dcLatitude  = @dcLatitude - @dcHeightLatitude
            END
          ELSE IF (@_tiNeighborOrientationEnumId = 4) --S
            SET @dcLatitude  = @dcLatitude - @dcHeightLatitude
          ELSE IF (@_tiNeighborOrientationEnumId = 5) --SW
            BEGIN
              SET @dcLongitude = @dcLongitude - @dcWidthLongitude
              SET @dcLatitude  = @dcLatitude - @dcHeightLatitude
            END
          ELSE IF (@_tiNeighborOrientationEnumId = 6) --W
            SET @dcLongitude = @dcLongitude - @dcWidthLongitude
          ELSE IF (@_tiNeighborOrientationEnumId = 7) --NW
            BEGIN
              SET @dcLongitude = @dcLongitude - @dcWidthLongitude
              SET @dcLatitude  = @dcLatitude + @dcHeightLatitude
            END
          IF (@dcLatitude < -90.0) --against the bottom, undefined
            RETURN NULL
          IF (@dcLatitude > 90.0) --against the top, undefined
            RETURN NULL
          IF (@dcLongitude < -180.0)
            SET @dcLongitude =  180.0 + (@dcLongitude + 180.0) --against the left, wrap around
          ELSE IF (@dcLongitude > 180.0)
            SET @dcLongitude = -180.0 + (@dcLongitude - 180.0) --against the right, wrap around
          SET @biGeohash_ =
            qalGeohash_Main.reduceLongLatIntoBigint(@dcLongitude, @dcLatitude, qalGeohash_Main.extractBitsWide(@_biGeohash))
        END
      ELSE
        IF (@_tiNeighborOrientationEnumId = 8) -- C
          SET @biGeohash_ = @_biGeohash -- Identity function, return self
          
      --Return the results
      RETURN @biGeohash_
    END --qalGeohash_Auxiliary.neighborOfBigint
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[neighborsOfBigintAsRowCheck] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE(
        biNorth     BIGINT,
        biNorthEast BIGINT,
        biEast      BIGINT,
        biSouthEast BIGINT,
        biSouth     BIGINT,
        biSouthWest BIGINT,
        biWest      BIGINT,
        biNorthWest BIGINT
      )
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN
        
      --Return the results
      INSERT INTO @table_
        SELECT * FROM qalGeohash_Auxiliary.neighborsOfBigintAsRow(@_biGeohash)
      RETURN
    END --qalGeohash_Auxiliary.neighborsOfBigintAsRowCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[neighborsOfBigintAsRow] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE(
        biNorth     BIGINT,
        biNorthEast BIGINT,
        biEast      BIGINT,
        biSouthEast BIGINT,
        biSouth     BIGINT,
        biSouthWest BIGINT,
        biWest      BIGINT,
        biNorthWest BIGINT
      )
  AS
    BEGIN
      --Allocate working variables
      --Execute the operation
      DECLARE @biNorth     BIGINT = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 0)
      DECLARE @biNorthEast BIGINT = NULL
      DECLARE @biEast      BIGINT = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 2)
      DECLARE @biSouthEast BIGINT = NULL
      DECLARE @biSouth     BIGINT = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 4)
      DECLARE @biSouthWest BIGINT = NULL
      DECLARE @biWest      BIGINT = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 6)
      DECLARE @biNorthWest BIGINT = NULL
      IF (@biNorth IS NOT NULL)
        BEGIN
          SET @biNorthEast = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 1)
          SET @biNorthWest = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 7)
        END
      IF (@biSouth IS NOT NULL)
        BEGIN
          SET @biSouthEast = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 3)
          SET @biSouthWest = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 5)
        END

      --Return the results
      INSERT INTO @table_
        VALUES (
          @biNorth,
          @biNorthEast,
          @biEast,
          @biSouthEast,
          @biSouth,
          @biSouthWest,
          @biWest,
          @biNorthWest
        )
      RETURN
    END --qalGeohash_Auxiliary.neighborsOfBigintAsRow
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[neighborsOfBigintWithSelfAsRowCheck] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE(
        biCenter    BIGINT,
        biNorth     BIGINT,
        biNorthEast BIGINT,
        biEast      BIGINT,
        biSouthEast BIGINT,
        biSouth     BIGINT,
        biSouthWest BIGINT,
        biWest      BIGINT,
        biNorthWest BIGINT
      )
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN
        
      --Return the results
      INSERT INTO @table_
        SELECT * FROM qalGeohash_Auxiliary.neighborsOfBigintWithSelfAsRow(@_biGeohash)
      RETURN
    END --qalGeohash_Auxiliary.neighborsOfBigintWithSelfAsRowCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[neighborsOfBigintWithSelfAsRow] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE(
        biCenter    BIGINT,
        biNorth     BIGINT,
        biNorthEast BIGINT,
        biEast      BIGINT,
        biSouthEast BIGINT,
        biSouth     BIGINT,
        biSouthWest BIGINT,
        biWest      BIGINT,
        biNorthWest BIGINT
      )
  AS
    BEGIN
      --Allocate working variables
      --Execute the operation
      DECLARE @biNorth     BIGINT = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 0)
      DECLARE @biNorthEast BIGINT = NULL
      DECLARE @biEast      BIGINT = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 2)
      DECLARE @biSouthEast BIGINT = NULL
      DECLARE @biSouth     BIGINT = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 4)
      DECLARE @biSouthWest BIGINT = NULL
      DECLARE @biWest      BIGINT = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 6)
      DECLARE @biNorthWest BIGINT = NULL
      IF (@biNorth IS NOT NULL)
        BEGIN
          SET @biNorthEast = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 1)
          SET @biNorthWest = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 7)
        END
      IF (@biSouth IS NOT NULL)
        BEGIN
          SET @biSouthEast = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 3)
          SET @biSouthWest = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 5)
        END

      --Return the results
      INSERT INTO @table_
        VALUES (
          @_biGeohash,
          @biNorth,
          @biNorthEast,
          @biEast,
          @biSouthEast,
          @biSouth,
          @biSouthWest,
          @biWest,
          @biNorthWest
        )
      RETURN
    END --qalGeohash_Auxiliary.neighborsOfBigintWithSelfAsRow
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[neighborsOfBigintAsTableCheck] (
  @_biGeohash       BIGINT,
  @_bIsSelfIncluded BIT = 0
) RETURNS
    @table_
      TABLE(
        tiNeighborOrientationEnumId TINYINT,
        biGeohash                   BIGINT
      )
  AS
    BEGIN
      --validate preconditions
      IF (
        (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL) OR
        (@_bIsSelfIncluded IS NULL)
      )
        RETURN
        
      --Return the results
      INSERT INTO @table_
        SELECT * FROM qalGeohash_Auxiliary.neighborsOfBigintAsTable(@_biGeohash, @_bIsSelfIncluded)
      RETURN
    END --qalGeohash_Auxiliary.neighborsOfBigintAsTableCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[neighborsOfBigintAsTable] (
  @_biGeohash       BIGINT,
  @_bIsSelfIncluded BIT = 0
) RETURNS
    @table_
      TABLE(
        tiNeighborOrientationEnumId TINYINT,
        biGeohash                   BIGINT
      )
  AS
    BEGIN
      --Execute the operation
      IF (@_bIsSelfIncluded = 1)
        INSERT INTO @table_
          VALUES (8, @_biGeohash)                                               --C
      INSERT INTO @table_
        VALUES (2, qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 2))       --E
      INSERT INTO @table_
        VALUES (6, qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 6))       --W
      DECLARE @n BIGINT = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 0)
      IF (@n IS NOT NULL)
        BEGIN
          INSERT INTO @table_
            VALUES (1, qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 1))   --NE
          INSERT INTO @table_
            VALUES (0, @n)                                                      --N
          INSERT INTO @table_
            VALUES (7, qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 7))   --NW
        END
      DECLARE @s BIGINT = qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 4)
      IF (@s IS NOT NULL)
        BEGIN
          INSERT INTO @table_
            VALUES (3, qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 3))   --SE
          INSERT INTO @table_
            VALUES (4, @s)                                                      --S
          INSERT INTO @table_
            VALUES (5, qalGeohash_Auxiliary.neighborOfBigint(@_biGeohash, 5))   --SW
        END
      
      --Return the results
      RETURN
    END --qalGeohash_Auxiliary.neighborsOfBigintAsTable
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[parentOfBigintCheck] (
  @_biGeohash BIGINT
) RETURNS
    BIGINT
  AS
    BEGIN
      --validate preconditions
      IF (
        (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL) OR
        (qalGeohash_Main.extractBitsWide(@_biGeohash) = 5)
      )
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Auxiliary.parentOfBigint(@_biGeohash)
    END --qalGeohash_Auxiliary.parentOfBigintCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[parentOfBigint] (
  @_biGeohash BIGINT
) RETURNS
    BIGINT
  AS
    BEGIN
      --Allocate working variables
      DECLARE @tiBitsWide TINYINT = qalGeohash_Main.extractBitsWide(@_biGeohash)
      IF (@tiBitsWide = 5)
        RETURN NULL
      
      --Return the results
      RETURN qalGeohash_Main.encodeBigint(qalGeohash_Main.extractSans(@_biGeohash) / 32, @tiBitsWide - 5)
    END --qalGeohash_Auxiliary.parentOfBigint
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[parentsOfBigintCheck] (
  @_biGeohash       BIGINT,
  @_tiBitsWideMin   TINYINT = 5,
  @_bIsSelfIncluded BIT     = 0
) RETURNS
    @table_
      TABLE(
        biGeohash BIGINT
      )
  AS
    BEGIN
      --validate preconditions
      IF ( 
        (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL) OR
        (qalGeohash_Preconditions.checkBitsWide(@_tiBitsWideMin) IS NOT NULL) OR
        (@_bIsSelfIncluded IS NULL) OR
        (qalGeohash_Main.extractBitsWide(@_biGeohash) < @_tiBitsWideMin)
      )   
        RETURN

      --Return the results
      INSERT INTO @table_
        SELECT * FROM qalGeohash_Auxiliary.parentsOfBigint(@_biGeohash, @_tiBitsWideMin, @_bIsSelfIncluded)
      RETURN
    END --qalGeohash_Auxiliary.parentsOfBigintCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[parentsOfBigint] (
  @_biGeohash       BIGINT,
  @_tiBitsWideMin   TINYINT = 5,
  @_bIsSelfIncluded BIT     = 0
) RETURNS
    @table_
      TABLE(
        biGeohash BIGINT
      )
  AS
    BEGIN
      DECLARE @tiCharsWide TINYINT = qalGeohash_Main.extractCharsWide(@_biGeohash)
      IF (@tiCharsWide = 1)
        RETURN

      --Allocate working variables
      DECLARE @tiCharsWideIndex TINYINT = @tiCharsWide - 1
      DECLARE @tiCharsWideMin   TINYINT = @_tiBitsWideMin / 5
      DECLARE @biGeohashParent  BIGINT  = @_biGeohash

      --Execute the operation
      IF (@_bIsSelfIncluded = 1)
        INSERT INTO @table_
          VALUES (@biGeohashParent)

      WHILE (@tiCharsWideIndex >= @tiCharsWideMin)
        BEGIN
          SET @biGeohashParent = qalGeohash_Auxiliary.parentOfBigint(@biGeohashParent)
          INSERT INTO @table_
            VALUES (@biGeohashParent)
          SET @tiCharsWideIndex = @tiCharsWideIndex - 1
        END

      --Return the results
      RETURN
    END --qalGeohash_Auxiliary.parentsOfBigint
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[parentOfVarcharCheck] (
  @_vcGeohash VARCHAR(12)
) RETURNS
    VARCHAR(12)
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkVarchar(@_vcGeohash) IS NOT NULL)
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Auxiliary.parentOfVarchar(@_vcGeohash)
    END --qalGeohash_Auxiliary.parentOfVarcharCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[parentOfVarchar] (
  @_vcGeohash VARCHAR(12)
) RETURNS
    VARCHAR(12)
  AS
    BEGIN
      --Allocate working variables
      DECLARE @tiCharsWide TINYINT = LEN(@_vcGeohash)

      IF (@tiCharsWide = 1)
        RETURN NULL --already at or below smallest size of 1 char or 5 bits wide
      
      --Return the results
      RETURN SUBSTRING(@_vcGeohash, 1, @tiCharsWide - 1)
    END --qalGeohash_Auxiliary.parentOfVarchar
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[parentsOfVarcharCheck] (
  @_vcGeohash       VARCHAR(12),
  @_tiCharsWideMin  TINYINT = 1,
  @_bIsSelfIncluded BIT     = 0
) RETURNS
    @table_
      TABLE(
        vcGeohash BIGINT
      )
  AS
    BEGIN
      --validate preconditions
      IF (
        (qalGeohash_Preconditions.checkVarchar(@_vcGeohash) IS NOT NULL) OR
        (qalGeohash_Preconditions.checkCharsWide(@_tiCharsWideMin) IS NOT NULL) OR
        (@_bIsSelfIncluded IS NULL) OR
        (LEN(@_vcGeohash) < @_tiCharsWideMin)
      )
        RETURN

      --Return the results
      INSERT INTO @table_
        SELECT * FROM qalGeohash_Auxiliary.parentsOfVarchar(@_vcGeohash, @_tiCharsWideMin, @_bIsSelfIncluded)
      RETURN
    END --qalGeohash_Auxiliary.parentsOfVarcharCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[parentsOfVarchar] (
  @_vcGeohash       VARCHAR(12),
  @_tiCharsWideMin  TINYINT = 1,
  @_bIsSelfIncluded BIT     = 0
) RETURNS
    @table_
      TABLE(
        vcGeohash BIGINT
      )
  AS
    BEGIN
      --Allocate working variables
      DECLARE @tiCharsWideIndex TINYINT = LEN(@_vcGeohash) - 1
      IF (@tiCharsWideIndex = 0)
        RETURN
      DECLARE @vcGeohashParent  BIGINT  = @_vcGeohash

      --Execute the operation
      IF (@_bIsSelfIncluded = 1)
        INSERT INTO @table_
          VALUES (@vcGeohashParent)

      WHILE (@tiCharsWideIndex >= @_tiCharsWideMin)
        BEGIN
          SET @vcGeohashParent = qalGeohash_Auxiliary.parentOfVarchar(@vcGeohashParent)
          INSERT INTO @table_
            VALUES (@vcGeohashParent)
          SET @tiCharsWideIndex = @tiCharsWideIndex - 1
        END

      --Return the results
      RETURN
    END --qalGeohash_Auxiliary.parentsOfVarchar
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[changeBitsWideCheck] (
  @_biGeohash     BIGINT,
  @_tiBitsWideNew TINYINT
) RETURNS
    BIGINT
  AS
    BEGIN
      --validate preconditions
      IF ( 
        (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL) OR
        (qalGeohash_Preconditions.checkBitsWide(@_tiBitsWideNew) IS NOT NULL)
      )   
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Auxiliary.changeBitsWide(@_biGeohash, @_tiBitsWideNew)
    END --qalGeohash_Auxiliary.changeBitsWideCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[changeBitsWide] (
  @_biGeohash     BIGINT,
  @_tiBitsWideNew TINYINT
) RETURNS
    BIGINT
  AS
    BEGIN
      --Allocate working variables
      DECLARE @tiBitsWide TINYINT = qalGeohash_Main.extractBitsWide(@_biGeohash)
      IF (@_tiBitsWideNew = @tiBitsWide)
        RETURN @_biGeohash
      DECLARE @biGeohashSans BIGINT = qalGeohash_Main.extractSans(@_biGeohash)

      --Execute the operation
      IF (@_tiBitsWideNew < @tiBitsWide)
          --must pull off bits
          SET @biGeohashSans = @biGeohashSans / POWER(CAST(2 AS BIGINT), @tiBitsWide - @_tiBitsWideNew)
      ELSE
        BEGIN
          --must add in bits
          DECLARE @multiple BIGINT = POWER(CAST(2 AS BIGINT), @_tiBitsWideNew - @tiBitsWide)
          SET @biGeohashSans = (@biGeohashSans * @multiple) + (CAST(24 AS BIGINT) * (@multiple / 32)) --Shift left appending with "s000..."
        END
        
      --Return the results
      RETURN qalGeohash_Main.encodeBigint(@biGeohashSans, @_tiBitsWideNew)
    END --qalGeohash_Auxiliary.changeBitsWide
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[changeCharsWideCheck] (
  @_vcGeohash      VARCHAR(12),
  @_tiCharsWideNew TINYINT
) RETURNS
    VARCHAR(12)
  AS
    BEGIN
      --validate preconditions
      IF ( 
        (qalGeohash_Preconditions.checkVarchar(@_vcGeohash) IS NOT NULL) OR
        (qalGeohash_Preconditions.checkCharsWide(@_tiCharsWideNew) IS NOT NULL)
      )   
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Auxiliary.changeCharsWide(@_vcGeohash, @_tiCharsWideNew)
    END --qalGeohash_Auxiliary.changeCharsWideCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Auxiliary].[changeCharsWide] (
  @_vcGeohash      VARCHAR(12),
  @_tiCharsWideNew TINYINT
) RETURNS
    VARCHAR(12)
  AS
    BEGIN
      --Return the results
      DECLARE @tiCharsWide TINYINT = LEN(@_vcGeohash)
      IF (@_tiCharsWideNew = @tiCharsWide)
        RETURN @_vcGeohash

      --Execute the operation
      IF (@_tiCharsWideNew < @tiCharsWide)
          --must pull off chars
        RETURN LEFT(@_vcGeohash, @_tiCharsWideNew)

      --Return the results
      RETURN LEFT(@_vcGeohash + 's0000000000', @_tiCharsWideNew)
    END --qalGeohash_Auxiliary.changeCharsWide
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
