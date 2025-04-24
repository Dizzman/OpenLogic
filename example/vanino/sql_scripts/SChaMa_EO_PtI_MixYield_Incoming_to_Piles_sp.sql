-- ==================================================================
-- Author:      SS
-- Create date: 30.11.2020
-- Project:     SChaMa - Vanino
-- Description: Filling EO_PtI_MixYield Obj_name=Incoming_to_Piles
-- ==================================================================
CREATE OR REPLACE PROCEDURE schama_eo_pti_mixyield_incoming_to_piles_sp(
    ConfigId INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Удаляем старые данные для указанного ConfigId
    DELETE FROM T_EO_PtI_MixYield
    WHERE _ScenarioID = ConfigId
    AND ObjectName = 'Incoming_to_Piles';

    -- Piles in Link PtI "Incoming_to_Piles"
    INSERT INTO T_EO_PtI_MixYield
        (_ScenarioID,
         ObjectName,
         FromLocation,
         ToLocation,
         ItemDescription,
         Material)
    SELECT
        _ScenarioID,
        'Incoming_to_Piles',
        Location,
        Location,
        ItemDescription,
        ItemDescription
    FROM
        T_EO_P_PurchaseActivity
    WHERE
        _ScenarioID = ConfigId
        AND ObjectName = 'Incoming';
END;
$$;