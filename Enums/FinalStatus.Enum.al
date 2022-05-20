enum 50007 "Final Status"
{
    Extensible = true;
    // ,Send To Customer,Misspick,Received from Customer,Misspick Processed,Cancelled,Cancellation,Send to Dias"
    value(0; " ")
    {
    }
    value(1; "Send To Customer")
    {
        Caption = 'Send To Customer';
    }
    value(2; Misspick)
    {
        Caption = 'Misspick';
    }
    value(3; "Received from Customer")
    {
        Caption = 'Received from Customer';
    }
    value(4; "Misspick Processed")
    {
        Caption = 'Misspick Processed';
    }
    value(5; Cancelled)
    {
        Caption = 'Cancelled';
    }
    value(6; Cancellation)
    {
        Caption = 'Cancellation';
    }
    value(7; "Send to Dias")
    {
        Caption = 'Send to Dias';
    }
}