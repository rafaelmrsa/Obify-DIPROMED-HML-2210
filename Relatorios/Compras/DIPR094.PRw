/*====================================================================================\
|Programa  | DIPR094    | Autor | Reginaldo Borges              | Data | 16/02/2018   |
|=====================================================================================|
|Descrição | Gerar um relatório em PDF dos produtos sem Giro e enviar como anexo      |
|          | por email.																  |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR094		                                                          |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Maximo    | DD/MM/AA - Descrição                                                     |
|          | 																		  |
\====================================================================================*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

#DEFINE _ENTER CHR(13)+CHR(10) // Quebra linha

User Function DIPR094(aWork)

Local _xArea := GetArea()
Private cWorkFlow	:= "" 
Private cWCodEmp    := ""  
Private cWCodFil    := "" 
Private oFont15 := TFont():New("Arial",9,13,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont15n:= TFont():New("Arial",9,13,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont16 := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont17n:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont20n:= TFont():New("Arial",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
Private cArq001 := ""
Private cArq002 := ""


cWorkFlow := aWork[1]    
cWCodEmp  := aWork[2]
cWCodFil  := aWork[3]  


If cWorkFlow == "S"                                  
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPR094"
Else
	Return	
EndIf

ConOut('Inicio do relatorio dos produtos sem giro DIPR094 '+dToc(date())+' as '+Time())

U_DIPPROC(ProcName(0),U_DipUsr())

RunProc(1) //Processamento dos dados por comprador
RunProc(0) //Processamento dos dados de todos os fornecedores

ConOut('Fim relatorio dos produtos sem giro DIPR094 '+dToc(date())+' as '+Time())

RestArea(_xArea)

Return

/*==========================================================================\
|Programa  | RUNPROC  | Autor | Reginaldo Borges       | Data ³ 16/02/18    |
|===========================================================================|
|Desc.     | Processamento dos dados dos produtos sem Giro                  |
|===========================================================================|
|Sintaxe   | RUNPROC                                                       |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function RunProc(_nOpc)

Local cAssunto  := EncodeUTF8("Relatório dos produtos sem Giro! ","cp1252")
Local QRY1      := ""
Local cPrefixo  := ""
Local _nPag     := 1 
Local _cCampo   := '('
Local _cMes     := 0
Local _cFornec  := ""
Local _nLin      := 0
Local nLinAx    := 0
Local nCol      := 70
Local cNomeFor  := ""
Local nTotalGer := 0
Local nTotal    := 0
Local nTotalCom := 0
Local cCompra   := ""

Local nDiasGiro := 30
Local nDiasEst  := 10
Local cFornecD  := "      "
Local cFornecA  := "ZZZZZZ"
Local cAlmox    := "01"

Private nOpcb   := _nOpc

/*
oPrint := FWMSPrinter():New(cPrefixo,6,.T.,,.T.)
oPrint :SetLandscape () 
//oPrint :cPathPDF:="C:\Relatorios\"
oPrint :cPathPDF:="\RELATO\"    
*/

For _x := 1 to 3
	If Month(dDataBase)-_x <= 0
		_cMes := 12 + (Month(dDataBase)-_x)
	Else
		_cMes := Month(dDataBase)-_x
	EndIf
	_cCampo := _cCampo + 'B3_Q'+StrZero(_cMes,2)+Iif(_x<>3,'+',')/3/30*'+Str(nDiasEst,2))
Next


//************** QUERY PARA BUSCAR OS PRODUTOS SEM GIRO***************** 
QRY1 := "SELECT B1_COD, B1_DESC, B1_UM, (B1_LISFOR) B1_UPRC, B1_UCOM, B1_PRVMINI, B2_QATU, B2_USAI, "+_cCampo+" B3_MEDIA, A2_COD, A2_NREDUZ, A2_COMPRA, DATEDIFF(DAY,GETDATE(),SB8010.B8_DTVALID) DIAS_VENC, B8_DTVALID, B8_LOTECTL, B8_SALDO, "
	 
If cWCodFil == '01'
	QRY1 += " (SELECT B1_UCOM FROM "+RetSQLName('SB1')+" with (nolock) WHERE "+RetSQLName('SB1')+".B1_FILIAL = '04'  AND "+RetSQLName('SB1')+".B1_PROC = B2_FORNEC AND "+RetSQLName('SB1')+".B1_COD = B2_COD AND D_E_L_E_T_ = '') ULT_ENTR, "
Else
	QRY1 += " (SELECT B1_UCOM FROM "+RetSQLName('SB1')+" with (nolock) WHERE "+RetSQLName('SB1')+".B1_FILIAL = '01'  AND "+RetSQLName('SB1')+".B1_PROC = B2_FORNEC AND "+RetSQLName('SB1')+".B1_COD = B2_COD AND D_E_L_E_T_ = '') ULT_ENTR, "
EndIf	 

If cWCodFil == '01'
	QRY1 += " (SELECT B2_USAI FROM "+RetSQLName('SB2')+" with (nolock) WHERE "+RetSQLName('SB2')+".B2_FILIAL = '04'  AND "+RetSQLName('SB2')+".B2_FORNEC = B1_PROC AND "+RetSQLName('SB2')+".B2_COD = B1_COD AND "+RetSQLName('SB2')+".B2_LOCAL = '01' AND D_E_L_E_T_ = '') ULT_SAIDA "
Else
	QRY1 += " (SELECT B2_USAI FROM "+RetSQLName('SB2')+" with (nolock) WHERE "+RetSQLName('SB2')+".B2_FILIAL = '01'  AND "+RetSQLName('SB2')+".B2_FORNEC = B1_PROC AND "+RetSQLName('SB2')+".B2_COD = B1_COD AND "+RetSQLName('SB2')+".B2_LOCAL = '01' AND D_E_L_E_T_ = '') ULT_SAIDA "	
EndIf	 

QRY1 += " FROM " + RetSQLName("SB1") + " SB1 with (nolock) "
QRY1 += " inner join " + RetSQLName("SB2") + " SB2 with (nolock) "
QRY1 += "    on SB2.D_E_L_E_T_ <> '*' "
QRY1 += "    and SB2.B2_FILIAL = '"+xFilial('SB2')+"' "
QRY1 += "    and SB2.B2_USAI < '"+DtoS(dDataBase-nDiasGiro)+"' "
QRY1 += "    and SB2.B2_QATU > 0 "
QRY1 += "    and SB1.B1_COD = SB2.B2_COD "
QRY1 += "    and SB2.B2_LOCAL = '"+cAlmox+"' "

QRY1 += " inner join " + RetSQLName("SB3") + " SB3 with (nolock) "
QRY1 += "    on SB3.D_E_L_E_T_ <> '*' "
QRY1 += "    and SB3.B3_FILIAL = '"+xFilial('SB3')+"' "
QRY1 += "    and SB1.B1_COD = SB3.B3_COD "

QRY1 += " left join " + RetSQLName("SA2") + " SA2 with (nolock) "
QRY1 += "    on SA2.D_E_L_E_T_ <> '*' "
QRY1 += "    and SA2.A2_COMPRA <>'' "
QRY1 += "    and SB1.B1_LOJPROC = SA2.A2_LOJA "
QRY1 += "    and SB1.B1_PROC = SA2.A2_COD "

QRY1 += " left join " + RetSQLName("SB8") + " SB8 with (nolock) "
QRY1 += "    on SB8.D_E_L_E_T_ <> '*' "
QRY1 += "    and SB8.B8_FILIAL = '"+xFilial('SB8')+"' "
QRY1 += "    and SB8.B8_SALDO > 0 "
QRY1 += "    and SB8.B8_LOCAL ='01' "
QRY1 += "    and DATEDIFF(DAY,GETDATE(),SB8.B8_DTVALID) < 390 "
QRY1 += "    and SB1.B1_COD = SB8.B8_PRODUTO "

QRY1 += " WHERE SB1.D_E_L_E_T_ <> '*' "
QRY1 += "    and SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
QRY1 += "    and SB1.B1_PROC BETWEEN '"+cFornecD+"' AND '"+cFornecA+"' "
QRY1 += "    and SB1.B1_TIPO = 'PA' "
QRY1 += "    and DATEDIFF(DAY,SB1.B1_UREV,'"+DToS(date())+"') > 30 "

QRY1 += "ORDER BY A2_COMPRA, A2_COD, B1_DESC"
QRY1 := ChangeQuery(QRY1)
	
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY1), 'QRY1', .F., .T.)   

memowrite('DIPR94.SQL',QRY1)


//**************IMPRIMINDO OS DADOS*****************

DbSelectArea("QRY1")
DbGoTop()

cCompra  := QRY1->A2_COMPRA

If _nOpc == 1
	cPrefixo := QRY1->A2_COMPRA
Else
	cPrefixo := "Produtos_Sem_Giro"
EndIf	

oPrint := FWMSPrinter():New(cPrefixo,6,.T.,,.T.)
oPrint :SetLandscape () 
//oPrint :cPathPDF:="C:\Relatorios\"
oPrint :cPathPDF:="\RELATO\"


oPrint:Startpage()
R94Cab(@_nLin,@_nPag,QRY1->A2_COMPRA)

_cFornec := QRY1->A2_COD 
cNomeFor := QRY1->A2_COD+" - "+Posicione("SA2",1,xFilial("SA2")+QRY1->A2_COD,"A2_NOME")

oPrint:Say(_nLin,nCol,cNomeFor,oFont17n,100,CLR_RED)

_nlin+=60
nLinAx := 40

If _nOpc == 1

	While QRY1->(!EOF())
	
	
	     cArq002 := "\RELATO\"+QRY1->A2_COMPRA+".rel" //Variavel recebendo o arquivo para enviar como anexo
	     If File(cArq002)
	     	fErase(cArq002)
	     EndIF
	
		If _nLin > 2100
			
			oPrint:EndPage()
			oPrint:Startpage()
			R94Cab(@_nLin,@_nPag,QRY1->A2_COMPRA)
			
		EndIf
	
	
		If _cFornec <> QRY1->A2_COD
			
			cNomeFor := QRY1->A2_COD+" - "+Posicione("SA2",1,xFilial("SA2")+QRY1->A2_COD,"A2_NOME")
			oPrint:Say(_nlin,nCol,cNomeFor,oFont17n,100,CLR_RED)
			_nlin += 60
			nTotal := 0
			
		EndIf
	
		oPrint:Say(_nlin ,nCol,SUBSTR(QRY1->B1_COD,1,6)+" - "+QRY1->B1_DESC,oFont15,100,CLR_BLUE)
		//oPrint:Say(_nlin ,nCol+=1000,QRY1->A2_NREDUZ,oFont15n,100,CLR_BLUE)
		oPrint:Say(_nlin ,nCol+=1230,QRY1->B1_UM,oFont15,100,CLR_BLUE)
		
		oPrint:SayAlign(_nLin-nLinAx,nCol+=100,Transform(QRY1->B1_UPRC,"@E 999,999,999.99"),oFont15,200,_nLin-nLinAx,,1,0)
		If !Empty(QRY1->B8_LOTECTL)
			oPrint:SayAlign(_nLin-nLinAx,nCol+=250,Transform(QRY1->B8_SALDO,"@E 999,999,999"),oFont15,200,_nLin-nLinAx,,1,0)
			oPrint:SayAlign(_nLin-nLinAx,nCol+=250,Transform((QRY1->B1_UPRC * QRY1->B8_SALDO),"@E 999,999,999.99"),oFont15,200,_nLin-nLinAx,,1,0)
		Else
			oPrint:SayAlign(_nLin-nLinAx,nCol+=250,Transform(QRY1->B2_QATU,"@E 999,999,999"),oFont15,200,_nLin-nLinAx,,1,0)
			oPrint:SayAlign(_nLin-nLinAx,nCol+=250,Transform((QRY1->B1_UPRC * QRY1->B2_QATU),"@E 999,999,999.99"),oFont15,200,_nLin-nLinAx,,1,0)
		EndIf
		oPrint:SayAlign(_nLin-nLinAx,nCol+=260,Transform(QRY1->B3_MEDIA,"@E 999,999,999"),oFont15,200,_nLin-nLinAx,,1,0)
	

		If QRY1->B1_UCOM > QRY1->ULT_ENTR 
			oPrint:Say(_nlin ,nCol+=250,SubStr(QRY1->B1_UCOM,7,2)+'/'+SubStr(QRY1->B1_UCOM,5,2)+'/'+SubStr(QRY1->B1_UCOM,1,4),oFont15,100,CLR_BLUE)
		Else	
			oPrint:Say(_nlin ,nCol+=250,SubStr(QRY1->ULT_ENTR,7,2)+'/'+SubStr(QRY1->ULT_ENTR,5,2)+'/'+SubStr(QRY1->ULT_ENTR,1,4),oFont15,100,CLR_BLUE)		
		EndIf
		
		oPrint:Say(_nlin ,nCol+=200,SubStr(QRY1->B2_USAI,7,2)+'/'+SubStr(QRY1->B2_USAI,5,2)+'/'+SubStr(QRY1->B2_USAI,1,4),oFont15,100,CLR_BLUE)
		oPrint:Say(_nlin ,nCol+=200,SubStr(QRY1->ULT_SAIDA,7,2)+'/'+SubStr(QRY1->ULT_SAIDA,5,2)+'/'+SubStr(QRY1->ULT_SAIDA,1,4),oFont15,100,CLR_BLUE)
		
		//INCLUSAO DO LOTE E DATA DE VALIDADE - FELIPE DURAN 09/03/2020
		If !Empty(QRY1->B8_LOTECTL)
			nCol  := 70
			_nLin +=50
			oPrint:Say(_nlin ,nCol,"LOTE - "+QRY1->B8_LOTECTL,oFont15,100,CLR_RED)
			oPrint:Say(_nlin ,nCol+=550,"DATA VALIDADE - "+SubStr(QRY1->B8_DTVALID,7,2)+'/'+SubStr(QRY1->B8_DTVALID,5,2)+'/'+SubStr(QRY1->B8_DTVALID,1,4),oFont15,100,CLR_RED)
		EndIf
		//FIM
		
		_nLin +=20
		oPrint:Line(_nLin,0050,_nLin,3000,CLR_RED)
		_nLin +=20
		
		
		nCol  := 70
		_nlin += 50
		_cFornec  := QRY1->A2_COD
		If !Empty(QRY1->B8_LOTECTL)
			nTotal    += (QRY1->B1_UPRC * QRY1->B8_SALDO)
			nTotalGer += (QRY1->B1_UPRC * QRY1->B8_SALDO)
		Else
			nTotal    += (QRY1->B1_UPRC * QRY1->B2_QATU)
			nTotalGer += (QRY1->B1_UPRC * QRY1->B2_QATU)
		EndIf	
		QRY1->(DbSkip())
	
		If _cFornec <> QRY1->A2_COD
		
			oPrint:SayAlign(_nLin-nLinAx,1700,"Total: ",oFont16,200,_nLin-nLinAx,,1,0)
			oPrint:SayAlign(_nLin-nLinAx,1900,Transform(nTotal,"@E 999,999,999.99"),oFont16,200,_nLin-nLinAx,,1,0)
	
			_nLin +=20
			oPrint:Line(_nLin,0050,_nLin,3000,CLR_BLUE)
			_nLin +=60
	
			nTotal    := 0
					
		EndIf
	
		If cCompra <> QRY1->A2_COMPRA
			
				
			oPrint:SayAlign(_nLin-nLinAx,1700,"Total Geral: ",oFont16,200,_nLin-nLinAx,,1,0)
			oPrint:SayAlign(_nLin-nLinAx,1900,Transform(nTotalGer,"@E 999,999,999.99"),oFont16,200,_nLin-nLinAx,,1,0)
					
			oPrint:EndPage()
			oPrint:SetViewPDF(.F.)
			oPrint:Print()
			
			cPrefixo :=cCompra
			cArq001 := "\RELATO\"+cPrefixo+".pdf" //Variavel recebendo o arquivo para enviar como anexo
	
			If      File(cArq001) //Se o arquivo existir no diretorio, chama o envio do e-mail
				//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo comentada
				//ENV_MAIL("rosemeire.ferraris@dipromed.com.br",cCompra,cArq001)
				//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo substituida
				ENV_MAIL(IIF(Empty(SUPERGETMV("MV_#EMLSCH", .F., "")),"rosemeire.ferraris@dipromed.com.br",GETMV("MV_#EMLSCH")),cCompra,cArq001)
			EndIf
				
			cPrefixo :=QRY1->A2_COMPRA
			oPrint := FWMSPrinter():New(cPrefixo,6,.T.,,.T.)
			oPrint :SetLandscape () 
			//oPrint :cPathPDF:="C:\Relatorios\"
			oPrint :cPathPDF:="\RELATO\"
	
			oPrint:EndPage()
			oPrint:Startpage()
			R94Cab(@_nLin,@_nPag,QRY1->A2_COMPRA)
					
			nTotalGer := 0
		    cCompra   := QRY1->A2_COMPRA
			
		EndIf	    
		
	
	EndDo

	QRY1->(dbCloseArea())

Else

	While QRY1->(!EOF())

	     cArq002 := "\RELATO\Produtos_Sem_Giro.rel" //Variavel recebendo o arquivo para enviar como anexo
	     If File(cArq002)
	     	fErase(cArq002)
	     EndIF
	
		If _nLin > 2100
			
			oPrint:EndPage()
			oPrint:Startpage()
			R94Cab(@_nLin,@_nPag,QRY1->A2_COMPRA)
			
		EndIf
	
	
		If _cFornec <> QRY1->A2_COD
			
			cNomeFor := QRY1->A2_COD+" - "+Posicione("SA2",1,xFilial("SA2")+QRY1->A2_COD,"A2_NOME")
			oPrint:Say(_nlin,nCol,cNomeFor,oFont17n,100,CLR_RED)
			_nlin += 60
			nTotal := 0
			
		EndIf
	
		oPrint:Say(_nlin ,nCol,SUBSTR(QRY1->B1_COD,1,6)+" - "+QRY1->B1_DESC,oFont15,100,CLR_BLUE)
		//oPrint:Say(_nlin ,nCol+=1000,QRY1->A2_NREDUZ,oFont15n,100,CLR_BLUE)
		oPrint:Say(_nlin ,nCol+=1230,QRY1->B1_UM,oFont15,100,CLR_BLUE)
		
		oPrint:SayAlign(_nLin-nLinAx,nCol+=100,Transform(QRY1->B1_UPRC,"@E 999,999,999.99"),oFont15,200,_nLin-nLinAx,,1,0)
		If !Empty(QRY1->B8_LOTECTL)
			oPrint:SayAlign(_nLin-nLinAx,nCol+=250,Transform(QRY1->B8_SALDO,"@E 999,999,999"),oFont15,200,_nLin-nLinAx,,1,0)
			oPrint:SayAlign(_nLin-nLinAx,nCol+=250,Transform((QRY1->B1_UPRC * QRY1->B8_SALDO),"@E 999,999,999.99"),oFont15,200,_nLin-nLinAx,,1,0)
		Else
			oPrint:SayAlign(_nLin-nLinAx,nCol+=250,Transform(QRY1->B2_QATU,"@E 999,999,999"),oFont15,200,_nLin-nLinAx,,1,0)
			oPrint:SayAlign(_nLin-nLinAx,nCol+=250,Transform((QRY1->B1_UPRC * QRY1->B2_QATU),"@E 999,999,999.99"),oFont15,200,_nLin-nLinAx,,1,0)
		EndIf
		oPrint:SayAlign(_nLin-nLinAx,nCol+=260,Transform(QRY1->B3_MEDIA,"@E 999,999,999"),oFont15,200,_nLin-nLinAx,,1,0)
	
		If QRY1->B1_UCOM > QRY1->ULT_ENTR 
			oPrint:Say(_nlin ,nCol+=250,SubStr(QRY1->B1_UCOM,7,2)+'/'+SubStr(QRY1->B1_UCOM,5,2)+'/'+SubStr(QRY1->B1_UCOM,1,4),oFont15,100,CLR_BLUE)
		Else	
			oPrint:Say(_nlin ,nCol+=250,SubStr(QRY1->ULT_ENTR,7,2)+'/'+SubStr(QRY1->ULT_ENTR,5,2)+'/'+SubStr(QRY1->ULT_ENTR,1,4),oFont15,100,CLR_BLUE)		
		EndIf		
				
		oPrint:Say(_nlin ,nCol+=200,SubStr(QRY1->B2_USAI,7,2)+'/'+SubStr(QRY1->B2_USAI,5,2)+'/'+SubStr(QRY1->B2_USAI,1,4),oFont15,100,CLR_BLUE)
		oPrint:Say(_nlin ,nCol+=200,SubStr(QRY1->ULT_SAIDA,7,2)+'/'+SubStr(QRY1->ULT_SAIDA,5,2)+'/'+SubStr(QRY1->ULT_SAIDA,1,4),oFont15,100,CLR_BLUE)
		
		//INCLUSAO DO LOTE E DATA DE VALIDADE - FELIPE DURAN 09/03/2020
		If !Empty(QRY1->B8_LOTECTL)
			nCol  := 70
			_nLin +=50
			oPrint:Say(_nlin ,nCol,"LOTE - "+QRY1->B8_LOTECTL,oFont15,100,CLR_RED)
			oPrint:Say(_nlin ,nCol+=550,"DATA VALIDADE - "+SubStr(QRY1->B8_DTVALID,7,2)+'/'+SubStr(QRY1->B8_DTVALID,5,2)+'/'+SubStr(QRY1->B8_DTVALID,1,4),oFont15,100,CLR_RED)
		EndIf
		//FIM
		
		_nLin +=20
		oPrint:Line(_nLin,0050,_nLin,3000,CLR_RED)
		_nLin +=20
		
		
		nCol  := 70
		_nlin += 50
		_cFornec  := QRY1->A2_COD
		If !Empty(QRY1->B8_LOTECTL)
			nTotal    += (QRY1->B1_UPRC * QRY1->B8_SALDO)
			nTotalGer += (QRY1->B1_UPRC * QRY1->B8_SALDO)
			nTotalCom += (QRY1->B1_UPRC * QRY1->B8_SALDO)
		Else
			nTotal    += (QRY1->B1_UPRC * QRY1->B2_QATU)
			nTotalGer += (QRY1->B1_UPRC * QRY1->B2_QATU)
			nTotalCom += (QRY1->B1_UPRC * QRY1->B2_QATU)
		EndIf
		
		QRY1->(DbSkip())
	
		If _cFornec <> QRY1->A2_COD
		
			oPrint:SayAlign(_nLin-nLinAx,1700,"Total: ",oFont16,200,_nLin-nLinAx,,1,0)
			oPrint:SayAlign(_nLin-nLinAx,1900,Transform(nTotal,"@E 999,999,999.99"),oFont16,200,_nLin-nLinAx,,1,0)
	
			_nLin +=20
			oPrint:Line(_nLin,0050,_nLin,3000,CLR_BLUE)
			_nLin +=60
	
			nTotal    := 0
					
		EndIf
	
		If cCompra <> QRY1->A2_COMPRA
			
				
			oPrint:SayAlign(_nLin-nLinAx,1600,"Total Comprador: ",oFont16,300,_nLin-nLinAx,,1,0)
			oPrint:SayAlign(_nLin-nLinAx,1900,Transform(nTotalCom,"@E 999,999,999.99"),oFont16,200,_nLin-nLinAx,,1,0)
			
			oPrint:EndPage()
			oPrint:Startpage()
			R94Cab(@_nLin,@_nPag,QRY1->A2_COMPRA)
					
			nTotalCom := 0
		    cCompra   := QRY1->A2_COMPRA
			
		EndIf	    
		
	
	EndDo


	oPrint:SayAlign(_nLin-nLinAx,1700,"Total Geral: ",oFont16,200,_nLin-nLinAx,,1,0)
	oPrint:SayAlign(_nLin-nLinAx,1900,Transform(nTotalGer,"@E 999,999,999.99"),oFont16,200,_nLin-nLinAx,,1,0)

	QRY1->(dbCloseArea())
	
			
	oPrint:EndPage()
	oPrint:SetViewPDF(.F.)
	oPrint:Print()
	
	cArq001 := "\RELATO\"+cPrefixo+".pdf" //Variavel recebendo o arquivo para enviar como anexo
	
	
	If      File(cArq001) //Se o arquivo existir no diretorio, chama o envio do e-mail
		//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo comentada
	   	//ENV_MAIL("rosemeire.ferraris@dipromed.com.br","",cArq001)
		//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo substituida
		ENV_MAIL(IIF(Empty(SUPERGETMV("MV_#EMLSCH", .F., "")),"rosemeire.ferraris@dipromed.com.br",GETMV("MV_#EMLSCH"))	,"",cArq001)  
	EndIf

EndIf

Return(.T.)      


/*==========================================================================\
|Programa  | R94Cab | Autor | Reginaldo Borges   | Data ³   16/02/2018     |
|==========================================================================|
|Desc.     | Cabecalho do relatorio										   |
|==========================================================================|
|Sintaxe   | R94Cab                                                     |
|==========================================================================|
|Uso       | Especifico DIPROMED                                           |
\==========================================================================*/

Static Function R94Cab(nLinha,_nPag,cCompra)

Local nLin     := 0100
Local nCol     := 0070
Local nColAux  := 0
Local _cEmpresa:=""
Local cCompr   := Posicione("SY1",1,xFilial("SY1")+cCompra,"Y1_NOME") 

	//Box Geral
	oPrint:Box(nLin,0050,2400,3000)
	
	If "01" $ cWCodEmp
		If "01" $ cWCodFil
			_cEmpresa:="DIPROMED"+"-"+"MATRIZ"
		Else
		   _cEmpresa:="DIPROMED"+"-"+"CD"
		EndIf
	Else
		If "01" $ cWCodFil
			_cEmpresa:="HEALTH"+"-"+"MATRIZ"
		Else
		   _cEmpresa:="HEALTH"+"-"+"CD"
		EndIf	
	EndIf
	
	
	nLin +=60	
	oPrint:Say(nLin,1300,_cEmpresa,oFont20n,,CLR_RED)
	oPrint:Say(nLin,2880,"Pag: "+StrZero(_nPag,2),oFont15n,100)

	nLin +=50
	oPrint:Line(nLin-10,0050,nLin-10,3000)

	nLin +=50
	
	oPrint:Say(nLin,070,"SIGA / DIPR094 ",oFont15n)
	oPrint:Say(nLin,1000,"PRODUTOS SEM GIRO - Comprador(a): "+cCompra+" - "+cCompr,oFont17n)
	oPrint:Say(nLin,2720,"Emissao: "+DTOC(dDataBase),oFont15n)
	
	nLin +=40
	oPrint:Line(nLin,0050,nLin,3000)
	
	nLin +=50
	nColAux := nCol
	oPrint:Say(nLin,nCol,"Produto - Descrição",oFont15n,,CLR_BLUE)
	//oPrint:Say(nLin,nColAux+=1000,"Marca",oFont15n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=1230,"UM",oFont15n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=100,"Custo Entrada",oFont15n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=280,"Quantidade",oFont15n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=350,"Total",oFont15n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=160,"Est. Minimo",oFont15n,,CLR_BLUE)
	oPrint:Say(nLin,nColAux+=200,"Ult. Entrada",oFont15n,,CLR_BLUE)
		
	If cWCodFil == '01'	
		oPrint:Say(nLin,nColAux+=180,"Ult.Saida_MTZ",oFont15n,,CLR_BLUE)	
		oPrint:Say(nLin,nColAux+=220,"Ult.Saida_CD",oFont15n,,CLR_BLUE)
	Else
		oPrint:Say(nLin,nColAux+=180,"Ult.Saida_CD",oFont15n,,CLR_BLUE)	
		oPrint:Say(nLin,nColAux+=220,"Ult.Saida_MTZ",oFont15n,,CLR_BLUE)	
	Endif	
	
	nLin +=40
	oPrint:Line(nLin,0050,nLin,3000,CLR_BLUE)
	
	nLin +=50
	nLinha := nLin
	_nPag++

Return 


/*==========================================================================\
|Programa  | ENV_MAIL | Autor | Reginaldo Borges       | Data ³ 31/01/18    |
|===========================================================================|
|Desc.     | Envia EMail com anexos dos relatórios dos pedidos por vendedor |
|===========================================================================|
|Sintaxe   | ENV_MAIL                                                       |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/
					    
Static Function ENV_MAIL(cEmail,cCompra,cArq001)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := "" 
Local cEmailCc  := ""
Local cEmailBcc := ""                
Local lResult   := .F.
Local cError    := ""
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.
Local aAnexos   := {}
Local cAssunto  := ""
Local cBody     := ""
Local _cFilial  := ""
Local cCompr    := ""
Local cMsg	    := ""

If Empty(cAssunto)
	If "01" $ cWCodEmp
		If "01" $ cWCodFil
			_cFilial:="MATRIZ"
		Else
			_cFilial:="CD"
		EndIf
	Else
		If "01" $ cWCodFil
			_cFilial:="MATRIZ"
		Else
			_cFilial:="CD"
		EndIf	
	EndIf
						
	If nOpcb == 1
		cCompr   :=Posicione("SY1",1,xFilial("SY1")+cCompra,"Y1_NOME")                              
		cAssunto :="Produtos sem Giro - "+_cFilial+" - "+cCompra+"-"+cCompr+"!"
		If cCompra == "009"
			cEmailTo  := "rodrigo.rodrigues@dipromed.com.br;rosemeire.ferraris@dipromed.com.br;santiago.gomes@dipromed.com.br"//cEmail - Rose quer receber apenas o relatório geral.
			cEmailCc  := "felipe.duran@dipromed.com.br" 
		Else
			cEmailTo  := "rodrigo.rodrigues@dipromed.com.br;rosemeire.ferraris@dipromed.com.br;santiago.gomes@dipromed.com.br"//AllTrim(Posicione("SY1",1,xFilial("SY1")+cCompra,"Y1_EMAIL"))	
			cEmailCc  := "felipe.duran@dipromed.com.br"
		EndIf
		
	Else
		cAssunto := EncodeUTF8("Relatório Geral dos Produtos sem Giro - "+_cFilial+"!","cp1252")
		cEmailTo  := "rodrigo.rodrigues@dipromed.com.br;rosemeire.ferraris@dipromed.com.br;santiago.gomes@dipromed.com.br"//cEmail 
		cEmailCc  := "felipe.duran@dipromed.com.br"
		
	End

	//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo adicionada - INICIO
	cEmailTo	:= IIF(Empty(SUPERGETMV("MV_#EMLSCH", .F., "")),cEmailTo,GETMV("MV_#EMLSCH"))	
	cEmailCc	:= IIF(Empty(SUPERGETMV("MV_#EMLSCH", .F., "")),cEmailCc,GETMV("MV_#EMLSCH"))
	//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo adicionada - FIM

EndIf

Aadd(aAnexos,cArq001)


cBody += (+Chr(13) +Chr(10) +Chr(13) +Chr(10))
cBody += '<font face="Arial" size=3>RELATÓRIO DOS PRODUTOS SEM GIRO REFERENTE AO DIA: '+DTOC(dDataBase)+"." +Chr(13) +Chr(10)
//cBody += '<font face="Arial" size=3>OLÁ, POR FAVOR DESCONSIDERAR ESSE E-MAIL, POIS SE TRATA DE UM TESTE!!!!!!!"' +Chr(13) +Chr(10)
cBody += '<font face="Arial" size=3>PRODUTOS SEM GIRO HÁ MAIS DE 30 DIAS!!!"' +Chr(13) +Chr(10)

If ("0401" $ cWCodEmp+cWCodFil)
	//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo comentada
    //cEmailBcc:="vendas@healthquality.ind.br" 
	//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo substituida
	cEmailBcc:=IIF(Empty(SUPERGETMV("MV_#EMLSCH", .F., "")),"vendas@healthquality.ind.br",GETMV("MV_#EMLSCH"))  
Endif    


If GetNewPar("ES_ATIVJOB",.T.)
	cEmail+=";"+AllTrim(cEmailBcc)
	u_UEnvMail(AllTrim(cEmail),cAssunto,nil,"",cFrom,"ENV_065(DIPR065.prw)",cMsg)
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf


//cEmailTo := "reginaldo.borges@dipromed.com.br"
//cEmailCc := "reginaldo.borges@dipromed.com.br"
//cEmailBcc:= "reginaldo.borges@dipromed.com.br"


If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	SubStr(cAssunto,1,55);
	BODY    	cBody;
	ATTACHMENT aAnexos[1];
	RESULT lResult
	
	If !lResult
		//Erro no envio do email''
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Atenção"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi("Atenção"))
EndIf


fErase(cArq001)

Return(.T.)
