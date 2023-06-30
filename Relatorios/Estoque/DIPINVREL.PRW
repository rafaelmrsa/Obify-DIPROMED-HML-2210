#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

#DEFINE ENTER CHR(13)+CHR(10)
/*====================================================================================\
|Programa  | DIPINVREL()  | Autor  | Reginaldo Borges   | Data | 01/01/2015           |
|=====================================================================================|
|Descrição | Gera um relatorio dos itens contados no inventario rotativo.             |
|          | Rrelatorio tambem sera gerado via workflow e enviado por e-mail em html. |
|          | As informações serão geradas de acordo com as informacoes nos parametros.|
|          |                                                                          |
|=====================================================================================|
|Uso       | Especifico Estoque Custos  - Logística                                   |
|=====================================================================================|
|Histórico | 																		  |
\====================================================================================*/
*/
User Function DipInvRel(aWork)

Local titulo      := OemTOAnsi("Relatorio do Fechamento Diario do Inventario",72)
Local cDesc1      := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2      := (OemToAnsi("com a relação de todos os endereços invetariados.",72))
Local cDesc3      := (OemToAnsi("Conforme parametros definidos.",72))
Private aReturn   := {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li        := 67
Private tamanho   := "M"
Private limite    := 130
Private nomeprog  := "DIPINVREL"
PRIVATE cPerg  	  := "DIPINVREL" 
Private nLastKey  := 0
Private lEnd      := .F.
Private wnrel     := "DIPINVREL"
Private cString   := "ZZD"
Private m_pag     := 1
Private cWorkFlow := ""
Private cWCodEmp  := ""  
Private cWCodFil  := "" 
Private _dDatIni  := ""
Private _dDatFim  := "" 
Private PG := 0

//Tratamento para workflow
If ValType(aWork) <> 'A'
	cWorkFlow := "N"
	cWCodEmp  := cEmpAnt
	cWCodFil  := cFilAnt
	cPerg  	:= U_FPADR( "DIPINVREL","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.
	U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 13/12/2005 - Gravando o nome do Programa no SZU
Else
	cWorkFlow := aWork[1]
	cWCodEmp  := aWork[2]
	cWCodFil  := aWork[3]
EndIf

If cWorkFlow == "N"
	
	AjustaSX1(cPerg)           // Verifica perguntas. Se nao existe INCLUI.
	
	If !Pergunte(cPerg,.T.)    // Solicita parametros
		Return
	EndIf
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.f.,,.f.,tamanho,,.f.,,,,,)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	RptStatus({|lEnd| RodaRel()},Titulo)
	
	Set device to Screen
	
	/*==========================================================================\
	| Se em disco, desvia para Spool                                            |
	\==========================================================================*/
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif
	
Else

	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPINVREL" TABLES "ZZD"	
	
 	MV_PAR01 := dDataBase-1
 	MV_PAR02 := dDataBase
	
  	ConOut('Inicio relatorio do invetario rotativo '+dToc(date())+' as '+Time())
 	
	RodaRel()
  	
  	ConOut('Fim relatorio do invetario rotativo '+dToc(date())+' as '+Time())
  	
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RODAREL() ºAutor  ³Microsiga           º Data ³  01/20/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RodaRel()

Local cArq		:= ""
Local cCampos	:= ""
Local nHandle	:= ""
Local cCodVen	:= ""
Local nTotImp	:= 10
Local cSQL 	    := "" 
Local nI        := 0
Local cEndPen	:= "" 
Private nDifp   := 0
Private nDifg   := 0
Private nDifpg := 0
Private nQtdTot := 0
Private nQtdPen := 0 
Private nQtdOk  := 0
Private nQtdDg  := 0
Private nQtdDp  := 0 
Private nTotIte := 0
Private cStatus := ""
Private aMsgI   := {}
Private aMsgL   := {}
Private _cTitulo:= "Fechamento Diario do Inventario"                                                 
Private _cDesc1 := " Endereço       Produto         Lote        Quant.Sist.     Quant.Cont.    Quant.Eleit.         Status    Data          Custo/Dif"
Private _cDesc2 := ""

cSQL := " SELECT "
cSQL += " 	ZZC_STATUS, ZZC_LOCAL, ZZC_LOCALI,ZZC_DATA "
cSQL += " 	FROM "+RetSQLName("ZZC")
cSQL += " 		WHERE "
cSQL += " 			ZZC_FILIAL     = '"+xFilial("ZZC")+"' AND "
cSQL += " 			ZZC_DATA BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'AND"
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)      
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZC",.T.,.F.)

Do While QRYZZC->(!Eof())
	If QRYZZC->ZZC_STATUS <> '4'//Endereço pendente ou em aberto
		cEndPen += QRYZZC->ZZC_LOCAL+" - "+QRYZZC->ZZC_LOCALI+CHR(10)+CHR(13)
		nQtdPen++ //Quantidade pendente
	EndIf
	nQtdTot++
	
	cSQL := " SELECT "
	cSQL += " ZZD.ZZD_DATA, ZZD.ZZD_PRODUT,ZZD.ZZD_LOTECT, ZZD.ZZD_LOCAL, ZZD.ZZD_LOCALI, ZZD.ZZD_QUANT, ZZD.ZZD_QTCONT, ZZD.ZZD_QTELEI, 
	cSQL += " ZZD.ZZD_TIPREG, ZZD.ZZD_EXPLIC, "
	cSQL += " CASE WHEN SB1.B1_PROC IN('"+StrTran(GetNewPar("ES_LISFOR","000041/000609/000334/000338/000183/100000/000630/000996/000997"),"/","','")+"') THEN "
	cSQL += " SB1.B1_LISFOR ELSE SB1.B1_UPRC END T_CUSTO"
	cSQL += " FROM "+RetSQLName("ZZD")+" ZZD "
	cSQL += " INNER JOIN "+ RetSQLName("SB1") +" SB1 ON SB1.B1_COD = ZZD.ZZD_PRODUT AND "
	cSQL += " SB1.B1_FILIAL  = '04' AND "
	cSQL += " SB1.D_E_L_E_T_ = ' '      "
	cSQL += " 		WHERE "
	cSQL += " 			ZZD_FILIAL = '"+xFilial("ZZD")+"' AND "
	cSQL += " 			ZZD_DATA   = '"+QRYZZC->ZZC_DATA+"' AND "
	cSQL += " 			ZZD_LOCAL  = '"+QRYZZC->ZZC_LOCAL+"' AND "
	cSQL += " 			ZZD_LOCALI = '"+QRYZZC->ZZC_LOCALI+"' AND "
	cSQL += " 			ZZD.D_E_L_E_T_ = ' ' "
	cSQL += " GROUP BY ZZD.ZZD_DATA, ZZD.ZZD_PRODUT, ZZD.ZZD_LOTECT, ZZD.ZZD_LOCAL, ZZD.ZZD_LOCALI, ZZD.ZZD_QUANT, ZZD.ZZD_QTCONT,  "
	cSQL += "          ZZD.ZZD_QTELEI, ZZD.ZZD_TIPREG, ZZD.ZZD_EXPLIC,SB1.B1_PROC,SB1.B1_UPRC, SB1.B1_LISFOR "
	cSQL += " ORDER BY ZZD.ZZD_LOCALI, ZZD.ZZD_PRODUT, ZZD.ZZD_DATA "
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZD",.T.,.F.)
	
		Do	While QRYZZD->(!Eof()) 
			If QRYZZD->ZZD_TIPREG == 'I'// 'A'-Automatico / 'I'-Informado
				VldTrcLot(QRYZZD->ZZD_DATA,QRYZZD->ZZD_PRODUT,QRYZZD->ZZD_LOCAL,QRYZZD->ZZD_LOCALI,QRYZZD->ZZD_QTELEI)
			EndIf
			If QRYZZD->ZZD_QUANT == QRYZZD->ZZD_QTELEI
				nQtdOk++ 	//Estoque OK
				cStatus := "Correto"
			ElseIf QRYZZD->ZZD_QUANT < QRYZZD->ZZD_QTELEI
				nQtdDg++	//Ganho
				cStatus := "Ganho"
			ElseIf QRYZZD->ZZD_QUANT > QRYZZD->ZZD_QTELEI
				nQtdDp++	//Perda
				cStatus := "Perda"
			ElseIf QRYZZC->ZZC_STATUS <> '4'
				cStatus := "Pendente"
			EndIf
			
			nTotIte++
			
			
			If cWorkFlow == "N" // SE NÃO FOR WORKFLOW
				
				If lAbortPrint
					@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
					Exit
				Endif
				
				If li > 56
					
					li := u_MYCabec(_cTitulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
					
				EndIf
				
				@ li,001 PSay ALLTRIM(QRYZZD->ZZD_LOCAL+"-"+QRYZZD->ZZD_LOCALI)
				@ li,016 PSay ALLTRIM(QRYZZD->ZZD_PRODUT)
				@ li,031 PSay ALLTRIM(QRYZZD->ZZD_LOTECT)
				@ li,046 PSay QRYZZD->ZZD_QUANT
				@ li,061 PSay QRYZZD->ZZD_QTCONT
				@ li,076 PSay QRYZZD->ZZD_QTELEI
				@ li,095 PSay cStatus 
				@ li,105 PSay StoD(QRYZZD->ZZD_DATA) 
				@ li,115 PSay TRANSFORM((QRYZZD->ZZD_QTELEI-QRYZZD->ZZD_QUANT)*QRYZZD->T_CUSTO,"@E 9,999,999.99") 
				
			  	If (QRYZZD->ZZD_QTELEI > QRYZZD->ZZD_QUANT) 
				    nDifg += ((QRYZZD->ZZD_QTELEI-QRYZZD->ZZD_QUANT)*QRYZZD->T_CUSTO)
				Else 
					nDifp += ((QRYZZD->ZZD_QTELEI-QRYZZD->ZZD_QUANT)*QRYZZD->T_CUSTO)
				EndIf
				
				li++
             
		    Else	// CASO SEJA WORKFLOW
				
				cAlmEnd := ALLTRIM(QRYZZD->ZZD_LOCAL+"-"+QRYZZD->ZZD_LOCALI)
				cProduto:= ALLTRIM(QRYZZD->ZZD_PRODUT)
				cLote   := ALLTRIM(QRYZZD->ZZD_LOTECT)
				nQuantS := QRYZZD->ZZD_QUANT 
				nQuantC := QRYZZD->ZZD_QTCONT
				nQuantE := QRYZZD->ZZD_QTELEI
				dData   := StoD(QRYZZD->ZZD_DATA) 
				nCusto  := TRANSFORM((QRYZZD->ZZD_QTELEI-QRYZZD->ZZD_QUANT)*QRYZZD->T_CUSTO,"@E 9,999,999.99")
				
				If (nQuantE > nQuantS) 
				    nDifg  += (QRYZZD->ZZD_QTELEI - QRYZZD->ZZD_QUANT ) * (QRYZZD->T_CUSTO)
				Else 
					nDifp  += (QRYZZD->ZZD_QTELEI - QRYZZD->ZZD_QUANT ) * (QRYZZD->T_CUSTO)
				EndIf
				  					
				aadd(aMsgI,{cAlmEnd,cProduto,cLote,nQuantS,nQuantC,nQuantE,cStatus,dData,nCusto})
				
			EndIf
			QRYZZD->(dbSkip())
		
		EndDo

		QRYZZD->(dbCLoseArea())

	QRYZZC->(dbSkip())
EndDo 

QRYZZC->(dbCloseArea())


	//Query para retornar os produtos e endereços onde ocorreu troca de lote, ganho e perda de produto
	cSQL := " SELECT "
	cSQL += " DISTINCT(ZZD2.ZZD_QUANT)As nQuantP, ZZD2.ZZD_QTELEI As nQtdEleP, ZZD2.ZZD_PRODUT As cProdutP,"
	cSQL += " ZZD2.ZZD_LOTECT As cLoteP , ZZD2.ZZD_LOCALI As cEnderP , ZZD2.ZZD_TIPREG As cTpRegP,         "
	cSQL += " ZZD1.ZZD_QUANT  As nQuantG, ZZD1.ZZD_QTELEI As nQtdEleG, ZZD1.ZZD_PRODUT As cProdutG,        "
	cSQL += " ZZD1.ZZD_LOTECT As cLoteG , ZZD1.ZZD_LOCALI As cEnderG , ZZD1.ZZD_TIPREG As cTpRegG,ZZD1.ZZD_DATA As dData"
	
	cSQL += "FROM "+ RetSQLName("ZZD")
	cSQL += "	INNER JOIN "+ RetSQLName("ZZD") +" ZZD1 ON ZZD1.ZZD_FILIAL = '"+xFilial("ZZD1") +"'"
	cSQL += "	AND        ZZD1.ZZD_LOCAL  = '01'        					                       "
	cSQL += "	AND        ZZD1.ZZD_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'     " 
	CSQL += "   AND        ZZD1.ZZD_QTELEI-ZZD1.ZZD_QUANT > 0                                      "
	cSQL += "	AND        ZZD1.D_E_L_E_T_ = ' ' 				                                   "
	cSQL += "	INNER JOIN "+ RetSQLName("ZZD") +" ZZD2 ON ZZD2.ZZD_FILIAL = ZZD1.ZZD_FILIAL    "
	cSQL += "	AND ZZD2.ZZD_PRODUT = ZZD1.ZZD_PRODUT                  							   "
	cSQL += "	AND ZZD2.ZZD_DATA   = ZZD1.ZZD_DATA         							           "                                                                     
	cSQL += "	AND ZZD2.ZZD_LOCALI = ZZD1.ZZD_LOCALI               							   "                                                                     
	cSQL += "	AND ZZD2.ZZD_LOTECT <>ZZD1.ZZD_LOTECT          					                   "                                                                     
	cSQL += "	AND ZZD2.ZZD_QUANT-ZZD2.ZZD_QTELEI > 0                					           "                                                                     
	cSQL += "	AND ZZD2.D_E_L_E_T_ = ''                                                           "                                                                     
	cSQL += " ORDER BY ZZD2.ZZD_LOCALI, ZZD2.ZZD_PRODUT				                               "                                                              
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYZZDL",.T.,.F.)  
	
	While  QRYZZDL->(!Eof())
		aadd(aMsgL,{QRYZZDL->nQuantP, QRYZZDL->nQtdEleP, QRYZZDL->cProdutP, QRYZZDL->cLoteP, QRYZZDL->cEnderP, QRYZZDL->cTpRegP,;
	                QRYZZDL->nQuantG, QRYZZDL->nQtdEleG, QRYZZDL->cProdutG, QRYZZDL->cLoteG, QRYZZDL->cEnderG, QRYZZDL->cTpRegG, QRYZZDL->dData})  
		QRYZZDL->(dbSkip())	  
	EndDo	                
	QRYZZDL->(dbCLoseArea())      
	
	//Impressão das linhas de totais
	If cWorkFlow == "N" // SE NÃO FOR WORKFLOW
	     

		 	     	
		@ li,000 PSay Replic("-",Limite) 
	    li++                    
		@li,001 PSay "Quant.Sist.    Quant.Eleit.   Produto              Lote          Endereço       Registro     Data"    
		li++
    	@ li,000 PSay Replic("-",Limite) 
    	li++
			
	  		For nI := 1 to Len(aMsgL) 
				@ li,001 PSay aMsgl[nI,1] 
		    	@ li,015 PSay aMsgl[nI,2] 
				@ li,031 PSay AllTrim(aMsgl[nI,3])
				@ li,052 PSay AllTrim(aMsgl[nI,4]) 
				@ li,066 PSay AllTrim(aMsgl[nI,5]) 
				@ li,084 PSay AllTrim(aMsgl[nI,6]) 
				@ li,092 PSay StoD(aMsgl[nI,13])
      	    	li++
   				@ li,001 PSay aMsgl[nI,7] 
		    	@ li,015 PSay aMsgl[nI,8] 
				@ li,031 PSay AllTrim(aMsgl[nI,9] )
				@ li,052 PSay AllTrim(aMsgl[nI,10]) 
				@ li,066 PSay AllTrim(aMsgl[nI,11]) 
				@ li,084 PSay AllTrim(aMsgl[nI,12]) 
				@ li,092 PSay    StoD(aMsgl[nI,13])
      	    	li++ 
      	    Next nI
        li++
		@ li,000 PSay Replic("-",Limite)
		li++
		@ li,000 PSay Replic("-",Limite)
		li++
		@ li,001 PSay "Itens Corretos :"
		@ li,017 PSay nQtdOk 
		@ li,065 PSay "Diferença Perda/Ganha"
		li++
		@ li,001 PSay "Itens Div.Ganho:"
		@ li,017 PSay nQtdDg 
		@ li,035 PSay "Tt. Custo Ganho:"
		@ li,051 PSay TRANSFORM(nDifg, "@E 9,999,999.99") 
		li++
		@ li,001 PSay "Itens Div.Perda:"
		@ li,017 PSay nQtdDp
		@ li,035 PSay "Tt. Custo Perda:"
		@ li,051 PSay TRANSFORM(nDifp, "@E 9,999,999.99") 
		@ li,065 PSay TRANSFORM((nDifg+nDifp),"@E 9,999,999.99")
		
		li++
		@ li,001 PSay "Itens Pendentes:"
		@ li,017 PSay nQtdPen 
		li++
		@ li,000 PSay Replic("-",Limite)
		li++
		@ li,001 PSay "Total de Itens:"
		@ li,017 PSay nTotIte 
		li++
		@ li,000 PSay Replic("-",Limite)
		li++
		@ li,001 PSay "Endes. Contatos:"
		@ li,017 PSay nQtdTot 
		li++
		@ li,000 PSay Replic("-",Limite)  
	Else

		If Len(aMsgI) > 0 // SE NÃO POSSUIR NENHUMA LINHA NO ARRAY NÃO ENVIA NADA  -  RBORGES 01/01/15
			//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo comentada
			//cEmail := GetNewPar("ES_EMINVRO","reginaldo.borges@dipromed.com.br")   //Usuários que receberão e-mails - RBORGES 01/01/15
			//Rafael Moraes Rosa - 28/06/2023 - Linha abaixo substituida
			cEmail := IIF(Empty(SUPERGETMV("MV_#EMLSCH", .F., "")),SUPERGETMV("ES_EMINVRO", .F., ""),GETMV("MV_#EMLSCH"))   //Usuários que receberão e-mails - RBORGES 01/01/15
			
			cAssunto:= 'INVENTARIO ROTATIVO - Periodo de: ' +DtoC(MV_PAR01)+ ' Ate '+DtoC(MV_PAR02)+' - ' +AllTrim(SM0->M0_NOME)+"/"+AllTrim(SM0->M0_FILIAL)
			nDifpg += (nDifg + nDifp)//Calculando a diferença das perdas e ganhos
			U_EMailIR(cEmail,cAssunto,aMsgI,aMsgL,nDifg,nDifp,nDifpg) //RBORGES 01/01/15 - Dispara E-mail do inventário rotativo
		EndIf
	EndIf 

		

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPINVREL ºAutor  ³Microsiga           º Data ³  01/13/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    
Static Function VldTrcLot(dData,cProduto,cLocal,cLocali,nQtd)
                                 

Local cSQL := ""

cSQL := " SELECT "
cSQL += " 	ZZD_DATA, ZZD_PRODUT, ZZD_LOCAL, ZZD_LOCALI, ZZD_QUANT, ZZD_QTCONT, ZZD_QTELEI, ZZD_TIPREG, ZZD_EXPLIC "
cSQL += " 	FROM "
cSQL += 		RetSQLName("ZZD")
cSQL += " 		WHERE "
cSQL += " 			ZZD_FILIAL = '"+xFilial("ZZD")+"' AND "
cSQL += " 			ZZD_DATA   = '"+dData+"' AND "
cSQL += " 			ZZD_PRODUT = '"+cProduto+"' AND "
cSQL += " 			ZZD_LOCAL  = '"+cLocal+"' AND "	
cSQL += " 			ZZD_LOCALI = '"+cLocali+"' AND "	
cSQL += " 			ZZD_TIPREG = 'A' AND "
cSQL += " 			(ZZD_QUANT-ZZD_QTELEI) = '"+AllTrim(Str(nQtd))+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY ZZD_LOCALI, ZZD_PRODUT, ZZD_DATA "

cSQL := ChangeQuery(cSQL)      
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYLOT",.T.,.F.)      

While !QRYLOT->(Eof())
    //Acerto de Loja
	QRYLOT->(dbSkip())
EndDo
QRYLOT->(dbCloseArea())

Return

/*==========================================================================\
|Programa  |VALIDPERG| Autor | Reginaldo Borges        | Data ³ 03/02/15    |
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

AADD(aRegs,{cPerg,"01","Inv. Rotativo de  ?","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Inv. Rotativo ate ?","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

/*------------------------------------------------------------------------+
+ Funcao:EMailTa()    |  Autor: RBORGES     |      Data: 01/01/15         +                                                     
+ Fará tratamento para enviar E-mail do inventário rotativo.              +
-------------------------------------------------------------------------*/

User Function EMailIR(cEmail,cAssunto,aMsgI,aMsgL)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := ""
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nI
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
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<td width="11%">Endereço     </td>'
cMsg += '<td width="11%">Produto      </td>'
cMsg += '<td width="11%">Lote         </td>'
cMsg += '<td width="11%">Quant.Sist.  </td>'
cMsg += '<td width="11%">Quant.Cont.  </td>'
cMsg += '<td width="11%">Quant.Eleit. </td>'
cMsg += '<td width="11%">Status       </td>'
cMsg += '<td width="11%">Data         </td>'
cMsg += '<td width="11,1%">Custo      </td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

/*=============================================================================*/
/*Definicao do texto/detalhe do email                                          */
/*=============================================================================*/

For nI := 1 to Len(aMsgI)
	nLin:= nI
	If Mod(nLin,2) == 0
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#B0E2FF">'
		cMsg += '<td width="11%" ><font  size="2">' +aMsgI[nLin,1]+ '</font></td>'
		cMsg += '<td width="11%" ><font  size="2">' +aMsgI[nLin,2]+ '</font></td>'
		cMsg += '<td width="11%" ><font  size="2">' +aMsgI[nLin,3]+ '</font></td>'
		cMsg += '<td width="11%" ><font  size="2">' +cValToChar(aMsgI[nLin,4])+ '</font></td>'
		cMsg += '<td width="11%" ><font  size="2">' +cValToChar(aMsgI[nLin,5])+ '</font></td>'
		cMsg += '<td width="11%" ><font  size="2">' +cValToChar(aMsgI[nLin,6])+ '</font></td>'
		cMsg += '<td width="11%" ><font  size="2">' +aMsgI[nLin,7]+ '</font></td>'		
		cMsg += '<td width="11% " ><font size="2">' +DtoC(aMsgI[nLin,8])+ '</font></td>'
		cMsg += '<td width="11,1%"><font size="2">' +cValToChar(aMsgI[nLin,9])+ '</font></td>'		
		cMsg += '</tr>'
		cMsg += '</table>'
	Else
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#c0c0c0">'
		cMsg += '<td width="11%"><font   size="2">' +aMsgI[nLin,1]+ '</font></td>'
		cMsg += '<td width="11%"><font   size="2">' +aMsgI[nLin,2]+ '</font></td>'
		cMsg += '<td width="11%"><font   size="2">' +aMsgI[nLin,3]+ '</font></td>'
		cMsg += '<td width="11%"><font   size="2">' +cValToChar(aMsgI[nLin,4])+ '</font></td>'
		cMsg += '<td width="11%"><font   size="2">' +cValToChar(aMsgI[nLin,5])+ '</font></td>'
		cMsg += '<td width="11%"><font   size="2">' +cValToChar(aMsgI[nLin,6])+ '</font></td>'
		cMsg += '<td width="11%"><font   size="2">' +aMsgI[nLin,7]+ '</font></td>'		
		cMsg += '<td width="11%"><font   size="2">' +DtoC(aMsgI[nLin,8])+ '</font></td>'		
		cMsg += '<td width="11,1%"><font size="2">' +cValToChar(aMsgI[nLin,9])+ '</font></td>'		
		cMsg += '</tr>'
		cMsg += '</table>'
	EndIf	
Next 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definição dos endereços com troca de lote ou perda e ganho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'           

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<td width="15%">Quant.Sist. </td>'
cMsg += '<td width="15%">Quant.Eleit.</td>'
cMsg += '<td width="14%">Produto     </td>'
cMsg += '<td width="14%">Lote        </td>'
cMsg += '<td width="14%">Endereço    </td>'
cMsg += '<td width="14%">Registro    </td>'
cMsg += '<td width="14%">Data        </td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

For nI := 1 to Len(aMsgL)
	nLin:= nI
	If Mod(nLin,2) == 0
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#B0E2FF">'
		cMsg += '<td width="15%"><font size="2">' +cValToChar(aMsgL[nLin,1])+ '</font></td>'
		cMsg += '<td width="15%"><font size="2">' +cValToChar(aMsgL[nLin,2])+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,3]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,4]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,5]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,6]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,13]+ '</font></td>'		
		cMsg += '</tr>'
		cMsg += '<tr bgcolor="#B0E2FF">'
		cMsg += '<td width="15%"><font size="2">' +cValToChar(aMsgL[nLin,7])+ '</font></td>'
		cMsg += '<td width="15%"><font size="2">' +cValToChar(aMsgL[nLin,8])+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,9]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,10]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,11]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,12]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,13]+ '</font></td>'		
		cMsg += '</tr>'
		cMsg += '</table>'
	Else
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
		cMsg += '<tr bgcolor="#c0c0c0">'
		cMsg += '<td width="15%"><font size="2">' +cValToChar(aMsgL[nLin,1])+ '</font></td>'
		cMsg += '<td width="15%"><font size="2">' +cValToChar(aMsgL[nLin,2])+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,3]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,4]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,5]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,6]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,13]+ '</font></td>'		
		cMsg += '</tr>'
		cMsg += '<tr bgcolor="#c0c0c0">'
		cMsg += '<td width="15%"><font size="2">' +cValToChar(aMsgL[nLin,7])+ '</font></td>'
		cMsg += '<td width="15%"><font size="2">' +cValToChar(aMsgL[nLin,8])+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,9]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,10]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,11]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,12]+ '</font></td>'
		cMsg += '<td width="14%"><font size="2">' +aMsgL[nLin,13]+ '</font></td>'		
		cMsg += '</tr>'
		cMsg += '</table>'
	EndIf	
Next 

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definição dos totais e diferenças³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<td width="16%">Itens Corretos</td>'
cMsg += '<td width="16%">Itens Div.Ganho</td>'
cMsg += '<td width="16%">Itens Div.Perda</td>'
cMsg += '<td width="20%">Itens Pendentes</td>'
cMsg += '<td width="16%">Total de Itens</td>'
cMsg += '<td width="16%">Endes.Contatos</td>'
cMsg += '</tr>'
cMsg += '</font></table>'
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'

cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'
cMsg += '<tr bgcolor="#B0E2FF">'
cMsg += '<td width="16%"><font size="2">' +cValToChar(nQtdOk)+ '</font></td>'
cMsg += '<td width="16%"><font size="2">' +cValToChar(nQtdDg)+ '</font></td>'
cMsg += '<td width="16%"><font size="2">' +cValToChar(nQtdDp)+ '</font></td>'
cMsg += '<td width="20%"><font size="2">' +cValToChar(nQtdPen)+ '</font></td>'
cMsg += '<td width="16%"><font size="2">' +cValToChar(nTotIte)+ '</font></td>'
cMsg += '<td width="16%"><font size="2">' +cValToChar(nQtdTot)+ '</font></td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'	

cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<td width="16%">Tt. Custo Ganho:                      </td>'
cMsg += '<td width="16%"><font size="2">' +Transform((nDifg),"@E 9,999,999.99")+ '</font></td>'
cMsg += '<td width="16%">Tt. Custo Perda:                             </td>'
cMsg += '<td width="16%"><font size="2">' +Transform((nDifp),"@E 9,999,999.99")+ '</font></td>'
cMsg += '<td width="18%">Diferença Perda/Ganho:                </td>'
cMsg += '<td width="18%"><font size="2">' +Transform((nDifpg),"@E 9,999,999.99")+'</font></td>'
cMsg += '</tr>'
cMsg += '</font></table>'
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
cMsg += '<tr>'
cMsg += '<td>===============================================================================================================</td>'
cMsg += '</tr>'
cMsg += '</font></table>'



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do rodape do email                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '<table width="100%" Align="Center" border="0">'
cMsg += '<tr align="center">'
cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(DIPINVREL.PRW)</td>'
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'
                 

If GetNewPar("ES_ATIVJOB",.T.)
	cEmail+=";"+AllTrim(cEmailBcc)
	u_UEnvMail(AllTrim(cEmail),cAssunto,nil,"",cFrom,"EMailIR(DIPINVREL.prw)",cMsg)
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense³
//³que somente ela recebeu aquele email, tornando o email mais personalizado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
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
	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	cAssunto;
	BODY    	cMsg;
	RESULT lResult
	
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
 */
Return(.T.)
