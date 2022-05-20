table 50002 "Web Mapping"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Type; enum "Web Mapping Type")
        {
            Caption = 'Type';
        }
        field(2; WEBID; Integer)
        {
            Caption = 'WEB ID';
        }
        field(3; LSID; code[10])
        {
            Caption = 'LS ID';
            TableRelation = "LSC Tender Type Setup".Code;
        }
        field(4; Description; Text[30])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; Type, WEBID)
        {
        }
    }
}