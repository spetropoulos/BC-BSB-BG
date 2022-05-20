table 50003 BSB_Extra_Printing
{
    DataClassification = ToBeClassified;
    Caption = 'BSB Extra Printing';

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
}