//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

#DEFINE CGETFILE_TYPE GETF_LOCALHARD
#DEFINE  CS ";"
//COR
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)

User Function DIPR106()
Local lEnd        := .F.
	Processa({ |lEnd| DIPR106(),OemToAnsi('Gerando o relatório.')}, OemToAnsi('Aguarde...'))
Return

Static Function DIPR106()
Local aDados		:= {}
Local aParc			:= {}
Local cPathInServer := "\system\pdf\"
Local cFilePDF		:= ""
Local lQuebra		:= .F.
Local x				:= 0
Local cQuery		:= ""
Local cAlias 		:= GetNextAlias()
Local nValPed		:= 0
Local nDias			:= 0
Local nMesIni		:= 0
Local nMesAtu		:= 0
Local nTotdia		:= 0
Local nTotMes		:= 0
Local nTotGer		:= 0
Local nTotMesST		:= 0
Local nTotDiaST		:= 0
Local nTotGerST		:= 0
Local cCodForn		:= SuperGetMV("MV_XCOFORN",.F.,"")
Local nST1P			:= 0
//Linhas e colunas
Private nLinAtu   := 000
Private nTamLin   := 010
Private nLinFin   := 820
Private nColIni   := 005
Private nColFin   := 840
Private nColMeio  := (nColFin-nColIni)/2

//Colunas
Private COL_EMIS	:= 010
Private COL_PREV	:= 070
Private COL_FORN	:= 170
Private COL_PED  	:= 450
Private COL_COND 	:= 530
Private COL_VENC 	:= 610
Private COL_VAL  	:= 690
Private COL_ST	 	:= 770

Private xnPag		:= 0		

Private _cArqPDF	:= ""
Private oBrush1     :=  TBrush():New( ,CLR_BLACK)
Private oBrush2     :=  TBrush():New( ,CLR_HGRAY)
Private	oBrush3		:= 	TBrush():New( ,CLR_LIGHTGRAY)
Private	oPen		:= 	TPen():New(0,5,CLR_BLACK)
/*
As fontes disponíveis para utilização com a classe TFont na FwMsPrinter() são:
Courier New
Arial
Arial Black
Times New Roman
Andale Mono
*/
/* Fontes Arial */
Private oFont12     := TFont():New( 'Arial', , -12, .F.)
Private oFont12N    := TFont():New( 'Arial', , -12, .T.)
Private oFont14     := TFont():New( 'Arial', , -14, .F.)
Private oFont14N    := TFont():New( 'Arial', , -14, .T.)
Private oFont16     := TFont():New( 'Arial', , -16, .F.)
Private oFont16N    := TFont():New( 'Arial', , -16, .T.)
Private oFont18     := TFont():New( 'Arial', , -18, .F.)
Private oFont18N    := TFont():New( 'Arial', , -18, .T.)
Private oFont20     := TFont():New( 'Arial', , -20, .F.)
Private oFont20N    := TFont():New( 'Arial', , -20, .T.)
/* Fontes Courier New */
Private oFont12c     := TFont():New( 'Courier New', , -12, .F.)
Private oFont12cN    := TFont():New( 'Courier New', , -12, .T.)
Private oFont14c     := TFont():New( 'Courier New', , -14, .F.)
Private oFont14cN    := TFont():New( 'Courier New', , -14, .T.)
Private oFont16c     := TFont():New( 'Courier New', , -16, .F.)
Private oFont16cN    := TFont():New( 'Courier New', , -16, .T.)
Private oFont18c     := TFont():New( 'Courier New', , -18, .F.)
Private oFont18cN    := TFont():New( 'Courier New', , -18, .T.)
Private oFont20c     := TFont():New( 'Courier New', , -20, .F.)
Private oFont20cN    := TFont():New( 'Courier New', , -20, .T.)
Private oFont22c     := TFont():New( 'Courier New', , -22, .F.)
Private oFont22cN    := TFont():New( 'Courier New', , -22, .T.)

//Private cPerg       := "DIPR103  "
Private cPerg       := "FIN140"
Private _cDirTemp   := GetTempPath()//"c:\temp\"
Private cUsuario	:= UsrFullName(RetCodUsr())

Private dPerIni
Private dPerFim
cPerg := padr(cPerg, len(SX1->X1_GRUPO))
If !Pergunte(cPerg,.T.)
	Return()
EndIf 
nDias 	 := MV_PAR01
dPerIni	 := "20100101" // busca desde do inicio pedidos em aberto
dPerFim  := DTos(ddataBase+nDias)

_cArqPDF    := "DIPR106-"+SUBSTR(TIME(),1,2)+"-"+SUBSTR(TIME(),4,2)+"-"+SUBSTR(TIME(),7,2)
lAdjustToLegacy := .F.
lDisableSetup  	:= .T.
/*
AADD(aDevice,"DISCO") // 1
AADD(aDevice,"SPOOL") // 2
AADD(aDevice,"EMAIL") // 3
AADD(aDevice,"EXCEL") // 4
AADD(aDevice,"HTML" ) // 5
AADD(aDevice,"PDF"  ) // 6
*/
//Cria o objeto FWMSPrinter
oPrint := FWMSPrinter():New(_cArqPDF,IMP_PDF,lAdjustToLegacy,cPathInServer,lDisableSetup,,,,.t.,,.F.,.F.)
oPrint:cPathPDF := "\system\pdf\"
//oPrint:Setup()
oPrint:SetResolution(72)
//oPrint:SetPaperSize(DMPAPER_A4)
oPrint:SetMargin(0, 0, 0, 0)
oPrint:SetLandscape()
cFileLogo	:= FisxLogo("1")
oPrint:SetViewPDF(.F.) //desativa o preview automatico para gerar no server primeiro

xCabec()
/*
If Mv_Par08 == 1
	If FErase(cPerg+".csv") == -1
		cCSV	:= AllTrim(cPerg)+StrTran(Time(),":","")+".csv"
	Else
		cCSV	:= cPerg+".csv"
	EndIF
	
	nHandle := FCreate(cCSV, FC_NORMAL )
	
	If nHandle == -1
		MsgStop('Erro de abertura : FERROR '+str(ferror(),4))
	Else
		FSeek(nHandle, 0, FS_END) // Posiciona no fim do arquivo
		FWrite(nHandle, "" ) // Insere texto no arquivo
	Endif
    cLinha := CRLF + ;
    			Titulo + CS + "(" + FunName() + ")" + CRLF +;
    			"Hora...:"+cValToChar(Time())+CS+"Emp.:"+cEmpAnt+"/"+cFilAnt+CRLF
	If Mv_Par07 == 1
		cLinha += "PEDIDO;FORNECEDOR;;CODIGO DO PRODUTO;DESCRICAO DO PRODUTO;PREV.DE ENTREGA;QTDE;VALOR;VALOR DA PARCELA;COND.PGTO"
	Else
		cLinha += "PEDIDO;FORNECEDOR;;PREV.DE ENTREGA;VALOR DA PARCELA;COND.PGTO"
	EndIf
	FWrite(nHandle, cLinha+CRLF)
	cLinha := ""
EndIf
*/
If cEmpAnt =="01"
	cFilIni	:= "01"
	cFilFin	:= "04"
EndIf
If Select(cAlias)
	cAlias->(dbCloseArea())
ENDIF
cQuery 	:= " SELECT SUM(C7_TOTAL+C7_VALIPI)AS TOTAL, "
//cQuery 	+= " SUM(C7_ICMSRET)AS ST,"
cQuery  += " SUM(C7_ICMSRET/C7_QUANT*(C7_QUANT - C7_QUJE))AS ST, "
cQuery 	+= " SUM(C7_QUJE * C7_PRECO) AS TOTENTR,"
cQuery 	+= " C7_FILIAL, C7_NUM, C7_DENTREG,C7_EMISSAO, C7_COND, C7_FORNECE, C7_LOJA, A2_NOME, C7_DATPRF, C7_TES"
cQuery 	+= " FROM " + RetSqlName("SC7")+" SC7 "
cQuery 	+= " INNER JOIN " + RetSqlName("SA2")+" SA2 ON "
cQuery 	+= " C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA "
cQuery 	+= " AND SA2.D_E_L_E_T_ = ' ' "
cQuery 	+= " WHERE C7_FILIAL between '"+cFilIni+"' and '"+cFilFin+"' "
cQuery 	+= " AND SC7.D_E_L_E_T_ = ' ' "
cQuery 	+= " AND C7_QUJE < C7_QUANT "
cQuery 	+= " AND C7_RESIDUO <> 'S' "
//cQuery 	+= " AND C7_EMISSAO BETWEEN'"+DTOS(Mv_Par01) +"' AND '"+Dtos(Mv_Par02)+"' "
cQuery 	+= " AND C7_DATPRF BETWEEN'"+dPerIni+"' AND '"+dPerFim+"' "
cQuery 	+= " GROUP by C7_FILIAL,C7_NUM,C7_DENTREG,C7_EMISSAO,C7_COND,C7_FORNECE, C7_LOJA, A2_NOME,C7_DATPRF,C7_TES"
cQuery	:= ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias , .F., .T.)
memowrite('\query\DIPR106-cQuery.SQL',cQuery)
(cAlias)->(dbGoTop())
While (cAlias)->(!Eof())
	nValPed 	:= (cAlias)->TOTAL - (cAlias)->TOTENTR
	DbSelectArea("SE4")
	DbSetOrder(1)
	DbSeek(xFilial("SE4")+(cAlias)->C7_COND)
	IF AllTrim(SE4->E4_COND)=="0" .or. AllTrim(SE4->E4_COND)=="1"
		dDataParc	:= Stod((cAlias)->C7_DENTREG) //Conforme alinhado com a Juraci considerar Data do Dia
	else
		dDataParc	:= Stod((cAlias)->C7_DENTREG)-5 //Conforme alinhado com a Juraci descontar 5 dias da entrega como previsao da emissao da nota
	ENDIF
	aParc :=  Condicao(nValPed,(cAlias)->C7_COND,0,dDataParc)
	For x:=1 to Len(aParc)
			If aParc[x,1] <= sTod(dPerFim)
				/*
				AADD(aDados, { aParc[x,1]		, ;
							(cAlias)->C7_DENTREG, ;
							(cAlias)->C7_NUM	, ;
							aParc[x,2]			, ;
							(cAlias)->C7_COND	, ;
							(cAlias)->C7_FORNECE, ; 
							(cAlias)->C7_LOJA   , ;
							(cAlias)->A2_NOME   , ;
							(cAlias)->C7_EMISSAO, ;
							(cAlias)->ST		, ;
							(cAlias)->C7_TES	})
							*/
				nST1P := 0
				/*
				cTexto := ""
				cTexto := '['+Posicione("SA2", 1, xFilial("SA2")+(cAlias)->C7_FORNECE+(cAlias)->C7_LOJA,"A2_EST")+']'
				cTexto += if((cAlias)->ST>0, '[ST]','')
				cTexto += '['+SE4->E4_SOLID+']'
				*/
				if  Posicione("SA2", 1, xFilial("SA2")+(cAlias)->C7_FORNECE+(cAlias)->C7_LOJA,"A2_EST") == "SP" .OR.;
					((cAlias)->C7_FORNECE+(cAlias)->C7_LOJA $ cCodForn .and. SE4->E4_SOLID =="J") 

					If x == 1
						nST1P := (cAlias)->ST

					Endif


				Endif

				AADD(aDados, { aParc[x,1]		, ;
							(cAlias)->C7_DENTREG, ;
							(cAlias)->C7_NUM	, ;
							aParc[x,2]	+nST1P	, ;
							(cAlias)->C7_COND	, ;
							(cAlias)->C7_FORNECE, ; 
							(cAlias)->C7_LOJA   , ;
							(cAlias)->A2_NOME   , ;
							(cAlias)->C7_EMISSAO, ;
							0		, ; //zerei o ICMS-ST
							(cAlias)->C7_TES	})
			EndIf
	Next x              
	(cAlias)->(dbSkip())
EndDo


// Acrescentando os lançamentos de ST

(cAlias)->(dbGoTop())
While (cAlias)->(!Eof())

	If (cAlias)->ST >0 .and. Posicione("SA2", 1, xFilial("SA2")+(cAlias)->C7_FORNECE+(cAlias)->C7_LOJA,"A2_EST") <> "SP" .and.;
		!((cAlias)->C7_FORNECE+(cAlias)->C7_LOJA $ cCodForn)
				/*
				cTexto := ""
				cTexto := '['+Posicione("SA2", 1, xFilial("SA2")+(cAlias)->C7_FORNECE+(cAlias)->C7_LOJA,"A2_EST")+']'
				cTexto += if((cAlias)->ST>0, '[ST]','')
				cTexto += '['+SE4->E4_SOLID+']'
				*/
			AADD(aDados, { Stod((cAlias)->C7_DENTREG)		, ;
								(cAlias)->C7_DENTREG, ;
								(cAlias)->C7_NUM	, ;
								0			, ;
								(cAlias)->C7_COND	, ;
								(cAlias)->C7_FORNECE, ; 
								(cAlias)->C7_LOJA   , ;
								'[ST]-'+(cAlias)->A2_NOME   , ;
								(cAlias)->C7_EMISSAO, ;
								(cAlias)->ST		, ;
								(cAlias)->C7_TES	})

	Endif
          
	(cAlias)->(dbSkip())
EndDo


(cAlias)->(dbCloseArea())
aSort(aDados,,,{|x,y| x[1] < y[1]})
nReg := Len(aDados)
ProcRegua(nReg,"Aguarde a Impressao....")
nMesIni := MONTH(aDados[1,1])
For x:=1 to Len(aDados)
	IncProc()
	
	nMesAtu := MONTH(aDados[x,1])	
	If nMesAtu <> nMesIni
		//oPrint:Line(nLinAtu,nColIni,nLinAtu,nColFin,COR_PRETO)
		nLinAtu += nTamLin
		xVerPag()
		oPrint:Say(nLinAtu,COL_EMIS+3, "TOTAL MES:"+Alltrim(Str(nMesIni))+Replicate("-",180),oFont12)
		oPrint:Say(nLinAtu,COL_VAL-10,Transform(nTotMes,"@E 999,999,999.99"),oFont12)
		oPrint:Say(nLinAtu,COL_ST-15,Transform(nTotMesST,"@E 999,999,999.99"),oFont12)
		nLinAtu += nTamLin
		oPrint:Say(nLinAtu,nColIni,Replicate("-",nColFin),oFont12)

		nMesIni 	:= nMesAtu
		nTotMes		:= 0
		nTotMesST 	:= 0
		nLinAtu += nTamLin+5
	EndIf

	xVerPag()
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4")+aDados[x,11])
	If SF4->F4_DUPLIC <> "N"
		oPrint:Say(nLinAtu,COL_EMIS+3, dTOC(sTOD(aDados[x,9])),oFont12)
		oPrint:Say(nLinAtu,COL_PREV+10, dTOC(sTOD(aDados[x,2])),oFont12)
		oPrint:Say(nLinAtu,COL_FORN,Alltrim(aDados[x,6])+"-"+Alltrim(aDados[x,8]),oFont12)
		oPrint:Say(nLinAtu,COL_PED, aDados[x,3],oFont12)
		//oPrint:Say(nLinAtu,COL_COND,aDados[x,5],oFont12)
		oPrint:Say(nLinAtu,COL_COND,StrTran(POSICIONE("SE4",1,xFilial("SE4")+aDados[x,5],"E4_DESCRI"),",","/"),oFont12)
		oPrint:Say(nLinAtu,COL_VENC+10,dTOC(aDados[x,1]),oFont12)
		oPrint:Say(nLinAtu,COL_VAL-10,Transform(aDados[x,4],"@E 999,999,999.99"),oFont12)
		oPrint:Say(nLinAtu,COL_ST-15,Transform(aDados[x,10],"@E 999,999,999.99"),oFont12)
		nTotdia	+= aDados[x,4]
		nTotGer	+= aDados[x,4]
		nTotMes += aDados[x,4]

		nTotdiaST	+= aDados[x,10]
		nTotGerST	+= aDados[x,10]
		nTotMesST	+= aDados[x,10]
		
	EndIf
	nLinAtu += nTamLin+5
	
	xVerPag()

	If (x+1) > Len(aDados)
		lQuebra := .T.
	Else
		lQuebra  := aDados[x,1] # aDados[x+1,1]
	EndIf 
	
	If lQuebra
		//oPrint:Line(nLinCab,nColIni,nLinCab,nColFin,COR_PRETO)
		oPrint:Say(nLinAtu,COL_EMIS,"SUB-TOTAL - "+ dTOC(aDados[x,1])+" "+Replicate("-",160),oFont12)
		oPrint:Say(nLinAtu,COL_VAL-10,Transform(nTotdia,"@E 999,999,999.99"),oFont12)

		oPrint:Say(nLinAtu,COL_ST-15,Transform(nTotDiaST,"@E 999,999,999.99"),oFont12) //andre

		nTotdia := 0
		nLinAtu += nTamLin+7

		nTotDiaST := 0 //andre

		If Select("TMPST")
			TMPST->(dbCloseArea())
		ENDIF
		cQueryST := " SELECT SUM(C7_ICMSRET/C7_QUANT*(C7_QUANT - C7_QUJE))AS VALST, "
		cQueryST += " C7_FILIAL, C7_NUM, C7_DENTREG "
		cQueryST += " FROM " + RetSqlName("SC7")+" SC7 "
		cQueryST += " INNER JOIN " + RetSqlName("SA2")+" SA2 ON "
		cQueryST += " C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA "
		cQueryST += " AND A2_EST <> 'SP' "
		cQueryST += " AND SA2.D_E_L_E_T_ = ' ' "
		cQueryST += " WHERE C7_FILIAL between '"+cFilIni+"' and '"+cFilFin+"' "
		cQueryST += " AND SC7.D_E_L_E_T_ = ' ' "
		cQueryST += " AND C7_QUJE < C7_QUANT"
		cQueryST += " AND C7_RESIDUO <> 'S'"
		cQueryST += " AND C7_ICMSRET > 0 "
		cQueryST += " AND 1=0 " // removendo essas quebras.
		cQueryST += " AND C7_DENTREG ='"+DTOS(aDados[x,1]) +"' "
		cQueryST += " GROUP by C7_FILIAL,C7_NUM,C7_DENTREG "
		cQueryST := ChangeQuery(cQueryST)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryST), 'TMPST', .F., .T.)
		memowrite('\query\DIPR106-cQueryST.SQL',cQueryST)
		TMPST->(dbGoTop())
		IF TMPST->(!Eof())
			oPrint:Say(nLinAtu,COL_EMIS,"ICMS ST PREVISTO  "+ dTOC(aDados[x,1]),oFont12)
			While TMPST->(!Eof())
					nLinAtu += nTamLin+2
					dbSelectArea("SC7")
					SC7->(dbSetOrder(1))
					dbSeek(TMPST->C7_FILIAL+TMPST->C7_NUM)
					oPrint:Say(nLinAtu,COL_EMIS+3, dTOC(SC7->C7_EMISSAO),oFont12)
					oPrint:Say(nLinAtu,COL_PREV+10, dTOC(sTOD(TMPST->C7_DENTREG)),oFont12)
					oPrint:Say(nLinAtu,COL_FORN,Alltrim(SC7->C7_FORNECE)+"-"+POSICIONE("SA2",1,xFilial("SA2")+SC7->(C7_FORNECE+C7_LOJA),"A2_NREDUZ"),oFont12)
					oPrint:Say(nLinAtu,COL_PED, TMPST->C7_NUM ,oFont12)
					oPrint:Say(nLinAtu,COL_COND,StrTran(POSICIONE("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI"),",","/"),oFont12)
					//oPrint:Say(nLinAtu,COL_VENC+10,dTOC(aDados[x,1]),oFont12)
					oPrint:Say(nLinAtu,COL_ST-10,Transform(TMPST->VALST, "@E 999,999,999.99"),oFont12)					
					nTotDiaST += TMPST->VALST
					xVerPag()
					TMPST->(dbSkip())
			EndDo
			TMPST->(dbCloseArea())
			nLinAtu += nTamLin+5
			oPrint:Say(nLinAtu,COL_EMIS,"Total ST "+ dTOC(aDados[x,1])+" "+Replicate("-",160),oFont12)
			oPrint:Say(nLinAtu,COL_ST-10,Transform(nTotDiaST,"@E 999,999,999.99"),oFont12)
			nTotGerST	+= nTotDiaST
			nTotMesST	+= nTotDiaST
			nTotDiaST 	:= 0
			nLinAtu += nTamLin+7
		EndIf
	EndIf

	
Next x

oPrint:Line(nLinAtu,nColIni,nLinAtu,nColFin,COR_PRETO)
nLinAtu += nTamLin+5
xVerPag()
oPrint:Say(nLinAtu,COL_EMIS+3, "TOTAL GERAL",oFont12)
oPrint:Say(nLinAtu,COL_VAL-10,Transform(nTotGer,"@E 999,999,999.99"),oFont12)
oPrint:Say(nLinAtu,COL_ST-15,Transform(nTotGerST,"@E 999,999,999.99"),oFont12)
xRodape()
/*
nLin++
@nLin,000 PSAY "Total Geral:"
If Mv_Par07 == 1
	@nLin,130 PSAY Transform(nTotG1,"@E 999,999,999.99") //VALOR DA PARCELA
EndIf
@nLin,150 PSAY Transform(nTotG2,"@E 999,999,999.99") //VALOR DA PARCELA

If Mv_Par08 == 1
	cLinha := "Total Geral:"+Iif(Mv_Par07 == 1, CS+CS+CS+CS+CS+CS+CS, CS+CS+CS)+;
		IIf( Mv_Par07 == 1, Transform(nTotG1,"@E 999,999,999.99")+CS , CS)+ ;
		Transform(nTotG2,"@E 999,999,999.99")+CS
	FWrite(nHandle, cLinha+CRLF)
	cLinha := ""
	
	FClose(nHandle)
	//U_fOpenXLS(cCSV)
EndIf	
*/

oPrint:EndPage()
oPrint:Preview()
cFilePDF := _cArqPDF+'.pdf'
If File(cPathInServer+cFilePDF)
	CpyS2T(cPathInServer+cFilePDF,_cDirTemp,.T.)
	//Executa para abrir o PDF local na máquina
	ShellExecute("open",cFilePDF, "",_cDirTemp, 1)
EndIf
FreeObj(oPrint)
Return

/*
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Cabecalho do relatorio...                        º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function xCabec()
Local cProt 		:= "Pedidos de COMPRA / Livro Caixa entre: " + dToc(ddataBase) + " e "  + Dtoc(sTod(dPerFim))
Local nLinCab 		:= 030
xnPag++
//Linha Separatória
oPrint:StartPage()
//oPrint:SayBitmap(20,05,cFileLogo,070,010)
oPrint:SayBitmap(10,05,"Dipromedcon.BMP",070,030)
oPrint:Say(nLinCab,220,cProt,oFont20N, 1400, COR_CINZA)
oPrint:Say(nLinCab,750,'Folha: '+Transform(xnPag,"@E 999"),oFont12)
nLinCab += nTamLin
oPrint:Line(nLinCab,nColIni,nLinCab,nColFin,COR_CINZA)
nLinCab += (nTamLin * 2)
/*
oPrint:FillRect({nLinCab-10,COL_EMIS,nLinCab,COL_EMIS+50},oBrush2)
oPrint:FillRect({nLinCab-10,COL_PREV,nLinCab,COL_PREV+70},oBrush2)
oPrint:FillRect({nLinCab-10,COL_FORN,nLinCab,COL_FORN+90},oBrush2)
oPrint:FillRect({nLinCab-10,COL_PED,nLinCab,COL_PED+80},oBrush2)
*/
oPrint:Say(nLinCab,COL_EMIS,"Emissão" 		,oFont16N)
oPrint:Say(nLinCab,COL_PREV,"Prev.Entrega" 	,oFont16N)
oPrint:Say(nLinCab,COL_FORN,"Fornecedor" 	,oFont16N)
oPrint:Say(nLinCab,COL_PED,"Pedido" 		,oFont16N)
oPrint:Say(nLinCab,COL_COND,"Condição"		,oFont16N)
oPrint:Say(nLinCab,COL_VENC,"Vencimento" 	,oFont16N)
oPrint:Say(nLinCab,COL_VAL,"Valor(R$)" 		,oFont16N)
oPrint:Say(nLinCab,COL_ST,"Icms-ST" 		,oFont16N)
nLinAtu := nLinCab + (nTamLin * 2)
//oPrint:Say(xnLin,2200,"Valor Nota" ,oFont10)
//oPrint:Say(xnLin,2370,"Tipo Frete" ,oFont10)
//oPrint:Say(xnLin,2630,"Observações" ,oFont10)
Return

/*
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica Pagina...                        º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function xVerPag()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia a montagem da impressao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	(nLinAtu >= 565)
	oPrint:Line(nLinAtu,5,nLinAtu,840)
	nLinAtu += 10
	oPrint:Say(nLinAtu,20,"CONTINUA...",oFont12N)
	//xRodape()
	oPrint:EndPage()
	//oPrint:StartPage()
	xCabec()
EndIf
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºDesc.     ³ Imprime o Rodape do Relatorio....                          º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function xRodape()
Local nLinRod	:= 570
oPrint:Line(nLinRod,nColIni,nLinRod,nColFin,COR_CINZA)
nLinRod += nTamLin
oPrint:Say(nLinRod,020,"Documento emitido em "+Dtoc(dDataBase)+", às "+Time() ,oFont12)
oPrint:Say(nLinRod,240,"Emitido por:  "+Alltrim(cUsuario),oFont12)
oPrint:Say(nLinRod,450,"DIPROMED",oFont12)
oPrint:EndPage()
Return
