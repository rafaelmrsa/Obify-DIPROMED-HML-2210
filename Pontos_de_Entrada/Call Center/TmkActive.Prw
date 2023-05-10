/*                                                    São Paulo, 30 Mai 2006
----------------------------------------------------------------------------
Empresa....: Dipromed Comercio e Importação Ltda

Execução...: Apos a abertura da

Objetivo...: Possibilitar a execução de algum procedimento
             antes da abertura da tela principal

Retorno....: Nenhum retorno é esperado

Autor......: Jailton B Santos (JBS)
Data.......: 30 Mai 2006      

----------------------------------------------------------------------------
*/

#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

*-------------------------------*
User Function TmkActive()
*-------------------------------* 

Local _cUsrRet   :=  AllTrim(Upper(GetNewPar("ES_SAC_SC","RBEAZIN/RBORGES")))
Local _cUSer     := U_DipUsr()  
Local aMultCx    := {}    
Local aMultCxC   := {}    
Local oFont24  := TFont():New("Times New Roman",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont16  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont30  := TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)
Local nI := 1

If type("lDipVpa") == "U"
	Public lDipVpa  := .f. // Array que controla se o TmkVpa foi executado
EndIf
If type("aDipSenhas") == "U"
	Public aDipSenhas := {} // Array que controla as senhas.
EndIf
If type("aDipTipo9") == "U"               
	Public aDipTipo9 := {} // Array que controla as senhas.
EndIf
If type("aDipEndEnt") == "U" // JBS 31/07/2006
	Public aDipEndEnt := {} // Array que contorla os endereços de entrega
EndIf    
U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009
aDipSenhas := {} // Array que controla as senhas.
aDipTipo9  := {} // Array que controla as senhas.
aDipEndEnt := {} // Array que contorla os endereços de entrega  // JBS 31/07/2006 

If Upper(FunName())=="TMKA271"
	If AllTrim(Upper(_cUSer)) $ _cUsrRet
		U_RETPEND()          
   
	If cEmpAnt <> "04"
		FOR I := 1 TO Len(aCols)
			If !Empty(aCols[I,2]) 
			U_PRODMULTCX(aCols[I,2],aCols[I,4],aCols[I,5],@aMultCx)
    	   	 	If Len(aMultCx) == nI
					cMsgAviso := "Produto "+AllTrim(aCols[I,5])+" da NF "+aCols[I,2]+", está na regra para venda em múltipos de caixa fechada! "+CHR(10)+CHR(13)
					cMsgAviso += "-> Venda múltiplos de "+AllTrim(Str(aMultCx[Len(aMultCx),6]))+"! "
					Aviso("Atenção",cMsgAviso,{"Ok"},3) 
					nI++
				EndIf 
        	EndIf	
		Next  	
	EndIf	
      /*  	If Len(aMultCxC) > 0
	     		Define msDialog oDlg Title "Vendas em Multoplos de caixa Fechada" From 000,000 TO 015,065
					@ 005,005 LISTBOX oLbx FIELDS HEADER "N. Fiscal", "Produto", "Cx.Fechada" SIZE 250,090 OF oDlg PIXEL
					oLbx:SetArray( aMultCxC )
					oLbx:bLine := {|| {aMultCxC[oLbx:nAt,1],aMultCxC[oLbx:nAt,4],aMultCxC[oLbx:nAt,6]}}	
					@ 100,215 BUTTON oBOTAOFECHAR PROMPT "&Fechar" SIZE 040,010 PIXEL OF oDLG ACTION (oDLG:END())
				Activate dialog oDlg centered
        	EndIf*/

	EndIf           
EndIf 

Return(.t.) 


/*-----------------------------------------------------------------------------------
REGINALDO BORGES 20/04/2016
Função........:  RETPEND()                                
Objetivo......:  Mostrar os atendimento do sac com retorno pendente.	
-------------------------------------------------------------------------------------*/

User Function RETPEND()  

Local cQuery   := ''
Local cGetNota := space(9)
Local aRetPen :={}
Local oFont24  := TFont():New("Times New Roman",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont16  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Local oFont30  := TFont():New("Arial",9,28,.T.,.T.,5,.T.,5,.T.,.F.)
Private oLbx     
Private dData := CToD('  /  /    ')


U_DIPPROC(ProcName(0),U_DipUsr()) // Gravando o nome do Programa no SZU

cQuery := "SELECT UC_CODIGO, UC_XDATAR, UC_XMENRE "
cQuery += " FROM " + RetSQLName("SUC")
cQuery += " WHERE UC_FILIAL  = '"+xFilial("SUC")+"'"
cQuery += "	  AND DATEDIFF(DAY,UC_XDATAR,'"+dTos(date())+"') >= 0"
cQuery += "   AND UC_XRETSN = '1'   "
cQuery += "   AND D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY UC_CODIGO,UC_DATA "

cQuery := ChangeQuery(cQuery)

DbCommitAll()
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"UCRET",.T.,.T.)

dbSelectArea("UCRET")
dbGotop()

While ! UCRET->(Eof()) 

dData := SToD(UCRET->UC_XDATAR)

	*                  1             2              3
	aadd(aRetPen,{UCRET->UC_CODIGO,dData,UCRET->UC_XMENRE })
	
	UCRET->(DbSkip())
EndDo

If  Len(aRetPen) > 0

	Define msDialog oDlg Title "Retornos Pendentes" From 000,000 TO 015,065
		
	@ 005,005 LISTBOX oLbx FIELDS HEADER "N. SAC", "Data Ret.", "Observacao" SIZE 250,090 OF oDlg PIXEL
	oLbx:SetArray( aRetPen )
	oLbx:bLine := {|| {aRetPen[oLbx:nAt,1],aRetPen[oLbx:nAt,2],aRetPen[oLbx:nAt,3]}}	
	@ 100,215 BUTTON oBOTAOFECHAR PROMPT "&Fechar" SIZE 040,010 PIXEL OF oDLG ACTION (oDLG:END())
	
	Activate dialog oDlg centered
	
EndIf

    UCRET->(dbCloseArea())

Return()