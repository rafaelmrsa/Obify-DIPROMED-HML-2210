#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#DEFINE CR    chr(13)+chr(10)

/*====================================================================================\
|Programa  | FT210LIB      | Autor | GIOVANI.ZAGO               | Data | 06/10/11     |
|=====================================================================================|
|Descrição | P.E. LIBERAÇÃO DE PEDIDO A VISTA               	                      |
|          |                                                                          |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | FT210LIB                                                                 |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
\====================================================================================*/
*--------------------------------------------------------------------------*
User Function FT210LIB()
*--------------------------------------------------------------------------*
Local nVlrped     := 0
Local cDeIc       :=  Lower(Alltrim(Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_EMAIL")))
Local cEmailIc    := GetMv("ES_MSTTS_1",,"maximo.canuto@dipromed.com.br")+";"+cDeIc
Local cAssuntoIc  := "LIBERADO - Pedido A Vista "
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   "FT210LIB.prw "
Local cOpFatDest  := GetMv("ES_MSTTS_2",,"MAXIMO.CANUTO")
Local _aMsgIc 	  := {}
Local cMSGcIC     := " "
Local cuserid     := U_DipUsr()
Local nVlrPedCE   := 0 


Local cTrpCol     := GetNewPar("ES_TRP_COLS","000235")

cMSGcIC       := "LIBERAÇÃO DE PEDIDO A VISTA"+CR
aAdd( _aMsgIc , { " EMPRESA"  				, + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) )  } )
cMSGcIC       += " EMPRESA:_______" + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   + CR 
aAdd( _aMsgIc , { " FILIAL"   	   			, + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) } )
aAdd( _aMsgIc , { "PEDIDO"    				,+SC5->C5_NUM  } )
cMSGcIC       += " PEDIDO:________"+SC5->C5_NUM +CR
aAdd( _aMsgIc , { "CLIENTE"    				,+SC5->C5_CLIENTE+" - "+Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,'A1_NREDUZ') } )
cMSGcIC       += " CLIENTE:________"+SC5->C5_CLIENTE+" - "+Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE,'A1_NREDUZ') +CR
aAdd( _aMsgIc , { "COND.PAG"    	, +SC5->C5_CONDPAG+" - "+Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI')   } )
cMSGcIC       += "COND.PAG:__________"+SC5->C5_CONDPAG+" - "+Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,'E4_DESCRI') +CR
If SC5->C5_TPFRETE = "D"
	aAdd( _aMsgIc , { "FORMA de PAGAMENTO"   , ""+Iif(SC5->C5_XFORPAG = '1',"Dinheiro",Iif(SC5->C5_XFORPAG = '2',"Cheque",Iif(SC5->C5_XFORPAG = '3',"Deposito","outros")))+"" } )
EndIf
nVlrped := ValorPedido(SC5->C5_NUM)
aAdd( _aMsgIc , { "VALOR do PEDIDO"    		, ""+Transform(nVlrped,"@EZ 999,999,999.99")+""  } )
cMSGcIC       +=  "VALOR:_________"+Transform(nVlrped,"@EZ 999,999,999.99") +CR
aAdd( _aMsgIc , { "OPERADOR"    			,""+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ") })
cMSGcIC       += " OPERADOR:_______"+SC5->C5_OPERADO+"-"+Posicione("SU7",1,xFilial("SU7")+SC5->C5_OPERADO,"U7_NREDUZ") +CR+CR
aAdd( _aMsgIc , { "TRANSPORTADORA"     , ""+SC5->C5_TRANSP+" - " + AllTrim(FDesc("SA4",SC5->C5_TRANSP,"SA4->A4_NREDUZ"))+" "  } )

cMSGcIC       += "LIBERADO PARA GERAÇÃO DE N. F. " 

Do Case
	Case SC5->C5_TPFRETE = "C"
		cTipFret:= "CIF"
	Case SC5->C5_TPFRETE = "I"
		cTipFret:= "INCLUSO"
	Case SC5->C5_TPFRETE = "F"
		cTipFret:= "FOB"
	Case SC5->C5_TPFRETE = "T"
		cTipFret:= "TERCEIRO"
	Case SC5->C5_TPFRETE = "S"
		cTipFret:= "SEM FRETE"
	Case SC5->C5_TPFRETE = "D"
		cTipFret:= "RETIRA"
	Case SC5->C5_TPFRETE = "N"
		cTipFret:= "NOSSO CARRO"
ENDCASE

aAdd( _aMsgIc , { "TIPO de FRETE "   , ""+cTipFret+"" } ) 
If SC5->C5_PRENOTA <> "S"
aAdd( _aMsgIc , { "SEPARAR PEDIDO :"     , " SIM  "  } )
EndIf
aAdd( _aMsgIc , { "GERAR NOTA FISCAL : "     , " SIM  "  } ) 


//GRAVA KARDEX
U_DiprKardex(SC5->C5_NUM,cUserId,"LIBERACAO PEDIDO A VISTA.",.t.,"54","LIBERACAO PEDIDO A VISTA.") // GIOVANI ZAGO 09/02/12
//manda EMAIL
u_UEnvMail(cEmailIc,cAssuntoIc,_aMsgIc,cAttachIc,cDeIc,cFuncSentIc)
//manda CIC
U_DIPCIC(cMSGcIC,AllTrim(cOpFatDest)) 

return()

*--------------------------------------------------------------------------*
Static Function ValorPedido(cPedido)
*--------------------------------------------------------------------------*
Local aArea      := GetArea()
Local aAreaSC61   := SC6->( GetArea() )
Local aAreaSC51   := SC5->( GetArea() )
Local nVlrPed      :=0


DbSelectArea("SC6")
DbSetOrder(1)
SC6->(DbSeek(xFilial("SC6")+cPedido))
While SC6->C6_NUM == cPedido
	If SC6->C6_NUM == cPedido
		nVlrPed += SC6->C6_VALOR
	Endif
	SC6->(DbSkip())
Enddo
SC6->(DbCloseArea())


nVlrPed := (nVlrPed + SC5->C5_DESPESA + SC5->C5_SEGURO + SC5->C5_FRETE)
 


RestArea( aAreaSC51 )
RestArea( aAreaSC61 )
RestArea( aArea )

Return(nVlrPed)
