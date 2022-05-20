page 50002 "eshop-Orders"
{
    ApplicationArea = All;
    Caption = 'eshop-Orders';
    PageType = List;
    SourceTable = "eShop-Order";
    UsageCategory = Documents;
    InsertAllowed = False;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Order Type"; Rec."Order Type")
                {
                    ToolTip = 'Specifies the value of the Order Type field.';
                    ApplicationArea = All;
                }
                field(WebOrderId; Rec.WebOrderId)
                {
                    ToolTip = 'Specifies the value of the WebOrderId field.';
                    ApplicationArea = All;
                }
                field(BlanketOrderNo; Rec.BlanketOrderNo)
                {
                    ToolTip = 'Specifies the value of the BlanketOrderNo field.';
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                    ApplicationArea = All;
                }
                field(CustomerLoginId; Rec.CustomerLoginId)
                {
                    ToolTip = 'Specifies the value of the CustomerLoginId field.';
                    ApplicationArea = All;
                }
                field("New StatusId"; Rec."New StatusId")
                {
                    ToolTip = 'Specifies the value of the New StatusId field.';
                    ApplicationArea = All;
                }
                field(Posted; Rec.Posted)
                {
                    ToolTip = 'Specifies the value of the Posted field.';
                    ApplicationArea = All;
                }
                field("Receipt No."; Rec."Receipt No.")
                {
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                    ApplicationArea = All;
                }
                field("Retail Doc No"; Rec."Retail Doc No")
                {
                    ToolTip = 'Specifies the value of the Retail Doc No field.';
                    ApplicationArea = All;
                }
                field("Store No."; Rec."Store No.")
                {
                    ToolTip = 'Specifies the value of the Store No. field.';
                    ApplicationArea = All;
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ToolTip = 'Specifies the value of the POS Terminal No. field.';
                    ApplicationArea = All;
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ToolTip = 'Specifies the value of the Transaction No. field.';
                    ApplicationArea = All;
                }
                field("Order Amount"; Rec."Order Amount")
                {
                    ToolTip = 'Specifies the value of the Order Amount field.';
                    ApplicationArea = All;
                }
                field("Order Amount (FC)"; Rec."Order Amount (FC)")
                {
                    ToolTip = 'Specifies the value of the Order Amount (FC) field.';
                    ApplicationArea = All;
                }
                field(PaymentAmount; Rec.PaymentAmount)
                {
                    ToolTip = 'Specifies the value of the PaymentAmount field.';
                    ApplicationArea = All;
                }
                field("PaymentAmount (FC)"; Rec."PaymentAmount (FC)")
                {
                    ToolTip = 'Specifies the value of the PaymentAmount (FC) field.';
                    ApplicationArea = All;
                }
                field(PaymentMethodId; Rec.PaymentMethodId)
                {
                    ToolTip = 'Specifies the value of the PaymentMethodId field.';
                    ApplicationArea = All;
                }
                field(ShippingFirstName; Rec.ShippingFirstName)
                {
                    ToolTip = 'Specifies the value of the ShippingFirstName field.';
                    ApplicationArea = All;
                }
                field(ShippingLastName; Rec.ShippingLastName)
                {
                    ToolTip = 'Specifies the value of the ShippingLastName field.';
                    ApplicationArea = All;
                }
                field(ShippingMobiles; Rec.ShippingMobiles)
                {
                    ToolTip = 'Specifies the value of the ShippingMobiles field.';
                    ApplicationArea = All;
                }
                field(ShippingPhones; Rec.ShippingPhones)
                {
                    ToolTip = 'Specifies the value of the ShippingPhones field.';
                    ApplicationArea = All;
                }
                field(ShippingEmail; Rec.ShippingEmail)
                {
                    ToolTip = 'Specifies the value of the ShippingEmail field.';
                    ApplicationArea = All;
                }
                field(ShippingCity; Rec.ShippingCity)
                {
                    ToolTip = 'Specifies the value of the ShippingCity field.';
                    ApplicationArea = All;
                }
                field(ShippingAddressLine1; Rec.ShippingAddressLine1)
                {
                    ToolTip = 'Specifies the value of the ShippingAddressLine1 field.';
                    ApplicationArea = All;
                }
                field(ShippingPostalCode; Rec.ShippingPostalCode)
                {
                    ToolTip = 'Specifies the value of the ShippingPostalCode field.';
                    ApplicationArea = All;
                }
                field(ShippingVoucherCode; Rec.ShippingVoucherCode)
                {
                    ToolTip = 'Specifies the value of the ShippingVoucherCode field.';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Post Order")
            {
                ApplicationArea = All;
                Tooltip = '';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Caption = 'Post Orders';
                trigger OnAction()
                var
                    myInt: Integer;
                    mySelection: Record "eShop-Order";
                    dDLG: Dialog;
                    i: Integer;
                    t: Integer;
                    cC: Codeunit "Web Order Post";
                begin
                    currpage.SetSelectionFilter(mySelection);
                    t := mySelection.Count;
                    if not Confirm('Post ' + format(t) + ' web orders?') then exit;
                    if t > 1 then dDLG.open('#1#######/#3#######', i, t);
                    If mySelection.findset then
                        repeat
                            i += 1;
                            if t > 1 then dDLG.Update;
                            clear(cC);
                            cC.PostOrder(mySelection);
                        until mySelection.next = 0;
                    if t > 1 then ddlg.Close();
                end;
            }
        }
    }
}
