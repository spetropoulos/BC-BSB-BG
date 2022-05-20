tableextension 50000 "Retail Setup Extension" extends "LSC Retail Setup"
{
    fields
    {
        field(50000; "Shipping Charge VAT%"; Decimal)
        {
            Caption = 'Shipping Charge VAT%';
        }
        field(50001; "Shipping Charge Item No."; Code[10])
        {
            Caption = 'Shipping Charge Item No.';
        }
    }

}