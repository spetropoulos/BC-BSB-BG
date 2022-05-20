page 50006 "Eshop-Order Lines"
{
    ApplicationArea = All;
    Caption = 'Eshop-Order Lines';
    PageType = List;
    SourceTable = "eShop-Order Lines";
    UsageCategory = Documents;
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Barcode; Rec.Barcode)
                {
                    ToolTip = 'Specifies the value of the Barcode field.';
                    ApplicationArea = All;
                }
                field(ItemNo; Rec.ItemNo)
                {
                    ToolTip = 'Specifies the value of the ItemNo field.';
                    ApplicationArea = All;
                }
                field(ItemDescription; Rec.ItemDescription)
                {
                    ToolTip = 'Specifies the value of the ItemDescription field.';
                    ApplicationArea = All;
                }
                field(VariantCode; Rec.VariantCode)
                {
                    ToolTip = 'Specifies the value of the VariantCode field.';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.';
                    ApplicationArea = All;
                }
                field("Picked Quantity"; Rec."Picked Quantity")
                {
                    ToolTip = 'Specifies the value of the Picked Quantity field.';
                    ApplicationArea = All;
                }
                field("Picked Line Amount"; Rec."Picked Line Amount")
                {
                    ToolTip = 'Specifies the value of the Picked Line Amount field.';
                    ApplicationArea = All;
                }
                field("Picked Line Amount (FC)"; Rec."Picked Line Amount (FC)")
                {
                    ToolTip = 'Specifies the value of the Picked Line Amount (FC) field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
