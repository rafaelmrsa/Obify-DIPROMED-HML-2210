#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
/*/{Protheus.doc} ETIQFEDEX
IMPRESSAO DE ETIQUETAS DESTINATÁRIO
@author Obify
@since 20/05/2021
@version undefined
@param lAutomatic, logical, Caso seja chamado por rotina automatica
@see www.obify.com.br
/*/

User Function ETIQFEDEX()
Local cArq 			:= ""//CriaTrab(,.F.)+".TXT" //Nome do Arquivo a Gerar
//Local Path 		:= GetTempPath() + Arq //Local de Geração do Arquivo
Local ENTER			:= Chr(13)+Chr(10)
Local QRY1		 	:= ""
Local cLocalEtiq 	:= Iif(ExistDir("C:\etiqueta\"),"C:\etiqueta\","C:\temp\")
Local ni			:= 0
Local xi			:= 0
Local nVolIni		:= 0
Local nVolFim		:= 0
Local nVolume		:= 0
Local cCodBar		:= ""

//Rafael Moraes Rosa - 12/01/2023 - VARIAVEL
Local cEndEnt	:= ""
Local cCidEnt	:= ""
Local cEstEnt	:= ""
Local cCEPEnt	:= ""
Local cBairEnt	:= ""
Local cCompEnt	:= ""

Private cPerg		:= PADR("ETIQFEDEX",10) //Pergunta
Private cPort		:= AllTrim(SuperGetMV("ES_LPTETQ1",.F.,"LPT1")) //Define a porta padrão da impressora
//Private cIpImp	:= AllTrim(SuperGetMV("ES_LPTETQ1",.F.,"LPT1")) //Define a porta padrão da impressora
Private nHdl


//Rafael Moraes Rosa - 12/01/2023 - INICIO
//dbSelectArea("SM0")

IF cEmpAnt+cFilAnt = '0101'

	SM0->(dbSeek("0104"))
		cEndEnt	:= SM0->M0_ENDENT
		cCidEnt		:= SM0->M0_CIDENT
		cEstEnt		:= SM0->M0_ESTENT
		cCEPEnt	:= SM0->M0_CEPENT
		cBairEnt	:= SM0->M0_BAIRENT
		cCompEnt	:= SM0->M0_COMPENT

ELSE
	SM0->(dbSeek(cEmpAnt+cFilAnt))
		cEndEnt	:= SM0->M0_ENDENT
		cCidEnt		:= SM0->M0_CIDENT
		cEstEnt		:= SM0->M0_ESTENT
		cCEPEnt	:= SM0->M0_CEPENT
		cBairEnt	:= SM0->M0_BAIRENT
		cCompEnt	:= SM0->M0_COMPENT

ENDIF
//SM0->(dbSkip())

SM0->(dbSeek(cEmpAnt+cFilAnt))

//Rafael Moraes Rosa - 12/01/2023 - FIM

If !Pergunte(cPerg,.T.)
	Return
EndIf

//Verifica se a rotina é automatica
/*
If !Empty(cProd)
	Pergunte(cPerg,.F.)
	mv_par01 := cProd
	//mv_par02 := cProd
	mv_par02 := nQtde		
	mv_par03 := cLote 
Else
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
EndIf
*/
QRY1 := " SELECT F2_VOLUME1, F2_DOC, F2_SERIE, "
QRY1 += " A1_NOME, A1_NREDUZ, A1_CGC, "
QRY1 += " C5_ENDENT, C5_BAIRROE, C5_MUNE, C5_ESTE, C5_CEPE "
QRY1 += " FROM "+RetSQLName("SF2")+" SF2 "
QRY1 += " INNER JOIN "+RetSQLName("SD2")+" SD2 ON "
QRY1 += " D2_FILIAL = F2_FILIAL "
QRY1 += " AND D2_DOC = F2_DOC "
QRY1 += " AND D2_SERIE = F2_SERIE "
QRY1 += " AND D2_CLIENTE = F2_CLIENTE "
QRY1 += " AND D2_LOJA = F2_LOJA "
QRY1 += " AND D2_ITEM = '01' "   
QRY1 += " AND SD2.D_E_L_E_T_ = '' "
QRY1 += " INNER JOIN "+RetSQLName("SC5")+" SC5 ON "
QRY1 += " D2_FILIAL = C5_FILIAL "
QRY1 += " AND D2_PEDIDO = C5_NUM "
QRY1 += " AND SC5.D_E_L_E_T_ = '' "
QRY1 += " INNER JOIN "+RetSQLName("SA1")+" SA1 ON "
QRY1 += " F2_CLIENTE = A1_COD "
QRY1 += " AND F2_LOJA = A1_LOJA "
QRY1 += " AND SA1.D_E_L_E_T_ = '' "
QRY1 += " WHERE F2_SERIE = '" + MV_PAR01 + "'"
QRY1 += " AND F2_DOC BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'"
QRY1 += " AND F2_FILIAL = '" + xFilial('SF2') + "'"
QRY1 += " AND SF2.D_E_L_E_T_ <> '*' "
QRY1 += " AND F2_TRANSP = '955917' "
QRY1 += "ORDER BY F2_DOC, F2_SERIE"
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query
DbSelectArea("QRY1")
QRY1->(dbGotop())
If QRY1->(Eof())
	msgInfo("Não foram encontrados registros com os parâmetros informados","Atenção")
	Return
EndIf
Do While QRY1->(!Eof())
	
	If QRY1->F2_VOLUME1 == 0 .and. MV_PAR04 == 0
		msgInfo("Volume da nota fiscal "+ALLTRIM(QRY1->F2_DOC)+" está com ZERO","Atenção")
		QRY1->(DbSkip())
	Endif
	If MV_PAR04 <> 0 //se preencher volume inicial pega dessa informação para começar impressao
		nVolIni := MV_PAR04
	EndIf
	If MV_PAR05 <> 0 //se preencher volume final pega dessa informação para finalizar a impressao
		nVolFim := MV_PAR05
	EndIf
	nVolume := QRY1->F2_VOLUME1
	cArq	:= ALLTRIM(QRY1->F2_DOC)+".txt"
	If File(cLocalEtiq+cArq)
		fErase(cLocalEtiq+cArq)
	EndIf
	nHdl 	:= fCreate(cLocalEtiq+cArq) // Criando arquivo txt
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Começa LOOP de impressao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For xi := Iif(nVolIni>0,nVolIni,1) to Iif(nVolFim>0,nVolFim,nVolume)
		ni++
		If ni == 1
			cVar := "^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR8,8~SD15^JUS^LRN^CI27^PA0,1,1,0^XZ"+ENTER
		Else
			cVar := ""
		EndIf

		cVar += " ^XA"+ENTER
		cVar += " ^MMT"+ENTER
		cVar += " ^PW799"+ENTER
		cVar += " ^LL799"+ENTER
		cVar += " ^LS0"+ENTER
		cVol 	:= StrZero(nVolume,4)
		cCodBar	:= StrZero(Val(QRY1->A1_CGC),14)+QRY1->F2_DOC+StrZero(xi,4)+LEFT(cVol,3)+">6"+Right(cVol,1) //o caracter >6 é necessário para o CODE128
		//CodBarras
		cVar += "^BY3,3,120^FT67,157^BCN,,Y,N"+ENTER
		//cVar += "^FH\^FD>;>"+CVALTOCHAR(cCodBar)+"^FS"+ENTER //OLD
		//cVar += "^FH\^FD>;"+051298350001600003386760001001>69+"^FS
		cVar += "^FH\^FD>;"+cCodBar+"^FS
		cVar += "^FT60,244^A0N,23,23^FH\^CI28^FDREMETENTE: ^FS^CI27"
		cVar += "^FT60,273^A0N,23,23^FH\^CI28^FD"+AllTrim(SM0->M0_NOMECOM)+"^FS^CI27"
		
		//Rafael Moraes Rosa - 13/01/2023 - INICIO - LINHA COMENTADA
		/*
		cVar += "^FT60,302^A0N,23,23^FH\^CI28^FD"+AllTrim(SM0->M0_ENDENT)+"^FS^CI27"
		cVar += "^FT60,331^A0N,23,23^FH\^CI28^FDBAIRRO: "+AllTrim(SM0->M0_BAIRENT)+"^FS^CI27"
		cVar += "^FT60,360^A0N,23,23^FH\^CI28^FDCIDADE: "+AllTrim(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT+" - CEP:"+ALLTRIM(SM0->M0_CEPENT)+"^FS^CI27"
		*/
		//Rafael Moraes Rosa - 13/01/2023 - INICIO - LINHA COMENTADA

		//Rafael Moraes Rosa - 13/01/2023 - INICIO - LINHA SUBSTITUIDA
		cVar += "^FT60,302^A0N,23,23^FH\^CI28^FD"+AllTrim(cEndEnt)+"^FS^CI27"
		cVar += "^FT60,331^A0N,23,23^FH\^CI28^FDBAIRRO: "+AllTrim(cBairEnt)+"^FS^CI27"
		cVar += "^FT60,360^A0N,23,23^FH\^CI28^FDCIDADE: "+AllTrim(cCidEnt)+" - "+cEstEnt+" - CEP:"+ALLTRIM(cCEPEnt)+"^FS^CI27"
		//Rafael Moraes Rosa - 13/01/2023 - FIM - LINHA SUBSTITUIDA

		cVar += "^FT60,389^A0N,23,23^FH\^CI28^FDCNPJ:"+AllTrim(SM0->M0_CGC)+"^FS^CI27"
		cVar += "^FT60,447^A0N,23,23^FH\^CI28^FDDESTINATARIO: ^FS^CI27"
		cVar += "^FT60,476^A0N,23,23^FH\^CI28^FD"+AllTrim(QRY1->A1_NOME)+"^FS^CI27"
		cVar += "^FT60,505^A0N,23,23^FH\^CI28^FD"+AllTrim(QRY1->C5_ENDENT)+"^FS^CI27"
		cVar += "^FT60,534^A0N,23,23^FH\^CI28^FDBAIRRO:"+AllTrim(QRY1->C5_BAIRROE)+"^FS^CI27"
		cVar += "^FT60,563^A0N,23,23^FH\^CI28^FDCIDADE:"+AllTrim(QRY1->C5_MUNE)+" - "+AllTrim(QRY1->C5_ESTE)+" - CEP:"+AllTrim(QRY1->C5_CEPE)+"^FS^CI27"
		cVar += "^FT60,592^A0N,23,23^FH\^CI28^FDCNPJ:"+QRY1->A1_CGC+"^FS^CI27"
		cVar += "^FT70,663^A0N,25,25^FH\^CI28^FDNOTA FISCAL: "+AllTrim(QRY1->F2_DOC)+"^FS^CI27"
		cVar += "^FT70,694^A0N,25,25^FH\^CI28^FDVOLUME: "+CVALTOCHAR(xi)+"/"+CVALTOCHAR(nVolume)+"^FS^CI27"
		cVar += "^FO60,202^GB744,0,8^FS"
		cVar += "^FO60,409^GB744,0,8^FS"
		cVar += "^FO60,620^GB740,105,4^FS"
		cVar += "^PQ1,0,1,Y"
		cVar += "^XZ"
		
		
		If fWrite(nHdl,cVar,Len(cVar)) != Len(cVar) //Gravacao do arquivo
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo !!","Atencao!")
				fClose(nHdl)
				Return
			Endif
		Endif
	Next
	fClose(nHdl)
	ni	:= 0
	//Mapeia a porta de impressao no cliente
	//WaitRun('CMD /C NET USE LPT3 /DELETE')
	//WaitRun('CMD /C NET USE LPT3 '+cIpImp) //  \\192.168.0.15\ZEBRA_ZT240 (Exemplo)

	//WaitRun(" CMD /C COPY '"+Path+cPort"' ")
	//WaitRun(" print /d:"+cPort+	Path"' ")
	cComand	:= "COPY "+cLocalEtiq+cArq+" "+cPort
	WaitRun(" CMD /C "+cComand)
	//MsgAlert("Arquivo  '" + cLocalEtiq+cArq+ "'  Gerado com Sucesso e Enviado para Impressora '"+cPort+"'!","Atenção")	
	QRY1->(DbSkip())
End
QRY1->(dbCloseArea())	
Return
