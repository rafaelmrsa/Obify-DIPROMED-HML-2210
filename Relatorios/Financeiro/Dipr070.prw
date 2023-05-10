/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณDipr070() ณ Autor ณJailton B Santos-JBS   ณ Data ณ24/07/2010ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Relatorio contas bancarias com movento dentro de um periodoณฑฑ
ฑฑณ          ณ informado pelo usuario                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Especifico Financeiro Dipromed                             ณฑฑ
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

User Function Dipr070()

Local lQry1
Local aArea  := GetArea()

Private QRY1
Private nLastKey := 0 
Private cBanco   := ''
Private dDataRel := cTod('')
Private aDados   := {}
Private aRCampos := {}
Private aQuery   := {}
Private lEnd     := .f.
Private cPerg    := Padr("DIPR070",10)
Private aReturn  := {"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
//---------------------------------------------------------------------------------------
// Configura os dados do relatorio
//---------------------------------------------------------------------------------------
aAdd(aDados,"TRB") 
aAdd(aDados,OemTOAnsi("Contas com Movimento no Periodo",72))    // 02
aAdd(aDados,OemToAnsi("",72))// 03
aAdd(aDados,OemToAnsi("",72))       // 04
aAdd(aDados,"P")              // 05
aAdd(aDados,80)               // 06
aAdd(aDados,"")               // 07
aAdd(aDados,"")               // 08
aAdd(aDados,OemTOAnsi("Contas com Movimento no Periodo",72))
aAdd(aDados,aReturn)          // 10
aAdd(aDados,"DIPR070")        // 11
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
aAdd(aRCampos,{{|| Space(AvSx3('E8_BANCO'  ,3))}       ,"" ,AvSx3('E8_BANCO'  ,5) ,""})
aAdd(aRCampos,{{|| Space(AvSx3('A6_NREDUZ' ,3))}       ,"" ,AvSx3('A6_NREDUZ' ,5) ,""})
aAdd(aRCampos,{{|| Space(AvSx3('E8_AGENCIA',3))}       ,"" ,AvSx3('E8_AGENCIA',5) ,""})
aAdd(aRCampos,{{|| Space(AvSx3('E8_CONTA'  ,3))}       ,"" ,AvSx3('E8_CONTA'  ,5) ,""})
aAdd(aRCampos,{{|| Padr(MesExtenso(Val(TRB->MES)),12)},"" ,Padr("Mes",12)        ,""})
aAdd(aRCampos,{"ANO"                                    ,"" ,Padr("Ano",12)        ,""})

aRCampos := E_CriaRCampos(aRCampos,"E")

Processa({|| lQry1 := fQuery()},"Notas Fiscais...",,.t.)

Begin Sequence

    If !lQry1
	    Aviso('Aten็ใo','Nใo encontrado dados que satisfa็am aos parametros informados pelo usuario!',{'Ok'})
	    Break
     EndIf            

     aReturn	:= {"Zebrado", 1,"Administracao", 1, 2, 1,"",1}
     aDados[10] :=aReturn 
     //---------------------------------------------------------------------------------------
     // Mostra o relatorio
     //---------------------------------------------------------------------------------------
     TRB->(dbGotop())
     TRB->(E_Report(aDados,aRCampos))

End Sequence     

TRB->(dbCloseArea())

Return(.t.)  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfQuery()  บAutor  ณJailton B Santos-JBSบ Data ณ 24/07/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca todos os meses com movimento bancario dentro do peri-บฑฑ
ฑฑบ          ณ odo informado pelo usuario                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico Financeiro Dipromed                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION fQuery()

Procregua(2)
IncProc()

BeginSql Alias "TRB"
	
	Select Distinct E8_BANCO, E8_AGENCIA, E8_CONTA, Left(E8_DTSALAT,6) MES_ANO, A6_NREDUZ, A6_NOMEAGE,Left(E8_DTSALAT,4) ANO,SubString(E8_DTSALAT,5,2) MES
	  From %Table:SE8% SE8
	
	 Inner Join %Table:SA6% SA6  on A6_FILIAL = %xFilial:SA6%
	                            and A6_COD = E8_BANCO
                                and A6_AGENCIA = E8_AGENCIA
	                            and A6_NUMCON = E8_CONTA
	                            and SA6.%notdel%
	
	 Where E8_FILIAL = %xFilial:SE8%
	   and E8_DTSALAT between %Exp:MV_PAR01% and %Exp:MV_PAR02%
	   and SE8.%notdel%
	
	 Order By E8_BANCO,E8_AGENCIA,E8_CONTA,ANO,MES
	
EndSql         

IncProc()

Return(!TRB->( EOF().and.BOF()))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfAjustSX1()บAutor ณJailton B Santos-JBSบ Data ณ 24/07/2010  บฑฑ
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
                           
If cBanco <>  TRB->E8_BANCO + TRB->E8_AGENCIA + TRB->E8_CONTA          

    linha++
    @ linha, T_LEN[1,2] psay Padr(TRB->E8_BANCO  ,len(AvSx3('E8_BANCO'  ,5))) + ' ' +;
                              Padr(TRB->A6_NREDUZ ,AvSx3('A6_NREDUZ' ,3)) + ' ' +;
                              Padr(TRB->E8_AGENCIA,len(AvSx3('E8_AGENCIA',5))) + ' ' +;
                              Padr(TRB->E8_CONTA  ,AvSx3('E8_CONTA'  ,3))
EndIf
cBanco := TRB->E8_BANCO + TRB->E8_AGENCIA + TRB->E8_CONTA          
Return(.T.)

Static Function fFinal()
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