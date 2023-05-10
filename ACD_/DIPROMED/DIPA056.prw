#include "rwmake.ch"
#Include "colors.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO6     �Autor  �Microsiga           � Data �  11/19/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DIPA056() 
Local aCores		:= {}  
Private cCadastro 	:= "Monitor Fila"
Private aRotina 	:= { ;
{"Pesquisar"  ,"AxPesqui"  , 0 , 1},;    
{"Visualiza"  ,"AxVisual"  , 0 , 2},;  
{"Faturar"    ,"U_D56FAT()", 0 , 3},;
{"Legenda"    ,"U_D56LEG()", 0 , 7}}

aAdd(aCores , {'U_DipPedBlq(ZZ5_PEDIDO) = "1" .And. ZZ5_STATUS = "4"','BR_AZUL'} )
aAdd(aCores , {'ZZ5_STATUS = "4"','BR_VERDE'   } )
aAdd(aCores , {'ZZ5_STATUS = "3"','BR_CINZA'   } )
aAdd(aCores , {'ZZ5_STATUS = "2"','BR_AMARELO' } )
aAdd(aCores , {'ZZ5_STATUS = "1"','BR_VERMELHO'} )


U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009  

dbSelectArea("ZZ5")
                                
SET FILTER TO ZZ5_FILIAL == xFilial("ZZ5") .And. Empty(ZZ5_NOTA) .And. Empty(ZZ5_SERIE)

mBrowse( 6, 1,22,75,"ZZ5",,,,,,aCores,,,,,,,,)

SET FILTER TO 	

Return                               
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPA056   �Autor  �Microsiga           � Data �  11/19/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                         	              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function D56LEG()
Local aLegenda:={}

aAdd(aLegenda, {'BR_VERDE'   ,"Pronto para Faturar"	} )  // 3
aAdd(aLegenda, {'BR_AMARELO' ,"Confer�ncia"        	} )  // 2
aAdd(aLegenda, {'BR_VERMELHO',"Separa��o"    		} )  // 1
aAdd(aLegenda, {'BR_AZUL'	 ,"Pedido � vista" 		} )  // 1
aAdd(aLegenda, {'BR_CINZA'   ,"Aguardando Consolidacao"} )  // 1

BrwLegenda("Status da OS","Status",aLegenda)

Return  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPA056   �Autor  �Microsiga           � Data �  11/19/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                         	              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function D56FAT()   
Local aArea 	:= GetArea()
Local aAreaSC5 	:= SC5->(GetArea())                                                       
Local cTransAut := AllTrim(GetNewPar("ES_TRANAUT","000000/000001/000111/000112"))    
Local cHorExc 	:= AllTrim(GetNewPar("ES_HORAAUT","15:40|16:20")) //Demais Transportadoras
Local cHorExc2 	:= AllTrim(GetNewPar("ES_HORAUT2","16:40|17:20")) //Emovere
Local cHorMin   := SubStr(cHorExc,1,At("|",cHorExc)-1) 
Local cHorMax   := SubStr(cHorExc,At("|",cHorExc)+1,Len(cHorExc)) 
Local cHorMin2  := SubStr(cHorExc2,1,At("|",cHorExc2)-1) 
Local cHorMax2  := SubStr(cHorExc2,At("|",cHorExc2)+1,Len(cHorExc2)) 
Local cHorAtu   := Left(Time(),5)    
Local cHorMsg   := "das "+StrTran(cHorExc,"|"," �s ")
Local cHorMsg2  := "das "+StrTran(cHorExc2,"|"," �s ")
Local lRet 		:= .T. 
Local cChave    := ""

SC5->(dbSetOrder(1))
If SC5->(dbSeek(xFilial("SC5")+AllTrim(ZZ5->ZZ5_PEDIDO)))
	If cHorAtu>cHorMin .And. cHorAtu<cHorMax .And. ZZ5->ZZ5_TRANSP$GetNewPar("ES_TRP_COLS","000235")  .And. !(ZZ5->ZZ5_TRANSP$cTransAut)
		Aviso("Aten��o","Hor�rio cr�tico "+cHorMsg+" !!!"+CHR(13)+CHR(10)+"N�o � permitido faturamento neste hor�rio!!!"+CHR(13)+CHR(10)+"Faturar, somente quando necess�rio, Retira/Malote/Coleta.",{"Ok"},1)
		lRet := .F.					
	EndIf
	
	If cHorAtu>cHorMin2 .And. cHorAtu<cHorMax2 .And. ZZ5->ZZ5_TRANSP$GetNewPar("ES_TRP_COLS","000235")  .And. !(ZZ5->ZZ5_TRANSP$cTransAut)
		Aviso("Aten��o","Hor�rio cr�tico "+cHorMsg2+" !!!"+CHR(13)+CHR(10)+"N�o � permitido faturamento neste hor�rio!!!"+CHR(13)+CHR(10)+"Faturar, somente quando necess�rio, Retira/Malote/Coleta.",{"Ok"},1)
		lRet := .F.					
	EndIf

	If lRet
		If !Empty(SC5->C5_XBLQNF)      
			Aviso("Aten��o","Foi solicitado estorno deste pedido. Entre em contato com a vendedora.",{"Ok"},1)
		ElseIf ZZ5->ZZ5_STATUS == '4'
			DipAtuSX1(ZZ5->ZZ5_PEDIDO,.T.)
			
			cChave := "Fat_"+cEmpAnt+cFilAnt+"_"+AllTrim(ZZ5->ZZ5_PEDIDO)
			If LockByName(cChave,.T.,.T.)
				MATA460() 
				UnLockByName(cChave,.T.,.T.)
			Else
				Aviso("Aten��o","Pedido em processo de estorno",{"Ok"},1)
			EndIf         	
			   
			DipAtuSX1(ZZ5->ZZ5_PEDIDO)
		Else
			Aviso("Aten��o","O pedido n�o est� pronto para ser faturado",{"Ok"},1)
		EndIf        
	EndIf
Else 
	Aviso("Aten��o","Pedido n�o encontrado na tabela SC5.",{"Ok"},1)	
EndIf	

RestArea(aAreaSC5)
RestArea(aArea)

Return          
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPA056   �Autor  �Microsiga           � Data �  02/07/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DipPedBlq(cPedido) 
Local aArea 	:= GetArea()
Local aAreaSC5 	:= SC5->(GetArea())
Local cBlq  	:= ""
DEFAULT cPedido := ""

dbSelectArea("SC5")
SC5->(dbSetOrder(1))

If SC5->(dbSeek(xFilial("SC5")+cPedido))
	cBlq := SC5->C5_BLQ
EndIf

RestArea(aAreaSC5)
RestArea(aArea) 

Return cBlq 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DIPA056   �Autor  �Microsiga           � Data �  06/04/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DipAtuSX1(cPedido,lTrava)
Local aArea		:= GetArea()
Local nDipTam 	:= 0
DEFAULT cPedido := ""             
DEFAULT lTrava	:= .F.

Begin Transaction
	cQuery := "UPDATE "+MPSysSqlName("SX1")+ " SET X1_GSC = '" + IIF(lTrava=.T.,"S","G") +"' "
	cQuery += "WHERE D_E_L_E_T_ = '' AND "
	cQuery += "X1_GRUPO  = 'MT461A' AND X1_ORDEM = '05' "
	nErro := TcSqlExec(cQuery)
							
	If nErro != 0
		MsgStop("Erro na execu��o da query: "+TcSqlError(), "Aten��o")
		DisarmTransaction()
	EndIf
End Transaction

/*
dbSelectArea("SX1")
dbSetOrder(1)   

nDipTam := Len( SX1->X1_GRUPO )

If SX1->(DbSeek(PadR("MT461A",nDipTam)+"05"))
	SX1->(RecLock("SX1",.F.))
		If lTrava
			Replace	SX1->X1_GSC   With "S"
		Else
			Replace	SX1->X1_GSC   With "G"			
		EndIf
	SX1->(MsUnlock())

	SX1->(dbSkip())                   

	SX1->(RecLock("SX1",.F.))
		If lTrava
			Replace	SX1->X1_GSC   With "S"
		Else
			Replace	SX1->X1_GSC   With "G"			
		EndIf
	SX1->(MsUnlock())
EndIf
*/

If FindFunction('SetMVValue')
	SetMVValue("MT461A","MV_PAR05",cPedido) 
	SetMVValue("MT461A","MV_PAR06",cPedido) 
Endif        

RestArea(aArea)

Return
