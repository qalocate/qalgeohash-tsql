SELECT  t1.sequenceId,
        t2.*
  FROM (
        SELECT sv.sequenceId,
               qalGeohash_Main.convertVarcharToBigint(sv.vcGeohash) AS biGeohash
          FROM qalGeohash_Test_Generator.SeedValues AS sv
      --    WHERE (sv.sequenceId = 0)
       ) AS t1
 CROSS APPLY qalGeohash_Test_Generator.fromBigint(t1.biGeohash) AS t2

SELECT t3.*
  FROM (
SELECT  t1.sequenceId,
        t2.*,
        qalGeohash_Test_CheckCoheranceAcrossFunctions.main(
          t2.biGeohash,
          t2.dcCenterLongitude,
          t2.dcCenterLatitude,
          t2.vcGeohash
        ) AS testMain,
        qalGeohash_Test_CheckCoheranceAcrossFunctions.dms(
          t2.biGeohash,
          t2.dcCenterLongitude,
          t2.dcCenterLatitude,
          t2.vcGeohash,
          t2.tiDegreesAbsoluteLongitude,
          t2.tiMinutesLongitude,
          t2.dcSecondsLongitude,
          t2.bIsNegativeLongitude,
          t2.tiDegreesAbsoluteLatitude,
          t2.tiMinutesLatitude,
          t2.dcSecondsLatitude,
          t2.bIsNegativeLatitude
        ) AS testDms,
        qalGeohash_Test_CheckCoheranceAcrossFunctions.auxiliary(
          t2.biGeohash,
          t2.dcLeftLongitude,
          t2.dcRightLongitude,
          t2.dcLowerLatitude,
          t2.dcUpperLatitude,
          t2.biGeohashParent,
          t2.vcGeohashParent,
          t2.biNorth,
          t2.biNorthEast,
          t2.biEast,
          t2.biSouthEast,
          t2.biSouth,
          t2.biSouthWest,
          t2.biWest,
          t2.biNorthWest
        ) AS testAuxiliary,
        qalGeohash_Test_CheckCoheranceAcrossFunctions.dms(
          t2.biGeohash,
          t2.dcCenterLongitude,
          t2.dcCenterLatitude,
          t2.vcGeohash
        ) AS testGeography
  FROM (
        SELECT sv.sequenceId,
               qalGeohash_Main.convertVarcharToBigint(sv.vcGeohash) AS biGeohash
          FROM qalGeohash_Test_Generator.SeedValues AS sv
      --    WHERE (sv.sequenceId = 0)
       ) AS t1
 CROSS APPLY qalGeohash_Test_Generator.fromBigint(t1.biGeohash) AS t2
) AS t3
WHERE (t3.testMain IS NOT NULL)
   OR (t3.testDms IS NOT NULL)
   OR (t3.testAuxiliary IS NOT NULL)
   OR (t3.testGeography IS NOT NULL)
