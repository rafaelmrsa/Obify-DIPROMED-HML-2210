#INCLUDE "PROTHEUS.CH"        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT010CAN  ºAutor  ³Microsiga           º Data ³  09/27/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para enviar e-mail ao modificar um produto tipo "Z" º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT010CAN()    
Local _nOpc   	:= ParamIxb[1]  
Local _cEmail 	:= GetNewPar("ES_ALTPROD","qualidade@dipromed.com.br") 
Local _cAssunto	:= ""
Local _aMsg		:= {}
Local _cAttach	:= ""
Local _cFrom 	:= ""
Local _cFuncSent:= Upper(ProcName())
Local _cMsgCic	:= ""

If Altera .And. _nOpc == 1 
	cSQL := "SELECT AIF_CONTEU "
	cSQL += "FROM "+RetSqlName("AIF")+" "
	cSQL += "WHERE AIF_FILIAL='"+xFilial("AIF")+"' AND "
	cSQL += "AIF_FILTAB 	= '"+xFilial("SB1")+"' AND "
	cSQL += "AIF_TABELA 	= 'SB1' AND "
	cSQL += "AIF_CAMPO 		= 'B1_DESC' AND "
	cSQL += "AIF_CODPRO 	= '"+AllTrim(SB1->B1_COD)+"' AND "
	cSQL += "AIF_DATA  		= '"+DTOS(dDataBase)+"' AND "
	cSQL += "D_E_L_E_T_		= ' ' "
	cSQL += "ORDER BY R_E_C_N_O_ DESC "
	
	cSQL := ChangeQuery(cSQL)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYAIF")	

	If !QRYAIF->(Eof()) .And. Left(Upper(QRYAIF->AIF_CONTEU),1) == 'Z' .And. Left(Upper(SB1->B1_DESC),1) <> Left(Upper(QRYAIF->AIF_CONTEU),1)   
				
		_cFrom  := "protheus@dipromed.com.br"
	    _cAssunto:= EncodeUTF8('Alteração de produto "Z" '+SB1->B1_COD,"cp1252")
	   	Aadd( _aMsg , { "Código do Produto: "   , SB1->B1_COD } )
		Aadd( _aMsg , { "Conteúdo Anterior: "       , AllTrim(QRYAIF->AIF_CONTEU) } )
		Aadd( _aMsg , { "Conteúdo Atual:  "     , AllTrim(SB1->B1_DESC) } )
		Aadd( _aMsg , { "Quem Alterou: "        , UsrFullName(RetCodUsr()) } )	
			
		U_UEnvMail(_cEmail,_cAssunto,_aMsg,_cAttach,_cFrom,_cFuncSent)
   
		_cMsgCic := "A descrição do produto "+AllTrim(SB1->B1_COD)+" foi alterada."+CHR(10)+CHR(13)
		_cMsgCic += "De:   "+AllTrim(QRYAIF->AIF_CONTEU)+CHR(10)+CHR(13)
		_cMsgCic += "Para: "+AllTrim(SB1->B1_DESC)+CHR(10)+CHR(13)
		_cMsgCic += "Empresa/Filial: "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+CHR(10)+CHR(13)				  
		_cMsgCic += "Usuário responsável pela alteração: "+UsrFullName(RetCodUsr())	
			
		_cEmail := AjusCIC(_cEmail)		                          
				
		U_DIPCIC(_cMsgCic,_cEmail) 
		            
	EndIf           
	
	QRYAIF->(dbCloseArea())
EndIf

Return                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT010CAN  ºAutor  ³Microsiga           º Data ³  09/18/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjusCIC(_cEmail)
Local _nI 	:= 0                        
Local _nPos := 0  
Local _cAux := "" 
DEFAULT _cEmail := ""

_cAux 	:= _cEmail
_cEmail := ""                 

While !Empty(_cAux)
	If (_nPos := At("@",_cAux)) >0
		_cEmail += Upper(SubStr(_cAux,1,_nPos-1))+","
		_cAux := SubStr(_cAux,_nPos+1,Len(_cAux))	
	Else
		Exit
	EndIf
EndDo

Return(Left(_cEmail,Len(_cEmail)-1))