table 50000 "eShop-Order"
{
    // version eShop,1701,CY,CRM,EshopOutlet,UPS

    //DrillDownFormID = Form82489;
    //LinkedInTransaction = false;
    LinkedObject = false;
    //LookupFormID = Form82489;

    fields
    {
        field(1; WebOrderId; Integer)
        {
            Caption = 'WebOrderId';
        }
        field(2; ErpOrderId; Text[20])
        {
        }
        field(3; "Code"; Text[100])
        {
        }
        field(4; CreatedOn; DateTime)
        {
        }
        field(5; UpdatedOn; DateTime)
        {
        }
        field(6; CheckoutCompletedOn; DateTime)
        {
        }
        field(7; ImportedToERPOn; DateTime)
        {
        }
        field(8; StatusId; Integer)
        {
        }
        field(9; CustomerLoginId; Integer)
        {
        }
        field(10; CustomerLoginEmail; Text[100])
        {
        }
        field(11; CustomerComments; Text[250])
        {
        }
        field(12; ShippingFirstName; Text[30])
        {
        }
        field(13; ShippingLastName; Text[30])
        {
        }
        field(14; ShippingAddressLine1; Text[100])
        {
        }
        field(15; ShippingAddressLine2; Text[30])
        {
        }
        field(16; ShippingCity; Text[50])
        {
        }
        field(17; ShippingPostalCode; Text[20])
        {
        }
        field(18; ShippingCoutryCode; Text[3])
        {
        }
        field(19; ShippingPhones; Text[30])
        {
        }
        field(20; ShippingMobiles; Text[30])
        {
        }
        field(21; ShippingEmail; Text[50])
        {
        }
        field(22; ShippingCompanyId; enum "Shipping Company")
        {
        }
        field(23; ShippingVoucherCode; Text[50])
        {
        }
        field(24; ShippingStartedDate; DateTime)
        {
        }
        field(25; BillingIsInvoice; Boolean)
        {
        }
        field(26; BillingBuyerCategory; Text[1])
        {
        }
        field(27; BillingCompanyName; Text[30])
        {
        }
        field(28; BillingOccupation; Text[20])
        {
        }
        field(29; BillingTaxIdentifier; Text[30])
        {
        }
        field(30; BillingTaxAgency; Text[30])
        {
        }
        field(31; BillingFirstName; Text[30])
        {
        }
        field(32; BillingLastName; Text[30])
        {
        }
        field(33; BillingAddressLine1; Text[100])
        {
        }
        field(34; BillingAddressLine2; Text[30])
        {
        }
        field(35; BillingPostalCode; Text[20])
        {
        }
        field(36; BillingCountryCode; Text[3])
        {
        }
        field(37; BillingPhones; Text[30])
        {
        }
        field(38; BillingMobiles; Text[30])
        {
        }
        field(39; BillingEmail; Text[50])
        {
        }
        field(40; PaymentMethodId; Integer)
        {
        }
        field(41; PaymentTransactionCode; Text[100])
        {
        }
        field(42; PaymentProcessorReferenceCode; Text[100])
        {
        }
        field(43; PaymentAmount; Decimal)
        {

            trigger OnValidate();
            begin
                IF USERID IN ['sa', 'SA'] THEN EXIT;
                IF PaymentMethodId <> 3 THEN ERROR(__PaymentMethodError);
            end;
        }
        field(44; CheckoutCountryCode; Code[2])
        {
        }
        field(45; ShippingArea; Text[100])
        {
        }
        field(46; FolderId; Integer)
        {
        }
        field(47; ExchangeRate; Decimal)
        {
        }
        field(48; UploadError; Boolean)
        {
        }
        field(49; BlanketOrderNo; Code[20])
        {
        }
        field(50; InvoiceNo; Code[20])
        {
        }
        field(53; CreatedOn2; Text[30])
        {
        }
        field(54; UpdatedOn2; Text[30])
        {
        }
        field(55; CheckoutCompletedOn2; Text[30])
        {
        }
        field(56; ImportedToERPOn2; Text[30])
        {
        }
        field(50000; "WMS Document Code"; Code[20])
        {
            //TableRelation = "BSB WMS Document".Code;
        }
        field(50001; "Document Type"; enum "Document Type")
        {
        }
        field(50002; "Related Order Code"; Code[20])
        {
        }
        field(50003; "Master Order Code"; Code[20])
        {
        }
        field(50100; ShippingSiteID; Text[30])
        {
        }
        field(50101; ShippingAddressNo; Text[30])
        {
        }
        field(50900; "Order Doc. No."; Code[20])
        {
        }
        field(60000; "Order Type"; enum "Order Type")
        {
        }
        field(60001; "Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(60002; "Customer Balance"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Cust. Ledg. Entry".Amount WHERE("Customer No." = FIELD("Customer No.")));
            Caption = 'Balance';
            Editable = false;
            FieldClass = FlowField;
        }
        field(60003; DeliveryStore; Code[20])
        {
            Caption = 'Delivery Store';
            TableRelation = "LSC Store";
        }
        field(70000; "Post Infocode"; Code[20])
        {
            TableRelation = "LSC Infocode";
        }
        field(70008; "New StatusId"; enum "Status ID")
        {

            trigger OnValidate();
            begin
                IF "New StatusId" = "New StatusId"::"2-Processing" THEN "Send For Process On" := CURRENTDATETIME;
                IF "New StatusId" = "New StatusId"::"3-To be Picked" THEN "Send For Picking On" := CURRENTDATETIME;
                IF "New StatusId" = "New StatusId"::"4-To be Invoiced" THEN "Send For Invoice On" := CURRENTDATETIME;
                IF "New StatusId" = "New StatusId"::"5-Canceled" THEN "Cancelled On" := CURRENTDATETIME;
                IF "New StatusId" = "New StatusId"::"7-Posted in BG" THEN "Invoiced On" := CURRENTDATETIME;
            end;
        }
        field(80000; "Quantity Picked"; Decimal)
        {
            CalcFormula = Sum("eShop-Order Lines"."Picked Quantity" WHERE("Order Type" = FIELD("Order Type"),
                                                                           WebOrderId = FIELD(WebOrderId),
                                                                           "Line Type" = CONST(Item)));
            FieldClass = FlowField;
        }
        field(80001; Quantity; Decimal)
        {
            CalcFormula = Sum("eShop-Order Lines".Quantity WHERE("Order Type" = FIELD("Order Type"),
                                                                  WebOrderId = FIELD(WebOrderId),
                                                                  "Line Type" = CONST(Item)));
            FieldClass = FlowField;
        }
        field(80003; "Order Amount"; Decimal)
        {
            CalcFormula = Sum("eShop-Order Lines"."Line Amount" WHERE(WebOrderId = FIELD(WebOrderId),
                                                                       "Order Type" = FIELD("Order Type")));
            FieldClass = FlowField;
        }
        field(80004; "Picked Order Amount"; Decimal)
        {
            CalcFormula = Sum("eShop-Order Lines"."Picked Line Amount" WHERE(WebOrderId = FIELD(WebOrderId),
                                                                              "Order Type" = FIELD("Order Type")));
            FieldClass = FlowField;
        }
        field(81003; "Order Amount (FC)"; Decimal)
        {
            CalcFormula = Sum("eShop-Order Lines"."Line Amount (FC)" WHERE(WebOrderId = FIELD(WebOrderId),
                                                                            "Order Type" = FIELD("Order Type")));
            FieldClass = FlowField;
        }
        field(81004; "Picked Order Amount (FC)"; Decimal)
        {
            CalcFormula = Sum("eShop-Order Lines"."Picked Line Amount (FC)" WHERE(WebOrderId = FIELD(WebOrderId),
                                                                                   "Order Type" = FIELD("Order Type")));
            FieldClass = FlowField;
        }
        field(81005; "PaymentAmount (FC)"; Decimal)
        {

            trigger OnValidate();

            begin
                IF PaymentMethodId <> 3 THEN ERROR('Лцдж йЬ ШдлабШлШЩжву гзжиЬх дШ ШввШоЯЬх Ю ШехШ лЮк звЮиргук!!!');
            end;
        }
        field(85003; "Order Item Amount"; Decimal)
        {
            CalcFormula = Sum("eShop-Order Lines"."Line Amount" WHERE(WebOrderId = FIELD(WebOrderId),
                                                                       "Order Type" = FIELD("Order Type"),
                                                                       "Line Type" = CONST(Item)));
            FieldClass = FlowField;
        }
        field(85004; "Picked Order Item Amount"; Decimal)
        {
            CalcFormula = Sum("eShop-Order Lines"."Picked Line Amount" WHERE(WebOrderId = FIELD(WebOrderId),
                                                                              "Order Type" = FIELD("Order Type"),
                                                                              "Line Type" = CONST(Item)));
            FieldClass = FlowField;
        }
        field(85005; "Order Item Amount (FC)"; Decimal)
        {
            CalcFormula = Sum("eShop-Order Lines"."Line Amount (FC)" WHERE(WebOrderId = FIELD(WebOrderId),
                                                                            "Order Type" = FIELD("Order Type"),
                                                                            "Line Type" = CONST(Item)));
            FieldClass = FlowField;
        }
        field(85006; "Picked Order Item Amount (FC)"; Decimal)
        {
            CalcFormula = Sum("eShop-Order Lines"."Picked Line Amount (FC)" WHERE(WebOrderId = FIELD(WebOrderId),
                                                                                   "Order Type" = FIELD("Order Type"),
                                                                                   "Line Type" = CONST(Item)));
            FieldClass = FlowField;
        }
        field(90000; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
        }
        field(90001; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            TableRelation = "LSC Store"."No.";
        }
        field(90002; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
            TableRelation = "LSC POS Terminal"."No.";

            ValidateTableRelation = false;
        }
        field(90003; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
        }
        field(90004; "Line Status"; Enum "Line Status")
        {
        }
        field(90005; "Shipment Reason"; Code[20])
        {
            //TableRelation = "Shipment Reasons".No. WHERE (eshop return=CONST(Yes));            
        }
        field(90006; Posted; Boolean)
        {
            Caption = 'Posted';
        }
        field(90100; "Send For Process On"; DateTime)
        {
        }
        field(90101; "Send For Picking On"; DateTime)
        {
        }
        field(90102; "Send For Invoice On"; DateTime)
        {
        }
        field(90103; "Cancelled On"; DateTime)
        {
        }
        field(90104; "Invoiced On"; DateTime)
        {
        }
        field(90105; "Temp balance"; Decimal)
        {
            /*FieldClass = FlowField;
            CalcFormula = Lookup(_EshopCustBalance.Balance WHERE ("Customer No_"=FIELD("Customer No.")));*/

        }
        field(91000; "Charge Receipt No."; Code[20])
        {
            Caption = 'Charge Receipt No.';
        }
        field(91001; "Charge Store No."; Code[10])
        {
            Caption = 'Charge Store No.';
            TableRelation = "LSC Store"."No.";
        }
        field(91002; "Charge POS Terminal No."; Code[10])
        {
            Caption = 'Charge POS Terminal No.';
            TableRelation = "LSC POS Terminal"."No.";
            ValidateTableRelation = false;
        }
        field(91003; "Charge Transaction No."; Integer)
        {
            Caption = 'Charge Transaction No.';
        }
        field(91004; "Charge Doc. No."; Code[20])
        {
        }
        field(98001; CPNNumber; Code[20])
        {
        }
        field(98002; CountyCode; Text[50])
        {
        }
        field(98003; Exported; Boolean)
        {
        }
        field(98004; "Charge Return"; Boolean)
        {
        }
        field(98005; ReturnVoucherCode; Code[50])
        {
        }
        field(98006; "email - send"; Boolean)
        {
        }
        field(98007; "email - send on"; DateTime)
        {
        }
        field(98008; "PDF Created"; Boolean)
        {
        }
        field(99100; CRMMobile; Code[20])
        {
        }
        field(99101; CRMPaid; Boolean)
        {
        }
        field(99102; CRMProcessed; Boolean)
        {
        }
        field(99103; CRMMsg; Text[250])
        {
        }
        field(99104; CRMPaidFile; Text[100])
        {
        }
        field(99105; CRMPaidFileLineNo; Integer)
        {
        }
        field(99106; CRMPaidFileUser; Text[50])
        {
        }
        field(99107; CRMExists; Boolean)
        {
            /*CalcFormula = Exist("Sieben Loyalty Invoices" WHERE ("Store No."=FIELD("Store No."),
                                                                 "POS Terminal No."=FIELD("POS Terminal No."),
                                                                 "Transaction No."=FIELD("Transaction No.")));
            FieldClass = FlowField;*/
        }
        field(99200; "Retail Doc No"; Code[20])
        {
            /* CalcFormula = Lookup("LSC Transaction Header"."Document No." WHERE ("Store No."=FIELD("Store No."),
                                                                             "POS Terminal No."=FIELD("POS Terminal No."),
                                                                             "Transaction No."=FIELD("Transaction No.")));
             FieldClass = FlowField;*/
        }
        field(99601; "Voucher on Intermediate DB"; Text[30])
        {
            /*CalcFormula = Lookup(eShopOutletOrders.ShippingVoucherCode WHERE (WebOrderId=FIELD(WebOrderId)));
            FieldClass = FlowField;*/
        }
        field(99800; "Picking List"; Boolean)
        {
        }
        field(99801; Seasons; Text[250])
        {
        }
        field(99999; "Replication Counter"; Integer)
        {

            trigger OnValidate();
            var
                Transaction: Record "LSC Transaction Header";
            begin
                Transaction.SETCURRENTKEY("Replication Counter");
                IF Transaction.FINDLAST THEN
                    "Replication Counter" := Transaction."Replication Counter" + 1
                ELSE
                    "Replication Counter" := 1;
            end;
        }
    }

    keys
    {
        key(Key1; "Order Type", WebOrderId)
        {
        }
        key(Key2; BlanketOrderNo)
        {
        }
        key(Key3; "Code")
        {
        }
        key(Key4; "New StatusId")
        {
        }
        key(Key5; "Store No.", "POS Terminal No.", "Transaction No.")
        {
        }
        key(Key6; "Order Type", CreatedOn)
        {
        }
        key(Key7; "Order Type", ShippingCompanyId, ShippingStartedDate)
        {
        }
        key(Key8; "Document Type", "New StatusId", "email - send")
        {
        }
        key(Key9; "Order Doc. No.")
        {
        }
        key(Key10; CRMMobile, CRMPaid)
        {
        }
        key(Key11; CRMMobile, CRMProcessed)
        {
        }
        key(Key12; ShippingVoucherCode)
        {
        }
        key(Key13; "Replication Counter")
        {
        }
        key(Key14; "Master Order Code", CreatedOn, BlanketOrderNo)
        {
        }
    }

    fieldgroups
    {
    }


    trigger OnDelete();
    begin
        rWOI.RESET;
        rWOI.SETRANGE("Order Type", "Order Type");
        rWOI.SETRANGE(WebOrderId, WebOrderId);
        rWOI.DELETEALL;
    end;

    trigger OnInsert();
    begin
        CalcLineStatus(FALSE);
        VALIDATE("Replication Counter")
    end;

    trigger OnModify();
    begin
        CalcLineStatus(FALSE);

    end;

    var
        rWOI: Record "eShop-Order Lines";
        __PaymentMethodError: Label 'Invalid Payment Code';


    procedure CalcLineStatus(bModify: Boolean);
    var
        rL: Record "eShop-Order Lines";
    begin
        IF "New StatusId" = "New StatusId"::"5-Canceled" THEN
            "Line Status" := "Line Status"::" "
        ELSE BEGIN
            rL.RESET;
            rWOI.SETCURRENTKEY("Order Type", WebOrderId, "Line Type", "Line Status");
            rL.SETRANGE("Order Type", "Order Type");
            rL.SETRANGE(WebOrderId, WebOrderId);
            rL.SETRANGE("Line Type", rL."Line Type"::Item);
            rL.SETRANGE("Line Status", rL."Line Status"::Pending);
            IF rL.ISEMPTY THEN
                "Line Status" := "Line Status"::Picked
            ELSE
                "Line Status" := "Line Status"::Pending;
        END;
        IF bModify THEN IF MODIFY THEN;
    end;

    procedure GetPdfName(): Text[1024];
    begin
        EXIT(ReturnVoucherCode + '-' + ShippingVoucherCode + '-' +
                        FORMAT("Invoiced On", 8, '<day,2><month,2><Year4>') + '-300.pdf');
    end;

}

