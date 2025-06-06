CREATE TABLE T_EO_A_RatioConstraints (
    _ScenarioID INT NULL,
    RatioName VARCHAR(255) NOT NULL,
    EnforceMinMaxRatioLimits VARCHAR(255) NULL,
    EnforceMinMaxRatioLimitsForSummaryRatio VARCHAR(255) NULL,
    ForceMinRatio VARCHAR(255) NULL,
    EnableRatioValueAsConstraint VARCHAR(255) NULL,
    FacilityForDrivingBiasToPAndL VARCHAR(255) NULL,
    Tag1 VARCHAR(255) NULL,
    Tag2 VARCHAR(255) NULL,
    Attribute1 VARCHAR(255) NULL,
    Attribute2 VARCHAR(255) NULL,
    Attribute3 VARCHAR(255) NULL,
    Attribute4 VARCHAR(255) NULL,
    Numerator VARCHAR(255) NULL,
    NumeratorValue FLOAT NULL,
    Denominator VARCHAR(255) NULL,
    DenominatorValue FLOAT NULL,
    MinRatio FLOAT NULL,
    MaxRatio FLOAT NULL,
    Ratio FLOAT NULL,
    MinRatioBias FLOAT NULL,
    MinRatioNumeratorShortage FLOAT NULL,
    OppValueMinRatio FLOAT NULL,
    MaxRatioBias FLOAT NULL,
    MaxRatioDenominatorShortage FLOAT NULL,
    OppValueMaxRatio FLOAT NULL,
    BudgetRatio FLOAT NULL,
    SolutionLessBudget FLOAT NULL,
    PctOUBudget FLOAT NULL,
    PreviousSolution FLOAT NULL,
    SolutionLessPrevious FLOAT NULL,
    PctOUPrevious FLOAT NULL,
    ConstraintSet VARCHAR(255) NULL,
    RatioConstraintPrecision FLOAT NULL,
    RatioPrecisionAdjustment FLOAT NULL,
    RatioPrecisionAdjustmentBias FLOAT NULL

);