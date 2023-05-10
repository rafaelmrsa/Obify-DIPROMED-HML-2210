#INCLUDE "PROTHEUS.CH"
/*=======================================================================================\
| Programa:     | DIPR105()                                        | Data: 29/07/2021   |
|========================================================================================|
| Cliente:      |                                                                        |
|========================================================================================|
| Resp.Cliente: |                                                                        |
|========================================================================================|
| Uso:          | Itens de Documento de Entrada e Movimentações                          |
|========================================================================================|
| Autor:        | Andre Mendes - Obify (11) 97150-0600                                   |
|========================================================================================| 
| Alteracoes:   |                                                                        |
|               |                                                                        |
\=======================================================================================*/
User Function DIPR105() 
    Private oRpt


    Pergunte("DIPR10501",.F.)
    oRpt := ReportDef()
    oRpt:PrintDialog() 

Return

//=============================
Static Function ReportDef()
//=============================
Private oSec1,oSec2,oBreak1

oRpt  := TReport():New("DIPR105", "Itens de Documento de Entrada e Movimentacoes", "DIPR10501", {|oRpt| PrintReport(oRpt)},"Itens de Documento de Entrada e Movimentacoes")
oRpt:SetLandScape()

oSec1 := TRSection():New(oRpt,"Itens de Documentos","ITDOC",{})
TRCell():New(oSec1,"D2_FILIAL"    ,"ITDOC",RetTitle("D2_FILIAL")     ,PesqPict("SD2","D2_FILIAL")     ,TamSx3("D2_FILIAL")[1]      ,/*lPixel*/,{|| ITDOC->D2_FILIAL     } )
TRCell():New(oSec1,"D2_LOCAL"     ,"ITDOC",RetTitle("D2_LOCAL")     ,PesqPict("SD2","D2_LOCAL")     ,TamSx3("D2_LOCAL")[1]      ,/*lPixel*/,{|| ITDOC->D2_LOCAL     } )
TRCell():New(oSec1,"D2_COD"    ,"ITDOC",RetTitle("D2_COD")     ,PesqPict("SD2","D2_COD")     ,TamSx3("D2_COD")[1]      ,/*lPixel*/,{|| ITDOC->D2_COD     } )
TRCell():New(oSec1,"B1_DESC"    ,"ITDOC",RetTitle("B1_DESC")     ,PesqPict("SB1","B1_DESC")     ,TamSx3("B1_DESC")[1]      ,/*lPixel*/,{|| ITDOC->B1_DESC     } )
TRCell():New(oSec1,"B1_UM"    ,"ITDOC",RetTitle("D2_FILIAL")     ,PesqPict("SD2","D2_FILIAL")     ,TamSx3("D2_FILIAL")[1]      ,/*lPixel*/,{|| ITDOC->D2_FILIAL     } )
TRCell():New(oSec1,"D2_LOTECTL"    ,"ITDOC",RetTitle("D2_LOTECTL")     ,PesqPict("SD2","D2_LOTECTL")     ,TamSx3("D2_LOTECTL")[1]      ,/*lPixel*/,{|| ITDOC->D2_LOTECTL     } )
TRCell():New(oSec1,"D2_DOC"    ,"ITDOC",RetTitle("D2_DOC")     ,PesqPict("SD2","D2_DOC")     ,TamSx3("D2_DOC")[1]      ,/*lPixel*/,{|| ITDOC->D2_DOC     } )
TRCell():New(oSec1,"D2_EMISSAO"    ,"ITDOC",RetTitle("D2_EMISSAO")     ,PesqPict("SD2","D2_EMISSAO")     ,TamSx3("D2_EMISSAO")[1]      ,/*lPixel*/,{|| ITDOC->D2_EMISSAO     } )
TRCell():New(oSec1,"F4_TEXTO"    ,"ITDOC",RetTitle("F4_TEXTO")     ,PesqPict("SF4","F4_TEXTO")     ,TamSx3("F4_TEXTO")[1]      ,/*lPixel*/,{|| ITDOC->F4_TEXTO     } )
TRCell():New(oSec1,"D2_QUANT"    ,"ITDOC",RetTitle("D2_QUANT")     ,PesqPict("SD2","D2_QUANT")     ,TamSx3("D2_QUANT")[1]      ,/*lPixel*/,{|| ITDOC->D2_QUANT     } )
TRCell():New(oSec1,"A1_COD"    ,"ITDOC",RetTitle("A1_COD")     ,PesqPict("SA1","A1_COD")     ,TamSx3("A1_COD")[1]      ,/*lPixel*/,{|| ITDOC->A1_COD     } )
TRCell():New(oSec1,"A1_NOME"    ,"ITDOC",RetTitle("A1_NOME")     ,PesqPict("SA1","A1_NOME")     ,TamSx3("A1_NOME")[1]      ,/*lPixel*/,{|| ITDOC->A1_NOME     } )
TRCell():New(oSec1,"A1_DDD"    ,"ITDOC",RetTitle("A1_DDD")     ,PesqPict("SA1","A1_DDD")     ,TamSx3("A1_DDD")[1]      ,/*lPixel*/,{|| ITDOC->A1_DDD     } )
TRCell():New(oSec1,"A1_TEL"    ,"ITDOC",RetTitle("A1_TEL")     ,PesqPict("SA1","A1_TEL")     ,TamSx3("A1_TEL")[1]      ,/*lPixel*/,{|| ITDOC->A1_TEL     } )
TRCell():New(oSec1,"A1_TELDIP"    ,"ITDOC",RetTitle("A1_TELDIP")     ,PesqPict("SA1","A1_TELDIP")     ,TamSx3("A1_TELDIP")[1]      ,/*lPixel*/,{|| ITDOC->A1_TELDIP     } )
TRCell():New(oSec1,"A1_EMAIL"    ,"ITDOC",RetTitle("A1_EMAIL")     ,PesqPict("SA1","A1_EMAIL")     ,TamSx3("A1_EMAIL")[1]      ,/*lPixel*/,{|| ITDOC->A1_EMAIL     } )

oSec2 := TRSection():New(oRpt,"Movimentos", "MOVIT", {})

TRCell():New(oSec2,"D3_LOCAL"   ,"MOVIT",RetTitle("D3_LOCAL") ,PesqPict("SD3","D3_LOCAL") ,TamSx3("D3_LOCAL")[1]  ,/*lPixel*/,{||     MOVIT->D3_LOCAL } )
TRCell():New(oSec2,"D3_DOC"     ,"MOVIT",RetTitle("D3_LOCAL") ,PesqPict("SD3","B1_DESC"   ) ,TamSx3("B1_DESC"   )[1]  ,/*lPixel*/,{|| MOVIT->D3_DOC    } )
TRCell():New(oSec2,"D3_COD"     ,"MOVIT",RetTitle("D3_COD") ,PesqPict("SD3","D3_COD"  ) ,TamSx3("D3_COD"  )[1]  ,/*lPixel*/,{|| MOVIT->D3_COD        } )
TRCell():New(oSec2,"D3_LOTECTL" ,"MOVIT",RetTitle("D3_LOTECTL") ,PesqPict("SD3","D3_LOTECTL"  ) ,TamSx3("D3_LOTECTL"  )[1]  ,/*lPixel*/,{|| MOVIT->D3_LOTECTL        } )
TRCell():New(oSec2,"D3_QUANT"   ,"MOVIT",RetTitle("D3_QUANT") ,PesqPict("SD3","D3_QUANT"  ) ,TamSx3("D3_QUANT"  )[1]  ,/*lPixel*/,{|| MOVIT->D3_QUANT        } )
TRCell():New(oSec2,"D3_TM"      ,"MOVIT",RetTitle("D3_TM") ,PesqPict("SD3","D3_TM"  ) ,TamSx3("D3_TM"  )[1]  ,/*lPixel*/,{|| MOVIT->D3_TM        } )
TRCell():New(oSec2,"D3_EMISSAO" ,"MOVIT",RetTitle("D3_EMISSAO") ,PesqPict("SD3","D3_EMISSAO"  ) ,TamSx3("D3_EMISSAO"  )[1]  ,/*lPixel*/,{|| MOVIT->D3_EMISSAO        } )
TRCell():New(oSec2,"D3_EXPLIC"  ,"MOVIT",RetTitle("D3_EXPLIC") ,PesqPict("SD3","D3_EXPLIC"  ) ,TamSx3("D3_EXPLIC"  )[1]  ,/*lPixel*/,{|| MOVIT->D3_EXPLIC        } )




Return(oRpt)

//================================
Static Function PrintReport(oRpt)
//================================


oSec1 := oRpt:Section(1)
oSec2 := oRpt:Section(2)



         
                                                                                                                      
#IFDEF TOP

    oSec1:BeginQuery()
        BeginSQL Alias "ITDOC"
            SELECT
                D2_FILIAL,
                D2_LOCAL,
                D2_COD,
                B1_DESC,
                B1_UM,
                D2_LOTECTL,
                D2_DOC,
                D2_EMISSAO,
                F4_TEXTO,
                D2_QUANT,
                A1_COD,
                A1_NOME,
                A1_DDD,
                A1_TEL,
                A1_TELDIP,
                A1_EMAIL 
            FROM
                %Table:SD2% ,
                %Table:SA1% ,
                %Table:SB1% ,
                %Table:Sf4%  
            WHERE
                SD2010.%notdel%
                AND SA1010.%notdel% 
                AND SB1010.%notdel% 
                AND SF4010.%notdel% 
                AND D2_TES = F4_CODIGO 
                AND D2_FILIAL = F4_FILIAL 
                AND D2_COD = B1_COD 
                AND D2_FILIAL = B1_FILIAL 
                AND A1_COD = D2_CLIENTE 
                AND D2_COD  BETWEEN %Exp:Mv_Par01%  AND %Exp:Mv_Par02% 
                AND D2_LOTECTL BETWEEN %Exp:Mv_Par03%  AND %Exp:Mv_Par04%
                AND A1_COD BETWEEN %Exp:Mv_Par05%  AND %Exp:Mv_Par06%
            ORDER BY
                D2_COD,
                D2_EMISSAO
                
       
            
        EndSQL
    oSec1:EndQuery()
    oSec1:Print()
    oRpt:EndPage( .t. )
    oRpt:StartPage() 
    oSec2:BeginQuery()
        BeginSQL Alias "MOVIT"
           
        SELECT
            D3_LOCAL,
            D3_DOC,
            D3_COD,
            D3_LOTECTL,
            D3_QUANT,
            D3_TM,
            D3_EMISSAO,
            D3_EXPLIC 
        FROM
            %Table:SD3% 
        WHERE
            SD3010.%notdel% 
            AND D3_COD BETWEEN %Exp:Mv_Par01%  AND %Exp:Mv_Par02% 
            AND D3_LOTECTL BETWEEN %Exp:Mv_Par03%  AND %Exp:Mv_Par04%
            AND D3_DOC NOT LIKE ('%SZP%') 
            AND D3_EXPLIC <> '' 
        ORDER BY
            D3_QUANT
            
        EndSQL
    oSec2:EndQuery()
    oSec2:Print()


#ENDIF

Return()

