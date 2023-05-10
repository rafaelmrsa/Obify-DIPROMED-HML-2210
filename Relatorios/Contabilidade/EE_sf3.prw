/* Eriberto Elias 14/02/09 para substituir os Nmarcas e Nresumo */
#include "Protheus.ch"
#include "RwMake.ch"
#include "vKey.ch"
#include "colors.ch"
#include "topconn.ch"
#INCLUDE "FileIO.ch"

#xcommand TCQUERY <sql_expr> [ALIAS <a>] [<new: NEW>] [SERVER <(server)>] [ENVIRONMENT <(environment)>] => dbUseArea(<.new.>,"TOPCONN",TCGENQRY(<(server)>,<(environment)>,<sql_expr>),<(a)>, .F., .T.)

User Function EE_sf3()
Local _xArea := GetArea()    

Local oDlg
Local nOpcao := 0

Local bOK    := {|| nOpcao := 1, oDlg:End()}
Local bCancel:= {|| nOpcao := 0, oDlg:End()}
Local aItens := {}
Private cPerg	:= "EE_SF3"
Private nRadio := 0
Private cUserAut := GetMV("MV_URELCON")
Private _cUserel  := U_DipUsr() 

aAdd(aItens,"Marca     ")
aAdd(aItens,"Corrige   ")
aAdd(aItens,"Resumo    ")
aAdd(aItens,"Confirma  ")

If 1=2
	//MSGSTOP("Pense no TS 532!"+chr(13)+chr(13)+"Ajustar programa para limpar as marcas"+chr(13)+chr(13)+"Criar seguranca para nao fazer 2 vezes o confirma "+chr(13)+chr(13)+"Rever EE_020, boa parte fazer aqui","Eriberto",)
	//MSGSTOP("PROCURE NO RDMAKE 'AQUI' LÝ ESTÝ A EXPLICAÇÃO DO AJUSTE","ERIBERTO")
	MSGSTOP("ajuste a query do PIS e da COFINS, para usar campo apropriado","ERIBERTO")
	RestArea(_xArea)
	//Return
EndIf

//If Upper(U_DipUsr()) <> 'ASANTOS'  	.AND.;  
//   Upper(U_DipUsr()) <> 'MCANUTO'  	.AND.;
//   Upper(U_DipUsr()) <> 'DDOMINGOS'	.AND.;
//   Upper(U_DipUsr()) <> 'MTEIXEIRA'	.AND.;
//   Upper(U_DipUsr()) <> 'RBORGES'  	.AND.;
//   Upper(U_DipUsr()) <> 'RLOPES'  	.AND.;
//   Upper(U_DipUsr()) <> 'MSANTOS'  	.AND.;
//   Upper(U_DipUsr()) <> 'SCREATTO'

If !Upper (_cUserel) $ cUserAut  //Ajuste realizado para utilizar o parametro ES_URELCON
	MSGSTOP("Usuário sem direito de acesso.","Atenção",)
	RestArea(_xArea)
	Return
EndIf

//ValidPerg()             // Verifica perguntas. Se nao existe INCLUI
SX1->(DipPergDiverg(.f.))

Pergunte(cPerg,.T.)  // Solicita parametro
Set Key VK_F12 TO perEE_SF3() // F12 Para redefinir parametros

If !MsgBox("Já fez o reprocessamento de: "+mv_par01+"?","Atencao","YESNO")
	MSGSTOP("Então faça.","Há é!")
	RestArea(_xArea)
	Return
EndIf

Do While .t.
	
	nRadio := 3
	nOpcao := 0
	
	Define msDialog oDlg Title "ICMS" From 00,00 TO 16,44
	
	@ 018,020 RADIO aItens VAR nRadio
	@ 103,001 to 119,174
	@ 110,006 say "F12 - Redefine parametros" COLOR CLR_RED
	
	Activate Dialog oDlg Centered on init EnchoiceBar(oDlg,bOk,bCancel)
	
	Do Case
		Case nOpcao == 0
			Exit
		Case nRadio == 1
			//Processa({|lEnd| lRetorno := EEMARCA()},"Marcando...")
		Case nRadio == 2
			//Processa({|lEnd| lRetorno := EECORRIGE()},"Corrigindo...")
		Case nRadio == 3
			EERESUMO()
		Case nRadio == 4
			//Processa({|lEnd| lRetorno := EECONFIRMA()},"Confirmando...")
	EndCase
EndDo

Set Key VK_F12 TO  // Limpa F12 para redefinir parametros

RestArea(_xArea)
Return
/*fim do EE_sf3*/

///////////////////////////
//Static Function ValidPerg()
Static Function DipPergDiverg(lLer)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO), " ")

aRegs:={}
//-----------Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{"EE_SF3","01","Mês/Ano ?","","","mv_ch1","C",7,0,0,"G","!Empty(MV_PAR01)","mv_par01","","","","99/9999","","","","","","","","","","","","","","","","","","","","","",""})
For i:=1 to Len(aRegs)
	If !dbSeek(CPERG+aRegs[i,2])
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
/*fim ValidPerg*/
///////////////////////////
Static Function perEE_SF3()
Pergunte("EE_SF3",.T.)  // Solicita parametro
Return .t.
/*fim perEE_SF3*/
/////////////////////////
Static Function EEMARCA()
Local QRY1
Local lReturn := .f.

If MsgBox("Marca os Xs?","Atencao","YESNO")
	
	ProcRegua(2500)
	For _x := 1 to 500
		IncProc( "Limpando marca XX XV XC...")
	Next
	/*
	BEGIN TRANSACTION
	UPDATE SF3010
	SET F3_EE = ''
	from SF3010 F3
	where F3.D_E_L_E_T_ = ' '
	and left(F3_ENTRADA,6) = '200901'
	and F3_FILIAL in ('04','XX','XV','XC')
	and F3_EE <> SPACE(2)
	COMMIT TRANSACTION
	*/
	
	// voltar aqui para fazer a limpeza
	
	
	/*
	select F3.F3_NFISCAL, F3.R_E_C_N_O_
	from SA1010 A1, SF3010 F3
	where F3.D_E_L_E_T_ <> '*'
	and A1.D_E_L_E_T_ <> '*'
	and A1_EE <> ' '
	and A1_COD = F3_CLIEFOR
	and A1_LOJA = F3_LOJA
	and left(F3_ENTRADA,6) = '200901'
	and F3_FILIAL in ('04','xa')
	and (F3_CFO > '5' or F3_TIPO in ('d','b')) -- elimina as compras
	*/
	
	For _x := 1 to 500
		IncProc( "Processando...X ")
	Next
/*	testando sem X
	QRY1 := "SELECT F3.F3_NFISCAL, F3.R_E_C_N_O_"
	QRY1 += " FROM " + RetSQLName("SA1")+' A1, '+ RetSQLName("SF3")+' F3'
	QRY1 += " WHERE A1.D_E_L_E_T_ = ' '"
	QRY1 += " AND F3.D_E_L_E_T_ = ' '"
	QRY1 += " AND A1_EE <> ' '"
	QRY1 += " AND A1_COD = F3_CLIEFOR"
	QRY1 += " AND A1_LOJA = F3_LOJA"
	QRY1 += " AND LEFT(F3_ENTRADA,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
	QRY1 += " AND F3_FILIAL = '"+xFILIAL("SF3") + "'"
	// AQUI ESTÝ ERRADO, NÃO MARCOU AS NOTAS DE ENTRADAS DOS X, VEJA A QUERY QUE USO PARA ALTERAR O CÓDIGO DO CLIENTE.
	QRY1 += " AND (F3_CFO > '5' OR F3_TIPO in ('D','B'))" // ELIMINA COMPRAS, CUJOS FORNECEDORES TEM CODIGO IGUAL AOS CLIENTES X
	// Processa Query SQL
	TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query
	DbSelectArea("QRY1")
	QRY1->(dbGotop())
	
	Do While !QRY1->(Eof())
		SF3->(DbGoTo(QRY1->R_E_C_N_O_))
		IncProc( "Marcando X -> " + QRY1->F3_NFISCAL)
		RecLock("SF3",.F.)
		SF3->F3_EE := "XX"
		SF3->(MsUnlock())
		QRY1->(DbSkip())
	EndDo
	
	QRY1->(DbCloseArea())
*/
	lReturn := .T.
EndIf
If lReturn
	lReturn := .F.
	If MsgBox("Marquei os Xs, continuo?","Atencao","YESNO")
		For _x := 1 to 500
			IncProc( "Processando...V ")
		Next
		
		/*
		select F3_NFISCAL, F3.R_E_C_N_O_
		from SF3010 F3
		where F3.D_E_L_E_T_ = ' '
		AND EXISTS
		(select sum(F3_VALICM)
		from SF3010 F3A, SA1010 A1
		where F3A.D_E_L_E_T_ = ' '
		and A1.D_E_L_E_T_ = ' '
		and F3_CLIEFOR = A1_COD
		and F3_LOJA = A1_LOJA
		and A1_EE = ' '
		and (A1_INSCR like '%ISEN%' or A1_INSCR = SPACE(18))
		and left(F3_ENTRADA,6) = '200901'
		and F3_FILIAL in ('04')
		and left(F3_CFO,2) = '51'
		
		AND F3A.F3_NFISCAL = F3.F3_NFISCAL
		AND F3A.F3_SERIE = F3.F3_SERIE
		AND F3A.F3_CLIEFOR = F3.F3_CLIEFOR
		AND F3A.F3_LOJA = F3.F3_LOJA
		AND F3A.F3_CFO = F3.F3_CFO
		AND F3A.F3_ENTRADA = F3.F3_ENTRADA
		group by F3_NFISCAL
		HAVING SUM(F3_VALICM) > 0)
		*/
		
		QRY1 := "SELECT F3.F3_NFISCAL, F3.R_E_C_N_O_"
		QRY1 += " FROM "+ RetSQLName("SF3")+' F3'
		QRY1 += " WHERE F3.D_E_L_E_T_ = ' '" 
		QRY1 += " AND F3_FILIAL = '"+xFILIAL("SF3") + "'"
		QRY1 += " AND EXISTS"
		QRY1 += " (select sum(F3_VALICM)"
		QRY1 += " from SF3010 F3A, SA1010 A1"
		QRY1 += " where F3A.D_E_L_E_T_ = ' '"
		QRY1 += " and A1.D_E_L_E_T_ = ' '"
		QRY1 += " and F3_CLIEFOR = A1_COD"
		QRY1 += " and F3_LOJA = A1_LOJA"
		QRY1 += " and A1_EE = ' '"
		QRY1 += " and (A1_INSCR like '%ISEN%' or A1_INSCR = SPACE(18))"
		QRY1 += " and left(F3_ENTRADA,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
		
		
        //and A1_SATIV1 NOT in ('1.1.01','1.2.08') --('1.1.04','3.1.11','3.1.19','3.1.21','3.1.22','1.1.01')
        
        		
		QRY1 += " and F3_FILIAL = '"+xFILIAL("SF3") + "'"
		QRY1 += " and left(F3_CFO,2) in ('51','54')"
		QRY1 += " and F3A.F3_NFISCAL = F3.F3_NFISCAL"
		QRY1 += " and F3A.F3_SERIE = F3.F3_SERIE"
		QRY1 += " and F3A.F3_CLIEFOR = F3.F3_CLIEFOR"
		QRY1 += " and F3A.F3_LOJA = F3.F3_LOJA"
		QRY1 += " and F3A.F3_CFO = F3.F3_CFO"
		QRY1 += " and F3A.F3_ENTRADA = F3.F3_ENTRADA"
		QRY1 += " group by F3_NFISCAL"
		QRY1 += " HAVING SUM(F3_VALICM) > 0)"  
		
		
		// Processa Query SQL
		TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query
		DbSelectArea("QRY1")
		QRY1->(dbGotop())
		
		Do While !QRY1->(Eof())
			SF3->(DbGoTo(QRY1->R_E_C_N_O_))
			IncProc( "Marcando V -> " + QRY1->F3_NFISCAL)
			RecLock("SF3",.F.)
			SF3->F3_EE := "XV"
			SF3->(MsUnlock())
			QRY1->(DbSkip())
		EndDo
		QRY1->(DbCloseArea())
		lReturn := .T.
	EndIf // Marcou Xs
EndIf // lReturn
If lReturn
	lReturn := .F.
	If MsgBox("Marquei as Vs, continuo?","Atencao","YESNO")
		For _x := 1 to 500
			IncProc( "Processando...E ")
		Next
		
		//-	IncProc( "Marcando E -> " + QRY1->F3_NFISCAL)
		lReturn := .t.
	EndIf // Marcou Xv
EndIf // lReturn
If lReturn
If MsgBox("Vamos corrigir?","Atencao","YESNO")
	EECORRIGE()
EndIf
EndIf
Return(lReturn)
/*fim EEMARCA*/
///////////////////////////
Static Function EECORRIGE()
Local nOpcao := 0
Private nMetaV := nMetaC := 0

@ 150,000 To 525,400 DIALOG oDlg TITLE OemToAnsi("Vamos corrigir até valor ideal")

@ 008,010 Say "Informe as metas:"
@ 008,120 Say MV_PAR01 Size 33,30
@ 028,010 Say "Meta para debito:"
@ 028,120 Get nMetaV Size 45,40 Valid nMetaV>=0 Picture "@E 999,999,999.99"
@ 045,010 Say "Meta para credito:"
@ 045,120 Get nMetaC Size 45,40 Valid nMetaC>=0 Picture "@E 999,999,999.99"

@ 170,100 BMPBUTTON TYPE 1 ACTION (nOpcao := 1,Close(oDlg))
@ 170,140 BMPBUTTON TYPE 2 ACTION Close(oDlg)

ACTIVATE DIALOG oDlg Centered

If nOpcao = 1
	(EEAtingeM(nMetaV,nMetaC))
EndIf

Return
/*fim EECORRIGE*/
//////////////////////////
Static Function EEAtingeM(nMetaV,nMetaC)
Local _xArea := GetArea()
Local nFalta := 0
Local QRY1
Local QRY2
Local lReturn := .T.
Local aJaUsado:= {}
Local cDia    := ''
Local cUltDia := ''
Local cNota   := ''
Local nControle := 0
Local nProcessados := 0

ProcRegua(2500)
For _x := 1 to 300
	IncProc( "Processando...XV ")
Next

/*
select ROUND(SUM((CASE WHEN left(F3_CFO,1) >= '5' and F3_EE = '  ' THEN F3_VALICM ELSE 0 END)),2) AS ICMSVEN,
ROUND(SUM((CASE WHEN left(F3_CFO,1) <  '5' and F3_EE = '  ' THEN F3_VALICM ELSE 0 END)),2) AS ICMSCOM,
ROUND(SUM((CASE WHEN F3_EE = 'XV' THEN F3_VALICM ELSE 0 END)),2) AS ICMSXV
from SF3010 F3
where F3.D_E_L_E_T_ <> '*'
and F3_DTCANC = SPACE(8)
and left(F3_ENTRADA,6) = '200901'
and F3_FILIAL in ('04')
*/
QRY1 := "select ROUND(SUM((CASE WHEN left(F3_CFO,1) >= '5' and F3_EE = '  ' THEN F3_VALICM ELSE 0 END)),2) AS ICMSVEN,"
QRY1 += " ROUND(SUM((CASE WHEN left(F3_CFO,1) <  '5' and F3_EE = '  ' THEN F3_VALICM ELSE 0 END)),2) AS ICMSCOM,"
QRY1 += " ROUND(SUM((CASE WHEN F3_EE = 'XV' THEN F3_VALICM ELSE 0 END)),2) AS ICMSXV"
QRY1 += " FROM " +RetSQLName("SF3")+' F3'
QRY1 += " WHERE F3.D_E_L_E_T_ = ' '"
QRY1 += " AND F3_DTCANC = SPACE(8)"
QRY1 += " AND LEFT(F3_ENTRADA,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
QRY1 += " AND F3_FILIAL = '"+xFILIAL("SF3") + "'"
// Processa Query SQL
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query
/*
select F3_NFISCAL, F3_SERIE, R_E_C_N_O_, F3_VALICM, F3_EMISSAO,
(
select SUM(F3_VALICM)
from SF3010 F3A
where F3A.D_E_L_E_T_ = '*'
and F3.F3_FILIAL = F3A.F3_FILIAL
and F3.F3_NFISCAL = F3A.F3_NFISCAL
and F3.F3_SERIE = F3A.F3_SERIE
and F3.F3_CLIEFOR = F3A.F3_CLIEFOR
GROUP BY F3_NFISCAL, F3_SERIE
) ICMSTOT
from SF3010 F3
where F3.D_E_L_E_T_ = '*'
and F3_EE = 'XV'
and left(F3_ENTRADA,6) = '200901'
and F3_FILIAL in ('04')
ORDER BY F3_EMISSAO, ICMSTOT, F3_NFISCAL,F3_SERIE
*/
QRY2 := "SELECT F3_NFISCAL, F3_SERIE, R_E_C_N_O_, F3_VALICM, F3_EMISSAO,"
QRY2 += "(select SUM(F3_VALICM)"
QRY2 += " from SF3010 F3A"
QRY2 += " where F3A.D_E_L_E_T_ = ' '"
QRY2 += " and F3.F3_FILIAL = F3A.F3_FILIAL"
QRY2 += " and F3.F3_NFISCAL = F3A.F3_NFISCAL"
QRY2 += " and F3.F3_SERIE = F3A.F3_SERIE"
QRY2 += " and F3.F3_CLIEFOR = F3A.F3_CLIEFOR"
QRY2 += " GROUP BY F3_NFISCAL, F3_SERIE) ICMSTOT"
QRY2 += " FROM "+RetSQLName("SF3")+' F3'
QRY2 += " WHERE F3.D_E_L_E_T_ = ' '"
QRY2 += " AND F3_EE = 'XV'"
QRY2 += " AND LEFT(F3_ENTRADA,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
QRY2 += " AND F3_FILIAL = '"+xFILIAL("SF3") + "'"
QRY2 += " ORDER BY F3_EMISSAO, ICMSTOT, F3_NFISCAL,F3_SERIE"
// Processa Query SQL
TcQuery QRY2 NEW ALIAS "QRY2"         // Abre uma workarea com o resultado da query

//nMetaC
nFalta := nMetaV - QRY1->ICMSVEN

If QRY1->ICMSXV < nFalta
	lReturn := .F.
	MSGSTOP("O que falta é maior que as notas marcadas."+chr(13)+chr(13)+str(nfalta)+chr(13)+chr(13)+str(QRY1->ICMSXV),"Atenção!")
EndIf
If lReturn
	
	DbSelectArea("QRY2")
	QRY2->(dbGotop())
	Do While !QRY2->(Eof())
		IncProc( "Processando: "+QRY2->F3_NFISCAL)
		Aadd(aJaUsado,{QRY2->F3_NFISCAL, QRY2->F3_SERIE, QRY2->R_E_C_N_O_, QRY2->F3_VALICM, QRY2->F3_EMISSAO, .F.})
		//		If aScan(aJaUsado, { |x| x[1] == QRY2->F3_EMISSAO}) = 0
		//			Aadd(aDias,{QRY2->F3_EMISSAO, 0})
		//	EndIf
		cUltDia := QRY2->F3_EMISSAO
		QRY2->(DbSkip())
	EndDo
	
	/*    For ee := 1 To Len(aDias)
	IncProc( "Processando 1: "+aDias[ee,1])
	aDias[ee,2] := nFalta / Len(aDias)
	Next
	
	For ee1 := 1 To Len(aDias)
	IncProc( "Processando 2: "+aDias[ee1,1])
	*/
	lDia := .t.
	For ee := 1 To Len(aJaUsado)
		if ajausado[ee,1]='103620'
			inkey(1)
		endif
		IncProc( "Falta: "+str(nFalta)+"  "+str(aJaUsado[ee,4]))
		lDia := .t.
		If cDia = aJaUsado[ee,5] .OR. aJaUsado[ee,6]
			lDia := .f.
			Loop
		EndIf
		If lDia .AND. !aJaUsado[ee,6]
			cDia := aJaUsado[ee,5]
			cNota := aJaUsado[ee,1]+aJaUsado[ee,2]
			nControle := ee
			Do While nControle <= Len(aJaUsado) .AND. aJaUsado[nControle,1]+aJaUsado[nControle,2] == cNota
				SF3->(DbGoTo(aJaUsado[nControle,3]))
				RecLock("SF3",.F.)
				SF3->F3_EE := "  "
				SF3->F3_REPROC := "V"
				SF3->(MsUnlock())
				nFalta -= aJaUsado[nControle,4]
				aJaUsado[nControle,6] := .T.
				nControle++
				nProcessados++
				//			Adel(aJaUsado,ee)
				//			Asize(aJaUsado,Len(aJaUsado)-1)
				//  			If Len(aJaUsado) = 0
				//				Exit
				//  		EndIf
			EndDo
			If nProcessados <= Len(aJaUsado)
				If cUltDia = aJaUsado[ee,5]
					ee:=1
				Else
					ee += (nControle-ee-1)
				EndIf
			EndIf
			
		EndIf
		
		If nFalta <= 0 .OR. nProcessados >= Len(aJaUsado)
			Exit
		EndIf
	Next
	//    Next
EndIf
QRY1->(DbCloseArea())
QRY2->(DbCloseArea())
RestArea(_xArea)
If MsgBox("Vamos imprimir o Resumo?","Atencao","YESNO")
	EERESUMO()
EndIf
Return
/*fim EEAtingeM*/
//////////////////////////
Static Function EERESUMO()
Local _xArea := GetArea()
Local titulo := OemTOAnsi("Resumo do ICMS - "+MV_PAR01,72)
Local cDesc1 := (OemToAnsi("Este programa tem como objetivo emitir um relat¢rio",72))
Local cDesc2 := (OemToAnsi("com o resumo da apuração do ICMS para recolhiemnto.",72))
Local cDesc3 := (OemToAnsi("",72))

Private aReturn	:= {"Bco A4", 1,"Administracao", 1, 2, 1,"",1}
Private li		:= 67
Private tamanho := "P"
Private limite	:= 80
Private nomeprog:= "EE_SF3"
Private nLastKey:= 0
Private lEnd	:= .F.
Private wnrel	:= "EE_SF3_"+Subs(MV_PAR01,4,4)+Subs(MV_PAR01,1,2)+"-"+SM0->(M0_CODIGO+M0_CODFIL) //+SM0->M0_FILIAL
Private cString	:= "SF3"
Private m_pag	:= 1

Private cCaminho  := "c:\temp\"
Private oExcel 	 := FWMSEXCEL():New()
PRIVATE cArquivo := AllTrim(cCaminho)+wnrel+".XML"

// Montagem das colunas
oExcel:AddworkSheet("SAIDAS")
oExcel:AddTable ("SAIDAS","ST-RESSARCIVEL-SAIDAS",)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","EMISSAO",1,4)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","NOTA",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","SERIE",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","CLIENTE",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","LOJA",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","CODIGO",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","PRODUTO",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","TES",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","CFOP",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","LOTE",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","QTDE",1,2)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","ICMS-RESSAR",1,3)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","NOTA-ENTRADA",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","SERIE-ENTRADA",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","DATA-ENTRADA",1,4)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","FORNEC-ENTRADA",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","CFOP-ENTRADA",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","LOTE-ENTRADA",1,1)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","VALOR-ENTRADA",1,3)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","BASEICMS-ENTRADA",1,3)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","ALIQ-ENTRADA",1,3)
oExcel:AddColumn("SAIDAS","ST-RESSARCIVEL-SAIDAS","ICMS-ENTRADA",1,3)


//wnrel:=SetPrint(cString,wnrel,cPerg, Titulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,tamanho,,.f.,,,,,)   
  wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|lEnd| EEimp(TITULO)},Titulo)

Set device to Screen

/*====================================================================================\
| Se em disco, desvia para Spool                                                      |
\====================================================================================*/
If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
	Set Printer TO
	Commit
	ourspool(wnrel)
Endif
RestArea(_xArea)
Return
/*fim EERESUMO*/
///////////////////////
Static Function EEimp(TITULO)
Local aTotEnt	:= {0,0,0,0,0} // 1 contabil  2 base  3 icms  4 isentas  5 outras
Local aTotSai	:= {0,0,0,0,0}
Local nCxVen    := 0
Local nCxCom	:= 0
Local QRY1
Local QRY2
Local QRY3
Local QRY4
Local QRY5
Local QRY6
Local QRY7
Local QRY8
Local nHandle	:= ""
Local cWorkFlow := "N"
Local nCredito  := 0    
Local nDifal    := 0

Local lfilial	:= .F.

If MsgYesNo("Considera Filial para busca da NF de entrada?", "Considera Filial") // ativada em 03/02/2022 - Thais Reis - Obify
	lfilial := .T.
EndIf

SetRegua(2100)
For _x := 1 to 300
	IncRegua( "Processando...1 ")
Next
/*
select F3_CFO, SUM(F3_VALCONT) CONTABIL, SUM(F3_BASEICM) BASE, SUM(F3_VALICM) ICMS, SUM(F3_ISENICM) ISENTAS, SUM(F3_OUTRICM) OUTRAS
from SF3010 F3
where F3.D_E_L_E_T_ <> '*'
and F3_EE = SPACE(2)
and F3_DTCANC = SPACE(8)
and left(F3_ENTRADA,6) = '200901'
and F3_FILIAL in ('04')
group by F3_CFO
order by F3_CFO
*/
QRY1 := "select F3_CFO, SUM(F3_VALCONT) CONTABIL, SUM(F3_BASEICM) BASE, SUM(F3_VALICM) ICMS, SUM(F3_ISENICM) ISENTAS, SUM(F3_OUTRICM) OUTRAS"
QRY1 += " FROM "+RetSQLName("SF3")+" F3"
QRY1 += " WHERE F3.D_E_L_E_T_ = ' '"
QRY1 += " AND F3_EE = SPACE(2)"
QRY1 += " AND F3_DTCANC = SPACE(8)"
QRY1 += " AND LEFT(F3_ENTRADA,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
QRY1 += " AND F3_FILIAL in ('"+xFILIAL("SF3") + "')"
QRY1 += " group by F3_CFO"
QRY1 += " order by F3_CFO"
// Processa Query SQL
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

For _x := 1 to 200
	IncRegua( "Processando...2 ")
Next
/*
select F3_EE, sum(F3_VALCONT) CONTABIL, SUM(F3_BASEICM) BASE, sum(F3_VALICM) ICMS
from SF3010 F3
where F3.D_E_L_E_T_ = ' '
and left(F3_ENTRADA,6) = '200901'
and F3_FILIAL in ('04','xx','xv','xc')
group by F3_EE
*/
QRY2 := "select F3_EE, SUM(F3_VALCONT) CONTABIL, SUM(F3_BASEICM) BASE, SUM(F3_VALICM) ICMS"
QRY2 += " FROM " + RetSQLName("SF3")
QRY2 += " WHERE " + RetSQLName("SF3")+".D_E_L_E_T_ = ' '"
QRY2 += " AND F3_DTCANC = SPACE(8)"
QRY2 += " AND LEFT(F3_ENTRADA,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
QRY2 += " AND F3_FILIAL in ('"+xFILIAL("SF3") + "','XX','XV','XC')"
QRY2 += " AND F3_EE <> SPACE(2)"
QRY2 += " group by F3_EE"
QRY2 += " order by F3_EE desc"
// Processa Query SQL
TcQuery QRY2 NEW ALIAS "QRY2"         // Abre uma workarea com o resultado da query

For _x := 1 to 200
	IncRegua( "Processando...3 ")
Next
/*
SELECT SUM((CASE WHEN F3_VALCONT/1000 < 10 THEN (F3_VALCONT/1000)+10 ELSE F3_VALCONT/1000 END)) XVA
FROM SF3010 F3
where F3.D_E_L_E_T_ <> '*'
and F3_EE = 'XV'
and F3_DTCANC = SPACE(8)
and left(F3_ENTRADA,6) = '200901'
and F3_FILIAL in ('04')
*/
QRY3 := "select ROUND(SUM((CASE WHEN F3_VALCONT/1000 < 10 THEN (F3_VALCONT/1000)+10 ELSE F3_VALCONT/1000 END)),2) XVA"
QRY3 += " FROM " + RetSQLName("SF3")
QRY3 += " WHERE " + RetSQLName("SF3")+".D_E_L_E_T_ = ' '"
QRY3 += " AND F3_DTCANC = SPACE(8)"
QRY3 += " AND LEFT(F3_ENTRADA,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
QRY3 += " AND F3_FILIAL in ('"+xFILIAL("SF3") + "','XX','XV','XC')"
QRY3 += " AND F3_EE = 'XV'"
// Processa Query SQL
TcQuery QRY3 NEW ALIAS "QRY3"         // Abre uma workarea com o resultado da query

For _x := 1 to 200
	IncRegua( "Processando...4 ")
Next
/*
SELECT sum(D2_TOTAL), SUM(D2_BASEICM), SUM(D2_VALICM)
FROM SD2010, SB1010
WHERE SD2010.D_E_L_E_T_ = '' 
  AND SB1010.D_E_L_E_T_ = '' 
  AND D2_FILIAL = '04'
  AND D2_EST <> 'SP' 
  AND D2_COD = B1_COD
  AND B1_PICMRET <> 0
  AND LEFT(D2_EMISSAO,6) = @PERIODO
*/
QRY4 := "SELECT SUM(D2_TOTAL+D2_VALFRE+D2_SEGURO+D2_DESPESA+D2_ICMSRET) D2_TOTAL "
QRY4 += " FROM "+RetSQLName("SD2")+" D2 "
QRY4 += " INNER JOIN "+RetSQLName("SB1")+" B1 ON "
QRY4 += " B1_FILIAL = D2_FILIAL "
QRY4 += " AND D2_COD = B1_COD "
QRY4 += " AND B1.D_E_L_E_T_ = ' ' "
QRY4 += " AND B1_GRTRIB NOT IN ('','001') "
QRY4 += " WHERE D2.D_E_L_E_T_ = ' '"
QRY4 += " AND D2_FILIAL = '"+xFILIAL("SD2")+"'"        
QRY4 += " AND D2_EST <> 'SP'"
//QRY4 += " AND D2_XICMRET <> 0"
//QRY4 += " AND D2_ICMSRET >0 "
QRY4 += " AND LEFT(D2_EMISSAO,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
// Processa Query SQL
TcQuery QRY4 NEW ALIAS "QRY4"         // Abre uma workarea com o resultado da query

For _x := 1 to 200
	IncRegua( "Processando...5 ")
Next

/*
SELECT (case when F1_EST='SP' then 'SP' else 'XX' end) F1_EST, SUM(F1_ICMSRET) 'ST-SP'
FROM SF1010 --, SA2010
WHERE SF1010.D_E_L_E_T_ = ''
--  AND SA2010.D_E_L_E_T_ = ''
  AND F1_FILIAL = '04'
  AND LEFT(F1_DTDIGIT,6) = @PERIODO
  AND F1_EMISSAO > '20090331'
  AND F1_ICMSRET <> 0
--  AND F1_FORNECE = A2_COD
--  AND F1_LOJA = A2_LOJA
GROUP BY F1_EST
ORDER BY F1_EST
*/
QRY5 := "SELECT SUM(F1_ICMSRET) F1_ICMSRET"
QRY5 += " FROM "+RetSQLName("SF1")
QRY5 += " WHERE "+RetSQLName("SF1")+".D_E_L_E_T_ = ' '"
//QRY5 += " AND F1_FILIAL = '"+xFILIAL("SF1")+"'"
QRY5 += " AND F1_EMISSAO > '20090331'"
QRY5 += " AND F1_ICMSRET <> 0"
QRY5 += " AND LEFT(F1_DTDIGIT,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
QRY5 += " AND F1_EST = 'SP'"
// Processa Query SQL
TcQuery QRY5 NEW ALIAS "QRY5"         // Abre uma workarea com o resultado da query

For _x := 1 to 200
	IncRegua( "Processando...6 ")
Next

QRY6 := "SELECT SUM(F1_ICMSRET) F1_ICMSRET"
QRY6 += " FROM "+RetSQLName("SF1")
QRY6 += " WHERE "+RetSQLName("SF1")+".D_E_L_E_T_ = ' '"
//QRY6 += " AND F1_FILIAL = '"+xFILIAL("SF1")+"'"
QRY6 += " AND F1_EMISSAO > '20090331'"
QRY6 += " AND F1_ICMSRET <> 0"
QRY6 += " AND LEFT(F1_DTDIGIT,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
QRY6 += " AND F1_EST <> 'SP'"
// Processa Query SQL
TcQuery QRY6 NEW ALIAS "QRY6"         // Abre uma workarea com o resultado da query

/*
SELECT left(D2_EMISSAO,6) DIPROMED, "VendaS", SUM(D2_TOTAL) VALOR, SUM(D2_TOTAL*0.076) "COFINS 7.6", SUM(D2_TOTAL*0.0165) "PIS 1.65"
FROM SD2010, SB1010, SF4010
WHERE ISNULL(SD2010.D_E_L_E_T_,'') = ''   AND SB1010.D_E_L_E_T_ = ''   AND SF4010.D_E_L_E_T_ = '' 
  AND LEFT(D2_EMISSAO,6) = '201011'
  AND D2_FILIAL = '04'
  AND ISNULL(D2_CONTA,'null') NOT IN ('ERA','VAI')
  AND D2_COD = B1_COD
--  AND B1_POSIPI IN ('30021022','30021023','30021024','30021029','30029010','30061011','30061019','30061020','30061090','30062000','30063021','30063029','30064011','30064012','30064020','30067000','39269030','39269040','39269050','39269090','90183111','90183119','90183190','90183211','90183212','90183219','90183220','90183910','90183921','90183922','90183923','90183929','90183930','90183990','90184911','90184912','90184919','90184920','90189095','90189099')
  and (B1_REDPIS <> 0 OR B1_REDCOF <> 0)
--  AND B1_ORIGEM IN ('1','2')
  AND D2_TES = F4_CODIGO AND (F4_DUPLIC = 'S' or F4_CODIGO = '538')
GROUP BY LEFT(D2_EMISSAO,6)
*/

For _x := 1 to 200
	IncRegua( "Processando...7 ")
Next

QRY7 := "SELECT SUM(D2_TOTAL) TOTAL, SUM(D2_TOTAL*0.076) COFINS, SUM(D2_TOTAL*0.0165) PIS"
QRY7 += " FROM "+RetSQLName("SD2")+", "+RetSQLName("SB1")+", "+RetSQLName("SF4")
QRY7 += " WHERE "+RetSQLName("SD2")+".D_E_L_E_T_ = ' '"
QRY7 += " AND "+RetSQLName("SB1")+".D_E_L_E_T_ = ' '"
QRY7 += " AND "+RetSQLName("SF4")+".D_E_L_E_T_ = ' '"
QRY7 += " AND D2_FILIAL = '"+xFILIAL("SD2")+"'"     
QRY7 += " AND B1_FILIAL = '"+xFILIAL("SB1")+"'"
QRY7 += " AND F4_FILIAL = '"+xFILIAL("SF4")+"'"
QRY7 += " AND LEFT(D2_EMISSAO,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
QRY7 += " AND D2_COD = B1_COD"
If CEMPANT = '04'
	QRY7 += " AND D2_FILIAL = B1_FILIAL"
EndIf
//QRY7 += " AND B1_POSIPI IN ('30021022','30021023','30021024','30021029','30029010','30061011','30061019','30061020','30061090','30062000','30063021','30063029','30064011','30064012','30064020','30067000','39269030','39269040','39269050','39269090','90183111','90183119','90183190','90183211','90183212','90183219','90183220','90183910','90183921','90183922','90183923','90183929','90183930','90183990','90184911','90184912','90184919','90184920','90189095','90189099')"
//QRY7 += " AND B1_ORIGEM IN ('1','2')"
QRY7 += " AND (F4_CSTPIS = '06' OR F4_CSTCOF = '06')"
QRY7 += " AND D2_TES = F4_CODIGO"
QRY7 += " AND (F4_DUPLIC = 'S' OR F4_CODIGO = '538')"
If CEMPANT = '04'
	QRY7 += " AND D2_FILIAL = F4_FILIAL"
EndIf
QRY7 += " GROUP BY LEFT(D2_EMISSAO,6)"
// Processa Query SQL
TcQuery QRY7 NEW ALIAS "QRY7"         // Abre uma workarea com o resultado da query

/*
SELECT left(D1_DTDIGIT,6) DIPROMED, "CompraS", SUM(D1_TOTAL) VALOR, SUM(D1_TOTAL*0.076) "COFINS 7.6", SUM(D1_TOTAL*0.0165) "PIS 1.65"
FROM SD1010, SB1010, SF4010
WHERE ISNULL(SD1010.D_E_L_E_T_,'') = ''   AND SB1010.D_E_L_E_T_ = ''   AND SF4010.D_E_L_E_T_ = '' 
  AND LEFT(D1_DTDIGIT,6) = '201011'
  AND D1_FILIAL = '04'
  AND ISNULL(D1_CONTA,'null') NOT IN ('ERA','VAI')
  AND D1_COD = B1_COD
--  AND B1_POSIPI IN ('30021022','30021023','30021024','30021029','30029010','30061011','30061019','30061020','30061090','30062000','30063021','30063029','30064011','30064012','30064020','30067000','39269030','39269040','39269050','39269090','90183111','90183119','90183190','90183211','90183212','90183219','90183220','90183910','90183921','90183922','90183923','90183929','90183930','90183990','90184911','90184912','90184919','90184920','90189095','90189099')
  and (B1_REDPIS <> 0 OR B1_REDCOF <> 0)
  AND B1_ORIGEM IN ('1','2')
  AND D1_TES = F4_CODIGO AND F4_DUPLIC = 'S'
GROUP BY LEFT(D1_DTDIGIT,6)
*/

For _x := 1 to 200
	IncRegua( "Processando...7 ")
Next

QRY8 := "SELECT SUM(D1_TOTAL) TOTAL, SUM(D1_TOTAL*0.076) COFINS, SUM(D1_TOTAL*0.0165) PIS"
QRY8 += " FROM "+RetSQLName("SD1")+", "+RetSQLName("SB1")+", "+RetSQLName("SF4")
QRY8 += " WHERE "+RetSQLName("SD1")+".D_E_L_E_T_ = ' '"
QRY8 += " AND "+RetSQLName("SB1")+".D_E_L_E_T_ = ' '"
QRY8 += " AND "+RetSQLName("SF4")+".D_E_L_E_T_ = ' '"
QRY8 += " AND D1_FILIAL = '"+xFILIAL("SD1")+"'"   
QRY8 += " AND B1_FILIAL = '"+xFILIAL("SB1")+"'"
QRY8 += " AND F4_FILIAL = '"+xFILIAL("SF4")+"'"
QRY8 += " AND LEFT(D1_DTDIGIT,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
QRY8 += " AND D1_COD = B1_COD"
If CEMPANT = '04'
	QRY8 += " AND D1_FILIAL = B1_FILIAL"
EndIf
//QRY8 += " AND B1_POSIPI IN ('30021022','30021023','30021024','30021029','30029010','30061011','30061019','30061020','30061090','30062000','30063021','30063029','30064011','30064012','30064020','30067000','39269030','39269040','39269050','39269090','90183111','90183119','90183190','90183211','90183212','90183219','90183220','90183910','90183921','90183922','90183923','90183929','90183930','90183990','90184911','90184912','90184919','90184920','90189095','90189099')"
//QRY8 += " AND B1_ORIGEM IN ('1','2')"
QRY8 += " AND (F4_CSTPIS = '73' OR F4_CSTCOF = '73')"
QRY8 += " AND D1_TES = F4_CODIGO"
QRY8 += " AND F4_DUPLIC = 'S'"
If CEMPANT = '04'
	QRY8 += " AND D1_FILIAL = F4_FILIAL"
EndIf
QRY8 += " GROUP BY LEFT(D1_DTDIGIT,6)"
// Processa Query SQL
TcQuery QRY8 NEW ALIAS "QRY8"         // Abre uma workarea com o resultado da query


//QRY9 := "SELECT D2_COD, D2_LOTECTL, D2_QUANT, D2_VALICM "
QRY9 := "SELECT D2_COD, D2_LOTECTL, D2_QUANT, D2_VALICM,D2_EMISSAO,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TES,D2_CF "
QRY9 += " FROM "+RetSQLName("SD2")+" D2  "
QRY9 += " INNER JOIN "+RetSQLName("SB1")+" B1 ON "
QRY9 += " B1_FILIAL = D2_FILIAL "
QRY9 += " AND D2_COD = B1_COD "
QRY9 += " AND B1.D_E_L_E_T_ = ' ' "
QRY9 += " AND B1_GRTRIB NOT IN ('','001') "
QRY9 += " WHERE "
QRY9 += " D2.D_E_L_E_T_ = ' ' "
QRY9 += " AND D2_FILIAL = '"+xFILIAL("SD2")+"'"        
QRY9 += " AND D2_EST <> 'SP'"
QRY9 += " AND D2_COD = B1_COD"  
//QRY9 += " AND D2_XICMRET <> 0"
QRY9 += " AND LEFT(D2_EMISSAO,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
TcQuery QRY9 NEW ALIAS "QRY9"

nValICM := 0

While !QRY9->(Eof())


	
	QRY10 := "	SELECT TOP 1 "
	QRY10 += "		D1_QUANT, D1_BASEICM, D1_PICM, D1_LOTECTL,D1_DOC,D1_SERIE,D1_FORNECE,D1_DTDIGIT,D1_CF,D1_TOTAL,D1_VALICM,D1_BASEICM "
	QRY10 += "		FROM "
	QRY10 +=			RetSQLName("SD1")
	QRY10 += "			WHERE "
  	If lfilial
	  QRY10 += "				D1_FILIAL  = '"+xFilial("SD1")	+"' AND "
	ENDIF
	QRY10 += "				D1_COD 	   = '"+QRY9->D2_COD	+"' AND "
	QRY10 += "				D1_LOTECTL = '"+QRY9->D2_LOTECTL+"' AND "
	If MV_PAR01 = '01/2014'
    	QRY10 += "				D1_DTDIGIT <=  '20140205' AND "	
 	Else
		QRY10 += "				D1_DTDIGIT <=  '" + dToS(LastDay(sTod(SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2)+'01'))) + "' AND "	
    EndIf
	QRY10 += "				D_E_L_E_T_ = ' ' "  
	QRY10 += "	ORDER BY R_E_C_N_O_ DESC "    
	
	TcQuery QRY10 NEW ALIAS "QRY10"

	If !QRY10->(Eof())	
//		nBaseICM += (QRY10->D1_BASEICM/QRY10->D1_QUANT)*QRY9->D2_QUANT
		nValICM	 += (QRY10->D1_BASEICM/QRY10->D1_QUANT)*QRY9->D2_QUANT*(QRY10->D1_PICM/100)		

		oExcel:AddRow("SAIDAS","ST-RESSARCIVEL-SAIDAS",	{	DtoC(Stod(QRY9->D2_EMISSAO)),;
															AllTrim(QRY9->D2_DOC),;
															AllTrim(QRY9->D2_SERIE),;
															AllTrim(QRY9->D2_CLIENTE),;
															AllTrim(QRY9->D2_LOJA),;
															AllTrim(QRY9->D2_COD),;
															Alltrim(Posicione("SB1",1,xfilial("SB1")+QRY9->D2_COD,"B1_DESC")),;
															AllTrim(QRY9->D2_TES),;
															AllTrim(QRY9->D2_CF),;
															AllTrim(QRY9->D2_LOTECTL),;
															QRY9->D2_QUANT,;
															(QRY10->D1_BASEICM/QRY10->D1_QUANT)*QRY9->D2_QUANT*(QRY10->D1_PICM/100),;
															Alltrim(QRY10->D1_DOC),;
															Alltrim(QRY10->D1_SERIE),;
															DtoC(Stod(QRY10->D1_DTDIGIT)),;
															Alltrim(QRY10->D1_FORNECE),;
															Alltrim(QRY10->D1_CF),;
															Alltrim(QRY10->D1_LOTECTL),;
															QRY10->D1_TOTAL,;
															QRY10->D1_BASEICM,;
															QRY10->D1_PICM,;
															QRY10->D1_VALICM})
	Else
		QRY11 := "	SELECT TOP 1 "
		//QRY11 += "		D1_QUANT, D1_BASEICM, D1_PICM, D1_LOTECTL "
		QRY11 += "		D1_QUANT, D1_BASEICM, D1_PICM, D1_LOTECTL,D1_DOC,D1_SERIE,D1_FORNECE,D1_DTDIGIT,D1_CF,D1_TOTAL,D1_VALICM,D1_BASEICM "
		QRY11 += "		FROM "
		QRY11 +=			RetSQLName("SD1")
		QRY11 += "			WHERE "
		If lfilial
			QRY11 += "				D1_FILIAL  = '"+xFilial("SD1")	+"' AND "
		ENDIF
		QRY11 += "				D1_COD 	   = '"+QRY9->D2_COD	+"' AND "
		If MV_PAR01 = '01/2014'
	    	QRY11 += "				D1_DTDIGIT <=  '20140205' AND "	
	 	Else
			QRY11 += "				D1_DTDIGIT <=  '" + dToS(LastDay(sTod(SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2)+'01'))) + "' AND "	
        EndIf
		QRY11 += "				D_E_L_E_T_ = ' ' "
		QRY11 += "	ORDER BY R_E_C_N_O_ DESC "    
		
		TcQuery QRY11 NEW ALIAS "QRY11"			
		
		If !QRY11->(Eof())	
			nValICM	+= (QRY11->D1_BASEICM/QRY11->D1_QUANT)*QRY9->D2_QUANT*(QRY11->D1_PICM/100)
			oExcel:AddRow("SAIDAS","ST-RESSARCIVEL-SAIDAS",	{	DtoC(Stod(QRY9->D2_EMISSAO)),;
															AllTrim(QRY9->D2_DOC),;
															AllTrim(QRY9->D2_SERIE),;
															AllTrim(QRY9->D2_CLIENTE),;
															AllTrim(QRY9->D2_LOJA),;
															AllTrim(QRY9->D2_COD),;
															Alltrim(Posicione("SB1",1,xfilial("SB1")+QRY9->D2_COD,"B1_DESC")),;
															AllTrim(QRY9->D2_TES),;
															AllTrim(QRY9->D2_CF),;
															AllTrim(QRY9->D2_LOTECTL),;
															QRY9->D2_QUANT,;
															(QRY11->D1_BASEICM/QRY11->D1_QUANT)*QRY9->D2_QUANT*(QRY11->D1_PICM/100),;
															Alltrim(QRY11->D1_DOC),;
															Alltrim(QRY11->D1_SERIE),;
															DtoC(Stod(QRY11->D1_DTDIGIT)),;
															Alltrim(QRY11->D1_FORNECE),;
															Alltrim(QRY11->D1_CF),;
															"",;
															QRY11->D1_TOTAL,;
															QRY11->D1_BASEICM,;
															QRY11->D1_PICM,;
															QRY11->D1_VALICM})

		Else
			//Alert("NF de entrada não encontrada. Será considerado o valor de ICMS da saída - Cod: "+QRY9->D2_COD+" ICMS: "+Transform(QRY9->D2_VALICM,"@E 999,999.99"))
			nValICM += QRY9->D2_VALICM

			oExcel:AddRow("SAIDAS","ST-RESSARCIVEL-SAIDAS",	{	DtoC(Stod(QRY9->D2_EMISSAO)),;
																		AllTrim(QRY9->D2_DOC),;
																		AllTrim(QRY9->D2_SERIE),;
																		AllTrim(QRY9->D2_CLIENTE),;
																		AllTrim(QRY9->D2_LOJA),;
																		AllTrim(QRY9->D2_COD),;
																		Alltrim(Posicione("SB1",1,xfilial("SB1")+QRY9->D2_COD,"B1_DESC")),;
																		AllTrim(QRY9->D2_TES),;
																		AllTrim(QRY9->D2_CF),;
																		AllTrim(QRY9->D2_LOTECTL),;
																		QRY9->D2_QUANT,;
																		QRY9->D2_VALICM,;
																		"",;
																		"",;
																		"",;
																		"",;
																		"",;
																		"",;
																		0,;
																		0,;
																		0,;
																		0})
		EndIf
		QRY11->(dbCloseArea())	
	EndIf	
	QRY10->(dbCloseArea())	
	QRY9->(dbSkip())                
EndDo               
QRY9->(dbCLoseArea())        

_cDesc2  := ""
_cDesc1  := "  CFOP VALOR CONTABIL           BASE          ICMS        ISENTAS         OUTRAS"
*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0
*123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
*CX9999 999.999.999,99 999.999.999,99 99.999.999,99 999.999.999,99 999.999.999,99

nCredito :=  DigValor() //-21268.66 //-82.87

lImpTot:=.t.
SF4->(DbOrderNickName("EEFISCAL"))
DbSelectArea("QRY1")

Do While QRY1->(!Eof())
	If lAbortPrint
		@ li+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	IncRegua( "Imprimindo... " + QRY1->F3_CFO )
	
	If li > 56
		li := u_MYCabec(Titulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	EndIf
	
	SF4->(DbSeek(xFilial("SF4")+Iif(Subs(QRY1->F3_CFO,1,1)$'2/3','1',Iif(Subs(QRY1->F3_CFO,1,1)$'6/7','5',Subs(QRY1->F3_CFO,1,1)))+Subs(QRY1->F3_CFO,2,4)+'X'))
	// Só para 6108
	If alltrim(QRY1->F3_CFO) $ '6108/6107/6403'
		SF4->(DbSeek(xFilial("SF4")+'5102 '+'X'))
	EndIf
	
	@ li,000 PSay Iif(!Empty(SF4->F4_EE),'*','')
	@ li,002 PSay QRY1->F3_CFO
	@ li,007 PSay Transform(QRY1->CONTABIL,"@E 999,999,999.99")
	@ li,022 PSay Transform(QRY1->BASE,    "@E 999,999,999.99")
	@ li,037 PSay Transform(QRY1->ICMS,    "@E 999,999,999.99")
	@ li,051 PSay Transform(QRY1->ISENTAS, "@E 999,999,999.99")
	@ li,066 PSay Transform(QRY1->OUTRAS,  "@E 999,999,999.99")
	li++
	
	//                    1 contabil  2 base  3 icms  4 isentas  5 outras
	If Subs(QRY1->F3_CFO,1,1) < '5'
		aTotEnt[1] := aTotEnt[1]+QRY1->CONTABIL
		aTotEnt[2] := aTotEnt[2]+QRY1->BASE
		aTotEnt[3] := aTotEnt[3]+QRY1->ICMS
		aTotEnt[4] := aTotEnt[4]+QRY1->ISENTAS
		aTotEnt[5] := aTotEnt[5]+QRY1->OUTRAS
		nCxCom	  := nCxCom + Iif(Upper(SF4->F4_EE)='X', QRY1->CONTABIL,0)
	EndIf
	If Subs(QRY1->F3_CFO,1,1) >= '5'
		aTotSai[1] := aTotSai[1]+QRY1->CONTABIL
		aTotSai[2] := aTotSai[2]+QRY1->BASE
		aTotSai[3] := aTotSai[3]+QRY1->ICMS
		aTotSai[4] := aTotSai[4]+QRY1->ISENTAS
		aTotSai[5] := aTotSai[5]+QRY1->OUTRAS
		nCxVen    := nCxVen + Iif(Upper(SF4->F4_EE)='X', QRY1->CONTABIL,0)
	EndIf
	
	QRY1->(dbSkip())
	
	If lImpTot .and. Subs(QRY1->F3_CFO,1,1) = '5'
		@ li,006 PSay Transform(aTotEnt[1], "@E 999,999,999.99")
		@ li,021 PSay Transform(aTotEnt[2], "@E 999,999,999.99")
		@ li,036 PSay Transform(aTotEnt[3], "@E 999,999,999.99")
		@ li,050 PSay Transform(aTotEnt[4], "@E 999,999,999.99")
		@ li,065 PSay Transform(aTotEnt[5], "@E 999,999,999.99")
		li+=2
		lImpTot := .f.
	EndIf
EndDo

IncRegua( "Imprimindo... TOTAL" )

If li > 56
	li := u_MYCabec(Titulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)
	li++
EndIf

@ li,006 PSay Transform(aTotSai[1], "@E 999,999,999.99")
@ li,021 PSay Transform(aTotSai[2], "@E 999,999,999.99")
@ li,036 PSay Transform(aTotSai[3], "@E 999,999,999.99")
@ li,050 PSay Transform(aTotSai[4], "@E 999,999,999.99")
@ li,065 PSay Transform(aTotSai[5], "@E 999,999,999.99")
li+=2

@ li, 000 PSay 'Vendas ->'+Transform(nCxVen, "@E 999,999,999.99")          //+SPACE(5)+Transform(nCxVen*0.7675, "@E 999,999,999.99")
@ li, 028 PSay '-ICMS do mes-   ->'+Transform(aTotSai[3]-aTotEnt[3], "@E 999,999,999.99")
li++
@ li, 000 PSay 'Compras->'+Transform(nCxCom, "@E 999,999,999.99")          //+SPACE(5)+Transform(nCxCom*0.7675, "@E 999,999,999.99")
@ li, 028 PSay 'Credito anterior-> -'+Transform(Abs(nCredito),  "@E 999,999,999.99")
li++
@ li, 000 PSay '* CAIXA->'+Transform(nCxVen-nCxCom, "@E 999,999,999.99")   //+SPACE(5)+Transform((nCxVen-nCxCom)*0.7675, "@E 999,999,999.99")
@ li, 028 PSay 'ST ressarcivel  -> -'+Transform(nValICM,"@E 999,999,999.99")+'   Vendas->'+Transform(QRY4->D2_TOTAL,  "@E 999,999,999.99")
li++
@ li, 047 PSay '-----------'
li++
@ li, 028 PSay Iif(aTotSai[3]-aTotEnt[3]-Abs(nCredito)-nValIcm>0,'RECOLHER ->      ','CREDITO ->       ')+Transform(aTotSai[3]-aTotEnt[3]-Abs(nCredito)-nValIcm, "@E 99,999,999.99")

li+=2
DbSelectArea("QRY2")
Do While QRY2->(!Eof())
	@ li,002 PSay QRY2->F3_EE
	@ li,006 PSay Transform(QRY2->CONTABIL,"@E 999,999,999.99")
	@ li,021 PSay Transform(QRY2->BASE,    "@E 999,999,999.99")
	@ li,036 PSay Transform(QRY2->ICMS,    "@E 999,999,999.99")
	If QRY2->F3_EE = 'XV'
		@ li,050 PSay Transform(QRY3->xva, "@E 999,999,999.99")
	EndIf
	li++
	QRY2->(dbSkip())
EndDo
/*
li+=1
@ li++,002 PSay 'Vendas de produtos com ST para outros estados:'
@ li,006 PSay Transform(QRY4->D2_TOTAL,  "@E 999,999,999.99")
@ li,021 PSay Transform(QRY4->D2_BASEICM,"@E 999,999,999.99")
@ li,036 PSay Transform(QRY4->D2_VALICM, "@E 99,999,999.99")
*/
li+=2
@ li,002 PSay 'ST paga no mês nas NFs: '+Transform(QRY5->F1_ICMSRET,"@E 999,999.99")+'  Por guia: '+Transform(QRY6->F1_ICMSRET,"@E 999,999.99")+'  Total: '+Transform(QRY5->F1_ICMSRET+QRY6->F1_ICMSRET,"@E 999,999.99")

li+=2
@ li,002 PSay 'ISENÇÃO       Valor      Cofins         Pis'
@ li+1,002 PSay 'Vendas: '+Transform(QRY7->TOTAL,"@E 999,999,999.99")+'  '+Transform(QRY7->COFINS,"@E 999,999,999.99")+'  '+Transform(QRY7->PIS,"@E 999,999,999.99")
@ li+2,002 PSay 'Compras:'+Transform(QRY8->TOTAL,"@E 999,999,999.99")+'  '+Transform(QRY8->COFINS,"@E 999,999,999.99")+'  '+Transform(QRY8->PIS,"@E 999,999,999.99")
//@ li+3,002 PSay '       '+Transform(QRY7->TOTAL-QRY8->TOTAL,"@E 9999,999.99")+'  '+Transform(QRY7->COFINS-QRY8->COFINS,"@E 999,999.99")+'  '+Transform(QRY7->PIS-QRY8->PIS,"@E 999,999.99")

_cDesc2  := ""
_cDesc1  := "  UF-INSCRICAO         BASE         ICMS-COMP.     ICMS-DIFAL.         FCP"


li := u_MYCabec(Titulo,_cDesc1,_cDesc2,nHandle,cWorkFlow)

cMVSubTrib := GetNewPar("MV_SUBTRIB","")

cSQL := " SELECT "
cSQL += " 	D2_EST, SUM(D2_BASEICM) D2_BASEICM, SUM(D2_ICMSCOM) D2_ICMSCOM, SUM(D2_DIFAL) D2_DIFAL, SUM(CD2_VFCP) CD2_VFCP "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SD2")+", "+RetSQLName("CD2")
cSQL += " 		WHERE "
cSQL += " 			D2_FILIAL = '"+xFilial("SD2")+"' AND "
cSQL += " 			LEFT(D2_EMISSAO,6) = '"+SUBS(MV_PAR01,4,4)+SUBS(MV_PAR01,1,2)+"' AND "  
cSQL += " 			D2_DIFAL   > 0 AND "
cSQL += " 			CD2_FILIAL = D2_FILIAL AND "
cSQL += "			CD2_TPMOV  = 'S' AND "
cSQL += " 			CD2_DOC    = D2_DOC AND "  
cSQL += "			CD2_CODCLI = D2_CLIENTE AND "
cSQL += "			CD2_LOJCLI = D2_LOJA AND "
cSQL += "			CD2_ITEM   = D2_ITEM AND "
cSQL += "			CD2_CODPRO = D2_COD AND "
cSQL += " 			CD2_IMP    = 'CMP' AND "
cSQL +=  			RetSQLName("SD2")+".D_E_L_E_T_ = ' ' AND "
cSQL +=  			RetSQLName("CD2")+".D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY D2_EST
cSQL += " ORDER BY D2_EST

cSQL := ChangeQuery(cSQL)   
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYDIF",.T.,.F.)

cEstAnt := ""
nTotBas := 0
nIcmCom := 0
nIcmDif := 0
nTotFCP := 0

While !QRYDIF->(Eof())

	cInscEst := ""
	nPos1  	 := 0
	nPos2    := 0            
	li++
		                                               
	nPos1  := At(AllTrim(QRYDIF->D2_EST),cMVSubTrib)	
	
	If nPos1 > 0                              
		cInscEst := SUBSTR(cMVSubTrib,nPos1+2,Len(cMVSubTrib))
		nPos2 	 := At("/",cInscEst)  
		If nPos2 == 0
			nPos2 := Len(cInscEst)+1
		EndIf    
		cInscEst := SUBSTR(cInscEst,1,nPos2-1)		
	EndIf                                           
	
	cInscEst := PADL(cInscEst,10)
	
	@ li,002 PSay QRYDIF->D2_EST+IIf(!Empty(cInscEst),"-"," ")+cInscEst+" "+TransForm(QRYDIF->D2_BASEICM,"@E 999,999,999.99")+" "+TransForm(QRYDIF->D2_ICMSCOM,"@E 999,999,999.99")+" "+TransForm(QRYDIF->D2_DIFAL,"@E 999,999,999.99")+" "+TransForm(QRYDIF->CD2_VFCP,"@E 999,999,999.99")

	cEstAnt := QRYDIF->D2_EST
    nTotBas += QRYDIF->D2_BASEICM
    nIcmCom += QRYDIF->D2_ICMSCOM
    nIcmDif += QRYDIF->D2_DIFAL
	nTotFCP += QRYDIF->CD2_VFCP
	
	QRYDIF->(dbSkip())
EndDo
QRYDIF->(dbCloseArea())

li+=2
@ li,002 PSay "TOTAL ------> "+TransForm(nTotBas,"@E 999,999,999.99")+" "+TransForm(nIcmCom,"@E 999,999,999.99")+" "+TransForm(nIcmDif,"@E 999,999,999.99")+" "+TransForm(nTotFCP,"@E 999,999,999.99")

QRY1->(dbCloseArea())
QRY2->(dbCloseArea())
QRY3->(dbCloseArea())
QRY4->(dbCloseArea())
QRY5->(dbCloseArea())
QRY6->(dbCloseArea())
QRY7->(dbCloseArea())
QRY8->(dbCloseArea())

If MsgYesNo("Deseja abrir detalhe Excel?", "Excel") // ativada em 03/02/2022 - Thais Reis - Obify
	oExcel:Activate()
	oExcel:GetXMLFile(cArquivo)
	oExcelApp:=MsExcel():New()                                         
	oExcelApp:WorkBooks:Open(cArquivo) // Abre uma planilha
	oExcelApp:SetVisible(.T.) 
ENDIF


Return(.T.)
/*fim EEimp*/
////////////////////////////
Static Function EECONFIRMA()
Local _xArea := GetArea()

If MsgBox("Vamos confirmar os dados no sistema?","Atencao","YESNO")
	Processa({|lEnd| AjustaF3()},"Ajustando SF3")
	Processa({|lEnd| Ajusta5949()},"Juntando 5949")
EndIf
RestArea(_xArea)
Return
/*fim EECONFIRMA*/
//////////////////////////
Static Function AjustaF3()
ProcRegua(2500)
For _x := 1 to 300
	IncProc( "Confirmando dados...")
Next
/*
select R_E_C_N_O_
from SF3010 F3
where F3.D_E_L_E_T_ = ' '
and left(F3_ENTRADA,6) = '200901'
and F3_FILIAL in ('04','XX','XV','XC')
and F3_EE <> SPACE(2)
*/

QRY1 := "SELECT F3_NFISCAL, F3.R_E_C_N_O_"
QRY1 += " FROM "+RetSQLName("SF3")+' F3'
QRY1 += " WHERE F3.D_E_L_E_T_ = ' '"
QRY1 += " AND F3_EE <> SPACE(2)"
QRY1 += " AND LEFT(F3_ENTRADA,6) = '" + SUBS(MV_PAR01,4,4) + SUBS(MV_PAR01,1,2) + "'"
QRY1 += " AND F3_FILIAL in ('"+xFILIAL("SF3") + "','XX','XV','XC')"
// Processa Query SQL
TcQuery QRY1 NEW ALIAS "QRY1"         // Abre uma workarea com o resultado da query

dBSelectArea("SF3")
dbSetOrder(1)  //F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM,5,2)

DbSelectArea("QRY1")
QRY1->(dbGotop())
Do While QRY1->(!Eof())
	
	IncProc( "Atualizando " + QRY1->F3_NFISCAL )
	
	SF3->(DbGoTo(QRY1->R_E_C_N_O_))
	RecLock("SF3",.F.)
	If SF3->F3_EE = 'XX'
		SF3->F3_REPROC := 'X'
		SF3->F3_FILIAL := 'XX'
	EndIf
	If SF3->F3_EE = 'XV'
		SF3->F3_REPROC := 'X'
		SF3->F3_CFO    := Subs(SF3->F3_CFO,1,1)+'949'
		SF3->F3_VALOBSE:= 0
		SF3->F3_DESPESA:= 0
		SF3->F3_ISENICM:= 0
		SF3->F3_BASEICM:= 0
		SF3->F3_VALICM := 0
		SF3->F3_ALIQICM:= 0
		SF3->F3_VALCONT:= Iif(SF3->F3_VALCONT / 1000 < 10,ROUND(SF3->F3_VALCONT / 1000,2)+10,ROUND(SF3->F3_VALCONT / 1000,2))
		SF3->F3_OUTRICM:= SF3->F3_VALCONT
		SF3->(MsUnlock())
	EndIf
	
	QRY1->(dBSkip())
	
EndDo

DbSelectArea("QRY1")
QRY1->(DbCloseArea())

MsgBox("Atualizado F3","Atencao","INFO")
Return
///////////////////////////////////////////////////////////
Static Function Ajusta5949()
Local _nValCont := _nIsenIcm := 0
Local _cNfiscal
Local _cSerie
Local _nAliqIcm
Local aUlt_Reg := {}
Local _dUltimoDia := LastDay(CtoD('01/'+MV_PAR01))

dBSelectArea("SF3")
dbSetOrder(1)  //F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA+F3_CFO+STR(F3_ALIQICM,5,2)
SF3->(dbSeek(xFilial("SF3")+DtoS(CtoD('01/'+MV_PAR01)),.T.))

ProcRegua(Reccount())

Do While SF3->(!Eof()) .and. SF3->F3_ENTRADA <= _dUltimoDia
	
	IncProc( "Juntando 5949 " + SF3->F3_NFISCAL + Space(4) + dTOc(SF3->F3_ENTRADA))
	
	If SF3->F3_CFO <> '5949 ' .OR. SF3->F3_EE = '  '
		SF3->(dBSkip())
		Loop
	EndIf
	
	_cNfiscal := SF3->F3_NFISCAL
	_cSerie   := SF3->F3_SERIE
	_nAliqIcm := SF3->F3_ALIQICM
	_nValCont := 0
	_nOutrIcm := 0
	
	aadd(aUlt_Reg,{0, "", "", 0, "", 0, 0, 0, 0, 0, "", "", "", "", "", "", "", "", "", "", "", "", ""})
	Do While SF3->F3_ALIQICM == _nAliqIcm .and. SF3->F3_SERIE == _cSerie .and. SF3->F3_NFISCAL == _cNfiscal
		_nValCont += SF3->F3_VALCONT
		_nOutrIcm += SF3->F3_OUTRICM
		
		aUlt_Reg[1,1]	 := SF3->F3_ALIQICM
		aUlt_Reg[1,2]	 := SF3->F3_SERIE
		aUlt_Reg[1,3]	 := SF3->F3_NFISCAL
		aUlt_Reg[1,4]	 := SF3->F3_DESPESA
		aUlt_Reg[1,5]	 := SF3->F3_ESPECIE
		aUlt_Reg[1,6]	 := SF3->F3_VALOBSE
		aUlt_Reg[1,7]	 := SF3->F3_ISENICM
		aUlt_Reg[1,8]	 := SF3->F3_VALICM
		aUlt_Reg[1,9]	 := SF3->F3_BASEICM
		aUlt_Reg[1,10]	 := SF3->F3_VALCONT
		aUlt_Reg[1,11]	 := SF3->F3_ENTRADA
		aUlt_Reg[1,12]	 := SF3->F3_EMISSAO
		aUlt_Reg[1,13]	 := SF3->F3_ESTADO
		aUlt_Reg[1,14]	 := SF3->F3_CFO
		aUlt_Reg[1,15]	 := SF3->F3_LOJA
		aUlt_Reg[1,16]	 := SF3->F3_CLIEFOR
		aUlt_Reg[1,17]	 := SF3->F3_REPROC
		aUlt_Reg[1,18]	 := SF3->F3_FILIAL
		aUlt_Reg[1,19]	 := SF3->F3_OBSERV
		aUlt_Reg[1,20]	 := SF3->F3_DTCANC
		aUlt_Reg[1,21]	 := SF3->F3_FORMUL
		aUlt_Reg[1,22]	 := SF3->F3_TIPO
		aUlt_Reg[1,23]	 := SF3->F3_EE
		
		RecLock("SF3",.F.)
		SF3->F3_REPROC := 'J'
		SF3->(DbDelete())
		SF3->(MsUnLock())
		
		SF3->(DbSkip())
		
	EndDo
	
	RecLock("SF3",.T.)
	SF3->F3_ALIQICM := aUlt_Reg[1,1]
	SF3->F3_SERIE	:= aUlt_Reg[1,2]
	SF3->F3_NFISCAL := aUlt_Reg[1,3]
	SF3->F3_DESPESA := aUlt_Reg[1,4]
	SF3->F3_ESPECIE := aUlt_Reg[1,5]
	SF3->F3_VALOBSE := aUlt_Reg[1,6]
	SF3->F3_ISENICM := aUlt_Reg[1,7]
	SF3->F3_VALICM	:= aUlt_Reg[1,8]
	SF3->F3_BASEICM := aUlt_Reg[1,9]
	SF3->F3_VALCONT := _nValCont
	SF3->F3_OUTRICM := _nOutrIcm
	SF3->F3_ENTRADA := aUlt_Reg[1,11]
	SF3->F3_EMISSAO := aUlt_Reg[1,12]
	SF3->F3_ESTADO	:= aUlt_Reg[1,13]
	SF3->F3_CFO		:= aUlt_Reg[1,14]
	SF3->F3_LOJA	:= aUlt_Reg[1,15]
	SF3->F3_CLIEFOR := aUlt_Reg[1,16]
	SF3->F3_REPROC  := 'J'
	SF3->F3_FILIAL	:= aUlt_Reg[1,18]
	SF3->F3_OBSERV  := aUlt_Reg[1,19]
	SF3->F3_DTCANC  := aUlt_Reg[1,20]
	SF3->F3_FORMUL  := aUlt_Reg[1,21]
	SF3->F3_TIPO    := aUlt_Reg[1,22]
	SF3->F3_EE      := aUlt_Reg[1,23]
	SF3->(MsUnlock())
	
	SF3->(dBSkip())
	
EndDo

MsgBox("Juntei 5949 "+mv_par01,"Atencao","INFO")
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³DigValor º Autor ³ Maximo             º Data ³ 18/02/2009   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDescricao ³ Para solicitar um valor sem validação  º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ ESPECIFICO DIPROMED                                        º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
*-------------------------------*
Static Function DigValor()
*-------------------------------*
Local bOk:={|| nOpcao:=1,lSaida := .T.,oDlg:End()}
Local oDlg
Local oBt1
Local oBt2
Local nOpcao  := 0   
Local nX      := 0 
Local lSaida  := .F.         
Local nValor  := GetMv("MV_ZZ_SF3") 

Do While !lSaida
	nOpcao := 0
	Define msDialog oDlg title OemToAnsi("informe o valor") From 09,10 TO 15,45
	@ 002,002 to 045,136 pixel
	@ 010,010 say "VALOR"      Pixel
	@ 010,060 get oValor var nValor Size 60,08 pixel  Picture "@E 999,999,999.99"
	Define sbutton oBt1 from 030,090 type 1 action Eval(bOK) enable of oDlg
	Activate Dialog oDlg Centered                          
EndDo                                                          

PutMv("MV_ZZ_SF3",nValor) 

Return(nValor)
