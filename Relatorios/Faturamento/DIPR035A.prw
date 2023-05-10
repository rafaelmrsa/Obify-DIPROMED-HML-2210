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

User Function DIPR035A(cPedido)

Local titulo     := OemTOAnsi("Relacao de pedidos com reserva...",72)
Local cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2     := (OemToAnsi("com os pedidos reservas.",72))
Local cDesc3     := (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))

Private aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private li         := 66
Private tamanho    := "G"
Private limite     := 220
Private nomeprog   := "DIPR035A"

// Private cPerg      := "DIPR35"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR35","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private nLastKey   := 0
Private lEnd       := .F.
Private wnrel      := "DIP35A"+StrTran(Time(),":","")
Private cString    := "SC9"
Private m_pag      := 1  
Private aPedCom	   := {}
  
//__AIMPRESS[1]:=1
wnrel := SetPrint(cString,wnrel,                       cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,.t.,,)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lEnd| RodaRel(cPedido)},Titulo)

Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
	MS_FLUSH()
Endif

Return

//////////////////////////////////////////////////////////////////////
Static Function RodaRel(cPedido)
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

Private _nTotFat     := 0
Private _nPedido     := 0

QRY1 := "Select "+RetSQLName("SC9")+".*, U7_NOME, B1_DESC ,B1_PROC, B1_LOJPROC, C5_DTPEDID, C5_HORALIB, C5_EXPLBLO, C5_PARCIAL, A1_NOME, A3_NOME, A3_NREDUZ, (B2_QATU-B2_QACLASS-B2_RESERVA) ESTOQUE, A2_COD, A2_NREDUZ"
QRY1 += " FROM "+RetSQLName("SC9")+", "+RetSQLName("SU7")+", "+RetSQLName("SB1")+", "+RetSQLName("SC5")+", "+RetSQLName("SA1")+", "+RetSQLName("SA3")+", "+RetSQLName("SB2")+", "+RetSQLName("SA2")+" "
QRY1 += " WHERE "
QRY1 += " C9_FILIAL = '"+xFilial("SC9")+"' and "
QRY1 += " C5_FILIAL = '"+xFilial("SC5")+"' and "
QRY1 += " B2_FILIAL = '"+xFilial("SB2")+"' and "
QRY1 += " B1_FILIAL = '"+xFilial("SB1")+"' and "
QRY1 += " C5_NUM = '"+cPedido+"' and "
QRY1 += " C9_NFISCAL = '' and "  
QRY1 += " C9_FILIAL  = C5_FILIAL and "
QRY1 += " C9_PEDIDO  = C5_NUM and "
QRY1 += " C9_OPERADO = U7_COD and "
QRY1 += " C9_CLIENTE = A1_COD and "
QRY1 += " C9_LOJA    = A1_LOJA and "
QRY1 += " C9_VEND    = A3_COD and " 
QRY1 += " B1_PROC    = A2_COD and "
QRY1 += " B1_LOJPROC = A2_LOJA and "    
QRY1 += " C9_LOCAL   =  B2_LOCAL and " 
QRY1 += " C9_PRODUTO =  B2_COD and " 
QRY1 += " C9_PRODUTO =  B1_COD and "      
QRY1 += RetSQLName("SC9")+".D_E_L_E_T_ = ' ' and "
QRY1 += RetSQLName("SU7")+".D_E_L_E_T_ = ' ' and "
QRY1 += RetSQLName("SB1")+".D_E_L_E_T_ = ' ' and "
QRY1 += RetSQLName("SC5")+".D_E_L_E_T_ = ' ' and "
QRY1 += RetSQLName("SA1")+".D_E_L_E_T_ = ' ' and "
QRY1 += RetSQLName("SA3")+".D_E_L_E_T_ = ' ' and "
QRY1 += RetSQLName("SB2")+".D_E_L_E_T_ = ' ' and "
QRY1 += RetSQLName("SA2")+".D_E_L_E_T_ = ' ' "  

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

memowrite('DIPR035.SQL',QRY1) 

//************** QUERY PARA BUSCAR PEDIDOS DE COMPRA(QUANTIDADE E PRAZO DE ENTREGA)*****************
QRY2 := "SELECT C7_NUM, C7_PRODUTO, C7_DENTREG, (C7_QUANT - C7_QUJE) QUANT"
QRY2 += " FROM "+RetSQLName("SC7")
QRY2 += " WHERE "
QRY2 += " C7_FILIAL IN ('01','04') and "
QRY2 += " C7_ENCER = ' ' and "  
QRY2 += " C7_RESIDUO = ' ' and "       
QRY2 += " D_E_L_E_T_ = ' ' " 
QRY2 += "order by C7_PRODUTO, C7_NUM, C7_DENTREG"

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

_cTitulo := "Relacao de pedidos com reserva - TODOS - Operador: '"+QRY1->C9_OPERADO+" - "+QRY1->U7_NOME                                                       
_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                         Estoque         Vendedor                                                            "

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
		@ li,000 PSay QRY1->C9_PEDIDO
		@ li,008 PSay SubStr(QRY1->C5_DTPEDID,7,2)+'/'+SubStr(QRY1->C5_DTPEDID,5,2)+'/'+SubStr(QRY1->C5_DTPEDID,1,4)
		@ li,020 PSay SubStr(QRY1->C9_DATALIB,7,2)+'/'+SubStr(QRY1->C9_DATALIB,5,2)+'/'+SubStr(QRY1->C9_DATALIB,1,4)
		@ li,032 PSay QRY1->C5_HORALIB 
		@ li,042 PSay QRY1->C9_CLIENTE+'-'+QRY1->C9_LOJA+' - '+QRY1->A1_NOME

		@ li,122 PSay QRY1->C9_VEND+' - '+QRY1->A3_NREDUZ
		li++

		@ li,000 PSay "EXPLICACAO: " + QRY1->C5_EXPLBLO
		li+=2  

		FindTot(QRY1->C9_PEDIDO)                                        
	EndIf
	
	//itens
	_cProduto := SUBSTR(QRY1->C9_PRODUTO,1,6)
	
	@ li,000 PSay SUBSTR(QRY1->C9_PRODUTO,1,6)+' '+QRY1->B1_DESC
	@ li,068 PSay QRY1->C9_QTDVEN PICTURE '@E 9,999,999'
	@ li,082 PSay QRY1->C9_QTDORI PICTURE '@E 9,999,999'
	@ li,093 PSay QRY1->C9_SALDO  PICTURE '@E 9,999,999'
	@ li,104 PSay QRY1->ESTOQUE	  PICTURE '@E 9,999,999'  //MCVN - 27/03/2007 

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
	                                                                	
	If _cPedido <> QRY1->C9_PEDIDO
		_cPedido := QRY1->C9_PEDIDO
	EndIf
	
	li++

 	DbSelectArea("QRY1")
	QRY1->(DbSkip())
	
	If _cPedido <> QRY1->C9_PEDIDO

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
	
		@ li,000 PSay Replicate('-',limite)
		li+=2
	EndIf
		

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
		

		_cTitulo := "Relacao de pedidos com reserva - TODOS - Operador: "+QRY1->C9_OPERADO+" - "+QRY1->U7_NOME                                                       
		_cDesc1  := "Pedido  Emissao      Liberacao Hora Lib   Cliente                                                         Estoque         Vendedor                                                            "

  	   	Roda(0,"Bom trabalho!",tamanho)
	EndIf

EndDo

         
// Imprimindo total geral - MCVN 20/04/2007
If li > 60
	li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho)
EndIf 
Li++
@ li,000 PSay  "Total geral: " 
@ li,208 PSay _nTotGer PICTURE '@E 9,999,999.99'        
li++ 
@ li,000 PSay Replicate('-',limite)
Roda(0,"Bom trabalho!",tamanho)  

dbSelectArea("QRY2")
QRY2->(dbCloseArea())

dbSelectArea("QRY1")
QRY1->(dbCloseArea())

Return(.T.)

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