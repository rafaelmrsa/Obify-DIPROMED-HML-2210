/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR035  ³ Autor ³ Eriberto Elias     ³ Data ³ 30/07/2003  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relacao de pedidos liberados                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DIPR035                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico DIPROMED                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
|..............................Histórico...................................±±
|Rafael    | DD/MM/AA - Descrição                                          ±±
|Maximo    | 27/03/07 - Inclusão de previsão de entrega do produto (SC7).  ±±
|Maximo    | 24/03/07 - Inclusão do valor do pedido total por operador e   ±±
|          |            total geral.                                       ±±
|Maximo    | 08/05/07 - Inclusão opção de gerar o relatório por fornecedor ±±
|Maximo    | 09/05/07 - Inclusão para filtrar por saldo e por estoque      ±± 
|Maximo    | 27/10/08 - Função para filtrar por departamentos(Listven)     ±±
|Maximo    | 28/10/08 - Incluir opção de programação SCJ                   ±±
|Maximo    | 20/02/09 - Incluir total do pedido qdo (mv_par02 == 3 .Or.    ±±
|Maximo    | 			mv_par02 == 4 .Or. mv_par02 == 5)      			   ±±
|Maximo    | 10/02/11	Somando os dados da Dipromed CD e HQ CD 		   ±±
|Maximo    | 05/05/11	Somando os dados da Dipromed CD e MATRIZ 		   ±±
|RBorges   | 23/05/13	Adicionado o campo C5_HORALIB para ordenar 		   ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "rwmake.ch"

User Function DIPR035()

Local _xArea   := GetArea()

Local titulo     := OemTOAnsi("Relacao de pedidos com reserva...",72)
Local cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2     := (OemToAnsi("com os pedidos reservas.",72))
Local cDesc3     := (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))

Private aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private li         := 66
Private tamanho    := "G"
Private limite     := 220
Private nomeprog   := "DIPR035"

// Private cPerg      := "DIPR35"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR35","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "DIPR035"
Private cString    := "SC9"
Private m_pag      := 1  
Private aPedCom	   := {}


U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)  

// Verifica perguntas. Se nao existe INCLUI
If !Pergunte(cPerg,.T.)     // Solicita parametro
	Return
EndIf
//Giovani Zago 13/03/2012 filtro para os vendedores.
If alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC")) $ GetMv("ES_VENDUSE",,"000053" )
	mv_par05 := alltrim(Posicione("SU7",4,xFilial("SU7") + RetCodUsr(),"U7_CGC"))
	mv_par06 := mv_par05
EndIf

If MV_PAR13 = 1
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	RptStatus({|lEnd| RodaRel()},Titulo)
Else  // Relatório de programação
	
	titulo     := OemTOAnsi("Relatório de programação por operador...",72)
	cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
	cDesc2     := (OemToAnsi("com as programações somente por operador.",72))
	cDesc3     := (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	RptStatus({|lEnd| RodaPro()},Titulo)
Endif

Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

RestArea(_xArea)

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaRel()
Local _cOperador  := ''
Local _cVendedor  := ''     
Local _cFornecedor:= ''
Local _cNomefor   := ''
Local _cPedido    := ''
Local _cProduto   := ''
Local _cCol		  := 0	 
Local i                       
Local _nTotProd   := 0   
Local _nTotRese   := 0
Local _nTotSaldo  := 0 
Local nEstoque    := 0 
Local cExpira  := ""

Private _nTotFat     := 0
Private _nPedido     := 0

// Gravando "z" no parametro referente ao produto se estiver vazio

If Empty(MV_Par10)
	MV_Par10 := "Z"
Endif

QRY1 :=        "Select "+RetSQLName("SC9")+".*, U7_NOME, B1_DESC ,B1_PROC, B1_LOJPROC, C5_DTPEDID, C5_HORALIB, C5_EXPLBLO, C5_PARCIAL,C5_XDATEXP, C5_XHOREXP, A1_NOME, A3_NOME, A3_NREDUZ, (B2_QATU-B2_QACLASS-B2_RESERVA) ESTOQUE, A2_COD, A2_NREDUZ"
QRY1 := QRY1 + " FROM "+RetSQLName("SC9")+", "+RetSQLName("SU7")+", "+RetSQLName("SB1")+", "+RetSQLName("SC5")+", "+RetSQLName("SA1")+", "+RetSQLName("SA3")+", "+RetSQLName("SB2")+", "+RetSQLName("SA2")+" "
QRY1 := QRY1 + " WHERE "
QRY1 := QRY1 + " C9_FILIAL = '04' and "
QRY1 := QRY1 + " C5_FILIAL = '04' and "
QRY1 := QRY1 + " B2_FILIAL = '04' and "
QRY1 := QRY1 + " B1_FILIAL = '04' and "
QRY1 := QRY1 + RetSQLName("SC9")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SU7")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SB1")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SC5")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SA1")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SA3")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SB2")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SA2")+".D_E_L_E_T_ <> '*' and "  
QRY1 := QRY1 + " C9_OPERADO between '"+mv_par03+"' and '"+mv_par04+"' and "
QRY1 := QRY1 + " C9_VEND between '"+mv_par05+"' and '"+mv_par06+"' and "
QRY1 := QRY1 + " C9_DATALIB between '"+DTOS(mv_par07)+"' and '"+DTOS(mv_par08)+"' and "
QRY1 := QRY1 + " C9_FORNEC between '"+mv_par11+"' and '"+mv_par12+"' and "

If mv_par02 == 1
	QRY1 := QRY1 + " C5_PARCIAL  = 'N' and "
ElseIf (mv_par02 == 3 .Or. mv_par02 == 4 .Or. mv_par02 == 5)
	QRY1 := QRY1 + " C9_SALDO <> 0 and "
EndIf
QRY1 := QRY1 + " C9_NFISCAL = '' and "  
QRY1 := QRY1 + " C9_FILIAL  = C5_FILIAL and "
QRY1 := QRY1 + " C9_PEDIDO  = C5_NUM and "
QRY1 := QRY1 + " C9_OPERADO = U7_COD and "
QRY1 := QRY1 + " C9_CLIENTE = A1_COD and "
QRY1 := QRY1 + " C9_LOJA    = A1_LOJA and "
QRY1 := QRY1 + " C9_VEND    = A3_COD and " 
QRY1 := QRY1 + " B1_PROC    = A2_COD and "
QRY1 := QRY1 + " B1_LOJPROC = A2_LOJA and "    

If U_ListVend() != '' .And. !Upper(U_DipUsr())$Upper(GetNewPar("ES_DIPR035","rferraris/wcicero"))  // Retorna a lista de vendedores que o usuario pode enxergar  MCVN - 27/10/2008
	QRY1 := QRY1 + " C9_VEND   "+ U_ListVend()+" and " 
EndIf

If mv_par02 == 4
	QRY1 := QRY1 + "B2_QATU-B2_RESERVA-B2_QACLASS > 0 and "
ElseIf	mv_par02 == 5                          
	QRY1 := QRY1 + "B2_QATU-B2_RESERVA-B2_QACLASS = 0 and "
Endif   

QRY1 := QRY1 + " C9_LOCAL   =  B2_LOCAL and " 

If !Empty(MV_Par09) // MCVN - 08/04/2008
	QRY1 := QRY1 + " C9_PRODUTO between '"+mv_par09+"' and '"+mv_par10+"' And "
EndiF

QRY1 := QRY1 + " C9_PRODUTO =  B2_COD and " 
QRY1 := QRY1 + " C9_PRODUTO =  B1_COD "      

QRY1 := QRY1 + "UNION "

QRY1 := QRY1 + "Select "+RetSQLName("SC9")+".*, U7_NOME, B1_DESC ,B1_PROC, B1_LOJPROC, C5_DTPEDID, C5_HORALIB, C5_EXPLBLO, C5_PARCIAL,C5_XDATEXP, C5_XHOREXP, A1_NOME, A3_NOME, A3_NREDUZ, (B2_QATU-B2_QACLASS-B2_RESERVA) ESTOQUE, A2_COD, A2_NREDUZ"
QRY1 := QRY1 + " FROM "+RetSQLName("SC9")+", "+RetSQLName("SU7")+", "+RetSQLName("SB1")+", "+RetSQLName("SC5")+", "+RetSQLName("SA1")+", "+RetSQLName("SA3")+", "+RetSQLName("SB2")+", "+RetSQLName("SA2")+" "
QRY1 := QRY1 + " WHERE "
QRY1 := QRY1 + "C9_FILIAL = '01' and "
QRY1 := QRY1 + "C5_FILIAL = '01' and "
QRY1 := QRY1 + "B2_FILIAL = '01' and "
QRY1 := QRY1 + "B1_FILIAL = '01' and "
QRY1 := QRY1 + RetSQLName("SC9")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SU7")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SB1")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SC5")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SA1")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SA3")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SB2")+".D_E_L_E_T_ <> '*' and "
QRY1 := QRY1 + RetSQLName("SA2")+".D_E_L_E_T_ <> '*' and "  
QRY1 := QRY1 + "C9_OPERADO between '"+mv_par03+"' and '"+mv_par04+"' and "
QRY1 := QRY1 + "C9_VEND between '"+mv_par05+"' and '"+mv_par06+"' and "
QRY1 := QRY1 + "C9_DATALIB between '"+DTOS(mv_par07)+"' and '"+DTOS(mv_par08)+"' and "
QRY1 := QRY1 + "C9_FORNEC between '"+mv_par11+"' and '"+mv_par12+"' and "
If mv_par02 == 1
	QRY1 := QRY1 + "C5_PARCIAL  = 'N' and "
ElseIf (mv_par02 == 3 .Or. mv_par02 == 4 .Or. mv_par02 == 5)
	QRY1 := QRY1 + "C9_SALDO <> 0 and "
EndIf
QRY1 := QRY1 + "C9_NFISCAL = '' and "  
QRY1 := QRY1 + "C9_FILIAL  = C5_FILIAL and "
QRY1 := QRY1 + "C9_PEDIDO  = C5_NUM and "
QRY1 := QRY1 + "C9_OPERADO = U7_COD and "
QRY1 := QRY1 + "C9_CLIENTE = A1_COD and "
QRY1 := QRY1 + "C9_LOJA    = A1_LOJA and "
QRY1 := QRY1 + "C9_VEND    = A3_COD and " 
QRY1 := QRY1 + "B1_PROC    = A2_COD and "
QRY1 := QRY1 + "B1_LOJPROC = A2_LOJA and "

If U_ListVend() != '' .And. !Upper(U_DipUsr())$Upper(GetNewPar("ES_DIPR035","rferraris/davelar/wcicero/smoraes"))  // Retorna a lista de vendedores que o usuario pode enxergar  MCVN - 27/10/2008
	QRY1 := QRY1 + "C9_VEND   "+ U_ListVend()+" and " 
EndIf

If mv_par02 == 4
	QRY1 := QRY1 + "B2_QATU-B2_RESERVA-B2_QACLASS > 0 and "
ElseIf	mv_par02 == 5                          
	QRY1 := QRY1 + "B2_QATU-B2_RESERVA-B2_QACLASS = 0 and "
Endif   

QRY1 := QRY1 + "C9_LOCAL   = B2_LOCAL and " 

If !Empty(MV_Par09) // MCVN - 08/04/2008
	QRY1 := QRY1 + "C9_PRODUTO between '"+mv_par09+"' and '"+mv_par10+"' And "
EndiF

QRY1 := QRY1 + "C9_PRODUTO = B2_COD and " 
QRY1 := QRY1 + "C9_PRODUTO = B1_COD "   

If mv_par01 == 1
	QRY1 := QRY1 + "order by U7_NOME, C9_DATALIB, C9_PEDIDO"
ElseIf mv_par01 == 2
	QRY1 := QRY1 + "order by A3_NREDUZ, C9_DATALIB, C9_PEDIDO"
Else 
	QRY1 := QRY1 + "order by A2_NREDUZ, C9_DATALIB, C5_HORALIB, C9_PEDIDO"
Endif

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

nTempoI := seconds()

// Processa Query SQL
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

TCSETFIELD("QRY1","C5_XDATEXP","D",8,0) 

memowrite('DIPR035.SQL',QRY1) 



//************** QUERY PARA BUSCAR PEDIDOS DE COMPRA(QUANTIDADE E PRAZO DE ENTREGA)*****************
QRY2 :=        "SELECT C7_NUM, C7_PRODUTO, C7_DENTREG, (C7_QUANT - C7_QUJE) QUANT"
QRY2 := QRY2 + " FROM "+RetSQLName("SC7")
QRY2 := QRY2 + " WHERE "
QRY2 := QRY2 + " C7_FILIAL = '04' and "
QRY2 := QRY2 + " D_E_L_E_T_ <> '*' and " 
QRY2 := QRY2 + " C7_PRODUTO between '"+mv_par09+"' and '"+mv_par10+"' and "
QRY2 := QRY2 + " C7_ENCER = '' and "  
QRY2 := QRY2 + " C7_RESIDUO = '' "       

QRY2 := QRY2 + " UNION "       

QRY2 := QRY2 +  "SELECT C7_NUM, C7_PRODUTO, C7_DENTREG, (C7_QUANT - C7_QUJE) QUANT"
QRY2 := QRY2 + " FROM "+RetSQLName("SC7")
QRY2 := QRY2 + " WHERE "
QRY2 := QRY2 + " C7_FILIAL = '01' and "
QRY2 := QRY2 + " D_E_L_E_T_ <> '*' and " 
QRY2 := QRY2 + " C7_PRODUTO between '"+mv_par09+"' and '"+mv_par10+"' and "
QRY2 := QRY2 + " C7_ENCER = '' and "  
QRY2 := QRY2 + " C7_RESIDUO = '' "       


QRY2 := QRY2 + "order by C7_PRODUTO, C7_NUM, C7_DENTREG"

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


// Processa Query SQL
TcQuery QRY2 NEW ALIAS "QRY2"         // Abre uma workarea com o resultado da query

memowrite('DIPR035B.SQL',QRY2)



DbSelectArea("QRY1")
QRY1->(dbGotop())
SetRegua(QRY1->(RecCount()))

If mv_par01 == 1
	_cTitulo := "Relacao de pedidos com reserva - "+Iif(mv_par02==1,'BLOQUEADOS',Iif(mv_par02==2,'TODOS','SALDO'))+' - Operador: ' +QRY1->C9_OPERADO+' - '+QRY1->U7_NOME                                                       
	_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                        Estoque         Expiração              Vendedor                            " + 'Periodo:   '+dTOc(mv_par07)+' - '+dTOc(mv_par08)
ElseIf mv_par01 == 2
	_cTitulo := "Relacao de pedidos com reserva - "+Iif(mv_par02==1,'BLOQUEADOS',Iif(mv_par02==2,'TODOS','SALDO'))+' - Vendedor: ' +QRY1->C9_VEND+' - '+QRY1->A3_NREDUZ
	_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                        Estoque         Expiração              Operador                            " + 'Periodo:   '+dTOc(mv_par07)+' - '+dTOc(mv_par08)
Else
	_cTitulo := "Relacao de pedidos com reserva - "+Iif(mv_par02==1,'BLOQUEADOS',Iif(mv_par02==2,'TODOS','SALDO'))+' - Fornecedor: '+QRY1->C9_FORNEC+' - '+QRY1->A2_NREDUZ
	_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                        Estoque         Expiração              Operador                            " + 'Periodo:   '+dTOc(mv_par07)+' - '+dTOc(mv_par08)	
EndIf

_cDesc2  := "Produto                                                           Qtd Vendida  Qtd Liberada      Saldo    Disponível     Dt Entrega   Quantidade    Dt Entrega   Quantidade    Dt Entrega     Quantidade       Valor do item"

_cOperador   := QRY1->C9_OPERADO
_cVendedor   := QRY1->C9_VEND
_cFornecedor := QRY1->C9_FORNEC
_cNomeFor    := QRY1->A2_NREDUZ
_cPedido     := '' 
_nTotPed     := 0
_nTotOper    := 0
_nTotGer     := 0                    
_nTotProd    := 0   
_nTotRese    := 0
_nTotSaldo   := 0 

Do While QRY1->(!Eof())
	
	IncRegua( "Imprimindo... ")
	
	If li > 60
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	*                                                                                                    1         1         1         1         1         1         1         1         1         1         2         2         2
	*          1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
	*01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	*Pedido  Emissao      Liberacao Hora Lib   Cliente                                                         Estoque         Vendedor                                                           Periodo: 99/99/9999 - 99/99/9999
	*Produto                                                           Qtd Vendida  Qtd Liberada      Saldo    Disponível     Dt Entrega   Quantidade    Dt Entrega   Quantidade    Dt Entrega     Quantidade       Valor    item 
	*Explicação
	*Valor  pedido
	*999999  99/99/9999  99/99/9999  99:99:99  123456-12 - 1234567890123456789012345678901234567890123456789012345678901  999999 - 1234567890123456789012345678901234567890
	*999999 123456789012345678901234567890123456789012345678901234567890 9,999,999     9,999,999  9,999,999  1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	
	// Pedido       
	If _cPedido <> QRY1->C9_PEDIDO   

       cExpira := DTOC(QRY1->C5_XDATEXP)+" às ("+AllTrim(QRY1->C5_XHOREXP)+") "
		
		@ li,000 PSay QRY1->C9_PEDIDO
		@ li,008 PSay SubStr(QRY1->C5_DTPEDID,7,2)+'/'+SubStr(QRY1->C5_DTPEDID,5,2)+'/'+SubStr(QRY1->C5_DTPEDID,1,4)
		@ li,020 PSay SubStr(QRY1->C9_DATALIB,7,2)+'/'+SubStr(QRY1->C9_DATALIB,5,2)+'/'+SubStr(QRY1->C9_DATALIB,1,4)
		@ li,032 PSay QRY1->C5_HORALIB 
		@ li,042 PSay QRY1->C9_CLIENTE+'-'+QRY1->C9_LOJA+' - '+QRY1->A1_NOME
		@ li,122 PSay cExpira
		If mv_par01 == 1
			@ li,142 PSay QRY1->C9_VEND+' - '+QRY1->A3_NREDUZ
			li++
		ElseIf mv_par01 == 2
			@ li,142 PSay QRY1->C9_OPERADO+' - '+QRY1->U7_NOME
			li++
		Else
			@ li,142 PSay QRY1->C9_OPERADO+' - '+QRY1->U7_NOME
			li++
		EndIf
		@ li,000 PSay "EXPLICACAO: " + QRY1->C5_EXPLBLO
		li+=2  
		
	   //If (mv_par02 == 3 .Or. mv_par02 == 4 .Or. mv_par02 == 5) // Atualiza total do pedido qdo o rel. for de saldo - MCVN - 20/02/2009
			FindTot(QRY1->C9_PEDIDO)                                        
	   //Endif
	EndIf
	
	//itens                                                  
	
    nEstoque  := U_DIPSALDSB2(QRY1->C9_PRODUTO,.T.,'')
	
	_cProduto := SUBSTR(QRY1->C9_PRODUTO,1,6)
	
	@ li,000 PSay SUBSTR(QRY1->C9_PRODUTO,1,6)+' '+QRY1->B1_DESC
	@ li,068 PSay QRY1->C9_QTDVEN PICTURE '@E 9,999,999'
	@ li,082 PSay QRY1->C9_QTDORI PICTURE '@E 9,999,999'
	@ li,093 PSay QRY1->C9_SALDO  PICTURE '@E 9,999,999'
	@ li,104 PSay nEstoque  	  PICTURE '@E 9,999,999'  //MCVN - 27/03/2007 

  	VerPedCom(_cProduto) // Executa a função que mostra a informação dos pedidos de compra
	
	If Len(aPedCom) > 0  
	_cCol := 109
		For i := 1 to Len(aPedCom)	
		   If i < 4
		   	  _cCol := _cCol + 12
			  @ li,_cCol PSay SubStr(aPedCom[i,1],7,2) + '/' + SubStr(aPedCom[i,1],5,2) + '/' + SubStr(aPedCom[i,1],1,4) //MCVN - 27/03/2007
			  _cCol := _cCol + 13			
			  @ li,_cCol PSay aPedCom[i,2]	  PICTURE '@E 99,999,999' //MCVN - 27/03/2007
		   Endif
		Next	
	Endif      
	
	// Imprime o valor dos itens e soma totaliza por pedido, operador/vendedor e geral - MCVN 20/04/2007
 	@ li,208 PSay (QRY1->C9_QTDVEN * QRY1->C9_PRCVEN)	  PICTURE '@E 9,999,999.99'
 	
	_nTotPed  := _nTotPed  + (QRY1->C9_QTDVEN * QRY1->C9_PRCVEN)
	_nTotOper := _nTotOper + (QRY1->C9_QTDVEN * QRY1->C9_PRCVEN)
	_nTotGer  := _nTotGer  + (QRY1->C9_QTDVEN * QRY1->C9_PRCVEN)    
	                                                                
	// Soma as quantidades quando for relatório por fornecedor e o filtro for somente de um produto
	If MV_PAR01 == 3 .And. MV_PAR09 == MV_PAR10 .And. !Empty(MV_PAR09) 
		_nTotProd  := _nTotProd  + QRY1->C9_QTDVEN 
		_nTotRese  := _nTotRese  + QRY1->C9_QTDORI
		_nTotSaldo := _nTotSaldo + QRY1->C9_SALDO 
	Endif                       
	
	If _cPedido <> QRY1->C9_PEDIDO
		_cPedido := QRY1->C9_PEDIDO
	EndIf
	
	li++

 	DbSelectArea("QRY1")
	QRY1->(DbSkip())
	
	If _cPedido <> QRY1->C9_PEDIDO  .AND. mv_par01 <> 3		
//		If (mv_par02 == 3 .Or. mv_par02 == 4 .Or. mv_par02 == 5)  // MCVN - 20/02/2009
			@ li,000 PSay  "Total em Saldo: " 
			@ li,208 PSay  _nTotPed PICTURE '@E 9,999,999.99'        
			_nTotPed := 0                      
			li++		
			@ li,000 PSay Replicate('.',limite)
			li++                           
			@ li,000 PSay  "Total Faturado: " 
			@ li,208 PSay  _nTotFat PICTURE '@E 9,999,999.99'        
			_nTotFat := 0
			li++		
			@ li,000 PSay Replicate('.',limite)
			li++
			@ li,000 PSay  "Total do pedido: " 
			@ li,208 PSay  _nPedido PICTURE '@E 9,999,999.99'        
			_nPedido := 0
			li++
//		Else
//			@ li,000 PSay  "Total do pedido: " 
//			@ li,208 PSay  _nTotPed PICTURE '@E 9,999,999.99'        
//			_nTotPed := 0                      		
//			li++                           
//		Endif
		
		@ li,000 PSay Replicate('-',limite)
		li+=2
	EndIf
	
	If _cPedido <> QRY1->C9_PEDIDO  .AND. mv_par01 == 3
		@ li,000 PSay Replicate('-',limite)
		li+=2
	EndIf                                                   
	
	If mv_par01 == 1
		If QRY1->C9_OPERADO <> _cOperador
		
			If li > 57
				li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
			EndIf
			// Imprimi total por operador/vendedor - MCVN 20/04/2007
	   		@ li,000 PSay  "Total do operador: " 
	   		@ li,208 PSay  _nTotOper PICTURE '@E 9,999,999.99'        
	   		li++ 
	   		@ li,000 PSay Replicate('-',limite)
	   		li++                                                    
	   		_nTotOper := 0
			m_pag := 1
			li := 66
			_cOperador   := QRY1->C9_OPERADOR
			_cVendedor   := QRY1->C9_VEND
			_cFornecedor := QRY1->C9_FORNEC
			_cNomefor    := QRY1->A2_NREDUZ
			
			If mv_par01 == 1
				_cTitulo := "Relacao de pedidos com reserva - "+Iif(mv_par02==1,'BLOQUEADOS',Iif(mv_par02==2,'TODOS','SALDO'))+' - Operador: ' +QRY1->C9_OPERADO+' - '+QRY1->U7_NOME                                                       
				_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                         Estoque         Expiração              Vendedor                            " + 'Periodo:   '+dTOc(mv_par07)+' - '+dTOc(mv_par08)
			ElseIf mv_par01 == 2
				_cTitulo := "Relacao de pedidos com reserva - "+Iif(mv_par02==1,'BLOQUEADOS',Iif(mv_par02==2,'TODOS','SALDO'))+' - Vendedor: ' +QRY1->C9_VEND+' - '+QRY1->A3_NREDUZ
				_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                         Estoque         Expiração              Operador                             " + 'Periodo:   '+dTOc(mv_par07)+' - '+dTOc(mv_par08)
			Else
				_cTitulo := "Relacao de pedidos com reserva - "+Iif(mv_par02==1,'BLOQUEADOS',Iif(mv_par02==2,'TODOS','SALDO'))+' - Fornecedor: '+QRY1->C9_FORNEC+' - '+QRY1->A2_NREDUZ
				_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                         Estoque         Expiração              Operador                             " + 'Periodo:   '+dTOc(mv_par07)+' - '+dTOc(mv_par08)	
			EndIf
			
	  	   	Roda(0,"Bom trabalho!",tamanho)
		EndIf
	ElseIf mv_par01 == 2
		If QRY1->C9_VEND <> _cVendedor 
			If li > 57
				li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
			EndIf
			// Imprimi total por operador/vendedor - MCVN 20/04/2007
	   		@ li,000 PSay  "Total do vendedor: " 
	   		@ li,208 PSay  _nTotOper PICTURE '@E 9,999,999.99'        
	   		li++ 
	   		@ li,000 PSay Replicate('-',limite)
	   		li++                                                                                                        
	   		_nTotOper := 0
			m_pag := 1
			li := 66
			_cOperador   := QRY1->C9_OPERADO
			_cVendedor   := QRY1->C9_VEND    
			_cFornecedor := QRY1->C9_FORNEC
			_cNomefor    := QRY1->A2_NREDUZ
			
			If mv_par01 == 1
				_cTitulo := "Relacao de pedidos com reserva - "+Iif(mv_par02==1,'BLOQUEADOS',Iif(mv_par02==2,'TODOS','SALDO'))+' - Operador: ' +QRY1->C9_OPERADO+' - '+QRY1->U7_NOME                                                       
				_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                         Estoque         Expiração              Vendedor                             " + 'Periodo:   '+dTOc(mv_par07)+' - '+dTOc(mv_par08)
			ElseIf mv_par01 == 2
				_cTitulo := "Relacao de pedidos com reserva - "+Iif(mv_par02==1,'BLOQUEADOS',Iif(mv_par02==2,'TODOS','SALDO'))+' - Vendedor: ' +QRY1->C9_VEND+' - '+QRY1->A3_NREDUZ
				_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                         Estoque         Expiração              Operador                             " + 'Periodo:   '+dTOc(mv_par07)+' - '+dTOc(mv_par08)
			Else
				_cTitulo := "Relacao de pedidos com reserva - "+Iif(mv_par02==1,'BLOQUEADOS',Iif(mv_par02==2,'TODOS','SALDO'))+' - Fornecedor: '+QRY1->C9_FORNEC+' - '+QRY1->A2_NREDUZ
				_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                         Estoque         Expiração              Operador                             " + 'Periodo:   '+dTOc(mv_par07)+' - '+dTOc(mv_par08)	
			EndIf
			
	   	 	Roda(0,"Bom trabalho!",tamanho)
		EndIf
	Else
		If QRY1->C9_FORNEC <> _cFornecedor
			If li > 57
				li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
			EndIf
			// Imprimi total por operador/vendedor - MCVN 20/04/2007
	   		@ li,000 PSay  "Total do Fornecedor: " + _cFornecedor +' - '+_cNomefor
			
			// Imprime as quantidades quando for relatório por fornecedor e o filtro for somente de um produto		   	
		   	If MV_PAR01 == 3 .And. MV_PAR09 == MV_PAR10 .And. !Empty(MV_PAR09) 
				@ li,068 PSay _nTotProd  PICTURE '@E 999,999,999'
				@ li,082 PSay _nTotRese  PICTURE '@E 999,999,999'
				@ li,093 PSay _nTotSaldo PICTURE '@E 999,999,999'
			Endif	
	   		
	   		@ li,208 PSay  _nTotOper PICTURE '@E 9,999,999.99'        
	   		li++ 
	   		@ li,000 PSay Replicate('-',limite)
	   		li++                                                                                                        
	   		_nTotOper := 0
			m_pag := 1
			li := 66
			_cOperador   := QRY1->C9_OPERADO
			_cVendedor   := QRY1->C9_VEND    
			_cFornecedor := QRY1->C9_FORNEC
			_cNomefor    := QRY1->A2_NREDUZ
			
			If mv_par01 == 1
				_cTitulo := "Relacao de pedidos com reserva - "+Iif(mv_par02==1,'BLOQUEADOS',Iif(mv_par02==2,'TODOS','SALDO'))+' - Operador: ' +QRY1->C9_OPERADO+' - '+QRY1->U7_NOME                                                       
				_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                         Estoque         Expiração              Vendedor                             " + 'Periodo:   '+dTOc(mv_par07)+' - '+dTOc(mv_par08)
			ElseIf mv_par01 == 2
				_cTitulo := "Relacao de pedidos com reserva - "+Iif(mv_par02==1,'BLOQUEADOS',Iif(mv_par02==2,'TODOS','SALDO'))+' - Vendedor: ' +QRY1->C9_VEND+' - '+QRY1->A3_NREDUZ
				_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                         Estoque         Expiração              Operador                             " + 'Periodo:   '+dTOc(mv_par07)+' - '+dTOc(mv_par08)
			Else
				_cTitulo := "Relacao de pedidos com reserva - "+Iif(mv_par02==1,'BLOQUEADOS',Iif(mv_par02==2,'TODOS','SALDO'))+' - Fornecedor: '+QRY1->C9_FORNEC+' - '+QRY1->A2_NREDUZ
				_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                         Estoque         Expiração              Operador                             " + 'Periodo:   '+dTOc(mv_par07)+' - '+dTOc(mv_par08)	
			EndIf
			
	   	 	Roda(0,"Bom trabalho!",tamanho)
		EndIf	
	EndIf
EndDo

         
// Imprimindo total geral - MCVN 20/04/2007
If mv_par14 == 1
	If li > 60
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho)
	EndIf 
	Li++
	@ li,000 PSay  "Total geral: " 
	// Imprime as quantidades quando for relatório por fornecedor e o filtro for somente de um produto
	If MV_PAR01 == 3 .And. MV_PAR09 == MV_PAR10 .And. !Empty(MV_PAR09) 
		@ li,068 PSay _nTotProd  PICTURE '@E 999,999,999'
		@ li,082 PSay _nTotRese  PICTURE '@E 999,999,999'
		@ li,093 PSay _nTotSaldo PICTURE '@E 999,999,999'
	Endif	
	@ li,208 PSay _nTotGer PICTURE '@E 9,999,999.99'        
	li++ 
	@ li,000 PSay Replicate('-',limite)
	Roda(0,"Bom trabalho!",tamanho)  
Endif

dbSelectArea("QRY2")
QRY2->(dbCloseArea())

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

Return(.T.)

/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
Local i,j

_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)                                                                    

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"01","Operador/Vendedor/Fornecedor  ?","","","mv_ch1","N",1, 0,1,"C","","mv_par01","Operador","","","","","Vendedor","","","","","Fornecedor","","",""})
aAdd(aRegs,{cPerg,"02","Bloq/Todos/Saldos/Saldos Com Estoque/Saldos Sem Estoque   ?","","","mv_ch2","N",1, 0,1,"C","","mv_par02","Bloqueados","","","","","Todos","","","","","Saldos","","","","","Saldos c/ Estoque","","","","","Saldos s/ Estoque"})
aAdd(aRegs,{cPerg,"03","Do Operador        ?","","","mv_ch3","C",6, 0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",'SU7'})
aAdd(aRegs,{cPerg,"04","Ate Operador       ?","","","mv_ch4","C",6, 0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",'SU7'})
aAdd(aRegs,{cPerg,"05","Do Vendedor        ?","","","mv_ch5","C",6, 0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
aAdd(aRegs,{cPerg,"06","Ate vendedor       ?","","","mv_ch6","C",6, 0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
aAdd(aRegs,{cPerg,"07","Data Liberacao de  ?","","","mv_ch7","D",8, 0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Data Liberacao ate ?","","","mv_ch8","D",8, 0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","De Produto         ?","","","mv_ch9","C",15,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"10","Ate Produto        ?","","","mv_chA","C",15,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"11","Do Fornecedor      ?","","","mv_chB","C",6, 0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
aAdd(aRegs,{cPerg,"12","Ate Fornecedor     ?","","","mv_chC","C",6, 0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
aAdd(aRegs,{cPerg,"13","Pedido/Programação ?","","","mv_chD","N",1, 0,1,"C","","mv_par13","Pedido","","","","","Programação","","","","","","","",""})
aAdd(aRegs,{cPerg,"14","Imprime Total Geral?","","","mv_chD","N",1, 0,1,"C","","mv_par14","Sim","","","","","Não","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)
Return
///////////////////////////////////////////////////////////////////////////    


 //MCVN - 27/03/07
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe pedido de compra e grava data e quantidade em um array³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static Function VerPedCom(_cProduto)
Local nPos
Static aQry2

//-- Salva o Array Estático para ganho de performance - D'Leme 01/08/2011
If aQry2 == Nil
	aQry2 := {}

    QRY2->(dbGotop())  
	QRY2->(DbEval({|| aAdd(aQry2,{ C7_PRODUTO, C7_DENTREG, QUANT})  } ))

    aQry2 := aSort(aQry2,,,{|x,y| x[1] < y[1] })
EndIf

aPedCom := {}

//-- Gravando informações no array private do produto - Adaptado por D'Leme em 01/08/2011
nPos := aScan(aQry2,{|x| AllTrim(x[1]) == AllTrim(_cProduto) })
Do While nPos > 0 .And. nPos <= Len(aQry2) .And. AllTrim(aQry2[nPos][1]) == AllTrim(_cProduto)
	aAdd( aPedCom,{aQry2[nPos][2],aQry2[nPos][3]})
	
	nPos++
EndDo

aPedCom := aSort(aPedCom,,,{|x,y| x[1] < y[1] })
	
Return      

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//28/10/2008   -   RELATÓRIO DE PROGRAMAÇÃO POR OPERADOR (SCJ E SCK)
Static Function RodaPro()
Local _cOperador := ''
Local _cVendedor := ''
Local _cFornecedor:= ''
Local _cNomefor   := ''
Local _cPedido   := ''
Local _cProduto  := ''
Local _cCol		 := 0	 

// Gravando "z" no parametro referente ao produto se estiver vazio

If Empty(MV_Par10)
	MV_Par10 := "Z"
Endif

mv_par01 := 1 // Somente por operador


//************** QUERY PARA BUSCAR PROGRAMAÇÃO POR OPERADOR/CLIENTE)*****************
QRY1 := "SELECT CJ_NUM, CJ_OPCAO, CJ_EMISSAO, CJ_VALIDA, CJ_CLIENTE, CJ_LOJA, A1_NOME, CK_PRODUTO, B1_DESC, B1_PROC, CK_UM, CK_QTDVEN, CJ_OPERADO, CK_ENTREG, CJ_OBS, CK_PRCVEN, CK_VALOR, U7_NOME, A1_VEND, A3_NREDUZ"
QRY1 := QRY1 + " FROM "+RetSQLName("SCJ")+", "+RetSQLName("SCK")+", "+RetSQLName("SB1")+", "+RetSQLName("SA1")+","+RetSQLName("SU7")+","+RetSQLName("SA3")
QRY1 := QRY1 + " WHERE "
QRY1 := QRY1 + RetSQLName("SCJ")+".D_E_L_E_T_ = '' and " 
QRY1 := QRY1 + RetSQLName("SCK")+".D_E_L_E_T_ = '' and " 
QRY1 := QRY1 + RetSQLName("SB1")+".D_E_L_E_T_ = '' and " 
QRY1 := QRY1 + RetSQLName("SA1")+".D_E_L_E_T_ = '' and " 
QRY1 := QRY1 + RetSQLName("SU7")+".D_E_L_E_T_ = '' and " 
QRY1 := QRY1 + RetSQLName("SA3")+".D_E_L_E_T_ = '' and " 
QRY1 := QRY1 + " CJ_FILIAL  = '04' and "
QRY1 := QRY1 + " CK_FILIAL  = '04' and "
QRY1 := QRY1 + " B1_FILIAL  = '04' and "
QRY1 := QRY1 + " CJ_FILIAL  = CK_FILIAL And "  
QRY1 := QRY1 + " CJ_NUM     = CK_NUM And "  
QRY1 := QRY1 + " CJ_CLIENTE = A1_COD And "  
QRY1 := QRY1 + " CK_PRODUTO = B1_COD and "    
QRY1 := QRY1 + " CJ_OPERADO = U7_COD and "    
QRY1 := QRY1 + " A1_VEND    = A3_COD and "    
QRY1 := QRY1 + " A1_VEND between '"+mv_par05+"' and '"+mv_par06+"' and "   // MCVN - 09/12/2008
QRY1 := QRY1 + " CJ_OPERADO between '"+mv_par03+"' and '"+mv_par04+"' and "
QRY1 := QRY1 + " CJ_EMISSAO between '"+DTOS(mv_par07)+"' and '"+DTOS(mv_par08)+"' and "
QRY1 := QRY1 + " CK_PRODUTO between '"+mv_par09+"' and '"+mv_par10+"' and "
QRY1 := QRY1 + " B1_PROC between '"+mv_par11+"' and '"+mv_par12+"' "

QRY1 := QRY1 + " UNION "

QRY1 := QRY1 + "SELECT CJ_NUM, CJ_OPCAO, CJ_EMISSAO, CJ_VALIDA, CJ_CLIENTE, CJ_LOJA, A1_NOME, CK_PRODUTO, B1_DESC, B1_PROC, CK_UM, CK_QTDVEN, CJ_OPERADO, CK_ENTREG, CJ_OBS, CK_PRCVEN, CK_VALOR, U7_NOME, A1_VEND, A3_NREDUZ"
QRY1 := QRY1 + " FROM "+RetSQLName("SCJ")+", "+RetSQLName("SCK")+", "+RetSQLName("SB1")+", "+RetSQLName("SA1")+","+RetSQLName("SU7")+","+RetSQLName("SA3")
QRY1 := QRY1 + " WHERE "
QRY1 := QRY1 + RetSQLName("SCJ")+".D_E_L_E_T_ = '' and " 
QRY1 := QRY1 + RetSQLName("SCK")+".D_E_L_E_T_ = '' and " 
QRY1 := QRY1 + RetSQLName("SB1")+".D_E_L_E_T_ = '' and " 
QRY1 := QRY1 + RetSQLName("SA1")+".D_E_L_E_T_ = '' and " 
QRY1 := QRY1 + RetSQLName("SU7")+".D_E_L_E_T_ = '' and " 
QRY1 := QRY1 + RetSQLName("SA3")+".D_E_L_E_T_ = '' and " 
QRY1 := QRY1 + " CJ_FILIAL  = '01' and "
QRY1 := QRY1 + " CK_FILIAL  = '01' and "
QRY1 := QRY1 + " B1_FILIAL  = '01' and "
QRY1 := QRY1 + " CJ_FILIAL  = CK_FILIAL And "  
QRY1 := QRY1 + " CJ_NUM     = CK_NUM And "  
QRY1 := QRY1 + " CJ_CLIENTE = A1_COD And "  
QRY1 := QRY1 + " CK_PRODUTO = B1_COD and "    
QRY1 := QRY1 + " CJ_OPERADO = U7_COD and "    
QRY1 := QRY1 + " A1_VEND    = A3_COD and "    
QRY1 := QRY1 + " A1_VEND between '"+mv_par05+"' and '"+mv_par06+"' and "   // MCVN - 09/12/2008
QRY1 := QRY1 + " CJ_OPERADO between '"+mv_par03+"' and '"+mv_par04+"' and "
QRY1 := QRY1 + " CJ_EMISSAO between '"+DTOS(mv_par07)+"' and '"+DTOS(mv_par08)+"' and "
QRY1 := QRY1 + " CK_PRODUTO between '"+mv_par09+"' and '"+mv_par10+"' and "
QRY1 := QRY1 + " B1_PROC between '"+mv_par11+"' and '"+mv_par12+"' "

QRY1 := QRY1 + "order by CJ_OPERADO, CJ_NUM, CJ_EMISSAO"

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

// Processa Query SQL
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

memowrite('DIPR035C.SQL',QRY1)



DbSelectArea("QRY1")
QRY1->(dbGotop())
SetRegua(QRY1->(RecCount()))


_cTitulo := "Relatório de programação por operador   -   Periodo:   "+dTOc(mv_par07)+' - '+dTOc(mv_par08)
_cDesc1  := "Código  Emissao                 Cliente                                                                 "
_cDesc2  := "Produto                                                                 Quantidade          Valor Unitário        Valor Total        Data Entrega  

_cOperador   := QRY1->CJ_OPERADO
_cFornecedor := QRY1->B1_PROC
_cPedido     := '' 
_nTotPed     := 0
_nTotOper    := 0
_nTotGer     := 0

Do While QRY1->(!Eof())
	
	IncRegua( "Imprimindo... ")
	
	If li > 60
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	
	// Pedido       
	If _cPedido <> QRY1->CJ_NUM   
		@ li,000 PSay QRY1->CJ_NUM
		@ li,008 PSay SubStr(QRY1->CJ_EMISSAO,7,2)+'/'+SubStr(QRY1->CJ_EMISSAO,5,2)+'/'+SubStr(QRY1->CJ_EMISSAO,1,4)
		@ li,032 PSay QRY1->CJ_CLIENTE+'-'+QRY1->CJ_LOJA+' - '+QRY1->A1_NOME
		@ li,132 PSay QRY1->CJ_OPERADO+' - '+QRY1->U7_NOME      
		@ li,180 PSay QRY1->A1_VEND+' - '+QRY1->A3_NREDUZ
		li++

		@ li,000 PSay "Observação: " + QRY1->CJ_OBS
		li+=2 
		_cPedido := QRY1->CJ_NUM                                         
	EndIf
	
	//itens
	_cProduto := SUBSTR(QRY1->CK_PRODUTO,1,6)
	
	@ li,000 PSay SUBSTR(QRY1->CK_PRODUTO,1,6)+' '+QRY1->B1_DESC
	@ li,068 PSay QRY1->CK_QTDVEN PICTURE '@E 9,999,999'
	@ li,090 PSay QRY1->CK_PRCVEN PICTURE '@E 9,999,999.99' 
	@ li,112 PSay QRY1->CK_VALOR  PICTURE '@E 9,999,999.99' 
	@ li,134 PSay SubStr(QRY1->CK_ENTREG,7,2)+'/'+SubStr(QRY1->CK_ENTREG,5,2)+'/'+SubStr(QRY1->CK_ENTREG,1,4)  // MCVN 15/01/2009
	
	_nTotPed  := _nTotPed  + (QRY1->CK_VALOR)
	_nTotOper := _nTotOper + (QRY1->CK_VALOR)
	_nTotGer  := _nTotGer  + (QRY1->CK_VALOR)
	
	If _cPedido <> QRY1->CJ_NUM
		_cPedido := QRY1->CJ_NUM
	EndIf
	
	li++

// 	DbSelectArea("QRY1")
	QRY1->(DbSkip())
	
   	If _cPedido <> QRY1->CJ_NUM  .AND. mv_par01 <> 3
	
		@ li,000 PSay  "Total do pedido: " 
		@ li,208 PSay  _nTotPed PICTURE '@E 9,999,999.99'        
		_nTotPed := 0
		li++
		@ li,000 PSay Replicate('-',limite)
		li+=2
	EndIf
	
	If _cPedido <> QRY1->CJ_NUM  .AND. mv_par01 == 3
		@ li,000 PSay Replicate('-',limite)
		li+=2
	EndIf                                                   
	
	If QRY1->CJ_OPERADO <> _cOperador
		If li > 57
			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
		EndIf
		// Imprimi total por operador/vendedor - MCVN 20/04/2007
   		@ li,000 PSay  "Total do operador: " 
   		@ li,208 PSay  _nTotOper PICTURE '@E 9,999,999.99'        
   		li++ 
   		@ li,000 PSay Replicate('-',limite)
   		li++                                                    
   		_nTotOper := 0
		m_pag := 1
		li := 66
		_cOperador   := QRY1->CJ_OPERADOR
		_cFornecedor := QRY1->B1_PROC		
		_cTitulo := "Relatório de programação por operador   -   Periodo:   "+dTOc(mv_par07)+' - '+dTOc(mv_par08)
		_cDesc1  := "Código  Emissao                 Cliente                                                                 "
  	   	Roda(0,"Bom trabalho!",tamanho)
	EndIf
EndDo
         
// Imprimindo total geral - MCVN 20/04/2007
If mv_par14 == 1
	If li > 60
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho)
	EndIf 
	Li++
	@ li,000 PSay  "Total geral: " 
	@ li,208 PSay  _nTotGer PICTURE '@E 9,999,999.99'        
	li++ 
	@ li,000 PSay Replicate('-',limite)
	Roda(0,"Bom trabalho!",tamanho)  
EndIf

//dbSelectArea("QRY2")
//QRY2->(dbCloseArea())

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

Return(.T.)     

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//20/02/2009   -   BUSCA TOTAL DO PEDIDO QDO MV_PAR02 = SALDO (mv_par02 == 3 .Or. mv_par02 == 4 .Or. mv_par02 == 5)
Static Function FindTot(_cPedido)

_nTotFat     := 0
_nPedido     := 0

QRY4 :=        "Select SUM(C9_QTDVEN * C9_PRCVEN) as nSC9PED, SUM( CASE WHEN C9_NFISCAL <> '' THEN C9_QTDVEN * C9_PRCVEN  ELSE 0 END) AS nSC9FAT
QRY4 := QRY4 + " FROM "+RetSQLName("SC9")
QRY4 := QRY4 + " WHERE "
QRY4 := QRY4 + " C9_FILIAL = '04' and "
QRY4 := QRY4 + " D_E_L_E_T_ = '' and "
QRY4 := QRY4 + " C9_PEDIDO  = '"+_cPedido+"'"                                                                                             

QRY4 := QRY4 + " UNION "

QRY4 := QRY4 + "Select SUM(C9_QTDVEN * C9_PRCVEN) as nSC9PED, SUM( CASE WHEN C9_NFISCAL <> '' THEN C9_QTDVEN * C9_PRCVEN  ELSE 0 END) AS nSC9FAT
QRY4 := QRY4 + " FROM "+RetSQLName("SC9")
QRY4 := QRY4 + " WHERE "
QRY4 := QRY4 + " C9_FILIAL = '01' and "
QRY4 := QRY4 + " D_E_L_E_T_ = '' and "
QRY4 := QRY4 + " C9_PEDIDO  = '"+_cPedido+"'"

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

// Processa Query SQL
TcQuery QRY4 NEW ALIAS "QRY4"         // Abre uma workarea com o resultado da query

memowrite('DIPR35TOT.SQL',QRY4) 


DbSelectArea("QRY4")
QRY4->(dbGotop())
//SetRegua(QRY4->(RecCount()))

_nTotFat     := QRY4->nSC9FAT
_nPedido     := QRY4->nSC9PED

dbSelectArea("QRY4")
QRY4->(dbCloseArea())

Return()
