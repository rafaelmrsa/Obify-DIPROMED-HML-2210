/*
PONTO.......: MSD2520           PROGRAMA....: MATA520
DESCRIÇÄO...: ANTES DE DELETAR SD2
UTILIZAÇÄO..: Este P.E. esta localizado na funcao A520Dele(); 
              E chamado antes de deletar o registro no SD2.
PARAMETROS..: Nenhum.
RETORNO.....: Nenhum.
OBSERVAÇÖES.: <NENHUM>
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ MSD2520  º Autor ³   Alexandro Dias   º Data ³  24/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza Call Center com informacoes da Nota Fiscal quando º±±
±±º          ³ a mesma e excluida.                                        º±±
±±º          ³                                                            º±±
±±º          ³ E exclui os itens de saldos do pedido                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ºMaximo    ³ Incluído  gravação dos campos D2_QUANT, D2_PRCVEN, D2_TOTALº±±
±±º28/11/08  ³ , D2_COMIS1 E D2_CUSDIP                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
#INCLUDE "RWMAKE.CH"

User Function MSD2520()

Local _xAlias  := GetArea()
Local _AreaSC9 := SC9->(GetArea())
Local _AreaSC6 := SC6->(GetArea())
Local cInd     := "1"
Local cQuery   := ""
Local nQtdNF   := 0 
Local _cEdital := ""

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If !("TMSA200" $ FUNNAME()) // Não entra se a rotina for chamada pelo TMS  - MCVN 01/12/2008
    
    DbCommitAll()

    fGeraSD3(.F.) // JBS 17/08/2010

	cQuery:= "SELECT Count(DISTINCT C9_NFISCAL) AS QTDNF FROM " + RetSqlName("SC9") + " SC9 WHERE SC9.D_E_L_E_T_ <> '*' AND SC9.C9_PEDIDO = '" + SD2->D2_PEDIDO + "'"
	cQuery:= ChangeQuery(cQuery)

	DbCommitAll()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
	nQtdNF:= TMP->QTDNF

	TMP->(dbCloseArea())

	If (nQtdNF == 0)                   
		DbSelectArea("SUA")
		DbSetOrder(8)
		IF DbSeek(xFilial("SUA")+SD2->D2_PEDIDO)
			RecLock("SUA",.F.)
			Replace UA_DOC     With ""
			Replace UA_SERIE   With ""
			Replace UA_EMISNF  With Ctod("")
			Replace UA_STATUS  With "SUP"
			SUA->(MsUnLock())
			SUA->(DbCommit())
		EndIF
	EndIf

	DbSelectArea("SC5")
	DbSetOrder(1)
	IF DbSeek(xFilial("SC5")+SD2->D2_PEDIDO) 
	    _cEdital := SC5->C5_EDITAL
		RecLock("SC5",.F.)
		Replace C5_PRENOTA With ""
		Replace C5_PARCIAL With ""
		SC5->(MsUnLock())
		SC5->(DbCommit())
	EndIF
Endif
////////////////////////////////////////////////////////////////////////////////// Eriberto 25/11/2003
  
// Vamos abrir o SC9 com outro alias deletar os registros criados por nos
DbUseArea(.T.,"TOPCONN",RetSQLName('SC9'),"S9C",.T.,.F.)
While TcCanOpen(RetSQLName('SC9'),RetSQLName('SC9') + cInd)
   ORDLISTADD(RetSQLName('SC9') + cInd)
   cInd:= soma1(cInd)
End

DbSelectArea("S9C")
DbSetOrder(1)
If DbSeek(xFilial("SC9")+SD2->D2_PEDIDO+SD2->D2_ITEMPV)
	While !S9C->(Eof()) ;
	   .and. S9C->C9_FILIAL == xFilial("SD2") ;
		.and. S9C->C9_PEDIDO == SD2->D2_PEDIDO ;
		.and. S9C->C9_ITEM == SD2->D2_ITEMPV
		
		If S9C->C9_QTDORI == 0 .AND. S9C->C9_BLEST <> '10' .AND. S9C->C9_BLCRED <> '10'
			DbSelectArea("SC6")
			DbSetOrder(1)
			If DbSeek(xFilial("SC6")+S9C->C9_PEDIDO+S9C->C9_ITEM)
				RecLock("SC6",.F.)
				SC6->C6_QTDEMP -= S9C->C9_QTDLIB
				SC6->C6_QTDEMP2 -= S9C->C9_QTDLIB2
				SC6->(MsUnLock())
				SC6->(DbCommit())
			EndIf

			DbSelectArea("S9C")
			RecLock("S9C",.F.)
			S9C->(DbDelete())
			S9C->(MsUnLock())
			S9C->(DbCommit())
		EndIf
		DbSelectArea("S9C")
		S9C->(DbSkip())
	End
	
EndIf

DbSelectArea("S9C") // Fecho area que criei - Eriberto 16/02/2007
S9C->(DbCloseArea())
DbSelectArea("SC9")

////////////////////// Eriberto 25/11/2003                       '

DBSELECTAREA("SF4")
DbSetOrder(1)
IF DbSeek(xFilial("SF4")+SD2->D2_TES)
	IF SF4->F4_ESTOQUE <> "N"
		IF SD2->D2_EMISSAO < CTOD("05/05/2002")
			DbSelectArea("SBF")
			DbSetOrder(1)
			IF DbSeek(xFilial("SBF")+"01"+"      EXPEDICAO"+SD2->D2_COD)
				RecLock("SBF",.F.)
				Replace SBF->BF_QUANT With SBF->BF_QUANT + SD2->D2_QUANT
				SBF->(MsUnLock())
				SBF->(DbCommit())
			ELSE
				RECLOCK("SBF",.T.)
				SBF->BF_FILIAL  := xFilial('SBF')  // JBS - 18/08/2010 - Estava chumbado filial '01', substituiodo pelo xFilial
				SBF->BF_PRODUTO := SD2->D2_COD
				SBF->BF_LOCAL   := "01"
				SBF->BF_PRIOR   := ""
				SBF->BF_LOCALIZ := "      EXPEDICAO"
				SBF->BF_NUMSERI := ""
				SBF->BF_LOTECTL := ""
				SBF->BF_NUMLOTE := ""
				SBF->BF_QUANT   := SD2->D2_QUANT
				SBF->(MSUNLOCK())
				SBF->(DbCommit()) //
			EndIF
			IF SD2->D2_COD > "004999" .AND. SD2->D2_COD < "006000"
				DbSelectArea("SB8")
				DbSetOrder(3)
				IF DbSeek(xFilial("SB8")+SD2->D2_COD+"01"+SD2->D2_LOTECTL)
					RECLOCK("SB8",.F.)
					SB8->B8_SALDO := SB8->B8_SALDO + SD2->D2_QUANT
					SB8->(MSUNLOCK())
					SB8->(DbCommit())
				ELSE
					RECLOCK("SB8",.T.)
					SB8->B8_FILIAL  := xFilial('SB8') //"01"   // JBS - 18/08/2010 - Estava chumbado filial '01', substituiodo pelo xFilial
					SB8->B8_QTDORI  := SD2->D2_QUANT
					SB8->B8_PRODUTO := SD2->D2_COD
					SB8->B8_LOCAL   := "01"
					SB8->B8_DATA    := DDATABASE
					SB8->B8_DTVALID := SD2->D2_DTVALID
					SB8->B8_SALDO   := SD2->D2_QUANT
					SB8->B8_LOTEFOR := SD2->D2_LOTECTL
					SB8->B8_LOTECTL := SD2->D2_LOTECTL
					SB8->(MSUNLOCK())
					SB8->(DbCommit())
				ENDIF
			ENDIF
		ENDIF
	Endif
ENDIF 

_cGera := " "
_cEst  := " "
_cFin  := " "
 
Dbselectarea("SF4")
Dbsetorder(1)
If Dbseek(xfilial("SF4")+StrZero(IIF(Val(SD2->D2_TES)>=500,Val(SD2->D2_TES),Val(SD2->D2_TES)+500),Len(SD2->D2_TES)))
	_cGera := SF4->F4_GER_EST
	_cEst  := SF4->F4_ESTOQUE
	_cFin  := SF4->F4_DUPLIC
Endif                       

DbSelectArea("SF2")
Dbsetorder(1)
Dbseek(xfilial("SF2") + SD2->D2_DOC + SD2->D2_SERIE )

DbSelectArea("SZD")
RecLock("SZD",.T.)
SZD->ZD_FILIAL  := xFilial("SZD")
SZD->ZD_NOTA    := SD2->D2_DOC
SZD->ZD_SERIE   := SD2->D2_SERIE
SZD->ZD_DATAEXC := DATE()
SZD->ZD_HORAEXC := TIME() 
SZD->ZD_USUARIO := Upper(U_DipUsr())
SZD->ZD_ATUEST  := _cEst
SZD->ZD_ATUFIN  := _cFin
SZD->ZD_ESTEXCL := _cGera
SZD->ZD_CLIENTE := SD2->D2_CLIENTE
SZD->ZD_COD     := SD2->D2_COD
SZD->ZD_EMISSAO := SD2->D2_EMISSAO
SZD->ZD_TES     := SD2->D2_TES
SZD->ZD_QUANT   := SD2->D2_QUANT // MCVN - 28/11/08
SZD->ZD_PRCVEN  := SD2->D2_PRCVEN// MCVN - 28/11/08
SZD->ZD_TOTAL   := SD2->D2_TOTAL // MCVN - 28/11/08
SZD->ZD_COMIS1  := SD2->D2_COMIS1// MCVN - 28/11/08
SZD->ZD_CUSDIP  := SD2->D2_CUSDIP// MCVN - 28/11/08
SZD->ZD_CONFERI := SF2->F2_CONFERI
SZD->ZD_SEPAROU := SF2->F2_SEPAROU
SZD->ZD_EXPLIC  := _ZD_EXPLIC
SZD->(MsUnLock())
SZD->(DbCommit())

// Limpando nota fiscal no Edital se o pedido foi gerado pelo Licitação  MCVN - 04/10/2007
If !Empty(Alltrim(_cEdital)) .And. !("TMSA200" $ FUNNAME()) // Não entra se a rotina for chamada pelo TMS  - MCVN 01/12/2008
	DbSelectArea("UA1")
	DbSetOrder(1)
	IF UA1->(DbSeek(xFilial("UA1")+_cEdital))   
		Reclock("UA1",.F.)
		UA1->UA1_NFISCA := ""
		UA1->UA1_SERIE  := ""
		UA1->(MsUnLock())
		UA1->(DbCommit())  
	EndIF
Endif

RestArea(_areaSC6)
RestArea(_areaSC9)
RestArea(_xAlias)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGeraSD3()ºAutor  ³Jailton B Santos-JBSº Data ³ 17/08/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta as  arrays com as informacoes para gerar a requisicao º±±
±±º          ³de movimentacao interna de mercadoria.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Faturamento Dipromed - DIPA046                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fGeraSD3()

Local aArea     := GetArea()
Local aArea_SDB := SDB->(GetArea())
Local aArea_SD5 := SD5->(GetArea())

Local cNumseq 
Local _cLocaliz   := ''
Local _NumLote    := ''
Local _cGera      := ''
Local _cEST       := ''
Local _DtValid    := cTod('')

Begin Sequence

    // cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.) // BUSCA NUMERACAO DO SD3

	SF4->(Dbsetorder(1))
	If SF4->(Dbseek(xfilial("SF4")+SD2->D2_TES))
		_cGera := SF4->F4_GER_EST
		_cEST  := SF4->F4_ESTOQUE
	Endif
	//---------------------------------------------------------------------------------------------
	// JBS 17/08/2010 - Quando a rotina for chamada a partir da avaliacao de 
	// processo de cancelamento de NFS e a mercadoria da nota fiscal que esta
	// sendo devolvida estiver no cliente.
	//---------------------------------------------------------------------------------------------
	If Type("lDip46GrD3") <> "U" .And. lDip46GrD3 
	    _cGera := 'N'
	Else   
		_cGera := ' '
	EndIf

	If _cGera <> "N" .or. _cEst <> 'S'
        Break
    EndIf    
    
    cNumseq := ProxNum()
         
    SB1->( Dbsetorder(1) )
    If SB1->(Dbseek(xFilial("SB1")+SD2->D2_COD))

	    If SB1->B1_LOCALIZ == "S"
		    SDB->(DbSetOrder(1))
		     IF SDB->( DbSeek(xFilial("SDB") + SD2->D2_COD + SD2->D2_LOCAL + SD2->D2_NUMSEQ))
			     _cLocaliz := SDB->DB_LOCALIZ
             EndIf
        EndIf    

	    If SB1->B1_RASTRO == "L" .OR. SB1->B1_RASTRO == "S"
		    SD5->( Dbsetorder(3) )
		    If SD5->( Dbseek(xFilial("SD5") + SD2->D2_NUMSEQ + SD2->D2_COD + SD2->D2_LOCAL + SD2->D2_LOTECTL))
			    _NumLote := SD5->D5_NUMLOTE
			    _DtValid := SD5->D5_DTVALID
            EndIf
        EndIf    

    EndIf          

    aadd(aRegSD3,{{"D3_ITEM"        , SD2->D2_ITEM                    ,Nil},;
                  {"D3_COD"          , SD2->D2_COD                    ,Nil},;
                  {"D3_LOCAL"        , SD2->D2_LOCAL                  ,Nil},;
                  {"D3_NUMSEQ"       , cNumSeq                        ,Nil},;
                  {"D3_QUANT"        , SD2->D2_QUANT                  ,Nil},;
                  {"D3_CF"           , "RE0"                          ,NIL},;
                  {"DE_UM"           , SD2->D2_UM                     ,NIL},;
                  {"D3_TIPO"         , SD2->D2_TP                     ,NIL},;
                  {"D3_GRUPO"        , SB1->B1_GRUPO                  ,NIL},;   
                  {"D3_CHAVE"        , "E0"                           ,Nil},;
                  {"D3_USUARIO"      , U_DipUsr()					  ,NIL},;
                  {"D3_ESTCIS"       , "S"                            ,Nil},;
		          {"D3_CONTA"        , SD2->D2_CONTA                  ,Nil},;
		          {"D3_SEGUM"        , SD2->D2_SEGUM                  ,Nil},;
		          {"D3_QTSEGUM"      , SD2->D2_QTSEGUM                ,Nil},;
          	      {"D3_IDENT"        , SD2->D2_SERIE                  ,Nil},;
		          {"D3_LOTECTL"      , SD2->D2_LOTECTL                ,Nil},;
		          {"D3_NUMLOTE"      , _NumLote                       ,Nil},;
		          {"D3_DTVALID"      , _DtValid                       ,Nil},;
		          {"D3_LOCALIZ"      , _cLocaliz                      ,Nil},;
	 	          {"D3_EXPLIC"       , SD2->D2_DOC + SD2->D2_SERIE +  _ZD_Explic,Nil}})

    		    //  {"D3_IDENT"        , SD2->D2_SERIE                  ,Nil},;

    aCabSD3 :=  {{"D3_FILIAL"       , SD2->D2_FILIAL                  ,Nil},;
                  {"D3_DOC"          , SD2->D2_DOC                    ,Nil},;
                  {"D3_TM"           , "532"                          ,Nil},;
                  {"D3_EMISSAO"      , dDatabase                      ,NIL},;
                  {"D3_CC"           , ""                             ,nil}}
                                                            
End Sequence 

SDB->(RestArea(aArea_SDB))
SD5->(RestArea(aArea_SD5))
RestArea(aArea)
          
Return