tableextension 50002 "Transaction Header Ext." extends "LSC Transaction Header"
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
    keys
    {
        key(WEB; "Web Order Code", "Web Order No.")
        {

        }
    }
}