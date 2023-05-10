/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA043() ºAutor  ³Jailton B Santos-JBSº Data ³ 26/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa desenvolvido para montar uma consulta de segmento º±±
±±º          ³ de clientes                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Faturamento - Dipromed                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"       

User Function DIPA043()

Local oDlg      
Local nOpca  := 0
Local lRet   := .T.

Local cFilSX5 := xFilial('SX5')
Local cTabSX5 := "ZF"
Local cPrefSX5:= "     "

Local bOk    := {|| nOpca := 1,oDlg:End()}
Local bCancel:= {|| nOpca := 2,oDlg:End()}

Private	oSeq01
Private	oSeq02
Private	oSeq03
Private	oSgmto

Private	cSeq01
Private	cSeq02
Private	cSeq03
Private	cSgmto

Private aSeq01 := {"","1=Particular", "2=Publico"}
Private aSeq02 := {"","01=Hospital", "02=Distribuidor","03=Clinicas","04=Industria","05=Laboratorio","06=Pessoa Fisica","07=Outros"}
Private aSeq03 := {""} 

Do While ReadVar() == "M->A1_SEGDIP"  

	If !Empty(M->A1_SEGDIP) 
	
		cSeq01 := SubStr(StrTran(M->A1_SEGDIP,".",""),1,1)
		cSeq02 := SubStr(StrTran(M->A1_SEGDIP,".",""),2,2)
		cSeq03 := SubStr(StrTran(M->A1_SEGDIP,".",""),4,3)

	    SX5->( DbSetOrder(1) )
        SX5->( DbSetOrder(1) )

        cPrefSX5:= StrZero(Val(cSeq01),1)+StrZero(Val(cSeq02),2)
	
	    If SX5->( DbSeek( cFilSX5 + cTabSX5 + cPrefSX5 ))
 
 		    Do While  SX5->(!EOF()) .and. SX5->X5_FILIAL == cFilSX5 .and.;
 		              SX5->X5_TABELA == cTabSX5 .and.;
 		              SubStr(SX5->X5_CHAVE,1,3) == cPrefSX5 
 			          
		              aadd(aSeq03,SubStr(SX5->X5_CHAVE,4,3) + '=' + SX5->X5_DESCRI)
			          SX5->(DbSkip())

		    EndDo  
		    
        EndIf

        cSgmto:=Padr(cSeq01 + '.' + cSeq02 + '.' + cSeq03 +;
                       '  Categoria  ' + iif(!Empty(cSeq01),aSeq01[val(cSeq01)],' ') + ;
                       '  Tipo  '      + iif(!Empty(cSeq02),aSeq02[val(cSeq02)],' ') + ;
                       '  Descricao  ' + iif(!Empty(cSeq03),aSeq03[val(cSeq03)],' '),250)

	Else
		cSeq01 := " "
		cSeq02 := "  "
		cSeq03 := "   "
        cSgmto := Space(250) 
	EndIf

                    
	Define MsDialog oDlg Title "ASSISTENTE DE CONSULTA DE SEGMENTO" from 000,000 to 280,652 of oMainWnd pixel

	@ 016,02 to 137,325 Of oDlg Pixel

	@ 025,015 say "Categoria" size 50,08 of oDlg pixel
	@ 038,015 say "Tipo"      size 50,08 of oDlg pixel
	@ 051,015 say "Descrição" size 50,08 of oDlg pixel
	
	@ 025,065 ComboBox oSeq01 var cSeq01 items  aSeq01 of oDlg pixel size 080,08 On Change fValid('01') 
    @ 037,065 ComboBox oSeq02 var cSeq02 items  aSeq02 of oDlg pixel size 080,08 On Change fValid('02') 
    @ 050,065 ComboBox oSeq03 var cSeq03 items  aSeq03 of oDlg pixel size 150,08 On Change fValid('03') 
	
    @ 080,015 say "Segmento" size 50,08 of oDlg pixel
	
	@ 079,065 msget oSgmto var cSgmto When .F. size 250,10 of oDlg pixel
	                                                                           
	Activate MsDialog oDlg Centered  on init EnchoiceBar(oDlg, bOk, bCancel)
    
    If nOpca == 1 .and. !Empty(cSeq01) .and. !Empty(cSeq02).and. !Empty(cSeq03) 
        M->A1_SEGDIP := cSeq01 + cSeq02 + cSeq03
        lRet := .F. 
    ElseIf M->A1_SEGDIP == cSeq01 + cSeq02 + cSeq03
        lRet := .F. 
    EndIf

    Exit

EndDo 

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fValid() ºAutor  ³Jailton B Santos-JBSº Data ³ 26/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz a validacao dos campos informados pelo usuario         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico Faturamento - Dipromed                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fValid(cCampo)

Local cFilSX5 := xFilial('SX5')
Local cTabSX5 := "ZF"
Local cPrefSX5:= StrZero(Val(cSeq01),1)+StrZero(Val(cSeq02),2)

Do Case
Case cCampo == '01' .or. cCampo == '02'

	If cCampo == '01'
		If StrZero(Val(cSeq01),1) == '2'
			aSeq02 := {"","01=Hospital"}
		Else
			aSeq02 := {"","01=Hospital", "02=Distribuidor","03=Clinicas","04=Industria","05=Laboratorio","06=Pessoa Fisica","07=Outros"}
		EndIf
		
		cSeq02 := "  "
        oSeq02:aItems:=Aclone(aSeq02)
	    oSeq02:Refresh()
  
		cSeq03 := "   "
        oSeq03:aItems:= {}
	    oSeq03:Refresh() 
	    
	    cSgmto:= Space(250)
	    oSgmto:Refresh()
	    

	EndIf

    aSeq03 := {""} 
    If !Empty(cSeq01) .and. !Empty(cSeq02)
                                                                                   
	    SX5->( DbSetOrder(1) )
        SX5->( DbSetOrder(1) )
	
	    If SX5->( DbSeek( cFilSX5 + cTabSX5 + cPrefSX5 ))
 
 		    Do While  SX5->(!EOF()) .and. SX5->X5_FILIAL == cFilSX5 .and.;
 		              SX5->X5_TABELA == cTabSX5 .and.;
 		              SubStr(SX5->X5_CHAVE,1,3) == cPrefSX5 
 			          
		              aadd(aSeq03,SubStr(SX5->X5_CHAVE,4,3) + '=' + SX5->X5_DESCRI)
			          SX5->(DbSkip())

		    EndDo 
		    
		    If val(cSeq03)+1 > len(aSeq03) // Quando o usuario muda para menos opcoes, a array eh menor que a anterior e o ponteiro esta maior que o len desta ultima 
		       cSeq03 := ''  
		    EndIf   
            
            cSgmto:=Padr(cSeq01 + '.' + cSeq02 + '.' + cSeq03 +;
                         '  Categoria  ' + iif(!Empty(cSeq01),aSeq01[val(cSeq01)+1],' ') + ;
                         '  Tipo  '      + iif(!Empty(cSeq02),aSeq02[val(cSeq02)+1],' ') + ;
                         '  Descricao  ' + iif(!Empty(cSeq03),aSeq03[val(cSeq03)+1],' '),250)
            oSgmto:Refresh()

	    EndIf
    EndIf

    oSeq03:aItems := Aclone(aSeq03)
	oSeq03:Refresh()
	
Case cCampo == '03' 

    If !Empty(cSeq01) .and. !Empty(cSeq02).and. !Empty(cSeq03) 

	    If val(cSeq03)+1 > len(aSeq03) // Quando o usuario muda para menos opcoes, a array eh menor que a anterior e o ponteiro esta maior que o len desta ultima 
	       cSeq03 := ''
	    EndIf   

        cSgmto:=Padr(cSeq01 + '.' + cSeq02 + '.' + cSeq03 +;
                       '  Categoria  ' + iif(!Empty(cSeq01),aSeq01[val(cSeq01)+1],' ') + ;
                       '  Tipo  '      + iif(!Empty(cSeq02),aSeq02[val(cSeq02)+1],' ') + ;
                       '  Descricao  ' + iif(!Empty(cSeq03),aSeq03[val(cSeq03)+1],' '),250)
          oSgmto:Refresh()
    EndIf      
    
EndCase

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DIPA43ALT     ºAutor  ³Maximo Canuto      º Data ³  04/06/10º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Permite a inclusão ou alteração de itens na tabela SX5     º±±
±±º          ³ na chave T3 - SEGMENTOSº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPA43ALT()
Local cUser := "APIRES/MCANUTO/EELIAS/DDOMINGOS/VQUEIROZ/VEGON/RBORGES"                                      
Local aAreaSX5    := SX5->(GetArea())

If !(Upper(U_DipUsr()) $ cUser)
	Return()
EndIf                              

SX5->(dbSetFilter({|| SX5->X5_TABELA == "ZF" .AND. SX5->X5_DESCENG = 'PA' .AND. SX5->X5_FILIAL = xFilial("SX5") },"SX5->X5_TABELA == 'ZF' .AND. SX5->X5_DESCENG = 'PA' .AND. SX5->X5_FILIAL = xFilial('SX5')"))

AxCadastro("SX5","SEGMENTOS",".F.",".T.")

SX5->(DbClearFilter())

RestArea(aAreaSX5)
Return()  