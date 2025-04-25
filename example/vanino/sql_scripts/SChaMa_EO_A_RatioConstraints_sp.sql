-- =============================================
-- Автор:       NY
-- Дата создания: 30.11.2020
-- Проект:      SChaMa - Ванино
-- Описание:    Заполнение EO_A_RatioConstraints соотношениями порядка судов в телескопе
-- =============================================
CREATE OR REPLACE PROCEDURE SChaMa_EO_A_RatioConstraints_sp(
    ConfigId INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Удаляем старые записи для данного конфига
    DELETE FROM T_EO_A_RatioConstraints
    WHERE _ScenarioID = ConfigId;

    -- Вставляем соотношения дней последовательных судов
    INSERT INTO T_EO_A_RatioConstraints
        (_ScenarioID, RatioName, EnforceMinMaxRatioLimitsForSummaryRatio,
         FacilityForDrivingBiasToPAndL, Numerator, Denominator,
         MinRatio, MaxRatio)
    SELECT
        av1._ScenarioID,
        TRIM(av1.VesselCode) || '|' || TRIM(av2.VesselCode),
        'Hard',
        'Facility 1',
        TRIM(av1.EO_Vessel) || '|Day',
        TRIM(av2.EO_Vessel) || '|Day',
        0,
        1
    FROM
        (SELECT *, ROW_NUMBER() OVER(ORDER BY VesselId) AS rn
         FROM T_EOtemp_ActiveVessel
         WHERE _ScenarioID = ConfigId) av1
        JOIN (SELECT *, ROW_NUMBER() OVER(ORDER BY VesselId) AS rn
              FROM T_EOtemp_ActiveVessel
              WHERE _ScenarioID = ConfigId) av2
        ON av1.rn = av2.rn - 1;
END;
$$