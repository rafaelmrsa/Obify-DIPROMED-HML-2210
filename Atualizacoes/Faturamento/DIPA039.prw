/*====================================================================================\
|Programa  | DIPA039       | Autor | Maximo Canuto              | Data | 07/07/2009   |
|=====================================================================================|
|Descrição | Utilizado executar novamente o ponto de entrada SF2460I                  |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPA039                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Histórico....................................|
|Maximo    | DD/MM/AA - Descrição                                                     |
|Maximo    | DD/MM/AA - Descrição                                                     |
\====================================================================================*/

#include "RwMake.ch"

User Function DIPA039()
 
Local cSF2460I := "MAXIMO"    
Private _cNFiscal := Space(06) 
Private _cSerie   := Space(02)   
Private cfilSC5 := xFilial("SC5")
Private cfilSC9 := xFilial("SC9")
Private cfilSF2 := xFilial("SF2")
Private cfilSA1 := xfilial("SA1")
Private cfilSE1 := xfilial("SE1")

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If !(FUNNAME()$"MATA460/MATA460A/DIPA056")
	SF2->(DbOrderNickName("F2OK2")) // Posicionando Nota Fiscal
	SF2->(DbSeek(cfilSF2+cMarca))	                                              
    
	If EMPTY(SF2->F2_IDINTER)    
	    If !Empty(SF2->F2_FIMP)
   			MsgBox("NOTA FISCAL JÁ TRANSMITIDA PARA A SEFAZ. É NECESSÁRIO FAZER CARTA DE CORREÇÃO CASO CONFIRME A ALTERAÇÃO DA TRANSPORTADORA OU DO TIPO DE FRETE!!","Atencao","INFO")
	    Endif
	    U_DIPA017()
	    U_M460FIM() 
	    Return()
	Else
		MsgBox("ALTERAÇÃO NÃO PERMITIDA. NOTA FISCAL JÁ SE ENCONTRA EM VIAGEM!!","Atencao","ALERT")	
	    Return()
	Endif
	
	SC9->(dbsetOrder(6))            // Posicionando SC9
	SC9->(DbSeek(cfilSC9+SF2->F2_SERIE+SF2->F2_DOC))
Endif

SA1->(dbSetOrder(1))            // Posicionando Cliente
SA1->(dbSeek(cfilSA1+SF2->F2_CLIENTE+SF2->F2_LOJA))

If !__TTSInUse
	MsgAlert("O sistema identificou Falhas na gravação da NF anterior - "+SF2->F2_DOC+Chr(13)+Chr(10)+" Informe novamente dados de Separação desta NF")
	U_TelSepar(.T.) // Tela de Separação
	U_SF2460I()
EndIf

SE1->(dbSetOrder(1))            // Posicionando Cliente
SE1->(dbSeek(cfilSE1+SF2->F2_SERIE+SF2->F2_DOC))
 
If !(FUNNAME()$"MATA460/MATA460A/DIPA056")
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(cfilSC5+SC9->C9_PEDIDO))   
Endif

U_M460FIM() 

Return(.T.) 
