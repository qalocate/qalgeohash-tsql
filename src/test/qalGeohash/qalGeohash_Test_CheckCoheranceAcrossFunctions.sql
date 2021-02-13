-- /* ---------.---------.---------.---------.---------.---------.--------.---------.---------.---------.---------.--------- *\
-- ** Part Of:     QA Locate Geohash API                                                                                     **
-- ** URL:         http://www.qalocate.com                                                                                   **
-- ** File:                                                                                                                  **
-- **   Name:      qalGeohash_Test_CheckCoheranceAcrossFunctions.sql                                                         **
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

--NOTE: None of these functions are focused on the individual functions, per se. For tests focused entirely on a particular
--      functions verification, see the positive/negative test cases

--NOTE: Uncomment out the next two lines when needing to initialize the schema (when loading the very first time)
--CREATE SCHEMA qalGeohash_Test_CheckCoheranceAcrossFunctions
--GO

DROP FUNCTION IF EXISTS [qalGeohash_Test_CheckCoheranceAcrossFunctions].[main]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Test_CheckCoheranceAcrossFunctions].[dms]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Test_CheckCoheranceAcrossFunctions].[auxiliary]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Test_CheckCoheranceAcrossFunctions].[geography]
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Test_CheckCoheranceAcrossFunctions].[main] (
  @_biGeohash   BIGINT,          --Driving value for all other function validation
  @_dcLongitude DECIMAL(15, 12),
  @_dcLatitude  DECIMAL(15, 12),
  @_vcGeohash   VARCHAR(12)
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @failedConditions_ VARCHAR(MAX) = ''

      DECLARE @failedPreconditions_biGeohash   VARCHAR(MAX) = qalGeohash_Preconditions.checkBigint(@_biGeohash)
      DECLARE @failedPreconditions_dcLongitude VARCHAR(MAX) = qalGeohash_Preconditions.checkL_itude(0, @_dcLongitude)
      DECLARE @failedPreconditions_dcLatitude  VARCHAR(MAX) = qalGeohash_Preconditions.checkL_itude(1, @_dcLatitude)
      DECLARE @failedPreconditions_vcGeohash   VARCHAR(MAX) = qalGeohash_Preconditions.checkVarchar(@_vcGeohash)
      IF (@failedPreconditions_biGeohash IS NOT NULL)
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkBigint>' + @failedPreconditions_biGeohash
      IF (@failedPreconditions_dcLongitude IS NOT NULL)
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkL_itude>' + @failedPreconditions_dcLongitude --error message(s) contain(s) the tag indicating to which it is related of Longitude(x) or Latitude(y)
      IF (@failedPreconditions_dcLatitude IS NOT NULL)
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkL_itude>' + @failedPreconditions_dcLatitude --error message(s) contain(s) the tag indicating to which it is related of Longitude(x) or Latitude(y)
      IF (@failedPreconditions_vcGeohash IS NOT NULL)
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkVarchar>' + @failedPreconditions_vcGeohash
      IF (@failedConditions_ = '')
        BEGIN
          DECLARE @vcGeohashFromBigint VARCHAR(MAX) = qalGeohash_Main.convertBigintToVarcharCheck(@_biGeohash)
          IF (@vcGeohashFromBigint <> @_vcGeohash)
            SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.convertBigintToVarchar>' + '|@_biGeohash [' + CAST(@vcGeohashFromBigint AS VARCHAR(MAX))+ '] is not equal to @_vcGeohash [' + CAST(@_vcGeohash AS VARCHAR(MAX))+ ']'
          DECLARE @biGeohashFromVarchar VARCHAR(MAX) = qalGeohash_Main.convertVarcharToBigintCheck(@_vcGeohash)
          IF (@biGeohashFromVarchar <> @_biGeohash)
            SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.convertVarcharToBigint>' + '|@_vcGeohash [' + CAST(@biGeohashFromVarchar AS VARCHAR(MAX))+ '] is not equal to @_biGeohash [' + CAST(@_biGeohash AS VARCHAR(MAX))+ ']'
          IF (@failedConditions_ = '')
            BEGIN
              DECLARE @failedConditionsExtractEncodeDecode VARCHAR(MAX)    = ''
              DECLARE @biSansFor_biGeohashA      BIGINT  = qalGeohash_Main.extractSansCheck(@_biGeohash)
              DECLARE @tiBitsWideFor_biGeohashA  TINYINT = qalGeohash_Main.extractBitsWideCheck(@_biGeohash)
              DECLARE @tiCharsWideFor_biGeohashA TINYINT = qalGeohash_Main.extractCharsWideCheck(@_biGeohash)
              DECLARE @biSansFor_biGeohashB      BIGINT  = NULL
              DECLARE @tiBitsWideFor_biGeohashB  TINYINT = NULL
              SELECT @biSansFor_biGeohashB     = tuple.biGeohashSans
                   , @tiBitsWideFor_biGeohashB = tuple.tiBitsWide
                FROM qalGeohash_Main.decodeBigintCheck(@_biGeohash) AS tuple
              IF (@tiCharsWideFor_biGeohashA * 5 <> @tiBitsWideFor_biGeohashA)
                SET @failedConditionsExtractEncodeDecode = @failedConditionsExtractEncodeDecode + '|@tiCharsWideFor_biGeohashA [' + CAST(@tiCharsWideFor_biGeohashA AS VARCHAR(MAX)) + '] * 5 is not equal to @tiBitsWideFor_biGeohashA [' + CAST(@tiBitsWideFor_biGeohashA AS VARCHAR(MAX)) + ']'
              IF (@biSansFor_biGeohashA <> @biSansFor_biGeohashB)
                SET @failedConditionsExtractEncodeDecode = @failedConditionsExtractEncodeDecode + '|@biSansFor_biGeohashA [' + CAST(@biSansFor_biGeohashA AS VARCHAR(MAX)) + '] is not equal to @biSansFor_biGeohashB [' + CAST(@biSansFor_biGeohashB AS VARCHAR(MAX)) + ']'
              IF (@tiBitsWideFor_biGeohashA <> @tiBitsWideFor_biGeohashB)
                SET @failedConditionsExtractEncodeDecode = @failedConditionsExtractEncodeDecode + '|@tiBitsWideFor_biGeohashA [' + CAST(@tiBitsWideFor_biGeohashA AS VARCHAR(MAX)) + '] is not equal to @tiBitsWideFor_biGeohashB [' + CAST(@tiBitsWideFor_biGeohashB AS VARCHAR(MAX)) + ']'
              DECLARE @encoded_biGeohashA BIGINT = qalGeohash_Main.encodeBigintCheck(@biSansFor_biGeohashA, @tiBitsWideFor_biGeohashA)
              IF (@encoded_biGeohashA <> @_biGeohash)
                SET @failedConditionsExtractEncodeDecode = @failedConditionsExtractEncodeDecode + '|@encoded_biGeohashA [' + CAST(@encoded_biGeohashA AS VARCHAR(MAX)) + '] is not equal to @_biGeohash [' + CAST(@_biGeohash AS VARCHAR(MAX)) + ']'
              IF (@failedConditionsExtractEncodeDecode <> '')
                SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.Extract_Encode_Decode>' + @failedConditionsExtractEncodeDecode
              IF (@failedConditions_ = '')
                BEGIN
                  DECLARE @failedConditionsLongLats VARCHAR(MAX)    = ''
                  DECLARE @biGeohashLoneLongitude DECIMAL(15, 12) = qalGeohash_Main.expandBigintIntoLongCheck(@_biGeohash)
                  IF (@biGeohashLoneLongitude <> @_dcLongitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashLoneLongitude [' + CAST(@biGeohashLoneLongitude AS VARCHAR(MAX)) + '] is not equal to @_dcLongitude [' + CAST(@_dcLongitude AS VARCHAR(MAX)) + ']'
                  DECLARE @biGeohashLoneLatgitude DECIMAL(15, 12) = qalGeohash_Main.expandBigintIntoLatCheck(@_biGeohash)
                  IF (@biGeohashLoneLatgitude <> @_dcLatitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashLoneLatgitude [' + CAST(@biGeohashLoneLatgitude AS VARCHAR(MAX)) + '] is not equal to @_dcLatitude [' + CAST(@_dcLatitude AS VARCHAR(MAX)) + ']'
                  IF (@failedConditionsLongLats <> '')
                    BEGIN
                      SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.expandBigintIntoLongOrLat>' + @failedConditionsLongLats
                      SET @failedConditionsLongLats = ''
                    END
                  DECLARE @biGeohashLongitude DECIMAL(15, 12) = NULL
                  DECLARE @biGeohashLatitude  DECIMAL(15, 12) = NULL
                  SELECT @biGeohashLongitude = tuple.dcLongitude,
                        @biGeohashLatitude  = tuple.dcLatitude
                    FROM qalGeohash_Main.expandBigintIntoLongLatCheck(@_biGeohash) AS tuple
                  IF (@biGeohashLongitude <> @_dcLongitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashLongitude [' + CAST(@biGeohashLongitude AS VARCHAR(MAX)) + '] is not equal to @_dcLongitude [' + CAST(@_dcLongitude AS VARCHAR(MAX)) + ']'
                  IF (@biGeohashLatitude <> @_dcLatitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashLatitude [' + CAST(@biGeohashLatitude AS VARCHAR(MAX)) + '] is not equal to @_dcLatitude [' + CAST(@_dcLatitude AS VARCHAR(MAX)) + ']'
                  IF (@failedConditionsLongLats <> '')
                    BEGIN
                      SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.expandBigintIntoLongLat>' + @failedConditionsLongLats
                      SET @failedConditionsLongLats = ''
                    END
                  DECLARE @biGeohashCenterLongitude DECIMAL(15, 12) = NULL
                  DECLARE @biGeohashCenterLatitude  DECIMAL(15, 12) = NULL
                  DECLARE @biGeohashLeftLongitude   DECIMAL(15, 12) = NULL
                  DECLARE @biGeohashRightLongitude  DECIMAL(15, 12) = NULL
                  DECLARE @biGeohashLowerLatitude   DECIMAL(15, 12) = NULL
                  DECLARE @biGeohashUpperLatitude   DECIMAL(15, 12) = NULL
                  SELECT @biGeohashCenterLongitude = tuple.dcCenterLongitude,
                        @biGeohashCenterLatitude  = tuple.dcCenterLatitude,
                        @biGeohashLeftLongitude   = tuple.dcLeftLongitude,
                        @biGeohashRightLongitude  = tuple.dcRightLongitude,
                        @biGeohashLowerLatitude   = tuple.dcLowerLatitude,
                        @biGeohashUpperLatitude   = tuple.dcUpperLatitude
                    FROM qalGeohash_Main.expandBigintIntoLongLatsCheck(@_biGeohash) AS tuple
                  IF (@biGeohashCenterLongitude <> @_dcLongitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashCenterLongitude [' + CAST(@biGeohashCenterLongitude AS VARCHAR(MAX)) + '] is not equal to @_dcLongitude [' + CAST(@_dcLongitude AS VARCHAR(MAX)) + ']'
                  IF (@biGeohashCenterLatitude <> @_dcLatitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashCenterLatitude [' + CAST(@biGeohashCenterLatitude AS VARCHAR(MAX)) + '] is not equal to @_dcLatitude [' + CAST(@_dcLatitude AS VARCHAR(MAX)) + ']'
                  IF (@failedConditionsLongLats <> '')
                    BEGIN
                      SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.expandBigintIntoLongLats>' + @failedConditionsLongLats
                      SET @failedConditionsLongLats = ''
                    END
                  SELECT @biGeohashLongitude = tuple.dcLongitude,
                        @biGeohashLatitude  = tuple.dcLatitude
                    FROM qalGeohash_Main.expandVarcharIntoLongLatCheck(@_vcGeohash) AS tuple
                  IF (@biGeohashLongitude <> @_dcLongitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashLongitude [' + CAST(@biGeohashLongitude AS VARCHAR(MAX)) + '] is not equal to @_dcLongitude [' + CAST(@_dcLongitude AS VARCHAR(MAX)) + ']'
                  IF (@biGeohashLatitude <> @_dcLatitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashLatitude [' + CAST(@biGeohashLatitude AS VARCHAR(MAX)) + '] is not equal to @_dcLatitude [' + CAST(@_dcLatitude AS VARCHAR(MAX)) + ']'
                  IF (@failedConditionsLongLats <> '')
                    BEGIN
                      SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.expandVarcharIntoLongLat>' + @failedConditionsLongLats
                      SET @failedConditionsLongLats = ''
                    END
                  DECLARE @vcGeohashCenterLongitude DECIMAL(15, 12) = NULL
                  DECLARE @vcGeohashCenterLatitude  DECIMAL(15, 12) = NULL
                  DECLARE @vcGeohashLeftLongitude   DECIMAL(15, 12) = NULL
                  DECLARE @vcGeohashRightLongitude  DECIMAL(15, 12) = NULL
                  DECLARE @vcGeohashLowerLatitude   DECIMAL(15, 12) = NULL
                  DECLARE @vcGeohashUpperLatitude   DECIMAL(15, 12) = NULL
                  SELECT @vcGeohashCenterLongitude = tuple.dcCenterLongitude,
                        @vcGeohashCenterLatitude  = tuple.dcCenterLatitude,
                        @vcGeohashLeftLongitude   = tuple.dcLeftLongitude,
                        @vcGeohashRightLongitude  = tuple.dcRightLongitude,
                        @vcGeohashLowerLatitude   = tuple.dcLowerLatitude,
                        @vcGeohashUpperLatitude   = tuple.dcUpperLatitude
                    FROM qalGeohash_Main.expandVarcharIntoLongLatsCheck(@_vcGeohash) AS tuple
                  IF (@vcGeohashCenterLongitude <> @_dcLongitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@vcGeohashCenterLongitude [' + CAST(@vcGeohashCenterLongitude AS VARCHAR(MAX)) + '] is not equal to @_dcLongitude [' + CAST(@_dcLongitude AS VARCHAR(MAX)) + ']'
                  IF (@vcGeohashCenterLatitude <> @_dcLatitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@vcGeohashCenterLatitude [' + CAST(@vcGeohashCenterLatitude AS VARCHAR(MAX)) + '] is not equal to @_dcLatitude [' + CAST(@_dcLatitude AS VARCHAR(MAX)) + ']'
                  IF (@failedConditionsLongLats <> '')
                    BEGIN
                      SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.expandVarcharIntoLongLats>' + @failedConditionsLongLats
                      SET @failedConditionsLongLats = ''
                    END
                  IF (@biGeohashCenterLongitude <> @vcGeohashCenterLongitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashCenterLongitude [' + CAST(@biGeohashCenterLongitude AS VARCHAR(MAX)) + '] is not equal to @vcGeohashCenterLongitude [' + CAST(@vcGeohashCenterLongitude AS VARCHAR(MAX)) + ']'
                  IF (@biGeohashCenterLatitude <> @vcGeohashCenterLatitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashCenterLatitude [' + CAST(@biGeohashCenterLatitude AS VARCHAR(MAX)) + '] is not equal to @vcGeohashCenterLatitude [' + CAST(@vcGeohashCenterLatitude AS VARCHAR(MAX)) + ']'
                  IF (@biGeohashLeftLongitude <> @vcGeohashLeftLongitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashLeftLongitude [' + CAST(@biGeohashLeftLongitude AS VARCHAR(MAX)) + '] is not equal to @vcGeohashLeftLongitude [' + CAST(@vcGeohashLeftLongitude AS VARCHAR(MAX)) + ']'
                  IF (@biGeohashRightLongitude <> @vcGeohashRightLongitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashRightLongitude [' + CAST(@biGeohashRightLongitude AS VARCHAR(MAX)) + '] is not equal to @vcGeohashRightLongitude [' + CAST(@vcGeohashRightLongitude AS VARCHAR(MAX)) + ']'
                  IF (@biGeohashLowerLatitude <> @vcGeohashLowerLatitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashLowerLatitude [' + CAST(@biGeohashLowerLatitude AS VARCHAR(MAX)) + '] is not equal to @vcGeohashLowerLatitude [' + CAST(@vcGeohashLowerLatitude AS VARCHAR(MAX)) + ']'
                  IF (@biGeohashUpperLatitude <> @vcGeohashUpperLatitude)
                    SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashUpperLatitude [' + CAST(@biGeohashUpperLatitude AS VARCHAR(MAX)) + '] is not equal to @vcGeohashUpperLatitude [' + CAST(@vcGeohashUpperLatitude AS VARCHAR(MAX)) + ']'
                  IF (@failedConditionsLongLats <> '')
                    SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main._IntoLongLats>' + @failedConditionsLongLats
                  IF (@failedConditions_ = '')
                    BEGIN
                      DECLARE @tiCharsWide TINYINT = LEN(@_vcGeohash)
                      DECLARE @tiBitsWide  TINYINT = @tiCharsWide * 5
                      DECLARE @dcCenterBigint BIGINT = qalGeohash_Main.reduceLongLatIntoBigintCheck(@_dcLongitude, @_dcLatitude, @tiBitsWide)
                      IF (@dcCenterBigint <> @_biGeohash)
                        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.reduceLongLatIntoBigint>' + '|(@_dcLongitude [' + CAST(@_dcLongitude AS VARCHAR(MAX)) + '], @_dcLatitude [' + CAST(@_dcLatitude AS VARCHAR(MAX)) + '], @tiBitsWide [' + CAST(@tiBitsWide AS VARCHAR(MAX)) + ']) not equal to @_biGeohash [' + CAST(@_biGeohash AS VARCHAR(MAX)) + ']'
                      DECLARE @dcCenterVarchar VARCHAR(12) = qalGeohash_Main.reduceLongLatIntoVarcharCheck(@_dcLongitude, @_dcLatitude, @tiCharsWide)
                      IF (@dcCenterVarchar <> @_vcGeohash)
                        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.reduceLongLatIntoVarchar>' + '|(@_dcLongitude [' + CAST(@_dcLongitude AS VARCHAR(MAX)) + '], @_dcLatitude [' + CAST(@_dcLatitude AS VARCHAR(MAX)) + '], @tiCharsWide [' + CAST(@tiCharsWide AS VARCHAR(MAX)) + ']) not equal to @_vcGeohash [' + CAST(@_vcGeohash AS VARCHAR(MAX)) + ']'
                    END
                END
            END
        END

      --Return the results
      IF (@failedConditions_ = '')
        RETURN NULL
      RETURN @failedConditions_
    END --qalGeohash_Test_CheckCoheranceAcrossFunctions.main
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Test_CheckCoheranceAcrossFunctions].[dms] (
  @_biGeohash                  BIGINT,
  @_dcLongitude                DECIMAL(15, 12),
  @_dcLatitude                 DECIMAL(15, 12),
  @_vcGeohash                  VARCHAR(12),
  @_tiDegreesAbsoluteLongitude TINYINT,
  @_tiMinutesLongitude         TINYINT,
  @_dcSecondsLongitude         DECIMAL(8, 6),
  @_bIsNegativeLongitude       BIT,
  @_tiDegreesAbsoluteLatitude  TINYINT,
  @_tiMinutesLatitude          TINYINT,
  @_dcSecondsLatitude          DECIMAL(8, 6),
  @_bIsNegativeLatitude        BIT
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @failedConditions_ VARCHAR(MAX) = ''

      DECLARE @failedPreconditions_biGeohash    VARCHAR(MAX) = qalGeohash_Preconditions.checkBigint(@_biGeohash)
      DECLARE @failedPreconditions_dcLongitude  VARCHAR(MAX) = qalGeohash_Preconditions.checkL_itude(0, @_dcLongitude)
      DECLARE @failedPreconditions_dcLatitude   VARCHAR(MAX) = qalGeohash_Preconditions.checkL_itude(1, @_dcLatitude)
      DECLARE @failedPreconditions_vcGeohash    VARCHAR(MAX) = qalGeohash_Preconditions.checkVarchar(@_vcGeohash)
      DECLARE @failedPreconditions_dmsLongitude VARCHAR(MAX) = qalGeohash_Preconditions.checkDms(0, @_tiDegreesAbsoluteLongitude, @_tiMinutesLongitude, @_dcSecondsLongitude, @_bIsNegativeLongitude)
      DECLARE @failedPreconditions_dmsLatitude  VARCHAR(MAX) = qalGeohash_Preconditions.checkDms(1, @_tiDegreesAbsoluteLatitude, @_tiMinutesLatitude, @_dcSecondsLatitude, @_bIsNegativeLatitude)
      IF (@failedPreconditions_biGeohash IS NOT NULL)
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkBigint>' + @failedPreconditions_biGeohash
      IF (@failedPreconditions_dcLongitude IS NOT NULL)
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkL_itude>' + @failedPreconditions_dcLongitude --error message(s) contain(s) the tag indicating to which it is related of Longitude(x) or Latitude(y)
      IF (@failedPreconditions_dcLatitude IS NOT NULL)
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkL_itude>' + @failedPreconditions_dcLatitude --error message(s) contain(s) the tag indicating to which it is related of Longitude(x) or Latitude(y)
      IF (@failedPreconditions_vcGeohash IS NOT NULL)
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkVarchar>' + @failedPreconditions_vcGeohash
      IF (@failedPreconditions_dmsLongitude IS NOT NULL)
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkDms>' + @failedPreconditions_dmsLongitude --error message(s) contain(s) the tag indicating to which it is related of Longitude(x) or Latitude(y)
      IF (@failedPreconditions_dmsLatitude IS NOT NULL)
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkDms>' + @failedPreconditions_dmsLatitude --error message(s) contain(s) the tag indicating to which it is related of Longitude(x) or Latitude(y)
      IF (@failedConditions_ = '')
        BEGIN
          DECLARE @failedConditionsLongLats VARCHAR(MAX)    = ''
          DECLARE @biGeohashLongitude DECIMAL(15, 12) = NULL
          DECLARE @biGeohashLatitude  DECIMAL(15, 12) = NULL
          SELECT @biGeohashLongitude = tuple.dcLongitude,
                 @biGeohashLatitude  = tuple.dcLatitude
            FROM qalGeohash_Main.expandBigintIntoLongLatCheck(@_biGeohash) AS tuple
          IF (@biGeohashLongitude <> @_dcLongitude)
            SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashLongitude [' + CAST(@biGeohashLongitude AS VARCHAR(MAX)) + '] is not equal to @_dcLongitude [' + CAST(@_dcLongitude AS VARCHAR(MAX)) + ']'
          IF (@biGeohashLatitude <> @_dcLatitude)
            SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashLatitude [' + CAST(@biGeohashLatitude AS VARCHAR(MAX)) + '] is not equal to @_dcLatitude [' + CAST(@_dcLatitude AS VARCHAR(MAX)) + ']'
          IF (@failedConditionsLongLats <> '')
            SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.expandBigintIntoLongLats>' + @failedConditionsLongLats
          DECLARE @vcGeohashFromBigint VARCHAR(MAX) = qalGeohash_Main.convertBigintToVarcharCheck(@_biGeohash)
          IF (@vcGeohashFromBigint <> @_vcGeohash)
            SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.convertBigintToVarchar>' + '|@_biGeohash [' + CAST(@vcGeohashFromBigint AS VARCHAR(MAX))+ '] is not equal to @_vcGeohash [' + CAST(@_vcGeohash AS VARCHAR(MAX))+ ']'
          IF (@failedConditions_ = '')
            BEGIN
              DECLARE @failedConditionsDms        VARCHAR(MAX)  = ''
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
                      @bIsNegativeLongitude      = tuple.bIsNegativeLongitude,
                      @tiDegreesAbsoluteLatitude  = tuple.tiDegreesAbsoluteLatitude,
                      @tiMinutesLatitude          = tuple.tiMinutesLatitude,
                      @dcSecondsLatitude          = tuple.dcSecondsLatitude,
                      @bIsNegativeLatitude       = tuple.bIsNegativeLatitude
                FROM qalGeohash_Dms.expandBigintIntoDmsCheck(@_biGeohash) AS tuple
              IF (@tiDegreesAbsoluteLongitude <> @_tiDegreesAbsoluteLongitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@tiDegreesAbsoluteLongitude [' + CAST(@tiDegreesAbsoluteLongitude AS VARCHAR(MAX)) + '] is not equal to @_tiDegreesAbsoluteLongitude [' + CAST(@_tiDegreesAbsoluteLongitude AS VARCHAR(MAX)) + ']'
              IF (@tiMinutesLongitude <> @_tiMinutesLongitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@tiMinutesLongitude [' + CAST(@tiMinutesLongitude AS VARCHAR(MAX)) + '] is not equal to @_tiMinutesLongitude [' + CAST(@_tiMinutesLongitude AS VARCHAR(MAX)) + ']'
              IF (@dcSecondsLongitude <> @_dcSecondsLongitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@dcSecondsLongitude [' + CAST(@_dcSecondsLongitude AS VARCHAR(MAX)) + '] is not equal to @_dcSecondsLongitude [' + CAST(@_dcSecondsLongitude AS VARCHAR(MAX)) + ']'
              IF (@bIsNegativeLongitude <> @_bIsNegativeLongitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@bIsNegativeLongitude [' + CAST(@bIsNegativeLongitude AS VARCHAR(MAX)) + '] is not equal to @_bIsNegativeLongitude [' + CAST(@_bIsNegativeLongitude AS VARCHAR(MAX)) + ']'
              IF (@tiDegreesAbsoluteLatitude <> @_tiDegreesAbsoluteLatitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@tiDegreesAbsoluteLatitude [' + CAST(@tiDegreesAbsoluteLatitude AS VARCHAR(MAX)) + '] is not equal to @_tiDegreesAbsoluteLatitude [' + CAST(@_tiDegreesAbsoluteLatitude AS VARCHAR(MAX)) + ']'
              IF (@tiMinutesLatitude <> @_tiMinutesLatitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@tiMinutesLatitude [' + CAST(@tiMinutesLatitude AS VARCHAR(MAX)) + '] is not equal to @_tiMinutesLatitude [' + CAST(@_tiMinutesLatitude AS VARCHAR(MAX)) + ']'
              IF (@dcSecondsLatitude <> @_dcSecondsLatitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@dcSecondsLatitude [' + CAST(@_dcSecondsLatitude AS VARCHAR(MAX)) + '] is not equal to @_dcSecondsLatitude [' + CAST(@_dcSecondsLatitude AS VARCHAR(MAX)) + ']'
              IF (@bIsNegativeLatitude <> @_bIsNegativeLatitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@bIsNegativeLatitude [' + CAST(@bIsNegativeLatitude AS VARCHAR(MAX)) + '] is not equal to @_bIsNegativeLatitude [' + CAST(@_bIsNegativeLatitude AS VARCHAR(MAX)) + ']'
              IF (@failedConditionsDms <> '')
                BEGIN
                  SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Dms.expandBigintIntoDms>' + @failedConditionsDms
                  SET @failedConditionsDms = ''
                END
              SELECT  @tiDegreesAbsoluteLongitude = tuple.tiDegreesAbsoluteLongitude,
                      @tiMinutesLongitude         = tuple.tiMinutesLongitude,
                      @dcSecondsLongitude         = tuple.dcSecondsLongitude,
                      @bIsNegativeLongitude      = tuple.bIsNegativeLongitude,
                      @tiDegreesAbsoluteLatitude  = tuple.tiDegreesAbsoluteLatitude,
                      @tiMinutesLatitude          = tuple.tiMinutesLatitude,
                      @dcSecondsLatitude          = tuple.dcSecondsLatitude,
                      @bIsNegativeLatitude       = tuple.bIsNegativeLatitude
                FROM qalGeohash_Dms.expandVarcharIntoDmsCheck(@_vcGeohash) AS tuple
              IF (@tiDegreesAbsoluteLongitude <> @_tiDegreesAbsoluteLongitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@tiDegreesAbsoluteLongitude [' + CAST(@tiDegreesAbsoluteLongitude AS VARCHAR(MAX)) + '] is not equal to @_tiDegreesAbsoluteLongitude [' + CAST(@_tiDegreesAbsoluteLongitude AS VARCHAR(MAX)) + ']'
              IF (@tiMinutesLongitude <> @_tiMinutesLongitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@tiMinutesLongitude [' + CAST(@tiMinutesLongitude AS VARCHAR(MAX)) + '] is not equal to @_tiMinutesLongitude [' + CAST(@_tiMinutesLongitude AS VARCHAR(MAX)) + ']'
              IF (@dcSecondsLongitude <> @_dcSecondsLongitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@dcSecondsLongitude [' + CAST(@_dcSecondsLongitude AS VARCHAR(MAX)) + '] is not equal to @_dcSecondsLongitude [' + CAST(@_dcSecondsLongitude AS VARCHAR(MAX)) + ']'
              IF (@bIsNegativeLongitude <> @_bIsNegativeLongitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@bIsNegativeLongitude [' + CAST(@bIsNegativeLongitude AS VARCHAR(MAX)) + '] is not equal to @_bIsNegativeLongitude [' + CAST(@_bIsNegativeLongitude AS VARCHAR(MAX)) + ']'
              IF (@tiDegreesAbsoluteLatitude <> @_tiDegreesAbsoluteLatitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@tiDegreesAbsoluteLatitude [' + CAST(@tiDegreesAbsoluteLatitude AS VARCHAR(MAX)) + '] is not equal to @_tiDegreesAbsoluteLatitude [' + CAST(@_tiDegreesAbsoluteLatitude AS VARCHAR(MAX)) + ']'
              IF (@tiMinutesLatitude <> @_tiMinutesLatitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@tiMinutesLatitude [' + CAST(@tiMinutesLatitude AS VARCHAR(MAX)) + '] is not equal to @_tiMinutesLatitude [' + CAST(@_tiMinutesLatitude AS VARCHAR(MAX)) + ']'
              IF (@dcSecondsLatitude <> @_dcSecondsLatitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@dcSecondsLatitude [' + CAST(@_dcSecondsLatitude AS VARCHAR(MAX)) + '] is not equal to @_dcSecondsLatitude [' + CAST(@_dcSecondsLatitude AS VARCHAR(MAX)) + ']'
              IF (@bIsNegativeLatitude <> @_bIsNegativeLatitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@bIsNegativeLatitude [' + CAST(@bIsNegativeLatitude AS VARCHAR(MAX)) + '] is not equal to @_bIsNegativeLatitude [' + CAST(@_bIsNegativeLatitude AS VARCHAR(MAX)) + ']'
              IF (@failedConditionsDms <> '')
                BEGIN
                  SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Dms.expandVarcharIntoDms>' + @failedConditionsDms
                  SET @failedConditionsDms = ''
                END
              SELECT  @tiDegreesAbsoluteLongitude = tuple.tiDegreesAbsoluteLongitude,
                      @tiMinutesLongitude         = tuple.tiMinutesLongitude,
                      @dcSecondsLongitude         = tuple.dcSecondsLongitude,
                      @bIsNegativeLongitude      = tuple.bIsNegativeLongitude,
                      @tiDegreesAbsoluteLatitude  = tuple.tiDegreesAbsoluteLatitude,
                      @tiMinutesLatitude          = tuple.tiMinutesLatitude,
                      @dcSecondsLatitude          = tuple.dcSecondsLatitude,
                      @bIsNegativeLatitude       = tuple.bIsNegativeLatitude
                FROM qalGeohash_Dms.convertLongLatToDmsCheck(@_dcLongitude, @_dcLatitude) AS tuple
              IF (@tiDegreesAbsoluteLongitude <> @_tiDegreesAbsoluteLongitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@tiDegreesAbsoluteLongitude [' + CAST(@tiDegreesAbsoluteLongitude AS VARCHAR(MAX)) + '] is not equal to @_tiDegreesAbsoluteLongitude [' + CAST(@_tiDegreesAbsoluteLongitude AS VARCHAR(MAX)) + ']'
              IF (@tiMinutesLongitude <> @_tiMinutesLongitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@tiMinutesLongitude [' + CAST(@tiMinutesLongitude AS VARCHAR(MAX)) + '] is not equal to @_tiMinutesLongitude [' + CAST(@_tiMinutesLongitude AS VARCHAR(MAX)) + ']'
              IF (@dcSecondsLongitude <> @_dcSecondsLongitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@dcSecondsLongitude [' + CAST(@_dcSecondsLongitude AS VARCHAR(MAX)) + '] is not equal to @_dcSecondsLongitude [' + CAST(@_dcSecondsLongitude AS VARCHAR(MAX)) + ']'
              IF (@bIsNegativeLongitude <> @_bIsNegativeLongitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@bIsNegativeLongitude [' + CAST(@bIsNegativeLongitude AS VARCHAR(MAX)) + '] is not equal to @_bIsNegativeLongitude [' + CAST(@_bIsNegativeLongitude AS VARCHAR(MAX)) + ']'
              IF (@tiDegreesAbsoluteLatitude <> @_tiDegreesAbsoluteLatitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@tiDegreesAbsoluteLatitude [' + CAST(@tiDegreesAbsoluteLatitude AS VARCHAR(MAX)) + '] is not equal to @_tiDegreesAbsoluteLatitude [' + CAST(@_tiDegreesAbsoluteLatitude AS VARCHAR(MAX)) + ']'
              IF (@tiMinutesLatitude <> @_tiMinutesLatitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@tiMinutesLatitude [' + CAST(@tiMinutesLatitude AS VARCHAR(MAX)) + '] is not equal to @_tiMinutesLatitude [' + CAST(@_tiMinutesLatitude AS VARCHAR(MAX)) + ']'
              IF (@dcSecondsLatitude <> @_dcSecondsLatitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@dcSecondsLatitude [' + CAST(@_dcSecondsLatitude AS VARCHAR(MAX)) + '] is not equal to @_dcSecondsLatitude [' + CAST(@_dcSecondsLatitude AS VARCHAR(MAX)) + ']'
              IF (@bIsNegativeLatitude <> @_bIsNegativeLatitude)
                SET @failedConditionsDms = @failedConditionsDms + '|@bIsNegativeLatitude [' + CAST(@bIsNegativeLatitude AS VARCHAR(MAX)) + '] is not equal to @_bIsNegativeLatitude [' + CAST(@_bIsNegativeLatitude AS VARCHAR(MAX)) + ']'
              IF (@failedConditionsDms <> '')
                BEGIN
                  SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Dms.convertLongLatToDms>' + @failedConditionsDms
                  SET @failedConditionsDms = ''
                END
              IF (@failedConditions_ = '')
                BEGIN
                  DECLARE @tiCharsWide TINYINT = LEN(@_vcGeohash)
                  DECLARE @tiBitsWide  TINYINT = @tiCharsWide * 5
                  DECLARE @biGeohash   BIGINT =
                    qalGeohash_Dms.reduceDmsIntoBigintCheck(
                      @_tiDegreesAbsoluteLongitude,
                      @_tiMinutesLongitude,
                      @_dcSecondsLongitude,
                      @_bIsNegativeLongitude,
                      @_tiDegreesAbsoluteLatitude,
                      @_tiMinutesLatitude,
                      @_dcSecondsLatitude,
                      @_bIsNegativeLatitude,
                      @tiBitsWide
                    )
                  IF (@biGeohash <> @_biGeohash)
                    SET @failedConditions_ = @failedConditions_ +
                      '|<qalGeohash_Dms.reduceDmsIntoBigint>' +
                      '|@biGeohash [' + CAST(@biGeohash AS VARCHAR(MAX)) + '] is not equal to @_biGeohash [' + CAST(@_biGeohash AS VARCHAR(MAX)) + ']' +
                        ' - Dms details: ' +
                        '@_tiDegreesAbsoluteLongitude[' + CAST(@_tiDegreesAbsoluteLongitude AS VARCHAR(MAX)) + '], ' +
                        '@_tiMinutesLongitude[' + CAST(@_tiMinutesLongitude AS VARCHAR(MAX)) + '], ' +
                        '@_dcSecondsLongitude[' + CAST(@_dcSecondsLongitude AS VARCHAR(MAX)) + '], ' +
                        '@_bIsNegativeLongitude[' + CAST(@_bIsNegativeLongitude AS VARCHAR(MAX)) + '], ' +
                        '@_tiDegreesAbsoluteLatitude[' + CAST(@_tiDegreesAbsoluteLatitude AS VARCHAR(MAX)) + '], ' +
                        '@_tiMinutesLatitude[' + CAST(@_tiMinutesLatitude AS VARCHAR(MAX)) + '], ' +
                        '@_dcSecondsLatitude[' + CAST(@_dcSecondsLatitude AS VARCHAR(MAX)) + '], ' +
                        '@_bIsNegativeLatitude[' + CAST(@_bIsNegativeLatitude AS VARCHAR(MAX)) + ']'
                  DECLARE @vcGeohash   VARCHAR(12) =
                    qalGeohash_Dms.reduceDmsIntoVarcharCheck(
                      @_tiDegreesAbsoluteLongitude,
                      @_tiMinutesLongitude,
                      @_dcSecondsLongitude,
                      @_bIsNegativeLongitude,
                      @_tiDegreesAbsoluteLatitude,
                      @_tiMinutesLatitude,
                      @_dcSecondsLatitude,
                      @_bIsNegativeLatitude,
                      @tiCharsWide
                    )
                  IF (@vcGeohash <> @_vcGeohash)
                    SET @failedConditions_ = @failedConditions_ +
                        '|<qalGeohash_Dms.reduceDmsIntoVarchar>' +
                        '|@vcGeohash [' + @vcGeohash + '] is not equal to @_vcGeohash [' + @_vcGeohash + ']' +
                          ' - Dms details: ' +
                          '@_tiDegreesAbsoluteLongitude[' + CAST(@_tiDegreesAbsoluteLongitude AS VARCHAR(MAX)) + '], ' +
                          '@_tiMinutesLongitude[' + CAST(@_tiMinutesLongitude AS VARCHAR(MAX)) + '], ' +
                          '@_dcSecondsLongitude[' + CAST(@_dcSecondsLongitude AS VARCHAR(MAX)) + '], ' +
                          '@_bIsNegativeLongitude[' + CAST(@_bIsNegativeLongitude AS VARCHAR(MAX)) + '], ' +
                          '@_tiDegreesAbsoluteLatitude[' + CAST(@_tiDegreesAbsoluteLatitude AS VARCHAR(MAX)) + '], ' +
                          '@_tiMinutesLatitude[' + CAST(@_tiMinutesLatitude AS VARCHAR(MAX)) + '], ' +
                          '@_dcSecondsLatitude[' + CAST(@_dcSecondsLatitude AS VARCHAR(MAX)) + '], ' +
                          '@_bIsNegativeLatitude[' + CAST(@_bIsNegativeLatitude AS VARCHAR(MAX)) + ']'
                  DECLARE @dcLongitude DECIMAL(15,12) = NULL
                  DECLARE @dcLatitude  DECIMAL(15,12) = NULL
                  SELECT @dcLongitude = tuple.dcLongitude,
                         @dcLatitude = tuple.dcLatitude
                    FROM  qalGeohash_Dms.convertDmsToLongLatCheck(
                            @_tiDegreesAbsoluteLongitude,
                            @_tiMinutesLongitude,
                            @_dcSecondsLongitude,
                            @_bIsNegativeLongitude,
                            @_tiDegreesAbsoluteLatitude,
                            @_tiMinutesLatitude,
                            @_dcSecondsLatitude,
                            @_bIsNegativeLatitude
                          ) AS tuple
                  DECLARE @maxThreshold DECIMAL(15, 12) = 0.000000000500
                  IF (ABS(@dcLongitude - @_dcLongitude) > @maxThreshold)
                    SET @failedConditionsDms = @failedConditionsDms + 
                        '|@dcLongitude [' + CAST(@dcLongitude AS VARCHAR(MAX)) + '] exceeds the maximum difference [' + @maxThreshold + '] with @_dcLongitude [' + CAST(@_dcLongitude AS VARCHAR(MAX)) + ']' +
                          ' - Dms details: ' +
                          '@_tiDegreesAbsoluteLongitude[' + CAST(@_tiDegreesAbsoluteLongitude AS VARCHAR(MAX)) + '], ' +
                          '@_tiMinutesLongitude[' + CAST(@_tiMinutesLongitude AS VARCHAR(MAX)) + '], ' +
                          '@_dcSecondsLongitude[' + CAST(@_dcSecondsLongitude AS VARCHAR(MAX)) + '], ' +
                          '@_bIsNegativeLongitude[' + CAST(@_bIsNegativeLongitude AS VARCHAR(MAX)) + '], ' +
                          '@_tiDegreesAbsoluteLatitude[' + CAST(@_tiDegreesAbsoluteLatitude AS VARCHAR(MAX)) + '], ' +
                          '@_tiMinutesLatitude[' + CAST(@_tiMinutesLatitude AS VARCHAR(MAX)) + '], ' +
                          '@_dcSecondsLatitude[' + CAST(@_dcSecondsLatitude AS VARCHAR(MAX)) + '], ' +
                          '@_bIsNegativeLatitude[' + CAST(@_bIsNegativeLatitude AS VARCHAR(MAX)) + ']'
                  IF (ABS(@dcLatitude - @_dcLatitude) > @maxThreshold)
                    SET @failedConditionsDms = @failedConditionsDms + 
                        '|@dcLatitude [' + CAST(@dcLatitude AS VARCHAR(MAX)) + '] exceeds the maximum difference [' + @maxThreshold + '] with @_dcLatitude [' + CAST(@_dcLatitude AS VARCHAR(MAX)) + ']' +
                          ' - Dms details: ' +
                          '@_tiDegreesAbsoluteLongitude[' + CAST(@_tiDegreesAbsoluteLongitude AS VARCHAR(MAX)) + '], ' +
                          '@_tiMinutesLongitude[' + CAST(@_tiMinutesLongitude AS VARCHAR(MAX)) + '], ' +
                          '@_dcSecondsLongitude[' + CAST(@_dcSecondsLongitude AS VARCHAR(MAX)) + '], ' +
                          '@_bIsNegativeLongitude[' + CAST(@_bIsNegativeLongitude AS VARCHAR(MAX)) + '], ' +
                          '@_tiDegreesAbsoluteLatitude[' + CAST(@_tiDegreesAbsoluteLatitude AS VARCHAR(MAX)) + '], ' +
                          '@_tiMinutesLatitude[' + CAST(@_tiMinutesLatitude AS VARCHAR(MAX)) + '], ' +
                          '@_dcSecondsLatitude[' + CAST(@_dcSecondsLatitude AS VARCHAR(MAX)) + '], ' +
                          '@_bIsNegativeLatitude[' + CAST(@_bIsNegativeLatitude AS VARCHAR(MAX)) + ']'
                  IF (@failedConditionsDms <> '')
                    SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Dms.convertDmsToLongLat>' + @failedConditionsDms
                  --TODO: Implement for (to expose any copy/paste errors)
                  --        - expandBigintIntoDmss
                  --        - expandVarcharIntoDmss
                END
            END
        END

      --Return the results
      IF (@failedConditions_ = '')
        RETURN NULL
      RETURN @failedConditions_
    END --qalGeohash_Test_CheckCoheranceAcrossFunctions.dms
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Test_CheckCoheranceAcrossFunctions].[auxiliary] (
  @_biGeohash        BIGINT,          --Driving value for all other function validation
  @_dcLeftLongitude  DECIMAL(15, 12),
  @_dcRightLongitude DECIMAL(15, 12),
  @_dcLowerLatitude  DECIMAL(15, 12),
  @_dcUpperLatitude  DECIMAL(15, 12),
  @_biGeohashParent  BIGINT,
  @_vcGeohashParent  VARCHAR(12),
  @_biNorth          BIGINT,
  @_biNorthE         BIGINT,
  @_biEast           BIGINT,
  @_biSouthE         BIGINT,
  @_biSouth          BIGINT,
  @_biSouthW         BIGINT,
  @_biWest           BIGINT,
  @_biNorthW         BIGINT
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @failedConditions_ VARCHAR(MAX) = ''

      DECLARE @failedPreconditions_biGeohash VARCHAR(MAX) = qalGeohash_Preconditions.checkBigint(@_biGeohash)
      IF (@failedPreconditions_biGeohash IS NOT NULL)
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkBigint>' + @failedPreconditions_biGeohash
      IF (@failedConditions_ = '')
        BEGIN
          DECLARE @failedConditionsLongLats VARCHAR(MAX)    = ''
          DECLARE @biGeohashLeftLongitude   DECIMAL(15, 12) = NULL
          DECLARE @biGeohashRightLongitude  DECIMAL(15, 12) = NULL
          DECLARE @biGeohashLowerLatitude   DECIMAL(15, 12) = NULL
          DECLARE @biGeohashUpperLatitude   DECIMAL(15, 12) = NULL
          SELECT  @biGeohashLeftLongitude   = tuple.dcLeftLongitude,
                  @biGeohashRightLongitude  = tuple.dcRightLongitude,
                  @biGeohashLowerLatitude   = tuple.dcLowerLatitude,
                  @biGeohashUpperLatitude   = tuple.dcUpperLatitude
            FROM qalGeohash_Main.expandBigintIntoLongLatsCheck(@_biGeohash) AS tuple
          IF (@biGeohashLeftLongitude <> @_dcLeftLongitude)
            SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashLeftLongitude [' + CAST(@biGeohashLeftLongitude AS VARCHAR(MAX)) + '] is not equal to @_dcLeftLongitude [' + CAST(@_dcLeftLongitude AS VARCHAR(MAX)) + ']'
          IF (@biGeohashRightLongitude <> @_dcRightLongitude)
            SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashRightLongitude [' + CAST(@biGeohashRightLongitude AS VARCHAR(MAX)) + '] is not equal to @_dcRightLongitude [' + CAST(@_dcRightLongitude AS VARCHAR(MAX)) + ']'
          IF (@biGeohashLowerLatitude <> @_dcLowerLatitude)
            SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashLowerLatitude [' + CAST(@biGeohashLowerLatitude AS VARCHAR(MAX)) + '] is not equal to @_dcLowerLatitude [' + CAST(@_dcLowerLatitude AS VARCHAR(MAX)) + ']'
          IF (@biGeohashUpperLatitude <> @_dcUpperLatitude)
            SET @failedConditionsLongLats = @failedConditionsLongLats + '|@biGeohashUpperLatitude [' + CAST(@biGeohashUpperLatitude AS VARCHAR(MAX)) + '] is not equal to @_dcUpperLatitude [' + CAST(@_dcUpperLatitude AS VARCHAR(MAX)) + ']'
          IF (@failedConditionsLongLats <> '')
            SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.expandBigintIntoLongLats>' + @failedConditionsLongLats
          IF ((@_biGeohashParent IS NOT NULL) AND (@_vcGeohashParent IS NOT NULL))
            BEGIN
              IF (@_biGeohashParent = qalGeohash_Main.convertVarcharToBigintCheck(@_vcGeohashParent))
                BEGIN
                  DECLARE @biGeohashParent BIGINT = qalGeohash_Auxiliary.parentOfBigintCheck(@_biGeohash)
                  DECLARE @vcGeohash VARCHAR(12) = qalGeohash_Main.convertBigintToVarcharCheck(@_biGeohash)
                  DECLARE @vcGeohashParent VARCHAR(12) = qalGeohash_Auxiliary.parentOfVarcharCheck(@vcGeohash)
                  IF (qalGeohash_Main.extractBitsWideCheck(@_biGeohash) > 5)
                    BEGIN
                      IF (@biGeohashParent <> @_biGeohashParent)
                        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Auxiliary.parentOfBigint>' + '|@biGeohashParent [' + CAST(@biGeohashParent AS VARCHAR(MAX)) + '] is not equal to @_biGeohashParent [' + CAST(@_biGeohashParent AS VARCHAR(MAX)) + ']'
                      IF (@vcGeohashParent <> @_vcGeohashParent)
                        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Auxiliary.parentOfVarchar>' + '|@vcGeohashParent [' + @vcGeohashParent + '] (of @vcGeohash [' + @vcGeohash + ']) is not equal to @_vcGeohashParent [' + @_vcGeohashParent + ']'
                      IF (@biGeohashParent <> qalGeohash_Main.convertVarcharToBigintCheck(@vcGeohashParent))
                        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Auxiliary.parentOf>' + '|@biGeohashParent [' + CAST(@biGeohashParent AS VARCHAR(MAX)) + '] is not equal to qalGeohash_Main.convertVarcharToBigint(@vcGeohashParent) [' + CAST(qalGeohash_Main.convertVarcharToBigint(@vcGeohashParent) AS VARCHAR(MAX)) + ']'
                    END
                  ELSE
                    BEGIN
                      IF (@biGeohashParent IS NOT NULL)
                        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Auxiliary.parentOfBigint>' + '|@biGeohashParent [' + CAST(@biGeohashParent AS VARCHAR(MAX)) + '] is not NULL'
                      IF (@vcGeohashParent IS NOT NULL)
                        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Auxiliary.parentOfVarchar>' + '|@vcGeohashParent [' + @vcGeohashParent + '] is not NULL'
                    END
                END
              ELSE
                SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Auxiliary.inputParents>' + '|@_biGeohashParent [' + CAST(@_biGeohashParent AS VARCHAR(MAX)) + '] is not equal to qalGeohash_Main.convertVarcharToBigint(@_vcGeohashParent) [' + CAST(qalGeohash_Main.convertVarcharToBigint(@_vcGeohashParent) AS VARCHAR(MAX)) + ']'
              --TODO: Implement for
              --        - parentsOfBigint
              --        - parentsOfVarchar
            END
          ELSE
            IF ((@_biGeohashParent IS NOT NULL) OR (@_vcGeohashParent IS NOT NULL))
              SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Auxiliary.inputParents>' + '|One is NULL and the other not NULL of @_biGeohashParent [' + CAST(@_biGeohashParent AS VARCHAR(MAX)) + '] and @_vcGeohashParent [' + @_vcGeohashParent + ']'
          DECLARE @failedConditionsNeighbors VARCHAR(MAX) = ''
          DECLARE @biNorth  BIGINT = NULL
          DECLARE @biNorthE BIGINT = NULL
          DECLARE @biEast   BIGINT = NULL
          DECLARE @biSouthE BIGINT = NULL
          DECLARE @biSouth  BIGINT = NULL
          DECLARE @biSouthW BIGINT = NULL
          DECLARE @biWest   BIGINT = NULL
          DECLARE @biNorthW BIGINT = NULL
          SELECT  @biNorth   = tuple.biNorth,
                  @biNorthE  = tuple.biNorthEast,
                  @biEast    = tuple.biEast,
                  @biSouthE  = tuple.biSouthEast,
                  @biSouth   = tuple.biSouth,
                  @biSouthW  = tuple.biSouthWest,
                  @biWest    = tuple.biWest,
                  @biNorthW  = tuple.biNorthWest
            FROM qalGeohash_Auxiliary.neighborsOfBigintAsRowCheck(@_biGeohash) AS tuple
          IF (@biNorth <> @_biNorth)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biNorth [' + CAST(@biNorth AS VARCHAR(MAX)) + '] is not equal to @_biNorth [' + CAST(@_biNorth AS VARCHAR(MAX)) + ']'
          IF (@biNorthE <> @_biNorthE)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biNorthE [' + CAST(@biNorthE AS VARCHAR(MAX)) + '] is not equal to @_biNorthE [' + CAST(@_biNorthE AS VARCHAR(MAX)) + ']'
          IF (@biEast <> @_biEast)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biEast [' + CAST(@biEast AS VARCHAR(MAX)) + '] is not equal to @_biEast [' + CAST(@_biEast AS VARCHAR(MAX)) + ']'
          IF (@biSouthE <> @_biSouthE)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biSouthE [' + CAST(@biSouthE AS VARCHAR(MAX)) + '] is not equal to @_biSouthE [' + CAST(@_biSouthE AS VARCHAR(MAX)) + ']'
          IF (@biSouth <> @_biSouth)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biSouth [' + CAST(@biSouth AS VARCHAR(MAX)) + '] is not equal to @_biSouth [' + CAST(@_biSouth AS VARCHAR(MAX)) + ']'
          IF (@biSouthW <> @_biSouthW)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biSouthW [' + CAST(@biSouthW AS VARCHAR(MAX)) + '] is not equal to @_biSouthW [' + CAST(@_biSouthW AS VARCHAR(MAX)) + ']'
          IF (@biWest <> @_biWest)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biWest [' + CAST(@biWest AS VARCHAR(MAX)) + '] is not equal to @_biWest [' + CAST(@_biWest AS VARCHAR(MAX)) + ']'
          IF (@biNorthW <> @_biNorthW)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biNorthW [' + CAST(@biNorthW AS VARCHAR(MAX)) + '] is not equal to @_biNorthW [' + CAST(@_biNorthW AS VARCHAR(MAX)) + ']'
          IF (@failedConditionsNeighbors <> '')
            BEGIN
              SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Auxiliary.neighborsOfBigintAsRow>' + @failedConditionsNeighbors
              SET @failedConditionsNeighbors = ''
            END
          DECLARE @biCenter BIGINT = NULL
          SELECT  @biCenter  = tuple.biCenter,
                  @biNorth   = tuple.biNorth,
                  @biNorthE  = tuple.biNorthEast,
                  @biEast    = tuple.biEast,
                  @biSouthE  = tuple.biSouthEast,
                  @biSouth   = tuple.biSouth,
                  @biSouthW  = tuple.biSouthWest,
                  @biWest    = tuple.biWest,
                  @biNorthW  = tuple.biNorthWest
            FROM qalGeohash_Auxiliary.neighborsOfBigintWithSelfAsRowCheck(@_biGeohash) AS tuple
          IF (@biCenter <> @_biGeohash)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biCenter [' + CAST(@biCenter AS VARCHAR(MAX)) + '] is not equal to @_biGeohash [' + CAST(@_biGeohash AS VARCHAR(MAX)) + ']'
          IF (@biNorth <> @_biNorth)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biNorth [' + CAST(@biNorth AS VARCHAR(MAX)) + '] is not equal to @_biNorth [' + CAST(@_biNorth AS VARCHAR(MAX)) + ']'
          IF (@biNorthE <> @_biNorthE)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biNorthE [' + CAST(@biNorthE AS VARCHAR(MAX)) + '] is not equal to @_biNorthE [' + CAST(@_biNorthE AS VARCHAR(MAX)) + ']'
          IF (@biEast <> @_biEast)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biEast [' + CAST(@biEast AS VARCHAR(MAX)) + '] is not equal to @_biEast [' + CAST(@_biEast AS VARCHAR(MAX)) + ']'
          IF (@biSouthE <> @_biSouthE)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biSouthE [' + CAST(@biSouthE AS VARCHAR(MAX)) + '] is not equal to @_biSouthE [' + CAST(@_biSouthE AS VARCHAR(MAX)) + ']'
          IF (@biSouth <> @_biSouth)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biSouth [' + CAST(@biSouth AS VARCHAR(MAX)) + '] is not equal to @_biSouth [' + CAST(@_biSouth AS VARCHAR(MAX)) + ']'
          IF (@biSouthW <> @_biSouthW)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biSouthW [' + CAST(@biSouthW AS VARCHAR(MAX)) + '] is not equal to @_biSouthW [' + CAST(@_biSouthW AS VARCHAR(MAX)) + ']'
          IF (@biWest <> @_biWest)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biWest [' + CAST(@biWest AS VARCHAR(MAX)) + '] is not equal to @_biWest [' + CAST(@_biWest AS VARCHAR(MAX)) + ']'
          IF (@biNorthW <> @_biNorthW)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biNorthW [' + CAST(@biNorthW AS VARCHAR(MAX)) + '] is not equal to @_biNorthW [' + CAST(@_biNorthW AS VARCHAR(MAX)) + ']'
          IF (@failedConditionsNeighbors <> '')
            BEGIN
              SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Auxiliary.neighborsOfBigintWithSelfAsRow>' + @failedConditionsNeighbors
              SET @failedConditionsNeighbors = ''
            END
          SELECT  @biNorth   = tuple.biNorth,
                  @biNorthE  = tuple.biNorthEast,
                  @biEast    = tuple.biEast,
                  @biSouthE  = tuple.biSouthEast,
                  @biSouth   = tuple.biSouth,
                  @biSouthW  = tuple.biSouthWest,
                  @biWest    = tuple.biWest,
                  @biNorthW  = tuple.biNorthWest
            FROM (
                  SELECT  MAX(biNorth)     AS biNorth,
                          MAX(biNorthEast) AS biNorthEast,
                          MAX(biEast)      AS biEast,
                          MAX(biSouthEast) AS biSouthEast,
                          MAX(biSouth)     AS biSouth,
                          MAX(biSouthWest) AS biSouthWest,
                          MAX(biWest)      AS biWest,
                          MAX(biNorthWest) AS biNorthWest
                    FROM (
                          SELECT  '1' AS groupByAnchor,
                                  CASE WHEN (tiNeighborOrientationEnumId = 0) THEN biGeohash ELSE NULL END AS biNorth,
                                  CASE WHEN (tiNeighborOrientationEnumId = 1) THEN biGeohash ELSE NULL END AS biNorthEast,
                                  CASE WHEN (tiNeighborOrientationEnumId = 2) THEN biGeohash ELSE NULL END AS biEast,
                                  CASE WHEN (tiNeighborOrientationEnumId = 3) THEN biGeohash ELSE NULL END AS biSouthEast,
                                  CASE WHEN (tiNeighborOrientationEnumId = 4) THEN biGeohash ELSE NULL END AS biSouth,
                                  CASE WHEN (tiNeighborOrientationEnumId = 5) THEN biGeohash ELSE NULL END AS biSouthWest,
                                  CASE WHEN (tiNeighborOrientationEnumId = 6) THEN biGeohash ELSE NULL END AS biWest,
                                  CASE WHEN (tiNeighborOrientationEnumId = 7) THEN biGeohash ELSE NULL END AS biNorthWest
                            FROM qalGeohash_Auxiliary.neighborsOfBigintAsTableCheck(@_biGeohash, 0)
                         ) AS asRowAndColumns
                   GROUP BY groupByAnchor
                 ) AS tuple
          IF (@biNorth <> @_biNorth)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biNorth [' + CAST(@biNorth AS VARCHAR(MAX)) + '] is not equal to @_biNorth [' + CAST(@_biNorth AS VARCHAR(MAX)) + ']'
          IF (@biNorthE <> @_biNorthE)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biNorthE [' + CAST(@biNorthE AS VARCHAR(MAX)) + '] is not equal to @_biNorthE [' + CAST(@_biNorthE AS VARCHAR(MAX)) + ']'
          IF (@biEast <> @_biEast)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biEast [' + CAST(@biEast AS VARCHAR(MAX)) + '] is not equal to @_biEast [' + CAST(@_biEast AS VARCHAR(MAX)) + ']'
          IF (@biSouthE <> @_biSouthE)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biSouthE [' + CAST(@biSouthE AS VARCHAR(MAX)) + '] is not equal to @_biSouthE [' + CAST(@_biSouthE AS VARCHAR(MAX)) + ']'
          IF (@biSouth <> @_biSouth)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biSouth [' + CAST(@biSouth AS VARCHAR(MAX)) + '] is not equal to @_biSouth [' + CAST(@_biSouth AS VARCHAR(MAX)) + ']'
          IF (@biSouthW <> @_biSouthW)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biSouthW [' + CAST(@biSouthW AS VARCHAR(MAX)) + '] is not equal to @_biSouthW [' + CAST(@_biSouthW AS VARCHAR(MAX)) + ']'
          IF (@biWest <> @_biWest)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biWest [' + CAST(@biWest AS VARCHAR(MAX)) + '] is not equal to @_biWest [' + CAST(@_biWest AS VARCHAR(MAX)) + ']'
          IF (@biNorthW <> @_biNorthW)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biNorthW [' + CAST(@biNorthW AS VARCHAR(MAX)) + '] is not equal to @_biNorthW [' + CAST(@_biNorthW AS VARCHAR(MAX)) + ']'
          IF (@failedConditionsNeighbors <> '')
            BEGIN
              SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Auxiliary.neighborsOfBigintAsTable - excluding self>' + @failedConditionsNeighbors
              SET @failedConditionsNeighbors = ''
            END
          SELECT  @biCenter  = tuple.biCenter,
                  @biNorth   = tuple.biNorth,
                  @biNorthE  = tuple.biNorthEast,
                  @biEast    = tuple.biEast,
                  @biSouthE  = tuple.biSouthEast,
                  @biSouth   = tuple.biSouth,
                  @biSouthW  = tuple.biSouthWest,
                  @biWest    = tuple.biWest,
                  @biNorthW  = tuple.biNorthWest
            FROM (
                  SELECT  MAX(biCenter)    AS biCenter,
                          MAX(biNorth)     AS biNorth,
                          MAX(biNorthEast) AS biNorthEast,
                          MAX(biEast)      AS biEast,
                          MAX(biSouthEast) AS biSouthEast,
                          MAX(biSouth)     AS biSouth,
                          MAX(biSouthWest) AS biSouthWest,
                          MAX(biWest)      AS biWest,
                          MAX(biNorthWest) AS biNorthWest
                    FROM (
                          SELECT  '1' AS groupByAnchor,
                                  CASE WHEN (tiNeighborOrientationEnumId = 8) THEN biGeohash ELSE NULL END AS biCenter,
                                  CASE WHEN (tiNeighborOrientationEnumId = 0) THEN biGeohash ELSE NULL END AS biNorth,
                                  CASE WHEN (tiNeighborOrientationEnumId = 1) THEN biGeohash ELSE NULL END AS biNorthEast,
                                  CASE WHEN (tiNeighborOrientationEnumId = 2) THEN biGeohash ELSE NULL END AS biEast,
                                  CASE WHEN (tiNeighborOrientationEnumId = 3) THEN biGeohash ELSE NULL END AS biSouthEast,
                                  CASE WHEN (tiNeighborOrientationEnumId = 4) THEN biGeohash ELSE NULL END AS biSouth,
                                  CASE WHEN (tiNeighborOrientationEnumId = 5) THEN biGeohash ELSE NULL END AS biSouthWest,
                                  CASE WHEN (tiNeighborOrientationEnumId = 6) THEN biGeohash ELSE NULL END AS biWest,
                                  CASE WHEN (tiNeighborOrientationEnumId = 7) THEN biGeohash ELSE NULL END AS biNorthWest
                            FROM qalGeohash_Auxiliary.neighborsOfBigintAsTableCheck(@_biGeohash, 1)
                         ) AS asRowAndColumns
                   GROUP BY groupByAnchor
                 ) AS tuple
          IF (@biCenter <> @_biGeohash)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biCenter [' + CAST(@biCenter AS VARCHAR(MAX)) + '] is not equal to @_biGeohash [' + CAST(@_biGeohash AS VARCHAR(MAX)) + ']'
          IF (@biNorth <> @_biNorth)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biNorth [' + CAST(@biNorth AS VARCHAR(MAX)) + '] is not equal to @_biNorth [' + CAST(@_biNorth AS VARCHAR(MAX)) + ']'
          IF (@biNorthE <> @_biNorthE)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biNorthE [' + CAST(@biNorthE AS VARCHAR(MAX)) + '] is not equal to @_biNorthE [' + CAST(@_biNorthE AS VARCHAR(MAX)) + ']'
          IF (@biEast <> @_biEast)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biEast [' + CAST(@biEast AS VARCHAR(MAX)) + '] is not equal to @_biEast [' + CAST(@_biEast AS VARCHAR(MAX)) + ']'
          IF (@biSouthE <> @_biSouthE)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biSouthE [' + CAST(@biSouthE AS VARCHAR(MAX)) + '] is not equal to @_biSouthE [' + CAST(@_biSouthE AS VARCHAR(MAX)) + ']'
          IF (@biSouth <> @_biSouth)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biSouth [' + CAST(@biSouth AS VARCHAR(MAX)) + '] is not equal to @_biSouth [' + CAST(@_biSouth AS VARCHAR(MAX)) + ']'
          IF (@biSouthW <> @_biSouthW)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biSouthW [' + CAST(@biSouthW AS VARCHAR(MAX)) + '] is not equal to @_biSouthW [' + CAST(@_biSouthW AS VARCHAR(MAX)) + ']'
          IF (@biWest <> @_biWest)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biWest [' + CAST(@biWest AS VARCHAR(MAX)) + '] is not equal to @_biWest [' + CAST(@_biWest AS VARCHAR(MAX)) + ']'
          IF (@biNorthW <> @_biNorthW)
            SET @failedConditionsNeighbors = @failedConditionsNeighbors + '|@biNorthW [' + CAST(@biNorthW AS VARCHAR(MAX)) + '] is not equal to @_biNorthW [' + CAST(@_biNorthW AS VARCHAR(MAX)) + ']'
          IF (@failedConditionsNeighbors <> '')
            SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Auxiliary.neighborsOfBigintAsTable - including self>' + @failedConditionsNeighbors
          --TODO: Implement for
          --        - changeBitsWide
          --        - changeCharsWide
        END

      --Return the results
      IF (@failedConditions_ = '')
        RETURN NULL
      RETURN @failedConditions_
    END --qalGeohash_Test_CheckCoheranceAcrossFunctions.auxiliary
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Test_CheckCoheranceAcrossFunctions].[geography] (
  @_biGeohash   BIGINT -- Driving value for all other function validation
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @failedConditions_ VARCHAR(MAX) = ''

      DECLARE @failedPreconditions_biGeohash   VARCHAR(MAX) = qalGeohash_Preconditions.checkBigint(@_biGeohash)
      IF (@failedPreconditions_biGeohash IS NOT NULL)
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkBigint>' + @failedPreconditions_biGeohash
      IF (@failedConditions_ = '')
        BEGIN
          DECLARE @failedPreconditionsGeography VARCHAR(MAX) = ''
          DECLARE @tiBitsWide TINYINT = qalGeohash_Main.extractBitsWideCheck(@_biGeohash)
          DECLARE @gcPoint_biGeohash geography = qalGeohash_Geography.expandBigintIntoGeographyPointCheck(@_biGeohash)
          DECLARE @biGeohashFromGcPoint BIGINT = qalGeohash_Geography.reduceGeographyPointIntoBigintCheck(@gcPoint_biGeohash, @tiBitsWide)
          IF (@biGeohashFromGcPoint <> @_biGeohash)
            SET @failedPreconditionsGeography = @failedPreconditionsGeography + '|@biGeohashFromGcPoint [' + CAST(@biGeohashFromGcPoint AS VARCHAR(MAX)) + '] is not equal to @_biGeohash [' + CAST(@_biGeohash AS VARCHAR(MAX)) + ']'
          DECLARE @gcPointBiGeohashFromGcPoint geography = qalGeohash_Geography.expandBigintIntoGeographyPointCheck(@biGeohashFromGcPoint)
          IF (@gcPointBiGeohashFromGcPoint.Long <> @gcPoint_biGeohash.Long)
            SET @failedPreconditionsGeography = @failedPreconditionsGeography + '|@gcPointBiGeohashFromGcPoint.Long [' + CAST(@gcPointBiGeohashFromGcPoint.Long AS VARCHAR(MAX)) + '] is not equal to @gcPoint_biGeohash.Long [' + CAST(@gcPoint_biGeohash.Long AS VARCHAR(MAX)) + ']'
          IF (@gcPointBiGeohashFromGcPoint.Lat <> @gcPoint_biGeohash.Lat)
            SET @failedPreconditionsGeography = @failedPreconditionsGeography + '|@gcPointBiGeohashFromGcPoint.Lat [' + CAST(@gcPointBiGeohashFromGcPoint.Lat AS VARCHAR(MAX)) + '] is not equal to @gcPoint_biGeohash.Lat [' + CAST(@gcPoint_biGeohash.Lat AS VARCHAR(MAX)) + ']'
          IF (@failedPreconditionsGeography <> '')
            BEGIN
              SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Geography.expandAndReduce>' + @failedPreconditionsGeography
              SET @failedPreconditionsGeography = ''
            END
          DECLARE @biBigint9s0000000000 BIGINT = 5620492334958379019
          DECLARE @gc9s0000000000 geography = qalGeohash_Geography.expandBigintIntoGeographyPointCheck(@biBigint9s0000000000)
          DECLARE @dimA FLOAT = qalGeohash_Geography.distanceInMetersBetweenBigintsCheck(@_biGeohash, @biBigint9s0000000000)
          DECLARE @dimB FLOAT = qalGeohash_Geography.distanceInMetersBetweenBigintsCheck(@biBigint9s0000000000, @_biGeohash)
          DECLARE @fMaxThreshold FLOAT = 0.001 --Anything under a millimeter is acceptable
          IF (ABS(@dimA - @dimB) > @fMaxThreshold)
            SET @failedPreconditionsGeography = @failedPreconditionsGeography + '|<qalGeohash_Geography.distanceInMetersBetweenBigints> - @dimA [' + CAST(@dimA AS VARCHAR(MAX)) + '] exceeded the max threshold [' + CAST(@fMaxThreshold AS VARCHAR(MAX)) + '] from @dimB [' + CAST(@dimB AS VARCHAR(MAX)) + '] - ABS(@dimA - @dimB) [' + CAST(ABS(@dimA - @dimB) AS VARCHAR(MAX)) + ']'
          SET @dimB = qalGeohash_Geography.distanceInMetersBetweenBigintAndGeographyPointCheck(@_biGeohash, @gc9s0000000000)
          IF (ABS(@dimA - @dimB) > @fMaxThreshold)
            SET @failedPreconditionsGeography = @failedPreconditionsGeography + '|<qalGeohash_Geography.distanceInMetersBetweenBigintAndGeographyPoint - A> - @dimA [' + CAST(@dimA AS VARCHAR(MAX)) + '] exceeded the max threshold [' + CAST(@fMaxThreshold AS VARCHAR(MAX)) + '] from @dimB [' + CAST(@dimB AS VARCHAR(MAX)) + '] - ABS(@dimA - @dimB) [' + CAST(ABS(@dimA - @dimB) AS VARCHAR(MAX)) + ']'
          SET @dimB = qalGeohash_Geography.distanceInMetersBetweenBigintAndGeographyPointCheck(@biBigint9s0000000000, @gcPoint_biGeohash)
          IF (ABS(@dimA - @dimB) > @fMaxThreshold)
            SET @failedPreconditionsGeography = @failedPreconditionsGeography + '|<qalGeohash_Geography.distanceInMetersBetweenBigintAndGeographyPoint - B> - @dimA [' + CAST(@dimA AS VARCHAR(MAX)) + '] exceeded the max threshold [' + CAST(@fMaxThreshold AS VARCHAR(MAX)) + '] from @dimB [' + CAST(@dimB AS VARCHAR(MAX)) + '] - ABS(@dimA - @dimB) [' + CAST(ABS(@dimA - @dimB) AS VARCHAR(MAX)) + ']'
          IF (@failedPreconditionsGeography <> '')
            SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Geography.distanceInMeters>' + @failedPreconditionsGeography
        END

      --Return the results
      IF (@failedConditions_ = '')
        RETURN NULL
      RETURN @failedConditions_
    END --qalGeohash_Test_CheckCoheranceAcrossFunctions.geography
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
