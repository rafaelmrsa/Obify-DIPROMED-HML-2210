#INCLUDE "RWMAKE.CH"                                                                                                                                            
#INCLUDE "NFFATURA.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "AP5MAIL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ DIPR018  ³ Autor ³ Eriberto Elias     ³ Data ³ 16/05/2002  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relacao das notas fiscais                                  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIPR018()

//³ Define Variaveis                                             ³
LOCAL  tamanho := "G"
LOCAL titulo  := "*** TITULOS QUE DERAM ENTRADA EM: "
LOCAL cDesc1  := "Relacao das notas fiscais,de acordo com a"
LOCAL cDesc2  := "DATA informada no parametro."
LOCAL cDesc3  := "So imprime notas lacandas nos modulos de COMPRAS ou ESTOQUES"
//LOCAL cPerg   := "DIPR18"
LOCAL wnrel   := "DIPR018"
LOCAL cString := "SF1"  
Local oDlg
Local nOpcao := 0
Local bOK    := {|| nOpcao := 1, oDlg:End()}
Local bCancel:= {|| nOpcao := 0, oDlg:End()}
Local aItens  := {}

// FPADR(cPerg, cArq, cCampo, cTipo)  - Para ajustar o tamanho das perguntas no SX1- uso generico
PRIVATE cPerg  	:= U_FPADR( "DIPR18","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

Private limite := 220
PRIVATE aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
PRIVATE nomeprog := "DIPR018", nLastKey := 0
PRIVATE li:=0, nTotGer := 0

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
                          ³
//Verifica se imprime pelo Estoque/Compras ou pelo FInanceiro  MCVN 25/08/08

aAdd(aItens,"Relação de Notas")
aAdd(aItens,"Relação de Faturas - FRETE")

Do While .t.
nTotGer      := 0 // MCVN 19/01/2009
	nRadio := 1
	nOpcao := 0

	Define msDialog oDlg Title "Selecione a opção desejada" From 00,00 TO 7,45

	@ 033,020 RADIO aItens VAR nRadio  
	
	Activate Dialog oDlg Centered on init EnchoiceBar(oDlg,bOk,bCancel)
	
	Do Case
		Case nOpcao == 0
			Exit
		Case nRadio == 1       
			pergunte(cPerg,.t.)
			wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)
			If nLastKey==27
			Set Filter to
			Return( NIL )
			Endif	
			SetDefault(aReturn,cString)
			If nLastKey==27
			Set Filter to
			Return( NIL )
			Endif
			RptStatus({|lEnd| C730Imp(@lEnd,wnRel,cString,TITULO+' '+DTOC(MV_PAR01)+" ***")},Titulo+' '+DTOC(MV_PAR01)+" ***")			
		Case nRadio == 2
			pergunte(cPerg,.t.)
			wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)
			If nLastKey==27
			Set Filter to
			Return( NIL )
			Endif	
			SetDefault(aReturn,cString)
			If nLastKey==27
			Set Filter to
			Return( NIL )
			Endif
			RptStatus({|lEnd| CFinImp(@lEnd,wnRel,cString,TITULO+' '+DTOC(MV_PAR01)+" ***")},Titulo+' '+DTOC(MV_PAR01)+" ***")
	EndCase
EndDo

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ C730IMP  ³ Autor ³ Eriberto Elias      ³ Data ³ 16/05/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/
Static Function C730Imp(lEnd,WnRel,cString,TITULO)
Local _cFilial := xFilial("SF1")  
Local lFilTipo := .F. 
Local lTpImp   := .F.
//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
@ 0,0 psay AvalImp(Limite)


//DbSelectArea("SF1")
//DbSetOrder(6)
SF1->(DbOrderNickName("F1DIPR018")) // Utilizando DbOrderNickName ao invés de DbSetOrder  devido a virada de versão MCVN - 26/10/2007
SF1->(DbSeek(cFilial+DtoS(MV_PAR01),.T.))
li := 67  

If  Upper(U_DipUsr()) $ "MCANUTO/ERIBERTO/DDOMINGOS/RBORGES" 
	lFilTipo:= MsgBox("Filtra somente notas fiscais (NFE)?","Atencao","YESNO") 
Endif

// RBORGES - 01/01/2015 - Chamar a função para marcar as notas a serem inclusas no relatorio
lTpImp := MsgBox("GERAR RELATORIO POR NOTA FISCAL? ","ATENÇÃO","YESNO")
 
If lTpImp  
		  
	IF li > 66
		_CabecA(TITULO)
	Endif 
				
	U_NfeChkNF(MV_PAR01,MV_PAR02)
	
    _PE()
    
Else	
		
	While SF1->(!Eof()) .And. SF1->F1_FILIAL == _cFilial .And. MV_PAR01 == SF1->F1_DTDIGIT 
		If UPPER(SF1->F1_USUARIO) <> UPPER(MV_PAR02)
			SF1->(DBSKIP())
			Loop
		EndIf   
		
		If lFilTipo                                 
			If SF1->F1_ESPECIE <> 'NFE  '
				SF1->(DBSKIP())
				Loop
			EndIf
		EndIf   
		
	//	If SF1->F1_TIPO <> 'N'
	//		DBSKIP()
	//		Loop
	//	EndIf
			
		IF li > 66
			_CabecA(TITULO)
		Endif 
		
		_CorpO()
		
		nTotGer := nTotGer + SF1->F1_VALBRUT
		
	
		SF1->(DBSKIP())
	Enddo                  
	
		_PE()

EndIf


If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ CabecA ³ Autor ³ Eriberto Elias      ³ Data ³ 14.05.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
*/
Static Function _CabecA(_titulo)

li := 0

@ li,000 psay Replicate("-",LIMITE-30)
li++
//@ li,000 psay "DIPROMED COMERCIO E IMPORTACAO LTDA."+SPACE(10)+'Digitados por: '+AllTrim(UPPER(MV_PAR02))
@ li,000 psay ALLTRIM(SM0->M0_NOMECOM)+if(cEmpAnt+cFilAnt=='0404',"(CD)","")+ SPACE(10)+'Digitados por: '+AllTrim(UPPER(MV_PAR02))+"      CNPJ: "+ALLTRIM(SM0->M0_CGC) // MCVN - 13/12/2009
@ li,limite-30 - Len(AllTrim(_titulo)) psay _titulo
li++
@ li,000 psay Replicate("-",LIMITE-30)
li++
li++
@ li,000 psay 'Fornecedor                                        Documento  Condicao de Pagamento                Valor   Estoques    Custos      Compras     Gerencia    Diretoria   Pagamentos Contabilidade'
li++
@ li,000 psay Replicate("-",LIMITE-30)
li++

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ Corpo ³ Autor ³ Eriberto Elias         ³ Data ³ 14.05.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
*/
Static Function _CorpO()
*                                                                                                   1                                                                                                   2
*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
*1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*Fornecedor                                        Documento  Condicao de Pagamento                Valor   Estoque     Gerencia    Compras     Diretor     Pagamentos Contabilidade
*99999-99 X234567890123456789012345678901234567890  123456    X234567890123456789012345  999.999.999,99  |           |           |           |           |           |           |

_vencimentos := ''
dbSelectArea("SE2")
dbSetOrder(6)
If dbSeek(xFilial('SE2')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC)
	Do While !Eof() .and. xFilial('SE2')+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC == ;
	                       SE2->E2_Filial+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM
        If SE2->E2_TIPO = 'NF' // mcvn - 29/04/09
	    	_vencimentos := _vencimentos + DtoC(SE2->E2_VENCREA)+'  '
    	Endif
		dbSkip()
	EndDo
Else
	_vencimentos := 'Nao achei os titulos no financeiro'
EndIf
                             
// mcvn - 29/04/09
If Empty(_vencimentos)
	_vencimentos := 'Nao achei os titulos no financeiro'
Endif
@ li,000 psay SF1->F1_FORNECE+'-'+SF1->F1_LOJA+'  '+Iif(SF1->F1_TIPO $ 'BD',Subs(;
              POSICIONE("SA1",1,xFilial("SA1") + SF1->F1_FORNECE+SF1->F1_LOJA,"A1_NOME"),1,40),;
              Posicione("SA2",1,xFilial("SA2") + SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME"))

@ li,051 psay SF1->F1_DOC
@ li,061 psay Posicione('SE4',1,xFilial("SE4")+SF1->F1_COND,"E4_DESCRI")
@ li,089 psay SF1->F1_VALBRUT picture "@E 999,999,999.99"
@ li,105 psay '|           |           |           |           |           |           |           |'
li++
_vencimentos := Iif(Len(AllTrim(_vencimentos))<=10,'Vencimento: ','Vencimentos: ')+ AllTrim(_vencimentos)
@ li,081-Len(_vencimentos) psay _vencimentos
@ li,105 psay '|           |           |           |           |           |           |           |'
li++
@ li,000 psay Replicate("-",LIMITE-30)
li++

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ PE    ³ Autor ³ Eriberto Elias         ³ Data ³ 14.05.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
*/
Static Function _PE()

@ li,000 psay Replicate("-",LIMITE-30)
li++
@ li,078 psay 'Total....:'
@ li,089 psay nTotGer picture "@E 999,999,999.99"
li++
@ li,000 psay Replicate("-",LIMITE-30)

@ 65,000 psay 'Impresso em '+DtoC(DATE())+' as '+TIME()

Return       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ CFINIMP  ³ Autor ³ Maximo Canuto       ³ Data ³ 25/08/2008 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
*/
Static Function CFinImp(lEnd,WnRel,cString,TITULO)
Local _cFilial  := xFilial("SE2")   
Local _aFaturas := {}

//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
@ 0,0 psay AvalImp(Limite)            
_vencimentos := '' 
 


SE2->(dbSetOrder(7))
SE2->(DbSeek(cFilial+DtoS(MV_PAR01),.T.))
li := 67
While SE2->(!Eof()) .And. SE2->E2_FILIAL == _cFilial .And. MV_PAR01 == SE2->E2_EMIS1
	If UPPER(SE2->E2_USUARIO) <> UPPER(MV_PAR02) .Or. SE2->E2_TIPO <> "FT"   // Incluído tratamento para títulos baixados e tipo do título - MCVN 01/09/2008
		SE2->(DBSKIP())
		Loop
	EndIf
    If Len(_afaturas) == 0
	  	Aadd(_aFaturas, { SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_FORNECE, SE2->E2_LOJA, DTOC(SE2->E2_EMIS1), SE2->E2_VALOR, SE2->E2_CONDPAG, Dtoc(SE2->E2_VENCREA) } )			
	Else
		If aScan(_aFaturas, { |x| x[1]+x[2]+x[3]+x[4]+x[5] == SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_FORNECE+SE2->E2_LOJA+DTOC(SE2->E2_EMIS1)}) = 0
		  	Aadd(_aFaturas, { SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_FORNECE, SE2->E2_LOJA, DTOC(SE2->E2_EMIS1), SE2->E2_VALOR, SE2->E2_CONDPAG, Dtoc(SE2->E2_VENCREA) } )
		Else
			_aFaturas[aScan(_aFaturas, { |x| x[1]+x[2]+x[3]+x[4]+x[5] == SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_FORNECE+SE2->E2_LOJA+DTOC(SE2->E2_EMIS1)}),6] += SE2->E2_VALOR
			_aFaturas[aScan(_aFaturas, { |x| x[1]+x[2]+x[3]+x[4]+x[5] == SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_FORNECE+SE2->E2_LOJA+DTOC(SE2->E2_EMIS1)}),8] := ;
			_aFaturas[aScan(_aFaturas, { |x| x[1]+x[2]+x[3]+x[4]+x[5] == SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_FORNECE+SE2->E2_LOJA+DTOC(SE2->E2_EMIS1)}),8]+" - "+Dtoc(SE2->E2_VENCREA)
		Endif   
	Endif

	nTotGer := nTotGer + SE2->E2_VALOR		

	SE2->(DBSKIP())
Enddo              

	IF li > 66
		_CabecA(TITULO)
	Endif
	
    For count:=1 to Len(_afaturas)
	    
	    @ li,000 psay _aFaturas[count,3]+'-'+_aFaturas[count,4]+'  '+Posicione("SA2",1,xFilial("SA2") + _aFaturas[count,3]+_aFaturas[count,4],"A2_NOME")
		@ li,051 psay _aFaturas[count,2]
		@ li,061 psay Posicione('SE4',1,xFilial("SE4")+ _aFaturas[count,7],"E4_DESCRI")
		@ li,089 psay _aFaturas[count,6] picture "@E 999,999,999.99"
		@ li,105 psay '|           |           |           |           |           |           |           |'
		li++
		@ li,061 psay "Vencimentos: "+_aFaturas[count,8]
		@ li,105 psay '|           |           |           |           |           |           |           |'
		li++
		@ li,000 psay Replicate("-",LIMITE-30)
		li++
    Next count


_PE()

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()

Return

/*-------------------------------------------------------------------------
+ RBORGES - 01/07/2015 ----- User Funcion: NfeChkNF()                     +                                                     
+ Carregará as notas fiscais de entrada de acordo com os parâmetros       +
+ informados pelo usuário, o qual marcará quais nota quer gerar relatório +
-------------------------------------------------------------------------*/

*---------------------------------------------*
User Function NfeChkNF(MV_PAR01,MV_PAR02) 
*---------------------------------------------*
Local oDlg                                    
Local nOpcao    := 0   
Local lRetorno  := .T.
Local lMarcados := .F.  
Private nI      := 0
Private cFilSF1 :=SF1->(xFilial("SF1"))
Private cFilSF2 :=SF2->(xFilial("SF2"))
Private aNfsJaImp:= {}
Private cUserImp := Upper(GetNewPar("ES_FORIMP","RBORGES/BFERREIRA/SCREATTO"))
Private _cUser   := Upper(U_DipUsr()) 


Private aCposSF := {}

limpressao    := .F.

AADD(ACPOSSF,{"WKFLAG"    ,,""                   })
AADD(ACPOSSF,{"F1_DOC"    ,,AVSX3("F1_DOC"    ,5)})
AADD(ACPOSSF,{"F1_SERIE"  ,,AVSX3("F1_SERIE"  ,5)})
AADD(ACPOSSF,{"WKTIPO"    ,,"Tipo de NF"         })
AADD(ACPOSSF,{"F1_FORNECE" ,,AVSX3("F1_FORNECE" ,5)})
AADD(ACPOSSF,{"F1_LOJA",,AVSX3("F1_LOJA",5)})

Processa({|| NFFatEntrada(MV_PAR01,MV_PAR02)},"Filtrando notas de Entrada")

If len(aNfsJaImp)>0
	//-----------------------------------------------------------
	//  Coloca as Nota de Entrada em ordem crescente.
	//-----------------------------------------------------------
	aSort(aNfsJaImp,,,{ |x,y| x[1] < y[1] } )
	
	lInverte := .F.
	cMarca   := GetMark()
	aHeader  := {}
	
	aCampos  := {} //Array(SF1->(FCount()))
	cFileWork:= E_CriaTrab(,{;
	{"WKFLAG"    , "C" ,2,0},;
	{"F1_DOC"    , "C" ,avsx3("F1_DOC"    ,3),0},;
	{"F1_SERIE"  , "C" ,avsx3("F1_SERIE"  ,3),0},;
	{"F1_FORNECE", "C" ,avsx3("F1_FORNECE" ,3),0},;
	{"F1_LOJA"   , "C" ,avsx3("F1_LOJA",3),0},;
	{"WKTIPO"    , "C" ,7,0},;
	{"WKPOS"     , "N" ,5,0}},"Work_NF",)
	
	IndRegua("Work_NF",cFileWork,"F1_DOC+F1_SERIE")
	cNFOutrasI:= ""
	cNFOutrasF:= ""
	For x=1 to len(aNfsJaImp)
			Work_NF->(DbAppend())
			Work_NF->F1_DOC     := aNfsJaImp[x,1]
			Work_NF->F1_SERIE	:= aNfsJaImp[x,2]
			Work_NF->F1_FORNECE := aNfsJaImp[x,3]
			Work_NF->F1_LOJA    := aNfsJaImp[x,5]
			Work_NF->WKFLAG     := Space(02)
			Work_NF->WKPOS      := X
			Work_NF->WKTIPO     := aNfsJaImp[x,6]
	Next
	
	Do While !Work_NF->(Bof().and.Eof())
		Work_NF->(DbGoTop())
		
		nI:=0
		
		Define msDialog oDlg Title "Documentos de Entrada " From 10,10 TO 44,85
		@ 11,02 to 61,295
		
	  	@ 020,005 BUTTON "Imprimir Documento(s) Marcado(s)" SIZE 200,15 ACTION (nOpcao:=2,oDlg:End())
	  	@ 040,005 BUTTON "Cancelar "                        SIZE 200,15 ACTION (nOpcao:=1,oDlg:End())	  	
			  	
		oMark:=MsSelect():New("Work_NF","WKFLAG",,aCposSF,lInverte,@cMarca,{62,01,258,297})
		
		Activate Dialog oDlg Centered 
				
		Do Case

			Case nOpcao==1
				Exit
			Case nOpcao==2 
				Work_NF->(DbGoTop())
				Do While Work_NF->(!EOF())
					nI++
					If Work_NF->WKFLAG # Space(02)
					
		   				If _cUser $ cUserImp
		   				
		   					If MsgYesNo("Gerar relatórios com Impostos?")
		   						_CorpONFb(aNfsJaImp[nI,3],aNfsJaImp[nI,5],aNfsJaImp[nI,1],aNfsJaImp[nI,2])
		   					Else
		   						_CorpONF(aNfsJaImp[nI,3],aNfsJaImp[nI,5],aNfsJaImp[nI,1],aNfsJaImp[nI,2])
		   					EndIf
			   				 
			   			Else
			   			
		   					_CorpONF(aNfsJaImp[nI,3],aNfsJaImp[nI,5],aNfsJaImp[nI,1],aNfsJaImp[nI,2])
		   				
		   				EndIf
		   				
						lMarcados := .T.
					EndIf
					Work_NF->(DbSkip())
				EndDo
				If !lMarcados
					msginfo(;
					"Nenhuma nota fiscal foi  selecionada  pelo usuario!"+f_linha+f_linha+;
					"Para executar esta operação marque as notas fiscais"+f_linha+;
					"para as quais será executada esta operação!","Atenção")
				Else
					Exit
				EndIf
		EndCase
	EndDo

	Work_NF->(E_EraseArq(cFileWork))
EndIf
Return(lRetorno)


/*-------------------------------------------------------------------------
+ RBORGES - 01/07/2015 ----- User Funcion: NFFatEntrada()                 +                                                     
+ Seleciona as notas fiscais de entrada de acordo com os parâmetros       +
+ informados pelo usuário.                                                +
-------------------------------------------------------------------------*/

*-----------------------------------------------*
Static Function NFFatEntrada()
*-----------------------------------------------*
Local lRetorno := .F.

ProcRegua(SF1->(Reccount()))
SF1->(DbSetOrder(9))
SF1->(dbSeek(cFilSF1+DTOS(MV_PAR01),.t.))

Do While SF1->(!eof()) .and. cFilSF1 == SF1->F1_FILIAL .and. SF1->F1_DTDIGIT == MV_PAR01
	
	Incproc("Verificando NF: "+SF1->F1_DOC+"-"+SF1->F1_SERIE )
	
	If UPPER(SF1->F1_USUARIO) <> UPPER(MV_PAR02)
		SF1->(DbSkip())                                                                      
		Loop
	EndIf
	
	lRetorno := .T.
	AADD(aNfsJaImp, {SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,,SF1->F1_LOJA,"Entrada",SF1->(Recno())})
	
	SF1->(DbSkip())
	
EndDo
Return(lRetorno)


/*-------------------------------------------------------------------------
+ RBORGES - 01/07/2015 ----- User Funcion: _CorpONF()                     +                                                     
+ Função chamada pela NfeChkNF() para montar o corpo do relatório.        +
-------------------------------------------------------------------------*/

Static Function _CorpONF(_cFornec,_cLjFor,_cNotaF,_cSerie)
*                                                                                                   1                                                                                                   2
*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
*1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*Fornecedor                                        Documento  Condicao de Pagamento                Valor   Estoque     Gerencia    Compras     Diretor     Pagamentos Contabilidade
*99999-99 X234567890123456789012345678901234567890  123456    X234567890123456789012345  999.999.999,99  |           |           |           |           |           |           |


dbSelectArea("SF1")
dbSetOrder(1)
dbSeek(xFilial('SF1')+_cNotaF+_cSerie+_cFornec+_cLjFor)

_vencimentos := ''
dbSelectArea("SE2")
dbSetOrder(6)
If dbSeek(xFilial('SE2')+_cFornec+_cLjFor+_cSerie+_cNotaF)
	Do While !Eof() .and. xFilial('SE2')+_cFornec+_cLjFor+_cSerie+_cNotaF == ;
	                       SE2->E2_Filial+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM
        If SE2->E2_TIPO = 'NF' 
	    	_vencimentos := _vencimentos + DtoC(SE2->E2_VENCREA)+'  '
    	Endif
		dbSkip()
	EndDo
Else
	_vencimentos := 'Nao achei os titulos no financeiro'
EndIf
                             
If Empty(_vencimentos)
	_vencimentos := 'Nao achei os titulos no financeiro'
Endif
@ li,000 psay SF1->F1_FORNECE+'-'+SF1->F1_LOJA+'  '+Iif(SF1->F1_TIPO $ 'BD',Subs(;
              POSICIONE("SA1",1,xFilial("SA1") + SF1->F1_FORNECE+SF1->F1_LOJA,"A1_NOME"),1,40),;
              Posicione("SA2",1,xFilial("SA2") + SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME"))

@ li,051 psay SF1->F1_DOC
@ li,061 psay Posicione('SE4',1,xFilial("SE4")+SF1->F1_COND,"E4_DESCRI")
@ li,089 psay SF1->F1_VALBRUT picture "@E 999,999,999.99"
@ li,105 psay '|           |           |           |           |           |           |           |'
li++
_vencimentos := Iif(Len(AllTrim(_vencimentos))<=10,'Vencimento: ','Vencimentos: ')+ AllTrim(_vencimentos)
@ li,081-Len(_vencimentos) psay _vencimentos
@ li,105 psay '|           |           |           |           |           |           |           |'
li++
@ li,000 psay Replicate("-",LIMITE-30)
li++

nTotGer := nTotGer + SF1->F1_VALBRUT

Return


/*-------------------------------------------------------------------------
+ RBORGES - 14/02/2018 ----- User Funcion: _CorpONFb()                    +                                                     
+ Função chamada pela NfeChkNF() para montar o corpo do relatório.        +
-------------------------------------------------------------------------*/

Static Function _CorpONFb(_cFornec,_cLjFor,_cNotaF,_cSerie)

Local cForImp := GetNewPar("ES_FORIMP","UNIAO")
*                                                                                                   1                                                                                                   2
*         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1         2
*1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*Fornecedor                                        Documento  Condicao de Pagamento                Valor   Estoque     Gerencia    Compras     Diretor     Pagamentos Contabilidade
*99999-99 X234567890123456789012345678901234567890  123456    X234567890123456789012345  999.999.999,99  |           |           |           |           |           |           |

dbSelectArea("SF1")
dbSetOrder(1)
dbSeek(xFilial('SF1')+_cNotaF+_cSerie+_cFornec+_cLjFor)

_vencimentos := ''
dbSelectArea("SE2")
dbSetOrder(1)
If dbSeek(xFilial('SE2')+_cSerie+_cNotaF)

	Do While !SE2->(Eof()) .and. xFilial('SE2')+_cSerie+_cNotaF == xFilial('SE2')+SE2->E2_PREFIXO+SE2->E2_NUM  
    
    If xFilial('SE2')+_cSerie+_cNotaF == xFilial('SE2')+SE2->E2_PREFIXO+SE2->E2_NUM .And. _cFornec+_cLjFor <> SE2->E2_FORNECE+SE2->E2_LOJA .And. SE2->E2_FORNECE <> "UNIAO"
		SE2->(dbSkip())
	Else
        
        _vencimentos := DtoC(SE2->E2_VENCREA)
        
	    @ li,000 psay SE2->E2_FORNECE+'-'+SE2->E2_LOJA+'  '+Substr(POSICIONE("SA2",1,xFilial("SA2") + SE2->E2_FORNECE+SE2->E2_LOJA,"A2_NOME"),1,40)
		@ li,051 psay SE2->E2_NUM
		@ li,061 psay Posicione('SE4',1,xFilial("SE4")+SF1->F1_COND,"E4_DESCRI")
		@ li,089 psay SE2->E2_VALOR picture "@E 999,999,999.99"
		@ li,105 psay '|           |           |           |           |           |           |           |'
		li++
		_vencimentos := 'Vencimento: '+ AllTrim(_vencimentos)
		@ li,081-Len(_vencimentos) psay _vencimentos
		@ li,105 psay '|           |           |           |           |           |           |           |'
		li++
		@ li,000 psay Replicate("-",LIMITE-30)
		li++

		nTotGer := nTotGer + SE2->E2_VALOR
	    	        	
		SE2->(dbSkip())
	EndIf
	EndDo
	
Else
	_vencimentos := 'Nao achei os titulos no financeiro'
EndIf
                             
If Empty(_vencimentos)
	_vencimentos := 'Nao achei os titulos no financeiro'
Endif


Return