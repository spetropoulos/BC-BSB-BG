tableextension 50001 "POS Transaction Ext." extends "LSC POS Transaction"
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