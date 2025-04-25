-- =============================================
-- Автор:       NY
-- Дата создания: 30.11.2020
-- Проект:      SChaMa - Ванино
-- Описание:    Заполнение EO_A_AttributeDefinitions атрибутами для управления порядком судов
-- =============================================
CREATE OR REPLACE PROCEDURE dbo.SChaMa_EO_A_AttributeDefinitions_Order_sp(ConfigId INT)

$$
BEGIN
    -- Удаляем старые записи для данного конфига с указанными тегами
    DELETE FROM T_EO_A_AttributeDefinitions
    WHERE _ScenarioID = ConfigId
          AND Tag1 IN ('Vessel|Day', 'Day of Vessel');

    -- Вставляем определители "Судно-День" для продаж
    INSERT INTO T_EO_A_AttributeDefinitions
        (_ScenarioID, Attribute, Tag1, Tag2, AttributeType, ObjectClassAppliedTo)
    SELECT
        sa._ScenarioID, sa.Attribute4, 'Vessel|Day', TRIM(av.EO_Vessel), 'Activity', 'Sales'
    FROM
        T_EO_S_SalesActivity sa
        JOIN T_EOtemp_ActiveVessel av ON CAST( sa.Tag1 AS INT) = av.VesselId AND sa._ScenarioID = av._ScenarioID
    WHERE
        sa._ScenarioID = ConfigId
        AND sa.Attribute4