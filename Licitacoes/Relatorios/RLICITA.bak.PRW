#include "protheus.ch"                                                       
#include "rwmake.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

/*
_________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ RLicita  ¦ Autor ¦ Walter C Silva (DELTA     ¦ Data ¦ 08.03.21 ¦¦¦
¦¦¦----------+----------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Relatorio Especifico de Licitações					          ¦¦¦
¦¦+---------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
user function RLicita(aWork)

Private oReport
Private oSection
Private oSection1
Private oSection2
Private oBreak
Private nTamLin := 0
Private nTipoRel := 1
Private cWorkFlow  := ""  
Private cFilSA3    := ""        
Private cPerg      := "DIRL40"

//Tratamento para workflow
If ValType(aWork) <> 'A'
	cWorkFlow := "N"
Else
	cWorkFlow := aWork[1]
EndIf

If cWorkFlow == "S"                        
	ConOut("Preparando empresa - Inicio")
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "04" FUNNAME "DIPRL40" 
	ConOut("Preparando empresa - Fim")
EndIf

If cWorkFlow == "N"
	
	AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI
 	If !pergunte("DIRL40",.T.)
		  	Return Nil
	EndIf         
End
//XPVLIB    
//exibe um diálogo onde a execução de um processo pode ser monitorada através da régua de progressão.                               
nTipoRel := MV_PAR16
Processa({|| oReport := ReportDef(), oReport:PrintDialog()},"Imprimindo dados...")

return                                                    
/*
_________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+---------------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ REPORTDEF ¦ Autor ¦ Jorge Saavedra           ¦ Data ¦ 04.01.18 ¦¦¦
¦¦¦----------+----------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Monta a estrutura do relatório.                                ¦¦¦
¦¦+---------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/               
static function reportDef


//configura o relatório
oReport := TReport():new("RELCLI","RELATORIO " + IIF(nTipoRel == 1," ANALITICO"," SINTETICO") + " DE CONTRATOS - " + If(mv_par20 == 1,'EM ABERTO',iF(mv_par20 ==2,'ENCERRADOS','EM ABERTO e ENCERRADOS')) + ' - Periodo: ' + DTOC(mv_par01) + ' a ' + DTOC(mv_par02) ,"DIRL40",{|oReport| printReport(oReport)},"Relatório Contrato / Licitações")
nTipoRel := MV_PAR16
//oReport:SetPortrait(.T.)
oReport:SetLandscape(.T.) 	//orientação da página como paisagem
//oReport:nFontBody := 10 //tamanho da fonte padrão
oReport:setTotalInLine(.F.)
//oReport:showHeader()
//If nTipoRel == 2 //Analitico
	//cria uma seção   
	oSection := TRSection():new(oReport,"Relatório Contratos - Licitações",{"TRB"})//importante descrever as tabelas utilizadas
	oReport:setTotalInLine(.F.)
	
	TRCell():new(oSection, "CLIENTE",,"")
	oSection:cell("CLIENTE"):disable()
	
	//define as colunas com o campo da tabela, tabela e cabeçalho que estará na planilha
	TRCell():new(oSection, "UA1_CODIGO" , "UA1", "EDITAL",PesqPict("UA1","UA1_CODIGO"),TamSX3("UA1_CODIGO")[1]+10,.F.,) 
	TRCell():new(oSection, "UA1_NRCONC" , "UA1", "PREGÃO",PesqPict("UA1","UA1_NRCONC"),TamSX3("UA1_NRCONC")[1]+10,.F.,) 
	TRCell():new(oSection, "UA1_TIPO", "UA1", "TIPO DO PREGÃO",PesqPict("UA1","UA1_TIPO"),TamSX3("UA1_TIPO")[1]+30,.F.,) 
	TRCell():new(oSection, "UA1_DENCER" , "UA1", "DT. ASSIN.",PesqPict("UA1","UA1_DENCER"),TamSX3("UA1_DENCER")[1]+10,.F.,) 
	TRCell():new(oSection, "UA1_VCONTR" , "UA1", "VALIDADE",PesqPict("UA1","UA1_VCONTR"),TamSX3("UA1_VCONTR")[1]+10,.F.,) 
	TRCell():new(oSection, "A1_NOME" , "SA1", "CLIENTE",PesqPict("SA1","A1_NOME"),TamSX3("A1_NOME")[1]+30,.F.,) 
	TRCell():new(oSection, "A3_NREDUZ", "SA3", "VENDEDOR",PesqPict("SA3","A3_NREDUZ"),TamSX3("A3_NREDUZ")[1]+50,.F.,) 
/*
	TRCell():new(oSection, "TOTAL"      , "UA4", "Valor Total",PesqPict("UA4","UA4_PRCVEN"),TamSX3("UA4_PRCVEN")[1],.F.,)
	   oBreak := TRBreak():New(oSection,oSection:Cell("TOTAL"),"Total Geral")
     TRFunction():New(oSection:Cell("TOTAL"),"Total","SUM",oBreak,,,,.F.,.F.)
*/
	oSection:SetHeaderPage()

//End	
oReport:setTotalInLine(.F.)
If nTipoRel == 2 //Analitico                                
	oSection1 := TRSection():new(oSection,"Detalhe Licitação",{"TRB"})//importante descrever as tabelas utilizadas

	TRCell():new(oSection1, "UA4_PRODUT" , "UA4", "Produto",PesqPict("UA4","UA4_PRODUT"),TamSX3("UA4_PRODUT")[1]+10,.F.,)  
	TRCell():new(oSection1, "B1_DESC" , "SB1", "Descrição Produto",PesqPict("SB1","B1_DESC"),TamSX3("B1_DESC")[1]+50,.F.,) 
	TRCell():new(oSection1, "UA4_QUANT"  , "UA4", "Qtd. Vendida",PesqPict("UA4","UA4_QUANT"),TamSX3("UA4_QUANT")[1]+20,.F.,) 
	TRCell():new(oSection1, "UA4_QTDENT" , "UA4", "Qtd. Entregue",PesqPict("UA4","UA4_QTDENT"),TamSX3("UA4_QTDENT")[1]+20,.F.,) 
	TRCell():new(oSection1, "UA4_XSALAD" , "UA4", "Sal. Add.",PesqPict("UA4","UA4_XSALAD"),TamSX3("UA4_XSALAD")[1]+20,.F.,) 
	TRCell():new(oSection1, "SALDO"      , "UA4", "Saldo.",PesqPict("UA4","UA4_XSALAD"),TamSX3("UA4_XSALAD")[1]+20,.F.,) 
	TRCell():new(oSection1, "UA4_PRCVEN" , "UA4", "Valor Unitario",PesqPict("UA4","UA4_PRCVEN"),TamSX3("UA4_PRCVEN")[1]+20,.F.,) 
	TRCell():new(oSection1, "TOTAL"      , "UA4", "Valor Total",PesqPict("UA4","UA4_PRCVEN"),TamSX3("UA4_PRCVEN")[1]+20,.F.,)

     oBreak := TRBreak():New(oSection1,oSection1:Cell("TOTAL"),"Total Edital " )
     TRFunction():New(oSection1:Cell("TOTAL"),"Total","SUM",oBreak,,,,.F.,.F.)

	oSection1:SetHeaderPage()

	If mv_par21 == 1  //Mostra Pedidos de Vendas

		oSection2 := TRSection():new(oSection1,"Pedidos de Vendas",{"TRB"})//importante descrever as tabelas utilizadas

		TRCell():new(oSection2, "C6_NUM" , "SC6", "Pedido",PesqPict("SC6","C6_NUM"),TamSX3("C6_NUM")[1]+10,.F.,) 
		TRCell():new(oSection2, "C6_PRODUTO" , "SC6", "Produto",PesqPict("SC6","C6_PRODUTO"),TamSX3("C6_PRODUTO")[1]+10,.F.,) 
		TRCell():new(oSection2, "B1_DESC" , "SB1", "Descrição Produto",PesqPict("SC6","B1_DESC"),TamSX3("B1_DESC")[1]+50,.F.,) 
		TRCell():new(oSection2, "C6_QTDVEN"  , "SC6", "Qtd. Vendida",PesqPict("SC6","C6_QTDVEN"),TamSX3("C6_QTDVEN")[1]+20,.F.,) 
		TRCell():new(oSection2, "C6_VALOR" , "SC6", "Total Item",PesqPict("SC6","C6_VALOR"),TamSX3("C6_VALOR")[1]+20,.F.,) 
		TRCell():new(oSection2, "C6_NOTA" , "SC6", "Nota Fiscal",PesqPict("SC6","C6_NOTA"),TamSX3("C6_NOTA")[1]+20,.F.,) 
		//	TRCell():new(oSection2, "C6_DATFAT" , "SC6", "Data Fatura",PesqPict("SC6","C6_DATFAT"),TamSX3("C6_DATFAT")[1]+20,.F.,) 

		//     oBreak := TRBreak():New(oSection2,oSection2:Cell("C6_VALOR"),"Total Pedido " )
		//     TRFunction():New(oSection2:Cell("C6_VALOR"),"Total Pedido","SUM",oBreak,,,,.F.,.F.)

		oSection2:SetHeaderPage()
	End
End
/*
if(nTipoRel == 1)
	nTamLin := 9+ TamSX3("C6_PRODUTO")[1] + TamSX3("C6_QTDVEN")[1]+ TamSX3("C6_PRCVEN")[1] + TamSX3("C6_X_PESOL")[1] + TamSX3("C6_QTDENT")[1]+ TamSX3("C6_QTDLIB2")[1]+ TamSX3("C6_X_OBS")[1]// + TamSX3("D1_UM")[1] + TamSX3("B1_ESPECIF")[1] + TamSX3("B1_PESO")[1] + TamSX3("D1_PESO")[1] + TamSX3("D1_VUNIT")[1] + TamSX3("D1_TOTAL")[1] + TamSX3("D2_PRCVEN")[1] + TamSX3("D2_PRUNIT")[1]
else
	nTamLin :=TamSX3("C6_FILIAL")[1]-60+TamSX3("B1_DESC")[1]+ TamSX3("C6_PRODUTO")[1] + TamSX3("C6_QTDVEN")[1] + TamSX3("C6_X_PESOL")[1] + TamSX3("C6_QTDENT")[1]+ TamSX3("C6_QTDLIB2")[1]+ TamSX3("C6_X_OBS")[1]// + TamSX3("D1_UM")[1] + TamSX3("B1_ESPECIF")[1] + TamSX3("B1_PESO")[1] + TamSX3("D1_PESO")[1] + TamSX3("D1_VUNIT")[1] + TamSX3("D1_TOTAL")[1] + TamSX3("D2_PRCVEN")[1] + TamSX3("D2_PRUNIT")[1]
end
*/
return oReport


/*
___________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PRINTREPORT ¦ Autor ¦ Renan Ramos              ¦ Data ¦ 25.01.16 ¦¦¦
¦¦¦----------+------------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦ Realiza a impressão do relatório.                                ¦¦¦
¦¦+-----------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
static function printReport()
    
QRY1 := " SELECT DISTINCT B1_DESC,UA1_DVALID,UA4_PRCVEN,A3_NREDUZ,A1_NOME,A1_SALDUP,UA1_VCONTR,UA1_VCONT2,UA1_TIPO,UA1_NRCONC,A1_GRPVEN,B1_FILIAL,A3_FILIAL,A1_FILIAL,UA4_FILIAL,UA1_FILIAL,UA1_STATUS,UA4_QTDENT,  "
QRY1 += " UA4_QUANT, UA1_TPVALI, "
QRY1 += " UA4_XSALAD,UA4_SALDO,UA4_VENCEU,A3_COD,UA1_VEND,B1_COD,UA4_PRODUT,UA1_DENCER,UA1_CODCLI,UA1_ASSCON,UA1_VEND,UA1_CODCLI,A1_COD,UA1_LOJA,A1_LOJA,UA1_VEND,A3_COD,UA1_CODIGO,A3_COD,UA1_CODIGO,UA4_EDITAL,UA4_PRODUT,B1_PROC "
QRY1 += " ,(((UA4_QUANT+UA4_XSALAD)-UA4_QTDENT)*UA4_PRCVEN) AS TOTAL "
If mv_par21 == 1 //INCLUI PV = SIM
	QRY1 += " ,C6_PRODUTO, C6_NUM, C6_QTDVEN, C6_VALOR, UA4_ITEM, C6_ITEM, C6_NOTA, C6_DATFAT "
End
QRY1 += " FROM " +RetSQLName("UA1")+" "
QRY1 += " INNER JOIN  "+RetSQLName("UA4")+" "
QRY1 += " INNER JOIN  "+RetSQLName("SA1")+" "
QRY1 += " INNER JOIN  "+RetSQLName("SA3")+" "
QRY1 += " INNER JOIN  "+RetSQLName("SB1") 
If mv_par21 == 1 //INCLUI PV = SIM
	QRY1 += " 	, "+ RetSQLName("SC6") + ", "+ RetSQLName("SC5")
End
If mv_par21 == 2 //INCLUI PV = NÃO
	QRY1 += " WHERE UA1_DENCER BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"
	If MV_PAR09 <> '' .OR. MV_PAR10 <> ''
		QRY1 += " AND UA1_CODCLI BETWEEN   '"+MV_PAR09+"'       AND '"+MV_PAR10+"'"
	End
	QRY1 += " AND UA1_ASSCON BETWEEN   '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'"
	QRY1 += " AND UA1_VEND   BETWEEN   '"+MV_PAR05+"'       AND '"+MV_PAR06+"'"
	QRY1 += " AND UA1_CODCLI = A1_COD"
	QRY1 += " AND UA1_LOJA = A1_LOJA"
	QRY1 += " AND UA1_VEND = A3_COD"
	QRY1 += " AND UA1_CODIGO = UA4_EDITAL"     
	If MV_PAR18 <> '' .OR. MV_PAR19 <> ''
		QRY1 += " AND UA1_CODIGO BETWEEN   '"+MV_PAR18+"' AND '"+MV_PAR19+"'"
	End	
	QRY1 += " AND UA4_PRODUT BETWEEN   '"+MV_PAR11+"' AND '"+MV_PAR12+"'"     
	QRY1 += " AND UA4_PRODUT = B1_COD"
	QRY1 += " AND UA1_VEND   = A3_COD"                                                                        
	QRY1 += " AND UA4_VENCEU = '1'"
	if mv_par20 == 1
		QRY1 += " AND UA1_STATUS = '7' " //Giovani Zago 03/10/11  
	elseIf  mv_par20 == 2	
		QRY1 += " AND UA1_STATUS = '8' " 
	else  //AMBOS
		QRY1 += " AND (UA1_STATUS = '7' OR UA1_STATUS = '8') " 
	end
Else      //INCLUI PV = SIM

	QRY1 += " WHERE C5_EDITAL BETWEEN   '"+MV_PAR18+"' AND '"+MV_PAR19+"'"
	QRY1 += " 	AND A1_COD    BETWEEN    '"+MV_PAR09+"'       AND '"+MV_PAR10+"'"
	QRY1 += " 	AND A1_VEND   BETWEEN    '"+MV_PAR05+"'       AND '"+MV_PAR06+"'"
 	QRY1 += "         AND A1_VEND = A3_COD 
	QRY1 += "         AND A1_COD = C5_CLIENTE
	QRY1 += "         AND A1_LOJA = C5_LOJACLI
	QRY1 += "         AND C6_PRODUTO BETWEEN  '"+MV_PAR11+"' AND '"+MV_PAR12+"'"     
	QRY1 += "         AND C6_PRODUTO = B1_COD   
	QRY1 += "         AND B1_COD = C6_PRODUTO
	QRY1 += "         AND C6_NUM = C5_NUM 
	QRY1 += "        AND C5_EDITAL *= UA4_EDITAL
	QRY1 += "        AND C5_EDITAL *= UA1_CODIGO

End

QRY1 += " AND B1_PROC    BETWEEN   '"+MV_PAR07+"' AND '"+MV_PAR08+"'"     
QRY1 += " AND A1_GRPVEN BETWEEN   '"+MV_PAR13+"' AND '"+MV_PAR14+"'" 
QRY1 += " AND UA1_FILIAL = '"+xFilial('UA1')+"'"
QRY1 += " AND UA4_FILIAL = '"+xFilial('UA4')+"'"
QRY1 += " AND A1_FILIAL  = '"+xFilial('SA1')+"'"
QRY1 += " AND A3_FILIAL  = '"+xFilial('SA3')+"'"
QRY1 += " AND B1_FILIAL  = '"+xFilial('SB1')+"'"
QRY1 += " AND " + RetSQLName("UA1") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("UA4") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = ''"

If mv_par21 == 1 //INCLUI PV = SIM
	QRY1 += " AND " + RetSQLName("SC6") + ".D_E_L_E_T_ = ''"
	QRY1 += " AND " + RetSQLName("SC5") + ".D_E_L_E_T_ = ''"
End

//QRY1 += " ORDER BY UA1_VEND, UA1_CODCLI, UA1_LOJA, UA1_DENCER, UA1_CODIGO, UA4_ITEM"
memowrite('RLICITA.SQL',QRY1)
cQuery := ChangeQuery(QRY1)
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY1), 'QRY1', .F., .T.)


oReport:setMeter(QRY1->(recCount()))

QRY1->(dbGoTop())
_nTotal:=0
while !QRY1->(eof())                                  
	oSection:init()    
	oSection:cell("UA1_CODIGO"):setValue(QRY1->UA1_CODIGO)
	oSection:cell("UA1_NRCONC"):setValue(QRY1->UA1_NRCONC)

 	_cPregao:=If(QRY1->UA1_TIPO = "1","Pregao Presencial",;
						  If(QRY1->UA1_TIPO = "2","Pregao Eletronico",;
						  If(QRY1->UA1_TIPO = "3","Tomada de Precos" ,;
  						  If(QRY1->UA1_TIPO = "4","Convite"          ,;
  						  If(QRY1->UA1_TIPO = "5","Registro de Precos","BEC")))))  		

	oSection:cell("UA1_TIPO"):setValue(_cPregao)
	oSection:cell("UA1_DENCER"):setValue(stod(QRY1->UA1_DENCER))	
	if !Empty(QRY1->UA1_VCONTR)
		oSection:cell("UA1_VCONTR"):setValue(stod(QRY1->UA1_VCONTR))
	Else
		oSection:cell("UA1_VCONTR"):setValue(If(!Empty(QRY1->UA1_VCONT2),QRY1->UA1_VCONT2+"  "+(If(QRY1->UA1_TPVALI="D","dias",If(QRY1->UA1_TPVALI="M","meses","Anos")))," "))
	End
	oSection:cell("A1_NOME"):setValue( QRY1->UA1_CODCLI+" - "+QRY1->UA1_LOJA+' - '+Alltrim(QRY1->A1_NOME))
	oSection:cell("A3_NREDUZ"):setValue(QRY1->UA1_VEND+' - '+Alltrim(QRY1->A3_NREDUZ))  
	oSection:printLine()

	If nTipoRel == 2 //Sintetico                                 

	    _cEdital := QRY1->UA1_CODIGO
		While QRY1->(!EOF()) .AND. QRY1->UA1_CODIGO == _cEdital

			oSection1:init()                           
			oSection1:cell("UA4_PRODUT"):setValue(SUBSTR(QRY1->UA4_PRODUT,1,6))
			oSection1:cell("B1_DESC"):setValue(QRY1->B1_DESC)
			oSection1:cell("UA4_QUANT"):setValue(QRY1->UA4_QUANT)
			oSection1:cell("UA4_QTDENT"):setValue(QRY1->UA4_QTDENT)        
			oSection1:cell("UA4_XSALAD"):setValue(QRY1->UA4_XSALAD)       	
			oSection1:cell("SALDO"):setValue(((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)  	)                                   
			oSection1:cell("UA4_PRCVEN"):setValue(QRY1->UA4_PRCVEN )    
			oSection1:cell("TOTAL"):setValue(QRY1->TOTAL)    				   	
				
			_nTotal += QRY1->TOTAL
			oSection1:printLine()                              

	
			If mv_par21 == 1   //Mostra Pedido de Vendas

			    oSection2:init()                           
		   		_cPedido := QRY1->C6_NUM
		   	    _cItem   := QRY1->C6_ITEM
		   	    _nTotalPV :=0
		   		While QRY1->(!EOF()) .and. QRY1->(C6_NUM+C6_ITEM) == _cPedido+_cItem

					oSection2:cell("C6_NUM"):setValue(QRY1->C6_NUM)
					oSection2:cell("C6_PRODUTO"):setValue(QRY1->C6_PRODUTO)        
					oSection2:cell("B1_DESC"):setValue(Posicione('SB1',1,xFilial('SB1')+QRY1->C6_PRODUTO,'B1_DESC'))      	
					oSection2:cell("C6_QTDVEN"):setValue(QRY1->C6_QTDVEN)
					oSection2:cell("C6_VALOR"):setValue(QRY1->C6_VALOR)
					oSection2:cell("C6_NOTA"):setValue(QRY1->C6_NOTA)
			//		oSection2:cell("C6_DATFAT"):setValue(QRY1->C6_DATFAT)

					_nTotalPV += QRY1->C6_VALOR
					oSection2:printLine()                              
					oSection2:finish()
					oReport:incMeter()      

					QRY1->(dbSkip())
		   		End
	        Else
				QRY1->(dbSkip())
			End
		End
/*
		    nRow := oReport:Row()
			oReport:PrintText(Replicate("_",nTamLin), nRow, 10) 
			oReport:SkipLine()
			oSection2:PrintLine()
			oSection2:finish()
*/
			oSection1:finish()

		Else
			QRY1->(dbSkip())
		End	
endDo

oSection:finish()


/*
	If nTipoRel == 2 //Sintetico                                 
		oSection:cell("TOTAL"):setValue(_nTotal)    				   	
	End	
*/

//END                  
QRY1->(dbCloseArea())

return 







/////////////////////////////////////////////////////////////////////////////
//
Static Function AjustaSX1(cPerg)
Local i, j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Encerramento de         ?","","","mv_ch1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Encerramento Até        ?","","","mv_ch2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Assinatura de         ?","","","mv_ch3","D",8,0,0,"G","","MV_PAR03","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Assinatura Até        ?","","","mv_ch4","D",8,0,0,"G","","MV_PAR04","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Vendedor De        ?","","","mv_ch4","C",6,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"06","Vendedor Até       ?","","","mv_ch5","C",6,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"07","Fornecedor De      ?","","","mv_ch6","C",6,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
AADD(aRegs,{cPerg,"08","Fornecedor Até     ?","","","mv_ch7","C",6,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
AADD(aRegs,{cPerg,"09","Cliente De         ?","","","mv_ch8","C",6,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
AADD(aRegs,{cPerg,"10","Cliente Até        ?","","","mv_ch9","C",6,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
AADD(aRegs,{cPerg,"11","Produto De         ?","","","mv_cha","C",6,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","",'SB1'})
AADD(aRegs,{cPerg,"12","Produto Até        ?","","","mv_chb","C",6,0,0,"G","","MV_PAR12","","","","","","","","","","","","","","","","","","","","","","","","",'SB1'})
AADD(aRegs,{cPerg,"13","Grupo de Clientes de?","","","mv_chc","C",6,0,0,"G","","MV_PAR13","","","","","","","","","","","","","","","","","","","","","","","","",'ACY'})
AADD(aRegs,{cPerg,"14","Grupo de Clientes até?","","","mv_chd","C",6,0,0,"G","","MV_PAR14","","","","","","","","","","","","","","","","","","","","","","","","",'ACY'})
AADD(aRegs,{cPerg,"15","Envia E-mail       ?","","","mv_che","N",1,0,1,"C","","MV_PAR15","Sim","","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"16","Sintético/Analítico?","","","mv_chf","N",1,0,1,"C","","MV_PAR16","Sintético","","","","","Analítico","","","","","","","",""})
AADD(aRegs,{cPerg,"17","Gera Arquivo       ?","","","mv_chg","N",1,0,1,"C","","MV_PAR17","Sim","","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"18","Edita De	       ?","","","mv_chh","C",6,0,0,"G","","MV_PAR18","","","","","","","","","","","","","","","","","","","","","","","","",'UA1'})
AADD(aRegs,{cPerg,"19","Edital até		   ?","","","mv_chi","C",6,0,0,"G","","MV_PAR19","","","","","","","","","","","","","","","","","","","","","","","","",'UA1'})
AADD(aRegs,{cPerg,"20","Status 			   ?","","","mv_chj","N",1,0,1,"C","","MV_PAR20","Aberto","","","","","Encerrado","","","","","Ambos","","",""})
AADD(aRegs,{cPerg,"21","Mostra Pedidos Vendas?","","","mv_chk","N",1,0,1,"C","","MV_PAR21","Sim","","","","","Não","","","","","","","",""})

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
