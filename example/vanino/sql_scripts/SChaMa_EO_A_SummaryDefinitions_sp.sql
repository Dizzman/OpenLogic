-- =============================================
-- Автор:       NY
-- Дата создания: 30.11.2020
-- Проект:      SChaMa - Ванино
-- Описание:    Заполнение EO_A_SummaryDefinitions связями Totaller(Day)-Vessel|Day
-- =============================================
CREATE OR REPLACE  PROCEDURE dbo.SChaMa_EO_A_SummaryDefinitions_sp(ConfigId INTEGER
)

$$
BEGIN
    -- Удаляем старые записи для данного конфига
    DELETE FROM EO_A_SummaryDefinitions
    WHERE _ScenarioID = ConfigId;

    -- Вставляем связи между агрегаторами дней и атрибутами судов
    INSERT INTO EO_A_SummaryDefinitions
        (_ScenarioID, SummaryAttribute, FromAttribute, Factor)
    SELECT
        DoV._ScenarioID,
        DoV.Attribute,
        VD.Attribute,
        tpd.PeriodIndex
    FROM
        T_EO_A_AttributeDefinitions DoV
        INNER JOIN EO_A_AttributeDefinitions VD
            ON DoV.Tag2 = VD.Tag2 AND DoV._ScenarioID = VD._ScenarioID
        JOIN dbo.EO_E_TimePeriodDefinitions tpd
            ON tpd.TimePeriod = get_part_from_to_code(VD.Attribute,6,6)
            AND DoV._ScenarioID = tpd._ScenarioID
    WHERE
        DoV._ScenarioID = ConfigId
        AND DoV.Tag1 = 'Day of Vessel'
        AND VD.Tag1 = 'Vessel|Day'
        AND tpd.Tag1 <> 'D';
END;
$$ LANGUAGE plpgsql;