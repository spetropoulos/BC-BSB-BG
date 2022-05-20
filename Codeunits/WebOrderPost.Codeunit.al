codeunit 50000 "Web Order Post"
{
    procedure PostOrder(var EshopOrder: Record "eShop-Order")
    var
        LastReceiptNo: Code[20];
        Globals: Codeunit "LSC POS Session";
        POSView: Codeunit "LSC POS View";
        PosTransaction: record "LSC POS Transaction";
        cPOSTrans: Codeunit "LSC POS Transaction";
        StoreSetup: Record "LSC Store";
        xCust: code[20];
        Customer: Record Customer;
        TenderType: Record "LSC Tender Type";
        PosPostUtility: Codeunit "LSC POS Post Utility";
    begin
        CheckTenderType(EshopOrder);

        LastReceiptNo := GetLastReceipt(Globals.StoreNo(), Globals.TerminalNo());
        LastReceiptNo := INCSTR(LastReceiptNo);
        LastReceiptNo := cPOSTrans.GetReceiptNo();
        StoreSetup.Get(Globals.StoreNo());
        PosTransaction."Receipt No." := ZeroPad(Globals.TerminalNo(), 10) + ZeroPad(LastReceiptNo, 9);
        PosTransaction."Store No." := Globals.StoreNo();
        PosTransaction."POS Terminal No." := Globals.TerminalNo();
        PosTransaction."Created on POS Terminal" := Globals.TerminalNo();
        PosTransaction."Staff ID" := Globals.StaffID();
        PosTransaction."Shift No." := '';
        PosTransaction."VAT Bus.Posting Group" := StoreSetup."Store VAT Bus. Post. Gr.";
        PosTransaction."Sale Is Return Sale" := FALSE;
        PosTransaction."Sales Type" := '';
        PosTransaction."Entry Status" := PosTransaction."Entry Status"::" ";
        //PosTransaction.Location                := StoreSetup."Location Code";
        PosTransaction."New Transaction" := FALSE;
        PosTransaction."Trans. Date" := TODAY;
        //PosTransaction."Distribution Channel"  := StoreSetup."Distribution Channel";
        PosTransaction."Original Date" := PosTransaction."Trans. Date";
        PosTransaction."Trans Time" := TIME;
        PosTransaction.VALIDATE("Trans. Currency Code", StoreSetup."Currency Code");
        PosTransaction."Transaction Type" := PosTransaction."Transaction Type"::Sales;

        //ggg 19.05.22
        xCust := CreateCustomer(EshopOrder);
        //xCust := EshopOrder."Customer No.";

        PosTransaction."Customer No." := xCust;

        IF Customer.GET(PosTransaction."Customer No.") THEN
            PosTransaction."VAT Bus.Posting Group" := Customer."VAT Bus. Posting Group";

        PosTransaction."Web Order No." := EshopOrder.WebOrderId;
        PosTransaction."Web Order Code" := EshopOrder.BlanketOrderNo;
        //PosTransaction."Post Infocode"       := rWO."Post Infocode";

        //PosTransaction."Cloudbiz Loyalty No" := rWO."Loyalty Card No.";        

        /*rInfo.GET(PosTransaction."Post Infocode");

        PosTransaction."Post Series"   := PosFunctions.GetNoSeriesCode(rInfo."Transaction Series Setup",PosTransaction."Store No.",PosTransaction."POS Terminal No.");
        PosTransaction."Allow Refund"  := rInfo."Allow Refund";
        PosTransaction."Allow Cancel"  := rInfo."Allow Cancel";
        PosTransaction."Shipment Reason" := rInfo."Shipment Reason";
        PosTransaction.Location := StoreSetup."Location Code";*/

        if not PosTransaction.INSERT then PosTransaction.modify;

        InsertTransactionLines(EshopOrder.WebOrderId, PosTransaction);

        WEBCreatePayment1(EshopOrder, POSTransaction);

        PosTransaction.CALCFIELDS("Gross Amount", Payment);


        IF PosTransaction."Gross Amount" <> PosTransaction.Payment THEN ERROR('Error!!! Difference in payment vs Transaction.\Fix WEB Order and retry!!!');

        Do_BGTransUpdate(PosTransaction);

        CLEAR(PosPostUtility);
        gTransNo := PosPostUtility.ProcessTransaction(PosTransaction);

        COMMIT;
        //        cPOSTrans.StartNewTransaction();
        cPOSTrans.InsertTmpTransaction(false);
    end;

    local procedure GetLastReceipt(StoreNo: code[20]; TerminalNo: code[20]): code[20]
    var
        Transaction: Record "LSC Transaction Header";
        PosTrans: record "LSC POS Transaction";
        LastSlipNo: Code[20];
    begin
        LastSlipNo := '000000000';
        Transaction.Reset();
        Transaction.SetRange("Store No.", StoreNo);
        Transaction.SetRange("POS Terminal No.", TerminalNo);
        Transaction.SETRANGE("Receipt No.", ZeroPad(TerminalNo, 10) + '000000000',
        ZeroPad(TerminalNo, 10) + '999999999');
        IF Transaction.FINDLAST THEN
            LastSlipNo := COPYSTR(Transaction."Receipt No.", 11);

        POSTrans.SETRANGE("Receipt No.", ZeroPad(TerminalNo, 10) + '000000000',
        ZeroPad(TerminalNo, 10) + '999999999');
        IF POSTrans.FINDLAST THEN
            IF COPYSTR(POSTrans."Receipt No.", 11) > LastSlipNo THEN
                LastSlipNo := COPYSTR(POSTrans."Receipt No.", 11);
        exit(LastSlipNo);
    end;

    local procedure ZeroPad(Str: text[30]; Len: Integer): text[30]
    begin
        Str := '0000000000' + Str;
        Str := COPYSTR(Str, STRLEN(Str) - Len + 1, Len);
        EXIT(Str);
    end;

    local procedure InsertTransactionLines(WebOrderID: Integer; var POSTransaction: Record "LSC POS Transaction")
    var
        EshopOrderLine: Record "eShop-Order Lines";
        LineNo: Integer;
        ActualPayment: Decimal;
    begin
        EshopOrderLine.RESET;
        EshopOrderLine.SETRANGE(WebOrderID, WebOrderID);
        IF EshopOrderLine.FINDSET(FALSE, FALSE) THEN BEGIN
            REPEAT
                LineNo := LineNo + 10000;
                CASE EshopOrderLine."Line Type" OF
                    EshopOrderLine."Line Type"::Item:
                        BEGIN
                            IF EshopOrderLine.Quantity <> 0 THEN WEBCreateItem(EshopOrderLine, POSTransaction, LineNo);
                        END;

                    EshopOrderLine."Line Type"::Charge:
                        BEGIN
                            IF EshopOrderLine."Line Amount" <> 0 THEN WEBCreateShipCharge(POSTransaction, EshopOrderLine, LineNo, EshopOrderLine."Line Amount");
                        END;
                END;

            UNTIL EshopOrderLine.NEXT = 0;

        END;

        POSTransaction.CALCFIELDS("Gross Amount", Payment);

        ActualPayment := POSTransaction."Gross Amount";

        //ggg 19.05.22
        /*IF EshopOrderLine.FINDSET(FALSE, FALSE) THEN BEGIN
            REPEAT
                LineNo := LineNo + 10000;
                CASE EshopOrderLine."Line Type" OF
                    EshopOrderLine."Line Type"::Payment:
                        BEGIN
                            EshopOrderLine."Line Amount" := ActualPayment;
                            WEBCreatePayment(EshopOrderLine, POSTransaction, LineNo);
                        END;
                END;
            UNTIL EshopOrderLine.NEXT = 0;
        END;*/

    end;

    local procedure WebCreateItem(EshopOrderLine: Record "eShop-Order Lines"; POSTransaction: Record "LSC POS Transaction"; var LineNo: Integer)
    var
        POSTransactionLine: Record "LSC POS Trans. Line";
        VATCode: Record "LSC POS VAT Code";
        Item: Record Item;
    begin

        IF EshopOrderLine."Picked Quantity" = 0 THEN EXIT;

        CLEAR(POSTransactionLine);

        VATCode.SETRANGE("VAT %", EshopOrderLine.VATPercent);

        POSTransactionLine."Receipt No." := POSTransaction."Receipt No.";
        POSTransactionLine."Line No." := LineNo + 10000;
        POSTransactionLine."Store No." := POSTransaction."Store No.";
        POSTransactionLine."POS Terminal No." := POSTransaction."POS Terminal No.";
        POSTransactionLine."Web Order No." := EshopOrderLine.WebOrderId;
        //POSTransactionLine."Web Order Line No."   := EshopOrderLine."Line No.";
        IF EshopOrderLine."Line Type" = EshopOrderLine."Line Type"::Item THEN BEGIN
            IF EshopOrderLine.Quantity <> 0 THEN BEGIN
                ITEM.RESET;
                ITEM.GET(EshopOrderLine.ItemNo);
                POSTransactionLine.Number := EshopOrderLine.ItemNo;
                POSTransactionLine."Price Change" := TRUE;
                //POSTransactionLine."Keep Prices"          := TRUE;
                //POSTransactionLine."Keep Doc. Price"      := TRUE;
                POSTransactionLine.VALIDATE(Number);
                POSTransactionLine."Entry Type" := POSTransactionLine."Entry Type"::Item;
                POSTransactionLine."Variant Code" := EshopOrderLine.VariantCode;
                POSTransactionLine."Unit of Measure" := ITEM."Base Unit of Measure";
                //POSTransactionLine."Location Code" := POSTransaction.Location;
                POSTransactionLine.Description := ITEM.Description;

            END;
        END;
        POSTransactionLine.INSERT;

        IF VATCode.FINDFIRST THEN
            POSTransactionLine.VALIDATE("VAT Code", VATCode."VAT Code");
        POSTransactionLine.VALIDATE("VAT %", EshopOrderLine.VATPercent);
        POSTransactionLine."Parent Line" := POSTransactionLine."Line No.";

        POSTransactionLine.Price := EshopOrderLine."ItemPrice (FC)";
        POSTransactionLine.VALIDATE(Quantity, ABS(EshopOrderLine."Picked Quantity"));
        POSTransactionLine.Amount := EshopOrderLine."Picked Line Amount (FC)";
        POSTransactionLine."Discount Amount" := POSTransactionLine.Price * POSTransactionLine.Quantity - POSTransactionLine.Amount;
        CalcPricesWEB(POSTransactionLine);
        POSTransactionLine.MODIFY;
    end;

    local procedure CalcPricesWeb(var POSTransactionLine: Record "LSC POS Trans. Line")
    var
        PosFuncProfile: Record "LSC POS Func. Profile";
    begin
        //"Keep Prices" := TRUE;

        POSTransactionLine.GetGeneralPosFunctionality(POSTransactionLine."Store No.", PosFuncProfile);

        IF POSTransactionLine."Net Price" = 0 THEN
            POSTransactionLine."Net Price" := ROUND(POSTransactionLine.Price / (1 + (POSTransactionLine."VAT %" / 100)), PosFuncProfile."Amount Rounding to");

        POSTransactionLine."Discount Amount" := ROUND((POSTransactionLine.Price * POSTransactionLine.Quantity) - POSTransactionLine.Amount, PosFuncProfile."Amount Rounding to");
        POSTransactionLine."Line Disc. %" := 0;
        POSTransactionLine."Discount %" := 0;
        IF POSTransactionLine."Entry Type" <> POSTransactionLine."Entry Type"::Payment THEN
            IF POSTransactionLine."Discount Amount" <> 0 THEN
                IF POSTransactionLine."Line Disc. %" = 0 THEN BEGIN
                    POSTransactionLine."Line Disc. %" :=
                    (1 - POSTransactionLine.Amount / (POSTransactionLine.Amount + POSTransactionLine."Discount Amount")) * 100;
                    POSTransactionLine."Discount %" := POSTransactionLine."Line Disc. %"
                END;

        IF POSTransactionLine."Total Disc. %" <> 0 THEN
            POSTransactionLine."Total Disc. Amount" := ROUND(POSTransactionLine.Amount * (POSTransactionLine."Total Disc. %" / 100), PosFuncProfile."Amount Rounding to");

        POSTransactionLine."Net Amount" := ROUND(POSTransactionLine.Amount / (1 + (POSTransactionLine."VAT %" / 100)), PosFuncProfile."Amount Rounding to");   //lsgr-012

        POSTransactionLine."VAT Amount" := POSTransactionLine.Amount - POSTransactionLine."Net Amount";

        POSTransactionLine."Cost Amount" := POSTransactionLine."Cost Price" * POSTransactionLine.Quantity;
    end;

    local procedure WEBCreateShipCharge(POSTransaction: Record "LSC POS Transaction"; EshopOrderLine: Record "eShop-Order Lines"; LineNo: Integer; ChargeAmt: Decimal)
    var
        POSTransLine: Record "LSC POS Trans. Line";
        VATCode: record "LSC POS VAT Code";
        RetailSetup: Record "LSC Retail Setup";
        Item: Record Item;
    begin
        RetailSetup.GET;

        CLEAR(POSTransLine);

        VATCode.SETRANGE("VAT %", RetailSetup."Shipping Charge VAT%");

        POSTransLine."Receipt No." := POSTransaction."Receipt No.";
        POSTransLine."Line No." := LineNo + 10000;
        POSTransLine."Store No." := POSTransaction."Store No.";
        POSTransLine."POS Terminal No." := POSTransaction."POS Terminal No.";
        POSTransLine."Web Order No." := EshopOrderLine.WebOrderId;
        //POSTransLine."Web Order Line No."   := EshopOrderLine."Line No.";
        ITEM.RESET;

        //        IF NOT ITEM.GET(RetailSetup."Shipping Charge Item No.") THEN ERROR('Missing Shipping Charge Item No. from Retail Setup!!!!');
        IF NOT ITEM.GET(EshopOrderLine.ItemNo) THEN ERROR('Missing Charge Item No. from Retail DB!!!!');

        POSTransLine.Number := EshopOrderLine.ItemNo;
        POSTransLine.VALIDATE(Number);
        POSTransLine."Entry Type" := POSTransLine."Entry Type"::Item;
        POSTransLine."Variant Code" := '';
        POSTransLine."Unit of Measure" := ITEM."Base Unit of Measure";
        //POSTransLine."Location Code"        := POSTransaction.Location;
        POSTransLine."Price Change" := TRUE;
        //POSTransLine."Keep Prices"          := TRUE;
        POSTransLine.Description := ITEM.Description;

        POSTransLine.INSERT;

        IF VATCode.FINDFIRST THEN
            POSTransLine.VALIDATE("VAT Code", VATCode."VAT Code");
        POSTransLine.VALIDATE("VAT %", RetailSetup."Shipping Charge VAT%");
        POSTransLine."Parent Line" := POSTransLine."Line No.";

        POSTransLine.Price := ROUND(ChargeAmt, 0.01);
        POSTransLine.VALIDATE(Quantity, 1);
        POSTransLine.Amount := ChargeAmt;
        CalcPricesWEB(POSTransLine);
        POSTransLine.MODIFY;
    end;

    local procedure WEBCreatePayment(EshopOrderLine: Record "eShop-Order Lines"; POSTransaction: Record "LSC POS Transaction"; var LineNo: Integer)
    var
        POSTransLine: record "LSC POS Trans. Line";
        TenderType: Record "LSC Tender Type Setup";
        WebMapping: Record "Web Mapping";
        EshopOrder: Record "eShop-Order";
    begin
        EshopOrder.SetRange(WebOrderId, EshopOrderLine.WebOrderId);
        EshopOrder.FindFirst();

        WebMapping.Get(WebMapping.Type::Payment, EshopOrder.PaymentMethodId);
        TenderType.RESET;
        TenderType.GET(WebMapping.LSID);

        CLEAR(POSTransLine);
        POSTransLine."Receipt No." := POSTransaction."Receipt No.";
        POSTransLine."Line No." := LineNo + 10000;
        POSTransLine."Store No." := POSTransaction."Store No.";
        POSTransLine."POS Terminal No." := POSTransaction."POS Terminal No.";

        POSTransLine."Web Order No." := EshopOrderLine.WebOrderId;
        //POSTransLine."Web Order Line No."   := EshopOrderLine."Line No.";

        IF EshopOrderLine."Line Type" = EshopOrderLine."Line Type"::Payment THEN BEGIN
            POSTransLine."Entry Type" := POSTransLine."Entry Type"::Payment;
            POSTransLine.Quantity := 1;
            POSTransLine.Description := TenderType.Description;
            POSTransLine.VALIDATE(Number, TenderType.Code);
            POSTransLine."Parent Line" := POSTransLine."Line No.";
        END;
        POSTransLine.INSERT;

        //POSTransLine.VALIDATE(Amount, EshopOrderLine."Line Amount");
        POSTransLine.VALIDATE(Amount, EshopOrder.PaymentAmount);
        POSTransLine.MODIFY;
    end;

    local procedure CheckTenderType(EshopOrder: Record "eshop-order")
    var
        WebMapping: record "Web Mapping";
        TenderType: Record "LSC Tender Type Setup";
        __InvalidTenderType: Label 'Invalid Tender Type!';
    begin

        if not WebMapping.Get(WebMapping.Type::Payment, EshopOrder.PaymentMethodId) then
            Error(__InvalidTenderType);

        if not TenderType.Get(WebMapping.LSID) then
            Error(__InvalidTenderType);
    end;

    local procedure Do_BGTransUpdate(var POSTransaction: Record "LSC POS Transaction")
    var
        POSTransLine: Record "LSC POS Trans. Line";
        Globals: Codeunit "LSC POS Session";
        rStaff: Record "LSC Staff";
        Subscribers: codeunit "FBG Codeunit Subscribers";
    begin
        WITH POSTransaction DO BEGIN
            IF ("Transaction Type" = "Transaction Type"::Sales) AND ("FBG_Unique Sales No." = '') AND NOT "Sale Is Return Sale" THEN BEGIN
                rStaff.GET(Globals.StaffID);
                "Staff ID" := rStaff.ID;
                "Trans. Date" := TODAY;
                "Trans Time" := TIME;
                "FBG_Staff UNP ID" := rStaff."FBG_UNP ID";
                //"FBG_Staff Role"   := rStaff."Permission Group";
                //"FBG_User Role"    := GetUserRole;
                "FBG_Unique Sales No." := Subscribers.GenerateUNP(POSTransaction);
                MODIFY;
            END;

            POSTransLine.SETRANGE("Receipt No.", "Receipt No.");
            POSTransLine.SETRANGE("Entry Type", POSTransLine."Entry Type"::Item);
            IF POSTransLine.FINDSET THEN
                REPEAT
                    POSTransLine."FBG_Unique Sales No." := "FBG_Unique Sales No.";
                    POSTransLine."FBG_Time When Tras. Started" := "Trans Time";
                    POSTransLine."FBG_Date When Trans. Started" := "Trans. Date";
                    POSTransLine."FBG_Staff UNP ID" := "FBG_Staff UNP ID";
                    POSTransLine."FBG_Staff ID" := "Staff ID";
                    //POSTransLine."Staff Role"                 := "Staff Role";
                    //POSTransLine."User Role"                  := "User Role";
                    POSTransLine.MODIFY;
                UNTIL POSTransLine.NEXT = 0;
        END;
    end;

    local procedure CreateCustomer(var EshopOrder: Record "eShop-Order"): Code[20]
    var
        CustomerTemplate: Record Customer;
        Customer: Record Customer;
        xPrefix: code[10];
    begin
        CustomerTemplate.Get('C0001');
        Customer.Init();
        Customer.Name := EshopOrder.BillingFirstName + ' ' + EshopOrder.BillingLastName;
        Customer."Gen. Bus. Posting Group" := CustomerTemplate."Gen. Bus. Posting Group";
        Customer."VAT Bus. Posting Group" := CustomerTemplate."VAT Bus. Posting Group";
        Customer."Customer Posting Group" := CustomerTemplate."Customer Posting Group";
        Customer."Invoice Disc. Code" := CustomerTemplate."Invoice Disc. Code";
        /*        
                if EshopOrder."Order Type" = EshopOrder."Order Type"::"BSB NS" then xPrefix := 'WB';
                if EshopOrder."Order Type" = EshopOrder."Order Type"::"Lynne NS" then xPrefix := 'WL';
                If EshopOrder.BillingIsInvoice then xPrefix := xPrefix + 'I';

                Customer."No." := xPrefix + format(EshopOrder.CustomerLoginId);
        */
        Customer."No." := EshopOrder."Customer No.";
        Customer.Insert(true);

        Customer.Address := EshopOrder.BillingAddressLine1;
        Customer."Address 2" := EshopOrder.BillingAddressLine2;
        Customer."Post Code" := EshopOrder.BillingPostalCode;
        Customer."Country/Region Code" := EshopOrder.BillingCountryCode;
        Customer.City := EshopOrder.ShippingCity;
        Customer."Phone No." := EshopOrder.BillingPhones;
        Customer."Mobile Phone No." := EshopOrder.BillingMobiles;
        Customer."E-Mail" := EshopOrder.BillingEmail;
        Customer.Modify();
        exit(Customer."No.");
    end;

    local procedure WEBCreatePayment1(EshopOrder: Record "eShop-Order"; POSTransaction: Record "LSC POS Transaction")
    var
        WebMapping: Record "Web Mapping";
        TenderType: Record "LSC Tender Type";
        POSTransLine: Record "LSC POS Trans. Line";
    begin
        WebMapping.Get(WebMapping.Type::Payment, EshopOrder.PaymentMethodId);
        TenderType.RESET;
        TenderType.GET(PosTransaction."Store No.", WebMapping.LSID);

        CLEAR(POSTransLine);
        POSTransLine."Receipt No." := POSTransaction."Receipt No.";
        POSTransLine."Line No." := 10000;
        POSTransLine."Store No." := POSTransaction."Store No.";
        POSTransLine."POS Terminal No." := POSTransaction."POS Terminal No.";

        POSTransLine."Web Order No." := EshopOrder.WebOrderId;
        //POSTransLine."Web Order Line No."   := EshopOrderLine."Line No.";


        POSTransLine."Entry Type" := POSTransLine."Entry Type"::Payment;
        POSTransLine.Quantity := 1;
        POSTransLine.Description := TenderType.Description;
        POSTransLine.VALIDATE(Number, TenderType.Code);
        POSTransLine."Parent Line" := POSTransLine."Line No.";

        POSTransLine.INSERT;

        //POSTransLine.VALIDATE(Amount, EshopOrderLine."Line Amount");
        POSTransLine.VALIDATE(Amount, EshopOrder."PaymentAmount (FC)");
        POSTransLine.MODIFY;
    end;

    var
        gTransNo: Integer;
}