-- /* ---------.---------.---------.---------.---------.---------.--------.---------.---------.---------.---------.--------- *\
-- ** Part Of:     QA Locate Geohash API                                                                                     **
-- ** URL:         http://www.qalocate.com                                                                                   **
-- ** File:                                                                                                                  **
-- **   Name:      qalGeohash_Main.sql                                                                                       **
-- **   Version:   v2021.02.04                                                                                               **
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
--CREATE SCHEMA qalGeohash_Main
--GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[extractCharsWideCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[extractCharsWide]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[extractBitsWideCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[extractBitsWide]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[extractSansCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[extractSans]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[encodeBigintCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[encodeBigint]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[decodeBigintCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[decodeBigint]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[convertBigintToVarcharCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[convertBigintToVarchar]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[convertVarcharToBigintCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[convertVarcharToBigint]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[expandBigintIntoLongCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[expandBigintIntoLong]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[expandBigintIntoLatCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[expandBigintIntoLat]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[expandBigintIntoLongLatCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[expandBigintIntoLongLat]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[expandBigintIntoLongLatsCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[expandBigintIntoLongLats]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[expandVarcharIntoLongLatCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[expandVarcharIntoLongLat]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[expandVarcharIntoLongLatsCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[expandVarcharIntoLongLats]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[reduceLongLatIntoBigintCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[reduceLongLatIntoBigint]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[reduceLongLatIntoVarcharCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Main].[reduceLongLatIntoVarchar]
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[extractCharsWideCheck] (
  @_biGeohash BIGINT
) RETURNS
    TINYINT
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Main.extractCharsWide(@_biGeohash)
    END --qalGeohash_Main.extractCharsWideCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[extractCharsWide] (
  @_biGeohash BIGINT
) RETURNS
    TINYINT
  AS
    BEGIN
      RETURN ABS(@_biGeohash % 16) + 1 --1 to 12 (inclusive)
    END --qalGeohash_Main.extractCharsWide
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[extractBitsWideCheck] (
  @_biGeohash BIGINT
) RETURNS
    TINYINT
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Main.extractBitsWide(@_biGeohash)
    END --qalGeohash_Main.extractBitsWideCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[extractBitsWide] (
  @_biGeohash BIGINT
) RETURNS
    TINYINT
  AS
    BEGIN
      RETURN qalGeohash_Main.extractCharsWide(@_biGeohash) * 5 -- 5 to 60 by 5s (inclusive)
    END --qalGeohash_Main.extractBitsWide
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[extractSansCheck] (
  @_biGeohash BIGINT
) RETURNS
    BIGINT
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Main.extractSans(@_biGeohash)
    END --qalGeohash_Main.extractSansCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[extractSans] (
  @_biGeohash BIGINT
) RETURNS
    BIGINT
  AS
    BEGIN
      DECLARE @biGeohashSans_ BIGINT = ABS(@_biGeohash / 16)
      IF (@_biGeohash < 0) --highest bit is set
        --Use the bit represented by 2^59 and then it back into to the sign inverted value
        SET @biGeohashSans_ = @biGeohashSans_ + 576460752303423488

      RETURN @biGeohashSans_
    END --qalGeohash_Main.extractBitsWide
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[encodeBigintCheck] (
  @_biGeohashSans BIGINT,
  @_tiBitsWide    TINYINT
) RETURNS
    BIGINT
  AS
    BEGIN
      --validate preconditions
      IF ( 
        (qalGeohash_Preconditions.checkSans(@_biGeohashSans) IS NOT NULL) OR
        (qalGeohash_Preconditions.checkBitsWide(@_tiBitsWide) IS NOT NULL)
      )   
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Auxiliary.encodeBigint(@_biGeohashSans, @_tiBitsWide)
    END --qalGeohash_Auxiliary.encodeBigintCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[encodeBigint] (
  @_biGeohashSans BIGINT,
  @_tiBitsWide    TINYINT
) RETURNS
    BIGINT
  AS
    BEGIN
      --Allocate working variables
      DECLARE @tiLeastSignficantBitsX4 TINYINT = (@_tiBitsWide / 5) - 1

      --Execute the operation
      IF (@_biGeohashSans < 576460752303423488)
        RETURN (@_biGeohashSans * 16) + @tiLeastSignficantBitsX4
  
      --Return the results
      --Because the 60th bit is set, it must first be stripped (@biGeohashSans_ - 576460752303423488) before the shift
      --  left (* 16) can occur (or an Arithmetic overflow will happen), and then the number of chars must be added before the
      --  entire thing is negated to regain the lost highest bit set
      RETURN -(((@_biGeohashSans - 576460752303423488) * 16) + @tiLeastSignficantBitsX4)
    END --qalGeohash_Auxiliary.encodeBigint
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[decodeBigintCheck] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE(
        biGeohashSans BIGINT,
        tiBitsWide    TINYINT
      )
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN

      --Return the results
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Auxiliary.decodeBigint(@_biGeohash)
      RETURN 
    END --qalGeohash_Auxiliary.decodeBigintCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[decodeBigint] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE(
        biGeohashSans BIGINT,
        tiBitsWide    TINYINT
      )
  AS
    BEGIN
      --Return the results
      INSERT INTO @table_
        SELECT qalGeohash_Main.extractSans(@_biGeohash),
               qalGeohash_Main.extractBitsWide(@_biGeohash)
      RETURN

    END --qalGeohash_Auxiliary.decodeBigint
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[convertBigintToVarcharCheck] (
  @_biGeohash BIGINT
) RETURNS
    VARCHAR(12)
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Main.convertBigintToVarchar(@_biGeohash)
    END --qalGeohash_Main.convertBigintToVarcharCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[convertBigintToVarchar] (
  @_biGeohash BIGINT
) RETURNS
    VARCHAR(12)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @vcGeohash_ VARCHAR(12) = ''

      --Allocate working variables
      DECLARE @biGeohashSans  BIGINT  = qalGeohash_Main.extractSans(@_biGeohash)
      DECLARE @tiGeohashWidth TINYINT = qalGeohash_Main.extractCharsWide(@_biGeohash)
      DECLARE @tiGeohashIndex TINYINT = 0

      --Execute the operation
      WHILE (@tiGeohashIndex < @tiGeohashWidth)
        BEGIN
          SET @vcGeohash_ = CONCAT(SUBSTRING('0123456789bcdefghjkmnpqrstuvwxyz', (@biGeohashSans % 32) + 1, 1), @vcGeohash_)
          SET @biGeohashSans = @biGeohashSans / 32
          SET @tiGeohashIndex = @tiGeohashIndex + 1
        END

      --Return the results
      RETURN @vcGeohash_
    END --qalGeohash_Main.convertBigintToVarchar
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[convertVarcharToBigintCheck] (
  @_vcGeohash VARCHAR(12)
) RETURNS 
    BIGINT
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkVarchar(@_vcGeohash) IS NOT NULL)
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Main.convertVarcharToBigint(@_vcGeohash)
    END --qalGeohash_Main.convertVarcharToBigintCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[convertVarcharToBigint] (
  @_vcGeohash VARCHAR(12)
) RETURNS 
    BIGINT
  AS
    BEGIN
      --Allocate working variables
      DECLARE @biGeohashSans  BIGINT  = 0
      DECLARE @tiGeohashWidth TINYINT = LEN(@_vcGeohash) --1 to 12 (inclusive)
      DECLARE @tiGeohashIndex TINYINT = 0

      --Execute the operation
      WHILE (@tiGeohashIndex < @tiGeohashWidth)
        BEGIN
          SET @biGeohashSans = 
            (@biGeohashSans * 32) +
            (CHARINDEX(LOWER(SUBSTRING(@_vcGeohash, @tiGeohashIndex + 1, 1)),'0123456789bcdefghjkmnpqrstuvwxyz') - 1)
          SET @tiGeohashIndex = @tiGeohashIndex + 1
        END

      --Return the results
      RETURN qalGeohash_Main.encodeBigint(@biGeohashSans, @tiGeohashWidth * 5)
    END --qalGeohash_Main.convertVarcharToBigint
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[expandBigintIntoLongCheck] (
  @_biGeohash BIGINT
) RETURNS
    DECIMAL(15, 12)
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN NULL
        
      --Return the results
      RETURN qalGeohash_Main.expandBigintIntoLong(@_biGeohash)
    END --qalGeohash_Main.expandBigintIntoLongCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[expandBigintIntoLong] (
  @_biGeohash BIGINT
) RETURNS
    DECIMAL(15, 12)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @dcCenterLongitude_ DECIMAL(15, 12) = NULL

      --Execute the operation
      SELECT @dcCenterLongitude_ = dcCenterLongitude
        FROM qalGeohash_Main.expandBigintIntoLongLats(@_biGeohash)

      --Return the results
      RETURN @dcCenterLongitude_
    END --qalGeohash_Main.expandBigintIntoLong
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[expandBigintIntoLatCheck] (
  @_biGeohash BIGINT
) RETURNS
    DECIMAL(15, 12)
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN NULL
        
      --Return the results
      RETURN qalGeohash_Main.expandBigintIntoLat(@_biGeohash)
    END --qalGeohash_Main.expandBigintIntoLatCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[expandBigintIntoLat] (
  @_biGeohash BIGINT
) RETURNS
    DECIMAL(15, 12)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @dcCenterLatitude_ DECIMAL(15, 12) = NULL

      --Execute the operation
      SELECT @dcCenterLatitude_ = dcCenterLatitude
        FROM qalGeohash_Main.expandBigintIntoLongLats(@_biGeohash)

      --Return the results
      RETURN @dcCenterLatitude_
    END --qalGeohash_Main.expandBigintIntoLat
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[expandBigintIntoLongLatCheck] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE(
        dcLongitude DECIMAL(15, 12),
        dcLatitude  DECIMAL(15, 12)
      )
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN
        
      --Return the results
      INSERT INTO @table_
        SELECT * FROM qalGeohash_Main.expandBigintIntoLongLat(@_biGeohash)
      RETURN
    END --qalGeohash_Main.expandBigintIntoLongLatCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[expandBigintIntoLongLat] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE(
        dcLongitude DECIMAL(15, 12),
        dcLatitude  DECIMAL(15, 12)
      )
  AS
    BEGIN
      --Return the results
      INSERT INTO @table_
        SELECT dcCenterLongitude,
               dcCenterLatitude
          FROM qalGeohash_Main.expandBigintIntoLongLats(@_biGeohash)
      RETURN
    END --qalGeohash_Main.expandBigintIntoLongLat
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[expandBigintIntoLongLatsCheck] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE(
        dcCenterLongitude DECIMAL(15, 12),
        dcCenterLatitude  DECIMAL(15, 12),
        dcLeftLongitude   DECIMAL(15, 12),
        dcRightLongitude  DECIMAL(15, 12),
        dcLowerLatitude   DECIMAL(15, 12),
        dcUpperLatitude   DECIMAL(15, 12)
      )
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN
        
      INSERT INTO @table_
        SELECT * FROM qalGeohash_Main.expandBigintIntoLongLats(@_biGeohash)
      RETURN
    END --qalGeohash_Main.expandBigintIntoLongLatsCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[expandBigintIntoLongLats] (
  @_biGeohash BIGINT
) RETURNS
    @table_
      TABLE(
        dcCenterLongitude DECIMAL(15, 12),
        dcCenterLatitude  DECIMAL(15, 12),
        dcLeftLongitude   DECIMAL(15, 12),
        dcRightLongitude  DECIMAL(15, 12),
        dcLowerLatitude   DECIMAL(15, 12),
        dcUpperLatitude   DECIMAL(15, 12)
      )
  AS
    BEGIN
      --Allocate result storage
      DECLARE @dcLeftLongitude_  DECIMAL(15, 12) = -180.0
      DECLARE @dcRightLongitude_ DECIMAL(15, 12) =  180.0
      DECLARE @dcLowerLatitude_  DECIMAL(15, 12) =  -90.0
      DECLARE @dcUpperLatitude_  DECIMAL(15, 12) =   90.0

      --Allocate working variables
      DECLARE @biBitIndexValue   BIGINT  = POWER(CAST(2 AS BIGINT), qalGeohash_Main.extractBitsWide(@_biGeohash) - 1)
      DECLARE @biGeohashSans     BIGINT  = qalGeohash_Main.extractSans(@_biGeohash)
      DECLARE @bIsBitSet         BIT     = NULL --0 to 1 (inclusive)
      DECLARE @bIsLatitude       BIT     = 0 --Start with Longitude
      DECLARE @dcL_itutde        DECIMAL(15, 12) = NULL

      --Execute the operation
      WHILE (@biBitIndexValue > 0)
        BEGIN
          IF (@biGeohashSans >= @biBitIndexValue)
            BEGIN
              SET @bIsBitSet = 1
              SET @biGeohashSans = @biGeohashSans - @biBitIndexValue
            END
          ELSE
            SET @bIsBitSet = 0
          IF (@bIsLatitude = 0)
            BEGIN
              SET @dcL_itutde = (@dcLeftLongitude_ + @dcRightLongitude_) / 2
              IF (@bIsBitSet = 1)
                SET @dcLeftLongitude_ = @dcL_itutde
              ELSE
                SET @dcRightLongitude_ = @dcL_itutde
            END
          ELSE
            BEGIN
              SET @dcL_itutde = (@dcLowerLatitude_ + @dcUpperLatitude_) / 2
              IF (@bIsBitSet = 1)
                SET @dcLowerLatitude_ = @dcL_itutde
              ELSE
                SET @dcUpperLatitude_ = @dcL_itutde
            END
          SET @bIsLatitude = CASE WHEN (@bIsLatitude = 0) THEN 1 ELSE 0 END
          SET @biBitIndexValue = @biBitIndexValue / 2
        END
      
      --Return the results
      INSERT INTO @table_
        SELECT (@dcLeftLongitude_ + @dcRightLongitude_) / 2,
               (@dcLowerLatitude_ + @dcUpperLatitude_)  / 2,
               @dcLeftLongitude_,
               @dcRightLongitude_,
               @dcLowerLatitude_,
               @dcUpperLatitude_
      RETURN
    END --qalGeohash_Main.expandBigintIntoLongLats
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[expandVarcharIntoLongLatCheck] (
  @_vcGeohash VARCHAR(12)
) RETURNS 
    @table_
      TABLE(
        dcLongitude DECIMAL(15, 12),
        dcLatitude  DECIMAL(15, 12)
      )
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkVarchar(@_vcGeohash) IS NOT NULL)
        RETURN
      
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Main.expandVarcharIntoLongLat(@_vcGeohash)
      RETURN 
    END --qalGeohash_Main.expandVarcharIntoLongLatCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[expandVarcharIntoLongLat] (
  @_vcGeohash VARCHAR(12)
) RETURNS 
    @table_
      TABLE(
        dcLongitude DECIMAL(15, 12),
        dcLatitude  DECIMAL(15, 12)
      )
  AS
    BEGIN
      --Execute the operation
      DECLARE @biGeohash BIGINT  = qalGeohash_Main.convertVarcharToBigint(@_vcGeohash)

      --Return the results
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Main.expandBigintIntoLongLat(@biGeohash)
      RETURN 
    END --qalGeohash_Main.expandVarcharIntoLongLat
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[expandVarcharIntoLongLatsCheck] (
  @_vcGeohash VARCHAR(12)
) RETURNS 
    @table_
      TABLE(
        dcCenterLongitude DECIMAL(15, 12),
        dcCenterLatitude  DECIMAL(15, 12),
        dcLeftLongitude   DECIMAL(15, 12),
        dcRightLongitude  DECIMAL(15, 12),
        dcLowerLatitude   DECIMAL(15, 12),
        dcUpperLatitude   DECIMAL(15, 12)
      )
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkVarchar(@_vcGeohash) IS NOT NULL)
        RETURN
      
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Main.expandVarcharIntoLongLats(@_vcGeohash)
      RETURN 
    END --qalGeohash_Main.expandVarcharIntoLongLatsCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[expandVarcharIntoLongLats] (
  @_vcGeohash VARCHAR(12)
) RETURNS 
    @table_
      TABLE(
        dcCenterLongitude DECIMAL(15, 12),
        dcCenterLatitude  DECIMAL(15, 12),
        dcLeftLongitude   DECIMAL(15, 12),
        dcRightLongitude  DECIMAL(15, 12),
        dcLowerLatitude   DECIMAL(15, 12),
        dcUpperLatitude   DECIMAL(15, 12)
      )
  AS
    BEGIN
      --Execute the operation
      DECLARE @biGeohash BIGINT  = qalGeohash_Main.convertVarcharToBigint(@_vcGeohash)

      --Return the results
      INSERT INTO @table_
        SELECT *
          FROM qalGeohash_Main.expandBigintIntoLongLats(@biGeohash)
      RETURN 
    END --qalGeohash_Main.expandVarcharIntoLongLats
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[reduceLongLatIntoBigintCheck] (
  @_dcLongitude DECIMAL(15, 12), --under 0.1mm
  @_dcLatitude  DECIMAL(15, 12), --under 0.1mm
  @_tiBitsWide  TINYINT = 55     --Largest value producing a square-like tile and still storable in a C# and Java type of Double
) RETURNS
    BIGINT
  AS
    BEGIN
      --validate preconditions
      IF (
        (qalGeohash_Preconditions.checkL_itude(0, @_dcLongitude) IS NOT NULL) OR
        (qalGeohash_Preconditions.checkL_itude(1, @_dcLatitude) IS NOT NULL) OR
        (qalGeohash_Preconditions.checkBitsWide(@_tiBitsWide) IS NOT NULL)
      )
        RETURN NULL
        
      --Return the results
      RETURN qalGeohash_Main.reduceLongLatIntoBigint(@_dcLongitude, @_dcLatitude, @_tiBitsWide)
    END --qalGeohash_Main.reduceLongLatIntoBigintCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[reduceLongLatIntoBigint] (
  @_dcLongitude DECIMAL(15, 12), --under 0.1mm
  @_dcLatitude  DECIMAL(15, 12), --under 0.1mm
  @_tiBitsWide  TINYINT = 55     --Largest value producing a square-like tile and still storable in a C# and Java type of Double
) RETURNS
    BIGINT --60 bits of value + 4 bits of length (0 based)
  AS
    BEGIN
      --Allocate working variables
      DECLARE @biBitIndexValue  BIGINT  = POWER(CAST(2 AS BIGINT), @_tiBitsWide - 1)
      DECLARE @bIsLatitude      BIT     = 0 --Start with Longitude
      DECLARE @dcMidpoint       DECIMAL(15, 12) = NULL
      DECLARE @dcLeftLongitude  DECIMAL(15, 12) = -180.0
      DECLARE @dcRightLongitude DECIMAL(15, 12) =  180.0
      DECLARE @dcLowerLatitude  DECIMAL(15, 12) =  -90.0
      DECLARE @dcUpperLatitude  DECIMAL(15, 12) =   90.0
      DECLARE @biGeohashSans    BIGINT  = 0

      --Execute the operation
      WHILE (@biBitIndexValue > 0)
        BEGIN
          IF (@bIsLatitude = 0)
            BEGIN
              SET @dcMidpoint = (@dcLeftLongitude + @dcRightLongitude) / 2
              IF (@_dcLongitude >= @dcMidpoint)
                BEGIN
                  SET @biGeohashSans = @biGeohashSans + @biBitIndexValue
                  SET @dcLeftLongitude = @dcMidpoint
                END
              ELSE
                SET @dcRightLongitude = @dcMidpoint
            END
          ELSE
            BEGIN
              SET @dcMidpoint = (@dcLowerLatitude + @dcUpperLatitude) / 2
              IF (@_dcLatitude >= @dcMidpoint)
                BEGIN
                  SET @biGeohashSans = @biGeohashSans + @biBitIndexValue
                  SET @dcLowerLatitude = @dcMidpoint
                END
              ELSE
                SET @dcUpperLatitude = @dcMidpoint
            END
          SET @bIsLatitude = CASE WHEN (@bIsLatitude = 0) THEN 1 ELSE 0 END
          SET @biBitIndexValue = @biBitIndexValue / 2
        END

      --Return the results
      RETURN qalGeohash_Main.encodeBigint(@biGeohashSans, @_tiBitsWide)
    END --qalGeohash_Main.reduceLongLatIntoBigint
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[reduceLongLatIntoVarcharCheck] (
  @_dcLongitude DECIMAL(15, 12), --under 0.1mm
  @_dcLatitude  DECIMAL(15, 12), --under 0.1mm
  @_tiCharsWide TINYINT = 11     --Largest value producing a square-like tile and storable in a C# and Java type of Double
) RETURNS
    VARCHAR(12)
  AS
    BEGIN
      --validate preconditions
      IF ((@_tiCharsWide = 0) OR (@_tiCharsWide > 12))
        RETURN NULL
      IF (
        (qalGeohash_Preconditions.checkL_itude(0, @_dcLongitude) IS NOT NULL) OR
        (qalGeohash_Preconditions.checkL_itude(1, @_dcLatitude) IS NOT NULL) OR
        (qalGeohash_Preconditions.checkBitsWide(@_tiCharsWide * 5) IS NOT NULL)
      )
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Main.reduceLongLatIntoVarchar(@_dcLongitude, @_dcLatitude, @_tiCharsWide)
    END --qalGeohash_Main.reduceLongLatIntoVarcharCheck
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Main].[reduceLongLatIntoVarchar] (
  @_dcLongitude DECIMAL(15, 12), --under 0.1mm
  @_dcLatitude  DECIMAL(15, 12), --under 0.1mm
  @_tiCharsWide TINYINT = 11     --Largest value producing a square-like tile and storable in a C# and Java type of Double
) RETURNS
    VARCHAR(12)
  AS
    BEGIN
      --Allocate working variables
      --Execute the operation
      DECLARE @biGeohash  BIGINT  = qalGeohash_Main.reduceLongLatIntoBigint(@_dcLongitude, @_dcLatitude, @_tiCharsWide * 5)

      --Return the results
      RETURN qalGeohash_Main.convertBigintToVarchar(@biGeohash)
    END --qalGeohash_Main.reduceLongLatIntoVarchar
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
