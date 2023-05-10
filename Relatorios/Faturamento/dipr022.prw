/*==========================================================================\
|Programa  | DIPR022 | Autor | Rafael de Campos Falco  | Data | 22/03/2003  |
|===========================================================================|
|Desc.     | Relacao com os SALDOS em Poder de terceiros                    |
|===========================================================================|
|Sintaxe   | DIPR022                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da modificação                            |
|Rafael    | 17/09/04 - Execução de macro para envio de planilha            |
|Rafael    | 15/12/04 - Execução de macro para criar planilha de COTAÇÃO    |
\==========================================================================*/

#Include "RwMake.ch"
#Include "Ap5Mail.ch"

User Function DIPR022()

Local _xArea   := GetArea()
Local _areaSB1 := SB1->(getarea())
Local _areaSB6 := SB6->(getarea())

Local titulo     := OemTOAnsi("Relacao de Produtos em Poder de Terceiros",72)
Local cDesc1     := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2     := (OemToAnsi("com os saldos dos produtos em poder de terceiros.",72))
Local cDesc3     := (OemToAnsi("Conforme parametros definidos pelo o usuario.",72))

Private aReturn    := {"Bco A4", 1,"Estoques", 1, 2, 1,"",1}
Private li         := 67
Private tamanho    := "G"
Private limite     := 220
Private nomeprog   := "DIPR022"
Private nLastKey   := 0
Private lContinua  := .T.
Private lEnd       := .F.
Private wnrel      := "DIPR022"
Private M_PAG      := 1
Private cString    := "SB6"
Private _cArqTrb
Private cOld_Arq := ""
Private cNew_Arq := ""
Private aReg_Arq := {}
Private aReg_Lst := {}

//Private cPerg      := "DIPR22"
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1
PRIVATE cPerg  	:= U_FPADR( "DIPR022","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.


U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

If !Pergunte(cPerg,.T.)    // Solicita parametros
	Return
EndIf

wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

Processa({|lEnd| PegaDados()},"Totalizando Saldos...")

RptStatus({|lEnd| RodaRel()},"Imprimindo Saldos...")

Set device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta arquivos temporarios e Retorna Indices padräes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DbSelectArea("TRB")
TRB->(DbCloseArea())
Ferase(_cArqTrb+".DBF")
Ferase(_cArqTrb+OrdBagExt())

RestArea(_areaSB1)
RestArea(_areaSB6)
RestArea(_xArea)

Return
*---------------------------------*
Static Function PegaDados()
*---------------------------------*
Local nTot_Pro := 0
Local cCod_Cli	:= ""
Local cCod_Pro	:= ""
Local cDes_Pro	:= ""
Local cUni_Med	:= ""
//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\Saldo" // JBS 12/12/2005

// Alteração efetuada para gravar no \protheus-data\ por Sandro em  19/11/09 
Local cArqExcell:= "\Excell-DBF\Saldo" 
Private cDestino := "C:\EXCELL-DBF"

_aCampos := {}                  
AAdd(_aCampos ,{"CLIENTE"  ,"C",AvSx3('B6_CLIFOR',3) ,AvSx3('B6_CLIFOR',4)})  // JBS 04/01/2006
AAdd(_aCampos ,{"CODIGO"   ,"C",AvSx3('B6_PRODUTO',3),AvSx3('B6_PRODUTO',4)}) // JBS 04/01/2006
AAdd(_aCampos ,{"DESCRICAO","C",AvSx3('B1_DESC',3)   ,AvSx3('B1_DESC',4)})    // JBS 04/01/2006
AAdd(_aCampos ,{"UM"       ,"C",AvSx3('B1_UM',3)     ,AvSx3('B1_UM',4)})      // JBS 04/01/2006
AAdd(_aCampos ,{"NOTA"     ,"C",AvSx3('B6_DOC',3)    ,AvSx3('B6_DOC',4)})     // JBS 04/01/2006
AAdd(_aCampos ,{"EMISSAO"  ,"D",AvSx3('B6_EMISSAO',3),AvSx3('B6_EMISSAO',4)}) // JBS 04/01/2006
AAdd(_aCampos ,{"ULT_COMP" ,"D",AvSx3('B6_UENT',3)   ,AvSx3('B6_UENT',4)})    // JBS 04/01/2006
AAdd(_aCampos ,{"SALDO"    ,"N",AvSx3('B6_SALDO',3)  ,AvSx3('B6_SALDO',4)})   // JBS 04/01/2006
AAdd(_aCampos ,{"CONTAGEM" ,"N",AvSx3('B6_SALDO',3)  ,AvSx3('B6_SALDO',4)})   // JBS 04/01/2006
AAdd(_aCampos ,{"QTDE_VEN" ,"N",AvSx3('B6_SALDO',3)  ,AvSx3('B6_SALDO',4)})   // JBS 04/01/2006
AAdd(_aCampos ,{"PRC_VEN"  ,"N",AvSx3('B6_PRUNIT',3) ,AvSx3('B6_PRUNIT',4)})  // JBS 04/01/2006
AAdd(_aCampos ,{"QTDE_REM" ,"N",AvSx3('B6_SALDO',3)  ,AvSx3('B6_SALDO',4)})   // JBS 04/01/2006
AAdd(_aCampos ,{"PRC_REM"  ,"N",AvSx3('B6_SALDO',3)  ,AvSx3('B6_SALDO',4)})   // JBS 04/01/2006
AAdd(_aCampos ,{"TES"      ,"C",AvSx3('B6_TES',3)    ,AvSx3('B6_TES',4)})     // JBS 04/01/2006

_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)

dbSelectArea("SB6")
dbSetOrder(6)
If Empty(MV_PAR01) 
	SB6->( DbGoTop() ) 
	SB6->(dbSeek(xFilial('SB6')))
Else
	SB6->(dbSeek(xFilial('SB6')+mv_par01+mv_par02+'R'))
Endif
ProcRegua(800)
While !SB6->(Eof()) .and. SB6->B6_FILIAL == xFilial('SB6') .AND. If(Empty(MV_PAR01),.T.,SB6->B6_CLIFOR = mv_par01 .AND. SB6->B6_LOJA <= mv_par02)
	IncProc( "Processando... Saldos " + DtoC(SB6->B6_EMISSAO) + "...")
	
	// DESCARTA OS REGISTROS COM SALDO ZERO
	If MV_PAR06 == 2 .and. SB6->B6_SALDO <= 0 // não listar saldo zero
		While SB6->B6_SALDO <= 0 .and. !SB6->(Eof())
			SB6->(dbSkip())
		EndDo
		loop
	EndIf
	
	If !Empty(MV_PAR08)
		If !AllTrim(SB6->B6_TES) $ MV_PAR08
			SB6->(dbSkip())
			loop
		EndIf
	EndIf

	DbSelectArea("SA7")
	DbSetOrder(1)
	SA7->(DbSeek(xFilial("SA7") + SB6->B6_CLIFOR + SB6->B6_LOJA + SB6->B6_PRODUTO))
//	cNom_Cpo := "SA7->A7_PRECO"+AllTrim(StrZero(MONTH(dDataBase),2))
	cNom_Cpo := "SA7->A7_PRECO" + StrZero(Val(MV_PAR05),2) /// preço do mês, conforme mês informado.
		
	DbSelectArea("SB1")
	DbSetOrder(1)
	SB1->(DbSeek(xFilial("SB1")+SB6->B6_PRODUTO))
	
	Aadd(aReg_Arq,{SB6->B6_CLIFOR,SB6->B6_EMISSAO,SB6->B6_DOC,SB6->B6_UENT,SB6->B6_PRODUTO,SB1->B1_DESC,SB1->B1_UM,SB6->B6_SALDO,SB6->B6_PRUNIT,&(cNom_Cpo),SB6->B6_TES})

	SB6->(dbSkip())

EndDo

If Len(aReg_Arq) > 0

	// CRIAR ARQUIVO DBF PARA SER IMPORTADO E ANEXADO NO E-MAIL
	ProcRegua(1500)
	For _x := 1 to 500
		IncProc("Gerando Arquivos DBF...(aguarde)")
	Next
	
	// ORDENA O ARRAY EM ORDEM DE CÓDIGO DE PRODUTO
	aSort( aReg_Arq ,,, {|a,b| a[5] < b[5]} )
	cCod_Pro := aReg_Arq[1,5]
	For xi:=1 to Len(aReg_Arq)
	    /*
	    while aReg_Arq[xi,8] <= 0
			xi++
		EndDo	
		*/
		RecLock("TRB",.T.)
		TRB->CLIENTE	:= aReg_Arq[xi,01]
		TRB->EMISSAO	:= aReg_Arq[xi,02]
		TRB->NOTA		:= aReg_Arq[xi,03]
		TRB->ULT_COMP	:= aReg_Arq[xi,04]
		TRB->CODIGO		:= aReg_Arq[xi,05]
		TRB->DESCRICAO	:= aReg_Arq[xi,06]
		TRB->UM			:= aReg_Arq[xi,07]
		TRB->SALDO		:= aReg_Arq[xi,08]
		TRB->PRC_VEN	:= aReg_Arq[xi,09]
		TRB->PRC_REM	:= aReg_Arq[xi,10]
		TRB->TES        := aReg_Arq[xi,11]
		MsUnLock()
		// INSERE UM REGISTRO COM O TOTAL GERADO
		If cCod_Pro <> aReg_Arq[xi,5]
	   	RecLock("TRB",.T.)
			TRB->CLIENTE	:= cCod_Cli
			TRB->NOTA		:= "TOTAL"
			TRB->CODIGO		:= cCod_Pro
			TRB->DESCRICAO	:=	cDes_Pro
			TRB->UM			:=	cUni_Med
			TRB->SALDO		:= nTot_Pro
			MsUnLock()
		   nTot_Pro := 0
	  		cCod_Pro := aReg_Arq[xi,5]
		EndIf
		// TOTALIZA CADA PRODUTO E GUARDA DADOS DO REGISTRO ATUAL
		cCod_Cli	:= aReg_Arq[xi,1]
		cDes_Pro	:= aReg_Arq[xi,6]
		cUni_Med	:= aReg_Arq[xi,7]
		nTot_Pro += aReg_Arq[xi,8]		
	Next
    // CRIANDO INDICE DO ARQUIVO .DBF             
	cNom_Ind := Subs(_cArqTrb,1,7)+"A"
	IndRegua("TRB",cNom_Ind,"DESCRICAO+DTOS(EMISSAO)",,,"Selecionando Registros...")
	dbClearIndex()
	dbSetIndex(cNom_Ind+OrdBagExt())
	
	If MV_PAR04 == 1
	
		DbSelectArea("TRB")
		TRB->(dbGotop())
		ProcRegua(TRB->(RECCOUNT()))	
		aCols := Array(TRB->(RECCOUNT()),Len(_aCampos))
		nColuna := 0
		nLinha := 0
		While TRB->(!Eof())
			nLinha++
			IncProc(OemToAnsi("Gerando planilha excel..."))
			For nColuna := 1 to Len(_aCampos)
				aCols[nLinha][nColuna] := &("TRB->("+_aCampos[nColuna][1]+")")			
			Next nColuna
			TRB->(dbSkip())	
		EndDo
		u_GDToExcel(_aCampos,aCols,Alltrim(FunName()))
	
		// CRIA ARQUIVO PARA ABRIR NO EXCEL
		DbSelectArea("TRB")
        Copy to &cArqExcell VIA "DBFCDX"
        
        MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
		CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO
		
		ProcRegua(1500)
		For _x := 1 to 1000
			IncProc("Gerando Planilha XLS...(aguarde)")
		Next
		ExecPlan()
	EndIf
	
	// CHAMADA DA FUNÇÃO DE CRIÇÃO DO ARQUIVO DE COTAÇÃO DE PREÇO DE PRODUTOS	
	If MV_PAR07 == 14
		GeraLst()
	EndIf
	
	ProcRegua(1500)
	For _x := 1 to 1500
		IncProc("Arquivos gerados com sucesso...")
	Next
EndIf
Return

*---------------------------*
Static Function RodaRel()    
*---------------------------*
Local _lIgual
Local _cDescProd
Local cAssunto	:= ""
Local cEmail	:= Space(220)
Local aAttach	:= {}
Local aMsg		:= {}
Local _cTitulo := ""
Local _cDesc1  := ""
Local _cDesc2  := ""
Local _qTOTAL  := 0
Local _cValTotal := 0
//Local cArqExcell:=GetSrvProfString("STARTPATH","")+"Excell-DBF\" // JBS 12/12/2005
                                  
// Alteração efetuada para gravar dados na raiz da pasta \protheus_data\ por Sandro em 19/11/09.
Local cArqExcell := "\Excell-DBF\" 

If Len(aReg_Arq) > 0
	DbSelectArea("SA1")
	DbSetOrder(1)
	SA1->(DbSeek(xFilial("SA1")+mv_par01+mv_par02))
	
	_cTitulo := "Produtos em poder de: "+AllTrim(SA1->A1_NOME)+' - '+mv_par01+'-'+mv_par02
	_cDesc1  := "|                                                                                                                                                 |           VENDA            |          REMESSA           |"
	_cDesc2  := "| Codigo | Descricao                                                    |U.M.| TES |  NOTA     |  EMISSAO   | ULT.COMPRA |       SALDO |    CONTAGEM |  Quantidade |        Preco |  Quantidade |        Preco |"
	_qTOTAL  := 0
	dData		:= "Impresso dia: " + DTOC(ddatabase) + " as " + SUBSTR(time(),1,5)+'  por: '+Upper(U_DipUsr())
	
	If MV_PAR03 == 1
		// Cabeçalho do e-mail
		Aadd(aMsg,{_cTitulo,dData}) 
		Aadd(aMsg,{"Codigo","Descricao","REMESSA","Nota","Emissão","Ult.Compra","Saldo","CONTAGEM","VENDA","Preço","Quantidade","Preço","TES"})
		cAssunto := "Produtos em Poder de Terceiros"
	EndIf
	
	DbSelectArea("TRB")
	_cChave  := 'DESCRICAO+NOTA+DTOS(EMISSAO)'
	IndRegua("TRB",_cArqTrb,_cChave,,,"Criando Indice...(descricao)")
	DbGoTop()
	SetRegua(RecCount())
	
	_cDescProd := TRB->DESCRICAO
	_lIgual    := .F.
	        
	Do While TRB->(!Eof())
	
		IncRegua( "Imprimindo: " + TRB->DESCRICAO +' - '+ TRB->CODIGO )
		
		If li > 65
			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
		EndIf
	
		// PULA TODOS REGISTROS DE TOTAL
		WHILE AllTrim(TRB->NOTA) == "TOTAL"
			TRB->(DbSkip())
		EndDo	
		
		If MV_PAR03 == 1
			// Itens do e-mail
			Aadd(aMsg,{TRB->CODIGO,;     // 03,01
			           TRB->DESCRICAO,;  // 03,02
			           TRB->UM,;         // 03,03
			           TRB->TES,;        // 03,04
			           TRB->NOTA,;       // 03,05
			           TRB->EMISSAO,;    // 03,06
			           TRB->ULT_COMP,;   // 03,07
			           TRB->SALDO,;      // 03,08
			           ".",;             // 03,09
			           ".",;             // 03,10
			           TRB->PRC_VEN,;    // 03,11
			           TRB->PRC_REM})	 // 03,12
	    EndIf
		*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
		*123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
		*                                                                                                                                            |           VENDA            |          REMESSA           |"
		* Codigo | Descricao                                                    |U.M.| TES |  NOTA    |  EMISSAO   | ULT.COMPRA |       SALDO |    CONTAGEM |  Quantidade |        Preco |  Quantidade |        Preco |"
		* 999999 | 123456789012345678901234567890123456789012345678901234567890 |xxxx| xxx | 999999   | 99/99/9999 | 99/99/9999 | 999.999.999 | 999.999.999 | 999.999.999 | 999.999,9999 | 999.999.999 | 999.999,9999 |
		If !_lIgual
			@ li,000 PSay '|'
			@ li,002 PSay Subs(TRB->CODIGO,1,6)
			@ li,009 PSay '|'
			@ li,011 PSay TRB->DESCRICAO
			@ li,072 PSay '|'
			@ li,074 PSay TRB->UM
			@ li,077 PSay '|'
			@ li,079 PSay TRB->TES
		EndIf
		@ li,083 PSay '|'
		@ li,085 PSay TRB->NOTA
		@ li,095 PSay '|'
		@ li,097 PSay TRB->EMISSAO
		@ li,108 PSay '|'
	    @ li,110 PSay Iif(!Empty(TRB->ULT_COMP),TRB->ULT_COMP,Space(10))
	    @ li,121 PSay '|'
		@ li,123 PSay TRB->SALDO PICTURE '@E 999,999,999'
		@ li,135 PSay '|'
		@ li,149 PSay '|'
		@ li,163 PSay '|'
		@ li,165 PSay TRB->PRC_VEN PICTURE '@E 999,999.9999'
		@ li,178 PSay '|'
		@ li,192 PSay '|'
		@ li,194 PSay TRB->PRC_REM PICTURE '@E 999,999.9999'
		@ li,207 PSay '|'
		li++
		If !_lIgual
			@ li,000 Psay Replicate('-',205)
		Else                                
			@ li,083 Psay Replicate('-',122)
		EndIf
		li++
		
		_qTOTAL    := _qTOTAL    + TRB->SALDO
	    _cValTotal += (TRB->SALDO*TRB->PRC_VEN)
		DbSelectArea("TRB")
		TRB->(DbSkip())
		
		// PULA TODOS REGISTROS DE TOTAL
		WHILE AllTrim(TRB->NOTA) == "TOTAL"
			TRB->(DbSkip())
		EndDo	
		
		If _cDescProd <> TRB->DESCRICAO
			_cDescProd  := TRB->DESCRICAO
			@ li,121 PSay '|'
			@ li,123 PSay _qTotal PICTURE '@E 999,999,999'
			@ li,135 PSay '|'
			li++
			@ li,000 Psay Replicate('-',205)
			li++
			_qTotal := 0
			_lIgual := .F.
		Else
			_lIgual := .T.	
		EndIf
	
	EndDo
	
	If li <> 80
		@ li,000 PSay Replic("*",Limite)
		//   Roda(_nReg,Iif(_nReg=1,'Fornecedor',"Fornecedores"),Tamanho)
	EndIf
	
	// RENOMEIA ARQUIVO CONSIGNA.XLS PARA O CÓDIGO DO REPRESENTANTE
	If MV_PAR04 == 1	   
		cOld_Arq := cArqExcell+"\Consigna.xls"	
		cNew_Arq := cArqExcell+"\Consi" + AllTrim(mv_par01) + ".xls"
		If File(cNew_Arq)
			FERASE(cNew_Arq)
		EndIf
		RENAME (cOld_Arq) TO (cNew_Arq)
		If File(cOld_Arq)
		   FERASE(cOld_Arq)
		EndIf
	EndIf
	
	If MV_PAR03 == 1
		//rfalco@ibest.com.br;rafael@dipromed.com.br
		@ 126,000 To 270,300 DIALOG oDlg TITLE OemToAnsi("Informe o endereço do E-mail")
		@ 010,015 Say "Endereço:"
		@ 025,015 Get cEmail Size 120,20 Picture "@S80" Valid !Empty(cEmail)	
		@ 045,050 BmpButton Type 1 Action Close(oDlg)
		Activate Dialog oDlg Centered
	
		// ATACHAR PLANILHA AO E-MAIL QUE SERÁ ENVIADO
		If MV_PAR04 == 1	   
			cNom_Arq := cArqExcell+"\consi" + AllTrim(mv_par01) + ".xls"
			Aadd(aAttach,cNom_Arq)
		EndIf
	
		EMail(cEmail,cAssunto,aMsg,aAttach)
	
	EndIf
	
Else
	If li > 65
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
	EndIf
	
	@ li,000 PSay Replic("*",Limite)
	li++
	@ li,002 PSay "Nenhum registro Localizado"
	li++
	@ li,000 PSay Replic("*",Limite)
EndIf	

Return(.T.)


/*==========================================================================\
|Programa  |EMail   | Autor | Rafael de Campos Falco  | Data ³ 04/06/2004   |
|===========================================================================|
|Desc.     | Envio de EMail                                                 |
|===========================================================================|
|Sintaxe   | EMail                                                          |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function EMail(cEmail,cAssunto,aMsg,aAttach)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cCod_Pro	:= ""
Local ni 		:= 1
Local i         := 0
Local cTot_Pro  := 0
Local cArq      := ""
Local cMsg      := ""  
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.


/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' + cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
//cMsg += '<Img Src="C:/AP5/SIGAADV/LGRL01.BMP"><BR>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

/*=============================================================================*/
/*Definicao do cabecalho do relatório                                          */
/*=============================================================================*/

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="50%">' + aMsg[1,1] + '</td>'
cMsg += '</tr>'
cMsg += '<tr>'
cMsg += '<td width="50%">' + aMsg[1,2] + '</td>'
cMsg += '</tr>'
cMsg += '</table>'

If MV_PAR04 == 2 // SE NÃO FOR ENVIAR PLANILHA ATACHADA
	cMsg += '<table width="100%">'
	cMsg += '<tr>'
	cMsg += '<td>===============================================================================================================</td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	
	cMsg += '<table width="100%">'
	cMsg += '<tr>'
	cMsg += '<td width="10%">' + aMsg[2,1] + '</td>'
	cMsg += '<td width="50%">' + aMsg[2,2] + '</td>'
	cMsg += '<td width="20%" align="center">' + aMsg[2,9] + '</td>'
	cMsg += '<td width="20%" align="center">' + aMsg[2,3] + '</td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	    
	cMsg += '<table width="100%">'
	cMsg += '<tr>'
	cMsg += '<td width="10%">' + aMsg[2,4] + '</td>'
	cMsg += '<td width="10%">' + aMsg[2,5] + '</td>'
	cMsg += '<td width="10%">' + aMsg[2,6] + '</td>'
	cMsg += '<td width="10%" align="right">' + aMsg[2,7] + '</td>'
	cMsg += '<td width="10%" align="right">' + aMsg[2,8] + '</td>'
	cMsg += '<td width="10%" align="right">' + aMsg[2,11]+ '</td>'
	cMsg += '<td width="10%" align="right">' + aMsg[2,10]+ '</td>'
	cMsg += '<td width="10%" align="right">' + aMsg[2,11]+ '</td>'
	cMsg += '<td width="10%" align="right">' + aMsg[2,12]+ '</td>'
	cMsg += '<td width="10%" align="center">' +aMsg[2,13]+ '</td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	    
	cMsg += '<table width="100%">'
	cMsg += '<tr>'
	cMsg += '<td>===============================================================================================================</td>'
	cMsg += '</tr>'
	cMsg += '</table>'
	
	
	/*=============================================================================*/
	/*Definicao do texto/detalhe do email                                          */
	/*=============================================================================*/
	
	
	For nLin := 3 to Len(aMsg)
		If cCod_Pro != aMsg[nLin,1]
			cMsg += '<table width="100%">'
			cMsg += '<tr BgColor=#B0E2FF>'
			cMsg += '<td width="10%">' + aMsg[nLin,1] + '</td>'
			cMsg += '<td width="70%">' + aMsg[nLin,2] + '</td>'
			cMsg += '<td width="10%">' + aMsg[nLin,3] + '</td>'
			cMsg += '</tr>'
			cMsg += '</table>'
			cCod_Pro := aMsg[nLin,1]
			cTot_Pro := 0
		EndIf	
	    
		cMsg += '<table width="100%" border="1">'
		cMsg += '<tr BgColor=#FFFFFF>'
		cMsg += '<td width="10%">' + aMsg[nLin,5] + '</td>'
		cMsg += '<td width="10%">' + DtoC(aMsg[nLin,6]) + '</td>'
		cMsg += '<td width="10%">' + DtoC(aMsg[nLin,7]) + '</td>'
		cMsg += '<td width="10%" align="right">' + Transform(aMsg[nLin,8],"@E 9,999,999") + '</td>'
		cMsg += '<td width="10%">' + aMsg[nLin,9] + '</td>'
		cMsg += '<td width="10%">' + aMsg[nLin,10] + '</td>'
		cMsg += '<td width="10%" align="right">' + Transform(aMsg[nLin,11],"@E 9,999.9999")+ '</td>'
		cMsg += '<td width="10%">' + aMsg[nLin,10] + '</td>'
		cMsg += '<td width="10%" align="right">' + Transform(aMsg[nLin,12],"@E 9,999.9999")+ '</td>'
		cMsg += '<td width="10%">' + aMsg[nLin,4] + '</td>'
		cMsg += '</tr>'
		cMsg += '</table>'
	
		cTot_Pro += aMsg[nLin,8]
	
		If cCod_Pro != Iif(Len(aMsg)==nLin,"x", aMsg[nLin+1,1])   // Imprime total do produto
			cMsg += '<table width="100%" border="1">'
			cMsg += '<tr BgColor=#FFFFFF>'
			cMsg += '<td width="10%"></td>'
			cMsg += '<td width="10%"></td>'
			cMsg += '<td width="10%" align="center">Total</td>'
			cMsg += '<td width="10%" align="center">' + Transform(cTot_Pro,"@E 9,999,999") + '</td>'
			cMsg += '<td width="10%"></td>'
			cMsg += '<td width="10%"></td>'
			cMsg += '<td width="10%"></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
		EndIf	
	Next
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do rodape do email                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '</body>'
cMsg += '</html>'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailCc := SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Else
	cEmailTo := Alltrim(cEmail)
EndIF

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf


If lResult .And. lAutOk
	If MV_PAR04 == 1
		SEND MAIL FROM cFrom ;
		TO      	Lower(cEmailTo);
		CC      	Lower(cEmailCc);
		BCC     	Lower(cEmailBcc);
		SUBJECT 	cAssunto;
		BODY    	cMsg;
		ATTACHMENT  aAttach[1];
		RESULT lResult
	Else
		SEND MAIL FROM cFrom ;
		TO      	Lower(cEmailTo);
		CC      	Lower(cEmailCc);
		BCC     	Lower(cEmailBcc);
		SUBJECT 	cAssunto;
		BODY    	cMsg;
		RESULT lResult
	EndIf
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Atenção"))
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError	
	MsgInfo(cError,OemToAnsi("Atenção"))
EndIf

Return(.T.)



/*==========================================================================\
|Programa  | ExecPlan | Autor | Rafael de Campos Falco | Data ³ 17/09/2004  |
|===========================================================================|
|Desc.     | Executa macro pra gerar arquivo XLS                            |
|===========================================================================|
|Sintaxe   | ExecPlan                                                          |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
\==========================================================================*/

Static Function ExecPlan()
//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\" // JBS 12/12/2005

// Alterado para gravar na pasta protheus_data - Por Sandro em 19/11/09. 
Local cArqExcell:= "\Excell-DBF\" 

cOld_Arq := cArqExcell+"\consigna.xls"
If File(cOld_Arq)
	FERASE(cOld_Arq)
EndIf

// Tento executar o Excel
If ! ApOleClient( 'MsExcel' )
	MsgStop('MsExcel nao instalado')
	Return
EndIf

oExcelApp := MsExcel():New()

oExcelApp:WorkBooks:Open(cArqExcell+"\MacroSaldo.xls") // Abre uma planilha

//oExcelApp:SetVisible(.T.) // Exibe geração do arquivo XLS

Return


/*==========================================================================\
|Programa  | GeraLst | Autor | Rafael de Campos Falco  | Data | 15/12/2004  |
|===========================================================================|
|Desc.     | Função para gerar lista de preços direto no EXCEL              |
|===========================================================================|
|Sintaxe   | GeraLst                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da modificação                            |
|          |   /  /   -                                                     |
\==========================================================================*/

Static Function GeraLst()
Local nTot_Pro := 0
Local cCod_Cli	:= ""
Local cCod_Pro	:= ""
Local cDes_Pro	:= ""
Local cUni_Med	:= ""
//Local cArqExcell:= GetSrvProfString("STARTPATH","")+"Excell-DBF\" // JBS 12/12/2005 
                                  

// Alterado para gravar na pasta protheus_data - Por Sandro em 19/11/09.
Local cArqExcell:= "\Excell-DBF\" 

_aCampos := {}                  
AAdd(_aCampos ,{"CODIGO"   ,"C",AvSx3('B6_PRODUTO',3),AvSx3('B6_PRODUTO',4)}) // JBS 04/01/2006
AAdd(_aCampos ,{"DESCRICAO","C",AvSx3('B1_DESC',3)   ,AvSx3('B1_DESC',4)})    // JBS 04/01/2006
AAdd(_aCampos ,{"UM"       ,"C",AvSx3('B1_UM',3)     ,AvSx3('B1_UM',4)})      // JBS 04/01/2006
AAdd(_aCampos ,{"PRC_REM"  ,"N",AvSx3('B6_SALDO',3)  ,AvSx3('B6_SALDO',4)})   // JBS 04/01/2006
AAdd(_aCampos ,{"TES"      ,"C",AvSx3('B6_TES',3)    ,AvSx3('B6_TES',4)})     // JBS 04/01/2006
DbUseArea(.T.,,_cArqTrb1,"TRB1",.F.,.F.)

DbSelectArea("SA7")
DbSetOrder(1)
SA7->(dbSeek(xFilial('SA7') + MV_PAR01 + MV_PAR02 ))
ProcRegua(1000)
While SA7->(!EOF()) .AND. SA7->A7_CLIENTE + SA7->A7_LOJA == MV_PAR01 + MV_PAR02
	IncProc( "Processando... COTAÇÃO " + SA7->A7_PRODUTO + "...")	

	cNom_Cpo := "SA7->A7_PRECO" + StrZero(Val(MV_PAR05),2)

	DbSelectArea("SB1")
	DbSetOrder(1)
	SB1->(DbSeek(xFilial("SB1") + SA7->A7_PRODUTO))
	nPos := aScan(aReg_Lst,{|x| x[1] == SA7->A7_PRODUTO})
	If nPos == 0
		Aadd(aReg_Lst,{SA7->A7_PRODUTO,SB1->B1_DESC,SB1->B1_UM,&(cNom_Cpo)})	
	EndIf
	SA7->(dbSkip())
EndDo

// CRIAR ARQUIVO DBF PARA SER IMPORTADO E ANEXADO NO E-MAIL
ProcRegua(1500)
For _x := 1 to 500
	IncProc("Gerando Arquivos DBF...(aguarde)")
Next

// ORDENA O ARRAY EM ORDEM DE CÓDIGO DE PRODUTO
aSort( aReg_Lst ,,, {|a,b| a[1] < b[1]} )
For xi:=1 to Len(aReg_Lst)
	RecLock("TRB1",.T.)
	TRB1->CODIGO	:= aReg_Lst[xi,1]
	TRB1->DESCRICAO	:= aReg_Lst[xi,2]
	TRB1->UM		:= aReg_Lst[xi,3]
	TRB1->PRC_REM	:= aReg_Lst[xi,4]
	MsUnLock()
Next


// CRIANDO INDICE DO ARQUIVO .DBF             
cNom_Ind := Subs(_cArqTrb1,1,7)+"A"
IndRegua("TRB1",cNom_Ind,"DESCRICAO",,,"Selecionando Registros...")
dbClearIndex()
dbSetIndex(cNom_Ind+OrdBagExt())

DbSelectArea("TRB1")
TRB1->(dbGotop())
ProcRegua(TRB1->(RECCOUNT()))	
aCols := Array(TRB1->(RECCOUNT()),Len(_aCampos))
nColuna := 0
nLinha := 0
While TRB1->(!Eof())
	nLinha++
	IncProc(OemToAnsi("Gerando planilha excel..."))
	For nColuna := 1 to Len(_aCampos)
		aCols[nLinha][nColuna] := &("TRB1->("+_aCampos[nColuna][1]+")")			
	Next nColuna
	TRB1->(dbSkip())	
EndDo
u_GDToExcel(_aCampos,aCols,Alltrim(FunName()))

// CRIA ARQUIVO PARA ABRIR NO EXCEL
cNom_Lst := cArqExcell+"Cotacao-" + mv_par01
DbSelectArea("TRB1")
COPY TO &cNom_Lst  VIA "DBFCDX"

ProcRegua(1500)
For _x := 1 to 1000
	IncProc("Gerando Planilha de Cotação...(aguarde)")
Next

ExecPlan()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta arquivos temporarios e Retorna Indices padräes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("TRB1")
TRB1->(DbCloseArea())
Ferase(_cArqTrb1+".DBF")
Ferase(_cArqTrb1+OrdBagExt())

Return
/*==========================================================================\
|Programa  |VALIDPERG| Autor | Rafael de Campos Falco  | Data ³ 04/06/2004  |
|===========================================================================|
|Desc.     | Inclui as perguntas caso nao existam                           |
|===========================================================================|
|Sintaxe   | VALIDPERG                                                      |
|===========================================================================|
|Uso       | Especifico DIPROMED                                            |
|===========================================================================|
|Histórico | DD/MM/AA - Descrição da alteração                              |
\==========================================================================*/

Static Function AjustaSX1(cPerg)

_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)  

aRegs:={}
//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
AADD(aRegs,{cPerg,"01","Qual cliente       ?","","","mv_ch1","C", 6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
AADD(aRegs,{cPerg,"02","Loja do cliente    ?","","","mv_ch2","C", 2,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"03","Envia e-mail       ?","","","mv_ch3","N", 1,0,0,"C","","MV_PAR03","1-Sim","","","","","2-Não","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"04","Gerar Planilha     ?","","","mv_ch4","N", 1,0,0,"C","","MV_PAR04","1-Sim","","","","","2-Não","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"05","Preço do mês       ?","","","mv_ch5","C", 2,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"06","Listar Saldo zero  ?","","","mv_ch6","N", 1,0,0,"C","","MV_PAR06","1-Sim","","","","","2-Não","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"07","Gerar Plan. Cotacao?","","","mv_ch7","N", 1,0,0,"C","","MV_PAR07","1-Sim","","","","","2-Não","","","","","","","","","","","","","","","","","","",''})
AADD(aRegs,{cPerg,"08","Tes                ?","","","mv_ch8","C",60,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","",''})
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