DROP FUNCTION IF EXISTS [qalGeohash_Preconditions].[checkBigint]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Preconditions].[checkSans]
GO

DROP FUNCTION IF EXISTS [qalGeohash_Preconditions].[checkBitsWide]
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
