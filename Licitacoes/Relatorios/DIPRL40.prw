/*====================================================================================\
|Programa  | DIPRL40       | Autor | Maximo Canuto - MCVN       | Data | 09/02/2009   |
|=====================================================================================|
|Descri��o | Contratos em aberto e envio por e-mail WF        |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPRL40                                                                  |
|=====================================================================================|
|Uso       | Especifico DIPROMED                                                      |
|=====================================================================================|
|........................................Hist�rico....................................|
|Analista  | DD/MM/AA - Descri��o                                                     |  
\====================================================================================*/  

#include "rwmake.ch"                        
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#IFNDEF WINDOWS
	#DEFINE PSay Say
#ENDIF

User Function DIPRL40(aWork)
Local _xArea     := GetArea()
Local _xAreaUA1  := If(ValType(aWork) <> 'A',UA1->(GetArea()),"")
Local _xAreaUA4  := If(ValType(aWork) <> 'A',UA4->(GetArea()),"")



Private tamanho    := "G"
Private limite     := 220
Private _cTitulo   := "RELA��O DE CONTRATOS EM ABERTO"
Private _cDesc1    := ""
Private _cDesc2    := ""
//Private cDesc3   := (OemToAnsi("Ranking: 0 pelo Total, 1 a 12 pelo m�s ou 13 pela Media",72))
Private aReturn    := {"Bco A4", 1,"Faturamento", 1, 2, 1,"",1}
Private nomeprog   := "DIPRL40"
Private cPerg      := "DIRL40"
Private nLastKey   := 0
Private lContinua  := .T.
Private lEnd       := .F.
Private li         := 67
Private wnrel      := "DIPRL40"
Private M_PAG      := 1
Private cString    := "UA4"
Private cWorkFlow  := ""  
Private cFilSA3    := ""        
Private cDestino  := "C:\EXCELL-DBF\"

//Tratamento para workflow
If ValType(aWork) <> 'A'
	cWorkFlow := "N"
Else
	cWorkFlow := aWork[1]
EndIf

If cWorkFlow == "S"                        
	ConOut("Preparando empresa - Inicio")
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "04" FUNNAME "DIPRL40" 
	ConOut("Preparando empresa - Fim")
EndIf
// Somente depois que preparar o ambiente...
cFilSA3     := xFilial("SA3")
U_DIPPROC(ProcName(0),U_DipUsr()) 


If cWorkFlow == "N"
	
	AjustaSX1(cPerg)             // Verifica perguntas. Se nao existe INCLUI
	
	If !Pergunte(cPerg,.T.)
		Return     // Solicita parametros
    EndIf
	
	wnrel := SetPrint(cString,wnrel,cPerg,_cTitulo,_cDesc1,_cDesc2,"",.f.,,.f.,tamanho,,.f.,,,,,)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	Processa({|lEnd| RunProc()},"Processando...")
		
	Set device to Screen
	
	//���������������������������������������������������������������������������Ŀ
	//� Se em disco, desvia para Spool                                            �
	//�����������������������������������������������������������������������������
	If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		Commit
		ourspool(wnrel)
	Endif      
	
	dbSelectArea("QRY1")
	QRY1->(dbCloseArea())
	
	RestArea(_xAreaUA4)
	RestArea(_xAreaUA1)
	RestArea(_xArea)
Else
	/*==========================================================================\
	| Este relat�rio ser� executado via WORKFLOW todos os s�bados
	\==========================================================================*/
	MV_PAR01 := cTod('')
	MV_PAR02 := dDataBase
	MV_PAR03 := cTod('')
	MV_PAR04 := dDataBase
	MV_PAR05 := ''    
	MV_PAR06 := ''
	MV_PAR07 := ''
	MV_PAR08 := 'zzzzzz'
	MV_PAR09 := ''
	MV_PAR10 := 'zzzzzz'
	MV_PAR11 := ''    
	MV_PAR12 := 'zzzzzz'
	MV_PAR13 := ''
	MV_PAR14 := 'zzzzzz'
	MV_PAR15 := 2
	MV_PAR16 := 2
	MV_PAR17 := 2
	MV_PAR18 := ''
	MV_PAR19 := 'zzzzzz'
		
	Qry := " SELECT A3_COD"
	Qry += " FROM " + RetSQLName("SA3")
	Qry += " WHERE A3_DESLIG = ''"
	Qry += " AND A3_TIPO = 'E'"
	Qry += " AND A3_EMAIL <> ''"
	Qry += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
	Qry := ChangeQuery(Qry)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,Qry),"Qry",.F.,.T.)
	
	DbSelectArea("Qry")
	DbGoTop()
	While Qry->(!EOF())
		MV_PAR05 := QRY->A3_COD
		MV_PAR06 := QRY->A3_COD    
		ConOut("RUNPROC")
		RUNPROC()
		ConOut("RUNPROC - Fim")

		Qry->(DbSkip())
	EndDo
	Qry->(dbCloseArea())
	
		

RestArea(_xArea)
EndIf

Return

/*====================================================================================\
|PROCESSAMENTO DOS DADOS, CRIA��O DO ARQUIVO TEMPOR�RIO, CRIA��O DO DBF E ENVIO DO E-MAIL
\====================================================================================*/
Static Function RunProc()
                 
Local _xArea     := GetArea()
Local _xAreaSA1  := SA1->(GetArea())
Local _xAreaSB1  := SB1->(GetArea())
Local cEmail     := ""
Local cAssunto   := ""
Local aEnv_040   := {}  
Local _cCliente  := '' 
Local _cEdital   := '' 
Local _lPriReg   := .T.
Local _nTotCli   := 0
Local _nTotGer   := 0   
Local _nTotEdi   := 0 
Local cAssunto   := EncodeUTF8("Licita��o - Relat�rio "+If(MV_PAR16=2,"Anal�tico","Sint�tico")+" de Contratos em aberto  -  "+Alltrim(Posicione("SA3",1,xFilial("SA3")+MV_PAR05,"A3_NOME")),"cp1252")
Local cEmail     := Alltrim(Posicione("SA3",1,xFilial("SA3")+MV_PAR05,"A3_EMAIL"))
//Local cArqExcell := GetSrvProfString("STARTPATH","")+"Excell-DBF\"+U_DipUsr()+"-DIPRL40 - "+If(MV_PAR13=1,"Sint�tico","Anal�tico")
                                                                                                                                                   
// Alterado para gravar arquivos na pasta protheus_data - Por Sandro em 19/11/09. 
Local cArqExcell := "\Excell-DBF\"+U_DipUsr()+"-DIPRL40 - "+If(MV_PAR16=1,"Sint�tico","Anal�tico")

Local oTempTable

Private QRY1     := ""  
Private _cChave  := ""
Private TRB  
Private _cArqTrb := ""



ProcRegua(600)
For _x := 1 to 350
	IncProc("Processando Contratos em aberto. . . ")
Next

QRY1 := " SELECT B1_DESC,UA1_DVALID,UA4_PRCVEN,A3_NREDUZ,A1_NOME,UA1_VCONTR,UA1_VCONT2,UA1_TIPO,UA1_NRCONC,A1_GRPVEN,B1_FILIAL,A3_FILIAL,A1_FILIAL,UA4_FILIAL,UA1_FILIAL,UA1_STATUS,UA4_QTDENT,  "
QRY1 += " UA4_QUANT, UA1_TPVALI, "
QRY1 += " UA4_XSALAD,UA4_SALDO,UA4_VENCEU,A3_COD,UA1_VEND,B1_COD,UA4_PRODUT,UA1_DENCER,UA1_CODCLI,UA1_ASSCON,UA1_CODCLI,A1_COD,UA1_LOJA,A1_LOJA,A3_COD,UA1_CODIGO,A3_COD,UA1_CODIGO,UA4_EDITAL,UA4_PRODUT,B1_PROC "
QRY1 += " FROM " + RetSQLName("UA1")+', '+RetSQLName("UA4")+', '+ RetSQLName("SA1")+', '+ RetSQLName("SA3")+', '+ RetSQLName("SB1")
QRY1 += " WHERE UA1_DENCER BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'"
QRY1 += " AND UA1_CODCLI BETWEEN   '"+MV_PAR09+"'       AND '"+MV_PAR10+"'"
QRY1 += " AND UA1_ASSCON BETWEEN   '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'"
QRY1 += " AND UA1_VEND   BETWEEN   '"+MV_PAR05+"'       AND '"+MV_PAR06+"'"
QRY1 += " AND UA1_CODCLI = A1_COD"
QRY1 += " AND UA1_LOJA = A1_LOJA"
QRY1 += " AND UA1_VEND = A3_COD"
QRY1 += " AND UA1_CODIGO = UA4_EDITAL"     
QRY1 += " AND UA1_CODIGO BETWEEN   '"+MV_PAR18+"' AND '"+MV_PAR19+"'"
QRY1 += " AND UA4_PRODUT BETWEEN   '"+MV_PAR11+"' AND '"+MV_PAR12+"'"     
QRY1 += " AND B1_PROC    BETWEEN   '"+MV_PAR07+"' AND '"+MV_PAR08+"'"     
QRY1 += " AND UA4_PRODUT = B1_COD"
QRY1 += " AND UA1_VEND   = A3_COD"                                                                        
QRY1 += " AND UA4_VENCEU = '1'"
QRY1 += " AND UA1_STATUS = '7' " //Giovani Zago 03/10/11  

//QRY1 += " AND ((UA4_SALDO+UA4_XSALAD+UA4_QUANT)- UA4_QTDENT) > 0  "
//QRY1 += " AND UA1_STATUS NOT IN ('9','8','0','6') "                             
//QRY1 += " AND UA1_XENCER <> 'S' "                             
//QRY1 += " AND UA1_VCONTR >=  '"+DTOS(DDATABASE)+"'"
QRY1 += " AND A1_GRPVEN BETWEEN   '"+MV_PAR13+"' AND '"+MV_PAR14+"'" 
QRY1 += " AND UA1_FILIAL = '"+xFilial('UA1')+"'"
QRY1 += " AND UA4_FILIAL = '"+xFilial('UA4')+"'"
QRY1 += " AND A1_FILIAL  = '"+xFilial('SA1')+"'"
QRY1 += " AND A3_FILIAL  = '"+xFilial('SA3')+"'"
QRY1 += " AND B1_FILIAL  = '"+xFilial('SB1')+"'"
QRY1 += " AND " + RetSQLName("UA1") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("UA4") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SA1") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SA3") + ".D_E_L_E_T_ = ''"
QRY1 += " AND " + RetSQLName("SB1") + ".D_E_L_E_T_ = ''"

QRY1 += " ORDER BY UA1_VEND, UA1_CODCLI, UA1_LOJA, UA1_DENCER, UA1_CODIGO"

cQuery := ChangeQuery(QRY1)
dbUseArea(.T., "TOPCONN", TCGenQry(,,QRY1), 'QRY1', .F., .T.)
memowrite('DIPRL40.SQL',QRY1)

/*====================================================================================\
| IMPRESS�O DO RELAT�RIO                                                              |
\====================================================================================*/

DbSelectArea("QRY1")
QRY1->(dbGotop())


If MV_PAR16 = 1
	_cTitulo := "RELAT�RIO SINT�TICO DE CONTRATOS EM ABERTO - Per�odo:   "+dTOc(mv_par01)+' - '+dTOc(mv_par02)
	_cDesc1  := "EDITAL    PREG�O                TIPO DO PREG�O           DT. ASSIN.      VALIDADE            CLIENTE                                                                        VENDEDOR                             Valor Total"// Giovani Zago 22/08/11
	_cDesc2  := ""
Else
	_cTitulo := "RELAT�RIO ANAL�TICO DE CONTRATOS EM ABERTO - Per�odo:   "+dTOc(mv_par01)+' - '+dTOc(mv_par02)
	_cDesc1  := "EDITAL    PREG�O                TIPO DO PREG�O           DT. ASSIN.      VALIDADE            CLIENTE                                                                        VENDEDOR"
	_cDesc2  := "Produto                                                                  Qtd. Vendida      Qtd. Entregue     Sal.Add.     Saldo       Valor unit�rio                                                             Valor Total"// Giovani Zago 22/08/11
Endif


_cEdital     := '' 
_cCliente    := ''   
_cVend       := ''
_nTotGer     := 0
_nTotCli     := 0
_nTotEdi     := 0
_nTotVen     := 0
                       

// CRIANDO CAMPOS PARA GERAR ARQUIVO EXCEL-DBF

If MV_PAR17	= 1
	If MV_PAR16 = 1
		_aCampos := {}
		_aTamSX3 := TamSX3("UA1_CODIGO")
		AAdd(_aCampos ,{"EDITAL", "C",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("UA1_NRCONC")
		AAdd(_aCampos ,{"PREGAO", "C",_aTamSX3[1],_aTamSX3[2]})
		AAdd(_aCampos ,{"TIPO_PREG", "C",20,0})
	   
	   //	_aTamSX3 := TamSX3("UA1_EMISSA")//Giovani Zago 22/08/11
	   //	AAdd(_aCampos ,{"DT_ENCER", "D",_aTamSX3[1],_aTamSX3[2]})//Giovani Zago 22/08/11
	   
			_aTamSX3 := TamSX3("UA1_ASSCON")//Giovani Zago 22/08/11
	   	AAdd(_aCampos ,{"DT_ASSIN", "D",_aTamSX3[1],_aTamSX3[2]})//Giovani Zago 22/08/11
	   
			AAdd(_aCampos ,{"VALIDADE", "C",15,0})
		_aTamSX3 := TamSX3("UA1_CODCLI")
		AAdd(_aCampos ,{"CLIENTE", "C",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("A1_NOME")
		AAdd(_aCampos ,{"NOME_CLI", "C",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("A1_VEND")
		AAdd(_aCampos ,{"VENDEDOR", "C",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("A3_NREDUZ")
		AAdd(_aCampos ,{"NOME_VEN", "C",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("UA4_TOTAL")
		AAdd(_aCampos ,{"TOTAL","N",_aTamSX3[1],_aTamSX3[2]})
	Else
		_aCampos := {}
		_aTamSX3 := TamSX3("UA1_CODIGO")
		AAdd(_aCampos ,{"EDITAL", "C",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("UA1_NRCONC")
		AAdd(_aCampos ,{"PREGAO", "C",_aTamSX3[1],_aTamSX3[2]})
		AAdd(_aCampos ,{"TIPO_PREG", "C",20,0})
	  
	   //	_aTamSX3 := TamSX3("UA1_EMISSA")//Giovani Zago 22/08/11
	   //	AAdd(_aCampos ,{"DT_ENCER", "D",_aTamSX3[1],_aTamSX3[2]})//Giovani Zago 22/08/11
	   
	    _aTamSX3 := TamSX3("UA1_ASSCON")//Giovani Zago 22/08/11
	   	AAdd(_aCampos ,{"DT_ASSIN", "D",_aTamSX3[1],_aTamSX3[2]})//Giovani Zago 22/08/11
		
			AAdd(_aCampos ,{"VALIDADE", "C",15,0})
		_aTamSX3 := TamSX3("UA1_CODCLI")
		AAdd(_aCampos ,{"CLIENTE", "C",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("A1_NOME")
		AAdd(_aCampos ,{"NOME_CLI", "C",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("A1_VEND")
		AAdd(_aCampos ,{"VENDEDOR", "C",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("A3_NREDUZ")
		AAdd(_aCampos ,{"NOME_VEN", "C",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("B1_COD")
		AAdd(_aCampos ,{"PRODUTO", "C",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("B1_DESC")
		AAdd(_aCampos ,{"DESCRICAO", "C",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("UA4_QUANT")
		AAdd(_aCampos ,{"QTD_VEND","N",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("UA4_QTDENT")
		AAdd(_aCampos ,{"QTD_ENTR","N",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("UA4_XSALAD")
		AAdd(_aCampos ,{"SALADD","N",_aTamSX3[1],_aTamSX3[2]})	
		_aTamSX3 := TamSX3("UA4_SALDO")
		AAdd(_aCampos ,{"SALDO","N",_aTamSX3[1],_aTamSX3[2]})		
		_aTamSX3 := TamSX3("UA4_PRCVEN")
		AAdd(_aCampos ,{"VAL_UNIT","N",_aTamSX3[1],_aTamSX3[2]})
		_aTamSX3 := TamSX3("UA4_TOTAL")
		AAdd(_aCampos ,{"TOTAL","N",_aTamSX3[1],_aTamSX3[2]})
	Endif

/*	
_cArqTrb := CriaTrab(_aCampos,.T.)
DbUseArea(.T.,,_cArqTrb,"TRB",.F.,.F.)
_cChave  := "VENDEDOR+CLIENTE+DTOC(DT_ASSIN)+EDITAL"
IndRegua("TRB",_cArqTrb,_cChave,,,"Criando Indice...(Edital)")
*/
	If(oTempTable <> NIL)
		oTempTable:Delete()
		oTempTable := NIL
	EndIf
	oTempTable := FWTemporaryTable():New("TRB")
	oTempTable:SetFields( _aCampos )
	//oTempTable:AddIndex("1", {"EDITAL", "PREGAO"} )
	oTempTable:Create()

	DbSelectArea("TRB")

EndIf

ProcRegua(600)
For _x := 1 to 450
	IncProc("Imprimindo Relat�rio. . . ")
Next
	
	
Do While QRY1->(!Eof())

  If cWorkFlow == "N"
	
	
	If MV_PAR16 = 2 // Anal�tico
		If MV_PAR15 = 1 			// Alimenta Array para envio de e-mail
	  		aadd(aEnv_040,{QRY1->UA1_CODIGO, QRY1->UA1_NRCONC, QRY1->UA1_TIPO,;
						   ;//SubStr(QRY1->UA1_DENCER,7,2)+'/'+SubStr(QRY1->UA1_DENCER,5,2)+'/'+SubStr(QRY1->UA1_DENCER,1,4),;					   
						   SubStr(QRY1->UA1_ASSCON,7,2)+'/'+SubStr(QRY1->UA1_ASSCON,5,2)+'/'+SubStr(QRY1->UA1_ASSCON,1,4),;	  //Giovani Zago 22/08/11				   
						   (If(!Empty(QRY1->UA1_VCONTR),SubStr(QRY1->UA1_DVALID,7,2)+'/'+SubStr(QRY1->UA1_DVALID,5,2)+'/'+SubStr(QRY1->UA1_DVALID,1,4),;					   
						   If(!Empty(QRY1->UA1_VCONT2),(QRY1->UA1_VCONT2+"  "+If(QRY1->UA1_TPVALI="D","dias",If(QRY1->UA1_TPVALI="M","meses","Anos"))),""))),;					  
						   QRY1->UA1_CODCLI+"-"+Alltrim(QRY1->A1_NOME),QRY1->UA1_VEND+' - '+Alltrim(QRY1->A3_NREDUZ),;
						   SUBSTR(QRY1->UA4_PRODUT,1,6)+'    '+QRY1->B1_DESC,QRY1->UA4_QUANT,QRY1->UA4_QTDENT,QRY1->UA4_XSALAD,;//Giovani Zago 22/08/11
						   ((QRY1->UA4_SALDO+QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT),QRY1->UA4_PRCVEN,((QRY1->UA4_SALDO+QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN})	//Giovani Zago 22/08/11
		Endif			    			   


	If MV_PAR17 = 1 //Giovani Zago 30/08/2011	
	    // ATUALIZANDO TABELA TEMPOR�RIA PARA GERAR ARQUIVO EM EXCEL	    	    
	    RecLock("TRB",.T.)                
   		TRB->EDITAL    := QRY1->UA1_CODIGO
		TRB->PREGAO    := QRY1->UA1_NRCONC
		TRB->TIPO_PREG := If(QRY1->UA1_TIPO = "1","Pregao Presencial",;
						  If(QRY1->UA1_TIPO = "2","Pregao Eletronico",;
						  If(QRY1->UA1_TIPO = "3","Tomada de Precos" ,;
  						  If(QRY1->UA1_TIPO = "4","Convite"          ,;
  						  If(QRY1->UA1_TIPO = "5","Registro de Precos","BEC")))))  					    						  
	   //	TRB->DT_ENCER  := CTOD(SUBSTRING(QRY1->UA1_DENCER,7,2)+'/'+SUBSTRING(QRY1->UA1_DENCER,5,2)+'/'+SUBSTRING(QRY1->UA1_DENCER,1,4))
	TRB->DT_ASSIN  := CTOD(SUBSTRING(QRY1->UA1_ASSCON,7,2)+'/'+SUBSTRING(QRY1->UA1_ASSCON,5,2)+'/'+SUBSTRING(QRY1->UA1_ASSCON,1,4))//Giovani Zago 22/08/11

		If !Empty(QRY1->UA1_VCONTR) 
			TRB->VALIDADE  := SubStr(QRY1->UA1_VCONTR,7,2)+'/'+SubStr(QRY1->UA1_VCONTR,5,2)+'/'+SubStr(QRY1->UA1_VCONTR,1,4)
		Else
			TRB->VALIDADE  := If(!Empty(QRY1->UA1_VCONT2),QRY1->UA1_VCONT2+"  "+(If(QRY1->UA1_TPVALI="D","dias",If(QRY1->UA1_TPVALI="M","meses","Anos")))," ")
		Endif
						   
		TRB->CLIENTE   := QRY1->UA1_CODCLI
		TRB->NOME_CLI  := QRY1->A1_NOME
		TRB->VENDEDOR  := QRY1->UA1_VEND
		TRB->NOME_VEN  := QRY1->A3_NREDUZ
		TRB->PRODUTO   := QRY1->UA4_PRODUT
		TRB->DESCRICAO := QRY1->B1_DESC 
		TRB->QTD_VEND  := QRY1->UA4_QUANT 
		TRB->QTD_ENTR  := QRY1->UA4_QTDENT
		TRB->SALADD    := QRY1->UA4_XSALAD
		TRB->SALDO     := ((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)
		TRB->VAL_UNIT  := QRY1->UA4_PRCVEN
		TRB->TOTAL     := ((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN
		MsUnlock()

          EndIf
        // In�cio da impress�o de relat�rio
		If li > 55
			If m_PAG > 1
				Roda(0,"Bom trabalho!",tamanho)
			Endif
			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
  		EndIf


		// Edital
		If _cEdital <> QRY1->UA1_CODIGO
			@ li,000 PSay QRY1->UA1_CODIGO
			@ li,010 PSay QRY1->UA1_NRCONC    
			@ li,032 PSay If(QRY1->UA1_TIPO = "1","Pregao Presencial",;
						  If(QRY1->UA1_TIPO = "2","Pregao Eletronico",;
						  If(QRY1->UA1_TIPO = "3","Tomada de Precos" ,;
  						  If(QRY1->UA1_TIPO = "4","Convite"          ,;
  						  If(QRY1->UA1_TIPO = "5","Registro de Precos","BEC")))))  					  
			@ li,057 PSay SubStr(QRY1->UA1_DENCER,7,2)+'/'+SubStr(QRY1->UA1_DENCER,5,2)+'/'+SubStr(QRY1->UA1_DENCER,1,4)
			If !Empty(QRY1->UA1_VCONTR) 
				@ li,073 PSay SubStr(QRY1->UA1_VCONTR,7,2)+'/'+SubStr(QRY1->UA1_VCONTR,5,2)+'/'+SubStr(QRY1->UA1_VCONTR,1,4)
			Else
				@ li,073 PSay If(!Empty(QRY1->UA1_VCONT2),QRY1->UA1_VCONT2+"  "+(If(QRY1->UA1_TPVALI="D","dias",If(QRY1->UA1_TPVALI="M","meses","Anos")))," ")
			Endif
		
			@ li,093 PSay QRY1->UA1_CODCLI+" - "+QRY1->UA1_LOJA+' - '+Alltrim(QRY1->A1_NOME)
			@ li,172 PSay QRY1->UA1_VEND+' - '+Alltrim(QRY1->A3_NREDUZ)
			li++                                         
			li++                                         
		EndIf
	
		//itens	
		@ li,000 PSay SUBSTR(QRY1->UA4_PRODUT,1,6)+'    '+QRY1->B1_DESC
		@ li,072 PSay QRY1->UA4_QUANT  					PICTURE '@E 999,999,999'
		@ li,092 PSay QRY1->UA4_QTDENT 					PICTURE '@E 999,999,999' 
		@ li,105 PSay QRY1->UA4_XSALAD                  PICTURE '@E 999,999,999'
		@ li,116 PSay ((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)  					PICTURE '@E 999,999,999'
 		@ li,132 PSay QRY1->UA4_PRCVEN 					PICTURE '@E 9,999,999.9999'	
	 	@ li,208 PSay ((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN  PICTURE '@E 9,999,999.99'	

		_nTotCli  := _nTotCli  + (((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN)
		_nTotEdi  := _nTotEdi  + (((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN)
		_nTotGer  := _nTotGer  + (((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN)
		_nTotVen  := _nTotVen  + (((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN)
	
		If _cEdital <> QRY1->UA1_CODIGO                 
			_cEdital := QRY1->UA1_CODIGO
		EndIf
	
		If _cCliente <> QRY1->UA1_CODCLI+QRY1->UA1_LOJA
			_cCliente := QRY1->UA1_CODCLI+QRY1->UA1_LOJA
		EndIf                                          
		
		If _cVend <> QRY1->UA1_VEND
			_cVend := QRY1->UA1_VEND
		EndIf
		
		li++

		QRY1->(DbSkip())                                
	

	
		If _cEdital <> QRY1->UA1_CODIGO

			If li > 57
	   			Roda(0,"Bom trabalho!",tamanho)
	   			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1				
	
				//li := 66
			EndIf
			@ li,172 PSay  "Total em aberto: " 
			@ li,208 PSay  _nTotEdi PICTURE '@E 9,999,999.99'        
			_nTotEdi := 0
			li++
			@ li,000 PSay Replicate('-',limite)
			li+=1
			
		EndIf


	
		If _cCliente <> QRY1->UA1_CODCLI+QRY1->UA1_LOJA	
			If li > 57
				Roda(0,"Bom trabalho!",tamanho)
	   			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1				
	   			
				//li := 66
			EndIf
			@ li,172 PSay  "TOTAL DO CLIENTE: " 
			@ li,208 PSay  _nTotCli PICTURE '@E 9,999,999.99'        
			_nTotCli := 0
			li++
			@ li,000 PSay Replicate('-',limite)
			li+=2
		EndIf    
	
		If _cVend <> QRY1->UA1_VEND
			If li > 57
				Roda(0,"Bom trabalho!",tamanho)
	   			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1				
	   		
				//li := 66
			EndIf
			@ li,172 PSay  "TOTAL DO VENDEDOR: " 
			@ li,208 PSay  _nTotVen PICTURE '@E 9,999,999.99'        
			_nTotVen := 0
			li++
			@ li,000 PSay Replicate('-',limite)
			li+=2
		EndIf

	Else // Sint�tico			    			   
	
		// Atualiza Array para E-mail  sint�tico
		//If MV_PAR12 = 1
			If aScan(aEnv_040, { |x| x[1] == QRY1->UA1_CODIGO }) > 0
   				aEnv_040[aScan(aEnv_040, { |x| x[1] == QRY1->UA1_CODIGO }),8]  += ((+QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN
			Else
				aadd(aEnv_040,{QRY1->UA1_CODIGO, QRY1->UA1_NRCONC, QRY1->UA1_TIPO,;
							  ; //SubStr(QRY1->UA1_DENCER,7,2)+'/'+SubStr(QRY1->UA1_DENCER,5,2)+'/'+SubStr(QRY1->UA1_DENCER,1,4),;					   
							   SubStr(QRY1->UA1_ASSCON,7,2)+'/'+SubStr(QRY1->UA1_ASSCON,5,2)+'/'+SubStr(QRY1->UA1_ASSCON,1,4),;	//Giovani Zago 22/08/11				   
							   (If(!Empty(QRY1->UA1_VCONTR),SubStr(QRY1->UA1_DVALID,7,2)+'/'+SubStr(QRY1->UA1_DVALID,5,2)+'/'+SubStr(QRY1->UA1_DVALID,1,4),;					   
							   If(!Empty(QRY1->UA1_VCONT2),(QRY1->UA1_VCONT2+"  "+If(QRY1->UA1_TPVALI="D","dias",If(QRY1->UA1_TPVALI="M","meses","Anos"))),""))),;					  
							   QRY1->UA1_CODCLI+" - "+Alltrim(QRY1->A1_NOME),QRY1->UA1_VEND+' - '+Alltrim(QRY1->A3_NREDUZ),((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN })								   		
		    Endif
		//Endif	                          
				
	    // INICIO DA IMPRESS�O DO RELAT�RIO        
	    
	    
		If li > 55
			If m_PAG > 1
				Roda(0,"Bom trabalho!",tamanho)
			Endif
			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1
  		EndIf
		// Edital
		If _cEdital <> QRY1->UA1_CODIGO
			@ li,000 PSay QRY1->UA1_CODIGO
			@ li,010 PSay QRY1->UA1_NRCONC    
			@ li,032 PSay If(QRY1->UA1_TIPO = "1","Pregao Presencial",;
						  If(QRY1->UA1_TIPO = "2","Pregao Eletronico",;
						  If(QRY1->UA1_TIPO = "3","Tomada de Precos" ,;
  						  If(QRY1->UA1_TIPO = "4","Convite"          ,;
  						  If(QRY1->UA1_TIPO = "5","Registro de Precos","BEC")))))  					  
			//@ li,057 PSay SubStr(QRY1->UA1_DENCER,7,2)+'/'+SubStr(QRY1->UA1_DENCER,5,2)+'/'+SubStr(QRY1->UA1_DENCER,1,4)
			@ li,057 PSay SubStr(QRY1->UA1_ASSCON,7,2)+'/'+SubStr(QRY1->UA1_ASSCON,5,2)+'/'+SubStr(QRY1->UA1_ASSCON,1,4)//Giovani Zago 22/08/11
			
			
			If !Empty(QRY1->UA1_VCONTR) 
				@ li,073 PSay SubStr(QRY1->UA1_VCONTR,7,2)+'/'+SubStr(QRY1->UA1_VCONTR,5,2)+'/'+SubStr(QRY1->UA1_VCONTR,1,4)
			Else
				@ li,073 PSay If(!Empty(QRY1->UA1_VCONT2),QRY1->UA1_VCONT2+"  "+(If(QRY1->UA1_TPVALI="D","dias",If(QRY1->UA1_TPVALI="M","meses","Anos"))),"  ")
			Endif
		
			@ li,093 PSay QRY1->UA1_CODCLI+" - "+QRY1->UA1_LOJA+' - '+Alltrim(QRY1->A1_NOME)
			@ li,172 PSay QRY1->UA1_VEND+' - '+Alltrim(QRY1->A3_NREDUZ)				
		EndIf
		 		

		_nTotCli  := _nTotCli  + (((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN)
		_nTotEdi  := _nTotEdi  + (((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN)
		_nTotGer  := _nTotGer  + (((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN)
		_nTotVen  := _nTotVen  + (((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN)
						
		
		If _cEdital <> QRY1->UA1_CODIGO                 
			_cEdital := QRY1->UA1_CODIGO
		EndIf
	
		If _cCliente <> QRY1->UA1_CODCLI+QRY1->UA1_LOJA
			_cCliente := QRY1->UA1_CODCLI+QRY1->UA1_LOJA
		EndIf                                          
		
		If _cVend <> QRY1->UA1_VEND
			_cVend := QRY1->UA1_VEND
		EndIf
		                                       

		QRY1->(DbSkip())                                
	

		If _cEdital <> QRY1->UA1_CODIGO		
//		   	@ li,172 PSay  "Total em aberto: " 
			@ li,208 PSay  _nTotEdi PICTURE '@E 9,999,999.99'        			
			_nTotEdi := 0
			li++
//			@ li,000 PSay Replicate('-',limite)
//			li+=1			
		EndIf


	
		If _cCliente <> QRY1->UA1_CODCLI+QRY1->UA1_LOJA	
			If li > 57
				Roda(0,"Bom trabalho!",tamanho)
	   			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1				
	   			
				//li := 66
			EndIf
			@ li,172 PSay  "TOTAL DO CLIENTE: " 
			@ li,208 PSay  _nTotCli PICTURE '@E 9,999,999.99'        
			_nTotCli := 0
			li++
			@ li,000 PSay Replicate('-',limite)
			li+=2
		EndIf    
	
		If _cVend <> QRY1->UA1_VEND
			If li > 57
				Roda(0,"Bom trabalho!",tamanho)
	   			li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1				
	   		
				//li := 66
			EndIf
			@ li,172 PSay  "TOTAL DO VENDEDOR: " 
			@ li,208 PSay  _nTotVen PICTURE '@E 9,999,999.99'        
			_nTotVen := 0
			li++
			@ li,000 PSay Replicate('-',limite)
			li+=2
		EndIf
	Endif
  Else  // Workflow (envia somente por e-mail  // MCVN 25/02/2009
	ConOut("rodando array"+QRY1->UA1_CODIGO+" - "+QRY1->UA1_VEND)
  	If MV_PAR16 = 2 // Anal�tico
	  		aadd(aEnv_040,{QRY1->UA1_CODIGO, QRY1->UA1_NRCONC, QRY1->UA1_TIPO,;
						   ;//SubStr(QRY1->UA1_DENCER,7,2)+'/'+SubStr(QRY1->UA1_DENCER,5,2)+'/'+SubStr(QRY1->UA1_DENCER,1,4),;					   
						   SubStr(QRY1->UA1_ASSCON,7,2)+'/'+SubStr(QRY1->UA1_ASSCON,5,2)+'/'+SubStr(QRY1->UA1_ASSCON,1,4),;//Giovani Zago 22/08/11					   
						   (If(!Empty(QRY1->UA1_VCONTR),SubStr(QRY1->UA1_DVALID,7,2)+'/'+SubStr(QRY1->UA1_DVALID,5,2)+'/'+SubStr(QRY1->UA1_DVALID,1,4),;					   
						   If(!Empty(QRY1->UA1_VCONT2),(QRY1->UA1_VCONT2+"  "+If(QRY1->UA1_TPVALI="D","dias",If(QRY1->UA1_TPVALI="M","meses","Anos"))),""))),;					  
						   QRY1->UA1_CODCLI+"-"+Alltrim(QRY1->A1_NOME),QRY1->UA1_VEND+' - '+Alltrim(QRY1->A3_NREDUZ),;
						   SUBSTR(QRY1->UA4_PRODUT,1,6)+'    '+QRY1->B1_DESC,QRY1->UA4_QUANT,QRY1->UA4_QTDENT,QRY1->UA4_XSALAD,;
						   ((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT),QRY1->UA4_PRCVEN,((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN})	
    Else 
		If aScan(aEnv_040, { |x| x[1] == QRY1->UA1_CODIGO }) > 0
   				aEnv_040[aScan(aEnv_040, { |x| x[1] == QRY1->UA1_CODIGO }),8]  += ((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN
		Else
				aadd(aEnv_040,{QRY1->UA1_CODIGO, QRY1->UA1_NRCONC, QRY1->UA1_TIPO,;
							   SubStr(QRY1->UA1_DENCER,7,2)+'/'+SubStr(QRY1->UA1_DENCER,5,2)+'/'+SubStr(QRY1->UA1_DENCER,1,4),;					   
							   (If(!Empty(QRY1->UA1_VCONTR),SubStr(QRY1->UA1_DVALID,7,2)+'/'+SubStr(QRY1->UA1_DVALID,5,2)+'/'+SubStr(QRY1->UA1_DVALID,1,4),;					   
							   If(!Empty(QRY1->UA1_VCONT2),(QRY1->UA1_VCONT2+"  "+If(QRY1->UA1_TPVALI="D","dias",If(QRY1->UA1_TPVALI="M","meses","Anos"))),""))),;					  
							   QRY1->UA1_CODCLI+" - "+Alltrim(QRY1->A1_NOME),QRY1->UA1_VEND+' - '+Alltrim(QRY1->A3_NREDUZ),((QRY1->UA4_QUANT+QRY1->UA4_XSALAD)-QRY1->UA4_QTDENT)*QRY1->UA4_PRCVEN })								   		
	    Endif    
	Endif    
	QRY1->(DbSkip())  // MCVN 24/02/2009    		
  Endif			    			   
  
EndDo              

If cWorkFlow == "N"
	If MV_PAR16 = 1  
		If MV_PAR17 = 1 //Giovani Zago 30/08/2011
	// Alimentando tabela tempor�ria para gerar excel do relat�rio sint�tico
		For m := 1 to Len(aEnv_040)	
			RecLock("TRB",.T.)                
	   		TRB->EDITAL    := aEnv_040[m,1]
			TRB->PREGAO    := aEnv_040[m,2]
			TRB->TIPO_PREG := If(aEnv_040[m,3] = "1","Pregao Presencial",;
							  If(aEnv_040[m,3] = "2","Pregao Eletronico",;
							  If(aEnv_040[m,3] = "3","Tomada de Precos" ,;
  							  If(aEnv_040[m,3] = "4","Convite"          ,;
  							  If(aEnv_040[m,3] = "5","Registro de Precos","BEC")))))  					    						  
			TRB->DT_ASSIN  := Ctod(aEnv_040[m,4])
			TRB->VALIDADE  := aEnv_040[m,5]						   
			TRB->CLIENTE   := substr(aEnv_040[m,6],01,06)						   
			TRB->NOME_CLI  := substr(aEnv_040[m,6],10,61)
			TRB->VENDEDOR  := substr(aEnv_040[m,7],01,06)						   
			TRB->NOME_VEN  := substr(aEnv_040[m,7],10,61)
			TRB->TOTAL     := aEnv_040[m,8]
			MsUnlock() 
			             
		Next
	Endif
      	Endif
	If li > 55
		Roda(0,"Bom trabalho!",tamanho)
		li := Cabec(_cTitulo,_cDesc1,_cDesc2,nomeprog,tamanho) + 1				
	EndIf             

	Li++
	@ li,172 PSay  "T O T A L   G E R A L : " 
	@ li,204 PSay  _nTotGer PICTURE '@E 9,999,999,999.99'        
	li++ 
	@ li,000 PSay Replicate('-',limite)
	Roda(0,"Bom trabalho!",tamanho)  
	
	// Envia e-mail com os dados do relat�rio
	If MV_PAR15 = 1 .And. MV_PAR05 == MV_PAR06 .And. !EMPTY(MV_PAR05)  // S� envia e�mail se o relat�rio for somente de um vendedor
	
		ProcRegua(600)
		For _x := 1 to 500
			IncProc("Enviando E-mail. . . ")
		Next
	    If Len(aEnv_040) > 0
			ENV_040(cEmail,cAssunto,aEnv_040)            
		Endif
	ElseIf MV_PAR15 = 1 .And. MV_PAR05 <> MV_PAR06 .And. !EMPTY(MV_PAR06) 
		MsgInfo("Voc� selecionou v�rios vendedores...O e-mail s� pode ser enviado para um vendedor por vez!")
	Endif

	// Gera arquivo Excel/Dbf

	If MV_PAR17 = 1 
	
		DbSelectArea("TRB")
		TRB->(dbGotop())
		ProcRegua(TRB->(RECCOUNT()))	
		aCols := Array(TRB->(RECCOUNT()),Len(_aCampos))
		nColuna := 0
		nLinha := 0
		While TRB->(!Eof())
			nLinha++
			IncProc(OemToAnsi("Gerando planilha excel..."))
			For nColuna := 1 to Len(_aCampos)
				aCols[nLinha][nColuna] := &("TRB->("+_aCampos[nColuna][1]+")")			
			Next nColuna
			TRB->(dbSkip())	
		EndDo
		u_GDToExcel(_aCampos,aCols,Alltrim(FunName()))	
	
		DbSelectArea("TRB")   //Giovani Zago 30/08/2011                    
		ProcRegua(1000)
		For _x := 1 to 1000
			IncProc("Gerando Arquivo. . . ")
		Next
		/*COPY TO &cArqExcell VIA "DBFCDX"
	   //	MsgInfo("Arquivo gerado com sucesso!") //Giovani Zago 30/08/2011  
	   
	   FRename(cArqExcell+".dtc",cArqExcell+".xls")*/
	   FRename(cArqExcell+".dtc",cArqExcell+".xlsx")
	
		MakeDir(cDestino) // CRIA DIRET�RIO CASO N�O EXISTA
		CpyS2T(cArqExcell+".xls",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USU�RIO
		
		Ferase(_cArqTrb+".DBF")
		Ferase(_cArqTrb+OrdBagExt()) 
		TRB->(DbCloseArea())
		oTempTable:Delete()
		
	EndIf
Else
	ConOut("Enviando email") 
	If Len(aEnv_040) > 0
		ENV_040(cEmail,cAssunto,aEnv_040) 
	Endif
Endif

Return()           

/*==========================================================================\
|Programa  | ENV_040 | Autor | Maximo Canuto - MCVN    | Data � 11/02/2009  |
|===========================================================================|
|Desc.     | Envio de EMail dos contratos em aberto por vendedor            |
|===========================================================================|
|Sintaxe   | ENV_040                                                        |
|===========================================================================|
|Uso       | Especifico DIPROMED  - Licita��o                               |
\==========================================================================*/

Static Function ENV_040(cEmail,cAssunto,aEnv_040)

Local cAccount  := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cFrom     := Lower(Alltrim(GetMv("MV_RELACNT")))
Local cPassword := Alltrim(GetMv("MV_RELPSW"))
Local cServer   := Alltrim(GetMv("MV_RELSERV"))
Local cEmailTo  := ""
Local cEmailCc  := "patricia.mendonca@dipromed.com.br;publico@dipromed.com.br"
Local cEmailBcc := ""
Local lResult   := .F.
Local cError    := ""
Local cMsg      := ""
Local nTot_Prod := 0
Local cEdital   := ""  
Local cCliente  := "" 
Local cTpEdital := "" 
Local _nTotCli  := 0
Local _nTotEdi  := 0
Local _nTotGer  := 0   
LOCAL lSmtpAuth := GetNewPar("MV_RELAUTH",.F.)
LOCAL lAutOk	:= .F.
Local cAssuntob := DecodeUTF8(cAssunto, "cp1252")

/*=============================================================================*/
/*Definicao do cabecalho do email                                              */
/*=============================================================================*/
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title>' +cAssunto + '</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red><P>'
cMsg += '<Table Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
//cMsg += '<td width="100%" align="center"><font size="3" color="red">ATEN��O: Este e-mail deve ser respondido para Patr�cia-Licita��o</font></td>'
cMsg += '</tr>'
cMsg += '</table>'

cMsg += '<table width="100%">'
cMsg += '<tr>'
cMsg += '<td width="100%" align="center"><font size="3" color="blue">' +cAssuntob+ '</font></td>' 
cMsg += '</tr>'
cMsg += '</table>'
cMsg += '<hr width="100%" size="3" align="center" color="#000000">'
cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="3" color="blue">'     
cMsg += '<tr>'
cMsg += '<td align="Left" width="08%"><font color="Black" size="3">EDITAL</font></td>'
cMsg += '<td align="Left" width="08%"><font  color="Black" size="3">PREG�O</font></td>'
cMsg += '<td align="Left" width="15%"><font color="Black" size="3">TIPO PREG�O</font></td>'
cMsg += '<td align="right" width="10%"><font color="Black" size="3">DT. ENCER.</font></td>'	
cMsg += '<td align="right" width="10%"><font color="Black" size="3">VALIDADE</font></td>'	

If MV_PAR16 = 1                                                                                                                         
	cMsg += '<td align="Left" width="39%"><font color="Black" size="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp CLIENTE</font></td>'	
	cMsg += '<td align="right" width="10%"><font color="Black" size="3">Valor Total</font></td>'	
Else
	cMsg += '<td align="Left" width="39%"><font color="Black" size="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp CLIENTE</font></td>'	
Endif                  
cMsg += '</tr>'
cMsg += '</table>'   

If MV_PAR16 = 2                  
	// Itens do Edital
	cMsg += '<hr width="100%" size="2" align="center" color="#996600">'
	cMsg += '<table width="100%" cellspacing="0" cellpadding="0"><font size="2" color="blue">'
	cMsg += '<tr>'
	cMsg += '<td align="Left" width="08%"><font size="2" color="Black" >Produto</font></td>'
	cMsg += '<td align="Left" width="42%"><font size="2" color="Black" >Descri��o</font></td>'
	cMsg += '<td align="right" width="10%"><font color="Black" size="2">Qtd. Vendida</font></td>'
	cMsg += '<td align="right" width="10%"><font color="Black" size="2">Qtd. Entregue</font></td>'
	cMsg += '<td align="right" width="10%"><font color="Black" size="2">Saldo</font></td>'
	cMsg += '<td align="right" width="10%"><font color="Black" size="2">Val. Unit.</font></td>'
	cMsg += '<td align="right" width="10%"><font color="Black" size="2">Val. Tot.</font></td>'                                         
	cMsg += '</tr>'
	cMsg += '</table>'
	cMsg += '<hr width="100%" size="2" align="center" color="#000000">'
Endif

For xi:=1 to Len(aEnv_040) 
    

    cTpEdital := If(aEnv_040[xi,3] = "1","Pregao Presencial",;
				 If(aEnv_040[xi,3] = "2","Pregao Eletronico",;
				 If(aEnv_040[xi,3] = "3","Tomada de Precos" ,;
  				 If(aEnv_040[xi,3] = "4","Convite"          ,;
  				 If(aEnv_040[xi,3] = "5","Registro de Precos","BEC"))))) 
  						  
	If MV_PAR16 = 2 // Anal�tico    
       
    	If cEdital <> aEnv_040[xi,1]  .And. !Empty(cEdital) 
		   	cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'		
			cMsg += '<tr BgColor="#c0c0c0">'
			cMsg += '<td align="right" width="100%"><font size="1"> Total em aberto &nbsp;&nbsp;&nbsp'+ cEdital+" &nbsp;&nbsp;&nbsp; "+Transform(_nTotEdi,"@E 999,999,999.99")+ '</font></td>'
	   		cMsg += '</tr>'
			cMsg += '</table>'
			_nTotEdi:=0		
		Endif
    	
        	
	    If cCliente <> aEnv_040[xi,6]  .And. !Empty(cCliente)     
		   	cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'		
			cMsg += '<tr BgColor="#c0c0c0">'
			cMsg += '<td align="right" width="100%"><font size="1" color="blue"> TOTAL DO CLIENTE  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp '+Transform(_nTotCli,"@E 999,999,999.99")+ '</font></td>'
   			cMsg += '</tr>'
			cMsg += '</table>'
			_nTotCli:=0
		Endif	 
    
    

		_nTotCli  := _nTotCli  + aEnv_040[xi,13]
		_nTotEdi  := _nTotEdi  + aEnv_040[xi,13]
		_nTotGer  := _nTotGer  + aEnv_040[xi,13]   

   	
   		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'	
	    If Empty(Alltrim(cEdital))
    
		    cEdital  := aEnv_040[xi,1]                                  
	    	cCliente := aEnv_040[xi,6]
		
			cMsg += '<hr width="100%" size="1" align="center" color="#000000">'
			cMsg += '<tr>'
   			cMsg += '<td align="Left"  width="08%"><font  color="Black" size="2">'   +aEnv_040[xi,1]+ '</font></td>'
			cMsg += '<td align="Left"  width="08%"><font  color="Black" size="1">'   +aEnv_040[xi,2]+ '</font></td>'
			cMsg += '<td align="Left"  width="15%"><font  color="Black" size="1">'   +cTpEdital+      '</font></td>'
			cMsg += '<td align="right" width="10%"><font  color="Black" size="1">'   +aEnv_040[xi,4]+ '</font></td>'
			cMsg += '<td align="right" width="10%"><font  color="Black" size="1">'   +aEnv_040[xi,5]+ '</font></td>'
			cMsg += '<td align="Left"  width="49%"><font  color="Black" size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp'+aEnv_040[xi,6]+ '</font></td>'
	   		cMsg += '</tr>'   
			cMsg += '</table>'
    	
		ElseIf cEdital <> aEnv_040[xi,1]  
		   
			cMsg += '<hr width="100%" size="1" align="center" color="#000000">'
			cMsg += '<tr>'
   			cMsg += '<td align="Left"  width="08%"><font  color="Black" size="2">'   +aEnv_040[xi,1]+ '</font></td>'
			cMsg += '<td align="Left"  width="08%"><font  color="Black" size="1">'   +aEnv_040[xi,2]+ '</font></td>'
			cMsg += '<td align="Left"  width="15%"><font  color="Black" size="1">'   +cTpEdital+      '</font></td>'
			cMsg += '<td align="right" width="10%"><font  color="Black" size="1">'   +aEnv_040[xi,4]+ '</font></td>'
			cMsg += '<td align="right" width="10%"><font  color="Black" size="1">'   +aEnv_040[xi,5]+ '</font></td>'
			cMsg += '<td align="left" width="49%"><font  color="Black" size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp'+aEnv_040[xi,6]+ '</font></td>'
		   	cMsg += '</tr>'   
   			cMsg += '</table>'
	        cEdital  := aEnv_040[xi,1] 
   		    cCliente := aEnv_040[xi,6]
		EndIf  	              
	
      	 
		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'		
		cMsg += '<tr BgColor="#c0c0c0">'
		cMsg += '<td align="Left"  width="08%"><font size="1">'  +Substr(aEnv_040[xi,8],01,06)+ '</font></td>'
		cMsg += '<td align="Left"  width="42%"><font size="1">'  +Substr(aEnv_040[xi,8],11,60)+ '</font></td>'
		cMsg += '<td align="right" width="10%"><font size="1">'  +Transform(aEnv_040[xi,09],"@E 999,999")+ '</font></td>'           
		cMsg += '<td align="right" width="10%"><font size="1">'  +Transform(aEnv_040[xi,10],"@E 999,999")+ '</font></td>'
		cMsg += '<td align="right" width="10%"><font size="1">'  +Transform(aEnv_040[xi,11],"@E 999,999")+ '</font></td>'
		cMsg += '<td align="right" width="10%"><font size="1">'  +Transform(aEnv_040[xi,12],"@E 999,999,999.9999")+ '</font></td>'
		cMsg += '<td align="right" width="10%"><font size="1">'  +Transform(aEnv_040[xi,13],"@E 999,999,999.99")+ '</font></td>'
   		cMsg += '</tr>'
		cMsg += '</table>'
		
    	If xi = Len(aEnv_040)
		   	cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'		
			cMsg += '<tr BgColor="#c0c0c0">'
			cMsg += '<td align="right" width="100%"><font size="1"> Total em aberto &nbsp;&nbsp;&nbsp'+ cEdital+" &nbsp;&nbsp;&nbsp; "+Transform(_nTotEdi,"@E 999,999,999.99")+ '</font></td>'
	   		cMsg += '</tr>'
			cMsg += '</table>'
		   	cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'		
			cMsg += '<tr BgColor="#c0c0c0">'
			cMsg += '<td align="right" width="100%"><font size="1" color="blue"> TOTAL DO CLIENTE  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp '+Transform(_nTotCli,"@E 999,999,999.99")+ '</font></td>'
   			cMsg += '</tr>'
			cMsg += '</table>'
			_nTotCli:=0       
			_nTotEdi:=0		
		Endif
	Else                                                    	   	    
 

    	If cCliente <> aEnv_040[xi,6]  .And. !Empty(cCliente)   
		   	cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'		
			cMsg += '<tr BgColor="#c0c0c0">'
			cMsg += '<td align="right" width="100%"><font size="1" color="blue"> TOTAL DO CLIENTE  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp '+Transform(_nTotCli,"@E 999,999,999.99")+ '</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
			_nTotCli:=0      			
		Endif	       

   	
   		cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'	                            		   
		cMsg += '<hr width="100%" size="1" align="center" color="#000000">'
		cMsg += '<tr>'
		cMsg += '<td align="Left"  width="08%"><font  color="Black" size="2">'   +aEnv_040[xi,1]+ '</font></td>'
		cMsg += '<td align="Left"  width="08%"><font  color="Black" size="1">'   +aEnv_040[xi,2]+ '</font></td>'
		cMsg += '<td align="Left"  width="15%"><font  color="Black" size="1">'   +cTpEdital+      '</font></td>'
		cMsg += '<td align="right" width="10%"><font  color="Black" size="1">'   +aEnv_040[xi,4]+ '</font></td>'
		cMsg += '<td align="right" width="10%"><font  color="Black" size="1">'   +aEnv_040[xi,5]+ '</font></td>'
		cMsg += '<td align="left"  width="39%"><font  color="Black" size="1">    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp'+aEnv_040[xi,6]+ '</font></td>'
		cMsg += '<td align="right" width="10%"><font  color="Black" size="1">'   +Transform(aEnv_040[xi,8],"@E 999,999,999.99")+ '</font></td>'
	   	cMsg += '</tr>'   
		cMsg += '</table>'
 	    
   		_nTotCli  := _nTotCli  + aEnv_040[xi,8]
		_nTotGer  := _nTotGer  + aEnv_040[xi,8]  
		cCliente := aEnv_040[xi,6]
        
    	If xi = Len(aEnv_040)
		   	cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'		
			cMsg += '<tr BgColor="#c0c0c0">'
			cMsg += '<td align="right" width="100%"><font size="1" color="blue"> TOTAL DO CLIENTE  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp '+Transform(_nTotCli,"@E 999,999,999.99")+ '</font></td>'
			cMsg += '</tr>'
			cMsg += '</table>'
			_nTotCli:=0      			
		Endif	     
	Endif
Next	              

	cMsg += '<hr width="100%" size="1" align="center" color="#000000">'
	cMsg += '<table width="100%" border="0" cellspacing="0" cellpadding="0">'		
	cMsg += '<tr BgColor="#c0c0c0">'
	cMsg += '<td align="right" width="100%"><font size="3" color="red"> TOTAL GERAL   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp '+Transform(_nTotGer,"@E 999,999,999.99")+ '</font></td>'
	cMsg += '</tr>'
	cMsg += '</table>'        

	cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red><P>'
	cMsg += '<table width="100%" Align="Center" border="0">'
	cMsg += '<tr align="center">'
	cMsg += '<td colspan="10"><font color="BLUE" size="2">Mensagem enviada automaticamente pelo sistema PROTHEUS - <font color="BLUE" size="1">(DIPRL40.PRW)</td>'
	cMsg += '</tr>'

	cMsg += '</table>'
	cMsg += '</body>'
	cMsg += '</html>'



//�����������������������������������������������������������������������������Ŀ
//�Envia o mail para a lista selecionada. Envia como BCC para que a pessoa pense�
//�que somente ela recebeu aquele email, tornando o email mais personalizado.   �
//�������������������������������������������������������������������������������

IF At(";",cEmail) > 0
	cEmailTo := SubStr(cEmail,1,At(";",cEmail)-1)
	cEmailCc := SubStr(cEmail,At(";",cEmail)+1,Len(cEmail))
Else
	cEmailTo := Alltrim(cEmail)
EndIF

	ConOut("Enviando email dentro da fun��o")
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

If lResult .And. lAutOk
	SEND MAIL FROM cFrom ;
	TO      	Lower(cEmailTo);
	CC      	Lower(cEmailCc);
	BCC     	Lower(cEmailBcc);
	SUBJECT 	SubStr(cAssunto,1,55);
	BODY    	cMsg;
	RESULT lResult
	
	If !lResult
		//Erro no envio do email
		GET MAIL ERROR cError
		
		MsgInfo(cError,OemToAnsi("Aten��o"))
	Else 
   		MsgInfo("Email enviado com sucesso")
	EndIf
	
	DISCONNECT SMTP SERVER
Else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	MsgInfo(cError,OemToAnsi("Aten��o"))
EndIf

Return(.T.)   

/////////////////////////////////////////////////////////////////////////////
//
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg, Len(SX1->X1_GRUPO)," " ) // Incluido por Sandro em 18/11/09.

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

AADD(aRegs,{cPerg,"01","Encerramento de         ?","","","mv_ch1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Encerramento At�        ?","","","mv_ch2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Assinatura de         ?","","","mv_ch3","D",8,0,0,"G","","MV_PAR03","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Assinatura At�        ?","","","mv_ch4","D",8,0,0,"G","","MV_PAR04","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Vendedor De        ?","","","mv_ch4","C",6,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"06","Vendedor At�       ?","","","mv_ch5","C",6,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","",'SA3'})
AADD(aRegs,{cPerg,"07","Fornecedor De      ?","","","mv_ch6","C",6,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
AADD(aRegs,{cPerg,"08","Fornecedor At�     ?","","","mv_ch7","C",6,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","",'SA2'})
AADD(aRegs,{cPerg,"09","Cliente De         ?","","","mv_ch8","C",6,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
AADD(aRegs,{cPerg,"10","Cliente At�        ?","","","mv_ch9","C",6,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","",'SA1'})
AADD(aRegs,{cPerg,"11","Produto De         ?","","","mv_cha","C",6,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","",'SB1'})
AADD(aRegs,{cPerg,"12","Produto At�        ?","","","mv_chb","C",6,0,0,"G","","MV_PAR12","","","","","","","","","","","","","","","","","","","","","","","","",'SB1'})
AADD(aRegs,{cPerg,"13","Grupo de Clientes de?","","","mv_chc","C",6,0,0,"G","","MV_PAR13","","","","","","","","","","","","","","","","","","","","","","","","",'ACY'})
AADD(aRegs,{cPerg,"14","Grupo de Clientes at�?","","","mv_chd","C",6,0,0,"G","","MV_PAR14","","","","","","","","","","","","","","","","","","","","","","","","",'ACY'})
AADD(aRegs,{cPerg,"15","Envia E-mail       ?","","","mv_che","N",1,0,1,"C","","MV_PAR15","Sim","","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"16","Sint�tico/Anal�tico?","","","mv_chf","N",1,0,1,"C","","MV_PAR16","Sint�tico","","","","","Anal�tico","","","","","","","",""})
AADD(aRegs,{cPerg,"17","Gera Arquivo       ?","","","mv_chg","N",1,0,1,"C","","MV_PAR17","Sim","","","","","Nao","","","","","","","",""})
AADD(aRegs,{cPerg,"18","Edita De	       ?","","","mv_chh","C",6,0,0,"G","","MV_PAR18","","","","","","","","","","","","","","","","","","","","","","","","",'UA1'})
AADD(aRegs,{cPerg,"19","Edital at�		   ?","","","mv_chi","C",6,0,0,"G","","MV_PAR19","","","","","","","","","","","","","","","","","","","","","","","","",'UA1'})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)
Return
///////////////////////////////////////////////////////////////////////////
