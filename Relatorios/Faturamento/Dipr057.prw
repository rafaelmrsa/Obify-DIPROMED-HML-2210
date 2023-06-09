/*                                                              Sao Paulo,  26 Ago 2005
---------------------------------------------------------------------------------------

Empresa.......: DIPROMED Com�rcio e Importa��o Ltda.
Programa......: DIPR057.PRW

Objetivo......: Relatorio de Conferencia de sequencia de Formularios e Notas Fiscais.

Autor.........: Jailton B Santos, JBS 
Data..........: 26 Ago Out 2005 
Vers�o........: 1.0 

Considera�oes.: Fun��o chamada direto do menu DIPRFAT.MNU
                                                                                      
Remodela��o...: Com o uso da Nota fiscal  eletr�nica, deixa de existir o controle de 
                formularios, continua a conferencia do numero de notas fiscais.
                Impress�o da chave de autentica��o do Sefaz e Controle de Impress�o
                 
Data..........: 28 Abr 2010 
Vers�o........: 2.0

---------------------------------------------------------------------------------------
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "DIPR057.CH" 
  
#Define CHVNFE   07
#Define IMPSN    08
#Define HORAD    09
#Define SITUACAO 10
*----------------------------------------------*
User Function Dipr057()
// Dipromed Relatorio de Divergencia F3, F2 e F1.
*----------------------------------------------*
Local bOk:={||IF(E_Periodo_Ok(@dDtI,@dDtF).and.!empty(cSerie),(nOpcao:=1,oDlg:End()),)} 
Local oDlg
Local _xArea:=GetArea()
Local nHandle:=""
Local cWorkFlow:="N"
Local nRecords:=0
Local aDados:={}
Local oBt1
Local oBt2
Local lQry1
Local lWork
Local nOpcao:=0
Local x
Private aReturn:={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private nLastKey:=0
Private lEnd:=.f.
Private aRCampos:={}
Private aStru:={}
Private cArqWork
Private cMes
Private cAno
Private cSerie
Private lNaoMostrar:=.f.
Private nRadio:=2
Private cIndex
Private QRY1
Private nQuery:=0
Private aQuery:={}
Private dDtI:=cTod("")
Private dDtF:=cTod("")
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
//-----------------------------
// Configura��es do Relatorio
//-----------------------------
aAdd(aDados,"WORK") 
aAdd(aDados,OemTOAnsi("Conferencia de DANFES e Notas Fiscais",72))    // 02
aAdd(aDados,OemToAnsi("Apurar incoerencias entre Emiss�o de Notas e Livros Fiscais",72))// 03
aAdd(aDados,OemToAnsi("Controlando numero sequencial de Notas e DANFES",72))       // 04
aAdd(aDados,"G")              // 05
aAdd(aDados,200)              // 06
aAdd(aDados,"")               // 07
aAdd(aDados,"")               // 08
aAdd(aDados,OemTOAnsi("Conferencia de DANFES e Notas Fiscais",72))
aAdd(aDados,aReturn)          // 10
aAdd(aDados,"DIPR057")        // 11
aAdd(aDados,{{||.t.},{||.t.}})// 12
aAdd(aDados,Nil)              // 13
//------------------------
// Estrutura para a Work
//------------------------
aAdd(aStru,{"WK_TIPONF" ,"C",10,0})
aAdd(aStru,{"F3_NFISCAL",AvSx3("F3_NFISCAL",2),AvSx3("F3_NFISCAL",3),AvSx3("F3_NFISCAL",4)})
aAdd(aStru,{"F3_SERIE"  ,AvSx3("F3_SERIE"  ,2),AvSx3("F3_SERIE"  ,3),AvSx3("F3_SERIE"  ,4)})
aAdd(aStru,{"F3_ENTRADA",AvSx3("F3_ENTRADA",2),AvSx3("F3_ENTRADA",3),AvSx3("F3_ENTRADA",4)})
aAdd(aStru,{"F3_OBSERV" ,AvSx3("F3_OBSERV" ,2),AvSx3("F3_OBSERV" ,3),AvSx3("F3_OBSERV" ,4)})
aAdd(aStru,{"F3_FORMUL" ,AvSx3("F3_FORMUL" ,2),AvSx3("F3_FORMUL" ,3),AvSx3("F3_FORMUL" ,4)})
aAdd(aStru,{"F1_HORA"   ,AvSx3("F1_HORA"   ,2),AvSx3("F1_HORA"   ,3),AvSx3("F1_HORA"   ,4)})
aAdd(aStru,{"F1_CHVNFE" ,AvSx3("F1_CHVNFE" ,2),AvSx3("F1_CHVNFE" ,3),AvSx3("F1_CHVNFE" ,4)})
aAdd(aStru,{"F1_FIMP"   ,"C",22,0})
//aAdd(aStru,{"F1_FIMP",AvSx3("F1_FIMP",2),AvSx3("F1_FIMP",3),AvSx3("F1_FIMP",4)})
aAdd(aStru,{"WK_OBS"    ,"C",30,0})
//------------------------
// Parametros do usuario
//------------------------
dDtI:=dDataBase
dDtF:=dDataBase
cSerie:=Space(3)

SX1->(DipPergDiverg(.t.)) // Verifica se existe o no SX1 o "DIP057". Retorna os Valores ou cria

Define msDialog oDlg title OemToAnsi("Conferencia de Formularios e Notas") From 10,10 TO 23,45

@ 002,002 to 083,137 pixel

@ 010,010 say "Data Inicial " Pixel
@ 022,010 say "Data Final   " Pixel
@ 034,010 say "Serie da Nota" Pixel

@ 010,080 get dDtI   valid !Empty(dDtI) Size 40,08 pixel
@ 022,080 get dDtF   valid !Empty(dDtF).and.E_Periodo_Ok(@dDtI,@dDtF) Size 40,08 pixel
@ 034,080 get cSerie valid !empty(cSerie) Size 20,08 pixel
//@ 050,010 radio oRadio var nRadio Items OemToAnsi("Sequ�ncia de Formulario"),OemToAnsi("Sequ�ncia de Nota Fiscal") 3D SIZE 120,08 OF oDlg PIXEL
@ 070,010 checkbox oMostrar var lNaoMostrar PROMPT "Mostrar apenas os DANFE's n�o encontrados" size 110,008 of oDlg

Define sbutton oBt1 from 085,074 type 1 action Eval(bOK) enable of oDlg
Define sbutton oBt2 from 085,108 type 2 action (nOpcao := 0, oDlg:End()) enable of oDlg

Activate Dialog oDlg Centered

If nOpcao = 0
	Return(.t.)
EndIf
aDados[07] := "Periodo de "+Dtoc(dDti)+" a "+Dtoc(dDtF)+ ".  Por "+If(nRadio=1,"Formularios","Notas Fiscais")
aDados[02]:=aDados[09]:=OemTOAnsi("Conferencia de Notas Fiscais",72)
aDados[08]:=If(lNaoMostrar,"Apenas as Notas Fiscais N�o encontradas","Mostrar todas as Notas Ficais do periodo")
//---------------------
// LayOut do Relatorio
//---------------------
AAdd(aRCampos,{"WK_TIPONF"  ,"","Tipo de NF","@!"})

aAdd(aRCampos,{"F3_NFISCAL" ,"",AvSx3("F3_NFISCAL",5),AvSx3("F3_NFISCAL",6)})
aAdd(aRCampos,{"F3_SERIE"   ,"",AvSx3("F3_SERIE",5)  ,AvSx3("F3_SERIE"  ,6)})
//    aAdd(aRCampos,{"WK_OBS"     ,"","PROBLEMA"           ,AvSx3("F3_OBSERV" ,6)})
aAdd(aRCampos,{"F3_OBSERV"  ,"",AvSx3("F3_OBSERV",5) ,AvSx3("F3_OBSERV" ,6)})
aAdd(aRCampos,{"F3_ENTRADA" ,"",AvSx3("F3_ENTRADA",5),AvSx3("F3_ENTRADA",6)})
//aAdd(aRCampos,{"F3_FORMUL"  ,"",AvSx3("F3_FORMUL",5) ,AvSx3("F3_FORMUL" ,6)})
aAdd(aRCampos,{"F1_CHVNFE"  ,"",AvSx3("F1_CHVNFE",5) ,AvSx3("F1_CHVNFE" ,6)})
aAdd(aRCampos,{{||Work->F1_FIMP+If(upper(alltrim(WORK->F1_HORA)) $ "ERA VAI", Space(5)+WORK->F1_HORA,"")}  ,"","S T A T U S  A T U A L"})

aRCampos:=E_CriaRCampos(aRCampos)

//---------------------------------------------------------//
// Registra no SX1 a altera��o dos parametros do pergunte. //
//-------------------------------------------------------- //
SX1->(DipPergDiverg(.f.))

//--------------------------------
// Gera a Query com parametros
//--------------------------------
Processa({|| lQry1 := DIPR57FilQuery()},"Filtrando as Notas fiscais...",,.t.)

If !lQry1
	MsgInfo(;
	"N�o encontrado dados que satisfa�am aos"+ENTER+;
	"parametros informados pelo usuario! ","Aten��o")
	QRY1->(dbCloseArea())
	Return(.t.)
EndIf            
//--------------------------------
// Achando os forms cancelados
//--------------------------------
Processa({|| DIPR57Cancelados()},"Verificando Formularios Cancelados...",,.t.)

//--------------------------------
// Grava os dados da Query na Work
//--------------------------------
Processa({|| lWork := DIPR57GrvWork()},"Gravando o Arquivo Temporario...",,.t.)

//--------------------------------
// Gera o Retlatorio
//--------------------------------
aReturn	:= {"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
aDados[10]:=aReturn 
Work->(dbGotop())
Work->(E_Report(aDados,aRCampos))
//--------------------------------
// Fecha a query
//--------------------------------
QRY1->(dbCloseArea())
Work->(dbCloseArea())

//--------------------------------
//Elimina os arquivos temporarios
//--------------------------------
FERASE(cArqWork+".dbf")
FERASE(cIndex+ordbagext())

RETURN(.t.)  
*----------------------------------*
STATIC FUNCTION DIPR57FilQuery()
*----------------------------------*
Local x
Local _x
ProcRegua(500)

For x := 1 to 250
	IncProc( "Selecionando dados ")
Next

/*SELECT DISTINCT F3_FILIAL, SUBSTRING(F3_ENTRADA,7,2)+'/'+SUBSTRING(F3_ENTRADA,5,2)+'/'+SUBSTRING(F3_ENTRADA,1,4) F3_ENTRADA, F3_SERIE, F3_NFISCAL, F3_FORMUL, F2_HORANOT, F1_HORA, F3_OBSERV, F2_CHVNFE, F1_CHVNFE, F2_FIMP, F1_FIMP
FROM SF3010, SF2010, SF1010
WHERE F3_FILIAL = '04'
  AND F2_FILIAL = '04'
  AND F1_FILIAL = '04'
  AND SF3010.D_E_L_E_T_ <> '*'
  AND F3_ENTRADA  BETWEEN '20051208' AND '20051208'
  AND F2_EMISSAO  BETWEEN '20051208' AND '20051208'
  AND F1_DTDIGIT  BETWEEN '20051208' AND '20051208' 
  AND (LEFT(F3_CFO,1) > '4' OR F3_FORMUL = 'S')
  AND F3_SERIE = '1'
  AND F3_NFISCAL (*LEFT JOIN) F2_DOC
  AND F3_SERIE   (*LEFT JOIN) F2_SERIE
  AND F3_NFISCAL (*LEFT JOIN) F1_DOC
  AND F3_SERIE   (*LEFT JOIN) F1_SERIE
  AND F3_FORMUL  (*LEFT JOIN) F1_FORMUL
ORDER BY F3_SERIE, F3_NFISCAL

*/                                                                                
QRY1 := " SELECT DISTINCT F3_FILIAL, SUBSTRING(F3_ENTRADA,7,2)+'/'+SUBSTRING(F3_ENTRADA,5,2)+'/'+SUBSTRING(F3_ENTRADA,1,4) F3_ENTRADA, F3_SERIE, F3_NFISCAL, F3_FORMUL, F2_HORANOT, F1_HORA, F3_OBSERV, F2_CHVNFE, F1_CHVNFE, F2_FIMP, F1_FIMP"
QRY1 += " FROM " + RetSQLName("SF3") + " SF3 with (nolock) "

QRY1 += " left join " + RetSQLName("SF2") + " SF2 with (nolock) ON "
QRY1 += "   F2_FILIAL  = '" + xFilial('SF2') + "' "
QRY1 += "   AND F2_EMISSAO  BETWEEN '"+dtos(dDti)+"' AND '"+dtos(dDtF)+"' " 
QRY1 += "   AND F3_NFISCAL = F2_DOC"
QRY1 += "   AND F3_SERIE   = F2_SERIE"

QRY1 += " left join " + RetSQLName("SF1") + " SF1 with (nolock) ON "
QRY1 += "   F1_FILIAL = '" + xFilial('SF1') + "'"
QRY1 += "   AND F1_DTDIGIT  BETWEEN '"+dtos(dDti)+"' AND '"+dtos(dDtF)+"' " 
QRY1 += "   AND F3_NFISCAL = F1_DOC"
QRY1 += "   AND F3_SERIE   = F1_SERIE"
QRY1 += "   AND F3_FORMUL  = F1_FORMUL"

QRY1 += " WHERE SF3.D_E_L_E_T_ <> '*' "
QRY1 += "   AND F3_FILIAL = '" + xFilial('SF3') + "'"
QRY1 += "   AND F3_ENTRADA  BETWEEN '"+dtos(dDti)+"' AND '"+dtos(dDtF)+"' " 
QRY1 += "   AND (LEFT(F3_CFO,1) > '4' OR F3_FORMUL = 'S')"
QRY1 += "   AND F3_SERIE = '"+cSerie+"'"
QRY1 += " ORDER BY F3_SERIE, F3_NFISCAL "

TcQuery QRY1 NEW ALIAS "QRY1" // Abre uma workarea com o resultado da query

DbSelectArea("QRY1")
QRY1->(dbGotop())

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Classificando... ")
Next

Return(!QRY1->(BOF().and.EOF()))

*----------------------------------*
STATIC FUNCTION DIPR57CriaWork()
*----------------------------------*
cArqWork:=E_CriaTrab(,aStru,"Work")
cIndex := Criatrab(Nil,.f.)
If nRadio = 1
	Indregua("Work",cIndex,"F1_CHVNFE+F3_NFISCAL",,,"Criando indices Temporarios")
Else
	Indregua("Work",cIndex,"F3_NFISCAL+F1_CHVNFE",,,"Criando indices Temporarios")
EndIf

RETURN(.t.)
*----------------------------------*
STATIC FUNCTION DIPR57Cancelados()
// Apura os Formularios Cancelados
*----------------------------------*
Local nCount := 200
Local bImp   := {|x| Iif(AllTrim(x)= 'S',Iif(!Empty(Iif(QRY1->F3_FORMUL ='S',QRY1->F1_CHVNFE ,QRY1->F2_CHVNFE)),'Impresso','Autorizada'),Iif(AllTrim(x) = 'T','Transmitida',Iif(AllTrim(x) = 'N','N�o Autorizada','N�o Transmitida')))}

aQuery    := {}
nQuery    := 0

QRY1->(dbGotop())
Procregua(nCount)

Do While QRY1->(!EOF())
	
	IncProc("Pesquisando nota fiscal " + QRY1->F3_NFISCAL)
	
	nCount--
	nQuery++
	
	If nCount<0
		nCount:= 200
		Procregua(nCount)
	EndIf
	
	aAdd(aQuery,{Padc(Iif(QRY1->F3_FORMUL='S',"Entrada","Saida"),10),;    // 01
	             QRY1->F3_NFISCAL,;                   // 02
	             QRY1->F3_SERIE,;                     // 03
	             cTod(QRY1->F3_ENTRADA),;             // 04
	             QRY1->F3_FORMUL,;                    // 05
	             QRY1->F3_OBSERV,;                    // 06
	             Iif(QRY1->F3_FORMUL ='S',QRY1->F1_CHVNFE ,QRY1->F2_CHVNFE),;       // 07  Chave de Autoriza��o 
	             Padc(Iif(QRY1->F3_FORMUL='S',Eval(bImp,QRY1->F1_FIMP) ,Eval(bImp,QRY1->F2_FIMP)),22),; // 08 Descri��o do Status
	             Iif(QRY1->F3_FORMUL ='S',QRY1->F1_HORA   ,QRY1->F2_HORANOT),;      // 09
	             Iif(QRY1->F3_FORMUL ='S',QRY1->F1_FIMP   ,QRY1->F2_FIMP)})         // 10 Status
	
	QRY1->(dbSkip())
	
EndDo
RETURN(.t.)       

*----------------------------------*
STATIC FUNCTION DIPR57GrvWork()
*----------------------------------*
Local nNFi      := Val(aQuery[01,NFISCAL])
Local nNFGrv    := Val(aQuery[01,NFISCAL])
Local nQtdNFs   := 0
Local nQ
Local i

DIPR57CriaWork() // Cria o arquivo temporario

Procregua(nQuery)

Asort(aQuery,,,{|x,y| x[2] < y[2] }) // Ondena a Array por Nota Fiscal

For nQ := 1 to len(aQuery)
	
	IncProc("Determinando Danfe . NF " + aQuery[nq,NFISCAL])
	
	//-----------------------------------------------------
	// Determina se existem formaularios fora da sequencia
	//-----------------------------------------------------
	If !lNaoMostrar
		Work->((RecLock("Work",.T.)))
		Work->WK_TIPONF  := aQuery[nQ,TIPONF]
		Work->F3_NFISCAL := aQuery[nQ,NFISCAL]
		Work->F3_SERIE   := aQuery[nQ,SERIE]
		Work->F3_ENTRADA := aQuery[nQ,ENTRADA]
		Work->F3_FORMUL  := aQuery[nQ,FORMUL]
		Work->F3_OBSERV  := aQuery[nQ,OBSERV]
		Work->F1_CHVNFE  := aQuery[nQ,CHVNFE]
		Work->F1_FIMP    := aQuery[nQ,IMPSN]
		Work->F1_HORA    := aQuery[nQ,HORAD]
		Work->(MsUnlock("Work"))
	EndIf
	
	nNFi   := Val(aQuery[nQ,NFISCAL])
	nQtdNFs:= nNFi-nNFGrv
	
	If nQtdNFs > 0
		//------------------------------------------------------------------------------------
		// Determina o numero das notas fiscais n�o encontradas
		//------------------------------------------------------------------------------------
		For i:=nNFGrv to nNFi-1
			Work->((RecLock("Work",.T.)))
			//Work->F3_NFISCAL:= StrZero(i,6) ANTES
			Work->F3_NFISCAL:= StrZero(i,9)  // ALTERADO PARA novo tamanho do campo da NF
			// Work->WK_OBS    := "NOTA FISCAL N�O ENCONTRADA"
			Work->F1_FIMP   := Padc("NF N�o Encontrada",22)
			Work->(MsUnlock("Work"))
		Next
		
	Else 
		
//		If !lNaoMostrar   // Nao.NaoMostrar � igual a Mostrar, Nao com Nao = SIM.
//			Work->((RecLock("Work",.F.)))
//		Else
//			Work->((RecLock("Work",.T.)))
//			Work->WK_TIPONF  := aQuery[nQ,TIPONF]
//			Work->F3_NFISCAL := aQuery[nQ,NFISCAL]
//			Work->F3_SERIE   := aQuery[nQ,SERIE]
//			Work->F3_ENTRADA := aQuery[nQ,ENTRADA]
//			Work->F3_FORMUL  := aQuery[nQ,FORMUL]
//			Work->F3_OBSERV  := aQuery[nQ,OBSERV]
//			Work->F1_CHVNFE  := aQuery[nQ,CHVNFE]
//			Work->F1_FIMP    := aQuery[nQ,IMPSN]
//			Work->F1_HORA    := aQuery[nQ,HORAD]
//		EndIf
		
		//Work->WK_OBS := "NF Sem DANFE / NAO IMPRES"
//		Work->(MsUnlock("Work"))
		
	EndIf
	nNFGrv    := Val(aQuery[nQ,NFISCAL])+1
Next
Return(.t.)
*---------------------------------------*
Static Function DipPergDiverg(lLer)
// Registra altera��es no SX1
*---------------------------------------*
Local aRegs:={}
Local lIncluir
Local i,j 
SX1->(dbSetOrder(1))                                                       
aAdd(aRegs,{"DIP057    ","01","Data Inicial ?","","","MV_CH1","D",08,0,0,"G","","MV_PAR01","","","", "'"+dToc(dDtI)+"'","","","","","","","","","","",""})
aAdd(aRegs,{"DIP057    ","02","Data Final   ?","","","MV_CH2","D",08,0,0,"G","","MV_PAR02","","","", "'"+dToc(dDtF)+"'","","","","","","","","","","",""})
aAdd(aRegs,{"DIP057    ","03","Serie ?       ","","","MV_CH3","C",03,0,0,"G","","MV_PAR03","","","", cSerie            ,"","","","","","","","","","",""})
For i:=1 to len(aRegs)
	lIncluir:=!SX1->(dbSeek("DIP057    "+aRegs[i,2]))
	If !lIncluir.and.lLer
		aRegs[i,17]:=SX1->X1_CNT01
	EndIf
	SX1->(RecLock("SX1",lIncluir))
	For j:=1 to SX1->(FCount())
		If j <= len(aRegs[i])
			SX1->(FieldPut(j,aRegs[i,j]))
		Endif
	Next
	SX1->(MsUnlock("SX1"))
Next
dDtI:=cTod(StrTran(aRegs[1,17],"'",""))
dDtF:=cTod(StrTran(aRegs[2,17],"'",""))
cSerie:=Left(aRegs[3,17],aRegs[3,08])
Return(.t.)
