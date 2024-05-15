import enum
class OBJECT_TYPE(enum.Enum):
    Purchase=1
    Inventory=2
    Sales=3
    SortInv2Inv=4
    SortInv2Sale=5
    SortPurch2Inv=6
    MixInv2Inv=7
    MixInv2Sale=8
    MixPurch2Inv=9