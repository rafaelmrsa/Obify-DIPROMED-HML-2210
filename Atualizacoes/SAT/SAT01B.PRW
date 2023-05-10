#INCLUDE "RWMAKE.CH"
#INCLUDE "VKEY.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "FONT.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SAT01B   ³ Autor ³   VIVIANE AP.CAMPOS   ³ Data ³ 16/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ TELA DE SAT (SOLICITACAO DE ATENDIMENTO TECNICO)           ³±±
±±³          ³ Funcao que chama a tela / incluir /alterar			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Depto:    | TI											              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AxSAT3(cMaster,cDetail,cCpoMas,cCpoDet,cCpoKey, cTitulo,cOpcoes,aCores,cFiltro,_FunLeg,FunLOk,FunTOk,_FunPrn)
LOCAL 	i	// contador para loops
LOCAL 	aOpc	  := {"P","V","I","A","E","N","U","L"}  // opções para habilitar as chamadas
LOCAL 	aChamadas := {{ "Pesquisar" ,"AxPesqui"     , 0 , 1},;
                      { "Visualizar","U_SAT3Exec(2)", 0 , 2},;
                      { "Incluir"   ,"U_SAT3Exec(1)", 0 , 3},;
                      { "Alterar"   ,"U_SAT3Exec(3)", 0 , 4, 20 },;
                      { "Excluir"   ,"U_SAT3Exec(4)", 0 , 5, 21 },;
                      { "Legenda"   ,_FunLeg        , 0 , 2}}
//			  { "Imprimir"  ,_FunPrn        , 0 , 2     },;
// inicializa variáveis do mBrowse 
Local cFiltra := ''

PRIVATE cCADASTRO 	:= cTitulo
PRIVATE	aRotina 	:= {}


// utiliza variáveis privadas para acesso em outras funções
PRIVATE _cMaster,_cDetail,_cCpoMas,_cCpoDet, _cCpoKey, _cTitulo, _FunLOk, _FunTOk

_cMaster := cMaster
_cDetail := cDetail
_cCpoMas := cCpoMas
_cCpoDet := cCpoDet
_cCpoKey := cCpoKey
_cTitulo := cTitulo
_FunLOk  := FunLOk
_FunTOk  := FunTOk
// monta array de rotinas com as opções passadas como parâmetro
// obs: o array aRotina é utilizado pela função mBrowse
for i := 1 to len(aChamadas)
	if aOpc[i] $ cOpcoes
		AADD(aRotina, aChamadas[i])
	endif
next i

// executa a mBrowse
dbSelectArea(cMaster)
dbSetOrder(1)

//Filtra SATs no Browse de acordo com os parametros

If Upper(U_DipUsr()) $ alltrim(getmv("MV_SATTI"))  // JBS 28/01/2010
	cFiltra  := "ZM_FILIAL = '" + xFilial("SZM") + "' "                 // JBS 28/01/2010
else                                                                     // JBS 28/01/2010
	cFiltra  := "ZM_FILIAL = '" + xFilial("SZM") + "' And ZM_USER = '" + RetCodUsr() + "' "  // JBS 28/01/2010
endif  // JBS 28/01/2010

mBrowse(06,01,22,75,cMaster,,,,,,aCORES,,,,,,,,cFiltra)  // JBS 28/01/2010
// mBrowse(06,01,22,75,cMaster,,,,cFiltro,,aCORES)

Return(NIL)


// Processa Modelo 3 de acordo com a chamada (Incluir, Visualizar, Alterar ou Excluir)
User Function SAT3exec(_nOpc)
Local i      
Local cAccount   := Lower(Alltrim(GetMv("MV_RELACNT")))   // JBS 15/01/2010
Local cFrom      := Lower(Alltrim(GetMv("MV_RELACNT")))             // JBS 15/01/2010
Local cPassword  := Alltrim(GetMv("MV_RELPSW"))           // JBS 15/01/2010
Local cServer    := Alltrim(GetMv("MV_RELSERV"))          // JBS 15/01/2010

PRIVATE nOpcE	 :=	3
PRIVATE nOpcG	 :=	3
PRIVATE nUsado	 :=	0      
PRIVATE nOpcWhen := _nOpc  // JBS 28/01/2010
PRIVATE aHeader  := {}
PRIVATE aCols	 := {}
PRIVATE cSatti   := alltrim(GETMV("MV_SATTI")) // Usuarios de TI
PRIVATE cEmInfra := alltrim(GETMV("MV_SATINFR")) // E-MAILS INFRA
PRIVATE cEmSiga	 := alltrim(GETMV("MV_SATSIGA")) // E-MAILS INFRA

/*
PRIVATE cSatman :=  alltrim(GETMV("MV_SATMAN")) //manutenção
PRIVATE cSatmar :=  alltrim(GETMV("MV_SATMAR")) //marcenaria
PRIVATE cSatgpe :=  alltrim(GETMV("MV_SATGPE")) //gestao de pessoas
PRIVATE cSat01 :=  alltrim(GETMV("MV_SAT01")) //AUTOMACAO
PRIVATE cSat02 :=  alltrim(GETMV("MV_SAT02")) //EQUIPAMENTOS
PRIVATE cSat03 :=  alltrim(GETMV("MV_SAT03"))  //SERVICOS
PRIVATE cSat04 :=  alltrim(GETMV("MV_SAT04"))  //PECAS
PRIVATE cSat05 :=  alltrim(GETMV("MV_SAT05"))  //INST E OBRAS
PRIVATE cSat06 :=  alltrim(GETMV("MV_SAT06"))  //GARANTIA
PRIVATE cSat07 :=  alltrim(GETMV("MV_SAT07"))  //TREINAMENTO
*/

PRIVATE cSat := cSatti //+ "/" + cSatman + "/" + cSatmar + "/" + cSatgpe + "/" + cSat01 + "/" + cSat02 + "/" + cSat03 + "/" + cSat04 + "/" + cSat05 + "/" + cSat06 + "/" + cSat07


_nRet := 0

// configura variáveis do modelo 3 de acordo com a chamada em nOpc
//nOpc=Botoes mbrowse / nOpcE=Cabeçalho / nOpcG=Itens / 2-So Visualiza 3- Pode Alterar
Do Case
	Case _nOpc==1
		//checa se existe Sat em Avaliação
		dbSelectArea(_cMaster)
		DBSETORDER(2)
		dbSeek(xFilial("SZM")+U_DipUsr())
		do While ( !Eof() .And. SZM->ZM_USER==U_DipUsr())
			If SZM->ZM_STATUS = 'AV'
				aviso("Inclusão não Autorizada","Não e permitido incluir SAT se você possui Avaliações pendentes. Entre no Menu - Atualizações / Específicos / *Avalie a SAT",{"Sair"})
				RETURN(.F.)
			EndIf
			dbskip()
		enddo
		//fim de checa se existe Sat em Avaliação
		nOpcE:=3 ; nOpcG:=2
	Case _nOpc==2 ; nOpcE:=2 ; nOpcG:=2
	Case _nOpc==3
		if sZM->ZM_status <> "AB"
			If (SZM->ZM_PARA == 'I' .OR. SZM->ZM_PARA == 'S') .AND. !Upper(U_DipUsr()) $ cSatti//alltrim(getmv("MV_SATTI"))
				//		!Upper(U_DipUsr()) $ alltrim(getmv("MV_SATTI")) .and. sZM->ZM_status <> "AB"
				aviso("Alteracao","SAT esta sob Avaliacao do Dpto de TI. Nao e permitido alterar, caso necessario, entre em contato nos ramais 187 ou 500",{"Sair"})
				return
				/*	ElseIf alltrim(SZM->ZM_PARA) == 'P' .AND. !Upper(U_DipUsr()) $ cSatman //alltrim(cmv("MV_SATMAN"))
				aviso("Alteracao","SAT esta sob Avaliacao do Dpto de Manutenção. Nao e permitido alterar, caso necessario, entre em contato no ramal 6556",{"Sair"})
				return
				ElseIf alltrim(SZM->ZM_PARA) == 'M' .AND. !Upper(U_DipUsr()) $ cSatmar //alltrim(getmv("MV_SATMAR"))
				aviso("Alteracao","SAT esta sob Avaliacao do Dpto de Marcenaria. Nao e permitido alterar, caso necessario, entre em contato no ramal 5048",{"Sair"})
				return
				ElseIf alltrim(SZM->ZM_PARA) == 'G' .AND. !Upper(U_DipUsr()) $ cSatGpe  //alltrim(getmv("MV_SATGPE"))
				aviso("Alteracao","SAT esta sob Avaliacao do Dpto de Gestao de Pessoas. Nao e permitido alterar, caso necessario, entre em contato no ramal 6579",{"Sair"})
				return
				ElseIf alltrim(SZM->ZM_PARA) == '01' .AND. !Upper(U_DipUsr()) $ cSat01  //alltrim(getmv("MV_SATGPE"))
				aviso("Alteracao","SAT esta sob Avaliacao do Dpto de Automacao. Nao e permitido alterar.",{"Sair"})
				return
				ElseIf alltrim(SZM->ZM_PARA) == '02' .AND. !Upper(U_DipUsr()) $ cSat02  //alltrim(getmv("MV_SATGPE"))
				aviso("Alteracao","SAT esta sob Avaliacao do Dpto de Equipamentos. Nao e permitido alterar.",{"Sair"})
				return
				ElseIf alltrim(SZM->ZM_PARA) == '03' .AND. !Upper(U_DipUsr()) $ cSat03  //alltrim(getmv("MV_SATGPE"))
				aviso("Alteracao","SAT esta sob Avaliacao do Dpto de Servicos/Assistencia Técnica. Nao e permitido alterar.",{"Sair"})
				return
				ElseIf alltrim(SZM->ZM_PARA) == '04' .AND. !Upper(U_DipUsr()) $ cSat04  //alltrim(getmv("MV_SATGPE"))
				aviso("Alteracao","SAT esta sob Avaliacao do Dpto de Peças. Nao e permitido alterar.",{"Sair"})
				return
				ElseIf alltrim(SZM->ZM_PARA) == '05' .AND. !Upper(U_DipUsr()) $ cSat05  //alltrim(getmv("MV_SATGPE"))
				aviso("Alteracao","SAT esta sob Avaliacao do Dpto de Instalações e Obras. Nao e permitido alterar.",{"Sair"})
				return
				ElseIf alltrim(SZM->ZM_PARA) == '06' .AND. !Upper(U_DipUsr()) $ cSat06  //alltrim(getmv("MV_SATGPE"))
				aviso("Alteracao","SAT esta sob Avaliacao do Dpto de Garantia. Nao e permitido alterar.",{"Sair"})
				return
				ElseIf alltrim(SZM->ZM_PARA) == '07' .AND. !Upper(U_DipUsr()) $ cSat07  //alltrim(getmv("MV_SATGPE"))
				aviso("Alteracao","SAT esta sob Avaliacao do Dpto de Treinamento Técnico. Nao e permitido alterar.",{"Sair"})
				return*/
			EndIf
		endif
		
		nOpcE:=3
		if !Upper(U_DipUsr()) $ cSat
			nOpcG:=2
		Else
			nOpcG:=3
		endif
	Case _nOpc==4
		if sZM->ZM_status <> "AB"
			aviso("Exclusao","Nao e permitido excluir SAT com Status diferente de Aberto",{"Sair"})
			return
		End If
		nOpcE:=2
		nOpcG:=2
	Case _nOpc==5
		ExecBlock("SATAVAL",.F.,.F.)
		
EndCase

// inicializa variaveis de memoria da Enchoice (Master)
dbSelectArea(_cMaster)
RegToMemory(_cMaster,_nOpc==1)

// monta array com campos da enchoice (Master) de acordo com o SX3
aCpoEnchoice := {}
dbSelectArea("SX3")
dbSeek(_cMaster)
While !Eof().And.(x3_arquivo==_cMaster)
	If X3USO(x3_usado) .And.cNivel>=x3_nivel
		Aadd( aCpoEnchoice, x3_campo )
	endif
	dbSkip()
enddo

// monta array de cabeçalho com informações dos campos do aCols (PICTURE, TAMANHO, F3, etc) de acordo com o SX3
dbSelectArea("SX3")
dbSeek(_cDetail)
aHeader:={}
While !Eof().And.(x3_arquivo==_cDetail)
	// não considera o campo de amarração
	If Alltrim(x3_campo)==_cCpoDet
		dbSkip()
		Loop
	Endif
	// inclui no aHeader somente se está em uso e de acordo com o nivel de usuario
	If X3USO(x3_usado) .And.cNivel>=x3_nivel
		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,"AllwaysTrue()",;
		x3_usado, x3_tipo, x3_arquivo, x3_context } )    // cria o array com as definições do SX3
	Endif
	dbSkip()
Enddo

If _nOpc==1
	// Na inclusão inicializa os campos vaZNos
	aCols:={Array(nUsado+1)}
	aCols[1,nUsado+1]:=.F. 
	aCols[1,1] := '001'
	For _ni:=2 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
Else
	aCols:={}
	dbSelectArea(_cDetail)
	dbSetOrder(1)
	cVar := "M->" + _cCpoMas
	
	//	cVar := _cMaster+ "->" + _cCpoMas
	dbSeek(xFilial()+&cVar.,.T.) // procura os itens de acordo com a amarração Master x Detail
	While !eof() .and. (xFilial()+&_cCpoDet. ==xFilial()+&cVar.) // Executa loop para carregar os registros no aCols
		AADD(aCols,Array(nUsado+1)) // inicializa a linha do aCols
		For _ni:=1 to nUsado  // carrega os campos do arquivo
			aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
		Next
		aCols[Len(aCols),nUsado+1]:=.F. // incializa campo de delatado com falso (não deletado)
		dbSkip()
	Enddo
	if Len(aCols)==0
		aCols:={Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
		For _ni:=1 to nUsado
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		Next
	endif
Endif

aCols := Asort(aCols,,,{|x,y|x[1]<y[1]})

If Len(aCols)>0
	cAliasEnchoice	:=	_cMaster
	cAliasGetD		:=	_cDetail
	
	cLinOk			:=	_FunLOk
	cTudOk			:=	_FunTOk
	cFieldOk		:=	"AllwaysTrue()"
	
	aCols := Asort(aCols,,,{|x,y|x[1]<y[1]})
	
	_lRet	:=	Modelo3(_cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)
	
	if _lRet
		if _nOpc==1 .or. _nOpc==3 .or. _nOpc==4 // Incluir, alterar ou excluir
			
			
			if _nOpc==1 .or. _nOpc==3  // incluir ou alterar
				
				
				dbSelectArea(_cMaster)
				Reclock(_cMaster,_nOpc==1)
				FieldPut(1,xFilial(_cMaster))
				For i := 1 to len(aCpoEnchoice)
					cCampo := "M->" + aCpoEnchoice[i]
					cConteudo := &cCampo.
					FieldPut(FieldPos(aCpoEnchoice[i]),cConteudo)
				next i
				If _nOpc==1
					SZM->ZM_STATUS := "AB"
				END IF
				MsUnlock()
				
				if _nOpc==1
					ConfirmSX8()
				endif
			endif
			
			// inclui registros de detalhe
			if _nOpc==1  // incluir
				dbSelectArea(_cDetail)
				/*
				For i := 1 to Len(aCols)
				if aCols[i][Len(aHeader)+1] == .f.
				Reclock(_cDetail,.t.)
				FieldPut(1,xFilial(_cDetail))
				FieldPut(FieldPos(_cCpoDet), &_cCpoMas.)
				for j := 1 to Len(aHeader)
				FieldPut(FieldPos(aHeader[j][2]),aCols[i][j])
				next j
				MsUnlock()
				endif
				Next i
				*/
				
				// Envia e-mail ao responsável na Inclusao da SAT
				
				IF SZM->ZM_STATUS == "AB"
				
					//Private CRLF       := Chr(13) + Chr(10)
					Private cMensagem  := ''
					Private cSat   := ALLTRIM(SZM->ZM_NRSAT)
					Private cEmiss := dtoc(SZM->ZM_DATA)
					Private cHora  := SZM->ZM_HORA
					Private cUser  := alltrim(SZM->ZM_USER)
					Private cDepto := alltrim(SZM->ZM_DEPTO)
					Private cTipo  := alltrim(SZM->ZM_TPSAT)
					Private cPara  := alltrim(SZM->ZM_PARA)
					Private cPriori:= ''
					Private cAssunto := alltrim(SZM->ZM_ASSUNTO)
					Private cDescr := alltrim(SZM->ZM_DESCR)
					Private cEmpresa := SM0->M0_NOME
					Private cTo := ''
					Private cNomeCompleto := ''
					Private cEmail := ''
					Private cDepartamento :=''
					Private cAvaliac := '' 
					Private cJustifi := ''
					
					PswOrder(2)      
					
					if PswSeek(cUser,.T.)
						cNomeCompleto := Alltrim(pswret(1,1,4)[1][4])
						cEmail	 	  := Alltrim(pswret(1,1,4)[1][14])
						cDepartamento := Alltrim(pswret(1,1,4)[1][12])
					Endif
					
					If alltrim(SZM->ZM_PRIORI) == 'A'
						cPriori := 'Alta'
					ElseIf alltrim(SZM->ZM_PRIORI) == 'M'
						cPriori := 'Média'
					elseIf alltrim(SZM->ZM_PRIORI) == 'B'
						cPriori :='Baixa'
					EndIf
					
					
					If cPara == 'I'
						cTo := cEmInfra
					Elseif cPara == 'S'
						cTo := cEmSiga
					EndiF
					
					cMensagem := txthtm()
					//
					CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword	RESULT lOk
					
					If lOk

						SEND MAIL FROM cFrom ;
						TO      	Lower(cTo);
						CC      	Lower("maximo.canuto@dipromed.com.br");
						BCC     	Lower("");
						SUBJECT 	"Inclusão da SAT Nr. " + cSat+ " - " +cEmpresa+ "  ";
						BODY    	cMensagem;
						RESULT lOK
						DISCONNECT SMTP SERVER
						
					ELSE
						Alert("Erro ao Conectar servidor de e-mails")
					Endif 
					
				Endif
				//---------------------------------------------------------------
	            // Envia Mensagem via CIC para o usuario que eh responsavel 
	            // pelo Atendimento Tecnico.
                //---------------------------------------------------------------
                fEnviaMsg('Incusão') // JBS 18/01/2010
		        
		        // Fim de envia e-mail
				
			endif
			
			// altera registros antigos, apaga deletados e grava novos itens
			if _nOpc==3  // alterar
				
				// Procura e guarda a posição do campo chave de ligação
				For i := 1 to Len(aHeader)
					if alltrim(aHeader[i][2])==alltrim(_cCpoKey)
						nPosKey := i
					endif
				Next i
				
				// verifica registros anteriores, atualizando-os
				dbSelectArea(_cDetail)
				dbSetOrder(1)
				cVar := "M->"+_cCpoMas
				dbSeek(xFilial()+&cVar.)
				While !eof() .and. (&_cCpoDet. == &cVar.)
					For i := 1 to Len(aCols)
						if aCols[i][nPosKey] == &_cCpoKey.
							if aCols[i][Len(aHeader)+1] == .t.
								Reclock(_cDetail,.f.)
								dbDelete()
								MsUnlock()
							else
								Reclock(_cDetail,.f.)
								
								for j := 1 to Len(aHeader)
									FieldPut(FieldPos(aHeader[j][2]),aCols[i][j])
								next j
								MsUnlock()
								aCols[i][Len(aHeader)+1] := .t.
							endif
						endif
					Next i
					dbSkip()
				enddo
				
				// inclui novos itens
				For i := 1 to Len(aCols)
					if aCols[i][Len(aHeader)+1] == .f.
						Reclock(_cDetail,.t.)
						FieldPut(1,xFilial(_cDetail))
						FieldPut(FieldPos(_cCpoDet), &_cCpoMas.)
						for j := 1 to Len(aHeader)
							FieldPut(FieldPos(aHeader[j][2]),aCols[i][j])
						next j
						MsUnlock()
						aCols[i][Len(aHeader)+1] := .t.
					endif
				Next i
				
				//*******************************************************************************************
				
				//
				IF SZM->ZM_STATUS == "AV"
					//	Private _aAreaAtu := GetArea()
					//Private CRLF       := Chr(13) + Chr(10)
					Private cMensagem  := ''
					Private cSat   := ALLTRIM(SZM->ZM_NRSAT)
					Private cEmiss := DtoC(SZM->ZM_DATA)
					Private cHora  := SZM->ZM_HORA
					Private cUser  := SZM->ZM_USER
					Private cDescr := alltrim(SZM->ZM_DESCR)
					Private cEmail := ''
					Private cPara  := alltrim(SZM->ZM_PARA)
					Private cEmpresa := SM0->M0_NOME
					Private cNomeCompleto := ''
					Private cAvaliac := '' 
					Private cJustifi := ''

					
					If cPara == 'I'
						cProbl := 'Infra-Estrutura'
						cTo := cEmInfra
					Elseif cPara == 'S'
						cProbl := 'Microsiga'
						cTo := cEmSiga
					EndiF
					
					PswOrder(2)

					if PswSeek(cUser,.T.)
						cNomeCompleto := Alltrim(pswret(1,1,4)[1][4])
						cEmail        := Alltrim(pswret(1,1,4)[1][14])
						cDepartamento := Alltrim(pswret(1,1,4)[1][12])
					Endif
										
					cMensagem :=  txthtm()
					
					CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword	RESULT lOk
					
					If lOk

						SEND MAIL FROM cFrom ;
						TO      	Lower(cEmail);
						CC      	Lower("maximo.canuto@dipromed.com.br");
						BCC     	Lower("");
						SUBJECT 	"Confirmação de Atendimento SAT Nr. " + cSat+ " - " +cEmpresa+ " ";
						BODY    	cMensagem;
						RESULT lOK
						DISCONNECT SMTP SERVER

					Else
						Alert("Erro ao Conectar servidor de e-mails")
					Endif     
                    //---------------------------------------------------------------
	                // Envia Mensagem via CIC para o usuario que eh responsavel 
	                // pelo Atendimento Tecnico.
                    //---------------------------------------------------------------
                    fEnviaMsg('Alteração')	// JBS 18/01/2010				
					
					RECLOCK("SZM",.F.)
					SZM->ZM_DTFIM := DDATABASE
					SZM->ZM_HRFIM := TIME()
					MSUNLOCK()
					
				Endif
				
			endif
			
			// Exclusão
			if _nOpc==4 // apagar
				
				// apaga o cabeçalho
				dbSelectArea(_cMaster)
				Reclock(_cMaster,.f.)
				dbDelete()
				MsUnlock()
				
				// apaga os detalhes
				dbSelectArea(_cDetail)
				dbSetOrder(1)
				cVar := "M->"+_cCpoMas
				dbSeek(xFilial()+&cVar.)
				While !eof() .and. (&_cCpoDet. == &cVar.)
					Reclock(_cDetail,.f.)
					dbDelete()
					MsUnlock()
					dbSkip()
				enddo
			endif
			
			//Avaliar
			If _nOpc==5
				
				
			End If
			
		endif
	else
		RollBackSx8()
	endif
endif

Return

// Monta vetor tipo Header de acordo com o vetor aCampos
User Function SATHeader(cAlias,aCampos)
Local aRet := {}
Local cAliasAnt := Alias()
Local nIndAnt   := IndexOrd()

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
nUsado := 0
while SX3->(!Eof()) .and. SX3->X3_ARQUIVO==cAlias
	If !Empty(X3_USADO) .and. (cNivel >= X3_NIVEL) .and. ASCAN(aCampos, alltrim(X3_CAMPO))<>0
		nUsado := nUsado + 1
		AADD(aRet,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
		X3_TAMANHO, X3_DECIMAL, X3_VALID,;
		X3_USADO, X3_TIPO, X3_ARQUIVO } )
	endif
	SX3->(dbSkip())
enddo

dbSelectArea(cAliasAnt)
dbSetOrder(nIndAnt)

Return(aRet)


// Monta vetor tipo Cols de acordo com os parametros
User Function SATCols(cAlias,nIndice,cCpoAmarr,cChave,aHeader)
Local cAliasAnt := Alias()
Local nIndAnt   := IndexOrd()
Local aRet

dbSelectArea(cAlias)
dbSetOrder(nIndice)
dbSeek(xFilial(cAlias)+cChave)
nCnt := 0
while !Eof() .and. (&cCpoAmarr. == cChave)
	nCnt := nCnt + 1
	dbSkip()
enddo

if nCnt<>0
	aRet := Array(nCnt,len(aHeader)+1)
	nCnt := 0
	dbSeek(xFilial(cAlias)+cChave)
	while !Eof() .and. (&cCpoAmarr. == cChave)
		nCnt := nCnt + 1
		For i := 1 to Len(aHeader)
			aRet[nCnt][i] := &(cAlias+"->"+aHeader[i][2])
		next i
		aRet[nCnt][len(aHeader)+1] := .f. //Flag de Delecao
		
		dbSkip()
	enddo
else
	aRet := Array(1,len(aHeader)+1)
	For i := 1 to Len(aHeader)
		do case
			case aHeader[i][8]=="C"
				aRet[1][i] := space(aHeader[i][4])
			case aHeader[i][8]=="N"
				aRet[1][i] := 0
			case aHeader[i][8]=="D"
				aRet[1][i] := CTOD("  /  /  ")
			case aHeader[i][8]=="L"
				aRet[1][i] := .t.
		endcase
	next i
	aRet[1][len(aHeader)+1] := .f. //Flag de Delecao
endif

dbSelectArea(cAliasAnt)
dbSetOrder(nIndAnt)

Return(aRet)

//<------------------------------------ HTML------------------------------------------------------------------>

Static Function Txthtm()

Private chtml := ""

chtml := "<html>"
chtml += "<head>"

chtml += "<title>SAT-Solicitacao de Atendimento Tecnico </title>"
chtml += "</head>"

chtml += "<body bottommargin='0' topmargin='0' leftmargin='0' rightmargin='0' marginheight='0' marginwidth='0'>"

chtml += "<style>a.footer{	font-family 	: Verdana, Arial;	font-size 		: 10px;	color			: "
chtml += "#000000;	font-weight		: bold;}a:hover.footer{	font-family 	: Verdana, Arial;	font-size 		: "
chtml += "10px;	color			: #2675af;	font-weight		: bold;}.footer{	font-family 	: Verdana, Arial;	font-size 		: 10px;	color			: #000000;	font-weight		: bold;	padding-top		: 5px;	padding-left	: 5px;	padding-right	: 5px;	padding-bottom	: 5px;}div, .conteudo{	background-image: url('');	font-family 	: Verdana, Arial;	font-size 		: 11px;	line-height		: 15px;	color			: #1269aa;	padding-left	: 10px;	padding-right	: 10px;	background-repeat: no-repeat;}.TabMenu{	background-color: #ffffff;	BORDER-TOP 		: #c8c8c8 1px solid;	BORDER-LEFT 	: #c8c8c8 1px solid;	BORDER-RIGHT 	: #c8c8c8 1px solid;	BORDER-BOTTOM 	: #c8c8c8 1px solid;}</style><table width='530' height='100%' cellpadding='0' cellspacing='0' class='TabMenu'><tr><td height='113'><img src='http://www.dipromed.com.br/site//images/inicio_banner.gif' width='540' height='113' alt='' border='0'></td></tr><tr><td valign='top' class='conteudo'><P><B><FONT color=crimson></FONT></B>&nbsp;</P>"

if SZM->ZM_STATUS == "AB"

	chtml +="<P><B><FONT color=crimson>Inclusão da SAT "+cSat+"</FONT></B></P>"
	chtml +="<P><B><FONT color=crimson>Empresa: "+cEmpresa+"</FONT></B></P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify><B>Aberta em:</B> "+cEmiss+" - "+cHora+" </P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify><B>Usuário:</B> "+cUser+" - "+cNomeCompleto+"</P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify><B>Departamento:</B> "+cDepto+"</P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify><B>Prioridade:</B> "+cPriori+"</P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify><B>Assunto:</B> "+cAssunto+"</P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify><B>Descrição: </B></P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>"+cDescr+"</P>"
	chtml +="<P>&nbsp;</P>"
    //chtml +="<tr><td align='center' height='20' bgcolor='#d9d9d8' class='footer'><a class='footer' href=''http://www.dipromed.com.br/site//images/inicio_banner.gif'></a></td>"
    //chtml +="<P>&nbsp;</P></td></tr><tr><td height='87'><img src='http://www.dipromed.com.br/site//images/inicio_banner.gif' width='540' height='71' alt='' border='0'></td></tr>
	
	chtml +="</script>"
	chtml +="<center>"
	chtml +="</center>"
	chtml +="</body>"
	chtml +="</html>"
	
elseif SZM->ZM_STATUS == "AV"
	chtml +="<P><B><FONT color=crimson>Olá "+cNomeCompleto+"!</FONT></B></P>"
	chtml +="<P align=justify><B><FONT style='TEXT-JUSTIFY: distribute-all-lines; TEXT-ALIGN: justify' color=crimson>Você está recebendo a confirmação de Atendimento de sua SAT<BR><BR><BR></FONT></B></P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>Nº "+ cSat+" </P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>Aberta em: "+cEmiss+" - "+cHora+"</P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>Para: "+cProbl+"</P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>"+cDescr+"</P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>Informamos que o atendimento de sua solicitação já foi concluído. Por favor entre no Menu -> Atualizações -> Específicos -> *Avalie a SAT, para avaliar o atendimento.</P>"
	chtml +="<P><B>Até a próxima,</B></P>"
	chtml +="<P><B>Equipe de TI</B></P>"
    //chtml += "10px;	color			: #2675af;	font-weight		: bold;}.footer{	font-family 	: Verdana, Arial;	font-size 		: 10px;	color			: #000000;	font-weight		: bold;	padding-top		: 5px;	padding-left	: 5px;	padding-right	: 5px;	padding-bottom	: 5px;}div, .conteudo{	background-image: url('');	font-family 	: Verdana, Arial;	font-size 		: 11px;	line-height		: 15px;	color			: #1269aa;	padding-left	: 10px;	padding-right	: 10px;	background-repeat: no-repeat;}.TabMenu{	background-color: #ffffff;	BORDER-TOP 		: #c8c8c8 1px solid;	BORDER-LEFT 	: #c8c8c8 1px solid;	BORDER-RIGHT 	: #c8c8c8 1px solid;	BORDER-BOTTOM 	: #c8c8c8 1px solid;}</style><table width='530' height='100%' cellpadding='0' cellspacing='0' class='TabMenu'><tr><td height='113'><img src='http://www.dipromed.com.br/site//images/fim_banner_topo.jpg' width='540' height='113' alt='' border='0'></td></tr><tr><td valign='top' class='conteudo'><P><B><FONT color=crimson></FONT></B>&nbsp;</P>"
    //chtml +="<P>&nbsp;</P></td></tr><tr><td height='87'><img src='http://www.dipromed.com.br/site//images/inicio_banner.gif' width='540' height='71' alt='' border='0'></td></tr>
	
	
	chtml +="</script>"
	chtml +="<center>"
	chtml +="</center>"
	chtml +="</body>"
	chtml +="</html>"
	
elseif SZM->ZM_STATUS == "CO" 

	chtml +="<P><B><FONT color=crimson>Olá "+cNomeCompleto+"!</FONT></B></P>"
	chtml +="<P align=justify><B><FONT style='TEXT-JUSTIFY: distribute-all-lines; TEXT-ALIGN: justify' color=crimson>Você está recebendo a confirmação de Atendimento de sua SAT<BR><BR><BR></FONT></B></P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>Nº "+ cSat+" </P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>Aberta em: "+cEmiss+" - "+cHora+"</P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>Para: "+cProbl+"</P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>"+cDescr+"</P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>Foi avaliada como "+cAvaliac+"</P>"
	chtml +="<P style='TEXT-ALIGN: justify; distribute-all-lines: ' align=justify>Justificativa do Usuario: "+cJustifi+"</P>"
    //chtml +="<tr><td align='center' height='20' bgcolor='#d9d9d8' class='footer'><a class='footer' href='http://www.dipromed.com.br/site//images/inicio_banner.gif'></a></td>"
	//chtml +="<P>&nbsp;</P></td></tr><tr><td height='87'><img src='http://www.dipromed.com.br/site//images/inicio_banner.gif' width='540' height='71' alt='' border='0'></td></tr>
	
	chtml +="</script>"
	chtml +="<center>"
	chtml +="</center>"
	chtml +="</body>"
	chtml +="</html>"
	
EndIf

return(chtml)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fEnviaMsg()ºAutor ³Jailton B Santos-JBSº Data ³ 18/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Envia a mensagem pelo CIC para o usuario de acordo com a   º±±
±±º          ³ avaliacao do Status do Chamado.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SAT - Dipromed                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fEnviaMsg(cTpMsg)

Local lRetorno    := .T.
Local cFilSC9     := xFilial("SC9")
Local cServidor   := GetMV("MV_CIC")     // Servidor para enviar mensagem pelo CIC
Local cOpFatRem   := GetMV("MV_REMETCI") // Usuario do CIC remetente de mensgens no Protheus
Local cOpFatSenha := "123456"
Local cOpFatDest  := fBuscaCic()
Local cMsg        := fMsg(cTpMsg)
                                                                        
cOpFatDest += ","

U_DIPCIC(Padr(cMsg,380),AllTrim(cOpFatDest))// RBorges 12/03/15
//WaitRun(cServidor+' '+cOpFatRem+' '+cOpFatSenha+' "'+AllTrim(cOpFatDest)+'" "'+Padr(cMsg,380)+'" ') // Comentada RBorges 12/03/15

Return(lRetorno)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fBuscaCic ºAutor  ³Jailton B Santos-JBSº Data ³  18/01/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca o usuario para disparar o CIC. Busca no 'SU7', 'SY1' eº±±
±±º          ³na tabela 'Z0'do 'SX5'.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SAT - Dipromed                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fBuscaCic(cTpMsg)

Local cOperador := '' 

Begin Sequence

SU7->(DbSetOrder(4))
SU7->(DbGoTop())

If SU7->(DbSeek(xFilial("SU7") + __cUserId))
	If SU7->U7_VALIDO == "1" .And. !Empty(Alltrim(SU7->U7_CICNOME))
		cOperador := Alltrim(SU7->U7_CICNOME)
		Break
	EndIf
EndIf

SY1->(DbSetOrder(3))
SY1->(DbGoTop())

If SY1->(DbSeek(xFilial("SY1") + __cUserId ))
	If !Empty(Y1_NOMECIC)
		cOperador := Alltrim(Y1_NOMECIC)
		Break
	Endif
EndIf

SX5->( DbSetOrder(1))
SX5->( DbGotop())

If SX5->( DbSeek(xFilial('SX5')+'Z0' + __cUserId ) )
	cOperador := AllTrim(SX5->X5_DESCRI)
EndIf
	
End Sequence

Return(cOperador)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fMsg()    ºAutor  ³Jailton B Santos-JBSº Data ³ 18/01/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta a mensagem a ser enviada pelo CIC, avaliando o statusº±±
±±º          ³ para determinar o usuario e a mensagem.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SAT - Dipromed                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fMsg(cTpMsg)

Local cMsg := "SAT-Solicitacao de Atendimento Tecnico ( " + cTpMsg + " ) " + Chr(13)+chr(10)

If SZM->ZM_STATUS == "AB"
	
	cMsg += "Inclusão SAT: " + cSat     + Chr(13)+chr(10)
	cMsg += "Empresa.....: " + cEmpresa + Chr(13)+chr(10)
	cMsg += "Aberta em...: " + cEmiss   + Chr(13)+chr(10)
	cMsg += "Usuário.....: " + cUser+" - "+cNomeCompleto + Chr(13)+chr(10)
	cMsg += "Departamento: " + cDepto   + Chr(13)+chr(10)
	cMsg += "Prioridade..: " + cPriori  + Chr(13)+chr(10)
	cMsg += "Assunto.....: " + cAssunto + Chr(13)+chr(10)
	
ElseIf SZM->ZM_STATUS == "AV"
	
	cMsg += "Olá " + cNomeCompleto + " "
	cMsg += "Você está recebendo a confirmação de Atendimento de sua SAT"
	cMsg += "Nº ...........: " + cSat   + Chr(13) + chr(10)
	cMsg += "Aberta em.....: " + cEmiss + " - "   + cHora + Chr(13)+chr(10)
	cMsg += "Para..........: " + cProbl + Chr(13) + chr(10)
	cMsg += "Descrição.....: " + cDescr + Chr(13) + chr(10)
	cMsg += "Atendimento Concluído. Avalie o Atendimento." + Chr(13)+chr(10)
	
ElseIf SZM->ZM_STATUS == "CO"
	
	cMsg += "Olá "+cNomeCompleto+"!" + Chr(13)+chr(10)
	cMsg += "Confirmação de Atendimento de sua SAT" + Chr(13)+chr(10)
	cMsg += "Nº ..........: " + cSat + " " +  Chr(13) + chr(10)
	cMsg += "Aberta em....: " + cEmiss   + " - " + cHora + " " + Chr(13)+chr(10)
	cMsg += "Para.........: " + cProbl   + Chr(13)+chr(10)
	cMsg += "Descrição....: " + cDescr   + Chr(13)+chr(10)
	cMsg += "Avalição.....: " + cAvaliac + Chr(13)+chr(10)
	cMsg += "Justificativa: " + cJustifi + Chr(13)+chr(10)
	
EndIf

Return(cMsg)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SAT01BRELAºAutor  ³Jailton B Santos-JBSº Data ³  19/01/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que retorna o X3_RELACAO do campo ZN_ITEM. Faz a in-º±±
±±º          ³ crementacao do item.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SAT - Dipromed                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SAT01BRELA(cCampo)
Return(StrZero(Len(aCols),3)) 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SAT01BWHENºAutor  ³Jailton B Santos-JBSº Data ³  28/01/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Determina se o campo que esta chamando a funcao pode ou naoº±±
±±º          ³ ser editado pelo usuario corrente.                         º±±
±±º          ³                                                            º±±
±±º          ³ Se o usuario logado estiver contido dentro do parametro,   º±±
±±º          ³ "MV_SATTI", o campo pode ser editado por este usuario na   º±±
±±º          ³ alteracao de "SAT".                                        º±±
±±º          ³ Na inclusao nao ha restricao.                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SAT - Dipromed                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SAT01BWHEN()
Return(Upper(U_DipUsr()) $ GetMv("MV_SATTI"))