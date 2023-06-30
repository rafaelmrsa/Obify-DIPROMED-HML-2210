#include "rwmake.ch"
#Include "colors.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO6     บAutor  ณMicrosiga           บ Data ณ  11/19/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIPA056() 
Local aCores		:= {}  
Private cCadastro 	:= "Monitor Fila"
Private aRotina 	:= { ;
{"Pesquisar"  				,"AxPesqui"  				, 0 , 1},;    
{"Visualiza"  				,"AxVisual"  				, 0 , 2},;  
{"Faturar"    				,"U_D56FAT()"				, 0 , 3},;
{"Liberar PV Bloq."			,"U_D56LIBPV(ZZ5_PEDIDO)"	,0 , 3},;
{"Legenda"   				,"U_D56LEG()"				, 0 , 7}}

aAdd(aCores , {'ZZ5_STATUS = "5"','BR_PRETO'} ) // Rafael Moraes Rosa - 14/06/2023 - Ajustar status de divergencia
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA056   บAutor  ณMicrosiga           บ Data ณ  11/19/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                         	              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function D56LEG()
Local aLegenda:={}

aAdd(aLegenda, {'BR_VERDE'   ,"Pronto para Faturar"	} )  // 3
aAdd(aLegenda, {'BR_AMARELO' ,"Confer๊ncia"        	} )  // 2
aAdd(aLegenda, {'BR_VERMELHO',"Separa็ใo"    		} )  // 1
aAdd(aLegenda, {'BR_AZUL'	 ,"Pedido เ vista" 		} )  // 1
aAdd(aLegenda, {'BR_CINZA'   ,"Aguardando Consolidacao"} )  // 1
aAdd(aLegenda, {'BR_PRETO'   ,"Bloqueado/Conflito de Faturamento"	} )  // 5

BrwLegenda("Status da OS","Status",aLegenda)

Return  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA056   บAutor  ณMicrosiga           บ Data ณ  11/19/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                         	              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
Local cHorMsg   := "das "+StrTran(cHorExc,"|"," เs ")
Local cHorMsg2  := "das "+StrTran(cHorExc2,"|"," เs ")
Local lRet 		:= .T. 
Local cChave    := ""

SC5->(dbSetOrder(1))
If SC5->(dbSeek(xFilial("SC5")+AllTrim(ZZ5->ZZ5_PEDIDO)))
	If cHorAtu>cHorMin .And. cHorAtu<cHorMax .And. ZZ5->ZZ5_TRANSP$GetNewPar("ES_TRP_COLS","000235")  .And. !(ZZ5->ZZ5_TRANSP$cTransAut)
		Aviso("Aten็ใo","Horแrio crํtico "+cHorMsg+" !!!"+CHR(13)+CHR(10)+"Nใo ้ permitido faturamento neste horแrio!!!"+CHR(13)+CHR(10)+"Faturar, somente quando necessแrio, Retira/Malote/Coleta.",{"Ok"},1)
		lRet := .F.					
	EndIf
	
	If cHorAtu>cHorMin2 .And. cHorAtu<cHorMax2 .And. ZZ5->ZZ5_TRANSP$GetNewPar("ES_TRP_COLS","000235")  .And. !(ZZ5->ZZ5_TRANSP$cTransAut)
		Aviso("Aten็ใo","Horแrio crํtico "+cHorMsg2+" !!!"+CHR(13)+CHR(10)+"Nใo ้ permitido faturamento neste horแrio!!!"+CHR(13)+CHR(10)+"Faturar, somente quando necessแrio, Retira/Malote/Coleta.",{"Ok"},1)
		lRet := .F.					
	EndIf

	If lRet
		If !Empty(SC5->C5_XBLQNF)      
			Aviso("Aten็ใo","Foi solicitado estorno deste pedido. Entre em contato com a vendedora.",{"Ok"},1)
		ElseIf ZZ5->ZZ5_STATUS == '4'
			//DipAtuSX1(ZZ5->ZZ5_PEDIDO,.T.)
			
			cChave := "Fat_"+cEmpAnt+cFilAnt+"_"+AllTrim(ZZ5->ZZ5_PEDIDO)
			If LockByName(cChave,.T.,.T.)
				//MATA460()//Rafael Moraes Rosa - 14/06/2023 - Linha comentada
				//Rafael Moraes Rosa - 14/06/2023 - INICIO
				IF IIF(SuperGetMV("MV_#ATVVLD",.F.,.F.)=.T.,ExistD2(ZZ5->ZZ5_PEDIDO,ZZ5->ZZ5_NOTA,ZZ5->ZZ5_SERIE),.F.)
					Aviso("Aten็ใo","Pedido " + ALLTRIM(ZZ5->ZZ5_PEDIDO) + " com faturamento existente/divergente. Entre em contato com o TI.",{"Ok"},1)
					ZZ5->(RecLock("ZZ5",.F.))
						ZZ5->ZZ5_STATUS := "5" //Bloqueado por conflito de faturamento
					ZZ5->(MsUnlock())
				ELSE
					MATA460()
				ENDIF
				//Rafael Moraes Rosa - 14/06/2023 - FIM
				UnLockByName(cChave,.T.,.T.)
			Else
				Aviso("Aten็ใo","Pedido em processo de estorno",{"Ok"},1)
			EndIf         	
			   
			//DipAtuSX1(ZZ5->ZZ5_PEDIDO)
		Else
			Aviso("Aten็ใo","O pedido nใo estแ pronto para ser faturado",{"Ok"},1)
		EndIf        
	EndIf
Else 
	Aviso("Aten็ใo","Pedido nใo encontrado na tabela SC5.",{"Ok"},1)	
EndIf	

RestArea(aAreaSC5)
RestArea(aArea)

Return          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA056   บAutor  ณMicrosiga           บ Data ณ  02/07/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA056   บAutor  ณMicrosiga           บ Data ณ  06/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
		MsgStop("Erro na execu็ใo da query: "+TcSqlError(), "Aten็ใo")
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExistD2   บAutor  Rafael Moraes Rosa   บ Data ณ  14/06/23   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                         	              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExistD2(cPedido,cNota,cSerie)
Local lRet	:= .F.
Local aINfe	:= {}
Local cQuery    := ""
Local cAliasQry := ""

        cAliasQry := GetNextAlias()

		cQuery := "SELECT SD2.R_E_C_N_O_ AS SD2REC "
        cQuery += "FROM  "+RetSqlName("SD2")+ " (NOLOCK) SD2 "
		
		cQuery += "WHERE SD2.D_E_L_E_T_ = '' "

		cQuery += "AND D2_FILIAL = '" + ALLTRIM(cFilAnt) + "' "
		cQuery += "AND D2_PEDIDO = '" + ALLTRIM(cPedido) + "' "
		//cQuery += "AND D2_DOC <> '" + ALLTRIM(cNota) + "' " //Variavel NOTA retirada da regra a pedido do Maximo
		//cQuery += "AND D2_SERIE <> '" + ALLTRIM(cSerie) + "' " //Variavel SERIE retirada da regra a pedido do Maximo
		cQuery += "AND D2_EMISSAO = '"+ Date() +"' "

        cQuery := ChangeQuery(cQuery)

        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

        While (cAliasQry)->(!Eof())

			Aadd(aINfe,{(cAliasQry)->SD2REC})
            (cAliasQry)->(dbSkip())
        EndDo

		IF Len(aINfe) > 0
			lRet := .T.
		ENDIF

		(cAliasQry)->(DbCloseArea())

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณD56LIBPV  บAutor  Rafael Moraes Rosa   บ Data ณ  15/06/23   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                         	              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function D56LIBPV(cPVZZ5) 

Local aArea 	:= GetArea()
Local aAreaZZ5 	:= ZZ5->(GetArea())

IF !SuperGetMV("MV_#ATVVLD",.F.,.F.)
	Aviso("Aten็ใo","Controle desabilitado. Habilite o parametro MV_#ATVVLD",{"Ok"},1)

ELSE
	IF RetCodUsr() $ SuperGetMV("MV_#ULPVFI",.F.,"000000|000001|000469")
		dbSelectArea("ZZ5")
		ZZ5->(dbSetOrder(1))

		If ZZ5->(dbSeek(xFilial("ZZ5")+cPVZZ5))
			IF ZZ5->ZZ5_STATUS = "5"
				IF MsgYESNO("Confirma a liberacao do PV " + ALLTRIM(cPVZZ5) + " com conflito no faturamento?")
					ZZ5->(RecLock("ZZ5",.F.))
						ZZ5->ZZ5_STATUS := "4" //Pronto para Faturar
					ZZ5->(MsUnlock())
				ENDIF
			ELSE
				Aviso("Aten็ใo","Ajuste do status nao permitido.",{"Ok"},1)
			ENDIF
		EndIf
	ELSE
		Aviso("Aten็ใo","Operacao permitida para o seu usuario. Entre em contato com o TI",{"Ok"},1)
	ENDIF
ENDIF

RestArea(aAreaZZ5)
RestArea(aArea)

Return
