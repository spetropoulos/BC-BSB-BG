enum 50006 "Receive Status"
{
    Extensible = true;
    // ,Pending,Posted,Error"
    value(0; " ")
    {
    }
    value(1; Pending)
    {
        Caption = 'Pending';
    }
    value(2; Posted)
    {
        Caption = 'Posted';
    }
    value(3; Error)
    {
        Caption = 'Error';
    }
}