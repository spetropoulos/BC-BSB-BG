page 50001 "Web Mapping"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Web Mapping";
    Caption = 'Web Mapping';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field(WEBID; Rec.WEBID)
                {
                    ApplicationArea = Al;
                    ;
                }
                field(LSID; Rec.LSID)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}