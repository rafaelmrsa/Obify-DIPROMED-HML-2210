/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPV002() บAutor  ณJailton B Santos-JBSบ Data ณ 26/02/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa chamado da validacao Codigo do cliente, para ava- บฑฑ
ฑฑบ          ณ liar se o cliente pode faturar pelo empresa corrente.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบPARAMETRO ณ No X3_VALID campo: C5_CLIENTE e C5_LOJA                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ -> MV_DIPV02A -> Condicao 01 (Avalia a condicao 01)        บฑฑ
ฑฑบ          ณ -> MV_DIPV02B -> Mensagem 01 (Mensagem de critica 01)      บฑฑ
ฑฑบ          ณ -> MV_DIPV02C -> Condicao 02 (Avalia a condicao 02)        บฑฑ
ฑฑบ          ณ -> MV_DIPV02D -> Mensagem 02 (Mensagem de critica 02)      บฑฑ
ฑฑบ          ณ -> MV_DIPV02E -> Condicao 03 (Avalia a condicao 03)        บฑฑ
ฑฑบ          ณ -> MV_DIPV02F -> Mensagem 03 (Mensagem de critica 03)      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ E assim sucessivamente ate a condicao 13:                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ -> MV_DIPV02Y -> Condicao 13 (Avalia a condicao 13)        บฑฑ
ฑฑบ          ณ -> MV_DIPV02Z -> Mensagem 13 (Mensagem de critica 13)      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Faturamento - Dipromed                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
  
User Function DIPV002(cNomeRotina)  

Local cCliente := ''
Local cLojaCli := ''
Local lRet     := .T.  
Local aArea    := GetArea()
Local _aRet    := {} 
Local cObsSAC  := ""
Local nI       := 0

local cMvDpv02A := fGetNewPar("MV_DPV002A",".T.") // Condicao 001 
local cMvDpv02B := fGetNewPar("MV_DPV002B"," ")   // Mensagem 01
local cMvDpv02C := fGetNewPar("MV_DPV002C",".T.") // Condicao 02
local cMvDpv02D := fGetNewPar("MV_DPV002D"," ")   // Mensagem 02
local cMvDpv02E := fGetNewPar("MV_DPV002E",".T.") // Condicao 03
local cMvDpv02F := fGetNewPar("MV_DPV002F"," ")   // Mensagem 03
local cMvDpv02G := fGetNewPar("MV_DPV002G",".T.") // Condicao 04
local cMvDpv02H := fGetNewPar("MV_DPV002H"," ")   // Mensagem 04
local cMvDpv02I := fGetNewPar("MV_DPV002I",".T.") // Condicao 05
local cMvDpv02J := fGetNewPar("MV_DPV002J"," ")   // Mensagem 05
local cMvDpv02K := fGetNewPar("MV_DPV002K",".T.") // Condicao 06
local cMvDpv02L := fGetNewPar("MV_DPV002L"," ")   // Mensagem 06
local cMvDpv02M := fGetNewPar("MV_DPV002M",".T.") // Condicao 07
local cMvDpv02N := fGetNewPar("MV_DPV002N"," ")   // Mensagem 07
local cMvDpv02O := fGetNewPar("MV_DPV002O",".T.") // Condicao 08
local cMvDpv02P := fGetNewPar("MV_DPV002P"," ")   // Mensagem 08
local cMvDpv02Q := fGetNewPar("MV_DPV002Q",".T.") // Condicao 09
local cMvDpv02R := fGetNewPar("MV_DPV002R"," ")   // Mensagem 09
local cMvDpv02S := fGetNewPar("MV_DPV002S",".T.") // Condicao 10
local cMvDpv02T := fGetNewPar("MV_DPV002T"," ")   // Mensagem 10
local cMvDpv02U := fGetNewPar("MV_DPV002U",".T.") // Condicao 11
local cMvDpv02V := fGetNewPar("MV_DPV002V"," ")   // Mensagem 11
local cMvDpv02W := fGetNewPar("MV_DPV002W",".T.") // Condicao 12
local cMvDpv02X := fGetNewPar("MV_DPV002X"," ")   // Mensagem 12
local cMvDpv02Y := fGetNewPar("MV_DPV002Y",".T.") // Condicao 13
local cMvDpv02Z := fGetNewPar("MV_DPV002Z"," ")   // Mensagem 13        

//-------------------------------------------------------------------------------------------------------------------------
// JBS 11/06/2010 -  Validando Geracao de Empenhos de Licitacao.
// Executado quando estiver gerando empenho de licitacao para gerar pedido de venda. Para pre-validar o cliente. Pois o 
// fato de nao validar a atividade do cliente, impede a geracao do pedido, porem o empenho fica como concluido e o 
// o usuario nao consegue fazer mais o empenho. So o Administrador, atraves  do MpSdu.
//-------------------------------------------------------------------------------------------------------------------------
If cNomeRotina <> NIL
	M->C5_CLIENTE := cCliente := M->UA8_CODCL
	M->C5_LOJACLI := cLojaCli := M->UA8_LOJA
Else
	cCliente := If(ReadVar() = "MV_PAR01",MV_PAR01,M->C5_CLIENTE)
	cLojaCli := If(ReadVar() = "MV_PAR01",'01',Iif(Empty(M->C5_LOJACLI),'01', M->C5_LOJACLI))
EndIf

If !(Type("M->C5_TIPO") == "U")
	If  M->C5_TIPO $ 'DB'
    	Return(.T.)
	EndIf
	If !u_DipVClVen()
		Return(.F.)
	EndIf
Endif 


If ReadVar() <> "MV_PAR01" .and. cNomeRotina == NIL
	If !(Inclui)  
		If  (SC5->C5_EMISSAO  <= CTOD('28/02/2010') .OR.	SC5->C5_DTPEDIDO <= CTOD('28/02/2010'))
			Return(.T.)
		Endif
	Endif
Endif	  
//---------------------------------------------------------------------------
SA1->( DbSetOrder(1))
//---------------------------------------------------------------------------
If SA1->( DbSeek(xFilial('SA1') + cCliente + cLojaCli))
	
	do case
		case !(&(cMvDpv02A)); lRet := .F.; MsgInfo(AllTrim(cMvDpv02B),'Aten็ใo!')//Aviso('Aten็ใo',AllTrim(cMvDpv02B),{'Ok'}) 
		case !(&(cMvDpv02C+' .OR. '+cMvDpv02E)); lRet := .F.; MsgInfo(AllTrim(cMvDpv02D),'Aten็ใo!')//Aviso('Aten็ใo',AllTrim(cMvDpv02D),{'Ok'})		
		case !(&(cMvDpv02G)); lRet := .F.; MsgInfo(AllTrim(cMvDpv02H),'Aten็ใo!')//Aviso('Aten็ใo',AllTrim(cMvDpv02H),{'Ok'})
		case !(&(cMvDpv02I)); lRet := .F.; MsgInfo(AllTrim(cMvDpv02J),'Aten็ใo!')//Aviso('Aten็ใo',AllTrim(cMvDpv02J),{'Ok'})
		case !(&(cMvDpv02K)); lRet := .F.; MsgInfo(AllTrim(cMvDpv02L),'Aten็ใo!')//Aviso('Aten็ใo',AllTrim(cMvDpv02L),{'Ok'})
		case !(&(cMvDpv02M)); lRet := .F.; MsgInfo(AllTrim(cMvDpv02N),'Aten็ใo!')//Aviso('Aten็ใo',AllTrim(cMvDpv02N),{'Ok'})
		case !(&(cMvDpv02O)); lRet := .F.; MsgInfo(AllTrim(cMvDpv02P),'Aten็ใo!')//Aviso('Aten็ใo',AllTrim(cMvDpv02P),{'Ok'})
		case !(&(cMvDpv02Q)); lRet := .F.; MsgInfo(AllTrim(cMvDpv02R),'Aten็ใo!')//Aviso('Aten็ใo',AllTrim(cMvDpv02R),{'Ok'})
		case !(&(cMvDpv02S)); lRet := .F.; MsgInfo(AllTrim(cMvDpv02T),'Aten็ใo!')//Aviso('Aten็ใo',AllTrim(cMvDpv02T),{'Ok'})
		case !(&(cMvDpv02U)); lRet := .F.; MsgInfo(AllTrim(cMvDpv02V),'Aten็ใo!')//Aviso('Aten็ใo',AllTrim(cMvDpv02V),{'Ok'})
		case !(&(cMvDpv02W)); lRet := .F.; MsgInfo(AllTrim(cMvDpv02X),'Aten็ใo!')//Aviso('Aten็ใo',AllTrim(cMvDpv02X),{'Ok'})
		case !(&(cMvDpv02Y)); lRet := .F.; MsgInfo(AllTrim(cMvDpv02Z),'Aten็ใo!')//Aviso('Aten็ใo',AllTrim(cMvDpv02Z),{'Ok'})
		Otherwise 
		     lRet := .T.
	endcase

	// Libera altera็ใo/exclusใo de pedido somente com senha! MCVN - 27-04-10
	If !("DIPAL10" $ FUNNAME()) .AND. !("TMK"$FunName()) 
		If !lRet .And. !(PROCNAME(1) == 'U_M410ALOK')    .And. (&(cMvDpv02A))
			lRet := U_SENHA("EMP",0,0,0)
	    ElseIf !lRet .And. (PROCNAME(1) == 'U_M410ALOK') .And. (&(cMvDpv02A))
     		lRet := .T.
		EndIf                                
	Endif
	
    If !lRet .and.ReadVar() <> "MV_PAR01"
       M->C5_CLIENTE := CriaVar("C5_CLIENTE") 
       M->C5_LOJACLI := CriaVar("C5_LOJACLI")
    EndIf                              
    
    If ReadVar()=="M->C5_CLIENTE" .And. (Type("l410Auto")=="U" .Or. !l410Auto) .And. SA1->A1_TIPO=="F" .And. SA1->A1_CONTRIB=="2" .And. SA1->A1_ESTE<>"SP"
    	If cEmpAnt == '04'
	    	If !(SA1->A1_ESTE$GetNewPar("ES_ESTNGCF",""))
		    	Aviso("Aten็ใo","Pedido necessita de GUIA. Horแrio de corte 12h.",{"Ok"},1)
		    EndIf
		Else
	    	If !(SA1->A1_ESTE$GetNewPar("ES_ESTNGCF",""))
		    	Aviso("Aten็ใo","Pedido necessita de GUIA. Horแrio de corte 14h.",{"Ok"},1)
		    EndIf		
		Endif    
    EndIf              
   	
   	If !("DIPAL10" $ FUNNAME())
		TitCli(SA1->A1_COD, SA1->A1_LOJA, SA1->A1_LC, SA1->A1_SALPEDL, SA1->A1_SALDUP)
	EndIf	
   	
	If !("DIPAL10" $ FUNNAME()) .And. !Empty(SA1->A1_OBSSAC)
		cObsSAC := SA1->A1_OBSSAC
 		Aviso("ATENวรO!"," Hแ observa็ใo de pend๊ncia do SAC para este cliente."+CHR(10)+CHR(13)+;
	          cObsSAC,{"Ok"},3)	
	EndIf	
	
	If cEmpAnt <> "04"
		If ("MATA410" $ FUNNAME()) .And. Empty(SA1->A1_LFVISA) //Reginaldo Borges 26/06/2017
			U_MENCNAE()
		EndIf

		If !Empty(SA1->A1_LFVISA) .And. SA1->A1_VLLVISA < dDATABASE //Reginaldo Borges 04/01/2018
			MsgInfo("Data de validade da licen็a vencida.","ATENวรO!")
		EndIF
	EndIF
	
	
	If cEmpAnt+cFilAnt == "0101" .And. (SA1->A1_TIPO == "R" .Or. !Empty(SA1->A1_INSCR))  .And. (Type("l410Auto")=="U" .Or. !l410Auto)
		_aRet := u_DipTemAnv()
		If Len(_aRet)>0
			If !_aRet[1]	          
			
			    cCampos := ""
				
			    For nI:=1 To Len(_aRet[2])
			    	cCampos += " * "+ AvSx3(_aRet[2,nI],5)+" ("+_aRet[2,nI]+") "+CHR(10)+CHR(13)
				Next nI
				
				If GetNewPar("ES_VLDANVI",.F.)
					Aviso("Aten็ใo","O pedido ficarแ bloqueado. "+CHR(10)+CHR(13)+;
								"Para liberar preencha o(s) campo(s) no cadastro do cliente:"+CHR(10)+CHR(13)+;
								cCampos,{"Ok"},3)
				EndIf				
				
				/*
				Else                             
					Aviso("Aten็ใo","Preencha os seguintes campos no cadastro do cliente:"+CHR(10)+CHR(13)+;
								cCampos,{"Ok"},3)
				EndIf
				*/
				
			EndIf
		EndIf
	EndIf
Else 

    MsgInfo('Cliente nใo cadastrado.','Aten็ใo!') 
    lRet := .F.

EndIf
 
RestArea(aArea)
Return(lRet)                                                                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGetNewPar()บAutorณJailton B Santos-JBSบ Data ณ 26/02/2010  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSubstitui o GetNewPar, pois o mesmo se perde quando o para- บฑฑ
ฑฑบ          ณmetro e atualizado.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especificacoes - Faturamento - Dipromed                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGetNewPar(cCampo,cRet)  
//---------------------------------------------------------------------------
Local aArea    := GetArea()
Local aAreaSX6 := SX6->(GetArea())
//---------------------------------------------------------------------------
SX6->(DbSetOrder(1))
SX6->(DbGoTop())
//---------------------------------------------------------------------------
If SX6->(DbSeek(cFilAnt+cCampo)) .or. SX6->(DbSeek(Space(2)+cCampo))
    cRet := SX6->X6_CONTEUD
EndIf       
//---------------------------------------------------------------------------
SX6->(RestArea(aAreaSX6)) 
//-----------------------------------------mcan----------------------------------
Return(cRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfVerCli() บAutor  ณJailton B Santos-JBSบ Data ณ 14/06/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณJBS 11/06/2010 - Validando Geracao de Empenhos de Licitacao.บฑฑ
ฑฑบ          ณExecutado quando estiver gerando empenho de licitacao para  บฑฑ
ฑฑบ          ณgerar pedido de venda. Para pre-validar o cliente.  Pois o  บฑฑ
ฑฑบ          ณfato de nao validar a atividade do cliente, impede a geracaoบฑฑ
ฑฑบ          ณdo pedido, porem o empenho fica como concluido e o usuario  บฑฑ
ฑฑบ          ณnao consegue fazer mais o empenho. So o Administrador,      บฑฑ
ฑฑบ          ณatraves  do MpSdu.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Licitacoes Dipromed                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fVerCli(cNomeRotina)
Local cRet := ''

//-------------------------------------------------------------------------------------------------------------------------
// 
// Executado quando estiver gerando empenho de licitacao para gerar pedido de venda. Para pre-validar o cliente. Pois o 
// fato de nao validar a atividade do cliente, impede a geracao do pedido, porem o empenho fica como concluido e o 
// o usuario nao consegue fazer mais o empenho. So o Administrador, atraves  do MpSdu.
//-------------------------------------------------------------------------------------------------------------------------

do case
case cNomeRotina <> NIL .and. cNomeRotina == 'UA1CLIENTE' ; cCliente := M->UA1_CODCL ; M->C5_CLIENTE := M->UA1_CODCL; M->C5_LOJACLI := M->UA1_LOJA
case cNomeRotina <> NIL .and. cNomeRotina == 'UA1LOJACLI' ; cLojaCli := M->UA1_LOJA  ; M->C5_CLIENTE := M->UA1_CODCL; M->C5_LOJACLI := M->UA1_LOJA
case cNomeRotina <> NIL .and. cNomeRotina == 'UA8CLIENTE' ; cCliente := M->UA8_CODCL ; M->C5_CLIENTE := M->UA8_CODCL; M->C5_LOJACLI := M->UA8_LOJA; cRet := M->UA8_CODCL
case cNomeRotina <> NIL .and. cNomeRotina == 'UA8LOJACLI' ; cLojaCli := M->UA8_LOJA  ; M->C5_CLIENTE := M->UA8_CODCL; M->C5_LOJACLI := M->UA8_LOJA; cRet := M->UA9_LOJA
endcase     

Return(cRet)                                                                                                                                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPV002   บAutor  ณMicrosiga           บ Data ณ  07/16/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Valida se a vendedora pode cotar para o cliente           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipVClVen()
Local lRet 		:= .T.
Local cParam 	:= GetNewPar("ES_VLDCLVE","")
Local cParamAux := ""
Local nPos 		:= 0
Local nPos2 	:= 0
Local cCliAut 	:= ""
Local cUsuAut 	:= ""

While Len(cParam)>0
	nPos := At("|",cParam)  
	If nPos <= 0
		nPos := Len(cParam)+1
	EndIf                   
	
	nPos2 := At(":",cParam)  
	
	cCliAut := SubStr(cParam,1,nPos2-1)	 
		
	cParamAux := SubStr(cParam,1,nPos-1)

	cUsuAut := SubStr(cParamAux,nPos2+1,Len(cParamAux))
	
	If M->C5_CLIENTE$cCliAut .And. Upper(u_DipUsr())<>Upper(cUsuAut)
		lRet := .F.
		Exit
	EndIf   
	
	If (Len(cParam)-nPos)>0
		cParam := Right(cParam,Len(cParam)-nPos)
	Else
		Exit
	EndIf     
EndDo  

If !lRet 
	Aviso("ES_VLDCLVE","Voc๊ nใo pode fazer cota็ใo para este cliente.",{"Ok"},1)
EndIf

Return lRet

/*
+------------------------------------------------------------+
|Autor: REGINALDO BORGES |Fun็ใo: TITCLI() |Data : 29/08/2019|
+------------------------------------------------------------+
|Objetivo......: Verificar se o cliente tem tํtulos vencidos | 
|                e mostra saldo disponํvel.                  |
-------------------------------------------------------------+
*/
Static Function TitCli(_cCliente,_cLjCli,nLimCred, nSalPedl, nSalDup)

Local cQry    := ""
Local aTitCli := {}
Local oFont24 := TFont():New("Times New Roman",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont14 := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Local nTotal  := 0
Local nValor  := 0
//NOVO 06/02/2020
Local nVlC9	  := 0
Local cSQL 	  := ""
Local dAnvisa := SA1->A1_VLLVISA
//Local aArea := GetArea()

cSQL := "SELECT SUM(C9_QTDORI*C9_PRCVEN) TOTAL_C9 " + CRLF
cSQL += "FROM "+RetSqlName("SC9")+" C9 " + CRLF
cSQL += "INNER JOIN "+RetSqlName("SC6")+" C6 ON C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_PRODUTO = C9_PRODUTO AND C9_ITEM = C6_ITEM " + CRLF
cSQL += "INNER JOIN "+RetSqlName("SC5")+" C5 ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO " + CRLF
cSQL += "WHERE C9.D_E_L_E_T_='' " + CRLF
cSQL += "AND C6.D_E_L_E_T_='' " + CRLF
cSQL += "AND C9_CLIENTE ='"+_cCliente+"' AND C9_LOJA ='"+_cLjCli+"' " + CRLF
cSQL += "AND C9_NFISCAL ='' " + CRLF
cSQL += "AND C9_BLCRED ='' " + CRLF
cSQL += "AND C5_PRENOTA IN('','S') " + CRLF
cSQL += "AND C5_PARCIAL ='' " + CRLF
cSQL += "GROUP BY C9_FILIAL,C9_CLIENTE,C9_LOJA " + CRLF
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSQL),"QRYCC2",.F.,.T.)

If !QRYCC2->(Eof())   
	nVlC9 := QRYCC2->TOTAL_C9
EndIf

QRYCC2->(dbCloseArea())
//FIM

/*
cQry := "SELECT E1_NUM,E1_PARCELA, E1_VALOR,E1_EMISSAO,E1_VENCTO, DATEDIFF(DAY,E1_VENCREA,'"+dTos(date())+"') 'DIAS_VENC' " 
cQry += " FROM "+RetSqlName("SE1") +" SE1 " "
cQry += " INNER JOIN "+RetSqlName("SA1") +" SA1 " +" ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_ = ''
cQry += " 	WHERE E1_SALDO > 0 AND "
cQry += " 	      E1_TIPO IN ('NF','FT') AND "
cQry += " 	      DATEDIFF(DAY,E1_VENCREA,'"+dTos(date())+"') >= 1 AND "
cQry += " 	      E1_CLIENTE ='"+_cCliente+"' AND "
cQry += " 	      E1_LOJA    ='"+_cLjCli+"' AND "
cQry += " 	      E1_BAIXA   = '' AND "
cQry += " 	      SE1.D_E_L_E_T_ = '' "
cQry += " ORDER BY E1_NUM, E1_PARCELA " 
cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRYTRB",.F.,.T.)
*/
//QUERY AJUSTADA DE ACORDO COM A NOVA REGRA
cQry := "SELECT E1_VENCREA FROM "+RetSqlName("SE1")+" SE1 " + CRLF
cQry += "WHERE SE1.D_E_L_E_T_ ='' " + CRLF		
cQry += "AND E1_CLIENTE ='"+_cCliente+"' " + CRLF
cQry += "AND E1_LOJA ='"+_cLjCli+"' " + CRLF
cQry += "AND E1_SALDO >0 " + CRLF
cQry += "AND E1_TIPO IN('NF','JP','FT','NDC','JUR') " + CRLF
cQry += "AND SE1.E1_VENCREA < CONVERT(VARCHAR(8),GETDATE(),112) " + CRLF
cQry += "AND E1_EMISSAO <> E1_VENCREA " + CRLF
cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRYTRB",.F.,.T.)
 
DbSelectArea("QRYTRB")
DbGoTop()
		
If !QRYTRB->(EOF())

	Define msDialog oDlg Title "POSIวรO DO CLIENTE" From 10,10 TO 25,50

	@ 010,010 say "Anvisa:" font oFont24 Pixel 	
	@ 017,010 say "Limite de Cr้dito:" font oFont24 Pixel
	@ 037,010 say "Saldo Disponํvel :" font oFont24 Pixel
	
	@ 017,080 say TransForm(nLimCred,"@E 999,999,999.99")                      font oFont24  COLOR CLR_BLUE Pixel

	If dAnvisa <= dDATABASE
		@ 010,080 say "VENCIDO!"											font oFont24 COLOR CLR_RED Pixel
		ElseIf dAnvisa > dDATABASE .AND. dAnvisa <= dDATABASE+15 
			@ 010,080 say "A VENCER!"											font oFont24 COLOR CLR_GREEN Pixel			
		Else
			@ 010,080 say "OK!"													font oFont24 COLOR CLR_BLUE Pixel
	EndIf
	
	If nLimCred > 0
		If (nLimCred-nVlC9-nSalDup) > 0
			@ 037,080 say TransForm(nLimCred-nVlC9-nSalDup,"@E 999,999,999.99") font oFont24  COLOR CLR_BLUE Pixel
		Else
			@ 037,080 say TransForm(nLimCred-nVlC9-nSalDup,"@E 999,999,999.99") font oFont24  COLOR CLR_RED Pixel	
		EndIf	
	Else
		@ 037,080 say TransForm(0,"@E 999,999,999.99") font oFont24  COLOR CLR_BLUE Pixel
	EndIf
	
	@ 060,010 say "CLIENTE COM TอTULO(S) VENCIDO(S)!!!" font oFont14  COLOR CLR_RED Pixel
	@ 095,110 BUTTON oBOTAOFECHAR PROMPT "&Fechar" SIZE 040,010 PIXEL OF oDLG ACTION (oDLG:END())
	@ 095,060 BUTTON "&Posi Cliente" SIZE 040,010 PIXEL OF oDLG ACTION (a450F4Con())


	
	Activate dialog oDlg centered

Else

	Define msDialog oDlg Title "POSIวรO DO CLIENTE" From 10,10 TO 25,50

	@ 010,010 say "Anvisa:" font oFont24 Pixel 		
	@ 017,010 say "Limite de Cr้dito:" font oFont24 Pixel
	@ 037,010 say "Saldo Disponํvel :" font oFont24 Pixel
	
	@ 017,080 say TransForm(nLimCred,"@E 999,999,999.99")                      font oFont24  COLOR CLR_BLUE Pixel

	If dAnvisa <= dDATABASE
		@ 010,080 say "VENCIDO!"											font oFont24 COLOR CLR_RED Pixel
	ElseIf dAnvisa > dDATABASE .AND. dAnvisa <= dDATABASE+15 
		@ 010,080 say "A VENCER!"											font oFont24 COLOR CLR_GREEN Pixel			
	Else
		@ 010,080 say "OK!"													font oFont24 COLOR CLR_BLUE Pixel
	EndIf
	
	If nLimCred > 0
		If (nLimCred-nVlC9-nSalDup) > 0
			@ 037,080 say TransForm(nLimCred-nVlC9-nSalDup,"@E 999,999,999.99") font oFont24  COLOR CLR_BLUE Pixel
		Else
			@ 037,080 say TransForm(nLimCred-nVlC9-nSalDup,"@E 999,999,999.99") font oFont24  COLOR CLR_RED Pixel	
		EndIf	
	Else
		@ 037,080 say TransForm(0,"@E 999,999,999.99") font oFont24  COLOR CLR_BLUE Pixel
	EndIf	
	
	@ 095,110 BUTTON oBOTAOFECHAR PROMPT "&Fechar" SIZE 040,010 PIXEL OF oDLG ACTION (oDLG:END())
	@ 095,060 BUTTON "&Posi Cliente" SIZE 040,010 PIXEL OF oDLG ACTION (a450F4Con())

	Activate dialog oDlg centered

EndIf

QRYTRB->(dbCloseArea())
 
Return
