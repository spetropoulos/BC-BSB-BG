codeunit 50003 "Item Label"
{

    TableNo = "LSC Item Label";

    trigger OnRun()
    var
        PrinterSelection: Record "Printer Selection";
        VariantReg: Record "LSC Item Variant Registration";
        BOPrintUtil: Codeunit "LSC BO Print Utility";
        BarcodeManagement: Codeunit "LSC Barcode Management";
        OStream: OutStream;
        IStream: InStream;
        ErrorText: Text;
        Intamount: Integer;
        Text001: Label 'There is nothing to print. ';
        CodeLabel: Label 'Код:';
        CCodeLabel: Label 'Код цвят:';
        SizeLabel: Label 'Размер:';
        PriceLabel: Label 'Цена:';
        DistrLabel: Label 'Дистрибутор:';
        CompanyLabel: Label 'БИ ЕНД ЕФ БЪЛГАРИЯ ЛИМИТЕД ЕООД';
        CompositionLabel: Label 'Състав:';
        ExtraPrinting: Record BSB_Extra_Printing;
        GLSetup: Record "General Ledger Setup";
        ExtVarValue: Record "LSC Extd. Variant Values";
        PriceText: Text;
        ColorDescr: Text;
    begin
        ItemLabelRec.CopyFilters(Rec);
        if ItemLabelRec.FindSet then begin
            InitPrint(ItemLabelRec."Label Code", OStream);
            repeat

                OStream.WriteText(LineEnd);
                OStream.WriteText('N' + LineEnd);
                OStream.WriteText('I8,10,001' + LineEnd);
                OStream.WriteText('q480' + LineEnd);
                OStream.WriteText('Q360,32' + LineEnd);

                OStream.WriteText('A12,20,0,3,1,1,N,"' + CodeLabel + ' ' + ItemLabelRec."Item No." + ' ' + CopyStr(ItemLabelRec."Text 1", 1, 22) + '"' + LineEnd);
                OStream.WriteText('A12,48,0,3,1,1,N,"' + CopyStr(ItemLabelRec."Text 1", 22, 39) + '"' + LineEnd);
                VariantReg.Reset();
                VariantReg.FindFirst();


                VariantReg.Reset();
                VariantReg.SetRange("Item No.", ItemLabelRec."Item No.");
                VariantReg.SetRange(Variant, ItemLabelRec.Variant);
                if VariantReg.FindFirst() then begin
                    ExtVarValue.Reset();
                    ExtVarValue.SetRange("Item No.", ItemLabelRec."Item No.");
                    ExtVarValue.SetRange(Code, 'COLOR');
                    ExtVarValue.SetRange(Value, VariantReg."Variant Dimension 1");
                    IF ExtVarValue.FindFirst() then
                        ColorDescr := ExtVarValue.Description;

                    OStream.WriteText('A12,76,0,3,1,1,N,"' + CCodeLabel + ' ' + VariantReg."Variant Dimension 1" + ' ' + ColorDescr + '"' + LineEnd);
                    OStream.WriteText('A12,104,0,3,1,1,N,"' + SizeLabel + VariantReg."Variant Dimension 2" + '"' + LineEnd);
                end;
                GLSetup.Get();
                PriceText := Format(ItemLabelRec."Price on Item Label", 0, '<Precision,2:2><Standard Format,0>');
                OStream.WriteText('A12,132,0,3,1,1,N,"' + PriceLabel + ' ' + PriceText + ' ' + GLSetup."Local Currency Symbol" + '"' + LineEnd);
                OStream.WriteText('A12,160,0,3,1,1,N,"' + DistrLabel + ' ' + CopyStr(CompanyLabel, 1, 18) + '"' + LineEnd);
                OStream.WriteText('A12,188,0,3,1,1,N,"' + CopyStr(CompanyLabel, 19) + '"' + LineEnd);
                if ExtraPrinting.Get(ItemLabelRec."Item No.") then begin
                    OStream.WriteText('A12,216,0,3,1,1,N,"' + CompositionLabel + ' ' + CopyStr(ExtraPrinting.Description, 1, 26) + '"' + LineEnd);
                    OStream.WriteText('A12,244,0,3,1,1,N,"' + CopyStr(ExtraPrinting.Description, 27, 39) + '"' + LineEnd);
                end;
                OStream.WriteText('B12,272,0,' + BarcodeManagement.GetBarcodeTypeEPL(ItemLabelRec."Barcode No.") + ',2,7,60,B,"' + ItemLabelRec."Barcode No." + '"' + LineEnd);

                OStream.WriteText('P' + Format(ItemLabelRec.Quantity) + LineEnd);
                OStream.WriteText('N' + LineEnd);
                OStream.WriteText(LineEnd);
                UpdateLabelStatus;
            until ItemLabelRec.Next = 0;
        end else
            Error(Text001 + ItemLabelRec.GetFilters);

        // Add boundary to stream
        OStream.WriteText('--boundary');
        OStream.WriteText(LineEnd);

        TempBlob.CreateInStream(IStream, TextEncoding::MSDos);
        PrinterSelection."Printer Name" := LabelPrinter."Hardware Station Printer";
        PrinterSelection."LSC Print to File" := LabelPrinter."Print to File";
        BOPrintUtil.DoPrint(IStream, BOPrintUtil.GetLabelPrinterUrl(LabelPrinter."Hardware Station Printer"), PrinterSelection, ErrorText);

        if ErrorText <> '' then
            Error(ErrorText);
    end;

    var
        LabelPrinter: Record "LSC Label Printer Selection";
        ItemLabelRec: Record "LSC Item Label";
        TempBlob: Codeunit "Temp Blob";
        LineEnd: Text;

    local procedure InitPrint(LabelCode: Code[20]; var OStream_p: OutStream)
    var
        NoLabelPrinter: Label 'No Printer defined for Item Label.';
        CR: Char;
        LF: Char;
    begin
        if not LabelPrinter.Get(UserId, LabelPrinter."Label Type"::"Item Label", LabelCode) then
            if not LabelPrinter.Get('', LabelPrinter."Label Type"::"Item Label", LabelCode) then
                error(NoLabelPrinter);

        CR := 13;
        LF := 10;
        LineEnd := Format(CR) + Format(LF);

        TempBlob.CreateOutStream(OStream_p, TextEncoding::MSDos);
        // Add boundary to stre
        OStream_p.WriteText('--boundary' + LineEnd);
        OStream_p.WriteText('Content-Type: application/octet-stream' + LineEnd);
        OStream_p.WriteText(LineEnd);
    end;

    procedure AlignAmount(Amount: Integer): Text
    begin
        case Amount of
            0 .. 9:
                exit(Format(560));
            10 .. 99:
                exit(Format(450));
            100 .. 999:
                exit(Format(340));
            1000 .. 9999:
                exit(Format(230));
            10000 .. 99999:
                exit(Format(120));
            100000 .. 999999:
                exit(Format(10));
        end;
    end;

    procedure UpdateLabelStatus()
    var
        ItemLabelPoster2: Record "LSC Item Label";
    begin
        ItemLabelPoster2 := ItemLabelRec;
        ItemLabelPoster2.Printed := true;
        ItemLabelPoster2."Date Last Printed" := Today;
        ItemLabelPoster2."Time Last Printed" := Time;
        ItemLabelPoster2.Modify;
    end;
}

