#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "MSOLE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "COLORS.CH"
/*
PONTO.......: A261TOK           PROGRAMA....: MATA261
DESCRIÇÄO...: VALIDACAO DA TRANSFERENCIA MOD 2
UTILIZAÇÄO..: O ponto sera disparado na chamada da funcao de validacao
geral dos itens digitados.
Serve para validar se o movimento pode ser efetuado ou nao


PARAMETROS..: UPAR do tipo X : Nenhum


RETORNO.....: URET do tipo X : Deve retornar um valor logico indicando:

RETORNO .T. - Confirma movimento
==================================================================================================

10/12/04 - RAFAEL - COLOCAÇÃO DA VALIDAÇÃO DE LOTE
*/

User Function a261TOK()

Local _cD3_Explic := ""
Local _lRetorno   := .T.
Local _lRetEm     := .T. 
Local _nEmaQua    := 0
Local i                  
Local nI		  := 0                      
Local nJ		  := 0
Local nK		  := 0
Local aMsg 		  := {}
Local aMsgIt 	  := {}
Local cTiMail     := ""   
Local cEmail      := GetNewPar("ES_A261TFM","reginaldo.borges@dipromed.com.br;lourival.nunes@dipromed.com.br;armazenamento@dipromed.com.br")
//Local cEmail      := _Emails
//Local cEmail      := If(cEmpAnt+cFilAnt=='0401',"vendas@healthquality.ind.br",_Emails) //Comentando RBorges 03/10/2018
Local aMsgMail    := {}                                                             
Local cEnd		  := CHR(10)+CHR(13)
Local cMsg		  := "" 
Local nPosExplic  := aScan(aHeader, { |x| Alltrim(x[2]) == "D3_EXPLIC" })

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If _lRetorno //MCVN - 03/06/2008
	If M->dA261Data<>DDataBase
		MSGINFO("Data de emissão incorreta, A data deve ser igual a database do sistema!")
		_lRetorno := .f.
	EndIf
EndIf

If _lRetorno
	For nI:=1 to len(aCols)
		If aCols[nI,4] <>  aCols[nI,9] .And. aCols[nI,4] == "01"  // Se está saindo do local 01
		   If !u_DipVldRes(aCols[nI,1],aCols[nI,4],aCols[nI,16],"P")
				u_DipRetPed(aCols[nI,1],aCols[nI,12],@aMsgMail,aCols[nI,16])
				If Len(aMsgMail)>0       
					For nJ:=1 to Len(aMsgMail)
						cMsg += "Produto/Lote: "+aMsgMail[nJ,1]+cEnd
						For nK:=1 to Len(aMsgMail[nK,2])
							cMsg += aMsgMail[nJ,2,nK,1]+" "+aMsgMail[nJ,2,nK,2]+cEnd
						Next nK
						cMsg += cEnd
					Next nJ
			                                      
					Aviso("Atenção","O(s) produto(s) não pode(m) ser movimentado(s), pois possui(em) reserva. "+cEnd+;
						"Verifique a reserva com a vendedora e execute o processo de baixa manual."+cEnd+cEnd+;
						cMsg,{"Ok"},3)
						
					DipWF(aMsgMail,aCols[nI,5])
				EndIf
				_lRetorno := .F.
		   EndIf
		EndIf
	Next nI
EndIf


//Giovani Zago 28/10/11
If _lRetorno
	aadd(aMsg,{"Documento",cDocumento})
	aadd(aMsg,{	"Operador",Upper(U_DipUsr()) })
	aadd(aMsgIt,{"Produto        ","Armazem - Ender. Ori.","Armazem - Ender. Dest.","Lote Ori.","Lote Dest.","Dt. Valid. Ori.","Dt. Valid. Dest.","Explicação" })
	for i := 1 to len(acols)
		If 	!aCols[ i , Len(aHeader)+1 ]  .and. _lRetorno

			If aCols[i,4] <> aCols[i,9]
				_lRetEm := .f.				
				If AllTrim(aCols[i,4])== "01" .And.( AllTrim(aCols[i,9])=="06" .Or. AllTrim(aCols[i,9])=="08") .And. cEmpAnt=="01"
					_NEMAQUA += 1
				EndIf				
			Endif
			
			If !Empty(aCols[i,20])
				If aCols[i,12] <> aCols[i,20]
					_lRetEm := .f.
				Endif
			Endif
	
			If dtoc(aCols[i,14]) <> dtoc(aCols[i,21])
				_lRetEm := .f.
			Endif
			
			If !"ACD"$AllTrim(FunName())
				If Empty(alltrim(aCols[i,nPosExplic]))
					Aviso("Atenção","Informar o motivo da transferencia no campo explicação!")
					_lRetorno := .F.
					_lRetEm   := .T.
				Else
					_lRetEm   := .F.
				EndIf
			EndIf
								
			aadd(aMsgIt,{alltrim(aCols[i,1])+" - "+alltrim(aCols[i,2]),alltrim(aCols[i,4])+" - "+alltrim(aCols[i,5]),alltrim(aCols[i,9])+" - "+alltrim(aCols[i,10]),alltrim(aCols[i,12]),If(Empty(alltrim(aCols[i,20])),alltrim(aCols[i,12]),alltrim(aCols[i,20])),dtoc(aCols[i,14]),dtoc(aCols[i,21]),alltrim(aCols[i,23]) })
		Endif
	Next i     
	
	If !_lRetEm				
		If _NEMAQUA > 0
			cEmail +=";qualidade@dipromed.com.br"
		EndIf       
		
		U_M261Email(aMsg,cTiMail,cEmail,aMsgIt)
		
		TransfMII(aMsg,_NEMAQUA)		
	Endif
Endif


If _lRetorno                           
	nPosCod := aScan(aHeader,{|x| Alltrim(x[2]) == "D3_COD"})
	nPosQtd := aScan(aHeader,{|x| Alltrim(x[2]) == "D3_QUANT"})   
	nPosLoc := aScan(aHeader,{|x| Alltrim(x[2]) == "D3_LOCAL"})   	
	for nI := 1 to len(acols)
		If !aCols[nI,Len(aHeader)+1] .And. _lRetorno .And. aCols[nI,nPosLoc]=="01"
			cDipCod   := aCols[nI,nPosCod]
			nDipQtd   := aCols[nI,nPosQtd]       
			_lRetorno := u_Dip071Vld(cDipCod,nDipQtd) 
		Endif
	next nI
Endif

Return(_lRetorno)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A261TOK   ºAutor  ³Microsiga           º Data ³  07/31/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DipWF(aMsgMail,cLocaliz)
Local aMsg 	 	:= {}                                                     
Local cFrom     := "protheus@dipromed.com.br"
Local cFuncSent := "A261TOK(DipWF)"
Local cMsgCic   := ""
Local cAssunto	:= "PRODUTO COM RESERVA-TRASFERENCIA MOD 2. "+cLocaliz
Local cEnd		:= CHR(10)+CHR(13)
DEFAULT aMsgMail := {}


Aadd(aMsg,{"Endereço: ",cLocaliz})

cMsgCic += "ATENÇÃO!!!"+cEnd
cMsgCic += "PRODUTO COM RESERVA-TRANSFERENCIA MOD 2 - "+cLocaliz+cEnd
cMsgCic += "ENTRE EM CONTATO COM A VENDEDORA PARA RETIRAR A RESERVA"+cEnd
cMsgCic += cEnd
For nI:=1 to Len(aMsgMail)
	Aadd(aMsg,{"Produto/Lote: ",aMsgMail[nI,1]})
	
	For nJ:=1 to Len(aMsgMail[nI,2])  	   
		Aadd(aMsg,{aMsgMail[nI,2,nJ,1],aMsgMail[nI,2,nJ,2]})
	Next nJ                    
	
	Aadd(aMsg,{" - "," - "})
Next nI

Aadd(aMsg,{"Usuário:   ",U_DipUsr()})

cMsgCic += cEnd
cMsgCic += "Usuário: "+U_DipUsr()
		
U_DIPCIC(cMsgCic,GetNewPar("ES_CICA261","DIEGO.DOMINGOS"))//envia cic

U_UEnvMail(GetNewPar("ES_MAIA261","diego.domingos@dipromed.com.br"),cAssunto,aMsg,"",cFrom,cFuncSent)

Return     
/*------------------------------------------------------------------------+
+ Funcao:TransfMII()    |  Autor: RBORGES     |    Data: 16/03/16         +                                                     
+ Disparar CIC de aviso das transferências mod2 se armazem de origem ou   +
+ lote de origem ou validade de origem for difente do destino.            +
-------------------------------------------------------------------------*/
Static Function TransfMII(aMsg,nEmaQ)
Local aArea       := GetArea()
Local cDeIc       := "protheus@dipromed.com.br"
Local cCICDest    := Upper(GetNewPar("ES_CIC_TM","REGINALDO.BORGES,LOURIVAL.NUNES")) // Usuários que receberão CIC´s
Local cAttachIc   :=  "  a"
Local cFuncSentIc :=   "A261TOK.PRW "
 	
dbSelectArea("SM0")
	               
_aMsgIc := {}      

cMSGcIC       := " EMPRESA:__ " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOME", cEmpAnt + cFilAnt, 1, "" ) ) ) +"/"+ Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) )   +CHR(13)+CHR(10)+CHR(13)+CHR(10)
cMSGcIC       += "TRANSFERENCIA MANUAL - VERIFICAR E-MAIL!"	+CHR(13)+CHR(10)+CHR(13)+CHR(10)
cMSGcIC       += " DOCUMENTO:______  "+ aMsg[1,2] +CHR(13)+CHR(10)+CHR(13)+CHR(10)
cMSGcIC       += " OPERADOR:_ " + aMsg[2,2]
    
If nEmaQ > 0
	cCICDest +=",RAFAELA.BEAZIN"
EndIf
                      
U_DIPCIC(cMSGcIC,cCICDest)

RestArea(aArea)	

return() 