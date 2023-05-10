#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MSDOCFIL  ºAutor  ³Microsiga           º Data ³  09/03/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ LOCALIZAÇÃO: Function MsDocArray - Função do MsDocument    º±±
±±º			   responsável pela montagem do acols com os documentos do    º±±
±±º			   banco de conhecimento.                                     º±±
±±º            No início da função dentro do laço da tabela AC9.          º±±
±±º             É utilizado para filtrar registros.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MSDOCFIL()

Local aArea   := GetArea()
Local lRet    := .T.
Local nRecno  := PARAMIXB[1]
Local _cValBc := ""   
      
dbSelectArea("SX3")
SX3->(dbSetOrder(2))
 
If SX3->(dbSeek("ACB_CODOBJ")) .And. SX3->X3_VALID != _cValBc
	SX3->(RecLock("SX3",.F.))
	SX3->X3_VALID := _cValBc
	SX3->(MsUnLock())
EndIf
 
AC9->(dbGoTo(nRecno))

If "TMKA271" $FUNNAME()
	If !Empty(M->UC_CODIGO)
	
		If AC9->AC9_CODOBJ <> M->UC_CODIGO
			lRet := .F.
		EndIf
		
	EndIf
EndIf

RestArea(aArea)

Return(lRet)   