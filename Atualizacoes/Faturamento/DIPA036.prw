#include "Protheus.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPA036   �Autor  �Microsiga           � Data �  01/30/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tela de consulta do Log/Kardex Generico                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � ESPECIFICO DIPROMED                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function DIPA036(_cAlias)
Local _aArea 	:= GetArea()   
Local _aRotAnt	:= If(Type("aRotina")=='A',aRotina,{})
Local _cCadAnt	:= If(Type("cCadastro")=="C",cCadastro,"")

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

Default _cAlias := ''

If Empty(_cCadAnt)
	Private aRotina	
	Private cCadastro
EndIf
aRotina	:= { {"Pesquisar", "AxPesqui"   ,0,1},;
		 					{"Visualizar" ,"AxVisual",0,2}}
cCadastro	:= "Kardex por Tabela/Recno"
	
If !Empty(_cAlias)
	DbSelectArea("SZG")
	DbSeek(xFilial("SZG"))
	Set Filter To ZG_TABELA == RetSqlName(_cAlias) .And. ZG_RECNO == (_cAlias)->(Recno())
EndIf	  
obrowseX := GetmBrowse()
//�����������������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                           �
//�������������������������������������������������������������������������
mBrowse(6,1,22,75,"SZG")
obrowseY := GetmBrowse()

DbSelectArea("SZG")
Set Filter To

RestArea(_aArea)               
aRotina 	:= _aRotAnt
cCadastro 	:= _cCadAnt
Return 


User Function DIPA36Key(nIndice)                  
Local _aArea 		:= GetArea()
Local _aAreaKey		:= (Left(SZG->ZG_TABELA,3))->(GetArea())
Local _cNomeIndice 	:= ''
Local cRet			:= ''  
Local nPos 			:= 0                                     
Local nPosAnt		:= 0                                     
Local cCampo		:= ''

Default nIndice 	:= 1
                          
(Left(SZG->ZG_TABELA,3))->(DbGoto(SZG->ZG_RECNO))
If !Eof()
	(Left(SZG->ZG_TABELA,3))->(DbSetOrder(nIndice)) 
	
	dbselectarea(Left(SZG->ZG_TABELA,3))
	_cNomeIndice := IndexKey()
	
	// Separa��o dos campos na Linha
	Do While (nPos := At('+',Right(_cNomeIndice,Len(_cNomeIndice)-nPos))) != 0
		cCampo 	:= AllTrim(Substr(_cNomeIndice,nPosAnt+1,nPos-1))
		cRet 	+= &cCampo + "+"

	    nPos	+= nPosAnt
		nPosAnt	:= nPos 
	EndDo       
	cCampo 	:= AllTrim(Substr(_cNomeIndice,nPosAnt+1,Len(_cNomeIndice)-nPosAnt))
	cRet 	+= &cCampo
EndIf
	
RestArea(_aAreaKey)
RestArea(_aArea)
Return cRet