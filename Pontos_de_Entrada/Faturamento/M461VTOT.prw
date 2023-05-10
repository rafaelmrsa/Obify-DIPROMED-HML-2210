#Include "RWMAKE.CH"
#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M461VTOT  ºAutor  ³Microsiga           º Data ³  03/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function M461VTOT()
Local _lRet			:= .T.
Local _aArea		:= {}
Local _aAreaSZ9		:= {}
Local _aAreaSC9		:= {}
Local _nVlrTotal	:= 0
Local _cChaveSF2	:= ""
Local _aItemPV		:= {}
Local _cPedido		:= ""

//-- Nao entra se a rotina for chamada pelo TMS
If !("TMSA200" $ FUNNAME()) 
	_aArea		:= GetArea()
	_aAreaSZ9	:= SZ9->(GetArea())
	_aAreaSC9	:= SC9->(GetArea())
	_aItemPV	:= U_M460NITE(.F.)
	
	//-- Calcula o Total pelos Itens Marcados
	aEval(_aItemPV,{ |x| 	SC9->(DbGoto(x[8])),; 
							_cPedido := SC9->C9_PEDIDO,;
							_nVlrTotal += NoRound(SC9->C9_QTDLIB*SC9->C9_PRCVEN,2)  })
	
	//-- Calcula a Chave pela soma dos SD2 - enviada pelo PE
	_cChaveSF2	:= AllTrim(Transform(Val(Embaralha(StrZero(int(;
															_nVlrTotal;
															); 		//-- Int
															,9); 	//-- StrZero
															,0); 	//-- Embaralha
															);		//-- Val
															,"@E 999,999,999"); //-- TransForm
															);		//-- AllTrim
	
 	//-- Busca Chave Gravada no SZ9
	_cChaveZ9 := RetChaveZ9(_cPedido)

	//-- Compara Chave Gravada na Separação com a Chave 	
	_lRet := (_cChaveSF2 == _cChaveZ9)
	
	//-- Exibe pergunta se deseja continuar em caso de erro
	If !_lRet
		//_lRet := MsgBox("Houve divergência entre o pedido de venda e a NF de saída."+Chr(13)+Chr(10)+"Deseja Continuar? ","Atenção","YESNO")

        MsgStop( "#####################"+CHR(13)+CHR(10)+;
				 "## ----- ATENÇÃO -----  ##"+CHR(13)+CHR(10)+;
		 		 "## ------- E R R O ------  ##"+CHR(13)+CHR(10)+; 
		         "#####################")
		         
		_lRet := (Aviso("DIVERGÊNCIA","Quantidade de itens faturados diferente da quantidade separada."+CHR(13)+CHR(10)+;
									 "Verifique a necessidade de estornar o processo.",{"Continua","Cancela"},2)==1)
										
		//-- Se o Usuário Continuar mesmo com erro, grava Log no Kardex
		If _lRet
		    U_DiprKardex(_cPedido,U_DipUsr(),"EMITIU CHV DIV -"+_cChaveSF2,.T.,"49") 
		EndIf 
	EndIf 

	RestArea(_aAreaSC9)
	RestArea(_aAreaSZ9)
	RestArea(_aArea)
EndIf

Return _lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetChaveZ9ºAutor  ³Microsiga           º Data ³  03/12/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetChaveZ9(_cPedido)
Local _cAlias	:= GetNextAlias()
Local _cQuery	:= ""
Local _cRet		:= ""
Local _aArea	:= GetArea()

_cQuery += " SELECT TOP 1 Z9_TIPMOV"
_cQuery += " FROM  "+RetSQLName('SZ9')
_cQuery += " WHERE "
_cQuery += " 	Z9_FILIAL = '" + xFilial('SZ9') + "'"
_cQuery += " 	AND Z9_PEDIDO  = '"+ _cPedido + "'"  
_cQuery += " 	AND Z9_OCORREN = '39'"
_cQuery += " 	AND D_E_L_E_T_ = ' '""
_cQuery += " ORDER BY R_E_C_N_O_ DESC"
DbCommitAll()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cAlias,.T.,.T.)

If (_cAlias)->(!Eof())
	//-- No DIPM010 grava como "SEPARACAO OK - " 
	_cRet := AllTrim(Substr((_cAlias)->Z9_TIPMOV,16))
EndIf
(_cAlias)->(DbCloseArea())

RestArea(_aArea)

Return _cRet