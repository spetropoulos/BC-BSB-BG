pageextension 50001 "Retail Setup Ext." extends "LSC Retail Setup"
{
    layout
    {
        addlast(Other)
        {
            field("Shipping Charge Item No."; Rec."Shipping Charge Item No.")
            {
                ApplicationArea = All;
            }
            field("Shipping Charge VAT%"; Rec."Shipping Charge VAT%")
            {
                ApplicationArea = All;
            }
        }
    }
}