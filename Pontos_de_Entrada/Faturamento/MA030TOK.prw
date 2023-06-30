#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
/*/
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ       	
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН»пїЅпїЅ
пїЅпїЅпїЅPrograma  пїЅ MA030TOK пїЅ Autor пїЅ CONSULTORIA        пїЅ Data пїЅ 23/01/2008  пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН№пїЅпїЅ
пїЅпїЅпїЅDescricao пїЅ Faz chamada para funпїЅпїЅo de gravacao do kardex na alteracao пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ de clientes                                                пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН№пїЅпїЅ
пїЅпїЅпїЅMaximo    пїЅ Alterado para enviar e-mails para vendedores e tпїЅcnicos    пїЅпїЅпїЅ
пїЅпїЅпїЅ30/09/08  пїЅ                                                            пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН№пїЅпїЅ
пїЅпїЅпїЅUso       пїЅ ESPECIFICO DIPROMED                                        пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅНјпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
/*/
User Function MA030TOK()
Local _areaSA3    := SA3->(getarea())
Local _areaSA1    := SA1->(getarea())
Local _aMsg       := {}
Local _cAssunto   := ""
Local _cFrom      := ""
Local _cEmail     := ""
Local _cEmailb    := ""
Local _cFuncSent  := "MA030TOK.PRW"
Local _cMailVO    := ''
Local _cNomeVO    := ''
Local _dDeslVO    := CtoD('')
Local _cTipoVO    := ''
Local _cMailVN    := ''
Local _cNomeVN    := ''
Local _dDeslVN    := CtoD('')
Local _cTipoVN    := ''
Local i           := 1
Local _nLogZg     := 0
Local _lRet       := .T.  //Giovani Zago 23/01/2012
Local _cCateg     := ""    //RBorges 25/10/2013
Local _Afe        := ""   //RBorges 16/06/2017

U_DIPPROC(ProcName(0),U_DipUsr()) // MCVN - 22/01/2009

//Giovani Zago 23/01/2012
If INCLUI .Or. ALTERA

	
	If M->A1_TIPO = "R" .And. Empty(M->A1_INSCR) .and. M->A1_PESSOA == "J"
		//If (M->A1_TPJ <> '3' .Or. M->A1_EST <> 'RJ') //Clientes MEI do RJ
		If (M->A1_TPJ = '3' .And. M->A1_EST = 'RJ') .Or. (M->A1_TPJ = '3' .And. M->A1_EST = 'ES') //Clientes MEI do RJ/ES 
		Else
			_lRet:= .F.
			MsgBox("Este Cliente й um Revendedor o Campo Inscriзгo Estadual deve ser Preenchido !!","Informacao!","INFO")
		EndIf
	EndIf

	If M->A1_TIPO = 'R' .And. M->A1_PESSOA == "J" .and.;  
	   (!Empty(M->A1_INSCR) .Or. ((Empty(M->A1_INSCR) .And. M->A1_TPJ == '3' .And. M->A1_EST $ 'RJ/ES'))) .And.; 
	   M->A1_INSCR <> 'ISENTO' .And.;
	   M->A1_GRPTRIB <> '001' .And.;
	   Empty(M->A1_DREGESP)
		Aviso("Atenзгo",'Cliente pertence ao grupo de clientes "001".'+CHR(10)+CHR(13)+;
						'Por favor, preencher o campo "Grp.Tribut" na terceira pasta/aba (Fiscais) com o conteъdo "001" ',{"Ok"},1)
		_lRet:= .F.
	ElseIf M->A1_TIPO = 'R' .And. M->A1_PESSOA == "J" .and.;
	   !Empty(M->A1_INSCR) .And.; 
	   M->A1_INSCR <> 'ISENTO' .And.;
	   M->A1_GRPTRIB <> '002' .And.;
	   M->A1_EST <> 'SP' .and.;
	   !Empty(M->A1_DREGESP)
		Aviso("Atenзгo",'Cliente PORTARIA SUTRI e pertence ao grupo de clientes "002".'+CHR(10)+CHR(13)+;
						'Por favor, preencher o campo "Grp.Tribut" na terceira pasta/aba (Fiscais) com o conteъdo "002" ',{"Ok"},1)
		_lRet:= .F.
	EndIf

EndIf
//******************************************


If cEmpAnt <> "04"
	If  INCLUI .And. Empty(M->A1_LFVISA) //Reginaldo Borges 16/06/2017
		U_MENCNAE()
	Endif
EndIf	        
	
/*	
	If U_AFEWHEN()
		

		If     (!Empty(M->A1_AFEVISC) .And. (AllTrim(M->A1_SITAFEC) == '1'))
			_Afe := "N"
		ElseIf (!Empty(M->A1_AFEVISS) .And. (AllTrim(M->A1_SITAFES) == '1'))
			_Afe := "N"
		ElseIf (!Empty(M->A1_AFEVISN) .And. (AllTrim(M->A1_SITAFEN) == '1'))
			_Afe := "N"
		EndIf			
		
		If Empty(_Afe)
			MsgInfo("Cliente necessita de AFE!","ATENпїЅпїЅO!")
		EndIf
		
	EndIf
*/	
	              
If !Inclui .And. _lRet // A Inclusao deve ser tratada no PE M030Inc, pois aqui ainda nпїЅo existe o registro na tabela, portanto no existe RECNO...
	U_GravaZG("SA1",@_nLogZg)
	
	// Atualiza data de alteraпїЅпїЅo do Cliente - MCVN - 26/01/10
	If _nLogZg > 0
		M->A1_DTALTER := DDATABASE
	Endif
	
	//  Envia e-mail para os gerentes   MCVN - 20/06/2008
	For i:=1 to 11
		
		_aMsg    := {}
		_cFrom   := ""
		_cEmail  := ""
	    _cEmailb := ""
		_cMailVO := ""
		_cNomeVO := ""
		_dDeslVO := CtoD('')
		_cTipoVO := ""
		_cMailVN := ""
		_cNomeVN := ""
		_dDeslVN := CtoD('')
		_cTipoVN := ""
		_lDipAvis:= .F.
		
		If i=1 // Vendedor
			cOldField := "SA1->A1_VEND"
			cNewField := "A1_VEND"
			_cAssunto := "VENDEDOR do Cliente " +SA1->A1_COD + " - " +Alltrim(SA1->A1_NOME)+" foi alterado! "
			_cCateg   := "Vendedor" //RBorges 25/10/2013
		ElseIf i=2 // TпїЅcnico KC
			cOldField := "SA1->A1_TECNICO"
			cNewField := "A1_TECNICO"
			_cAssunto := EncodeUTF8("TпїЅCNICO do Cliente " +SA1->A1_COD + " - " +Alltrim(SA1->A1_NOME)+" foi alterado! ","cp1252")
			_cCateg   := "TпїЅcnico" //RBorges 25/10/2013			
		ElseIf i=3 // Tecnico AMCOR
			cOldField := "SA1->A1_TECN_A"
			cNewField := "A1_TECN_A"
			_cAssunto := EncodeUTF8("TпїЅCNICO AMCOR do Cliente " +SA1->A1_COD + " - " +Alltrim(SA1->A1_NOME)+" foi alterado! ","cp1252") 
			_cCateg   := "TпїЅcnico AMCOR" //RBorges 25/10/2013		
		ElseIf i=4 // TпїЅcnico 3M
			cOldField := "SA1->A1_TECN_3"
			cNewField := "A1_TECN_3"
			_cAssunto := EncodeUTF8("TпїЅCNICO 3M do Cliente " +SA1->A1_COD + " - " +Alltrim(SA1->A1_NOME)+" foi alterado! ","cp1252")
			_cCateg   := "TпїЅcnico 3M" //RBorges 25/10/2013			
		ElseIf i=5 // TпїЅcnico Roche
			cOldField := "SA1->A1_TECN_R"
			cNewField := "A1_TECN_R"
			_cAssunto := EncodeUTF8("TпїЅCNICO ROCHE do Cliente " +SA1->A1_COD + " - " +Alltrim(SA1->A1_NOME)+" foi alterado! ","cp1252")
			_cCateg   := "TпїЅcnico ROCHE" //RBorges 25/10/2013			
		ElseIf i=6 // Vendedor HQ
			cOldField := "SA1->A1_VENDHQ"
			cNewField := "A1_VENDHQ"
			_cAssunto := "VENDEDOR HQ do Cliente " +SA1->A1_COD + " - " +Alltrim(SA1->A1_NOME)+" foi alterado! "
			_cCateg   := "Vendedor HQ"	 //RBorges 25/10/2013		
			_lDipAvis := DipValCli(SA1->A1_CGC,M->&cNewField)
	    ElseIf i=7 // TпїЅcnico Convatec
			cOldField := "SA1->A1_TECN_C"
			cNewField := "A1_TECN_C"
			_cAssunto := "TпїЅCNICO CONVATEC do Cliente " +SA1->A1_COD + " - " +Alltrim(SA1->A1_NOME)+" foi alterado! "
			_cCateg   := "TпїЅcnico CONV." //RBorges 25/10/2013			
        ElseIf i=8 // TпїЅcnico SP
			cOldField := "SA1->A1_XTEC_SP"
			cNewField := "A1_XTEC_SP"
			_cAssunto := "TпїЅCNICO SP do Cliente " +SA1->A1_COD + " - " +Alltrim(SA1->A1_NOME)+" foi alterado! "			
			_cCateg   := "TпїЅcnico SP" //RBorges 25/10/2013			
        ElseIf i= 9 // TпїЅcnico MA
			cOldField := "SA1->A1_XTEC_MA"
			cNewField := "A1_XTEC_MA"
			_cAssunto := EncodeUTF8("TпїЅCNICO MA do Cliente " +SA1->A1_COD + " - " +Alltrim(SA1->A1_NOME)+" foi alterado! ","cp1252")				
			_cCateg   := "TпїЅcnico MA" //RBorges 25/10/2013			
		ElseIf i= 10 // TпїЅcnico BRAUN
			cOldField := "SA1->A1_TECN_B"
			cNewField := "A1_TECN_B"
			_cAssunto := "TпїЅCNICO Braun do Cliente " +SA1->A1_COD + " - " +Alltrim(SA1->A1_NOME)+" foi alterado! "				
			_cCateg   := "TпїЅcnico BRAUN" //RBorges 25/10/2013			
		ElseIf i= 11 // Vendedor SP
			cOldField := "SA1->A1_XVENDSP"
			cNewField := "A1_XVENDSP"
			_cAssunto := "VENDEDOR SP do cliente " +SA1->A1_COD + " - " +Alltrim(SA1->A1_NOME)+" foi alterado! " 
			_cCateg   := "Vendedor SP"	 //RBorges 25/10/2013			
		Endif
		
		
		
		
		If M->&cNewField <> &cOldField
			DbSelectArea("SA3")
			SA3->(DbSetOrder(1))
			If SA3->(dbSeek(xFilial("SA3")+&cOldField))
				_cMailVO := SA3->A3_EMAIL
				_cNomeVO := SA3->A3_NOME
				_dDeslVO := SA3->A3_DESLIG
				_cTipoVO := SA3->A3_TIPO
			EndIf
			If SA3->(dbSeek(xFilial("SA3")+M->&cNewField))
				_cMailVN := SA3->A3_EMAIL
				_cNomeVN := SA3->A3_NOME
				_dDeslVN := SA3->A3_DESLIG
				_cTipoVN := SA3->A3_TIPO
			EndIf
			
			//			Aadd( _aMsg , { "Cliente"         , SA1->A1_COD +" - "+Alltrim(SA1->A1_NOME) } )
			//			Aadd( _aMsg , { If(i=1,If(i=6,"Vendedor HQ","Vendedor"),"TпїЅcnico")+ " Anterior" , &cOldField  +" - "+ If(!Empty(&cOldField),_cNomeVO,"")} )
			//			Aadd( _aMsg , { If(i=1,If(i=6,"Vendedor HQ","Vendedor"),"TпїЅcnico")+ " Atual" , M->&cNewField  +" - "+ If(!Empty(M->&cNewField),_cNomeVN,"")} )
			//			Aadd( _aMsg , { "Alterado por"    , Upper(U_DipUsr()) } )
			

			// RBorges - 25/10/2013 - Alterei para ser usado com a variпїЅvel.
			Aadd( _aMsg , { "Cliente"          , SA1->A1_COD +" - "+Alltrim(SA1->A1_NOME) } )
			Aadd( _aMsg , { _cCateg +" Anterior" , &cOldField    +" - "+ If(!Empty(&cOldField),_cNomeVO,"")} )
			Aadd( _aMsg , { _cCateg +" Atual   " , M->&cNewField +" - "+ If(!Empty(M->&cNewField),_cNomeVN,"")} )
			Aadd( _aMsg , { "--------------------------------" , "          Outras InformaпїЅпїЅes                           "    } )			

			/* RBorges - 25/10/2013 - Comentei para ser usado com a variпїЅvel na forma acima.
			Aadd( _aMsg , { "Cliente"          , SA1->A1_COD +" - "+Alltrim(SA1->A1_NOME) } )
			Aadd( _aMsg , { If(i=1 .Or. i=6 .Or. i=11  ,"_cCateg "+If(i=6, "HQ",If(i=11, "SP","")),"TпїЅcnico")+ " Anterior" , &cOldField  +" - "+ If(!Empty(&cOldField),_cNomeVO,"")} )
			Aadd( _aMsg , { If(i=1 .Or. i=6 .Or. i=11  ,"Vendedor "+If(i=6, "HQ",If(i=11, "SP","")),"TпїЅcnico")+ " Atual" , M->&cNewField  +" - "+ If(!Empty(M->&cNewField),_cNomeVN,"")} )
			Aadd( _aMsg , { "--------------------------------" , "          Outras InformaпїЅпїЅes                           "    } )			
              */
              
			//RSB 04/09/2013 - Adicionar as tпїЅcnicas e vendedores(as) do cliente na mensagem dos e-mails.
			If  ! i == 3
				Aadd( _aMsg , { "TпїЅcnica Amcor"    , SA1->A1_TECN_A +" - "+Alltrim( FDESC("SA3",SA1->A1_TECN_A ,"SA3->A3_NOME"))  } )
   				If(!Empty(SA1->A1_TECN_A))
			    _cEmailb+=ALLTRIM(POSICIONE('SA3',1,xFilial('SA3')+SA1->A1_TECN_A,"A3_EMAIL"))+";"
		        EndIf
   			EndIf
			If  ! i == 4
				Aadd( _aMsg , { "TпїЅcnica 3M"       , SA1->A1_TECN_3 +" - "+Alltrim( FDESC("SA3",SA1->A1_TECN_3 ,"SA3->A3_NOME"))  } )
				If(!Empty(SA1->A1_TECN_3))
			    _cEmailb+=ALLTRIM(POSICIONE('SA3',1,xFilial('SA3')+SA1->A1_TECN_3,"A3_EMAIL"))+";"
		        EndIf			
			EndIf
			If  ! i == 5
				Aadd( _aMsg , { "TпїЅcnica Roche"    , SA1->A1_TECN_R +" - "+Alltrim( FDESC("SA3",SA1->A1_TECN_R ,"SA3->A3_NOME"))  } )
				If(!Empty(SA1->A1_TECN_R))
			    _cEmailb+=ALLTRIM(POSICIONE('SA3',1,xFilial('SA3')+SA1->A1_TECN_R,"A3_EMAIL"))+";"
		        EndIf			
			EndIf
			If  ! i == 7
				Aadd( _aMsg , { "TпїЅcnica Convatec" , SA1->A1_TECN_C +" - "+Alltrim( FDESC("SA3",SA1->A1_TECN_C ,"SA3->A3_NOME"))  } )
			    If(!Empty(SA1->A1_TECN_C))
			    _cEmailb+=ALLTRIM(POSICIONE('SA3',1,xFilial('SA3')+SA1->A1_TECN_C,"A3_EMAIL"))+";"
		        EndIf
			EndIf
			If  ! i == 8
				Aadd( _aMsg , { "TпїЅcnica SP"       , SA1->A1_XTEC_SP+" - "+Alltrim( FDESC("SA3",SA1->A1_XTEC_SP,"SA3->A3_NOME"))  } )
				If(!Empty(SA1->A1_XTEC_SP))
			    _cEmailb+=ALLTRIM(POSICIONE('SA3',1,xFilial('SA3')+SA1->A1_XTEC_SP ,"A3_EMAIL"))+";"
		        EndIf
			
			EndIf
			If  ! i == 9
				Aadd( _aMsg , { "TпїЅcnica MA"	   , SA1->A1_XTEC_MA+" - "+Alltrim( FDESC("SA3",SA1->A1_XTEC_MA,"SA3->A3_NOME"))  } )
			    If(!Empty(SA1->A1_XTEC_MA))
			    _cEmailb+=ALLTRIM(POSICIONE('SA3',1,xFilial('SA3')+SA1->A1_XTEC_MA,"A3_EMAIL"))+";"
		        EndIf
			EndIf
			If  ! i == 10
				Aadd( _aMsg , { "TпїЅcnica Braun"	   , SA1->A1_TECN_B +" - "+Alltrim( FDESC("SA3",SA1->A1_TECN_B ,"SA3->A3_NOME"))  } )
     			If(!Empty(SA1->A1_TECN_B))
			    _cEmailb+=ALLTRIM(POSICIONE('SA3',1,xFilial('SA3')+SA1->A1_TECN_B,"A3_EMAIL"))
		        EndIf
			EndIf
			If  ! i == 1
				Aadd( _aMsg , { "Vendedor "	   , SA1->A1_VEND +" - "+Alltrim( FDESC("SA3",SA1->A1_VEND ,"SA3->A3_NOME"))  } )
     			If(!Empty(SA1->A1_VEND))
			    _cEmailb+=ALLTRIM(POSICIONE('SA3',1,xFilial('SA3')+SA1->A1_VEND,"A3_EMAIL"))
		        EndIf
			EndIf  
			If  ! i == 11
				Aadd( _aMsg , { "Vendedor SP"	   , SA1->A1_XVENDSP +" - "+Alltrim( FDESC("SA3",SA1->A1_XVENDSP ,"SA3->A3_NOME"))  } )
     			If(!Empty(SA1->A1_XVENDSP))
			    _cEmailb+=ALLTRIM(POSICIONE('SA3',1,xFilial('SA3')+SA1->A1_XVENDSP,"A3_EMAIL"))
		        EndIf
			EndIf
			// RSB 04/09/2013 - Se o vendedor for o mesmo vendedor HQ, atualizar no envio da mensagem, caso contrпїЅrio manter o atual.
			If &cOldField == SA1->A1_VENDHQ
				Aadd( _aMsg , { "Vendedor HQ"	   ,  M->&cNewField+" - "+ If(!Empty(M->&cNewField),_cNomeVN,"")  } )
			Else
				Aadd( _aMsg , { "Vendedor HQ"	   , SA1->A1_VENDHQ +" - "+Alltrim( FDESC("SA3",SA1->A1_VENDHQ ,"SA3->A3_NOME"))  } )
			EndIf
			Aadd( _aMsg , { "Alterado por"     , Upper(U_DipUsr())} ) 
			 
						
			If i=1 .OR. i=6 .OR. i=11
				
				_cEmail  := Iif(!Empty(_cMailVN).and.Empty(_dDeslVN),_cMailVN+";","")
				_cEmail  += Iif(!Empty(_cMailVO).and.Empty(_dDeslVO),_cMailVO+";","")
				_cEmail  +="erich.pontoldio@dipromed.com.br;"+SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br")
				
				If i=1
					_cEmail  += Iif((_cTipoVO='I' .OR. _cTipoVN='I') .AND. (i=1 .OR. i=11),";patricia.mendonca@dipromed.com.br","")
		        	_cEmail  += Iif( _cTipoVO='E' .OR. _cTipoVN='E', ";apoio@dipromed.com.br","")
				Endif
		          
		     	If SA1->A1_COD <= "019018"
			     	//_cEmail  += Iif( i==6,";lucas.santos@dipromed.com.br;diretor@healthquality.ind.br;vendas@healthquality.ind.br;elcio@healthquality.ind.br","")															      
				EndIf
				
			ElseIf i=4    // Se o TпїЅcnico for 3M, envia e-mail para Alex Santos
				_cEmail  := Iif(!Empty(_cMailVN).and.Empty(_dDeslVN),ALLTRIM(_cMailVN)+";","")+;
				Iif(!Empty(_cMailVO).and.Empty(_dDeslVO),_cMailVO+";","")
			Else
				_cEmail  := Iif(!Empty(_cMailVN).and.Empty(_dDeslVN),_cMailVN+";","")+;
				Iif(!Empty(_cMailVO).and.Empty(_dDeslVO),_cMailVO+";","")+";alvaro.menezes@dipromed.com.br"
			Endif 
 			 			           
			_cEmail +=";"+ _cEmailb			
			//_cEmail :="reginaldo.borges@dipromed.com.br"
			
			U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent) 
			
			If _lDipAvis        
				_aMsg := {}				 
				If cEmpAnt == "01"
					_cAssunto := "Alterar o vendedor HQ na Empresa (HEALTH QUALITY)"
			    	Aadd( _aMsg , { "Alterado na Empresa", "DIPROMED" 		} )
					Aadd( _aMsg , { "ALTERAR na Empresa" , "HEALTH QUALITY" } )
					
					If SA1->A1_COD <= "019018"
						_cEmail := "vendas@healthquality.ind.br;lucas@healthquality.ind.br;"
						_cEmail += "diretor@healthquality.ind.br;"+SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br")
					EndIF
					 
				// _cEmail := "reginaldo.borges@dipromed.com.br" 
				Else                                                           
					_cAssunto := "Alterar o vendedor HQ na Empresa (DIPROMED)"
			    	Aadd( _aMsg , { "Alterado na Empresa", "HEALTH QUALITY"	} )
					Aadd( _aMsg , { "ALTERAR na Empresa" , "DIPROMED" 		} )
					
					_cEmail := "patricia.mendonca@dipromed.com.br;elizabete.rodrigues@dipromed.com.br;"
					_cEmail += SUPERGETMV("MV_#EMLTI",.F.,"ti@dipromed.com.br")
					
				   //_cEmail := "reginaldo.borges@dipromed.com.br" 
				EndIf
				
				If SA1->A1_PESSOA == 'F'
					Aadd( _aMsg , { "CPF"	   			 ,Transform(SA1->A1_CGC,"@R 99999999999") } )
				Else
					Aadd( _aMsg , { "CNPJ"	   			 ,Transform(SA1->A1_CGC,"@R 99999999999999") } )
				EndIF
				Aadd( _aMsg , { "Nome"	   			 ,AllTrim(SA1->A1_NOME) 						 } )
				
				If &cOldField == SA1->A1_VENDHQ                                                                
					Aadd( _aMsg , { "Vendedor HQ antigo"   ,  M->&cOldField+" - "+ If(!Empty(M->&cOldField),_cNomeVO,"")  } )
					Aadd( _aMsg , { "Vendedor HQ novo"	   ,  M->&cNewField+" - "+ If(!Empty(M->&cNewField),_cNomeVN,"")  } )
				Else
					Aadd( _aMsg , { "Vendedor HQ"	   , SA1->A1_VENDHQ +" - "+Alltrim( FDESC("SA3",SA1->A1_VENDHQ ,"SA3->A3_NOME"))  } )
				EndIf
	
				Aadd( _aMsg , { "Alterado por"     , Upper(U_DipUsr())} ) 

				U_UEnvMail(_cEmail,_cAssunto,_aMsg,"",_cFrom,_cFuncSent) 
			EndIf
		   
		EndIf
	Next i
EndIf 

RestArea(_areaSA3)
RestArea(_areaSA1)
Return (_lRet)
/*
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН»пїЅпїЅ
пїЅпїЅпїЅPrograma  пїЅMA030TOK  пїЅAutor  пїЅMicrosiga           пїЅ Data пїЅ  06/27/14   пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН№пїЅпїЅ
пїЅпїЅпїЅDesc.     пїЅ                                                            пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ                                                            пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅН№пїЅпїЅ
пїЅпїЅпїЅUso       пїЅ AP                                                        пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅНјпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
*/
Static Function DipValCli(cCGC,cVendNew)
Local lRet := .F.           
Local cSQL := ""  

cSQL := " SELECT "
cSQL += " 	* "
cSQL += " 	FROM "
cSQL += " 		SA1"+IIf(cEmpAnt=="01","040","010") 
cSQL += " 		WHERE "
cSQL += " 			A1_CGC = '"+cCGC+"' AND "
cSQL += " 			A1_VENDHQ <> '"+cVendNew+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QRYSA1",.T.,.F.)      

lRet := !QRYSA1->(Eof())
QRYSA1->(dbCloseArea())

Return lRet
