-- /* ---------.---------.---------.---------.---------.---------.--------.---------.---------.---------.---------.--------- *\
-- ** Part Of:     QA Locate Geohash API                                                                                     **
-- ** URL:         http://www.qalocate.com                                                                                   **
-- ** File:                                                                                                                  **
-- **   Name:      qalGeohash_Preconditions.sql                                                                              **
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

CREATE SCHEMA qalGeohash_Preconditions
GO

DROP FUNCTION IF EXISTS [qalGeohash_Preconditions].[checkBigint]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Preconditions].[checkSans]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Preconditions].[checkBitsWide]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Preconditions].[checkCharsWide]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Preconditions].[checkL_itude]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Preconditions].[checkVarchar]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Preconditions].[checkDms]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Preconditions].[checkDmsDirectional]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Preconditions].[checkNeighborOrientationEnumId]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Preconditions].[checkNeighborOrientationEnumName]
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Preconditions].[checkBigint] (
  @_biGeohash BIGINT
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @vcFailedPreconditions_ VARCHAR(MAX) = ''

      --Allocate working variables
      --Execute the operation
      IF (@_biGeohash IS NULL)
        SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_biGeohash must not be NULL'
      ELSE
        BEGIN
          DECLARE @biGeohashSans BIGINT  = qalGeohash_Main.extractSans(@_biGeohash)
          DECLARE @tiBitsWide    TINYINT = qalGeohash_Main.extractBitsWide(@_biGeohash)
          DECLARE @vcErrorsBitsWide VARCHAR(MAX) = qalGeohash_Preconditions.checkBitsWide(@tiBitsWide)
          IF (@vcErrorsBitsWide IS NOT NULL)
            SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + 'checkBitsWide Failed: ' + @vcErrorsBitsWide
          ELSE
            BEGIN
              DECLARE @vcErrorsSans VARCHAR(MAX) = qalGeohash_Preconditions.checkSans(@biGeohashSans)
              IF (@vcErrorsSans IS NOT NULL)
                --Should never be able to reach here if qalGeohash_Main.extractSans is properly implemented
                SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + 'checkSans Failed: ' + @vcErrorsSans
              ELSE
                BEGIN
                  DECLARE @biMaximum     BIGINT  = POWER(CAST(2 AS BIGINT), @tiBitsWide)
                  IF (@biGeohashSans >= @biMaximum)
                    --Largest valid value is ((2^60) - 1) [1,152,921,504,606,846,976] (maximum VARCHAR length of 25) which is
                    --  when @tiBitsWide is equal to 60
                    SET @vcFailedPreconditions_ =
                      @vcFailedPreconditions_ + '|' + 'After removing @tiBitsWide [' + CAST(@tiBitsWide AS VARCHAR(40)) +
                      '], @biGeohashSans [' + CAST(@biGeohashSans AS VARCHAR(40)) + '] must be less than the maximum ['
                      + CAST(@biMaximum AS VARCHAR(40)) + ']'
                END
            END
        END

      --Return the results
      IF (@vcFailedPreconditions_ = '')
        RETURN NULL
      RETURN @vcFailedPreconditions_
    END --qalGeohash_Preconditions.checkBigint
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Preconditions].[checkSans] (
  @_biGeohashSans BIGINT
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @vcFailedPreconditions_ VARCHAR(MAX) = ''

      --Allocate working variables
      --Execute the operation
      IF (@_biGeohashSans IS NULL)
        SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_biGeohashSans must not be NULL'
      ELSE
        IF (@_biGeohashSans < 0)
          SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_biGeohashSans [' + CAST(@_biGeohashSans AS VARCHAR(40)) + '] must not be less than 0'
        ELSE
          IF (NOT (@_biGeohashSans < 1152921504606846976)) --2^60th
            SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_biGeohashSans [' + CAST(@_biGeohashSans AS VARCHAR(40)) + '] must be less than 2^60 [1152921504606846976]'

      --Return the results
      IF (@vcFailedPreconditions_ = '')
        RETURN NULL
      RETURN @vcFailedPreconditions_
    END --qalGeohash_Preconditions.checkSans
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Preconditions].[checkBitsWide] (
  @_tiBitsWide TINYINT = 55    -- Largest value producing a square-like tile and still storable in a C# and Java type of Double
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @vcFailedPreconditions_ VARCHAR(MAX) = ''

      IF (@_tiBitsWide IS NULL)
        SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_tiBitsWide must not be NULL'
      ELSE
        BEGIN
          IF (@_tiBitsWide = 0)
            SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_tiBitsWide must not be 0'
          IF (@_tiBitsWide > 60)
            SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_tiBitsWide must not be greater than 60'
          IF (@_tiBitsWide % 5 <> 0)
            SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_tiBitsWide must be a multiple of 5'
        END

      --Return the results
      IF (@vcFailedPreconditions_ = '')
        RETURN NULL
      RETURN @vcFailedPreconditions_
    END --qalGeohash_Preconditions.checkBitsWide
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Preconditions].[checkCharsWide] (
  @_tiCharsWide TINYINT = 11    -- Largest value producing a square-like tile and still storable in a C# and Java type of Double
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @vcFailedPreconditions_ VARCHAR(MAX) = ''

      IF (@_tiCharsWide IS NULL)
        SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_tiCharsWide must not be NULL'
      ELSE
        BEGIN
          IF (@_tiCharsWide = 0)
            SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_tiCharsWide must not be 0'
          IF (@_tiCharsWide > 12)
            SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_tiCharsWide must not be greater than 12'
        END

      --Return the results
      IF (@vcFailedPreconditions_ = '')
        RETURN NULL
      RETURN @vcFailedPreconditions_
    END --qalGeohash_Preconditions.checkCharsWide
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Preconditions].[checkL_itude] (
  @_bIsLatitude BIT,
  @_dcL_itude   DECIMAL(15, 12) -- under 0.1mm
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @vcFailedPreconditions_ VARCHAR(MAX) = ''

      --Execute the operation
      IF (@_bIsLatitude IS NULL)
        SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_bIsLatitude must not be NULL'
      IF (@vcFailedPreconditions_ = '')
        BEGIN
          DECLARE @vcName VARCHAR(MAX) = CASE WHEN @_bIsLatitude = 0 THEN 'Longitude' ELSE 'Latitude' END
          IF (@_dcL_itude IS NULL)
            SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_dcL_itude (for ' + @vcName+ ') must not be NULL'
          ELSE
            BEGIN
              DECLARE @dcDegreesAbsoluteMax DECIMAL(15, 12) = CASE WHEN @_bIsLatitude = 0 THEN 180.0 ELSE 90.0 END
              IF (@_dcL_itude < -@dcDegreesAbsoluteMax)
                SET @vcFailedPreconditions_ =
                  @vcFailedPreconditions_ + '|' + '_dcL_itude (for ' + @vcName+ ') must not be less than ' +
                  CAST(-@dcDegreesAbsoluteMax AS VARCHAR(40))
              ELSE
                IF (@_dcL_itude > @dcDegreesAbsoluteMax)
                  SET @vcFailedPreconditions_ =
                    @vcFailedPreconditions_ + '|' + '_dcL_itude (for ' + @vcName+ ') must not be greater than ' +
                    CAST(@dcDegreesAbsoluteMax AS VARCHAR(40))
            END
        END

      --Return the results
      IF (@vcFailedPreconditions_ = '')
        RETURN NULL
      RETURN @vcFailedPreconditions_
    END --qalGeohash_Preconditions.checkL_itude
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Preconditions].[checkVarchar] (
  @_vcGeohash VARCHAR(12)
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @vcFailedPreconditions_ VARCHAR(MAX) = ''

      --Execute the operation
      IF (@_vcGeohash IS NULL)
        SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_vcGeohash must not be NULL'
      ELSE
        IF (@_vcGeohash = '')
          SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_vcGeohash must not be empty'
        ELSE
          BEGIN
            DECLARE @vcGeohashWidth      TINYINT      = LEN(@_vcGeohash)
            DECLARE @vcGeohashIndex      TINYINT      = 0
            DECLARE @chCurrent           CHAR         = NULL
            DECLARE @vcInvalidCharacters VARCHAR(MAX) = ''
            WHILE (@vcGeohashIndex < @vcGeohashWidth)
              BEGIN
                SET @chCurrent = SUBSTRING(@_vcGeohash, @vcGeohashIndex + 1, 1)
                IF (CHARINDEX(LOWER(@chCurrent), '0123456789bcdefghjkmnpqrstuvwxyz') = 0)
                  SET @vcInvalidCharacters = @vcInvalidCharacters + ',' + @chCurrent
                SET @vcGeohashIndex = @vcGeohashIndex + 1
              END
            IF (@vcInvalidCharacters <> '')
              SET @vcFailedPreconditions_ =
                @vcFailedPreconditions_ + '|' + '_vcGeohash must not contain invalid character(s) [' +
                SUBSTRING(@vcInvalidCharacters, 2, LEN(@vcInvalidCharacters) - 1) + ']'
          END

      --Return the results
      IF (@vcFailedPreconditions_ = '')
        RETURN NULL
      RETURN @vcFailedPreconditions_
    END --qalGeohash_Preconditions.checkVarchar
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Preconditions].[checkDms] (
  @_bIsLatitude       BIT,
  @_tiDegreesAbsolute TINYINT,       -- 0..180    inclusive
  @_tiMinutes         TINYINT,       -- 0..60     exclusive
  @_dcSeconds         DECIMAL(8, 6), -- 0.0..60.0 exclusive
  @_bIsNegative       BIT            -- If directional, is either S or W?
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @vcFailedPreconditions_ VARCHAR(MAX) = ''

      --Execute the operation
      IF (@_bIsLatitude IS NULL)
        SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_bIsLatitude must not be NULL'
      IF (@vcFailedPreconditions_ = '')
        BEGIN
          DECLARE @vcName VARCHAR(MAX) = CASE WHEN @_bIsLatitude = 0 THEN 'Longitude' ELSE 'Latitude' END
          DECLARE @tiDegreesAbsoluteMax TINYINT = CASE WHEN @_bIsLatitude = 0 THEN 180 ELSE 90 END
          IF (@_tiDegreesAbsolute IS NULL)
            SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_tiDegreesAbsolute must not be NULL'
          ELSE
            IF (@_tiDegreesAbsolute > @tiDegreesAbsoluteMax)
              SET @vcFailedPreconditions_ =
                @vcFailedPreconditions_ + '|' + '_tiDegreesAbsolute [' + CAST(@_tiDegreesAbsolute AS VARCHAR(MAX)) + '] (for ' +
                @vcName+ ') must be less than or equal to ' + CAST(@tiDegreesAbsoluteMax AS VARCHAR(40))
          IF (@_tiMinutes IS NULL)
            SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_tiMinutes must not be NULL'
          ELSE
            IF (NOT (@_tiMinutes < 60))
              SET @vcFailedPreconditions_ =
                @vcFailedPreconditions_ + '|' + '_tiMinutes [' + CAST(@_tiDegreesAbsolute AS VARCHAR(MAX)) + '] (for ' +
                @vcName + ') must be less than 60'
          IF (@_dcSeconds IS NULL)
            SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_dcSeconds must not be NULL'
          ELSE
            IF (@_dcSeconds < 0.0)
              SET @vcFailedPreconditions_ =
                @vcFailedPreconditions_ + '|' + '_dcSeconds [' + CAST(@_dcSeconds AS VARCHAR(MAX)) + '] (for ' + @vcName +
                ') must be greater than or equal to 0.0'
            ELSE
              IF (NOT (@_dcSeconds < 60.0))
                SET @vcFailedPreconditions_ =
                  @vcFailedPreconditions_ + '|' + '_dcSeconds [' + CAST(@_dcSeconds AS VARCHAR(MAX)) + '] (for ' + @vcName +
                  ') must be less than 60.0'
          IF (@_bIsNegative IS NULL)
            SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_bIsNegative must not be NULL'
        END

      --Return the results
      IF (@vcFailedPreconditions_ = '')
        RETURN NULL
      RETURN @vcFailedPreconditions_
    END --qalGeohash_Preconditions.checkDms
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Preconditions].[checkDmsDirectional] (
  @_chDirectional CHAR
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @vcFailedPreconditions_ VARCHAR(MAX) = ''

      IF (@_chDirectional IS NULL)
        SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_chDirectional must not be NULL'
      ELSE
        IF (CHARINDEX(UPPER(@_chDirectional), 'NSEW') = 0)
          SET @vcFailedPreconditions_ =
            @vcFailedPreconditions_ + '|' + 'UPPER(_chDirectional) [' + UPPER(@_chDirectional) +
            '] must be exactly one of (N, S, E, or W)'

      --Return the results
      IF (@vcFailedPreconditions_ = '')
        RETURN NULL
      RETURN @vcFailedPreconditions_
    END --qalGeohash_Preconditions.checkDmsDirectional
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Preconditions].[checkNeighborOrientationEnumId] (
  @_tiNeighborOrientationEnumId TINYINT
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @vcFailedPreconditions_ VARCHAR(MAX) = ''

      IF (@_tiNeighborOrientationEnumId IS NULL)
        SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_tiNeighborOrientationEnumId must not be NULL'
      ELSE
        IF (@_tiNeighborOrientationEnumId > 8)
          SET @vcFailedPreconditions_ =
            @vcFailedPreconditions_ + '|' + '_tiNeighborOrientationEnumId [' +
            CAST(@_tiNeighborOrientationEnumId AS VARCHAR(MAX)) + '] must be less than or equal to 8'

      --Return the results
      IF (@vcFailedPreconditions_ = '')
        RETURN NULL
      RETURN @vcFailedPreconditions_
    END --qalGeohash_Preconditions.checkNeighborOrientationEnumId
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Preconditions].[checkNeighborOrientationEnumName] (
  @_chNeighborOrientationEnumName CHAR(2)
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @vcFailedPreconditions_ VARCHAR(MAX) = ''

      IF (@_chNeighborOrientationEnumName IS NULL)
        SET @vcFailedPreconditions_ = @vcFailedPreconditions_ + '|' + '_chNeighborOrientationEnumName must not be NULL'
      ELSE
        IF (
          CASE UPPER(@_chNeighborOrientationEnumName)
            WHEN 'N'  THEN 1
            WHEN 'NE' THEN 1
            WHEN 'E'  THEN 1
            WHEN 'SE' THEN 1
            WHEN 'S'  THEN 1
            WHEN 'SW' THEN 1
            WHEN 'W'  THEN 1
            WHEN 'NW' THEN 1
            WHEN 'C'  THEN 1
            ELSE 0
          END = 0
        )
          SET @vcFailedPreconditions_ =
            @vcFailedPreconditions_ + '|' + 'UPPER(_chNeighborOrientationEnumName) [' + UPPER(@_chNeighborOrientationEnumName) +
            '] must be exactly one of (N, NE, E, SE, S, SW, W, NW, C)'

      --Return the results
      IF (@vcFailedPreconditions_ = '')
        RETURN NULL
      RETURN @vcFailedPreconditions_
    END --qalGeohash_Preconditions.checkNeighborOrientationEnumName
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
