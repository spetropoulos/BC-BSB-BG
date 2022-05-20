tableextension 50004 "Trans. Payment Entry Ext." extends "LSC Trans. Payment Entry"
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