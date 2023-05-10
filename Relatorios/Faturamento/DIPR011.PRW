#include "rwmake.ch"
#define DESLOC_ETQ  57

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ DIPR011  ³ Autor ³ Rodrigo Franco        ³ Data ³ 15.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Etiquetas para os volumes                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPR011()

//³ Define Variaveis                                             ³
LOCAL titulo := "Mala Direta"
LOCAL cDesc1 := "Este programa ira emitir as Mala Direta"
LOCAL cDesc2 := "para as envelopes a serem despachadas."
LOCAL cDesc3 := ""
LOCAL wnrel
LOCAL tamanho:= "G"
LOCAL cString:= "SA1"
LOCAL aOrd      := { " Etiqueta - 36 X 81mm  3 colunas " }		//" Etiqueta - 36 X 81mm  3 colunas "
LOCAL aImp      := 0   
Local cUserAut  := GetMV("MV_URELFAT") // MCVN - 04/05/09    

PRIVATE aReturn := { "Etiqueta", 1,"Producao", 2, 2, 1, "",1 }		//"Etiqueta"###"Producao"
PRIVATE nomeprog:= "ETIQUETA" //"MATR710"
PRIVATE aLinha  := { },nLastKey := 0

//PRIVATE cPerg   :="MALDIR"      
// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1
PRIVATE cPerg  	:= U_FPADR( "MALDIR","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09. 


// MCVN - 04/05/09    
If !(Upper(U_DipUsr()) $ cUserAut)
	Alert(Upper(U_DipUsr())+", você não tem autorização para utilizar esta rotina. Qualquer dúvida falar com Eriberto!","Atenção")	
	Return()
EndIF

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//³ Verifica as perguntas selecionadas                           ³

pergunte(cPerg,.F.)

//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        	// Qual Serie De Nota Fiscal            	  ³
//³ mv_par02        	// Nota Fiscal de                        	  ³
//³ mv_par03        	// Nota Fiscal ate                       	  ³
//³ mv_par04        	// Emite por   Pedido   Nota Fiscal      	  ³
//³ Envia controle para a funcao SETPRINT                        ³
wnrel:="MALADIR"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,tamanho)
If nLastKey == 27
	Set Filter to
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Set Filter to
	Return
Endif
RptStatus({|lEnd| C710Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ C710IMP  ³ Autor ³ Rodrigo Franco        ³ Data ³ 01.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR550			                                            ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C710Imp(lEnd,WnRel,cString)

//³ Define Variaveis                                             ³
LOCAL CbTxt
LOCAL titulo := "Mala Direta"
LOCAL cDesc1 := "Este programa ira emitir as Mala Direta"
LOCAL cDesc2 := "para as envelopes a serem despachadas."
LOCAL cDesc3 := ""
LOCAL nTipo, nOrdem
LOCAL CbCont,cabec1,cabec2
LOCAL tamanho:= "P"
LOCAL limite := 80
LOCAL nVolume := nVolumex := 0
LOCAL aEtiq[8,3]
LOCAL nEtiqueta := I := J := 1
LOCAL aOrd      := { " Etiqueta - 36 X 81mm  3 colunas " }	//" Etiqueta - 36 X 81mm  3 colunas "
LOCAL aImp      := 0
LOCAL nEstaOk   := 0
LOCAL nContCol  := 1
LOCAL cPedi     := ""
Local cX
Local cIndex
Local lRet      := .F.
Local cCadastro := "Mala Direta"

//³ Definicao do cabecalho e tipo de impressao do relatorio      ³
cbtxt    := SPACE(10)
cbcont   := 0
li       := 0
col      := 0
m_pag    := 1
titulo := "Mala Direta"
cabec1 := ""
cabec2 := ""
nTipo  := 18
nOrdem := aReturn[8]

//³ Acesso nota fiscal informada pelo usuario                    ³
dbSelectArea("SA1")
dbsetorder(1)
dbSeek(xFilial("SA1")+mv_par01,.T.)
SetRegua(RecCount())		// Total de Elementos da regua

//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
@ 0,0 Psay AvalImp(Limite)
While !eof() .and. xFilial("SA1") == SA1->A1_FILIAL .And. SA1->A1_COD <= mv_par02
	If SA1->A1_ULTCOM < mv_par03 .AND. SA1->A1_ULTCOM > mv_par04
		DbSkip()
	Endif
	IncRegua()
	For G:=1 to 3
		cX := "SF2->F2_VOLUME"+str(G,1)
		nVolume := nVolumex := &cX
		While !eof() .and. xFilial("SA1") == SA1->A1_FILIAL .And. SA1->A1_COD <= mv_par02
			If SA1->A1_ULTCOM < mv_par03 .AND. SA1->A1_ULTCOM > mv_par04
				DbSkip()
			Endif
			If nOrdem == 1
				If aImp == 0
					While !lRet
						lRet := (MsgYesNo("O Alinhamento da Impressora esta correto ?","Aten‡„o"))			//"O Alinhamento da Impressora esta correto ?"###"Aten‡„o"
					End
				EndIf
				_n_Lin := pRow()
				_n_Col := pCol()
				@ _n_Lin,_n_Col Psay chr(15) //@ _n_Lin,_n_Col Psay chr( getMV( "MV_COMP" ) )
				setPrc( _n_Lin,_n_Col )
				cX := "SF2->F2_ESPECI"+str(G,1)
				Do Case
					Case nEtiqueta == 1
						If nVolume == 0
							aEtiq[1,nEtiqueta] := SA1->A1_COD				   			  	 					//SM0->M0_NOMECOM  //STR0012+PadR(SD2->D2_CLIENTE,20)+STR0013+SD2->D2_PEDIDO				//"Cliente: "###"Pedido: "
							aEtiq[2,nEtiqueta] := SUBSTR(SA1->A1_NOME,1,51)            				   		  				//REPLICATE("=",30)  //SA1->A1_NOME
							aEtiq[3,nEtiqueta] := SA1->A1_CONTATO            		  			 	 			//"Destino: " + SA1->A1_NOME   //IIF(!empty(SA1->A1_ENDENT),Subs(SA1->A1_ENDENT,1,49),Subs(SA1->A1_END,1,49))
							aEtiq[4,nEtiqueta] := ""      					//"Endereco: " + IIF(!empty(SA1->A1_ENDENT),Subs(SA1->A1_ENDENT,1,48),Subs(SA1->A1_END,1,48))  //STR0014+Trans(SA1->A1_CEP,"@R 99999-999")+" "+AllTrim(SA1->A1_MUN)+" "+SA1->A1_EST		//"Cep: "
							aEtiq[5,nEtiqueta] := SA1->A1_END + " - " + SUBSTR(SA1->A1_BAIRRO,1,10)    	//"Cidade: " + AllTrim(SA1->A1_MUN)+" / "+SA1->A1_EST //STR0015		//"Transportadora: "
							aEtiq[6,nEtiqueta] :=  ""           // "Transportadora: " + SA4->A4_NOME
							aEtiq[7,nEtiqueta] := ""            //"Volume: "+AllTrim(STR((nVolumex-nVolume)+1))+"/"+AllTrim(STR(nVolumex))+" "+"    Especie: "+&cX	//"Volume: "###"    Especie: "
							aEtiq[8,nEtiqueta] := Trans(SA1->A1_CEP,"@R 99999-999") + "    - " + SA1->A1_MUN + " - " + SA1->A1_EST            //"Nota Fiscal/Serie: " + SF2->F2_DOC + "/" + mv_par01		//"Nota Fiscal/Serie: "
							nEtiqueta++
						EndIf
					Case nEtiqueta == 2
						If nVolume == 0
							aEtiq[1,nEtiqueta] := SA1->A1_COD 				   			  	 					//SM0->M0_NOMECOM  //STR0012+PadR(SD2->D2_CLIENTE,20)+STR0013+SD2->D2_PEDIDO				//"Cliente: "###"Pedido: "
							aEtiq[2,nEtiqueta] := SUBSTR(SA1->A1_NOME,1,51)           				   		  				//REPLICATE("=",30)  //SA1->A1_NOME
							aEtiq[3,nEtiqueta] := SA1->A1_CONTATO            		  			 	 			//"Destino: " + SA1->A1_NOME   //IIF(!empty(SA1->A1_ENDENT),Subs(SA1->A1_ENDENT,1,49),Subs(SA1->A1_END,1,49))
							aEtiq[4,nEtiqueta] := ""      					//"Endereco: " + IIF(!empty(SA1->A1_ENDENT),Subs(SA1->A1_ENDENT,1,48),Subs(SA1->A1_END,1,48))  //STR0014+Trans(SA1->A1_CEP,"@R 99999-999")+" "+AllTrim(SA1->A1_MUN)+" "+SA1->A1_EST		//"Cep: "
							aEtiq[5,nEtiqueta] := SA1->A1_END + " - " + SUBSTR(SA1->A1_BAIRRO,1,10)    	//"Cidade: " + AllTrim(SA1->A1_MUN)+" / "+SA1->A1_EST //STR0015		//"Transportadora: "
							aEtiq[6,nEtiqueta] :=  ""           // "Transportadora: " + SA4->A4_NOME
							aEtiq[7,nEtiqueta] :=  ""           //"Volume: "+AllTrim(STR((nVolumex-nVolume)+1))+"/"+AllTrim(STR(nVolumex))+" "+"    Especie: "+&cX	//"Volume: "###"    Especie: "
							aEtiq[8,nEtiqueta] := Trans(SA1->A1_CEP,"@R 99999-999") + " - " + SA1->A1_MUN + " - " + SA1->A1_EST            //"Nota Fiscal/Serie: " + SF2->F2_DOC + "/" + mv_par01		//"Nota Fiscal/Serie: "
							nEtiqueta++
						EndIf
					Case nEtiqueta == 3
						If nVolume == 0
							aEtiq[1,nEtiqueta] := SA1->A1_COD 				   			  	 					//SM0->M0_NOMECOM  //STR0012+PadR(SD2->D2_CLIENTE,20)+STR0013+SD2->D2_PEDIDO				//"Cliente: "###"Pedido: "
							aEtiq[2,nEtiqueta] := SUBSTR(SA1->A1_NOME,1,51)       				   		  				//REPLICATE("=",30)  //SA1->A1_NOME
							aEtiq[3,nEtiqueta] := SA1->A1_CONTATO            		  			 	 			//"Destino: " + SA1->A1_NOME   //IIF(!empty(SA1->A1_ENDENT),Subs(SA1->A1_ENDENT,1,49),Subs(SA1->A1_END,1,49))
							aEtiq[4,nEtiqueta] :=   ""    					//"Endereco: " + IIF(!empty(SA1->A1_ENDENT),Subs(SA1->A1_ENDENT,1,48),Subs(SA1->A1_END,1,48))  //STR0014+Trans(SA1->A1_CEP,"@R 99999-999")+" "+AllTrim(SA1->A1_MUN)+" "+SA1->A1_EST		//"Cep: "
							aEtiq[5,nEtiqueta] := SA1->A1_END + " - " + SUBSTR(SA1->A1_BAIRRO,1,10)    	//"Cidade: " + AllTrim(SA1->A1_MUN)+" / "+SA1->A1_EST //STR0015		//"Transportadora: "
							aEtiq[6,nEtiqueta] :=   ""          // "Transportadora: " + SA4->A4_NOME
							aEtiq[7,nEtiqueta] :=   ""          //"Volume: "+AllTrim(STR((nVolumex-nVolume)+1))+"/"+AllTrim(STR(nVolumex))+" "+"    Especie: "+&cX	//"Volume: "###"    Especie: "
							aEtiq[8,nEtiqueta] := Trans(SA1->A1_CEP,"@R 99999-999") + " - " + SA1->A1_MUN + " - " + SA1->A1_EST            //"Nota Fiscal/Serie: " + SF2->F2_DOC + "/" + mv_par01		//"Nota Fiscal/Serie: "
							nEtiqueta := 1
							For I:= 1 TO 8
								For J:=1 TO 3
									@Li , COL  Psay aEtiq[I,J]
									COL := COL + 14
									COL += DESLOC_ETQ
								Next j
								Li++
								COL := 0
							Next I
							For I:= 1 TO 8
								For J:=1 TO 3
									aEtiq[I,J] := ""
								NEXT J
							NEXT I
							Li++
						EndIf
				EndCase
			EndIf
			dbSelectArea("SA1")
			dbSkip()
		End
	Next G
	dbSelectArea("SA1")
	dbSkip()
End
If nOrdem == 1
	For I:= 1 TO 8
		For J:=1 TO 3
			If !EMPTY(aEtiq[I,J])
				@Li , COL  Psay aEtiq[I,J]
				COL := COL + 14
				COL += DESLOC_ETQ
			EndIf
		NEXT J
		Li++
		COL := 0
	Next I
EndIf
@ Li+1,0 Psay ""
Setprc(0,0)
If aReturn[5] == 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif
MS_FLUSH()

Return .T.