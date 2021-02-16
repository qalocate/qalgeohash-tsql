-- /* ---------.---------.---------.---------.---------.---------.--------.---------.---------.---------.---------.--------- *\
-- ** Part Of:     QA Locate Geohash API                                                                                     **
-- ** URL:         http://www.qalocate.com                                                                                   **
-- ** File:                                                                                                                  **
-- **   Name:      qalGeohash_Geography.sql                                                                                  **
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

CREATE SCHEMA qalGeohash_Geography
GO

DROP FUNCTION IF EXISTS [qalGeohash_Geography].[expandBigintIntoGeographyPointCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Geography].[expandBigintIntoGeographyPoint]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Geography].[reduceGeographyPointIntoBigintCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Geography].[reduceGeographyPointIntoBigint]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Geography].[distanceInMetersBetweenBigintsCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Geography].[distanceInMetersBetweenBigints]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Geography].[distanceInMetersBetweenBigintAndGeographyPointCheck]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Geography].[distanceInMetersBetweenBigintAndGeographyPoint]
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Geography].[expandBigintIntoGeographyPointCheck] (
  @_biGeohash BIGINT
) RETURNS
    geography --gcPoint_
  AS
    BEGIN
      --validate preconditions
      IF (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL)
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Geography.expandBigintIntoGeographyPoint(@_biGeohash)
    END --expandBigintIntoGeographyPointCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Geography].[expandBigintIntoGeographyPoint] (
  @_biGeohash BIGINT
) RETURNS
    geography --gcPoint_
  AS
    BEGIN
      --Allocate working variables
      DECLARE @dcLongitude DECIMAL(15, 12) = NULL
      DECLARE @dcLatitude  DECIMAL(15, 12) = NULL

      --Execute the operation
      SELECT  @dcLongitude = tuple.dcLongitude,
              @dcLatitude  = tuple.dcLatitude
        FROM qalGeohash_Main.expandBigintIntoLongLat(@_biGeohash) AS tuple

      --Return the results
      RETURN geography::Point(CAST(@dcLatitude AS FLOAT), CAST(@dcLongitude AS FLOAT), 4326)
    END --expandBigintIntoGeographyPoint
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Geography].[reduceGeographyPointIntoBigintCheck] (
  @_gcPoint geography,
  @_tiBitsWide TINYINT = 55
) RETURNS
    BIGINT --biGeohash_
  AS
    BEGIN
      --validate preconditions
      IF (
        (@_gcPoint IS NULL) OR 
        (@_gcPoint.STGeometryType() <> 'Point') OR
        (qalGeohash_Preconditions.checkBitsWide(@_tiBitsWide) IS NOT NULL)
      )
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Geography.reduceGeographyPointIntoBigint(@_gcPoint, @_tiBitsWide)
    END --reduceGeographyPointIntoBigintCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Geography].[reduceGeographyPointIntoBigint] (
  @_gcPoint geography,
  @_tiBitsWide TINYINT = 55
) RETURNS
    BIGINT --biGeohash_
  AS
    BEGIN
      --Return the results
      RETURN
        qalGeohash_Main.reduceLongLatIntoBigint(
          CAST(@_gcPoint.Long AS DECIMAL(15, 12)),
          CAST(@_gcPoint.Lat AS DECIMAL(15, 12)),
          @_tiBitsWide
        )
    END --reduceGeographyPointIntoBigint
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Geography].[distanceInMetersBetweenBigintsCheck] (
  @_biGeohashA BIGINT,
  @_biGeohashB BIGINT
) RETURNS
    FLOAT --fDistanceInMeters_
  AS
    BEGIN
      --validate preconditions
      IF (
        (qalGeohash_Preconditions.checkBigint(@_biGeohashA) IS NOT NULL) OR
        (qalGeohash_Preconditions.checkBigint(@_biGeohashB) IS NOT NULL)
      )
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Geography.distanceInMetersBetweenBigints(@_biGeohashA, @_biGeohashB)
    END --distanceInMetersBetweenBigintsCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Geography].[distanceInMetersBetweenBigints] (
  @_biGeohashA BIGINT,
  @_biGeohashB BIGINT
) RETURNS
    FLOAT --fDistanceInMeters_
  AS
    BEGIN
      --TODO: Ensure the definition of geodesic/geodetic distance (below) is included within the README.md
      --      STDistance uses geodesic/geodetic distance; i.e. the shortest path along the ellipsoid of the earth at sea level
      --        between one point and another
      --      http://vterrain.org/Misc/distance.html
      --Return the results
      RETURN
        qalGeohash_Geography.expandBigintIntoGeographyPoint(@_biGeohashA).STDistance(
            qalGeohash_Geography.expandBigintIntoGeographyPoint(@_biGeohashB)
          )
    END --distanceInMetersBetweenBigints
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Geography].[distanceInMetersBetweenBigintAndGeographyPointCheck] (
  @_biGeohash BIGINT,
  @_gcPoint geography
) RETURNS
    FLOAT --fDistanceInMeters_
  AS
    BEGIN
      --validate preconditions
      IF (
        (qalGeohash_Preconditions.checkBigint(@_biGeohash) IS NOT NULL) OR
        (@_gcPoint IS NULL) OR
        (@_gcPoint.STGeometryType() <> 'Point')
      )
        RETURN NULL

      --Return the results
      RETURN qalGeohash_Geography.distanceInMetersBetweenBigintAndGeographyPoint(@_biGeohash, @_gcPoint)
    END --distanceInMetersBetweenBigintAndGeographyPointCheck
GO

-- v2021.02.14 - qalGeohash-TSQL™ - Copyright © 2021 by Precision Location Intelligence, Inc. - All rights reserved.
CREATE FUNCTION [qalGeohash_Geography].[distanceInMetersBetweenBigintAndGeographyPoint] (
  @_biGeohash BIGINT,
  @_gcPoint geography
) RETURNS
    FLOAT --fDistanceInMeters_
  AS
    BEGIN
      --Return the results
      RETURN @_gcPoint.STDistance(qalGeohash_Geography.expandBigintIntoGeographyPoint(@_biGeohash))
    END --distanceInMetersBetweenBigintAndGeographyPoint
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
