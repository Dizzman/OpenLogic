-- =============================================
-- Author:      NY
-- Create date: 30.11.2020
-- Project:     SCHaMa - Vanino
-- Description: Filling EO_A_AttributeDefinitions with attributes to maintain order of Vessels
-- =============================================
CREATE OR REPLACE PROCEDURE SChaMa_EO_A_AttributeDefinitions_Order_sp(
    ConfigId INT
)
LANGUAGE plpgsql
AS $$
BEGIN

    DELETE FROM T_EO_A_AttributeDefinitions
    WHERE _ScenarioID = ConfigId
          AND (Tag1 IN ('Vessel|Day', 'Day of Vessel'));

    -- Vessel-day determinator in Sales
    INSERT INTO T_EO_A_AttributeDefinitions
        (_ScenarioID, Attribute, Tag1, Tag2, AttributeType, ObjectClassAppliedTo)
    SELECT
        sa._ScenarioID, sa.Attribute4,
        'Vessel|Day', TRIM(av.EO_Vessel),
        'Activity', 'Sales'
    FROM
        T_EO_S_SalesActivity sa
        JOIN T_EOtemp_ActiveVessel av ON CAST(sa.Tag1 AS INT) = av.VesselId AND sa._ScenarioID = av._ScenarioID
    WHERE
        sa._ScenarioID = ConfigId
        AND sa.Attribute4 IS NOT NULL;

    -- Day of Vessel Totaller
    INSERT INTO T_EO_A_AttributeDefinitions
        (_ScenarioID, Attribute, Tag1, Tag2, AttributeType)
    SELECT
        _ScenarioID, TRIM(av.EO_Vessel) || '|Day',
        'Day of Vessel', TRIM(av.EO_Vessel),
        'Attribute Totaller'
    FROM
        T_EOtemp_ActiveVessel av
    WHERE
        av._ScenarioID = ConfigId;

END;
$$;