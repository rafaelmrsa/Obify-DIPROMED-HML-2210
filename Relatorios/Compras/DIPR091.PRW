/*====================================================================================\
|Programa  | DIPR091.PRW  | Autor  | Reginaldo Borges        | Data | 08/08/2017      |
|=====================================================================================|
|Descri็ใo | Gera o relatorio do Kardex de pedido, a partir de um numero inicial ate  |
|          | o numero final. Ambos fornecidos pelo usuario                            |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR091()                                                                |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|Hist๓rico | 																		  |
\====================================================================================*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)
*-------------------------------------*
User Function DIPR091()                
*-------------------------------------*
Local aDados:={}
Local lQuery
Local lWork
Private aReturn :={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private aRCampos:={}
Private Query
Private aReturn:={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private cString:="ZZW"   

Private cPerg  	:= U_FPADR( "KARDPC","SX1","SX1->X1_GRUPO"," " ) 

U_DIPPROC(ProcName(0),U_DipUsr()) 

AjustaSX1(cPerg)   

	If !Pergunte(cPerg,.T.)  
		Return
	EndIf
    
aAdd(aDados,"TRB") 
aAdd(aDados,OemTOAnsi("Relatorio do Kardex do Pedido de Compras",72))
aAdd(aDados,OemToAnsi("Relatorio de Kardex do Pedido,de acordo com",72))
aAdd(aDados,OemToAnsi("intervalo informado na opcao do Parametros.",72))
aAdd(aDados,"M")
aAdd(aDados,132)
aAdd(aDados,"Do Pedido: "+MV_PAR01+" Ate o Pedido: "+MV_PAR02)
aAdd(aDados,"Por Pedido")
aAdd(aDados,OemTOAnsi("Relatorio do Kardex do Pedido de Compras",72))
aAdd(aDados,aReturn)
aAdd(aDados,"DIPR091") 
aAdd(aDados,{{||.t.},{||.t.}})
aAdd(aDados,Nil)              

aAdd(aRCampos,{"ZZW_PEDIDO" ,"",AvSx3("ZZW_PEDIDO" ,5),AvSx3("ZZW_PEDIDO" ,6)})
aAdd(aRCampos,{"ZZW_TIPMOV" ,"",AvSx3("ZZW_TIPMOV" ,5),AvSx3("ZZW_TIPMOV" ,6)})
aAdd(aRCampos,{"ZZW_DATAMO" ,"",AvSx3("ZZW_DATAMO" ,5),AvSx3("ZZW_DATAMO" ,6)})
aAdd(aRCampos,{"ZZW_HORAMO" ,"",AvSx3("ZZW_HORAMO" ,5),AvSx3("ZZW_HORAMO" ,6)})
aAdd(aRCampos,{"ZZW_USUARI" ,"",AvSx3("ZZW_USUARI" ,5),AvSx3("ZZW_USUARI" ,6)})
aAdd(aRCampos,{"ZZW_DESOCO" ,"",AvSx3("ZZW_DESOCO" ,5),AvSx3("ZZW_TIPMOV" ,6)})
aRCampos:=E_CriaRCampos(aRCampos,"E")  

Processa({|| lQuery := DIPR91FilQuery()},"Filtrando Pedidos no Kardex...",,.t.)

If !lQuery
	MsgInfo(;
	"Nใo encontrado dados que satisfa็am aos"+ENTER+;
	"parametros informados pelo usuario! ","Aten็ใo")
	TRB->(dbCloseArea())
	Return(.t.)
EndIf   
       
TRB->(E_Report(aDados,aRCampos))
TRB->(dbCloseArea())
Return
*----------------------------------*
STATIC FUNCTION DIPR91FilQuery()
*----------------------------------*
Local _x

ProcRegua(500)

For _x := 1 to 250                
	IncProc( "Selecionando Pedidos...")
Next
                                                                                
Query := "SELECT ZZW_FILIAL, ZZW_PEDIDO, ZZW_TIPMOV, SUBSTRING(ZZW_DATAMO,7,2)+'/'+SUBSTRING(ZZW_DATAMO,5,2)+'/'+SUBSTRING(ZZW_DATAMO,1,4) ZZW_DATAMO, ZZW_HORAMO, ZZW_USUARI, ZZW_DESOCO, SUBSTRING(ZZW_DATAMO,1,4)+SUBSTRING(ZZW_DATAMO,5,2)+SUBSTRING(ZZW_DATAMO,7,2) DATAMOV" 
Query += " FROM " + RetSQLName("ZZW")
Query += " WHERE ZZW_FILIAL = '" + xFilial('ZZW') + "'"
Query += "    AND "+RetSQLName("ZZW")+".D_E_L_E_T_ <> '*'"
Query += "    AND ZZW_PEDIDO  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " 
Query += " ORDER BY ZZW_PEDIDO, DATAMOV, ZZW_HORAMO"

#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)

TcQuery Query NEW ALIAS "TRB"
ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Classificando Pedidos... ")
Next
Return(!TRB->(BOF().and.EOF()))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPR091   บAutor  ณMicrosiga           บ Data ณ  08/08/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)
Local aRegs 	:= {}
DEFAULT cPerg 	:= ""

dbSelectArea("SX1")
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Pedido De     ?","1","","mv_ch1","C", 6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"02","Pedido At้    ?","1","","mv_ch2","C", 6,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",''})

PlsVldPerg( aRegs )       

Return
