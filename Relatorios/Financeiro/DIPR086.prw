/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR086  ³ Autor ³ Reginaldo Borges   ³ Data ³ 04/01/2016  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relacao dos lancamentos que so têm financeiro difer. de NF ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"  
#INCLUDE "AP5MAIL.CH"        
#INCLUDE "COLORS.CH"

User Function DIPR086()

Local   tamanho  := "G"
Local   titulo   := " TITULOS LANÇADOS SOMENTE NO FINANCEIRO "
Local   titulo2  := "*** TITULOS LANÇADOS SOMENTE NO FINANCEIRO, PERIODO DE: "
Local   cDesc1   := "Relacao dos titulos lancados somente no financeiro"
Local   cDesc2   := "de acordo com as informaoes nos parametros."
Local   cDesc3   := " "
Local   wnrel    := "DIPR086"
Local   cString  := "SE2"
Local   cPerg  	 := "DIPR086"
Private limite   := 220
Private nomeprog := "DIPR086"
Private nLastKey := 0
Private li       :=0
Private nTotGer  := 0
Private aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }

U_DIPPROC(ProcName(0),U_DipUsr())

AjustaSX1(cPerg)

If Pergunte(cPerg,.F.)
	Return
EndIf

wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)

If nLastKey==27
	Set Filter to
	Return( NIL )
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	Set Filter to
	Return( NIL )
Endif

RptStatus({|lEnd| _C730Imp(@lEnd,wnRel,cString,TITULO2+' '+DTOC(MV_PAR01)+' a '+DTOC(MV_PAR02)+" ***")},TITULO2+' '+DTOC(MV_PAR01)+' a '+DTOC(MV_PAR02)+" ***")


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ _C730IMP  ³ Autor ³ Reginaldo Borges    ³ Data ³ 04/01/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/

Static Function _C730Imp(lEnd,WnRel,cString,TITULO)

Local    cQRY        := ""
Local   _aVencimentos:= {}
Local   _cFornec     := ""
Local   _cLoja       := ""
Local   _cDoc        := ""
Local   _nParcel     := 0
Local   _nValor      := 0
Local  cUserImp      := Upper(GetNewPar("ES_DIPR086","SCREATTO/BFERREIRA/RBORGES"))
Local _lContinua     := .F.
Local _cUser         := Upper(U_DipUsr())
Private nTotGer      := 0



If Alltrim(_cUser) $ cUserImp

_lContinua:= MsgYesNo("Gerar relatórios com Impostos?")
	If _lContinua
		
		cQRY := "SELECT E2_FORNECE,E2_LOJA, E2_NUM, E2_PARCELA, E2_TIPO, E2_VENCREA, E2_VALOR, E2_CONDPAG "
		cQRY += " FROM "+RetSqlName("SE2")
		cQRY += " WHERE E2_FILIAL  = '"+xFilial("SE2")+"' "
		cQRY += " AND   E2_EMIS1 BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
		cQRY += " AND   LEFT(E2_ORIGEM,7) = 'MATA100'"
		cQRY += " AND   E2_BAIXA = ''"
		cQRY += " AND   E2_FILORIG = '"+cFilAnt+"' "
		
		If     MV_PAR03 == 1
			cQRY += " AND   E2_TIPO     IN ('"+AllTrim(UPPER(MV_PAR04))+"') "
		ElseIf MV_PAR03 == 2
			cQRY += " AND   E2_TIPO NOT IN ('"+AllTrim(UPPER(MV_PAR04))+"') "
		ElseIf MV_PAR03 == 3
			cQRY += " AND   E2_TIPO <> '' "
		EndIf
		
		If !Empty(MV_PAR05)
			cQRY += " AND   E2_USUARIO IN('','"+AllTrim(Lower(MV_PAR05))+"') "
		EndIf
		
		cQRY += " AND   D_E_L_E_T_ =  '' "
		
		cQRY += " ORDER BY E2_NUM, E2_FORNECE,E2_LOJA, E2_USUARIO, E2_VENCREA,E2_PARCELA "
		
		
		cQRY := ChangeQuery(cQRY)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY),"cQRY",.T.,.T.)

	Else			

		cQRY := "SELECT E2_FORNECE,E2_LOJA, E2_NUM, E2_PARCELA, E2_TIPO, E2_VENCREA, E2_VALOR, E2_CONDPAG "
		cQRY += " FROM "+RetSqlName("SE2")
		cQRY += " WHERE E2_FILIAL  = '"+xFilial("SE2")+"' "
		cQRY += " AND   E2_EMIS1 BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
		cQRY += " AND   LEFT(E2_ORIGEM,4) = 'FINA'"
		cQRY += " AND   E2_BAIXA = ''"
		
		If     MV_PAR03 == 1
			cQRY += " AND   E2_TIPO     IN ('"+AllTrim(UPPER(MV_PAR04))+"') "
		ElseIf MV_PAR03 == 2
			cQRY += " AND   E2_TIPO NOT IN ('"+AllTrim(UPPER(MV_PAR04))+"') "
		ElseIf MV_PAR03 == 3
			cQRY += " AND   E2_TIPO <> '' "
		EndIf
		
		If !Empty(MV_PAR05)
			cQRY += " AND   E2_USUARIO = '"+AllTrim(Lower(MV_PAR05))+"' "
		EndIf
		
		cQRY += " AND   D_E_L_E_T_ =  '' "
		
		If !Empty(MV_PAR05)
			cQRY += " ORDER BY E2_USUARIO,E2_FORNECE,E2_LOJA, E2_NUM, E2_VENCREA,E2_PARCELA "
		Else
			cQRY += " ORDER BY E2_MSIDENT, E2_FORNECE,E2_LOJA, E2_NUM, E2_VENCREA,E2_PARCELA "
		EndIf
		
		
		cQRY := ChangeQuery(cQRY)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY),"cQRY",.T.,.T.)

	EndIf

Else

		cQRY := "SELECT E2_FORNECE,E2_LOJA, E2_NUM, E2_PARCELA, E2_TIPO, E2_VENCREA, E2_VALOR, E2_CONDPAG "
		cQRY += " FROM "+RetSqlName("SE2")
		cQRY += " WHERE E2_FILIAL  = '"+xFilial("SE2")+"' "
		cQRY += " AND   E2_EMIS1 BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
		cQRY += " AND   LEFT(E2_ORIGEM,4) = 'FINA'"
		cQRY += " AND   E2_BAIXA = ''"
		
		If     MV_PAR03 == 1
			cQRY += " AND   E2_TIPO     IN ('"+AllTrim(UPPER(MV_PAR04))+"') "
		ElseIf MV_PAR03 == 2
			cQRY += " AND   E2_TIPO NOT IN ('"+AllTrim(UPPER(MV_PAR04))+"') "
		ElseIf MV_PAR03 == 3
			cQRY += " AND   E2_TIPO <> '' "
		EndIf
		
		If !Empty(MV_PAR05)
			cQRY += " AND   E2_USUARIO = '"+AllTrim(Lower(MV_PAR05))+"' "
		EndIf
		
		cQRY += " AND   D_E_L_E_T_ =  '' "
		
		If !Empty(MV_PAR05)
			cQRY += " ORDER BY E2_USUARIO,E2_FORNECE,E2_LOJA, E2_NUM, E2_VENCREA,E2_PARCELA "
		Else
			cQRY += " ORDER BY E2_MSIDENT, E2_FORNECE,E2_LOJA, E2_NUM, E2_VENCREA,E2_PARCELA "
		EndIf
		
		
		cQRY := ChangeQuery(cQRY)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQRY),"cQRY",.T.,.T.)

Endif


cQRY->(dbGoTop())

@ 0,0 psay AvalImp(Limite)

li := 67

_cFornec := cQRY->E2_FORNECE
_cLoja   := cQRY->E2_LOJA
_cDoc    := cQRY->E2_NUM

While cQRY->(!Eof())
	
	IF li > 66
		_CabecA(TITULO)
	Endif
	
	If (_cFornec+_cLoja == cQRY->E2_FORNECE+cQRY->E2_LOJA) .And. (_cDoc == cQRY->E2_NUM) .And. AllTrim(_cFornec) <> "UNIAO"
		
		aadd(_aVencimentos,{ DtoC(StoD(cQRY->E2_VENCREA))+' ',cQRY->E2_FORNECE+'-'+cQRY->E2_LOJA,cQRY->E2_NUM})
		_nValor := _nValor+cQRY->E2_VALOR
		
	Else
		
		If Len(_aVencimentos) > 0
			
			_nParcel := Len(_aVencimentos)
			
			@ li,000 psay _aVencimentos[1][2]+'  '+Iif(cQRY->E2_TIPO $ 'BD',;
			Substr(Posicione("SA1",1,xFilial("SA1") + AllTrim(Substr(_aVencimentos[1][2],1,6))+AllTrim(Substr(_aVencimentos[1][2],8,9)),"A1_NOME"),1,37),;
			Substr(Posicione("SA2",1,xFilial("SA2") + AllTrim(Substr(_aVencimentos[1][2],1,6))+AllTrim(Substr(_aVencimentos[1][2],8,9)),"A2_NOME"),1,37))
			
			@ li,051 psay AllTrim(_aVencimentos[1][3])
			
			If (_nParcel) <= 2
				If _nParcel == 1
					@ li,064 psay _aVencimentos[1][1]
				Else
					@ li,064 psay _aVencimentos[1][1]+"e "+_aVencimentos[2][1]
				EndIf
			Else
				@ li,064 psay _nParcel
				@ li,067 psay " Parcelas - Primeira "+_aVencimentos[1][1]+"e Ultima "+_aVencimentos[_nParcel][1]
			EndIf
			
			@ li,122 psay _nValor picture "@E 999,999,999.99"
			@ li,141 psay '|           |           |           |           |'
			li++
			@ li,141 psay '|           |           |           |           |'
			li++
			@ li,000 psay Replicate("-",LIMITE-30)
			li++
		EndIf
		_aVencimentos := {}
		aadd(_aVencimentos,{ DtoC(StoD(cQRY->E2_VENCREA))+' ',cQRY->E2_FORNECE+'-'+cQRY->E2_LOJA,cQRY->E2_NUM})
		_cFornec := cQRY->E2_FORNECE
		_cLoja   := cQRY->E2_LOJA
		_cDoc    := cQRY->E2_NUM
		_nValor  := cQRY->E2_VALOR
		
	EndIf
	
	cQRY->(DBSKIP())
	
Enddo

_nParcel := Len(_aVencimentos)

If len(_aVencimentos) > 0
	
	@ li,000 psay _aVencimentos[1][2]+'  '+Iif(cQRY->E2_TIPO $ 'BD',;
	Substr(Posicione("SA1",1,xFilial("SA1") + AllTrim(Substr(_aVencimentos[1][2],1,6))+AllTrim(Substr(_aVencimentos[1][2],8,9)),"A1_NOME"),1,37),;
	Substr(Posicione("SA2",1,xFilial("SA2") + AllTrim(Substr(_aVencimentos[1][2],1,6))+AllTrim(Substr(_aVencimentos[1][2],8,9)),"A2_NOME"),1,37))
	
	@ li,051 psay AllTrim(_aVencimentos[1][3])
	
	If (_nParcel) <= 2
		If _nParcel == 1
			@ li,064 psay _aVencimentos[1][1]
		Else
			@ li,064 psay _aVencimentos[1][1]+"e "+_aVencimentos[2][1]
		EndIf
	Else
		@ li,064 psay _nParcel
		@ li,067 psay " Parcelas - Primeira "+_aVencimentos[1][1]+"e Ultima "+_aVencimentos[_nParcel][1]
	EndIf
	
	@ li,122 psay _nValor picture "@E 999,999,999.99"
	@ li,141 psay '|           |           |           |           |'
	li++
	@ li,141 psay '|           |           |           |           |'
	li++
	@ li,000 psay Replicate("-",LIMITE-30)
	li++
	
EndIf

nTotGer := nTotGer(@nTotGer,_lContinua)
_PE(nTotGer)


If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

cQRY->(DbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ _CabecA ³ Autor ³ Reginaldo Borges     ³ Data ³ 04/01/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
*/
Static Function _CabecA(_titulo)

Local _cUseDig := AllTrim(UPPER(MV_PAR05))

If Empty(_cUseDig) 
	_cUseDig := " "
EndIf

li := 0

@ li,000 psay Replicate("-",LIMITE-30)
li++
@ li,000 psay ALLTRIM(SM0->M0_NOMECOM)+if(cEmpAnt+cFilAnt=='0404',"(CD)","")+ SPACE(10)+'Digitados por: '+_cUseDig+"      CNPJ: "+ALLTRIM(SM0->M0_CGC) // MCVN - 13/12/2009
@ li,limite-30 - Len(AllTrim(_titulo)) psay _titulo
li++
@ li,000 psay Replicate("-",LIMITE-30)
li++
li++                                                                                                                                                                                        
@ li,000 psay 'Fornecedor                                        Documento    Condicao de Pagamento                                               Valor     Secretaria  Diretoria   Financeiro Contabilidade'
li++
@ li,000 psay Replicate("-",LIMITE-30)
li++

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ _PE    ³ Autor ³ Reginaldo Borges      ³ Data ³ 04/01/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
*/
Static Function _PE(nTotGer)

@ li,000 psay Replicate("-",LIMITE-30)
li++
@ li,0111 psay 'Total....:'
@ li,0122 psay nTotGer picture "@E 999,999,999.99"
li++
@ li,000 psay Replicate("-",LIMITE-30)

@ 65,000 psay 'Impresso em '+DtoC(DATE())+' as '+TIME()

Return
	       
                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ nTotGer  ³ Autor ³ Reginaldo Borges    ³ Data ³ 04/01/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
*/

Static Function nTotGer(nTotGer,_lContinua)

Local _cQRY     := ""
Default nTotGer := 0

If _lContinua

	_cQRY := "SELECT SUM(E2_VALOR) AS TOTAL	 "
	_cQRY += " FROM "+RetSqlName("SE2")
	_cQRY += " WHERE E2_FILIAL  = '"+xFilial("SE2")+"' "
	_cQRY += " AND   E2_EMIS1 BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
	_cQRY += " AND   LEFT(E2_ORIGEM,7) = 'MATA100'"
	_cQRY += " AND   E2_BAIXA = ''"
	_cQRY += " AND   E2_FILORIG = '"+cFilAnt+"' "
	
	If     MV_PAR03 == 1
		_cQRY += " AND   E2_TIPO     IN ('"+AllTrim(UPPER(MV_PAR04))+"') "
	ElseIf MV_PAR03 == 2
		_cQRY += " AND   E2_TIPO NOT IN ('"+AllTrim(UPPER(MV_PAR04))+"') "
	ElseIf MV_PAR03 == 3
		_cQRY += " AND   E2_TIPO <> '' "
	EndIf
			
	If !Empty(MV_PAR05)
		_cQRY += " AND   E2_USUARIO IN('','"+AllTrim(Lower(MV_PAR05))+"') "
	EndIf
			
	_cQRY += " AND   D_E_L_E_T_ =  '' "

Else

	_cQRY := "SELECT SUM(E2_VALOR) AS TOTAL	 "
	_cQRY += " FROM "+RetSqlName("SE2")
	_cQRY += " WHERE E2_FILIAL  = '"+xFilial("SE2")+"' "
	_cQRY += " AND   E2_EMIS1 BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
	_cQRY += " AND   LEFT(E2_ORIGEM,4) = 'FINA'"  
	_cQRY += " AND   E2_BAIXA = ''"
	
	If     MV_PAR03 == 1
		_cQRY += " AND   E2_TIPO     IN ('"+AllTrim(UPPER(MV_PAR04))+"') "
	ElseIf MV_PAR03 == 2
		_cQRY += " AND   E2_TIPO NOT IN ('"+AllTrim(UPPER(MV_PAR04))+"') "
	ElseIf MV_PAR03 == 3
		_cQRY += " AND   E2_TIPO <> '' "	
	EndIf
	
	If !Empty(MV_PAR05)
		_cQRY += " AND   E2_USUARIO = '"+AllTrim(Lower(MV_PAR05))+"' "
	EndIf
	
	_cQRY += " AND   D_E_L_E_T_ =  '' "

EndIf

_cQRY := ChangeQuery(_cQRY)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQRY),"_cQRYSE2",.T.,.T.)

nTotGer := _cQRYSE2->TOTAL

_cQRYSE2->(DbCloseArea())

Return(nTotGer)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPR086   ºAutor  ³Reginaldo Borges    º Data ³ 04/01/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AjustaSX1(cPerg)

Local aRegs 	:= {}
DEFAULT cPerg 	:= ""

dbSelectArea("SX1")
dbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Data de     ?","","","mv_ch1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"02","Data ate    ?","","","mv_ch2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"03","Tipo         ","","","mv_ch3","C",1,0,1,"C","","MV_PAR03","Igual a","","","","","Diferente de","","","","","Todos","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"04","Informe tipo Ex.: NF','NFE ","","","mv_ch4","C",20,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","",''})
aAdd(aRegs,{cPerg,"05","Operador    ?","","","mv_ch5","C",15,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","",''})

PlsVldPerg( aRegs )

Return
