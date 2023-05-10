/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Funcao    ≥ DIPM012  ≥ Autor ≥ Eriberto Elias     ≥ Data ≥ 24/03/2003  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Acho o percentual mensal da comissao dos operadores e      ≥±±
±±≥          ≥ atualizo o D2 com base no mes anterior                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ DIPM012                                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Especifico DIPROMED                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥                       ALTERA«¬O                                       ≥±± 
±±≥ Data     ≥ DescriÁ„o                                                  ≥±±
±±------------------------------------------------------------------------≥±±
±±≥ 01/08/08 ≥ Modificado para rodar no schedule - MCVN                   ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

User Function DIPM012(aWork)
Local _xArea      := GetArea()
Local lEnd        := .t. 
Private cPerg     := "DIPM12"   
Private cWorkFlow := ""
Private cWCodEmp  := ""  // MCVN - 04/10/2010
Private cWCodFil  := ""  // MCVN - 04/10/2010 

If ValType(aWork) <> 'A'
	cWorkFlow := "N"   
	cWCodEmp  := cEmpAnt// MCVN - 04/10/2010
    cWCodFil  := cFilAnt// MCVN - 04/10/2010
    U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 13/12/2005 - Gravando o nome do Programa no SZU
Else    
	cWorkFlow := aWork[1]    // MCVN - 04/10/2010
	cWCodEmp  := aWork[3]	 // MCVN - 04/10/2010
    cWCodFil  := aWork[4]    // MCVN - 04/10/2010
Endif                        

If cWorkFlow == "S"  // MCVN - 04/10/2010  
	PREPARE ENVIRONMENT EMPRESA cWCodEmp FILIAL cWCodFil FUNNAME "DIPM012"
EndIf

If cWorkFlow = "N" 

	If !(Upper(U_DipUsr())  $  "MCANUTO/DDOMINGOS/VQUEIROZ/VEGON/RBORGES")
		MsgBox("VocÍ n„o È o Maximo","Atencao","OK")
		Return()
	Else
		If Day(dDataBase) > 5
			MsgBox("A data n„o È a ideal para alteraÁ„o, volte a database do sistema!","Atencao","OK")
			Return()			
		Endif
	Endif
	
	AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI

	If Pergunte(cPerg,.T.)     // Solicita parametros
		IF MsgBox("Calcula o faturamento?","Atencao","YESNO")
			Processa({|lEnd| AchaValor()},"Achando o valor do faturamento por operador")
		EndIf
		IF MsgBox("Altera o percentual nas notas?","Atencao","YESNO")
		   	Processa({|lEnd| ArrumaD2()},"Alterando o percentual da comissao nas notas")
		EndIF	
	EndIf    
Else   
    MV_PAR01 := SUBSTR(dtos(DATE()-10),5,2)+"/"+SUBSTR(dtos(DATE()-10),1,4)
   
	ConOut("--------------------------")
	ConOut('DIPM012 agendado - Inicio Achavalor - '+MV_PAR01+Time())
	ConOut("--------------------------")
 	   		If cWCodEmp+cWCodFil = '0104'			
				AchaValor()   
			EndIf	                           
				
	ConOut("--------------------------")
	ConOut('DIPM012 agendado - Fim Achavalor - ' +Time())
    ConOut("--------------------------")
	
	   
	ConOut("--------------------------")
	ConOut('DIPM012 agendado - Inicio ArrumaD2-' +MV_PAR01+Time())
	ConOut("--------------------------")
	 	
				ArrumaD2()	
				
	ConOut("--------------------------")
	ConOut('DIPM012 agendado - Fim ArrumaD2- ' +Time())
    ConOut("--------------------------")
	
Endif         

RestArea(_xArea)                                  
Return

//////////////////////////////////////////////////////////////////////
Static Function AchaValor()
Local _nPerc := 0
Local _nValFat := 0
Local cU7_CODVEN
Local cU7_NOME
Local cU7_COD
Local aValFat := {}
Local cFornVend := AllTrim(GETNEWPAR("MV_FORNVEN",""))

ProcRegua(1000)
For _x:=1 to 20
	IncProc(OemToAnsi("Aguarde....."))
Next

/*QRY1 :=        " SELECT U7_CODVEN, U7_NOME, U7_COD, LEFT(F2_EMISSAO,6) MESANO, SUM(F2_VALFAT) F2_VALOR"
QRY1 := QRY1 + " FROM " + RetSQLName("SU7")
QRY1 := QRY1 + " INNER JOIN " + RetSQLName("SF2")
QRY1 := QRY1 + " ON U7_CODVEN = F2_VEND1 "
QRY1 := QRY1 + " WHERE "
QRY1 := QRY1 + RetSQLName("SU7")+".D_E_L_E_T_ <> '*'" + " AND "
QRY1 := QRY1 + RetSQLName("SF2")+".D_E_L_E_T_ <> '*'" + " AND "
QRY1 := QRY1 + "LEFT(F2_EMISSAO,6) = '"+SUBSTR(MV_PAR01,4,4)+SUBSTR(MV_PAR01,1,2)+"' "
//QRY1 := QRY1 + "F2_FILIAL = '" +xFilial("SF2")+"'"
QRY1 := QRY1 + "group by U7_CODVEN, U7_NOME, U7_COD, left(F2_EMISSAO,6)"
QRY1 := QRY1 + "ORDER BY U7_CODVEN"
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
*/
//*********************** QUERY DO FATURAMENTO GERAL **************************************
QRY1 := "SELECT LEFT(F2_EMISSAO,6) MESANO, F2_VEND1, F2_VEND2, U7_COD, U7_CODVEN, U7_NOME, D2_FORNEC, SUM(D2_TOTAL+D2_SEGURO+D2_VALFRE+D2_DESPESA) F2_VALFAT"
//QRY1 += " FROM " +  RetSQLName('SF2') + ',' + RetSQLName('SD2') + ',' + RetSQLName('SF4')+ ',' + 'SU7010' //RetSQLName('SU7')
QRY1 += " FROM SF2010, SD2010, SF4010, SU7010 "
QRY1 += " WHERE LEFT(F2_EMISSAO,6) = '"+SUBSTR(MV_PAR01,4,4)+SUBSTR(MV_PAR01,1,2)+"' AND "
QRY1 += " F2_TIPO = 'N' AND "
QRY1 += " F2_FILIAL = D2_FILIAL AND "  
QRY1 += " F4_FILIAL = '04' AND "
QRY1 += " D2_FILIAL = '04' AND "
QRY1 += " F2_FILIAL = '04' AND "
QRY1 += " F2_DOC    = D2_DOC AND "
QRY1 += " F2_SERIE  = D2_SERIE AND "
QRY1 += " D2_TES    = F4_CODIGO AND "
QRY1 += " F4_DUPLIC = 'S' AND "
QRY1 += " F2_VEND1  = U7_CODVEN AND "
QRY1 += " SF2010.D_E_L_E_T_ <> '*' AND "
QRY1 += " SD2010.D_E_L_E_T_ <> '*' AND "
QRY1 += " SF4010.D_E_L_E_T_ <> '*' AND "
QRY1 += " SU7010.D_E_L_E_T_ <> '*' "              
QRY1 += "GROUP BY LEFT(F2_EMISSAO,6), F2_VEND1, F2_VEND2, U7_COD, U7_CODVEN, U7_NOME, D2_FORNEC "
QRY1 += " UNION "   
QRY1 += "SELECT LEFT(F2_EMISSAO,6) MESANO, F2_VEND1, F2_VEND2, U7_COD, U7_CODVEN, U7_NOME, D2_FORNEC, SUM(D2_TOTAL+D2_SEGURO+D2_VALFRE+D2_DESPESA) F2_VALFAT"
QRY1 += " FROM SF2010, SD2010, SF4010, SU7010 "
QRY1 += " WHERE LEFT(F2_EMISSAO,6) = '"+SUBSTR(MV_PAR01,4,4)+SUBSTR(MV_PAR01,1,2)+"' AND "
QRY1 += " F2_TIPO = 'N' AND "
QRY1 += " F2_FILIAL = D2_FILIAL AND "
QRY1 += " F4_FILIAL = '01' AND "
QRY1 += " D2_FILIAL = '01' AND "
QRY1 += " F2_FILIAL = '01' AND "
QRY1 += " F2_DOC    = D2_DOC AND "
QRY1 += " F2_SERIE  = D2_SERIE AND "
QRY1 += " D2_TES    = F4_CODIGO AND "
QRY1 += " F4_DUPLIC = 'S' AND "
QRY1 += " F2_VEND1  = U7_CODVEN AND "
QRY1 += " SF2010.D_E_L_E_T_ <> '*' AND "
QRY1 += " SD2010.D_E_L_E_T_ <> '*' AND "
QRY1 += " SF4010.D_E_L_E_T_ <> '*' AND "
QRY1 += " SU7010.D_E_L_E_T_ <> '*' "              
QRY1 += "GROUP BY LEFT(F2_EMISSAO,6), F2_VEND1, F2_VEND2, U7_COD, U7_CODVEN, U7_NOME, D2_FORNEC "
QRY1 += "ORDER BY U7_CODVEN"

#xcommand TCQUERY <sql_expr> [ALIAS <a>] [<new: NEW>] [SERVER <(server)>] [ENVIRONMENT <(environment)>] => dbUseArea(<.new.>,"TOPCONN",TCGENQRY(<(server)>,<(environment)>,<sql_expr>),<(a)>, .F., .T.)
// Processa Query SQL E Abre uma workarea com o resultado da query
DbCommitAll()
TcQuery QRY1 NEW ALIAS "QRY1"

memowrite('dipm012_f.SQL',QRY1) // Grava em txt

//********************************** QUERY DAS DEVOLU«’ES **************************************
QRY2 := "SELECT LEFT(D1_DTDIGIT,6) MESANO, F2_VEND1, F2_VEND2, U7_COD, U7_CODVEN, U7_NOME, D2_FORNEC, SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA) D1_TOTAL"
//QRY2 += " FROM " +  RetSQLName('SD1') + ',' + RetSQLName('SF2') + ',' + RetSQLName('SD2') + ',' + RetSQLName('SF4') + ',' + 'SU7010' //RetSQLName('SU7')
QRY2 += " FROM SD1010, SF2010, SD2010 , SF4010, SU7010 "
QRY2 += " WHERE D1_TIPO = 'D' AND "
QRY2 += " LEFT(D1_DTDIGIT,6) = '"+SUBSTR(MV_PAR01,4,4)+SUBSTR(MV_PAR01,1,2)+"' AND "
QRY2 += " D1_TES = F4_CODIGO AND "
QRY2 += " F4_DUPLIC = 'S' AND "
QRY2 += " F4_FILIAL = '04' AND " 
QRY2 += " F2_FILIAL = '04' AND "
QRY2 += " D2_FILIAL = '04' AND "
QRY2 += " D1_FILIAL = '04' AND "
QRY2 += " D1_FILIAL =  D2_FILIAL AND "
QRY2 += " D1_NFORI =   D2_DOC AND "
QRY2 += " D1_SERIORI = D2_SERIE AND "
QRY2 += " D1_ITEMORI = D2_ITEM AND "
QRY2 += " D2_FILIAL =  F2_FILIAL AND "
QRY2 += " D2_DOC =     F2_DOC AND "
QRY2 += " D2_SERIE =   F2_SERIE AND "
QRY2 += " F2_VEND1 = U7_CODVEN AND "
QRY2 += " SD1010.D_E_L_E_T_ <> '*' AND "
QRY2 += " SD2010.D_E_L_E_T_ <> '*' AND "
QRY2 += " SF2010.D_E_L_E_T_ <> '*' AND "
QRY2 += " SF4010.D_E_L_E_T_ <> '*' AND "
QRY2 += " SU7010.D_E_L_E_T_ <> '*' "
QRY2 += "GROUP BY LEFT(D1_DTDIGIT,6), F2_VEND1, F2_VEND2, U7_COD, U7_CODVEN, U7_NOME, D2_FORNEC "
QRY2 += " UNION "
QRY2 += "SELECT LEFT(D1_DTDIGIT,6) MESANO, F2_VEND1, F2_VEND2, U7_COD, U7_CODVEN, U7_NOME, D2_FORNEC, SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA) D1_TOTAL"
//QRY2 += " FROM " +  RetSQLName('SD1') + ',' + RetSQLName('SF2') + ',' + RetSQLName('SD2') + ',' + RetSQLName('SF4') + ',' + 'SU7010' //RetSQLName('SU7')
QRY2 += " FROM SD1010, SF2010, SD2010 , SU7010 , SF4010"
QRY2 += " WHERE D1_TIPO = 'D' AND "
QRY2 += " LEFT(D1_DTDIGIT,6) = '"+SUBSTR(MV_PAR01,4,4)+SUBSTR(MV_PAR01,1,2)+"' AND "
QRY2 += " D1_TES = F4_CODIGO AND "
QRY2 += " F4_DUPLIC = 'S' AND "
QRY2 += " F4_FILIAL = '01' AND "
QRY2 += " F2_FILIAL = '01' AND "
QRY2 += " D2_FILIAL = '01' AND "
QRY2 += " D1_FILIAL = '01' AND "
QRY2 += " D1_FILIAL =  D2_FILIAL AND "
QRY2 += " D1_NFORI =   D2_DOC AND "
QRY2 += " D1_SERIORI = D2_SERIE AND "
QRY2 += " D1_ITEMORI = D2_ITEM AND "
QRY2 += " D2_FILIAL =  F2_FILIAL AND "
QRY2 += " D2_DOC =     F2_DOC AND "
QRY2 += " D2_SERIE =   F2_SERIE AND "
QRY2 += " F2_VEND1 = U7_CODVEN AND "
QRY2 += " SD1010.D_E_L_E_T_ <> '*' AND "
QRY2 += " SD2010.D_E_L_E_T_ <> '*' AND "
QRY2 += " SF2010.D_E_L_E_T_ <> '*' AND "
QRY2 += " SF4010.D_E_L_E_T_ <> '*' AND "
QRY2 += " SU7010.D_E_L_E_T_ <> '*' "
QRY2 += "GROUP BY LEFT(D1_DTDIGIT,6), F2_VEND1, F2_VEND2, U7_COD, U7_CODVEN, U7_NOME, D2_FORNEC "
QRY2 += "ORDER BY U7_CODVEN"

// Processa Query SQL e Abre uma workarea com o resultado da query
DbCommitAll()
TcQuery QRY2 NEW ALIAS "QRY2"

memowrite('dipm012_d.SQL',QRY2) // Grava em txt   
// Vamos calcular o faturamento por vendedor do CC

dbSelectArea("QRY1")
While QRY1->(!Eof())
	IncProc(OemToAnsi("Operador: " + QRY1->U7_NOME))
	
	_nValFat   := 0
	cU7_CODVEN := QRY1->U7_CODVEN
	cU7_NOME      := QRY1->U7_NOME
	cU7_COD        := QRY1->U7_COD
	
	While QRY1->U7_CODVEN = cU7_CODVEN
		
		If Empty(QRY1->F2_VEND2) .OR. ;
			(!Empty(QRY1->F2_VEND2) .AND. !(QRY1->D2_FORNEC $ cFornVend))
			
			_nValFat += QRY1->F2_VALFAT
			
		EndIf
		
		QRY1->(dbSkip())
		
	End //While QRY1->U7_CODVEN = cU7_CODVEN
	
	_nPos := Ascan(aValFat,{|y| y[1] == cU7_CODVEN})
	If _nPos == 0
		Aadd(aValFat,{cU7_CODVEN, cU7_NOME, cU7_COD, MV_PAR01, _nPerc, _nValFat})
	Else
		aValFat[_nPos,6] += _nValFat
	EndIf
	                                                                                                        
End //While QRY1->(!Eof())
                                                                  
// Vamos calcular as devoluÁoes por vendedor do CC
dbSelectArea("QRY2")
While QRY2->(!Eof())
	IncProc(OemToAnsi("Operador: " + QRY2->U7_NOME))
	
	_nValFat   := 0
	cU7_CODVEN := QRY2->U7_CODVEN
	cU7_NOME   := QRY2->U7_NOME
	cU7_COD    := QRY2->U7_COD
	
	While QRY2->U7_CODVEN = cU7_CODVEN
		
		If Empty(QRY2->F2_VEND2) .OR. ;
			(!Empty(QRY2->F2_VEND2) .AND. !(QRY2->D2_FORNEC $ cFornVend))
			
			_nValFat -= QRY2->D1_TOTAL
			
		EndIf
		
		QRY2->(dbSkip())
		
	End //While QRY2->U7_CODVEN = cU7_CODVEN
	
	_nPos := Ascan(aValFat,{|y| y[1] == cU7_CODVEN})
	If _nPos == 0
		Aadd(aValFat,{cU7_CODVEN, cU7_NOME, cU7_COD, MV_PAR01, _nPerc, _nValFat})
	Else
		aValFat[_nPos,6] += _nValFat
	EndIf
	
End //While QRY2->(!Eof())
 
For ee := 1 TO Len(aValFat)
	_nPerc := 0
	dbSelectArea("SZE")
	dbSetOrder(1)
	SZE->(dbGoBottom())
	While SZE->(!BOF())
		If aValFat[ee,6] > SZE->ZE_FAIXA
			_nPerc := SZE->ZE_PERC
			Exit
		EndIf
		SZE->(dbSkip(-1))
	EndDo
	
	dbSelectArea("SA3")
	dbSetOrder(1)
	SA3->(dbSeek(xFilial('SA3')+aValFat[ee,1]))
	If SA3->A3_PERCINI > 0 .AND. SA3->A3_PERCINI > _nPerc
		_nPerc := SA3->A3_PERCINI
	EndIf
	
	dbSelectArea("SZF")
	dbSetOrder(1)
	If SZF->(dbSeek(xFilial('SZF')+aValFat[ee,1]+mv_par01))
		RecLock("SZF",.F.)
		ZF_PERC   := 0.90 //_nPerc - fixado em 0.90 dia 01/07/2019                    
		ZF_OPER   := If(Empty(Alltrim(ZF_OPER)),aValFat[ee,3],ZF_OPER) // MCVN - 10/06/09
		If ZF_FATURAM == 0  
			ZF_PROCEM := DATE()
		Else
			ZF_REPROC := DATE()
		Endif
		ZF_FATURAM:= aValFat[ee,6] 
	Else
		RecLock("SZF",.T.)
		ZF_FILIAL := xFilial('SZF')
		ZF_VEND   := aValFat[ee,1]
		ZF_NOMVEND:= aValFat[ee,2]
		ZF_OPER   := aValFat[ee,3]
		ZF_MESANO := mv_par01
		ZF_PERC   := 0.90//_nPerc - fixado em 0.90 dia 01/07/2019
		ZF_FATURAM:= aValFat[ee,6]
		ZF_PROCEM := DATE()
	EndIf
	SZF->(MsUnLock())
	
Next

QRY1->(dbCloseArea())
QRY2->(dbCloseArea())

Return
/////////////////////////////////////////////////////////////////////////////
Static Function ArrumaD2()
Local _cMesBase := MV_PAR01    
Local cFornVend := AllTrim(GETNEWPAR("MV_FORNVEN",""))

ProcRegua(2200)
For _x:=1 to 400
	IncProc(OemToAnsi("Aguarde....."))
Next

  // MCVN - 31/07/2007 
  If SubStr(mv_par01,4,4)+SubStr(mv_par01,1,2) < '200707' 
  	If SubStr(mv_par01,1,2) == '01'
		_cMesBase := '12/'+Str(Val(SubStr(mv_par01,4,4))-1,4,0)
	Else
		_cMesBase := StrZero(Val(SubStr(mv_par01,1,2))-1,2,0)+'/'+Str(Val(SubStr(mv_par01,4,4)),4,0)
	EndIf
/*  Else         
	If SubStr(mv_par01,1,2) == '01'
		_cMesBase := '12/'+Str(Val(SubStr(mv_par01,4,4)),4,0)
	Else
		_cMesBase := StrZero(Val(SubStr(mv_par01,1,2)),2,0)+'/'+Str(Val(SubStr(mv_par01,4,4)),4,0)
	EndIf */
  Endif
  
QRY2 := "SELECT ZF_VEND, ZF_PERC, F2_DOC, F2_SERIE, F2_VEND2, F2_CLIENTE, F2_FILIAL, A3_TIPO"
QRY2 += " FROM SZF010 "
QRY2 += " INNER JOIN SF2010 "
QRY2 += " ON ZF_VEND = F2_VEND1 "  
QRY2 += " INNER JOIN SA3010 "
QRY2 += " ON ZF_VEND = A3_COD "// MCVN - 09/06/09     
QRY2 += " WHERE "
QRY2 += " SZF010.D_E_L_E_T_ <> '*' AND "
QRY2 += " SF2010.D_E_L_E_T_ <> '*' AND "
QRY2 += " SA3010.D_E_L_E_T_ <> '*' AND " // MCVN - 09/06/09     
QRY2 += " ZF_MESANO = '"+_cMesBase+"'  AND "
QRY2 += " A3_TIPO = 'I' AND "  // MCVN - 09/06/09        
QRY2 += " F2_FILIAL = '"+xFilial("SF2")+"' AND "       
QRY2 += " LEFT(F2_EMISSAO,6) = '"+SUBSTR(MV_PAR01,4,4)+SUBSTR(MV_PAR01,1,2)+"' " //AND "
QRY2 += " ORDER BY ZF_VEND, F2_DOC, F2_SERIE"
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
DbCommitAll()
TcQuery QRY2 NEW ALIAS "QRY2"         // Abre uma workarea com o resultado da query

DbSelectArea("QRY2")

While QRY2->(!Eof())
	IncProc(OemToAnsi("Vendedor: " + QRY2->ZF_VEND+'  -  Nota: '+QRY2->F2_DOC))
	
	dbSelectArea("SD2")
	dbSetOrder(3)
	If SD2->(dbSeek(xFilial('SD2')+QRY2->F2_DOC+QRY2->F2_SERIE))
		While SD2->D2_FILIAL == xFilial('SD2') .And. SD2->D2_DOC == QRY2->F2_DOC .And. SD2->D2_SERIE == QRY2->F2_SERIE .AND.;
		      SD2->D2_CLIENTE == QRY2->F2_CLIENTE .AND. SD2->D2_FILIAL == QRY2->F2_FILIAL 
			
			If  Left(DTOS(SD2->D2_EMISSAO),6) == SUBSTR(MV_PAR01,4,4)+SUBSTR(MV_PAR01,1,2)               
			
				If Empty(QRY2->F2_VEND2) .OR. (!Empty(QRY2->F2_VEND2) .AND. !(SD2->D2_FORNEC $ cFornVend))		
				    If (DateDiffDay( D2_EMISSAO , D2_DTVALID ) > 180) .OR. !(SD2->D2_COMIS1 = 10 .AND. SD2->D2_FORNEC $ '000996/100275') //Mantem a comiss„o para venda com validade menor que 6 meses para Televendas ou se for promoÁ„o SteriPacks/NS	
						RecLock("SD2",.F.)
    	            	SD2->D2_COMIS1 := QRY2->ZF_PERC // A PARTIR DE JULHO
						SD2->D2_COMIS2 := 0
						SD2->(MsUnLock())   
					EndIf
				Else
					RecLock("SD2",.F.)
					SD2->D2_COMIS1 := 0
					SD2->(MsUnLock())
				EndIf
				
			Endif           
			
			SD2->(dbSkip())
		EndDo
	EndIf
	
	/*	dbSelectArea("SE1")
	dbSetOrder(1)
	If SE1->(dbSeek(xFilial('SE1')+'UNI'+QRY2->F2_DOC))
	While SE1->E1_FILIAL == xFilial('SE1') .And. SE1->E1_NUM == QRY2->F2_DOC .And. SE1->E1_PREFIXO == 'UNI'
	RecLock("SE1",.F.)
	SE1->E1_COMIS1 := QRY2->ZF_PERC
	SE1->(MsUnLock())
	SE1->(dbSkip())
	EndDo
	EndIf
	
	If SE1->(dbSeek(xFilial('SE1')+'1  '+QRY2->F2_DOC))
	While SE1->E1_FILIAL == xFilial('SE1') .And. SE1->E1_NUM == QRY2->F2_DOC .And. SE1->E1_PREFIXO == '1  '
	RecLock("SE1",.F.)
	SE1->E1_COMIS1 := QRY2->ZF_PERC
	SE1->(MsUnLock())
	SE1->(dbSkip())
	EndDo
	EndIf
	*/
	
	dbSelectArea("QRY2")
	QRY2->(dbSkip())
EndDo
dbSelectArea("QRY2")
QRY2->(dbCloseArea())
Return
/////////////////////////////////////////////////////////////////////////////
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥VALIDPERG ≥ Autor ≥                       ≥ Data ≥          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Verifica as perguntas inclu°ndo-as caso nÑo existam        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ Especifico para Clientes Microsiga                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Qual Mes/Ano        ?","","","mv_ch1","C", 7,0,0,"G","cMesAno","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",''})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		SX1->(MsUnlock())
	Endif
Next

dbSelectArea(_sAlias)
Return
///////////////////////////////////////////////////////////////////////////
