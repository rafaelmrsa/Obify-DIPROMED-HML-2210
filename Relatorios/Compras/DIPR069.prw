/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณDipr069() ณ Autor ณJailton B Santos-JBS   ณ Data ณ17/07/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Relatorio de notas fiscais recebidas dentro de um periodo  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especifico De Compras Dipromed                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ  Motivo da Alteracao                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ            ณ        ณ                                                 ณฑฑ
ฑฑณ            ณ        ณ                                                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#DEFINE say_tit 1
#DEFINE say_det 2
#DEFINE say_rep 3               

User Function Dipr069()

Local lQry1
Local aArea  := GetArea()

Private QRY1
Private nLastKey := 0
Private nTotVol  := 0
Private nTotVoG  := 0 
Private dDataRel := cTod('')
Private aDados   := {}
Private aRCampos := {}
Private aQuery   := {}
Private lEnd     := .f.
Private cPerg    := Padr("DIPR069",10)
Private aReturn  := {"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
//---------------------------------------------------------------------------------------
// Configura os dados do relatorio
//---------------------------------------------------------------------------------------
aAdd(aDados,"TRB_PC") 
aAdd(aDados,OemTOAnsi("Notas Fiscal Recebidas",72))    // 02
aAdd(aDados,OemToAnsi("",72))// 03
aAdd(aDados,OemToAnsi("",72))       // 04
aAdd(aDados,"G")              // 05
aAdd(aDados,200)              // 06
aAdd(aDados,"")               // 07
aAdd(aDados,"")               // 08
aAdd(aDados,OemTOAnsi("Notas Fiscal Recebidas",72))
aAdd(aDados,aReturn)          // 10
aAdd(aDados,"DIPR068")        // 11
//aAdd(aDados,{{||.t.},{|| .t.}})// 12
aAdd(aDados,{{||fQuebra()},{|| fFinal()}})// 12

aAdd(aDados,Nil)              // 13
//---------------------------------------------------------------------------------------
// Cria o grupo de perguntas
//---------------------------------------------------------------------------------------
fAjustSX1()
If !Pergunte(cPerg, .T.)
    Return(.F.)
EndIf
//---------------------------------------------------------------------------------------
aDados[07] := "Data de " + Dtoc(MV_PAR01)+"  ate " + Dtoc(MV_PAR02)
//---------------------------------------------------------------------------------------
// Campos do relatorio
//---------------------------------------------------------------------------------------
aAdd(aRCampos,{"F1_DTCHEGA" ,"",AvSx3("F1_DTCHEGA",5),AvSx3("F1_DTCHEGA",6)})
aAdd(aRCampos,{"F1_HRCHEGA" ,"",AvSx3("F1_HRCHEGA",5),AvSx3("F1_HRCHEGA",6)})
aAdd(aRCampos,{"F1_HRCOINI" ,"",AvSx3("F1_HRCOINI",5),AvSx3("F1_HRCOINI",6)})
aAdd(aRCampos,{"F1_HRCOFIN" ,"",AvSx3("F1_HRCOFIN",5),AvSx3("F1_HRCOFIN",6)})
aAdd(aRCampos,{"F1_DOC" ,"",AvSx3("F1_DOC",5),AvSx3("F1_DOC",6)})
aAdd(aRCampos,{"F1_SERIE" ,"",AvSx3("F1_SERIE",5),AvSx3("F1_SERIE",6)})
aAdd(aRCampos,{"F1_FORNECE" ,"",AvSx3("F1_FORNECE",5),AvSx3("F1_FORNECE",6)})
aAdd(aRCampos,{"F1_LOJA" ,"",AvSx3("F1_LOJA",5),AvSx3("F1_LOJA",6)})
aAdd(aRCampos,{"A2_NREDUZ" ,"",AvSx3("A2_NREDUZ",5),AvSx3("A2_NREDUZ",6)})
//aAdd(aRCampos,{"F1_CONFERE" ,"",AvSx3("F1_CONFERE",5),AvSx3("F1_CONFERE",6)})
aAdd(aRCampos,{"ZC_NOME" ,"","Nome Conferente",AvSx3("ZC_NOME",6)})
//aAdd(aRCampos,{"F1_DTENTRE" ,"",AvSx3("F1_DTENTRE",5),AvSx3("F1_DTENTRE",6)})
//aAdd(aRCampos,{"F1_HRENTRE" ,"",AvSx3("F1_HRENTRE",5),AvSx3("F1_HRENTRE",6)})
//aAdd(aRCampos,{"F1_NOMCONT" ,"",AvSx3("F1_NOMCONT",5),AvSx3("F1_NOMCONT",6)})
//aAdd(aRCampos,{"F1_FONE" ,"",AvSx3("F1_FONE",5),AvSx3("F1_FONE",6)})
aAdd(aRCampos,{"F1_TRANSP" ,"",AvSx3("F1_TRANSP",5),AvSx3("F1_TRANSP",6)})
aAdd(aRCampos,{"A4_NREDUZ" ,"",AvSx3("A4_NREDUZ",5),AvSx3("A4_NREDUZ",6)})
aAdd(aRCampos,{{|| Transform(TRB_PC->F1_VOLUMES,"@e 999,999,999")} ,"",AvSx3("F1_VOLUMES",5),""})

aRCampos := E_CriaRCampos(aRCampos,"E")

Processa({|| lQry1 := fQuery()},"Notas Fiscais...",,.t.)

Begin Sequence

    If !lQry1
	    MsgInfo("Nใo encontrado dados que satisfa็am aos parametros informados pelo usuario! ","Aten็ใo")
	    Break
     EndIf            

     aReturn	:= {"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
     aDados[10] :=aReturn 
     //---------------------------------------------------------------------------------------
     // Mostra o relatorio
     //---------------------------------------------------------------------------------------
     TRB_PC->(dbGotop())
     TRB_PC->(E_Report(aDados,aRCampos))

End Sequence     

TRB_PC->(dbCloseArea())

Return(.t.)  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery()  บAutor  ณJailton B Santos-JBSบ Data ณ 17/07/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca todas as agendas existentes dentro do periodo infor- บฑฑ
ฑฑบ          ณ mado pelo usuario.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Compras Dipromed                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION fQuery()

Procregua(2)
IncProc()

BeginSql Alias "TRB_PC"
	
	COLUMN F1_DTCHEGA AS DATE
	COLUMN F1_HRENTRE AS DATE
	
	Select DISTINCT F1_DTCHEGA,F1_HRCHEGA,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,A2_NREDUZ,F1_CONFERE,ZC_NOME,F1_HRCOINI,F1_HRCOFIN,F1_DTENTRE,F1_HRENTRE,F1_NOMCONT,F1_FONE,F1_TRANSP,A4_NREDUZ,F1_VOLUMES
	
	From %Table:SF1% SF1
	
	Inner Join %Table:SA2% SA2  on A2_FILIAL = %xFilial:SA2%
	                            and A2_COD    = F1_FORNECE
	                            and A2_LOJA   = F1_LOJA
	                            and SA2.%notdel%
	
	Inner Join %Table:SA4% SA4  on A4_FILIAL = %xFilial:SA4%
	                            and A4_COD    = F1_TRANSP
	                            and SA4.%notdel%
	
	
	Inner Join %Table:SZC% SZC  on ZC_FILIAL = %xFilial:SZC%
	                            and ZC_CODIGO = F1_CONFERE
	                            and SZC.%notdel%
	
	Where F1_FILIAL = %xFilial:SF1%
	  and F1_DTDIGIT between %Exp:MV_PAR01% and %Exp:MV_PAR02%
	  and SF1.%notdel%
	
	Order By F1_DTCHEGA,F1_HRCHEGA,F1_CONFERE,F1_FORNECE,F1_LOJA
	
EndSql         

IncProc()

Return(!TRB_PC->( EOF().and.BOF()))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfAjustSX1()บAutor ณJailton B Santos-JBSบ Data ณ 17/07/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o Grupo de Perguntas no SX1                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico Compras Dipromed                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAjustSX1(cNome)

Local nId_SX1
Local aRegs	:= {}
Local aArea := GetArea()
Local lRet  := .T.
                   
AAdd(aRegs,{"01","Data de                    ","mv_ch1","D",08,0,0,"G","mv_par01","" ,"" ,"",""})
AAdd(aRegs,{"02","Data ate                   ","mv_ch2","D",08,0,0,"G","mv_par02","" ,"" ,"",""})
//AAdd(aRegs,{"02","Transportadora           ","mv_ch1","C",06,0,0,"G","mv_par02","" ,"" ,"","SA4"})
//AAdd(aRegs,{"03","Fornecedor               ","mv_ch1","C",06,0,0,"G","mv_par03","" ,"" ,"","SA2"})

DbSelectArea("SX1")
DbSetOrder(1)

For nId_SX1:=1 to Len(aRegs)

	DbSeek( cPerg + aRegs[nId_SX1][1] )

	If !Found() .or. aRegs[nId_SX1][2]<>X1_PERGUNT    
	
		RecLock("SX1",!Found())
	
		SX1->X1_GRUPO   := cPerg
		SX1->X1_ORDEM   := aRegs[nId_SX1][01]
		SX1->X1_PERGUNT := aRegs[nId_SX1][02]
		SX1->X1_VARIAVL := aRegs[nId_SX1][03]
		SX1->X1_TIPO    := aRegs[nId_SX1][04]
		SX1->X1_TAMANHO := aRegs[nId_SX1][05]
		SX1->X1_DECIMAL := aRegs[nId_SX1][06]
		SX1->X1_PRESEL  := aRegs[nId_SX1][07]
		SX1->X1_GSC     := aRegs[nId_SX1][08]
		SX1->X1_VAR01   := aRegs[nId_SX1][09]
		SX1->X1_DEF01   := aRegs[nId_SX1][10]
		SX1->X1_DEF02   := aRegs[nId_SX1][11]
		SX1->X1_DEF03   := aRegs[nId_SX1][12]
		SX1->X1_F3      := aRegs[nId_SX1][13]
	
		MsUnlock()
	
	Endif

Next nId_SX1
RestArea(aArea)
Return(lRet)   

Static Function fQuebra()

If dDataRel <> TRB_PC->F1_DTCHEGA .and. dDataRel <> cTod('').or.TRB_PC->(EOF())  
   
   fCabec() 
   
   linha++
   @ linha, T_LEN[13,2] psay '------------'
   linha++  
   @ linha, T_LEN[11,2] psay 'Total de Volumes por Dia'
   @ linha, T_LEN[13,2] psay Transform(nTotVol,"@ke 999,999,999")
   linha++  
   nTotVol := 0
EndIf 
  
dDataRel := TRB_PC->F1_DTCHEGA
nTotVol += TRB_PC->F1_VOLUMES
nTotVoG += TRB_PC->F1_VOLUMES

Return(.T.)

Static Function fFinal()

If TRB_PC->(EOF())
   
   fCabec() 
   
   linha++
   @ linha, T_LEN[13,2] psay '------------'
   linha++  
   @ linha, T_LEN[11,2] psay 'Total Volumes por Dia'
   @ linha, T_LEN[13,2] psay Transform(nTotVol,"@ke 999,999,999")
   linha++  

   fCabec()
   
   linha++
   @ linha, T_LEN[13,2] psay '------------'
   linha++  
   @ linha, T_LEN[11,2] psay 'Total Geral'
   @ linha, T_LEN[13,2] psay Transform(nTotVoG,"@ke 999,999,999")
   linha++  
EndIf   

Return(.T.)

Static Function fCabec()

local b_lin   := {|valor,ind| F_Ler_Tab(R_Campos,ind)}
Local tamanho := Adados[5]
Local nAsterisco

Do Case
	Case Tamanho == "P"; nAsterisco := 080
	Case Tamanho == "M"; nAsterisco := 132
	Case Tamanho == "G"; nAsterisco := 220
EndCase                

If Linha>55
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_COMP"))

	If Empty(cabec1) .And. Empty(cabec2)
		@ PROW()+1,T_Len[1,2]-1 PSAY REPLI('*',nAsterisco)
	Endif             

	Linha:=PROW()+1 ; l_tag:=say_tit
	AEVAL(R_Campos, b_lin)
	Linha++ ; l_tag:=say_rep
	AEVAL(R_Campos, b_lin)
Endif
Return(.T.)