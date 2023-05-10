/*====================================================================================\
|Programa  | DIPR014.PRW  | Autor  | Jailton B Santos, JBS   | Data | 02 Set 2005     |
|=====================================================================================|
|Descrição | Gera o relatorio do Kardex de pedido, a partir de um numero inicial ate  |
|          | o numero final. Ambos fornecidos pelo usuario                            |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR014()                                                                |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|Histórico | 03 Mai 2007 - Query alterada para ordenar corretamente por data - MCVN   |
\====================================================================================*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)
*-------------------------------------*
User Function DIPR014()                
*-------------------------------------*
Local aDados:={}
Local lQuery
Local lWork
Private aReturn :={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private aRCampos:={}
Private Query
Private aReturn:={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private cString:="SZ9"   
//Private cPerg:="KARDPV"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1
PRIVATE cPerg  	:= U_FPADR( "KARDPV","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

If !Pergunte(cPerg,.T.)  
	Return
EndIf

aAdd(aDados,"TRB") 
aAdd(aDados,OemTOAnsi("Relatorio do Kardex do Pedido de Vendas",72))
aAdd(aDados,OemToAnsi("Relatorio de Kardex do Pedido,de acordo com",72))
aAdd(aDados,OemToAnsi("intervalo informado na opcao do Parametros.",72))
aAdd(aDados,"M")
aAdd(aDados,132)
aAdd(aDados,"Do Pedido: "+MV_PAR01+" Ate o Pedido: "+MV_PAR02)
aAdd(aDados,"Por Pedido")
aAdd(aDados,OemTOAnsi("Relatorio do Kardex do Pedido de Vendas",72))
aAdd(aDados,aReturn)
aAdd(aDados,"DIPR014") 
aAdd(aDados,{{||.t.},{||.t.}})
aAdd(aDados,Nil)              

aAdd(aRCampos,{"Z9_PEDIDO" ,"",AvSx3("Z9_PEDIDO" ,5),AvSx3("Z9_PEDIDO" ,6)})
aAdd(aRCampos,{{|| TRB->Z9_OCORREN+" - "+Left(Tabela("Z9",TRB->Z9_OCORREN,.f.),35)},"","Tipo de Ocorrencia"})
aAdd(aRCampos,{"Z9_DATAMOV","",AvSx3("Z9_DATAMOV",5),AvSx3("Z9_DATAMOV",6)})
aAdd(aRCampos,{"Z9_HORAMOV","",AvSx3("Z9_HORAMOV",5),AvSx3("Z9_HORAMOV",6)})
aAdd(aRCampos,{"Z9_USUARIO","",AvSx3("Z9_USUARIO",5),AvSx3("Z9_USUARIO",6)})
aAdd(aRCampos,{"Z9_TIPMOV" ,"",AvSx3("Z9_TIPMOV" ,5),AvSx3("Z9_TIPMOV" ,6)})
aRCampos:=E_CriaRCampos(aRCampos,"E")

Processa({|| lQuery := DIPR14FilQuery()},"Filtrando Pedidos no Kardex...",,.t.)

If !lQuery
	MsgInfo(;
	"Não encontrado dados que satisfaçam aos"+ENTER+;
	"parametros informados pelo usuario! ","Atenção")
	TRB->(dbCloseArea())
	Return(.t.)
EndIf   
       
TRB->(E_Report(aDados,aRCampos))
TRB->(dbCloseArea())
Return
*----------------------------------*
STATIC FUNCTION DIPR14FilQuery()
*----------------------------------*
Local _x

ProcRegua(500)

For _x := 1 to 250                
	IncProc( "Selecionando Pedidos...")
Next
                                                                                
Query := "SELECT Z9_FILIAL, Z9_PEDIDO, Z9_TIPMOV, SUBSTRING(Z9_DATAMOV,7,2)+'/'+SUBSTRING(Z9_DATAMOV,5,2)+'/'+SUBSTRING(Z9_DATAMOV,1,4) Z9_DATAMOV, Z9_HORAMOV, Z9_USUARIO, Z9_OCORREN, SUBSTRING(Z9_DATAMOV,1,4)+SUBSTRING(Z9_DATAMOV,5,2)+SUBSTRING(Z9_DATAMOV,7,2) DATAMOV" 
Query += " FROM " + RetSQLName("SZ9")
Query += " WHERE Z9_FILIAL = '" + xFilial('SZ9') + "'"
Query += "    AND "+RetSQLName("SZ9")+".D_E_L_E_T_ <> '*'"
Query += "    AND Z9_PEDIDO  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " 
Query += " ORDER BY Z9_PEDIDO, DATAMOV, Z9_HORAMOV"

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
