tableextension 50003 "POS Trans. Line Ext." extends "LSC POS Trans. Line"
{
    fields
    {
        field(50000; "Web Order No."; Integer)
        {
            Caption = 'Web Order No.';
        }
        field(50001; "Web Order Code"; Code[20])
        {
            Caption = 'Web Order Code';
        }
    }
}