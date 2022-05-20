codeunit 50002 "Web Order Print"
{
    procedure PrintOrder(OrderNo: Integer; var xMSG: text[1000])
    var
        EshopOrder: Record "eShop-Order";
        TransHeader: Record "LSC Transaction Header";
        PrintUtil: codeunit "LSC POS Print Utility";
        CodeunitSubsc: Codeunit "FBG Codeunit Subscribers";
        Phase: Integer;
    begin
        EshopOrder.SetRange(WebOrderId, OrderNo);
        if not EshopOrder.FindFirst() then begin
            xMSG := ('WEB Order ' + FORMAT(OrderNo) + ' not found!!!');
            EXIT;
        END;

        if not EshopOrder.Posted then begin
            xMSG := 'WEB Order ' + Format(OrderNo) + ' is not Posted yet!!!';
            EXIT;
        END;

        TransHeader.RESET;
        IF TransHeader.GET(EshopOrder."Store No.", EshopOrder."POS Terminal No.", EshopOrder."Transaction No.") THEN BEGIN
            IF TransHeader."Entry Status" <> TransHeader."Entry Status"::Voided THEN begin
                CLEAR(PrintUtil);
                IF NOT PrintUtil.PrintSlips(TransHeader, Phase) THEN BEGIN
                    //DS10.0.017; begin
                    CodeunitSubsc.SuspendPostedTrans(TransHeader."Store No.",
                                        TransHeader."POS Terminal No.",
                                        TransHeader."Transaction No.");
                    EshopOrder.Posted := false;
                    EshopOrder.Modify();                    
                    //DS10.0.07; end
                    xMSG := PrintUtil.GetPrintErrorTxt;

                END ELSE
                    xMSG := ('WEB Order ' + Format(OrderNo) + ' printed!!!');

            END;
        END ELSE BEGIN
            xMSG := 'WEB Order ' + Format(OrderNo) + ' is not Posted yet!!!';
        END;
        COMMIT;
    end;
}