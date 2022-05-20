page 50000 "Print Web Order"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;


    layout
    {
        area(Content)
        {
            group("Web Order")
            {
                field("Web Order No."; xScan)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        xMSG := '';
                        if Evaluate(xScanInt, xScan) then;
                        EShopOrder.SetRange(WebOrderId, xScanInt);
                        if not EShopOrder.FindFirst() then begin
                            xMSG := ('WEB Order ' + xScan + ' not found!!!');
                            exit;
                        end;
                        if not EShopOrder.Posted then begin
                            Clear(WebOrderPost);
                            WebOrderPost.PostOrder(EShopOrder);
                            Clear(WebOrderPrint);
                            WebOrderPrint.PrintOrder(xScanInt, xMSG);
                            Clear(xScan);
                            CurrPage.Update();
                        end else
                            xMSG := ('WEB Order ' + xScan + ' is already posted!!!');


                    end;
                }
                field(Message; xMSG)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    var
        EShopOrder: record "eShop-Order";
        WebOrderPost: codeunit "Web Order Post";
        WebOrderPrint: Codeunit "Web Order Print";
        xScan: Code[50];
        xScanInt: Integer;


        xMSG: Text[100];
}