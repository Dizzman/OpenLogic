CREATE TABLE IF NOT EXISTS EO_A_SummaryDefinitions (
    _ScenarioID INT NOT NULL,
    ObjectName VARCHAR(255) NULL,
    _VariableTypeAndConstraintSetControl VARCHAR(255) NULL,
    _ForceMinRatiosOnAttributesDefaultValue VARCHAR(255) NULL,
    _AnalysisFlag VARCHAR(255) NULL,
    _CopyTagFieldsToAdjustmentTables VARCHAR(255) NULL,
    _CurrencyAdjustPeriodBiases VARCHAR(255) NULL,
    SummaryAttribute VARCHAR(255) NOT NULL,
    Tag1 VARCHAR(255) NULL,
    Tag2 VARCHAR(255) NULL,
    Tag3 VARCHAR(255) NULL,
    FromAttribute VARCHAR(255) NOT NULL,
    Factor FLOAT NULL
    )