#INCLUDE "PROTHEUS.CH"
User Function DIPA084(nTipo)                        
LOCAL nLin			:= 0       
LOCAL nOpca			:= 0
LOCAL cRetorno		:= ""
LOCAL bRefresh   	:= { || u_DipRefaz(cChave,.T.)}
LOCAL cValid     	:= "{|| Eval(bRefresh) }"
LOCAL bOK        	:= { || IIf(Dip084Ok(),(nLin:=oBrowPro:nAt,nOpca:=1,oDlgPesPro:End()),nil) }
LOCAL bCanc      	:= { || nOpca:=3,oDlgPesPro:End() }
LOCAL aTipoPes   	:= {}
LOCAL lRet		 	:= .F.
LOCAL aButtons   	:= {} 
LOCAL dDatAnalise	:= dDataBase
LOCAL dDatPro		:= dDataBase
LOCAL oTipoPes
LOCAL aOpcoes       := {}        
LOCAL lRet 			:= .F.   
LOCAL cSQL 			:= ""

PRIVATE oBrowPro
PRIVATE cChave      := Space(40)
PRIVATE aBrowPro 	:= {}
PRIVATE aBrowAux    := {}
PRIVATE lChkChk    	:= .F.
PRIVATE cTipoPes	:= "1"
PRIVATE _nLinha     := 0
PRIVATE cGetOld 	:= ""           
	                                           
If ReadVar()<>"M->C6_PRODUTO"
	Return .F.
EndIf
	
aTipoPes := {"1-Descri็ใo","2-C๓digo"}
aadd(aOpcoes,{"SB1_DESC"})
aadd(aOpcoes,{"SB1_COD"})
                             
cSQL := " SELECT "
cSQL += "   B1_DESC, B1_COD, B1_PRVSUPE, B1_PRVMINI, B1_PRVPROM, B1_PRV1, "+RetSQLName("SB1")+".R_E_C_N_O_ REC, SUM(B2_QATU-B2_QACLASS-B2_RESERVA) ESTOQUE "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SB1")
cSQL += "		LEFT JOIN " 
cSQL += 			RetSQLName("SB2")
cSQL += " 			ON "
cSQL += " 				B2_FILIAL IN('01','04') AND "
cSQL += " 				B2_COD = B1_COD AND " 
cSQL += " 				B2_LOCAL = '01' AND "
cSQL +=  				RetSQLName("SB2")+".D_E_L_E_T_ = ' ' "
cSQL += " 		WHERE "
cSQL += " 			B1_FILIAL = '"+xFilial("SB1")+"' AND "
cSQL += " 			B1_HABILIT NOT IN('N','O','L') AND "
cSQL += " 			LEFT(B1_DESC,1) NOT IN('.','Z') AND "
cSQL += " 			B1_MSBLQL<>'1' AND "
cSQL += " 			B1_TIPO<>'MC' AND "
cSQL +=  			RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY B1_DESC, B1_COD, B1_PRVSUPE, B1_PRVMINI, B1_PRVPROM, B1_PRV1, "+RetSQLName("SB1")+".R_E_C_N_O_ "
cSQL += " ORDER BY B1_DESC "


cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"SXBSB1",.T.,.T.)  
                            
While !SXBSB1->(Eof())
	aAdd(aBrowAux,{	SXBSB1->B1_DESC,;						// 1
					SXBSB1->ESTOQUE,;  						// 2  U_DIPSaldSB2(SXBSB1->B1_COD,.T.,' ')
					SXBSB1->B1_PRVSUPE,;                    // 3
					SXBSB1->B1_PRVMINI,;                    // 4
					SXBSB1->B1_PRVPROM,;                    // 5
					SXBSB1->B1_PRV1,;                       // 6
					SXBSB1->B1_COD,;                        // 7
					SXBSB1->REC})                           // 8
	SXBSB1->(dbSkip())                                          
EndDo
SXBSB1->(dbCloseArea())

//aSort(aBrowAux,,,{|x,y| x[1]<y[1]})

aBrowPro := aClone(aBrowAux)      
                  
If !Empty(&(ReadVar()))
	u_DipRefaz(AllTrim(&(ReadVar())))                
	cChave := PADR(&(ReadVar()),40)
	If AllTrim(&(ReadVar()))=="0" .And. Len(aBrowPro)==0
		cChave := Space(40)
	EndIf
EndIf        

AAdd(aButtons, {"DBG10",{|| DipVisSB1() },"Visualizar" } )

DEFINE MSDIALOG oDlgPesPro TITLE "DIPROMED - Pesquisa de Produto" FROM 008.2,000 TO 050,130 OF GetWndDefault()

@ 035,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE

oGetChave := TGet():New(035,080,{|U| IIf(PCOUNT()==0,cChave,cChave:=U)},oDlgPesPro,230,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,nil/*cchave*/)

@ 035,315 CHECKBOX oChkChk   Var lChkChk PROMPT "Pesquisar Palavra Chave" PIXEL SIZE 080, 010 OF oDlgPesPro on change DipVldChg()

oBrowPro := TcBrowse():New(050,008,500,250,,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowPro:AddColumn(TcColumn():New("Descri็ใo",nil,nil,nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[1]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,1],nil) }
  
oBrowPro:AddColumn(TcColumn():New("Estoque",nil,"@E 99,999,999",nil,nil,"RIGHT",030,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[2]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,2],nil) }

oBrowPro:AddColumn(TcColumn():New("Promo็ใo",nil,"@E 9,999.9999",nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[3]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,3],nil) }

oBrowPro:AddColumn(TcColumn():New("C",nil,"@E 9,999.9999",nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[4]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,4],nil) }

oBrowPro:AddColumn(TcColumn():New("D",nil,"@E 9,999.9999",nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[5]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,5],nil) }

oBrowPro:AddColumn(TcColumn():New("Lista",nil,"@E 9,999.9999",nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[6]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,6],nil) }
         
oBrowPro:AddColumn(TcColumn():New("Codigo",nil,nil,nil,nil,"CENTER",030,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[7]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,7],nil) }

oBrowPro:SetArray(aBrowPro)
oBrowPro:BLDBLCLICK := bOK
oGetChave:SetFocus(oGetChave)

If _nLinha > 0 .And. Len(aBrowPro) >= _nLinha
	oBrowPro:GoPosition(_nLinha)
Else
	oBrowPro:GoTop()
EndIf

ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,aButtons) }) CENTERED

If nOpca==1
	If Len(aBrowPro)>0 .And. nLin>0 
		M->C6_PRODUTO := aBrowPro[nLin,7]
		SB1->(dbGoTo(aBrowPro[nLin,8]))
	EndIf
EndIf
	
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPFILSB1 บAutor  ณMicrosiga           บ Data ณ  05/24/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipRefaz(cChave,lTela)
Local nPos 	   := 0                        
Local _lAchou  := .F.
DEFAULT cChave := ""
DEFAULT lTela  := .F.
 
If AllTrim(cGetOld) <> AllTrim(cChave) .Or. lChkChk
	If Len(aBrowPro)<> Len(aBrowAux)
		aBrowPro  := aClone(aBrowAux)
	EndIf	
	If Left(cTipoPes,1)=="1"
		If AllTrim(cChave)=="0"			
			If (nPos:=aScan(aBrowPro,{|x| x[8]==SB1->(Recno()) }))>0
				_nLinha := nPos
			EndIf			
		ElseIf lChkChk
			aBrowPro := {}
			aEval(aBrowAux, {|x| IIf(AllTrim(cChave)$x[1],aAdd(aBrowPro,x),nil) })				
		ElseIf (nPos:=aScan(aBrowPro,{|x|   Left(x[1],Len(AllTrim(cChave)))==AllTrim(cChave) }))>0
			_nLinha := nPos
		ElseIf (nPos:=aScan(aBrowPro,{|x|   Left(x[7],Len(AllTrim(cChave)))==AllTrim(cChave) }))>0
			_nLinha := nPos	
		Else
			_nLinha := 1
		EndIf		        
	Else
		If (nPos:=aScan(aBrowPro,{|x| x[7]==PadR(cChave,15)}))>0
			_nLinha := nPos
		EndIf
	EndIf
		       
	If lTela
		If Len(aBrowPro)<> Len(aBrowAux)
			oBrowPro:SetArray(aBrowPro)
		EndIf		
		If _nLinha>0 .And. Len(aBrowPro)>=_nLinha
			oBrowPro:GoPosition(_nLinha)
		Else
			oBrowPro:GoTop()
		EndIf	
		oBrowPro:Refresh()
	EndIf
	cGetOld := cChave
EndIf
	
Return                                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA084   บAutor  ณMicrosiga           บ Data ณ  06/02/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Dip084Ok()
Local lRet := .F.

If oBrowPro:nAt>0 .And. Len(aBrowPro)>0
	lRet := .T.
Else
	Aviso("Aviso","Nenhum produto selecionado",{"Ok"},1)
EndIf

Return lRet 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA084   บAutor  ณMicrosiga           บ Data ณ  06/06/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipVisSB1()
Local aAreaSB1 := SB1->(GetArea())

If Len(aBrowPro)>0 .And. Type("oBrowPro:nAt")<>"U" 
	SB1->(dbGoTo(aBrowPro[oBrowPro:nAt,8]))
	AxVisual("SB1",aBrowPro[oBrowPro:nAt,8],2)
EndIf

RestArea(aAreaSB1)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA084   บAutor  ณMicrosiga           บ Data ณ  06/06/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipVldChg()
cGetOld  := ""
aBrowPro := aClone(aBrowAux)
oBrowPro:SetArray(aBrowPro)
oBrowPro:GoTop()
oGetChave:SetFocus(oGetChave)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPA084b   บAutor  ณReginaldo Borges   บ Data ณ  23/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consulta padrใo SB1DIP com multipla escolha de produtos    บฑฑ
ฑฑบ          ณ F3 - C6_PRODUTO                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ VENDAS - Pedido de Vendas                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DIPA084b(nTipo)
LOCAL nLin			:= 0       
LOCAL nOpca			:= 0
LOCAL cRetorno		:= ""
LOCAL bRefresh   	:= { || u_DipRefab(cChave,.T.)}
LOCAL cValid     	:= "{|| Eval(bRefresh) }"
LOCAL bOK        	:= { || IIf((),(nLin:=oBrowPro:nAt,nOpca:=1,oDlgPesPro:End()),nil) }
LOCAL bCanc      	:= { || nOpca:=3,oDlgPesPro:End() }
LOCAL aTipoPes   	:= {}
LOCAL lRet		 	:= .F.
LOCAL aButtons   	:= {} 
LOCAL dDatAnalise	:= dDataBase
LOCAL dDatPro		:= dDataBase
LOCAL oTipoPes
LOCAL aOpcoes       := {}        
LOCAL lRet 			:= .F.   
LOCAL cSQL 			:= ""
LOCAL oOk           := LoadBitMap(GetResources(), "LBOK")
LOCAL oNo           := LoadBitMap(GetResources(), "LBNO")

PRIVATE oBrowPro
PRIVATE cChave      := Space(40)
PRIVATE aBrowPro 	:= {}
PRIVATE aBrowAux    := {}
PRIVATE lChkChk    	:= .F.
PRIVATE cTipoPes	:= "1"
PRIVATE _nLinha     := 0
PRIVATE cGetOld 	:= ""        
PRIVATE cSeq        := "01"
                                           
If ReadVar()<>"M->C6_PRODUTO"
	Return .F.
EndIf

If M->C5_TIPODIP == "1"
	MsgStop("Op็ใo disponivel para Or็amentos, para incluir novos itens em pedidos, utilziar a tecla F3")
	Return .F.
EndIf	

aTipoPes := {"1-Descri็ใo","2-C๓digo"}
aadd(aOpcoes,{"SB1_DESC"})
aadd(aOpcoes,{"SB1_COD"})
                             
cSQL := " SELECT "
cSQL += "   B1_DESC, B1_COD, B1_PRVSUPE, B1_PRVMINI, B1_PRVPROM, B1_PRV1, "+RetSQLName("SB1")+".R_E_C_N_O_ REC, SUM(B2_QATU-B2_QACLASS-B2_RESERVA) ESTOQUE "
cSQL += " 	FROM "
cSQL +=  		RetSQLName("SB1")
cSQL += "		LEFT JOIN " 
cSQL += 			RetSQLName("SB2")
cSQL += " 			ON "
cSQL += " 				B2_FILIAL IN('01','04') AND "
cSQL += " 				B2_COD = B1_COD AND " 
cSQL += " 				B2_LOCAL = '01' AND "
cSQL +=  				RetSQLName("SB2")+".D_E_L_E_T_ = ' ' "
cSQL += " 		WHERE "
cSQL += " 			B1_FILIAL = '"+xFilial("SB1")+"' AND "
cSQL += " 			B1_HABILIT NOT IN('N','O','L') AND "
cSQL += " 			LEFT(B1_DESC,1) NOT IN('.','Z') AND "
cSQL += " 			B1_MSBLQL<>'1' AND "
cSQL += " 			B1_TIPO<>'MC' AND "
cSQL +=  			RetSQLName("SB1")+".D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY B1_DESC, B1_COD, B1_PRVSUPE, B1_PRVMINI, B1_PRVPROM, B1_PRV1, "+RetSQLName("SB1")+".R_E_C_N_O_ "
cSQL += " ORDER BY B1_DESC "


cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"SXBSB1",.T.,.T.)  
                            
While !SXBSB1->(Eof())
	aAdd(aBrowAux,{	.F.,;				  // 1
					SXBSB1->B1_DESC,;	  // 2
					SXBSB1->ESTOQUE,;  	  // 3  
					SXBSB1->B1_PRVSUPE,;  // 4
					SXBSB1->B1_PRVMINI,;  // 5
					SXBSB1->B1_PRVPROM,;  // 6
					SXBSB1->B1_PRV1,;     // 7
					SXBSB1->B1_COD,;      // 8
					space(2),;            // 9
					SXBSB1->REC})         // 10
	SXBSB1->(dbSkip())                                          
EndDo
SXBSB1->(dbCloseArea())

aBrowPro := aClone(aBrowAux)      
                  
If !Empty(&(ReadVar()))
	u_DipRefab(AllTrim(&(ReadVar())))                
	cChave := PADR(&(ReadVar()),40)
	If AllTrim(&(ReadVar()))=="0" .And. Len(aBrowPro)==0
		cChave := Space(40)
	EndIf
EndIf        

AAdd(aButtons, {"DBG10",{|| DipViSB1() },"Visualizar" } )

DEFINE MSDIALOG oDlgPesPro TITLE "DIPROMED - Pesquisa de Produto" FROM 008.2,000 TO 050,130 OF GetWndDefault()

@ 035,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE

oGetChave := TGet():New(035,080,{|U| IIf(PCOUNT()==0,cChave,cChave:=U)},oDlgPesPro,230,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,nil/*cchave*/)

@ 035,315 CHECKBOX oChkChk   Var lChkChk PROMPT "Pesquisar Palavra Chave" PIXEL SIZE 080, 010 OF oDlgPesPro on change DipVldCh()

oBrowPro := TcBrowse():New(050,008,500,250,,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowPro:AddColumn(TCColumn():New(" ",{|| If(aBrowPro[oBrowPro:nAt,1],oOk,oNo) },,,,,015,.T.,.F.,,,,.F., ) )

oBrowPro:AddColumn(TcColumn():New("Descri็ใo",nil,nil,nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[2]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,2],nil) }
  
oBrowPro:AddColumn(TcColumn():New("Estoque",nil,"@E 99,999,999",nil,nil,"RIGHT",030,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[3]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,3],nil) }

oBrowPro:AddColumn(TcColumn():New("Promo็ใo",nil,"@E 9,999.9999",nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[4]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,4],nil) }

oBrowPro:AddColumn(TcColumn():New("C",nil,"@E 9,999.9999",nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[5]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,5],nil) }

oBrowPro:AddColumn(TcColumn():New("D",nil,"@E 9,999.9999",nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[6]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,6],nil) }

oBrowPro:AddColumn(TcColumn():New("Lista",nil,"@E 9,999.9999",nil,nil,"RIGHT",050,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[7]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,7],nil) }
         
oBrowPro:AddColumn(TcColumn():New("Codigo",nil,nil,nil,nil,"CENTER",030,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[8]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,8],nil) }
         
oBrowPro:AddColumn(TcColumn():New("Seq",nil,"@E 99",nil,nil,"RIGHT",015,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPro:ACOLUMNS[9]:BDATA := { || IIf(Len(aBrowPro)>0,aBrowPro[oBrowPro:nAt,9],nil) }         

oBrowPro:SetArray(aBrowPro)
oBrowPro:bLDblClick := { || aBrowPro[oBrowPro:nAt,1] := !aBrowPro[oBrowPro:nAt,1],aBrowPro[oBrowPro:nAt,9] := cSeq,cSeq:=soma1(cSeq)}
oGetChave:SetFocus(oGetChave)

If _nLinha > 0 .And. Len(aBrowPro) >= _nLinha
	oBrowPro:GoPosition(_nLinha)
Else
	oBrowPro:GoTop()
EndIf

ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,aButtons) }) CENTERED

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPREFAB  บAutor  ณMicrosiga           บ Data ณ  23/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DipRefab(cChave,lTela)
Local nPos 	   := 0                        
Local _lAchou  := .F.
DEFAULT cChave := ""
DEFAULT lTela  := .F.
 
If AllTrim(cGetOld) <> AllTrim(cChave) .Or. lChkChk
	If Len(aBrowPro)<> Len(aBrowAux)
		aBrowPro  := aClone(aBrowAux)
	EndIf	
	If Left(cTipoPes,1)=="1"
		If AllTrim(cChave)=="0"			
			If (nPos:=aScan(aBrowPro,{|x| x[10]==SB1->(Recno()) }))>0
				_nLinha := nPos
			EndIf			
		ElseIf lChkChk
			aBrowPro := {}
			aEval(aBrowAux, {|x| IIf(AllTrim(cChave)$x[2],aAdd(aBrowPro,x),nil) })				
		ElseIf (nPos:=aScan(aBrowPro,{|x|   Left(x[2],Len(AllTrim(cChave)))==AllTrim(cChave) }))>0
			_nLinha := nPos
		ElseIf (nPos:=aScan(aBrowPro,{|x|   Left(x[8],Len(AllTrim(cChave)))==AllTrim(cChave) }))>0
			_nLinha := nPos	
		Else
			_nLinha := 1
		EndIf		        
	Else
		If (nPos:=aScan(aBrowPro,{|x| x[8]==PadR(cChave,15)}))>0
			_nLinha := nPos
		EndIf
	EndIf
		       
	If lTela
		If Len(aBrowPro)<> Len(aBrowAux)
			oBrowPro:SetArray(aBrowPro)
		EndIf		
		If _nLinha>0 .And. Len(aBrowPro)>=_nLinha
			oBrowPro:GoPosition(_nLinha)
		Else
			oBrowPro:GoTop()
		EndIf	
		oBrowPro:Refresh()
	EndIf
	cGetOld := cChave
EndIf
	
Return                                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIP84OK  บAutor  ณMicrosiga           บ Data ณ  23/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Dip84Ok()
	
Local lRet       := .F.
Local nI         := 0
//Local aLinha     := {}
Local nTamAcols  := Len(aCols)
Local nTamAcolsM := nTamAcols 
Local cProAux    := ""
Local nlin		 := 0
Local cItem		 := ""
Local ix
nPosIt   	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_ITEM"})
nPosProd 	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_PRODUTO"})
nPosQtd  	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_QTDVEN"})
nPosDesc	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_DESCRI"})
nPosUM   	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_UM"})
nPosSgUM 	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_SEGUM"})
nPosTes  	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_TES"})
nPosCF   	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_CF"})
nPosLoc  	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_LOCAL"})
nPosCont 	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_CONTA"})
nPosTpDi 	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_TIPODIP"})
nPosPcVd 	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_PRCVEN"})
nPosPcTb 	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_PRV1"})
nPosClaFis	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_CLASFIS"})
nPosCodLan	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_CODLAN"})
nPosRevProd	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_REVPROD"})
nPosServic	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_SERVIC"})
nPosEndPad	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_ENDPAD"})
nPosTpEstr	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_TPESTR"})
nPosCCusto	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_CC"})
nPosItCta	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_ITEMCTA"})
nPosClVl	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_CLVL"})
nPosFornec	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_FORNEC"})
nPosPrvMini	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_PRVMINI"})
nPosPrvSupe	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_PRVSUPE"})
nPosBlq		:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_BLQ"})
nPosPrvProm	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_PRVPROM"})
nPosCusDip	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_CUSDIP"})
nPosUPrc	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_UPRC"})
nPosLisFor	:= aScan(aHeader,{|x| Alltrim(x[2])=="C6_LISFOR"})
 
Private aTemp  := {}

aLinha   := aClone(aCols[Len(ACols)])

For ix := 1 to Len(aBrowPro)
	If aBrowPro[ix,1]
		aAdd(aTemp,aBrowPro[ix])
	EndIf
Next ix

aBrowPro := aClone(aTemp)

aSort(aBrowPro,,,{|x,y| x[9]<y[9]})

For nI := 1 to Len(aBrowPro)
	
	nTamAcols := Len(aCols)
	
	If Empty(cItem)	
		For nlin := 1 to Len(aCols)
			cItem := aCols[nlin][nPosIt]
		Next nlin	
	EndIf	
	
	If !Empty(cItem)
		If nI > 1
			cItem := Soma1(cItem)
		EndIf
	EndIf
	
//		If nTamAcols > 1 .And. ALTERA .And. nI == 1
//			nTamAcols := nTamAcols+1
//		EndIf
	     
		//If aBrowPro[nI,1] == .T. //Pega apenas os itens marcados
				If nI > 1
					aCols[nTamAcols][nPosIt]   		:= cItem //StrZero(nTamAcols,2) 																				// Item
				EndIf
		   
		    //If nTamAcols <> nTamAcolsM
				aCols[nTamAcols][nPosProd] 		:= aBrowPro[nI,8]       																				// Produto
				aCols[nTamAcols][nPosDesc] 		:= Posicione("SB1",1,xFilial("SB1")+aBrowPro[nI,8],"B1_DESC") 											// Descri็ใo
				aCols[nTamAcols][nPosUM]   		:= Posicione("SB1",1,xFilial("SB1")+aBrowPro[nI,8],"B1_UM") 											// Unidade de Medida
				aCols[nTamAcols][nPosSgUM] 		:= Posicione("SB1",1,xFilial("SB1")+aBrowPro[nI,8],"B1_SEGUM") 
				aCols[nTamAcols][nPosTes]  		:= U_VldTesCF(Posicione("SB1",1,xFilial("SB1")+aBrowPro[nI,8],"B1_TS"),aBrowPro[nI,8]) 					// Tipo de saida	
				aCols[nTamAcols][nPosCF]   		:= Posicione("SF4",1,xFilial("SF4")+Posicione("SB1",1,xFilial("SB1")+aBrowPro[nI,8],"B1_TS"),"F4_CF") 	// Codigo Fiscal
				aCols[nTamAcols][nPosLoc]  		:= Iif(!Empty(M->C5_PEDECOM),"20","01")                                                                 // Almoxarifado
				aCols[nTamAcols][nPosTpDi] 		:= "2"																									// Tipo Dipromed - Pedido/Or็amento
				
				aCols[nTamAcols][nPosCont] 		:= Posicione('SB1',1,xFilial("SB1")+aBrowPro[nI,8], 'B1_CONTA')
				If SB1->B1_PRVSUPE > 0
					aCols[nTamAcols][nPosPcVd]	:= Posicione("SB1",1,xFilial("SB1")+aBrowPro[nI,8],"B1_PRVSUPE")
				Else
					aCols[nTamAcols][nPosPcVd]	:= Posicione("SB1",1,xFilial("SB1")+aBrowPro[nI,8],"B1_PRVMINI")
				EndIf
				//aCols[nTamAcols][nPosPcVd] 		:= Posicione("SB1",1,xFilial("SB1")+aBrowPro[nI,8],"B1_UPRC")	   
				aCols[nTamAcols][nPosPcTb] 		:= Posicione("SB1",1,xFilial("SB1")+aBrowPro[nI,8],"B1_PRV1")
				aCols[nTamAcols][nPosClaFis] 	:= Posicione("SB1",1,xFilial("SB1")+aBrowPro[nI,8],"B1_ORIGEM")+;
												   Posicione("SF4",1,xFilial("SF4")+AllTrim(aCols[nTamAcols][nPosTes]),"F4_SITTRIB")
				//aCols[nTamAcols][nPosCodLan] 	:= Posicione("SF4",1,xFilial("SF4")+aCols[nTamAcols][nPosTes],"F4_CODLAN")
				aCols[nTamAcols][nPosRevProd] 	:= Posicione("SB5",1,xFilial("SB5")+aBrowPro[nI,8],"B5_VERSAO")
				aCols[nTamAcols][nPosServic] 	:= Posicione("SB5",1,xFilial("SB5")+aBrowPro[nI,8],"B5_SERVSAI")
				aCols[nTamAcols][nPosEndPad] 	:= Posicione("SB5",1,xFilial("SB5")+aBrowPro[nI,8],"B5_ENDSAI")
				aCols[nTamAcols][nPosTpEstr] 	:= Posicione("SBE",9,xFilial("SBE")+aCols[nTamAcols][nPosEndPad],"BE_ESTFIS")
				aCols[nTamAcols][nPosCCusto]	:= Posicione('SB1',1,xfilial('SB1')+aBrowPro[nI,8],"B1_CC")                                                
				aCols[nTamAcols][nPosItCta] 	:= Posicione('SB1',1,xFilial('SB1')+aBrowPro[nI,8],"B1_ITEMCC")                                        
				aCols[nTamAcols][nPosClVl] 		:= Posicione('SB1',1,xFilial('SB1')+aBrowPro[nI,8],"B1_CLVL")                                          
				aCols[nTamAcols][nPosFornec] 	:= Posicione('SB1',1,xFilial('SB1')+aBrowPro[nI,8],"B1_PROC")   
				aCols[nTamAcols][nPosPrvMini] 	:= Posicione('SB1',1,xFilial('SB1')+aBrowPro[nI,8],"B1_PRVMINI")   
				aCols[nTamAcols][nPosPrvSupe] 	:= Posicione('SB1',1,xFilial('SB1')+aBrowPro[nI,8],"B1_PRVSUPE")   
				aCols[nTamAcols][nPosBlq] 		:= Iif(M->C5_TIPODIP $"2/3 ","S","N")                                                                  
				aCols[nTamAcols][nPosPrvProm] 	:= Posicione('SB1',1,xFilial('SB1')+aBrowPro[nI,8],"B1_PRVPROM")  
				aCols[nTamAcols][nPosCusDip] 	:= u_DipAtuCus(Posicione('SB1',1,xFilial('SB1')+aBrowPro[nI,8],"B1_CUSDIP"))                                                                         
				aCols[nTamAcols][nPosUPrc] 		:= Posicione('SB1',1,xFilial('SB1')+aBrowPro[nI,8],"B1_UPRC")  
				aCols[nTamAcols][nPosLisFor] 	:= u_DipAtuCus(Posicione('SB1',1,xFilial('SB1')+aBrowPro[nI,8],"B1_LISFOR"))                                                                         
		
				aCols[nTamAcols][Len(aHeader)+1] := .F.
	    
			//EndIf
	        
		    //If nTamAcols == nTamAcolsM
		    If nI == 1	
		    	M->C6_PRODUTO := aBrowPro[nI,8]
		    	//cProAux       := aBrowPro[nI,8]
		    EndIf
		    
		    If nI < Len(aBrowPro)		
		    	aadd(aCols,aClone(aLinha)) //adiciona uma linha no acols
			EndIf
			SysRefresh()			

		// EndIf
Next nI

	
//este trecho e para excluir a ultima linha do pedido
nTamAcols                   := Len(aCols)
//aCols[nTamAcols][nPosIt]    := StrZero(nTamAcols,2)	
//aCols[nTamAcols][nPosProd]  := cProAux
//aCols[nTamAcols][Len(aHeader)+1] := .T.
       
If nTamAcols > 1
	Aviso("Aviso","Produto(s) Incluso(s)!",{"Ok"},1)
	lRet := .T.
Else
	Aviso("Aviso","Nenhum produto selecionado",{"Ok"},1)
EndIf

oDlgPesPro:End()

Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPVISB1  บAutor  ณMicrosiga          บ Data ณ  23/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipViSB1()
Local aAreaSB1 := SB1->(GetArea())

If Len(aBrowPro)>0 .And. Type("oBrowPro:nAt")<>"U" 
	SB1->(dbGoTo(aBrowPro[oBrowPro:nAt,10]))
	AxVisual("SB1",aBrowPro[oBrowPro:nAt,10],2)
EndIf

RestArea(aAreaSB1)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDIPVLDCH บAutor  ณMicrosiga           บ Data ณ  23/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DipVldCh()
cGetOld  := ""
aBrowPro := aClone(aBrowAux)
oBrowPro:SetArray(aBrowPro)
oBrowPro:GoTop()
oGetChave:SetFocus(oGetChave)
Return
