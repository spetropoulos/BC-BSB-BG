table 50001 "eShop-Order Lines"
{
    // version eShop,1701,EshopOutlet,DISC

    //LinkedInTransaction = false;
    LinkedObject = false;

    fields
    {
        field(1; WebOrderId; Integer)
        {
            TableRelation = "eShop-Order".WebOrderId WHERE("Order Type" = FIELD("Order Type"));
        }
        field(2; OrderItemId; Integer)
        {
        }
        field(3; ItemNo; Code[20])
        {
            TableRelation = Item;

            trigger OnValidate();
            begin
                UpdateInfo();
            end;
        }
        field(4; ItemDescription; Text[30])
        {
        }
        field(5; "Initial Quantity"; Integer)
        {
        }
        field(6; ItemPrice; Decimal)
        {
        }
        field(7; VATPercent; Decimal)
        {
        }
        field(8; CreatedOn; DateTime)
        {
        }
        field(9; VariantCode; Text[20])
        {
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD(ItemNo));

            trigger OnValidate();
            begin
                UpdateInfo();
            end;
        }
        field(10; UploadErrorText; Text[100])
        {
        }
        field(50000; "Location Code"; Code[10])
        {
            TableRelation = Location;
        }
        field(50900; "Order Doc. No."; Code[20])
        {
        }
        field(60000; "Order Type"; Enum "Order Type")
        {
        }
        field(60001; "Line Type"; Option)
        {
            OptionCaption = 'Item,Charge,Payment,Total Discount';
            OptionMembers = Item,Charge,Payment,"Total Discount";
        }
        field(60002; "Line Amount"; Decimal)
        {
        }
        field(70000; "Picked Quantity"; Decimal)
        {
        }
        field(70001; "Picked by User ID"; Text[100])
        {
        }
        field(70002; "Picked Line Amount"; Decimal)
        {
        }
        field(70003; Quantity; Decimal)
        {

            trigger OnValidate();
            begin
                UpdateInfo();
            end;
        }
        field(70004; Barcode; Code[50])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("LSC Barcodes"."Barcode No." WHERE("Item No." = FIELD(ItemNo),
                                                               "Variant Code" = FIELD(VariantCode)));


            trigger OnValidate();
            begin
                UpdateInfo();
            end;
        }
        field(70005; "Picked on"; DateTime)
        {
        }
        field(70006; "Line Status"; Option)
        {
            OptionCaption = '" ,Pending,Picked"';
            OptionMembers = " ",Pending,Picked;
        }
        field(80000; "ItemPrice (FC)"; Decimal)
        {
        }
        field(80001; "Line Amount (FC)"; Decimal)
        {
        }
        field(80002; "Picked Line Amount (FC)"; Decimal)
        {
        }
        field(90501; InitialPrice; Decimal)
        {
        }
        field(90900; "Dias ILE Entry no."; Integer)
        {
        }
        field(90901; MissPickedQty; Decimal)
        {
        }
        field(90902; "Label Price"; Decimal)
        {
        }
    }

    keys
    {
        key(Key1; "Order Type", WebOrderId, OrderItemId)
        {
            SumIndexFields = "Line Amount", "Picked Quantity", "Picked Line Amount", Quantity, "Line Amount (FC)", "Picked Line Amount (FC)";
        }
        key(Key2; "Order Type", WebOrderId, ItemNo, VariantCode)
        {
            SumIndexFields = "Line Amount", "Picked Quantity", "Picked Line Amount", Quantity, "Line Amount (FC)", "Picked Line Amount (FC)";
        }
        key(Key3; "Order Type", WebOrderId, "Line Type")
        {
            SumIndexFields = "Picked Quantity", Quantity;
        }
        key(Key4; "Location Code")
        {
        }
        key(Key5; "Location Code", ItemNo, VATPercent)
        {
            SumIndexFields = "Picked Quantity", Quantity;
        }
        key(Key6; "Order Type", WebOrderId, "Line Type", "Line Status")
        {
            SumIndexFields = "Line Amount", "Picked Quantity", "Picked Line Amount", Quantity, "Line Amount (FC)", "Picked Line Amount (FC)";
        }
        key(Key7; "Order Doc. No.")
        {
            SumIndexFields = "Line Amount", "Picked Quantity", "Picked Line Amount", Quantity, "Line Amount (FC)", "Picked Line Amount (FC)";
        }
        key(Key8; CreatedOn)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert();
    begin
        ValidateAmount;

        GetLabelPrice;
    end;

    trigger OnModify();
    begin
        ValidateAmount;
    end;

    var
        rH: Record "eShop-Order";
        //rS : Record "48003062";
        rItem: Record Item;
        rVariant: Record "Item Variant";
        rBarcode: Record "LSC Barcodes";
        rSP: Record "Sales Price";

    procedure ValidateAmount();
    begin
        IF "Line Type" = "Line Type"::Item THEN BEGIN
            "Line Amount" := ABS(Quantity) * ItemPrice;
            "Line Amount (FC)" := ABS(Quantity) * "ItemPrice (FC)";
            "Picked Line Amount" := ABS("Picked Quantity") * ItemPrice;
            "Picked Line Amount (FC)" := ABS("Picked Quantity") * "ItemPrice (FC)";

            IF "Picked Quantity" = Quantity THEN
                "Line Status" := "Line Status"::Picked
            ELSE
                "Line Status" := "Line Status"::Pending;
        END;

        IF "Line Type" = "Line Type"::Charge THEN BEGIN
            "Line Amount" := ItemPrice;
            "Picked Line Amount" := ItemPrice;
            "Line Amount (FC)" := "ItemPrice (FC)";
            "Picked Line Amount (FC)" := "ItemPrice (FC)";
            "Line Status" := "Line Status"::" ";

        END;

        /*IF rH.GET("Order Type",WebOrderId) THEN BEGIN
          rH.CalcLineStatus(TRUE);
          rS.GET(rH."Order Type");
          "Location Code" := rS."Eshop Location Code";
        END;*/
    end;

    procedure UpdateInfo();
    begin
        //UpdateInfo
        IF ("Line Type" = "Line Type"::Item) AND ("Order Type" = "Order Type"::"Outlet NS") THEN BEGIN
            CLEAR(rSP);
            rSP.SETRANGE("Item No.", ItemNo);
            rSP.SETRANGE("Sales Type", rSP."Sales Type"::"Customer Price Group");
            rSP.SETRANGE("Sales Code", '8');
            IF rSP.FINDLAST THEN
                ItemPrice := rSP."Unit Price";
            //
            "Initial Quantity" := Quantity;
            //
            IF (ItemNo <> '') AND (VariantCode <> '') AND (Barcode = '') THEN BEGIN
                CLEAR(rBarcode);
                rBarcode.SETRANGE("Item No.", ItemNo);
                rBarcode.SETRANGE("Variant Code", VariantCode);
                IF rBarcode.FINDFIRST THEN
                    Barcode := rBarcode."Barcode No.";
            END;
            //
            IF (Barcode <> '') AND (ItemNo = '') AND (VariantCode = '') THEN BEGIN
                IF rBarcode.GET(Barcode) THEN
                    Barcode := rBarcode."Barcode No.";
            END;
            //
            IF rItem.GET(ItemNo) THEN
                ItemDescription := COPYSTR(rItem.Description, 1, 30);
        END;
    end;

    procedure GetLabelPrice();
    begin
        /*IF "Order Type" = "Order Type"::"Outlet NS" THEN BEGIN
          CLEAR(rSP);
          rSP.SETRANGE("Item No.",ItemNo);
          rSP.SETRANGE("Sales Type",rSP."Sales Type"::"Customer Price Group");
          rSP.SETRANGE("Sales Code",'3');
          IF rSP.FINDLAST THEN
            "Label Price" := rSP."Unit Price Including VAT";
        END;*/
    end;
}

