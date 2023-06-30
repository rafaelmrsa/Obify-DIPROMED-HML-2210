#Include "Protheus.ch"

Static _aDados
Static _aBack

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPM_B1   ºAutor  ³Microsiga           º Data ³  04/20/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPM_B1()
Local aSays := {}
Local aButtons := {}
Local nOpca,cCadastro

If !(Upper(U_DipUsr()) $ 'MCANUTO/EELIAS/DDOMINGOS/VQUEIROZ/VEGON/RBORGES/RLOPES')
	MSGSTOP("Voce nao é o MAXIMO","Usuario sem autorizacao!")
	Return
EndIf

If Type("INCLUI") == "U"
	PRIVATE INCLUI := .T.
Endif
If Type("ALTERA") == "U"
	PRIVATE ALTERA := .F.
Endif


AADD(aSays, "Este programa tem o objetivo de realizar replicação dos produtos acabados ")
AADD(aSays, "da empresa HQ/Matriz para Dipromed CD e Matriz")

AADD(aButtons, { 1,.T.,{|| nOpca := 1,	Processa({||ProcAux()}, "Aguarde !!! Iniciando leitura das informações"),FechaBatch()  }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

If cEmpAnt + cFilAnt == "0401"
	FormBatch( cCadastro, aSays, aButtons )
Else
	MsgAlert("Rotina habilitada apenas para HQ/Matriz","Atenção")
EndIf

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPM_B1   ºAutor  ³Microsiga           º Data ³  04/20/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcAux()
Local _lRet 		:= .T.
Local _cQuery	 	:= ""
Local _cAliasTRB 	:= GetNextAlias()
Local _aArea 		:= GetArea()
Local nHandle	 	:= 0
Local nSecIni		:= seconds()
Local _nLoop		:= 0
Local _aEmpr		:= {{"01","01"},;
{"01","04"}}

Local _cEmpOld	:= cEmpAnt
Local _cFilOld	:= cFilAnt
Local _aStru    := SB1->( DbStruct() )
Local nI

Private lMsErroAuto := .F.

//-- Fazer Selecao dos Produtos a serem migrados
_cQuery	:= " SELECT * " //+ " TOP 10 * "
// _cQuery	+= " 	B1.R_E_C_N_O_ B1RECNO, B1_COD"
_cQuery	+= " FROM "+RetSqlName("SB1")+" B1 "
_cQuery	+= " WHERE"
_cQuery	+= "     B1_FILIAL         = '"+xFilial("SB1")+"'"
_cQuery	+= "     AND B1.D_E_L_E_T_ = ' '"
_cQuery	+= "     AND B1_TIPO       = 'PA'"
_cQuery	+= "     AND B1_DESC LIKE '%HQ%'"
_cQuery += " ORDER BY B1.R_E_C_N_O_  "

_aStru := SB1->( DbStruct() )

For _nLoop := 1 To Len(_aEmpr)
	
	If _aEmpr[_nLoop][1] != cEmpAnt
		GetEmpr(_aEmpr[_nLoop][1]+_aEmpr[_nLoop][2])
	Else
		cFilAnt := _aEmpr[_nLoop][2]
	EndIf
	
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAliasTRB,.T.,.T.)
	//---------------------------------------------------------------------------------------------------------------
	// JBS 10/05/2010 - Configura as propriedades dos campos da query conforme o SB1 destino esta definido.
	//---------------------------------------------------------------------------------------------------------------
	For ni := 1 to Len(_aStru)
		If _aStru[ni,2] != 'C'
			TCSetField(_cAliasTRB, _aStru[ni,1], _aStru[ni,2],_aStru[ni,3],_aStru[ni,4])
		Endif
	Next
	//---------------------------------------------------------------------------------------------------------------
	Do While (_cAliasTRB)->(!Eof())
		IncProc("Processando o Produto "+Alltrim((_cAliasTRB)->B1_COD))
		//---------------------------------------------------------------------------------------------------------------
		// JBS 10/05/2010 - Cria as variaveis de memoria de acordo o que foi lido da query, para ganho de performance, em virtude à troca de empresa.
		//---------------------------------------------------------------------------------------------------------------
		For nI := 1 to Len(_aStru)
			cCpoDes  := 'M->' + _aStru[nI,1]
			cCpoOri  := _cAliasTRB + '->' + _aStru[nI,1]
			&cCpoDes := &cCpoOri
		Next nI
		//---------------------------------------------------------------------------------------------------------------
		lMsErroAuto := .F.
		
		U_SvMemSB1(.T.) //-- Guarda Array com variáveis de Memoria para uso posterior na gravacao
		
		U_CpySB1(_aEmpr[_nLoop][1],_aEmpr[_nLoop][2],,.T.) //-- Copia para empresa/filial posicionada
		
		If lMsErroAuto
			
			If _lRet
				If File("ERROB1_"+Dtos(dDataBase)+".TXT")
					fErase("ERROB1"+Dtos(dDataBase)+".TXT")
				EndIf
				nHandle := MsfCreate("ERROB1"+Dtos(dDataBase)+".TXT",0)
			EndIf
			
			If nHandle > 0
				fWrite(nHandle, cEmpAnt+cFilAnt+":"+(_cAliasTRB)->B1_COD+chr(13)+chr(10))
			EndIf
			
			_lRet := .F.
		EndIf
		(_cAliasTRB)->(DbSkip())
	EndDo
	
	(_cAliasTRB)->(DbCloseArea())
Next _nLoop

If cEmpAnt != _cEmpOld
	GetEmpr(_cEmpOld+_cFilOld)
Else
	cFilAnt := _cFilOld
EndIf

RestArea(_aArea)

If _lRet
	MsgInfo("Processo concluído com êxito! "+Chr(13)+Chr(10)+"Tempo Processamento: "+AllTrim(Str(seconds()-nSecIni))+" segundos")
Else
	MsgAlert("Problemas no decorrer do processo! "+Chr(13)+Chr(10)+"Tempo Processamento: "+AllTrim(Str(seconds()-nSecIni))+" segundos")
	If nHandle > 0
		fClose(nHandle)
	EndIf
EndIf

Return _lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CpySB1    ºAutor  ³Microsiga           º Data ³  04/13/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Replica as informações para as demais empresas, caso tenha º±±
±±º          ³ sido salva                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CpySB1(cParEmp,cParFilial,lExclusao,lTela)
//Local _aArea	:= U_SvAllAreas() //-- Funcão de Teste
Local _aArea	:= {SM0->(GetArea()),;
SB1->(GetArea()),;
SB2->(GetArea()),;
SB3->(GetArea()),;
SB5->(GetArea()),;
SX3->(GetArea()),;
GetArea(); //-- Deixar este por ultimo sempre
}
Local _cEmpOld	:= cEmpAnt
Local _cFilOld	:= cFilAnt
Local _aDadosB1	:= U_SvMemSB1()
Local _aDadosOk := {}
Local _nOpc		:= 0
Local _lIncOld	:= INCLUI
Local _lAltOld	:= ALTERA
Local nCont
Local _cNaoAtual:= "B1_PICMRET/B1_PICMENT/B1_ARTIGST/B1_DREVFIS"
Local _lAtuCampo:= .F.
Local _aButPerg := {}

Private _cSimAtual:= ""
DEFAULT lExclusao	:= .F.
DEFAULT lTela		:= .T.

//-- Tratamento de Atualização de campos somente para réplicas entre Dipromed's: D'Leme 10/10/2011
If cEmpAnt == "01"
	_cNaoAtual += "/B1_TE/B1_TS"
	_cSimAtual:= "B1_COD/" + GetNewPar("ES_B1_INCL","")+GetNewPar("ES_B1_INC1","")+GetNewPar("ES_B1_INC2","")+GetNewPar("ES_B1_INC3","")+GetNewPar("ES_B1_INC4","")
EndIf
//Giovani Zago
If cEmpAnt == "04"
	_cNaoAtual := ""   
	_cSimAtual:= "B1_COD/" + GetNewPar("ES_B1_INCL","")+GetNewPar("ES_B1_INC1","")+GetNewPar("ES_B1_INC2","")+GetNewPar("ES_B1_INC3","")+GetNewPar("ES_B1_INC4","")
EndIf

If Type("lMsErroAuto") == "U"
	Private lMsErroAuto
EndIf
lMsErroAuto := .F.

If Len(_aDadosB1) > 0
	
	If cParEmp != cEmpAnt
		GetEmpr(cParEmp+cParFilial)
	Else
		cFilAnt := cParFilial
	EndIf
	
	SB1->( DbSetOrder(1) )
	If (lExclusao .Or. !(AllTrim(GetCpoSB1("B1_TIPO")) $ "PA/MC/MP/PI/BN/PV")).And. SB1->(DbSeek(xFilial("SB1") + GetCpoSB1("B1_COD")))
		_nOpc 	:= 5 //-- Exclusao
		INCLUI	:= .F.
		ALTERA	:= .F.
	ElseIf !lExclusao .And. AllTrim(GetCpoSB1("B1_TIPO")) $ "PA/MC/MP/PI/BN/PV" .And. SB1->(DbSeek(xFilial("SB1") + GetCpoSB1("B1_COD")))
		_nOpc	:= 4 //-- Alteração
		INCLUI	:= .F.
		ALTERA	:= .T.
	ElseIf !lExclusao .And. AllTrim(GetCpoSB1("B1_TIPO")) $ "PA/MC/MP/PI/BN/PV" .And. SB1->(!DbSeek(xFilial("SB1") + GetCpoSB1("B1_COD")))
		_nOpc 	:= 3 //-- Inclusao
		INCLUI	:= .T.
		ALTERA	:= .F.
	EndIf
	
	If !Empty(_nOpc)
		
		If cParEmp == '01'// Se for Dipromed não atualiza os campos de substituição tributária - MCVN 28/12/10
			_aDadosOk := aClone(_aDadosB1)
			_aDadosB1 := {}
			
			
			If _nOpc == 4
				
				If !_lIncOld
					_aButPerg := {"NÃO"} 
					If GetCpoSB1("B1_PRVMINI" ) != GetCpoSB1("B1_PRVMINI" ,.T.) .Or.;
						GetCpoSB1("B1_PRVSUPE") != GetCpoSB1("B1_PRVSUPE",.T.) .Or.;
						GetCpoSB1("B1_PRV1"   ) != GetCpoSB1("B1_PRV1"   ,.T.) .Or.;
						GetCpoSB1("B1_PRVPROM") != GetCpoSB1("B1_PRVPROM",.T.)
						aAdd(_aButPerg,"PREÇOS")
					Else
						_cNaoAtual:= _cNaoAtual+"/B1_PRVMINI/B1_PRVSUPE/B1_PRV1/B1_PRVPROM"
					EndIf    
					
					If  GetCpoSB1("B1_UPRC"  ) != GetCpoSB1("B1_UPRC"  ,.T.) .Or.;
						GetCpoSB1("B1_CUSDIP") != GetCpoSB1("B1_CUSDIP",.T.) .Or.;
						GetCpoSB1("B1_LISFOR") != GetCpoSB1("B1_LISFOR",.T.)
						aAdd(_aButPerg,"CUSTO")
					Else
						_cNaoAtual:= _cNaoAtual+"/B1_UPRC/B1_CUSDIP/B1_LISFOR"
					EndIf
					
					If GetCpoSB1("B1_DESC") != GetCpoSB1("B1_DESC",.T.)
						aAdd(_aButPerg,"DESCRIÇÃO")
					Else
						_cNaoAtual:= _cNaoAtual+"/B1_DESC"
					EndIf
					
					If GetCpoSB1("B1_MSBLQL" ) != GetCpoSB1("B1_MSBLQL",.T.)
						aAdd(_aButPerg,"BLOQUEIO")
					Else
						_cNaoAtual:= _cNaoAtual+"/B1_MSBLQL"
					EndIf
		            If Len(_aButPerg)>2
						aAdd(_aButPerg,"TODOS")
					EndIf
				EndIf                    
			
				If Len(_aButPerg) > 1
					_lAtuCampo := Aviso("Atencao","Existe algum campo que deseja  N Ã O    A T U A L I Z A R ",_aButPerg)
					Do Case
						Case _lAtuCampo == 1
						Case _aButPerg[_lAtuCampo] == "PREÇOS";    	_cNaoAtual:= _cNaoAtual+"/B1_PRVMINI/B1_PRVSUPE/B1_PRV1/B1_PRVPROM"
						Case _aButPerg[_lAtuCampo] == "DESCRIÇÃO"; 	_cNaoAtual:= _cNaoAtual+"/B1_DESC"
						Case _aButPerg[_lAtuCampo] == "BLOQUEIO";  	_cNaoAtual:= _cNaoAtual+"/B1_MSBLQL" 
						Case _aButPerg[_lAtuCampo] == "CUSTO";  	_cNaoAtual:= _cNaoAtual+"/B1_UPRC/B1_CUSDIP/B1_LISFOR"
						Case _aButPerg[_lAtuCampo] == "TODOS";  	_cNaoAtual:= _cNaoAtual+"/B1_PRVMINI/B1_PRVSUPE/B1_PRV1/B1_PRVPROM/B1_DESC/B1_MSBLQL/B1_UPRC/B1_CUSDIP/B1_LISFOR"
						OtherWise
							Return(.F.)
					EndCase
				EndIf
			EndIf
			
			For ncont := 1 To Len(_aDadosOk)
				If INCLUI
					If !(_aDadosOk[nCont][1] $ _cNaoAtual) // não atualiza B1_PICMRET/B1_PICMENT/B1_ARTIGST/B1_DREVFIS/B1_TE/B1_TS
						aAdd(_aDadosB1,{_aDadosOk[nCont][1],_aDadosOk[nCont][2],Nil})
					Endif
				ElseIf ALTERA
					If !(_aDadosOk[nCont][1] $ _cNaoAtual) .And. alltrim(_aDadosOk[nCont][1]) $ _cSimAtual // não atualiza B1_PICMRET/B1_PICMENT/B1_ARTIGST/B1_DREVFIS/B1_TE/B1_TS
					   	aAdd(_aDadosB1,{_aDadosOk[nCont][1],_aDadosOk[nCont][2],Nil})
					Endif
				Endif
			Next nCont
			
		Endif
		
		// Posicionando SA2 para corrigir problema em rotina padrão MATA010(A010PROC) JBS/MCVN - 11/05/10
		SA2->( DbSetOrder(1) )
		SA2->( DbSeek(xFilial('SA2')+GetCpoSB1("B1_PROC")+GetCpoSB1("B1_LOJPROC")) )
		MSExecAuto( { | x, y | MATA010( x, y ) }, _aDadosB1, _nOpc)
		
		If lMsErroAuto .And. lTela
			MostraErro()
		EndIf
	EndIf
	
	If cEmpAnt != _cEmpOld
		GetEmpr(_cEmpOld+_cFilOld)
	Else
		cFilAnt := _cFilOld
	EndIf
	
	INCLUI := _lIncOld
	ALTERA := _lAltOld
	aEval(_aArea,{ |x| RestArea(x) })
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³VET2MSEXECºAutor  ³ Ernani Forastieri  º Data ³  25/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ordena uma vetor que sera usado no MSEXECAUTO conforme     º±±
±±º          ³ a posicao dos campos no SX3                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Vet2MSExec( aVetor, cTabela, lItens )
Local aArea     := GetArea()
Local aAreaSX3  := SX3->( GetArea() )
Local aStrSX3   := {}
Local aStrSX3SF := {}
Local aRet      := {}
Local aAux      := {}
Local nI        := 0
Local nJ        := 0

Default lItens  := .F.

SX3->( dbSetOrder( 4 ) )

If cTabela == NIL
	cTabela := SubStr( aVetor[1][1], 1, At( '_', aVetor[1][1] ) - 1 )
	cTabela := IIf( Len( cTabela ) == 2, 'S' + cTabela, cTabela )
EndIf

SX3->( dbSeek( cTabela ) )

While !SX3->( Eof () ) .AND. SX3->X3_ARQUIVO == cTabela
	
	If Empty( SX3->X3_FOLDER )
		aAdd( aStrSX3SF,  SX3->X3_CAMPO )
	Else
		aAdd( aStrSX3  ,  SX3->X3_CAMPO )
	EndIf
	
	SX3->( dbSkip() )
End

aEval( aStrSX3SF, { |x| aAdd( aStrSX3 , x ) } )

If lItens
	//
	// Faz a classificacao de um vetor de "itens"
	//
	For nI:=1 to Len( aVetor )
		
		aAux := {}
		
		For nJ := 1 to Len( aStrSX3 )
			
			If  ( nPos := aScan( aVetor[nI], { |x| RTrim( aStrSX3[nJ] ) == RTrim( x[1] ) } ) ) <> 0
				aAdd( aAux, aVetor[nI][nPos] )
			EndIf
			
		Next
		
		aAdd( aRet, aAux )
		
	Next
	
Else
	//
	// Faz a classificacao de um vetor simples ou de "cabecalho"
	//
	aAux := {}
	
	For nJ := 1 to Len( aStrSX3 )
		
		If  ( nPos := aScan( aVetor, { |x| RTrim( aStrSX3[nJ] ) == RTrim( x[1] ) } ) ) <> 0
			aAdd( aAux, aVetor[nPos] )
		EndIf
		
	Next
	
	aRet :=  aClone( aAux )
	
EndIf

RestArea( aAreaSX3 )
RestArea( aArea )
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SvMemSB1  ºAutor  ³Microsiga           º Data ³  04/13/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Salva campos de Memória do Produto em array estático para  º±±
±±º          ³ replicacao para outras empresas.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SvMemSB1(_lReset)

Local _cAcreDip := 7
Local _PeCusDip := 15
Local lGrv		:= .T.

DEFAULT _aDados	:= {}
DEFAULT _aBack	:= {}
DEFAULT _lReset	:= .F.


//-- Forca recarregar
If _lReset
	U_ClrMemSB1()
EndIf

If Len(_aDados) == 0
	
	//-- Preparação do Vetor com dados para a ExecAuto
	SX3->(DbSetOrder(1))
	SX3->(DbSeek("SB1"))
	While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == "SB1"
		lGrv := .T.
		If AllTrim(SX3->X3_CAMPO) != "B1_FILIAL" .And. "M->"+AllTrim(SX3->X3_CAMPO) != "U"  //.And. !(AllTrim(SX3->X3_CAMPO) $ "B1_PICMRET/B1_PICMENT/B1_ARTIGST")
			
			If AllTrim(SX3->X3_CAMPO) == "B1_ADMIN"
				cPara := ""
			EndIf
			
			If Valtype(lCopia) == "L" .And. lCopia 
			    If SX3->X3_TIPO<>"N"
					If Empty(&("M->"+AllTrim(SX3->X3_CAMPO))) .And. !Empty(SX3->X3_RELACAO)
						//&("M->"+AllTrim(SX3->X3_CAMPO)) := &(SX3->X3_RELACAO)
						SX3->(DbSkip())
						Loop
					EndIf
				Else 
					If Empty(Str(&("M->"+AllTrim(SX3->X3_CAMPO)))) .And. !Empty(SX3->X3_RELACAO)
						//&("M->"+AllTrim(SX3->X3_CAMPO)) := &(SX3->X3_RELACAO)
						SX3->(DbSkip())
						Loop
					EndIf
				EndIf
			EndIf
			//@Andre Mendes - Obify - 22/07/2021 - trecho comentado para que haja replicação dos campos vazios também
			//If !Empty(&("M->"+AllTrim(SX3->X3_CAMPO))) 
				If (!Empty(Alltrim(SX3->X3_WHEN)) .and. &(Alltrim(SX3->X3_WHEN))) .OR. Empty(Alltrim(SX3->X3_WHEN))				
					aAdd(_aDados,{AllTrim(SX3->X3_CAMPO),&("M->"+AllTrim(SX3->X3_CAMPO)),Nil})
					//-- Inclusço de tratamento para testar alterações: D'Leme 10/10/2011
					If !INCLUI .And. SB1->(FieldPos(SX3->X3_CAMPO)) > 0
						aAdd(_aBack,{AllTrim(SX3->X3_CAMPO),&("SB1->"+AllTrim(SX3->X3_CAMPO)),Nil})
					EndIf
				EndIf
			//EndIf
		EndIf
		
		SX3->(DbSkip())
	EndDo
	
	//-- Ordena uma vetor que sera usado no MSEXECAUTO conforme a posicao do SX3
	_aDados := u_Vet2MSExec( _aDados, "SB1" )
		
EndIf

Return aClone(_aDados)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetCpoSB1 ºAutor  ³Microsiga           º Data ³  04/13/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca conteudo de campo do SB1 salvo no array estatico     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetCpoSB1(cCampo,lBackup)
Local _uRet := CriaVar(cCampo,.T.)
Local _nPos

Default lBackup := .F.

If lBackup .And. !Empty(_aBack)
	_nPos := aScan(_aBack,{|x| AllTrim(x[1]) == AllTrim(cCampo)})
Else
	_nPos := aScan(_aDados,{|x| AllTrim(x[1]) == AllTrim(cCampo)})
EndIf

If _nPos > 0
	If lBackup
		_uRet := _aBack[_nPos][2]
	Else
		_uRet := _aDados[_nPos][2]
	EndIf
EndIf
Return _uRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PutCpoSB1 ºAutor  ³Microsiga           º Data ³  04/13/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Salva informações de campo específico no array estatico    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PutCpoSB1(cCampo,uConteudo)
Local _nPos

If (_nPos := aScan(_aDados,{|x| AllTrim(x[1]) == AllTrim(cCampo)})) > 0
	_aDados[_nPos][2] := uConteudo
EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ClrMemSB1 ºAutor  ³Microsiga           º Data ³  04/13/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Limpa array estatico                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ClrMemSB1()
_aDados := {}
_aBack  := {}
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SvAllAreasºAutor  ³Microsiga           º Data ³  08/31/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Salva os Aliases abertos (em testes)                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SvAllAreas()
Local _aAreas	:= {}
Local _nArea	:= 0

aAdd(_aAreas,SM0->(GetArea()))
aAdd(_aAreas,SX3->(GetArea()))
Do While !Empty(Alias(++_nArea)) .And. !Empty(Alias(++_nArea))
	aAdd(_aAreas,(Alias(_nArea))->(GetArea()))
EndDo
aAdd(_aAreas,GetArea()) //-- Deixar este por ultimo sempre

Return aClone(_aAreas)
