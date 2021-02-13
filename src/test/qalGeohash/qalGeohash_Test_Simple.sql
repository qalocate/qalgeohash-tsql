/* ---------.---------.---------.---------.---------.---------.--------.---------.---------.---------.---------.--------- *\
-- ** Part Of:     QA Locate Geohash API                                                                                     **
-- ** URL:         http://www.qalocate.com                                                                                   **
-- ** File:                                                                                                                  **
-- **   Name:      qalGeohash_Test_Simple.sql                                                                                **
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

--NOTE: None of these functions are focused on the individual functions, per se. For tests focused entirely on a particular
--      functions verification, see the positive/negative test cases

--NOTE: Uncomment out the next two lines when needing to initialize the schema (when loading the very first time)
--CREATE SCHEMA qalGeohash_Test_Simple
--GO

DROP FUNCTION IF EXISTS [qalGeohash_Test_Simple].[preconditions]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Test_Simple].[main]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Test_Simple].[dms]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Test_Simple].[auxiliary]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Test_Simple].[geography]
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Test_Simple].[preconditions] (
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @failedConditions_ VARCHAR(MAX) = ''

      -- checkBigint
      DECLARE @failedConditions VARCHAR(MAX) = ''
      IF (qalGeohash_Preconditions.checkBigint(NULL) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _biGeohash equal to NULL'
      IF (qalGeohash_Preconditions.checkBigint(0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _biGeohash equal to 0'
      IF (qalGeohash_Preconditions.checkBigint(11) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _biGeohash equal to 11'
      IF (qalGeohash_Preconditions.checkBigint(12) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'call to checkBitsWide failed'
      --No test for checkSans as there should be no means to pass an invalid value if the prior code works correcly (meaning I wasn't able to create a value that made here and then failed)
      IF (qalGeohash_Preconditions.checkBigint(-1) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _biGeohash with a biGeohashSans part exceeding the maximum value allowed by the bits wide part'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkBigint>' + @failedConditions

      -- checkSans
      SET @failedConditions = ''
      IF (qalGeohash_Preconditions.checkSans(NULL) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _biGeohashSans equal to NULL'
      IF (qalGeohash_Preconditions.checkSans(-1) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _biGeohashSans equal to a value less than 0 [-1]'
      IF (qalGeohash_Preconditions.checkSans(-2) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _biGeohashSans equal to a value less than 0 [-2]'
      IF (qalGeohash_Preconditions.checkSans(-10000) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _biGeohashSans equal to a value less than 0 [-10000]'
      IF (qalGeohash_Preconditions.checkSans(0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _biGeohashSans equal to 0'
      IF (qalGeohash_Preconditions.checkSans(1) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _biGeohashSans equal to 1'
      IF (qalGeohash_Preconditions.checkSans(10000) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _biGeohashSans equal to 10000'
      DECLARE @twoToThe59th BIGINT = 576460752303423488
      IF (qalGeohash_Preconditions.checkSans(@twoToThe59th) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _biGeohashSans equal to @twoToThe59th [' + CAST(@twoToThe59th AS VARCHAR(MAX)) + ']'
      IF (qalGeohash_Preconditions.checkSans(@twoToThe59th + 1) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _biGeohashSans equal to @twoToThe59th + 1 [' + CAST((@twoToThe59th + 1) AS VARCHAR(MAX)) + ']'
      IF (qalGeohash_Preconditions.checkSans((@twoToThe59th * 2) - 1) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _biGeohashSans equal to (@twoToThe59th * 2) - 1 [' + CAST(((@twoToThe59th * 2) - 1) AS VARCHAR(MAX)) + ']'
      IF (qalGeohash_Preconditions.checkSans(@twoToThe59th * 2) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _biGeohashSans equal to @twoToThe59th * 2 [' + CAST((@twoToThe59th * 2) AS VARCHAR(MAX)) + ']'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkSans>' + @failedConditions

      -- checkBitsWide
      SET @failedConditions = ''
      IF (qalGeohash_Preconditions.checkBitsWide(NULL) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiBitsWide equal to NULL'
      --TINYINT (0..255 inclusive) cannot be a negative value
      IF (qalGeohash_Preconditions.checkBitsWide(5) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiBitsWide equal to 5'
      IF (qalGeohash_Preconditions.checkBitsWide(10) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiBitsWide equal to 10'
      IF (qalGeohash_Preconditions.checkBitsWide(15) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiBitsWide equal to 15'
      IF (qalGeohash_Preconditions.checkBitsWide(20) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiBitsWide equal to 20'
      IF (qalGeohash_Preconditions.checkBitsWide(25) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiBitsWide equal to 25'
      IF (qalGeohash_Preconditions.checkBitsWide(30) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiBitsWide equal to 30'
      IF (qalGeohash_Preconditions.checkBitsWide(35) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiBitsWide equal to 35'
      IF (qalGeohash_Preconditions.checkBitsWide(40) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiBitsWide equal to 40'
      IF (qalGeohash_Preconditions.checkBitsWide(45) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiBitsWide equal to 45'
      IF (qalGeohash_Preconditions.checkBitsWide(50) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiBitsWide equal to 50'
      IF (qalGeohash_Preconditions.checkBitsWide(55) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiBitsWide equal to 55'
      IF (qalGeohash_Preconditions.checkBitsWide(60) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiBitsWide equal to 60'
      IF (qalGeohash_Preconditions.checkBitsWide(0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiBitsWide equal to 0'
      IF (qalGeohash_Preconditions.checkBitsWide(1) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiBitsWide equal to 1'
      IF (qalGeohash_Preconditions.checkBitsWide(2) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiBitsWide equal to 2'
      IF (qalGeohash_Preconditions.checkBitsWide(3) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiBitsWide equal to 3'
      IF (qalGeohash_Preconditions.checkBitsWide(4) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiBitsWide equal to 4'
      IF (qalGeohash_Preconditions.checkBitsWide(6) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiBitsWide equal to 6'
      IF (qalGeohash_Preconditions.checkBitsWide(59) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiBitsWide equal to 59'
      IF (qalGeohash_Preconditions.checkBitsWide(61) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiBitsWide equal to 61'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkBitsWide>' + @failedConditions

      -- checkL_itude
      SET @failedConditions = ''
      IF (qalGeohash_Preconditions.checkL_itude(NULL, 0.0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _bIsLatitude equal to NULL'
      IF (qalGeohash_Preconditions.checkL_itude(0, NULL) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _dcL_itude (Longitude) equal to NULL'
      IF (qalGeohash_Preconditions.checkL_itude(1, NULL) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _dcL_itude (Latitude) equal to NULL'
      IF (qalGeohash_Preconditions.checkL_itude(0, -180.0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcL_itude (Longitude) equal to -180.0'
      IF (qalGeohash_Preconditions.checkL_itude(0, 180.0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcL_itude (Longitude) equal to 180.0'
      IF (qalGeohash_Preconditions.checkL_itude(0, -179.999999999) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcL_itude (Longitude) equal to -179.999999999'
      IF (qalGeohash_Preconditions.checkL_itude(0, 179.999999999) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcL_itude (Longitude) equal to 179.999999999'
      IF (qalGeohash_Preconditions.checkL_itude(0, 0.0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcL_itude (Longitude) equal to 0.0'
      IF (qalGeohash_Preconditions.checkL_itude(1, -90.1) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _dcL_itude (Longitude) equal to -180.1'
      IF (qalGeohash_Preconditions.checkL_itude(1, 90.1) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _dcL_itude (Longitude) equal to 180.1'
      IF (qalGeohash_Preconditions.checkL_itude(1, -90.0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcL_itude (Latitude) equal to -180.0'
      IF (qalGeohash_Preconditions.checkL_itude(1, 90.0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcL_itude (Latitude) equal to 180.0'
      IF (qalGeohash_Preconditions.checkL_itude(1, -79.999999999) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcL_itude (Latitude) equal to -179.999999999'
      IF (qalGeohash_Preconditions.checkL_itude(1, 79.999999999) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcL_itude (Latitude) equal to 179.999999999'
      IF (qalGeohash_Preconditions.checkL_itude(1, 0.0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcL_itude (Latitude) equal to 0.0'
      IF (qalGeohash_Preconditions.checkL_itude(1, -90.1) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _dcL_itude (Latitude) equal to -90.1'
      IF (qalGeohash_Preconditions.checkL_itude(1, 90.1) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _dcL_itude (Latitude) equal to 90.1'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkL_itude>' + @failedConditions

      -- checkVarchar
      SET @failedConditions = ''
      IF (qalGeohash_Preconditions.checkVarchar(NULL) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash equal to NULL'
      IF (qalGeohash_Preconditions.checkVarchar('') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash equal to '''''
      IF (qalGeohash_Preconditions.checkVarchar('0') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _vcGeohash equal to 0'
      IF (qalGeohash_Preconditions.checkVarchar('B') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _vcGeohash equal to B'
      IF (qalGeohash_Preconditions.checkVarchar('b') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _vcGeohash equal to b'
      IF (qalGeohash_Preconditions.checkVarchar('a') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character a'
      IF (qalGeohash_Preconditions.checkVarchar('i') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character i'
      IF (qalGeohash_Preconditions.checkVarchar('l') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character l'
      IF (qalGeohash_Preconditions.checkVarchar('o') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character o'
      IF (qalGeohash_Preconditions.checkVarchar('0a') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character a'
      IF (qalGeohash_Preconditions.checkVarchar('0i') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character i'
      IF (qalGeohash_Preconditions.checkVarchar('0l') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character l'
      IF (qalGeohash_Preconditions.checkVarchar('0o') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character o'
      IF (qalGeohash_Preconditions.checkVarchar('a0') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character a'
      IF (qalGeohash_Preconditions.checkVarchar('i0') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character i'
      IF (qalGeohash_Preconditions.checkVarchar('l0') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character l'
      IF (qalGeohash_Preconditions.checkVarchar('o0') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character o'
      IF (qalGeohash_Preconditions.checkVarchar('a0i') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character a and i'
      IF (qalGeohash_Preconditions.checkVarchar('i0l') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character i and l'
      IF (qalGeohash_Preconditions.checkVarchar('l0o') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character l and o'
      IF (qalGeohash_Preconditions.checkVarchar('o0a') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _vcGeohash containing illegal character o and a'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkVarchar>' + @failedConditions

      -- checkDms
      SET @failedConditions = ''
      IF (qalGeohash_Preconditions.checkDms(NULL, 0, 0, 0.0, 0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _bIsLatitude equal to NULL'
      IF (qalGeohash_Preconditions.checkDms(0, NULL, 0, 0.0, 0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiDegreesAbsolute equal to NULL'
      IF (qalGeohash_Preconditions.checkDms(0, 0, NULL, 0.0, 0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiMinutes equal to NULL'
      IF (qalGeohash_Preconditions.checkDms(0, 0, 0, NULL, 0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _dcSeconds equal to NULL'
      IF (qalGeohash_Preconditions.checkDms(0, 0, 0, 0.0, NULL) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _bIsNegative equal to NULL'
      IF (qalGeohash_Preconditions.checkDms(0, 0, 0, 0.0, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiDegreesAbsolute (Longitude) equal to 0'
      IF (qalGeohash_Preconditions.checkDms(0, 180, 0, 0.0, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiDegreesAbsolute (Longitude) equal to 180'
      IF (qalGeohash_Preconditions.checkDms(0, 181, 0, 0.0, 0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiDegreesAbsolute (Longitude) equal to 181'
      IF (qalGeohash_Preconditions.checkDms(0, 0, 0, 0.0, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiMinutes (Longitude) equal to 0'
      IF (qalGeohash_Preconditions.checkDms(0, 0, 59, 0.0, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiMinutes (Longitude) equal to 59'
      IF (qalGeohash_Preconditions.checkDms(0, 0, 60, 0.0, 0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiMinutes (Longitude) equal to 60'
      IF (qalGeohash_Preconditions.checkDms(0, 0, 0, -0.000001, 0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _dcSeconds (Longitude) equal to -0.000001'
      IF (qalGeohash_Preconditions.checkDms(0, 0, 0, 0.0, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcSeconds (Longitude) equal to 0.0'
      IF (qalGeohash_Preconditions.checkDms(0, 0, 0, 0.000001, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcSeconds (Longitude) equal to 0.000001'
      IF (qalGeohash_Preconditions.checkDms(0, 0, 0, 59.999999, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcSeconds (Longitude) equal to 59.999999'
      IF (qalGeohash_Preconditions.checkDms(0, 0, 0, 60.0, 0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _dcSeconds (Longitude) equal to 60.0'
      IF (qalGeohash_Preconditions.checkDms(1, 0, 0, 0.0, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiDegreesAbsolute (Latitude) equal to 0'
      IF (qalGeohash_Preconditions.checkDms(1, 90, 0, 0.0, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiDegreesAbsolute (Latitude) equal to 90'
      IF (qalGeohash_Preconditions.checkDms(1, 91, 0, 0.0, 0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiDegreesAbsolute (Latitude) equal to 91'
      IF (qalGeohash_Preconditions.checkDms(1, 0, 0, 0.0, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiMinutes (Latitude) equal to 0'
      IF (qalGeohash_Preconditions.checkDms(1, 0, 59, 0.0, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiMinutes (Latitude) equal to 59'
      IF (qalGeohash_Preconditions.checkDms(1, 0, 60, 0.0, 0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiMinutes (Latitude) equal to 60'
      IF (qalGeohash_Preconditions.checkDms(1, 0, 0, -0.000001, 0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _dcSeconds (Latitude) equal to -0.000001'
      IF (qalGeohash_Preconditions.checkDms(1, 0, 0, 0.0, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcSeconds (Latitude) equal to 0.0'
      IF (qalGeohash_Preconditions.checkDms(1, 0, 0, 0.000001, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcSeconds (Latitude) equal to 0.000001'
      IF (qalGeohash_Preconditions.checkDms(1, 0, 0, 59.999999, 0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _dcSeconds (Latitude) equal to 59.999999'
      IF (qalGeohash_Preconditions.checkDms(1, 0, 0, 60.0, 0) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _dcSeconds (Latitude) equal to 60.0'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkDms>' + @failedConditions

      -- checkDmsDirectional
      SET @failedConditions = ''
      IF (qalGeohash_Preconditions.checkDmsDirectional(NULL) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _chDirectional equal to NULL'
      IF (qalGeohash_Preconditions.checkDmsDirectional('E') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chDirectional equal to E'
      IF (qalGeohash_Preconditions.checkDmsDirectional('W') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chDirectional equal to W'
      IF (qalGeohash_Preconditions.checkDmsDirectional('N') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chDirectional equal to N'
      IF (qalGeohash_Preconditions.checkDmsDirectional('S') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chDirectional equal to S'
      IF (qalGeohash_Preconditions.checkDmsDirectional('e') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chDirectional equal to e'
      IF (qalGeohash_Preconditions.checkDmsDirectional('a') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _chDirectional equal to a'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkDmsDirectional>' + @failedConditions

      -- checkNeighborOrientationEnumId
      SET @failedConditions = ''
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumId(NULL) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiNeighborOrientationEnumId equal to NULL'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumId(0) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiNeighborOrientationEnumId equal to 0'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumId(1) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiNeighborOrientationEnumId equal to 1'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumId(2) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiNeighborOrientationEnumId equal to 2'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumId(3) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiNeighborOrientationEnumId equal to 3'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumId(4) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiNeighborOrientationEnumId equal to 4'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumId(5) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiNeighborOrientationEnumId equal to 5'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumId(6) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiNeighborOrientationEnumId equal to 6'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumId(7) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiNeighborOrientationEnumId equal to 7'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumId(8) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _tiNeighborOrientationEnumId equal to 8'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumId(9) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _tiNeighborOrientationEnumId equal to 9'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkNeighborOrientationEnumId>' + @failedConditions

      -- checkNeighborOrientationEnumName
      SET @failedConditions = ''
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumName(NULL) IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _chNeighborOrientationEnumName equal to NULL'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumName('N') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chNeighborOrientationEnumName equal to N'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumName('NE') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chNeighborOrientationEnumName equal to NE'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumName('E') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chNeighborOrientationEnumName equal to E'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumName('SE') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chNeighborOrientationEnumName equal to SE'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumName('S') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chNeighborOrientationEnumName equal to S'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumName('SW') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chNeighborOrientationEnumName equal to SW'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumName('W') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chNeighborOrientationEnumName equal to W'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumName('NW') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chNeighborOrientationEnumName equal to NW'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumName('n') IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to allow _chNeighborOrientationEnumName equal to n'
      IF (qalGeohash_Preconditions.checkNeighborOrientationEnumName('a') IS NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to prevent _chNeighborOrientationEnumName equal to a'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Preconditions.checkNeighborOrientationEnumName>' + @failedConditions

      --Return the results
      IF (@failedConditions_ = '')
        RETURN NULL
      RETURN @failedConditions_
    END --qalGeohash_Test_Simple.preconditions
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Test_Simple].[main] (
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @failedConditions_ VARCHAR(MAX) = ''

      -- extractCharsWide
      DECLARE @failedConditions VARCHAR(MAX) = ''
      IF (qalGeohash_Main.extractCharsWideCheck(NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed NULL'
      IF (qalGeohash_Main.extractCharsWideCheck(0) <> 1)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 1 when passed 0'
      IF (qalGeohash_Main.extractCharsWideCheck(1) <> 2)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 2 when passed 1'
      IF (qalGeohash_Main.extractCharsWideCheck(2) <> 3)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 3 when passed 2'
      IF (qalGeohash_Main.extractCharsWideCheck(3) <> 4)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 4 when passed 3'
      IF (qalGeohash_Main.extractCharsWideCheck(4) <> 5)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 5 when passed 4'
      IF (qalGeohash_Main.extractCharsWideCheck(5) <> 6)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 6 when passed 5'
      IF (qalGeohash_Main.extractCharsWideCheck(6) <> 7)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 7 when passed 6'
      IF (qalGeohash_Main.extractCharsWideCheck(7) <> 8)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 8 when passed 7'
      IF (qalGeohash_Main.extractCharsWideCheck(8) <> 9)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 9 when passedn 8'
      IF (qalGeohash_Main.extractCharsWideCheck(9) <> 10)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 10 when passed 9'
      IF (qalGeohash_Main.extractCharsWideCheck(10) <> 11)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 11 when passed 10'
      IF (qalGeohash_Main.extractCharsWideCheck(11) <> 12)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 12 when passed 11'
      IF (qalGeohash_Main.extractCharsWideCheck(12) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed 12'
      IF (qalGeohash_Main.extractCharsWideCheck(13) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed 13'
      IF (qalGeohash_Main.extractCharsWideCheck(14) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed 14'
      IF (qalGeohash_Main.extractCharsWideCheck(15) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed 15'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.extractCharsWide>' + @failedConditions

      -- extractSans
      SET @failedConditions = ""
      IF (qalGeohash_Main.extractSansCheck(NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed NULL'
      IF (qalGeohash_Main.extractSansCheck(0) <> 0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 0 when passed 0'
      IF (qalGeohash_Main.extractSansCheck(16) <> 1)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 1 when passed 16'
      --TODO: Unable to think of any not covered by the tests in qalGeohash_Test_CheckCoheranceAcrossFunctions.main
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.extractSans>' + @failedConditions

      -- extractBitsWide
      SET @failedConditions = ""
      IF (qalGeohash_Main.extractBitsWideCheck(NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed NULL'
      IF (qalGeohash_Main.extractBitsWideCheck(0) <> 5)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 5 when passed 0'
      IF (qalGeohash_Main.extractBitsWideCheck(1) <> 10)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 10 when passed 1'
      IF (qalGeohash_Main.extractBitsWideCheck(2) <> 15)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 15 when passed 2'
      IF (qalGeohash_Main.extractBitsWideCheck(3) <> 20)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 20 when passed 3'
      IF (qalGeohash_Main.extractBitsWideCheck(4) <> 25)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 25 when passed 4'
      IF (qalGeohash_Main.extractBitsWideCheck(5) <> 30)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 30 when passed 5'
      IF (qalGeohash_Main.extractBitsWideCheck(6) <> 35)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 35 when passed 6'
      IF (qalGeohash_Main.extractBitsWideCheck(7) <> 40)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 40 when passed 7'
      IF (qalGeohash_Main.extractBitsWideCheck(8) <> 45)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 45 when passed 8'
      IF (qalGeohash_Main.extractBitsWideCheck(9) <> 50)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 50 when passed 9'
      IF (qalGeohash_Main.extractBitsWideCheck(10) <> 55)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 55 when passed 10'
      IF (qalGeohash_Main.extractBitsWideCheck(11) <> 60)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 60 when passed 11'
      IF (qalGeohash_Main.extractBitsWideCheck(12) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed 12'
      IF (qalGeohash_Main.extractBitsWideCheck(13) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed 13'
      IF (qalGeohash_Main.extractBitsWideCheck(14) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed 14'
      IF (qalGeohash_Main.extractBitsWideCheck(15) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed 15'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.extractBitsWide>' + @failedConditions

      -- encodeBigint
      SET @failedConditions = ""
      IF (qalGeohash_Main.encodeBigintCheck(NULL, NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed (NULL, NULL)'
      IF (qalGeohash_Main.encodeBigintCheck(0, NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed (0, NULL)'
      IF (qalGeohash_Main.encodeBigintCheck(NULL, 5) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed (NULL, 5)'
      IF (qalGeohash_Main.encodeBigintCheck(0, 5) <> 0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 0 when passed (0, 5)'
      --TODO: Unable to think of any not covered by the tests in qalGeohash_Test_CheckCoheranceAcrossFunctions.main
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.encodeBigint>' + @failedConditions

      -- decodeBigint
      SET @failedConditions = ""
      DECLARE @rowCount TINYINT = NULL
      SELECT @rowCount = COUNT(tuple.*)
        FROM qalGeohash_Main.decodeBigintCheck(NULL) AS tuple
      IF (@rowCount <> 0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return row count of 0 when passed NULL'
      DECLARE @biGeohashSans BIGINT  = NULL
      DECLARE @tiBitsWide    TINYINT = NULL
      SELECT @biGeohashSans = tuple.biGeohashSans
           , @tiBitsWide    = tuple.tiBitsWide
        FROM qalGeohash_Main.decodeBigintCheck(0) AS tuple
      IF (@biGeohashSans <> 0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return @biGeohashSans equal to 0 when passed 0'
      IF (@tiBitsWide <> 5)
        SET @failedConditions = @failedConditions + '|' + 'failed to return @tiBitsWide equal to 5 when passed 0'
      --TODO: Unable to think of any not covered by the tests in qalGeohash_Test_CheckCoheranceAcrossFunctions.main
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Main.decodeBigint>' + @failedConditions

      --Return the results
      IF (@failedConditions_ = '')
        RETURN NULL
      RETURN @failedConditions_
    END --qalGeohash_Test_Simple.main
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Test_Simple].[dms] (
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @failedConditions_ VARCHAR(MAX) = ''

      -- convertDmsDirectionalToBit
      DECLARE @failedConditions VARCHAR(MAX) = ''
      IF (qalGeohash_Dms.convertDmsDirectionalToBitCheck(NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed NULL'
      IF (qalGeohash_Dms.convertDmsDirectionalToBitCheck('N') <> 0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 0 when passed N'
      IF (qalGeohash_Dms.convertDmsDirectionalToBitCheck('E') <> 0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 0 when passed E'
      IF (qalGeohash_Dms.convertDmsDirectionalToBitCheck('S') <> 1)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 1 when passed S'
      IF (qalGeohash_Dms.convertDmsDirectionalToBitCheck('W') <> 1)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 1 when passed W'
      IF (qalGeohash_Dms.convertDmsDirectionalToBitCheck('A') <> 0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 0 when passed A'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Dms.convertDmsDirectionalToBit>' + @failedConditions

      -- convertDmsToL_itude
      SET @failedConditions = ''
      IF (qalGeohash_Dms.convertDmsToL_itudeCheck(NULL, NULL, NULL, NULL, NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed (NULL, NULL, NULL, NULL, NULL)'
      IF (qalGeohash_Dms.convertDmsToL_itudeCheck(0, 0, 0, 0.0, 0) <> 0.0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 0.0 when passed (0, 0, 0, 0.0, 0)'
      --TODO: Unable to think of any not covered by the tests in qalGeohash_Test_CheckCoheranceAcrossFunctions.dms
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Dms.convertDmsToL_itude>' + @failedConditions

      -- convertL_itudeToDms
      SET @failedConditions = ''
      DECLARE @rowCount TINYINT = NULL
      SELECT @rowCount = COUNT(tuple.*)
        FROM qalGeohash_Dms.convertL_itudeToDmsCheck(NULL, NULL) AS tuple
      IF (@rowCount <> 0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return row count of 0 when passed (NULL, NULL)'
      SELECT @rowCount = COUNT(tuple.*)
        FROM qalGeohash_Dms.convertL_itudeToDmsCheck(0, NULL) AS tuple
      IF (@rowCount <> 0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return row count of 0 when passed (0, NULL)'
      SELECT @rowCount = COUNT(tuple.*)
        FROM qalGeohash_Dms.convertL_itudeToDmsCheck(NULL, 0.0) AS tuple
      IF (@rowCount <> 0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return row count of 0 when passed (NULL, 0.0)'
      DECLARE @tiDegreesAbsolute TINYINT       = NULL
      DECLARE @tiMinutes         TINYINT       = NULL
      DECLARE @dcSeconds         DECIMAL(8, 6) = NULL
      DECLARE @bIsNegative       BIT           = NULL
      SELECT @tiDegreesAbsolute = tuple.tiDegreesAbsolute
           , @tiMinutes         = tuple.tiMinutes
           , @dcSeconds         = tuple.dcSeconds
           , @bIsNegative       = tuple.bIsNegative
        FROM qalGeohash_Dms.convertL_itudeToDmsCheck(0, 0.0) AS tuple
      IF (@tiDegreesAbsolute <> 0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return @tiDegreesAbsolute equal to 0 when passed (0, 0.0)'
      IF (@tiMinutes <> 0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return @tiMinutes equal to 0 when passed (0, 0.0)'
      IF (@dcSeconds <> 0.0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return @dcSeconds equal to 0.0 when passed (0, 0.0)'
      IF (@bIsNegative <> 0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return @bIsNegative equal to 0 when passed (0, 0.0)'
      --TODO: Unable to think of any not covered by the tests in qalGeohash_Test_CheckCoheranceAcrossFunctions.main
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Dms.convertL_itudeToDms>' + @failedConditions

      --Return the results
      IF (@failedConditions_ = '')
        RETURN NULL
      RETURN @failedConditions_
    END --qalGeohash_Test_Simple.dms
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Test_Simple].[auxiliary] (
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @failedConditions_ VARCHAR(MAX) = ''

      -- convertNeighborOrientationEnumFromIdToName
      DECLARE @failedConditions VARCHAR(MAX) = ''
      IF (qalGeohash_Auxiliary.convertNeighborOrientationEnumFromIdToNameCheck(NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed NULL'
      --TODO: Add more cases
      --        - convertNeighborOrientationEnumFromNameToId
      --        - neighborOfBigint
      --        - neighborsOfBigintAsRow
      --        - neighborsOfBigintWithSelfAsRow
      --        - neighborsOfBigintAsTable
      --        - parentOfBigint
      --        - parentsOfBigint
      --        - parentOfVarchar
      --        - parentsOfVarchar
      --        - changeBitsWide
      --        - changeCharsWide
      --      Unable to think of any not covered by the tests in qalGeohash_Test_CheckCoheranceAcrossFunctions.auxiliary
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Auxiliary.convertNeighborOrientationEnumFromIdToName>' + @failedConditions

      --Return the results
      IF (@failedConditions_ = '')
        RETURN NULL
      RETURN @failedConditions_
    END --qalGeohash_Test_Simple.auxiliary
GO

-- v2021.02.04 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Test_Simple].[geography] (
) RETURNS
    VARCHAR(MAX)
  AS
    BEGIN
      --Allocate result storage
      DECLARE @failedConditions_ VARCHAR(MAX) = ''

      -- expandBigintIntoGeographyPoint
      DECLARE @failedConditions VARCHAR(MAX) = ''
      IF (qalGeohash_Geography.expandBigintIntoGeographyPointCheck(NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed NULL'
      DECLARE @gcPointS00000000000 geography = geography::Point(8.382E-08, 1.67639E-07, 4326)
      DECLARE @gcS00000000000 geography = qalGeohash_Geography.expandBigintIntoGeographyPointCheck(-4611686018427387915)
      IF ((@gcPointS00000000000.Long <> @gcS00000000000.Long) OR (@gcPointS00000000000.Lat <> @gcS00000000000.Lat))
        SET @failedConditions = @failedConditions + '|' + 'failed to return geography::Point(8.382E-08, 1.67639E-07, 4326) when passed -4611686018427387915'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Geography.expandBigintIntoGeographyPoint>' + @failedConditions
      
      -- reduceGeographyPointIntoBigintCheck
      SET @failedConditions = ''
      IF (qalGeohash_Geography.reduceGeographyPointIntoBigintCheck(NULL, 60) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed (NULL, 60)'
      IF (qalGeohash_Geography.reduceGeographyPointIntoBigintCheck(@gcPointS00000000000, NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed (@gcTempA, NULL)'
      IF (qalGeohash_Geography.reduceGeographyPointIntoBigintCheck(@gcPointS00000000000, 60) <> -4611686018427387915)
        SET @failedConditions = @failedConditions + '|' + 'failed to return -4611686018427387915 when passed geography::Point(8.382E-08, 1.67639E-07, 4326)'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Geography.reduceGeographyPointIntoBigintCheck>' + @failedConditions
      
      -- distanceInMetersBetweenBigints
      SET @failedConditions = ''
      IF (qalGeohash_Geography.distanceInMetersBetweenBigintsCheck(NULL, NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed (NULL, NULL)'
      IF (qalGeohash_Geography.distanceInMetersBetweenBigintsCheck(-4611686018427387915, NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed (-4611686018427387915, NULL)'
      IF (qalGeohash_Geography.distanceInMetersBetweenBigintsCheck(NULL, 5620492334958379019) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed (NULL, 5620492334958379019)'
      IF (qalGeohash_Geography.distanceInMetersBetweenBigintsCheck(-4611686018427387915, -4611686018427387915) <> 0.0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 0.0 when passed (-4611686018427387915, -4611686018427387915)'
      DECLARE @dim FLOAT = qalGeohash_Geography.distanceInMetersBetweenBigintsCheck(-4611686018427387915, 5620492334958379019)
      IF (@dim <> 12321940.02889006)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 12321940.02889006 when passed (-4611686018427387915, 5620492334958379019)'
      IF (qalGeohash_Geography.distanceInMetersBetweenBigintsCheck(5620492334958379019, -4611686018427387915) <> @dim)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 12321940.02889006 when passed (5620492334958379019, -4611686018427387915)'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Geography.distanceInMetersBetweenBigints>' + @failedConditions
      
      -- distanceInMetersBetweenBigintAndGeographyPoint
      SET @failedConditions = ''
      DECLARE @gcPoint9s0000000000 geography = geography::Point(22.50000008382, -112.499999832362, 4326)
      DECLARE @gc9s0000000000 geography = qalGeohash_Geography.expandBigintIntoGeographyPointCheck(5620492334958379019)
      IF (qalGeohash_Geography.distanceInMetersBetweenBigintAndGeographyPointCheck(NULL, NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed (NULL, NULL)'
      IF (qalGeohash_Geography.distanceInMetersBetweenBigintAndGeographyPointCheck(5620492334958379019, NULL) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed (5620492334958379019, NULL)'
      IF (qalGeohash_Geography.distanceInMetersBetweenBigintAndGeographyPointCheck(NULL, @gcPoint9s0000000000) IS NOT NULL)
        SET @failedConditions = @failedConditions + '|' + 'failed to return NULL when passed (NULL, @gcPoint9s0000000000)'
      IF (qalGeohash_Geography.distanceInMetersBetweenBigintAndGeographyPointCheck(5620492334958379019, @gcPoint9s0000000000) <> 0.0)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 0.0 when passed (5620492334958379019, @gcPoint9s0000000000)'
      IF (qalGeohash_Geography.distanceInMetersBetweenBigintAndGeographyPointCheck(-4611686018427387915, @gcPoint9s0000000000) <> 12321940.02889006)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 12321940.02889006 when passed (-4611686018427387915, @gcPoint9s0000000000)'
      IF (qalGeohash_Geography.distanceInMetersBetweenBigintAndGeographyPointCheck(5620492334958379019, @gcPointS00000000000) <> 12321940.02889006)
        SET @failedConditions = @failedConditions + '|' + 'failed to return 12321940.02889006 when passed (5620492334958379019, @gcPointS00000000000)'
      IF (@failedConditions <> '')
        SET @failedConditions_ = @failedConditions_ + '|<qalGeohash_Geography.distanceInMetersBetweenBigintAndGeographyPoint>' + @failedConditions

      --Return the results
      IF (@failedConditions_ = '')
        RETURN NULL
      RETURN @failedConditions_
    END --qalGeohash_Test_Simple.geography
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
