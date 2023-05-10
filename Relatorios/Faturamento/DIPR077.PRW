/*====================================================================================\
|Programa  | DIPR077.PRW  | Autor  | Reginaldo Borges, RSB   | Data | 13/03/2014      |
|=====================================================================================|
|Descrição | Gera o relatorio do cadastro de produtos,                                |
|          | a partir de um numero inicial ate o numero final.                        |
|          | Ambos fornecidos pelo usuario.   			                              |
|          |                                                                          |
|=====================================================================================|
|Sintaxe   | DIPR077()                                                                |
|=====================================================================================|
|Uso       | Especifico DIPROMED  - Departamento de Qualidade                         |
|=====================================================================================|
|Histórico | 																		  |
\====================================================================================*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE ENTER CHR(13)+CHR(10)
*-------------------------------------*
User Function DIPR077()                
*-------------------------------------*

Local aDados:={}
Local lQuery
Local lWork
Private aReturn :={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
//Private aRCampos:={} 
Private cDestino   := "C:\EXCELL-DBF\"
Private _cDipUsr   := U_DipUsr() 
Private cQuery
Private aReturn:={"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
Private cString:="SB1"   

PRIVATE cPerg  	:= U_FPADR( "DIPR77","SX1","SX1->X1_GRUPO"," " ) //Função criada por Sandro em 19/11/09.

U_DIPPROC(ProcName(0),U_DipUsr()) //RSB 13/03/2014

AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)  
	Return
EndIf

    
Processa({|| lQuery := DIPR77FilQuery()},"Filtrando Produtos do Cadastro...",,.t.)

If !lQuery
	MsgInfo(;
	"Não encontrado dados que satisfaçam aos"+ENTER+;
	"parametros informados pelo usuario! ","Atenção")
	TRB->(dbCloseArea())
	Return(.t.)
EndIf   
       
TRB->(dbCloseArea())
Return
*----------------------------------*
STATIC FUNCTION DIPR77FilQuery()
*----------------------------------*
Local _x      
Local cArqExcell:= "\Excell-DBF\"+_cDipUsr+"-DIPR077" 

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Preparando os dados... ")
Next

                                                                                
cQuery := "SELECT B1_COD, B1_DESC, B1_UM, B1_PROC,B1_GRUPO, B1_REG_ANV, B1_DTV_ANV, B1_CANVISA, B1_RANVISA, B1_CAMTE, B1_DTCAMTE, B1_XQTDEMB, B1_PESOEMB, B1_LARGURA, "
cQuery += " B1_ALTURA, B1_COMPRIM, B1_XCUBEMB, B1_CODBAR, B1_LOTEDIP, B1_TIPOCQ, B1_XQTDSEC,B1_XLARSEC, B1_XALTSEC, B1_XCOMSEC, B1_XCUBSEC, "
cQuery += " B1_XBARSEC, B1_PESO, B1_PESBRU, B1_XLARPRI, B1_XALTPRI, B1_XCOMPRI, B1_XCUBPRI, B1_XBARRUM, B1_XTPEMBV " 
cQuery += " FROM " + RetSQLName("SB1")
cQuery += " WHERE B1_FILIAL = '" + xFilial('SB1') + "'"
cQuery += "    AND "+RetSQLName("SB1")+".D_E_L_E_T_ <> '*'"
cQuery += "    AND B1_COD   BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
cQuery += "    AND B1_PROC  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "  
cQuery += "    AND B1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "  
cQuery += " ORDER BY B1_COD, B1_PROC, B1_GRUPO"


#xcommand TCQUERY <sql_expr>                          ;
[ALIAS <a>]                                           ;
[<new: NEW>]                                          ;
[SERVER <(server)>]                                   ;
[ENVIRONMENT <(environment)>]                         ;
=> dbUseArea(                                         ;
<.new.>,                                              ;
"TOPCONN",                                            ;
TCGENQRY(<(server)>,<(environment)>,<sql_expr>),      ;
<(a)>, .F., .T.)
                           
TcQuery cQuery NEW ALIAS "TRB"

DbSelectArea("TRB")
_aCampos := TRB->(DbStruct())
nTotReg := Contar("TRB","!Eof()")
TRB->(dbGotop())	
ProcRegua(nTotReg)	
aCols := Array(nTotReg,Len(_aCampos))
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

DbSelectArea("TRB")
TRB->(dbGotop())

ProcRegua(15000)
For _x := 1 to 5000
	IncProc( "Classificando Produtos... ")
Next


// Gerando arquivo excel - RB 18/10/2013
COPY TO &cArqExcell VIA "DBFCDX"

MakeDir(cDestino) // CRIA DIRETÓRIO CASO NÃO EXISTA
CpyS2T(cArqExcell+".dbf",cDestino,.T.) // COPIA ARQUIVO PARA MAQUINA DO USUÁRIO
	
// Buscando e apagando arquivos temporários - MCVN 27/08/10
aTmp := Directory( cDestino+"*.tmp" )
For nI:= 1 to Len(aTmp)
	fErase(cDestino+aTmp[nI,1])
Next nI 


Return(!TRB->(BOF().and.EOF()))


/////////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

//------------ Grupo/Ordem/Pergunta/PERGING/PERGESP/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3

aAdd(aRegs,{cPerg,"1","Do  Produto    ?","","","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"2","Ate Produto    ?","","","mv_ch2","C",6,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"3","Do  Fornecedor ?","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
aAdd(aRegs,{cPerg,"4","Ate Fornecedor ?","","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
aAdd(aRegs,{cPerg,"5","Do  Grupo      ?","","","mv_ch5","C",4,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
aAdd(aRegs,{cPerg,"6","Ate Grupo      ?","","","mv_ch6","C",4,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})


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