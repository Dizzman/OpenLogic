CREATE TABLE IF NOT EXISTS T_EO_I_InventoryActivity (

    _ScenarioID INTEGER NOT NULL,
    ObjectName VARCHAR(255) NOT NULL,
    _VariableControlledFacilityLocationAttribute VARCHAR(255),
    _Location VARCHAR(255),
    _Facility VARCHAR(255),
    _AttributeVariableTypeAndConstraintSetControl VARCHAR(255),
    _TransferCurrencyControl VARCHAR(255),
    _Attribute1 VARCHAR(255),
    _Attribute2 VARCHAR(255),
    _Attribute3 VARCHAR(255),
    _Attribute4 VARCHAR(255),
    _Tag1 VARCHAR(255),
    _Tag2 VARCHAR(255),
    _AnalysisFlag VARCHAR(255),
    _InventoryClass VARCHAR(255),
    _SingleSourceOptions VARCHAR(255),
    _SourceLimit FLOAT,
    _SourcePenalty FLOAT,
    _MaxSingleSourceExceptions FLOAT,
    _ForceMinRatiosOnInventoriesDefaultValue VARCHAR(255),
    _PoolingFlag VARCHAR(255),
    _RatioBandingFlag VARCHAR(255),
    _ValueTaxRateBase VARCHAR(255),
    _AllocateValueTaxTo VARCHAR(255),
    _UseUnitCostDriverDefaultAccounts VARCHAR(255),
    _ObjectActive VARCHAR(255),
    _PropagateTagsToMTPTable VARCHAR(255),
    Facility VARCHAR(255) ,
    Location VARCHAR(255) NOT NULL,
    Material VARCHAR(255) NOT NULL,
    Attribute1 VARCHAR(255),
    Attribute2 VARCHAR(255),
    Attribute3 VARCHAR(255),
    Attribute4 VARCHAR(255),
    MinBeginUnitsFirstPeriod FLOAT,
    MaxBeginUnitsFirstPeriod FLOAT,
    ValuePerBeginUnitFirstPeriod FLOAT,
    MinEndUnitsLastPeriod FLOAT,
    MaxEndUnitsLastPeriod FLOAT,
    ValuePerEndUnit FLOAT,
    MinCarryforwardUnits FLOAT,
    MaxCarryforwardUnits FLOAT,
    HoldingCostPerUnit FLOAT,
    ValueTaxRate FLOAT,
    VolumeChangeFactor FLOAT,
    SolutionBeginUnitsFirstPeriod FLOAT,
    OppValuePerBeginUnitFirstPeriod FLOAT,
    SolutionEndUnitsLastPeriod FLOAT,
    OppValuePerEndUnitLastPeriod FLOAT,
    TotalVolumeIn FLOAT,
    TotalVolumeOut FLOAT,
    VolumeLossGain FLOAT,
    ValueLossGain FLOAT,
    AvgIncomingCostPerUnit FLOAT,
    AvgOutgoingCostPerUnit FLOAT,
    AvgEndingCostPerUnit FLOAT,
    Tag1 VARCHAR(255),
    Tag2 VARCHAR(255),
    Tag3 VARCHAR(255),
    Tag4 VARCHAR(255)

);

