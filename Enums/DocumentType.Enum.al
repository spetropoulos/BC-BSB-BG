enum 50001 "Document Type"
{
    Extensible = true;

    value(0; Order)
    {
        Caption = 'Order';
    }
    value(1; Return)
    {
        Caption = 'Return';
    }
    value(2; Cancel)
    {
        Caption = 'Cancel';
    }
    value(3; "Correction Order")
    {
        Caption = 'Correction Order';
    }
    value(4; " ")
    {
        Caption = '';
    }
    value(5; "Correction Return")
    {
        Caption = 'Correction Return';
    }
}