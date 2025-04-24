-- ==================================================================
-- Author:      SS
-- Create date: 30.11.2020
-- Project:     SChaMa - Vanino
-- Description: Filling EO_PtI_MixYield Obj_name=Incoming_to_Ships with day items
-- ==================================================================
CREATE OR REPLACE PROCEDURE schama_eo_pti_mixyield_incoming_to_ships_sp(ConfigId INT)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete existing data for specified ConfigId
    DELETE FROM T_EO_PtI_MixYield
    WHERE _ScenarioID = ConfigId
    AND ObjectName = 'Incoming_to_Ships';

    -- Day items in Link PtI "Incoming_to_Ships"
    INSERT INTO T_EO_PtI_MixYield
        (_ScenarioID,
         ObjectName,
         FromLocation,
         ToLocation,
         ItemDescription,
         Material)
    SELECT
        pa._ScenarioID,
        'Incoming_to_Ships',
        pa.Location,
        ld.Location,
        pa.ItemDescription,
        pa.ItemDescription
    FROM
        T_EO_P_PurchaseActivity pa
        CROSS JOIN T_EO_E_LocationDefinitions ld
        JOIN T_EOtemp_ActiveVessel av ON av._ScenarioID = pa._ScenarioID AND av.EO_Vessel = ld.Tag2
    WHERE
        pa._ScenarioID = ConfigId
        AND pa.ObjectName = 'Incoming'
        AND pa.Location = 'Days'
        AND ld._ScenarioID = pa._ScenarioID
        AND ld.Tag1 = 'Ships'
        AND av.DayOfStart <= CAST(get_part_from_to_code(pa.ItemDescription, 2, 2) AS INT);
END;
$$;