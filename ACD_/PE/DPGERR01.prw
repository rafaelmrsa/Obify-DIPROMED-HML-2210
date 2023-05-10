#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DPGERR01  � Autor � Robson Sales   		� Data � 14/11/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Ordens de Separacao                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
User Function DPGERR01()

Local aOrdem		:= {"Ordem de Separa��o"}//"Ordem de Separa��o"
Local aDevice		:= {"DISCO","SPOOL","EMAIL","EXCEL","HTML","PDF"}
Local bParam		:= {|| Pergunte("ACD100", .T.)}
Local cDevice		:= ""
Local cPathDest	:= GetSrvProfString("StartPath","\system\")
Local cRelName	:= "ACDR100"
Local cSession	:= GetPrinterSession()
Local lAdjust		:= .F.
Local nFlags		:= PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION
Local nLocal		:= 1
Local nOrdem		:= 1
Local nOrient		:= 1
Local nPrintType	:= 6
Local oPrinter	:= Nil
Local oSetup		:= Nil
Private nMaxLin	:= 600
Private nMaxCol	:= 800

cSession	:= GetPrinterSession()
cDevice	:= If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
nOrient	:= If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
nLocal		:= If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
nPrintType	:= aScan(aDevice,{|x| x == cDevice })     

oPrinter	:= FWMSPrinter():New(cRelName, nPrintType, lAdjust, /*cPathDest*/, .T.)
oSetup		:= FWPrintSetup():New (nFlags,cRelName)

oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
oSetup:SetPropert(PD_ORIENTATION , nOrient)
oSetup:SetPropert(PD_DESTINATION , nLocal)
oSetup:SetPropert(PD_MARGIN      , {0,0,0,0})
oSetup:SetOrderParms(aOrdem,@nOrdem)
oSetup:SetUserParms(bParam)

If oSetup:Activate() == PD_OK 
	fwWriteProfString(cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )	
	fwWriteProfString(cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )	
	fwWriteProfString(cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
		
	oPrinter:lServer			:= oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER	
	oPrinter:SetDevice(oSetup:GetProperty(PD_PRINTTYPE))
	oPrinter:SetLandscape()
	oPrinter:SetPaperSize(oSetup:GetProperty(PD_PAPERSIZE))
	oPrinter:setCopies(Val(oSetup:cQtdCopia))
	
	If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
		oPrinter:nDevice		:= IMP_SPOOL
		fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
		oPrinter:cPrinter		:= oSetup:aOptions[PD_VALUETYPE]
	Else 
		oPrinter:nDevice		:= IMP_PDF
		oPrinter:cPathPDF		:= oSetup:aOptions[PD_VALUETYPE]
		oPrinter:SetViewPDF(.T.)
	Endif
	
	RptStatus({|lEnd| ACD100Imp(@lEnd,@oPrinter)},"Imprimindo Relatorio...")//"Imprimindo Relatorio..."
Else 
	MsgInfo("Relat�rio cancelado pelo usu�rio.") //"Relat�rio cancelado pelo usu�rio."
	oPrinter:Cancel()
EndIf

oSetup		:= Nil
oPrinter	:= Nil

Return Nil

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    | ACD100Imp  � Autor � Robson Sales          � Data �14/11/13  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o corpo do relatorio                                 ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � ACDR100                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function ACD100Imp(lEnd,oPrinter)

Local nMaxLinha	:= 40
Local nLinCount	:= 0
Local aArea		:= GetArea()
Local cQry			:= ""
Local cOrdSep		:= ""
Private cAliasOS	:= GetNextAlias()
Private nMargDir	:= 15
Private nMargEsq	:= 20
Private nColAmz	:= nMargEsq+155
Private nColEnd	:= nColAmz+45
Private nColLot	:= nColEnd+85
Private nColSLt	:= nColLot+85
Private nSerie	:= nColSLt+40
Private nQtOri	:= nSerie+110
Private nQtSep	:= nQtOri+85
Private nQtEmb	:= nQtSep+85
Private oFontA7	:= TFont():New('Arial',,7,.T.)
Private oFontA12	:= TFont():New('Arial',,12,.T.)
Private oFontC8	:= TFont():New('Courier new',,8,.T.)
Private li			:= 10
Private nLiItm	:= 0
Private nPag		:= 0

Pergunte("ACD100",.F.)


//����������������������������Ŀ
//� Monta o arquivo temporario � 
//������������������������������
cQry := "SELECT CB7_ORDSEP,CB7_PEDIDO,CB7_CLIENT,CB7_LOJA,CB7_NOTA,"+SerieNfId('CB7',3,'CB7_SERIE')+",CB7_OP,CB7_STATUS,CB7_ORIGEM, "
cQry += "CB8_PROD,CB8_ORDSEP,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_NUMLOT,CB8_NUMSER,CB8_QTDORI,CB8_SALDOS,CB8_SALDOE"
cQry += " FROM "+RetSqlName("CB7")+","+RetSqlName("CB8")
cQry += " WHERE CB7_FILIAL = '"+xFilial("CB7")+"' AND"
cQry += " CB7_ORDSEP >= '"+MV_PAR01+"' AND"
cQry += " CB7_ORDSEP <= '"+MV_PAR02+"' AND"
cQry += " CB7_DTEMIS >= '"+DTOS(MV_PAR03)+"' AND"
cQry += " CB7_DTEMIS <= '"+DTOS(MV_PAR04)+"' AND"
cQry += " CB8_FILIAL = CB7_FILIAL AND"
cQry += " CB8_ORDSEP = CB7_ORDSEP AND"
//����������������������������������������Ŀ
//� Nao Considera as Ordens ja finalizadas � 
//������������������������������������������
If MV_PAR05 == 2
	cQry += " CB7_STATUS <> '9' AND"
EndIf
cQry += " "+RetSqlName("CB8")+".D_E_L_E_T_ = '' AND"
cQry += " "+RetSqlName("CB7")+".D_E_L_E_T_ = ''"
cQry += " ORDER BY CB7_ORDSEP,CB8_PROD"
cQry := ChangeQuery(cQry)                  
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasOS,.T.,.T.)

SetRegua((cAliasOS)->(LastRec()))
     
//���������������������������������Ŀ
//� Inicia a impressao do relatorio � 
//�����������������������������������
While !(cAliasOS)->(Eof())
	IncRegua()
	nLiItm		:= 110
	nLinCount	:= 0
	nPag++
	oPrinter:StartPage()
	CabPagina(@oPrinter)
	CabItem(@oPrinter,(cAliasOS)->CB7_ORIGEM)
	//������������������������������������������Ŀ
	//� Imprime os titulos das colunas dos itens � 
	//��������������������������������������������
	oPrinter:SayAlign(li+100,nMargDir,"Produto",oFontC8,200,200,,0)//"Produto"
	oPrinter:SayAlign(li+100,nColAmz,"Armazem",oFontC8,200,200,,0)//"Armazem"
	oPrinter:SayAlign(li+100,nColEnd,"Endere�o",oFontC8,200,200,,0)//"Endere�o"
	oPrinter:SayAlign(li+100,nColLot,"Lote",oFontC8,200,200,,0)//"Lote"
	oPrinter:SayAlign(li+100,nColSLt,"SubLt.",oFontC8,200,200,,0)//"SubLt."
	oPrinter:SayAlign(li+100,nSerie,"Num. S�rie",oFontC8,200,200,,0)//"Num. S�rie"
	oPrinter:SayAlign(li+100,nQtOri,"Qtde. Original",oFontC8,200,200,,0)//"Qtde. Original"
	oPrinter:SayAlign(li+100,nQtSep,"Qtd. a Separar",oFontC8,200,200,,0)//"Qtd. a Separar"
	oPrinter:SayAlign(li+100,nQtEmb,"Qtd. a Embalar",oFontC8,200,200,,0)//"Qtd. a Embalar"
	oPrinter:Line(li+110,nMargDir, li+110, nMaxCol-nMargEsq,, "-2")
	
	cOrdSep := (cAliasOS)->CB7_ORDSEP
	
	While !(cAliasOS)->(Eof()) .and. (cAliasOS)->CB8_ORDSEP == cOrdSep
		//������������������������������������������������Ŀ
		//� Inicia uma nova pagina caso nao estiver em EOF � 
		//��������������������������������������������������
		If nLinCount == nMaxLinha
			oPrinter:StartPage()
			nPag++
			CabPagina(@oPrinter)
			nLiItm		:= li+50
			nLinCount	:= 0
			//������������������������������������������Ŀ
			//� Imprime os titulos das colunas dos itens � 
			//��������������������������������������������			
			oPrinter:SayAlign(nLiItm,nMargDir,"Produto",oFontC8,200,200,,0)//"Produto"
			oPrinter:SayAlign(nLiItm,nColAmz,"Armazem",oFontC8,200,200,,0)//"Armazem"
			oPrinter:SayAlign(nLiItm,nColEnd,"Endere�o",oFontC8,200,200,,0)//"Endere�o"
			oPrinter:SayAlign(nLiItm,nColLot,"Lote",oFontC8,200,200,,0)//"Lote"
			oPrinter:SayAlign(nLiItm,nColSLt,"SubLt.",oFontC8,200,200,,0)//"SubLt."
			oPrinter:SayAlign(nLiItm,nSerie,"Num. S�rie",oFontC8,200,200,,0)//"Num. S�rie"
			oPrinter:SayAlign(nLiItm,nQtOri,"Qtde. Original",oFontC8,200,200,,0)//"Qtde. Original"
			oPrinter:SayAlign(nLiItm,nQtSep,"Qtd. a Separar",oFontC8,200,200,,0)//"Qtd. a Separar"
			oPrinter:SayAlign(nLiItm,nQtEmb,"Qtd. a Embalar",oFontC8,200,200,,0)//"Qtd. a Embalar"
			oPrinter:Line(li+nLiItm,nMargDir, li+nLiItm, nMaxCol-nMargEsq,, "-2")
		EndIf
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		MsSeek(xFilial("SB1")+(cAliasOS)->CB8_PROD)
		
		//����������������������������������������Ŀ
		//� Imprime os itens da ordem de separacao � 
		//������������������������������������������
		oPrinter:SayAlign(li+nLiItm,nMargDir,Alltrim((cAliasOS)->CB8_PROD)+" - "+Substr(SB1->B1_DESC,1,25),oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nColAmz,(cAliasOS)->CB8_LOCAL,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nColEnd,(cAliasOS)->CB8_LCALIZ,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nColLot,(cAliasOS)->CB8_LOTECT,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nColSLt,(cAliasOS)->CB8_NUMLOT,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nSerie,(cAliasOS)->CB8_NUMSER,oFontC8,200,200,,0)
		oPrinter:SayAlign(li+nLiItm,nQtOri+li,Transform((cAliasOS)->CB8_QTDORI,PesqPictQt("CB8_QTDORI",20)),oFontC8,200,200,1,0) 
		oPrinter:SayAlign(li+nLiItm,nQtSep+li,Transform((cAliasOS)->CB8_SALDOS,PesqPictQt("CB8_QTDORI",20)),oFontC8,200,200,1,0)
		oPrinter:SayAlign(li+nLiItm,nQtEmb+li,Transform((cAliasOS)->CB8_SALDOE,PesqPictQt("CB8_QTDORI",20)),oFontC8,200,200,1,0)
		
		nLinCount++
		//���������������������������������������������������������������Ŀ
		//� Finaliza a pagina quando atingir a quantidade maxima de itens � 
		//�����������������������������������������������������������������		
		If nLinCount == nMaxLinha
			oPrinter:Line(550,nMargDir, 550, nMaxCol-nMargEsq,, "-2")
			oPrinter:EndPage()
		Else
			nLiItm += li
		EndIf
			
		(cAliasOS)->(dbSkip())
		Loop
	EndDo
	//������������������������������������������������������������������������Ŀ
	//� Finaliza a pagina se a quantidade de itens for diferente da quantidade � 
	//� maxima, para evitar que a pagina seja finalizada mais de uma vez.      �
	//��������������������������������������������������������������������������
	If nLinCount <> nMaxLinha
		oPrinter:Line(550,nMargDir, 550, nMaxCol-nMargEsq,, "-2")
		oPrinter:EndPage()
	EndIf
EndDo

oPrinter:Print()

(cAliasOS)->(dbCloseArea())
RestArea(aArea)

Return

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    | CabPagina  � Autor � Robson Sales          � Data �14/11/13  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o cabecalho do relatorio                             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � ACDR100                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function CabPagina(oPrinter)

Private nCol1Dir	:= 720-nMargDir   
Private nCol2Dir	:= 760-nMargDir

oPrinter:Line(li+5, nMargDir, li+5, nMaxCol-nMargEsq,, "-8")

oPrinter:SayAlign(li+10,nMargDir,"SIGA/ACDR100/v11",oFontA7,200,200,,0)//"SIGA/ACDR100/v11"
oPrinter:SayAlign(li+20,nMargDir,"Hora: "+Time(),oFontA7,200,200,,0)//"Hora: "
oPrinter:SayAlign(li+30,nMargDir,"Empresa: "+FWFilialName(,,2) ,oFontA7,300,200,,0)//"Empresa: "

oPrinter:SayAlign(li+20,340,"Impress�o das Ordens de Separa��o",oFontA12,nMaxCol-nMargEsq,200,2,0)//"Impress�o das Ordens de Separa��o"

oPrinter:SayAlign(li+10,nCol1Dir,"Folha   : ",oFontA7,200,200,,0)//"Folha   : "
oPrinter:SayAlign(li+20,nCol1Dir,"Dt. Ref.: ",oFontA7,200,200,,0)//"Dt. Ref.: "
oPrinter:SayAlign(li+30,nCol1Dir,"Emiss�o : ",oFontA7,200,200,,0)//"Emiss�o : "

oPrinter:SayAlign(li+10,nCol2Dir,AllTrim(STR(nPag)),oFontA7,200,200,,0)
oPrinter:SayAlign(li+20,nCol2Dir,DTOC(ddatabase),oFontA7,200,200,,0)
oPrinter:SayAlign(li+30,nCol2Dir,DTOC(ddatabase),oFontA7,200,200,,0)

oPrinter:Line(li+40,nMargDir, li+40, nMaxCol-nMargEsq,, "-8")

Return

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    | CabItem    � Autor � Robson Sales          � Data �18/11/13  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime o cabecalho do relatorio                             ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � ACDR100                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function CabItem(oPrinter,cOrigem)

Local cOrdSep		:= AllTrim((cAliasOS)->CB7_ORDSEP)
Local cPedVen		:= AllTrim((cAliasOS)->CB7_PEDIDO)
Local cClient		:= AllTrim((cAliasOS)->CB7_CLIENT)+"-"+AllTrim((cAliasOS)->CB7_LOJA)
Local cNFiscal	:= AllTrim((cAliasOS)->CB7_NOTA)+"-"+AllTrim((cAliasOS)->&(SerieNfId('CB7',3,'CB7_SERIE')))
Local cOP			:= AllTrim((cAliasOS)->CB7_OP)
Local cStatus		:= RetStatus((cAliasOS)->CB7_STATUS)

oPrinter:SayAlign(li+60,nMargDir,"Ordem de Separa��o:",oFontC8,200,200,,0)//"Ordem de Separa��o:"
oPrinter:SayAlign(li+60,nMargDir+105,cOrdSep,oFontC8,200,200,,0)

If Alltrim(cOrigem) == "1" // Pedido venda
	oPrinter:SayAlign(li+60,nMargDir+160,"Pedido de Venda:",oFontC8,200,200,,0)//"Pedido de Venda:"
	If Empty(cPedVen) .And. (cAliasOS)->CB7_STATUS <> "9"
		oPrinter:SayAlign(li+60,nMargDir+245,"Aglutinado",oFontC8,200,200,,0)//"Aglutinado"
		oPrinter:SayAlign(li+72,nMargDir,"PV's Aglutinados:",oFontC8,200,200,,0)//"PV's Aglutinados:"
		oPrinter:SayAlign(li+72,nMargDir+105,A100AglPd(cOrdSep),oFontC8,550,200,,0)		
	Else
		oPrinter:SayAlign(li+60,nMargDir+245,cPedVen,oFontC8,200,200,,0)
	EndIf
	oPrinter:SayAlign(li+60,nMargDir+310,"Cliente:",oFontC8,200,200,,0)//"Cliente:"
	oPrinter:SayAlign(li+60,nMargDir+355,cClient,oFontC8,200,200,,0)
ElseIf Alltrim(cOrigem) == "2" // Nota Fiscal
	oPrinter:SayAlign(li+60,nMargDir+160,"Nota Fiscal:",oFontC8,200,200,,0)//"Nota Fiscal:"
	oPrinter:SayAlign(li+60,nMargDir+230,cNFiscal,oFontC8,200,200,,0)
	oPrinter:SayAlign(li+60,nMargDir+310,"Cliente:",oFontC8,200,200,,0)//"Cliente:"
	oPrinter:SayAlign(li+60,nMargDir+355,cClient,oFontC8,200,200,,0)
ElseIf Alltrim(cOrigem) == "3" // Ordem de Producao
	oPrinter:SayAlign(li+60,nMargDir+160,"Ordem de Produ��o:",oFontC8,200,200,,0)//"Ordem de Produ��o:"
	oPrinter:SayAlign(li+60,nMargDir+255,cOP,oFontC8,200,200,,0)
EndIf

oPrinter:SayAlign(li+60,nMargDir+430,"Status:",oFontC8,200,200,,0)//"Status:"
oPrinter:SayAlign(li+60,nMargDir+470,cStatus,oFontC8,200,200,,0)
oPrinter:Line(li+90,nMargDir, li+90, nMaxCol-nMargEsq,, "-2")

If MV_PAR06 == 1
	oPrinter:FWMSBAR("CODE128",5/*nRow*/,60/*nCol*/,AllTrim(cOrdSep),oPrinter,,,, 0.049,1.0,,,,.F.,,,)
EndIf

Return

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    | RetStatus  � Autor � Robson Sales          � Data �18/11/13  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o Status da Ordem de Separacao                       ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � ACDR100                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function RetStatus(cStatus)

Local cDescri	:= ""

If Empty(cStatus) .or. cStatus == "0"
	cDescri:= "Nao iniciado"
ElseIf cStatus == "1"
	cDescri:= "Em separacao"
ElseIf cStatus == "2"
	cDescri:= "Separacao finalizada"
ElseIf cStatus == "3"
	cDescri:= "Em processo de embalagem"
ElseIf cStatus == "4"
	cDescri:= "Embalagem Finalizada"
ElseIf cStatus == "5"
	cDescri:= "Nota gerada"
ElseIf cStatus == "6"
	cDescri:= "Nota impressa"
ElseIf cStatus == "7"
	cDescri:= "Volume impresso"
ElseIf cStatus == "8"
	cDescri:= "Em processo de embarque"
ElseIf cStatus == "9"
	cDescri:= "Finalizado"
EndIf

Return(cDescri)

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    | A100AglPd  � Autor � Materiais             � Data � 08/07/14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna String com os Pedidos de Venda aglutinados na OS     ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � ACDR100                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function A100AglPd(cOrdSep)

Local cAliasPV	:= GetNextAlias()
Local cQuery		:= ""
Local cPedidos	:= ""
Local aArea		:= GetArea()

cQuery := "SELECT C9_PEDIDO FROM "+RetSqlName("SC9")+" WHERE C9_ORDSEP = '"+cOrdSep+"' AND "
cQuery += "C9_FILIAL = '"+xFilial("SC9")+"' AND D_E_L_E_T_ = '' ORDER BY C9_PEDIDO"

cQuery := ChangeQuery(cQuery)                  
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPV,.T.,.T.)

While !(cAliasPV)->(EOF())
	cPedidos += (cAliasPV)->C9_PEDIDO+"/"
	(cAliasPV)->(dbSkip())
EndDo

(cAliasPV)->(dbCloseArea())
RestArea(aArea)

If Len(cPedidos) > 119
	cPedidos := SubStr(cPedidos,1,119)+"..."
EndIf

Return cPedidos
