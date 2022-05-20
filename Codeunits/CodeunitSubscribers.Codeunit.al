codeunit 50001 "Codeunit Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterInsertTransHeader', '', true, true)]
    local procedure OnAfterInsertTransaction(var POSTrans: Record "LSC POS Transaction"; var Transaction: Record "LSC Transaction Header")

    begin
        Transaction."Web Order No." := POSTrans."Web Order No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnBeforeInsertPaymentEntryV2', '', true, true)]
    local procedure OnBeforeInsertPaymentEntryV2(var TransPaymentEntry: Record "LSC Trans. Payment Entry"; var POSTransaction: Record "LSC POS Transaction")
    begin
        TransPaymentEntry."Web Order No." := POSTransaction."Web Order No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'SalesEntryOnBeforeInsertV2', '', true, true)]
    local procedure SalesEntryOnBeforeInsertV2(var pTransSalesEntry: Record "LSC Trans. Sales Entry"; var pPOSTransLineTemp: Record "LSC POS Trans. Line")
    begin
        pTransSalesEntry."Web Order No." := pPOSTransLineTemp."Web Order No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterPostTransaction', '', true, true)]
    local procedure OnAfterPostTransaction(var TransactionHeader_p: Record "LSC Transaction Header")
    var
        EshopOrder: Record "eShop-Order";
    begin
        EshopOrder.SetRange(WebOrderId, TransactionHeader_p."Web Order No.");
        if EshopOrder.FindFirst() then begin
            EshopOrder."Receipt No." := TransactionHeader_p."Receipt No.";
            EshopOrder."Store No." := TransactionHeader_p."Store No.";
            EshopOrder."POS Terminal No." := TransactionHeader_p."POS Terminal No.";
            EshopOrder."Transaction No." := TransactionHeader_p."Transaction No.";
            EshopOrder.Posted := true;
            EshopOrder.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Print Utility", 'OnBeforeCommnetInPrintSubHeader', '', true, true)]
    local procedure OnBeforeCommnetInPrintSubHeader(DSTR1: Text[100]; ValueArray: array[10] of Text[100]; Tray: Integer; var Transaction: Record "LSC Transaction Header"; sender: Codeunit "LSC POS Print Utility")
    var
        Text001: Label 'Receipt';
    begin
        DSTR1 := '#L###### #L################';
        ValueArray[1] := Text001 + ':';
        ValueArray[2] := Transaction."FBG_Global Number";
        Sender.PrintLine(Tray, Sender.FormatLine(Sender.FormatStr(ValueArray, DSTR1), false, true, false, false));
    end;
}